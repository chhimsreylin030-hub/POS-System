import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../state/pos_state.dart';

class CustomersView extends StatefulWidget {
  const CustomersView({super.key});

  @override
  State<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView> {
  final PosState posState = PosState();

  void _openAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    MembershipTier tier = MembershipTier.silver;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Register New Member (US-044)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Customer Full Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<MembershipTier>(
                initialValue: tier,
                decoration: const InputDecoration(labelText: 'Membership Tier', border: OutlineInputBorder()),
                items: MembershipTier.values.map((t) {
                  final name = t.name.toUpperCase();
                  return DropdownMenuItem(value: t, child: Text('$name Member'));
                }).toList(),
                onChanged: (val) => setDlgState(() => tier = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                  final c = Customer(
                    id: 'cust-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text,
                    phone: phoneCtrl.text,
                    email: emailCtrl.text,
                    tier: tier,
                    loyaltyPoints: 50, // Welcome points
                    totalSpent: 0.0,
                    joinedDate: DateTime.now(),
                  );
                  posState.addCustomer(c);
                  Navigator.of(ctx).pop();
                  setState(() {});
                }
              },
              child: const Text('Register Member'),
            ),
          ],
        ),
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
                    'Customer Membership & Loyalty (US-044, US-047)',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track member tier discounts, points balance, and repeat purchase patterns.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Add New Customer'),
                onPressed: _openAddCustomerDialog,
              ),
            ],
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('MEMBER NAME', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('TIER & DISCOUNT', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('PHONE NUMBER', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('LOYALTY POINTS', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('LIFETIME SPENT', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('MEMBER SINCE', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: posState.customers.map((c) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF0F172A),
                                child: Text(c.name[0], style: const TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.tier == MembershipTier.vip
                                  ? Colors.purple.shade50
                                  : (c.tier == MembershipTier.gold ? Colors.amber.shade50 : Colors.blue.shade50),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              c.tierName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: c.tier == MembershipTier.vip
                                    ? Colors.purple.shade800
                                    : (c.tier == MembershipTier.gold ? Colors.amber.shade900 : Colors.blue.shade900),
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(c.phone)),
                        DataCell(Text('${c.loyaltyPoints} pts', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('\$${c.totalSpent.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                        DataCell(Text('${c.joinedDate.toLocal()}'.substring(0, 10))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
