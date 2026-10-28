# POS with Digital Payment System (SmartPOS)
> **Modern Flutter Retail POS & Web Admin Management System** with support for Cambodia's National Bank Bakong KHQR, Credit/Debit Cards, Cash (USD & KHR Dual Currency), Inventory Control, and Executive Reporting.

---

## 🚀 Quick Start & Demo Credentials

When launching the app, you can use the **1-Click Quick Demo Login** buttons on the Login screen:

| Role | Email | Password | Access Level |
|---|---|---|---|
| **System Admin / Manager** | `admin@pos.com` | `admin123` | Full Admin Web Dashboard & POS Terminal |
| **POS Cashier** | `cashier@pos.com` | `cashier123` | Direct Sales POS Terminal, Hold Sale, Receipt |
| **Inventory Staff** | `inventory@pos.com` | `staff123` | Stock Management & Supplier Orders |

To run the app:
```bash
flutter pub get
flutter run -d chrome     # Run as Web Admin Site
# OR
flutter run -d windows    # Run as Desktop POS Terminal
# OR
flutter run -d android    # Run on Android Tablet / Phone
```

---

## 📋 Complete User Stories & Sprints Implementation Matrix

### **Sprint 1: System Setup (Week 1–2)**
- **US-001 (Login)**: Multi-role authentication (Admin, Cashier, Stock Keeper) with 1-click test presets.
- **US-002 (Logout)**: Secure session logout clearing active cashier session.
- **US-003 (Change Password)**: Password change dialog with validation.
- **US-004 (Product Image)**: Image URL preview with fallback food icons.
- **US-005 (Categories)**: Categorization (Drinks & Coffee, Burgers & Fast Food, Bakery, Khmer Food, Snacks, Grocery).
- **US-006 (Admin Panel)**: Responsive Web Dashboard with collapsible navigation sidebar.
- **US-007 (Dashboard)**: KPI stat cards (Gross Revenue, Orders count, Bakong volume, Low stock count).
- **US-008 (Employee Management)**: Staff directory with roles (Admin, Manager, Cashier, Stock Staff).
- **US-009 (CRUD Product)**: Create, Read, Update, Delete products with live catalog updates.
- **US-010 (Barcode)**: Native vector barcode rendering for each product.
- **US-011 (Product Status)**: Dynamic status badges (Active, Low Stock, Out of Stock, Inactive).

### **Sprint 2: Product & Inventory (Week 3–4)**
- **US-012 (Product Management)**: Comprehensive product attributes editing.
- **US-013 (Barcode Scanning)**: Interactive Barcode Scanner Simulator with animated laser line and quick scan presets.
- **US-014 (Inventory Management)**: Real-time stock quantity tracking per item.
- **US-015 (Search Product)**: Instant real-time search across English names, Khmer names, and barcodes.
- **US-016 (Cost Price)**: Cost price tracking for profit margin calculation.
- **US-017 (Selling Price)**: Configurable selling price in USD with automatic KHR exchange conversion.
- **US-018 (Import)**: CSV import simulation dialog.
- **US-019 (Export)**: CSV export for inventory records.
- **US-020 (Low Stock)**: Automatic threshold detection with visual warning badges and alerts.
- **US-021 (Stock In)**: Stock In dialog to receive shipments from suppliers with batch notes.
- **US-022 (Stock Out)**: Stock Out dialog for damaged, expired, or internal consumption.
- **US-023 (Stock Transfer)**: Stock transfer dialog (Warehouse to Store Floor).
- **US-024 (Adjustment)**: Physical stock reconciliation dialog.
- **US-025 (Supplier)**: Supplier directory with contact details and categories supplied.
- **US-026 (Purchase Order)**: Create and track Purchase Orders with status (Pending, Received & Restocked).
- **US-027 (Purchase Return)**: Return defective goods to suppliers with return slip.

### **Sprint 3: Sales (Week 5–6)**
- **US-028 (Sales Module)**: Touch/desktop-friendly Cashier Sales Terminal with category filters and product grid.
- **US-029 (Receipt Printing)**: Authentic 340px thermal receipt preview with store info, tax TIN, barcode, and QR.
- **US-030 (Customer Membership)**: Membership tiers (VIP 15% off, Gold 10% off, Silver 5% off, Standard).
- **US-031 (Product Scan)**: Barcode scanning simulator automatically adds products to the active cart.
- **US-032 (Hold Sale)**: Hold active customer cart with custom notes, recall held sale back to cart, or discard.
- **US-033 (Quantity Management)**: Quick quantity `+` / `-` controls, direct line item total calculation, and cart clear.

