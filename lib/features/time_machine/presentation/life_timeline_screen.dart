import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/section_header.dart';
import '../application/birth_date_controller.dart';
import '../application/life_timeline_providers.dart';
import '../domain/life_portal.dart';
import 'widgets/life_portal_card.dart';

class LifeTimelineScreen extends ConsumerWidget {
  const LifeTimelineScreen({super.key});

  Future<void> _changeBirthDate(BuildContext context, WidgetRef ref) async {
    await ref.read(birthDateControllerProvider.notifier).clearBirthDate();
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(lifeSnapshotProvider);

    return snapshotAsync.when(
      loading: () => const _TimelineLoading(),
      error: (error, stackTrace) => _TimelineError(message: error.toString()),
      data: (snapshot) {
        final lifeSnapshot = snapshot;
        if (lifeSnapshot == null) {
          return const SizedBox.shrink();
        }

        return AppScaffold(
          appBar: AppBar(
            title: const Text('Your timeline'),
            actions: [
              TextButton(
                onPressed: () => _changeBirthDate(context, ref),
                child: const Text('Change date'),
              ),
            ],
          ),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: _SnapshotHero(snapshot: lifeSnapshot),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Time portals',
                    subtitle: 'Moments, chapters, and horizons generated from your birth date.',
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
                        childAspectRatio: columns == 1 ? 1.15 : 1.42,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final portal = lifeSnapshot.portals[index];
                          return LifePortalCard(
                            portal: portal,
                            onTap: () => context.go('/portal/${portal.id}'),
                          );
                        },
                        childCount: lifeSnapshot.portals.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SnapshotHero extends StatelessWidget {
  const _SnapshotHero({required this.snapshot});

  final LifeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;

          final storySection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You are ${snapshot.ageYears} years into the story',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 0.96,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Current chapter: ${snapshot.currentChapter}. Next chapter: ${snapshot.nextChapter}.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          );

          final metricsSection = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricBox(
                label: 'Days lived',
                value: snapshot.daysLived.toString(),
              ),
              _MetricBox(
                label: 'Days to birthday',
                value: snapshot.daysToNextBirthday.toString(),
              ),
              _MetricBox(
                label: 'Birth date',
                value: MaterialLocalizations.of(context).formatMediumDate(snapshot.birthDate),
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: storySection),
                const SizedBox(width: 24),
                Expanded(flex: 4, child: metricsSection),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              storySection,
              const SizedBox(height: 24),
              metricsSection,
            ],
          );
        },
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      opacity: 0.6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
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

class _TimelineLoading extends StatelessWidget {
  const _TimelineLoading();

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _TimelineError extends StatelessWidget {
  const _TimelineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(child: Text(message)),
    );
  }
}
