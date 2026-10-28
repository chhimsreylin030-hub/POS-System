-- ============================================================================
-- SMART POS WITH DIGITAL PAYMENT SYSTEM - MYSQL DATABASE SCHEMA
-- Topic: POS with Digital Payment (Cambodia Bakong KHQR, Card, Cash, Split)
-- Covers: Sprint 1 to Sprint 6 (US-001 through US-061)
-- Charset: utf8mb4 (Full support for English & Khmer text: ភាសាខ្មែរ)
-- ============================================================================

DROP DATABASE IF EXISTS `pos_db`;
CREATE DATABASE `pos_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `pos_db`;

-- ----------------------------------------------------------------------------
-- 1. STORE INFORMATION & CONFIGURATION (US-059)
-- ----------------------------------------------------------------------------
CREATE TABLE `store_settings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_name` VARCHAR(150) NOT NULL DEFAULT 'SMART POS & DIGITAL PAY',
    `khmer_store_name` VARCHAR(200) NOT NULL DEFAULT 'ស្មាត ភីអូអេស និងការទូទាត់ឌីជីថល',
    `branch_name` VARCHAR(100) NOT NULL DEFAULT 'Toul Kork Branch, Phnom Penh',
    `phone` VARCHAR(50) NOT NULL DEFAULT '+855 23 999 888',
    `address` TEXT NOT NULL,
    `vat_tin` VARCHAR(50) NOT NULL DEFAULT 'K002-902341882',
    `usd_to_khr_rate` DECIMAL(10, 2) NOT NULL DEFAULT 4100.00,
    `tax_rate_percent` DECIMAL(5, 2) NOT NULL DEFAULT 10.00,
    `wifi_password` VARCHAR(50) DEFAULT 'posguestpass@2026',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 2. EMPLOYEES & USERS (US-001, US-002, US-003, US-008)
-- ----------------------------------------------------------------------------
CREATE TABLE `employees` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL, -- BCrypt or hashed password
    `pin_code` VARCHAR(10) NOT NULL DEFAULT '1234',
    `phone` VARCHAR(30) NOT NULL,
    `role` ENUM('ADMIN', 'MANAGER', 'CASHIER', 'INVENTORY_STAFF') NOT NULL DEFAULT 'CASHIER',
    `monthly_salary` DECIMAL(10, 2) NOT NULL DEFAULT 350.00,
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 3. PRODUCT CATEGORIES (US-005)
-- ----------------------------------------------------------------------------
CREATE TABLE `categories` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `khmer_name` VARCHAR(150) NOT NULL,
    `icon` VARCHAR(50) DEFAULT 'category',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 4. PRODUCTS & MENU CATALOG (US-004, US-009, US-010, US-011, US-012, US-016, US-017)
-- ----------------------------------------------------------------------------
CREATE TABLE `products` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `category_id` INT NOT NULL,
    `name` VARCHAR(150) NOT NULL,
    `khmer_name` VARCHAR(200) NOT NULL,
    `barcode` VARCHAR(60) NOT NULL UNIQUE,
    `cost_price` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `selling_price` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `stock_quantity` INT NOT NULL DEFAULT 0,
    `low_stock_threshold` INT NOT NULL DEFAULT 10,
    `image_url` VARCHAR(500) DEFAULT NULL,
    `status` ENUM('ACTIVE', 'INACTIVE', 'OUT_OF_STOCK', 'LOW_STOCK') NOT NULL DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_barcode` (`barcode`),
    INDEX `idx_category` (`category_id`),
    CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 5. CUSTOMERS & MEMBERSHIP (US-030, US-044, US-047)
-- ----------------------------------------------------------------------------
CREATE TABLE `customers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(30) NOT NULL UNIQUE,
    `email` VARCHAR(100) DEFAULT NULL,
    `membership_tier` ENUM('REGULAR', 'SILVER', 'GOLD', 'VIP') NOT NULL DEFAULT 'REGULAR',
    `loyalty_points` INT NOT NULL DEFAULT 0,
    `total_spent` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `joined_date` DATE NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_customer_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 6. SUPPLIERS (US-025)
-- ----------------------------------------------------------------------------
CREATE TABLE `suppliers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL,
    `contact_person` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(50) NOT NULL,
    `email` VARCHAR(100) DEFAULT NULL,
    `address` TEXT NOT NULL,
    `category_supplied` VARCHAR(100) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 7. PURCHASE ORDERS & RETURNS (US-026, US-027)
