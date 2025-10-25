import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🪐 NEBULA LOGIN ANIMATION 2.0
/// - Green Star Wars–style laser beam from C64 to Moon PNG.
/// - Glowing parallax stars, bloom, and cinematic energy effects.
/// - Auto-syncs to light/dark AppColors.
class NebulaLoginAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onErrorEnd;
  final bool errorMode;
  final Duration successDuration;
  final Duration errorDuration;
  final void Function(String phase)? onPhaseChange;

  const NebulaLoginAnimation({
    super.key,
    this.onComplete,
    this.onErrorEnd,
    this.onPhaseChange,
    this.errorMode = false,
    this.successDuration = const Duration(seconds: 3),
    this.errorDuration = const Duration(seconds: 2),
  });

  @override
  State<NebulaLoginAnimation> createState() => _NebulaLoginAnimationState();
}

class _NebulaLoginAnimationState extends State<NebulaLoginAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String? _lastPhase;

  final _moon = Image.asset('assets/images/moon.png');
  final _c64 = Image.asset(
    'assets/images/c64.svg',
    errorBuilder: (_, __, ___) => Image.asset('assets/images/c64.svg'),
  );

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: widget.errorMode
              ? widget.errorDuration
              : widget.successDuration,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.errorMode
                ? widget.onErrorEnd?.call()
                : widget.onComplete?.call();
          }
        });
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  void _handlePhases(double t) {
    if (widget.errorMode) {
      if (_lastPhase != 'error') {
        widget.onPhaseChange?.call('error');
        _lastPhase = 'error';
      }
      return;
    }
    if (t < 0.2 && _lastPhase != 'charge') {
      widget.onPhaseChange?.call('charge');
      _lastPhase = 'charge';
    } else if (t >= 0.2 && t < 0.85 && _lastPhase != 'fire') {
      widget.onPhaseChange?.call('fire');
      _lastPhase = 'fire';
    } else if (t >= 0.85 && _lastPhase != 'impact') {
      widget.onPhaseChange?.call('impact');
      _lastPhase = 'impact';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 800,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 600,
        );
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = _controller.value;
            _handlePhases(t);

            return CustomPaint(
              size: size,
              painter: _NebulaPainter(
                t: t,
                errorMode: widget.errorMode,
                isDark: isDark,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // === MOON ===
                  Positioned(
                    right: size.width * 0.15,
                    top: size.height * 0.12,
                    width: size.shortestSide * 0.16,
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: _moon,
                    ),
                  ),

                  // === C64 ===
                  Positioned(
                    left: size.width * 0.14,
                    bottom: size.height * 0.1,
                    width: size.shortestSide * 0.25,
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: _c64,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Painter for cinematic beam + energy effects
class _NebulaPainter extends CustomPainter {
  final double t;
  final bool errorMode;
  final bool isDark;
  final math.Random _rng = math.Random(42);

  _NebulaPainter({
    required this.t,
    required this.errorMode,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgRect = Offset.zero & size;
    final bgGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [const Color(0xFF0C0F1A), const Color(0xFF141B2E)]
          : [const Color(0xFFE4E9F4), const Color(0xFFD9E4FF)],
    );
    canvas.drawRect(bgRect, Paint()..shader = bgGrad.createShader(bgRect));

    _drawStars(canvas, size);
    _drawGrid(canvas, size);

    if (errorMode) {
      _drawErrorOverlay(canvas, size);
      return;
    }

    final compCenter = Offset(size.width * 0.28, size.height * 0.66);
    final moonCenter = Offset(size.width * 0.78, size.height * 0.28);

    final chargeEnd = 0.2;
    final fireEnd = 0.85;

    if (t < chargeEnd) {
      _drawChargeGlow(canvas, compCenter, t / chargeEnd);
    } else if (t < fireEnd) {
      final localT = (t - chargeEnd) / (fireEnd - chargeEnd);
      final beamEnd = Offset.lerp(
        compCenter,
        moonCenter,
        _easeOutCubic(localT),
      )!;
      _drawLaserBeam(canvas, compCenter, beamEnd, localT);
    } else {
      _drawLaserBeam(canvas, compCenter, moonCenter, 1.0);
      _drawImpactExplosion(canvas, moonCenter, t);
    }

    _drawScanlines(canvas, size);
  }

  void _drawChargeGlow(Canvas canvas, Offset center, double glow) {
    final base = Paint()
      ..color = Colors.greenAccent.withOpacity(0.2 + 0.5 * glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);
    canvas.drawCircle(center, 40 + 40 * glow, base);
  }

  void _drawLaserBeam(Canvas canvas, Offset from, Offset to, double localT) {
    final tail = (1.0 - localT) * 40.0;
    final beamPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00FF00), Color(0xFF66FF66)],
      ).createShader(Rect.fromPoints(from, to))
      ..strokeWidth = 5 + (2 * math.sin(localT * 30))
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawLine(from, to, beamPaint);

    // energy pulse
    final pulse = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, to, pulse);

    // glowing tail burst
    final tailPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.2)
      ..strokeWidth = tail.clamp(1, 20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(to, 10 + 10 * localT, tailPaint);
  }

  void _drawImpactExplosion(Canvas canvas, Offset center, double t) {
    final phase = ((t - 0.85) / 0.15).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(1.0 - phase)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(center, 30 + 70 * phase, paint);

    // energy ring
    final ring = Paint()
      ..color = Colors.white.withOpacity(0.4 - 0.4 * phase)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 80 * phase, ring);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 200; i++) {
      final x = (i * 73.7) % size.width;
      final y = (i * 41.3) % (size.height * 0.7);
      final twinkle = 0.4 + 0.6 * math.sin((i * 0.77) + t * 8.0);
      paint.color = Colors.white.withOpacity(0.1 + 0.5 * twinkle);
      canvas.drawCircle(Offset(x, y), 0.8 + (twinkle * 1.4), paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.greenAccent : Colors.lightGreenAccent)
          .withOpacity(0.2)
      ..strokeWidth = 1;

    final horizonY = size.height * 0.72;
    const rows = 10, cols = 14;
    for (int r = 0; r < rows; r++) {
      final y = horizonY + math.pow(r / rows, 2) * (size.height - horizonY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (int c = 0; c <= cols; c++) {
      final x = size.width * (c / cols);
      canvas.drawLine(Offset(x, horizonY), Offset(x, size.height), paint);
    }
  }

  void _drawErrorOverlay(Canvas canvas, Size size) {
    final shake = 4.0 * math.sin(t * 40.0);
    canvas.save();
    canvas.translate(shake, 0);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF330000).withOpacity(0.6),
    );
    canvas.restore();
    _drawScanlines(canvas, size);
  }

  void _drawScanlines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  double _easeOutCubic(double x) => 1 - math.pow(1 - x, 3).toDouble();

  @override
  bool shouldRepaint(covariant _NebulaPainter old) =>
      old.t != t || old.errorMode != errorMode;
}
