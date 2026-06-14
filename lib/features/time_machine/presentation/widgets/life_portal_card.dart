import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_panel.dart';
import '../../domain/life_portal.dart';

class LifePortalCard extends StatelessWidget {
  const LifePortalCard({
    super.key,
    required this.portal,
    required this.onTap,
  });

  final LifePortal portal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.985, end: 1),
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: GlassPanel(
            borderRadius: 28,
            padding: const EdgeInsets.all(20),
            opacity: 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(portal: portal),
                const Spacer(),
                Text(
                  portal.summary,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.76),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: portal.tags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.portal});

  final LifePortal portal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${portal.age}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: portal.accent,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                portal.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.03,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                portal.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                ),
              ),
            ],
          ),
        ),
        Hero(
          tag: 'life-${portal.age}',
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  portal.accent.withValues(alpha: 0.95),
                  portal.accent.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
