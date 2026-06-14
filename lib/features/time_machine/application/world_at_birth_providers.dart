import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/world_snapshot.dart';

final worldAtBirthRepositoryProvider = Provider<WorldAtBirthRepository>((ref) {
  return WorldAtBirthRepository();
});

final worldAtBirthProvider = FutureProvider.family<WorldAtBirthSnapshot, DateTime>((ref, birthDate) async {
  final repository = ref.read(worldAtBirthRepositoryProvider);
  return repository.loadSnapshot(birthDate);
});

class WorldAtBirthRepository {
  WorldAtBirthRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WorldAtBirthSnapshot> loadSnapshot(DateTime birthDate) async {
    final normalized = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final mm = normalized.month.toString().padLeft(2, '0');
    final dd = normalized.day.toString().padLeft(2, '0');

    try {
      final summary = await _fetchYearSummary(normalized.year);
      final events = await _fetchMoments('events', mm, dd);
      final births = await _fetchMoments('births', mm, dd);
      final deaths = await _fetchMoments('deaths', mm, dd);

      final hasLiveData =
          summary.extract.isNotEmpty || events.isNotEmpty || births.isNotEmpty || deaths.isNotEmpty;

      if (!hasLiveData) {
        return buildFallbackSnapshot(normalized, notes: 'No live historical data came back.');
      }

      return WorldAtBirthSnapshot(
        birthDate: normalized,
        yearSummary: summary,
        events: events,
        births: births,
        deaths: deaths,
        seasonLabel: seasonFor(normalized),
        weekdayLabel: weekdayLabel(normalized),
        eraLabel: eraFor(normalized.year),
        sourceLabel: 'Wikipedia + Wikimedia',
        isLive: true,
        notes: 'Built from the year summary and on-this-day data for $mm/$dd.',
      );
    } catch (error) {
      return buildFallbackSnapshot(normalized, notes: error.toString());
    }
  }

  Future<WorldYearSummary> _fetchYearSummary(int year) async {
    final data = await _getJson(Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$year'));
    return WorldYearSummary(
      year: year,
      description: (data['description'] as String?) ?? 'Calendar year',
      extract: (data['extract'] as String?) ?? '',
    );
  }

  Future<List<WorldMoment>> _fetchMoments(String kind, String month, String day) async {
    final data = await _getJson(
      Uri.parse('https://api.wikimedia.org/feed/v1/wikipedia/en/onthisday/$kind/$month/$day'),
    );

    final items = (data[kind] as List<dynamic>? ?? const <dynamic>[]);
    return items
        .take(4)
        .map((item) {
          final map = item as Map<String, dynamic>;
          final pages = (map['pages'] as List<dynamic>? ?? const <dynamic>[]);
          final firstPage = pages.isNotEmpty ? pages.first as Map<String, dynamic> : const <String, dynamic>{};
          final titles = firstPage['titles'] as Map<String, dynamic>? ?? const <String, dynamic>{};
          final urls = firstPage['content_urls'] as Map<String, dynamic>? ?? const <String, dynamic>{};
          final desktop = urls['desktop'] as Map<String, dynamic>? ?? const <String, dynamic>{};
          final thumbnail = firstPage['thumbnail'] as Map<String, dynamic>? ?? const <String, dynamic>{};
          final rawTitle = (titles['normalized'] as String?) ?? (firstPage['title'] as String?) ?? (map['text'] as String?) ?? 'Untitled';

          return WorldMoment(
            year: map['year'] as int?,
            title: rawTitle.replaceAll('_', ' '),
            description: (map['text'] as String?) ?? '',
            url: desktop['page'] as String?,
            thumbnailUrl: thumbnail['source'] as String?,
          );
        })
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _client.get(
      uri,
      headers: const {
        'accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    return decoded;
  }
}
