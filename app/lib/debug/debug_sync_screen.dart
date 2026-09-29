import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../firebase_emulator.dart' show firebaseEmulatorHost;
import '../design/tokens.dart';
import '../persistence/app_database.dart';
import '../persistence/fake_daily_result_producer.dart';
import '../persistence/persistence_providers.dart';
import '../persistence/sync_providers.dart';

/// Debug builds only (F08 `architecture.md` Activation A3): triggers the
/// [FakeDailyResultProducer] without a Daily screen, so the `sync_queue` →
/// `submitDailyResultV1` path can be run end to end against the Firebase
/// emulator. Reached from Home's debug row; the route exists only under
/// `kDebugMode` (`app_router.dart`). Players never see it — plain Material.
///
/// "produce + leave" pops this screen at once: the drain it started belongs to
/// the session-level sync service and must still complete (the Ownership
/// check, F08.LIFECYCLE).
class DebugSyncScreen extends ConsumerStatefulWidget {
  const DebugSyncScreen({super.key});

  @override
  ConsumerState<DebugSyncScreen> createState() => _DebugSyncScreenState();
}

class _DebugSyncScreenState extends ConsumerState<DebugSyncScreen> {
  late final TextEditingController _date = TextEditingController(
    text: _localDate(DateTime.now()),
  );
  String _status = '';

  static String _localDate(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';

  /// A fresh `dailyDate` (a new idempotency key) without typing.
  void _shiftDate(int days) {
    final current = DateTime.tryParse(_date.text.trim()) ?? DateTime.now();
    _date.text = _localDate(current.add(Duration(days: days)));
  }

  @override
  void dispose() {
    _date.dispose();
    super.dispose();
  }

  /// Produces the fake first run for the entered date and drains. Everything
  /// captured here is session-level (repos + the sync service), not this
  /// widget, so it runs to the end after a pop.
  Future<String> _produceAndDrain() async {
    final sync = ref.read(dailyResultSyncServiceProvider);
    final producer = FakeDailyResultProducer(
      player: ref.read(playerRepoProvider),
      daily: ref.read(dailyRepoProvider),
      sync: sync,
    );
    final date = _date.text.trim();
    final outcome = await producer.produce(
      dailyDate: date,
      dailyId: 'fake-daily-tr-$date',
      completedAtUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    debugPrint('debug-sync: produced $date → $outcome');
    await sync.drain();
    debugPrint('debug-sync: drain after produce $date done');
    return '$date → ${outcome?.name}';
  }

  Future<void> _run(Future<String> Function() work) async {
    final result = await work();
    if (mounted) setState(() => _status = result);
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final db = ref.watch(appDatabaseProvider);
    final disabled = ref.watch(debugSyncDisabledProvider);
    final host = firebaseEmulatorHost(debugBuild: kDebugMode);
    return Scaffold(
      appBar: AppBar(title: const Text('debug · sync')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('emulator: ${host ?? 'none (the configured project)'}'),
          StreamBuilder<List<Player>>(
            stream: db.select(db.players).watch(),
            builder: (context, snap) {
              final player = snap.data?.firstOrNull;
              return Text(
                'guest ${player?.guestId ?? '…'}\n'
                'uid ${player?.firebaseUid ?? '(awaiting auth)'}',
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey<String>('debugSync.date'),
            controller: _date,
            decoration: const InputDecoration(labelText: 'dailyDate'),
          ),
          Row(
            children: <Widget>[
              for (final days in const <int>[-1, 1])
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _shiftDate(days)),
                    child: Text(days < 0 ? '− 1 day' : '+ 1 day'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(
                onPressed: () => _run(_produceAndDrain),
                child: const Text('produce'),
              ),
              FilledButton(
                onPressed: () {
                  unawaited(_produceAndDrain());
                  context.pop();
                },
                child: const Text('produce + leave'),
              ),
              OutlinedButton(
                onPressed: () => _run(() async {
                  await ref.read(dailyResultSyncServiceProvider).drain();
                  debugPrint('debug-sync: manual drain done');
                  return 'drained';
                }),
                child: const Text('drain'),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('daily_sync_enabled'),
            value: !disabled,
            onChanged: (on) =>
                ref.read(debugSyncDisabledProvider.notifier).state = !on,
          ),
          if (_status.isNotEmpty) Text(_status),
          const Divider(),
          StreamBuilder<List<SyncQueueRow>>(
            stream: db.select(db.syncQueueRows).watch(),
            builder: (context, snap) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('sync_queue (${snap.data?.length ?? 0})'),
                for (final row in snap.data ?? const <SyncQueueRow>[])
                  Text(
                    '#${row.id} ${row.state.name} a=${row.attemptCount} '
                    '${row.idempotencyKey ?? '(no key)'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: LoopColors.muted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
