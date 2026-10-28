import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodpanda_app/models/food_models.dart';
import 'package:foodpanda_app/screens/admin/admin_web_portal.dart';
import 'package:foodpanda_app/screens/auth/food_login_screen.dart';
import 'package:foodpanda_app/screens/customer/customer_food_app.dart';
import 'package:foodpanda_app/screens/merchant/merchant_web_portal.dart';
import 'package:foodpanda_app/state/food_delivery_state.dart';

void main() {
  testWidgets('Food Delivery Platform Unit & Widget Smoke Test', (WidgetTester tester) async {
    // 1. Verify Food Delivery state initializes with merchants, dishes, and drivers
    final state = FoodDeliveryState();
    expect(state.merchants.isNotEmpty, true);
    expect(state.menuItems.isNotEmpty, true);
    expect(state.drivers.isNotEmpty, true);
    expect(state.vouchers.isNotEmpty, true);

    // 2. Test Login Widget loads cleanly
    await tester.pumpWidget(
      MaterialApp(
        home: FoodLoginScreen(onSelectPortal: (_) {}),
      ),
    );

    // Verify brand title and quick portal launcher buttons render
    expect(find.text('FOOD DELIVERY PLATFORM'), findsOneWidget);
    expect(find.text('Customer App'), findsOneWidget);
    expect(find.text('Merchant Web'), findsOneWidget);
    expect(find.text('Admin Web'), findsOneWidget);
    expect(find.text('Driver Console'), findsOneWidget);

    // Clean up timers before test completes
    state.stopAutoConnectHeartbeat();
  });

  testWidgets('PasswordInputField hide and unhide toggle test', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordInputField(
            controller: controller,
            label: 'Test Password',
            hint: 'Enter pass',
          ),
        ),
      ),
    );

    // Initially obscured
    TextField textField = tester.widget(find.byType(TextField));
    expect(textField.obscureText, true);

    // Enter text
    await tester.enterText(find.byType(TextField), 'secret123');
    await tester.pump();
    expect(controller.text, 'secret123');

    // Tap suffix eye icon button to toggle to unhide
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    // Now unobscured
    textField = tester.widget(find.byType(TextField));
    expect(textField.obscureText, false);
    expect(controller.text, 'secret123');

    // Tap suffix eye icon button again to hide
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    textField = tester.widget(find.byType(TextField));
    expect(textField.obscureText, true);
    expect(controller.text, 'secret123');
  });

  test('Customer Address state management unit test', () async {
    final state = FoodDeliveryState();
    state.stopAutoConnectHeartbeat();

    // Initial state has default seeded addresses
    expect(state.savedAddresses.isNotEmpty, true);
    final initialCount = state.savedAddresses.length;

    // Add address
    await state.addCustomerAddress(
      label: 'Gym',
      addressLine: 'The Place Gym, Toul Kork, Phnom Penh',
      city: 'Phnom Penh',
      isDefault: false,
    );
    expect(state.savedAddresses.length, initialCount + 1);
    expect(state.savedAddresses.any((a) => a.label == 'Gym'), true);

    // Set delivery address
    state.setDeliveryAddress('The Place Gym, Toul Kork, Phnom Penh');
    expect(state.deliveryAddress, 'The Place Gym, Toul Kork, Phnom Penh');

    // Update address
    final gymAddr = state.savedAddresses.firstWhere((a) => a.label == 'Gym');
    await state.updateCustomerAddress(
      id: gymAddr.id,
      label: 'Club Gym',
      addressLine: 'St 289, Toul Kork, Phnom Penh',
      city: 'Phnom Penh',
      isDefault: false,
    );
    expect(state.savedAddresses.any((a) => a.label == 'Club Gym'), true);

    // Delete address
    await state.deleteCustomerAddress(gymAddr.id);
    expect(state.savedAddresses.any((a) => a.id == gymAddr.id), false);
  });

  testWidgets('MerchantWebPortal small screen responsive layout test (no RenderFlex overflow)', (WidgetTester tester) async {
    final state = FoodDeliveryState();
    state.stopAutoConnectHeartbeat();

    // Set screen size to narrow width (e.g. 500 x 800)
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: MerchantWebPortal(
          onNavigateToCustomer: () {},
          onNavigateToAdmin: () {},
          onNavigateToDriver: () {},
          onLogout: () {},
        ),
      ),
    );

    // Initial is Merchant Login/Register screen
    await tester.pumpAndSettle();
    expect(find.text('SmartFood Merchant'), findsOneWidget);

    // Now log in merchant in state
    state.isMerchantLoggedIn = true;
    state.currentMerchantAccount = MerchantAccount(
      id: '1',
      accountName: 'Angkor Group Co.',
      email: 'contact@angkor.com',
      phone: '012 345 678',
      companyRegNumber: 'MO-1029',
    );
    state.activeMerchantId = 'rest-1';

    await tester.pumpWidget(
      MaterialApp(
        home: MerchantWebPortal(
          onNavigateToCustomer: () {},
          onNavigateToAdmin: () {},
          onNavigateToDriver: () {},
          onLogout: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Header Bar rendered cleanly without overflow
    expect(find.text('Merchant Controller'), findsOneWidget);

    // Test with even smaller width 360px (mobile)
    tester.view.physicalSize = const Size(360, 800);
    await tester.pumpAndSettle();

    // Test with width 803.3px (reported in user issue)
    tester.view.physicalSize = const Size(803.3, 800);
    await tester.pumpAndSettle();
  });

  testWidgets('AdminWebPortal small screen responsive layout test (no RenderFlex overflow)', (WidgetTester tester) async {
    final state = FoodDeliveryState();
    state.stopAutoConnectHeartbeat();

    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: AdminWebPortal(
          onNavigateToCustomer: () {},
          onNavigateToMerchant: () {},
          onNavigateToDriver: () {},
          onLogout: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Corporate Super Admin Controller'), findsOneWidget);

    // Test with width 803.3px
    tester.view.physicalSize = const Size(803.3, 800);
    await tester.pumpAndSettle();
  });
}
