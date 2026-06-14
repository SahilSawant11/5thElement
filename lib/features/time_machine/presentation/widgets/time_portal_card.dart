import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_panel.dart';
import '../../domain/time_portal.dart';

class TimePortalCard extends StatefulWidget {
  const TimePortalCard({
    super.key,
    required this.portal,
    required this.onTap,
  });

  final TimePortal portal;
  final VoidCallback onTap;

  @override
  State<TimePortalCard> createState() => _TimePortalCardState();
}

class _TimePortalCardState extends State<TimePortalCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lift = (_isHovered ? 1 : 0) + (_isPressed ? 1 : 0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, lift * -3, 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(30),
                child: GlassPanel(
                  borderRadius: 30,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PortalHeader(portal: widget.portal),
                      const SizedBox(height: 18),
                      Text(
                        widget.portal.summary,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.76),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.portal.tags
                            .map(
                              (tag) => _TagChip(
                                label: tag,
                                accent: widget.portal.accent,
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Text(
                            'Open portal',
                            style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: widget.portal.accent,
                                ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 18,
                            color: widget.portal.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalHeader extends StatelessWidget {
  const _PortalHeader({required this.portal});

  final TimePortal portal;

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
                '${portal.year}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: portal.accent,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                portal.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                portal.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Hero(
          tag: 'portal-${portal.id}',
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: portal.accent.withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  portal.accent.withValues(alpha: 0.96),
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: 0.08),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: accent,
              ),
        ),
      ),
    );
  }
}
