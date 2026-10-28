import 'package:flutter/material.dart';
import '../../state/pos_state.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final Function(String portalKey)? onSelectPortal;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    this.onSelectPortal,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@pos.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _performLogin(String email, String password, {String? targetPortal}) {
    setState(() => _errorMessage = null);
    final posState = PosState();
    final success = posState.login(email, password);
    if (success) {
      if (targetPortal != null && widget.onSelectPortal != null) {
        widget.onSelectPortal!(targetPortal);
      } else {
        widget.onLoginSuccess();
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid email or password.';
      });
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 16,
                shadowColor: AppColors.deepBerry.withValues(alpha: 0.5),
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Brand Logo & Header
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
                                BoxShadow(
                                  color: AppColors.richMagenta.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.point_of_sale, size: 36, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'SMART POS & PAY',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: AppColors.deepBerry,
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Enterprise Multi-Channel Retail & Payment System',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.blushTint.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.softPink.withValues(alpha: 0.6)),
                            ),
                            child: const Text(
                              'NBC Bakong KHQR • Dual Currency (USD & KHR)',
                              style: TextStyle(fontSize: 10, color: AppColors.deepBerry, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Staff Email Address',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.richMagenta),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.richMagenta, width: 2),
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Please enter email' : null,
                        ),
                        const SizedBox(height: 14),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.richMagenta),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: AppColors.textMuted),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.richMagenta, width: 2),
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Please enter password' : null,
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Main Sign In Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.richMagenta,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _performLogin(_emailController.text, _passwordController.text);
                            }
                          },
                          child: const Text('Sign In to System', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),

                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.borderLight)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'QUICK PORTAL SELECTOR',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1),
                              ),
                            ),
                            Expanded(child: Divider(color: AppColors.borderLight)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 4 Portal Quick Launch Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildPortalButton(
                                icon: Icons.admin_panel_settings,
                                title: 'Admin Web',
                                subtitle: 'Corporate Super Admin',
                                color: AppColors.deepBerry,
                                onTap: () => _performLogin('admin@pos.com', 'admin123', targetPortal: 'admin'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPortalButton(
                                icon: Icons.storefront,
                                title: 'Merchant Web',
                                subtitle: 'Store Management',
                                color: AppColors.richMagenta,
                                onTap: () => _performLogin('merchant@pos.com', 'admin123', targetPortal: 'merchant'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPortalButton(
                                icon: Icons.point_of_sale,
                                title: 'POS Cashier',
                                subtitle: 'Front Checkout',
                                color: const Color(0xFFC2185B),
                                onTap: () => _performLogin('cashier@pos.com', 'cashier123', targetPortal: 'posTerminal'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPortalButton(
                                icon: Icons.phone_android,
                                title: 'Customer App',
                                subtitle: 'Mobile Smartphone',
                                color: AppColors.vibrantPink,
                                onTap: () {
                                  if (widget.onSelectPortal != null) {
                                    widget.onSelectPortal!('customerMobile');
                                  } else {
                                    widget.onLoginSuccess();
                                  }
                                },
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
      ),
    );
  }

  Widget _buildPortalButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.blushTint.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
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
