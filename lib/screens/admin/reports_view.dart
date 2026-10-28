import 'package:flutter/material.dart';
import '../../state/pos_state.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PosState posState = PosState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inventory valuation computation
    final totalCostValuation = posState.products.fold(0.0, (sum, p) => sum + (p.costPrice * p.stockQuantity));
    final totalRetailValuation = posState.products.fold(0.0, (sum, p) => sum + (p.sellingPrice * p.stockQuantity));
    final totalUnitsInStock = posState.products.fold(0, (sum, p) => sum + p.stockQuantity);
    final projectedProfit = totalRetailValuation - totalCostValuation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reports & Business Analytics (Sprint 6)',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generate weekly revenue summaries, monthly performance, and stock valuation audits.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export Summary PDF/CSV'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Financial & Inventory report downloaded.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF0F172A),
            indicatorColor: const Color(0xFF0F172A),
            tabs: const [
              Tab(text: 'Weekly Sales Report (US-049)'),
              Tab(text: 'Monthly Performance (US-050)'),
              Tab(text: 'Inventory Valuation Audit (US-051)'),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 520,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWeeklyReport(),
                _buildMonthlyReport(),
                _buildInventoryValuation(totalCostValuation, totalRetailValuation, totalUnitsInStock, projectedProfit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final sales = [145.0, 210.0, 180.0, 290.0, 340.0, 480.0, 390.0];
    final orders = [12, 18, 14, 25, 30, 42, 35];

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: const [
              DataColumn(label: Text('DAY', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('TRANSACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('GROSS SALES (USD)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('KHR EQUIVALENT', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('AVG ORDER VALUE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('GROWTH', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(days.length, (i) {
              final khr = posState.usdToKhr(sales[i]);
              final aov = sales[i] / orders[i];

              return DataRow(
                cells: [
                  DataCell(Text(days[i], style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${orders[i]} orders')),
                  DataCell(Text('\$${sales[i].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${khr.toStringAsFixed(0)} ៛')),
                  DataCell(Text('\$${aov.toStringAsFixed(2)}')),
                  DataCell(
                    Text(
                      i % 2 == 0 ? '+14.2%' : '+8.5%',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyReport() {
    final months = ['October 2026 (Current)', 'September 2026', 'August 2026', 'July 2026'];
    final revs = [4250.0, 3890.0, 3420.0, 3100.0];

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: const [
              DataColumn(label: Text('MONTH', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('REVENUE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('VAT COLLECTED (10%)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('DIGITAL PAYMENTS SHARE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('NET PROFIT MARGIN', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(months.length, (i) {
              final vat = revs[i] * 0.10;

              return DataRow(
                cells: [
                  DataCell(Text(months[i], style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('\$${revs[i].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('\$${vat.toStringAsFixed(2)}')),
                  DataCell(const Text('68% (Bakong KHQR + Cards)', style: TextStyle(color: Color(0xFFE2001A), fontWeight: FontWeight.bold))),
                  DataCell(const Text('42.5%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryValuation(double cost, double retail, int units, double profit) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildValuationCard('Total Units in Stock', '$units units', Icons.inventory_2, Colors.blue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildValuationCard('Asset Value (At Cost)', '\$${cost.toStringAsFixed(2)}', Icons.monetization_on, Colors.indigo),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildValuationCard('Retail Potential Value', '\$${retail.toStringAsFixed(2)}', Icons.storefront, Colors.green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildValuationCard('Projected Gross Profit', '\$${profit.toStringAsFixed(2)}', Icons.trending_up, Colors.orange),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Performing Products by Turnover:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  ...posState.products.take(4).map((p) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${p.stockQuantity} remaining • Unit profit: \$${(p.sellingPrice - p.costPrice).toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValuationCard(String title, String val, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