### **Sprint 4: Digital Payment (Week 7–8)**
- **US-034 (QR Payment)**: Dynamic QR code payment modal with merchant info and bill number.
- **US-035 (Card Payment)**: Credit/Debit card virtual terminal simulator (Visa, MasterCard, UnionPay).
- **US-036 (Discounts)**: Member tier discounts and order percentage discounts.
- **US-037 (Promotions)**: Promo codes support (e.g. `WELCOME10` for 10% off, `BAKONG15` for 15% off).
- **US-038 (Receipt)**: Full receipt breakdown with VAT (10%), discount, tendered amount, change, and auth codes.
- **US-039 (Bakong)**: Authentic National Bank of Cambodia Bakong KHQR visual card with currency toggle ($ / ៛) and "Simulate Scan & Pay" 1-click test button.
- **US-040 (Split Payment)**: Split total between Cash and Bakong KHQR / Card.
- **US-041 (Payment Status)**: Real-time payment status badges (Completed, Refunded, Pending).
- **US-042 (Payment History)**: Searchable transaction ledger with payment method filtering.
- **US-043 (Refund Payment)**: 1-click refund dialog with reason tracking, automatic item restocking, and ledger update.

### **Sprint 5: Customer Services (Week 9–10)**
- **US-044 (Customer Management)**: Customer directory with phone, email, lifetime spend, and loyalty points.
- **US-045 (Refunds)**: Full refund audit trail with restock logic.
- **US-046 (Shift Management)**: Cashier register shift management: opening float, cash sales, expected in drawer, closing shift reconciliation, discrepancy calculation.
- **US-047 (Customer Report)**: Membership breakdown and top loyalty point earners.
- **US-048 (Payroll)**: Employee payroll table with base salary, sales bonuses, and net payable.
- **US-049 (Weekly Report)**: Daily sales breakdown for Monday to Sunday.
- **US-050 (Monthly Report)**: Monthly performance, VAT collected, digital payment share (68%).
- **US-051 (Inventory Report)**: Stock valuation audit: asset value at cost vs retail potential value and projected gross profit.

### **Sprint 6: Reports & Deployment (Week 11–12)**
- **US-052 (Reports)**: Centralized reporting hub with export capabilities.
- **US-053 (Analytics)**: Weekly bar charts and payment method distribution analytics.
- **US-054 (Notifications)**: Notification drawer for low stock alerts and gateway updates.
- **US-055 (Backup)**: One-click cloud/database snapshot backup simulator with timestamp.
- **US-056 (System Testing)**: Diagnostics health check (Database, Bakong KHQR Gateway, Barcode Engine, Thermal Printer).
- **US-057 (Deployment)**: Production-ready badge, store info configuration, and environment indicator.
- **US-058 (Activity Log)**: System audit trail logging all actions (logins, sales, stock adjustments, refunds).
- **US-059 (Store Information)**: Store profile settings (Store Name, Khmer Name, Branch, Phone, Address, VAT TIN, USD/KHR exchange rate: 1 USD = 4,100 KHR).
- **US-060 (Mobile Dashboard)**: Responsive layout collapsing seamlessly to mobile navigation drawer.
- **US-061 (Activity History)**: Searchable history timeline of all store operations.

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                          # App Entrypoint & Multi-Screen Routing
├── models/
│   ├── product.dart                   # ProductItem, CategoryItem, ProductStatus
│   ├── cart_item.dart                 # CartItem, HeldSale
│   ├── transaction.dart               # TransactionRecord, PaymentMethod, TransactionStatus
│   ├── customer.dart                  # Customer, MembershipTier
│   ├── employee.dart                  # Employee, ShiftRecord, PayrollEntry
│   ├── supplier.dart                  # Supplier, StockMovement, PurchaseOrder, PurchaseReturn
│   └── store_info.dart                # StoreInfo, AppNotification, ActivityLog
├── state/
│   └── pos_state.dart                 # Centralized ChangeNotifier singleton state & business logic
├── widgets/
│   ├── custom_barcode.dart            # Pure Flutter CustomPainter Barcode (Code 128 / EAN)
│   ├── custom_qr.dart                 # Authentic National Bank of Cambodia Bakong KHQR CustomPainter
│   └── stat_card.dart                 # Reusable KPI metric card with trends
└── screens/
    ├── auth/
    │   ├── login_screen.dart          # Login with 1-click test role presets
    │   └── change_password_dialog.dart# Password change modal
    ├── pos/
    │   ├── pos_terminal_screen.dart   # Main Cashier Terminal (Catalog, Cart, Totals)
    │   ├── barcode_scanner_modal.dart # Simulated Barcode Scanner Viewfinder
    │   ├── payment_modal.dart         # Bakong KHQR, Cash, Card, Split Payment dialogs
    │   ├── receipt_dialog.dart        # Printable thermal receipt preview
    │   └── held_sales_modal.dart      # Hold/Recall pending orders
    └── admin/
        ├── admin_layout.dart          # Responsive Admin Shell with Collapsible Sidebar & Header
        ├── dashboard_view.dart        # Executive KPI Cards, Analytics Charts, Recent Orders
        ├── products_view.dart         # Product Catalog CRUD, Categories, Prices, Margins
        ├── inventory_view.dart        # Stock In/Out/Transfer/Adjustment, CSV Import/Export
        ├── suppliers_view.dart        # Suppliers & Purchase Orders / Returns
        ├── transactions_view.dart     # Payment history, Status tracking, Refunds
        ├── customers_view.dart        # Customer memberships, loyalty points
        ├── employees_view.dart        # Staff management, Shifts, Payroll
        ├── reports_view.dart          # Weekly/Monthly sales reports, inventory valuation
        └── settings_view.dart         # Store config, Activity log, Backup/restore, Health check
```
