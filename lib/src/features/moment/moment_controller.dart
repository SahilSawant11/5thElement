import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'moment.dart';

final momentsProvider = StateNotifierProvider<MomentsNotifier, List<Moment>>((ref) {
  return MomentsNotifier();
});

class MomentsNotifier extends StateNotifier<List<Moment>> {
  MomentsNotifier()
      : super(List.generate(
          6,
          (i) => Moment(
            id: '$i',
            title: 'Memory ${i + 1}',
            description: 'A fleeting memory from day ${i + 1}.',
            image: '',
            date: DateTime.now().subtract(Duration(days: i * 30)),
          ),
        ));

  final _rand = Random();

  void addRandom() {
    final i = _rand.nextInt(10000);
    final m = Moment(
      id: '$i',
      title: 'Memory $i',
      description: 'A newly captured moment #$i.',
      image: '',
      date: DateTime.now(),
    );
    state = [m, ...state];
  }

  Moment? byId(String id) {
    for (final moment in state) {
      if (moment.id == id) {
        return moment;
      }
    }

    return null;
  }
}
