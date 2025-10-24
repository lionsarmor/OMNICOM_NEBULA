import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Nebula login animation:
/// - Success mode (default): C64-like computer fires a purple laser to the moon.
/// - Error mode: red terminal text scroll + subtle screen shake.
///
/// Callbacks:
///  - onComplete: fired when the success animation finishes.
///  - onErrorEnd: fired after the error animation finishes.
///  - onPhaseChange: 'charge', 'fire', 'impact', or 'error' (for sound sync)
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
          widget.errorMode ? widget.errorDuration : widget.successDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (widget.errorMode) {
            widget.onErrorEnd?.call();
          } else {
            widget.onComplete?.call();
          }
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
    return RepaintBoundary(
      child: LayoutBuilder(
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
                painter: NebulaPainter(
                  t: t,
                  errorMode: widget.errorMode,
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Painter for both success and error variants.
class NebulaPainter extends CustomPainter {
  final double t; // 0..1
  final bool errorMode;
  final math.Random _rng = math.Random(1337);

  NebulaPainter({required this.t, required this.errorMode});

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient (synthwave)
    final bg = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF120022),
        Color(0xFF25004A),
        Color(0xFF080013),
      ],
    );
    canvas.drawRect(bg, Paint()..shader = bgGrad.createShader(bg));

    _drawStars(canvas, size);
    _drawGrid(canvas, size);

    if (errorMode) {
      _drawErrorScene(canvas, size, t);
      return;
    }

    _drawMoon(canvas, size);
    _drawComputer(canvas, size);

    final chargeEnd = 0.20;
    final fireEnd = 0.85;

    final compCenter = Offset(size.width * 0.28, size.height * 0.62);
    final moonCenter = Offset(size.width * 0.78, size.height * 0.28);

    if (t < chargeEnd) {
      final glow = (t / chargeEnd);
      final glowPaint = Paint()
        ..color = Colors.purpleAccent.withOpacity(0.3 + 0.5 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(compCenter, 30 + 25 * glow, glowPaint);
    } else if (t < fireEnd) {
      final localT = (t - chargeEnd) / (fireEnd - chargeEnd);
      final beamEnd =
          Offset.lerp(compCenter, moonCenter, _easeOutCubic(localT))!;
      _drawBeam(canvas, compCenter, beamEnd);
    } else {
      _drawBeam(canvas, compCenter, moonCenter);
      final flashT = (t - fireEnd) / (1 - fireEnd);
      _drawImpactFlash(canvas, moonCenter, size, flashT);
    }

    _drawScanlines(canvas, size);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.7);
    for (int i = 0; i < 120; i++) {
      final x = (i * 127.1) % size.width;
      final y = (i * 73.7) % (size.height * 0.55);
      final twinkle = 0.5 + 0.5 * math.sin((i * 0.37) + t * 12.0);
      paint.color = Colors.white.withOpacity(0.2 + 0.6 * twinkle);
      canvas.drawCircle(Offset(x, y), 0.8 + (twinkle * 1.2), paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.purple.withOpacity(0.25)
      ..strokeWidth = 1;

    final horizonY = size.height * 0.72;
    final rows = 10;
    final cols = 14;

    for (int r = 0; r < rows; r++) {
      final lerp = r / rows;
      final y = horizonY + math.pow(lerp, 2) * (size.height - horizonY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int c = 0; c <= cols; c++) {
      final x = size.width * (c / cols);
      canvas.drawLine(Offset(x, horizonY), Offset(x, size.height), gridPaint);
    }
  }

  void _drawMoon(Canvas canvas, Size size) {
    final moonCenter = Offset(size.width * 0.78, size.height * 0.28);
    final r = size.shortestSide * 0.06;

    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.grey.shade200, Colors.grey.shade600],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: r));

    canvas.drawCircle(moonCenter, r, moonPaint);
  }

  void _drawComputer(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.28, size.height * 0.62);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 140, height: 90),
      const Radius.circular(8),
    );
    canvas.drawRRect(
        bodyRect, Paint()..color = const Color(0xFF33FFDD).withOpacity(0.85));

    final bezel = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -5), width: 110, height: 60),
      const Radius.circular(6),
    );
    canvas.drawRRect(bezel, Paint()..color = const Color(0xFF0B2A2A));

    final screenRect =
        Rect.fromCenter(center: center.translate(0, -5), width: 100, height: 50);
    final screenGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF00FFC8).withOpacity(0.35 + 0.15 * math.sin(t * 6)),
        const Color(0xFF0A6060).withOpacity(0.65),
      ],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, const Radius.circular(4)),
      Paint()..shader = screenGrad.createShader(screenRect),
    );

    canvas.drawRect(
      Rect.fromCenter(center: center.translate(0, 34), width: 60, height: 6),
      Paint()..color = const Color(0xFF108080),
    );
    canvas.drawCircle(center.translate(55, 34), 4,
        Paint()..color = Colors.greenAccent.withOpacity(0.9));
  }

  void _drawBeam(Canvas canvas, Offset from, Offset to) {
    final glowPaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.35)
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, to, glowPaint);

    final corePaint = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0xFFBE4BFF),
          Color(0xFF9C2BFF),
          Color(0xFFE07BFF),
        ],
      ).createShader(Rect.fromPoints(from, to))
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, to, corePaint);
  }

  void _drawImpactFlash(Canvas canvas, Offset center, Size size, double flashT) {
    final radius = flashT * (size.shortestSide * 0.12);
    final alpha = (1.0 - flashT).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(center, radius, paint);
  }

  void _drawScanlines(Canvas canvas, Size size) {
    final lines = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lines);
    }
  }

  void _drawErrorScene(Canvas canvas, Size size, double t) {
    final shake = 4.0 * math.sin(t * 40.0);
    canvas.save();
    canvas.translate(shake, 0);
    final overlay = Paint()..color = const Color(0xFF250019).withOpacity(0.55);
    canvas.drawRect(Offset.zero & size, overlay);
    canvas.restore();
    _drawScanlines(canvas, size);
  }

  double _easeOutCubic(double x) => 1 - math.pow(1 - x, 3).toDouble();

  @override
  bool shouldRepaint(covariant NebulaPainter old) =>
      old.t != t || old.errorMode != errorMode;
}
