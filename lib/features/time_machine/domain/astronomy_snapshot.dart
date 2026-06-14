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

class DaylightSnapshot {
  const DaylightSnapshot({
    required this.referenceLabel,
    required this.sunriseLabel,
    required this.sunsetLabel,
    required this.daylightHours,
    required this.note,
  });

  final String referenceLabel;
  final String sunriseLabel;
  final String sunsetLabel;
  final double daylightHours;
  final String note;
}

class VisibleSkySnapshot {
  const VisibleSkySnapshot({
    required this.seasonLabel,
    required this.planets,
    required this.constellations,
    required this.note,
  });

  final String seasonLabel;
  final List<String> planets;
  final List<String> constellations;
  final String note;
}

class SkyEventSnapshot {
  const SkyEventSnapshot({
    required this.meteorShower,
    required this.meteorWindow,
    required this.eclipseNote,
    required this.note,
  });

  final String meteorShower;
  final String meteorWindow;
  final String eclipseNote;
  final String note;
}

class MoonTimelinePoint {
  const MoonTimelinePoint({
    required this.ageYears,
    required this.label,
    required this.date,
    required this.moon,
  });

  final int ageYears;
  final String label;
  final DateTime date;
  final MoonSnapshot moon;
}

class AstronomySnapshot {
  const AstronomySnapshot({
    required this.birthDate,
    required this.observationDate,
    required this.apod,
    required this.moon,
    required this.daylight,
    required this.visibleSky,
    required this.skyEvents,
    required this.moonTimeline,
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
  final DaylightSnapshot daylight;
  final VisibleSkySnapshot visibleSky;
  final SkyEventSnapshot skyEvents;
  final List<MoonTimelinePoint> moonTimeline;
  final String seasonLabel;
  final String weekdayLabel;
  final String skyNote;
  final String sourceLabel;
  final bool isLive;
  final String notes;

  String get title =>
      'The sky on ${_monthDayLabel(birthDate)} ${birthDate.year}';
  String get subtitle =>
      'A live astronomy snapshot with moon phase, daylight, and seasonal sky context.';
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

DaylightSnapshot buildDaylightSnapshot(DateTime date) {
  const referenceLatitudeDegrees = 23.0;
  final normalized = DateTime(date.year, date.month, date.day);
  final dayOfYear = _dayOfYear(normalized);
  final declinationDegrees =
      23.44 * math.sin((2 * math.pi / 365.0) * (dayOfYear - 81));
  const latitudeRadiansFactor = math.pi / 180;
  const latitudeRadians = referenceLatitudeDegrees * latitudeRadiansFactor;
  final declinationRadians = declinationDegrees * latitudeRadiansFactor;
  final cosineHourAngle = -math.tan(latitudeRadians) * math.tan(declinationRadians);

  if (cosineHourAngle >= 1) {
    return const DaylightSnapshot(
      referenceLabel: 'Estimated for 23°N',
      sunriseLabel: '—',
      sunsetLabel: '—',
      daylightHours: 0,
      note: 'Polar-style darkness at this reference latitude.',
    );
  }

  if (cosineHourAngle <= -1) {
    return const DaylightSnapshot(
      referenceLabel: 'Estimated for 23°N',
      sunriseLabel: '—',
      sunsetLabel: '—',
      daylightHours: 24,
      note: 'Midnight-sun style daylight at this reference latitude.',
    );
  }

  final hourAngleRadians = math.acos(cosineHourAngle);
  final daylightHours = (2 * hourAngleRadians * 24) / (2 * math.pi);
  final sunriseMinutes = 12 * 60 - (daylightHours * 60 / 2);
  final sunsetMinutes = 12 * 60 + (daylightHours * 60 / 2);

  return DaylightSnapshot(
    referenceLabel: 'Estimated for 23°N',
    sunriseLabel: _formatClock(sunriseMinutes),
    sunsetLabel: _formatClock(sunsetMinutes),
    daylightHours: double.parse(daylightHours.toStringAsFixed(1)),
    note: 'Approximate solar times without a birth location.',
  );
}

VisibleSkySnapshot buildVisibleSkySnapshot(DateTime date) {
  final season = seasonFor(date);

  switch (season) {
    case 'Winter':
      return const VisibleSkySnapshot(
        seasonLabel: 'Winter sky',
        planets: ['Jupiter', 'Mars'],
        constellations: ['Orion', 'Taurus', 'Gemini'],
        note: 'Clear winter nights usually favor the brightest constellation patterns.',
      );
    case 'Spring':
      return const VisibleSkySnapshot(
        seasonLabel: 'Spring sky',
        planets: ['Venus', 'Jupiter'],
        constellations: ['Leo', 'Virgo', 'Ursa Major'],
        note: 'Spring is often a strong season for galaxy-rich star fields and bright planets.',
      );
    case 'Summer':
      return const VisibleSkySnapshot(
        seasonLabel: 'Summer sky',
        planets: ['Saturn', 'Jupiter'],
        constellations: ['Scorpius', 'Sagittarius', 'Cygnus'],
        note: 'Summer evenings can reveal the Milky Way band and seasonal constellations.',
      );
    default:
      return const VisibleSkySnapshot(
        seasonLabel: 'Autumn sky',
        planets: ['Saturn', 'Venus'],
        constellations: ['Pegasus', 'Andromeda', 'Pisces'],
        note: 'Autumn skies often highlight long-looking star chains and deep-sky regions.',
      );
  }
}

SkyEventSnapshot buildSkyEventSnapshot(DateTime date, MoonSnapshot moon) {
  final meteorShower = _meteorShowerFor(date);
  final eclipseNote = _eclipseNoteFor(date, moon);

  return SkyEventSnapshot(
    meteorShower: meteorShower.name,
    meteorWindow: meteorShower.windowLabel,
    eclipseNote: eclipseNote,
    note: 'Closest annual shower: ${meteorShower.name}. ${meteorShower.note}',
  );
}

List<MoonTimelinePoint> buildMoonTimeline(DateTime birthDate) {
  final today = DateTime.now();
  var currentAgeYears = today.year - birthDate.year;
  if (DateTime(today.year, birthDate.month, birthDate.day).isAfter(today)) {
    currentAgeYears -= 1;
  }
  final milestoneYears = <int>{
    0,
    1,
    5,
    10,
    13,
    18,
    21,
    25,
    30,
    35,
    40,
    50,
    if (currentAgeYears > 0) currentAgeYears,
  }
      .where((ageYears) => ageYears <= currentAgeYears)
      .toList()
    ..sort();

  return milestoneYears.map((ageYears) {
    final milestoneDate = _birthAnniversary(birthDate, ageYears);
    final moon = buildMoonSnapshot(milestoneDate);
    final label = ageYears == 0 ? 'Birth' : '$ageYears years';
    return MoonTimelinePoint(
      ageYears: ageYears,
      label: label,
      date: milestoneDate,
      moon: moon,
    );
  }).toList();
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

AstronomySnapshot buildAstronomySnapshot({
  required DateTime birthDate,
  required ApodSnapshot apod,
  required bool isLive,
  required String sourceLabel,
  required String notes,
}) {
  final normalized = DateTime(birthDate.year, birthDate.month, birthDate.day);
  final moon = buildMoonSnapshot(normalized);

  return AstronomySnapshot(
    birthDate: normalized,
    observationDate: apod.date,
    apod: apod,
    moon: moon,
    daylight: buildDaylightSnapshot(normalized),
    visibleSky: buildVisibleSkySnapshot(normalized),
    skyEvents: buildSkyEventSnapshot(normalized, moon),
    moonTimeline: buildMoonTimeline(normalized),
    seasonLabel: seasonFor(normalized),
    weekdayLabel: weekdayLabel(normalized),
    skyNote: skyNoteFor(normalized),
    sourceLabel: sourceLabel,
    isLive: isLive,
    notes: notes,
  );
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

String formatDurationHours(double value) {
  return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}h';
}

String _formatClock(double minutes) {
  final totalMinutes = minutes.round();
  final normalizedMinutes = ((totalMinutes % (24 * 60)) + (24 * 60)) % (24 * 60);
  final hours = normalizedMinutes ~/ 60;
  final minutesPart = normalizedMinutes % 60;
  final hour12 = hours % 12 == 0 ? 12 : hours % 12;
  final period = hours < 12 ? 'AM' : 'PM';
  return '$hour12:${minutesPart.toString().padLeft(2, '0')} $period';
}

int _dayOfYear(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1);
  return date.difference(startOfYear).inDays + 1;
}

DateTime _birthAnniversary(DateTime birthDate, int ageYears) {
  final targetYear = birthDate.year + ageYears;
  final month = birthDate.month;
  final day = math.min(
    birthDate.day,
    DateTime(targetYear, month + 1, 0).day,
  );
  return DateTime(targetYear, month, day);
}

_MeteorShower _meteorShowerFor(DateTime date) {
  final showers = <_MeteorShower>[
    const _MeteorShower(
      name: 'Quadrantids',
      windowLabel: 'Jan 1–5',
      peakMonth: 1,
      peakDay: 3,
      note: 'One of the year’s first strong meteor showers.',
    ),
    const _MeteorShower(
      name: 'Lyrids',
      windowLabel: 'Apr 16–25',
      peakMonth: 4,
      peakDay: 22,
      note: 'A classic spring shower with bright, fast streaks.',
    ),
    const _MeteorShower(
      name: 'Eta Aquariids',
      windowLabel: 'Apr 19–May 28',
      peakMonth: 5,
      peakDay: 5,
      note: 'Often better from the Southern Hemisphere, but still a big calendar marker.',
    ),
    const _MeteorShower(
      name: 'Perseids',
      windowLabel: 'Jul 17–Aug 24',
      peakMonth: 8,
      peakDay: 12,
      note: 'Usually the most celebrated summer meteor shower.',
    ),
    const _MeteorShower(
      name: 'Orionids',
      windowLabel: 'Oct 2–Nov 7',
      peakMonth: 10,
      peakDay: 21,
      note: 'A strong autumn shower tied to Halley’s Comet.',
    ),
    const _MeteorShower(
      name: 'Leonids',
      windowLabel: 'Nov 6–30',
      peakMonth: 11,
      peakDay: 17,
      note: 'A sharp mid-November shower with occasional bursts.',
    ),
    const _MeteorShower(
      name: 'Geminids',
      windowLabel: 'Dec 4–17',
      peakMonth: 12,
      peakDay: 13,
      note: 'Often the brightest and most reliable winter shower.',
    ),
  ];

  final normalized = DateTime(date.year, date.month, date.day);
  _MeteorShower? nearest;
  var nearestDistance = 9999;

  for (final shower in showers) {
    final peakDate = DateTime(date.year, shower.peakMonth, shower.peakDay);
    final distance = normalized.difference(peakDate).inDays.abs();
    if (distance < nearestDistance) {
      nearest = shower;
      nearestDistance = distance;
    }
  }

  return nearest ?? showers.first;
}

String _eclipseNoteFor(DateTime date, MoonSnapshot moon) {
  final age = moon.ageDays;
  final nearNewMoon = age <= 2 || age >= 27.5;
  final nearFullMoon = age >= 14 && age <= 17;

  if (nearNewMoon || nearFullMoon) {
    return 'Eclipse geometry was more plausible around this lunar phase, but exact visibility depends on location.';
  }

  return 'No obvious eclipse window stood out from the Moon phase alone.';
}

class _MeteorShower {
  const _MeteorShower({
    required this.name,
    required this.windowLabel,
    required this.peakMonth,
    required this.peakDay,
    required this.note,
  });

  final String name;
  final String windowLabel;
  final int peakMonth;
  final int peakDay;
  final String note;
}