-- ----------------------------------------------------------------------------
CREATE TABLE `purchase_orders` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `po_number` VARCHAR(50) NOT NULL UNIQUE,
    `supplier_id` INT NOT NULL,
    `order_date` DATETIME NOT NULL,
    `expected_delivery` DATETIME NOT NULL,
    `total_cost` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `status` ENUM('PENDING', 'RECEIVED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_po_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `purchase_order_items` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `po_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `quantity` INT NOT NULL,
    `unit_cost` DECIMAL(10, 2) NOT NULL,
    `line_total` DECIMAL(12, 2) NOT NULL,
    CONSTRAINT `fk_poi_po` FOREIGN KEY (`po_id`) REFERENCES `purchase_orders` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_poi_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `purchase_returns` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `return_number` VARCHAR(50) NOT NULL UNIQUE,
    `po_id` INT DEFAULT NULL,
    `supplier_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `quantity` INT NOT NULL,
    `refund_amount` DECIMAL(10, 2) NOT NULL,
    `reason` TEXT NOT NULL,
    `return_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_pr_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_pr_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 8. INVENTORY STOCK MOVEMENTS & AUDIT (US-021, US-022, US-023, US-024)
-- ----------------------------------------------------------------------------
CREATE TABLE `stock_movements` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `product_id` INT NOT NULL,
    `movement_type` ENUM('STOCK_IN', 'STOCK_OUT', 'TRANSFER', 'ADJUSTMENT') NOT NULL,
    `quantity_delta` INT NOT NULL,
    `remaining_stock` INT NOT NULL,
    `reason` VARCHAR(255) NOT NULL,
    `operator_id` INT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_movement_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_movement_operator` FOREIGN KEY (`operator_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 9. CASHIER SHIFT MANAGEMENT & DRAWER BALANCING (US-046)
-- ----------------------------------------------------------------------------
CREATE TABLE `shifts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `shift_code` VARCHAR(50) NOT NULL UNIQUE,
    `employee_id` INT NOT NULL,
    `start_time` DATETIME NOT NULL,
    `end_time` DATETIME DEFAULT NULL,
    `opening_float` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `total_cash_sales` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `total_digital_sales` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `expected_cash` DECIMAL(12, 2) GENERATED ALWAYS AS (opening_float + total_cash_sales) STORED,
    `closing_cash_actual` DECIMAL(12, 2) DEFAULT NULL,
    `discrepancy` DECIMAL(10, 2) DEFAULT NULL,
    `notes` TEXT DEFAULT NULL,
    `is_closed` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_shift_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 10. SALES TRANSACTIONS & DIGITAL PAYMENTS (Sprint 3 & 4)
-- US-028, US-029, US-034 (QR), US-035 (Card), US-038 (Receipt),
-- US-039 (Bakong), US-040 (Split), US-041 (Status), US-042 (History), US-043/US-045 (Refund)
-- ----------------------------------------------------------------------------
CREATE TABLE `transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `invoice_number` VARCHAR(60) NOT NULL UNIQUE,
    `timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `cashier_id` INT NOT NULL,
    `customer_id` INT DEFAULT NULL,
    `shift_id` INT DEFAULT NULL,
    `subtotal` DECIMAL(10, 2) NOT NULL,
    `discount_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `tax_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `grand_total_usd` DECIMAL(10, 2) NOT NULL,
    `grand_total_khr` DECIMAL(14, 2) NOT NULL,
    `payment_method` ENUM('CASH', 'BAKONG_KHQR', 'CREDIT_CARD', 'SPLIT_PAYMENT') NOT NULL,
    `payment_reference` VARCHAR(100) NOT NULL, -- Bakong Tx Hash or Card Auth Code
    `amount_tendered` DECIMAL(10, 2) NOT NULL,
    `change_given` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `split_cash_amount` DECIMAL(10, 2) DEFAULT NULL,
    `split_digital_amount` DECIMAL(10, 2) DEFAULT NULL,
    `status` ENUM('COMPLETED', 'REFUNDED', 'PENDING', 'FAILED') NOT NULL DEFAULT 'COMPLETED',
    `refund_reason` TEXT DEFAULT NULL,
    `refunded_at` DATETIME DEFAULT NULL,
    INDEX `idx_invoice` (`invoice_number`),
    INDEX `idx_payment_method` (`payment_method`),
    INDEX `idx_timestamp` (`timestamp`),
    CONSTRAINT `fk_tx_cashier` FOREIGN KEY (`cashier_id`) REFERENCES `employees` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_tx_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_tx_shift` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `transaction_items` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `transaction_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `quantity` INT NOT NULL,
    `unit_price` DECIMAL(10, 2) NOT NULL,
    `discount_percent` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `line_total` DECIMAL(10, 2) NOT NULL,
    CONSTRAINT `fk_ti_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_ti_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 11. HELD SALES (US-032)
-- ----------------------------------------------------------------------------
CREATE TABLE `held_sales` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `hold_code` VARCHAR(50) NOT NULL UNIQUE,
    `cashier_id` INT NOT NULL,
    `customer_name` VARCHAR(100) DEFAULT NULL,
    `note` VARCHAR(255) DEFAULT 'Table / Waiting',
    `discount_percent` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `total_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `held_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_held_cashier` FOREIGN KEY (`cashier_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `held_sale_items` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `held_sale_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `quantity` INT NOT NULL DEFAULT 1,
    `unit_price` DECIMAL(10, 2) NOT NULL,
    CONSTRAINT `fk_hsi_sale` FOREIGN KEY (`held_sale_id`) REFERENCES `held_sales` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_hsi_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 12. EMPLOYEE PAYROLL (US-048)
-- ----------------------------------------------------------------------------
CREATE TABLE `payroll` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `employee_id` INT NOT NULL,
    `month_year` VARCHAR(20) NOT NULL, -- e.g. '10-2026'
    `base_salary` DECIMAL(10, 2) NOT NULL,
    `bonus` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `deductions` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `net_salary` DECIMAL(10, 2) GENERATED ALWAYS AS (base_salary + bonus - deductions) STORED,
    `is_paid` BOOLEAN NOT NULL DEFAULT FALSE,
    `paid_at` DATETIME DEFAULT NULL,
    CONSTRAINT `fk_payroll_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 13. NOTIFICATIONS & SECURITY AUDIT LOGS (US-054, US-058, US-061)
-- ----------------------------------------------------------------------------
CREATE TABLE `notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(150) NOT NULL,
    `message` TEXT NOT NULL,
    `is_warning` BOOLEAN NOT NULL DEFAULT FALSE,
    `is_read` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `activity_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `actor_name` VARCHAR(100) NOT NULL DEFAULT 'System',
    `action` VARCHAR(100) NOT NULL,
    `details` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- SEED INITIAL DATA (Ready-to-Test Dataset)
-- ============================================================================

-- 1. Store Info
INSERT INTO `store_settings` (`store_name`, `khmer_store_name`, `branch_name`, `phone`, `address`, `vat_tin`, `usd_to_khr_rate`, `tax_rate_percent`, `wifi_password`)
VALUES ('SMART POS & DIGITAL PAY', 'ស្មាត ភីអូអេស និងការទូទាត់ឌីជីថល', 'Toul Kork Branch, Phnom Penh', '+855 23 999 888 / 012 345 678', '#128, St 315, Sangkat Boeng Kak 1, Khan Toul Kork, Phnom Penh', 'K002-902341882', 4100.00, 10.00, 'posguestpass@2026');

-- 2. Employees (Passwords: admin123, cashier123, staff123)
INSERT INTO `employees` (`id`, `name`, `email`, `password_hash`, `pin_code`, `phone`, `role`, `monthly_salary`)
VALUES 
(1, 'Vannak Heng (Admin)', 'admin@pos.com', '$2a$10$abcdefghijklmnopqrstuvwxyz123456AdminHash', '1234', '012 345 678', 'ADMIN', 850.00),
(2, 'Sreylis Sinoun (Cashier)', 'cashier@pos.com', '$2a$10$abcdefghijklmnopqrstuvwxyz123456CashierHash', '1234', '097 554 321', 'CASHIER', 380.00),
(3, 'Rithy Seng (Stock Keeper)', 'inventory@pos.com', '$2a$10$abcdefghijklmnopqrstuvwxyz123456StaffHash', '1234', '088 123 999', 'INVENTORY_STAFF', 420.00);

-- 3. Categories
INSERT INTO `categories` (`id`, `name`, `khmer_name`, `icon`)
VALUES 
(1, 'Drinks & Coffee', 'ភេសជ្ជៈ និងកាហ្វេ', 'local_cafe'),
(2, 'Burgers & Fast Food', 'ប៊ឺហ្គឺ និងអាហាររហ័ស', 'lunch_dining'),
(3, 'Bakery & Dessert', 'នំបុ័ង និងបង្អែម', 'cake'),
(4, 'Khmer Food', 'ម្ហូបខ្មែរ', 'ramen_dining'),
(5, 'Snacks & Bites', 'ចំណីសម្រន់', 'fastfood'),
(6, 'Grocery & Retail', 'ទំនិញទូទៅ', 'shopping_bag');

-- 4. Products
INSERT INTO `products` (`id`, `category_id`, `name`, `khmer_name`, `barcode`, `cost_price`, `selling_price`, `stock_quantity`, `low_stock_threshold`, `image_url`, `status`)
VALUES 
(1, 1, 'Iced Latte Macchiato', 'ឡាតេទឹកកក ម៉ាគីយ៉ាតូ', '8850123001', 1.10, 2.75, 45, 10, 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=300', 'ACTIVE'),
(2, 1, 'Cambodian Drip Coffee (Cafe Teuk Doh Koh)', 'កាហ្វេទឹកដោះគោទឹកកក', '8850123002', 0.70, 1.80, 60, 10, 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=300', 'ACTIVE'),
(3, 1, 'Matcha Green Tea Frappe', 'ម៉ាត់ឆាបៃតងក្រឡុក', '8850123003', 1.30, 3.25, 28, 10, 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=300', 'ACTIVE'),
(4, 2, 'Signature Wagyu Cheeseburger', 'ប៊ឺហ្គឺសាច់គោ វ៉ាហ្គ្យូ', '8850123004', 3.20, 6.50, 22, 10, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300', 'ACTIVE'),
(5, 2, 'Crispy Truffle Fries', 'ដំឡូងបារាំងបំពង ត្រាហ្វល', '8850123005', 1.20, 3.50, 30, 10, 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=300', 'ACTIVE'),
(6, 3, 'French Butter Croissant', 'នំបុ័ងខ្វាសុង ប៊័រស្រស់', '8850123006', 0.90, 2.20, 8, 10, 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=300', 'LOW_STOCK'),
(7, 3, 'Belgian Chocolate Brownie', 'ប្រោវនីសូកូឡាបែលហ្ស៊ិក', '8850123007', 1.10, 2.80, 15, 10, 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=300', 'ACTIVE'),
(8, 4, 'Khmer Beef Lok Lak with Fried Egg', 'ឡុកឡាក់សាច់គោពងទាចៀន', '8850123008', 2.50, 5.50, 18, 10, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300', 'ACTIVE'),
(9, 4, 'Fish Amok Traditional Rice Set', 'អាម៉ុកត្រី បាយដំណើប', '8850123009', 2.80, 6.00, 12, 10, 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300', 'ACTIVE'),
(10, 3, 'Fresh Mango Sticky Rice', 'បាយដំណើបស្វាយទុំ', '8850123010', 1.00, 3.00, 0, 10, 'https://images.unsplash.com/photo-1505253758473-96b3015f240a?w=300', 'OUT_OF_STOCK'),
(11, 1, 'Angkor Premium Beer 330ml Can', 'ស្រាបៀរអង្គរ កំប៉ុង', '8850123011', 0.75, 1.50, 120, 20, 'https://images.unsplash.com/photo-1608270199042-30372df34389?w=300', 'ACTIVE'),
(12, 6, 'Organic Jasmine Rice 5kg', 'អង្ករផ្កាម្លិះសរីរាង្គ ៥គីឡូ', '8850123012', 4.80, 7.20, 35, 10, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=300', 'ACTIVE');

-- 5. Customers
INSERT INTO `customers` (`id`, `name`, `phone`, `email`, `membership_tier`, `loyalty_points`, `total_spent`, `joined_date`)
VALUES 
(1, 'Sokha Chan (ចាន់ សុខា)', '012 889 977', 'sokha.chan@gmail.com', 'VIP', 340, 480.50, '2025-03-10'),
(2, 'Dara Lim (លីម ដារ៉ា)', '098 765 432', 'dara.lim@yahoo.com', 'GOLD', 195, 260.00, '2025-06-18'),
(3, 'Bopha Pich (ពេជ្រ បុប្ផា)', '010 334 556', 'bopha.pich@outlook.com', 'SILVER', 80, 110.00, '2026-01-05');

-- 6. Suppliers
INSERT INTO `suppliers` (`id`, `name`, `contact_person`, `phone`, `email`, `address`, `category_supplied`)
VALUES 
(1, 'Angkor Beverage Supplies Ltd', 'Mr. David Roth', '023 888 111', 'sales@angkorbev.com.kh', 'Russian Blvd, Phnom Penh', 'Drinks & Coffee'),
(2, 'Phnom Penh Fresh Bakeries Co.', 'Ms. Kolab Chea', '012 998 877', 'order@ppbakery.kh', 'St 271, Boeng Tumpun, Phnom Penh', 'Bakery & Dessert'),
(3, 'Mekong Agri-Food Wholesale', 'Mr. Bunthoeun Keo', '015 443 221', 'supply@mekongfood.com', 'St 598, Sen Sok, Phnom Penh', 'Grocery & Meat');

-- 7. Initial Active Shift
INSERT INTO `shifts` (`id`, `shift_code`, `employee_id`, `start_time`, `opening_float`, `total_cash_sales`, `total_digital_sales`, `is_closed`)
VALUES (1, 'SFT-20261026-01', 2, NOW(), 100.00, 84.50, 142.00, FALSE);

-- 8. Sample Transactions (Bakong KHQR, Cash, Card)
INSERT INTO `transactions` (`id`, `invoice_number`, `timestamp`, `cashier_id`, `customer_id`, `shift_id`, `subtotal`, `discount_amount`, `tax_amount`, `grand_total_usd`, `grand_total_khr`, `payment_method`, `payment_reference`, `amount_tendered`, `change_given`, `status`)
VALUES 
(1, 'INV-20261026-001', DATE_SUB(NOW(), INTERVAL 45 MINUTE), 2, 1, 1, 12.00, 1.20, 1.08, 11.88, 48708.00, 'BAKONG_KHQR', 'BK-89421092', 11.88, 0.00, 'COMPLETED'),
(2, 'INV-20261026-002', DATE_SUB(NOW(), INTERVAL 90 MINUTE), 2, NULL, 1, 14.60, 0.00, 1.46, 16.06, 65846.00, 'CASH', 'CASH-TENDER', 20.00, 3.94, 'COMPLETED'),
(3, 'INV-20261026-003', DATE_SUB(NOW(), INTERVAL 150 MINUTE), 1, 2, 1, 9.25, 0.50, 0.88, 9.63, 39483.00, 'CREDIT_CARD', 'AUTH-458921', 9.63, 0.00, 'COMPLETED');

-- 9. Transaction Line Items
INSERT INTO `transaction_items` (`transaction_id`, `product_id`, `quantity`, `unit_price`, `discount_percent`, `line_total`)
VALUES 
(1, 1, 2, 2.75, 0.00, 5.50),
(1, 4, 1, 6.50, 10.00, 5.85),
(2, 8, 2, 5.50, 0.00, 11.00),
(2, 2, 2, 1.80, 0.00, 3.60),
(3, 9, 1, 6.00, 0.00, 6.00),
(3, 3, 1, 3.25, 0.00, 3.25);

-- 10. System Notifications
INSERT INTO `notifications` (`title`, `message`, `is_warning`, `is_read`)
VALUES 
('Low Stock Alert', 'French Butter Croissant is down to 8 units.', TRUE, FALSE),
('Bakong Gateway Online', 'Bakong KHQR instant payment channel is operational.', FALSE, TRUE);

-- 11. Activity Logs
INSERT INTO `activity_logs` (`actor_name`, `action`, `details`)
VALUES 
('System', 'System Startup', 'POS System initialized. MySQL Database connected.'),
('Vannak Heng', 'User Login', 'Vannak Heng logged in as System Admin.'),
('Sreylis Sinoun', 'Sale Completed', 'INV-20261026-001 - $11.88 via Bakong KHQR (បាគង)');
