import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _AmbientBackground()),
            const Positioned.fill(child: _BackdropVignette()),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: appBar,
              bottomNavigationBar: bottomNavigationBar,
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatefulWidget {
  const _AmbientBackground();

  @override
  State<_AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<_AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_controller.value);

          return Stack(
            children: [
              const SizedBox.expand(),
              Positioned(
                top: -110 + (t * 18),
                left: -60 + (t * 14),
                child: _GlowOrb(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                  size: 300,
                ),
              ),
              Positioned(
                top: 90 + (1 - t) * 22,
                right: -90 + (t * 10),
                child: _GlowOrb(
                  color: colorScheme.secondary.withValues(alpha: 0.12),
                  size: 240,
                ),
              ),
              Positioned(
                bottom: -120 + (1 - t) * 16,
                left: 100 + (t * 16),
                child: _GlowOrb(
                  color: colorScheme.tertiary.withValues(alpha: 0.1),
                  size: 280,
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _AtmospherePainter(
                    lineColor: colorScheme.onSurface.withValues(alpha: 0.025),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _BackdropVignette extends StatelessWidget {
  const _BackdropVignette();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              Colors.transparent,
              colorScheme.surface.withValues(alpha: 0.2),
              colorScheme.surface.withValues(alpha: 0.68),
            ],
            stops: const [0.55, 0.82, 1.0],
          ),
        ),
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    const spacing = 48.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}
