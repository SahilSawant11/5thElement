class WorldYearSummary {
  const WorldYearSummary({
    required this.year,
    required this.description,
    required this.extract,
  });

  final int year;
  final String description;
  final String extract;
}

class WorldMoment {
  const WorldMoment({
    required this.year,
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
  });

  final int? year;
  final String title;
  final String description;
  final String? url;
  final String? thumbnailUrl;
}

class WorldAtBirthSnapshot {
  const WorldAtBirthSnapshot({
    required this.birthDate,
    required this.yearSummary,
    required this.events,
    required this.births,
    required this.deaths,
    required this.seasonLabel,
    required this.weekdayLabel,
    required this.eraLabel,
    required this.sourceLabel,
    required this.isLive,
    required this.notes,
  });

  final DateTime birthDate;
  final WorldYearSummary yearSummary;
  final List<WorldMoment> events;
  final List<WorldMoment> births;
  final List<WorldMoment> deaths;
  final String seasonLabel;
  final String weekdayLabel;
  final String eraLabel;
  final String sourceLabel;
  final bool isLive;
  final String notes;

  String get displayTitle => 'The world on ${_monthDayLabel(birthDate)} ${birthDate.year}';
  String get introText => events.isNotEmpty
      ? events.first.description
      : yearSummary.extract;
}

String _monthDayLabel(DateTime date) {
  const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[date.month - 1]} ${date.day}';
}

String seasonFor(DateTime date) {
  if (date.month == 12 && date.day >= 21) return 'Winter';
  if (date.month <= 2) return 'Winter';
  if (date.month == 3 && date.day < 20) return 'Winter';
  if (date.month == 3 || date.month == 4 || date.month == 5) return 'Spring';
  if (date.month == 6 && date.day < 21) return 'Spring';
  if (date.month == 6 || date.month == 7 || date.month == 8) return 'Summer';
  if (date.month == 9 && date.day < 22) return 'Summer';
  if (date.month == 9 || date.month == 10 || date.month == 11) return 'Autumn';
  if (date.month == 12 && date.day < 21) return 'Autumn';
  return 'Autumn';
}

String eraFor(int year) {
  if (year < 1950) return 'Mid-century world';
  if (year < 1970) return 'Postwar shift';
  if (year < 1990) return 'Late 20th century';
  if (year < 2000) return 'The 90s';
  if (year < 2010) return 'Early 2000s';
  if (year < 2020) return 'The 2010s';
  return 'The 2020s';
}

String weekdayLabel(DateTime date) {
  const weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  return weekdays[date.weekday - 1];
}

WorldAtBirthSnapshot buildFallbackSnapshot(DateTime birthDate, {String? notes}) {
  final yearSummary = WorldYearSummary(
    year: birthDate.year,
    description: 'A calmer fallback summary',
    extract:
        'Live historical data could not be loaded, so this snapshot is falling back to a local summary. '
        'The app is still ready to be explored, and we can keep the historical layer in place.',
  );

  return WorldAtBirthSnapshot(
    birthDate: birthDate,
    yearSummary: yearSummary,
    events: const [],
    births: const [],
    deaths: const [],
    seasonLabel: seasonFor(birthDate),
    weekdayLabel: weekdayLabel(birthDate),
    eraLabel: eraFor(birthDate.year),
    sourceLabel: 'Local fallback',
    isLive: false,
    notes: notes ?? 'Historical data is temporarily unavailable.',
  );
}
