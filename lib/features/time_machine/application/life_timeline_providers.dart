import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/life_portal.dart';
import 'birth_date_controller.dart';

final lifeSnapshotProvider = Provider<AsyncValue<LifeSnapshot?>>((ref) {
  final birthDateAsync = ref.watch(birthDateControllerProvider);
  return birthDateAsync.whenData((birthDate) {
    if (birthDate == null) {
      return null;
    }

    return buildLifeSnapshot(birthDate, DateTime.now());
  });
});

final lifePortalsProvider = Provider<AsyncValue<List<LifePortal>>>((ref) {
  return ref.watch(lifeSnapshotProvider).whenData(
        (snapshot) => snapshot?.portals ?? const [],
      );
});

final lifePortalByIdProvider = Provider.family<LifePortal?, String>((ref, id) {
  final portals = ref.watch(lifePortalsProvider);
  return portals.maybeWhen(
    data: (items) {
      for (final portal in items) {
        if (portal.id == id) {
          return portal;
        }
      }
      return null;
    },
    orElse: () => null,
  );
});
