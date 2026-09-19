-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: citymartstore
-- ------------------------------------------------------
-- Server version	8.4.3

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
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'المنزل',
  `recipient_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `district` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `street` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `addresses_user_id_foreign` (`user_id`),
  CONSTRAINT `addresses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (1,3,'المنزل','ابراهيم محمد','967777234341','Sanaa','Hay Al Ziraah','954Q+MMR','المنزل',15.3567111,44.1893381,1,'2026-08-31 01:45:40','2026-08-31 01:45:40'),(2,1,'المكتب','ابوبكر الحجي','967778396448','صنعاء','حي الزراعة','954Q+MMR، صنعاء‎، اليَمَن','الدائري',15.3567027,44.1893303,1,'2026-09-08 20:11:26','2026-09-08 20:11:26');
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_events`
--

DROP TABLE IF EXISTS `admin_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_events` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_id` bigint unsigned DEFAULT NULL,
  `courier_id` bigint unsigned DEFAULT NULL,
  `data` json DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `admin_events_order_id_foreign` (`order_id`),
  KEY `admin_events_courier_id_foreign` (`courier_id`),
  KEY `admin_events_created_at_index` (`created_at`),
  KEY `admin_events_read_at_index` (`read_at`),
  CONSTRAINT `admin_events_courier_id_foreign` FOREIGN KEY (`courier_id`) REFERENCES `couriers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `admin_events_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_events`
--

LOCK TABLES `admin_events` WRITE;
/*!40000 ALTER TABLE `admin_events` DISABLE KEYS */;
INSERT INTO `admin_events` VALUES (1,'order_placed','طلب جديد','وصل طلب 1 بقيمة 6.00',1,NULL,NULL,'2026-08-31 05:09:59','2026-08-31 01:34:29'),(2,'order_placed','طلب جديد','وصل طلب 2 بقيمة 22.00',2,NULL,NULL,'2026-08-31 05:09:59','2026-08-31 01:44:14'),(3,'order_placed','طلب جديد','وصل طلب 3 بقيمة 61.00',3,NULL,NULL,'2026-08-31 05:09:59','2026-08-31 01:45:45'),(4,'courier_accepted','الموصل قبل الطلب','ابراهيم محمد قبل الطلب 1',1,1,NULL,'2026-08-31 05:09:59','2026-08-31 02:31:23'),(5,'courier_accepted','الموصل قبل الطلب','ابراهيم محمد قبل الطلب 2',2,1,NULL,'2026-08-31 05:09:59','2026-08-31 02:32:51'),(6,'courier_picked_up','تم استلام الطلب من المتجر','ابراهيم محمد استلم الطلب 2 وهو في الطريق',2,1,NULL,'2026-08-31 05:09:59','2026-08-31 02:33:47'),(7,'courier_delivered','تم تسليم الطلب','ابراهيم محمد سلّم الطلب 2',2,1,NULL,'2026-08-31 05:09:59','2026-08-31 02:34:06'),(8,'courier_picked_up','تم استلام الطلب من المتجر','ابراهيم محمد استلم الطلب 1 وهو في الطريق',1,1,NULL,'2026-08-31 05:09:59','2026-08-31 02:35:05'),(9,'courier_delivered','تم تسليم الطلب','ابراهيم محمد سلّم الطلب 1',1,1,NULL,'2026-08-31 05:09:59','2026-08-31 02:35:14'),(10,'courier_accepted','الموصل قبل الطلب','ابراهيم محمد قبل الطلب 3',3,1,NULL,'2026-08-31 05:09:59','2026-08-31 02:35:23'),(11,'order_placed','طلب جديد','وصل طلب 4 بقيمة 22.00',4,NULL,NULL,'2026-08-31 05:09:59','2026-08-31 03:09:37'),(12,'courier_accepted','الموصل قبل الطلب','ابراهيم محمد قبل الطلب 4',4,1,NULL,'2026-08-31 05:09:59','2026-08-31 03:10:24'),(13,'order_placed','طلب جديد','وصل طلب 5 بقيمة 64.00',5,NULL,NULL,'2026-08-31 05:09:59','2026-08-31 03:11:14'),(14,'courier_picked_up','تم استلام الطلب من المتجر','ابراهيم محمد استلم الطلب 4 وهو في الطريق',4,1,NULL,'2026-08-31 05:09:59','2026-08-31 03:11:19'),(15,'courier_delivered','تم تسليم الطلب','ابراهيم محمد سلّم الطلب 4',4,1,NULL,'2026-08-31 05:09:59','2026-08-31 03:11:22'),(16,'courier_accepted','الموصل قبل الطلب','ابراهيم محمد قبل الطلب 5',5,1,NULL,'2026-08-31 05:09:59','2026-08-31 03:11:28'),(17,'order_placed','طلب جديد','وصل طلب 6 بقيمة 72.85',6,NULL,NULL,NULL,'2026-09-01 23:26:13'),(18,'order_placed','طلب جديد','وصل طلب 7 بقيمة 354.00',7,NULL,NULL,NULL,'2026-09-08 20:11:39'),(19,'order_placed','طلب جديد','وصل طلب 8 بقيمة 27.00',8,NULL,NULL,NULL,'2026-09-12 20:42:18'),(20,'order_placed','طلب جديد','وصل طلب 9 بقيمة 80.00',9,NULL,NULL,NULL,'2026-09-12 22:45:45'),(21,'order_placed','طلب جديد','وصل طلب 10 بقيمة 37.00',10,NULL,NULL,NULL,'2026-09-12 23:23:09'),(22,'order_placed','طلب جديد','وصل طلب 11 بقيمة 66.85',11,NULL,NULL,NULL,'2026-09-12 23:36:32'),(23,'order_placed','طلب جديد','وصل طلب 12 بقيمة 66.85',12,NULL,NULL,NULL,'2026-09-12 23:51:00'),(24,'order_placed','طلب جديد','وصل طلب 13 بقيمة 50.30',13,NULL,NULL,NULL,'2026-09-14 18:46:05'),(25,'courier_accepted','الموصل قبل الطلب','ابوبكر الحجي قبل الطلب 7',7,3,NULL,NULL,'2026-09-14 20:22:22'),(26,'courier_picked_up','تم استلام الطلب من المتجر','ابوبكر الحجي استلم الطلب 7 وهو في الطريق',7,3,NULL,NULL,'2026-09-14 20:22:52'),(27,'courier_delivered','تم تسليم الطلب','ابوبكر الحجي سلّم الطلب 7',7,3,NULL,NULL,'2026-09-14 20:23:03');
/*!40000 ALTER TABLE `admin_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_conversations`
--

DROP TABLE IF EXISTS `ai_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_conversations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `guest_token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ai_conversations_guest_token_index` (`guest_token`),
  KEY `ai_conversations_user_id_foreign` (`user_id`),
  CONSTRAINT `ai_conversations_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_conversations`
--

