import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../application/birth_date_controller.dart';

class BirthDateOnboardingScreen extends ConsumerStatefulWidget {
  const BirthDateOnboardingScreen({super.key});

  @override
  ConsumerState<BirthDateOnboardingScreen> createState() => _BirthDateOnboardingScreenState();
}

class _BirthDateOnboardingScreenState extends ConsumerState<BirthDateOnboardingScreen> {
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 25, now.month, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'When did your story begin?',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _continue() async {
    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      return;
    }

    await ref.read(birthDateControllerProvider.notifier).setBirthDate(selectedDate);
    if (mounted) {
      context.go('/sky');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedLabel = _selectedDate == null
        ? 'Pick your birth date'
        : MaterialLocalizations.of(context).formatMediumDate(_selectedDate!);

    return AppScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 560),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: GlassPanel(
                padding: const EdgeInsets.all(28),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 760;

                    final introSection = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '5th Element',
                          style: theme.textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.6,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter your birth date.\nWatch your life unfold.',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We turn your timeline into a set of cinematic portals, revealing eras, chapters, and the feeling of where you are right now.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.55,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.74),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            _SoftMetric(label: 'Age', value: 'Calculated'),
                            _SoftMetric(label: 'Eras', value: 'Generated'),
                            _SoftMetric(label: 'Portals', value: 'Unfolded'),
                          ],
                        ),
                      ],
                    );

                    final dateSection = GlassPanel(
                      padding: const EdgeInsets.all(22),
                      opacity: 0.72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Birth date',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedLabel,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Tap to choose your date. The app remembers it, then generates your life-time portals immediately.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                            ),
                          ),
                          const SizedBox(height: 22),
                          FilledButton.tonal(
                            onPressed: _pickDate,
                            child: const Text('Choose birth date'),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _selectedDate == null ? null : _continue,
                            child: const Text('See the sky I was born under'),
                          ),
                        ],
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: introSection),
                          const SizedBox(width: 24),
                          Expanded(flex: 5, child: dateSection),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        introSection,
                        const SizedBox(height: 24),
                        dateSection,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftMetric extends StatelessWidget {
  const _SoftMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      opacity: 0.56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62),
                ),
          ),
        ],
      ),
    );
  }
}
