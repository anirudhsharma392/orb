import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:orb/orb.dart'; // To access OrbController and utilities

/// An authentic replication of the iOS 14+ Siri Orb.
/// This widget must be placed on a very dark or pitch black background
/// to properly render the additive BlendModes which create the bright white core.
class SiriORB extends StatefulWidget {
  final OrbController controller;
  final double radius;
  final GestureTapCallback? onTap;

  const SiriORB({
    super.key,
    required this.controller,
    this.radius = 80.0,
    this.onTap,
  });

  @override
  State<SiriORB> createState() => _SiriORBState();
}

class _SiriORBState extends State<SiriORB>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Slow rotation base
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        widget.onTap?.call();
      },
      child: AnimatedListenableBuilder(
        listenable: widget.controller,
        builder: (context, child) {
          final amplitude = widget.controller.amplitude;
          
          return AnimatedScale(
            scale: _isPressed ? 0.85 : 1.0,
            duration: Duration(milliseconds: _isPressed ? 100 : 400),
            curve: _isPressed ? Curves.easeOutQuad : Curves.elasticOut,
            child: AnimatedBuilder(
              animation: _spinController,
              builder: (context, _) {
                return SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: AuthenticSiriOrbPainter(
                      progress: _spinController.value,
                      amplitude: amplitude,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AuthenticSiriOrbPainter extends CustomPainter {
  final double progress;
  final double amplitude;

  AuthenticSiriOrbPainter({
    required this.progress,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final time = progress * math.pi * 2;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Smooth amplitude reactivity mapping
    final reactiveDef = amplitude * 25.0;
    final reactiveOffset = amplitude * 12.0;
    final reactiveScale = 1.0 + (amplitude * 0.15);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(reactiveScale);
    final localCenter = Offset.zero;
    
    // The exact boundary of the Siri orb (the "Ball" envelope)
    final sphereRadius = size.width * 0.40;

    // Use saveLayer to safely composite BlendMode.plus effects
    // Adding a slight ImageFilter.blur softens the entire orb homogeneously 
    // to give it a misty, glowing liquid surface without hardware clipping bugs
    canvas.saveLayer(
      Rect.fromCircle(center: localCenter, radius: sphereRadius * 1.5), 
      Paint()..imageFilter = ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5)
    );

    // 0. Hard mask to make the perfect glass sphere boundary
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: localCenter, radius: sphereRadius)));

    // 1. Dark ambient sphere background
    canvas.drawCircle(
      localCenter,
      sphereRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1E1E3A).withOpacity(0.8), 
            const Color(0xFF0A0A15).withOpacity(0.6), 
          ],
          stops: const [0.3, 1.0],
        ).createShader(Rect.fromCircle(center: localCenter, radius: sphereRadius))
    );

    // 2. Helper to draw distinct wavy "petals"/ribbons
    // We construct a dynamic squiggly unit-path and stretch the entire piece
    void drawWavyPetal({
      required Color color,
      required double width,
      required double height,
      required double rotation,
      required Offset offset,
      required int waves,
      required double waveSpeed,
    }) {
      canvas.save();
      canvas.translate(localCenter.dx + offset.dx, localCenter.dy + offset.dy);
      canvas.rotate(rotation);
      
      // Stretch the canvas to map the unit-path out to massive proportions
      canvas.scale(width / 2, height / 2);

      // Build the undulating liquid boundary
      final path = Path();
      const points = 60;
      final angleStep = (2 * math.pi) / (points - 1);
      
      final timePhase = time * waveSpeed;
      // Amplitude makes the waves physically writhe and bulge more aggressively
      final waveDepth = 0.08 + (amplitude * 0.15);

      for (int i = 0; i < points; i++) {
        final angle = i * angleStep;
        // The ripple math loops perfectly due to integer multipliers
        final r = 1.0 + math.sin(angle * waves + timePhase) * waveDepth;
        final x = r * math.cos(angle);
        final y = r * math.sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..blendMode = BlendMode.plus 
          ..shader = RadialGradient(
            colors: [
              color.withOpacity(0.9), // Vibrant inner color
              color.withOpacity(0.35), // Smooth falloff
              color.withOpacity(0.0), // Invisible clamp boundary
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1.0 + waveDepth + 0.05)), // gradient encompasses the wave peaks safely
      );
      
      canvas.restore();
    }

    // 3. Draw the overlapping running wavy ribbons
    
    // Bottom Massive Magenta/Pink Ribbon
    drawWavyPetal(
      color: const Color(0xFFFF2D55),
      width: sphereRadius * 2.5 + math.sin(time * 2.0) * 20 + reactiveDef,
      height: sphereRadius * 1.4 + math.cos(time * 2.0) * 15,
      rotation: time * 1.0, // Flawless continuous forward rotation
      offset: Offset(
        (sphereRadius * 0.2 + reactiveOffset) * math.cos(time * 1.0),
        (sphereRadius * 0.2 + reactiveOffset) * math.sin(time * 2.0)
      ),
      waves: 3,
      waveSpeed: 2.0,
    );

    // Top Right Deep Blue Ribbon
    drawWavyPetal(
      color: const Color(0xFF007AFF),
      width: sphereRadius * 2.4 + math.cos(time * 2.0) * 25 + reactiveDef,
      height: sphereRadius * 1.2 + math.sin(time * 1.0) * 15,
      rotation: time * -1.0 + 1.0, 
      offset: Offset(
        (sphereRadius * 0.25 + reactiveOffset) * math.sin(time * 1.0),
        (sphereRadius * 0.15 + reactiveOffset) * math.cos(time * 2.0)
      ),
      waves: 2,
      waveSpeed: -1.0,
    );

    // Left sweeping Cyan/Teal Ribbon
    drawWavyPetal(
      color: const Color(0xFF00E5FF),
      width: sphereRadius * 2.6 + math.sin(time * 2.0) * 20 + reactiveDef,
      height: sphereRadius * 1.0 + math.cos(time * 2.0) * 15,
      rotation: time * 1.5 + 2.0, 
      offset: Offset(
        (sphereRadius * 0.15 + reactiveOffset) * math.cos(time * 1.0 + math.pi),
        (sphereRadius * 0.25 + reactiveOffset) * math.sin(time * 3.0)
      ),
      waves: 4,
      waveSpeed: 3.0,
    );

    // Purple central supporting ribbon
    drawWavyPetal(
      color: const Color(0xFF7B61FF),
      width: sphereRadius * 2.0 + reactiveDef * 0.8,
      height: sphereRadius * 0.9 + math.sin(time * 2.0) * 10,
      rotation: time * -1.0 - 1.0, 
      offset: Offset(
        (sphereRadius * 0.1 + reactiveOffset) * math.sin(time * 2.0),
        (sphereRadius * 0.1 + reactiveOffset) * math.cos(time * 4.0)
      ),
      waves: 3,
      waveSpeed: -2.0,
    );

    // 4. White intense Core
    // Blows out the center perfectly just like the real Siri orb crossover
    final coreRadius = sphereRadius * 0.35 + (amplitude * 15);
    canvas.drawCircle(
      localCenter,
      coreRadius,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.35, 1.0],
        ).createShader(Rect.fromCircle(center: localCenter, radius: coreRadius))
    );

    canvas.restore(); // Restore saveLayer composite
    canvas.restore(); // Restore master canvas transforms
  }

  @override
  bool shouldRepaint(covariant AuthenticSiriOrbPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.amplitude != amplitude;
  }
}
