-- ==============================================================================
-- FOOD DELIVERY PLATFORM - DATABASE SCHEMA (MYSQL 8.0+)
-- Architecture: Customer App • Merchant Web • Admin Web • Driver Console (Static)
-- Character Set: utf8mb4 (Full Khmer & International Unicode Support)
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS `food_delivery_db`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `food_delivery_db`;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `activity_logs`;
DROP TABLE IF EXISTS `platform_analytics`;
DROP TABLE IF EXISTS `vouchers`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `drivers`;
DROP TABLE IF EXISTS `delivery_addresses`;
DROP TABLE IF EXISTS `customers`;
DROP TABLE IF EXISTS `menu_items`;
DROP TABLE IF EXISTS `food_categories`;
DROP TABLE IF EXISTS `merchants`;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------------------------
-- 1. MERCHANTS / RESTAURANTS (Merchant Webpage Controller)
-- ------------------------------------------------------------------------------
CREATE TABLE `merchants` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL,
  `khmer_name` VARCHAR(150) NOT NULL,
  `cuisine` VARCHAR(100) NOT NULL,
  `banner_url` TEXT,
  `logo_url` TEXT,
  `rating` DECIMAL(3, 2) DEFAULT 4.80,
  `delivery_time_min` INT DEFAULT 25,
  `delivery_fee_usd` DECIMAL(10, 2) DEFAULT 1.00,
  `is_open` TINYINT(1) DEFAULT 1,
  `address` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(50) NOT NULL,
  `total_sales_usd` DECIMAL(12, 2) DEFAULT 0.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `merchants` (`id`, `name`, `khmer_name`, `cuisine`, `banner_url`, `logo_url`, `rating`, `delivery_time_min`, `delivery_fee_usd`, `is_open`, `address`, `phone`, `total_sales_usd`) VALUES
('rest-1', 'Angkor Authentic Kitchen', 'ផ្ទះបាយខ្មែរ អង្គរ', 'Traditional Khmer • Rice & Noodles', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&q=80', 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200&q=80', 4.90, 20, 1.00, 1, 'St 214, Daun Penh, Phnom Penh', '023 219 900', 480.00),
('rest-2', 'Phnom Penh Brown Coffee & Bakery', 'ហាងកាហ្វេ និងនំបុ័ង ប្រោន', 'Specialty Coffee • Croissants • Cakes', 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=700&q=80', 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=200&q=80', 4.80, 15, 0.75, 1, 'St 57, BKK1, Phnom Penh', '023 222 345', 310.00),
('rest-3', 'Sen Sok Gourmet Burger & Pizza', 'ប៊ឺហ្គឺ និងភីហ្សា សែនសុខ', 'American Fast Food • Crispy Chicken', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700&q=80', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=200&q=80', 4.70, 30, 1.25, 1, 'St 1003, Sen Sok, Phnom Penh', '012 998 776', 520.00),
('rest-4', 'Malis Khmer Street Food', 'ម្ហូបតាមផ្លូវ ម្លិះ', 'Barbecue • Seafood • Spicy Salad', 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=700&q=80', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=200&q=80', 4.60, 25, 1.00, 1, 'St 155, Tuol Tompoung, Phnom Penh', '015 667 889', 240.00);

-- ------------------------------------------------------------------------------
-- 2. FOOD CATEGORIES
-- ------------------------------------------------------------------------------
CREATE TABLE `food_categories` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `khmer_name` VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `food_categories` (`id`, `name`, `khmer_name`) VALUES
('cat-1', 'Khmer Dishes', 'ម្ហូបខ្មែរ'),
('cat-2', 'Coffee & Tea', 'កាហ្វេ និងតែ'),
('cat-3', 'Bakery & Dessert', 'នំបុ័ង និងបង្អែម'),
('cat-4', 'Burgers & Fast Food', 'ប៊ឺហ្គឺ និងអាហាររហ័ស'),
('cat-5', 'Pizza', 'ភីហ្សា'),
('cat-6', 'Appetizers', 'អាហារសម្រន់');

