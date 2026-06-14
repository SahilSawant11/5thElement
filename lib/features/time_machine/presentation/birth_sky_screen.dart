import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/section_header.dart';
import '../application/astronomy_at_birth_providers.dart';
import '../application/birth_date_controller.dart';
import '../domain/astronomy_snapshot.dart';

class BirthSkyScreen extends ConsumerWidget {
  const BirthSkyScreen({super.key});

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

        final snapshotAsync = ref.watch(astronomyAtBirthProvider(birthDate));

        return snapshotAsync.when(
          loading: () => const _LoadingScreen(),
          error: (error, stackTrace) => _ErrorScreen(message: error.toString()),
          data: (snapshot) {
            return AppScaffold(
              appBar: AppBar(
                title: const Text('The sky when you were born'),
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                    sliver: SliverToBoxAdapter(
                      child: _DelayedReveal(
                        delay: const Duration(milliseconds: 0),
                        child: _SkyHero(snapshot: snapshot),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    sliver: SliverToBoxAdapter(
                      child: _DelayedReveal(
                        delay: const Duration(milliseconds: 120),
                        child: _SourceStrip(snapshot: snapshot),
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Moon and light',
                        subtitle: 'A cleaner moon, plus the daylight pattern around your date.',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: _DelayedReveal(
                        delay: const Duration(milliseconds: 180),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 900;
                            final moonCard = _MoonCard(snapshot: snapshot);
                            final daylightCard = _DaylightCard(snapshot: snapshot);

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: moonCard),
                                  const SizedBox(width: 16),
                                  Expanded(child: daylightCard),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                moonCard,
                                const SizedBox(height: 16),
                                daylightCard,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Seasonal sky',
                        subtitle: 'Constellations and planets that fit the season of your birth date.',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: _DelayedReveal(
                        delay: const Duration(milliseconds: 260),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 900;
                            final visibleSkyCard = _VisibleSkyCard(snapshot: snapshot);
                            final skyEventsCard = _SkyEventsCard(snapshot: snapshot);

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: visibleSkyCard),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 2, child: skyEventsCard),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                visibleSkyCard,
                                const SizedBox(height: 16),
                                skyEventsCard,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Moon through life',
                        subtitle: 'A small timeline of moon phases across your milestones.',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: _DelayedReveal(
                        delay: const Duration(milliseconds: 340),
                        child: _MoonTimelineCard(snapshot: snapshot),
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Archive image',
                        subtitle: 'A live NASA APOD card still sits in the mix, but it is no longer the whole story.',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: _DelayedReveal(
                        delay: const Duration(milliseconds: 420),
                        child: _ApodCard(snapshot: snapshot),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    sliver: SliverToBoxAdapter(
                      child: _DelayedReveal(
                        delay: const Duration(milliseconds: 500),
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
                                'You’ve seen the sky you arrived under. Now step into the personal timeline that followed.',
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

class _SkyHero extends StatelessWidget {
  const _SkyHero({required this.snapshot});

  final AstronomySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 760;

          final textSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                snapshot.title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 0.98,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                snapshot.subtitle,
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
                  _FactChip(label: snapshot.moon.phaseLabel),
                  _FactChip(label: '${snapshot.moon.phaseEmoji} ${snapshot.moon.illuminationPercent}% lit'),
                  _FactChip(label: snapshot.daylight.referenceLabel),
                ],
              ),
            ],
          );

          final moonBadge = Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 44,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: _MoonVisual(snapshot: snapshot, size: 170),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: textSection),
                const SizedBox(width: 20),
                moonBadge,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textSection,
              const SizedBox(height: 22),
              Center(child: moonBadge),
            ],
          );
        },
      ),
    );
  }
}

class _MoonCard extends StatelessWidget {
  const _MoonCard({required this.snapshot});

