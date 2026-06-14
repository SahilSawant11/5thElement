import 'package:flutter/material.dart';

enum TimePortalCategory { all, moments, places, rituals, ideas }

extension TimePortalCategoryLabel on TimePortalCategory {
  String get label {
    switch (this) {
      case TimePortalCategory.all:
        return 'All';
      case TimePortalCategory.moments:
        return 'Moments';
      case TimePortalCategory.places:
        return 'Places';
      case TimePortalCategory.rituals:
        return 'Rituals';
      case TimePortalCategory.ideas:
        return 'Ideas';
    }
  }
}

class TimePortal {
  const TimePortal({
    required this.id,
    required this.year,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.narrative,
    required this.category,
    required this.accent,
    required this.tags,
    required this.highlight,
  });

  final String id;
  final int year;
  final String title;
  final String subtitle;
  final String summary;
  final String narrative;
  final TimePortalCategory category;
  final Color accent;
  final List<String> tags;
  final String highlight;

  static const seed = TimePortal(
    id: 'seed',
    year: 1998,
    title: 'The first spark',
    subtitle: 'A memory that still feels warm.',
    summary: 'The kind of moment that makes the rest of the timeline shimmer.',
    narrative:
        'A line of light moves through the room, and the ordinary becomes a landmark. '
        'The smell of rain, a half-finished sketch, and a quiet laugh turn into a place you can visit again.',
    category: TimePortalCategory.moments,
    accent: Color(0xFF7A5CFF),
    tags: ['Warm', 'Private', 'Atmospheric'],
    highlight: 'Rain on the window, a blue notebook, and a feeling of almost.',
  );
}
