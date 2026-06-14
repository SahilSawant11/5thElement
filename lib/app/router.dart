import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/time_machine/presentation/birth_date_gate_screen.dart';
import '../features/time_machine/presentation/life_portal_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BirthDateGateScreen(),
        routes: [
          GoRoute(
            path: 'portal/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return LifePortalDetailScreen(portalId: id);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const BirthDateGateScreen(),
  );
});
