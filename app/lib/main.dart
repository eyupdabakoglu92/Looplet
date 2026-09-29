import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'design/tokens.dart';
import 'play/play_theme.dart';
import 'persistence/sync_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // LOOPLET is portrait-only (product-prd §1, §33; F03 architecture §3/§13).
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  runApp(const ProviderScope(child: LoopletApp()));
}

/// App shell. `go_router` gates the first real screen on the local bootstrap
/// (DB + migrations + snapshot); Firebase init + the daily-result sync run in
/// the background (see `appBootstrapProvider`). The session-level sync-drain
/// lifecycle observer ([_SessionLifecycle]) wraps the whole router so it
/// outlives every route (`platform.md` §7, F08 architecture).
class LoopletApp extends ConsumerWidget {
  const LoopletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Looplet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: PlayTheme.colorScheme,
        // The Foundation ground (#070C25): no frame between the native launch,
        // the splash, Home and the store-error screen shows another colour
        // (F05 architecture §18.3 (8)).
        scaffoldBackgroundColor: LoopColors.groundMid,
        canvasColor: LoopColors.groundMid,
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: (context, child) =>
          _SessionLifecycle(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Drains the deferred daily-result sync queue on `paused` (final flush) and
/// `resumed`. The sync service itself is session-level and outlives every
/// screen (`platform.md` §7); this observer is mounted once, app-wide.
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
      unawaited(ref.read(dailyResultSyncServiceProvider).drain());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
