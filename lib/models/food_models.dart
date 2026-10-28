enum FoodOrderStatus {
  pendingAcceptance,
  delivering,
  delivered,
  cancelled,
}

enum FoodPaymentMethod {
  payOnDelivery,
  paid,
}

class MerchantAccount {
  final String id;
  final String accountName;
  final String email;
  final String phone;
  final String companyRegNumber;
  final String status;
  final int restaurantsCount;

  MerchantAccount({
    required this.id,
    required this.accountName,
    required this.email,
    required this.phone,
    required this.companyRegNumber,
    this.status = 'ACTIVE',
    this.restaurantsCount = 2,
  });
}

class RestaurantMerchant {
  final String id;
  final String accountId;
  String name;
  String khmerName;
  String cuisine;
  String bannerUrl;
  String logoUrl;
  double rating;
  int deliveryTimeMin;
  double deliveryFeeUSD;
  bool isOpen;
  String address;
  String phone;
  double totalSalesUSD;

  RestaurantMerchant({
    required this.id,
    this.accountId = '1',
    required this.name,
    required this.khmerName,
    required this.cuisine,
    required this.bannerUrl,
    required this.logoUrl,
    this.rating = 4.8,
    this.deliveryTimeMin = 25,
    this.deliveryFeeUSD = 1.00,
    this.isOpen = true,
    required this.address,
    required this.phone,
    this.totalSalesUSD = 0.0,
  });
}

class FoodMenuItem {
  final String id;
  final String merchantId;
  String name;
  String khmerName;
  String description;
  double priceUSD;
  String imageUrl;
  String category;
  bool isAvailable;

  FoodMenuItem({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.khmerName,
    required this.description,
    required this.priceUSD,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
  });

  FoodMenuItem copyWith({
    String? id,
    String? merchantId,
    String? name,
    String? khmerName,
    String? description,
    double? priceUSD,
    String? imageUrl,
    String? category,
    bool? isAvailable,
  }) {
    return FoodMenuItem(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      khmerName: khmerName ?? this.khmerName,
      description: description ?? this.description,
      priceUSD: priceUSD ?? this.priceUSD,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class FoodCartItem {
  final FoodMenuItem menuItem;
  int quantity;
  String specialNotes;

  FoodCartItem({
    required this.menuItem,
    this.quantity = 1,
    this.specialNotes = '',
  });

  double get totalUSD => menuItem.priceUSD * quantity;
}

class FoodOrder {
  String id;
  String orderNumber;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String merchantId;
  final String merchantName;
  final List<FoodCartItem> items;
  final double subtotalUSD;
  final double deliveryFeeUSD;
  final double discountUSD;
  final double totalUSD;
  final double totalKHR;
  final FoodPaymentMethod paymentMethod;
  FoodOrderStatus status;
  String driverId;
  String driverName;
  String driverPlate;
  final DateTime orderTime;

  FoodOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.merchantId,
    required this.merchantName,
    required this.items,
    required this.subtotalUSD,
    required this.deliveryFeeUSD,
    required this.discountUSD,
    required this.totalUSD,
    required this.totalKHR,
    required this.paymentMethod,
    this.status = FoodOrderStatus.pendingAcceptance,
    this.driverId = 'DRV-001',
    this.driverName = 'Sokha Chea (ជា សុខា)',
    this.driverPlate = 'Phnom Penh 1AB-2345 (Honda Dream)',
    required this.orderTime,
  });

  String get statusDisplay {
    switch (status) {
      case FoodOrderStatus.pendingAcceptance:
        return 'Order Placed';
      case FoodOrderStatus.delivering:
        return 'Delivering';
      case FoodOrderStatus.delivered:
        return 'Delivered';
      case FoodOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get paymentDisplay {
    switch (paymentMethod) {
      case FoodPaymentMethod.payOnDelivery:
        return 'Pay on Delivery';
      case FoodPaymentMethod.paid:
        return 'Paid';
    }
  }
}

class DeliveryDriver {
  final String id;
  final String name;
  final String khmerName;
  final String vehiclePlate;
  final double rating;
  final String phone;
  final String photoUrl;
  final int totalDeliveriesToday;
  final double earningsUSD;

  DeliveryDriver({
    required this.id,
    required this.name,
    required this.khmerName,
    required this.vehiclePlate,
    this.rating = 4.9,
    this.phone = '+855 12 889 001',
    this.photoUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=60',
    this.totalDeliveriesToday = 14,
    this.earningsUSD = 28.50,
  });
}

class PromoVoucher {
  final String code;
  final double discountPercent;
  final String description;
  final double minSpendUSD;

  PromoVoucher({
    required this.code,
    required this.discountPercent,
    required this.description,
    this.minSpendUSD = 0.0,
  });
}

class CustomerDeliveryAddress {
  final String id;
  final String customerId;
  String label; // e.g. "Home", "Work", "Condo", "Other"
  String addressLine;
  String city;
  bool isDefault;

  CustomerDeliveryAddress({
    required this.id,
    required this.customerId,
    required this.label,
    required this.addressLine,
    this.city = 'Phnom Penh',
    this.isDefault = false,
  });

  factory CustomerDeliveryAddress.fromJson(Map<String, dynamic> json) {
    return CustomerDeliveryAddress(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '1',
      label: json['label'] ?? 'Home',
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? 'Phnom Penh',
      isDefault: json['isDefault'] == true || json['isDefault'] == 1 || json['isDefault'] == '1',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'label': label,
    'addressLine': addressLine,
    'city': city,
    'isDefault': isDefault,
  };
}
