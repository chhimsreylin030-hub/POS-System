# SmartFood Platform — Quick Setup Guide for Teammates & Friends

Welcome! If you just pulled or cloned this repository, follow these simple steps to run the complete **SmartFood Multi-Tenant Food Delivery & Merchant POS System** on your local machine with full MySQL integration.

---

## ⚡ 1-Click Fast Start (Windows)

1. Make sure your local **MySQL Server** (or XAMPP / WAMP / Laragon) is running.
2. Double-click **`setup_database.bat`** in this folder.
   - Enter your MySQL root password (or press Enter if default `sinoeun2026`).
   - This automatically creates `pos_db` and seeds all **14 tables, 10 corporate accounts, 21 restaurants, 68 products, delivery drivers, and vouchers**.
3. Double-click **`run_app.bat`**.
   - It automatically starts the backend API server on port 8081.
   - It automatically starts the Flutter web app on port 8085 (avoiding port 8080 conflicts) and opens your browser at `http://127.0.0.1:8085`.
   - The app automatically connects to MySQL within 3 seconds!

---

## 🛠️ Manual Terminal Instructions (Cross-Platform)

### Step 1: Initialize MySQL Database (`pos_db`)
Using MySQL CLI:
```bash
mysql -u root -p < pos_db_complete_setup.sql
```
*(Or import `pos_db_complete_setup.sql` into phpMyAdmin / MySQL Workbench / DBeaver).*

### Step 2: Start the Backend API Server
```bash
dart run bin/server.dart
```
> **Auto-Credential Detection**: The server automatically checks common passwords (`sinoeun2026`, `root`, blank `''`, `123456`, `password`). You can also specify your credentials via environment variables:
> - `set DB_PASSWORD=your_password`
> - `set DB_USER=root`
> - `set DB_PORT=3306`
> - `set DB_NAME=pos_db`

### Step 3: Start the Flutter App
In another terminal:
```bash
flutter run -d chrome
# OR
flutter run -d web-server --web-port=8085 --web-hostname=127.0.0.1
# OR
flutter run -d windows
```

---

## 🔑 Login Credentials

### 1. Merchant Web Portal
To access the restaurant kitchen order terminal and menu CRUD:
- **Corporate Account #1**: `angkor.heritage@gmail.com` / `123456` (Angkor Authentic Kitchen)
- **Corporate Account #2**: `artisan.coffee@gmail.com` / `123456` (Brown Coffee & Bakery)
- **Corporate Account #3**: `smash.burger@gmail.com` / `123456` (Burger Labs)
- *(Accounts #4 through #10 are also available, or you can register a new merchant partner directly in the portal).*

### 2. Customer Mobile App
- **Demo Customer 1**: `010 334 556` / `123456` (Bopha Pich)
- **Demo Customer 2**: `098 765 432` / `123456` (Dara Lim)
- *(Or tap "Register" to create a new customer account).*

---

## 🔄 Automatic Auto-Reconnect Feature
- If you start the Flutter app before starting MySQL or the API server, the app will show **"Offline • Auto-retrying every 3s"**.
- As soon as you start `dart run bin/server.dart` or MySQL, **the app automatically detects it within 3 seconds** and switches to **Online (MySQL 8.0: pos_db)** without needing to reload!
