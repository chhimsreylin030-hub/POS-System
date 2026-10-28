-- ============================================================================
-- SmartFood Database Schema Optimization for pos_db
-- 1. Drops 10 legacy, unused retail POS tables (0 rows, not relevant to food delivery)
-- 2. Creates 4 necessary food delivery tables (delivery_drivers, vouchers, customer_addresses, reviews)
-- 3. Ensures strict data integrity for pos_db exclusively (smartfood_db untouched)
-- ============================================================================

-- Step 1: Remove legacy retail shift constraints from transactions
ALTER TABLE transactions DROP FOREIGN KEY fk_tx_shift;
ALTER TABLE transactions MODIFY COLUMN shift_id INT NULL;
ALTER TABLE transactions MODIFY COLUMN cashier_id INT NULL;

-- Step 2: Drop unused legacy retail POS tables
DROP TABLE IF EXISTS held_sale_items;
DROP TABLE IF EXISTS held_sales;
DROP TABLE IF EXISTS payroll;
DROP TABLE IF EXISTS purchase_order_items;
DROP TABLE IF EXISTS purchase_returns;
DROP TABLE IF EXISTS purchase_orders;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS stock_movements;
DROP TABLE IF EXISTS shifts;
DROP TABLE IF EXISTS store_settings;

-- Step 3: Create delivery_drivers table (Delivery Fleet)
CREATE TABLE IF NOT EXISTS delivery_drivers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  driver_code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  khmer_name VARCHAR(100) NOT NULL,
  phone VARCHAR(50) NOT NULL UNIQUE,
  vehicle_type VARCHAR(50) DEFAULT 'Motorcycle (ម៉ូតូ)',
  vehicle_plate VARCHAR(50) NOT NULL,
  rating DECIMAL(3,2) DEFAULT 4.90,
  total_deliveries INT DEFAULT 120,
  status ENUM('AVAILABLE','DELIVERING','OFFLINE') DEFAULT 'AVAILABLE',
  photo_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed Delivery Drivers
INSERT INTO delivery_drivers (driver_code, name, khmer_name, phone, vehicle_type, vehicle_plate, rating, total_deliveries, status, photo_url)
VALUES 
('DRV-001', 'Sokha Chea', 'ជា សុខា', '+855 12 345 678', 'Honda Dream 125', 'Phnom Penh 1AB-2345', 4.95, 342, 'AVAILABLE', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'),
('DRV-002', 'Dara Vong', 'វង្ស ដារ៉ា', '+855 98 765 432', 'Honda Scoopy 110', 'Phnom Penh 1BC-6789', 4.88, 280, 'AVAILABLE', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200'),
('DRV-003', 'Piseth Mao', 'ម៉ៅ ពិសិដ្ឋ', '+855 10 998 877', 'Yamaha Aerox 155', 'Phnom Penh 1CD-4567', 4.92, 195, 'AVAILABLE', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200'),
('DRV-004', 'Chantrea Meas', 'មាស ច័ន្ទទ្រា', '+855 11 223 344', 'Suzuki Viva 115', 'Phnom Penh 1EF-8910', 4.85, 150, 'AVAILABLE', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Step 4: Create vouchers table (Promo & Voucher Codes)
CREATE TABLE IF NOT EXISTS vouchers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  title VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  discount_percent INT NOT NULL,
  max_discount_usd DECIMAL(10,2) DEFAULT 5.00,
  min_spend_usd DECIMAL(10,2) DEFAULT 0.00,
  expiry_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed Promo Vouchers
INSERT INTO vouchers (code, title, description, discount_percent, max_discount_usd, min_spend_usd, expiry_date, is_active)
VALUES
('WELCOME5', 'New Customer Welcome', '15% discount for new customer first order', 15, 5.00, 5.00, '2026-12-31', TRUE),
('FREESHIP', 'Free Delivery Deal', 'Free delivery on all food orders above $8', 10, 2.00, 8.00, '2026-12-31', TRUE),
('SMARTFOOD20', 'SmartFood Special Promo', '20% off for all Khmer dishes & burgers', 20, 8.00, 10.00, '2026-12-31', TRUE),
('KHMERDELIGHT', 'Khmer Heritage Food Fest', '10% discount on authentic traditional dishes', 10, 4.00, 5.00, '2026-12-31', TRUE)
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- Step 5: Create customer_addresses table
CREATE TABLE IF NOT EXISTS customer_addresses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  label VARCHAR(50) NOT NULL,
  address_line VARCHAR(255) NOT NULL,
  city VARCHAR(50) DEFAULT 'Phnom Penh',
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

-- Seed Customer Addresses
INSERT INTO customer_addresses (customer_id, label, address_line, city, is_default)
VALUES
(1, 'Home', 'House 14, St 214, Daun Penh, Phnom Penh', 'Phnom Penh', TRUE),
(1, 'Office', 'Canadia Tower, Floor 14, St 102, Phnom Penh', 'Phnom Penh', FALSE),
(2, 'Home', 'Condo 802, The Bridge, Tonle Bassac, Phnom Penh', 'Phnom Penh', TRUE),
(3, 'Home', 'House 42, St 271, Boeng Tumpun, Phnom Penh', 'Phnom Penh', TRUE),
(3, 'Work', 'Exchange Square, Floor 8, Daun Penh, Phnom Penh', 'Phnom Penh', FALSE);

-- Step 6: Create reviews table (Restaurant & Dish Feedback)
CREATE TABLE IF NOT EXISTS reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  merchant_id INT NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
  FOREIGN KEY (merchant_id) REFERENCES merchants(id) ON DELETE CASCADE
);

-- Seed Reviews
INSERT INTO reviews (customer_id, merchant_id, rating, comment)
VALUES
(1, 1, 5, 'Traditional Fish Amok was exceptional! Very authentic Khmer herbs and coconut cream.'),
(2, 4, 5, 'Best espresso and croissants in BKK1. Fast delivery.'),
(3, 1, 5, 'Delicious beef lok lak and very fast delivery to Boeng Tumpun.'),
(3, 6, 4, 'Juicy smash burger and crispy fries. Will order again!');
