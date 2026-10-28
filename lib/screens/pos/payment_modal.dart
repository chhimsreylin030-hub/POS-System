import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/pos_state.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_qr.dart';

class PaymentModal extends StatefulWidget {
  final VoidCallback onPaymentSuccess;
  final Function(TransactionRecord record) onShowReceipt;

  const PaymentModal({
    super.key,
    required this.onPaymentSuccess,
    required this.onShowReceipt,
  });

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PosState posState = PosState();

  // Cash Tab State
  final TextEditingController _cashTenderedController = TextEditingController();
  double _cashTendered = 0.0;

  // Split Payment Tab State
  final TextEditingController _splitCashController = TextEditingController();
  double _splitCash = 0.0;

  // Bakong Tab State
  String _bakongCurrency = 'USD'; // 'USD' or 'KHR'
  int _qrCountdown = 300; // 5 minutes
  Timer? _countdownTimer;

  // Card Tab State
  String _cardBrand = 'Visa';
  final TextEditingController _cardNumberController = TextEditingController(text: '4532 •••• •••• 8821');

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cashTendered = posState.cartGrandTotalUSD;
    _cashTenderedController.text = _cashTendered.toStringAsFixed(2);

    _splitCash = (posState.cartGrandTotalUSD / 2).roundToDouble();
    _splitCashController.text = _splitCash.toStringAsFixed(2);

    // Start Bakong KHQR Countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_qrCountdown > 0) {
        setState(() => _qrCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashTenderedController.dispose();
    _splitCashController.dispose();
    _cardNumberController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _finishPayment({
    required PaymentMethod method,
    required double tendered,
    required String reference,
    double? splitCash,
    double? splitDigital,
  }) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Smooth simulation
    if (!mounted) return;

    final record = posState.completeCheckout(
      method: method,
      amountTendered: tendered,
      reference: reference,
      splitCash: splitCash,
      splitDigital: splitDigital,
    );

    Navigator.of(context).pop();
    widget.onPaymentSuccess();
    widget.onShowReceipt(record);
  }

