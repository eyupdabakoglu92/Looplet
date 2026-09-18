#!/usr/bin/env sh
set -eu

usage() {
  printf '%s\n' 'Usage: sh ai-system/tools/workflow-state-audit.sh [ROOT] [--local|--structure-only]' \
    'Optional positive byte budgets:' \
    '  WORKFLOW_MAX_SYSTEM_STATE_BYTES (default 24000)' \
    '  WORKFLOW_MAX_FEATURE_BOARD_BYTES (default 24000)' \
    '  WORKFLOW_MAX_ORCHESTRATION_BYTES (default 40000)'
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  -*) usage >&2; exit 1 ;;
esac
if [ "$#" -gt 2 ]; then usage >&2; exit 1; fi
ROOT=${1:-ai-system}
MODE=${2:-full}
case "$MODE" in full|--local|--structure-only) ;; *) usage >&2; exit 1 ;; esac
MAX_SYSTEM_STATE_BYTES=${WORKFLOW_MAX_SYSTEM_STATE_BYTES:-24000}
MAX_FEATURE_BOARD_BYTES=${WORKFLOW_MAX_FEATURE_BOARD_BYTES:-24000}
MAX_ORCHESTRATION_BYTES=${WORKFLOW_MAX_ORCHESTRATION_BYTES:-40000}
ERRORS=0

fail() {
  printf 'ERROR: %s\n' "$*"
  ERRORS=$((ERRORS + 1))
}

for budget in "$MAX_SYSTEM_STATE_BYTES" "$MAX_FEATURE_BOARD_BYTES" "$MAX_ORCHESTRATION_BYTES"; do
  case "$budget" in
    ''|*[!0-9]*) echo 'ERROR: budgets must be positive integers' >&2; exit 1 ;;
  esac
  if ! [ "$budget" -gt 0 ] 2>/dev/null; then
    echo 'ERROR: budgets must be positive integers' >&2
    exit 1
  fi
done

if [ ! -d "$ROOT" ]; then
  printf 'ERROR: root directory not found: %s\n' "$ROOT" >&2
  exit 1
fi

# A field must contain exactly one value and occur once outside fenced examples.
# Strip a Markdown bullet only when it has following whitespace: "-" is a value.
section_value() {
  awk -v heading="$2" '
    {
      sub(/\r$/, "")
      line = $0
      sub(/^[[:space:]]+/, "", line)
      sub(/[[:space:]]+$/, "", line)
      if (fence != "") {
        if (match(line, /^(```+|~~~+)/)) {
          marker = substr(line, 1, 1)
          tail = substr(line, RLENGTH + 1)
          if (marker == fence && RLENGTH >= fence_length && tail !~ /[^[:space:]]/) fence = ""
        }
        next
      }
      if (comment) {
        end = index(line, "-->")
        if (!end) next
        line = substr(line, end + 3)
        comment = 0
      }
      while ((start = index(line, "<!--")) > 0) {
        rest = substr(line, start + 4)
        end = index(rest, "-->")
        if (!end) {
          line = substr(line, 1, start - 1)
          comment = 1
          break
        }
        line = substr(line, 1, start - 1) substr(rest, end + 3)
      }
      sub(/^[[:space:]]+/, "", line)
      sub(/[[:space:]]+$/, "", line)
      if (match(line, /^(```+|~~~+)/)) {
        fence = substr(line, 1, 1)
        fence_length = RLENGTH
        next
      }
      if (line == heading) { headers++; active = 1; next }
      if (line ~ /^#+[[:space:]]/) active = 0
      if (!active || line == "" || line == "---") next
      sub(/^[-*+][[:space:]]+/, "", line)
      if (line ~ /^\*\*.*\*\*$/) {
        line = substr(line, 3, length(line) - 4)
      } else if (line ~ /^`.*`$/) {
        line = substr(line, 2, length(line) - 2)
      }
      values++
      value = line
    }
    END {
      if (headers != 1 || values != 1) {
        printf "<invalid field: %d headings, %d values>\n", headers, values
      } else {
        print value
      }
    }
  ' "$1"
}

valid_status() {
  case "$1" in
    "Not Started"|"In Progress"|"In QA"|"In Release"|"Rework"|"Done"|"Blocked"|"Closed") return 0 ;;
    *) return 1 ;;
  esac
}