-- ------------------------------------------------------------------------------
-- 3. MENU ITEMS (Food Dishes Managed by Merchant Webpage)
-- ------------------------------------------------------------------------------
CREATE TABLE `menu_items` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `merchant_id` VARCHAR(50) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `khmer_name` VARCHAR(150) NOT NULL,
  `description` TEXT,
  `price_usd` DECIMAL(10, 2) NOT NULL,
  `image_url` TEXT,
  `category` VARCHAR(50) NOT NULL,
  `is_available` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`merchant_id`) REFERENCES `merchants`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `menu_items` (`id`, `merchant_id`, `name`, `khmer_name`, `description`, `price_usd`, `image_url`, `category`, `is_available`) VALUES
('dish-1', 'rest-1', 'Khmer Beef Lok Lak with Jasmine Rice', 'បាយឡុកឡាក់សាច់គោខ្មែរ', 'Tender marinated cubed beef with lime-black pepper dipping sauce, fried egg, and steamed jasmine rice.', 4.50, 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80', 'Khmer Dishes', 1),
('dish-2', 'rest-1', 'Traditional Fish Amok in Banana Leaf', 'អាម៉ុកត្រីស្លឹកចេក', 'Steamed river fish mousse infused with kroeung paste, coconut milk, and wild kaffir leaves.', 5.00, 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=500&q=80', 'Khmer Dishes', 1),
('dish-3', 'rest-1', 'Crispy Pork & Seafood Spring Rolls (4 pcs)', 'ណែមចៀនសាច់ជ្រូក', 'Deep-fried golden rolls stuffed with minced pork, taro, and glass noodles with sweet chili dip.', 3.00, 'https://images.unsplash.com/photo-1541518763669-27fef04b14ea?w=500&q=80', 'Appetizers', 1),
('dish-4', 'rest-1', 'Iced Tamarind Juice with Chia Seeds', 'ទឹកអំពិលទុំទឹកកក', 'Fresh chilled sweet and tangy tamarind drink served over crushed ice.', 1.50, 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=500&q=80', 'Drinks', 1),
('dish-5', 'rest-2', 'Iced Palm Sugar Latte', 'កាហ្វេទឹកដោះគោស្ករត្នោត', 'Double espresso pulled over fresh milk and Kampong Speu natural palm sugar syrup.', 2.75, 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=500&q=80', 'Coffee', 1),
('dish-6', 'rest-2', 'French Butter Croissant', 'នំបុ័ងខ្វាសុងប៊័រ', 'Flaky, buttery multi-layered Parisian croissant baked golden fresh every morning.', 2.25, 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&q=80', 'Bakery', 1),
('dish-7', 'rest-2', 'Brown Signature Milk Tea with Boba', 'តែទឹកដោះគោគុជប្រោន', 'Rich Ceylon black tea brewed with fresh milk and chewy brown sugar tapioca pearls.', 2.50, 'https://images.unsplash.com/photo-1558857563-b37cf5a22d25?w=500&q=80', 'Drinks', 1),
('dish-8', 'rest-3', 'Double Wagyu Cheese Burger with Fries', 'ប៊ឺហ្គឺសាច់គោបន្ទះពីរ ឈីស', 'Two smashed beef patties, melted cheddar, pickles, grilled onions and smoky house sauce with fries.', 6.50, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80', 'Burgers', 1),
('dish-9', 'rest-3', 'Pepperoni & Mozzarella Pizza 10"', 'ភីហ្សាភិបភើរ៉ូនី', 'Stone-baked thin crust pizza loaded with tomato marinara, Italian mozzarella, and spicy beef pepperoni.', 7.00, 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500&q=80', 'Pizza', 1),
('dish-10', 'rest-3', 'Crispy Buffalo Chicken Wings (6 pcs)', 'ស្លាបមាន់បំពងស្រួយ', 'Fried crunchy wings tossed in tangy hot sauce, served with blue cheese dip.', 4.00, 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&q=80', 'Appetizers', 1);

-- ------------------------------------------------------------------------------
-- 4. CUSTOMERS (App Users)
-- ------------------------------------------------------------------------------
CREATE TABLE `customers` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL,
  `phone` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100),
  `default_address` VARCHAR(255) NOT NULL,
  `loyalty_points` INT DEFAULT 50,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `customers` (`id`, `name`, `phone`, `email`, `default_address`, `loyalty_points`) VALUES
('cust-1', 'Bopha Pich (ពេជ្រ បុប្ផា)', '010 334 556', 'bopha@gmail.com', 'House 42, St 271, Boeng Tumpun, Phnom Penh', 120),
('cust-2', 'Dara Lim (លីម ដារ៉ា)', '012 345 678', 'dara@gmail.com', 'Condo 12A, BKK1, Phnom Penh', 85);

-- ------------------------------------------------------------------------------
-- 5. DELIVERY DRIVERS (Static Fleet for Delivery Part)
-- ------------------------------------------------------------------------------
CREATE TABLE `drivers` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `khmer_name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(50) NOT NULL,
  `photo_url` TEXT,
  `vehicle_plate` VARCHAR(100) NOT NULL,
  `rating` DECIMAL(3, 2) DEFAULT 4.90,
  `is_online` TINYINT(1) DEFAULT 1,
  `total_deliveries_today` INT DEFAULT 12,
  `earnings_usd` DECIMAL(10, 2) DEFAULT 36.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `drivers` (`id`, `name`, `khmer_name`, `phone`, `photo_url`, `vehicle_plate`, `rating`, `is_online`, `total_deliveries_today`, `earnings_usd`) VALUES
('DRV-001', 'Sokha Chea', 'ជា សុខា', '012 889 977', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', 'Phnom Penh 1AB-2345 (Honda Dream)', 4.90, 1, 12, 36.00),
('DRV-002', 'Chanrithy Keo', 'កែវ ច័ន្ទរិទ្ធី', '097 554 321', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', 'Kandal 1C-8899 (Yamaha Scoopy)', 4.80, 1, 9, 27.00);

-- ------------------------------------------------------------------------------
-- 6. FOOD ORDERS
-- ------------------------------------------------------------------------------
CREATE TABLE `orders` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `order_number` VARCHAR(50) NOT NULL UNIQUE,
  `customer_id` VARCHAR(50) NOT NULL,
  `customer_name` VARCHAR(150) NOT NULL,
  `customer_phone` VARCHAR(50) NOT NULL,
  `delivery_address` VARCHAR(255) NOT NULL,
  `merchant_id` VARCHAR(50) NOT NULL,
  `merchant_name` VARCHAR(150) NOT NULL,
  `subtotal_usd` DECIMAL(10, 2) NOT NULL,
  `delivery_fee_usd` DECIMAL(10, 2) NOT NULL,
  `discount_usd` DECIMAL(10, 2) DEFAULT 0.00,
  `total_usd` DECIMAL(10, 2) NOT NULL,
  `total_khr` DECIMAL(12, 2) NOT NULL,
  `payment_method` ENUM('bakong_khqr', 'cash_on_delivery', 'credit_card') NOT NULL,
  `status` ENUM('pending_acceptance', 'cooking', 'ready_for_driver', 'driver_on_the_way', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending_acceptance',
  `driver_id` VARCHAR(50),
  `driver_name` VARCHAR(100),
  `driver_phone` VARCHAR(50),
  `driver_plate` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`merchant_id`) REFERENCES `merchants`(`id`),
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `orders` (`id`, `order_number`, `customer_id`, `customer_name`, `customer_phone`, `delivery_address`, `merchant_id`, `merchant_name`, `subtotal_usd`, `delivery_fee_usd`, `discount_usd`, `total_usd`, `total_khr`, `payment_method`, `status`, `driver_id`, `driver_name`, `driver_phone`, `driver_plate`) VALUES
('ord-1', 'ORD-98214', 'cust-1', 'Bopha Pich (ពេជ្រ បុប្ផា)', '010 334 556', 'House 42, St 271, Boeng Tumpun, Phnom Penh', 'rest-1', 'Angkor Authentic Kitchen', 12.00, 1.00, 1.20, 11.80, 48380.00, 'bakong_khqr', 'driver_on_the_way', 'DRV-001', 'Sokha Chea', '012 889 977', 'Phnom Penh 1AB-2345'),
('ord-2', 'ORD-98210', 'cust-2', 'Dara Lim (លីម ដារ៉ា)', '012 345 678', 'Condo 12A, BKK1, Phnom Penh', 'rest-2', 'Phnom Penh Brown Coffee & Bakery', 7.25, 0.75, 0.00, 8.00, 32800.00, 'cash_on_delivery', 'cooking', 'DRV-001', 'Sokha Chea', '012 889 977', 'Phnom Penh 1AB-2345');

-- ------------------------------------------------------------------------------
-- 7. ORDER ITEMS
-- ------------------------------------------------------------------------------
CREATE TABLE `order_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` VARCHAR(50) NOT NULL,
  `menu_item_id` VARCHAR(50) NOT NULL,
  `item_name` VARCHAR(150) NOT NULL,
  `quantity` INT NOT NULL,
  `unit_price_usd` DECIMAL(10, 2) NOT NULL,
  `total_price_usd` DECIMAL(10, 2) NOT NULL,
  `special_notes` TEXT,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `order_items` (`order_id`, `menu_item_id`, `item_name`, `quantity`, `unit_price_usd`, `total_price_usd`, `special_notes`) VALUES
('ord-1', 'dish-1', 'Khmer Beef Lok Lak with Jasmine Rice', 2, 4.50, 9.00, 'Mild spicy, extra lime'),
('ord-1', 'dish-4', 'Iced Tamarind Juice with Chia Seeds', 2, 1.50, 3.00, 'Extra cold crushed ice'),
('ord-2', 'dish-5', 'Iced Palm Sugar Latte', 1, 2.75, 2.75, 'Normal sweetness'),
('ord-2', 'dish-6', 'French Butter Croissant', 2, 2.25, 4.50, 'Warm up if possible');

-- ------------------------------------------------------------------------------
-- 8. PROMO VOUCHERS
-- ------------------------------------------------------------------------------
CREATE TABLE `vouchers` (
  `code` VARCHAR(50) NOT NULL PRIMARY KEY,
  `discount_percent` DECIMAL(5, 2) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `vouchers` (`code`, `discount_percent`, `description`, `is_active`) VALUES
('WELCOME5', 20.00, '20% off your first food order', 1),
('FREESHIP', 10.00, '10% discount to offset delivery fee', 1),
('KHQRFOOD', 15.00, '15% discount for Bakong KHQR payments', 1);

-- ------------------------------------------------------------------------------
-- 9. PLATFORM ACTIVITY LOGS
-- ------------------------------------------------------------------------------
CREATE TABLE `activity_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `action_type` VARCHAR(100) NOT NULL,
  `description` TEXT NOT NULL,
  `user_role` VARCHAR(50) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `activity_logs` (`action_type`, `description`, `user_role`) VALUES
('ORDER_PLACED', 'Order ORD-98214 placed by Bopha Pich via Bakong KHQR', 'customer'),
('MERCHANT_ACCEPTED', 'Angkor Authentic Kitchen started cooking ORD-98214', 'merchant'),
('DRIVER_ASSIGNED', 'Sokha Chea assigned to deliver ORD-98214', 'driver');
