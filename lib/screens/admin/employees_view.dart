import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../state/pos_state.dart';

class EmployeesView extends StatefulWidget {
  const EmployeesView({super.key});

  @override
  State<EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> with SingleTickerProviderStateMixin {
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

  void _openStartShiftDialog() {
    final floatCtrl = TextEditingController(text: '100.00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start New Register Shift (US-046)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter initial opening cash float in drawer:'),
            const SizedBox(height: 12),
            TextField(
              controller: floatCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Opening Float Amount (\$)', prefixText: '\$ ', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            onPressed: () {
              final fl = double.tryParse(floatCtrl.text) ?? 100.0;
              posState.startShift(fl);
              Navigator.of(ctx).pop();
              setState(() {});
            },
            child: const Text('Open Shift'),
          ),
        ],
      ),
    );
  }

  void _openCloseShiftDialog() {
    final shift = posState.activeShift;
    if (shift == null) return;
    final countedCtrl = TextEditingController(text: shift.expectedCashInDrawer.toStringAsFixed(2));
    final noteCtrl = TextEditingController(text: 'Drawer balanced at end of shift');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reconcile & Close Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expected Cash in Drawer: \$${shift.expectedCashInDrawer.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Float: \$${shift.openingFloat.toStringAsFixed(2)} + Cash Sales: \$${shift.totalCashSales.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 14),
            TextField(
              controller: countedCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Actual Cash Counted (\$)', prefixText: '\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Shift Notes / Discrepancy explanation', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              final counted = double.tryParse(countedCtrl.text) ?? shift.expectedCashInDrawer;
              posState.closeShift(counted, noteCtrl.text);
              Navigator.of(ctx).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Register shift successfully closed and archived.')),
              );
            },
            child: const Text('Confirm Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Staff, Shift Management & Payroll',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage employee roles, track daily cashier drawer reconciliation, and review payroll.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (posState.activeShift == null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                  icon: const Icon(Icons.play_circle_outline, size: 16),
                  label: const Text('Open New Shift'),
                  onPressed: _openStartShiftDialog,
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                  icon: const Icon(Icons.stop_circle_outlined, size: 16),
                  label: const Text('Close Active Shift'),
                  onPressed: _openCloseShiftDialog,
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
              Tab(text: 'Staff Directory (US-008)'),
              Tab(text: 'Active Shift & Drawer Float (US-046)'),
              Tab(text: 'Staff Payroll Overview (US-048)'),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 520,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStaffDirectory(),
                _buildShiftView(),
                _buildPayrollView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffDirectory() {
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
              DataColumn(label: Text('EMPLOYEE NAME', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ROLE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('EMAIL / LOGIN', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('PHONE NUMBER', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('MONTHLY SALARY', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: posState.employees.map((e) {
              return DataRow(
                cells: [
                  DataCell(Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(e.roleDisplay)),
                  DataCell(Text(e.email)),
                  DataCell(Text(e.phone)),
                  DataCell(Text('\$${e.monthlySalary.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text('Active Staff', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildShiftView() {
    final shift = posState.activeShift;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shift != null) ...[
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.green.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('ACTIVE SHIFT: ${shift.id}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          ],
                        ),
                        Text('Cashier: ${shift.employeeName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildShiftMetric('Opening Float', '\$${shift.openingFloat.toStringAsFixed(2)}'),
                        _buildShiftMetric('Cash Collected', '\$${shift.totalCashSales.toStringAsFixed(2)}'),
                        _buildShiftMetric('Digital / Bakong', '\$${shift.totalDigitalSales.toStringAsFixed(2)}'),
                        _buildShiftMetric('Expected in Drawer', '\$${shift.expectedCashInDrawer.toStringAsFixed(2)}', isBold: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Text('Past Shift History (Audit Trail):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),

          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                columns: const [
                  DataColumn(label: Text('SHIFT ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('CASHIER', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('OPEN FLOAT', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('CASH SALES', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('EXPECTED', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ACTUAL', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('DISCREPANCY', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: posState.pastShifts.map((s) {
                  return DataRow(
                    cells: [
                      DataCell(Text(s.id)),
                      DataCell(Text(s.employeeName)),
                      DataCell(Text('\$${s.openingFloat.toStringAsFixed(2)}')),
                      DataCell(Text('\$${s.totalCashSales.toStringAsFixed(2)}')),
                      DataCell(Text('\$${s.expectedCashInDrawer.toStringAsFixed(2)}')),
                      DataCell(Text('\$${s.closingCashActual?.toStringAsFixed(2) ?? "0.00"}')),
                      DataCell(
                        Text(
                          '\$${s.discrepancy.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: s.discrepancy < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftMetric(String title, String val, {bool isBold = false}) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: isBold ? Colors.green.shade800 : Colors.black87)),
      ],
    );
  }

  Widget _buildPayrollView() {
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
              DataColumn(label: Text('EMPLOYEE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ROLE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('BASE SALARY', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('SALES BONUS', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('NET PAYABLE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: posState.employees.map((e) {
              final bonus = e.role == EmployeeRole.cashier ? 45.0 : (e.role == EmployeeRole.admin ? 100.0 : 25.0);
              final net = e.monthlySalary + bonus;

              return DataRow(
                cells: [
                  DataCell(Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(e.roleDisplay)),
                  DataCell(Text('\$${e.monthlySalary.toStringAsFixed(2)}')),
                  DataCell(Text('+\$${bonus.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green))),
                  DataCell(Text('\$${net.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text('Paid / Cleared', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
