USE `pos_db`;

-- 1. Create merchant_accounts table (10 Merchant Accounts)
CREATE TABLE IF NOT EXISTS `merchant_accounts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `account_name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(100) UNIQUE NOT NULL,
    `phone` VARCHAR(50) NOT NULL,
    `company_reg_number` VARCHAR(50) DEFAULT 'MO-2026-98102',
    `status` ENUM('ACTIVE', 'SUSPENDED') DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Create merchants table (Multiple restaurants per merchant account)
CREATE TABLE IF NOT EXISTS `merchants` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `account_id` INT NOT NULL,
    `name` VARCHAR(150) NOT NULL,
    `khmer_name` VARCHAR(200) NOT NULL,
    `cuisine` VARCHAR(100) NOT NULL,
    `banner_url` VARCHAR(500) NOT NULL,
    `logo_url` VARCHAR(500) NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `city` VARCHAR(100) DEFAULT 'Phnom Penh',
    `phone` VARCHAR(50) NOT NULL,
    `rating` DECIMAL(3, 1) DEFAULT 4.8,
    `delivery_time_min` INT DEFAULT 20,
    `delivery_fee_usd` DECIMAL(10, 2) DEFAULT 1.00,
    `is_open` TINYINT(1) DEFAULT 1,
    `total_sales_usd` DECIMAL(12, 2) DEFAULT 0.00,
    `status` VARCHAR(50) DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY `idx_account` (`account_id`),
    CONSTRAINT `fk_merchant_account` FOREIGN KEY (`account_id`) REFERENCES `merchant_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Add columns to products and transactions if not present
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'pos_db' AND TABLE_NAME = 'products' AND COLUMN_NAME = 'merchant_id';
SET @query = IF(@col_exists = 0, 'ALTER TABLE `products` ADD COLUMN `merchant_id` INT NULL AFTER `category_id`', 'SELECT 1');
PREPARE stmt FROM @query; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'pos_db' AND TABLE_NAME = 'transactions' AND COLUMN_NAME = 'merchant_id';
SET @query = IF(@col_exists = 0, 'ALTER TABLE `transactions` ADD COLUMN `merchant_id` INT NULL AFTER `customer_id`', 'SELECT 1');
PREPARE stmt FROM @query; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'pos_db' AND TABLE_NAME = 'transactions' AND COLUMN_NAME = 'customer_name';
SET @query = IF(@col_exists = 0, 'ALTER TABLE `transactions` ADD COLUMN `customer_name` VARCHAR(150) NULL AFTER `merchant_id`', 'SELECT 1');
PREPARE stmt FROM @query; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'pos_db' AND TABLE_NAME = 'transactions' AND COLUMN_NAME = 'customer_phone';
SET @query = IF(@col_exists = 0, 'ALTER TABLE `transactions` ADD COLUMN `customer_phone` VARCHAR(50) NULL AFTER `customer_name`', 'SELECT 1');
PREPARE stmt FROM @query; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'pos_db' AND TABLE_NAME = 'transactions' AND COLUMN_NAME = 'delivery_address';
SET @query = IF(@col_exists = 0, 'ALTER TABLE `transactions` ADD COLUMN `delivery_address` VARCHAR(255) NULL AFTER `customer_phone`', 'SELECT 1');
PREPARE stmt FROM @query; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 4. Insert 10 Merchant Accounts
INSERT INTO `merchant_accounts` (`id`, `account_name`, `email`, `phone`, `company_reg_number`, `status`)
VALUES
(1, 'Angkor Food & Heritage Group', 'angkor.heritage@gmail.com', '+855 23 881 111', 'AF-2026-001', 'ACTIVE'),
(2, 'Brown & Artisan Coffee Ventures', 'artisan.coffee@gmail.com', '+855 23 882 222', 'BC-2026-002', 'ACTIVE'),
(3, 'Smash & Patty Burger Labs', 'smash.burger@gmail.com', '+855 23 883 333', 'SB-2026-003', 'ACTIVE'),
(4, 'Royal Asian Noodle & Dim Sum Co.', 'asian.noodles@gmail.com', '+855 23 884 444', 'RN-2026-004', 'ACTIVE'),
(5, 'Tokyo Ramen & Sushi Masters', 'tokyo.izakaya@gmail.com', '+855 23 885 555', 'TR-2026-005', 'ACTIVE'),
(6, 'Bella Napoli Italian Cuisine', 'bella.napoli@gmail.com', '+855 23 886 666', 'BN-2026-006', 'ACTIVE'),
(7, 'Bangkok Wok & Night Market', 'bangkok.wok@gmail.com', '+855 23 887 777', 'BW-2026-007', 'ACTIVE'),
(8, 'Seoul K-Chicken & BBQ House', 'seoul.kchicken@gmail.com', '+855 23 888 888', 'SC-2026-008', 'ACTIVE'),
(9, 'Taj Mahal Spice & Biryani Palace', 'taj.spice@gmail.com', '+855 23 889 999', 'TM-2026-009', 'ACTIVE'),
(10, 'Green Vitality & Organic Kitchen', 'green.vitality@gmail.com', '+855 23 880 000', 'GV-2026-010', 'ACTIVE')
ON DUPLICATE KEY UPDATE `account_name` = VALUES(`account_name`);

-- 5. Insert Restaurants for each merchant account (22 Restaurants total)
INSERT INTO `merchants` (`id`, `account_id`, `name`, `khmer_name`, `cuisine`, `banner_url`, `logo_url`, `address`, `city`, `phone`, `rating`, `delivery_time_min`, `delivery_fee_usd`, `is_open`, `total_sales_usd`)
VALUES
-- Account 1: Angkor Food & Heritage (3 restaurants)
(1, 1, 'Angkor Authentic Kitchen', 'ផ្ទះបាយខ្មែរ អង្គរ', 'Traditional Khmer • Lok Lak & Amok', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200&q=80', 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=300&q=80', 'St 214, Daun Penh, Phnom Penh', 'Phnom Penh', '+855 23 219 900', 4.9, 20, 1.00, 1, 620.00),
(2, 1, 'Siem Reap Night BBQ & Grill', 'សាច់អាំង សៀមរាប ភ្នំពេញ', 'Khmer BBQ & Hotpot', 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=1200&q=80', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=300&q=80', 'St 360, BKK1, Phnom Penh', 'Phnom Penh', '+855 12 888 123', 4.8, 25, 1.25, 1, 480.00),
(3, 1, 'Tonle Sap River Fish & Crab', 'ត្រីអាំង និងក្តាមទន្លេសាប', 'Fresh River Seafood', 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=1200&q=80', 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=300&q=80', 'Sisowath Quay, Riverside, Phnom Penh', 'Phnom Penh', '+855 98 777 666', 4.7, 30, 1.50, 1, 390.00),

-- Account 2: Brown & Artisan Coffee (2 restaurants)
(4, 2, 'Mondulkiri Drip Coffee & Roastery', 'កាហ្វេតំណក់ មណ្ឌលគិរី', 'Drinks & Coffee', 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200&q=80', 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=300&q=80', 'Norodom Blvd, Daun Penh, Phnom Penh', 'Phnom Penh', '+855 23 555 444', 4.9, 15, 1.00, 1, 890.00),
(5, 2, 'French Butter Bakery & Croissant', 'នំបុ័ងខ្វាសុង ប៊័រស្រស់', 'Bakery & Dessert', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200&q=80', 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=300&q=80', 'St 57, BKK1, Phnom Penh', 'Phnom Penh', '+855 12 999 888', 4.9, 18, 1.00, 1, 540.00),

-- Account 3: Smash & Patty Burger (2 restaurants)
(6, 3, 'Wagyu Smash Burger Lab', 'ប៊ឺហ្គឺសាច់គោ វ៉ាហ្គ្យូ', 'Burgers & Fast Food', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=1200&q=80', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=80', 'St 271, Toul Kork, Phnom Penh', 'Phnom Penh', '+855 23 888 999', 4.8, 20, 1.25, 1, 710.00),
(7, 3, 'Crispy Golden Wings & Tenders', 'មាន់បំពងស្រួយ ភ្នំពេញ', 'Burgers & Fast Food', 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=1200&q=80', 'https://images.unsplash.com/photo-1562967914-608f82629710?w=300&q=80', 'St 199, Toul Tum Poung, Phnom Penh', 'Phnom Penh', '+855 12 333 444', 4.7, 22, 1.00, 1, 460.00),

-- Account 4: Royal Asian Noodle & Dim Sum (2 restaurants)
(8, 4, 'Phnom Penh Kuy Teav Master', 'គុយទាវភ្នំពេញ ដើមដើម', 'Khmer Food • Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=1200&q=80', 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=300&q=80', 'Central Market, Daun Penh, Phnom Penh', 'Phnom Penh', '+855 12 444 555', 4.9, 15, 1.00, 1, 930.00),
(9, 4, 'Hong Kong Dim Sum & Dumpling House', 'ឌីមសាំ ហុងកុង', 'Asian Specialties • Dim Sum', 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=1200&q=80', 'https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=300&q=80', 'Monivong Blvd, BKK2, Phnom Penh', 'Phnom Penh', '+855 23 777 888', 4.8, 25, 1.25, 1, 620.00),

-- Account 5: Tokyo Ramen & Sushi (2 restaurants)
(10, 5, 'Sakura Tonkotsu Ramen House', 'រ៉ាមេន សាគូរ៉ា ជប៉ុន', 'Japanese Artisan • Ramen', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=1200&q=80', 'https://images.unsplash.com/photo-1557872943-16a5ac26437e?w=300&q=80', 'St 302, BKK1, Phnom Penh', 'Phnom Penh', '+855 23 999 111', 4.9, 25, 1.50, 1, 880.00),
(11, 5, 'Torched Salmon & Sushi Bar', 'ស៊ូស៊ី និងត្រីសាម៉ុងស្រស់', 'Japanese Artisan • Sushi', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=1200&q=80', 'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=300&q=80', 'St 288, BKK1, Phnom Penh', 'Phnom Penh', '+855 12 666 555', 4.9, 30, 2.00, 1, 750.00),

-- Account 6: Bella Napoli Italian (2 restaurants)
(12, 6, 'La Bella Napoli Sourdough Pizza', 'ភីហ្សា អ៊ីតាលី ប៉េបប៉េរ៉ូនី', 'Italian Artisan • Pizza', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=1200&q=80', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=300&q=80', 'St 310, BKK1, Phnom Penh', 'Phnom Penh', '+855 23 888 777', 4.8, 25, 1.25, 1, 640.00),
(13, 6, 'Handcrafted Truffle Pasta House', 'ប៉ាស្តាស្រស់ ត្រាហ្វល', 'Italian Artisan • Pasta', 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1200&q=80', 'https://images.unsplash.com/photo-1621996346565-e3d5d628169e?w=300&q=80', 'St 294, BKK1, Phnom Penh', 'Phnom Penh', '+855 23 444 333', 4.8, 25, 1.50, 1, 520.00),

-- Account 7: Bangkok Wok Street Food (2 restaurants)
(14, 7, 'Siam Street Pad Thai & Tom Yum', 'ផាត់ថៃ & ស្ងោរតុងយ៉ាំ', 'Thai Street Wok', 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=1200&q=80', 'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=300&q=80', 'St 51, Daun Penh, Phnom Penh', 'Phnom Penh', '+855 12 777 999', 4.8, 20, 1.00, 1, 590.00),
(15, 7, 'Crispy Pork Belly & Basil Rice', 'បាយសាច់ជ្រូកបំពង កាផាវ', 'Thai Street Wok', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=1200&q=80', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&q=80', 'St 178, Daun Penh, Phnom Penh', 'Phnom Penh', '+855 12 888 000', 4.7, 18, 1.00, 1, 470.00),

-- Account 8: Seoul K-Chicken & BBQ (2 restaurants)
(16, 8, 'Seoul Crispy K-Chicken & Beer', 'មាន់បំពងកូរ៉េ ស្រួយឆ្ងាញ់', 'Korean Fried Chicken', 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=1200&q=80', 'https://images.unsplash.com/photo-1562967914-608f82629710?w=300&q=80', 'St 63, BKK1, Phnom Penh', 'Phnom Penh', '+855 23 666 888', 4.9, 20, 1.25, 1, 810.00),
(17, 8, 'K-Street Tteokbokki & Bibimbap', 'ថុកបូគី & ប៊ីប៊ីមបាប់ ក្តៅៗ', 'Korean Comfort Dishes', 'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=1200&q=80', 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=300&q=80', 'St 334, BKK1, Phnom Penh', 'Phnom Penh', '+855 12 999 111', 4.7, 22, 1.00, 1, 490.00),

-- Account 9: Taj Mahal Spice Palace (2 restaurants)
(18, 9, 'Taj Mahal Butter Chicken & Naan', 'ការីឥណ្ឌា និងនំប៉័ងណាន', 'Indian Specialties • Curry', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=1200&q=80', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300&q=80', 'St 130, Daun Penh, Phnom Penh', 'Phnom Penh', '+855 23 333 222', 4.8, 25, 1.25, 1, 560.00),
(19, 9, 'Royal Dum Biryani Claypots', 'បាយប៊ីរីយ៉ានី ឆ្នាំងដី', 'Indian Specialties • Biryani', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=1200&q=80', 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=300&q=80', 'St 214, Daun Penh, Phnom Penh', 'Phnom Penh', '+855 12 222 333', 4.8, 30, 1.50, 1, 480.00),

-- Account 10: Green Vitality & Organic (2 restaurants)
(20, 10, 'Green Vitality Salad & Salmon Poke', 'សាឡាដ & ផូកប៊ូលសាម៉ុង', 'Healthy & Superfood Bowls', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200&q=80', 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&q=80', 'St 306, BKK1, Phnom Penh', 'Phnom Penh', '+855 23 111 222', 4.9, 15, 1.00, 1, 670.00),
(21, 10, 'Tropical Açaí & Cold-Pressed Juice', 'ទឹកផ្លែឈើស្រស់ & អាសៃ', 'Smoothies & Fresh Juices', 'https://images.unsplash.com/photo-1505253758473-96b3015f240a?w=1200&q=80', 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=300&q=80', 'St 57, BKK1, Phnom Penh', 'Phnom Penh', '+855 12 111 000', 4.9, 15, 1.00, 1, 530.00)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `cuisine` = VALUES(`cuisine`), `rating` = VALUES(`rating`);

-- 6. Update existing products (1..12) with merchant_ids
UPDATE `products` SET `merchant_id` = 4 WHERE `id` IN (1, 2, 3);   -- Mondulkiri Coffee
UPDATE `products` SET `merchant_id` = 6 WHERE `id` IN (4, 5);      -- Wagyu Burger
UPDATE `products` SET `merchant_id` = 5 WHERE `id` IN (6, 7, 10);  -- French Bakery
UPDATE `products` SET `merchant_id` = 1 WHERE `id` IN (8, 9);      -- Angkor Kitchen
UPDATE `products` SET `merchant_id` = 2 WHERE `id` = 11;           -- Siem Reap BBQ
UPDATE `products` SET `merchant_id` = 20 WHERE `id` = 12;          -- Organic Market

-- 7. Insert over 60+ new dishes across all 22 restaurants for an endless scroll menu!
INSERT INTO `products` (`category_id`, `merchant_id`, `name`, `khmer_name`, `barcode`, `cost_price`, `selling_price`, `stock_quantity`, `low_stock_threshold`, `image_url`, `status`)
VALUES
-- Restaurant 1: Angkor Authentic Kitchen (Khmer Food - category 4)
(4, 1, 'Traditional Fish Amok in Coconut', 'អាម៉ុកត្រីដូងខ្ចី', '8850201001', 2.50, 5.75, 50, 10, 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80', 'ACTIVE'),
(4, 1, 'Kampot Pepper Beef Lok Lak Set', 'ឡុកឡាក់សាច់គោម្រេចកំពត', '8850201002', 2.80, 6.25, 45, 10, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80', 'ACTIVE'),
(4, 1, 'Siem Reap Grilled Chicken with Sticky Rice', 'មាន់អាំងបាយដំណើប', '8850201003', 3.00, 6.50, 30, 10, 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500&q=80', 'ACTIVE'),
(4, 1, 'Crispy Fried Spring Rolls (4 pcs)', 'ណែមបំពងស្រួយ', '8850201004', 1.20, 2.75, 60, 10, 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&q=80', 'ACTIVE'),

-- Restaurant 2: Siem Reap Night BBQ
(4, 2, 'Charcoal Pork Skewers with Pickles (5 pcs)', 'សាច់ជ្រូកចង្កាក់អាំងជ្រក់', '8850202001', 1.80, 4.00, 60, 10, 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80', 'ACTIVE'),
(4, 2, 'Grilled Beef with Teuk Prahok Dip', 'សាច់គោអាំងទឹកប្រហុក', '8850202002', 3.20, 6.75, 40, 10, 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500&q=80', 'ACTIVE'),
(4, 2, 'Mekong River Prawn Skewers', 'បង្កងទន្លេអាំងអំបិលម្ទេស', '8850202003', 4.00, 8.50, 25, 10, 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&q=80', 'ACTIVE'),

-- Restaurant 3: Tonle Sap River Fish & Crab
(4, 3, 'Steamed Kep Flower Crab (3 pcs)', 'ក្តាមសេះកែប ចំហុយ', '8850203001', 4.50, 9.50, 20, 5, 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80', 'ACTIVE'),
(4, 3, 'Deep-Fried River Elephant Fish', 'ត្រីដំរីបំពងជូរអែម', '8850203002', 3.80, 7.80, 18, 5, 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&q=80', 'ACTIVE'),
(4, 3, 'Sour Spicy Seafood Soup (Tom Yum)', 'សម្លម្ជូរគ្រឿងគ្រឿងសមុទ្រ', '8850203003', 2.80, 5.50, 35, 10, 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80', 'ACTIVE'),

-- Restaurant 4: Mondulkiri Drip Coffee (Drinks - category 1)
(1, 4, 'Signature Mondulkiri Iced Latte', 'ឡាតេទឹកកក កាហ្វេមណ្ឌលគិរី', '8850204001', 1.00, 2.50, 100, 20, 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=500&q=80', 'ACTIVE'),
(1, 4, 'Traditional Condensed Milk Iced Coffee', 'កាហ្វេទឹកដោះគោទឹកកកពិសេស', '8850204002', 0.80, 2.00, 120, 20, 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500&q=80', 'ACTIVE'),
(1, 4, 'Salted Caramel Cold Brew', 'ខូលប៊្រូ ខារ៉ាមែលប្រៃ', '8850204003', 1.30, 3.25, 80, 15, 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500&q=80', 'ACTIVE'),
(1, 4, 'Iced Green Tea Coconut Cream', 'តែបៃតងដូងក្រអូប', '8850204004', 1.10, 2.75, 90, 15, 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500&q=80', 'ACTIVE'),

-- Restaurant 5: French Butter Bakery (Bakery - category 3)
(3, 5, 'Golden Flaky French Croissant', 'នំបុ័ងខ្វាសុង ប៊័រស្រស់បារាំង', '8850205001', 0.90, 2.25, 60, 10, 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&q=80', 'ACTIVE'),
(3, 5, 'Pain au Chocolat (Dark Belgian Chocolate)', 'នំសូកូឡាប៉ាំងអូសូកូឡា', '8850205002', 1.10, 2.65, 50, 10, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&q=80', 'ACTIVE'),
(3, 5, 'Strawberry Vanilla Choux Cream', 'នំស៊ូក្រែម ស្រ្តប៊ឺរីវ៉ានីឡា', '8850205003', 1.30, 3.00, 40, 10, 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&q=80', 'ACTIVE'),

-- Restaurant 6: Wagyu Smash Burger (Burgers - category 2)
(2, 6, 'Double Truffle Wagyu Smash Burger', 'ប៊ឺហ្គឺសាច់គោវ៉ាហ្គ្យូ ត្រាហ្វល', '8850206001', 3.50, 7.50, 40, 10, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80', 'ACTIVE'),
(2, 6, 'Bacon Avocado Cheddar Smash', 'ប៊ឺហ្គឺសាច់គោ បែកខិនប័រ', '8850206002', 3.20, 6.95, 45, 10, 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&q=80', 'ACTIVE'),
(2, 6, 'Loaded Cheese Truffle Fries', 'ដំឡូងបារាំងបំពង ឈីសត្រាហ្វល', '8850206003', 1.50, 3.75, 70, 15, 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&q=80', 'ACTIVE'),

-- Restaurant 7: Crispy Golden Wings
(2, 7, 'Nashville Hot Fried Chicken Burger', 'ប៊ឺហ្គឺមាន់បំពងហិរណាស្វិល', '8850207001', 2.50, 5.50, 50, 10, 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&q=80', 'ACTIVE'),
(2, 7, 'Garlic Parmesan Crispy Wings (6 pcs)', 'ស្លាបមាន់បំពង ខ្ទឹមសឈីស', '8850207002', 2.00, 4.80, 65, 15, 'https://images.unsplash.com/photo-1562967914-608f82629710?w=500&q=80', 'ACTIVE'),
(2, 7, 'Honey Butter Tenders Basket (4 pcs)', 'សាច់មាន់បំពង ទឹកឃ្មុំប៊័រ', '8850207003', 1.80, 4.25, 55, 10, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80', 'ACTIVE'),

-- Restaurant 8: Phnom Penh Kuy Teav Master (Khmer Noodles)
(4, 8, 'Special Seafood Pork Kuy Teav Soup', 'គុយទាវភ្នំពេញ គ្រឿងសមុទ្រពិសេស', '8850208001', 1.60, 3.80, 80, 15, 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80', 'ACTIVE'),
(4, 8, 'Dry Kuy Teav with Rich Broth Bowl', 'គុយទាវគោក ភ្នំពេញ', '8850208002', 1.60, 3.80, 75, 15, 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=500&q=80', 'ACTIVE'),
(4, 8, 'Braised Beef Noodle Soup', 'មីស៊ុបសាច់គោខ', '8850208003', 1.80, 4.20, 60, 10, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80', 'ACTIVE'),

-- Restaurant 9: Hong Kong Dim Sum
(4, 9, 'Steamed Pork & Prawn Siu Mai (4 pcs)', 'ស៊ីវម៉ៃសាច់ជ្រូក បង្គា', '8850209001', 1.20, 2.95, 60, 10, 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=500&q=80', 'ACTIVE'),
(4, 9, 'Crystal Prawn Dumplings Har Gow (4 pcs)', 'ហាកាវបង្គាស្រស់', '8850209002', 1.40, 3.25, 50, 10, 'https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=500&q=80', 'ACTIVE'),
(4, 9, 'Steamed BBQ Pork Char Siu Bao (3 pcs)', 'នំប៉ាវសាច់ជ្រូកខ្វៃ', '8850209003', 1.10, 2.50, 50, 10, 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=500&q=80', 'ACTIVE'),

-- Restaurant 10: Sakura Tonkotsu Ramen House (Japanese)
(4, 10, 'Signature Black Garlic Tonkotsu Ramen', 'រ៉ាមេនខ្ទឹមសខ្មៅ ទំពាំងសាច់ជ្រូក', '8850210001', 3.20, 7.50, 45, 10, 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80', 'ACTIVE'),
(4, 10, 'Spicy Miso Ramen with Chashu', 'រ៉ាមេនមីស៊ូហិរ សាច់ជ្រូកចាស្ស៊ូ', '8850210002', 3.00, 7.00, 50, 10, 'https://images.unsplash.com/photo-1557872943-16a5ac26437e?w=500&q=80', 'ACTIVE'),
(4, 10, 'Crispy Japanese Pan Gyoza (6 pcs)', 'គាវបំពងជប៉ុន ហ្គីយ៉ូហ្សា', '8850210003', 1.20, 3.20, 60, 10, 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=500&q=80', 'ACTIVE'),

-- Restaurant 11: Torched Salmon & Sushi Bar
(4, 11, 'Torched Aburi Salmon Cheese Roll (8 pcs)', 'ស៊ូស៊ីត្រីសាម៉ុង ដុតឈីស', '8850211001', 3.80, 8.50, 35, 10, 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80', 'ACTIVE'),
(4, 11, 'Fresh Atlantic Salmon Sashimi (5 pcs)', 'សាច់ត្រីសាម៉ុងឆៅ អាត្លង់ទិក', '8850211002', 3.50, 7.80, 40, 10, 'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=500&q=80', 'ACTIVE'),
(4, 11, 'Crunchy California Prawn Tempura Roll', 'កាលីហ្វ័រញ៉ារ៉ូល បង្គាបំពង', '8850211003', 2.80, 6.20, 45, 10, 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80', 'ACTIVE'),

-- Restaurant 12: La Bella Napoli Sourdough Pizza
(2, 12, 'Spicy Beef Pepperoni Sourdough Pizza', 'ភីហ្សា ប៉េបប៉េរ៉ូនីសាច់គោ', '8850212001', 4.00, 8.95, 30, 5, 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80', 'ACTIVE'),
(2, 12, 'Classic Margherita Buffalo Mozzarella', 'ភីហ្សា ម៉ាហ្គារីតា ឈីសស្រស់', '8850212002', 3.50, 7.50, 35, 5, 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&q=80', 'ACTIVE'),
(2, 12, 'Four Cheese Quattro Formaggi Pizza', 'ភីហ្សា ឈីស៤មុខ', '8850212003', 4.20, 9.50, 25, 5, 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80', 'ACTIVE'),

-- Restaurant 13: Handcrafted Truffle Pasta House
(2, 13, 'Black Truffle Wild Mushroom Fettuccine', 'ប៉ាស្តាផ្សិត ទឹកជ្រលក់ត្រាហ្វល', '8850213001', 3.50, 7.80, 30, 5, 'https://images.unsplash.com/photo-1621996346565-e3d5d628169e?w=500&q=80', 'ACTIVE'),
(2, 13, 'Classic Creamy Carbonara with Pancetta', 'ប៉ាស្តា កាបូណារ៉ា សាច់ជ្រូកបំពង', '8850213002', 3.00, 6.95, 35, 5, 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80', 'ACTIVE'),

-- Restaurant 14: Siam Street Pad Thai & Tom Yum
(4, 14, 'Bangkok Jumbo Prawn Pad Thai', 'ផាត់ថៃ បង្គាធំ បាងកក', '8850214001', 2.00, 4.75, 55, 10, 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=500&q=80', 'ACTIVE'),
(4, 14, 'Seafood Tom Yum Goong Soup Bowl', 'ស្ងោរតុងយ៉ាំគ្រឿងសមុទ្រ ក្តៅៗ', '8850214002', 2.20, 5.25, 45, 10, 'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=500&q=80', 'ACTIVE'),

-- Restaurant 15: Crispy Pork Belly & Basil Rice
(4, 15, 'Crispy Pork Belly Holy Basil (Pad Kra Pao)', 'បាយសាច់ជ្រូកបំពង កាផាវ ពងទាចៀន', '8850215001', 1.80, 4.25, 60, 10, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&q=80', 'ACTIVE'),
(4, 15, 'Green Curry Chicken with Jasmine Rice', 'ការីបៃតងសាច់មាន់ ថៃ', '8850215002', 2.00, 4.80, 50, 10, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80', 'ACTIVE'),

-- Restaurant 16: Seoul Crispy K-Chicken & Beer
(2, 16, 'Sweet & Spicy Yangnyeom K-Chicken (8 pcs)', 'មាន់បំពងកូរ៉េ ទឹកជ្រលក់ហិរផ្អែម', '8850216001', 2.80, 6.50, 40, 10, 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&q=80', 'ACTIVE'),
(2, 16, 'Honey Butter Garlic Fried Chicken', 'មាន់បំពងកូរ៉េ ខ្ទឹមសទឹកឃ្មុំ', '8850216002', 2.80, 6.50, 45, 10, 'https://images.unsplash.com/photo-1562967914-608f82629710?w=500&q=80', 'ACTIVE'),

-- Restaurant 17: K-Street Tteokbokki & Bibimbap
(4, 17, 'Spicy Cheese Tteokbokki Rice Cake', 'ថុកបូគី បន្ទះអង្ករកូរ៉េដុតឈីស', '8850217001', 1.60, 3.80, 50, 10, 'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=500&q=80', 'ACTIVE'),
(4, 17, 'Beef Bulgogi Dolsot Bibimbap', 'ប៊ីប៊ីមបាប់សាច់គោ កូរ៉េ', '8850217002', 2.20, 5.25, 45, 10, 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500&q=80', 'ACTIVE'),

-- Restaurant 18: Taj Mahal Butter Chicken & Naan
(4, 18, 'Creamy Butter Chicken Curry Pot', 'ការីសាច់មាន់ប៊័រ ឥណ្ឌា', '8850218001', 2.80, 6.50, 35, 10, 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&q=80', 'ACTIVE'),
(4, 18, 'Fresh Garlic Butter Naan (2 pcs)', 'នំប៉័ងណាន ខ្ទឹមសប៊័រ', '8850218002', 0.80, 2.00, 80, 15, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500&q=80', 'ACTIVE'),

-- Restaurant 19: Royal Dum Biryani Claypots
(4, 19, 'Hyderabadi Chicken Dum Biryani', 'បាយប៊ីរីយ៉ានីសាច់មាន់ ឆ្នាំងដី', '8850219001', 2.80, 6.20, 40, 10, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&q=80', 'ACTIVE'),
(4, 19, 'Slow-Cooked Mutton Biryani', 'បាយប៊ីរីយ៉ានីសាច់ចៀម', '8850219002', 3.50, 7.80, 30, 5, 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=500&q=80', 'ACTIVE'),

-- Restaurant 20: Green Vitality Salad & Salmon Poke
(5, 20, 'Norwegian Salmon Avocado Poke Bowl', 'ផូកប៊ូលសាម៉ុង ប័រ និងពងត្រី', '8850220001', 3.20, 6.95, 35, 10, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80', 'ACTIVE'),
(5, 20, 'Grilled Chicken Quinoa Superfood Salad', 'សាឡាដមាន់អាំង គីន័រ', '8850220002', 2.40, 5.50, 40, 10, 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&q=80', 'ACTIVE'),

-- Restaurant 21: Tropical Açaí & Cold-Pressed Juice
(1, 21, 'Amazonian Superfood Açaí Berry Bowl', 'អាសៃប៊ូល ផ្លែប៊ឺរី និងចេកស្រស់', '8850221001', 1.80, 4.50, 45, 10, 'https://images.unsplash.com/photo-1505253758473-96b3015f240a?w=500&q=80', 'ACTIVE'),
(1, 21, 'Cold-Pressed Green Detox Cleanser', 'ទឹកបន្លែផ្លែឈើបន្សាបជាតិពុល', '8850221002', 1.20, 2.95, 60, 15, 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=500&q=80', 'ACTIVE')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `selling_price` = VALUES(`selling_price`), `merchant_id` = VALUES(`merchant_id`);

-- 8. Assign existing transactions to Merchant 1
UPDATE `transactions` SET `merchant_id` = 1, `delivery_address` = 'House 42, St 271, Boeng Tumpun, Phnom Penh' WHERE `merchant_id` IS NULL;