valid_role() {
  case "$1" in
    "Product Owner"|"Tech Lead"|"Technical Analyst"|"Content Designer"|"UI Designer"|"Backend Developer"|"Frontend/Mobile Developer"|"Game Developer (Unity)"|"DevOps/Release Engineer"|"QA"|"Project Setup") return 0 ;;
    *) return 1 ;;
  esac
}

check_budget() {
  [ -f "$1" ] || return 0
  count=$(wc -c < "$1" | tr -d '[:space:]')
  if [ "$count" -gt "$2" ]; then
    fail "$1 snapshot is $count bytes; limit is $2. Move history/detail to a history artifact."
  fi
}

check_budget "$ROOT/system-state.md" "$MAX_SYSTEM_STATE_BYTES"
check_budget "$ROOT/feature-board.md" "$MAX_FEATURE_BOARD_BYTES"

for snapshot in "$ROOT/system-state.md" "$ROOT/feature-board.md"; do
  if [ ! -f "$snapshot" ]; then
    fail "$snapshot is a required live snapshot but is missing."
    continue
  fi
  if LC_ALL=C grep -Eiq '^[#*[:space:]]*superseded([[:space:]:-]|$)' "$snapshot"; then
    fail "$snapshot contains a superseded history entry in a live snapshot."
  fi
done

found_orchestration=0
for file in "$ROOT"/features/*/orchestration.md; do
  [ -f "$file" ] || continue
  found_orchestration=$((found_orchestration + 1))
  check_budget "$file" "$MAX_ORCHESTRATION_BYTES"

  status=$(section_value "$file" "## Current Status")
  owner=$(section_value "$file" "## Current Owner")
  next=$(section_value "$file" "## Next Role")

  if ! valid_status "$status"; then
    fail "$file Current Status must contain exactly one valid status."
  fi
  if [ "$owner" != "-" ] && ! valid_role "$owner"; then
    fail "$file Current Owner must contain exactly one canonical role or '-'."
  fi
  if [ "$next" != "-" ] && [ "$next" != "Closed" ] && ! valid_role "$next"; then
    fail "$file Next Role must contain exactly one canonical role, Closed, or '-'."
  fi

  case "$status" in
    Done|Closed)
      [ "$owner" = "-" ] || fail "$file is terminal but Current Owner is not '-'."
      case "$next" in -|Closed) ;; *) fail "$file is terminal but Next Role is not closed." ;; esac
      action=$(section_value "$file" "## Next Action")
      case "$action" in -|Closed) ;; *) fail "$file is terminal but Next Action is not closed." ;; esac
      ledger=$(section_value "$file" "## Active Task Ledger")
      [ "$ledger" = "None" ] || fail "$file is terminal but Active Task Ledger is not None."
      ;;
  esac
done

printf '# Workflow State Audit\nRoot: %s\nOrchestration files checked: %s\n' "$ROOT" "$found_orchestration"
printf 'Byte budgets: system-state=%s feature-board=%s orchestration=%s\n' \
  "$MAX_SYSTEM_STATE_BYTES" "$MAX_FEATURE_BOARD_BYTES" "$MAX_ORCHESTRATION_BYTES"
echo 'Structural scope: snapshot size, history entries, exact headers and terminal fields.'
if [ "$ERRORS" -gt 0 ]; then
  printf 'Result: FAIL (%s issue(s))\n' "$ERRORS"
  exit 2
fi
echo 'Structural Result: PASS'
if [ "$MODE" = "--structure-only" ]; then
  echo 'Diagnostic only: workflow handoff/Done gate NOT evaluated.'
  exit 0
fi
if ! command -v node >/dev/null 2>&1; then
  echo 'ERROR: full/local workflow audit requires Node.js 18+; structural-only is not a handoff gate.' >&2
  exit 1
fi
if ! node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 18 ? 0 : 1)'; then
  echo 'ERROR: Node.js 18+ is required.' >&2
  exit 1
fi
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ "$MODE" = "--local" ]; then
  exec node "$SCRIPT_DIR/workflow-flow-audit.mjs" "$ROOT" --local
fi
exec node "$SCRIPT_DIR/workflow-flow-audit.mjs" "$ROOT"
