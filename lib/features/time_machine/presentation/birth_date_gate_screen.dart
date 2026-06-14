import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../application/birth_date_controller.dart';
import 'birth_date_onboarding_screen.dart';
import 'life_timeline_screen.dart';

class BirthDateGateScreen extends ConsumerWidget {
  const BirthDateGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthDateAsync = ref.watch(birthDateControllerProvider);

    return birthDateAsync.when(
      loading: () => const _LoadingGlassScreen(),
      error: (error, stackTrace) => _GateErrorScreen(message: error.toString()),
      data: (birthDate) {
        if (birthDate == null) {
          return const BirthDateOnboardingScreen();
        }

        return const LifeTimelineScreen();
      },
    );
  }
}

class _LoadingGlassScreen extends StatelessWidget {
  const _LoadingGlassScreen();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Opening your time machine...',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GateErrorScreen extends StatelessWidget {
  const _GateErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
