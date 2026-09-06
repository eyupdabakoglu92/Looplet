import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';
import 'persistence/sync_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // LOOPLET is portrait-only (product-prd §1, §33).
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  runApp(const ProviderScope(child: LoopletApp()));
}

/// App shell. The local bootstrap (DB + migrations + snapshot) gates the first
/// real screen; Firebase init + the daily-result sync run in the background
/// (see [appBootstrapProvider]). Routing (go_router) + the game/menu screens
/// land with F03/F05/F09/F10.
class LoopletApp extends ConsumerWidget {
  const LoopletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);

    return MaterialApp(
      title: 'LOOPLET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B1B1F)),
        useMaterial3: true,
      ),
      home: bootstrap.when(
        loading: () => const _SplashScreen(),
        error: (error, _) => _StoreErrorScreen(
          message: '$error',
          onRetry: () => ref.invalidate(appBootstrapProvider),
        ),
        data: (result) => switch (result) {
          AppBootstrapReady() => const _SessionLifecycle(
            child: _HomePlaceholder(),
          ),
          AppBootstrapMigrationError(:final message) => _StoreErrorScreen(
            message: message,
            onRetry: () => ref.invalidate(appBootstrapProvider),
          ),
        },
      ),
    );
  }
}

/// Registers a single app-level lifecycle observer that drains the deferred
/// daily-result sync queue on `paused` (final flush) and `resumed`. The sync
/// service itself is session-level and outlives every screen (`platform.md` §7).
class _SessionLifecycle extends ConsumerStatefulWidget {
  const _SessionLifecycle({required this.child});
  final Widget child;

  @override
  ConsumerState<_SessionLifecycle> createState() => _SessionLifecycleState();
}

class _SessionLifecycleState extends ConsumerState<_SessionLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      // Write-through means durable state is already committed; this attempts a
      // sync flush. Fire-and-forget — never blocks the lifecycle transition.
      unawaited(ref.read(dailyResultSyncServiceProvider).drain());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('LOOPLET')));
  }
}

/// Shown when the on-device store cannot be opened or a migration failed. The
/// data is left intact at the previous schema (F08 AC9); "Retry" re-runs the
/// bootstrap. The only F08-owned screen — plain, no design handoff.
class _StoreErrorScreen extends StatelessWidget {
  const _StoreErrorScreen({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Couldn’t open your saved data',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your progress is safe. Please try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder home. The real menu / play screens land with F05 / F09 / F10.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('LOOPLET')));
  }
}
