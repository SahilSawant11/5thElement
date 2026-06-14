import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/time_portal.dart';

final selectedCategoryProvider =
    StateProvider<TimePortalCategory>((ref) => TimePortalCategory.all);

final timePortalsProvider = Provider<List<TimePortal>>((ref) {
  return const [
    TimePortal(
      id: 'midnight-train',
      year: 2004,
      title: 'Midnight train to nowhere',
      subtitle: 'The city looked softer through fogged glass.',
      summary: 'A travel memory that still feels cinematic and suspended.',
      narrative:
          'Some nights feel like they were written in widescreen. The stations blur, the lights stretch, '
          'and every announcement sounds like a promise to your younger self.',
      category: TimePortalCategory.places,
      accent: Color(0xFF56B8D6),
      tags: ['Travel', 'Motion', 'Night'],
      highlight: 'Platform lights, a paper ticket, and a window full of rain.',
    ),
    TimePortal(
      id: 'sunday-ritual',
      year: 2011,
      title: 'Sunday ritual',
      subtitle: 'Tea, a playlist, and the same sunbeam on the floor.',
      summary: 'A familiar rhythm that makes time feel generous.',
      narrative:
          'Rituals are tiny time machines. They return us to the shape of ourselves that lived before the week got loud.',
      category: TimePortalCategory.rituals,
      accent: Color(0xFFFFA463),
      tags: ['Routine', 'Quiet', 'Safe'],
      highlight: 'Warm ceramic, open windows, and a song you know by heart.',
    ),
    TimePortal(
      id: 'first-idea',
      year: 2018,
      title: 'The first version of the big idea',
      subtitle: 'A sketch that later became a system.',
      summary: 'A thought that started tiny and kept asking to grow.',
      narrative:
          'Great ideas often arrive as whispers. If you keep them in the light, they become maps for a life you have not reached yet.',
      category: TimePortalCategory.ideas,
      accent: Color(0xFF7A5CFF),
      tags: ['Build', 'Future', 'Clarity'],
      highlight: 'Sticky notes, a blank canvas, and a brave first sentence.',
    ),
    TimePortal(
      id: 'backyard-late-summer',
      year: 1999,
      title: 'Late summer in the backyard',
      subtitle: 'Everything golden, nothing urgent.',
      summary: 'A memory that feels like it has been sitting in the sun.',
      narrative:
          'The air was heavy with fruit and dust. The kind of afternoon where silence feels full, not empty.',
      category: TimePortalCategory.moments,
      accent: Color(0xFF8BC34A),
      tags: ['Home', 'Nostalgia', 'Summer'],
      highlight: 'Grass under bare feet and a sky that seemed to go on forever.',
    ),
  ];
});

final filteredPortalsProvider = Provider<List<TimePortal>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final portals = ref.watch(timePortalsProvider);

  if (selectedCategory == TimePortalCategory.all) {
    return portals;
  }

  return portals
      .where((portal) => portal.category == selectedCategory)
      .toList(growable: false);
});

final featuredPortalProvider = Provider<TimePortal>((ref) {
  final portals = ref.watch(timePortalsProvider);
  return portals.first;
});

final portalByIdProvider = Provider.family<TimePortal?, String>((ref, id) {
  final portals = ref.watch(timePortalsProvider);
  for (final portal in portals) {
    if (portal.id == id) {
      return portal;
    }
  }
  return null;
});
