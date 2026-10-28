// US-030, US-044, US-047

enum MembershipTier {
  regular,
  silver,
  gold,
  vip,
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final MembershipTier tier;
  final int loyaltyPoints;
  final double totalSpent;
  final DateTime joinedDate;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.tier = MembershipTier.regular,
    this.loyaltyPoints = 0,
    this.totalSpent = 0.0,
    required this.joinedDate,
  });

  double get discountPercent {
    switch (tier) {
      case MembershipTier.regular:
        return 0.0;
      case MembershipTier.silver:
        return 5.0; // 5% off
      case MembershipTier.gold:
        return 10.0; // 10% off
      case MembershipTier.vip:
        return 15.0; // 15% off
    }
  }

  String get tierName {
    switch (tier) {
      case MembershipTier.regular:
        return 'Standard';
      case MembershipTier.silver:
        return 'Silver (5% off)';
      case MembershipTier.gold:
        return 'Gold (10% off)';
      case MembershipTier.vip:
        return 'VIP (15% off)';
    }
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    MembershipTier? tier,
    int? loyaltyPoints,
    double? totalSpent,
    DateTime? joinedDate,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      tier: tier ?? this.tier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalSpent: totalSpent ?? this.totalSpent,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}
