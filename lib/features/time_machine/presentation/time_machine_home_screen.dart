import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/section_header.dart';
import '../application/time_portal_providers.dart';
import '../domain/time_portal.dart';
import 'widgets/home_hero_section.dart';
import 'widgets/time_portal_card.dart';

class TimeMachineHomeScreen extends ConsumerWidget {
  const TimeMachineHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portals = ref.watch(filteredPortalsProvider);
    final featuredPortal = ref.watch(featuredPortalProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return AppScaffold(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            sliver: SliverToBoxAdapter(
              child: HomeHeroSection(portal: featuredPortal),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: CategoryFilterChips(selectedCategory: selectedCategory),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
            sliver: SliverToBoxAdapter(
              child: _HomeStatsStrip(
                portalCount: portals.length,
                selectedCategory: selectedCategory.label,
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Open a portal',
                subtitle: 'Curated moments that bend time a little.',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final columns = width > 980 ? 2 : 1;

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: columns == 1 ? 1.18 : 1.48,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return TimePortalCard(
                        portal: portals[index],
                        onTap: () => context.go('/portal/${portals[index].id}'),
                      );
                    },
                    childCount: portals.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeStatsStrip extends StatelessWidget {
  const _HomeStatsStrip({
    required this.portalCount,
    required this.selectedCategory,
  });

  final int portalCount;
  final String selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      opacity: 0.68,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _StatBlock(
            label: 'Portals',
            value: '$portalCount',
            accent: theme.colorScheme.primary,
          ),
          _StatBlock(
            label: 'Filter',
            value: selectedCategory,
            accent: theme.colorScheme.secondary,
          ),
          _StatBlock(
            label: 'Mode',
            value: 'Cinematic',
            accent: theme.colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62),
                  letterSpacing: 1.1,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
          ),
        ],
      ),
    );
  }
}
