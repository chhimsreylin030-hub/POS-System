import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FoodLoginScreen extends StatefulWidget {
  final Function(String portalKey) onSelectPortal;

  const FoodLoginScreen({super.key, required this.onSelectPortal});

  @override
  State<FoodLoginScreen> createState() => _FoodLoginScreenState();
}

class _FoodLoginScreenState extends State<FoodLoginScreen> {
  final _emailCtrl = TextEditingController(text: 'customer@food.com');
  final _passCtrl = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.deepBerry,   // #59123E
              AppColors.richMagenta, // #8C0057
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 16,
                shadowColor: AppColors.deepBerry.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Food Delivery Brand Header
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.richMagenta, AppColors.vibrantPink],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: AppColors.richMagenta.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Icon(Icons.delivery_dining, size: 38, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Center(
                        child: Text(
                          'FOOD DELIVERY PLATFORM',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.deepBerry,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Multi-Channel Delivery System • NBC Bakong KHQR',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blushTint.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.softPink.withValues(alpha: 0.6)),
                          ),
                          child: const Text(
                            'Customer App • Merchant Web • Admin Web • Driver (Static)',
                            style: TextStyle(fontSize: 9, color: AppColors.deepBerry, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email Field
                      TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          labelText: 'Account Email',
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.richMagenta),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderLight)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password Field
                      TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.richMagenta),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderLight)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sign In Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.richMagenta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        onPressed: () => widget.onSelectPortal('customer'),
                        child: const Text('Sign In as Customer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),

                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.borderLight)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'SELECT ROLE PORTAL TO ENTER',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.8),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.borderLight)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 4 Role Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildRoleCard(
                              icon: Icons.phone_android,
                              title: 'Customer App',
                              subtitle: 'Order food on mobile',
                              color: AppColors.richMagenta,
                              onTap: () => widget.onSelectPortal('customer'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildRoleCard(
                              icon: Icons.storefront,
                              title: 'Merchant Web',
                              subtitle: 'Kitchen & menu controller',
                              color: AppColors.deepBerry,
                              onTap: () => widget.onSelectPortal('merchant'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRoleCard(
                              icon: Icons.admin_panel_settings,
                              title: 'Admin Web',
                              subtitle: 'Platform analytics & fleet',
                              color: const Color(0xFFC2185B),
                              onTap: () => widget.onSelectPortal('admin'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildRoleCard(
                              icon: Icons.two_wheeler,
                              title: 'Driver Console',
                              subtitle: 'Static delivery tracking',
                              color: AppColors.vibrantPink,
                              onTap: () => widget.onSelectPortal('driver'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.blushTint.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.softPink.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
