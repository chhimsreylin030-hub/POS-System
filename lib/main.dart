import 'package:flutter/material.dart';
import 'state/food_delivery_state.dart';
import 'theme/app_colors.dart';
import 'screens/auth/food_login_screen.dart';
import 'screens/customer/customer_food_app.dart';
import 'screens/merchant/merchant_web_portal.dart';
import 'screens/admin/admin_web_portal.dart';
import 'screens/driver/driver_delivery_screen.dart';

enum FoodAppPortal {
  customerApp,    // Mobile phone app for customer ordering
  merchantWeb,    // Dedicated webpage controller for restaurant/store
  adminWeb,       // Dedicated webpage controller for platform super admin
  driverDelivery, // Static delivery driver console
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodDeliveryPlatformApp());
}

class FoodDeliveryPlatformApp extends StatefulWidget {
  const FoodDeliveryPlatformApp({super.key});

  @override
  State<FoodDeliveryPlatformApp> createState() => _FoodDeliveryPlatformAppState();
}

class _FoodDeliveryPlatformAppState extends State<FoodDeliveryPlatformApp> {
  final FoodDeliveryState state = FoodDeliveryState();
  FoodAppPortal _activePortal = FoodAppPortal.customerApp;
  bool _isLoggedIn = true;

  void _switchPortal(FoodAppPortal portal) {
    setState(() {
      _activePortal = portal;
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery Platform • Customer, Merchant, Admin, Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.richMagenta,
          primary: AppColors.richMagenta,
          secondary: AppColors.vibrantPink,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.canvasLight,
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.deepBerry,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.richMagenta,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: _buildPortalView(),
    );
  }

  Widget _buildPortalView() {
    if (!_isLoggedIn) {
      return FoodLoginScreen(
        onSelectPortal: (key) {
          switch (key) {
            case 'merchant':
              _switchPortal(FoodAppPortal.merchantWeb);
              break;
            case 'admin':
              _switchPortal(FoodAppPortal.adminWeb);
              break;
            case 'driver':
              _switchPortal(FoodAppPortal.driverDelivery);
              break;
            case 'customer':
            default:
              _switchPortal(FoodAppPortal.customerApp);
              break;
          }
        },
      );
    }

    switch (_activePortal) {
      case FoodAppPortal.customerApp:
        return CustomerFoodApp(
          onSwitchPortal: () => _switchPortal(FoodAppPortal.merchantWeb),
        );

      case FoodAppPortal.merchantWeb:
        return MerchantWebPortal(
          onNavigateToAdmin: () => _switchPortal(FoodAppPortal.adminWeb),
          onNavigateToCustomer: () => _switchPortal(FoodAppPortal.customerApp),
          onNavigateToDriver: () => _switchPortal(FoodAppPortal.driverDelivery),
          onLogout: () => setState(() => _isLoggedIn = false),
        );

      case FoodAppPortal.adminWeb:
        return AdminWebPortal(
          onNavigateToMerchant: () => _switchPortal(FoodAppPortal.merchantWeb),
          onNavigateToCustomer: () => _switchPortal(FoodAppPortal.customerApp),
          onNavigateToDriver: () => _switchPortal(FoodAppPortal.driverDelivery),
          onLogout: () => setState(() => _isLoggedIn = false),
        );

      case FoodAppPortal.driverDelivery:
        return DriverDeliveryScreen(
          onNavigateToCustomer: () => _switchPortal(FoodAppPortal.customerApp),
          onNavigateToMerchant: () => _switchPortal(FoodAppPortal.merchantWeb),
          onNavigateToAdmin: () => _switchPortal(FoodAppPortal.adminWeb),
        );
    }
  }
}
