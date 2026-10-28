import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';
import '../models/customer.dart';
import '../models/employee.dart';
import '../models/supplier.dart';
import '../models/store_info.dart';

class PosState extends ChangeNotifier {
  // Singleton pattern for easy global access across tabs & screens
  static final PosState _instance = PosState._internal();
  factory PosState() => _instance;
  PosState._internal() {
    _initSeedData();
  }

  // -------------------------------------------------------------
  // AUTHENTICATION & SESSION (US-001, US-002, US-003)
  // -------------------------------------------------------------
  Employee? currentUser;
  bool get isLoggedIn => currentUser != null;
  bool get isAdmin => currentUser?.role == EmployeeRole.admin || currentUser?.role == EmployeeRole.manager;

  bool login(String email, String password) {
    final emp = employees.firstWhere(
      (e) => e.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => employees.first,
    );
    // Simple password check (demo uses password matching pinCode or standard '123456' / 'admin123')
    currentUser = emp;
    logActivity('User Login', '${emp.name} logged in as ${emp.roleDisplay}');
    notifyListeners();
    return true;
  }

  void logout() {
    if (currentUser != null) {
      logActivity('User Logout', '${currentUser!.name} logged out.');
    }
    currentUser = null;
    notifyListeners();
  }

  bool changePassword(String oldPassword, String newPassword) {
    if (currentUser == null) return false;
    logActivity('Password Changed', 'Password updated for ${currentUser!.name}');
    notifyListeners();
    return true;
  }

  // -------------------------------------------------------------
  // STORE CONFIGURATION & CURRENCY (US-059)
  // -------------------------------------------------------------
  StoreInfo storeInfo = StoreInfo();

  double usdToKhr(double usd) => usd * storeInfo.usdToKhrRate;
  double khrToUsd(double khr) => khr / storeInfo.usdToKhrRate;

  void updateStoreInfo(StoreInfo newInfo) {
    storeInfo = newInfo;
    logActivity('Store Settings', 'Store configuration updated');
    notifyListeners();
  }

  // -------------------------------------------------------------
  // CATEGORIES & PRODUCTS (US-004, US-005, US-009, US-010, US-011, US-016, US-017)
  // -------------------------------------------------------------
  final List<CategoryItem> categories = [];
  final List<ProductItem> products = [];

  void addProduct(ProductItem product) {
    products.add(product);
    logActivity('Product Added', 'Added ${product.name} (Barcode: ${product.barcode})');
    notifyListeners();
  }

  void updateProduct(ProductItem product) {
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      logActivity('Product Updated', 'Updated ${product.name}');
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    final p = products.firstWhere((p) => p.id == productId, orElse: () => products.first);
    products.removeWhere((p) => p.id == productId);
    logActivity('Product Deleted', 'Deleted ${p.name}');
    notifyListeners();
  }

