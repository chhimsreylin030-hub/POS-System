import 'package:flutter/material.dart';

class BarcodeWidget extends StatelessWidget {
  final String code;
  final double width;
  final double height;
  final bool showText;
  final Color color;

  const BarcodeWidget({
    super.key,
    required this.code,
    this.width = 160,
    this.height = 50,
    this.showText = true,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(width, height),
          painter: _BarcodePainter(code: code, barColor: color),
        ),
        if (showText) ...[
          const SizedBox(height: 3),
          Text(
            code,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final String code;
  final Color barColor;

  _BarcodePainter({required this.code, required this.barColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // Deterministic pseudo-random bar pattern based on code characters
    final seed = code.codeUnits.fold(0, (sum, c) => sum + c);
    final totalBars = 35;
    final barWidth = size.width / totalBars;

    for (int i = 0; i < totalBars; i++) {
      // Guard bars at start, middle, and end are always drawn full height
      final isGuard = (i < 3) || (i > 15 && i < 18) || (i > 31);
      final hash = ((seed * (i + 7) * 31) ^ (i * 17)) % 10;
      final shouldDraw = isGuard || (hash > 3);

      if (shouldDraw) {
        final currentBarW = ((hash % 2 == 0) && !isGuard) ? barWidth * 0.9 : barWidth * 0.55;
        final x = i * barWidth;
        final h = isGuard ? size.height : size.height * 0.88;
        canvas.drawRect(Rect.fromLTWH(x, 0, currentBarW, h), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) =>
      oldDelegate.code != code || oldDelegate.barColor != barColor;
}
