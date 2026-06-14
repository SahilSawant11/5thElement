import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/time_machine/presentation/birth_date_gate_screen.dart';
import '../features/time_machine/presentation/birth_sky_screen.dart';
import '../features/time_machine/presentation/life_portal_detail_screen.dart';
import '../features/time_machine/presentation/life_timeline_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: const BirthDateGateScreen(),
        ),
        routes: [
          GoRoute(
            path: 'sky',
            pageBuilder: (context, state) => _fadeSlidePage(
              key: state.pageKey,
              child: const BirthSkyScreen(),
            ),
          ),
          GoRoute(
            path: 'world',
            redirect: (context, state) => '/sky',
          ),
          GoRoute(
            path: 'timeline',
            pageBuilder: (context, state) => _fadeSlidePage(
              key: state.pageKey,
              child: const LifeTimelineScreen(),
              begin: const Offset(0.04, 0.03),
            ),
          ),
          GoRoute(
            path: 'portal/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return _fadeSlidePage(
                key: state.pageKey,
                child: LifePortalDetailScreen(portalId: id),
                begin: const Offset(0.06, 0.02),
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const BirthDateGateScreen(),
  );
});

CustomTransitionPage<void> _fadeSlidePage({
  required LocalKey key,
  required Widget child,
  Offset begin = const Offset(0.0, 0.03),
}) {
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}
