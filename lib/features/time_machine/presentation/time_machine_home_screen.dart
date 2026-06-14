import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../application/time_portal_providers.dart';
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
