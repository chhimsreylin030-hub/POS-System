import 'package:flutter/material.dart';

class BakongKhqrCard extends StatelessWidget {
  final double amountUsd;
  final double amountKhr;
  final String currency; // 'USD' or 'KHR'
  final String merchantName;
  final String billNumber;
  final double size;

  const BakongKhqrCard({
    super.key,
    required this.amountUsd,
    required this.amountKhr,
    this.currency = 'USD',
    this.merchantName = 'SMART POS STORE',
    required this.billNumber,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    final displayAmount = currency == 'USD'
        ? '\$${amountUsd.toStringAsFixed(2)}'
        : '${amountKhr.toStringAsFixed(0)} ៛';

    return Container(
      width: size + 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2001A), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // KHQR Red Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFE2001A), // Official KHQR Red
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'KHQR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'BAKONG',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  merchantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Invoice #$billNumber',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),

                // QR Code Vector Canvas
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(size * 0.75, size * 0.75),
                        painter: _QrMatrixPainter(seed: billNumber.hashCode),
                      ),
                      // Bakong Center Logo Emblem
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2001A),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            currency == 'USD' ? '\$' : '៛',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  displayAmount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE2001A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Scan with any Bakong or Mobile Banking App',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrMatrixPainter extends CustomPainter {
  final int seed;

  _QrMatrixPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cells = 21;
    final cellSize = size.width / cells;

    // Draw standard 3 finder corners
    _drawFinderPattern(canvas, 0, 0, cellSize, paint);
    _drawFinderPattern(canvas, (cells - 7) * cellSize, 0, cellSize, paint);
    _drawFinderPattern(canvas, 0, (cells - 7) * cellSize, cellSize, paint);

    // Fill in pseudo-random data matrix dots (excluding center and finders)
    for (int r = 0; r < cells; r++) {
      for (int c = 0; c < cells; c++) {
        // Exclude 3 finder zones
        if (r < 8 && c < 8) continue;
        if (r < 8 && c >= cells - 8) continue;
        if (r >= cells - 8 && c < 8) continue;

        // Exclude center badge zone
        if (r >= 8 && r <= 12 && c >= 8 && c <= 12) continue;

        final hash = ((seed * (r + 1) * 37) ^ (c * 53)) % 100;
        if (hash > 48) {
          final x = c * cellSize;
          final y = r * cellSize;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 0.5, y + 0.5, cellSize - 1, cellSize - 1),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double ox, double oy, double cs, Paint paint) {
    // 7x7 outer square
    canvas.drawRect(Rect.fromLTWH(ox, oy, cs * 7, cs * 7), paint);
    // 5x5 white inner square
    canvas.drawRect(
      Rect.fromLTWH(ox + cs, oy + cs, cs * 5, cs * 5),
      Paint()..color = Colors.white,
    );
    // 3x3 black center core
    canvas.drawRect(Rect.fromLTWH(ox + cs * 2, oy + cs * 2, cs * 3, cs * 3), paint);
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPainter oldDelegate) => oldDelegate.seed != seed;
}
