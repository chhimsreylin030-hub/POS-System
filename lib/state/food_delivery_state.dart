import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food_models.dart';
import '../services/food_api_service.dart';

class FoodDeliveryState extends ChangeNotifier {
  static final FoodDeliveryState _instance = FoodDeliveryState._internal();
  factory FoodDeliveryState() => _instance;

  Timer? _autoConnectTimer;

  FoodDeliveryState._internal() {
    _initSeedData();
    syncWithDatabase();
    _startAutoConnectHeartbeat();
  }

  void _startAutoConnectHeartbeat() {
    _autoConnectTimer?.cancel();
    // Auto-reconnect timer: Every 3 seconds, if MySQL is offline, automatically retry connecting!
    _autoConnectTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isDbConnected && !isLoadingDb) {
        syncWithDatabase();
      }
    });
  }

  void stopAutoConnectHeartbeat() {
    _autoConnectTimer?.cancel();
    _autoConnectTimer = null;
  }

  @override
  void dispose() {
    stopAutoConnectHeartbeat();
    super.dispose();
  }

  // Live MySQL Database Status
  bool isDbConnected = false;
  bool isLoadingDb = false;
  String dbStatusMessage = 'Connecting to MySQL (pos_db)...';
  int dbMerchantsCount = 0;
  int dbMenuItemsCount = 0;
  int dbOrdersCount = 0;

  // Currency Exchange Rate ($1 = 4,100 ៛)
  final double usdToKhrRate = 4100.0;
  double usdToKhr(double usd) => usd * usdToKhrRate;

  // Active Merchant ID for Merchant Controller
  String activeMerchantId = '1';

  // Merchant Multi-Tenant Corporate Account State (10 Isolated Accounts)
  final List<MerchantAccount> merchantAccounts = [];
  MerchantAccount? currentMerchantAccount;
  bool isMerchantLoggedIn = false;

  // Multi-Tenant Isolation: Returns ONLY restaurants belonging to the logged-in merchant account
  List<RestaurantMerchant> get currentMerchantRestaurants {
    if (currentMerchantAccount == null) return [];
    return merchants.where((m) => m.accountId == currentMerchantAccount!.id).toList();
  }

  // Data Stores
  final List<RestaurantMerchant> merchants = [];
  final List<FoodMenuItem> menuItems = [];
  final List<DeliveryDriver> drivers = [];
  final List<FoodOrder> orders = [];
  final List<PromoVoucher> vouchers = [];

  // Customer Cart & Auth State
  RestaurantMerchant? cartMerchant;
  final List<FoodCartItem> cartItems = [];
  bool isCustomerLoggedIn = false;
  String? currentCustomerId;
  String customerName = 'Guest User';
  String customerPhone = '';
  String customerEmail = '';
  String deliveryAddress = 'House 42, St 271, Boeng Tumpun, Phnom Penh';
  String membershipTier = 'REGULAR';
  int loyaltyPoints = 0;

  // Saved Delivery Addresses (pos_db.customer_addresses)
  final List<CustomerDeliveryAddress> savedAddresses = [];

  // Individual Customer Orders (100% Isolated: returns ONLY orders placed by this customer)
  List<FoodOrder> get customerOrders {
    if (!isCustomerLoggedIn || customerPhone.isEmpty) return [];
    return orders.where((o) => o.customerPhone == customerPhone || o.customerName == customerName).toList();
  }

  PromoVoucher? appliedVoucher;
  FoodOrder? activeTrackingOrder;
  FoodOrder? lastNewOrderNotification;

  void dismissNewOrderNotification() {
    lastNewOrderNotification = null;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // Customer Authentication: Login & Register (Synced with pos_db.customers)
  // --------------------------------------------------------------------------
  Future<Map<String, dynamic>> loginCustomer(String identifier, String password) async {
    final res = await FoodApiService.loginCustomer(identifier: identifier, password: password);
    if (res != null && res['success'] == true) {
      final cust = res['customer'] as Map<String, dynamic>;
      isCustomerLoggedIn = true;
      currentCustomerId = cust['id']?.toString() ?? '1';
      customerName = cust['name'] ?? customerName;
      customerPhone = cust['phone'] ?? customerPhone;
      customerEmail = cust['email'] ?? customerEmail;
      deliveryAddress = cust['address'] ?? deliveryAddress;
      membershipTier = cust['membershipTier'] ?? 'REGULAR';
      loyaltyPoints = cust['loyaltyPoints'] ?? 0;
      notifyListeners();
      return {'success': true, 'message': res['message'] ?? 'Login successful'};
    } else {
      // Offline fallback: check if matches demo user
      if (identifier == '010 334 556' || identifier.toLowerCase().contains('bopha')) {
        isCustomerLoggedIn = true;
        currentCustomerId = '3';
        customerName = 'Bopha Pich (ពេជ្រ បុប្ផា)';
        customerPhone = '010 334 556';
        customerEmail = 'bopha.pich@outlook.com';
        deliveryAddress = 'House 42, St 271, Boeng Tumpun, Phnom Penh';
        membershipTier = 'SILVER';
        loyaltyPoints = 80;
        notifyListeners();
        return {'success': true, 'message': 'Welcome back, Bopha Pich!'};
      }
      return {'success': false, 'message': res?['message'] ?? 'Invalid phone or password.'};
    }
  }

  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
  }) async {
    final res = await FoodApiService.registerCustomer(
      name: name,
      phone: phone,
      email: email,
      password: password,
      address: address,
    );
    if (res != null && res['success'] == true) {
      final cust = res['customer'] as Map<String, dynamic>;
      isCustomerLoggedIn = true;
      currentCustomerId = cust['id']?.toString() ?? '1';
      customerName = cust['name'] ?? name;
      customerPhone = cust['phone'] ?? phone;
      customerEmail = cust['email'] ?? email;
      deliveryAddress = cust['address'] ?? address;
      membershipTier = cust['membershipTier'] ?? 'REGULAR';
      loyaltyPoints = cust['loyaltyPoints'] ?? 25;
      notifyListeners();
      return {'success': true, 'message': res['message'] ?? 'Registration successful!'};
    } else {
      return {'success': false, 'message': res?['message'] ?? 'Registration failed. Phone may already be registered.'};
    }
  }

  void logoutCustomer() {
    isCustomerLoggedIn = false;
    currentCustomerId = null;
    customerName = 'Guest User';
    customerPhone = '';
    customerEmail = '';
    membershipTier = 'REGULAR';
    loyaltyPoints = 0;
    deliveryAddress = 'House 42, St 271, Boeng Tumpun, Phnom Penh';
    cartMerchant = null;
    cartItems.clear();
    appliedVoucher = null;
    activeTrackingOrder = null;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // Customer Delivery Address & Location Management (pos_db.customer_addresses)
  // --------------------------------------------------------------------------
  void setDeliveryAddress(String newAddress) {
    deliveryAddress = newAddress;
    for (final a in savedAddresses) {
      a.isDefault = (a.addressLine.trim().toLowerCase() == newAddress.trim().toLowerCase());
    }
    if (isCustomerLoggedIn && currentCustomerId != null) {
      FoodApiService.updateCustomerProfile(
        id: currentCustomerId!,
        name: customerName,
        phone: customerPhone,
        address: newAddress,
      );
    }
    notifyListeners();
  }

  Future<void> addCustomerAddress({
    required String label,
    required String addressLine,
    String city = 'Phnom Penh',
    bool isDefault = false,
  }) async {
    final custId = currentCustomerId ?? '1';
    final newAddr = CustomerDeliveryAddress(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      customerId: custId,
      label: label,
      addressLine: addressLine,
      city: city,
      isDefault: isDefault || savedAddresses.isEmpty,
    );

    if (newAddr.isDefault) {
      for (final a in savedAddresses) {
        a.isDefault = false;
      }
      deliveryAddress = addressLine;
    }

    savedAddresses.add(newAddr);
    notifyListeners();

    final dbId = await FoodApiService.addCustomerAddress(newAddr);
    if (dbId != null) {
      await fetchSavedAddresses();
    }
  }

  Future<void> updateCustomerAddress({
    required String id,
    required String label,
    required String addressLine,
    String city = 'Phnom Penh',
    bool isDefault = false,
  }) async {
    final idx = savedAddresses.indexWhere((a) => a.id == id);
    if (idx != -1) {
      if (isDefault) {
        for (final a in savedAddresses) {
          a.isDefault = false;
        }
        deliveryAddress = addressLine;
      }
      savedAddresses[idx].label = label;
      savedAddresses[idx].addressLine = addressLine;
      savedAddresses[idx].city = city;
      savedAddresses[idx].isDefault = isDefault;
      notifyListeners();

      await FoodApiService.updateCustomerAddress(savedAddresses[idx]);
    }
  }

  Future<void> deleteCustomerAddress(String id) async {
    savedAddresses.removeWhere((a) => a.id == id);
    if (savedAddresses.isNotEmpty && !savedAddresses.any((a) => a.isDefault)) {
      savedAddresses.first.isDefault = true;
      deliveryAddress = savedAddresses.first.addressLine;
    }
    notifyListeners();
    await FoodApiService.deleteCustomerAddress(id);
  }

  Future<void> fetchSavedAddresses() async {
    final custId = currentCustomerId ?? '1';
    final dbAddrs = await FoodApiService.getCustomerAddresses(custId);
    if (dbAddrs.isNotEmpty) {
      savedAddresses.clear();
      savedAddresses.addAll(dbAddrs);
      final defaultAddr = savedAddresses.firstWhere((a) => a.isDefault, orElse: () => savedAddresses.first);
      deliveryAddress = defaultAddr.addressLine;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Merchant Multi-Tenant Corporate Login & Logout (pos_db.merchant_accounts)
  // --------------------------------------------------------------------------
  Future<Map<String, dynamic>> loginMerchant(String identifier, String password) async {
    final res = await FoodApiService.loginMerchantAccount(identifier: identifier, password: password);
    if (res != null && res['success'] == true) {
      final accData = res['account'] as Map<String, dynamic>;
      final accId = accData['id'].toString();
      currentMerchantAccount = MerchantAccount(
        id: accId,
        accountName: accData['accountName'] ?? '',
        email: accData['email'] ?? '',
        phone: accData['phone'] ?? '',
        companyRegNumber: accData['companyRegNumber'] ?? '',
        status: accData['status'] ?? 'ACTIVE',
        restaurantsCount: merchants.where((m) => m.accountId == accId).length,
      );
      isMerchantLoggedIn = true;
      final allowedStores = currentMerchantRestaurants;
      if (allowedStores.isNotEmpty) {
        activeMerchantId = allowedStores.first.id;
      }
      notifyListeners();
      return {'success': true, 'message': res['message'] ?? 'Logged in successfully'};
    } else {
      // Offline fallback: match by email or id
      final match = merchantAccounts.firstWhere(
        (a) => a.email.toLowerCase() == identifier.toLowerCase() || a.id == identifier,
        orElse: () => merchantAccounts.isNotEmpty
            ? merchantAccounts.first
            : MerchantAccount(id: '1', accountName: 'Angkor Food & Heritage Group', email: identifier, phone: '+855 23 881 111', companyRegNumber: 'AF-2026-001'),
      );
      currentMerchantAccount = match;
      isMerchantLoggedIn = true;
      final allowedStores = currentMerchantRestaurants;
      if (allowedStores.isNotEmpty) {
        activeMerchantId = allowedStores.first.id;
      }
      notifyListeners();
      return {'success': true, 'message': 'Welcome back, ${match.accountName}!'};
    }
  }

  Future<Map<String, dynamic>> registerMerchant({
    required String accountName,
    required String email,
    required String phone,
    required String password,
    String? companyRegNumber,
    required String restaurantName,
    String? khmerName,
    String? cuisine,
    String? address,
  }) async {
    final res = await FoodApiService.registerMerchantAccount(
      accountName: accountName,
      email: email,
      phone: phone,
      password: password,
      companyRegNumber: companyRegNumber,
      restaurantName: restaurantName,
      khmerName: khmerName,
      cuisine: cuisine,
      address: address,
    );

    if (res != null && res['success'] == true) {
      final accData = res['account'] as Map<String, dynamic>;
      final accId = accData['id'].toString();

      // Refresh merchants, categories, and products from MySQL so new store is active
      await syncWithDatabase();

      currentMerchantAccount = MerchantAccount(
        id: accId,
        accountName: accData['accountName'] ?? accountName,
        email: accData['email'] ?? email,
        phone: accData['phone'] ?? phone,
        companyRegNumber: accData['companyRegNumber'] ?? companyRegNumber ?? '',
        status: accData['status'] ?? 'ACTIVE',
        restaurantsCount: merchants.where((m) => m.accountId == accId).length,
      );
      isMerchantLoggedIn = true;
      final allowedStores = currentMerchantRestaurants;
      if (allowedStores.isNotEmpty) {
        activeMerchantId = allowedStores.first.id;
      }
      notifyListeners();
      return {'success': true, 'message': res['message'] ?? 'Merchant registered successfully!'};
    } else {
      // Offline fallback: create local merchant account & restaurant
      final newAccId = (merchantAccounts.length + 1).toString();
      final newAcc = MerchantAccount(
        id: newAccId,
        accountName: accountName,
        email: email,
        phone: phone,
        companyRegNumber: companyRegNumber ?? 'CR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        status: 'ACTIVE',
        restaurantsCount: 1,
      );
      merchantAccounts.add(newAcc);

      final newRest = RestaurantMerchant(
        id: 'rest-$newAccId',
        accountId: newAccId,
        name: restaurantName,
        khmerName: khmerName ?? restaurantName,
        cuisine: cuisine ?? 'Khmer Gourmet & Asian Cuisine',
        bannerUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=700&q=80',
        logoUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&q=80',
        rating: 5.0,
        deliveryTimeMin: 20,
        deliveryFeeUSD: 1.00,
        address: address ?? 'Phnom Penh, Cambodia',
        phone: phone,
        totalSalesUSD: 0.0,
      );
      merchants.add(newRest);

      currentMerchantAccount = newAcc;
      isMerchantLoggedIn = true;
      activeMerchantId = newRest.id;
      notifyListeners();
      return {'success': true, 'message': 'Welcome! Your merchant account has been registered.'};
    }
  }

  void logoutMerchant() {
    isMerchantLoggedIn = false;
    currentMerchantAccount = null;
    activeMerchantId = '';
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // Synchronize with Local Laptop MySQL Database
  // --------------------------------------------------------------------------
  Future<void> syncWithDatabase() async {
    isLoadingDb = true;
    notifyListeners();

    try {
      final health = await FoodApiService.checkHealth();
      if (health != null && health['connected'] == true) {
        isDbConnected = true;
        dbMerchantsCount = health['categories_count'] ?? 0;
        dbMenuItemsCount = health['products_count'] ?? 0;
        dbOrdersCount = health['orders_count'] ?? 0;
        dbStatusMessage = 'Connected to MySQL 8.0 (pos_db • $dbMenuItemsCount Products, $dbMerchantsCount Categories)';

        // Fetch Live Merchants from MySQL
        final dbMerchants = await FoodApiService.getMerchants();
        if (dbMerchants.isNotEmpty) {
          merchants.clear();
          merchants.addAll(dbMerchants);
          activeMerchantId = dbMerchants.first.id;
        }

        // Fetch Live Menu Items from MySQL
        final dbItems = await FoodApiService.getMenuItems();
        if (dbItems.isNotEmpty) {
          menuItems.clear();
          menuItems.addAll(dbItems);
        }

        // Fetch Live Orders from MySQL
        final dbOrders = await FoodApiService.getOrders();
        if (dbOrders.isNotEmpty) {
          orders.clear();
          orders.addAll(dbOrders);
          activeTrackingOrder = dbOrders.first;
        }

        // Fetch Live Merchant Accounts from MySQL
        final dbAccounts = await FoodApiService.getMerchantAccounts();
        if (dbAccounts.isNotEmpty) {
          merchantAccounts.clear();
          merchantAccounts.addAll(dbAccounts);
        }

        // Fetch Live Promo Vouchers from MySQL (pos_db.vouchers)
        final dbVouchers = await FoodApiService.getVouchers();
        if (dbVouchers.isNotEmpty) {
          vouchers.clear();
          vouchers.addAll(dbVouchers);
        }

        // Fetch Live Delivery Drivers from MySQL (pos_db.delivery_drivers)
        final dbDrivers = await FoodApiService.getDrivers();
        if (dbDrivers.isNotEmpty) {
          drivers.clear();
          drivers.addAll(dbDrivers);
        }
      } else {
        isDbConnected = false;
        dbStatusMessage = 'MySQL API Offline • Auto-retrying every 3s...';
      }
    } catch (e) {
      isDbConnected = false;
      dbStatusMessage = 'Database Sync: $e • Auto-retrying...';
    } finally {
      isLoadingDb = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Lightweight Background Sync for Orders (Real-time Polling)
  // --------------------------------------------------------------------------
  Future<void> syncOrdersOnly() async {
    try {
      final dbOrders = await FoodApiService.getOrders();
      if (dbOrders.isEmpty) return;

      if (!isDbConnected) {
        isDbConnected = true;
        dbOrdersCount = dbOrders.length;
        dbStatusMessage = 'Connected to MySQL 8.0 (pos_db)';
      }

      final knownOrderIds = orders.map((o) => o.id).toSet();
      final knownOrderNumbers = orders.map((o) => o.orderNumber).toSet();

      for (final o in dbOrders) {
        if (!knownOrderIds.contains(o.id) && !knownOrderNumbers.contains(o.orderNumber)) {
          if (o.status == FoodOrderStatus.pendingAcceptance) {
            lastNewOrderNotification = o;
          }
        }
      }

      orders.clear();
      orders.addAll(dbOrders);
      dbOrdersCount = orders.length;

      if (activeTrackingOrder != null) {
        final match = orders.firstWhere(
          (o) => o.id == activeTrackingOrder!.id || o.orderNumber == activeTrackingOrder!.orderNumber,
          orElse: () => activeTrackingOrder!,
        );
        activeTrackingOrder = match;
      }

      notifyListeners();
    } catch (_) {}
  }

  // --------------------------------------------------------------------------
  // Cart Calculations
  // --------------------------------------------------------------------------
  double get cartSubtotalUSD =>
      cartItems.fold(0.0, (sum, i) => sum + i.totalUSD);

  double get cartDeliveryFeeUSD =>
      cartItems.isEmpty ? 0.0 : (cartMerchant?.deliveryFeeUSD ?? 1.00);

  double get cartDiscountUSD {
    if (appliedVoucher == null || cartItems.isEmpty) return 0.0;
    return cartSubtotalUSD * (appliedVoucher!.discountPercent / 100);
  }

  double get cartTotalUSD =>
      (cartSubtotalUSD - cartDiscountUSD) + cartDeliveryFeeUSD;

  double get cartTotalKHR => usdToKhr(cartTotalUSD);

  // --------------------------------------------------------------------------
  // Cart Actions
  // --------------------------------------------------------------------------
  void addToCart(RestaurantMerchant merchant, FoodMenuItem item, {String notes = ''}) {
    if (cartMerchant != null && cartMerchant!.id != merchant.id) {
      cartItems.clear();
      appliedVoucher = null;
    }
    cartMerchant = merchant;

    final existingIndex = cartItems.indexWhere((i) => i.menuItem.id == item.id);
    if (existingIndex != -1) {
      cartItems[existingIndex].quantity += 1;
      if (notes.isNotEmpty) {
        cartItems[existingIndex].specialNotes = notes;
      }
    } else {
      cartItems.add(FoodCartItem(menuItem: item, quantity: 1, specialNotes: notes));
    }
    notifyListeners();
  }

  void updateCartQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      cartItems.removeWhere((i) => i.menuItem.id == itemId);
      if (cartItems.isEmpty) {
        cartMerchant = null;
        appliedVoucher = null;
      }
    } else {
      final index = cartItems.indexWhere((i) => i.menuItem.id == itemId);
      if (index != -1) {
        cartItems[index].quantity = quantity;
      }
    }
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    cartMerchant = null;
    appliedVoucher = null;
    notifyListeners();
  }

  bool applyVoucher(String code) {
    final v = vouchers.firstWhere(
      (v) => v.code.toUpperCase() == code.trim().toUpperCase(),
      orElse: () => PromoVoucher(code: '', discountPercent: 0, description: ''),
    );
    if (v.code.isNotEmpty) {
      appliedVoucher = v;
      notifyListeners();
      return true;
    }
    return false;
  }

  // --------------------------------------------------------------------------
  // Order Placement (Customer)
  // --------------------------------------------------------------------------
  FoodOrder placeOrder({required FoodPaymentMethod paymentMethod}) {
    final orderNum = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final driver = drivers.isNotEmpty
        ? drivers.first
        : DeliveryDriver(
            id: 'DRV-001',
            name: 'Sokha Chea',
            khmerName: 'ជា សុខា',
            vehiclePlate: 'Phnom Penh 1AB-2345 (Honda Dream)',
            rating: 4.9,
          );

    final order = FoodOrder(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNum,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      merchantId: cartMerchant?.id ?? 'rest-1',
      merchantName: cartMerchant?.name ?? 'Angkor Kitchen',
      items: List.from(cartItems),
      subtotalUSD: cartSubtotalUSD,
      deliveryFeeUSD: cartDeliveryFeeUSD,
      discountUSD: cartDiscountUSD,
      totalUSD: cartTotalUSD,
      totalKHR: cartTotalKHR,
      paymentMethod: paymentMethod,
      status: FoodOrderStatus.pendingAcceptance,
      driverId: driver.id,
      driverName: driver.name,
      driverPlate: driver.vehiclePlate,
      orderTime: DateTime.now(),
    );

    orders.insert(0, order);
    activeTrackingOrder = order;

    if (cartMerchant != null) {
      cartMerchant!.totalSalesUSD += order.totalUSD;
    }

    // Persist to MySQL Database
    FoodApiService.placeOrder(order).then((res) {
      if (res != null) {
        if (res['id'] != null) {
          order.id = res['id'].toString();
        }
        if (res['orderNumber'] != null) {
          order.orderNumber = res['orderNumber'].toString();
        }
        notifyListeners();
      }
    });

    clearCart();
    notifyListeners();
    return order;
  }

  // --------------------------------------------------------------------------
  // Merchant Order Processing: Accept -> Assigns Driver & Sets to Delivering
  // --------------------------------------------------------------------------
  void merchantAcceptOrder(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId || o.orderNumber == orderId);
    if (idx != -1) {
      // When merchant agrees on the dish, app assigns driver and sets to delivering
      orders[idx].status = FoodOrderStatus.delivering;
      if (drivers.isNotEmpty) {
        final assigned = drivers[idx % drivers.length];
        orders[idx].driverId = assigned.id;
        orders[idx].driverName = assigned.name;
        orders[idx].driverPlate = assigned.vehiclePlate;
      }
      if (activeTrackingOrder?.id == orderId || activeTrackingOrder?.orderNumber == orderId) {
        activeTrackingOrder!.status = FoodOrderStatus.delivering;
        if (drivers.isNotEmpty) {
          activeTrackingOrder!.driverId = orders[idx].driverId;
          activeTrackingOrder!.driverName = orders[idx].driverName;
          activeTrackingOrder!.driverPlate = orders[idx].driverPlate;
        }
      }
      if (lastNewOrderNotification?.id == orderId || lastNewOrderNotification?.orderNumber == orderId) {
        lastNewOrderNotification = null;
      }
      // Persist to MySQL
      FoodApiService.updateOrderStatus(orderId, 'delivering');
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Mark Order Delivered / Done
  // --------------------------------------------------------------------------
  void markOrderDelivered(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId || o.orderNumber == orderId);
    if (idx != -1) {
      orders[idx].status = FoodOrderStatus.delivered;
      if (activeTrackingOrder?.id == orderId || activeTrackingOrder?.orderNumber == orderId) {
        activeTrackingOrder!.status = FoodOrderStatus.delivered;
      }
      // Persist to MySQL
      FoodApiService.updateOrderStatus(orderId, 'delivered');
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Menu Item CRUD (Merchant Webpage - Persisted to MySQL)
  // --------------------------------------------------------------------------
  void addMenuItem(FoodMenuItem item) {
    menuItems.add(item);
    FoodApiService.addMenuItem(item).then((newId) {
      if (newId != null) {
        // sync ID if returned
      }
    });
    notifyListeners();
  }

  void updateMenuItem(FoodMenuItem item) {
    final idx = menuItems.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      menuItems[idx] = item;
      FoodApiService.updateMenuItem(item);
      notifyListeners();
    }
  }

  void toggleItemAvailability(String itemId) {
    final idx = menuItems.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      menuItems[idx].isAvailable = !menuItems[idx].isAvailable;
      FoodApiService.updateMenuItem(menuItems[idx]);
      notifyListeners();
    }
  }

  void deleteMenuItem(String itemId) {
    menuItems.removeWhere((i) => i.id == itemId);
    FoodApiService.deleteMenuItem(itemId);
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // Admin Operations (Admin Webpage)
  // --------------------------------------------------------------------------
  void toggleMerchantOpen(String merchantId) {
    final idx = merchants.indexWhere((m) => m.id == merchantId);
    if (idx != -1) {
      merchants[idx].isOpen = !merchants[idx].isOpen;
      notifyListeners();
    }
  }

  void addVoucher(PromoVoucher voucher) {
    vouchers.add(voucher);
    notifyListeners();
  }

  double get totalPlatformGMV =>
      orders.fold(0.0, (sum, o) => sum + (o.status != FoodOrderStatus.cancelled ? o.totalUSD : 0.0));

  double get platformCommissionEarnings => totalPlatformGMV * 0.15; // 15% platform cut

  // --------------------------------------------------------------------------
  // Seed Data Initializer
  // --------------------------------------------------------------------------
  void _initSeedData() {
    // 1. Cambodian Restaurants (Merchants)
    merchants.addAll([
      RestaurantMerchant(
        id: 'rest-1',
        name: 'Angkor Authentic Kitchen',
        khmerName: 'ផ្ទះបាយខ្មែរ អង្គរ',
        cuisine: 'Traditional Khmer • Rice & Noodles',
        bannerUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&q=80',
        logoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200&q=80',
        rating: 4.9,
        deliveryTimeMin: 20,
        deliveryFeeUSD: 1.00,
        address: 'St 214, Daun Penh, Phnom Penh',
        phone: '023 219 900',
        totalSalesUSD: 480.0,
      ),
      RestaurantMerchant(
        id: 'rest-2',
        name: 'Phnom Penh Brown Coffee & Bakery',
        khmerName: 'ហាងកាហ្វេ និងនំបុ័ង ប្រោន',
        cuisine: 'Specialty Coffee • Croissants • Cakes',
        bannerUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=700&q=80',
        logoUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=200&q=80',
        rating: 4.8,
        deliveryTimeMin: 15,
        deliveryFeeUSD: 0.75,
        address: 'St 57, BKK1, Phnom Penh',
        phone: '023 222 345',
        totalSalesUSD: 310.0,
      ),
      RestaurantMerchant(
        id: 'rest-3',
        name: 'Sen Sok Gourmet Burger & Pizza',
        khmerName: 'ប៊ឺហ្គឺ និងភីហ្សា សែនសុខ',
        cuisine: 'American Fast Food • Crispy Chicken',
        bannerUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700&q=80',
        logoUrl: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=200&q=80',
        rating: 4.7,
        deliveryTimeMin: 30,
        deliveryFeeUSD: 1.25,
        address: 'St 1003, Sen Sok, Phnom Penh',
        phone: '012 998 776',
        totalSalesUSD: 520.0,
      ),
      RestaurantMerchant(
        id: 'rest-4',
        name: 'Malis Khmer Street Food',
        khmerName: 'ម្ហូបតាមផ្លូវ ម្លិះ',
        cuisine: 'Barbecue • Seafood • Spicy Salad',
        bannerUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=700&q=80',
        logoUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=200&q=80',
        rating: 4.6,
        deliveryTimeMin: 25,
        deliveryFeeUSD: 1.00,
        address: 'St 155, Tuol Tompoung, Phnom Penh',
        phone: '015 667 889',
        totalSalesUSD: 240.0,
      ),
    ]);

    // 2. Menu Items
    menuItems.addAll([
      FoodMenuItem(
        id: 'dish-1',
        merchantId: 'rest-1',
        name: 'Khmer Beef Lok Lak with Jasmine Rice',
        khmerName: 'បាយឡុកឡាក់សាច់គោខ្មែរ',
        description: 'Tender marinated cubed beef with lime-black pepper dipping sauce, fried egg, and steamed jasmine rice.',
        priceUSD: 4.50,
        imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80',
        category: 'Khmer Dishes',
        isAvailable: true,
      ),
      FoodMenuItem(
        id: 'dish-2',
        merchantId: 'rest-1',
        name: 'Traditional Fish Amok in Banana Leaf',
        khmerName: 'អាម៉ុកត្រីស្លឹកចេក',
        description: 'Steamed river fish mousse infused with fresh kroeung paste, coconut milk, and wild kaffir leaves.',
        priceUSD: 5.00,
        imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=500&q=80',
        category: 'Khmer Dishes',
        isAvailable: true,
      ),
      FoodMenuItem(
        id: 'dish-3',
        merchantId: 'rest-1',
        name: 'Crispy Pork & Seafood Spring Rolls (4 pcs)',
        khmerName: 'ណែមចៀនសាច់ជ្រូក',
        description: 'Deep-fried golden rolls stuffed with minced pork, taro, and glass noodles with sweet chili dip.',
        priceUSD: 3.00,
        imageUrl: 'https://images.unsplash.com/photo-1541518763669-27fef04b14ea?w=500&q=80',
        category: 'Appetizers',
        isAvailable: true,
      ),
      FoodMenuItem(
        id: 'dish-4',
        merchantId: 'rest-1',
        name: 'Iced Tamarind Juice with Chia Seeds',
        khmerName: 'ទឹកអំពិលទុំទឹកកក',
        description: 'Fresh chilled sweet and tangy tamarind drink served over crushed ice.',
        priceUSD: 1.50,
        imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=500&q=80',
        category: 'Drinks',
        isAvailable: true,
      ),
      FoodMenuItem(
        id: 'dish-5',
        merchantId: 'rest-2',
        name: 'Iced Palm Sugar Latte',
        khmerName: 'កាហ្វេទឹកដោះគោស្ករត្នោត',
        description: 'Double espresso pulled over fresh milk and Kampong Speu natural palm sugar syrup.',
        priceUSD: 2.75,
        imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=500&q=80',
        category: 'Coffee',
        isAvailable: true,
      ),
      FoodMenuItem(
        id: 'dish-6',
        merchantId: 'rest-2',
        name: 'French Butter Croissant',
        khmerName: 'នំបុ័ងខ្វាសុងប៊័រ',
        description: 'Flaky, buttery multi-layered Parisian croissant baked golden fresh every morning.',
        priceUSD: 2.25,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&q=80',
        category: 'Bakery',
        isAvailable: true,
      ),
      FoodMenuItem(
        id: 'dish-7',
        merchantId: 'rest-2',
        name: 'Brown Signature Milk Tea with Boba',
        khmerName: 'តែទឹកដោះគោគុជប្រោន',
        description: 'Rich Ceylon black tea brewed with fresh milk and chewy brown sugar tapioca pearls.',
        priceUSD: 2.50,
        imageUrl: 'https://images.unsplash.com/photo-1558857563-b37cf5a22d25?w=500&q=80',
        category: 'Drinks',
        isAvailable: true,
      ),
      FoodMenuItem(
        id: 'dish-8',
        merchantId: 'rest-3',
        name: 'Double Wagyu Cheese Burger with Fries',
        khmerName: 'ប៊ឺហ្គឺសាច់គោបន្ទះពីរ ឈីស',
        description: 'Two smashed beef patties, melted cheddar, pickles, grilled onions and smoky house sauce with fries.',
        priceUSD: 6.50,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
        category: 'Burgers',
        isAvailable: true,
      ),
      FoodMenuItem(
        id: 'dish-9',
        merchantId: 'rest-3',
        name: 'Pepperoni & Mozzarella Pizza 10"',
        khmerName: 'ភីហ្សាភិបភើរ៉ូនី',
        description: 'Stone-baked thin crust pizza loaded with tomato marinara, Italian mozzarella, and spicy beef pepperoni.',
        priceUSD: 7.00,
        imageUrl: 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500&q=80',
        category: 'Pizza',
        isAvailable: true,
      ),
      FoodMenuItem(
        id: 'dish-10',
        merchantId: 'rest-3',
        name: 'Crispy Buffalo Chicken Wings (6 pcs)',
        khmerName: 'ស្លាបមាន់បំពងស្រួយ',
        description: 'Fried crunchy wings tossed in tangy hot sauce, served with blue cheese dip.',
        priceUSD: 4.00,
        imageUrl: 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&q=80',
        category: 'Appetizers',
        isAvailable: true,
      ),
    ]);

    // 3. Static Assigned Delivery Driver
    drivers.addAll([
      DeliveryDriver(
        id: 'DRV-001',
        name: 'Sokha Chea',
        khmerName: 'ជា សុខា',
        vehiclePlate: 'Phnom Penh 1AB-2345 (Honda Dream)',
        rating: 4.9,
      ),
    ]);

    // 4. Promo Vouchers
    vouchers.addAll([
      PromoVoucher(code: 'WELCOME5', discountPercent: 20, description: '20% off your first food order'),
      PromoVoucher(code: 'FREESHIP', discountPercent: 10, description: '10% discount to offset delivery fee'),
    ]);

    // 5. Initial Sample Orders
    orders.addAll([
      FoodOrder(
        id: 'ord-seed-1',
        orderNumber: 'ORD-98214',
        customerName: 'Bopha Pich (ពេជ្រ បុប្ផា)',
        customerPhone: '010 334 556',
        deliveryAddress: 'St 271, Boeng Tumpun, Phnom Penh',
        merchantId: 'rest-1',
        merchantName: 'Angkor Authentic Kitchen',
        items: [
          FoodCartItem(menuItem: menuItems[0], quantity: 2, specialNotes: 'Mild spicy, extra lime'),
          FoodCartItem(menuItem: menuItems[3], quantity: 2),
        ],
        subtotalUSD: 12.00,
        deliveryFeeUSD: 1.00,
        discountUSD: 1.20,
        totalUSD: 11.80,
        totalKHR: usdToKhr(11.80),
        paymentMethod: FoodPaymentMethod.paid,
        status: FoodOrderStatus.delivering,
        driverId: 'DRV-001',
        driverName: 'Sokha Chea',
        driverPlate: 'Phnom Penh 1AB-2345',
        orderTime: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      FoodOrder(
        id: 'ord-seed-2',
        orderNumber: 'ORD-98210',
        customerName: 'Dara Lim (លីម ដារ៉ា)',
        customerPhone: '012 345 678',
        deliveryAddress: 'Condo 12A, BKK1, Phnom Penh',
        merchantId: 'rest-2',
        merchantName: 'Phnom Penh Brown Coffee & Bakery',
        items: [
          FoodCartItem(menuItem: menuItems[4], quantity: 1),
          FoodCartItem(menuItem: menuItems[5], quantity: 2),
        ],
        subtotalUSD: 7.25,
        deliveryFeeUSD: 0.75,
        discountUSD: 0.0,
        totalUSD: 8.00,
        totalKHR: usdToKhr(8.00),
        paymentMethod: FoodPaymentMethod.payOnDelivery,
        status: FoodOrderStatus.pendingAcceptance,
        driverId: 'DRV-001',
        driverName: 'Sokha Chea',
        driverPlate: 'Phnom Penh 1AB-2345',
        orderTime: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ]);

    activeTrackingOrder = orders.first;

    // 6. Initial Saved Addresses
    savedAddresses.addAll([
      CustomerDeliveryAddress(id: '1', customerId: '1', label: 'Home', addressLine: 'House 42, St 271, Boeng Tumpun, Phnom Penh', isDefault: true),
      CustomerDeliveryAddress(id: '2', customerId: '1', label: 'Work', addressLine: 'Exchange Square, Floor 8, Daun Penh, Phnom Penh', isDefault: false),
      CustomerDeliveryAddress(id: '3', customerId: '1', label: 'Condo', addressLine: 'The Bridge, Unit 1804, Tonle Bassac, Phnom Penh', isDefault: false),
    ]);
  }
}
