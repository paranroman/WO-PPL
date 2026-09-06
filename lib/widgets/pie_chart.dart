import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;

  const PieChart({super.key, required this.values, required this.colors});

  @override
  Widget build(BuildContext context) {
    final sum = values.fold<double>(0, (a, b) => a + b);
    final safeSum = sum == 0 ? 1.0 : sum;

    return CustomPaint(
      painter: _PieChartPainter(values: values, colors: colors, total: safeSum),
      child: const SizedBox.expand(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double total;

  _PieChartPainter({
    required this.values,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide / 2);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    double start = -1.57079632679;

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 6.28318530718;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );
      start += sweep;
    }

    final holePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius * 0.55, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    if (oldDelegate.total != total) return true;
    if (oldDelegate.values.length != values.length) return true;
    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}
