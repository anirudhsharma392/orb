import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// A controller used to dynamically adjust the amplitude of the SiriOrbAnimation
/// without triggering a full screen rebuild.
class SiriOrbController extends ChangeNotifier {
  double _amplitude;

  SiriOrbController({double initialAmplitude = 0.0})
      : _amplitude = initialAmplitude;

  double get amplitude => _amplitude;

  set amplitude(double value) {
    // Clamp the amplitude usually between 0.0 and 1.0 but allow slight overshoots for bounciness.
    if (_amplitude != value) {
      _amplitude = value;
      notifyListeners();
    }
  }
}

class SiriOrbAnimation extends StatefulWidget {
  final SiriOrbController controller;
  final double radius;
  final List<Color> waveColors;
  final GestureTapCallback? onTap;

  const SiriOrbAnimation({
    super.key,
    required this.controller,
    this.radius = 80.0,
    this.waveColors = const [
      Color(0xFFBF5AF2), // Purple
      Colors.cyan,       // Cyan
      Color(0xFF9066FF), // Dark Purple
      Color(0xFF007AFF), // Blue
    ],
    this.onTap,
  });

  @override
  State<SiriOrbAnimation> createState() => _SiriOrbAnimationState();
}

class _SiriOrbAnimationState extends State<SiriOrbAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Controls the slow continuous spin
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = widget.radius / 90.0;
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
            child: AnimatedScale(
              scale: 1.0 + (amplitude * 0.6),
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              child: AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  return Container(
                    width: size,
                    height: size,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF0F4FA),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x665D9CFF),
                          blurRadius: 80 * scaleFactor,
                          spreadRadius: 10 * scaleFactor,
                        ),
                        BoxShadow(
                          color: const Color(0x33BF5AF2),
                          blurRadius: 120 * scaleFactor,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Core and Waves rendered on Canvas (GPU-accelerated)
                        CustomPaint(
                          size: Size(size, size),
                          painter: SiriOrbPainter(
                            progress: _spinController.value,
                            scaleFactor: scaleFactor,
                            amplitude: amplitude,
                            colors: widget.waveColors,
                          ),
                        ),
                        
                        // Static Blur Layer
                        BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: 5 * scaleFactor, sigmaY: 5 * scaleFactor),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 2.0 * scaleFactor,
                              ),
                            ),
                          ),
                        ),

                        // Static Specular Reflection
                        Positioned(
                          top: 0,
                          left: 20 * scaleFactor,
                          right: 20 * scaleFactor,
                          height: 60 * scaleFactor,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(100 * scaleFactor),
                                topRight: Radius.circular(100 * scaleFactor),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.8),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                stops: const [0.3, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedListenableBuilder extends StatefulWidget {
  final Listenable listenable;
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedListenableBuilder({
    super.key,
    required this.listenable,
    required this.builder,
  });

  @override
  State<AnimatedListenableBuilder> createState() =>
      _AnimatedListenableBuilderState();
}

class _AnimatedListenableBuilderState extends State<AnimatedListenableBuilder> {
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(AnimatedListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_handleChange);
      widget.listenable.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, null);
}

class SiriOrbPainter extends CustomPainter {
  final double progress; // from 0.0 to 1.0
  final double scaleFactor;
  final double amplitude;
  final List<Color> colors;

  SiriOrbPainter({
    required this.progress,
    required this.scaleFactor,
    required this.amplitude,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw solid glowing core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFF3EDFF),
        ],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2, corePaint);

    // 2. Helper to draw individual waves
    void drawWave(
      Color color,
      double width,
      double height,
      double baseRotation,
      Offset offset,
      double opacity,
    ) {
      canvas.save();
      // Translate to overall center + the offset
      canvas.translate(center.dx + offset.dx, center.dy + offset.dy);
      // Rotate
      canvas.rotate(baseRotation);

      final squashWobble = math.sin(t * 3.0 + baseRotation) * 20;
      final stretchedWidth =
          math.max(1.0, width + squashWobble + (amplitude * 120)) / 2;
      final stretchedHeight =
          math.max(1.0, height - squashWobble + (amplitude * 80)) / 2;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.2, 1.0],
        ).createShader(Rect.fromCenter(
          center: Offset.zero,
          width: stretchedWidth * 2,
          height: stretchedHeight * 2,
        ));

      // Draw an oval stretching around this wave's offset
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: stretchedWidth * 2,
          height: stretchedHeight * 2,
        ),
        paint,
      );

      canvas.restore();
    }

    // Safe color access helper
    Color getColor(int index) => colors[index % colors.length];

    // Wave 1: Broad swath
    drawWave(
      getColor(0),
      320,
      160,
      math.sin(t * 1.0) * 0.2,
      Offset(math.cos(t * 2.0) * 10, math.sin(t * 1.0) * 40),
      0.2,
    );

    // Wave 3: Light edge
    drawWave(
      getColor(1),
      300 * scaleFactor,
      150 * scaleFactor,
      math.sin(t * 2.0) * -0.2 + 0.1,
      Offset(math.sin(t * 3.0) * 30 * scaleFactor,
          math.cos(t * 1.0) * 45 * scaleFactor),
      1.0,
    );

    // Wave 4: Internal complexity
    drawWave(
      getColor(2),
      360,
      140,
      math.cos(t * 1.0) * 0.25,
      Offset(math.cos(t * 2.0) * -15, math.sin(t * 2.0) * -45),
      1.0,
    );

    // Wave 5: Prominent frame
    drawWave(
      getColor(3),
      300 * scaleFactor,
      180 * scaleFactor,
      math.sin(t * 2.0) * 0.15 - 0.1,
      Offset(math.sin(t * 1.0) * 35 * scaleFactor,
          math.cos(t * 2.0) * -50 * scaleFactor),
      1.0,
    );

    // Wave 6: Sharp white highlight swirls slicing across edges
    drawWave(
      Colors.white,
      280 * scaleFactor,
      35 * scaleFactor,
      math.cos(t * 2.0) * 0.15 + 0.2,
      Offset(math.sin(t * 2.0) * -15 * scaleFactor,
          math.sin(t * 2.0 + math.pi / 2) * 55 * scaleFactor),
      0.9,
    );

    // Wave 7: Secondary bright highlight to give glossy 3D depth
    drawWave(
      Colors.white,
      200 * scaleFactor,
      15 * scaleFactor,
      math.sin(t * 1.0) * -0.2 - 0.1,
      Offset(math.cos(t * 2.0) * 20 * scaleFactor,
          math.cos(t * 1.0 + math.pi) * 40 * scaleFactor),
      0.75,
    );
  }

  @override
  bool shouldRepaint(covariant SiriOrbPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scaleFactor != scaleFactor ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.colors != colors;
  }
}
