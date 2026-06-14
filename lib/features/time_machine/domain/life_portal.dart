import 'package:flutter/material.dart';

enum LifePortalCategory { origin, becoming, ritual, presence, horizon }

extension LifePortalCategoryLabel on LifePortalCategory {
  String get label {
    switch (this) {
      case LifePortalCategory.origin:
        return 'Origin';
      case LifePortalCategory.becoming:
        return 'Becoming';
      case LifePortalCategory.ritual:
        return 'Ritual';
      case LifePortalCategory.presence:
        return 'Presence';
      case LifePortalCategory.horizon:
        return 'Horizon';
    }
  }
}

class LifePortal {
  const LifePortal({
    required this.id,
    required this.age,
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
  final int age;
  final int year;
  final String title;
  final String subtitle;
  final String summary;
  final String narrative;
  final LifePortalCategory category;
  final Color accent;
  final List<String> tags;
  final String highlight;
}

class LifeSnapshot {
  const LifeSnapshot({
    required this.birthDate,
    required this.now,
    required this.ageYears,
    required this.daysLived,
    required this.daysToNextBirthday,
    required this.currentChapter,
    required this.nextChapter,
    required this.portals,
  });

  final DateTime birthDate;
  final DateTime now;
  final int ageYears;
  final int daysLived;
  final int daysToNextBirthday;
  final String currentChapter;
  final String nextChapter;
  final List<LifePortal> portals;
}

LifeSnapshot buildLifeSnapshot(DateTime birthDate, DateTime now) {
  final ageYears = _calculateAgeYears(birthDate, now);
  final daysLived = now.difference(birthDate).inDays;
  final nextBirthday = _nextBirthday(birthDate, now);
  final daysToNextBirthday = nextBirthday.difference(_stripTime(now)).inDays;

  return LifeSnapshot(
    birthDate: birthDate,
    now: now,
    ageYears: ageYears,
    daysLived: daysLived,
    daysToNextBirthday: daysToNextBirthday,
    currentChapter: _chapterForAge(ageYears),
    nextChapter: _chapterForAge(ageYears + 1),
    portals: _generateLifePortals(birthDate, now, ageYears),
  );
}

int _calculateAgeYears(DateTime birthDate, DateTime now) {
  var years = now.year - birthDate.year;
  final hadBirthdayThisYear = now.month > birthDate.month ||
      (now.month == birthDate.month && now.day >= birthDate.day);
  if (!hadBirthdayThisYear) {
    years -= 1;
  }
  return years.clamp(0, 150);
}

DateTime _nextBirthday(DateTime birthDate, DateTime now) {
  final candidate = _safeDate(now.year, birthDate.month, birthDate.day);
  if (!candidate.isBefore(_stripTime(now))) {
    return candidate;
  }
  return _safeDate(now.year + 1, birthDate.month, birthDate.day);
}

DateTime _stripTime(DateTime value) => DateTime(value.year, value.month, value.day);

DateTime _safeDate(int year, int month, int day) {
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day.clamp(1, lastDayOfMonth));
}

String _chapterForAge(int ageYears) {
  if (ageYears < 8) return 'Origin';
  if (ageYears < 14) return 'Becoming';
  if (ageYears < 22) return 'Awakening';
  if (ageYears < 30) return 'Expansion';
  if (ageYears < 45) return 'Momentum';
  return 'Legacy';
}

List<LifePortal> _generateLifePortals(DateTime birthDate, DateTime now, int ageYears) {
  final milestones = <_Milestone>[
    const _Milestone(
      age: 0,
      title: 'The first light',
      subtitle: 'Your story begins softly.',
      summary: 'The first room, the first breath, the first page of your own orbit.',
      narrative:
          'Every time machine needs an origin point. Yours is a quiet spark, a beginning that still echoes in the shape of everything that follows.',
      category: LifePortalCategory.origin,
      accent: Color(0xFF56B8D6),
      tags: ['Beginning', 'Rooted', 'Warm'],
      highlight: 'A small beginning with a very long shadow.',
    ),
    const _Milestone(
      age: 6,
      title: 'The world gets bigger',
      subtitle: 'Curiosity starts collecting maps.',
      summary: 'A season of first questions, bright edges, and pocket-sized wonder.',
      narrative:
          'The world becomes a little more legible here. You start noticing what feels safe, what feels loud, and what feels like yours.',
      category: LifePortalCategory.becoming,
      accent: Color(0xFFFFA463),
      tags: ['Curious', 'Play', 'Discovery'],
      highlight: 'The age of fearless questions.',
    ),
    const _Milestone(
      age: 13,
      title: 'The mirror wakes up',
      subtitle: 'Identity becomes an experiment.',
      summary: 'A chapter of edges, signals, and early self-definition.',
      narrative:
          'This is where life starts asking for your opinion. Your preferences sharpen, your private world deepens, and the mirror begins to answer back.',
      category: LifePortalCategory.becoming,
      accent: Color(0xFF7A5CFF),
      tags: ['Identity', 'Shift', 'Signal'],
      highlight: 'The first time you feel the shape of yourself changing.',
    ),
    const _Milestone(
      age: 18,
      title: 'The first open door',
      subtitle: 'Freedom arrives with a pulse.',
      summary: 'A turn toward independence, possibility, and consequence.',
      narrative:
          'The future is no longer a rumor. You can walk toward it, hesitate in front of it, or build it by hand.',
      category: LifePortalCategory.ritual,
      accent: Color(0xFF8BC34A),
      tags: ['Freedom', 'Choice', 'Velocity'],
      highlight: 'A first step that changes the map.',
    ),
    _Milestone(
      age: ageYears,
      title: 'Right now',
      subtitle: _chapterForAge(ageYears),
      summary: 'The place you are standing in today.',
      narrative:
          'This is the living edge of the story. The part that is still being written, still making decisions, still learning how to feel like home.',
      category: LifePortalCategory.presence,
      accent: const Color(0xFF4DD0C8),
      tags: ['Present', 'Breath', 'Here'],
      highlight: 'This moment, held carefully.',
    ),
    _Milestone(
      age: ageYears + 5,
      title: 'The horizon five years out',
      subtitle: 'What your future self is beginning to design.',
      summary: 'A forward glance that turns uncertainty into architecture.',
      narrative:
          'The next five years are not a prediction; they are an invitation. You can already feel the outline of the person who will arrive there.',
      category: LifePortalCategory.horizon,
      accent: const Color(0xFFB07CFF),
      tags: ['Future', 'Intent', 'Arc'],
      highlight: 'A future version of you already leaving clues.',
    ),
  ];

  return milestones
      .map(
        (milestone) => LifePortal(
          id: 'life-${milestone.age}',
          age: milestone.age,
          year: birthDate.year + milestone.age,
          title: milestone.title,
          subtitle: milestone.subtitle,
          summary: milestone.summary,
          narrative: milestone.narrative,
          category: milestone.category,
          accent: milestone.accent,
          tags: milestone.tags,
          highlight: milestone.highlight,
        ),
      )
      .toList(growable: false);
}

class _Milestone {
  const _Milestone({
    required this.age,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.narrative,
    required this.category,
    required this.accent,
    required this.tags,
    required this.highlight,
  });

  final int age;
  final String title;
  final String subtitle;
  final String summary;
  final String narrative;
  final LifePortalCategory category;
  final Color accent;
  final List<String> tags;
  final String highlight;
}
