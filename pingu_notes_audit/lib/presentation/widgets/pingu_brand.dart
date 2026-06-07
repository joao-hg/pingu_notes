import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PinguPaper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderSide? border;

  const PinguPaper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor =
        color ?? (isDark ? AppColors.darkSurface : AppColors.paper);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.fromBorderSide(
          border ??
              BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withAlpha(80),
              ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepOceanBlue.withAlpha(isDark ? 45 : 18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PaperTexturePainter(
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : AppColors.deepOceanBlue.withAlpha(8),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class PinguMascot extends StatelessWidget {
  final double size;
  final bool holdingNotebook;

  const PinguMascot({super.key, this.size = 96, this.holdingNotebook = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PinguMascotPainter(holdingNotebook: holdingNotebook),
      ),
    );
  }
}

class PinguEmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PinguEmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: PinguPaper(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PinguMascot(size: 112, holdingNotebook: true),
              const SizedBox(height: 18),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WatercolorBackdrop extends StatelessWidget {
  final Widget child;

  const WatercolorBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        CustomPaint(painter: _WatercolorPainter()),
        child,
      ],
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  final Color color;

  _PaperTexturePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;
    for (double y = 8; y < size.height; y += 13) {
      canvas.drawLine(
        Offset(6, y),
        Offset(size.width - 6, y + math.sin(y) * 0.8),
        paint,
      );
    }
    for (double x = 12; x < size.width; x += 19) {
      canvas.drawCircle(Offset(x, (x * 1.7) % size.height), 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperTexturePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _WatercolorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blobs = [
      (
        Offset(size.width * .15, size.height * .18),
        size.shortestSide * .38,
        AppColors.iceBlue.withAlpha(145),
      ),
      (
        Offset(size.width * .86, size.height * .10),
        size.shortestSide * .24,
        AppColors.warmYellow.withAlpha(70),
      ),
      (
        Offset(size.width * .76, size.height * .76),
        size.shortestSide * .32,
        AppColors.softOrange.withAlpha(55),
      ),
    ];

    for (final blob in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.$3, blob.$3.withAlpha(0)],
        ).createShader(Rect.fromCircle(center: blob.$1, radius: blob.$2));
      canvas.drawCircle(blob.$1, blob.$2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PinguMascotPainter extends CustomPainter {
  final bool holdingNotebook;

  _PinguMascotPainter({required this.holdingNotebook});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final scale = s / 120;
    canvas.scale(scale);

    final ocean = Paint()..color = AppColors.deepOceanBlue;
    final white = Paint()..color = AppColors.softWhite;
    final yellow = Paint()..color = AppColors.warmYellow;
    final orange = Paint()..color = AppColors.softOrange;
    final stroke = Paint()
      ..color = AppColors.deepOceanBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawOval(const Rect.fromLTWH(22, 18, 76, 88), ocean);
    canvas.drawOval(const Rect.fromLTWH(36, 38, 48, 60), white);
    canvas.drawCircle(const Offset(49, 42), 5, white);
    canvas.drawCircle(const Offset(71, 42), 5, white);
    canvas.drawCircle(const Offset(50, 43), 2.4, ocean);
    canvas.drawCircle(const Offset(70, 43), 2.4, ocean);

    final beak = Path()
      ..moveTo(57, 50)
      ..lineTo(63, 50)
      ..lineTo(60, 56)
      ..close();
    canvas.drawPath(beak, orange);
    canvas.drawArc(
      const Rect.fromLTWH(46, 56, 28, 18),
      0.15,
      math.pi - 0.3,
      false,
      stroke,
    );

    canvas.drawOval(const Rect.fromLTWH(21, 96, 28, 10), yellow);
    canvas.drawOval(const Rect.fromLTWH(71, 96, 28, 10), yellow);

    if (holdingNotebook) {
      final notebook = RRect.fromRectAndRadius(
        const Rect.fromLTWH(58, 66, 42, 30),
        const Radius.circular(5),
      );
      canvas.drawRRect(notebook, Paint()..color = AppColors.iceBlue);
      canvas.drawRRect(notebook, stroke);
      canvas.drawLine(const Offset(66, 72), const Offset(92, 72), stroke);
      canvas.drawLine(const Offset(66, 80), const Offset(88, 80), stroke);
      canvas.drawLine(const Offset(66, 88), const Offset(82, 88), stroke);
      canvas.drawArc(
        const Rect.fromLTWH(72, 60, 30, 24),
        math.pi,
        math.pi / 1.8,
        false,
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PinguMascotPainter oldDelegate) {
    return oldDelegate.holdingNotebook != holdingNotebook;
  }
}