  final AstronomySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moon = snapshot.moon;

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.nights_stay_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Moon',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: _MoonVisual(snapshot: snapshot, size: 204),
          ),
          const SizedBox(height: 18),
          _StatLine(label: 'Moon age', value: '${moon.ageDays} days'),
          _StatLine(label: 'Illumination', value: '${moon.illuminationPercent}%'),
          _StatLine(label: 'Season', value: snapshot.seasonLabel),
        ],
      ),
    );
  }
}

class _MoonVisual extends StatelessWidget {
  const _MoonVisual({
    required this.snapshot,
    required this.size,
  });

  final AstronomySnapshot snapshot;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moon = snapshot.moon;
    final phaseLabel = moon.phaseLabel.toLowerCase();
    final isWaxing = phaseLabel.contains('waxing');
    final isWaning = phaseLabel.contains('waning');
    final isFull = phaseLabel.contains('full');
    final isNew = phaseLabel.contains('new');
    final darkness = 1 - (moon.illuminationPercent / 100).clamp(0.0, 1.0);
    final shadowShift = size * 0.34 * darkness;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.34, -0.34),
                radius: 0.96,
                colors: [
                  Color(0xFFF4EEE2),
                  Color(0xFFDDD4C1),
                  Color(0xFFB9AE9B),
                ],
                stops: [0.0, 0.62, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
          ),
          if (!isFull)
            Transform.translate(
              offset: Offset(isNew ? 0 : (isWaxing ? -shadowShift : isWaning ? shadowShift : 0), 0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface.withValues(alpha: 0.96),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _MoonTexturePainter(
                  craterTone: Colors.black.withValues(alpha: 0.06),
                  accentTone: Colors.black.withValues(alpha: 0.02),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            child: Column(
              children: [
                Text(
                  moon.phaseEmoji == '◌' ? '●' : moon.phaseEmoji,
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: size * 0.16),
                ),
                const SizedBox(height: 2),
                Text(
                  moon.phaseLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoonTexturePainter extends CustomPainter {
  const _MoonTexturePainter({
    required this.craterTone,
    required this.accentTone,
  });

  final Color craterTone;
  final Color accentTone;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;

    final craterPaint = Paint()..color = craterTone;
    final shadowPaint = Paint()..color = accentTone;

    final craterOffsets = <Offset>[
      Offset(center.dx - radius * 0.30, center.dy - radius * 0.18),
      Offset(center.dx + radius * 0.16, center.dy - radius * 0.24),
      Offset(center.dx - radius * 0.04, center.dy + radius * 0.05),
      Offset(center.dx + radius * 0.22, center.dy + radius * 0.18),
    ];

    for (final offset in craterOffsets) {
      canvas.drawCircle(offset, radius * 0.055, craterPaint);
      canvas.drawCircle(offset.translate(radius * 0.018, radius * 0.01), radius * 0.022, shadowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MoonTexturePainter oldDelegate) {
    return oldDelegate.craterTone != craterTone || oldDelegate.accentTone != accentTone;
  }
}

class _DaylightCard extends StatelessWidget {
  const _DaylightCard({required this.snapshot});

  final AstronomySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daylight = snapshot.daylight;

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_rounded, color: theme.colorScheme.secondary),
              const SizedBox(width: 10),
              Text(
                'Sun and daylight',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _StatLine(label: 'Sunrise', value: daylight.sunriseLabel),
          _StatLine(label: 'Sunset', value: daylight.sunsetLabel),
          _StatLine(label: 'Daylight length', value: formatDurationHours(daylight.daylightHours)),
          const SizedBox(height: 4),
          Text(
            daylight.note,
            style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
          ),
        ],
      ),
    );
  }
}

class _VisibleSkyCard extends StatelessWidget {
  const _VisibleSkyCard({required this.snapshot});

  final AstronomySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleSky = snapshot.visibleSky;

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.tertiary),
              const SizedBox(width: 10),
              Text(
                visibleSky.seasonLabel,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Constellations',
            style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: visibleSky.constellations
                .map((constellation) => _FactChip(label: constellation))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Planets',
            style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: visibleSky.planets.map((planet) => _FactChip(label: planet)).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            visibleSky.note,
            style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
          ),
        ],
      ),
    );
  }
}

