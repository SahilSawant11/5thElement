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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    sliver: SliverToBoxAdapter(child: _SkyHero(snapshot: snapshot)),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(child: _SourceStrip(snapshot: snapshot)),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 14, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Moon and light',
                        subtitle: 'The sky’s core details on your birth date.',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;
                          final moonCard = _MoonCard(snapshot: snapshot);
                          final apodCard = _ApodCard(snapshot: snapshot);

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: moonCard),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: apodCard),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              moonCard,
                              const SizedBox(height: 16),
                              apodCard,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Sky context',
                        subtitle: 'Season, weekday, and the astronomy note for that date.',
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
                              snapshot.skyNote,
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
                                _FactChip(label: snapshot.seasonLabel),
                                _FactChip(label: snapshot.weekdayLabel),
                                _FactChip(label: displayDate(snapshot.observationDate)),
                                _FactChip(label: snapshot.apod.isFallback ? 'Archive fallback' : 'Live NASA APOD'),
                              ],
                            ),
                          ],
                        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              _FactChip(label: snapshot.sourceLabel),
            ],
          ),
        ],
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
          Text(
            'Moon',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 198,
              height: 198,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    blurRadius: 44,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _MoonPainter(
                  phaseLabel: moon.phaseLabel,
                  illuminationPercent: moon.illuminationPercent,
                  accent: theme.colorScheme.primary,
                  shadowTone: theme.colorScheme.onSurface,
                ),
              ),
            ),
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

class _MoonPainter extends CustomPainter {
  const _MoonPainter({
    required this.phaseLabel,
    required this.illuminationPercent,
    required this.accent,
    required this.shadowTone,
  });

  final String phaseLabel;
  final double illuminationPercent;
  final Color accent;
  final Color shadowTone;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final phaseKey = phaseLabel.toLowerCase();
    final isWaxing = phaseKey.contains('waxing');
    final isWaning = phaseKey.contains('waning');
    final isFull = phaseKey.contains('full');
    final isNew = phaseKey.contains('new');
    final quarter = phaseKey.contains('quarter');

    final basePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.98),
          const Color(0xFFECE7DB),
          const Color(0xFFD8D2C4),
        ],
        stops: const [0.0, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, basePaint);

    final shadowPaint = Paint()..color = shadowTone.withValues(alpha: 0.92);
    final offset = radius * 0.38;

    if (isNew) {
      canvas.drawCircle(center, radius, shadowPaint);
    } else if (isFull) {
      // No terminator overlay for full moon.
    } else {
      final shadowCenter = Offset(
        center.dx + (isWaxing ? offset : isWaning ? -offset : 0),
        center.dy,
      );
      final shadowRect = Rect.fromCircle(center: shadowCenter, radius: radius);

      canvas.saveLayer(Rect.fromCircle(center: center, radius: radius), Paint());
      canvas.drawCircle(center, radius, basePaint);
      canvas.drawCircle(shadowCenter, radius, shadowPaint);

      final terminatorPaint = Paint()
        ..blendMode = BlendMode.srcOut
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: quarter ? 0.9 : 0.96),
          ],
          stops: const [0.48, 1.0],
        ).createShader(shadowRect);
      canvas.drawRect(shadowRect, terminatorPaint);
      canvas.restore();
    }

    final craterPaint = Paint()..color = Colors.black.withValues(alpha: 0.06);
    final craterRings = <Offset>[
      Offset(center.dx - radius * 0.22, center.dy - radius * 0.18),
      Offset(center.dx + radius * 0.12, center.dy - radius * 0.02),
      Offset(center.dx - radius * 0.02, center.dy + radius * 0.18),
    ];
    for (final crater in craterRings) {
      canvas.drawCircle(crater, radius * 0.05, craterPaint);
    }

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center.translate(-radius * 0.18, -radius * 0.22), radius * 0.62, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) {
    return oldDelegate.phaseLabel != phaseLabel ||
        oldDelegate.illuminationPercent != illuminationPercent ||
        oldDelegate.accent != accent ||
        oldDelegate.shadowTone != shadowTone;
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
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.16),
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
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
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

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      child: Center(child: CircularProgressIndicator()),
    );
  }
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
