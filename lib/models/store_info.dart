// US-054, US-055, US-056, US-057, US-058, US-059, US-061

class StoreInfo {
  String storeName;
  String khmerStoreName;
  String branchName;
  String phone;
  String address;
  String vatTin;
  double usdToKhrRate; // Standard 4,100 KHR per USD
  double taxRatePercent; // e.g. 10.0%
  String wifiPassword;

  StoreInfo({
    this.storeName = 'SMART POS & DIGITAL PAY',
    this.khmerStoreName = 'ស្មាត ភីអូអេស និងការទូទាត់ឌីជីថល',
    this.branchName = 'Toul Kork Branch, Phnom Penh',
    this.phone = '+855 23 999 888 / 012 345 678',
    this.address = '#128, St 315, Sangkat Boeng Kak 1, Khan Toul Kork, Phnom Penh',
    this.vatTin = 'K002-902341882',
    this.usdToKhrRate = 4100.0,
    this.taxRatePercent = 10.0,
    this.wifiPassword = 'posguestpass@2026',
  });
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isWarning;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isWarning = false,
    this.isRead = false,
  });
}

class ActivityLog {
  final String id;
  final String actor;
  final String action;
  final String details;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.actor,
    required this.action,
    required this.details,
    required this.timestamp,
  });
}
