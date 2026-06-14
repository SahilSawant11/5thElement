import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/section_header.dart';
import '../application/birth_date_controller.dart';
import '../application/world_at_birth_providers.dart';
import '../domain/world_snapshot.dart';

class BirthWorldScreen extends ConsumerWidget {
  const BirthWorldScreen({super.key});

  Future<void> _changeDate(BuildContext context, WidgetRef ref) async {
    await ref.read(birthDateControllerProvider.notifier).clearBirthDate();
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthDateAsync = ref.watch(birthDateControllerProvider);

    return birthDateAsync.when(
      loading: () => const _LoadingScreen(),
      error: (error, stackTrace) => _ErrorScreen(message: error.toString()),
      data: (birthDate) {
        if (birthDate == null) {
          return const _RedirectingHome();
        }

        final snapshotAsync = ref.watch(worldAtBirthProvider(birthDate));

        return snapshotAsync.when(
          loading: () => const _LoadingScreen(),
          error: (error, stackTrace) => _ErrorScreen(message: error.toString()),
          data: (snapshot) {
            return AppScaffold(
              appBar: AppBar(
                title: const Text('The world you were born into'),
                actions: [
                  TextButton(
                    onPressed: () => _changeDate(context, ref),
                    child: const Text('Change date'),
                  ),
                ],
              ),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: _WorldHero(snapshot: snapshot),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: _SourceStrip(snapshot: snapshot),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'The year in focus',
                        subtitle: 'A real summary of the year you arrived.',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: GlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.yearSummary.extract,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.76),
                                  ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _FactChip(label: snapshot.eraLabel),
                                _FactChip(label: snapshot.seasonLabel),
                                _FactChip(label: snapshot.weekdayLabel),
                                _FactChip(label: '${snapshot.birthDate.year}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'What was happening that day',
                        subtitle: 'Events, births, and deaths around the same date.',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 980;
                          final cards = [
                            _MomentGroupCard(
                              title: 'Events',
                              accent: Theme.of(context).colorScheme.primary,
                              moments: snapshot.events,
                              emptyLabel: 'No live events loaded.',
                            ),
                            _MomentGroupCard(
                              title: 'Births',
                              accent: Theme.of(context).colorScheme.secondary,
                              moments: snapshot.births,
                              emptyLabel: 'No live births loaded.',
                            ),
                            _MomentGroupCard(
                              title: 'Deaths',
                              accent: Theme.of(context).colorScheme.tertiary,
                              moments: snapshot.deaths,
                              emptyLabel: 'No live deaths loaded.',
                            ),
                          ];

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: cards[0]),
                                const SizedBox(width: 16),
                                Expanded(child: cards[1]),
                                const SizedBox(width: 16),
                                Expanded(child: cards[2]),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              cards[0],
                              const SizedBox(height: 16),
                              cards[1],
                              const SizedBox(height: 16),
                              cards[2],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    sliver: SliverToBoxAdapter(
                      child: GlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ready to go deeper?',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'You’ve seen the world you arrived into. Now step into the chapters that followed.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.74),
                                  ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton(
                                  onPressed: () => context.go('/timeline'),
                                  child: const Text('Enter my timeline'),
                                ),
                                FilledButton.tonal(
                                  onPressed: () => _changeDate(context, ref),
                                  child: const Text('Change date'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _WorldHero extends StatelessWidget {
  const _WorldHero({required this.snapshot});

  final WorldAtBirthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snapshot.displayTitle,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 0.98,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A real historical snapshot, built from the year itself and the events that happened on that date.',
            style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.74),
                ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FactChip(label: snapshot.eraLabel),
              _FactChip(label: snapshot.seasonLabel),
              _FactChip(label: snapshot.weekdayLabel),
              _FactChip(label: snapshot.yearSummary.description),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceStrip extends StatelessWidget {
  const _SourceStrip({required this.snapshot});

  final WorldAtBirthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          snapshot.isLive ? Icons.public_rounded : Icons.cloud_off_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.58),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${snapshot.sourceLabel} · ${snapshot.notes}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62),
                ),
          ),
        ),
      ],
    );
  }
}

class _MomentGroupCard extends StatelessWidget {
  const _MomentGroupCard({
    required this.title,
    required this.accent,
    required this.moments,
    required this.emptyLabel,
  });

  final String title;
  final Color accent;
  final List<WorldMoment> moments;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (moments.isEmpty)
            Text(
              emptyLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                  ),
            )
          else
            Column(
              children: moments
                  .map(
                    (moment) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _MomentItem(moment: moment),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}

class _MomentItem extends StatelessWidget {
  const _MomentItem({required this.moment});

  final WorldMoment moment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (moment.year != null) ...[
            Text(
              '${moment.year}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            moment.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            moment.description,
            style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
          ),
        ],
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(
        child: Text(message),
      ),
    );
  }
}

class _RedirectingHome extends StatelessWidget {
  const _RedirectingHome();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go('/');
      }
    });
    return const _LoadingScreen();
  }
}
