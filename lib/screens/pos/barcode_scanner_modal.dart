import 'package:flutter/material.dart';
import '../../state/pos_state.dart';
import '../../models/product.dart';

class BarcodeScannerModal extends StatefulWidget {
  final Function(ProductItem product) onProductScanned;

  const BarcodeScannerModal({super.key, required this.onProductScanned});

  @override
  State<BarcodeScannerModal> createState() => _BarcodeScannerModalState();
}

class _BarcodeScannerModalState extends State<BarcodeScannerModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _manualController = TextEditingController();
  final PosState posState = PosState();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _handleBarcode(String code) {
    setState(() => _errorMessage = null);
    final product = posState.findProductByBarcode(code);
    if (product != null) {
      widget.onProductScanned(product);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Scanned: ${product.name} (\$$product.sellingPrice)'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'No product found with barcode "$code"';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.qr_code_scanner, color: Color(0xFF0F172A), size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Barcode Scanner Simulator',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Animated Laser Viewfinder
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueGrey.shade800, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Corner targeting brackets
                    Positioned(
                      top: 20,
                      left: 20,
                      child: _buildCorner(isTop: true, isLeft: true),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: _buildCorner(isTop: true, isLeft: false),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: _buildCorner(isTop: false, isLeft: true),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: _buildCorner(isTop: false, isLeft: false),
                    ),

                    // Aim text
                    const Text(
                      'Align barcode inside frame',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),

                    // Moving Laser Line
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Positioned(
                          top: 30 + (_animController.value * 140),
                          left: 30,
                          right: 30,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick preset barcodes for instant 1-click test
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Test Barcodes (Click to simulate scan):',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: posState.products.take(4).map((p) {
                  return ActionChip(
                    avatar: const Icon(Icons.barcode_reader, size: 16, color: Colors.indigo),
                    label: Text('${p.name.split(" ").first} (${p.barcode})'),
                    onPressed: () => _handleBarcode(p.barcode),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Manual Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Or enter barcode manually...',
                        prefixIcon: const Icon(Icons.keyboard),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: (val) => _handleBarcode(val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleBarcode(_manualController.text),
                    child: const Text('Scan'),
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.redAccent, width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.redAccent, width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.redAccent, width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.redAccent, width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}