LOCK TABLES `ai_conversations` WRITE;
/*!40000 ALTER TABLE `ai_conversations` DISABLE KEYS */;
INSERT INTO `ai_conversations` VALUES (37,1,'2026-09-14 17:52:21','2026-09-14 17:52:21','d0b55335acc261b1dabdbbbe3d90b5b0'),(38,1,'2026-09-14 17:52:48','2026-09-14 17:52:48','d0b55335acc261b1dabdbbbe3d90b5b0'),(39,1,'2026-09-14 20:31:36','2026-09-14 20:31:36','d0b55335acc261b1dabdbbbe3d90b5b0'),(40,1,'2026-09-14 20:32:15','2026-09-14 20:32:15','d0b55335acc261b1dabdbbbe3d90b5b0'),(41,1,'2026-09-14 20:41:03','2026-09-14 20:41:03','d0b55335acc261b1dabdbbbe3d90b5b0'),(42,1,'2026-09-14 20:43:42','2026-09-14 20:43:42','d0b55335acc261b1dabdbbbe3d90b5b0'),(43,1,'2026-09-14 20:45:28','2026-09-14 20:45:28','d0b55335acc261b1dabdbbbe3d90b5b0'),(44,1,'2026-09-14 20:45:49','2026-09-14 20:45:49','d0b55335acc261b1dabdbbbe3d90b5b0'),(45,1,'2026-09-14 20:46:05','2026-09-14 20:46:05','d0b55335acc261b1dabdbbbe3d90b5b0');
/*!40000 ALTER TABLE `ai_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_messages`
--

DROP TABLE IF EXISTS `ai_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint unsigned NOT NULL,
  `role` enum('user','assistant') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `suggested_product_ids` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ai_messages_conversation_id_foreign` (`conversation_id`),
  CONSTRAINT `ai_messages_conversation_id_foreign` FOREIGN KEY (`conversation_id`) REFERENCES `ai_conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_messages`
--

LOCK TABLES `ai_messages` WRITE;
/*!40000 ALTER TABLE `ai_messages` DISABLE KEYS */;
INSERT INTO `ai_messages` VALUES (63,39,'user','أبحث عن إكسسوارات للمنزل',NULL,'2026-09-14 20:31:40','2026-09-14 20:31:40'),(64,39,'assistant','أهلاً بك في روعة الخمسة! للأسف لا تتوفر لدينا إكسسوارات منزلية في الكتالوج الحالي، ولكن يمكنك تصفح الأقسام المتاحة مثل المنظفات، البسكويت، والزيوت. هل تود الانتقال لشاشة الأقسام لرؤية المتاح؟','[]','2026-09-14 20:31:40','2026-09-14 20:31:40'),(65,40,'user','منتجات العناية بالمنزل',NULL,'2026-09-14 20:32:18','2026-09-14 20:32:18'),(66,40,'assistant','أهلاً بك في روعة الخمسة! لدينا منتج رائع للعناية بملابسك ونظافة منزلك، وهو مسحوق غسيل كريستال برائحة الورد 2.5 كجم بسعر 12.00 ريال، وتجده في قسم غسيل الملابس.','[57]','2026-09-14 20:32:18','2026-09-14 20:32:18'),(67,41,'user','مرحبا',NULL,'2026-09-14 20:41:13','2026-09-14 20:41:13'),(68,41,'assistant','يا هلا وغلا فيك يا فندم بمتجر روعة الخمسة! كيف أقدر أساعدك اليوم في جولاتك وتسوقك؟','[]','2026-09-14 20:41:13','2026-09-14 20:41:13'),(69,42,'user','وين ألقى الحليب؟',NULL,'2026-09-14 20:43:56','2026-09-14 20:43:56'),(70,42,'assistant','تفضل هذه اختيارات من سيتي مارت، ويمكنك فتح أي منتج للتفاصيل.','[]','2026-09-14 20:43:56','2026-09-14 20:43:56'),(71,44,'user','ما هي المنتجات التي لديها خص',NULL,'2026-09-14 20:46:04','2026-09-14 20:46:04'),(72,44,'assistant','أهلاً بك يا غالي. ما بش عندنا عروض خصومات مسجلة حالياً في الكتالوج، بس تقدر تطلع على أقسام المتجر وتشوف المنتجات المميزة والأسعار الطيبة المتوفرة عندنا. تحب أفتح لك صفحة الأقسام؟','[]','2026-09-14 20:46:04','2026-09-14 20:46:04');
/*!40000 ALTER TABLE `ai_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `banners`
--

DROP TABLE IF EXISTS `banners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `banners` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `show_title` tinyint(1) NOT NULL DEFAULT '0',
  `subtitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_type` enum('product','category','url','none','page') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'none',
  `link_id` bigint unsigned DEFAULT NULL,
  `link_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `starts_at` timestamp NULL DEFAULT NULL,
  `ends_at` timestamp NULL DEFAULT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `banners_is_active_sort_order_index` (`is_active`,`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `banners`
--

LOCK TABLES `banners` WRITE;
/*!40000 ALTER TABLE `banners` DISABLE KEYS */;
INSERT INTO `banners` VALUES (1,'عرض اليوم',0,'عروض السوبر','banners/Lm7bjsNI6VpGmZThTTVNiMbHdQSfDGTjKDMoC0a2.jpg','none',NULL,NULL,NULL,NULL,0,0,'2026-09-12 23:16:44','2026-09-13 00:14:29'),(2,'سلة رمضان',0,NULL,'banners/h8e5lcXDGPI0c6AbGqHJWRTyLZKUJgUQGzlxw3OP.jpg','none',NULL,NULL,NULL,NULL,0,0,'2026-09-12 23:18:03','2026-09-14 15:48:24');
/*!40000 ALTER TABLE `banners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bundle_items`
--

DROP TABLE IF EXISTS `bundle_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bundle_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `bundle_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bundle_items_bundle_id_product_id_unique` (`bundle_id`,`product_id`),
  KEY `bundle_items_product_id_foreign` (`product_id`),
  CONSTRAINT `bundle_items_bundle_id_foreign` FOREIGN KEY (`bundle_id`) REFERENCES `product_bundles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bundle_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bundle_items`
--

LOCK TABLES `bundle_items` WRITE;
/*!40000 ALTER TABLE `bundle_items` DISABLE KEYS */;
INSERT INTO `bundle_items` VALUES (4,2,2,1,0),(5,2,3,1,1),(6,1,15,1,0),(7,1,7,3,1),(8,1,24,1,2),(13,4,1,2,0),(14,4,3,1,1),(15,4,5,3,2),(16,4,6,1,3),(17,5,1,1,0),(18,5,3,1,1),(19,5,37,1,2),(20,5,17,2,3),(21,5,23,1,4),(27,6,1,1,0),(28,6,2,1,1),(29,6,5,1,2),(30,6,6,1,3),(31,6,20,1,4);
/*!40000 ALTER TABLE `bundle_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('aimstore-cache-admin.reports.overview.v2.1789344000.1789430399','a:10:{s:4:\"kpis\";a:8:{i:0;a:8:{s:5:\"label\";s:27:\"إيرادات مسلّمة\";s:5:\"value\";d:0;s:8:\"previous\";d:0;s:5:\"delta\";N;s:11:\"delta_label\";s:3:\"—\";s:4:\"icon\";s:10:\"bi-wallet2\";s:6:\"format\";s:5:\"money\";s:4:\"tone\";s:7:\"success\";}i:1;a:8:{s:5:\"label\";s:27:\"إجمالي الطلبات\";s:5:\"value\";i:1;s:8:\"previous\";i:4;s:5:\"delta\";d:-75;s:11:\"delta_label\";s:4:\"-75%\";s:4:\"icon\";s:12:\"bi-bag-check\";s:6:\"format\";s:6:\"number\";s:4:\"tone\";s:4:\"info\";}i:2;a:8:{s:5:\"label\";s:21:\"متوسط الطلب\";s:5:\"value\";d:0;s:8:\"previous\";d:0;s:5:\"delta\";N;s:11:\"delta_label\";s:3:\"—\";s:4:\"icon\";s:11:\"bi-graph-up\";s:6:\"format\";s:5:\"money\";s:4:\"tone\";s:7:\"primary\";}i:3;a:8:{s:5:\"label\";s:17:\"عملاء جدد\";s:5:\"value\";i:0;s:8:\"previous\";i:0;s:5:\"delta\";N;s:11:\"delta_label\";s:3:\"—\";s:4:\"icon\";s:9:\"bi-people\";s:6:\"format\";s:6:\"number\";s:4:\"tone\";s:7:\"warning\";}i:4;a:8:{s:5:\"label\";s:10:\"ملغاة\";s:5:\"value\";i:0;s:8:\"previous\";i:0;s:5:\"delta\";N;s:11:\"delta_label\";s:3:\"—\";s:4:\"icon\";s:11:\"bi-x-circle\";s:6:\"format\";s:6:\"number\";s:4:\"tone\";s:6:\"danger\";}i:5;a:8:{s:5:\"label\";s:23:\"نسبة الإلغاء\";s:5:\"value\";d:0;s:8:\"previous\";d:0;s:5:\"delta\";N;s:11:\"delta_label\";s:3:\"—\";s:4:\"icon\";s:10:\"bi-percent\";s:6:\"format\";s:7:\"percent\";s:4:\"tone\";s:5:\"muted\";}i:6;a:8:{s:5:\"label\";s:16:\"الخصومات\";s:5:\"value\";d:0;s:8:\"previous\";d:0;s:5:\"delta\";N;s:11:\"delta_label\";s:3:\"—\";s:4:\"icon\";s:20:\"bi-ticket-perforated\";s:6:\"format\";s:5:\"money\";s:4:\"tone\";s:5:\"promo\";}i:7;a:8:{s:5:\"label\";s:17:\"قطع مباعة\";s:5:\"value\";i:4;s:8:\"previous\";i:24;s:5:\"delta\";d:-83.3;s:11:\"delta_label\";s:6:\"-83.3%\";s:4:\"icon\";s:11:\"bi-box-seam\";s:6:\"format\";s:6:\"number\";s:4:\"tone\";s:4:\"info\";}}s:6:\"series\";a:23:{i:0;a:5:{s:4:\"date\";s:16:\"2026-09-14 00:00\";s:5:\"label\";s:5:\"00:00\";s:4:\"hour\";i:0;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:1;a:5:{s:4:\"date\";s:16:\"2026-09-14 01:00\";s:5:\"label\";s:5:\"01:00\";s:4:\"hour\";i:1;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:2;a:5:{s:4:\"date\";s:16:\"2026-09-14 02:00\";s:5:\"label\";s:5:\"02:00\";s:4:\"hour\";i:2;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:3;a:5:{s:4:\"date\";s:16:\"2026-09-14 03:00\";s:5:\"label\";s:5:\"03:00\";s:4:\"hour\";i:3;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:4;a:5:{s:4:\"date\";s:16:\"2026-09-14 04:00\";s:5:\"label\";s:5:\"04:00\";s:4:\"hour\";i:4;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:5;a:5:{s:4:\"date\";s:16:\"2026-09-14 05:00\";s:5:\"label\";s:5:\"05:00\";s:4:\"hour\";i:5;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:6;a:5:{s:4:\"date\";s:16:\"2026-09-14 06:00\";s:5:\"label\";s:5:\"06:00\";s:4:\"hour\";i:6;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:7;a:5:{s:4:\"date\";s:16:\"2026-09-14 07:00\";s:5:\"label\";s:5:\"07:00\";s:4:\"hour\";i:7;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:8;a:5:{s:4:\"date\";s:16:\"2026-09-14 08:00\";s:5:\"label\";s:5:\"08:00\";s:4:\"hour\";i:8;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:9;a:5:{s:4:\"date\";s:16:\"2026-09-14 09:00\";s:5:\"label\";s:5:\"09:00\";s:4:\"hour\";i:9;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:10;a:5:{s:4:\"date\";s:16:\"2026-09-14 10:00\";s:5:\"label\";s:5:\"10:00\";s:4:\"hour\";i:10;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:11;a:5:{s:4:\"date\";s:16:\"2026-09-14 11:00\";s:5:\"label\";s:5:\"11:00\";s:4:\"hour\";i:11;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:12;a:5:{s:4:\"date\";s:16:\"2026-09-14 12:00\";s:5:\"label\";s:5:\"12:00\";s:4:\"hour\";i:12;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:13;a:5:{s:4:\"date\";s:16:\"2026-09-14 13:00\";s:5:\"label\";s:5:\"13:00\";s:4:\"hour\";i:13;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:14;a:5:{s:4:\"date\";s:16:\"2026-09-14 14:00\";s:5:\"label\";s:5:\"14:00\";s:4:\"hour\";i:14;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:15;a:5:{s:4:\"date\";s:16:\"2026-09-14 15:00\";s:5:\"label\";s:5:\"15:00\";s:4:\"hour\";i:15;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:16;a:5:{s:4:\"date\";s:16:\"2026-09-14 16:00\";s:5:\"label\";s:5:\"16:00\";s:4:\"hour\";i:16;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:17;a:5:{s:4:\"date\";s:16:\"2026-09-14 17:00\";s:5:\"label\";s:5:\"17:00\";s:4:\"hour\";i:17;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:18;a:5:{s:4:\"date\";s:16:\"2026-09-14 18:00\";s:5:\"label\";s:5:\"18:00\";s:4:\"hour\";i:18;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:19;a:5:{s:4:\"date\";s:16:\"2026-09-14 19:00\";s:5:\"label\";s:5:\"19:00\";s:4:\"hour\";i:19;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:20;a:5:{s:4:\"date\";s:16:\"2026-09-14 20:00\";s:5:\"label\";s:5:\"20:00\";s:4:\"hour\";i:20;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}i:21;a:5:{s:4:\"date\";s:16:\"2026-09-14 21:00\";s:5:\"label\";s:5:\"21:00\";s:4:\"hour\";i:21;s:7:\"revenue\";d:0;s:6:\"orders\";i:1;}i:22;a:5:{s:4:\"date\";s:16:\"2026-09-14 22:00\";s:5:\"label\";s:5:\"22:00\";s:4:\"hour\";i:22;s:7:\"revenue\";d:0;s:6:\"orders\";i:0;}}s:6:\"status\";a:5:{i:0;a:4:{s:3:\"key\";s:7:\"pending\";s:5:\"label\";s:32:\"في انتظار التأكيد\";s:5:\"count\";i:1;s:5:\"total\";d:50.3;}i:1;a:4:{s:3:\"key\";s:9:\"preparing\";s:5:\"label\";s:23:\"جاري التحضير\";s:5:\"count\";i:0;s:5:\"total\";d:0;}i:2;a:4:{s:3:\"key\";s:10:\"on_the_way\";s:5:\"label\";s:26:\"في الطريق إليك\";s:5:\"count\";i:0;s:5:\"total\";d:0;}i:3;a:4:{s:3:\"key\";s:9:\"delivered\";s:5:\"label\";s:19:\"تم التسليم\";s:5:\"count\";i:0;s:5:\"total\";d:0;}i:4;a:4:{s:3:\"key\";s:9:\"cancelled\";s:5:\"label\";s:8:\"ملغي\";s:5:\"count\";i:0;s:5:\"total\";d:0;}}s:8:\"payments\";a:1:{i:0;a:4:{s:3:\"key\";s:7:\"floosak\";s:5:\"label\";s:10:\"فلوسك\";s:5:\"count\";i:1;s:5:\"total\";d:50.3;}}s:7:\"methods\";a:1:{i:0;a:4:{s:3:\"key\";s:8:\"delivery\";s:5:\"label\";s:10:\"توصيل\";s:5:\"count\";i:1;s:5:\"total\";d:50.3;}}s:12:\"top_products\";a:4:{i:0;a:6:{s:4:\"rank\";i:1;s:10:\"product_id\";i:34;s:4:\"name\";s:21:\"بسكويت ماري\";s:3:\"qty\";i:1;s:7:\"revenue\";d:14;s:6:\"orders\";i:1;}i:1;a:6:{s:4:\"rank\";i:2;s:10:\"product_id\";i:5;s:4:\"name\";s:56:\"بسكويت أبو ولد بكريمة الفراولة\";s:3:\"qty\";i:1;s:7:\"revenue\";d:9;s:6:\"orders\";i:1;}i:2;a:6:{s:4:\"rank\";i:3;s:10:\"product_id\";i:2;s:4:\"name\";s:60:\"بسكويت أبو ولد بكريمة الشوكولاتة\";s:3:\"qty\";i:1;s:7:\"revenue\";d:6.3;s:6:\"orders\";i:1;}i:3;a:6:{s:4:\"rank\";i:4;s:10:\"product_id\";i:1;s:4:\"name\";s:60:\"بسكويت أبو ولد بكريمة الشوكولاتة\";s:3:\"qty\";i:1;s:7:\"revenue\";d:6;s:6:\"orders\";i:1;}}s:13:\"top_customers\";a:1:{i:0;a:13:{s:4:\"rank\";i:1;s:7:\"user_id\";i:1;s:4:\"name\";s:23:\"ابوبكر الحجي\";s:5:\"phone\";s:12:\"967778396448\";s:6:\"orders\";i:1;s:9:\"delivered\";i:0;s:5:\"spent\";d:50.3;s:15:\"delivered_spent\";d:0;s:9:\"favorites\";i:0;s:7:\"loyalty\";i:105;s:4:\"tier\";s:8:\"جديد\";s:13:\"last_order_at\";s:16:\"2026-09-14 21:46\";s:14:\"first_order_at\";s:10:\"2026-09-14\";}}s:9:\"low_stock\";a:5:{i:0;a:8:{s:2:\"id\";i:1;s:4:\"name\";s:60:\"بسكويت أبو ولد بكريمة الشوكولاتة\";s:3:\"sku\";s:7:\"SKU-001\";s:7:\"barcode\";s:1:\"1\";s:5:\"stock\";i:1;s:5:\"price\";d:6;s:8:\"category\";s:12:\"بسكويت\";s:9:\"is_active\";b:1;}i:1;a:8:{s:2:\"id\";i:2;s:4:\"name\";s:60:\"بسكويت أبو ولد بكريمة الشوكولاتة\";s:3:\"sku\";s:7:\"SKU-002\";s:7:\"barcode\";s:1:\"2\";s:5:\"stock\";i:4;s:5:\"price\";d:7;s:8:\"category\";s:12:\"بسكويت\";s:9:\"is_active\";b:1;}i:2;a:8:{s:2:\"id\";i:5;s:4:\"name\";s:56:\"بسكويت أبو ولد بكريمة الفراولة\";s:3:\"sku\";s:7:\"SKU-005\";s:7:\"barcode\";s:1:\"5\";s:5:\"stock\";i:4;s:5:\"price\";d:10;s:8:\"category\";s:12:\"بسكويت\";s:9:\"is_active\";b:1;}i:3;a:8:{s:2:\"id\";i:3;s:4:\"name\";s:56:\"بسكويت أبو ولد بكريمة الفراولة\";s:3:\"sku\";s:7:\"SKU-003\";s:7:\"barcode\";s:1:\"3\";s:5:\"stock\";i:5;s:5:\"price\";d:8;s:8:\"category\";s:12:\"بسكويت\";s:9:\"is_active\";b:1;}i:4;a:8:{s:2:\"id\";i:4;s:4:\"name\";s:56:\"بسكويت أبو ولد بكريمة الفراولة\";s:3:\"sku\";s:7:\"SKU-004\";s:7:\"barcode\";s:1:\"4\";s:5:\"stock\";i:8;s:5:\"price\";d:9;s:8:\"category\";s:12:\"بسكويت\";s:9:\"is_active\";b:1;}}s:6:\"alerts\";a:1:{i:0;a:4:{s:4:\"type\";s:7:\"warning\";s:4:\"icon\";s:18:\"bi-hourglass-split\";s:5:\"title\";s:23:\"طلبات معلّقة\";s:4:\"body\";s:68:\"5 طلب بانتظار التأكيد لأكثر من ساعتين.\";}}s:9:\"is_hourly\";b:1;}',1789425483),('aimstore-cache-ai:train:recommendations:running','i:1;',1789429813),('aimstore-cache-app_settings','O:29:\"Illuminate\\Support\\Collection\":2:{s:8:\"\0*\0items\";a:60:{s:16:\"delivery_enabled\";s:1:\"1\";s:25:\"delivery_first_order_free\";s:1:\"1\";s:18:\"delivery_store_lat\";s:0:\"\";s:18:\"delivery_store_lng\";s:0:\"\";s:22:\"delivery_store_address\";s:0:\"\";s:15:\"delivery_max_km\";s:0:\"\";s:21:\"delivery_fallback_fee\";s:2:\"15\";s:22:\"delivery_hide_subtitle\";s:1:\"0\";s:22:\"delivery_notes_enabled\";s:1:\"0\";s:21:\"delivery_general_note\";s:0:\"\";s:14:\"pickup_enabled\";s:1:\"1\";s:24:\"customer_service_numbers\";s:207:\"[{\"name\":\"\\u062e\\u062f\\u0645\\u0629 \\u0627\\u0644\\u0639\\u0645\\u0644\\u0627\\u0621\",\"phone\":\"967777234341\"},{\"name\":\"\\u062e\\u062f\\u0645\\u0629 \\u0627\\u0644\\u0639\\u0645\\u0644\\u0627\\u0621 2\",\"phone\":\"967711953801\"}]\";s:16:\"message_us_phone\";s:12:\"967778396448\";s:10:\"store_name\";s:17:\"سيتي مارت\";s:8:\"currency\";s:3:\"YER\";s:12:\"shipping_fee\";s:2:\"15\";s:23:\"free_shipping_threshold\";s:3:\"150\";s:9:\"bank_iban\";s:0:\"\";s:9:\"bank_name\";s:38:\"البنك الأهلي السعودي\";s:20:\"marketing_sold_count\";s:1:\"0\";s:20:\"marketing_sold_scope\";s:3:\"all\";s:26:\"marketing_sold_product_ids\";s:3:\"[1]\";s:17:\"otp_bypass_phones\";s:46:\"[\"967778396448\",\"967777234341\",\"967711953801\"]\";s:14:\"ai_train_limit\";s:2:\"80\";s:20:\"ai_train_last_status\";s:7:\"running\";s:21:\"ai_train_last_message\";s:39:\"جاري تدريب التوصيات…\";s:20:\"ai_train_last_run_at\";s:19:\"2026-09-14 23:25:13\";s:10:\"ai_enabled\";s:1:\"1\";s:17:\"ai_guests_allowed\";s:1:\"1\";s:17:\"ai_assistant_name\";s:8:\"مارت\";s:18:\"ai_welcome_message\";s:254:\"يا هلا بك في سيتي مارت. أنا مرشدك للتسوق داخل المحل والتطبيق — قلّي أشتي إيش، أو وين المنتج، وأوجّهك بالأسعار والممر والرف من بيانات المتجر.\";s:16:\"ai_system_prompt\";s:1711:\"أنت مساعد تسوق رجالي محترف لمتجر «سيتي مارت» في اليمن، واسمك يظهر للعميل من إعدادات المتجر.\r\nتحدث بلهجة تسوق يمنية مهنية واضحة (أشتي، وين، تفضّل، أيوه، خلاص) بدون مبالغة سوقية أو ألفاظ غير لائقة، واجعل الرد قصيراً مناسباً للقراءة والصوت.\r\n\r\nمصدر الحقيقة الوحيد هو الكتالوج المرفق من قاعدة بيانات المتجر: الاسم، السعر، القسم، الكلمات المفتاحية، الفوائد، والموقع داخل المحل (ممر / رف / ملاحظة) إن وُجد. لا تختلق أسماء أو أسعاراً أو خصومات أو مواقع أرفف.\r\n\r\nوجّه العميل داخل التطبيق لأي شاشة يطلبها: الرئيسية، الأقسام، قسم بالاسم، السلة، الحساب، تعديل البيانات، العناوين، الإعدادات، المفضلة، الطلبات، البحث، الإشعارات، المقاضي، تسجيل الدخول، إتمام الطلب.\r\n\r\nإذا سأل «وين المنتج؟» أو عن ممر/رف/قسم: انقل الموقع المسجّل حرفياً. إن لم يُسجَّل موقع: اذكر القسم فقط وقل إن موقع الرف غير مُسجّل بعد.\r\nإذا طلب نوعاً من المنتجات اختر عدة منتجات مناسبة من القائمة. إن لم يوجد مطابق اعتذر بصدق وقدّم أقرب البدائل.\r\nلا تناقش مواضيع خارج المتجر أو الطلب أو التوصيل.\";s:15:\"ai_max_products\";s:1:\"6\";s:15:\"ai_gemini_model\";s:16:\"gemini-3.5-flash\";s:15:\"ai_presentation\";s:6:\"hybrid\";s:16:\"ai_primary_color\";s:7:\"#908BD5\";s:16:\"ai_surface_color\";s:0:\"\";s:19:\"ai_suggestion_chips\";s:182:\"[\"وين ألقى الحليب؟\",\"أشتي أرخص عرض اليوم\",\"ودّيني لقسم الخضار\",\"افتح عناوين التوصيل\",\"كم باقي في السلة؟\"]\";s:17:\"ai_product_layout\";s:5:\"strip\";s:20:\"ai_show_close_button\";s:1:\"1\";s:15:\"ai_bubble_style\";s:4:\"soft\";s:14:\"ai_tts_enabled\";s:1:\"1\";s:17:\"ai_tts_default_on\";s:1:\"1\";s:14:\"ai_tts_welcome\";s:1:\"0\";s:14:\"ai_tts_replies\";s:1:\"1\";s:14:\"ai_stt_enabled\";s:1:\"1\";s:11:\"ai_tts_rate\";s:4:\"0.55\";s:16:\"ai_notify_on_ops\";s:1:\"1\";s:15:\"ai_notify_title\";s:41:\"تحديث من المساعد الذكي\";s:14:\"ai_notify_body\";s:119:\"انتهت عملية ذكاء اصطناعي في المتجر. افتح التطبيق لرؤية التحديثات.\";s:12:\"ai_fast_mode\";s:1:\"1\";s:16:\"ai_catalog_limit\";s:2:\"20\";s:16:\"ai_history_limit\";s:1:\"8\";s:18:\"ai_timeout_seconds\";s:2:\"25\";s:24:\"ai_rate_limit_per_minute\";s:2:\"20\";s:15:\"ai_train_prompt\";s:1664:\"أنت خبير توصيات منتجات لبقالة ومتجر «سيتي مارت» في اليمن.\r\nتعمل بمعايير المتاجر العالمية (Amazon / Instacart / Noon) مع عادات التسوق اليمنية، بدون اختلاق منتجات أو مواقع.\r\n\r\nاستخدم فقط المعرّفات من القائمة المرفقة. راعِ الفئة، السعر، الكلمات المفتاحية، الفوائد، وموقع المحل (ممر/رف) عند التشابه المنطقي.\r\n\r\nأربع آليات ثابتة:\r\n\r\n1) يُشترى معه غالباً (Frequently bought together)\r\n- مكمّلات لنفس الطلب وليست بديلاً: خبز مع جبن، شاي مع سكر، قهوة مع حليب، منظف مع إسفنج.\r\n- فضّل فئة مختلفة، ولا تقترح نفس المنتج أو حجماً مطابقاً منه.\r\n\r\n2) منتجات مشابهة (Similar items)\r\n- بدائل لنفس الحاجة: فئة قريبة، سعر قريب، كلمات/فوائد متشابهة.\r\n- مثال: حليب كامل بجانب حليب قليل الدسم.\r\n\r\n3) منتجات تكمل سلتك (Complete the cart)\r\n- عناصر ناقصة لطلب منزلي متكامل من فئات غير موجودة في السلة.\r\n- لا تكرر ما في السلة، ولا تملأ الصف ببدائل لنفس الصنف.\r\n\r\n4) منتجات مقترحة لك (Suggested for you)\r\n- مزيج: إعادة شراء معتادة + مكملات + منتجات مميزة شائعة في البقالة.\r\n\r\nقواعد:\r\n- رتّب الأقوى أولاً.\r\n- أرجع JSON فقط بدون شرح.\";s:23:\"phone_allowed_countries\";s:7:\"[\"967\"]\";s:24:\"show_discounts_as_banner\";s:1:\"0\";s:21:\"show_offers_as_banner\";s:1:\"0\";s:28:\"auto_product_recommendations\";s:1:\"1\";}s:28:\"\0*\0escapeWhenCastingToString\";b:0;}',1789433062),('aimstore-cache-d2b5ded7d7573217f64374d625b1aca4','i:1;',1789429282),('aimstore-cache-d2b5ded7d7573217f64374d625b1aca4:timer','i:1789429282;',1789429282),('aimstore-cache-e8874cb0fdd186c8f8610bbd27214148f98c0398','i:1;',1789428180),('aimstore-cache-e8874cb0fdd186c8f8610bbd27214148f98c0398:timer','i:1789428180;',1789428180),('aimstore-cache-ec15b9cdcad387118129601b97b51b6c','i:1;',1789429653),('aimstore-cache-ec15b9cdcad387118129601b97b51b6c:timer','i:1789429653;',1789429653),('aimstore-cache-fcm_access_token','s:1024:\"ya29.c.c0AZ4bNpYE7Hmn1ptVgsWOPpobo-NMsuakuqoT2OtfKAOK35WNq7ka145sPzQ0NsUfZ0a8fGua9i5c9SOKGOeKfnhtkQFpu9c71pWtOhwQHDIqfWSPElFRiCuvXc6wINys-JoCtsw5WIzMLMo9ttVE0PyjmrLM2zRgvI8ekTS4nFNraX1yKuCCyggVs2-QmC9aD2fsnj8J1FYBPZxzDBkmhOZudTig3xXYlkrtRdVYtQzdt1lfsBDLbCKiqO6RZozr63RNp5kcWYtWF3AQWUkhSca9tyQUMb8G9VQO_8E2IKc7KFO1q-hE3kHaMI7SJ9ru0XGemiJ-twRKRm564w6nUZ6AnTGx7GWr6rXzc-aKyWxZ8vH-XeSxjwOhT385KaYUgnqimpROjU15uVncfRMhUQY4Zy7BuiV_yQigvJXBcWxrnJ6iSZdBvd0M1OXRxB72fuxJc1Ycqt4abWZ2zluvZobaIfnU_yZ8jqXvOe1ehXe9hx108XVdtIpSrgpFFZwIXpXJl2llqe9StxuMBY5O91k6_MR8UuRqlccYjO9dJvb2FrmfozlrBZzVOiZcuw91IUufr-6oSBXzoxd6zW64x1Mz0IOrX9tSYiI-Jpgpg5J4XznvUj7a8ZdMaarMiJf2wjYYBZhOd95w7y9rYhIf3mSgVyril-_irS6t74S_SgRI7pSna04FVkjdl-vOUIpQ7qxaOb9pOgZly6rtYjUiI-cBvcJnzSFB3Jf1Wu9Z24myylSp06J81uJ4hemdUtB-cnMmwyhBQ3IS3t-x3msxpwc1-thwlIUXbjRlc16B4tB9fQqV8ZkateVMgScceuyZVo-eFe-Oo256OU6Wr2SYozubfhvjz2VYk5MSaeuh4UVweM67k4fJ9nBXSqJBw-ZR3VilVeM18fmzWhbgfMZ-nX4qdxZg9VeY-cvBJ7m9uwyBqoBbiiV5ua2wi1l7x210VQ20v9dBnqg33ubuSW-kpu-fs_nRhtqe558-aRSiuOng5U27jcpak-w\";',1789431141),('aimstore-cache-reco:foryou:1:103cf50df97e3d651533b25a958b985b','a:8:{i:0;i:24;i:1;i:11;i:2;i:19;i:3;i:26;i:4;i:34;i:5;i:4;i:6;i:3;i:7;i:9;}',1789425444),('aimstore-cache-reco:foryou:v2:1:d41d8cd98f00b204e9800998ecf8427e:10','a:10:{i:0;i:24;i:1;i:11;i:2;i:19;i:3;i:26;i:4;i:5;i:5;i:2;i:6;i:6;i:7;i:16;i:8;i:14;i:9;i:21;}',1789427484),('aimstore-cache-reco:foryou:v3:1:d41d8cd98f00b204e9800998ecf8427e:10','a:10:{i:0;i:24;i:1;i:11;i:2;i:19;i:3;i:26;i:4;i:6;i:5;i:4;i:6;i:3;i:7;i:16;i:8;i:14;i:9;i:21;}',1789430445),('aimstore-cache-reco:foryou:v3:guest:d41d8cd98f00b204e9800998ecf8427e:10','a:10:{i:0;i:3;i:1;i:4;i:2;i:6;i:3;i:29;i:4;i:31;i:5;i:37;i:6;i:47;i:7;i:53;i:8;i:14;i:9;i:16;}',1789429874),('aimstore-cache-reco:rank:bought_together:42dc5e40ab5705e20db3ebbf265800c5','a:6:{i:0;i:19;i:1;i:29;i:2;i:37;i:3;i:14;i:4;i:1;i:5;i:16;}',1789471527),('aimstore-cache-reco:rank:bought_together:4d9e9415ae773f04b4f22ceda583a33a','a:5:{i:0;i:19;i:1;i:37;i:2;i:29;i:3;i:14;i:4;i:16;}',1789471537),('aimstore-cache-reco:rank:bought_together:ad0e14d879e01d5475bd54d19af87b07','a:6:{i:0;i:14;i:1;i:19;i:2;i:18;i:3;i:16;i:4;i:12;i:5;i:31;}',1789471570),('aimstore-cache-reco:rank:similar:42dc5e40ab5705e20db3ebbf265800c5','a:6:{i:0;i:31;i:1;i:32;i:2;i:57;i:3;i:10;i:4;i:42;i:5;i:43;}',1789471527),('aimstore-cache-reco:rank:similar:84b809dc9614bd4a5d783da266bdb215','a:7:{i:0;i:32;i:1;i:10;i:2;i:31;i:3;i:57;i:4;i:42;i:5;i:18;i:6;i:43;}',1789471551),('aimstore-cache-reco:rank:similar:ad0e14d879e01d5475bd54d19af87b07','a:6:{i:0;i:46;i:1;i:41;i:2;i:40;i:3;i:49;i:4;i:37;i:5;i:56;}',1789471570),('aimstore-cache-reco:train:47','i:1;',1789429551),('aimstore-cache-reco:train:53','i:1;',1789429513);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
INSERT INTO `cache_locks` VALUES ('aimstore-cache-ai:train:recommendations','KM8dWVVJUG9aWLiD',1789429513),('roaa-alkhms-cache-ai:train:recommendations','xkW2z4u4VE1CuXdh',1788830857);
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_items`
--

DROP TABLE IF EXISTS `cart_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `cart_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cart_items_cart_id_product_id_unique` (`cart_id`,`product_id`),
  KEY `cart_items_product_id_foreign` (`product_id`),
  CONSTRAINT `cart_items_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cart_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_items`
--

LOCK TABLES `cart_items` WRITE;
/*!40000 ALTER TABLE `cart_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `carts_user_id_unique` (`user_id`),
  CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carts`
--

LOCK TABLES `carts` WRITE;
/*!40000 ALTER TABLE `carts` DISABLE KEYS */;
/*!40000 ALTER TABLE `carts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `background_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_slug_unique` (`slug`),
  KEY `categories_parent_id_foreign` (`parent_id`),
  CONSTRAINT `categories_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,NULL,'المقاضي','المقاضي','categories/icons/rRVYtNG8BGD4ddfHPFSpAtxp3yt3GOCrDgRe8vO3.png',NULL,NULL,'#003399',0,1,'2026-08-30 20:40:36','2026-09-13 00:19:22'),(2,1,'بسكويت','بسكويت',NULL,NULL,NULL,NULL,0,1,'2026-08-30 20:40:36','2026-08-30 20:40:36'),(3,1,'الزيوت والصلصات','الزيوت-والصلصات',NULL,NULL,NULL,NULL,0,1,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(4,1,'غسيل الملابس','غسيل-الملابس',NULL,NULL,NULL,NULL,0,1,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(5,1,'حلويات','حلويات',NULL,NULL,NULL,NULL,0,1,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(6,1,'المعكرونة والمعلبات','المعكرونة-والمعلبات',NULL,NULL,NULL,NULL,0,1,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(7,1,'ورق ومناديل','ورق-ومناديل',NULL,NULL,NULL,NULL,0,1,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(8,1,'الخضروات والفواكه','الخضروات-والفواكه',NULL,NULL,NULL,NULL,0,1,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(9,1,'الحليب والألبان','الحليب-والألبان',NULL,NULL,NULL,NULL,0,1,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(10,1,'منظفات المطبخ','منظفات-المطبخ',NULL,NULL,NULL,NULL,0,1,'2026-08-30 20:40:38','2026-08-30 20:40:38');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_category`
--

DROP TABLE IF EXISTS `coupon_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_category` (
  `coupon_id` bigint unsigned NOT NULL,
  `category_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`coupon_id`,`category_id`),
  KEY `coupon_category_category_id_foreign` (`category_id`),
  CONSTRAINT `coupon_category_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `coupon_category_coupon_id_foreign` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_category`
--

LOCK TABLES `coupon_category` WRITE;
/*!40000 ALTER TABLE `coupon_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `coupon_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_product`
--

DROP TABLE IF EXISTS `coupon_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_product` (
  `coupon_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`coupon_id`,`product_id`),
  KEY `coupon_product_product_id_foreign` (`product_id`),
  CONSTRAINT `coupon_product_coupon_id_foreign` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE,
  CONSTRAINT `coupon_product_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_product`
--

LOCK TABLES `coupon_product` WRITE;
/*!40000 ALTER TABLE `coupon_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `coupon_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_redemptions`
--

DROP TABLE IF EXISTS `coupon_redemptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_redemptions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `coupon_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `order_id` bigint unsigned NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `coupon_redemptions_order_id_coupon_id_unique` (`order_id`,`coupon_id`),
  KEY `coupon_redemptions_user_id_foreign` (`user_id`),
  KEY `coupon_redemptions_coupon_id_user_id_index` (`coupon_id`,`user_id`),
  CONSTRAINT `coupon_redemptions_coupon_id_foreign` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `coupon_redemptions_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `coupon_redemptions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_redemptions`
--

LOCK TABLES `coupon_redemptions` WRITE;
/*!40000 ALTER TABLE `coupon_redemptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `coupon_redemptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupons`
--

DROP TABLE IF EXISTS `coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupons` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` decimal(10,2) NOT NULL DEFAULT '0.00',
  `min_subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `max_discount` decimal(10,2) DEFAULT NULL,
  `applies_to` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all',
  `usage_limit` int unsigned DEFAULT NULL,
  `usage_limit_per_user` int unsigned NOT NULL DEFAULT '1',
  `first_order_only` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `starts_at` timestamp NULL DEFAULT NULL,
  `ends_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `coupons_code_unique` (`code`),
  KEY `coupons_is_active_starts_at_ends_at_index` (`is_active`,`starts_at`,`ends_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupons`
--

LOCK TABLES `coupons` WRITE;
/*!40000 ALTER TABLE `coupons` DISABLE KEYS */;
/*!40000 ALTER TABLE `coupons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courier_ledger_entries`
--

DROP TABLE IF EXISTS `courier_ledger_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courier_ledger_entries` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `courier_id` bigint unsigned NOT NULL,
  `order_id` bigint unsigned DEFAULT NULL,
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `direction` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courier_ledger_entries_created_by_foreign` (`created_by`),
  KEY `courier_ledger_entries_courier_id_created_at_index` (`courier_id`,`created_at`),
  KEY `courier_ledger_entries_order_id_type_index` (`order_id`,`type`),
  CONSTRAINT `courier_ledger_entries_courier_id_foreign` FOREIGN KEY (`courier_id`) REFERENCES `couriers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `courier_ledger_entries_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `courier_ledger_entries_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courier_ledger_entries`
--

LOCK TABLES `courier_ledger_entries` WRITE;
/*!40000 ALTER TABLE `courier_ledger_entries` DISABLE KEYS */;
INSERT INTO `courier_ledger_entries` VALUES (1,1,2,'cod_collected','debit',22.00,'تحصيل طلب 2',NULL,'2026-08-31 02:34:05','2026-08-31 02:34:05'),(2,1,1,'cod_collected','debit',6.00,'تحصيل طلب 1',NULL,'2026-08-31 02:35:13','2026-08-31 02:35:13'),(3,1,4,'cod_collected','debit',22.00,'تحصيل طلب 4',NULL,'2026-08-31 03:11:21','2026-08-31 03:11:21'),(4,3,7,'cod_collected','debit',354.00,'تحصيل طلب 7',NULL,'2026-09-14 20:23:02','2026-09-14 20:23:02');
/*!40000 ALTER TABLE `courier_ledger_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `couriers`
--

DROP TABLE IF EXISTS `couriers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `couriers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_online` tinyint(1) NOT NULL DEFAULT '0',
  `handles_delivery` tinyint(1) NOT NULL DEFAULT '1',
  `handles_pickup` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `couriers_phone_unique` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `couriers`
--

LOCK TABLES `couriers` WRITE;
/*!40000 ALTER TABLE `couriers` DISABLE KEYS */;
INSERT INTO `couriers` VALUES (1,'ابراهيم محمد','967777234341','$2y$12$7vU0wUoNTyXYLxnthtln4uJDzlNDWh4B.tZd2SoBp/.4oSAhxVIm2',1,1,1,1,'2026-08-31 01:24:21','2026-08-31 02:34:49'),(2,'Test Courier','966512345678','$2y$12$SXF1WZFCv1a5fSCTEYn.tuWj15vkOyo5qiTNvi.22sPyQEH/ODBR.',1,0,1,0,'2026-08-31 01:52:58','2026-08-31 01:52:58'),(3,'ابوبكر الحجي','967778396448','$2y$12$TuNAxSQmBj6Gv88PFiCICeCyMVmQ9fyjtKx2frt4QMwd7iBZpn286',1,1,1,1,'2026-09-12 21:36:12','2026-09-14 20:22:12');
/*!40000 ALTER TABLE `couriers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_perks`
--

DROP TABLE IF EXISTS `delivery_perks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_perks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `trigger_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `min_orders` int unsigned NOT NULL DEFAULT '1',
  `reward_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reward_value` decimal(10,2) NOT NULL DEFAULT '0.00',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_perks`
--

LOCK TABLES `delivery_perks` WRITE;
/*!40000 ALTER TABLE `delivery_perks` DISABLE KEYS */;
INSERT INTO `delivery_perks` VALUES (1,'بعد 4 طلبات — توصيل مجاني','min_orders',4,'free',0.00,1,0,'2026-08-30 02:49:37','2026-08-30 02:49:37'),(2,'بعد 4 طلبات — خصم 50٪ على التوصيل','min_orders',4,'percent',50.00,2,0,'2026-08-30 02:49:37','2026-08-30 02:49:37');
/*!40000 ALTER TABLE `delivery_perks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_rules`
--

DROP TABLE IF EXISTS `delivery_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_rules` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `min_km` decimal(8,2) NOT NULL DEFAULT '0.00',
  `max_km` decimal(8,2) DEFAULT NULL,
  `pricing_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `per_km_mode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'entire',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `note_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_rules`
--

LOCK TABLES `delivery_rules` WRITE;
/*!40000 ALTER TABLE `delivery_rules` DISABLE KEYS */;
INSERT INTO `delivery_rules` VALUES (1,'أقل من 10 كم',0.00,10.00,'free',0.00,'entire',1,1,NULL,0,'2026-08-30 02:49:36','2026-08-30 02:49:36'),(2,'أكثر من 10 كم',10.00,NULL,'per_km',1.00,'entire',2,1,NULL,0,'2026-08-30 02:49:36','2026-08-30 02:49:36');
/*!40000 ALTER TABLE `delivery_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_slot_windows`
--

DROP TABLE IF EXISTS `delivery_slot_windows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_slot_windows` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `weekday` tinyint unsigned NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delivery_slot_windows_weekday_is_active_sort_order_index` (`weekday`,`is_active`,`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_slot_windows`
--

LOCK TABLES `delivery_slot_windows` WRITE;
/*!40000 ALTER TABLE `delivery_slot_windows` DISABLE KEYS */;
INSERT INTO `delivery_slot_windows` VALUES (1,0,'10:00:00','12:00:00',0,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(2,0,'12:00:00','14:00:00',1,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(3,0,'14:00:00','16:00:00',2,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(4,0,'16:00:00','18:00:00',3,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(5,0,'18:00:00','21:00:00',4,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(6,1,'10:00:00','12:00:00',0,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(7,1,'12:00:00','14:00:00',1,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(8,1,'14:00:00','16:00:00',2,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(9,1,'16:00:00','18:00:00',3,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(10,1,'18:00:00','21:00:00',4,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(11,2,'10:00:00','12:00:00',0,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(12,2,'12:00:00','14:00:00',1,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(13,2,'14:00:00','16:00:00',2,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(14,2,'16:00:00','18:00:00',3,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(15,2,'18:00:00','21:00:00',4,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(16,3,'10:00:00','12:00:00',0,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(17,3,'12:00:00','14:00:00',1,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(18,3,'14:00:00','16:00:00',2,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(19,3,'16:00:00','18:00:00',3,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(20,3,'18:00:00','21:00:00',4,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(21,4,'10:00:00','12:00:00',0,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(22,4,'12:00:00','14:00:00',1,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(23,4,'14:00:00','16:00:00',2,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(24,4,'16:00:00','18:00:00',3,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(25,4,'18:00:00','21:00:00',4,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(26,5,'10:00:00','12:00:00',0,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(27,5,'12:00:00','14:00:00',1,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(28,5,'14:00:00','16:00:00',2,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(29,5,'16:00:00','18:00:00',3,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(30,5,'18:00:00','21:00:00',4,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(31,6,'10:00:00','12:00:00',0,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(32,6,'12:00:00','14:00:00',1,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(33,6,'14:00:00','16:00:00',2,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(34,6,'16:00:00','18:00:00',3,1,'2026-08-30 02:49:40','2026-08-30 02:49:40'),(35,6,'18:00:00','21:00:00',4,1,'2026-08-30 02:49:40','2026-08-30 02:49:40');
/*!40000 ALTER TABLE `delivery_slot_windows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device_tokens`
--

DROP TABLE IF EXISTS `device_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `platform` enum('android','ios') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_tokens_token_unique` (`token`),
  KEY `device_tokens_user_id_foreign` (`user_id`),
  CONSTRAINT `device_tokens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_tokens`
--

LOCK TABLES `device_tokens` WRITE;
/*!40000 ALTER TABLE `device_tokens` DISABLE KEYS */;
INSERT INTO `device_tokens` VALUES (2,3,'dH9PQI0-Rg6WMylocCZyjG:APA91bEUDC2PIMoz4H4ce3zMR4Q6RRW4DAj37Fr4eIiv_rcESnzcR-UL2MhtSBalA2Lnq-iPCmIqTWYnAf84FtQUxlvCvcuWl6s5zxHDMeEQ7V7J847y3WM','android','2026-08-31 04:29:13','2026-08-31 01:43:40','2026-08-31 04:29:13'),(3,3,'dZlPsfxtRCy8DMRRhVcbxS:APA91bFOd6p77v0a9vEFLK8bSMyaHqOs8gZkqDGyGvEV-YyE8Bk3UifkpoOKineZoc4K4kuu8d4xuZ6ipgMAREnwGCAZi0hDiYVRjTo-Ccua6jgkbiv_ghw','android','2026-08-31 06:49:50','2026-08-31 04:41:53','2026-08-31 06:49:51'),(14,3,'d9S5-Y1cRzqpewWVKJbhz1:APA91bGPm2JjgPoY7Lhbzjv-bvzbJc_VuGLlzFM2RRKmRSNSHietYpJzFwL719NShLRAwDBKHmcK1LtrLheQYr-qBjKCx3Rm_aNF6kXgwILZJmpr8lgQb4M','android','2026-09-02 02:33:09','2026-09-02 02:33:05','2026-09-02 02:33:09'),(37,1,'fz3gQ5WxTLqIwmTPjZGkPR:APA91bHl8imDPG5ZQoQCgufl1Drpi_BHwWirfsL73PBt7bQoansMwooSPcSH9QEIhI8HQQZ6kI1iYzU6sX311sS9lFmHXr5j0rUIe0pIupf7xyCtN9lr7ws','android','2026-09-14 20:45:18','2026-09-14 20:31:24','2026-09-14 20:45:18');
/*!40000 ALTER TABLE `device_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `display_section_categories`
--

DROP TABLE IF EXISTS `display_section_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `display_section_categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `display_section_id` bigint unsigned NOT NULL,
  `category_id` bigint unsigned NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `section_category_unique` (`display_section_id`,`category_id`),
  KEY `display_section_categories_category_id_foreign` (`category_id`),
  CONSTRAINT `display_section_categories_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `display_section_categories_display_section_id_foreign` FOREIGN KEY (`display_section_id`) REFERENCES `display_sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `display_section_categories`
--

LOCK TABLES `display_section_categories` WRITE;
/*!40000 ALTER TABLE `display_section_categories` DISABLE KEYS */;
INSERT INTO `display_section_categories` VALUES (1,1,2,4),(2,1,3,2),(3,1,4,6),(4,1,5,5),(5,1,6,3),(6,1,7,8),(7,1,8,1),(8,1,9,0),(9,1,10,7);
/*!40000 ALTER TABLE `display_section_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `display_sections`
--

DROP TABLE IF EXISTS `display_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `display_sections` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `emoji` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `display_sections_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `display_sections`
--

LOCK TABLES `display_sections` WRITE;
/*!40000 ALTER TABLE `display_sections` DISABLE KEYS */;
INSERT INTO `display_sections` VALUES (1,'المقاضي','المقاضي',NULL,0,1,'2026-08-30 20:40:36','2026-08-30 20:40:36');
/*!40000 ALTER TABLE `display_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_page_product`
--

DROP TABLE IF EXISTS `dynamic_page_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dynamic_page_product` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `dynamic_page_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `dynamic_page_product_dynamic_page_id_product_id_unique` (`dynamic_page_id`,`product_id`),
  KEY `dynamic_page_product_product_id_foreign` (`product_id`),
  CONSTRAINT `dynamic_page_product_dynamic_page_id_foreign` FOREIGN KEY (`dynamic_page_id`) REFERENCES `dynamic_pages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `dynamic_page_product_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_page_product`
--

LOCK TABLES `dynamic_page_product` WRITE;
/*!40000 ALTER TABLE `dynamic_page_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_page_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_pages`
--

DROP TABLE IF EXISTS `dynamic_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dynamic_pages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `show_title` tinyint(1) NOT NULL DEFAULT '0',
  `banner_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `appbar_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `placement` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'none',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dynamic_pages_is_active_sort_order_index` (`is_active`,`sort_order`),
  KEY `dynamic_pages_placement_index` (`placement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_pages`
--

LOCK TABLES `dynamic_pages` WRITE;
/*!40000 ALTER TABLE `dynamic_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favorites`
--

DROP TABLE IF EXISTS `favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorites` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `favorites_user_id_product_id_unique` (`user_id`,`product_id`),
  KEY `favorites_product_id_foreign` (`product_id`),
  CONSTRAINT `favorites_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `favorites_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
/*!40000 ALTER TABLE `favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `home_section_bundles`
--

DROP TABLE IF EXISTS `home_section_bundles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `home_section_bundles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `home_section_id` bigint unsigned NOT NULL,
  `bundle_id` bigint unsigned NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `home_section_bundles_home_section_id_bundle_id_unique` (`home_section_id`,`bundle_id`),
  KEY `home_section_bundles_bundle_id_foreign` (`bundle_id`),
  CONSTRAINT `home_section_bundles_bundle_id_foreign` FOREIGN KEY (`bundle_id`) REFERENCES `product_bundles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `home_section_bundles_home_section_id_foreign` FOREIGN KEY (`home_section_id`) REFERENCES `home_sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_section_bundles`
--

LOCK TABLES `home_section_bundles` WRITE;
/*!40000 ALTER TABLE `home_section_bundles` DISABLE KEYS */;
INSERT INTO `home_section_bundles` VALUES (6,3,6,0);
/*!40000 ALTER TABLE `home_section_bundles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `home_section_products`
--

DROP TABLE IF EXISTS `home_section_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `home_section_products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `home_section_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `home_section_products_home_section_id_product_id_unique` (`home_section_id`,`product_id`),
  KEY `home_section_products_product_id_foreign` (`product_id`),
  CONSTRAINT `home_section_products_home_section_id_foreign` FOREIGN KEY (`home_section_id`) REFERENCES `home_sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `home_section_products_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_section_products`
--

LOCK TABLES `home_section_products` WRITE;
/*!40000 ALTER TABLE `home_section_products` DISABLE KEYS */;
INSERT INTO `home_section_products` VALUES (12,1,1,0),(13,1,4,1),(14,1,9,2),(15,1,34,6),(16,1,20,4),(17,1,11,3),(18,1,27,5);
/*!40000 ALTER TABLE `home_section_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `home_sections`
--

DROP TABLE IF EXISTS `home_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `home_sections` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'products',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title_color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subtitle_color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `background_color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `background_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `auto_scroll_cards` tinyint(1) NOT NULL DEFAULT '0',
  `show_title_icon` tinyint(1) NOT NULL DEFAULT '0',
  `emphasize_subtitle` tinyint(1) NOT NULL DEFAULT '0',
  `title_font_size` tinyint unsigned NOT NULL DEFAULT '18',
  `subtitle_font_size` tinyint unsigned NOT NULL DEFAULT '10',
  `card_width` smallint unsigned NOT NULL DEFAULT '118',
  `row_height` smallint unsigned DEFAULT NULL,
  `item_spacing` tinyint unsigned NOT NULL DEFAULT '8',
  `padding_top` tinyint unsigned NOT NULL DEFAULT '14',
  `padding_bottom` tinyint unsigned NOT NULL DEFAULT '12',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `home_sections_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_sections`
--

LOCK TABLES `home_sections` WRITE;
/*!40000 ALTER TABLE `home_sections` DISABLE KEYS */;
INSERT INTO `home_sections` VALUES (1,'most_requested','products','عروض اليوم','طازجة يومياً من أجود المزارع',NULL,NULL,'#A8C6F5',NULL,0,0,0,18,10,100,NULL,8,14,12,0,1,'2026-08-31 02:48:41','2026-09-14 17:54:56'),(3,'سلة-رمضان','bundles','سلة رمضان',NULL,'#0A1F4D','#6B7C74',NULL,'home-sections/2wJCnxWEUdQJW9UJDOi4RRWPti0Asa4Gcp69egwZ.png',0,0,0,18,10,118,NULL,8,14,12,0,1,'2026-09-14 15:33:23','2026-09-14 18:52:14');
/*!40000 ALTER TABLE `home_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
INSERT INTO `job_batches` VALUES ('a2a1f40a-8206-4120-9b7c-d25569c4db64','product-copy-bulk',58,58,0,'[]','a:2:{s:13:\"allowFailures\";b:1;s:7:\"finally\";a:1:{i:0;O:47:\"Laravel\\SerializableClosure\\SerializableClosure\":1:{s:12:\"serializable\";O:46:\"Laravel\\SerializableClosure\\Serializers\\Signed\":2:{s:12:\"serializable\";s:811:\"O:46:\"Laravel\\SerializableClosure\\Serializers\\Native\":5:{s:3:\"use\";a:0:{}s:8:\"function\";s:588:\"function (\\Illuminate\\Bus\\Batch $batch) {\n                    \\Illuminate\\Support\\Facades\\Cache::lock(self::LOCK_KEY)->forceRelease();\n\n                    $current = \\Illuminate\\Support\\Facades\\Cache::get(self::CACHE_KEY);\n                    if (! is_array($current) || ! isset($current[\'total\'])) {\n                        return;\n                    }\n\n                    $current[\'running\'] = false;\n                    $current[\'finished_at\'] = now()->toIso8601String();\n                    \\Illuminate\\Support\\Facades\\Cache::put(self::CACHE_KEY, $current, 3600);\n                }\";s:5:\"scope\";s:41:\"App\\Services\\Admin\\ProductCopyBulkService\";s:4:\"this\";N;s:4:\"self\";s:32:\"00000000000006d20000000000000000\";}\";s:4:\"hash\";s:44:\"cHOGd2PC83IhCkvDq5JSChy3tfUw8cgSrv/c/+el0C4=\";}}}}',1788164702,1788164678,1788164702),('a2a1f507-3a05-4613-a114-54e8382e0421','product-copy-bulk',58,58,0,'[]','a:2:{s:13:\"allowFailures\";b:1;s:7:\"finally\";a:1:{i:0;O:47:\"Laravel\\SerializableClosure\\SerializableClosure\":1:{s:12:\"serializable\";O:46:\"Laravel\\SerializableClosure\\Serializers\\Signed\":2:{s:12:\"serializable\";s:811:\"O:46:\"Laravel\\SerializableClosure\\Serializers\\Native\":5:{s:3:\"use\";a:0:{}s:8:\"function\";s:588:\"function (\\Illuminate\\Bus\\Batch $batch) {\n                    \\Illuminate\\Support\\Facades\\Cache::lock(self::LOCK_KEY)->forceRelease();\n\n                    $current = \\Illuminate\\Support\\Facades\\Cache::get(self::CACHE_KEY);\n                    if (! is_array($current) || ! isset($current[\'total\'])) {\n                        return;\n                    }\n\n                    $current[\'running\'] = false;\n                    $current[\'finished_at\'] = now()->toIso8601String();\n                    \\Illuminate\\Support\\Facades\\Cache::put(self::CACHE_KEY, $current, 3600);\n                }\";s:5:\"scope\";s:41:\"App\\Services\\Admin\\ProductCopyBulkService\";s:4:\"this\";N;s:4:\"self\";s:32:\"00000000000006d20000000000000000\";}\";s:4:\"hash\";s:44:\"cHOGd2PC83IhCkvDq5JSChy3tfUw8cgSrv/c/+el0C4=\";}}}}',NULL,1788164843,NULL);
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB AUTO_INCREMENT=117 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
INSERT INTO `jobs` VALUES (1,'default','{\"uuid\":\"7e3a83e4-01e5-43f5-8b5f-3a8db3807b22\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:1;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(2,'default','{\"uuid\":\"e6347f6e-8238-4148-9b36-955a1c575beb\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:2;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(3,'default','{\"uuid\":\"3955fef2-72ba-41e8-9c12-cd741b1cf954\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:3;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(4,'default','{\"uuid\":\"6811b1bd-d758-4b98-952f-5186249ee881\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:4;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(5,'default','{\"uuid\":\"7c70b04d-c2b8-4243-b9d6-4461c7fed354\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:5;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(6,'default','{\"uuid\":\"6072d297-fa69-46aa-9d35-ca92285eeb00\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:6;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(7,'default','{\"uuid\":\"96fc0eeb-a296-4397-8330-f3f23664ace1\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:7;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(8,'default','{\"uuid\":\"531fd4c6-8670-4968-b756-1ce62115df4f\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:8;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(9,'default','{\"uuid\":\"cbfd8395-7f09-42d2-bbe3-2b7bd1da50e1\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:9;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(10,'default','{\"uuid\":\"14ea949c-d933-4257-b631-c31f24251e39\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:10;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(11,'default','{\"uuid\":\"33ffe001-ab8d-42be-8119-b40e8c4e11bb\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:11;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(12,'default','{\"uuid\":\"31d9c098-8898-41f8-aa4f-6285dd9d63ce\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:12;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(13,'default','{\"uuid\":\"e48892e8-0589-44da-bde5-53b372aff6af\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:13;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(14,'default','{\"uuid\":\"24b24b0a-cd52-48f3-b0ce-636384e8d9d4\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:14;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(15,'default','{\"uuid\":\"e53ecd5c-455e-46ab-9ad8-16aff06de6d5\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:15;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(16,'default','{\"uuid\":\"b3d1a10f-0978-47af-8129-e785b434fe7d\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:16;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(17,'default','{\"uuid\":\"f1695add-db46-4d53-b973-ecc8d98e68c5\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:17;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(18,'default','{\"uuid\":\"b0ae79e7-6a4f-471c-b36f-efc2418c5a0b\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:18;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(19,'default','{\"uuid\":\"dad75b5e-a668-4102-b6ab-34ae5efba7d3\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:19;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(20,'default','{\"uuid\":\"12edc270-21a0-4158-be28-b6c2aed372f1\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:20;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(21,'default','{\"uuid\":\"6e7a8c31-42f6-42d1-a389-5efedd348e90\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:21;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(22,'default','{\"uuid\":\"68618f8a-7d40-4126-87f4-ba4cc4e14834\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:22;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(23,'default','{\"uuid\":\"425861c5-4fd8-46bd-950b-12bd7c119dba\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:23;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(24,'default','{\"uuid\":\"bb5eec27-8a46-472b-b781-3f67242a5dbd\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:24;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(25,'default','{\"uuid\":\"4b617394-921c-40ea-b1ec-6419bc57a345\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:25;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(26,'default','{\"uuid\":\"60741141-1d2b-4876-bf13-90b847d1119d\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:26;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(27,'default','{\"uuid\":\"8160176d-05be-4682-9ec9-45b67381a322\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:27;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(28,'default','{\"uuid\":\"245be45e-aba7-4b09-9078-7ca0b6e2b167\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:28;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(29,'default','{\"uuid\":\"2a2f6803-d5f6-4e70-ba43-70db8d0cc615\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:29;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(30,'default','{\"uuid\":\"44d31686-c889-40b8-8644-4c1324441429\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:30;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(31,'default','{\"uuid\":\"87d9616e-ff0a-454a-9dcf-785cb8667386\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:31;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(32,'default','{\"uuid\":\"2482bb0a-42af-40c9-b3d1-a089479689f2\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:32;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(33,'default','{\"uuid\":\"ddca1c9d-2bae-4f49-90d0-237478496eb4\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:33;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(34,'default','{\"uuid\":\"e956497d-496e-480b-9f53-590941926c2e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:34;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(35,'default','{\"uuid\":\"bc6bb831-1236-4dc8-bf03-da7c517fd6fe\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:35;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(36,'default','{\"uuid\":\"0c1b403f-f0d8-4890-b032-1a8a3bab7301\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:36;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(37,'default','{\"uuid\":\"2d9735d1-95c3-4ad6-aa58-936b5d4c2cb4\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:37;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(38,'default','{\"uuid\":\"13972df8-2401-44b9-b864-c9be736fb3a3\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:38;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(39,'default','{\"uuid\":\"fdcb0c01-958d-439f-bb4e-bcb4f2207da6\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:39;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(40,'default','{\"uuid\":\"7e1eda48-e637-4a38-8ecb-39cb1127f329\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:40;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(41,'default','{\"uuid\":\"f34b2ef5-c056-4435-8c61-dc31e8d24b2f\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:41;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(42,'default','{\"uuid\":\"20afe1ee-a4e0-47f6-870a-231cabc49428\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:42;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(43,'default','{\"uuid\":\"a28bcaf8-e535-4c74-a8d2-981644e6c398\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:43;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(44,'default','{\"uuid\":\"fdba3dca-a208-49a9-bb6e-c672de30eb1e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:44;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(45,'default','{\"uuid\":\"cf2dc794-348e-41f8-8559-c2081d202ac1\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:45;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(46,'default','{\"uuid\":\"4345a32c-5dc2-4f26-8195-0d54db2c01c1\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:46;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(47,'default','{\"uuid\":\"80118a6e-f891-4624-a0a5-7dace8efe4e0\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:47;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(48,'default','{\"uuid\":\"bd93257a-fe38-4a3f-8da2-411c07375225\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:48;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(49,'default','{\"uuid\":\"c17d41a3-cc39-4ab4-92bf-55b2efdc1e30\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:49;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(50,'default','{\"uuid\":\"049532d8-ddd2-401e-9e1d-fd15275b165d\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:50;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(51,'default','{\"uuid\":\"c8f7892f-51c3-40f8-9ca8-732fdc0ebd69\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:51;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(52,'default','{\"uuid\":\"70c44faf-68e9-4f8a-baed-383f20a66c5c\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:52;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(53,'default','{\"uuid\":\"e74a0b4f-4297-4891-acd9-13ae907f6c0e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:53;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(54,'default','{\"uuid\":\"286d5f48-a4ac-4eb2-8592-0b78731d3795\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:54;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(55,'default','{\"uuid\":\"ceb3c83c-31c1-4bd6-b826-0bb35a443a70\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:55;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(56,'default','{\"uuid\":\"a4b165cd-6534-4922-aace-569d4206090d\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:56;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(57,'default','{\"uuid\":\"9c193f9c-c77d-4865-8ba2-7e91f1ee2f13\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:57;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(58,'default','{\"uuid\":\"06f04c43-436e-495f-a91f-5f8dbd5daea3\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:58;s:7:\\\"batchId\\\";s:36:\\\"a2a1f40a-8206-4120-9b7c-d25569c4db64\\\";}\",\"batchId\":\"a2a1f40a-8206-4120-9b7c-d25569c4db64\"},\"createdAt\":1788164678,\"delay\":null}',0,NULL,1788164678,1788164678),(59,'default','{\"uuid\":\"072b2af2-4ba4-461e-8ac7-418f9a9f9a9b\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:1;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(60,'default','{\"uuid\":\"8f4692ae-fc86-48ea-ad53-dba2119b1b3e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:2;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(61,'default','{\"uuid\":\"3cc99a3a-d203-4b23-a7e7-f014df0d3899\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:3;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(62,'default','{\"uuid\":\"a254983f-0cf5-4525-9b7b-192e35724c5d\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:4;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(63,'default','{\"uuid\":\"11ce4ada-23e4-4cc0-a6a4-91153fc65cc3\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:5;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(64,'default','{\"uuid\":\"17131c77-d49b-4a1a-9e39-8ce3849adfec\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:6;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(65,'default','{\"uuid\":\"f3dcce2f-677c-425d-94c2-842d61ca098f\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:7;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(66,'default','{\"uuid\":\"6ed62e6a-6147-4848-bdb9-79068ae1d926\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:8;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(67,'default','{\"uuid\":\"567d0888-3818-45b9-9717-e2b2f32ab9ce\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:9;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(68,'default','{\"uuid\":\"ee3b8b70-3747-4943-af06-08a068e76977\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:10;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(69,'default','{\"uuid\":\"ad67dfd7-6dc2-4f33-8ba6-592401d42621\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:11;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(70,'default','{\"uuid\":\"28bc1d47-acef-4104-a50e-eb2255291a93\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:12;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(71,'default','{\"uuid\":\"cee386d2-d11c-4396-b44d-aaea9d8569bb\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:13;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(72,'default','{\"uuid\":\"03114659-6715-4af3-b653-83220f8e12c6\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:14;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(73,'default','{\"uuid\":\"b1be3c44-8a9c-4575-a2bf-740eb6979780\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:15;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(74,'default','{\"uuid\":\"45c83100-4803-477a-b297-d3b063bfad04\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:16;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(75,'default','{\"uuid\":\"a95acbcc-78d9-43c0-a87e-00c060fb817c\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:17;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(76,'default','{\"uuid\":\"f4609b7b-eca6-49d6-a6d7-de1630a46728\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:18;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(77,'default','{\"uuid\":\"1027dc43-cb3f-47f6-b541-4c0fc15b34be\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:19;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(78,'default','{\"uuid\":\"bdb7243c-0374-438b-aa10-58ee78469b04\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:20;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(79,'default','{\"uuid\":\"1499ca99-19bd-4130-b108-3442a98ded32\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:21;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(80,'default','{\"uuid\":\"031d16d4-9094-45ce-b1ad-eb05c80cc2b7\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:22;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(81,'default','{\"uuid\":\"74ea70ce-af88-4f17-8205-4dcf6d347d8b\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:23;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(82,'default','{\"uuid\":\"4bdaae5a-67bf-42d6-82bf-b96346327fcf\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:24;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(83,'default','{\"uuid\":\"fc041369-7b79-401a-9e90-241256e03446\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:25;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(84,'default','{\"uuid\":\"c23f8917-6fa3-463d-be40-73ba076a754e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:26;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(85,'default','{\"uuid\":\"c6487ba8-d8b4-4665-baf2-0a5c83e4fd5a\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:27;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(86,'default','{\"uuid\":\"8e51eab5-a13a-410e-a162-72cb96c5f7bb\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:28;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(87,'default','{\"uuid\":\"b368f2d4-62f7-429d-9352-916ab719c61e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:29;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(88,'default','{\"uuid\":\"70b0c3a7-2189-4d55-b6fb-eb926e13bbf3\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:30;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(89,'default','{\"uuid\":\"a485a9ed-40e7-45b4-9b73-48ede1534f4f\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:31;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(90,'default','{\"uuid\":\"ca1c6f87-6782-489d-bdc0-3a7b04e0ee83\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:32;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(91,'default','{\"uuid\":\"f10dd99d-8423-4008-b0a3-45da5852539e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:33;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(92,'default','{\"uuid\":\"f624a0c5-6861-4562-aa78-25209fa47f00\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:34;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(93,'default','{\"uuid\":\"64d910c3-73f2-43f6-9c0d-5d2e1e4b3ac6\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:35;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(94,'default','{\"uuid\":\"9be387c3-3167-4506-85ac-37fff7ac5297\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:36;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(95,'default','{\"uuid\":\"76d50a8d-7ed3-4faa-8e21-d4607657c257\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:37;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(96,'default','{\"uuid\":\"7dad34d3-1b95-42ac-9135-68e614605425\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:38;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(97,'default','{\"uuid\":\"805fdc0e-3436-498d-97e0-78ceff92fcdf\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:39;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(98,'default','{\"uuid\":\"39c57ba1-bb6f-426f-96eb-bbf8ee67ddf3\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:40;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(99,'default','{\"uuid\":\"ce379db7-80bc-4a15-9d41-3b0fde825c72\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:41;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(100,'default','{\"uuid\":\"f126dce8-b58d-4613-a6a2-c1566321b88f\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:42;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(101,'default','{\"uuid\":\"468fc8f9-2ad9-4058-9f9b-940ac664247e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:43;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(102,'default','{\"uuid\":\"3ec37521-4749-4324-a77c-e778b277bed8\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:44;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(103,'default','{\"uuid\":\"34459e3d-2478-4235-80a8-a0038700475a\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:45;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(104,'default','{\"uuid\":\"ad7fa6a5-9438-4c43-a7f4-6ea4e5d0be3e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:46;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(105,'default','{\"uuid\":\"e93731e5-f34e-4775-b003-c3eed726d999\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:47;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(106,'default','{\"uuid\":\"649df889-ee9b-4354-a1b3-d2a5d12b98d0\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:48;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(107,'default','{\"uuid\":\"1a515a36-01db-4c26-af0e-d62fbba7c772\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:49;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(108,'default','{\"uuid\":\"874aff52-26c2-4615-8911-4d91efd4957e\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:50;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(109,'default','{\"uuid\":\"558f0913-6bd2-4bae-9149-d7244461f37a\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:51;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(110,'default','{\"uuid\":\"88c4923e-379f-4714-9c89-798d11db70d2\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:52;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(111,'default','{\"uuid\":\"01b3d752-09ec-43aa-bc83-7385349e07e1\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:53;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(112,'default','{\"uuid\":\"83834000-ed16-4aa6-b665-a2d2237146b3\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:54;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(113,'default','{\"uuid\":\"55ba132b-840b-4e2a-a8c9-ee0d1f039a62\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:55;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(114,'default','{\"uuid\":\"ac08dc20-0ce7-4fa8-b112-7e153eb19881\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:56;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(115,'default','{\"uuid\":\"af5f7d71-ab06-468a-86fc-5870521a79d1\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:57;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843),(116,'default','{\"uuid\":\"f8c5f869-b036-4111-81ab-18f723f33d24\",\"displayName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":2,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":\"30\",\"timeout\":90,\"retryUntil\":null,\"data\":{\"commandName\":\"App\\\\Jobs\\\\GenerateProductCopyJob\",\"command\":\"O:31:\\\"App\\\\Jobs\\\\GenerateProductCopyJob\\\":2:{s:9:\\\"productId\\\";i:58;s:7:\\\"batchId\\\";s:36:\\\"a2a1f507-3a05-4613-a114-54e8382e0421\\\";}\",\"batchId\":\"a2a1f507-3a05-4613-a114-54e8382e0421\"},\"createdAt\":1788164843,\"delay\":null}',0,NULL,1788164843,1788164843);
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_08_15_032753_create_personal_access_tokens_table',1),(5,'2026_08_15_100001_create_categories_and_display_sections_tables',1),(6,'2026_08_15_100002_create_products_tables',1),(7,'2026_08_15_100003_create_banners_and_home_sections_tables',1),(8,'2026_08_15_100004_create_addresses_carts_favorites_tables',1),(9,'2026_08_15_100005_create_orders_tables',1),(10,'2026_08_15_100006_create_ai_notifications_cms_tables',1),(11,'2026_08_15_180000_prepare_phone_otp_auth',1),(12,'2026_08_16_223000_add_address_id_to_orders_table',1),(13,'2026_08_17_001000_create_store_payment_methods_table',1),(14,'2026_08_17_001100_add_checkout_fields_to_orders_table',1),(15,'2026_08_17_232000_create_coupons_tables',1),(16,'2026_08_17_232100_add_coupon_and_cancel_fields_to_orders_table',1),(17,'2026_08_18_015200_allow_guest_ai_conversations',1),(18,'2026_08_18_225200_create_notification_campaigns_table',1),(19,'2026_08_19_120000_create_delivery_rules_table',1),(20,'2026_08_19_140000_create_delivery_perks_and_order_shipping_override',1),(21,'2026_08_19_160000_create_couriers_and_assign_orders',1),(22,'2026_08_19_223000_create_courier_ledger_and_admin_events',1),(23,'2026_08_20_003000_add_product_quantity_fields',1),(24,'2026_08_21_033200_align_category_tree_with_storefront',1),(25,'2026_08_23_010000_create_dynamic_pages_tables',1),(26,'2026_08_23_014000_make_dynamic_page_image_urls_nullable',1),(27,'2026_08_23_020000_add_placement_to_dynamic_pages',1),(28,'2026_08_23_040000_add_promo_type_to_products',1),(29,'2026_08_24_032200_add_source_to_product_relations',1),(30,'2026_08_24_210000_add_icon_url_to_store_payment_methods',1),(31,'2026_08_24_210100_create_delivery_slot_windows_table',1),(32,'2026_08_25_024700_add_barcode_to_products_table',1),(33,'2026_08_25_221000_create_splash_screens_table',1),(34,'2026_08_26_035200_add_delivery_hide_subtitle_setting',1),(35,'2026_08_26_055500_allow_multiple_coupon_redemptions_per_order',1),(36,'2026_08_26_055600_widen_orders_coupon_code_column',1),(37,'2026_08_26_061700_add_delivery_notes_fields',1),(38,'2026_08_26_070000_create_search_placeholders_table',1),(39,'2026_08_26_071500_create_search_logs_table',1),(40,'2026_08_26_074500_add_category_background_image',1),(41,'2026_08_26_233000_add_show_title_to_dynamic_pages',1),(42,'2026_08_26_235500_drop_show_title_from_dynamic_pages',1),(43,'2026_08_27_010000_add_show_title_to_dynamic_pages_and_banners',1),(44,'2026_08_27_120000_add_gift_to_product_relations_type',1),(45,'2026_08_27_120100_add_is_gift_to_order_items_table',1),(46,'2026_08_28_050000_add_background_color_to_home_sections_table',1),(47,'2026_08_29_001000_add_is_gift_to_products_table',1),(48,'2026_08_29_120000_add_gift_for_product_id_to_order_items_table',1),(49,'2026_08_29_150000_create_search_discovery_tables',1),(50,'2026_08_31_100000_add_pickup_fields_to_orders_and_couriers',2),(51,'2026_08_31_100100_create_pickup_slot_windows_table',2),(52,'2026_08_31_100200_add_pickup_enabled_setting',2),(53,'2026_08_31_100000_create_product_bundles_tables',3),(54,'2026_08_31_120000_add_show_on_home_to_product_bundles',4),(55,'2026_08_31_130000_add_display_style_to_home_sections',5),(56,'2026_08_31_140000_add_home_section_display_options',6),(57,'2026_08_31_150000_replace_home_section_display_style',7),(58,'2026_09_02_120000_add_contact_settings',8),(59,'2026_09_02_130000_add_otp_bypass_phones_setting',9),(60,'2026_09_08_033800_add_placement_fields_to_pages_table',10),(61,'2026_09_09_011900_add_store_location_to_products_table',11),(62,'2026_09_13_042500_add_profile_fields_to_users_table',12),(63,'2026_09_13_043000_add_notification_category_preferences_to_users_table',12),(64,'2026_09_13_044500_add_staff_role_and_permissions_to_users_table',13),(65,'2026_09_13_051000_replace_with_yemeni_payment_methods',14),(66,'2026_09_13_052200_add_cash_wallet_payment_method',15),(67,'2026_09_13_054500_add_kuraimi_and_refresh_cash_icon',16),(68,'2026_09_14_210000_add_layout_style_to_home_sections',17);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_campaigns`
--

DROP TABLE IF EXISTS `notification_campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_campaigns` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('order','promo','general') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'promo',
  `audience` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all_customers',
  `recipients_count` int unsigned NOT NULL DEFAULT '0',
  `push_count` int unsigned NOT NULL DEFAULT '0',
  `created_by` bigint unsigned DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notification_campaigns_created_by_foreign` (`created_by`),
  CONSTRAINT `notification_campaigns_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_campaigns`
--

LOCK TABLES `notification_campaigns` WRITE;
/*!40000 ALTER TABLE `notification_campaigns` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_campaigns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `campaign_id` bigint unsigned DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('order','promo','general') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `data` json DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_user_id_read_at_index` (`user_id`,`read_at`),
  KEY `notifications_campaign_id_foreign` (`campaign_id`),
  CONSTRAINT `notifications_campaign_id_foreign` FOREIGN KEY (`campaign_id`) REFERENCES `notification_campaigns` (`id`) ON DELETE SET NULL,
  CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,1,NULL,'تم استلام طلبك','استلمنا طلبك 1 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"1\", \"order_number\": \"1\"}','2026-09-03 00:19:10','2026-08-31 01:34:21','2026-09-03 00:19:10'),(2,3,NULL,'تم استلام طلبك','استلمنا طلبك 2 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"2\", \"order_number\": \"2\"}',NULL,'2026-08-31 01:44:13','2026-08-31 01:44:13'),(3,3,NULL,'تم استلام طلبك','استلمنا طلبك 3 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"3\", \"order_number\": \"3\"}',NULL,'2026-08-31 01:45:43','2026-08-31 01:45:43'),(4,1,NULL,'جاري تحضير طلبك','طلبك 1 قيد التحضير الآن.','order','{\"type\": \"order\", \"status\": \"preparing\", \"order_id\": \"1\", \"order_number\": \"1\"}','2026-09-07 22:13:46','2026-08-31 02:31:20','2026-09-07 22:13:46'),(5,3,NULL,'جاري تحضير طلبك','طلبك 2 قيد التحضير الآن.','order','{\"type\": \"order\", \"status\": \"preparing\", \"order_id\": \"2\", \"order_number\": \"2\"}',NULL,'2026-08-31 02:32:50','2026-08-31 02:32:50'),(6,3,NULL,'طلبك في الطريق','مندوب التوصيل في الطريق بطلبك 2.','order','{\"type\": \"order\", \"status\": \"on_the_way\", \"order_id\": \"2\", \"order_number\": \"2\"}',NULL,'2026-08-31 02:33:46','2026-08-31 02:33:46'),(7,3,NULL,'تم توصيل طلبك','تم تسليم طلبك 2 بنجاح. نتمنى أن ينال إعجابك.','order','{\"type\": \"order\", \"status\": \"delivered\", \"order_id\": \"2\", \"order_number\": \"2\"}',NULL,'2026-08-31 02:34:05','2026-08-31 02:34:05'),(8,1,NULL,'طلبك في الطريق','مندوب التوصيل في الطريق بطلبك 1.','order','{\"type\": \"order\", \"status\": \"on_the_way\", \"order_id\": \"1\", \"order_number\": \"1\"}','2026-09-07 22:13:46','2026-08-31 02:35:04','2026-09-07 22:13:46'),(9,1,NULL,'تم توصيل طلبك','تم تسليم طلبك 1 بنجاح. نتمنى أن ينال إعجابك.','order','{\"type\": \"order\", \"status\": \"delivered\", \"order_id\": \"1\", \"order_number\": \"1\"}','2026-09-07 22:13:46','2026-08-31 02:35:13','2026-09-07 22:13:46'),(10,3,NULL,'جاري تحضير طلبك','طلبك 3 قيد التحضير الآن.','order','{\"type\": \"order\", \"status\": \"preparing\", \"order_id\": \"3\", \"order_number\": \"3\"}',NULL,'2026-08-31 02:35:22','2026-08-31 02:35:22'),(11,3,NULL,'تم استلام طلبك','استلمنا طلبك 4 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"4\", \"order_number\": \"4\"}',NULL,'2026-08-31 03:09:32','2026-08-31 03:09:32'),(12,3,NULL,'جاري تحضير طلبك','طلبك 4 قيد التحضير الآن.','order','{\"type\": \"order\", \"status\": \"preparing\", \"order_id\": \"4\", \"order_number\": \"4\"}',NULL,'2026-08-31 03:10:23','2026-08-31 03:10:23'),(13,3,NULL,'تم استلام طلبك','استلمنا طلبك 5 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"5\", \"order_number\": \"5\"}',NULL,'2026-08-31 03:11:13','2026-08-31 03:11:13'),(14,3,NULL,'طلبك في الطريق','مندوب التوصيل في الطريق بطلبك 4.','order','{\"type\": \"order\", \"status\": \"on_the_way\", \"order_id\": \"4\", \"order_number\": \"4\"}',NULL,'2026-08-31 03:11:19','2026-08-31 03:11:19'),(15,3,NULL,'تم توصيل طلبك','تم تسليم طلبك 4 بنجاح. نتمنى أن ينال إعجابك.','order','{\"type\": \"order\", \"status\": \"delivered\", \"order_id\": \"4\", \"order_number\": \"4\"}',NULL,'2026-08-31 03:11:21','2026-08-31 03:11:21'),(16,3,NULL,'جاري تحضير طلبك','طلبك 5 قيد التحضير الآن.','order','{\"type\": \"order\", \"status\": \"preparing\", \"order_id\": \"5\", \"order_number\": \"5\"}',NULL,'2026-08-31 03:11:27','2026-08-31 03:11:27'),(17,1,NULL,'تم استلام طلبك','استلمنا طلبك 6 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"6\", \"order_number\": \"6\"}','2026-09-01 23:28:13','2026-09-01 23:26:07','2026-09-01 23:28:13'),(18,1,NULL,'تم إلغاء الطلب','تم إلغاء طلبك 6.','order','{\"type\": \"order\", \"status\": \"cancelled\", \"order_id\": \"6\", \"order_number\": \"6\"}','2026-09-03 00:19:52','2026-09-03 00:19:41','2026-09-03 00:19:52'),(19,1,NULL,'تم استلام طلبك','استلمنا طلبك 7 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"7\", \"order_number\": \"7\"}','2026-09-08 20:12:05','2026-09-08 20:11:33','2026-09-08 20:12:05'),(20,1,NULL,'تم استلام طلبك','استلمنا طلبك 8 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"8\", \"order_number\": \"8\"}','2026-09-12 20:59:16','2026-09-12 20:42:01','2026-09-12 20:59:16'),(21,1,NULL,'تم إلغاء الطلب','تم إلغاء طلبك 8.','order','{\"type\": \"order\", \"status\": \"cancelled\", \"order_id\": \"8\", \"order_number\": \"8\"}',NULL,'2026-09-12 20:59:23','2026-09-12 20:59:23'),(22,1,NULL,'تم استلام طلبك','استلمنا طلبك 9 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"9\", \"order_number\": \"9\"}','2026-09-12 22:45:52','2026-09-12 22:45:40','2026-09-12 22:45:52'),(23,1,NULL,'تم استلام طلبك','استلمنا طلبك 10 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"10\", \"order_number\": \"10\"}',NULL,'2026-09-12 23:23:08','2026-09-12 23:23:08'),(24,1,NULL,'تم استلام طلبك','استلمنا طلبك 11 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"11\", \"order_number\": \"11\"}',NULL,'2026-09-12 23:36:30','2026-09-12 23:36:30'),(25,1,NULL,'تم استلام طلبك','استلمنا طلبك 12 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"12\", \"order_number\": \"12\"}',NULL,'2026-09-12 23:50:59','2026-09-12 23:50:59'),(26,1,NULL,'تم استلام طلبك','استلمنا طلبك 13 وجاري تأكيده.','order','{\"type\": \"order\", \"status\": \"pending\", \"order_id\": \"13\", \"order_number\": \"13\"}','2026-09-14 18:46:20','2026-09-14 18:46:00','2026-09-14 18:46:20'),(27,1,NULL,'جاري تحضير طلبك','طلبك 7 قيد التحضير الآن.','order','{\"type\": \"order\", \"status\": \"preparing\", \"order_id\": \"7\", \"order_number\": \"7\"}',NULL,'2026-09-14 20:22:19','2026-09-14 20:22:19'),(28,1,NULL,'طلبك في الطريق','مندوب التوصيل في الطريق بطلبك 7.','order','{\"type\": \"order\", \"status\": \"on_the_way\", \"order_id\": \"7\", \"order_number\": \"7\"}',NULL,'2026-09-14 20:22:50','2026-09-14 20:22:50'),(29,1,NULL,'تم توصيل طلبك','تم تسليم طلبك 7 بنجاح. نتمنى أن ينال إعجابك.','order','{\"type\": \"order\", \"status\": \"delivered\", \"order_id\": \"7\", \"order_number\": \"7\"}',NULL,'2026-09-14 20:23:02','2026-09-14 20:23:02');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `onboarding_slides`
--

DROP TABLE IF EXISTS `onboarding_slides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `onboarding_slides` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `onboarding_slides`
--

LOCK TABLES `onboarding_slides` WRITE;
/*!40000 ALTER TABLE `onboarding_slides` DISABLE KEYS */;
/*!40000 ALTER TABLE `onboarding_slides` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned DEFAULT NULL,
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity` int unsigned NOT NULL,
  `line_total` decimal(10,2) NOT NULL,
  `is_gift` tinyint(1) NOT NULL DEFAULT '0',
  `gift_for_product_id` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_foreign` (`order_id`),
  KEY `order_items_product_id_foreign` (`product_id`),
  KEY `order_items_gift_for_product_id_foreign` (`gift_for_product_id`),
  CONSTRAINT `order_items_gift_for_product_id_foreign` FOREIGN KEY (`gift_for_product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',6.00,1,6.00,0,NULL,'2026-08-31 01:34:21','2026-08-31 01:34:21'),(2,2,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',6.00,1,6.00,0,NULL,'2026-08-31 01:44:12','2026-08-31 01:44:12'),(3,2,2,'بسكويت أبو ولد بكريمة الشوكولاتة','products/JpuZFAVxR8MV0in4WLzjHUob5X34fyQmbACObJ6S.png',7.00,1,7.00,0,NULL,'2026-08-31 01:44:12','2026-08-31 01:44:12'),(4,2,4,'بسكويت أبو ولد بكريمة الفراولة','products/qizQVVgTpOZPItg5Z38kOwvi5aaaX5EHBiCBOLat.png',9.00,1,9.00,0,NULL,'2026-08-31 01:44:12','2026-08-31 01:44:12'),(5,3,7,'زيت كريم نباتي للقلي والطبخ','products/EPVOGRtH0QtUExcwfInlEXATTVbvJoTD8knvDBL0.png',12.00,1,12.00,0,NULL,'2026-08-31 01:45:43','2026-08-31 01:45:43'),(6,3,8,'زيت كريم نباتي للقلي والطبخ','products/RY7AbYCeoTDOItjNOuVkDAA93u7gQP8RnHJtQyyA.png',13.00,1,13.00,0,NULL,'2026-08-31 01:45:43','2026-08-31 01:45:43'),(7,3,5,'بسكويت أبو ولد بكريمة الفراولة','products/VCPe5yFszUl4ZvgrrCFpfXRZ1dsZoIkMD3c2MBjk.png',10.00,1,10.00,0,NULL,'2026-08-31 01:45:43','2026-08-31 01:45:43'),(8,3,6,'بسكويت أبو ولد بكريمة الفراولة','products/xVesFDonPQ9ZqZo0ECHoLy4G22u6ofDFKFRAvyq0.png',11.00,1,11.00,0,NULL,'2026-08-31 01:45:43','2026-08-31 01:45:43'),(9,4,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',6.00,1,6.00,0,NULL,'2026-08-31 03:09:32','2026-08-31 03:09:32'),(10,4,2,'بسكويت أبو ولد بكريمة الشوكولاتة','products/JpuZFAVxR8MV0in4WLzjHUob5X34fyQmbACObJ6S.png',7.00,1,7.00,0,NULL,'2026-08-31 03:09:32','2026-08-31 03:09:32'),(11,4,4,'بسكويت أبو ولد بكريمة الفراولة','products/qizQVVgTpOZPItg5Z38kOwvi5aaaX5EHBiCBOLat.png',9.00,1,9.00,0,NULL,'2026-08-31 03:09:32','2026-08-31 03:09:32'),(12,5,3,'بسكويت أبو ولد بكريمة الفراولة','products/A5YBjTVoqGesFyPrQwXPUjbYPL4QOyoXOixBUqWq.png',8.00,5,40.00,0,NULL,'2026-08-31 03:11:13','2026-08-31 03:11:13'),(13,5,4,'بسكويت أبو ولد بكريمة الفراولة','products/qizQVVgTpOZPItg5Z38kOwvi5aaaX5EHBiCBOLat.png',9.00,1,9.00,0,NULL,'2026-08-31 03:11:13','2026-08-31 03:11:13'),(14,6,2,'بسكويت أبو ولد بكريمة الشوكولاتة','products/JpuZFAVxR8MV0in4WLzjHUob5X34fyQmbACObJ6S.png',7.00,1,7.00,0,NULL,'2026-09-01 23:26:07','2026-09-01 23:26:07'),(15,6,9,'بسكويت ماري','products/CDGIAIGy6gegZTRG9G5OC7lriG6N4IpRneFa1lyw.png',14.00,1,14.00,0,NULL,'2026-09-01 23:26:07','2026-09-01 23:26:07'),(16,6,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',5.10,2,10.20,0,NULL,'2026-09-01 23:26:07','2026-09-01 23:26:07'),(17,6,3,'بسكويت أبو ولد بكريمة الفراولة','products/A5YBjTVoqGesFyPrQwXPUjbYPL4QOyoXOixBUqWq.png',6.80,1,6.80,0,NULL,'2026-09-01 23:26:07','2026-09-01 23:26:07'),(18,6,5,'بسكويت أبو ولد بكريمة الفراولة','products/VCPe5yFszUl4ZvgrrCFpfXRZ1dsZoIkMD3c2MBjk.png',8.50,3,25.50,0,NULL,'2026-09-01 23:26:07','2026-09-01 23:26:07'),(19,6,6,'بسكويت أبو ولد بكريمة الفراولة','products/xVesFDonPQ9ZqZo0ECHoLy4G22u6ofDFKFRAvyq0.png',9.35,1,9.35,0,NULL,'2026-09-01 23:26:07','2026-09-01 23:26:07'),(20,7,2,'بسكويت أبو ولد بكريمة الشوكولاتة','products/JpuZFAVxR8MV0in4WLzjHUob5X34fyQmbACObJ6S.png',7.00,2,14.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(21,7,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',6.00,1,6.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(22,7,4,'بسكويت أبو ولد بكريمة الفراولة','products/qizQVVgTpOZPItg5Z38kOwvi5aaaX5EHBiCBOLat.png',9.00,1,9.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(23,7,21,'سمن نباتي البنت بنكهة الحلبة','products/xZZQTQWMifhqwzTIidsNcZFwTMgZYbZPQlNuDoKk.png',26.00,2,52.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(24,7,5,'بسكويت أبو ولد بكريمة الفراولة','products/VCPe5yFszUl4ZvgrrCFpfXRZ1dsZoIkMD3c2MBjk.png',10.00,1,10.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(25,7,6,'بسكويت أبو ولد بكريمة الفراولة','products/xVesFDonPQ9ZqZo0ECHoLy4G22u6ofDFKFRAvyq0.png',11.00,1,11.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(26,7,9,'بسكويت ماري','products/CDGIAIGy6gegZTRG9G5OC7lriG6N4IpRneFa1lyw.png',14.00,1,14.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(27,7,13,'ويفر مغطى بالشوكولاتة','products/3reZFuNB2jFbFymSzdHr8imRiaCSDmK1UakSpmUj.png',18.00,1,18.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(28,7,12,'بسكويت ماري','products/fq5eXidjnhnaVO7Y5gTxnX08Cb2B2pRGUqFTFOgZ.png',17.00,1,17.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(29,7,22,'بسكويت ويفر تيشوب بالشوكولاتة','products/256arQJGloGWErSnuW1Ns7jFs9oFRxyDwkjI2oQM.png',27.00,1,27.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(30,7,3,'بسكويت أبو ولد بكريمة الفراولة','products/A5YBjTVoqGesFyPrQwXPUjbYPL4QOyoXOixBUqWq.png',8.00,1,8.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(31,7,28,'زيت كريم نباتي','products/MXYWOORYxh5S4VwLcJ0P6Nam9XLSKH7O0KBSXE1e.png',8.00,1,8.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(32,7,46,'سمن نباتي البنت بنكهة الزبدة','products/ysfikRykdMas5DvPMd9VCR5WypRYp1X03FIboivU.png',26.00,3,78.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(33,7,41,'زيت نباتي القمرية 15 كجم','products/98A4UJGRIOGePHmslWFitbQE956jAyUwExsQzhYX.png',21.00,2,42.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(34,7,40,'زيت نباتي القمرية 15 كجم','products/rFmRXQRSrc8tnKwus7puvjh8ORuHKFZFeYSk3Ad7.png',20.00,2,40.00,0,NULL,'2026-09-08 20:11:33','2026-09-08 20:11:33'),(35,8,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',6.00,2,12.00,0,NULL,'2026-09-12 20:42:01','2026-09-12 20:42:01'),(36,9,2,'بسكويت أبو ولد بكريمة الشوكولاتة','products/JpuZFAVxR8MV0in4WLzjHUob5X34fyQmbACObJ6S.png',7.00,2,14.00,0,NULL,'2026-09-12 22:45:40','2026-09-12 22:45:40'),(37,9,4,'بسكويت أبو ولد بكريمة الفراولة','products/qizQVVgTpOZPItg5Z38kOwvi5aaaX5EHBiCBOLat.png',9.00,1,9.00,0,NULL,'2026-09-12 22:45:40','2026-09-12 22:45:40'),(38,9,21,'سمن نباتي البنت بنكهة الحلبة','products/xZZQTQWMifhqwzTIidsNcZFwTMgZYbZPQlNuDoKk.png',26.00,1,26.00,0,NULL,'2026-09-12 22:45:40','2026-09-12 22:45:40'),(39,9,5,'بسكويت أبو ولد بكريمة الفراولة','products/VCPe5yFszUl4ZvgrrCFpfXRZ1dsZoIkMD3c2MBjk.png',10.00,2,20.00,0,NULL,'2026-09-12 22:45:40','2026-09-12 22:45:40'),(40,9,6,'بسكويت أبو ولد بكريمة الفراولة','products/xVesFDonPQ9ZqZo0ECHoLy4G22u6ofDFKFRAvyq0.png',11.00,1,11.00,0,NULL,'2026-09-12 22:45:40','2026-09-12 22:45:40'),(41,10,2,'بسكويت أبو ولد بكريمة الشوكولاتة','products/JpuZFAVxR8MV0in4WLzjHUob5X34fyQmbACObJ6S.png',7.00,1,7.00,0,NULL,'2026-09-12 23:23:08','2026-09-12 23:23:08'),(42,10,4,'بسكويت أبو ولد بكريمة الفراولة','products/qizQVVgTpOZPItg5Z38kOwvi5aaaX5EHBiCBOLat.png',9.00,1,9.00,0,NULL,'2026-09-12 23:23:08','2026-09-12 23:23:08'),(43,10,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',6.00,1,6.00,0,NULL,'2026-09-12 23:23:08','2026-09-12 23:23:08'),(44,11,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',5.10,2,10.20,0,NULL,'2026-09-12 23:36:30','2026-09-12 23:36:30'),(45,11,3,'بسكويت أبو ولد بكريمة الفراولة','products/A5YBjTVoqGesFyPrQwXPUjbYPL4QOyoXOixBUqWq.png',6.80,1,6.80,0,NULL,'2026-09-12 23:36:30','2026-09-12 23:36:30'),(46,11,5,'بسكويت أبو ولد بكريمة الفراولة','products/VCPe5yFszUl4ZvgrrCFpfXRZ1dsZoIkMD3c2MBjk.png',8.50,3,25.50,0,NULL,'2026-09-12 23:36:30','2026-09-12 23:36:30'),(47,11,6,'بسكويت أبو ولد بكريمة الفراولة','products/xVesFDonPQ9ZqZo0ECHoLy4G22u6ofDFKFRAvyq0.png',9.35,1,9.35,0,NULL,'2026-09-12 23:36:30','2026-09-12 23:36:30'),(48,12,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',5.10,2,10.20,0,NULL,'2026-09-12 23:50:58','2026-09-12 23:50:58'),(49,12,3,'بسكويت أبو ولد بكريمة الفراولة','products/A5YBjTVoqGesFyPrQwXPUjbYPL4QOyoXOixBUqWq.png',6.80,1,6.80,0,NULL,'2026-09-12 23:50:58','2026-09-12 23:50:58'),(50,12,5,'بسكويت أبو ولد بكريمة الفراولة','products/VCPe5yFszUl4ZvgrrCFpfXRZ1dsZoIkMD3c2MBjk.png',8.50,3,25.50,0,NULL,'2026-09-12 23:50:58','2026-09-12 23:50:58'),(51,12,6,'بسكويت أبو ولد بكريمة الفراولة','products/xVesFDonPQ9ZqZo0ECHoLy4G22u6ofDFKFRAvyq0.png',9.35,1,9.35,0,NULL,'2026-09-12 23:50:58','2026-09-12 23:50:58'),(52,13,34,'بسكويت ماري','products/x68Uv7wZm5Lzeia591TOeNXHcUAVM1IDo7pXLpJV.png',14.00,1,14.00,0,NULL,'2026-09-14 18:46:00','2026-09-14 18:46:00'),(53,13,1,'بسكويت أبو ولد بكريمة الشوكولاتة','products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png',6.00,1,6.00,0,NULL,'2026-09-14 18:46:00','2026-09-14 18:46:00'),(54,13,2,'بسكويت أبو ولد بكريمة الشوكولاتة','products/JpuZFAVxR8MV0in4WLzjHUob5X34fyQmbACObJ6S.png',6.30,1,6.30,0,NULL,'2026-09-14 18:46:00','2026-09-14 18:46:00'),(55,13,5,'بسكويت أبو ولد بكريمة الفراولة','products/VCPe5yFszUl4ZvgrrCFpfXRZ1dsZoIkMD3c2MBjk.png',9.00,1,9.00,0,NULL,'2026-09-14 18:46:00','2026-09-14 18:46:00'),(56,13,34,'بسكويت ماري','products/x68Uv7wZm5Lzeia591TOeNXHcUAVM1IDo7pXLpJV.png',0.00,1,0.00,1,1,'2026-09-14 18:46:00','2026-09-14 18:46:00');
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status_histories`
--

DROP TABLE IF EXISTS `order_status_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_status_histories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `status` enum('pending','preparing','on_the_way','delivered','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_status_histories_order_id_foreign` (`order_id`),
  CONSTRAINT `order_status_histories_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status_histories`
--

LOCK TABLES `order_status_histories` WRITE;
/*!40000 ALTER TABLE `order_status_histories` DISABLE KEYS */;
INSERT INTO `order_status_histories` VALUES (1,1,'pending','تم إنشاء الطلب — الدفع عند الاستلام','2026-08-31 01:34:21'),(2,2,'pending','تم إنشاء الطلب — الدفع عند الاستلام','2026-08-31 01:44:13'),(3,3,'pending','تم إنشاء الطلب — الدفع عند الاستلام','2026-08-31 01:45:43'),(4,1,'preparing','قبل الموصل الطلب: ابراهيم محمد','2026-08-31 02:31:20'),(5,2,'preparing','قبل الموصل الطلب: ابراهيم محمد','2026-08-31 02:32:50'),(6,2,'on_the_way','الطلب جاهز لاستلام العميل من المركز','2026-08-31 02:33:46'),(7,2,'delivered','استلم العميل الطلب من المركز','2026-08-31 02:34:05'),(8,1,'on_the_way','الطلب جاهز لاستلام العميل من المركز','2026-08-31 02:35:04'),(9,1,'delivered','استلم العميل الطلب من المركز','2026-08-31 02:35:13'),(10,3,'preparing','قبل الموصل الطلب: ابراهيم محمد','2026-08-31 02:35:22'),(11,4,'pending','تم إنشاء الطلب — الدفع عند الاستلام','2026-08-31 03:09:32'),(12,4,'preparing','قبل الموصل الطلب: ابراهيم محمد','2026-08-31 03:10:23'),(13,5,'pending','تم إنشاء الطلب — الدفع عند الاستلام','2026-08-31 03:11:13'),(14,4,'on_the_way','الطلب جاهز لاستلام العميل من المركز','2026-08-31 03:11:19'),(15,4,'delivered','استلم العميل الطلب من المركز','2026-08-31 03:11:21'),(16,5,'preparing','قبل الموصل الطلب: ابراهيم محمد','2026-08-31 03:11:27'),(17,6,'pending','تم إنشاء الطلب — الدفع عند الاستلام','2026-09-01 23:26:07'),(18,6,'cancelled','ألغاه العميل','2026-09-03 00:19:41'),(19,7,'pending','تم إنشاء الطلب — الدفع عند الاستلام','2026-09-08 20:11:33'),(20,8,'pending','تم إنشاء الطلب — الدفع عند الاستلام','2026-09-12 20:42:01'),(21,8,'cancelled','ألغاه العميل','2026-09-12 20:59:23'),(22,9,'pending','تم إنشاء الطلب — الدفع عند الاستلام','2026-09-12 22:45:40'),(23,10,'pending','تم إنشاء الطلب — جوالي','2026-09-12 23:23:08'),(24,11,'pending','تم إنشاء الطلب — كاش','2026-09-12 23:36:30'),(25,12,'pending','تم إنشاء الطلب — حاسب كريمي','2026-09-12 23:50:58'),(26,13,'pending','تم إنشاء الطلب — فلوسك','2026-09-14 18:46:00'),(27,7,'preparing','قبل الموصل الطلب: ابوبكر الحجي','2026-09-14 20:22:19'),(28,7,'on_the_way','استلم الموصل الطلب من المتجر','2026-09-14 20:22:50'),(29,7,'delivered','أكد الموصل التسليم','2026-09-14 20:23:02');
/*!40000 ALTER TABLE `order_status_histories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `courier_id` bigint unsigned DEFAULT NULL,
  `address_id` bigint unsigned DEFAULT NULL,
  `order_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','preparing','on_the_way','delivered','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `order_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'delivery',
  `subtotal` decimal(10,2) NOT NULL,
  `shipping_fee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total` decimal(10,2) NOT NULL,
  `has_free_shipping` tinyint(1) NOT NULL DEFAULT '0',
  `shipping_manual` tinyint(1) NOT NULL DEFAULT '0',
  `delivery_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `payment_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `shipping_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `shipping_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `shipping_city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `shipping_district` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_street` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `coupon_code` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `coupon_id` bigint unsigned DEFAULT NULL,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `fulfillment_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'now',
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `cancelled_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orders_order_number_unique` (`order_number`),
  KEY `orders_user_id_status_index` (`user_id`,`status`),
  KEY `orders_address_id_foreign` (`address_id`),
  KEY `orders_coupon_id_foreign` (`coupon_id`),
  KEY `orders_courier_id_foreign` (`courier_id`),
  CONSTRAINT `orders_address_id_foreign` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_coupon_id_foreign` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_courier_id_foreign` FOREIGN KEY (`courier_id`) REFERENCES `couriers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,1,NULL,'1','delivered','pickup',6.00,0.00,6.00,1,0,NULL,'cash','paid','ابوبكر الحجي','967778396448','استلام من المركز',NULL,'','',NULL,NULL,NULL,0.00,'now',NULL,NULL,NULL,NULL,'2026-08-31 01:34:21','2026-08-31 02:35:13'),(2,3,1,NULL,'2','delivered','pickup',22.00,0.00,22.00,1,0,NULL,'cash','paid','ابراهيم محمد','967777234341','استلام من المركز',NULL,'','',NULL,NULL,NULL,0.00,'now',NULL,NULL,NULL,NULL,'2026-08-31 01:44:12','2026-08-31 02:34:05'),(3,3,1,1,'3','preparing','delivery',46.00,15.00,61.00,0,0,'رسوم احتياطية — حدّد موقع المتجر وعنوان العميل لحساب المسافة','cash','pending','ابراهيم محمد','967777234341','Sanaa','Hay Al Ziraah','954Q+MMR','المنزل',NULL,NULL,NULL,0.00,'now',NULL,NULL,NULL,NULL,'2026-08-31 01:45:43','2026-08-31 02:35:22'),(4,3,1,NULL,'4','delivered','pickup',22.00,0.00,22.00,1,0,NULL,'cash','paid','ابراهيم محمد','967777234341','استلام من المركز',NULL,'','',NULL,NULL,NULL,0.00,'scheduled','2026-08-31 08:00:00',NULL,NULL,NULL,'2026-08-31 03:09:32','2026-08-31 03:11:21'),(5,3,1,1,'5','preparing','delivery',49.00,15.00,64.00,0,0,'رسوم احتياطية — حدّد موقع المتجر وعنوان العميل لحساب المسافة','cash','pending','ابراهيم محمد','967777234341','Sanaa','Hay Al Ziraah','954Q+MMR','المنزل',NULL,NULL,NULL,0.00,'scheduled','2026-08-31 09:00:00',NULL,NULL,NULL,'2026-08-31 03:11:13','2026-08-31 03:11:27'),(6,1,NULL,NULL,'6','cancelled','pickup',72.85,0.00,72.85,1,0,NULL,'cash','pending','ابوبكر الحجي','967778396448','استلام من المركز',NULL,'','',NULL,NULL,NULL,0.00,'now',NULL,'customer','ألغاه العميل','2026-09-03 00:19:41','2026-09-01 23:26:07','2026-09-03 00:19:41'),(7,1,3,2,'7','delivered','delivery',354.00,0.00,354.00,1,0,'تجاوزت حد التوصيل المجاني للطلب','cash','paid','ابوبكر الحجي','967778396448','صنعاء','حي الزراعة','954Q+MMR، صنعاء‎، اليَمَن','الدائري',NULL,NULL,NULL,0.00,'now',NULL,NULL,NULL,NULL,'2026-09-08 20:11:33','2026-09-14 20:23:02'),(8,1,NULL,2,'8','cancelled','delivery',12.00,15.00,27.00,0,0,'رسوم احتياطية — حدّد موقع المتجر وعنوان العميل لحساب المسافة','cash','pending','ابوبكر الحجي','967778396448','صنعاء','حي الزراعة','954Q+MMR، صنعاء‎، اليَمَن','الدائري',NULL,NULL,NULL,0.00,'now',NULL,'customer','ألغاه العميل','2026-09-12 20:59:23','2026-09-12 20:42:01','2026-09-12 20:59:23'),(9,1,NULL,NULL,'9','pending','pickup',80.00,0.00,80.00,1,0,NULL,'cash','pending','ابوبكر الحجي','967778396448','استلام من المركز',NULL,'','',NULL,NULL,NULL,0.00,'scheduled','2026-09-13 07:00:00',NULL,NULL,NULL,'2026-09-12 22:45:40','2026-09-12 22:45:40'),(10,1,NULL,2,'10','pending','delivery',22.00,15.00,37.00,0,0,'رسوم احتياطية — حدّد موقع المتجر وعنوان العميل لحساب المسافة','jawali','pending','ابوبكر الحجي','967778396448','صنعاء','حي الزراعة','954Q+MMR، صنعاء‎، اليَمَن','الدائري','جوالي: 0778396448',NULL,NULL,0.00,'now',NULL,NULL,NULL,NULL,'2026-09-12 23:23:08','2026-09-12 23:23:08'),(11,1,NULL,2,'11','pending','delivery',51.85,15.00,66.85,0,0,'رسوم احتياطية — حدّد موقع المتجر وعنوان العميل لحساب المسافة','cash_wallet','pending','ابوبكر الحجي','967778396448','صنعاء','حي الزراعة','954Q+MMR، صنعاء‎، اليَمَن','الدائري',NULL,NULL,NULL,0.00,'now',NULL,NULL,NULL,NULL,'2026-09-12 23:36:30','2026-09-12 23:36:30'),(12,1,NULL,2,'12','pending','delivery',51.85,15.00,66.85,0,0,'رسوم احتياطية — حدّد موقع المتجر وعنوان العميل لحساب المسافة','kuraimi','pending','ابوبكر الحجي','967778396448','صنعاء','حي الزراعة','954Q+MMR، صنعاء‎، اليَمَن','الدائري',NULL,NULL,NULL,0.00,'now',NULL,NULL,NULL,NULL,'2026-09-12 23:50:58','2026-09-12 23:50:58'),(13,1,NULL,2,'13','pending','delivery',35.30,15.00,50.30,0,0,'رسوم احتياطية — حدّد موقع المتجر وعنوان العميل لحساب المسافة','floosak','pending','ابوبكر الحجي','967778396448','صنعاء','حي الزراعة','954Q+MMR، صنعاء‎، اليَمَن','الدائري','فلوسك: 0778396448',NULL,NULL,0.00,'now',NULL,NULL,NULL,NULL,'2026-09-14 18:46:00','2026-09-14 18:46:00');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `placement` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'profile_footer',
  `button_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pages_slug_unique` (`slug`),
  KEY `pages_placement_is_active_index` (`placement`,`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES (1,'privacy-policy','سياسة الخصوصية','<h2>سياسة الخصوصية</h2>\r\n<p>نحن نحترم خصوصيتك. توضّح هذه الصفحة كيف نجمع ونستخدم بياناتك عند استخدام تطبيق روعة الخمسة.</p>\r\n<p>يمكنك تعديل هذا النص من لوحة التحكم.</p>','auth_terms','سياسة الخصوصية',0,1,'2026-09-07 21:44:19','2026-09-07 21:51:48'),(2,'terms-of-use','شروط الاستخدام','<h2>شروط الاستخدام</h2>\r\n<p>باستخدامك لتطبيق روعة الخمسة فإنك توافق على الالتزام بهذه الشروط.</p>\r\n<p>شركة روعة الخمسة \r\n\r\nحي الرحاب، مدينة جدة، المملكة العربية السعودية\r\n\r\n\r\n\r\nسياسة الخصوصية لتطبيق كيو\r\n\r\n\r\n\r\nسياسة الخصوصية\r\n\r\nنحن عبر منصة كيو، وهي منصة إلكترونية متخصصة في توصيل المنتجات الغذائية والاستهلاكية (“المنصة” أو “منصتنا” أو “التطبيق”)، نقدر مخاوفكم واهتمامكم بشأن خصوصية بياناتكم الشخصية. نلتزم بالشفافية في كيفية جمع واستخدام معلوماتكم، وتهدف سياسة الخصوصية هذه (“السياسة”) إلى توضيح البيانات التي نجمعها عند استخدامكم لتطبيقنا أو موقعنا، وكيف نتعامل معها لضمان أمنها وسريتها أثناء تقديم خدماتنا لكم.\r\n\r\n\r\n\r\nتقدم منصتنا تجربة تسوق متكاملة تمكنكم من تصفح واختيار وطلب المنتجات المتنوعة بسهولة، مع ضمان حماية معلوماتكم الشخصية في كل خطوة. للاستفسارات أو الملاحظات المتعلقة بخصوصيتكم، يمكنكم التواصل معنا عبر القنوات المتعددة الموضحة أدناه.\r\n\r\n\r\n\r\nبيانات التواصل\r\n\r\n\r\n\r\nتاريخ آخر تحديث\r\n\r\nتم إجراء آخر تحديث على هذه السياسة بتاريخ 21 ديسمبر 2025م.\r\n\r\n\r\n\r\nما هي البيانات الشخصية التي يتم جمعها؟\r\n\r\nنقوم بجمع ومعالجة البيانات الشخصية التالية:\r\n\r\nالبيانات الأساسية: الاسم، رقم الهوية الشخصية، العنوان، رقم الجوال.\r\n\r\nبيانات الحساب: معلومات تسجيل الدخول.\r\n\r\nبيانات الموقع: الموقع الجغرافي لتسليم الطلبات.\r\n\r\nبيانات الدفع: معلومات بطاقات الدفع، سجل المعاملات المالية.\r\n\r\nبيانات الاستخدام: سجل الطلبات، تفضيلات المنتجات، أوقات الاستخدام.\r\n\r\nبيانات تقنية: نوع الجهاز، نظام التشغيل، معلومات المتصفح، عنوان IP، معلومات ملفات تعريف الارتباط.\r\n\r\n\r\n\r\nكيف يتم جمع بياناتك الشخصية وما هو الغرض من جمعها؟\r\n\r\n\r\n\r\nالبيانات التي نجمعها بشكل مباشر:\r\n\r\nعند إنشاء حساب في التطبيق لتمكينك من استخدام خدماتنا.\r\n\r\nعند تقديم طلبات المنتجات لتنفيذ وتوصيل الطلبات.\r\n\r\nعند التواصل مع خدمة العملاء لتقديم الدعم والمساعدة.\r\n\r\nعند إجراء المدفوعات لإتمام عمليات الشراء.\r\n\r\n\r\n\r\nالبيانات التي نجمعها بشكل غير مباشر:\r\n\r\nمن خلال تقنيات ملفات تعريف الارتباط “الكوكيز” لتحسين تجربة المستخدم.\r\n\r\nمن خلال تحليلات المنصة لفهم سلوك المستخدم وتحسين الخدمات.\r\n\r\nمن خلال أنظمة تحديد الموقع الجغرافي لتسهيل توصيل الطلبات.\r\n\r\n\r\n\r\nكيف نستخدم بياناتك الشخصية؟\r\n\r\nنستخدم البيانات الشخصية التي تم جمعها على النحو التالي:\r\n\r\nإنشاء وإدارة حسابك على المنصة.\r\n\r\nمعالجة وتوصيل الطلبات المقدمة من خلال المنصة.\r\n\r\nإجراء عمليات الدفع وإصدار الفواتير الإلكترونية.\r\n\r\nالتواصل معك بشأن طلباتك وتقديم الدعم الفني.\r\n\r\nتحسين خدماتنا وتطوير المنتجات والميزات الجديدة.\r\n\r\nحماية أمن المنصة ومنع الاحتيال.\r\n\r\nالامتثال للمتطلبات القانونية والتنظيمية.\r\n\r\n\r\n\r\nفي تطبيق كيو، نعالج بياناتكم الشخصية باستخدام أنظمة رقمية متطورة وآمنة تشمل منصات التحليل وأدوات خدمة العملاء. تساعدنا هذه الأنظمة على فهم تفضيلاتكم، إرسال التنبيهات المناسبة، وتطوير خدماتنا باستمرار، مع الالتزام التام بالضوابط التنظيمية المعتمدة في المملكة العربية السعودية.\r\n\r\n\r\n\r\nكيف نفصح عن بياناتك الشخصية؟\r\n\r\nلن نفصح عن بياناتك الشخصية لأي طرف آخر لأغراض التسويق المباشر. ومع ذلك، فقد نفصح عن بياناتك الشخصية مع الجهات التالية:\r\n\r\nمندوبي التوصيل لتسليم طلباتك.\r\n\r\nمزودي خدمات الدفع لمعالجة المدفوعات.\r\n\r\nالجهات الحكومية عند الطلب بموجب الأنظمة واللوائح المعمول بها.\r\n\r\n\r\n\r\nلا تغطي هذه السياسة المحتويات التي يشاركها المستخدمون علناً مثل التقييمات والصور والتعليقات حول المنتجات والخدمات. قد نستخدم هذه المشاركات لأغراض التحسين والتسويق دون الحاجة إلى موافقة إضافية.\r\n\r\n\r\n\r\nملفات تعريف الارتباط (الكوكيز)\r\n\r\nيستخدم تطبيق كيو ملفات تعريف الارتباط، وهي عبارة عن معلومات رقمية صغيرة تُخزن على جهازك. تساعدنا هذه الملفات على تحسين تجربتك وتخصيصها وفق احتياجاتك. يمكنك عبر إعدادات جهازك التحكم في قبول أو رفض هذه الملفات، مع العلم أن تعطيلها قد يحد من بعض مميزات التطبيق.\r\n\r\n\r\n\r\nالمسوغات النظامية لجمع ومعالجة بياناتك الشخصية\r\n\r\nوفقًا لنظام حماية البيانات الشخصية الصادر بموجب المرسوم الملكي رقم (م/19) وتاريخ 09/02/1443هـ ولائحته التنفيذية الصادرة بموجب قرار مجلس الوزراء رقم (98) وتاريخ 07/02/1443هـ (“نظام حماية البيانات الشخصية”)، فإن المسوغ النظامي الذي نعتمد عليه لمعالجة هذه البيانات:\r\n\r\nموافقتك الصريحة، ويمكنك العدول عن الموافقة في أي وقت.\r\n\r\nتنفيذ الالتزام التعاقدي بينك وبيننا لتقديم الخدمات المطلوبة.\r\n\r\nالمصالح المشروعة لتطوير وتحسين خدماتنا بما لا يتعارض مع حقوقك.\r\n\r\n\r\n\r\nكيف نقوم بتخزين بياناتك الشخصية؟\r\n\r\nيتم تخزين بياناتك الشخصية بشكل آمن في خوادم محمية داخل المملكة العربية السعودية و/أو لدى مزودي خدمات الحوسبة السحابية الموثوقين. نستخدم تقنيات التشفير والحماية المتقدمة لضمان أمن بياناتك. كما نحتفظ ببياناتك الشخصية طالما كان حسابك نشطًا عبر منصة كيو، ولمدة لا تتجاوز خمس (5) سنوات بعد إغلاق الحساب أو آخر استخدام للخدمة، وذلك وفقًا للمتطلبات النظامية. بعد انتهاء فترة الاحتفاظ، نقوم بإتلاف البيانات بطريقة آمنة من خلال الحذف النهائي من أنظمتنا ومن النسخ الاحتياطية.\r\n\r\n\r\n\r\nيتبنى تطبيق كيو إجراءات أمنية متعددة المستويات لحماية بياناتكم، بما في ذلك التشفير وضوابط الوصول المشددة. ومع ذلك، نؤكد أن الاتصال الرقمي لا يمكن أن يكون آمناً بنسبة 100%. نلتزم بإشعاركم فوراً في حال وقوع أي اختراق أمني يؤثر على بياناتكم، واتخاذ الإجراءات التصحيحية اللازمة وفق الأنظمة المرعية.\r\n\r\n\r\n\r\nحقوقك فيما يتعلق بمعالجة بياناتك الشخصية\r\n\r\nبموجب نظام حماية البيانات الشخصية، لديك الحقوق التالية:\r\n\r\nالحق في العلم: معرفة كيفية جمع واستخدام بياناتك.\r\n\r\nالحق في الوصول: الاطلاع على بياناتك الشخصية التي نحتفظ بها.\r\n\r\nالحق في التصحيح: تصحيح أي معلومات غير دقيقة أو غير مكتملة.\r\n\r\nالحق في الحذف: طلب إتلاف بياناتك عندما لا تكون هناك حاجة لها.\r\n\r\nالحق في العدول عن الموافقة: سحب موافقتك على معالجة بياناتك في أي وقت.\r\n\r\nالحق في تقديم شكوى: إلى الجهة المختصة إذا كنت تعتقد أن حقوقك قد انتهكت.\r\n\r\n\r\n\r\nلممارسة أي من هذه الحقوق، يمكنك التواصل معنا عبر البريد الإلكتروني أو من خلال خاصية التواصل في التطبيق. سنستجيب لطلبك خلال [•] يوم عمل.\r\n\r\n\r\n\r\nكيف تقدم شكوى أو اعتراض؟\r\n\r\nفي حال وجود أي مخاوف بشأن كيفية تعاملنا مع بياناتك الشخصية، يمكنك تقديم شكوى إلى قسم الدعم من خلال:\r\n\r\nالبريد الإلكتروني: support@que.app\r\n\r\nالتطبيق: من خلال قسم “تواصل معنا”\r\n\r\n\r\n\r\nإذا لم تكن راضيًا عن معالجتنا للشكوى، يمكنك تقديم شكوى إلى الهيئة السعودية للبيانات والذكاء الاصطناعي.\r\n\r\n\r\n\r\nروابط المواقع الخارجية\r\n\r\nقد يحتوي تطبيق كيو على روابط تنقلك إلى منصات أخرى خارج نطاق سيطرتنا. عند استخدام هذه الروابط، ستخضع لسياسات خصوصية مختلفة عن سياستنا. ننصح بالاطلاع على سياسات تلك المواقع قبل استخدامها، حيث لا يمكننا تحمل مسؤولية ممارساتها فيما يخص خصوصية البيانات.\r\n\r\n\r\n\r\nتحديثات سياسة الخصوصية\r\n\r\nقد نقوم بتحديث السياسة هذه من وقت لآخر لتعكس التغييرات في ممارساتنا أو للامتثال للمتطلبات القانونية، وسنقوم بإخطارك بأي تغييرات جوهرية من خلال إشعار على تطبيقنا أو عبر البريد الإلكتروني.\r\n\r\n\r\n\r\nموافقتك\r\n\r\nباستخدام منصة كيو، فإنك توافق على جمع واستخدام معلوماتك وفقًا لهذه السياسة. إذا كنت لا توافق على هذه السياسة، يرجى عدم استخدام منصتنا أو خدماتنا.</p>','auth_terms','شروط الاستخدام',0,1,'2026-09-07 21:44:19','2026-09-07 21:45:47');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (9,'App\\Models\\Courier',1,'courier','2800d00300ed8157a1abd71f22cd87a8ca1240ad2ac0c4c5af10cc299adab31e','[\"*\"]',NULL,NULL,'2026-08-31 06:39:28','2026-08-31 06:39:28'),(17,'App\\Models\\User',3,'mobile','63736ec4dee7e624d7bed3d7f5ae482abdb0091c98dd1cc64066d6ffc8bb8f89','[\"*\"]','2026-09-02 02:33:23',NULL,'2026-09-02 02:33:04','2026-09-02 02:33:23'),(36,'App\\Models\\Courier',3,'courier','a4719a64b2f4c593c4f8dc741386ee6f89932514afcded2f0f7fcc641ba5ce86','[\"*\"]','2026-09-14 20:24:03',NULL,'2026-09-14 20:22:01','2026-09-14 20:24:03'),(37,'App\\Models\\User',1,'mobile','dc8d8130c957c08f21eec67d1037aaa01b9e4e026b26b8f89f1e6f3b9726a7c3','[\"*\"]','2026-09-14 20:46:49',NULL,'2026-09-14 20:31:23','2026-09-14 20:46:49');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phone_otps`
--

DROP TABLE IF EXISTS `phone_otps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phone_otps` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` timestamp NOT NULL,
  `attempts` tinyint unsigned NOT NULL DEFAULT '0',
  `consumed_at` timestamp NULL DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `phone_otps_phone_index` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phone_otps`
--

LOCK TABLES `phone_otps` WRITE;
/*!40000 ALTER TABLE `phone_otps` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_otps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pickup_slot_windows`
--

DROP TABLE IF EXISTS `pickup_slot_windows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_slot_windows` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `weekday` tinyint unsigned NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `interval_minutes` tinyint unsigned NOT NULL DEFAULT '15',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pickup_slot_windows_weekday_is_active_sort_order_index` (`weekday`,`is_active`,`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pickup_slot_windows`
--

LOCK TABLES `pickup_slot_windows` WRITE;
/*!40000 ALTER TABLE `pickup_slot_windows` DISABLE KEYS */;
INSERT INTO `pickup_slot_windows` VALUES (1,0,'10:00:00','12:00:00',15,0,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(2,0,'12:00:00','14:00:00',15,1,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(3,0,'14:00:00','16:00:00',15,2,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(4,0,'16:00:00','18:00:00',15,3,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(5,0,'18:00:00','21:00:00',15,4,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(6,1,'10:00:00','12:00:00',15,0,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(7,1,'12:00:00','14:00:00',15,1,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(8,1,'14:00:00','16:00:00',15,2,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(9,1,'16:00:00','18:00:00',15,3,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(10,1,'18:00:00','21:00:00',15,4,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(11,2,'10:00:00','12:00:00',15,0,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(12,2,'12:00:00','14:00:00',15,1,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(13,2,'14:00:00','16:00:00',15,2,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(14,2,'16:00:00','18:00:00',15,3,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(15,2,'18:00:00','21:00:00',15,4,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(16,3,'10:00:00','12:00:00',15,0,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(17,3,'12:00:00','14:00:00',15,1,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(18,3,'14:00:00','16:00:00',15,2,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(19,3,'16:00:00','18:00:00',15,3,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(20,3,'18:00:00','21:00:00',15,4,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(21,4,'10:00:00','12:00:00',15,0,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(22,4,'12:00:00','14:00:00',15,1,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(23,4,'14:00:00','16:00:00',15,2,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(24,4,'16:00:00','18:00:00',15,3,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(25,4,'18:00:00','21:00:00',15,4,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(26,5,'10:00:00','12:00:00',15,0,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(27,5,'12:00:00','14:00:00',15,1,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(28,5,'14:00:00','16:00:00',15,2,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(29,5,'16:00:00','18:00:00',15,3,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(30,5,'18:00:00','21:00:00',15,4,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(31,6,'10:00:00','12:00:00',15,0,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(32,6,'12:00:00','14:00:00',15,1,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(33,6,'14:00:00','16:00:00',15,2,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(34,6,'16:00:00','18:00:00',15,3,1,'2026-08-31 01:13:38','2026-08-31 01:13:38'),(35,6,'18:00:00','21:00:00',15,4,1,'2026-08-31 01:13:38','2026-08-31 01:13:38');
/*!40000 ALTER TABLE `pickup_slot_windows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_bundles`
--

DROP TABLE IF EXISTS `product_bundles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_bundles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount_percent` decimal(5,2) NOT NULL DEFAULT '0.00',
  `bundle_price` decimal(10,2) NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_bundles_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_bundles`
--

LOCK TABLES `product_bundles` WRITE;
/*!40000 ALTER TABLE `product_bundles` DISABLE KEYS */;
INSERT INTO `product_bundles` VALUES (1,'سلة رمضان','سلة-رمضان','مقاضي شهر رمضان',NULL,NULL,10.00,76.50,0,1,'2026-08-31 02:54:05','2026-08-31 02:54:06'),(2,'المقاضي','المقاضي','مقاضي شهر رمضان',NULL,NULL,12.00,13.20,0,1,'2026-08-31 03:04:45','2026-08-31 03:04:45'),(3,'سلة رمضان','سلة-رمضان-2','سلة رمضان تجمع لكِ أهم مقادير الشهر الفضيل لتوفير مضمون وجودة تليق بسفرتكِ اليومية.','سلة متكاملة ومدروسة بعناية لتلبي احتياجات مطبخكِ الأساسية في رمضان. اخترنا لكِ أهم مستلزمات الطبخ والتحضير اليومي لتوفري وقتكِ وجهدكِ، وبسعر اقتصادي يضمن لكِ التوفير الذكي طوال الشهر المبارك.',NULL,25.00,51.00,0,1,'2026-08-31 05:54:40','2026-08-31 05:54:41'),(4,'المقاضي','المقاضي-2','سلة رمضان تجمع لكِ أهم مقادير الشهر الفضيل لتوفير مضمون وجودة تليق بسفرتكِ اليومية.',NULL,NULL,15.00,51.85,0,1,'2026-08-31 06:05:08','2026-08-31 06:05:08'),(5,'سلة رمضان','سلة-رمضان-3',NULL,NULL,'bundles/6OV6AumFhVOVlZyBuJ0tzcQ8hqR95L6UgowLnESW.jpg',15.00,87.55,0,1,'2026-09-14 15:25:17','2026-09-14 15:25:17'),(6,'سلة رمضان','سلة-رمضان-4',NULL,NULL,'bundles/PneQhR1HhYwtO2XMzw9bNRoUeUbc2baZFAtlAcdU.jpg',15.00,47.49,0,1,'2026-09-14 15:35:09','2026-09-14 19:40:52');
/*!40000 ALTER TABLE `product_bundles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_images`
--

DROP TABLE IF EXISTS `product_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_images` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `alt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_images_product_id_foreign` (`product_id`),
  CONSTRAINT `product_images_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_images`
--

LOCK TABLES `product_images` WRITE;
/*!40000 ALTER TABLE `product_images` DISABLE KEYS */;
INSERT INTO `product_images` VALUES (1,1,'products/UtpzbR9Tx0EowXcBUslZq5m8wWbgdsjVWdftHXXs.png','بسكويت أبو ولد بكريمة الشوكولاتة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(2,2,'products/JpuZFAVxR8MV0in4WLzjHUob5X34fyQmbACObJ6S.png','بسكويت أبو ولد بكريمة الشوكولاتة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(3,3,'products/A5YBjTVoqGesFyPrQwXPUjbYPL4QOyoXOixBUqWq.png','بسكويت أبو ولد بكريمة الفراولة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(4,4,'products/qizQVVgTpOZPItg5Z38kOwvi5aaaX5EHBiCBOLat.png','بسكويت أبو ولد بكريمة الفراولة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(5,5,'products/VCPe5yFszUl4ZvgrrCFpfXRZ1dsZoIkMD3c2MBjk.png','بسكويت أبو ولد بكريمة الفراولة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(6,6,'products/xVesFDonPQ9ZqZo0ECHoLy4G22u6ofDFKFRAvyq0.png','بسكويت أبو ولد بكريمة الفراولة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(7,7,'products/EPVOGRtH0QtUExcwfInlEXATTVbvJoTD8knvDBL0.png','زيت كريم نباتي للقلي والطبخ',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(8,8,'products/RY7AbYCeoTDOItjNOuVkDAA93u7gQP8RnHJtQyyA.png','زيت كريم نباتي للقلي والطبخ',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(9,9,'products/CDGIAIGy6gegZTRG9G5OC7lriG6N4IpRneFa1lyw.png','بسكويت ماري',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(10,10,'products/HAc0Gr4NUe7ZbU9pucYqjpeBLXRs2zLiKqWL4z2S.png','مسحوق غسيل كريستال',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(11,11,'products/zPTqTglJU7R3zeq2GMDKkXar2Zd0PopxhcAavMkx.png','حلاوة طحينية الفنار',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(12,12,'products/fq5eXidjnhnaVO7Y5gTxnX08Cb2B2pRGUqFTFOgZ.png','بسكويت ماري',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(13,13,'products/3reZFuNB2jFbFymSzdHr8imRiaCSDmK1UakSpmUj.png','ويفر مغطى بالشوكولاتة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(14,14,'products/d5iGJnrfeznS0RMjptksDq3Y1rIvsW7WcLsGGVBd.png','فاصوليا حمراء الهناء',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(15,15,'products/FRV9jr8vHV3vpzlcpbQmGN8Ong3rChKDOTiW2GIe.png','زيت القمرية أولين النخيل',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(16,16,'products/gJikZjFAoa3uekVcmpYrLq6iT8XDJG4WN0Wxy0yC.png','نودلز نوودي بنكهة الدجاج الخاصة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(17,17,'products/jDMYsrcDzMPQbjuDnliY46IXAM09LQgWqmAr1sV2.png','زيت نباتي القمرية 15 كجم',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(18,18,'products/4BH9x9doz64ZupVOJwumIj8BvEpN6oc86Pkru85D.png','مسحوق غسيل كريستال برائحة الورد 2.5 كجم',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(19,19,'products/7W7ssecKtGlivGqSNShxHg5zhuC6qw8ROOVthJUz.png','مناديل سوفلي 800 منديل',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(20,20,'products/a8SwAnx7TLrmqFVqnlLfGLdFN1h6C04lOyr4jOvn.png','ثوم',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(21,21,'products/xZZQTQWMifhqwzTIidsNcZFwTMgZYbZPQlNuDoKk.png','سمن نباتي البنت بنكهة الحلبة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(22,22,'products/256arQJGloGWErSnuW1Ns7jFs9oFRxyDwkjI2oQM.png','بسكويت ويفر تيشوب بالشوكولاتة',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(23,23,'products/kAFqeIlzdOKfKRxOAzrZYdt4wEWul4nydLinrglG.png','سمن نباتي البنت 14 كجم',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(24,24,'products/Oghk1eGbg9hMD0siLo8oPmXsM8HokD3Gx13wfIvE.png','حليب مبخر الممتاز',1,0,'2026-08-30 20:40:37','2026-08-30 20:40:37'),(25,25,'products/SiiFt0ghgJPFfhIXwvJmEDqdjvJ9L5iT2KZsODJk.png','زيت نباتي القمرية',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(26,26,'products/3BwYebUPk29PR6NlAgwMUCDhgW9FFdPKCrKpXCue.png','سائل غسيل صحون ليجا بالليمون 500 مل',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(27,27,'products/Zfql0QtZuNt3wJyWPbwg07RfNnnXdE7gQDct3o37.png','زيت كريم نباتي نقي',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(28,28,'products/MXYWOORYxh5S4VwLcJ0P6Nam9XLSKH7O0KBSXE1e.png','زيت كريم نباتي',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(29,29,'products/XJ2utrjYjaSGYQSGMiSFFZhU1ksvgajvuRd7W6t9.png','زيت كريم نباتي',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(30,30,'products/PcO65xC9C1FUtLbTtxD0IHojgOkWIF4RYAiRahyn.png','زيت كريم نباتي للقلي والطبخ',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(31,31,'products/32ZoEKJnGUhYakvFliFp6nfP7ZC9SckA07zKNqER.png','مسحوق غسيل كريستال',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(32,32,'products/tswsiKWGSjKvH7wkJl4PEaPSNfCkPMxPJ3JAft8I.png','مسحوق غسيل كريستال',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(33,33,'products/EfKxok02rE9MYdWcHzSEy6mofbIl45XaTFZBpwN6.png','حلاوة طحينية الفنار',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(34,34,'products/x68Uv7wZm5Lzeia591TOeNXHcUAVM1IDo7pXLpJV.png','بسكويت ماري',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(35,35,'products/3vXq3vdMS2iQUZiEHu0kLnrR3Le1w1MJQ2IBXLSF.png','ويفر مغطى بالشوكولاتة',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(36,36,'products/6Ut1tYwUNczObqG6dbXbRfKFhffLQKh2WaHNWTYS.png','فاصوليا حمراء الهناء',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(37,37,'products/t3aaT0fmjoDOhkJainC1ytOqHWfWjn12Uc0Skeed.png','زيت القمرية أولين النخيل',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(38,38,'products/YXzJjW3LhMk3sRD9cQlpyrTdW6WePXiIJMzaASck.png','نودلز نوودي بنكهة الدجاج الخاصة',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(39,39,'products/bGEaeXy31hvppCYRLPYx45vdHyhGLs3VIjYpNpcS.png','نودلز نوودي بنكهة الدجاج الخاصة',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(40,40,'products/rFmRXQRSrc8tnKwus7puvjh8ORuHKFZFeYSk3Ad7.png','زيت نباتي القمرية 15 كجم',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(41,41,'products/98A4UJGRIOGePHmslWFitbQE956jAyUwExsQzhYX.png','زيت نباتي القمرية 15 كجم',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(42,42,'products/F9Dr8iBQchgCX4Qcu1Qve31FlFDPmwBrAMD5ym13.png','مسحوق غسيل كريستال برائحة الورد',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(43,43,'products/wvgnyVw3hFxwquXmTurVBuYROnDxoHFRH1f51qcT.png','مسحوق غسيل كريستال برائحة الورد 2.5 كجم',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(44,44,'products/0LryFq8c9Y98YT596CSY9QrWourl56bJriJTDN44.png','مناديل سوفلي 800 منديل',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(45,45,'products/ctgRmlqyjNwxrGqWqTjrDJqytT3C59abWrtkxUFs.png','ثوم',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(46,46,'products/ysfikRykdMas5DvPMd9VCR5WypRYp1X03FIboivU.png','سمن نباتي البنت بنكهة الزبدة',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(47,47,'products/c8BjPTssDUk7cDCPOzRM1WHPZJ1XoWSiY3JMK6xr.png','سمن نباتي البنت 14 كجم',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(48,48,'products/FdWW5To73NFakUeNvcgGtkbmfkLiXC2x971uheDC.png','حليب مبخر الممتاز',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(49,49,'products/KRic0AxXMSg2PdNk4CG0niNlIQBYravKkYcbNT4h.png','زيت نباتي القمرية',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38'),(50,50,'products/nOweY4LcUwxexozwqO3INtsfrlqv5AV9Aqa3icO8.png','سائل غسيل صحون ليجا بالليمون 500 مل',1,0,'2026-08-30 20:40:38','2026-08-30 20:40:38');
/*!40000 ALTER TABLE `product_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_relations`
--

DROP TABLE IF EXISTS `product_relations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_relations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `related_product_id` bigint unsigned NOT NULL,
  `type` enum('complementary','upsell','gift') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'complementary',
  `source` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_relation_unique` (`product_id`,`related_product_id`,`type`),
  KEY `product_relations_related_product_id_foreign` (`related_product_id`),
  CONSTRAINT `product_relations_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `product_relations_related_product_id_foreign` FOREIGN KEY (`related_product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_relations`
--

LOCK TABLES `product_relations` WRITE;
/*!40000 ALTER TABLE `product_relations` DISABLE KEYS */;
INSERT INTO `product_relations` VALUES (1,58,20,'complementary','ai',0,'2026-09-07 22:07:51','2026-09-07 22:07:51'),(2,58,14,'complementary','ai',1,'2026-09-07 22:07:51','2026-09-07 22:07:51'),(3,58,16,'complementary','ai',2,'2026-09-07 22:07:51','2026-09-07 22:07:51'),(4,58,19,'complementary','ai',3,'2026-09-07 22:07:51','2026-09-07 22:07:51'),(5,58,11,'complementary','ai',4,'2026-09-07 22:07:51','2026-09-07 22:07:51'),(6,58,18,'complementary','ai',5,'2026-09-07 22:07:52','2026-09-07 22:07:52'),(7,57,19,'complementary','ai',0,'2026-09-07 22:08:12','2026-09-07 22:08:12'),(8,57,7,'complementary','ai',1,'2026-09-07 22:08:12','2026-09-07 22:08:12'),(9,57,14,'complementary','ai',2,'2026-09-07 22:08:12','2026-09-07 22:08:12'),(10,57,16,'complementary','ai',3,'2026-09-07 22:08:12','2026-09-07 22:08:12'),(11,57,1,'complementary','ai',4,'2026-09-07 22:08:12','2026-09-07 22:08:12'),(12,57,20,'complementary','ai',5,'2026-09-07 22:08:12','2026-09-07 22:08:12'),(13,1,34,'gift','manual',0,'2026-09-14 15:49:54','2026-09-14 15:49:54'),(14,12,24,'complementary','ai',0,'2026-09-14 18:54:39','2026-09-14 18:54:39'),(15,12,11,'complementary','ai',1,'2026-09-14 18:54:39','2026-09-14 18:54:39'),(16,12,19,'complementary','ai',2,'2026-09-14 18:54:39','2026-09-14 18:54:39'),(17,12,16,'complementary','ai',3,'2026-09-14 18:54:39','2026-09-14 18:54:39'),(18,12,14,'complementary','ai',4,'2026-09-14 18:54:39','2026-09-14 18:54:39'),(19,12,26,'complementary','ai',5,'2026-09-14 18:54:39','2026-09-14 18:54:39'),(20,9,24,'complementary','ai',0,'2026-09-14 18:55:00','2026-09-14 18:55:00'),(21,9,11,'complementary','ai',1,'2026-09-14 18:55:00','2026-09-14 18:55:00'),(22,9,19,'complementary','ai',2,'2026-09-14 18:55:00','2026-09-14 18:55:00'),(23,9,16,'complementary','ai',3,'2026-09-14 18:55:00','2026-09-14 18:55:00'),(24,9,26,'complementary','ai',4,'2026-09-14 18:55:00','2026-09-14 18:55:00'),(25,9,14,'complementary','ai',5,'2026-09-14 18:55:00','2026-09-14 18:55:00'),(26,5,24,'complementary','ai',0,'2026-09-14 18:55:15','2026-09-14 18:55:15'),(27,5,19,'complementary','ai',1,'2026-09-14 18:55:15','2026-09-14 18:55:15'),(28,5,11,'complementary','ai',2,'2026-09-14 18:55:15','2026-09-14 18:55:15'),(29,5,26,'complementary','ai',3,'2026-09-14 18:55:16','2026-09-14 18:55:16'),(30,53,19,'complementary','ai',0,'2026-09-14 20:25:27','2026-09-14 20:25:27'),(31,53,29,'complementary','ai',1,'2026-09-14 20:25:27','2026-09-14 20:25:27'),(32,53,37,'complementary','ai',2,'2026-09-14 20:25:27','2026-09-14 20:25:27'),(33,53,14,'complementary','ai',3,'2026-09-14 20:25:27','2026-09-14 20:25:27'),(34,53,1,'complementary','ai',4,'2026-09-14 20:25:27','2026-09-14 20:25:27'),(35,53,16,'complementary','ai',5,'2026-09-14 20:25:27','2026-09-14 20:25:27'),(36,47,14,'complementary','ai',0,'2026-09-14 20:26:10','2026-09-14 20:26:10'),(37,47,19,'complementary','ai',1,'2026-09-14 20:26:10','2026-09-14 20:26:10'),(38,47,18,'complementary','ai',2,'2026-09-14 20:26:10','2026-09-14 20:26:10'),(39,47,16,'complementary','ai',3,'2026-09-14 20:26:10','2026-09-14 20:26:10'),(40,47,12,'complementary','ai',4,'2026-09-14 20:26:10','2026-09-14 20:26:10'),(41,47,31,'complementary','ai',5,'2026-09-14 20:26:10','2026-09-14 20:26:10');
/*!40000 ALTER TABLE `product_relations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `category_id` bigint unsigned NOT NULL,
  `sku` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `barcode` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `price` decimal(10,2) NOT NULL,
  `discount_price` decimal(10,2) DEFAULT NULL,
  `promo_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stock` int unsigned NOT NULL DEFAULT '0',
  `piece_count` int unsigned DEFAULT NULL,
  `weight_label` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity_label` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `store_aisle` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `store_shelf` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `store_location_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rating` decimal(3,2) NOT NULL DEFAULT '0.00',
  `review_count` int unsigned NOT NULL DEFAULT '0',
  `benefits` json DEFAULT NULL,
  `keywords` json DEFAULT NULL,
  `usage_instructions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `is_gift` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_slug_unique` (`slug`),
  UNIQUE KEY `products_sku_unique` (`sku`),
  UNIQUE KEY `products_barcode_unique` (`barcode`),
  KEY `products_category_id_is_active_index` (`category_id`,`is_active`),
  KEY `products_is_featured_index` (`is_featured`),
  KEY `products_is_gift_index` (`is_gift`),
  CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,2,'SKU-001','1','بسكويت أبو ولد بكريمة الشوكولاتة','بسكويت-أبو-ولد-بكريمة-الشوكولاتة','بسكويت أبو ولد العريق والتقليدي المحشو بكريمة الشوكولاتة الغنية والمميزة، يقدم طعماً رائعاً يأخذك في رحلة إلى ذكريات الطفولة الجميلة.',6.00,NULL,NULL,1,NULL,'120 غرام','عبوة واحدة',NULL,NULL,NULL,0.00,0,'[\"مذاق كلاسيكي محبب لجميع الأعمار\", \"مثالي لتناوله مع الشاي أو الحليب\", \"وجبة خفيفة ومثالية في أي وقت من اليوم\", \"حشوة كريمة شوكولاتة غنية ومتوازنة الحلاوة\"]','[\"بسكويت\", \"ابو ولد\", \"بسكوت\", \"شوكولاتة\", \"شوكولاته\", \"حلا\", \"تسالي\", \"مستورد\", \"بسكوت قديم\", \"سناك\"]','يُفتح المغلف ويُتناول مباشرة كوجبة خفيفة، كما يمكن غمسه في الشاي أو الحليب الدافئ للحصول على تجربة مذاق غنية.',1,1,0,1,'2026-08-30 20:40:36','2026-09-14 18:46:00',NULL),(2,2,'SKU-002','2','بسكويت أبو ولد بكريمة الشوكولاتة','بسكويت-أبو-ولد-بكريمة-الشوكولاتة-2','بسكويت أبو ولد العريق والتقليدي المحشو بكريمة الشوكولاتة الغنية والمميزة، يقدم طعماً رائعاً يأخذك في رحلة إلى ذكريات الطفولة الجميلة.',7.00,NULL,NULL,4,NULL,'120 غرام','عبوة واحدة',NULL,NULL,NULL,0.00,0,'[\"مذاق كلاسيكي محبب لجميع الأعمار\", \"مثالي لتناوله مع الشاي أو الحليب\", \"وجبة خفيفة ومثالية في أي وقت من اليوم\", \"حشوة كريمة شوكولاتة غنية ومتوازنة الحلاوة\"]','[\"بسكويت\", \"ابو ولد\", \"بسكوت\", \"شوكولاتة\", \"شوكولاته\", \"حلا\", \"تسالي\", \"مستورد\", \"بسكوت قديم\", \"سناك\"]','يُفتح المغلف ويُتناول مباشرة كوجبة خفيفة، كما يمكن غمسه في الشاي أو الحليب الدافئ للحصول على تجربة مذاق غنية.',1,1,0,2,'2026-08-30 20:40:37','2026-09-14 20:04:07',NULL),(3,2,'SKU-003','3','بسكويت أبو ولد بكريمة الفراولة','بسكويت-أبو-ولد-بكريمة-الفراولة','بسكويت أبو ولد العريق واللذيذ المحشو بكريمة الفراولة الغنية، يقدم طعماً كلاسيكياً يجمع بين قرمشة البسكويت وحلاوة الفراولة المحببة لجميع الأجيال.',8.00,7.20,'discount',5,NULL,'30 جرام','حبة فردية',NULL,NULL,NULL,0.00,0,'[\"طعم كلاسيكي لذيذ بنكهة الفراولة\", \"وجبة خفيفة ومثالية للأطفال في المدرسة\", \"سهل الحمل والتناول في أي وقت وأي مكان\"]','[\"بسكوت\", \"ابو ولد\", \"بسكويت ابو ولد\", \"كريمة الفراولة\", \"حلويات قديمة\", \"سناك\", \"وجبة خفيفة\", \"بسكوت احمر\"]','يمكن تناوله مباشرة كوجبة خفيفة ومسلية، أو الاستمتاع به إلى جانب كوب من الشاي الساخن أو الحليب الدافئ.',1,1,0,3,'2026-08-30 20:40:37','2026-09-14 18:11:08',NULL),(4,2,'SKU-004','4','بسكويت أبو ولد بكريمة الفراولة','بسكويت-أبو-ولد-بكريمة-الفراولة-2','بسكويت أبو ولد العريق واللذيذ المحشو بكريمة الفراولة الغنية، يقدم طعماً كلاسيكياً يجمع بين قرمشة البسكويت وحلاوة الفراولة المحببة لجميع الأجيال.',9.00,8.10,'discount',8,NULL,'30 جرام','حبة فردية',NULL,NULL,NULL,0.00,0,'[\"طعم كلاسيكي لذيذ بنكهة الفراولة\", \"وجبة خفيفة ومثالية للأطفال في المدرسة\", \"سهل الحمل والتناول في أي وقت وأي مكان\"]','[\"بسكوت\", \"ابو ولد\", \"بسكويت ابو ولد\", \"كريمة الفراولة\", \"حلويات قديمة\", \"سناك\", \"وجبة خفيفة\", \"بسكوت احمر\"]','يمكن تناوله مباشرة كوجبة خفيفة ومسلية، أو الاستمتاع به إلى جانب كوب من الشاي الساخن أو الحليب الدافئ.',1,1,0,4,'2026-08-30 20:40:37','2026-09-14 18:11:08',NULL),(5,2,'SKU-005','5','بسكويت أبو ولد بكريمة الفراولة','بسكويت-أبو-ولد-بكريمة-الفراولة-3','بسكويت أبو ولد العريق واللذيذ المحشو بكريمة الفراولة الغنية، يقدم طعماً كلاسيكياً يجمع بين قرمشة البسكويت وحلاوة الفراولة المحببة لجميع الأجيال.',10.00,NULL,NULL,4,NULL,'30 جرام','حبة فردية',NULL,NULL,NULL,0.00,0,'[\"طعم كلاسيكي لذيذ بنكهة الفراولة\", \"وجبة خفيفة ومثالية للأطفال في المدرسة\", \"سهل الحمل والتناول في أي وقت وأي مكان\"]','[\"بسكوت\", \"ابو ولد\", \"بسكويت ابو ولد\", \"كريمة الفراولة\", \"حلويات قديمة\", \"سناك\", \"وجبة خفيفة\", \"بسكوت احمر\"]','يمكن تناوله مباشرة كوجبة خفيفة ومسلية، أو الاستمتاع به إلى جانب كوب من الشاي الساخن أو الحليب الدافئ.',1,1,0,5,'2026-08-30 20:40:37','2026-09-14 20:04:07',NULL),(6,2,'SKU-006','6','بسكويت أبو ولد بكريمة الفراولة','بسكويت-أبو-ولد-بكريمة-الفراولة-4','بسكويت أبو ولد العريق واللذيذ المحشو بكريمة الفراولة الغنية، يقدم طعماً كلاسيكياً يجمع بين قرمشة البسكويت وحلاوة الفراولة المحببة لجميع الأجيال.',11.00,9.57,'offer',11,NULL,'30 جرام','حبة فردية',NULL,NULL,NULL,0.00,0,'[\"طعم كلاسيكي لذيذ بنكهة الفراولة\", \"وجبة خفيفة ومثالية للأطفال في المدرسة\", \"سهل الحمل والتناول في أي وقت وأي مكان\"]','[\"بسكوت\", \"ابو ولد\", \"بسكويت ابو ولد\", \"كريمة الفراولة\", \"حلويات قديمة\", \"سناك\", \"وجبة خفيفة\", \"بسكوت احمر\"]','يمكن تناوله مباشرة كوجبة خفيفة ومسلية، أو الاستمتاع به إلى جانب كوب من الشاي الساخن أو الحليب الدافئ.',1,1,0,6,'2026-08-30 20:40:37','2026-09-14 19:26:37',NULL),(7,3,'SKU-007','7','زيت كريم نباتي للقلي والطبخ','زيت-كريم-نباتي-للقلي-والطبخ','زيت كريم نباتي مخصص للطهي والقلي اليومي، يتميز بنقاء وجودة عالية تضمن نضوج الأطعمة بشكل متساوٍ ومذاق مقرمش وخفيف بدون روائح مزعجة في المطبخ.',12.00,NULL,NULL,16,NULL,'1.5 لتر','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مثالي للقلي العميق والطبخ اليومي\", \"يتحمل درجات الحرارة العالية دون احتراق\", \"يمنح الأطعمة قرمشة ذهبية وخفة في القوام\", \"خالٍ من الكوليسترول ومناسب لمختلف الوصفات\"]','[\"زيت كريم\", \"زيت نباتي\", \"زيت طبخ\", \"زيت قلي\", \"زيت طهي\", \"قلي عميق\", \"مقاضي المطبخ\", \"كريم للطبخ\"]','يُسخن الزيت في المقلاة حسب الحرارة المطلوبة قبل إضافة المكونات. يُنصح بعدم إعادة استخدام الزيت لعدة مرات للمحافظة على جودة ونكهة الأطباق.',1,0,0,7,'2026-08-30 20:40:37','2026-08-31 05:36:09',NULL),(8,3,'SKU-008','8','زيت كريم نباتي للقلي والطبخ','زيت-كريم-نباتي-للقلي-والطبخ-2','زيت كريم نباتي مخصص للطهي والقلي اليومي، يتميز بنقاء وجودة عالية تضمن نضوج الأطعمة بشكل متساوٍ ومذاق مقرمش وخفيف بدون روائح مزعجة في المطبخ.',13.00,NULL,NULL,17,NULL,'1.5 لتر','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مثالي للقلي العميق والطبخ اليومي\", \"يتحمل درجات الحرارة العالية دون احتراق\", \"يمنح الأطعمة قرمشة ذهبية وخفة في القوام\", \"خالٍ من الكوليسترول ومناسب لمختلف الوصفات\"]','[\"زيت كريم\", \"زيت نباتي\", \"زيت طبخ\", \"زيت قلي\", \"زيت طهي\", \"قلي عميق\", \"مقاضي المطبخ\", \"كريم للطبخ\"]','يُسخن الزيت في المقلاة حسب الحرارة المطلوبة قبل إضافة المكونات. يُنصح بعدم إعادة استخدام الزيت لعدة مرات للمحافظة على جودة ونكهة الأطباق.',1,0,0,8,'2026-08-30 20:40:37','2026-08-31 05:36:10',NULL),(9,2,'SKU-009','9','بسكويت ماري','بسكويت-ماري','بسكويت ماري الكلاسيكي المقرمش، يتميز بطعمه الخفيف والمعتدل الحلاوة. الخيار المثالي لتناوله مع الشاي أو استخدامه في إعداد الحلويات المنزلية اللذيذة.',14.00,NULL,NULL,18,NULL,'90 جرام','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"قوام مقرمش وخفيف على المعدة\", \"مثالي للتغميس مع الشاي والحليب\", \"مكون أساسي لعمل حلى السجاد والتشيز كيك\", \"سناك سريع ومناسب لجميع أفراد العائلة\"]','[\"بسكوت\", \"ماري\", \"بسكويت شاي\", \"حلى\", \"مقرمش\", \"سناك\", \"حلويات\", \"بسكوت ماري\"]','يمكن تناوله مباشرة كوجبة خفيفة مع الشاي أو القهوة. كما يمكن طحنه واستخدامه كقاعدة متماسكة لطبقات التشيز كيك والحلويات الباردة.',1,1,0,9,'2026-08-30 20:40:37','2026-09-14 20:04:07',NULL),(10,4,'SKU-010','10','مسحوق غسيل كريستال','مسحوق-غسيل-كريستال',NULL,15.00,NULL,NULL,20,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,10,'2026-08-30 20:40:37','2026-08-30 20:40:37',NULL),(11,5,'SKU-011','11','حلاوة طحينية الفنار','حلاوة-طحينية-الفنار','حلاوة طحينية الفنار بنكهتها الأصلية الغنية والمحضرة من أجود بذور السمسم. تتميز بقوامها المتماسك والمثالي للتقديم كوجبة خفيفة ومغذية لجميع أفراد العائلة.',16.00,NULL,NULL,21,NULL,'500 جرام','علبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مصدر غني بالطاقة والنشاط\", \"محضرة من سمسم طبيعي عالي الجودة\", \"طعم لذيذ ومميز يفضله الكبار والصغار\", \"خيار ممتاز لوجبات الإفطار والحلويات التقليدية\"]','[\"حلاوة طحينية\", \"طحينية الفنار\", \"حلاوة سمسم\", \"طحينة سائلة\", \"حلويات شعبية\", \"فطور\", \"سندويشات\", \"حلاوة قصيمية\"]','تُقدم مباشرة مع الخبز الطازج في وجبة الإفطار أو العشاء، ويمكن استخدامها لحشو الفطائر والمعجنات. يُنصح بحفظها في مكان بارد وجاف للحفاظ على تماسكها وجودتها.',1,0,0,11,'2026-08-30 20:40:37','2026-08-31 05:36:41',NULL),(12,2,'SKU-012','12','بسكويت ماري','بسكويت-ماري-2','بسكويت ماري الكلاسيكي المقرمش، يتميز بطعمه الخفيف والمعتدل الحلاوة. الخيار المثالي لتناوله مع الشاي أو استخدامه في إعداد الحلويات المنزلية اللذيذة.',17.00,15.30,'discount',21,NULL,'90 جرام','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"قوام مقرمش وخفيف على المعدة\", \"مثالي للتغميس مع الشاي والحليب\", \"مكون أساسي لعمل حلى السجاد والتشيز كيك\", \"سناك سريع ومناسب لجميع أفراد العائلة\"]','[\"بسكوت\", \"ماري\", \"بسكويت شاي\", \"حلى\", \"مقرمش\", \"سناك\", \"حلويات\", \"بسكوت ماري\"]','يمكن تناوله مباشرة كوجبة خفيفة مع الشاي أو القهوة. كما يمكن طحنه واستخدامه كقاعدة متماسكة لطبقات التشيز كيك والحلويات الباردة.',1,1,0,12,'2026-08-30 20:40:37','2026-09-14 18:11:09',NULL),(13,2,'SKU-013','13','ويفر مغطى بالشوكولاتة','ويفر-مغطى-بالشوكولاتة','ويفر مقرمش ولذيذ مغطى بطبقة غنية من الشوكولاتة الفاخرة، يمنحك تجربة مذاق متوازنة ومثالية كوجبة خفيفة في أي وقت من اليوم.',18.00,NULL,NULL,22,NULL,'40 غرام','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مزيج رائع بين قرمشة الويفر ونعومة الشوكولاتة\", \"وجبة خفيفة ومثالية للتناول أثناء التنقل\", \"مغلفة بإحكام لضمان الحفاظ على الجودة والقرمشة\"]','[\"ويفر\", \"شوكولاتة\", \"بسكويت\", \"حلا\", \"سناك\", \"شوكولاته\", \"مقرمش\", \"روعة الخمسة\"]','يُحفظ في مكان بارد وجاف بعيداً عن أشعة الشمس المباشرة. يُفتح الغلاف ويُستمتع به مباشرة بجانب القهوة أو الشاي.',1,0,0,13,'2026-08-30 20:40:37','2026-09-08 20:11:33',NULL),(14,6,'SKU-014','14','فاصوليا حمراء الهناء','فاصوليا-حمراء-الهناء','فاصوليا حمراء مطبوخة وجاهزة للاستخدام من الهناء، تتميز بجودتها العالية وقوامها المتماسك. خيار مثالي وسريع لتحضير أطباق السلطات والشوربات واليخنات اللذيذة.',19.00,NULL,NULL,24,NULL,'400 غرام','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مصدر غني بالألياف الغذائية والبروتين النباتي\", \"جاهزة للاستخدام مباشرة مما يوفر وقت الطهي\", \"خالية من المواد الحافظة الاصطناعية\"]','[\"فاصوليا حمراء\", \"الهناء\", \"معلبات\", \"فاصوليا معلبة\", \"سلطة فاصوليا\", \"مقاضي\", \"أغذية معلبة\", \"فاصوليا جاهزة\"]','تفتح العلبة وتصفى الفاصوليا من السائل وتشطف بالماء البارد قبل إضافتها مباشرة إلى السلطات، أو تسخن مع الكشنة والبهارات لتحضير طبق يخنة سريع.',1,0,0,14,'2026-08-30 20:40:37','2026-08-31 05:37:13',NULL),(15,3,'SKU-015','15','زيت القمرية أولين النخيل','زيت-القمرية-أولين-النخيل',NULL,20.00,NULL,NULL,25,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,15,'2026-08-30 20:40:37','2026-08-30 20:40:37',NULL),(16,6,'SKU-016','16','نودلز نوودي بنكهة الدجاج الخاصة','نودلز-نوودي-بنكهة-الدجاج-الخاصة','نودلز نوودي سريعة التحضير بنكهة الدجاج الخاصة، وجبة خفيفة ولذيذة ومثالية للأوقات التي تحتاج فيها إلى طبق دافئ وسريع التحضير بنكهة غنية ومتكاملة.',21.00,NULL,NULL,26,NULL,'75 جم','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"سهلة وسريعة التحضير في دقائق معدودة\", \"نكهة الدجاج الخاصة الغنية والشهية\", \"وجبة خفيفة ملائمة للأوقات المزدحمة\", \"تأتي مع كيس بهارات مخصص لضبط الطعم\"]','[\"نودلز\", \"اندومي\", \"شعيرية سريعة التحضير\", \"نوودي\", \"دجاج خاص\", \"وجبة سريعة\", \"مكرونة\", \"مقاضي\", \"نودلز دجاج\"]','ضع النودلز في وعاء وأضف عليها الماء المغلي واتركها مغطاة لمدة 3 دقائق. أفرغ محتويات كيس التوابل والزيت، ثم حرك الخليط جيداً وقدمها ساخنة.',1,0,0,16,'2026-08-30 20:40:37','2026-08-31 05:37:35',NULL),(17,3,'SKU-017','17','زيت نباتي القمرية 15 كجم','زيت-نباتي-القمرية-15-كجم','زيت نباتي نقي من القمرية، مثالي للاستخدامات اليومية المتعددة في القلي والطهي. يأتي بحجم اقتصادي كبير ومناسب للمطاعم والعائلات الكبيرة لضمان جودة الطبخ ونكهة الأطعمة الشهية.',22.00,NULL,NULL,27,NULL,'15 كجم','حبة واحدة حجم عائلي',NULL,NULL,NULL,0.00,0,'[\"حجم اقتصادي كبير يدوم طويلاً\", \"مثالي للقلي العميق وتحضير مختلف الأطباق\", \"يتحمل درجات الحرارة العالية أثناء الطهي\", \"يحافظ على النكهة الطبيعية للأطعمة\"]','[\"زيت نباتي\", \"القمرية\", \"زيت طبخ\", \"زيت قلي\", \"حجم عائلي\", \"كرتون زيت\", \"زيت 15 كيلو\", \"مقاضي البيت\", \"زيت طعام\"]','يُستخدم في عمليات القلي والطهي وإعداد المعجنات حسب الرغبة. يُنصح بحفظه في مكان بارد وجاف بعيداً عن أشعة الشمس المباشرة لضمان جودته ونقائه.',1,0,0,17,'2026-08-30 20:40:37','2026-08-31 05:37:48',NULL),(18,4,'SKU-018','18','مسحوق غسيل كريستال برائحة الورد 2.5 كجم','مسحوق-غسيل-كريستال-برائحة-الورد-25-كجم','مسحوق غسيل كريستال بتركيبة متطورة تنظف الملابس بعمق وتزيل البقع الصعبة بفعالية، مع لمسة منعشة من عطر الورد الطبيعي الذي يدوم طويلاً على الأقمشة.',23.00,NULL,NULL,28,NULL,'2.5 كجم','كيس واحد',NULL,NULL,NULL,0.00,0,'[\"قوة تنظيف فائقة تزيل البقع الصعبة بفعالية\", \"رائحة الورد المنعشة تدوم طويلاً في الملابس\", \"يحافظ على زهاء الألوان ويحمي الأنسجة من التلف\", \"مناسب للاستخدام في الغسالات العادية والاتوماتيك التي تفتح من الأعلى\"]','[\"مسحوق غسيل\", \"صابون ملابس\", \"كريستال\", \"رائحة الورد\", \"منظف ملابس\", \"غسيل ملابس\", \"بودرة غسيل\", \"روعة الخمسة\"]','يُضاف المقدار المناسب من مسحوق كريستال حسب حجم الغسيل ودرجة اتساخ الملابس في درج الغسالة المخصص، ثم تُشغل دورة الغسيل المعتادة. للحصول على أفضل النتائج مع البقع الصعبة، يُنصح بنقع الملابس لفترة وجيزة قبل الغسيل.',1,0,0,18,'2026-08-30 20:40:37','2026-08-31 05:38:08',NULL),(19,7,'SKU-019','19','مناديل سوفلي 800 منديل','مناديل-سوفلي-800-منديل','مناديل سوفلي ناعمة وعالية الجودة، تأتي بعبوة توفيرية ضخمة تحتوي على 800 منديل مفرد. مثالية للاستخدام اليومي في المنزل والسيارة والمكتب لضمان النظافة والنعومة.',24.00,NULL,NULL,29,800,NULL,'عبوة مفردة (800 منديل)',NULL,NULL,NULL,0.00,0,'[\"ملمس ناعم ولطيف على البشرة\", \"امتصاص عالي وقوة تحمل ممتازة\", \"عبوة اقتصادية موفرة تدوم طويلاً\", \"مناسبة لجميع الاستخدامات اليومية للعائلة\"]','[\"مناديل\", \"سوفلي\", \"مناديل ناعمة\", \"مناديل علب\", \"مناديل توفيرية\", \"مناديل ورق\", \"مناديل وجه\", \"ورق ومناديل\", \"مطبخ\", \"روعة الخمسة\"]','اسحب المنديل برفق من الفتحة المخصصة أعلى العبوة. استخدمه لتنظيف الوجه، اليدين، أو الأسطح برفق، ثم تخلص منه في سلة المهملات بعد الاستخدام.',1,0,0,19,'2026-08-30 20:40:37','2026-08-31 05:38:26',NULL),(20,8,'SKU-020','20','ثوم','ثوم',NULL,25.00,NULL,NULL,30,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,20,'2026-08-30 20:40:37','2026-08-30 20:40:37',NULL),(21,3,'SKU-021','21','سمن نباتي البنت بنكهة الحلبة','سمن-نباتي-البنت-بنكهة-الحلبة','سمن نباتي البنت بنكهة الحلبة المميزة، يضفي نكهة غنية ورائحة زكية وتقليدية لمختلف الأطباق الشعبية والمخبوزات بطعم أصيل.',26.00,NULL,NULL,28,NULL,'1 كجم','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"يمنح الأطباق نكهة الحلبة التقليدية الغنية\", \"مثالي لتحضير المخبوزات والأكلات الشعبية\", \"قوام متماسك وسهل الاستخدام في الطبخ\"]','[\"سمن\", \"سمن نباتي\", \"سمن البنت\", \"سمن حلبة\", \"حلبة\", \"طبخ شعبية\", \"مخبوزات\", \"مكونات طبخ\", \"أكلات شعبية\"]','تضاف ملعقة أو أكثر حسب الرغبة أثناء إعداد الأطباق الشعبية مثل الجريش أو الحنيني، أو يدهن به خبز التنور الساخن للحصول على طعم مميز.',1,0,0,21,'2026-08-30 20:40:37','2026-09-12 22:45:40',NULL),(22,2,'SKU-022','22','بسكويت ويفر تيشوب بالشوكولاتة','بسكويت-ويفر-تيشوب-بالشوكولاتة','بسكويت ويفر تيشوب الهش والمقرمش، محشو بكريمة الشوكولاتة الغنية واللذيذة، مثالي كوجبة خفيفة ومحبب لدى الأطفال والكبار.',27.00,23.49,'offer',31,NULL,'25 جرام','حبة فردية',NULL,NULL,NULL,0.00,0,'[\"قوام مقرمش وهش يذوب في الفم\", \"حشوة شوكولاتة غنية ولذيذة\", \"وجبة خفيفة ومثالية في العمل أو المدرسة\", \"تغليف عملي ومناسب للتنقل\"]','[\"تيشوب\", \"ويفر\", \"بسكويت شوكولاته\", \"حلى تيشوب\", \"ويفر كاكاو\", \"بسكوت مغطى\", \"سناكس\", \"حلويات بقالة\"]','يؤكل مباشرة كوجبة خفيفة في أي وقت من اليوم. يمكن تناوله بجانب كوب من الشاي الساخن أو القهوة لتعزيز النكهة.',1,1,0,22,'2026-08-30 20:40:37','2026-09-14 19:26:37',NULL),(23,3,'SKU-023','23','سمن نباتي البنت 14 كجم','سمن-نباتي-البنت-14-كجم','سمن نباتي البنت بجودة عالية ونكهة غنية تضفي مذاقاً لذيذاً على أطباقك ومخبوزاتك. يأتي بحجم عائلي كبير ومناسب للمطابخ والمخابز التي تحتاج كميات وفيرة لتحضير أشهى الوجبات.',28.00,NULL,NULL,33,NULL,'14 كجم','عبوة حجم عائلي',NULL,NULL,NULL,0.00,0,'[\"يضفي نكهة مميزة ورائحة زكية للأطعمة\", \"مثالي لتحضير المعجنات والمخبوزات الهشة\", \"حجم اقتصادي كبير يدوم طويلاً\", \"قوام متماسك ومناسب لمختلف درجات حرارة الطهي\"]','[\"سمن\", \"سمن نباتي\", \"البنت\", \"سمن البنت\", \"سمن 14 كيلو\", \"مستلزمات طبخ\", \"زيت وسمن\", \"حلويات شرقية\", \"سمن عائلي\"]','يستخدم في الطهي، القلي، وتحضير المخبوزات والحلويات الشرقية حسب الرغبة. يُحفظ في مكان بارد وجاف بعيداً عن أشعة الشمس المباشرة لضمان جودته.',1,0,0,23,'2026-08-30 20:40:37','2026-08-31 05:39:17',NULL),(24,9,'SKU-024','24','حليب مبخر الممتاز','حليب-مبخر-الممتاز','حليب مبخر عالي الجودة ومحضر بعناية ليضفي قواماً كريمياً غنياً ونكهة مميزة للشاي والقهوة اليومية، كما يمكن استخدامه في إعداد مختلف أطباق الحلويات والمخبوزات.',29.00,NULL,NULL,34,NULL,'170 غرام','علبة واحدة',NULL,NULL,NULL,0.00,0,'[\"يمنح الشاي والقهوة قواماً كريمياً غنياً\", \"مصدر جيد للكالسيوم وفيتامين د\", \"مثالي لتحضير الحلويات والمخبوزات المتنوعة\", \"معبأ بعناية لضمان الحفاظ على الطعم الطازج\"]','[\"حليب مبخر\", \"حليب الممتاز\", \"حليب شاي\", \"شاهي عدني\", \"حليب مركز\", \"حليب علب\", \"مقاضي بقالة\", \"حليب كرتون\"]','يُرج المغلف جيداً قبل الفتح. أضف الكمية المناسبة إلى كوب الشاي الساخن أو القهوة حسب الرغبة، ويُحفظ بالثلاجة بعد الفتح في وعاء مغلق ويستهلك خلال أيام قليلة.',1,0,0,24,'2026-08-30 20:40:37','2026-08-31 05:39:40',NULL),(25,3,'SKU-025','25','زيت نباتي القمرية','زيت-نباتي-القمرية','زيت نباتي نقي ومثالي للطهي والقلي اليومي. يتميز بتركيبته الخفيفة التي لا تغير نكهة الأطعمة وتمنحها قواماً مقرمشاً ولذيذاً.',5.00,NULL,NULL,35,NULL,'1.5 لتر','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مناسب لجميع أنواع الطهي والقلي والخبز\", \"قوام خفيف لا يثقل على المعدة\", \"يتحمل درجات الحرارة العالية أثناء القلي\"]','[\"زيت\", \"نباتي\", \"القمرية\", \"طبخ\", \"قلي\", \"زيت طبخ\", \"زيوت\", \"مقاضي\", \"المطبخ\"]','يُستخدم في تحضير الأطباق اليومية، القلي، وتتبيل المأكولات. يُنصح بعدم تسخينه لدرجة الغليان المفرطة وتخزينه في مكان بارد وجاف بعيداً عن أشعة الشمس.',1,0,0,25,'2026-08-30 20:40:38','2026-08-31 05:39:40',NULL),(26,10,'SKU-026','26','سائل غسيل صحون ليجا بالليمون 500 مل','سائل-غسيل-صحون-ليجا-بالليمون-500-مل',NULL,6.00,NULL,NULL,36,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,26,'2026-08-30 20:40:38','2026-08-30 20:40:38',NULL),(27,3,'SKU-027','27','زيت كريم نباتي نقي','زيت-كريم-نباتي-نقي',NULL,7.00,NULL,NULL,37,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,27,'2026-08-30 20:40:38','2026-08-30 20:40:38',NULL),(28,3,'SKU-028','28','زيت كريم نباتي','زيت-كريم-نباتي','بديل نباتي مميز للزيوت والدهون التقليدية، يمنح أطباقك قواماً كريمياً غنياً ونكهة متوازنة. مثالي لتحضير الصلصات والمخبوزات والشوربات بطعم رائع وقوام متجانس.',8.00,NULL,NULL,37,NULL,'1 لتر','عبوة واحدة',NULL,NULL,NULL,0.00,0,'[\"قوام كريمي يمتزج بسهولة مع المكونات\", \"خيار نباتي بالكامل وخالٍ من الكوليسترول\", \"يتحمل درجات الحرارة المختلفة في الطهي\", \"يضفي نكهة غنية للمخبوزات والأطباق الساخنة\"]','[\"زيت نباتي\", \"بديل الزبدة\", \"زيت كريمي\", \"طبخ ونفخ\", \"حلويات ومخبوزات\", \"روعة الخمسة\", \"مقاضي المطبخ\", \"صلصات\"]','يُضاف مباشرة إلى الشوربات والصلصات أثناء الطهي للحصول على قوام كريمي كثيف، كما يمكن استخدامه كبديل للزبدة في تحضير الكيك والمعجنات.',1,0,0,28,'2026-08-30 20:40:38','2026-09-08 20:11:33',NULL),(29,3,'SKU-029','29','زيت كريم نباتي','زيت-كريم-نباتي-2','بديل نباتي مميز للزيوت والدهون التقليدية، يمنح أطباقك قواماً كريمياً غنياً ونكهة متوازنة. مثالي لتحضير الصلصات والمخبوزات والشوربات بطعم رائع وقوام متجانس.',9.00,7.83,'offer',39,NULL,'1 لتر','عبوة واحدة',NULL,NULL,NULL,0.00,0,'[\"قوام كريمي يمتزج بسهولة مع المكونات\", \"خيار نباتي بالكامل وخالٍ من الكوليسترول\", \"يتحمل درجات الحرارة المختلفة في الطهي\", \"يضفي نكهة غنية للمخبوزات والأطباق الساخنة\"]','[\"زيت نباتي\", \"بديل الزبدة\", \"زيت كريمي\", \"طبخ ونفخ\", \"حلويات ومخبوزات\", \"روعة الخمسة\", \"مقاضي المطبخ\", \"صلصات\"]','يُضاف مباشرة إلى الشوربات والصلصات أثناء الطهي للحصول على قوام كريمي كثيف، كما يمكن استخدامه كبديل للزبدة في تحضير الكيك والمعجنات.',1,1,0,29,'2026-08-30 20:40:38','2026-09-14 19:26:37',NULL),(30,3,'SKU-030','30','زيت كريم نباتي للقلي والطبخ','زيت-كريم-نباتي-للقلي-والطبخ-3','زيت كريم نباتي مخصص للطهي والقلي اليومي، يتميز بنقاء وجودة عالية تضمن نضوج الأطعمة بشكل متساوٍ ومذاق مقرمش وخفيف بدون روائح مزعجة في المطبخ.',10.00,NULL,NULL,40,NULL,'1.5 لتر','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مثالي للقلي العميق والطبخ اليومي\", \"يتحمل درجات الحرارة العالية دون احتراق\", \"يمنح الأطعمة قرمشة ذهبية وخفة في القوام\", \"خالٍ من الكوليسترول ومناسب لمختلف الوصفات\"]','[\"زيت كريم\", \"زيت نباتي\", \"زيت طبخ\", \"زيت قلي\", \"زيت طهي\", \"قلي عميق\", \"مقاضي المطبخ\", \"كريم للطبخ\"]','يُسخن الزيت في المقلاة حسب الحرارة المطلوبة قبل إضافة المكونات. يُنصح بعدم إعادة استخدام الزيت لعدة مرات للمحافظة على جودة ونكهة الأطباق.',1,0,0,30,'2026-08-30 20:40:38','2026-08-31 05:40:02',NULL),(31,4,'SKU-031','31','مسحوق غسيل كريستال','مسحوق-غسيل-كريستال-2','مسحوق غسيل كريستال بتركيبة متطورة تزيل البقع الصعبة بفعالية من الملابس الملونة والبيضاء، ويمنح ملابسك نظافة مثالية ورائحة منعشة تدوم طويلاً.',11.00,9.57,'offer',41,NULL,'2 كجم','كيس واحد',NULL,NULL,NULL,0.00,0,'[\"قوة تنظيف عالية وإزالة فعالة للبقع المستعصية\", \"يحافظ على زهاء الألوان ويحمي الأبيض من البهتان\", \"يترك الملابس برائحة منعشة ونظيفة تدوم طويلاً\", \"رغوة مثالية مناسبة للغسالات العادية واليدوية\"]','[\"مسحوق غسيل\", \"صابون ملابس\", \"منظف ملابس\", \"كريستال\", \"غسيل ملابس\", \"نظافة ملابس\", \"تايد كرتون\", \"مستلزمات غسيل\", \"صابون بودرة\"]','أضف المقدار المناسب من مسحوق كريستال في حوض الغسالة حسب كمية الغسيل ودرجة اتساخه، ثم ابدأ دورة الغسيل المعتادة. للملابس شديدة الاتساخ، يُفضل نقعها لفترة وجيزة قبل الغسل.',1,1,0,31,'2026-08-30 20:40:38','2026-09-14 19:26:37',NULL),(32,4,'SKU-032','32','مسحوق غسيل كريستال','مسحوق-غسيل-كريستال-3',NULL,12.00,NULL,NULL,42,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,32,'2026-08-30 20:40:38','2026-08-30 20:40:38',NULL),(33,5,'SKU-033','33','حلاوة طحينية الفنار','حلاوة-طحينية-الفنار-2','حلاوة طحينية الفنار بنكهتها الأصلية الغنية والمحضرة من أجود بذور السمسم. تتميز بقوامها المتماسك والمثالي للتقديم كوجبة خفيفة ومغذية لجميع أفراد العائلة.',13.00,NULL,NULL,43,NULL,'500 جرام','علبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مصدر غني بالطاقة والنشاط\", \"محضرة من سمسم طبيعي عالي الجودة\", \"طعم لذيذ ومميز يفضله الكبار والصغار\", \"خيار ممتاز لوجبات الإفطار والحلويات التقليدية\"]','[\"حلاوة طحينية\", \"طحينية الفنار\", \"حلاوة سمسم\", \"طحينة سائلة\", \"حلويات شعبية\", \"فطور\", \"سندويشات\", \"حلاوة قصيمية\"]','تُقدم مباشرة مع الخبز الطازج في وجبة الإفطار أو العشاء، ويمكن استخدامها لحشو الفطائر والمعجنات. يُنصح بحفظها في مكان بارد وجاف للحفاظ على تماسكها وجودتها.',1,0,0,33,'2026-08-30 20:40:38','2026-08-31 05:40:03',NULL),(34,2,'SKU-034','34','بسكويت ماري','بسكويت-ماري-3','بسكويت ماري الكلاسيكي المقرمش، يتميز بطعمه الخفيف والمعتدل الحلاوة. الخيار المثالي لتناوله مع الشاي أو استخدامه في إعداد الحلويات المنزلية اللذيذة.',14.00,NULL,NULL,42,NULL,'90 جرام','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"قوام مقرمش وخفيف على المعدة\", \"مثالي للتغميس مع الشاي والحليب\", \"مكون أساسي لعمل حلى السجاد والتشيز كيك\", \"سناك سريع ومناسب لجميع أفراد العائلة\"]','[\"بسكوت\", \"ماري\", \"بسكويت شاي\", \"حلى\", \"مقرمش\", \"سناك\", \"حلويات\", \"بسكوت ماري\"]','يمكن تناوله مباشرة كوجبة خفيفة مع الشاي أو القهوة. كما يمكن طحنه واستخدامه كقاعدة متماسكة لطبقات التشيز كيك والحلويات الباردة.',1,0,1,34,'2026-08-30 20:40:38','2026-09-14 18:46:00',NULL),(35,2,'SKU-035','35','ويفر مغطى بالشوكولاتة','ويفر-مغطى-بالشوكولاتة-2','ويفر مقرمش ولذيذ مغطى بطبقة غنية من الشوكولاتة الفاخرة، يمنحك تجربة مذاق متوازنة ومثالية كوجبة خفيفة في أي وقت من اليوم.',15.00,NULL,NULL,45,NULL,'40 غرام','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مزيج رائع بين قرمشة الويفر ونعومة الشوكولاتة\", \"وجبة خفيفة ومثالية للتناول أثناء التنقل\", \"مغلفة بإحكام لضمان الحفاظ على الجودة والقرمشة\"]','[\"ويفر\", \"شوكولاتة\", \"بسكويت\", \"حلا\", \"سناك\", \"شوكولاته\", \"مقرمش\", \"روعة الخمسة\"]','يُحفظ في مكان بارد وجاف بعيداً عن أشعة الشمس المباشرة. يُفتح الغلاف ويُستمتع به مباشرة بجانب القهوة أو الشاي.',1,0,0,35,'2026-08-30 20:40:38','2026-08-31 05:40:03',NULL),(36,6,'SKU-036','36','فاصوليا حمراء الهناء','فاصوليا-حمراء-الهناء-2','فاصوليا حمراء مطبوخة وجاهزة للاستخدام من الهناء، تتميز بجودتها العالية وقوامها المتماسك. خيار مثالي وسريع لتحضير أطباق السلطات والشوربات واليخنات اللذيذة.',16.00,NULL,NULL,46,NULL,'400 غرام','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مصدر غني بالألياف الغذائية والبروتين النباتي\", \"جاهزة للاستخدام مباشرة مما يوفر وقت الطهي\", \"خالية من المواد الحافظة الاصطناعية\"]','[\"فاصوليا حمراء\", \"الهناء\", \"معلبات\", \"فاصوليا معلبة\", \"سلطة فاصوليا\", \"مقاضي\", \"أغذية معلبة\", \"فاصوليا جاهزة\"]','تفتح العلبة وتصفى الفاصوليا من السائل وتشطف بالماء البارد قبل إضافتها مباشرة إلى السلطات، أو تسخن مع الكشنة والبهارات لتحضير طبق يخنة سريع.',1,0,0,36,'2026-08-30 20:40:38','2026-08-31 05:40:06',NULL),(37,3,'SKU-037','37','زيت القمرية أولين النخيل','زيت-القمرية-أولين-النخيل-2',NULL,17.00,14.79,'offer',47,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,1,0,37,'2026-08-30 20:40:38','2026-09-14 19:26:37',NULL),(38,6,'SKU-038','38','نودلز نوودي بنكهة الدجاج الخاصة','نودلز-نوودي-بنكهة-الدجاج-الخاصة-2','نودلز نوودي سريعة التحضير بنكهة الدجاج الخاصة، وجبة خفيفة ولذيذة ومثالية للأوقات التي تحتاج فيها إلى طبق دافئ وسريع التحضير بنكهة غنية ومتكاملة.',18.00,NULL,NULL,48,NULL,'75 جم','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"سهلة وسريعة التحضير في دقائق معدودة\", \"نكهة الدجاج الخاصة الغنية والشهية\", \"وجبة خفيفة ملائمة للأوقات المزدحمة\", \"تأتي مع كيس بهارات مخصص لضبط الطعم\"]','[\"نودلز\", \"اندومي\", \"شعيرية سريعة التحضير\", \"نوودي\", \"دجاج خاص\", \"وجبة سريعة\", \"مكرونة\", \"مقاضي\", \"نودلز دجاج\"]','ضع النودلز في وعاء وأضف عليها الماء المغلي واتركها مغطاة لمدة 3 دقائق. أفرغ محتويات كيس التوابل والزيت، ثم حرك الخليط جيداً وقدمها ساخنة.',1,0,0,38,'2026-08-30 20:40:38','2026-08-31 05:40:06',NULL),(39,6,'SKU-039','39','نودلز نوودي بنكهة الدجاج الخاصة','نودلز-نوودي-بنكهة-الدجاج-الخاصة-3','نودلز نوودي سريعة التحضير بنكهة الدجاج الخاصة، وجبة خفيفة ولذيذة ومثالية للأوقات التي تحتاج فيها إلى طبق دافئ وسريع التحضير بنكهة غنية ومتكاملة.',19.00,NULL,NULL,49,NULL,'75 جم','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"سهلة وسريعة التحضير في دقائق معدودة\", \"نكهة الدجاج الخاصة الغنية والشهية\", \"وجبة خفيفة ملائمة للأوقات المزدحمة\", \"تأتي مع كيس بهارات مخصص لضبط الطعم\"]','[\"نودلز\", \"اندومي\", \"شعيرية سريعة التحضير\", \"نوودي\", \"دجاج خاص\", \"وجبة سريعة\", \"مكرونة\", \"مقاضي\", \"نودلز دجاج\"]','ضع النودلز في وعاء وأضف عليها الماء المغلي واتركها مغطاة لمدة 3 دقائق. أفرغ محتويات كيس التوابل والزيت، ثم حرك الخليط جيداً وقدمها ساخنة.',1,0,0,39,'2026-08-30 20:40:38','2026-08-31 05:40:07',NULL),(40,3,'SKU-040','40','زيت نباتي القمرية 15 كجم','زيت-نباتي-القمرية-15-كجم-2','زيت نباتي نقي من القمرية، مثالي للاستخدامات اليومية المتعددة في القلي والطهي. يأتي بحجم اقتصادي كبير ومناسب للمطاعم والعائلات الكبيرة لضمان جودة الطبخ ونكهة الأطعمة الشهية.',20.00,NULL,NULL,48,NULL,'15 كجم','حبة واحدة حجم عائلي',NULL,NULL,NULL,0.00,0,'[\"حجم اقتصادي كبير يدوم طويلاً\", \"مثالي للقلي العميق وتحضير مختلف الأطباق\", \"يتحمل درجات الحرارة العالية أثناء الطهي\", \"يحافظ على النكهة الطبيعية للأطعمة\"]','[\"زيت نباتي\", \"القمرية\", \"زيت طبخ\", \"زيت قلي\", \"حجم عائلي\", \"كرتون زيت\", \"زيت 15 كيلو\", \"مقاضي البيت\", \"زيت طعام\"]','يُستخدم في عمليات القلي والطهي وإعداد المعجنات حسب الرغبة. يُنصح بحفظه في مكان بارد وجاف بعيداً عن أشعة الشمس المباشرة لضمان جودته ونقائه.',1,0,0,40,'2026-08-30 20:40:38','2026-09-08 20:11:33',NULL),(41,3,'SKU-041','41','زيت نباتي القمرية 15 كجم','زيت-نباتي-القمرية-15-كجم-3','زيت نباتي نقي من القمرية، مثالي للاستخدامات اليومية المتعددة في القلي والطهي. يأتي بحجم اقتصادي كبير ومناسب للمطاعم والعائلات الكبيرة لضمان جودة الطبخ ونكهة الأطعمة الشهية.',21.00,NULL,NULL,49,NULL,'15 كجم','حبة واحدة حجم عائلي',NULL,NULL,NULL,0.00,0,'[\"حجم اقتصادي كبير يدوم طويلاً\", \"مثالي للقلي العميق وتحضير مختلف الأطباق\", \"يتحمل درجات الحرارة العالية أثناء الطهي\", \"يحافظ على النكهة الطبيعية للأطعمة\"]','[\"زيت نباتي\", \"القمرية\", \"زيت طبخ\", \"زيت قلي\", \"حجم عائلي\", \"كرتون زيت\", \"زيت 15 كيلو\", \"مقاضي البيت\", \"زيت طعام\"]','يُستخدم في عمليات القلي والطهي وإعداد المعجنات حسب الرغبة. يُنصح بحفظه في مكان بارد وجاف بعيداً عن أشعة الشمس المباشرة لضمان جودته ونقائه.',1,0,0,41,'2026-08-30 20:40:38','2026-09-08 20:11:33',NULL),(42,4,'SKU-042','42','مسحوق غسيل كريستال برائحة الورد','مسحوق-غسيل-كريستال-برائحة-الورد',NULL,22.00,NULL,NULL,52,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,42,'2026-08-30 20:40:38','2026-08-30 20:40:38',NULL),(43,4,'SKU-043','43','مسحوق غسيل كريستال برائحة الورد 2.5 كجم','مسحوق-غسيل-كريستال-برائحة-الورد-25-كجم-2','مسحوق غسيل كريستال بتركيبة متطورة تنظف الملابس بعمق وتزيل البقع الصعبة بفعالية، مع لمسة منعشة من عطر الورد الطبيعي الذي يدوم طويلاً على الأقمشة.',23.00,NULL,NULL,53,NULL,'2.5 كجم','كيس واحد',NULL,NULL,NULL,0.00,0,'[\"قوة تنظيف فائقة تزيل البقع الصعبة بفعالية\", \"رائحة الورد المنعشة تدوم طويلاً في الملابس\", \"يحافظ على زهاء الألوان ويحمي الأنسجة من التلف\", \"مناسب للاستخدام في الغسالات العادية والاتوماتيك التي تفتح من الأعلى\"]','[\"مسحوق غسيل\", \"صابون ملابس\", \"كريستال\", \"رائحة الورد\", \"منظف ملابس\", \"غسيل ملابس\", \"بودرة غسيل\", \"روعة الخمسة\"]','يُضاف المقدار المناسب من مسحوق كريستال حسب حجم الغسيل ودرجة اتساخ الملابس في درج الغسالة المخصص، ثم تُشغل دورة الغسيل المعتادة. للحصول على أفضل النتائج مع البقع الصعبة، يُنصح بنقع الملابس لفترة وجيزة قبل الغسيل.',1,0,0,43,'2026-08-30 20:40:38','2026-08-31 05:40:10',NULL),(44,7,'SKU-044','44','مناديل سوفلي 800 منديل','مناديل-سوفلي-800-منديل-2','مناديل سوفلي ناعمة وعالية الجودة، تأتي بعبوة توفيرية ضخمة تحتوي على 800 منديل مفرد. مثالية للاستخدام اليومي في المنزل والسيارة والمكتب لضمان النظافة والنعومة.',24.00,NULL,NULL,54,800,NULL,'عبوة مفردة (800 منديل)',NULL,NULL,NULL,0.00,0,'[\"ملمس ناعم ولطيف على البشرة\", \"امتصاص عالي وقوة تحمل ممتازة\", \"عبوة اقتصادية موفرة تدوم طويلاً\", \"مناسبة لجميع الاستخدامات اليومية للعائلة\"]','[\"مناديل\", \"سوفلي\", \"مناديل ناعمة\", \"مناديل علب\", \"مناديل توفيرية\", \"مناديل ورق\", \"مناديل وجه\", \"ورق ومناديل\", \"مطبخ\", \"روعة الخمسة\"]','اسحب المنديل برفق من الفتحة المخصصة أعلى العبوة. استخدمه لتنظيف الوجه، اليدين، أو الأسطح برفق، ثم تخلص منه في سلة المهملات بعد الاستخدام.',1,0,0,44,'2026-08-30 20:40:38','2026-08-31 05:40:10',NULL),(45,8,'SKU-045','45','ثوم','ثوم-2',NULL,25.00,NULL,NULL,55,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,45,'2026-08-30 20:40:38','2026-08-30 20:40:38',NULL),(46,3,'SKU-046','46','سمن نباتي البنت بنكهة الزبدة','سمن-نباتي-البنت-بنكهة-الزبدة',NULL,26.00,NULL,NULL,53,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,46,'2026-08-30 20:40:38','2026-09-08 20:11:33',NULL),(47,3,'SKU-047','47','سمن نباتي البنت 14 كجم','سمن-نباتي-البنت-14-كجم-2','سمن نباتي البنت بجودة عالية ونكهة غنية تضفي مذاقاً لذيذاً على أطباقك ومخبوزاتك. يأتي بحجم عائلي كبير ومناسب للمطابخ والمخابز التي تحتاج كميات وفيرة لتحضير أشهى الوجبات.',27.00,23.49,'offer',57,NULL,'14 كجم','عبوة حجم عائلي',NULL,NULL,NULL,0.00,0,'[\"يضفي نكهة مميزة ورائحة زكية للأطعمة\", \"مثالي لتحضير المعجنات والمخبوزات الهشة\", \"حجم اقتصادي كبير يدوم طويلاً\", \"قوام متماسك ومناسب لمختلف درجات حرارة الطهي\"]','[\"سمن\", \"سمن نباتي\", \"البنت\", \"سمن البنت\", \"سمن 14 كيلو\", \"مستلزمات طبخ\", \"زيت وسمن\", \"حلويات شرقية\", \"سمن عائلي\"]','يستخدم في الطهي، القلي، وتحضير المخبوزات والحلويات الشرقية حسب الرغبة. يُحفظ في مكان بارد وجاف بعيداً عن أشعة الشمس المباشرة لضمان جودته.',1,1,0,47,'2026-08-30 20:40:38','2026-09-14 19:26:38',NULL),(48,9,'SKU-048','48','حليب مبخر الممتاز','حليب-مبخر-الممتاز-2','حليب مبخر عالي الجودة ومحضر بعناية ليضفي قواماً كريمياً غنياً ونكهة مميزة للشاي والقهوة اليومية، كما يمكن استخدامه في إعداد مختلف أطباق الحلويات والمخبوزات.',28.00,NULL,NULL,58,NULL,'170 غرام','علبة واحدة',NULL,NULL,NULL,0.00,0,'[\"يمنح الشاي والقهوة قواماً كريمياً غنياً\", \"مصدر جيد للكالسيوم وفيتامين د\", \"مثالي لتحضير الحلويات والمخبوزات المتنوعة\", \"معبأ بعناية لضمان الحفاظ على الطعم الطازج\"]','[\"حليب مبخر\", \"حليب الممتاز\", \"حليب شاي\", \"شاهي عدني\", \"حليب مركز\", \"حليب علب\", \"مقاضي بقالة\", \"حليب كرتون\"]','يُرج المغلف جيداً قبل الفتح. أضف الكمية المناسبة إلى كوب الشاي الساخن أو القهوة حسب الرغبة، ويُحفظ بالثلاجة بعد الفتح في وعاء مغلق ويستهلك خلال أيام قليلة.',1,0,0,48,'2026-08-30 20:40:38','2026-08-31 05:40:22',NULL),(49,3,'SKU-049','49','زيت نباتي القمرية','زيت-نباتي-القمرية-2','زيت نباتي نقي ومثالي للطهي والقلي اليومي. يتميز بتركيبته الخفيفة التي لا تغير نكهة الأطعمة وتمنحها قواماً مقرمشاً ولذيذاً.',29.00,NULL,NULL,59,NULL,'1.5 لتر','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"مناسب لجميع أنواع الطهي والقلي والخبز\", \"قوام خفيف لا يثقل على المعدة\", \"يتحمل درجات الحرارة العالية أثناء القلي\"]','[\"زيت\", \"نباتي\", \"القمرية\", \"طبخ\", \"قلي\", \"زيت طبخ\", \"زيوت\", \"مقاضي\", \"المطبخ\"]','يُستخدم في تحضير الأطباق اليومية، القلي، وتتبيل المأكولات. يُنصح بعدم تسخينه لدرجة الغليان المفرطة وتخزينه في مكان بارد وجاف بعيداً عن أشعة الشمس.',1,0,0,49,'2026-08-30 20:40:38','2026-08-31 05:40:22',NULL),(50,10,'SKU-050','50','سائل غسيل صحون ليجا بالليمون 500 مل','سائل-غسيل-صحون-ليجا-بالليمون-500-مل-2',NULL,5.00,NULL,NULL,60,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,50,'2026-08-30 20:40:38','2026-08-30 20:40:38',NULL),(51,3,'SKU-051','51','زيت كريم نباتي','زيت-كريم-نباتي-3','بديل نباتي مميز للزيوت والدهون التقليدية، يمنح أطباقك قواماً كريمياً غنياً ونكهة متوازنة. مثالي لتحضير الصلصات والمخبوزات والشوربات بطعم رائع وقوام متجانس.',6.00,NULL,NULL,61,NULL,'1 لتر','عبوة واحدة',NULL,NULL,NULL,0.00,0,'[\"قوام كريمي يمتزج بسهولة مع المكونات\", \"خيار نباتي بالكامل وخالٍ من الكوليسترول\", \"يتحمل درجات الحرارة المختلفة في الطهي\", \"يضفي نكهة غنية للمخبوزات والأطباق الساخنة\"]','[\"زيت نباتي\", \"بديل الزبدة\", \"زيت كريمي\", \"طبخ ونفخ\", \"حلويات ومخبوزات\", \"روعة الخمسة\", \"مقاضي المطبخ\", \"صلصات\"]','يُضاف مباشرة إلى الشوربات والصلصات أثناء الطهي للحصول على قوام كريمي كثيف، كما يمكن استخدامه كبديل للزبدة في تحضير الكيك والمعجنات.',1,0,0,51,'2026-08-30 20:40:38','2026-08-31 05:40:25',NULL),(52,3,'SKU-052','52','زيت كريم نباتي','زيت-كريم-نباتي-4','بديل نباتي مميز للزيوت والدهون التقليدية، يمنح أطباقك قواماً كريمياً غنياً ونكهة متوازنة. مثالي لتحضير الصلصات والمخبوزات والشوربات بطعم رائع وقوام متجانس.',7.00,NULL,NULL,62,NULL,'1 لتر','عبوة واحدة',NULL,NULL,NULL,0.00,0,'[\"قوام كريمي يمتزج بسهولة مع المكونات\", \"خيار نباتي بالكامل وخالٍ من الكوليسترول\", \"يتحمل درجات الحرارة المختلفة في الطهي\", \"يضفي نكهة غنية للمخبوزات والأطباق الساخنة\"]','[\"زيت نباتي\", \"بديل الزبدة\", \"زيت كريمي\", \"طبخ ونفخ\", \"حلويات ومخبوزات\", \"روعة الخمسة\", \"مقاضي المطبخ\", \"صلصات\"]','يُضاف مباشرة إلى الشوربات والصلصات أثناء الطهي للحصول على قوام كريمي كثيف، كما يمكن استخدامه كبديل للزبدة في تحضير الكيك والمعجنات.',1,0,0,52,'2026-08-30 20:40:38','2026-08-31 05:40:25',NULL),(53,4,'SKU-053','53','مسحوق غسيل كريستال','مسحوق-غسيل-كريستال-4','مسحوق غسيل كريستال بتركيبة متطورة تزيل البقع الصعبة بفعالية من الملابس الملونة والبيضاء، ويمنح ملابسك نظافة مثالية ورائحة منعشة تدوم طويلاً.',8.00,6.96,'offer',63,NULL,'2 كجم','كيس واحد',NULL,NULL,NULL,0.00,0,'[\"قوة تنظيف عالية وإزالة فعالة للبقع المستعصية\", \"يحافظ على زهاء الألوان ويحمي الأبيض من البهتان\", \"يترك الملابس برائحة منعشة ونظيفة تدوم طويلاً\", \"رغوة مثالية مناسبة للغسالات العادية واليدوية\"]','[\"مسحوق غسيل\", \"صابون ملابس\", \"منظف ملابس\", \"كريستال\", \"غسيل ملابس\", \"نظافة ملابس\", \"تايد كرتون\", \"مستلزمات غسيل\", \"صابون بودرة\"]','أضف المقدار المناسب من مسحوق كريستال في حوض الغسالة حسب كمية الغسيل ودرجة اتساخه، ثم ابدأ دورة الغسيل المعتادة. للملابس شديدة الاتساخ، يُفضل نقعها لفترة وجيزة قبل الغسل.',1,1,0,53,'2026-08-30 20:40:39','2026-09-14 19:26:38',NULL),(54,6,'SKU-054','54','نودلز نوودي بنكهة الدجاج الخاصة','نودلز-نوودي-بنكهة-الدجاج-الخاصة-4','نودلز نوودي سريعة التحضير بنكهة الدجاج الخاصة، وجبة خفيفة ولذيذة ومثالية للأوقات التي تحتاج فيها إلى طبق دافئ وسريع التحضير بنكهة غنية ومتكاملة.',9.00,NULL,NULL,64,NULL,'75 جم','حبة واحدة',NULL,NULL,NULL,0.00,0,'[\"سهلة وسريعة التحضير في دقائق معدودة\", \"نكهة الدجاج الخاصة الغنية والشهية\", \"وجبة خفيفة ملائمة للأوقات المزدحمة\", \"تأتي مع كيس بهارات مخصص لضبط الطعم\"]','[\"نودلز\", \"اندومي\", \"شعيرية سريعة التحضير\", \"نوودي\", \"دجاج خاص\", \"وجبة سريعة\", \"مكرونة\", \"مقاضي\", \"نودلز دجاج\"]','ضع النودلز في وعاء وأضف عليها الماء المغلي واتركها مغطاة لمدة 3 دقائق. أفرغ محتويات كيس التوابل والزيت، ثم حرك الخليط جيداً وقدمها ساخنة.',1,0,0,54,'2026-08-30 20:40:39','2026-08-31 05:40:25',NULL),(55,3,'SKU-055','55','زيت نباتي القمرية 15 كجم','زيت-نباتي-القمرية-15-كجم-4','زيت نباتي نقي من القمرية، مثالي للاستخدامات اليومية المتعددة في القلي والطهي. يأتي بحجم اقتصادي كبير ومناسب للمطاعم والعائلات الكبيرة لضمان جودة الطبخ ونكهة الأطعمة الشهية.',10.00,NULL,NULL,65,NULL,'15 كجم','حبة واحدة حجم عائلي',NULL,NULL,NULL,0.00,0,'[\"حجم اقتصادي كبير يدوم طويلاً\", \"مثالي للقلي العميق وتحضير مختلف الأطباق\", \"يتحمل درجات الحرارة العالية أثناء الطهي\", \"يحافظ على النكهة الطبيعية للأطعمة\"]','[\"زيت نباتي\", \"القمرية\", \"زيت طبخ\", \"زيت قلي\", \"حجم عائلي\", \"كرتون زيت\", \"زيت 15 كيلو\", \"مقاضي البيت\", \"زيت طعام\"]','يُستخدم في عمليات القلي والطهي وإعداد المعجنات حسب الرغبة. يُنصح بحفظه في مكان بارد وجاف بعيداً عن أشعة الشمس المباشرة لضمان جودته ونقائه.',1,0,0,55,'2026-08-30 20:40:39','2026-08-31 05:40:25',NULL),(56,3,'SKU-056','56','زيت نباتي القمرية 15 كجم','زيت-نباتي-القمرية-15-كجم-5','زيت نباتي نقي من القمرية، مثالي للاستخدامات اليومية المتعددة في القلي والطهي. يأتي بحجم اقتصادي كبير ومناسب للمطاعم والعائلات الكبيرة لضمان جودة الطبخ ونكهة الأطعمة الشهية.',11.00,NULL,NULL,66,NULL,'15 كجم','حبة واحدة حجم عائلي',NULL,NULL,NULL,0.00,0,'[\"حجم اقتصادي كبير يدوم طويلاً\", \"مثالي للقلي العميق وتحضير مختلف الأطباق\", \"يتحمل درجات الحرارة العالية أثناء الطهي\", \"يحافظ على النكهة الطبيعية للأطعمة\"]','[\"زيت نباتي\", \"القمرية\", \"زيت طبخ\", \"زيت قلي\", \"حجم عائلي\", \"كرتون زيت\", \"زيت 15 كيلو\", \"مقاضي البيت\", \"زيت طعام\"]','يُستخدم في عمليات القلي والطهي وإعداد المعجنات حسب الرغبة. يُنصح بحفظه في مكان بارد وجاف بعيداً عن أشعة الشمس المباشرة لضمان جودته ونقائه.',1,0,0,56,'2026-08-30 20:40:39','2026-08-31 05:40:25',NULL),(57,4,'SKU-057','57','مسحوق غسيل كريستال برائحة الورد 2.5 كجم','مسحوق-غسيل-كريستال-برائحة-الورد-25-كجم-3','مسحوق غسيل كريستال بتركيبة متطورة تنظف الملابس بعمق وتزيل البقع الصعبة بفعالية، مع لمسة منعشة من عطر الورد الطبيعي الذي يدوم طويلاً على الأقمشة.',12.00,NULL,NULL,67,NULL,'2.5 كجم','كيس واحد',NULL,NULL,NULL,0.00,0,'[\"قوة تنظيف فائقة تزيل البقع الصعبة بفعالية\", \"رائحة الورد المنعشة تدوم طويلاً في الملابس\", \"يحافظ على زهاء الألوان ويحمي الأنسجة من التلف\", \"مناسب للاستخدام في الغسالات العادية والاتوماتيك التي تفتح من الأعلى\"]','[\"مسحوق غسيل\", \"صابون ملابس\", \"كريستال\", \"رائحة الورد\", \"منظف ملابس\", \"غسيل ملابس\", \"بودرة غسيل\", \"روعة الخمسة\"]','يُضاف المقدار المناسب من مسحوق كريستال حسب حجم الغسيل ودرجة اتساخ الملابس في درج الغسالة المخصص، ثم تُشغل دورة الغسيل المعتادة. للحصول على أفضل النتائج مع البقع الصعبة، يُنصح بنقع الملابس لفترة وجيزة قبل الغسيل.',1,0,0,57,'2026-08-30 20:40:39','2026-08-31 05:40:29',NULL),(58,3,'SKU-058','58','زيت نباتي القمرية 1.5 كجم','زيت-نباتي-القمرية-15-كجم-6',NULL,13.00,NULL,NULL,68,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0,'[]','[]',NULL,1,0,0,58,'2026-08-30 20:40:39','2026-08-30 20:40:39',NULL);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `rating` tinyint unsigned NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reviews_user_id_product_id_unique` (`user_id`,`product_id`),
  KEY `reviews_product_id_foreign` (`product_id`),
  CONSTRAINT `reviews_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_logs`
--

DROP TABLE IF EXISTS `search_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `query` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `matched_product_id` bigint unsigned DEFAULT NULL,
  `results_count` int unsigned NOT NULL DEFAULT '0',
  `source` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'app',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `search_logs_user_id_created_at_index` (`user_id`,`created_at`),
  KEY `search_logs_query_created_at_index` (`query`,`created_at`),
  KEY `search_logs_matched_product_id_index` (`matched_product_id`),
  CONSTRAINT `search_logs_matched_product_id_foreign` FOREIGN KEY (`matched_product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  CONSTRAINT `search_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_logs`
--

LOCK TABLES `search_logs` WRITE;
/*!40000 ALTER TABLE `search_logs` DISABLE KEYS */;
INSERT INTO `search_logs` VALUES (1,1,'حليب طازج',NULL,0,'app','2026-08-30 03:42:20'),(2,NULL,'قهوة',24,2,'app','2026-09-08 19:35:58'),(3,1,'حليب طازج',NULL,0,'app','2026-09-08 20:28:24'),(4,1,'عروض اليوم',NULL,0,'app','2026-09-08 20:28:32'),(5,1,'عروض اليوم',NULL,0,'app','2026-09-08 20:28:35'),(6,1,'خضار وفواكه',NULL,0,'app','2026-09-08 20:28:38'),(7,1,'عروض اليوم',NULL,0,'app','2026-09-08 20:28:42');
/*!40000 ALTER TABLE `search_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_placeholders`
--

DROP TABLE IF EXISTS `search_placeholders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_placeholders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `phrase` varchar(160) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_placeholders`
--

LOCK TABLES `search_placeholders` WRITE;
/*!40000 ALTER TABLE `search_placeholders` DISABLE KEYS */;
INSERT INTO `search_placeholders` VALUES (1,'ابحث عن عروض اليوم...',0,1,'2026-08-30 02:49:41','2026-08-30 02:49:41'),(2,'ابحث في روعة الخمسة',1,1,'2026-08-30 02:49:41','2026-08-30 02:49:41'),(3,'في روعة تحصل كل شي روعة... أنت ابحث فقط',2,1,'2026-08-30 02:49:41','2026-08-30 02:49:41'),(4,'ابحث عن كل شي روعة',3,1,'2026-08-30 02:49:41','2026-08-30 02:49:41');
/*!40000 ALTER TABLE `search_placeholders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_smart_suggestions`
--

DROP TABLE IF EXISTS `search_smart_suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_smart_suggestions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `phrase` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_smart_suggestions`
--

LOCK TABLES `search_smart_suggestions` WRITE;
/*!40000 ALTER TABLE `search_smart_suggestions` DISABLE KEYS */;
INSERT INTO `search_smart_suggestions` VALUES (1,'فطور الدوام',0,1,'2026-08-30 02:49:42','2026-08-30 02:49:42'),(2,'كبسة الغدا',1,1,'2026-08-30 02:49:42','2026-08-30 02:49:42'),(3,'عروض اليوم',2,1,'2026-08-30 02:49:42','2026-08-30 02:49:42'),(4,'خضار وفواكه',3,1,'2026-08-30 02:49:42','2026-08-30 02:49:42'),(5,'قهوة',4,1,'2026-08-30 02:49:42','2026-08-30 02:49:42'),(6,'منظفات',5,1,'2026-08-30 02:49:42','2026-08-30 02:49:42');
/*!40000 ALTER TABLE `search_smart_suggestions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_trending_pins`
--

DROP TABLE IF EXISTS `search_trending_pins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_trending_pins` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `phrase` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_trending_pins`
--

LOCK TABLES `search_trending_pins` WRITE;
/*!40000 ALTER TABLE `search_trending_pins` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_trending_pins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('8xgkvUQ6VH54C2mDQPN2CcttoUXJ8d6MF1EzspNt',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Cursor/3.20.17 Chrome/148.0.7778.280 Electron/42.10.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoicmtjVU55VjdsWXBxOGdXd1pZVUJuOVBGUG5CWkNLTjNRZ0dGU2FUayI7czoxODoiZmxhc2hlcjo6ZW52ZWxvcGVzIjthOjA6e31zOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czo0ODoiaHR0cDovLzEyNy4wLjAuMTo4MDAwL2FkbWluL29mZmVycz90eXBlPWRpc2NvdW50IjtzOjU6InJvdXRlIjtzOjE4OiJhZG1pbi5vZmZlcnMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToyO30=',1789430016),('8y4P0CLs48aud634js03kiQR682zqv4xuASHPn84',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiVDBsb2lyYUZRTFpSc3BHcWtkMFlaTU9NdVI4bnpMdHYxZkVyekR6ZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03ZTQ0ZGYyNTYxIjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789426269),('aIJDFwb6S4yV38gNxAClpLjqzHUlnurl5esWhcEJ',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiWlhWZ0FqcGFkVXVPbjdmYU5vMzVEc1JsNHBGeER4eVBCcU9oTE5KbSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789426916),('ciiEErILSvaWGI2Bvhonq13o7JHokOCl1Huv4W8A',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ0R5QmxMUWxuekUzNHlIa2pEVVF6aE9URXJNRkFGS1RVZnRjN0JSeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTI6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2hvbWUtbG9nbz92PTE2YmMwZjVmNDIiO3M6NToicm91dGUiO3M6MTU6Im1lZGlhLmhvbWUtbG9nbyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1789429249),('Dv2Lg4TVBbjIZuSKI2dcJg2P7DgUq76AuqiFpLy7',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiRllTcUJ6OEo3ZVFtTWtHUFgwTTJsdkNBSko3VHhrWDQ0aVI5dDdiTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03ZTQ0ZGYyNTYxIjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789425979),('GIC53jLbcuKKETztFDsB23TrmIIhkLmynLqOYYyB',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiRE5Ld0w4NXNBVlpXSGpSR1RxQURqeHJZY3M4ZWhnQ0pRNlBidWtEOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTI6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2hvbWUtbG9nbz92PTE2YmMwZjVmNDIiO3M6NToicm91dGUiO3M6MTU6Im1lZGlhLmhvbWUtbG9nbyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1789428632),('GwJTs0XFFxGySVu4XMvAPYgZBk3mTnTUt3bSoF62',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoibzQwS0FRT3MzMDNnWmVBMnRpYTEyU09ud2tnRno2aDZyaEdzMmdJaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789428701),('hweA3zzQLfxkmA28e5UKGOVI4vEkFJvZlI7aMotZ',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiakNHRW1zUUhlN0JyQ29WZmJVNk1scnVlWlVpWmdCazlXaDBFWlJLaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTI6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2hvbWUtbG9nbz92PTE2YmMwZjVmNDIiO3M6NToicm91dGUiO3M6MTU6Im1lZGlhLmhvbWUtbG9nbyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1789427979),('HykQv0DcYpKtrDMnmbgA4tx1ehoIHzjViugLkL9a',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiZmFQUk9uZTkweFY4czRtRmc2YnNWcTB4TjI3OFd0cjQ2bHRLUEdvdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03ZTQ0ZGYyNTYxIjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789426734),('INBvpI5UXyCC1aclXdxCJxqbs8NwDRoMb21fSFRM',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiU3lYM1lOMXBla2Y2VUpmN09lY2c0WnlmRG15VDJQeVVHQmVMVXZlUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789426978),('j7RyPVZ4U4T67Grz1OJWRl2Q6uhHUdVkXNsMwD2B',2,'172.20.2.66','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiTEFaRnJIZWRPMVRwMkpLTndocHIzWERVQ1k3RjJHN1NMUVNnQjgwdCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czoxODoiZmxhc2hlcjo6ZW52ZWxvcGVzIjthOjA6e31zOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czo0MzoiaHR0cDovLzE3Mi4yMC4yLjY2OjgwODgvYWRtaW4vYWk/dGFiPXByb21wdCI7czo1OiJyb3V0ZSI7czoxNDoiYWRtaW4uYWkuaW5kZXgiO31zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToyO30=',1789429979),('kqkPfGNAS8rf9occMjhwsgUhQwZhB9wbkE5JrEwX',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTEgyaWtNMWgwbEY4U1VRYUY2VEtEdlpOT0k5ZWN2Y1BzWTFwZHF3SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789427478),('LmvlLhknhivSlsPRupKOAMNLdwh6WfK0eApmtIHU',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiV2RWSTRRckNPaGRmQmxHdVFSa1BEOGxpc1NtbkRzZkl2TFg5emJmQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTI6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2hvbWUtbG9nbz92PTE2YmMwZjVmNDIiO3M6NToicm91dGUiO3M6MTU6Im1lZGlhLmhvbWUtbG9nbyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1789425859),('maKuiD0r3VlKIvK3ZFte1dRGtQF4YZIy7GuQLwKs',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiVXBJTUhKNm9VclZCakVjT2s1NkFsclRYV1cwdFhrZXZRU2w2Q1hnZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789429568),('Mo6bQjNEAUirf2fe3sZc9Dnyr0LJfktP9LWU1DLY',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoia3ozV0tPUEoyazhPdnBvUnBNZFFSTjdpS0RlSlBNRjR3ZGh4aWJ1NCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789427092),('NHJrVaG0zKALOef6fCVK4xJp0GwLFVQkJAM6D3MY',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoicXJYaXJTOWlHbEhtNkNwSHd2dTFuN2VQeWZoS25pQ2FPMlUwTzc0aiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789428739),('OcDXyCcbTZlGw2rCi8fwa3H9q61FxNmCVCxyw8FI',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiRURLT2M4NUFjSGhiTUtKNXpJNEQwTGlIWFdRaEhFTkNTaDY0S3F1TSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03ZTQ0ZGYyNTYxIjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789425908),('oKPEI9hKOC1FXCOY4QNk5LawDpnQUJUUcBUfxuKp',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoidnpZVDJ6akdEQ2s1WVpPT1l3N3FMVW5OaklJdWhhUzRhTm4zbHhVcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTI6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2hvbWUtbG9nbz92PTE2YmMwZjVmNDIiO3M6NToicm91dGUiO3M6MTU6Im1lZGlhLmhvbWUtbG9nbyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1789428247),('P3NfcfkS4Y7Eurh3SGINwRx4ExpJkh6TRdFRS46u',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTTBzZkltbWtIb01ZSVI1YWxwcXZGUWl6dkRKcjlVdVJIdFg0Z3lYdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789428013),('Q0Z2dC5Ayey8zMc2j2P2xwlOnnYnycIyEa4nK3CT',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiQUVDU0w4ZFJxM21QOEpmUUVTcGVqN1FMUEo3NjFyT1E3cDVaZ3lvNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789427705),('uW8KPewRABXDpcoQ65DZjj8RBt9dQxvjF3ZCHbQt',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoibHBFRk9FcHQyTU9pT09DWk5LMnlDZXo2cUk2OHlCaGpwZDROTGkzQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTI6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2hvbWUtbG9nbz92PTE2YmMwZjVmNDIiO3M6NToicm91dGUiO3M6MTU6Im1lZGlhLmhvbWUtbG9nbyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1789429518),('ZliSHqxq9TI5AOGfoqrgWRKrU62ef4MnooIHmi7F',NULL,'172.20.2.246','Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiVllodFJBcUU3Vk9UejZNblVSWTQ2WTdCNEdlZTczVzRHMkNSRVlFaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTk6Imh0dHA6Ly8xNzIuMjAuMi42Njo4MDg4L21lZGlhL2ZhbGxiYWNrLXByb2R1Y3Q/dj03MmQwMTQyNWY4IjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpYS5mYWxsYmFjay1wcm9kdWN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1789427498);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `settings_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'delivery_enabled','1','2026-08-30 02:49:36','2026-08-30 02:49:36'),(2,'delivery_first_order_free','1','2026-08-30 02:49:36','2026-08-30 02:49:36'),(3,'delivery_store_lat','','2026-08-30 02:49:36','2026-08-30 02:49:36'),(4,'delivery_store_lng','','2026-08-30 02:49:36','2026-08-30 02:49:36'),(5,'delivery_store_address','','2026-08-30 02:49:36','2026-08-30 02:49:36'),(6,'delivery_max_km','','2026-08-30 02:49:36','2026-08-30 02:49:36'),(7,'delivery_fallback_fee','15','2026-08-30 02:49:36','2026-08-30 02:49:36'),(8,'delivery_hide_subtitle','0','2026-08-30 02:49:40','2026-08-30 02:49:40'),(9,'delivery_notes_enabled','0','2026-08-30 02:49:40','2026-08-30 02:49:40'),(10,'delivery_general_note','','2026-08-30 02:49:40','2026-08-30 02:49:40'),(11,'pickup_enabled','1','2026-08-31 01:13:38','2026-08-31 01:13:38'),(12,'customer_service_numbers','[{\"name\":\"\\u062e\\u062f\\u0645\\u0629 \\u0627\\u0644\\u0639\\u0645\\u0644\\u0627\\u0621\",\"phone\":\"967777234341\"},{\"name\":\"\\u062e\\u062f\\u0645\\u0629 \\u0627\\u0644\\u0639\\u0645\\u0644\\u0627\\u0621 2\",\"phone\":\"967711953801\"}]','2026-09-01 22:10:41','2026-09-14 18:48:21'),(13,'message_us_phone','967778396448','2026-09-01 22:10:41','2026-09-01 22:10:41'),(14,'store_name','سيتي مارت','2026-09-01 23:22:35','2026-09-12 21:25:15'),(15,'currency','YER','2026-09-01 23:22:35','2026-09-14 18:47:31'),(16,'shipping_fee','15','2026-09-01 23:22:35','2026-09-01 23:22:35'),(17,'free_shipping_threshold','150','2026-09-01 23:22:35','2026-09-01 23:22:35'),(18,'bank_iban','','2026-09-01 23:22:35','2026-09-01 23:22:35'),(19,'bank_name','البنك الأهلي السعودي','2026-09-01 23:22:35','2026-09-01 23:22:35'),(20,'marketing_sold_count','0','2026-09-01 23:22:35','2026-09-14 20:02:47'),(21,'marketing_sold_scope','all','2026-09-01 23:22:35','2026-09-14 20:02:48'),(22,'marketing_sold_product_ids','[1]','2026-09-01 23:22:35','2026-09-14 19:55:50'),(23,'otp_bypass_phones','[\"967778396448\",\"967777234341\",\"967711953801\"]','2026-09-01 23:43:11','2026-09-02 00:44:20'),(24,'ai_train_limit','80','2026-09-07 22:07:37','2026-09-07 22:07:37'),(25,'ai_train_last_status','running','2026-09-07 22:07:37','2026-09-14 20:25:13'),(26,'ai_train_last_message','جاري تدريب التوصيات…','2026-09-07 22:07:37','2026-09-14 20:25:13'),(27,'ai_train_last_run_at','2026-09-14 23:25:13','2026-09-07 22:07:37','2026-09-14 20:25:13'),(28,'ai_enabled','1','2026-09-07 22:18:22','2026-09-07 22:18:22'),(29,'ai_guests_allowed','1','2026-09-07 22:18:22','2026-09-07 22:18:22'),(30,'ai_assistant_name','مارت','2026-09-07 22:18:22','2026-09-14 20:43:23'),(31,'ai_welcome_message','يا هلا بك في سيتي مارت. أنا مرشدك للتسوق داخل المحل والتطبيق — قلّي أشتي إيش، أو وين المنتج، وأوجّهك بالأسعار والممر والرف من بيانات المتجر.','2026-09-07 22:18:22','2026-09-14 20:41:47'),(32,'ai_system_prompt','أنت مساعد تسوق رجالي محترف لمتجر «سيتي مارت» في اليمن، واسمك يظهر للعميل من إعدادات المتجر.\r\nتحدث بلهجة تسوق يمنية مهنية واضحة (أشتي، وين، تفضّل، أيوه، خلاص) بدون مبالغة سوقية أو ألفاظ غير لائقة، واجعل الرد قصيراً مناسباً للقراءة والصوت.\r\n\r\nمصدر الحقيقة الوحيد هو الكتالوج المرفق من قاعدة بيانات المتجر: الاسم، السعر، القسم، الكلمات المفتاحية، الفوائد، والموقع داخل المحل (ممر / رف / ملاحظة) إن وُجد. لا تختلق أسماء أو أسعاراً أو خصومات أو مواقع أرفف.\r\n\r\nوجّه العميل داخل التطبيق لأي شاشة يطلبها: الرئيسية، الأقسام، قسم بالاسم، السلة، الحساب، تعديل البيانات، العناوين، الإعدادات، المفضلة، الطلبات، البحث، الإشعارات، المقاضي، تسجيل الدخول، إتمام الطلب.\r\n\r\nإذا سأل «وين المنتج؟» أو عن ممر/رف/قسم: انقل الموقع المسجّل حرفياً. إن لم يُسجَّل موقع: اذكر القسم فقط وقل إن موقع الرف غير مُسجّل بعد.\r\nإذا طلب نوعاً من المنتجات اختر عدة منتجات مناسبة من القائمة. إن لم يوجد مطابق اعتذر بصدق وقدّم أقرب البدائل.\r\nلا تناقش مواضيع خارج المتجر أو الطلب أو التوصيل.','2026-09-07 22:18:22','2026-09-14 20:42:18'),(33,'ai_max_products','6','2026-09-07 22:18:22','2026-09-07 22:18:22'),(34,'ai_gemini_model','gemini-3.5-flash','2026-09-07 22:18:22','2026-09-07 23:51:36'),(35,'ai_presentation','hybrid','2026-09-07 22:18:22','2026-09-07 23:33:15'),(36,'ai_primary_color','#908BD5','2026-09-07 22:18:22','2026-09-07 22:40:56'),(37,'ai_surface_color','','2026-09-07 22:18:22','2026-09-07 23:33:15'),(38,'ai_suggestion_chips','[\"وين ألقى الحليب؟\",\"أشتي أرخص عرض اليوم\",\"ودّيني لقسم الخضار\",\"افتح عناوين التوصيل\",\"كم باقي في السلة؟\"]','2026-09-07 22:18:22','2026-09-14 20:41:47'),(39,'ai_product_layout','strip','2026-09-07 22:18:22','2026-09-07 23:33:15'),(40,'ai_show_close_button','1','2026-09-07 22:18:22','2026-09-07 22:18:22'),(41,'ai_bubble_style','soft','2026-09-07 22:18:22','2026-09-07 23:33:15'),(42,'ai_tts_enabled','1','2026-09-07 22:18:22','2026-09-14 18:55:55'),(43,'ai_tts_default_on','1','2026-09-07 22:18:22','2026-09-14 18:55:55'),(44,'ai_tts_welcome','0','2026-09-07 22:18:22','2026-09-07 22:18:22'),(45,'ai_tts_replies','1','2026-09-07 22:18:22','2026-09-14 20:42:18'),(46,'ai_stt_enabled','1','2026-09-07 22:18:22','2026-09-07 22:18:22'),(47,'ai_tts_rate','0.55','2026-09-07 22:18:22','2026-09-14 20:44:20'),(48,'ai_notify_on_ops','1','2026-09-07 22:18:22','2026-09-14 18:55:55'),(49,'ai_notify_title','تحديث من المساعد الذكي','2026-09-07 22:18:22','2026-09-07 22:18:22'),(50,'ai_notify_body','انتهت عملية ذكاء اصطناعي في المتجر. افتح التطبيق لرؤية التحديثات.','2026-09-07 22:18:22','2026-09-07 22:18:22'),(51,'ai_fast_mode','1','2026-09-07 22:18:22','2026-09-07 22:18:22'),(52,'ai_catalog_limit','20','2026-09-07 22:18:22','2026-09-07 22:18:22'),(53,'ai_history_limit','8','2026-09-07 22:18:22','2026-09-07 22:18:22'),(54,'ai_timeout_seconds','25','2026-09-07 22:18:22','2026-09-07 22:18:22'),(55,'ai_rate_limit_per_minute','20','2026-09-07 22:18:22','2026-09-07 22:18:22'),(56,'ai_train_prompt','أنت خبير توصيات منتجات لبقالة ومتجر «سيتي مارت» في اليمن.\r\nتعمل بمعايير المتاجر العالمية (Amazon / Instacart / Noon) مع عادات التسوق اليمنية، بدون اختلاق منتجات أو مواقع.\r\n\r\nاستخدم فقط المعرّفات من القائمة المرفقة. راعِ الفئة، السعر، الكلمات المفتاحية، الفوائد، وموقع المحل (ممر/رف) عند التشابه المنطقي.\r\n\r\nأربع آليات ثابتة:\r\n\r\n1) يُشترى معه غالباً (Frequently bought together)\r\n- مكمّلات لنفس الطلب وليست بديلاً: خبز مع جبن، شاي مع سكر، قهوة مع حليب، منظف مع إسفنج.\r\n- فضّل فئة مختلفة، ولا تقترح نفس المنتج أو حجماً مطابقاً منه.\r\n\r\n2) منتجات مشابهة (Similar items)\r\n- بدائل لنفس الحاجة: فئة قريبة، سعر قريب، كلمات/فوائد متشابهة.\r\n- مثال: حليب كامل بجانب حليب قليل الدسم.\r\n\r\n3) منتجات تكمل سلتك (Complete the cart)\r\n- عناصر ناقصة لطلب منزلي متكامل من فئات غير موجودة في السلة.\r\n- لا تكرر ما في السلة، ولا تملأ الصف ببدائل لنفس الصنف.\r\n\r\n4) منتجات مقترحة لك (Suggested for you)\r\n- مزيج: إعادة شراء معتادة + مكملات + منتجات مميزة شائعة في البقالة.\r\n\r\nقواعد:\r\n- رتّب الأقوى أولاً.\r\n- أرجع JSON فقط بدون شرح.','2026-09-07 22:18:22','2026-09-14 20:42:18'),(57,'phone_allowed_countries','[\"967\"]','2026-09-07 23:21:50','2026-09-07 23:21:50'),(58,'fallback_product_image','settings/pVobWW0tHvkr4OnWWFwkjfDPNhJwkoWsZSSroIYr.png','2026-09-14 18:47:31','2026-09-14 20:01:48'),(59,'home_logo','settings/y5DxkaGykTqoO1WwWUWny5bRdTukLkyyM00Umue0.png','2026-09-14 18:47:31','2026-09-14 18:47:31'),(60,'show_discounts_as_banner','0','2026-09-14 19:25:02','2026-09-14 19:41:38'),(61,'show_offers_as_banner','0','2026-09-14 19:41:32','2026-09-14 19:41:32'),(62,'auto_product_recommendations','1','2026-09-14 19:55:50','2026-09-14 19:59:15');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `splash_screens`
--

DROP TABLE IF EXISTS `splash_screens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `splash_screens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `media_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'image',
  `media_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_ms` int unsigned NOT NULL DEFAULT '2500',
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `splash_screens`
--

LOCK TABLES `splash_screens` WRITE;
/*!40000 ALTER TABLE `splash_screens` DISABLE KEYS */;
INSERT INTO `splash_screens` VALUES (1,'روعه','video','https://youtu.be/NbOIflUZNus?si=_juoJZBD96DYtz8w',2500,0,1,'2026-09-02 00:36:10','2026-09-02 00:36:10');
/*!40000 ALTER TABLE `splash_screens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_payment_methods`
--

DROP TABLE IF EXISTS `store_payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_payment_methods` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hint` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'bi-credit-card',
  `icon_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `store_payment_methods_slug_unique` (`slug`),
  KEY `store_payment_methods_is_active_sort_order_index` (`is_active`,`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_payment_methods`
--

LOCK TABLES `store_payment_methods` WRITE;
/*!40000 ALTER TABLE `store_payment_methods` DISABLE KEYS */;
INSERT INTO `store_payment_methods` VALUES (1,'cash','الدفع عند الاستلام','ادفع كاش لمندوب التوصيل عند استلام الطلب','bi-cash-coin','payments/cash.png',1,1,'2026-08-30 02:49:33','2026-09-12 23:48:38'),(6,'jeeb','جيب','ادفع عبر محفظة جيب ثم أكّد التحويل مع المتجر','bi-wallet2','payments/jeeb.png',3,1,'2026-09-12 23:18:17','2026-09-12 23:48:38'),(7,'floosak','فلوسك','ادفع عبر محفظة فلوسك ثم أكّد التحويل مع المتجر','bi-wallet2','payments/floosak.png',4,1,'2026-09-12 23:18:17','2026-09-12 23:48:38'),(8,'onecash','ون كاش','ادفع عبر محفظة ون كاش ثم أكّد التحويل مع المتجر','bi-wallet2','payments/onecash.png',5,1,'2026-09-12 23:18:17','2026-09-12 23:48:38'),(9,'jawali','جوالي','ادفع عبر محفظة جوالي ثم أكّد التحويل مع المتجر','bi-wallet2','payments/jawali.png',6,1,'2026-09-12 23:18:17','2026-09-12 23:48:38'),(10,'banky','بنكي','ادفع عبر تطبيق بنكي لبنك اليمن والكويت ثم أكّد التحويل','bi-bank','payments/banky.png',7,1,'2026-09-12 23:18:17','2026-09-12 23:48:38'),(11,'easy','محفظة إيزي','ادفع عبر محفظة إيزي ثم أكّد التحويل مع المتجر','bi-wallet2','payments/easy.png',8,1,'2026-09-12 23:18:17','2026-09-12 23:48:38'),(12,'mobile_money','موبايل موني','ادفع عبر موبايل موني (CAC) ثم أكّد التحويل مع المتجر','bi-phone','payments/mobile_money.png',9,1,'2026-09-12 23:18:17','2026-09-12 23:48:38'),(13,'cash_wallet','كاش','ادفع عبر محفظة كاش ثم أكّد التحويل مع المتجر','bi-wallet2','payments/cash_wallet.png',2,1,'2026-09-12 23:24:52','2026-09-12 23:48:38'),(14,'kuraimi','حاسب كريمي','حوّل إلى حساب بنك الكريمي ثم أكّد التحويل مع المتجر','bi-bank','payments/kuraimi.png',10,1,'2026-09-12 23:48:38','2026-09-12 23:48:38');
/*!40000 ALTER TABLE `store_payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `job_title` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_verified_at` timestamp NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `google_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('customer','admin','staff') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'customer',
  `permissions` json DEFAULT NULL,
  `locale` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ar',
  `notifications_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `notifications_orders_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `notifications_offers_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `notifications_general_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_google_id_unique` (`google_id`),
  UNIQUE KEY `users_phone_unique` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'ابوبكر الحجي',NULL,NULL,NULL,NULL,'$2y$12$iE5lS8GFquCPMKNfdFDF1.lbx7QQ2g8Y38k4VInUlULo9GsgSh0C2','967778396448','2026-08-30 03:41:46',NULL,NULL,'customer',NULL,'ar',1,1,1,1,NULL,'2026-08-30 03:41:46','2026-09-12 22:43:36',NULL),(2,'مدير النظام',NULL,NULL,'admin@raoah.test','2026-08-30 20:39:52','$2y$12$Vz5VVznfEwhHW2ta756O7u9Bs6LQ6TeVrq6AvI1bACM.sy5dx.Fn6',NULL,NULL,NULL,NULL,'admin',NULL,'en',1,1,1,1,'TdcseXcf9VxXlp9D8izLiewdHPMLC4epIt66my3vq7uV4mLrQHM6Mo3t3WGw','2026-08-30 20:39:52','2026-09-14 18:46:41',NULL),(3,'ابراهيم محمد',NULL,NULL,NULL,NULL,'$2y$12$pisnX8zWyKof3h5imzQhtuv9gjN46uMOl8LZiKA8sKQl.L.M48ofu','967777234341','2026-08-31 01:43:38',NULL,NULL,'customer',NULL,'ar',1,1,1,1,NULL,'2026-08-31 01:43:38','2026-08-31 01:43:57',NULL),(4,'ابوبكر 2',NULL,NULL,NULL,NULL,'$2y$12$1Hls9gmvhWgjjgGcCpKhxeKFo11uCnnd8E60mwCGaf9Zoyn2lNfz.','967711953801','2026-09-02 00:44:42',NULL,NULL,'customer',NULL,'ar',1,1,1,1,NULL,'2026-09-02 00:44:42','2026-09-02 01:17:30',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'citymartstore'
--

--
-- Dumping routines for database 'citymartstore'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-15  2:53:37
