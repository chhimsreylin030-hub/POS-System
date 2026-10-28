import 'package:flutter/material.dart';
import '../../state/pos_state.dart';
import '../../widgets/stat_card.dart';
import '../../models/transaction.dart';

class DashboardView extends StatelessWidget {
  final Function(int tabIndex) onNavigateTab;

  const DashboardView({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final posState = PosState();
    final transactions = posState.transactions;
    final products = posState.products;

    // Computed KPIs
    final totalRevenueUSD = transactions.fold(0.0, (sum, t) => sum + (t.status == TransactionStatus.completed ? t.grandTotalUSD : 0.0));
    final totalOrders = transactions.length;
    final avgBasket = totalOrders > 0 ? (totalRevenueUSD / totalOrders) : 0.0;
    final lowStockItems = products.where((p) => p.isLowStock || p.isOutOfStock).toList();
    final bakongTransactions = transactions.where((t) => t.paymentMethod == PaymentMethod.bakongKhqr && t.status == TransactionStatus.completed);
    final bakongVolume = bakongTransactions.fold(0.0, (sum, t) => sum + t.grandTotalUSD);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Quick Action Banner
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Executive Dashboard Overview',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time retail metrics, digital payments, and inventory status.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.point_of_sale, size: 18),
                label: const Text('Launch POS Terminal', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => onNavigateTab(-1), // Special trigger to switch to POS screen
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4 Main KPI Cards (US-007)
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.35,
                children: [
                  StatCard(
                    title: "Today's Gross Revenue",
                    value: '\$${totalRevenueUSD.toStringAsFixed(2)}',
                    subtitle: 'vs yesterday',
                    trend: '+18.4%',
                    isTrendPositive: true,
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  StatCard(
                    title: 'Total Transactions',
                    value: '$totalOrders',
                    subtitle: 'Avg: \$${avgBasket.toStringAsFixed(2)}',
                    trend: '+12%',
                    isTrendPositive: true,
                    icon: Icons.receipt_long,
                    color: Colors.indigo,
                  ),
                  StatCard(
                    title: 'Bakong KHQR Volume',
                    value: '\$${bakongVolume.toStringAsFixed(2)}',
                    subtitle: '${bakongTransactions.length} digital scans',
                    trend: '+25.0%',
                    isTrendPositive: true,
                    icon: Icons.qr_code_2,
                    color: const Color(0xFFE2001A),
                  ),
                  StatCard(
                    title: 'Stock Attention Needed',
                    value: '${lowStockItems.length}',
                    subtitle: 'Items low or out of stock',
                    trend: lowStockItems.isNotEmpty ? 'Action needed' : 'Healthy',
                    isTrendPositive: lowStockItems.isEmpty,
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Middle Row: Weekly Sales Chart & Payment Distribution
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildWeeklySalesCard()),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: _buildPaymentMethodCard(transactions)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildWeeklySalesCard(),
                    const SizedBox(height: 16),
                    _buildPaymentMethodCard(transactions),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Bottom Row: Recent Orders Table & Low Stock Alerts
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: _buildRecentOrdersTable(transactions)),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: _buildStockAlertsCard(lowStockItems)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildRecentOrdersTable(transactions),
                    const SizedBox(height: 16),
                    _buildStockAlertsCard(lowStockItems),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySalesCard() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sales = [145.0, 210.0, 180.0, 290.0, 340.0, 480.0, 390.0];
    final maxSale = 500.0;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Sales Revenue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('This Week', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(days.length, (i) {
                  final hPercent = sales[i] / maxSale;
                  final isToday = i == 6; // Sunday/Today

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '\$${sales[i].toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isToday ? const Color(0xFF0F172A) : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 28,
                        height: 130 * hPercent,
                        decoration: BoxDecoration(
                          color: isToday ? const Color(0xFF0F172A) : Colors.indigo.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        days[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? const Color(0xFF0F172A) : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(List<TransactionRecord> transactions) {
    int khqrCount = 0;
    int cardCount = 0;
    int cashCount = 0;
    int splitCount = 0;

    for (var t in transactions) {
      if (t.paymentMethod == PaymentMethod.bakongKhqr) khqrCount++;
      if (t.paymentMethod == PaymentMethod.creditCard) cardCount++;
      if (t.paymentMethod == PaymentMethod.cash) cashCount++;
      if (t.paymentMethod == PaymentMethod.splitPayment) splitCount++;
    }

    final total = transactions.isEmpty ? 1 : transactions.length;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digital Payment Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 18),
            _buildPaymentBar('Bakong KHQR (NBC)', khqrCount, total, const Color(0xFFE2001A)),
            const SizedBox(height: 12),
            _buildPaymentBar('Credit/Debit Card', cardCount, total, Colors.indigo),
            const SizedBox(height: 12),
            _buildPaymentBar('Cash on Counter', cashCount, total, Colors.green),
            const SizedBox(height: 12),
            _buildPaymentBar('Split Payment', splitCount, total, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBar(String title, int count, int total, Color color) {
    final double percent = (count / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(
              '$count (${(percent * 100).toStringAsFixed(0)}%)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersTable(List<TransactionRecord> transactions) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(4), // Transactions tab
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No orders recorded yet')))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.take(5).length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  final isRefunded = t.status == TransactionStatus.refunded;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isRefunded ? Colors.red.shade50 : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isRefunded ? Icons.replay : Icons.receipt,
                            size: 18,
                            color: isRefunded ? Colors.red : Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(
                                '${t.items.length} items • ${t.paymentMethodLabel}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${t.grandTotalUSD.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: isRefunded ? Colors.red : const Color(0xFF0F172A),
                                decoration: isRefunded ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Text(
                              isRefunded ? 'Refunded' : 'Completed',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isRefunded ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlertsCard(List<dynamic> lowStockItems) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Low Stock Alerts (US-020)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(2), // Inventory tab
                  child: const Text('Manage Stock'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lowStockItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('All products are healthy in stock ✓', style: TextStyle(color: Colors.green)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lowStockItems.take(4).length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = lowStockItems[index];
                  final isOut = p.isOutOfStock;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            p.imageUrl,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 38, height: 38, color: Colors.grey.shade200),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(
                                'Barcode: ${p.barcode}',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOut ? Colors.red.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isOut ? '0 (Out)' : '${p.stockQuantity} left',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isOut ? Colors.red.shade800 : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
