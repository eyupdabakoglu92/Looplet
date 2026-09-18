#!/usr/bin/env sh
set -eu

ROOT="ai-system"
ROOT_SET=0
ESTIMATOR="char4"
TOKENIZER_ENCODING="${TOKENIZER_ENCODING:-cl100k_base}"
ROLE_FILTER=""
BUDGET_TOKENS=""
CUSTOM_BASELINE=""
LIST_ROLES=0

usage() {
  cat <<'EOF'
Usage: sh ai-system/tools/token-cost-audit.sh [ROOT] [options]

Options:
  --estimator char4|auto|tiktoken
      Token estimator to use for selected totals. Default: char4.
      auto uses tiktoken when python3+tiktoken are available, otherwise char4.
  --encoding NAME
      tiktoken encoding name. Default: cl100k_base.
  --role ROLE
      Show only the selected role baseline row. Examples: qa, backend, tech-lead.
  --list-roles
      Print supported role filters and exit.
  --baseline TOKENS
      Compare the selected total against a custom baseline.
  --budget TOKENS
      Fail with exit code 2 when the selected total exceeds this budget.
  -h, --help
      Show this help.
EOF
}

print_roles() {
  cat <<'EOF'
Supported role filters:
  product-owner, po
  tech-lead, tl
  technical-analyst, ta
  content-designer, content
  ui-designer, ui
  backend, be
  frontend, fe
  game-developer-unity, game-developer, gamedev, unity, game
  devops, release
  qa
  project-setup, setup
EOF
}

is_non_negative_integer() {
  case "$1" in
    ''|*[!0-9]*)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --estimator)
      [ "$#" -ge 2 ] || { echo "ERROR: --estimator requires a value" >&2; exit 1; }
      ESTIMATOR="$2"
      shift 2
      ;;
    --estimator=*)
      ESTIMATOR="${1#*=}"
      shift
      ;;
    --encoding)
      [ "$#" -ge 2 ] || { echo "ERROR: --encoding requires a value" >&2; exit 1; }
      TOKENIZER_ENCODING="$2"
      shift 2
      ;;
    --encoding=*)
      TOKENIZER_ENCODING="${1#*=}"
      shift
      ;;
    --role)
      [ "$#" -ge 2 ] || { echo "ERROR: --role requires a value" >&2; exit 1; }
      ROLE_FILTER="$2"
      shift 2
      ;;
    --role=*)
      ROLE_FILTER="${1#*=}"
      shift
      ;;
    --baseline)
      [ "$#" -ge 2 ] || { echo "ERROR: --baseline requires a value" >&2; exit 1; }
      CUSTOM_BASELINE="$2"
      shift 2
      ;;
    --baseline=*)
      CUSTOM_BASELINE="${1#*=}"
      shift
      ;;
    --budget)
      [ "$#" -ge 2 ] || { echo "ERROR: --budget requires a value" >&2; exit 1; }
      BUDGET_TOKENS="$2"
      shift 2
      ;;
    --budget=*)
      BUDGET_TOKENS="${1#*=}"
      shift
      ;;
    --list-roles)
      LIST_ROLES=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ "$ROOT_SET" -eq 1 ]; then
        echo "ERROR: multiple root directories provided: $ROOT and $1" >&2
        exit 1
      fi
      ROOT="$1"
      ROOT_SET=1
      shift
      ;;
  esac
done

if [ "$LIST_ROLES" -eq 1 ]; then
  print_roles
  exit 0
fi

case "$ESTIMATOR" in
  char4|auto|tiktoken)
    ;;
  *)
    echo "ERROR: unsupported estimator: $ESTIMATOR" >&2
    echo "Supported estimators: char4, auto, tiktoken" >&2
    exit 1
    ;;
esac

if [ -n "$BUDGET_TOKENS" ] && ! is_non_negative_integer "$BUDGET_TOKENS"; then
  echo "ERROR: --budget must be a non-negative integer" >&2
  exit 1
fi

