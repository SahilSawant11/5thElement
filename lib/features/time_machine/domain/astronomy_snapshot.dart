import 'dart:math' as math;

class ApodSnapshot {
  const ApodSnapshot({
    required this.date,
    required this.title,
    required this.explanation,
    required this.url,
    required this.mediaType,
    required this.thumbnailUrl,
    required this.credit,
    required this.isFallback,
  });

  final DateTime date;
  final String title;
  final String explanation;
  final String? url;
  final String mediaType;
  final String? thumbnailUrl;
  final String credit;
  final bool isFallback;
}

class MoonSnapshot {
  const MoonSnapshot({
    required this.ageDays,
    required this.illuminationPercent,
    required this.phaseLabel,
    required this.phaseEmoji,
  });

  final double ageDays;
  final double illuminationPercent;
  final String phaseLabel;
  final String phaseEmoji;
}

class AstronomySnapshot {
  const AstronomySnapshot({
    required this.birthDate,
    required this.observationDate,
    required this.apod,
    required this.moon,
    required this.seasonLabel,
    required this.weekdayLabel,
    required this.skyNote,
    required this.sourceLabel,
    required this.isLive,
    required this.notes,
  });

  final DateTime birthDate;
  final DateTime observationDate;
  final ApodSnapshot apod;
  final MoonSnapshot moon;
  final String seasonLabel;
  final String weekdayLabel;
  final String skyNote;
  final String sourceLabel;
  final bool isLive;
  final String notes;

  String get title =>
      'The sky on ${_monthDayLabel(birthDate)} ${birthDate.year}';
  String get subtitle =>
      'A live astronomy snapshot built from NASA APOD and moon-phase context.';
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
  if (date.month == 12 || date.month <= 2) return 'Winter';
  if (date.month <= 5) return 'Spring';
  if (date.month <= 8) return 'Summer';
  return 'Autumn';
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

MoonSnapshot buildMoonSnapshot(DateTime date) {
  final normalized = DateTime.utc(date.year, date.month, date.day, 12);
  final referenceNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
  const synodicMonth = 29.53058867;

  final ageDays = normalized.difference(referenceNewMoon).inMilliseconds /
      Duration.millisecondsPerDay;
  final age = _positiveModulo(ageDays, synodicMonth);
  final illumination = 0.5 * (1 - math.cos((2 * math.pi * age) / synodicMonth)) * 100;

  final phaseLabel = _phaseLabelForAge(age);
  final phaseEmoji = _phaseEmojiForAge(age);

  return MoonSnapshot(
    ageDays: double.parse(age.toStringAsFixed(1)),
    illuminationPercent: double.parse(illumination.toStringAsFixed(0)),
    phaseLabel: phaseLabel,
    phaseEmoji: phaseEmoji,
  );
}

double _positiveModulo(double value, double modulus) {
  final result = value % modulus;
  return result < 0 ? result + modulus : result;
}

String _phaseLabelForAge(double ageDays) {
  if (ageDays < 1.8) return 'New Moon';
  if (ageDays < 5.5) return 'Waxing Crescent';
  if (ageDays < 8.5) return 'First Quarter';
  if (ageDays < 12.5) return 'Waxing Gibbous';
  if (ageDays < 16.0) return 'Full Moon';
  if (ageDays < 20.0) return 'Waning Gibbous';
  if (ageDays < 23.0) return 'Last Quarter';
  if (ageDays < 27.0) return 'Waning Crescent';
  return 'New Moon';
}

String _phaseEmojiForAge(double ageDays) {
  if (ageDays < 1.8) return '◌';
  if (ageDays < 5.5) return '🌒';
  if (ageDays < 8.5) return '🌓';
  if (ageDays < 12.5) return '🌔';
  if (ageDays < 16.0) return '🌕';
  if (ageDays < 20.0) return '🌖';
  if (ageDays < 23.0) return '🌗';
  if (ageDays < 27.0) return '🌘';
  return '◌';
}

String skyNoteFor(DateTime date) {
  final season = seasonFor(date);
  return 'A $season sky, shaped by the Moon’s cycle and the day NASA chose to archive.';
}

DateTime apodDateFor(DateTime birthDate) {
  final launchDate = DateTime(1995, 6, 16);
  final normalized = DateTime(birthDate.year, birthDate.month, birthDate.day);
  return normalized.isBefore(launchDate) ? launchDate : normalized;
}

String displayDate(DateTime date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