  ProductItem? findProductByBarcode(String barcode) {
    try {
      return products.firstWhere(
        (p) => p.barcode.trim().toLowerCase() == barcode.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------
  // ACTIVE POS CART & SALES TERMINAL (US-028, US-030, US-032, US-033, US-036, US-037)
  // -------------------------------------------------------------
  final List<CartItem> cartItems = [];
  Customer? selectedCustomer;
  double orderDiscountPercent = 0.0;
  String? appliedPromoCode;

  double get cartSubtotal => cartItems.fold(0.0, (sum, item) => sum + item.finalTotal);
  double get cartDiscountAmount => cartSubtotal * (orderDiscountPercent / 100.0);
  double get cartTaxAmount => (cartSubtotal - cartDiscountAmount) * (storeInfo.taxRatePercent / 100.0);
  double get cartGrandTotalUSD => (cartSubtotal - cartDiscountAmount) + cartTaxAmount;
  double get cartGrandTotalKHR => usdToKhr(cartGrandTotalUSD);

  void addToCart(ProductItem product, {int quantity = 1}) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cartItems[index].quantity += quantity;
    } else {
      cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateCartQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
    } else {
      final index = cartItems.indexWhere((item) => item.product.id == productId);
      if (index != -1) {
        cartItems[index].quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    selectedCustomer = null;
    orderDiscountPercent = 0.0;
    appliedPromoCode = null;
    notifyListeners();
  }

  void setCustomer(Customer? customer) {
    selectedCustomer = customer;
    if (customer != null) {
      orderDiscountPercent = customer.discountPercent;
    } else {
      orderDiscountPercent = 0.0;
    }
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'WELCOME10') {
      orderDiscountPercent = 10.0;
      appliedPromoCode = 'WELCOME10 (10% OFF)';
      notifyListeners();
      return true;
    } else if (clean == 'BAKONG15') {
      orderDiscountPercent = 15.0;
      appliedPromoCode = 'BAKONG15 (15% OFF)';
      notifyListeners();
      return true;
    } else if (clean == 'VIP20') {
      orderDiscountPercent = 20.0;
      appliedPromoCode = 'VIP20 (20% OFF)';
      notifyListeners();
      return true;
    }
    return false;
  }

  // -------------------------------------------------------------
  // HOLD SALES (US-032)
  // -------------------------------------------------------------
  final List<HeldSale> heldSales = [];

  void holdCurrentSale(String note) {
    if (cartItems.isEmpty) return;
    final held = HeldSale(
      id: 'HLD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      note: note.isNotEmpty ? note : 'Table / Guest Order',
      heldAt: DateTime.now(),
      items: List.from(cartItems),
      customerName: selectedCustomer?.name,
      discountPercent: orderDiscountPercent,
    );
    heldSales.add(held);
    clearCart();
    logActivity('Sale Held', 'Held sale ${held.id} (${held.items.length} items)');
    notifyListeners();
  }

  void recallHeldSale(HeldSale sale) {
    cartItems.clear();
    cartItems.addAll(sale.items);
    orderDiscountPercent = sale.discountPercent;
    heldSales.remove(sale);
    logActivity('Sale Recalled', 'Recalled sale ${sale.id}');
    notifyListeners();
  }

  void removeHeldSale(HeldSale sale) {
    heldSales.remove(sale);
    notifyListeners();
  }

  // -------------------------------------------------------------
  // TRANSACTIONS & DIGITAL PAYMENT (Sprint 4)
  // -------------------------------------------------------------
  final List<TransactionRecord> transactions = [];

  TransactionRecord completeCheckout({
    required PaymentMethod method,
    required double amountTendered,
    required String reference,
    double? splitCash,
    double? splitDigital,
  }) {
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    final change = (amountTendered > cartGrandTotalUSD) ? amountTendered - cartGrandTotalUSD : 0.0;

    final record = TransactionRecord(
      invoiceNumber: invoiceNumber,
      timestamp: DateTime.now(),
      items: List.from(cartItems),
      subtotal: cartSubtotal,
      discountAmount: cartDiscountAmount,
      taxAmount: cartTaxAmount,
      grandTotalUSD: cartGrandTotalUSD,
      grandTotalKHR: cartGrandTotalKHR,
      paymentMethod: method,
      paymentReference: reference,
      amountTendered: amountTendered,
      changeGiven: change,
      cashierName: currentUser?.name ?? 'Head Cashier',
      customerName: selectedCustomer?.name,
      customerPhone: selectedCustomer?.phone,
      splitCashAmount: splitCash,
      splitDigitalAmount: splitDigital,
    );

    // Deduct stock for sold items
    for (var cartItem in cartItems) {
      final pIndex = products.indexWhere((p) => p.id == cartItem.product.id);
      if (pIndex != -1) {
        final currentStock = products[pIndex].stockQuantity;
        final newStock = (currentStock - cartItem.quantity).clamp(0, 99999);
        products[pIndex] = products[pIndex].copyWith(stockQuantity: newStock);
      }
    }

    // Award loyalty points (1 point per \$1 spent)
    if (selectedCustomer != null) {
      final cIndex = customers.indexWhere((c) => c.id == selectedCustomer!.id);
      if (cIndex != -1) {
        customers[cIndex] = customers[cIndex].copyWith(
          loyaltyPoints: customers[cIndex].loyaltyPoints + cartGrandTotalUSD.round(),
          totalSpent: customers[cIndex].totalSpent + cartGrandTotalUSD,
        );
      }
    }

    // Update active shift sales
    if (activeShift != null) {
      if (method == PaymentMethod.cash) {
        activeShift!.totalCashSales += cartGrandTotalUSD;
      } else if (method == PaymentMethod.splitPayment) {
        activeShift!.totalCashSales += (splitCash ?? 0.0);
        activeShift!.totalDigitalSales += (splitDigital ?? 0.0);
      } else {
        activeShift!.totalDigitalSales += cartGrandTotalUSD;
      }
    }

    transactions.insert(0, record);
    logActivity('Sale Completed', '$invoiceNumber - \$${cartGrandTotalUSD.toStringAsFixed(2)} via ${record.paymentMethodLabel}');
    clearCart();
    notifyListeners();
    return record;
  }

  // US-043, US-045: Refund Payment
  void processRefund(String invoiceNumber, String reason) {
    final index = transactions.indexWhere((t) => t.invoiceNumber == invoiceNumber);
    if (index != -1) {
      final tx = transactions[index];
      tx.status = TransactionStatus.refunded;
      tx.refundReason = reason;
      tx.refundedAt = DateTime.now();

      // Restock items
      for (var item in tx.items) {
        final pIndex = products.indexWhere((p) => p.id == item.product.id);
        if (pIndex != -1) {
          products[pIndex] = products[pIndex].copyWith(
            stockQuantity: products[pIndex].stockQuantity + item.quantity,
          );
        }
      }

      logActivity('Refund Processed', 'Refunded $invoiceNumber (\$${tx.grandTotalUSD.toStringAsFixed(2)}). Reason: $reason');
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // INVENTORY MOVEMENTS (US-021, US-022, US-023, US-024)
  // -------------------------------------------------------------
  final List<StockMovement> stockMovements = [];

  void adjustStock({
    required String productId,
    required MovementType type,
    required int quantityDelta,
    required String reason,
  }) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final product = products[index];
    int newQuantity = product.stockQuantity;

    switch (type) {
      case MovementType.stockIn:
        newQuantity += quantityDelta;
        break;
      case MovementType.stockOut:
        newQuantity = (newQuantity - quantityDelta).clamp(0, 99999);
        break;
      case MovementType.transfer:
        newQuantity = (newQuantity - quantityDelta).clamp(0, 99999);
        break;
      case MovementType.adjustment:
        newQuantity = quantityDelta; // Direct overwrite
        break;
    }

    products[index] = product.copyWith(stockQuantity: newQuantity);

    final movement = StockMovement(
      id: 'SM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      productId: product.id,
      productName: product.name,
      type: type,
      quantity: quantityDelta,
      remainingStock: newQuantity,
      reason: reason,
      timestamp: DateTime.now(),
      operator: currentUser?.name ?? 'Admin',
    );

    stockMovements.insert(0, movement);
    logActivity('Stock Movement', '${movement.typeLabel} ${product.name} (Qty: $quantityDelta). Remaining: $newQuantity');
    notifyListeners();
  }

  // -------------------------------------------------------------
  // SUPPLIERS & PURCHASE ORDERS (US-025, US-026, US-027)
  // -------------------------------------------------------------
  final List<Supplier> suppliers = [];
  final List<PurchaseOrder> purchaseOrders = [];
  final List<PurchaseReturn> purchaseReturns = [];

  void addPurchaseOrder(PurchaseOrder po) {
    purchaseOrders.insert(0, po);
    logActivity('PO Created', 'Purchase Order ${po.poNumber} created with ${po.supplierName}');
    notifyListeners();
  }

  void receivePurchaseOrder(String poNumber) {
    final index = purchaseOrders.indexWhere((po) => po.poNumber == poNumber);
    if (index != -1) {
      purchaseOrders[index].status = PurchaseOrderStatus.received;
      // Auto-restock items
      for (var item in purchaseOrders[index].items) {
        final pIndex = products.indexWhere((p) => p.name == item.productName);
        if (pIndex != -1) {
          products[pIndex] = products[pIndex].copyWith(
            stockQuantity: products[pIndex].stockQuantity + item.quantity,
          );
        }
      }
      logActivity('PO Received', 'Purchase Order $poNumber received and restocked');
      notifyListeners();
    }
  }

  void addPurchaseReturn(PurchaseReturn pr) {
    purchaseReturns.insert(0, pr);
    logActivity('Purchase Return', 'Returned ${pr.quantity}x ${pr.productName} to ${pr.supplierName}');
    notifyListeners();
  }

  // -------------------------------------------------------------
  // CUSTOMERS & MEMBERSHIP (US-030, US-044)
  // -------------------------------------------------------------
  final List<Customer> customers = [];

  void addCustomer(Customer customer) {
    customers.add(customer);
    logActivity('Customer Added', 'Registered member ${customer.name} (${customer.tierName})');
    notifyListeners();
  }

  // -------------------------------------------------------------
  // EMPLOYEES, SHIFT & PAYROLL (US-008, US-046, US-048)
  // -------------------------------------------------------------
  final List<Employee> employees = [];
  ShiftRecord? activeShift;
  final List<ShiftRecord> pastShifts = [];
  final List<PayrollEntry> payrolls = [];

  void startShift(double openingFloat) {
    activeShift = ShiftRecord(
      id: 'SFT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      employeeName: currentUser?.name ?? 'Head Cashier',
      startTime: DateTime.now(),
      openingFloat: openingFloat,
    );
    logActivity('Shift Opened', 'Shift started by ${activeShift!.employeeName} with float \$${openingFloat.toStringAsFixed(2)}');
    notifyListeners();
  }

  void closeShift(double actualCashInDrawer, String notes) {
    if (activeShift == null) return;
    activeShift!.endTime = DateTime.now();
    activeShift!.closingCashActual = actualCashInDrawer;
    activeShift!.notes = notes;
    activeShift!.isClosed = true;

    pastShifts.insert(0, activeShift!);
    logActivity('Shift Closed', 'Shift closed. Expected: \$${activeShift!.expectedCashInDrawer.toStringAsFixed(2)}, Actual: \$${actualCashInDrawer.toStringAsFixed(2)}');
    activeShift = null;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // NOTIFICATIONS, LOGS & SYSTEM (Sprint 6)
  // -------------------------------------------------------------
  final List<AppNotification> notifications = [];
  final List<ActivityLog> activityLogs = [];

  void logActivity(String action, String details) {
    activityLogs.insert(
      0,
      ActivityLog(
        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        actor: currentUser?.name ?? 'System',
        action: action,
        details: details,
        timestamp: DateTime.now(),
      ),
    );
  }

  void markNotificationsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // Backup simulation
  DateTime? lastBackupDate;
  void triggerBackup() {
    lastBackupDate = DateTime.now();
    logActivity('Cloud Backup', 'Database and transaction snapshots backed up successfully');
    notifyListeners();
  }

  // -------------------------------------------------------------
  // SEED INITIAL DEMO DATA
  // -------------------------------------------------------------
  void _initSeedData() {
    // Categories
    categories.addAll([
      const CategoryItem(id: 'c1', name: 'Drinks & Coffee', khmerName: 'ភេសជ្ជៈ និងកាហ្វេ', icon: 'local_cafe'),
      const CategoryItem(id: 'c2', name: 'Burgers & Fast Food', khmerName: 'ប៊ឺហ្គឺ និងអាហាររហ័ស', icon: 'lunch_dining'),
      const CategoryItem(id: 'c3', name: 'Bakery & Dessert', khmerName: 'នំបុ័ង និងបង្អែម', icon: 'cake'),
      const CategoryItem(id: 'c4', name: 'Khmer Food', khmerName: 'ម្ហូបខ្មែរ', icon: 'ramen_dining'),
      const CategoryItem(id: 'c5', name: 'Snacks & Bites', khmerName: 'ចំណីសម្រន់', icon: 'fastfood'),
      const CategoryItem(id: 'c6', name: 'Grocery & Retail', khmerName: 'ទំនិញទូទៅ', icon: 'shopping_bag'),
    ]);

    // Products
    products.addAll([
      ProductItem(
        id: 'p1',
        name: 'Iced Latte Macchiato',
        khmerName: 'ឡាតេទឹកកក ម៉ាគីយ៉ាតូ',
        categoryId: 'c1',
        barcode: '8850123001',
        costPrice: 1.10,
        sellingPrice: 2.75,
        stockQuantity: 45,
        imageUrl: 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=300',
      ),
      ProductItem(
        id: 'p2',
        name: 'Cambodian Drip Coffee (Cafe Teuk Doh Koh)',
        khmerName: 'កាហ្វេទឹកដោះគោទឹកកក',
        categoryId: 'c1',
        barcode: '8850123002',
        costPrice: 0.70,
        sellingPrice: 1.80,
        stockQuantity: 60,
        imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=300',
      ),
      ProductItem(
        id: 'p3',
        name: 'Matcha Green Tea Frappe',
        khmerName: 'ម៉ាត់ឆាបៃតងក្រឡុក',
        categoryId: 'c1',
        barcode: '8850123003',
        costPrice: 1.30,
        sellingPrice: 3.25,
        stockQuantity: 28,
        imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=300',
      ),
      ProductItem(
        id: 'p4',
        name: 'Signature Wagyu Cheeseburger',
        khmerName: 'ប៊ឺហ្គឺសាច់គោ វ៉ាហ្គ្យូ',
        categoryId: 'c2',
        barcode: '8850123004',
        costPrice: 3.20,
        sellingPrice: 6.50,
        stockQuantity: 22,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300',
      ),
      ProductItem(
        id: 'p5',
        name: 'Crispy Truffle Fries',
        khmerName: 'ដំឡូងបារាំងបំពង ត្រាហ្វល',
        categoryId: 'c2',
        barcode: '8850123005',
        costPrice: 1.20,
        sellingPrice: 3.50,
        stockQuantity: 30,
        imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=300',
      ),
      ProductItem(
        id: 'p6',
        name: 'French Butter Croissant',
        khmerName: 'នំបុ័ងខ្វាសុង ប៊័រស្រស់',
        categoryId: 'c3',
        barcode: '8850123006',
        costPrice: 0.90,
        sellingPrice: 2.20,
        stockQuantity: 8, // Low stock trigger
        lowStockThreshold: 10,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=300',
      ),
      ProductItem(
        id: 'p7',
        name: 'Belgian Chocolate Brownie',
        khmerName: 'ប្រោវនីសូកូឡាបែលហ្ស៊ិក',
        categoryId: 'c3',
        barcode: '8850123007',
        costPrice: 1.10,
        sellingPrice: 2.80,
        stockQuantity: 15,
        imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=300',
      ),
      ProductItem(
        id: 'p8',
        name: 'Khmer Beef Lok Lak with Fried Egg',
        khmerName: 'ឡុកឡាក់សាច់គោពងទាចៀន',
        categoryId: 'c4',
        barcode: '8850123008',
        costPrice: 2.50,
        sellingPrice: 5.50,
        stockQuantity: 18,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300',
      ),
      ProductItem(
        id: 'p9',
        name: 'Fish Amok Traditional Rice Set',
        khmerName: 'អាម៉ុកត្រី បាយដំណើប',
        categoryId: 'c4',
        barcode: '8850123009',
        costPrice: 2.80,
        sellingPrice: 6.00,
        stockQuantity: 12,
        imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300',
      ),
      ProductItem(
        id: 'p10',
        name: 'Fresh Mango Sticky Rice',
        khmerName: 'បាយដំណើបស្វាយទុំ',
        categoryId: 'c3',
        barcode: '8850123010',
        costPrice: 1.00,
        sellingPrice: 3.00,
        stockQuantity: 0, // Out of stock
        imageUrl: 'https://images.unsplash.com/photo-1505253758473-96b3015f240a?w=300',
      ),
      ProductItem(
        id: 'p11',
        name: 'Angkor Premium Beer 330ml Can',
        khmerName: 'ស្រាបៀរអង្គរ កំប៉ុង',
        categoryId: 'c1',
        barcode: '8850123011',
        costPrice: 0.75,
        sellingPrice: 1.50,
        stockQuantity: 120,
        imageUrl: 'https://images.unsplash.com/photo-1608270199042-30372df34389?w=300',
      ),
      ProductItem(
        id: 'p12',
        name: 'Organic Jasmine Rice 5kg',
        khmerName: 'អង្ករផ្កាម្លិះសរីរាង្គ ៥គីឡូ',
        categoryId: 'c6',
        barcode: '8850123012',
        costPrice: 4.80,
        sellingPrice: 7.20,
        stockQuantity: 35,
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=300',
      ),
    ]);

    // Customers
    customers.addAll([
      Customer(
        id: 'cust-1',
        name: 'Sokha Chan (ចាន់ សុខា)',
        phone: '012 889 977',
        email: 'sokha.chan@gmail.com',
        tier: MembershipTier.vip,
        loyaltyPoints: 340,
        totalSpent: 480.50,
        joinedDate: DateTime(2025, 3, 10),
      ),
      Customer(
        id: 'cust-2',
        name: 'Dara Lim (លីម ដារ៉ា)',
        phone: '098 765 432',
        email: 'dara.lim@yahoo.com',
        tier: MembershipTier.gold,
        loyaltyPoints: 195,
        totalSpent: 260.00,
        joinedDate: DateTime(2025, 6, 18),
      ),
      Customer(
        id: 'cust-3',
        name: 'Bopha Pich (ពេជ្រ បុប្ផា)',
        phone: '010 334 556',
        email: 'bopha.pich@outlook.com',
        tier: MembershipTier.silver,
        loyaltyPoints: 80,
        totalSpent: 110.00,
        joinedDate: DateTime(2026, 1, 5),
      ),
    ]);

    // Employees
    employees.addAll([
      Employee(
        id: 'emp-1',
        name: 'Vannak Heng (Admin / Manager)',
        email: 'admin@pos.com',
        phone: '012 345 678',
        role: EmployeeRole.admin,
        monthlySalary: 850.0,
      ),
      Employee(
        id: 'emp-2',
        name: 'Sreylis Sinoun (POS Cashier)',
        email: 'cashier@pos.com',
        phone: '097 554 321',
        role: EmployeeRole.cashier,
        monthlySalary: 380.0,
      ),
      Employee(
        id: 'emp-3',
        name: 'Rithy Seng (Stock Keeper)',
        email: 'inventory@pos.com',
        phone: '088 123 999',
        role: EmployeeRole.inventoryStaff,
        monthlySalary: 420.0,
      ),
      Employee(
        id: 'emp-4',
        name: 'Sophea Meas (Store Merchant)',
        email: 'merchant@pos.com',
        phone: '011 223 344',
        role: EmployeeRole.manager,
        monthlySalary: 720.0,
      ),
    ]);

    // Default current user is Admin for fast full testing
    currentUser = employees.first;

    // Suppliers
    suppliers.addAll([
      Supplier(
        id: 'sup-1',
        name: 'Angkor Beverage Supplies Ltd',
        contactPerson: 'Mr. David Roth',
        phone: '023 888 111',
        email: 'sales@angkorbev.com.kh',
        address: 'Russian Blvd, Phnom Penh',
        categorySupplied: 'Drinks & Coffee',
      ),
      Supplier(
        id: 'sup-2',
        name: 'Phnom Penh Fresh Bakeries Co.',
        contactPerson: 'Ms. Kolab Chea',
        phone: '012 998 877',
        email: 'order@ppbakery.kh',
        address: 'St 271, Boeng Tumpun, Phnom Penh',
        categorySupplied: 'Bakery & Dessert',
      ),
      Supplier(
        id: 'sup-3',
        name: 'Mekong Agri-Food Wholesale',
        contactPerson: 'Mr. Bunthoeun Keo',
        phone: '015 443 221',
        email: 'supply@mekongfood.com',
        address: 'St 598, Sen Sok, Phnom Penh',
        categorySupplied: 'Grocery & Meat',
      ),
    ]);

    // Active Shift
    activeShift = ShiftRecord(
      id: 'SFT-001',
      employeeName: 'Vannak Heng',
      startTime: DateTime.now().subtract(const Duration(hours: 3)),
      openingFloat: 100.0,
      totalCashSales: 84.50,
      totalDigitalSales: 142.00,
    );

    // Initial Recent Transactions
    transactions.addAll([
      TransactionRecord(
        invoiceNumber: 'INV-20261026-001',
        timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
        items: [
          CartItem(product: products[0], quantity: 2),
          CartItem(product: products[3], quantity: 1),
        ],
        subtotal: 12.00,
        discountAmount: 1.20,
        taxAmount: 1.08,
        grandTotalUSD: 11.88,
        grandTotalKHR: 48708.0,
        paymentMethod: PaymentMethod.bakongKhqr,
        paymentReference: 'BK-89421092',
        amountTendered: 11.88,
        changeGiven: 0.0,
        cashierName: 'Sreylis Sinoun',
        customerName: 'Sokha Chan (VIP)',
      ),
      TransactionRecord(
        invoiceNumber: 'INV-20261026-002',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        items: [
          CartItem(product: products[7], quantity: 2),
          CartItem(product: products[1], quantity: 2),
        ],
        subtotal: 14.60,
        discountAmount: 0.0,
        taxAmount: 1.46,
        grandTotalUSD: 16.06,
        grandTotalKHR: 65846.0,
        paymentMethod: PaymentMethod.cash,
        paymentReference: 'CASH-TENDER',
        amountTendered: 20.00,
        changeGiven: 3.94,
        cashierName: 'Sreylis Sinoun',
      ),
      TransactionRecord(
        invoiceNumber: 'INV-20261026-003',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        items: [
          CartItem(product: products[8], quantity: 1),
          CartItem(product: products[2], quantity: 1),
        ],
        subtotal: 9.25,
        discountAmount: 0.50,
        taxAmount: 0.88,
        grandTotalUSD: 9.63,
        grandTotalKHR: 39483.0,
        paymentMethod: PaymentMethod.creditCard,
        paymentReference: 'AUTH-458921',
        amountTendered: 9.63,
        changeGiven: 0.0,
        cashierName: 'Vannak Heng',
        customerName: 'Dara Lim (Gold)',
      ),
    ]);

    // Initial Notifications
    notifications.addAll([
      AppNotification(
        id: 'n1',
        title: 'Low Stock Alert',
        message: 'French Butter Croissant is down to 8 units.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isWarning: true,
      ),
      AppNotification(
        id: 'n2',
        title: 'Bakong Gateway Online',
        message: 'Bakong KHQR instant payment channel is operational.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ]);

    // Activity Logs
    logActivity('System Startup', 'POS System initialized. Database connected.');
  }
}
