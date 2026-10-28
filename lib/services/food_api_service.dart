import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/food_models.dart';

class FoodApiService {
  static String get baseUrl {
    const custom = String.fromEnvironment('API_BASE_URL');
    if (custom.isNotEmpty) return custom;

    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return 'http://$host:8081/api';
    }
    // Android Emulator host loopback address
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8081/api';
    }
    return 'http://127.0.0.1:8081/api';
  }

  // --------------------------------------------------------------------------
  // Check MySQL Health
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // --------------------------------------------------------------------------
  // Fetch Merchants from MySQL
  // --------------------------------------------------------------------------
  static Future<List<RestaurantMerchant>> getMerchants() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/merchants')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final List data = decoded['data'] ?? [];
        return data.map((json) {
          return RestaurantMerchant(
            id: json['id'].toString(),
            accountId: json['accountId']?.toString() ?? '1',
            name: json['name'] ?? '',
            khmerName: json['khmerName'] ?? '',
            cuisine: json['cuisine'] ?? 'Cambodian Gourmet',
            bannerUrl: json['bannerUrl'] ?? '',
            logoUrl: json['logoUrl'] ?? '',
            rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
            deliveryTimeMin: (json['deliveryTimeMin'] as num?)?.toInt() ?? 25,
            deliveryFeeUSD: (json['deliveryFeeUSD'] as num?)?.toDouble() ?? 1.0,
            isOpen: json['isOpen'] == true,
            address: json['address'] ?? '',
            phone: json['phone'] ?? '',
            totalSalesUSD: (json['totalSalesUSD'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  // --------------------------------------------------------------------------
  // Fetch Menu Items from MySQL
  // --------------------------------------------------------------------------
  static Future<List<FoodMenuItem>> getMenuItems({String? merchantId}) async {
    try {
      var url = '$baseUrl/menu-items';
      if (merchantId != null && merchantId.isNotEmpty) {
        url += '?merchant_id=$merchantId';
      }
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final List data = decoded['data'] ?? [];
        return data.map((json) {
          return FoodMenuItem(
            id: json['id'].toString(),
            merchantId: json['merchantId'].toString(),
            name: json['name'] ?? '',
            khmerName: json['khmerName'] ?? '',
            description: json['description'] ?? '',
            priceUSD: (json['priceUSD'] as num?)?.toDouble() ?? 3.5,
            imageUrl: json['imageUrl'] ?? '',
            category: json['category'] ?? 'Khmer Food',
            isAvailable: json['isAvailable'] == true,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  // --------------------------------------------------------------------------
  // Save New Menu Item to MySQL (Merchant)
  // --------------------------------------------------------------------------
  static Future<String?> addMenuItem(FoodMenuItem item) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/menu-items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'merchantId': item.merchantId,
          'name': item.name,
          'khmerName': item.khmerName,
          'description': item.description,
          'priceUSD': item.priceUSD,
          'imageUrl': item.imageUrl,
          'category': item.category,
          'isAvailable': item.isAvailable,
        }),
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        return decoded['id']?.toString();
      }
    } catch (_) {}
    return null;
  }

  // --------------------------------------------------------------------------
  // Update Menu Item in MySQL (Merchant)
  // --------------------------------------------------------------------------
  static Future<bool> updateMenuItem(FoodMenuItem item) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/menu-items/${item.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': item.name,
          'khmerName': item.khmerName,
          'description': item.description,
          'priceUSD': item.priceUSD,
          'imageUrl': item.imageUrl,
          'category': item.category,
          'isAvailable': item.isAvailable,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // --------------------------------------------------------------------------
  // Delete Menu Item from MySQL (Merchant)
  // --------------------------------------------------------------------------
  static Future<bool> deleteMenuItem(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/menu-items/$id'));
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // --------------------------------------------------------------------------
  // Fetch Orders from MySQL
  // --------------------------------------------------------------------------
  static Future<List<FoodOrder>> getOrders({String? merchantId}) async {
    try {
      var url = '$baseUrl/orders';
      if (merchantId != null && merchantId.isNotEmpty) {
        url += '?merchant_id=$merchantId';
      }
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final List data = decoded['data'] ?? [];
        return data.map((json) {
          final List rawItems = json['items'] ?? [];
          final items = rawItems.map((i) {
            return FoodCartItem(
              menuItem: FoodMenuItem(
                id: i['menuItemId']?.toString() ?? '1',
                merchantId: json['merchantId']?.toString() ?? '1',
                name: i['name'] ?? '',
                khmerName: i['name'] ?? '',
                description: '',
                priceUSD: (i['priceUSD'] as num?)?.toDouble() ?? 0.0,
                imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
                category: 'Dishes',
              ),
              quantity: (i['quantity'] as num?)?.toInt() ?? 1,
              specialNotes: i['specialNotes'] ?? '',
            );
          }).toList();

          FoodOrderStatus parseStatus(String? s) {
            switch (s?.toLowerCase()) {
              case 'delivering':
                return FoodOrderStatus.delivering;
              case 'delivered':
              case 'completed':
                return FoodOrderStatus.delivered;
              case 'cancelled':
              case 'refunded':
                return FoodOrderStatus.cancelled;
              default:
                return FoodOrderStatus.pendingAcceptance;
            }
          }

          final totalUSD = (json['totalUSD'] as num?)?.toDouble() ?? 0.0;
          return FoodOrder(
            id: json['id'].toString(),
            orderNumber: json['orderNumber'] ?? 'ORD-000',
            customerName: json['customerName'] ?? 'Customer',
            customerPhone: json['customerPhone'] ?? '',
            deliveryAddress: json['deliveryAddress'] ?? 'Phnom Penh',
            merchantId: json['merchantId']?.toString() ?? '1',
            merchantName: json['merchantName'] ?? 'Restaurant',
            items: items,
            subtotalUSD: (json['subtotalUSD'] as num?)?.toDouble() ?? totalUSD,
            deliveryFeeUSD: 1.0,
            discountUSD: 0.0,
            totalUSD: totalUSD,
            totalKHR: totalUSD * 4100.0,
            paymentMethod: json['paymentMethod'] == 'paid' ? FoodPaymentMethod.paid : FoodPaymentMethod.payOnDelivery,
            status: parseStatus(json['status']),
            orderTime: DateTime.tryParse(json['orderTime'] ?? '') ?? DateTime.now(),
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  // --------------------------------------------------------------------------
  // Place Order in MySQL (Customer)
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> placeOrder(FoodOrder order) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderNumber': order.orderNumber,
          'merchantId': order.merchantId,
          'merchantName': order.merchantName,
          'customerName': order.customerName,
          'customerPhone': order.customerPhone,
          'deliveryAddress': order.deliveryAddress,
          'subtotalUSD': order.subtotalUSD,
          'deliveryFeeUSD': order.deliveryFeeUSD,
          'totalUSD': order.totalUSD,
          'paymentMethod': order.paymentMethod == FoodPaymentMethod.paid ? 'paid' : 'payOnDelivery',
          'items': order.items.map((i) => {
            'menuItemId': i.menuItem.id,
            'name': i.menuItem.name,
            'priceUSD': i.menuItem.priceUSD,
            'quantity': i.quantity,
            'specialNotes': i.specialNotes,
          }).toList(),
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}
    return null;
  }

  // --------------------------------------------------------------------------
  // Update Order Status in MySQL (Merchant)
  // --------------------------------------------------------------------------
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // --------------------------------------------------------------------------
  // Customer Authentication: Register (Saved to pos_db.customers)
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'address': address,
        }),
      );
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>?;
    } catch (_) {}
    return null;
  }

  // --------------------------------------------------------------------------
  // Customer Authentication: Login (pos_db.customers)
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> loginCustomer({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
        }),
      );
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>?;
    } catch (_) {}
    return null;
  }

  // --------------------------------------------------------------------------
  // Update Customer Profile (pos_db.customers)
  // --------------------------------------------------------------------------
  static Future<bool> updateCustomerProfile({
    required String id,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'name': name,
          'phone': phone,
          'address': address,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // --------------------------------------------------------------------------
  // Fetch Saved Customer Addresses (pos_db.customer_addresses)
  // --------------------------------------------------------------------------
  static Future<List<CustomerDeliveryAddress>> getCustomerAddresses(String customerId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/customer-addresses?customer_id=$customerId')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final List data = decoded['data'] ?? [];
        return data.map((json) => CustomerDeliveryAddress.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  // --------------------------------------------------------------------------
  // Add Saved Customer Address (pos_db.customer_addresses)
  // --------------------------------------------------------------------------
  static Future<String?> addCustomerAddress(CustomerDeliveryAddress address) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/customer-addresses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(address.toJson()),
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        return decoded['id']?.toString();
      }
    } catch (_) {}
    return null;
  }

  // --------------------------------------------------------------------------
  // Update Customer Address (pos_db.customer_addresses)
  // --------------------------------------------------------------------------
  static Future<bool> updateCustomerAddress(CustomerDeliveryAddress address) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/customer-addresses/${address.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(address.toJson()),
      );
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // --------------------------------------------------------------------------
  // Delete Customer Address (pos_db.customer_addresses)
  // --------------------------------------------------------------------------
  static Future<bool> deleteCustomerAddress(String addressId) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/customer-addresses/$addressId'));
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // --------------------------------------------------------------------------
  // Fetch Merchant Corporate Accounts (pos_db.merchant_accounts)
  // --------------------------------------------------------------------------
  static Future<List<MerchantAccount>> getMerchantAccounts() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/merchant-accounts')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final List data = decoded['data'] ?? [];
        return data.map((json) {
          return MerchantAccount(
            id: json['id'].toString(),
            accountName: json['accountName'] ?? '',
            email: json['email'] ?? '',
            phone: json['phone'] ?? '',
            companyRegNumber: json['companyRegNumber'] ?? '',
            status: json['status'] ?? 'ACTIVE',
            restaurantsCount: (json['restaurantsCount'] as num?)?.toInt() ?? 2,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  // --------------------------------------------------------------------------
  // Merchant Account Authentication: Login (pos_db.merchant_accounts)
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> loginMerchantAccount({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/merchant-auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
        }),
      );
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>?;
    } catch (_) {}
    return null;
  }

  // --------------------------------------------------------------------------
  // Merchant Account Authentication: Register (pos_db.merchant_accounts)
  // --------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> registerMerchantAccount({
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
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/merchant-auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accountName': accountName,
          'email': email,
          'phone': phone,
          'password': password,
          'companyRegNumber': companyRegNumber,
          'restaurantName': restaurantName,
          'khmerName': khmerName,
          'cuisine': cuisine,
          'address': address,
        }),
      );
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>?;
    } catch (_) {}
    return null;
  }

  // --------------------------------------------------------------------------
  // Fetch Promo Vouchers (pos_db.vouchers)
  // --------------------------------------------------------------------------
  static Future<List<PromoVoucher>> getVouchers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/vouchers')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final List data = decoded['data'] ?? [];
        return data.map((json) {
          return PromoVoucher(
            code: json['code'] ?? '',
            discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 10.0,
            description: json['description'] ?? '',
            minSpendUSD: (json['minSpendUSD'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  // --------------------------------------------------------------------------
  // Fetch Delivery Drivers (pos_db.delivery_drivers)
  // --------------------------------------------------------------------------
  static Future<List<DeliveryDriver>> getDrivers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/drivers')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final List data = decoded['data'] ?? [];
        return data.map((json) {
          return DeliveryDriver(
            id: json['code'] ?? json['id'].toString(),
            name: json['name'] ?? '',
            khmerName: json['khmerName'] ?? '',
            vehiclePlate: '${json['vehicleType']} • ${json['vehiclePlate']}',
            rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
            phone: json['phone'] ?? '',
            photoUrl: json['photoUrl'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }
}
