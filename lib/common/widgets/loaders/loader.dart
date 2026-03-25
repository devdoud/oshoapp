import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/utils/constants/colors.dart';

class OLoader extends StatelessWidget {
  const OLoader({super.key, this.color, this.size = 24.0});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _ModernSpinner(
        color: color ?? OColors.primary,
        size: size,
      ),
    );
  }
}

class _ModernSpinner extends StatefulWidget {
  final Color color;
  final double size;

  const _ModernSpinner({
    required this.color,
    required this.size,
  });

  @override
  State<_ModernSpinner> createState() => _ModernSpinnerState();
}

class _ModernSpinnerState extends State<_ModernSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // iOS-like smooth rotation
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpinnerPainter(
              color: widget.color,
              angle: _controller.value * 2 * 3.14159,
            ),
          );
        },
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double angle;

  _SpinnerPainter({required this.color, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final double radius = size.width / 3.2; // Radius of the circle
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Number of bars in the circle (12 segments like iOS)
    const int barCount = 12;
    const double barWidth =
        2.2; // Width of each segment - slightly thicker for visibility
    const double barHeight = 4.5; // Height of each segment

    // Rotate the canvas
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Draw bars with varying opacity
    for (int i = 0; i < barCount; i++) {
      final double barAngle = (i * 2 * 3.14159) / barCount;

      // Calculate opacity based on position (creates the spinning effect)
      // iOS-style smooth opacity curve
      final double opacity = 1.0 - (i / barCount);
      final double smoothOpacity =
          opacity * opacity; // Quadratic curve for smoother fade

      paint.color = color.withValues(
          alpha: smoothOpacity * 0.85 + 0.15); // Min opacity 0.15

      // Calculate bar position on the circle
      final double x = radius * cos(barAngle);
      final double y = radius * sin(barAngle);

      // Draw each bar as a rounded rectangle (cylinder shape)
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(barAngle + 3.14159 / 2); // Rotate bar to point outward

      final RRect barRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: barWidth,
          height: barHeight,
        ),
        Radius.circular(barWidth / 2), // Rounded ends for cylinder effect
      );

      canvas.drawRRect(barRect, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.color != color;
  }
}

class OLoaders {
  static void warningSnackBar({required String title, String? message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            if (message != null)
              Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void successSnackBar(
      {required String title, String? message, int duration = 3}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            if (message != null)
              Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: OColors.primary,
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void errorSnackBar({required String title, String? message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            if (message != null)
              Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
