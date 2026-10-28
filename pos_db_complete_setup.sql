-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: pos_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `pos_db`
--

/*!40000 DROP DATABASE IF EXISTS `pos_db`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `pos_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `pos_db`;

--
-- Table structure for table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actor_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'System',
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_logs`
--

LOCK TABLES `activity_logs` WRITE;
/*!40000 ALTER TABLE `activity_logs` DISABLE KEYS */;
INSERT INTO `activity_logs` VALUES (1,'System','System Startup','POS System initialized. MySQL Database connected.','2026-10-26 20:29:11'),(2,'Vannak Heng','User Login','Vannak Heng logged in as System Admin.','2026-10-26 20:29:11'),(3,'Sreylis Sinoun','Sale Completed','INV-20261026-001 - $11.88 via Bakong KHQR (បាគង)','2026-10-26 20:29:11');
/*!40000 ALTER TABLE `activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `khmer_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'category',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Drinks & Coffee','ភេសជ្ជៈ និងកាហ្វេ','local_cafe','2026-10-26 20:29:10'),(2,'Burgers & Fast Food','ប៊ឺហ្គឺ និងអាហាររហ័ស','lunch_dining','2026-10-26 20:29:10'),(3,'Bakery & Dessert','នំបុ័ង និងបង្អែម','cake','2026-10-26 20:29:10'),(4,'Khmer Food','ម្ហូបខ្មែរ','ramen_dining','2026-10-26 20:29:10'),(5,'Snacks & Bites','ចំណីសម្រន់','fastfood','2026-10-26 20:29:10'),(6,'Grocery & Retail','ទំនិញទូទៅ','shopping_bag','2026-10-26 20:29:10');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_addresses`
--

DROP TABLE IF EXISTS `customer_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `label` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_line` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'Phnom Penh',
  `is_default` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `customer_addresses_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_addresses`
--

LOCK TABLES `customer_addresses` WRITE;
/*!40000 ALTER TABLE `customer_addresses` DISABLE KEYS */;
INSERT INTO `customer_addresses` VALUES (1,1,'Home','House 14, St 214, Daun Penh, Phnom Penh','Phnom Penh',1,'2026-10-27 22:57:32'),(2,1,'Office','Canadia Tower, Floor 14, St 102, Phnom Penh','Phnom Penh',0,'2026-10-27 22:57:32'),(3,2,'Home','Condo 802, The Bridge, Tonle Bassac, Phnom Penh','Phnom Penh',1,'2026-10-27 22:57:32'),(4,3,'Home','House 42, St 271, Boeng Tumpun, Phnom Penh','Phnom Penh',1,'2026-10-27 22:57:32'),(5,3,'Work','Exchange Square, Floor 8, Daun Penh, Phnom Penh','Phnom Penh',0,'2026-10-27 22:57:32');
/*!40000 ALTER TABLE `customer_addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `membership_tier` enum('REGULAR','SILVER','GOLD','VIP') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'REGULAR',
  `loyalty_points` int NOT NULL DEFAULT '0',
  `total_spent` decimal(12,2) NOT NULL DEFAULT '0.00',
  `joined_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '123456',
  `default_address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'House 42, St 271, Boeng Tumpun, Phnom Penh',
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone` (`phone`),
  KEY `idx_customer_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Sokha Chan (ចាន់ សុខា)','012 889 977','sokha.chan@gmail.com','VIP',340,480.50,'2025-03-10','2026-10-26 20:29:10','123456','House 42, St 271, Boeng Tumpun, Phnom Penh'),(2,'Dara Lim (លីម ដារ៉ា)','098 765 432','dara.lim@yahoo.com','GOLD',195,260.00,'2025-06-18','2026-10-26 20:29:10','123456','House 42, St 271, Boeng Tumpun, Phnom Penh'),(3,'Bopha Pich (ពេជ្រ បុប្ផា)','010 334 556','bopha.pich@outlook.com','SILVER',80,110.00,'2026-01-05','2026-10-26 20:29:10','123456','House 42, St 271, Boeng Tumpun, Phnom Penh'),(4,'Sreylis Sinoun (???????)','011 223 344','sreylis@foodkh.com','REGULAR',25,0.00,'2026-10-27','2026-10-27 22:11:27','secretpassword','St 2004, Sen Sok, Phnom Penh'),(5,'sinoun','011111111','sinoun@gmail.com','REGULAR',25,0.00,'2026-10-27','2026-10-27 22:32:52','123456','Phnom Penh');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_drivers`
--

DROP TABLE IF EXISTS `delivery_drivers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_drivers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `driver_code` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `khmer_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vehicle_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'Motorcycle (ម៉ូតូ)',
  `vehicle_plate` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` decimal(3,2) DEFAULT '4.90',
  `total_deliveries` int DEFAULT '120',
  `status` enum('AVAILABLE','DELIVERING','OFFLINE') COLLATE utf8mb4_unicode_ci DEFAULT 'AVAILABLE',
  `photo_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `driver_code` (`driver_code`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_drivers`
--

LOCK TABLES `delivery_drivers` WRITE;
/*!40000 ALTER TABLE `delivery_drivers` DISABLE KEYS */;
INSERT INTO `delivery_drivers` VALUES (1,'DRV-001','Sokha Chea','ជា សុខា','+855 12 345 678','Honda Dream 125','Phnom Penh 1AB-2345',4.95,342,'AVAILABLE','https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200','2026-10-27 22:57:32'),(2,'DRV-002','Dara Vong','វង្ស ដារ៉ា','+855 98 765 432','Honda Scoopy 110','Phnom Penh 1BC-6789',4.88,280,'AVAILABLE','https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200','2026-10-27 22:57:32'),(3,'DRV-003','Piseth Mao','ម៉ៅ ពិសិដ្ឋ','+855 10 998 877','Yamaha Aerox 155','Phnom Penh 1CD-4567',4.92,195,'AVAILABLE','https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200','2026-10-27 22:57:32'),(4,'DRV-004','Chantrea Meas','មាស ច័ន្ទទ្រា','+855 11 223 344','Suzuki Viva 115','Phnom Penh 1EF-8910',4.85,150,'AVAILABLE','https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200','2026-10-27 22:57:32');
/*!40000 ALTER TABLE `delivery_drivers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pin_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1234',
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('ADMIN','MANAGER','CASHIER','INVENTORY_STAFF') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'CASHIER',
  `monthly_salary` decimal(10,2) NOT NULL DEFAULT '350.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'Vannak Heng (Admin)','admin@pos.com','$2a$10$abcdefghijklmnopqrstuvwxyz123456AdminHash','1234','012 345 678','ADMIN',850.00,1,'2026-10-26 20:29:10','2026-10-26 20:29:10'),(2,'Sreylis Sinoun (Cashier)','cashier@pos.com','$2a$10$abcdefghijklmnopqrstuvwxyz123456CashierHash','1234','097 554 321','CASHIER',380.00,1,'2026-10-26 20:29:10','2026-10-26 20:29:10'),(3,'Rithy Seng (Stock Keeper)','inventory@pos.com','$2a$10$abcdefghijklmnopqrstuvwxyz123456StaffHash','1234','088 123 999','INVENTORY_STAFF',420.00,1,'2026-10-26 20:29:10','2026-10-26 20:29:10');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant_accounts`
--

DROP TABLE IF EXISTS `merchant_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant_accounts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `account_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `company_reg_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'MO-2026-98102',
  `status` enum('ACTIVE','SUSPENDED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '123456',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant_accounts`
--

LOCK TABLES `merchant_accounts` WRITE;
/*!40000 ALTER TABLE `merchant_accounts` DISABLE KEYS */;
INSERT INTO `merchant_accounts` VALUES (1,'Angkor Food & Heritage Group','angkor.heritage@gmail.com','+855 23 881 111','AF-2026-001','ACTIVE','2026-10-27 02:44:51','123456'),(2,'Brown & Artisan Coffee Ventures','artisan.coffee@gmail.com','+855 23 882 222','BC-2026-002','ACTIVE','2026-10-27 02:44:51','123456'),(3,'Smash & Patty Burger Labs','smash.burger@gmail.com','+855 23 883 333','SB-2026-003','ACTIVE','2026-10-27 02:44:51','123456'),(4,'Royal Asian Noodle & Dim Sum Co.','asian.noodles@gmail.com','+855 23 884 444','RN-2026-004','ACTIVE','2026-10-27 02:44:51','123456'),(5,'Tokyo Ramen & Sushi Masters','tokyo.izakaya@gmail.com','+855 23 885 555','TR-2026-005','ACTIVE','2026-10-27 02:44:51','123456'),(6,'Bella Napoli Italian Cuisine','bella.napoli@gmail.com','+855 23 886 666','BN-2026-006','ACTIVE','2026-10-27 02:44:51','123456'),(7,'Bangkok Wok & Night Market','bangkok.wok@gmail.com','+855 23 887 777','BW-2026-007','ACTIVE','2026-10-27 02:44:51','123456'),(8,'Seoul K-Chicken & BBQ House','seoul.kchicken@gmail.com','+855 23 888 888','SC-2026-008','ACTIVE','2026-10-27 02:44:51','123456'),(9,'Taj Mahal Spice & Biryani Palace','taj.spice@gmail.com','+855 23 889 999','TM-2026-009','ACTIVE','2026-10-27 02:44:51','123456'),(10,'Green Vitality & Organic Kitchen','green.vitality@gmail.com','+855 23 880 000','GV-2026-010','ACTIVE','2026-10-27 02:44:51','123456');
/*!40000 ALTER TABLE `merchant_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchants`
--

DROP TABLE IF EXISTS `merchants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `account_id` int NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `khmer_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cuisine` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `banner_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `logo_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'Phnom Penh',
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` decimal(3,1) DEFAULT '4.8',
  `delivery_time_min` int DEFAULT '20',
  `delivery_fee_usd` decimal(10,2) DEFAULT '1.00',
  `is_open` tinyint(1) DEFAULT '1',
  `total_sales_usd` decimal(12,2) DEFAULT '0.00',
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_account` (`account_id`),
  CONSTRAINT `fk_merchant_account` FOREIGN KEY (`account_id`) REFERENCES `merchant_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchants`
--

LOCK TABLES `merchants` WRITE;
/*!40000 ALTER TABLE `merchants` DISABLE KEYS */;
INSERT INTO `merchants` VALUES (1,1,'Angkor Authentic Kitchen','ផ្ទះបាយខ្មែរ អង្គរ','Traditional Khmer • Lok Lak & Amok','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200&q=80','https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=300&q=80','St 214, Daun Penh, Phnom Penh','Phnom Penh','+855 23 219 900',4.9,20,1.00,1,644.75,'ACTIVE','2026-10-27 02:44:51'),(2,1,'Siem Reap Night BBQ & Grill','សាច់អាំង សៀមរាប ភ្នំពេញ','Khmer BBQ & Hotpot','https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=1200&q=80','https://images.unsplash.com/photo-1544025162-d76694265947?w=300&q=80','St 360, BKK1, Phnom Penh','Phnom Penh','+855 12 888 123',4.8,25,1.25,1,480.00,'ACTIVE','2026-10-27 02:44:51'),(3,1,'Tonle Sap River Fish & Crab','ត្រីអាំង និងក្តាមទន្លេសាប','Fresh River Seafood','https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=1200&q=80','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=300&q=80','Sisowath Quay, Riverside, Phnom Penh','Phnom Penh','+855 98 777 666',4.7,30,1.50,1,390.00,'ACTIVE','2026-10-27 02:44:51'),(4,2,'Mondulkiri Drip Coffee & Roastery','កាហ្វេតំណក់ មណ្ឌលគិរី','Drinks & Coffee','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200&q=80','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=300&q=80','Norodom Blvd, Daun Penh, Phnom Penh','Phnom Penh','+855 23 555 444',4.9,15,1.00,1,890.00,'ACTIVE','2026-10-27 02:44:51'),(5,2,'French Butter Bakery & Croissant','នំបុ័ងខ្វាសុង ប៊័រស្រស់','Bakery & Dessert','https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200&q=80','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=300&q=80','St 57, BKK1, Phnom Penh','Phnom Penh','+855 12 999 888',4.9,18,1.00,1,550.00,'ACTIVE','2026-10-27 02:44:51'),(6,3,'Wagyu Smash Burger Lab','ប៊ឺហ្គឺសាច់គោ វ៉ាហ្គ្យូ','Burgers & Fast Food','https://images.unsplash.com/photo-1550547660-d9450f859349?w=1200&q=80','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=80','St 271, Toul Kork, Phnom Penh','Phnom Penh','+855 23 888 999',4.8,20,1.25,1,710.00,'ACTIVE','2026-10-27 02:44:51'),(7,3,'Crispy Golden Wings & Tenders','មាន់បំពងស្រួយ ភ្នំពេញ','Burgers & Fast Food','https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=1200&q=80','https://images.unsplash.com/photo-1562967914-608f82629710?w=300&q=80','St 199, Toul Tum Poung, Phnom Penh','Phnom Penh','+855 12 333 444',4.7,22,1.00,1,477.50,'ACTIVE','2026-10-27 02:44:51'),(8,4,'Phnom Penh Kuy Teav Master','គុយទាវភ្នំពេញ ដើមដើម','Khmer Food • Noodles','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=1200&q=80','https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=300&q=80','Central Market, Daun Penh, Phnom Penh','Phnom Penh','+855 12 444 555',4.9,15,1.00,1,930.00,'ACTIVE','2026-10-27 02:44:51'),(9,4,'Hong Kong Dim Sum & Dumpling House','ឌីមសាំ ហុងកុង','Asian Specialties • Dim Sum','https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=1200&q=80','https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=300&q=80','Monivong Blvd, BKK2, Phnom Penh','Phnom Penh','+855 23 777 888',4.8,25,1.25,1,620.00,'ACTIVE','2026-10-27 02:44:51'),(10,5,'Sakura Tonkotsu Ramen House','រ៉ាមេន សាគូរ៉ា ជប៉ុន','Japanese Artisan • Ramen','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=1200&q=80','https://images.unsplash.com/photo-1557872943-16a5ac26437e?w=300&q=80','St 302, BKK1, Phnom Penh','Phnom Penh','+855 23 999 111',4.9,25,1.50,1,880.00,'ACTIVE','2026-10-27 02:44:51'),(11,5,'Torched Salmon & Sushi Bar','ស៊ូស៊ី និងត្រីសាម៉ុងស្រស់','Japanese Artisan • Sushi','https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=1200&q=80','https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=300&q=80','St 288, BKK1, Phnom Penh','Phnom Penh','+855 12 666 555',4.9,30,2.00,1,750.00,'ACTIVE','2026-10-27 02:44:51'),(12,6,'La Bella Napoli Sourdough Pizza','ភីហ្សា អ៊ីតាលី ប៉េបប៉េរ៉ូនី','Italian Artisan • Pizza','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=1200&q=80','https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=300&q=80','St 310, BKK1, Phnom Penh','Phnom Penh','+855 23 888 777',4.8,25,1.25,1,640.00,'ACTIVE','2026-10-27 02:44:51'),(13,6,'Handcrafted Truffle Pasta House','ប៉ាស្តាស្រស់ ត្រាហ្វល','Italian Artisan • Pasta','https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1200&q=80','https://images.unsplash.com/photo-1621996346565-e3d5d628169e?w=300&q=80','St 294, BKK1, Phnom Penh','Phnom Penh','+855 23 444 333',4.8,25,1.50,1,520.00,'ACTIVE','2026-10-27 02:44:51'),(14,7,'Siam Street Pad Thai & Tom Yum','ផាត់ថៃ & ស្ងោរតុងយ៉ាំ','Thai Street Wok','https://images.unsplash.com/photo-1559847844-5315695dadae?w=1200&q=80','https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=300&q=80','St 51, Daun Penh, Phnom Penh','Phnom Penh','+855 12 777 999',4.8,20,1.00,1,590.00,'ACTIVE','2026-10-27 02:44:51'),(15,7,'Crispy Pork Belly & Basil Rice','បាយសាច់ជ្រូកបំពង កាផាវ','Thai Street Wok','https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=1200&q=80','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&q=80','St 178, Daun Penh, Phnom Penh','Phnom Penh','+855 12 888 000',4.7,18,1.00,1,470.00,'ACTIVE','2026-10-27 02:44:51'),(16,8,'Seoul Crispy K-Chicken & Beer','មាន់បំពងកូរ៉េ ស្រួយឆ្ងាញ់','Korean Fried Chicken','https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=1200&q=80','https://images.unsplash.com/photo-1562967914-608f82629710?w=300&q=80','St 63, BKK1, Phnom Penh','Phnom Penh','+855 23 666 888',4.9,20,1.25,1,810.00,'ACTIVE','2026-10-27 02:44:51'),(17,8,'K-Street Tteokbokki & Bibimbap','ថុកបូគី & ប៊ីប៊ីមបាប់ ក្តៅៗ','Korean Comfort Dishes','https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=1200&q=80','https://images.unsplash.com/photo-1590301157890-4810ed352733?w=300&q=80','St 334, BKK1, Phnom Penh','Phnom Penh','+855 12 999 111',4.7,22,1.00,1,490.00,'ACTIVE','2026-10-27 02:44:51'),(18,9,'Taj Mahal Butter Chicken & Naan','ការីឥណ្ឌា និងនំប៉័ងណាន','Indian Specialties • Curry','https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=1200&q=80','https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300&q=80','St 130, Daun Penh, Phnom Penh','Phnom Penh','+855 23 333 222',4.8,25,1.25,1,560.00,'ACTIVE','2026-10-27 02:44:51'),(19,9,'Royal Dum Biryani Claypots','បាយប៊ីរីយ៉ានី ឆ្នាំងដី','Indian Specialties • Biryani','https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=1200&q=80','https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=300&q=80','St 214, Daun Penh, Phnom Penh','Phnom Penh','+855 12 222 333',4.8,30,1.50,1,480.00,'ACTIVE','2026-10-27 02:44:51'),(20,10,'Green Vitality Salad & Salmon Poke','សាឡាដ & ផូកប៊ូលសាម៉ុង','Healthy & Superfood Bowls','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200&q=80','https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&q=80','St 306, BKK1, Phnom Penh','Phnom Penh','+855 23 111 222',4.9,15,1.00,1,670.00,'ACTIVE','2026-10-27 02:44:51'),(21,10,'Tropical Açaí & Cold-Pressed Juice','ទឹកផ្លែឈើស្រស់ & អាសៃ','Smoothies & Fresh Juices','https://images.unsplash.com/photo-1505253758473-96b3015f240a?w=1200&q=80','https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=300&q=80','St 57, BKK1, Phnom Penh','Phnom Penh','+855 12 111 000',4.9,15,1.00,1,530.00,'ACTIVE','2026-10-27 02:44:51');
/*!40000 ALTER TABLE `merchants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_warning` tinyint(1) NOT NULL DEFAULT '0',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,'Low Stock Alert','French Butter Croissant is down to 8 units.',1,0,'2026-10-26 20:29:10'),(2,'Bakong Gateway Online','Bakong KHQR instant payment channel is operational.',0,1,'2026-10-26 20:29:10');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `merchant_id` int DEFAULT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `khmer_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `barcode` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cost_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `selling_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `stock_quantity` int NOT NULL DEFAULT '0',
  `low_stock_threshold` int NOT NULL DEFAULT '10',
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','OUT_OF_STOCK','LOW_STOCK') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `barcode` (`barcode`),
  KEY `idx_barcode` (`barcode`),
  KEY `idx_category` (`category_id`),
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,1,4,'Iced Latte Macchiato','ឡាតេទឹកកក ម៉ាគីយ៉ាតូ','8850123001',1.10,2.75,45,10,'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(2,1,4,'Cambodian Drip Coffee (Cafe Teuk Doh Koh)','កាហ្វេទឹកដោះគោទឹកកក','8850123002',0.70,1.80,60,10,'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(3,1,4,'Matcha Green Tea Frappe','ម៉ាត់ឆាបៃតងក្រឡុក','8850123003',1.30,3.25,28,10,'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(4,2,6,'Signature Wagyu Cheeseburger','ប៊ឺហ្គឺសាច់គោ វ៉ាហ្គ្យូ','8850123004',3.20,6.50,22,10,'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(5,2,6,'Crispy Truffle Fries','ដំឡូងបារាំងបំពង ត្រាហ្វល','8850123005',1.20,3.50,30,10,'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(6,3,5,'French Butter Croissant','នំបុ័ងខ្វាសុង ប៊័រស្រស់','8850123006',0.90,2.20,8,10,'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=300','LOW_STOCK','2026-10-26 20:29:10','2026-10-27 02:44:51'),(7,3,5,'Belgian Chocolate Brownie','ប្រោវនីសូកូឡាបែលហ្ស៊ិក','8850123007',1.10,2.80,15,10,'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(8,4,1,'Khmer Beef Lok Lak with Fried Egg','ឡុកឡាក់សាច់គោពងទាចៀន','8850123008',2.50,5.50,18,10,'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(9,4,1,'Fish Amok Traditional Rice Set','អាម៉ុកត្រី បាយដំណើប','8850123009',2.80,6.00,12,10,'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(10,3,5,'Fresh Mango Sticky Rice','បាយដំណើបស្វាយទុំ','8850123010',1.00,3.00,0,10,'https://images.unsplash.com/photo-1505253758473-96b3015f240a?w=300','OUT_OF_STOCK','2026-10-26 20:29:10','2026-10-27 02:44:51'),(11,1,2,'Angkor Premium Beer 330ml Can','ស្រាបៀរអង្គរ កំប៉ុង','8850123011',0.75,1.50,120,20,'https://images.unsplash.com/photo-1608270199042-30372df34389?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(12,6,20,'Organic Jasmine Rice 5kg','អង្ករផ្កាម្លិះសរីរាង្គ ៥គីឡូ','8850123012',4.80,7.20,35,10,'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=300','ACTIVE','2026-10-26 20:29:10','2026-10-27 02:44:51'),(13,4,1,'Traditional Fish Amok in Coconut','អាម៉ុកត្រីដូងខ្ចី','8850201001',2.50,5.75,50,10,'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(14,4,1,'Kampot Pepper Beef Lok Lak Set','ឡុកឡាក់សាច់គោម្រេចកំពត','8850201002',2.80,6.25,45,10,'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(15,4,1,'Siem Reap Grilled Chicken with Sticky Rice','មាន់អាំងបាយដំណើប','8850201003',3.00,6.50,30,10,'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(16,4,1,'Crispy Fried Spring Rolls (4 pcs)','ណែមបំពងស្រួយ','8850201004',1.20,2.75,60,10,'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(17,4,2,'Charcoal Pork Skewers with Pickles (5 pcs)','សាច់ជ្រូកចង្កាក់អាំងជ្រក់','8850202001',1.80,4.00,60,10,'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(18,4,2,'Grilled Beef with Teuk Prahok Dip','សាច់គោអាំងទឹកប្រហុក','8850202002',3.20,6.75,40,10,'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(19,4,2,'Mekong River Prawn Skewers','បង្កងទន្លេអាំងអំបិលម្ទេស','8850202003',4.00,8.50,25,10,'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(20,4,3,'Steamed Kep Flower Crab (3 pcs)','ក្តាមសេះកែប ចំហុយ','8850203001',4.50,9.50,20,5,'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(21,4,3,'Deep-Fried River Elephant Fish','ត្រីដំរីបំពងជូរអែម','8850203002',3.80,7.80,18,5,'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(22,4,3,'Sour Spicy Seafood Soup (Tom Yum)','សម្លម្ជូរគ្រឿងគ្រឿងសមុទ្រ','8850203003',2.80,5.50,35,10,'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(23,1,4,'Signature Mondulkiri Iced Latte','ឡាតេទឹកកក កាហ្វេមណ្ឌលគិរី','8850204001',1.00,2.50,100,20,'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(24,1,4,'Traditional Condensed Milk Iced Coffee','កាហ្វេទឹកដោះគោទឹកកកពិសេស','8850204002',0.80,2.00,120,20,'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(25,1,4,'Salted Caramel Cold Brew','ខូលប៊្រូ ខារ៉ាមែលប្រៃ','8850204003',1.30,3.25,80,15,'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(26,1,4,'Iced Green Tea Coconut Cream','តែបៃតងដូងក្រអូប','8850204004',1.10,2.75,90,15,'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(27,3,5,'Golden Flaky French Croissant','នំបុ័ងខ្វាសុង ប៊័រស្រស់បារាំង','8850205001',0.90,2.25,60,10,'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(28,3,5,'Pain au Chocolat (Dark Belgian Chocolate)','នំសូកូឡាប៉ាំងអូសូកូឡា','8850205002',1.10,2.65,50,10,'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(29,3,5,'Strawberry Vanilla Choux Cream','នំស៊ូក្រែម ស្រ្តប៊ឺរីវ៉ានីឡា','8850205003',1.30,3.00,40,10,'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(30,2,6,'Double Truffle Wagyu Smash Burger','ប៊ឺហ្គឺសាច់គោវ៉ាហ្គ្យូ ត្រាហ្វល','8850206001',3.50,7.50,40,10,'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(31,2,6,'Bacon Avocado Cheddar Smash','ប៊ឺហ្គឺសាច់គោ បែកខិនប័រ','8850206002',3.20,6.95,45,10,'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(32,2,6,'Loaded Cheese Truffle Fries','ដំឡូងបារាំងបំពង ឈីសត្រាហ្វល','8850206003',1.50,3.75,70,15,'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(33,2,7,'Nashville Hot Fried Chicken Burger','ប៊ឺហ្គឺមាន់បំពងហិរណាស្វិល','8850207001',2.50,5.50,50,10,'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(34,2,7,'Garlic Parmesan Crispy Wings (6 pcs)','ស្លាបមាន់បំពង ខ្ទឹមសឈីស','8850207002',2.00,4.80,65,15,'https://images.unsplash.com/photo-1562967914-608f82629710?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(35,2,7,'Honey Butter Tenders Basket (4 pcs)','សាច់មាន់បំពង ទឹកឃ្មុំប៊័រ','8850207003',1.80,4.25,55,10,'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(36,4,8,'Special Seafood Pork Kuy Teav Soup','គុយទាវភ្នំពេញ គ្រឿងសមុទ្រពិសេស','8850208001',1.60,3.80,80,15,'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(37,4,8,'Dry Kuy Teav with Rich Broth Bowl','គុយទាវគោក ភ្នំពេញ','8850208002',1.60,3.80,75,15,'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(38,4,8,'Braised Beef Noodle Soup','មីស៊ុបសាច់គោខ','8850208003',1.80,4.20,60,10,'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(39,4,9,'Steamed Pork & Prawn Siu Mai (4 pcs)','ស៊ីវម៉ៃសាច់ជ្រូក បង្គា','8850209001',1.20,2.95,60,10,'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(40,4,9,'Crystal Prawn Dumplings Har Gow (4 pcs)','ហាកាវបង្គាស្រស់','8850209002',1.40,3.25,50,10,'https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(41,4,9,'Steamed BBQ Pork Char Siu Bao (3 pcs)','នំប៉ាវសាច់ជ្រូកខ្វៃ','8850209003',1.10,2.50,50,10,'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(42,4,10,'Signature Black Garlic Tonkotsu Ramen','រ៉ាមេនខ្ទឹមសខ្មៅ ទំពាំងសាច់ជ្រូក','8850210001',3.20,7.50,45,10,'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(43,4,10,'Spicy Miso Ramen with Chashu','រ៉ាមេនមីស៊ូហិរ សាច់ជ្រូកចាស្ស៊ូ','8850210002',3.00,7.00,50,10,'https://images.unsplash.com/photo-1557872943-16a5ac26437e?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(44,4,10,'Crispy Japanese Pan Gyoza (6 pcs)','គាវបំពងជប៉ុន ហ្គីយ៉ូហ្សា','8850210003',1.20,3.20,60,10,'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(45,4,11,'Torched Aburi Salmon Cheese Roll (8 pcs)','ស៊ូស៊ីត្រីសាម៉ុង ដុតឈីស','8850211001',3.80,8.50,35,10,'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(46,4,11,'Fresh Atlantic Salmon Sashimi (5 pcs)','សាច់ត្រីសាម៉ុងឆៅ អាត្លង់ទិក','8850211002',3.50,7.80,40,10,'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(47,4,11,'Crunchy California Prawn Tempura Roll','កាលីហ្វ័រញ៉ារ៉ូល បង្គាបំពង','8850211003',2.80,6.20,45,10,'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(48,2,12,'Spicy Beef Pepperoni Sourdough Pizza','ភីហ្សា ប៉េបប៉េរ៉ូនីសាច់គោ','8850212001',4.00,8.95,30,5,'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(49,2,12,'Classic Margherita Buffalo Mozzarella','ភីហ្សា ម៉ាហ្គារីតា ឈីសស្រស់','8850212002',3.50,7.50,35,5,'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(50,2,12,'Four Cheese Quattro Formaggi Pizza','ភីហ្សា ឈីស៤មុខ','8850212003',4.20,9.50,25,5,'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(51,2,13,'Black Truffle Wild Mushroom Fettuccine','ប៉ាស្តាផ្សិត ទឹកជ្រលក់ត្រាហ្វល','8850213001',3.50,7.80,30,5,'https://images.unsplash.com/photo-1621996346565-e3d5d628169e?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(52,2,13,'Classic Creamy Carbonara with Pancetta','ប៉ាស្តា កាបូណារ៉ា សាច់ជ្រូកបំពង','8850213002',3.00,6.95,35,5,'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(53,4,14,'Bangkok Jumbo Prawn Pad Thai','ផាត់ថៃ បង្គាធំ បាងកក','8850214001',2.00,4.75,55,10,'https://images.unsplash.com/photo-1559847844-5315695dadae?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(54,4,14,'Seafood Tom Yum Goong Soup Bowl','ស្ងោរតុងយ៉ាំគ្រឿងសមុទ្រ ក្តៅៗ','8850214002',2.20,5.25,45,10,'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(55,4,15,'Crispy Pork Belly Holy Basil (Pad Kra Pao)','បាយសាច់ជ្រូកបំពង កាផាវ ពងទាចៀន','8850215001',1.80,4.25,60,10,'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(56,4,15,'Green Curry Chicken with Jasmine Rice','ការីបៃតងសាច់មាន់ ថៃ','8850215002',2.00,4.80,50,10,'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(57,2,16,'Sweet & Spicy Yangnyeom K-Chicken (8 pcs)','មាន់បំពងកូរ៉េ ទឹកជ្រលក់ហិរផ្អែម','8850216001',2.80,6.50,40,10,'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(58,2,16,'Honey Butter Garlic Fried Chicken','មាន់បំពងកូរ៉េ ខ្ទឹមសទឹកឃ្មុំ','8850216002',2.80,6.50,45,10,'https://images.unsplash.com/photo-1562967914-608f82629710?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(59,4,17,'Spicy Cheese Tteokbokki Rice Cake','ថុកបូគី បន្ទះអង្ករកូរ៉េដុតឈីស','8850217001',1.60,3.80,50,10,'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(60,4,17,'Beef Bulgogi Dolsot Bibimbap','ប៊ីប៊ីមបាប់សាច់គោ កូរ៉េ','8850217002',2.20,5.25,45,10,'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(61,4,18,'Creamy Butter Chicken Curry Pot','ការីសាច់មាន់ប៊័រ ឥណ្ឌា','8850218001',2.80,6.50,35,10,'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(62,4,18,'Fresh Garlic Butter Naan (2 pcs)','នំប៉័ងណាន ខ្ទឹមសប៊័រ','8850218002',0.80,2.00,80,15,'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(63,4,19,'Hyderabadi Chicken Dum Biryani','បាយប៊ីរីយ៉ានីសាច់មាន់ ឆ្នាំងដី','8850219001',2.80,6.20,40,10,'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(64,4,19,'Slow-Cooked Mutton Biryani','បាយប៊ីរីយ៉ានីសាច់ចៀម','8850219002',3.50,7.80,30,5,'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(65,5,20,'Norwegian Salmon Avocado Poke Bowl','ផូកប៊ូលសាម៉ុង ប័រ និងពងត្រី','8850220001',3.20,6.95,35,10,'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(66,5,20,'Grilled Chicken Quinoa Superfood Salad','សាឡាដមាន់អាំង គីន័រ','8850220002',2.40,5.50,40,10,'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(67,1,21,'Amazonian Superfood Açaí Berry Bowl','អាសៃប៊ូល ផ្លែប៊ឺរី និងចេកស្រស់','8850221001',1.80,4.50,45,10,'https://images.unsplash.com/photo-1505253758473-96b3015f240a?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51'),(68,1,21,'Cold-Pressed Green Detox Cleanser','ទឹកបន្លែផ្លែឈើបន្សាបជាតិពុល','8850221002',1.20,2.95,60,15,'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=500&q=80','ACTIVE','2026-10-27 02:44:51','2026-10-27 02:44:51');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `merchant_id` int NOT NULL,
  `rating` int NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `merchant_id` (`merchant_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,1,1,5,'Traditional Fish Amok was exceptional! Very authentic Khmer herbs and coconut cream.','2026-10-27 22:57:33'),(2,2,4,5,'Best espresso and croissants in BKK1. Fast delivery.','2026-10-27 22:57:33'),(3,3,1,5,'Delicious beef lok lak and very fast delivery to Boeng Tumpun.','2026-10-27 22:57:33'),(4,3,6,4,'Juicy smash burger and crispy fries. Will order again!','2026-10-27 22:57:33');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_items`
--

DROP TABLE IF EXISTS `transaction_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `discount_percent` decimal(5,2) NOT NULL DEFAULT '0.00',
  `line_total` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ti_transaction` (`transaction_id`),
  KEY `fk_ti_product` (`product_id`),
  CONSTRAINT `fk_ti_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_ti_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_items`
--

LOCK TABLES `transaction_items` WRITE;
/*!40000 ALTER TABLE `transaction_items` DISABLE KEYS */;
INSERT INTO `transaction_items` VALUES (1,1,1,2,2.75,0.00,5.50),(2,1,4,1,6.50,10.00,5.85),(3,2,8,2,5.50,0.00,11.00),(4,2,2,2,1.80,0.00,3.60),(5,3,9,1,6.00,0.00,6.00),(6,3,3,1,3.25,0.00,3.25),(7,4,1,1,2.75,0.00,2.75),(8,5,8,1,5.50,0.00,5.50),(9,5,14,1,6.25,0.00,6.25),(10,6,1,1,6.50,0.00,6.50),(11,6,2,1,5.50,0.00,5.50),(12,7,27,4,2.25,0.00,9.00),(13,8,33,3,5.50,0.00,16.50);
/*!40000 ALTER TABLE `transaction_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cashier_id` int DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `merchant_id` int DEFAULT NULL,
  `customer_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delivery_address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shift_id` int DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `grand_total_usd` decimal(10,2) NOT NULL,
  `grand_total_khr` decimal(14,2) NOT NULL,
  `payment_method` enum('CASH','BAKONG_KHQR','CREDIT_CARD','SPLIT_PAYMENT') COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_reference` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount_tendered` decimal(10,2) NOT NULL,
  `change_given` decimal(10,2) NOT NULL DEFAULT '0.00',
  `split_cash_amount` decimal(10,2) DEFAULT NULL,
  `split_digital_amount` decimal(10,2) DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'COMPLETED',
  `refund_reason` text COLLATE utf8mb4_unicode_ci,
  `refunded_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `idx_invoice` (`invoice_number`),
  KEY `idx_payment_method` (`payment_method`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `fk_tx_cashier` (`cashier_id`),
  KEY `fk_tx_customer` (`customer_id`),
  KEY `fk_tx_shift` (`shift_id`),
  CONSTRAINT `fk_tx_cashier` FOREIGN KEY (`cashier_id`) REFERENCES `employees` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_tx_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,'INV-20261026-001','2026-10-26 12:44:10',2,1,1,NULL,NULL,'House 42, St 271, Boeng Tumpun, Phnom Penh',1,12.00,1.20,1.08,11.88,48708.00,'BAKONG_KHQR','BK-89421092',11.88,0.00,NULL,NULL,'COMPLETED',NULL,NULL),(2,'INV-20261026-002','2026-10-26 11:59:10',2,NULL,1,NULL,NULL,'House 42, St 271, Boeng Tumpun, Phnom Penh',1,14.60,0.00,1.46,16.06,65846.00,'CASH','CASH-TENDER',20.00,3.94,NULL,NULL,'COMPLETED',NULL,NULL),(3,'INV-20261026-003','2026-10-26 10:59:10',1,2,1,NULL,NULL,'House 42, St 271, Boeng Tumpun, Phnom Penh',1,9.25,0.50,0.88,9.63,39483.00,'CREDIT_CARD','AUTH-458921',9.63,0.00,NULL,NULL,'COMPLETED',NULL,NULL),(4,'INV-7485087','2026-10-26 19:18:05',1,1,1,NULL,NULL,'House 42, St 271, Boeng Tumpun, Phnom Penh',1,2.75,0.00,0.00,3.75,15375.00,'CASH','APP-INV-7485087',3.75,0.00,NULL,NULL,'COMPLETED',NULL,NULL),(5,'INV-9233570','2026-10-26 19:47:13',1,1,1,'Vireak Bot (???? ?????)','+855 12 999 001','BKK1, St 288, House 15',1,11.75,0.00,0.00,12.75,52275.00,'CREDIT_CARD','APP-INV-9233570',12.75,0.00,NULL,NULL,'COMPLETED',NULL,NULL),(6,'ORD-TEST-9999','2026-10-26 19:53:55',1,1,1,'Bopha Pich','+855 12 345 678','House 42, St 271, Boeng Tumpun, Phnom Penh',1,11.00,0.00,0.00,12.00,49200.00,'CASH','APP-ORD-TEST-9999',12.00,0.00,NULL,NULL,'COMPLETED',NULL,NULL),(7,'ORD-810973','2026-10-27 15:06:50',1,1,5,'Bopha Pich (ពេជ្រ បុប្ផា)','012 345 678','House 42, St 271, Boeng Tumpun, Phnom Penh',1,9.00,0.00,0.00,10.00,41000.00,'CASH','APP-ORD-810973',10.00,0.00,NULL,NULL,'COMPLETED',NULL,NULL),(8,'ORD-408902','2026-10-27 15:33:28',1,1,7,'sinoun','011111111','Phnom Penh',1,16.50,0.00,0.00,17.50,71750.00,'CREDIT_CARD','APP-ORD-408902',17.50,0.00,NULL,NULL,'COMPLETED',NULL,NULL);
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vouchers`
--

DROP TABLE IF EXISTS `vouchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vouchers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount_percent` int NOT NULL,
  `max_discount_usd` decimal(10,2) DEFAULT '5.00',
  `min_spend_usd` decimal(10,2) DEFAULT '0.00',
  `expiry_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vouchers`
--

LOCK TABLES `vouchers` WRITE;
/*!40000 ALTER TABLE `vouchers` DISABLE KEYS */;
INSERT INTO `vouchers` VALUES (1,'WELCOME5','New Customer Welcome','15% discount for new customer first order',15,5.00,5.00,'2026-12-31',1,'2026-10-27 22:57:32'),(2,'FREESHIP','Free Delivery Deal','Free delivery on all food orders above $8',10,2.00,8.00,'2026-12-31',1,'2026-10-27 22:57:32'),(3,'SMARTFOOD20','SmartFood Special Promo','20% off for all Khmer dishes & burgers',20,8.00,10.00,'2026-12-31',1,'2026-10-27 22:57:32'),(4,'KHMERDELIGHT','Khmer Heritage Food Fest','10% discount on authentic traditional dishes',10,4.00,5.00,'2026-12-31',1,'2026-10-27 22:57:32');
/*!40000 ALTER TABLE `vouchers` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-27 17:43:44
