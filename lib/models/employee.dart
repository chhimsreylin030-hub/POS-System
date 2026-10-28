// US-008, US-046, US-048

enum EmployeeRole {
  admin,
  manager,
  cashier,
  inventoryStaff,
}

class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final EmployeeRole role;
  final double monthlySalary;
  final bool isActive;
  final String pinCode;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.monthlySalary,
    this.isActive = true,
    this.pinCode = '1234',
  });

  String get roleDisplay {
    switch (role) {
      case EmployeeRole.admin:
        return 'System Admin';
      case EmployeeRole.manager:
        return 'Branch Manager';
      case EmployeeRole.cashier:
        return 'POS Cashier';
      case EmployeeRole.inventoryStaff:
        return 'Stock Keeper';
    }
  }

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    EmployeeRole? role,
    double? monthlySalary,
    bool? isActive,
    String? pinCode,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      isActive: isActive ?? this.isActive,
      pinCode: pinCode ?? this.pinCode,
    );
  }
}

class ShiftRecord {
  final String id;
  final String employeeName;
  final DateTime startTime;
  DateTime? endTime;
  final double openingFloat; // initial cash in drawer
  double totalCashSales;
  double totalDigitalSales;
  double? closingCashActual;
  String? notes;
  bool isClosed;

  ShiftRecord({
    required this.id,
    required this.employeeName,
    required this.startTime,
    this.endTime,
    required this.openingFloat,
    this.totalCashSales = 0.0,
    this.totalDigitalSales = 0.0,
    this.closingCashActual,
    this.notes,
    this.isClosed = false,
  });

  double get expectedCashInDrawer => openingFloat + totalCashSales;
  double get discrepancy => (closingCashActual ?? expectedCashInDrawer) - expectedCashInDrawer;
}

class PayrollEntry {
  final String employeeId;
  final String employeeName;
  final String role;
  final double baseSalary;
  final double bonus;
  final double deductions;
  final String monthYear;
  final bool isPaid;

  PayrollEntry({
    required this.employeeId,
    required this.employeeName,
    required this.role,
    required this.baseSalary,
    this.bonus = 0.0,
    this.deductions = 0.0,
    required this.monthYear,
    this.isPaid = false,
  });

  double get netSalary => baseSalary + bonus - deductions;
}
