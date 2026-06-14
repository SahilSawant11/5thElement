import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final birthDateControllerProvider =
    AsyncNotifierProvider<BirthDateController, DateTime?>(BirthDateController.new);

class BirthDateController extends AsyncNotifier<DateTime?> {
  static const _storageKey = 'birth_date_millis';

  @override
  Future<DateTime?> build() async {
    final preferences = await SharedPreferences.getInstance();
    final storedMillis = preferences.getInt(_storageKey);
    if (storedMillis == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(storedMillis);
  }

  Future<void> setBirthDate(DateTime birthDate) async {
    final normalized = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_storageKey, normalized.millisecondsSinceEpoch);
    state = AsyncData(normalized);
  }

  Future<void> clearBirthDate() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
    state = const AsyncData(null);
  }
}