if [ -n "$CUSTOM_BASELINE" ] && ! is_non_negative_integer "$CUSTOM_BASELINE"; then
  echo "ERROR: --baseline must be a non-negative integer" >&2
  exit 1
fi

if [ ! -d "$ROOT" ]; then
  echo "ERROR: root directory not found: $ROOT" >&2
  exit 1
fi

TMP="${TMPDIR:-/tmp}/ai-system-token-cost-audit.$$"
trap 'rm -f "$TMP"' EXIT
: > "$TMP"

normalize_count() {
  tr -d ' '
}

tokenizer_available() {
  command -v python3 >/dev/null 2>&1 && python3 -c 'import tiktoken' >/dev/null 2>&1
}

ACTIVE_ESTIMATOR="$ESTIMATOR"
ESTIMATOR_NOTE=""

case "$ESTIMATOR" in
  char4)
    ACTIVE_ESTIMATOR="char4"
    ;;
  auto)
    if tokenizer_available; then
      ACTIVE_ESTIMATOR="tiktoken"
    else
      ACTIVE_ESTIMATOR="char4"
      ESTIMATOR_NOTE="python3+tiktoken unavailable; auto fell back to chars/4"
    fi
    ;;
  tiktoken)
    if tokenizer_available; then
      ACTIVE_ESTIMATOR="tiktoken"
    else
      echo "ERROR: --estimator tiktoken requires python3 and the tiktoken package" >&2
      echo "Use --estimator auto for a safe fallback or --estimator char4 for dependency-free mode." >&2
      exit 1
    fi
    ;;
esac

if [ "$ACTIVE_ESTIMATOR" = "tiktoken" ]; then
  python3 -c 'import sys, tiktoken; tiktoken.get_encoding(sys.argv[1])' "$TOKENIZER_ENCODING" >/dev/null
  TOKEN_LABEL="tiktoken/$TOKENIZER_ENCODING"
  TOKEN_HEADER="Tok(tiktoken)"
else
  TOKEN_LABEL="chars/4"
  TOKEN_HEADER="Tok(c/4)"
fi

file_tokens_tiktoken() {
  file="$1"
  if [ ! -f "$file" ]; then
    echo "0"
    return
  fi

  python3 -c 'import sys, tiktoken
encoding = sys.argv[1]
path = sys.argv[2]
enc = tiktoken.get_encoding(encoding)
with open(path, "r", encoding="utf-8", errors="replace") as fh:
    data = fh.read()
print(len(enc.encode(data)))' "$TOKENIZER_ENCODING" "$file"
}

file_tokens_char4() {
  file="$1"
  if [ ! -f "$file" ]; then
    echo "0"
    return
  fi

  chars=$(wc -c < "$file" | normalize_count)
  echo $(( (chars + 3) / 4 ))
}

file_tokens_active() {
  file="$1"
  if [ "$ACTIVE_ESTIMATOR" = "tiktoken" ]; then
    file_tokens_tiktoken "$file"
  else
    file_tokens_char4 "$file"
  fi
}

estimate_file() {
  file="$1"
  lines=$(wc -l < "$file" | normalize_count)
  chars=$(wc -c < "$file" | normalize_count)
  tokens_char4=$(( (chars + 3) / 4 ))
  tokens_line13=$(( lines * 13 ))
  tokens_active="$tokens_char4"

  if [ "$ACTIVE_ESTIMATOR" = "tiktoken" ]; then
    tokens_active=$(file_tokens_tiktoken "$file")
  fi

  printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$file" "$lines" "$chars" "$tokens_active" "$tokens_char4" "$tokens_line13"
}

add_glob() {
  for file in "$@"; do
    [ -f "$file" ] || continue
    case "$file" in
      */prompt-alignment-matrix.md|*/prompt-boilerplate-map.md)
        continue
        ;;
    esac
    estimate_file "$file" >> "$TMP"
  done
}

role_key() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]'
}

role_selected() {
  name="$1"
  aliases="$2"

  [ -n "$ROLE_FILTER" ] || return 0

  wanted=$(role_key "$ROLE_FILTER")
  [ "$wanted" = "$(role_key "$name")" ] && return 0

  for alias in $aliases; do
    [ "$wanted" = "$alias" ] && return 0
  done

  return 1
}