  @override
  Widget build(BuildContext context) {
    final grandTotalUSD = posState.cartGrandTotalUSD;
    final grandTotalKHR = posState.cartGrandTotalKHR;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 720),
        child: Column(
          children: [
            // Header with Total Due
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: AppColors.deepBerry,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${grandTotalUSD.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${grandTotalKHR.toStringAsFixed(0)} ៛)',
                            style: const TextStyle(
                              color: AppColors.softPink,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Payment Tabs
            Container(
              color: AppColors.blushTint.withValues(alpha: 0.25),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.deepBerry,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.richMagenta,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.qr_code_2), text: 'Bakong KHQR'),
                  Tab(icon: Icon(Icons.payments_outlined), text: 'Cash'),
                  Tab(icon: Icon(Icons.credit_card), text: 'Card'),
                  Tab(icon: Icon(Icons.call_split), text: 'Split'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: _isProcessing
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFFE2001A)),
                          SizedBox(height: 16),
                          Text('Authorizing Digital Payment...', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBakongTab(grandTotalUSD, grandTotalKHR),
                        _buildCashTab(grandTotalUSD, grandTotalKHR),
                        _buildCardTab(grandTotalUSD),
                        _buildSplitTab(grandTotalUSD),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // TAB 1: BAKONG KHQR (US-034, US-039)
  // -----------------------------------------------------------
  Widget _buildBakongTab(double usd, double khr) {
    final minutes = (_qrCountdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (_qrCountdown % 60).toString().padLeft(2, '0');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Currency Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('USD (\$)'),
                selected: _bakongCurrency == 'USD',
                onSelected: (val) => setState(() => _bakongCurrency = 'USD'),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('KHR (៛)'),
                selected: _bakongCurrency == 'KHR',
                onSelected: (val) => setState(() => _bakongCurrency = 'KHR'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // KHQR Card
          BakongKhqrCard(
            amountUsd: usd,
            amountKhr: khr,
            currency: _bakongCurrency,
            billNumber: '2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          ),

          const SizedBox(height: 12),
          Text(
            'Expires in: $minutes:$seconds',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _qrCountdown < 60 ? Colors.red : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // 1-Click Simulate Bakong Scan & Pay button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2001A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'Simulate Bakong App Scan & Pay',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              final ref = 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
              _finishPayment(
                method: PaymentMethod.bakongKhqr,
                tendered: usd,
                reference: ref,
              );
            },
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // TAB 2: CASH PAYMENT
  // -----------------------------------------------------------
  Widget _buildCashTab(double usd, double khr) {
    final changeUSD = (_cashTendered >= usd) ? (_cashTendered - usd) : 0.0;
    final changeKHR = posState.usdToKhr(changeUSD);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amount Tendered:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _cashTenderedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '\$ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _cashTenderedController.clear();
                  setState(() => _cashTendered = 0.0);
                },
              ),
            ),
            onChanged: (val) {
              setState(() {
                _cashTendered = double.tryParse(val) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 14),

          // Quick Cash Pills (USD)
          const Text('Quick Cash (USD):', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ActionChip(
                label: const Text('Exact'),
                onPressed: () {
                  setState(() {
                    _cashTendered = usd;
                    _cashTenderedController.text = usd.toStringAsFixed(2);
                  });
                },
              ),
              ...[5, 10, 20, 50, 100].map((amount) {
                return ActionChip(
                  label: Text('\$$amount'),
                  onPressed: () {
                    setState(() {
                      _cashTendered = amount.toDouble();
                      _cashTenderedController.text = amount.toStringAsFixed(2);
                    });
                  },
                );
              }),
            ],
          ),

          const SizedBox(height: 14),

          // Change Calculation Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change to Customer:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${changeUSD.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.green),
                    ),
                    Text(
                      '${changeKHR.toStringAsFixed(0)} ៛',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Confirm Cash Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.print),
              label: const Text('Confirm Cash & Print Receipt', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: _cashTendered < usd
                  ? null
                  : () {
                      _finishPayment(
                        method: PaymentMethod.cash,
                        tendered: _cashTendered,
                        reference: 'CASH-PAID',
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // TAB 3: CARD PAYMENT (US-035)
  // -----------------------------------------------------------
  Widget _buildCardTab(double usd) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Card Network:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: ['Visa', 'MasterCard', 'UnionPay'].map((brand) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(brand),
                  selected: _cardBrand == brand,
                  onSelected: (val) => setState(() => _cardBrand = brand),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Virtual POS Terminal preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.contactless, color: Colors.white70, size: 28),
                    Text(
                      _cardBrand.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _cardNumberController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 3.0,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('POS TERMINAL #01', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    Text(
                      '\$${usd.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.contactless),
              label: const Text('Tap / Insert Card to Authorize', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () {
                final authCode = 'AUTH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                _finishPayment(
                  method: PaymentMethod.creditCard,
                  tendered: usd,
                  reference: authCode,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // TAB 4: SPLIT PAYMENT (US-040)
  // -----------------------------------------------------------
  Widget _buildSplitTab(double totalUsd) {
    final remainingDigital = (totalUsd - _splitCash).clamp(0.0, totalUsd);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Divide payment between Cash and Bakong KHQR:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Cash portion input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _splitCashController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Cash Amount (\$)',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _splitCash = double.tryParse(val) ?? 0.0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bakong Balance:', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      Text(
                        '\$${remainingDigital.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE2001A)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blueGrey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cashier collects \$${_splitCash.toStringAsFixed(2)} cash, and customer scans KHQR for \$${remainingDigital.toStringAsFixed(2)}.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.done_all),
              label: const Text('Process Split Payment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () {
                _finishPayment(
                  method: PaymentMethod.splitPayment,
                  tendered: totalUsd,
                  reference: 'SPLIT-CASH-BAKONG',
                  splitCash: _splitCash,
                  splitDigital: remainingDigital,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
