import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/time_portal_providers.dart';
import '../../domain/time_portal.dart';

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key, required this.portal});

  final TimePortal portal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.onSurface.withValues(alpha: 0.02),
            colorScheme.primary.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.98, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _IntroCopy(
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          portal: portal,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: FeaturedAccentCard(portal: portal),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IntroCopy(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      portal: portal,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FeaturedAccentCard(portal: portal),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy({
    required this.colorScheme,
    required this.textTheme,
    required this.portal,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final TimePortal portal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '5th Element',
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A personal time machine',
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 0.95,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Return to a feeling, a place, or a version of yourself without losing the wonder.',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.72),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MetricChip(label: '${portal.year}', value: 'Feature year'),
            MetricChip(
              label: portal.category.label,
              value: 'Selected lens',
            ),
          ],
        ),
      ],
    );
  }
}

class FeaturedAccentCard extends StatelessWidget {
  const FeaturedAccentCard({super.key, required this.portal});

  final TimePortal portal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            portal.accent.withValues(alpha: 0.95),
            portal.accent.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured portal',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 18),
          Text(
            portal.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          Text(
            portal.highlight,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key, required this.selectedCategory});

  final TimePortalCategory selectedCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TimePortalCategory.values
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(category.label),
                  selected: category == selectedCategory,
                  onSelected: (_) {
                    ref.read(selectedCategoryProvider.notifier).state = category;
                  },
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class MetricChip extends StatelessWidget {
  const MetricChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.66),
                ),
          ),
        ],
      ),
    );
  }
}
