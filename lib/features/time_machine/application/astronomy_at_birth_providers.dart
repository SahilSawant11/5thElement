import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/astronomy_snapshot.dart';

final astronomyAtBirthRepositoryProvider = Provider<AstronomyAtBirthRepository>((ref) {
  return AstronomyAtBirthRepository();
});

final astronomyAtBirthProvider =
    FutureProvider.family<AstronomySnapshot, DateTime>((ref, birthDate) async {
  final repository = ref.read(astronomyAtBirthRepositoryProvider);
  return repository.loadSnapshot(birthDate);
});

class AstronomyAtBirthRepository {
  AstronomyAtBirthRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AstronomySnapshot> loadSnapshot(DateTime birthDate) async {
    final normalized = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final apodDate = apodDateFor(normalized);

    try {
      final apod = await _fetchApod(apodDate, fallbackToLaunchDay: apodDate != normalized);
      return buildAstronomySnapshot(
        birthDate: normalized,
        apod: apod,
        isLive: true,
        sourceLabel: 'NASA APOD',
        notes: apod.isFallback
            ? 'Your exact birth date predates APOD, so we showed the launch-day sky archive.'
            : 'Built from NASA APOD plus moon, daylight, and seasonal sky estimates.',
      );
    } catch (_) {
      return buildAstronomySnapshot(
        birthDate: normalized,
        apod: ApodSnapshot(
          date: apodDate,
          title: 'Astronomy snapshot unavailable',
          explanation:
              'NASA APOD could not be loaded right now, so this is a local fallback. The moon-phase card still works.',
          url: null,
          mediaType: 'image',
          thumbnailUrl: null,
          credit: 'Local fallback',
          isFallback: true,
        ),
        isLive: false,
        sourceLabel: 'Local fallback',
        notes: 'Live APOD could not load, so the sky cards are using local estimates.',
      );
    }
  }

  Future<ApodSnapshot> _fetchApod(DateTime date, {required bool fallbackToLaunchDay}) async {
    final queryDate = Uri.encodeComponent('${date.year}-${_two(date.month)}-${_two(date.day)}');
    final uri = Uri.parse(
      'https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&date=$queryDate&thumbs=true',
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('NASA APOD request failed with status ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected APOD response format');
    }

    final mediaType = (decoded['media_type'] as String?) ?? 'image';
    final isVideo = mediaType == 'video';

    return ApodSnapshot(
      date: date,
      title: (decoded['title'] as String?) ?? 'Astronomy Picture of the Day',
      explanation: (decoded['explanation'] as String?) ?? '',
      url: (decoded['url'] as String?) ?? (decoded['hdurl'] as String?),
      mediaType: mediaType,
      thumbnailUrl: isVideo ? decoded['thumbnail_url'] as String? : decoded['url'] as String?,
      credit: 'NASA APOD',
      isFallback: fallbackToLaunchDay,
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