PROFILE_COUNT=0

profile() {
  name="$1"
  aliases="$2"
  shift 2

  if ! role_selected "$name" "$aliases"; then
    return 0
  fi

  total=0
  missing=""

  for rel in "$@"; do
    file="$ROOT/$rel"
    if [ -f "$file" ]; then
      total=$(( total + $(file_tokens_active "$file") ))
    else
      if [ -z "$missing" ]; then
        missing="$rel"
      else
        missing="$missing, $rel"
      fi
    fi
  done

  if [ -z "$missing" ]; then
    missing="-"
  fi

  PROFILE_COUNT=$(( PROFILE_COUNT + 1 ))
  printf "%-28s %8s   %s\n" "$name" "$total" "$missing"
}

add_glob \
  "$ROOT"/prompts/*.md \
  "$ROOT"/prompt-*.md \
  "$ROOT"/role-execution-contract.md \
  "$ROOT"/orchestration-template.md \
  "$ROOT"/system-state.md \
  "$ROOT"/feature-board.md \
  "$ROOT"/design/*.md \
  "$ROOT"/product/*.md \
  "$ROOT"/project-authority/*.md \
  "$ROOT"/templates/*.md

echo "# Token Cost Audit"
echo
echo "Root: $ROOT"
echo "Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Estimator requested: $ESTIMATOR"
echo "Estimator active: $TOKEN_LABEL"
echo "Secondary estimator: lines*13"
[ -z "$ROLE_FILTER" ] || echo "Role filter: $ROLE_FILTER"
[ -z "$ESTIMATOR_NOTE" ] || echo "Estimator note: $ESTIMATOR_NOTE"
echo
CURRENT_FILES=$(awk -F '\t' 'END { print NR + 0 }' "$TMP")
CURRENT_LINES=$(awk -F '\t' '{ sum += $2 } END { print sum + 0 }' "$TMP")
CURRENT_CHARS=$(awk -F '\t' '{ sum += $3 } END { print sum + 0 }' "$TMP")
CURRENT_TOKENS_ACTIVE=$(awk -F '\t' '{ sum += $4 } END { print sum + 0 }' "$TMP")
CURRENT_TOKENS_CHAR4=$(awk -F '\t' '{ sum += $5 } END { print sum + 0 }' "$TMP")
CURRENT_TOKENS_LINE13=$(awk -F '\t' '{ sum += $6 } END { print sum + 0 }' "$TMP")

echo "## Totals"
printf "Files: %d\n" "$CURRENT_FILES"
printf "Lines: %d\n" "$CURRENT_LINES"
printf "Chars: %d\n" "$CURRENT_CHARS"
printf "Estimated tokens selected (%s): %d\n" "$TOKEN_LABEL" "$CURRENT_TOKENS_ACTIVE"
printf "Estimated tokens chars/4: %d\n" "$CURRENT_TOKENS_CHAR4"
printf "Estimated tokens lines*13: %d\n" "$CURRENT_TOKENS_LINE13"

if [ -n "$CUSTOM_BASELINE" ]; then
  CUSTOM_DELTA=$(( CURRENT_TOKENS_ACTIVE - CUSTOM_BASELINE ))
  echo
  echo "## Custom Baseline Delta"
  printf "%-20s %12s\n" "Baseline" "$CUSTOM_BASELINE"
  printf "%-20s %12s\n" "Current" "$CURRENT_TOKENS_ACTIVE"
  printf "%-20s %12s\n" "Delta" "$CUSTOM_DELTA"
fi

EXIT_CODE=0

if [ -n "$BUDGET_TOKENS" ]; then
  echo
  echo "## Budget Check"
  printf "%-20s %12s\n" "Budget" "$BUDGET_TOKENS"
  printf "%-20s %12s\n" "Current" "$CURRENT_TOKENS_ACTIVE"
  if [ "$CURRENT_TOKENS_ACTIVE" -le "$BUDGET_TOKENS" ]; then
    echo "Result: PASS"
  else
    echo "Result: FAIL"
    EXIT_CODE=2
  fi
fi

SNAPSHOT_PHASE6_TOKENS=67277
SNAPSHOT_PHASE7_TOKENS=66852
DELTA_PHASE7=$(( CURRENT_TOKENS_CHAR4 - SNAPSHOT_PHASE7_TOKENS ))

echo
echo "## Recorded Baseline Snapshots (chars/4)"
printf "%-28s %12s %12s\n" "Snapshot" "Tok(c/4)" "Delta"
printf "%-28s %12s %12s\n" "Phase 6 post-doc-sync" "$SNAPSHOT_PHASE6_TOKENS" "-"
printf "%-28s %12s %12s\n" "Phase 7 post-cleanup" "$SNAPSHOT_PHASE7_TOKENS" "-"
printf "%-28s %12s %12s\n" "Current" "$CURRENT_TOKENS_CHAR4" "$DELTA_PHASE7"

echo
echo "## Largest Files"
if [ "$ACTIVE_ESTIMATOR" = "tiktoken" ]; then
  printf "%-64s %8s %8s %13s %10s %10s\n" "File" "Lines" "Chars" "$TOKEN_HEADER" "Tok(c/4)" "Tok(l*13)"
  sort -nr -k4 "$TMP" | awk -F '\t' 'NR <= 15 {
    printf "%-64s %8d %8d %13d %10d %10d\n", $1, $2, $3, $4, $5, $6
  }'
else
  printf "%-64s %8s %8s %10s %10s\n" "File" "Lines" "Chars" "Tok(c/4)" "Tok(l*13)"
  sort -nr -k4 "$TMP" | awk -F '\t' 'NR <= 15 {
    printf "%-64s %8d %8d %10d %10d\n", $1, $2, $3, $4, $6
  }'
fi

echo
echo "## Role Static Baselines"
echo "Approximate role prompt/core-document cost only. Referenced shared supplements are listed separately."
printf "%-28s %8s   %s\n" "Role" "$TOKEN_HEADER" "Missing"
profile "Product Owner" "productowner po product" \
  "prompts/product-owner.md" \
  "role-execution-contract.md" \
  "system-state.md" \
  "feature-board.md" \
  "product/product-prd.md"
profile "Tech Lead" "techlead tl tech" \
  "prompts/tech-lead.md" \
  "role-execution-contract.md" \
  "system-state.md" \
  "feature-board.md" \
  "product/product-prd.md" \
  "prompt-tech-lead-state-machine-standard.md" \
  "prompt-tech-lead-output-standard.md" \
  "prompt-input-authority-standard.md"
profile "Technical Analyst" "technicalanalyst ta analyst" \
  "prompts/technical-analyst.md" \
  "role-execution-contract.md" \
  "system-state.md"
profile "Content Designer" "contentdesigner content" \
  "prompts/content-designer.md" \
  "role-execution-contract.md" \
  "system-state.md"
profile "UI Designer" "uidesigner ui designer" \
  "prompts/ui-designer.md" \
  "role-execution-contract.md" \
  "system-state.md" \
  "design/design-doctrine.md" \
  "design/premium-ui-rubric.md"
profile "Backend Developer" "backenddeveloper backend be" \
  "prompts/backend-dev.md" \
  "role-execution-contract.md" \
  "system-state.md"
profile "Frontend Developer" "frontenddeveloper frontend fe" \
  "prompts/frontend-dev.md" \
  "role-execution-contract.md" \
  "system-state.md" \
  "design/design-doctrine.md" \
  "design/premium-ui-rubric.md"
profile "Game Developer Unity" "gamedeveloperunity gamedeveloper gamedev unity game" \
  "prompts/game-developer-unity.md" \
  "role-execution-contract.md" \
  "system-state.md" \
  "project-authority/platform.md"
profile "DevOps Release" "devopsrelease devops release" \
  "prompts/devops-release.md" \
  "role-execution-contract.md" \
  "system-state.md" \
  "project-authority/release.md"
profile "QA" "qa qualityassurance" \
  "prompts/qa.md" \
  "role-execution-contract.md" \
  "system-state.md" \
  "prompt-input-integrity-standard.md"
profile "Project Setup" "projectsetup setup project" \
  "prompts/project-setup.md" \
  "role-execution-contract.md" \
  "system-state.md" \
  "project-authority/platform.md" \
  "project-authority/setup-manifest.md"

if [ "$PROFILE_COUNT" -eq 0 ]; then
  echo "No role matched filter: $ROLE_FILTER"
  EXIT_CODE=1
fi

echo
echo "## Referenced Supplement Add-ons"
echo "Use these when a role prompt requires or references the shared supplement in its execution/output sections."
printf "%-36s %8s   %s\n" "Supplement" "$TOKEN_HEADER" "Typical roles"
printf "%-36s %8s   %s\n" "prompt-delivery-artifact-standard" \
  "$(file_tokens_active "$ROOT/prompt-delivery-artifact-standard.md")" \
  "Backend, Frontend, Game Developer, DevOps"
printf "%-36s %8s   %s\n" "prompt-delivery-footer-standard" \
  "$(file_tokens_active "$ROOT/prompt-delivery-footer-standard.md")" \
  "Backend, Frontend, Game Developer, DevOps, UI Designer, QA, Technical Analyst, Project Setup"
printf "%-36s %8s   %s\n" "prompt-execution-gating-standard" \
  "$(file_tokens_active "$ROOT/prompt-execution-gating-standard.md")" \
  "Delivery roles"
printf "%-36s %8s   %s\n" "prompt-input-authority-standard" \
  "$(file_tokens_active "$ROOT/prompt-input-authority-standard.md")" \
  "Tech Lead, Backend, Frontend, Game Developer, QA"
printf "%-36s %8s   %s\n" "prompt-input-integrity-standard" \
  "$(file_tokens_active "$ROOT/prompt-input-integrity-standard.md")" \
  "Frontend, Game Developer, UI Designer, QA"
printf "%-36s %8s   %s\n" "prompt-evidence-integrity-standard" \
  "$(file_tokens_active "$ROOT/prompt-evidence-integrity-standard.md")" \
  "Tech Lead, QA, Project Setup, Developer, DevOps, Content"

echo
echo "## Conditional Cost Add-ons"
printf "%-28s %8s   %s\n" "Add-on" "$TOKEN_HEADER" "Files"
printf "%-28s %8s   %s\n" "UI doctrine/rubric" \
  "$(( $(file_tokens_active "$ROOT/design/design-doctrine.md") + $(file_tokens_active "$ROOT/design/premium-ui-rubric.md") ))" \
  "design/design-doctrine.md, design/premium-ui-rubric.md"
printf "%-28s %8s   %s\n" "Release authority" \
  "$(file_tokens_active "$ROOT/project-authority/release.md")" \
  "project-authority/release.md"
printf "%-28s %8s   %s\n" "Platform authority" \
  "$(file_tokens_active "$ROOT/project-authority/platform.md")" \
  "project-authority/platform.md"
printf "%-28s %8s   %s\n" "Setup manifest" \
  "$(file_tokens_active "$ROOT/project-authority/setup-manifest.md")" \
  "project-authority/setup-manifest.md"

echo
echo "## Notes"
echo "* Default char4 mode is dependency-free and stable for trend tracking."
echo "* Optional tokenizer mode is available with --estimator auto or --estimator tiktoken when python3+tiktoken are installed."
echo "* tiktoken mode is still a static file report; runtime read gating decides actual activation cost."
echo "* Feature artifacts under features/* are excluded because they vary by project and active feature."
echo "* README, adoption guides, roadmap and validation notes are excluded because they are not role activation inputs."
echo "* Alignment and boilerplate maps are excluded because they are summary/reference documents."
echo "* Role baselines count static prompt/core files only; referenced shared supplements are reported as add-ons."
echo "* Runtime read gating still decides actual cost."

exit "$EXIT_CODE"
