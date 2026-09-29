import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'bootstrap.dart';
import 'debug/debug_sync_screen.dart';
import 'home_screen.dart';
import 'play/play_session_args.dart';
import 'play/play_session_screen.dart';
import 'shell/splash_screen.dart';
import 'shell/store_error_screen.dart';

export 'shell/store_error_screen.dart' show StoreErrorScreen;

/// Route names. Kept small — F05 / F07 / F09 / F10 add their screens here.
abstract final class Routes {
  static const String home = '/';
  static const String play = '/play';

  /// Debug builds only: the fake daily-result trigger (F08 Activation A3).
  static const String debugSync = '/debug/sync';
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
      if (kDebugMode)
        GoRoute(
          path: Routes.debugSync,
          builder: (context, state) => const DebugSyncScreen(),
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
    // While Retry re-runs the bootstrap the splash frame shows again, not the
    // previous error (F05 `ui-design.md` §4), hence no skipping on refresh.
    return bootstrap.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      loading: () => const LoopSplashScreen(),
      error: (error, _) => StoreErrorScreen(
        message: '$error',
        onRetry: () => ref.invalidate(appBootstrapProvider),
      ),
      data: (result) => switch (result) {
        AppBootstrapReady() => const HomeScreen(),
        AppBootstrapStoreError(:final message) => StoreErrorScreen(
          message: message,
          onRetry: () => ref.invalidate(appBootstrapProvider),
        ),
      },
    );
  }
}
