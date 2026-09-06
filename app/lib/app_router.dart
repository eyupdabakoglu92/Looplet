import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'bootstrap.dart';
import 'home_screen.dart';
import 'play/play_session_args.dart';
import 'play/play_session_screen.dart';

/// Route names. Kept small — F05 / F07 / F09 / F10 add their screens here.
abstract final class Routes {
  static const String home = '/';
  static const String play = '/play';
}

/// The app router. `'/'` renders the local-bootstrap gate (splash → home /
/// recoverable error); `'/play'` is the F03 puzzle screen (`architecture.md`
/// §13). Portrait lock is applied once in `main()`.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const _BootstrapGate(),
      ),
      GoRoute(
        path: Routes.play,
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is PlaySessionArgs
              ? extra
              : const PlaySessionArgs(
                  source: PuzzleSource.journey,
                  debugPuzzleId: 'smoke-tr-01',
                );
          return PlaySessionScreen(args: args);
        },
      ),
    ],
  );
});

/// Gates the first real screen on the local bootstrap (DB + migrations +
/// snapshot). Firebase init is fire-and-forget inside [appBootstrapProvider].
class _BootstrapGate extends ConsumerWidget {
  const _BootstrapGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);
    return bootstrap.when(
      loading: () => const _SplashScreen(),
      error: (error, _) => StoreErrorScreen(
        message: '$error',
        onRetry: () => ref.invalidate(appBootstrapProvider),
      ),
      data: (result) => switch (result) {
        AppBootstrapReady() => const HomeScreen(),
        AppBootstrapMigrationError(:final message) => StoreErrorScreen(
          message: message,
          onRetry: () => ref.invalidate(appBootstrapProvider),
        ),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('LOOPLET')));
}

/// Shown when the on-device store cannot be opened or a migration failed. Data
/// is left intact at the previous schema (F08 AC9); Retry re-runs the bootstrap.
/// F08-owned, plain by design (`f08 architecture.md` — no design handoff).
class StoreErrorScreen extends StatelessWidget {
  const StoreErrorScreen({
    required this.message,
    required this.onRetry,
    super.key,
  });

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
