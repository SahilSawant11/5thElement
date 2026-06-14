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
            colorScheme.tertiary.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.975, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return Transform.translate(
            offset: Offset(0, 10 * (1 - scale)),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -36,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.14),
                      colorScheme.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
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
          ],
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
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                portal.accent.withValues(alpha: 0.98),
                portal.accent.withValues(alpha: 0.5),
                portal.accent.withValues(alpha: 0.28),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured portal',
                style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
              ),
              const SizedBox(height: 18),
              Text(
                portal.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 14),
              Text(
                portal.highlight,
                style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Open the year',
                    style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: -14,
          top: -16,
          child: Hero(
            tag: 'featured-portal-${portal.id}',
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.96),
                    Colors.white.withValues(alpha: 0.16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
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