class _SkyEventsCard extends StatelessWidget {
  const _SkyEventsCard({required this.snapshot});

  final AstronomySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skyEvents = snapshot.skyEvents;

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Meteor & eclipse watch',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _StatLine(label: 'Closest shower', value: skyEvents.meteorShower),
          _StatLine(label: 'Shower window', value: skyEvents.meteorWindow),
          _StatLine(label: 'Eclipse note', value: skyEvents.eclipseNote),
          const SizedBox(height: 4),
          Text(
            skyEvents.note,
            style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
          ),
        ],
      ),
    );
  }
}

class _MoonTimelineCard extends StatelessWidget {
  const _MoonTimelineCard({required this.snapshot});

  final AstronomySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Moon phase timeline',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Milestone birthdays and the Moon phase each one landed on.',
            style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 760;
              final items = snapshot.moonTimeline
                  .map((point) => _MoonTimelineTile(point: point))
                  .toList();

              if (isWide) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: items
                      .map(
                        (item) => SizedBox(
                          width: 180,
                          child: item,
                        ),
                      )
                      .toList(),
                );
              }

              return Column(
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: item,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoonTimelineTile extends StatelessWidget {
  const _MoonTimelineTile({required this.point});

  final MoonTimelinePoint point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      opacity: 0.64,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: Text(
                  point.moon.phaseEmoji == '◌' ? '●' : point.moon.phaseEmoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  point.label,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            displayDate(point.date),
            style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${point.moon.phaseLabel} · ${point.moon.illuminationPercent}% lit',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ApodCard extends StatelessWidget {
  const _ApodCard({required this.snapshot});

  final AstronomySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apod = snapshot.apod;
    final previewUrl = apod.thumbnailUrl ?? apod.url;

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
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'NASA APOD',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: previewUrl == null
                  ? _ApodPlaceholder(mediaType: apod.mediaType)
                  : Image.network(
                      previewUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return _ApodPlaceholder(mediaType: apod.mediaType);
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _ApodPlaceholder(mediaType: apod.mediaType);
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            apod.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            apod.explanation,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.74),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FactChip(label: displayDate(apod.date)),
              _FactChip(label: apod.isFallback ? 'Archive fallback' : 'Exact birth date'),
              _FactChip(label: apod.mediaType.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApodPlaceholder extends StatelessWidget {
  const _ApodPlaceholder({required this.mediaType});

  final String mediaType;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.18),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mediaType == 'video' ? Icons.play_circle_fill_rounded : Icons.image_rounded,
              size: 44,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 8),
            Text(
              mediaType == 'video' ? 'APOD video' : 'APOD image',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceStrip extends StatelessWidget {
  const _SourceStrip({required this.snapshot});

  final AstronomySnapshot snapshot;

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

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.58),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
    return Chip(label: Text(label));
  }
}

class _DelayedReveal extends StatefulWidget {
  const _DelayedReveal({
    required this.delay,
    required this.child,
  });

  final Duration delay;
  final Widget child;

  @override
  State<_DelayedReveal> createState() => _DelayedRevealState();
}

class _DelayedRevealState extends State<_DelayedReveal> {
  late final Future<void> _delayFuture = Future<void>.delayed(widget.delay);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _delayFuture,
      builder: (context, snapshot) {
        final visible = snapshot.connectionState == ConnectionState.done;

        return AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, 0.03),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOut,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = 0.45 + (_controller.value * 0.25);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                sliver: SliverToBoxAdapter(
                  child: _LoadingPanel(
                    pulse: pulse,
                    child: _LoadingHeroSkeleton(pulse: pulse),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                sliver: SliverToBoxAdapter(
                  child: _LoadingStrip(pulse: pulse),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: _LoadingSectionHeader(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      final moonCard = _LoadingCardSkeleton(pulse: pulse, height: 320);
                      final daylightCard = _LoadingCardSkeleton(pulse: pulse, height: 320);

                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(child: moonCard),
                            const SizedBox(width: 16),
                            Expanded(child: daylightCard),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          moonCard,
                          const SizedBox(height: 16),
                          daylightCard,
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: _LoadingSectionHeader(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      final visibleSkyCard = _LoadingCardSkeleton(pulse: pulse, height: 240);
                      final eventsCard = _LoadingCardSkeleton(pulse: pulse, height: 240);

                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(flex: 3, child: visibleSkyCard),
                            const SizedBox(width: 16),
                            Expanded(flex: 2, child: eventsCard),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          visibleSkyCard,
                          const SizedBox(height: 16),
                          eventsCard,
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: _LoadingSectionHeader(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: _LoadingCardSkeleton(pulse: pulse, height: 240),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: _LoadingSectionHeader(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: _LoadingCardSkeleton(pulse: pulse, height: 280),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({
    required this.pulse,
    required this.child,
  });

  final double pulse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: pulse,
      child: child,
    );
  }
}

class _LoadingHeroSkeleton extends StatelessWidget {
  const _LoadingHeroSkeleton({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 760;
          final moon = _skeletonCircle(pulse, 170);

          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skeletonLine(pulse, widthFactor: 0.45, height: 24),
              const SizedBox(height: 14),
              _skeletonLine(pulse, widthFactor: 0.92, height: 20),
              const SizedBox(height: 8),
              _skeletonLine(pulse, widthFactor: 0.78, height: 20),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  3,
                  (index) => _skeletonChip(pulse, width: 88 + (index * 18).toDouble()),
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: text),
                const SizedBox(width: 20),
                moon,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text,
              const SizedBox(height: 20),
              Center(child: moon),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingStrip extends StatelessWidget {
  const _LoadingStrip({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.public_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: pulse)),
        const SizedBox(width: 8),
        Expanded(
          child: _skeletonLine(pulse, widthFactor: 0.72, height: 14),
        ),
      ],
    );
  }
}

class _LoadingSectionHeader extends StatelessWidget {
  const _LoadingSectionHeader();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      opacity: 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 140, height: 18, decoration: _skeletonDecoration()),
          const SizedBox(height: 8),
          Container(width: 250, height: 12, decoration: _skeletonDecoration()),
        ],
      ),
    );
  }
}

class _LoadingCardSkeleton extends StatelessWidget {
  const _LoadingCardSkeleton({
    required this.pulse,
    required this.height,
  });

  final double pulse;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Opacity(
        opacity: pulse,
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skeletonLine(pulse, widthFactor: 0.48, height: 18),
              const SizedBox(height: 16),
              Expanded(child: Container(decoration: _skeletonDecoration(radius: 20))),
              const SizedBox(height: 16),
              _skeletonLine(pulse, widthFactor: 0.82, height: 14),
              const SizedBox(height: 8),
              _skeletonLine(pulse, widthFactor: 0.64, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _skeletonCircle(double pulse, double size) {
  return Opacity(
    opacity: pulse,
    child: Container(
      width: size,
      height: size,
      decoration: _skeletonDecoration(radius: size / 2),
    ),
  );
}

Widget _skeletonChip(double pulse, {required double width}) {
  return Opacity(
    opacity: pulse,
    child: Container(
      width: width,
      height: 32,
      decoration: _skeletonDecoration(radius: 16),
    ),
  );
}

Widget _skeletonLine(double pulse, {required double widthFactor, required double height}) {
  return FractionallySizedBox(
    widthFactor: widthFactor,
    alignment: Alignment.centerLeft,
    child: Opacity(
      opacity: pulse,
      child: Container(
        height: height,
        decoration: _skeletonDecoration(radius: height / 2),
      ),
    ),
  );
}

BoxDecoration _skeletonDecoration({double radius = 14}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0.04),
      ],
    ),
  );
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(child: Text(message)),
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
