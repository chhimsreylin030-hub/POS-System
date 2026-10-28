import 'package:flutter/material.dart';
import '../../models/food_models.dart';
import '../../state/food_delivery_state.dart';
import '../../theme/app_colors.dart';

class DriverDeliveryScreen extends StatefulWidget {
  final VoidCallback onNavigateToCustomer;
  final VoidCallback onNavigateToMerchant;
  final VoidCallback onNavigateToAdmin;

  const DriverDeliveryScreen({
    super.key,
    required this.onNavigateToCustomer,
    required this.onNavigateToMerchant,
    required this.onNavigateToAdmin,
  });

  @override
  State<DriverDeliveryScreen> createState() => _DriverDeliveryScreenState();
}

class _DriverDeliveryScreenState extends State<DriverDeliveryScreen> {
  final FoodDeliveryState state = FoodDeliveryState();

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _showGpsMapModal(FoodOrder order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('GPS Live Motorcycle Route', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBerry)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map, size: 48, color: Colors.blueGrey),
                          const SizedBox(height: 6),
                          Text('Monivong Blvd -> Russian Blvd -> St 271', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          const Text('Distance: 3.4 km • Est. 12 mins by Motorcycle', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Route Clear', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.store, color: AppColors.richMagenta, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('From: ${order.merchantName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.home, color: AppColors.deepBerry, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('To: ${order.deliveryAddress}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.richMagenta, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close Route'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = state.drivers.first;
    // Find active order for this driver
    final activeOrder = state.orders.firstWhere(
      (o) => o.status != FoodOrderStatus.delivered && o.status != FoodOrderStatus.cancelled,
      orElse: () => state.orders.first,
    );

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      appBar: AppBar(
        backgroundColor: AppColors.deepBerry,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.richMagenta, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.two_wheeler, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DRIVER DELIVERY CONSOLE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${driver.name} (${driver.khmerName}) • ${driver.vehiclePlate}', style: const TextStyle(fontSize: 10, color: AppColors.softPink), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.softPink),
            icon: const Icon(Icons.phone_android, size: 16),
            label: const Text('Customer App'),
            onPressed: widget.onNavigateToCustomer,
          ),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.storefront, size: 16),
            label: const Text('Merchant Web'),
            onPressed: widget.onNavigateToMerchant,
          ),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.admin_panel_settings, size: 16),
            label: const Text('Admin Web'),
            onPressed: widget.onNavigateToAdmin,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver Profile & Shift Status Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.borderLight)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 32, backgroundImage: NetworkImage(driver.photoUrl)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(driver.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.deepBerry)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                                    child: const Text('ONLINE • ON DUTY', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Vehicle: ${driver.vehiclePlate}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              Text('Rating: ${driver.rating} ★ • Phone: ${driver.phone}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${driver.earningsUSD.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.richMagenta)),
                            Text('${driver.totalDeliveriesToday} Trips Completed', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Current Active Assigned Delivery Card
                const Text('Current Assigned Food Delivery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
                const SizedBox(height: 10),

                Card(
                  elevation: 2,
                  shadowColor: AppColors.richMagenta.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.borderLight)),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(activeOrder.orderNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.blushTint.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.softPink),
                              ),
                              child: Text(
                                activeOrder.statusDisplay.toUpperCase(),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.richMagenta),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Step 1: Restaurant Pickup
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.deepBerry, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.storefront, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PICKUP RESTAURANT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.8)),
                                  Text(activeOrder.merchantName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.deepBerry)),
                                  const Text('St 214, Daun Penh, Phnom Penh • Kitchen ready', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Step 2: Customer Dropoff
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.richMagenta, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.home, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('DROP-OFF CUSTOMER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.8)),
                                  Text('${activeOrder.customerName} (${activeOrder.customerPhone})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.deepBerry)),
                                  Text(activeOrder.deliveryAddress, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Items list to verify
                        const Text('Items in Package to Deliver:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry)),
                        const SizedBox(height: 8),
                        ...activeOrder.items.map((i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: AppColors.richMagenta, size: 16),
                                const SizedBox(width: 8),
                                Text('${i.quantity}x ${i.menuItem.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 20),

                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.deepBerry,
                            side: const BorderSide(color: AppColors.borderLight),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          icon: const Icon(Icons.map_outlined, size: 16),
                          label: const Text('View Delivery Route (GPS Map)'),
                          onPressed: () => _showGpsMapModal(activeOrder),
                        ),
                        const SizedBox(height: 16),

                        // Delivery Status & Single Clickable Done Action
                        if (activeOrder.status == FoodOrderStatus.pendingAcceptance)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.blushTint.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.softPink),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.richMagenta),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Waiting for merchant to agree & accept dish...',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.deepBerry),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (activeOrder.status == FoodOrderStatus.delivering)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.richMagenta,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Mark Delivered (Done)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                state.markOrderDelivered(activeOrder.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✓ Order marked Delivered!'), backgroundColor: AppColors.richMagenta),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.done_all, color: Colors.green),
                                SizedBox(width: 8),
                                Text('This order has been completed and delivered!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
