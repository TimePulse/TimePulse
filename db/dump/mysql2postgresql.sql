-- MySQL dump 10.13  Distrib 5.6.14, for osx10.7 (x86_64)
--
-- Host: localhost    Database: timepulse_dev
-- ------------------------------------------------------
-- Server version	5.6.14

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `action` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `reference_1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reference_2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `reference_3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activities`
--

LOCK TABLES `activities` WRITE;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bills`
--

DROP TABLE IF EXISTS `bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `due_on` date DEFAULT NULL,
  `paid_on` date DEFAULT NULL,
  `reference_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bills`
--

LOCK TABLES `bills` WRITE;
/*!40000 ALTER TABLE `bills` DISABLE KEYS */;
/*!40000 ALTER TABLE `bills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billing_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `postal` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `abbreviation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (1,'Client 0','client_0@example.com',NULL,NULL,NULL,NULL,NULL,'CL0','2014-05-23 02:10:37','2014-05-23 02:10:37'),(2,'Client 1','client_1@example.com',NULL,NULL,NULL,NULL,NULL,'CL1','2014-05-23 02:10:37','2014-05-23 02:10:37'),(3,'Client 2','client_2@example.com',NULL,NULL,NULL,NULL,NULL,'CL2','2014-05-23 02:10:37','2014-05-23 02:10:37'),(4,'Client 3','client_3@example.com',NULL,NULL,NULL,NULL,NULL,'CL3','2014-05-23 02:10:37','2014-05-23 02:10:37');
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_items`
--

DROP TABLE IF EXISTS `invoice_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount` decimal(8,2) DEFAULT NULL,
  `hours` decimal(8,2) DEFAULT NULL,
  `total` decimal(8,2) DEFAULT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_items`
--

LOCK TABLES `invoice_items` WRITE;
/*!40000 ALTER TABLE `invoice_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoice_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `due_on` date DEFAULT NULL,
  `paid_on` date DEFAULT NULL,
  `reference_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `lft` int(11) DEFAULT NULL,
  `rgt` int(11) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `account` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `clockable` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `billable` tinyint(1) DEFAULT '1',
  `flat_rate` tinyint(1) DEFAULT '0',
  `archived` tinyint(1) DEFAULT NULL,
  `github_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pivotal_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_projects_on_lft` (`lft`),
  KEY `index_projects_on_lft_and_rgt` (`lft`,`rgt`),
  KEY `index_projects_on_parent_id_and_lft` (`parent_id`,`lft`),
  KEY `index_projects_on_client_id` (`client_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
INSERT INTO `projects` VALUES (1,NULL,1,34,NULL,'root',NULL,NULL,0,'2014-05-23 02:10:04','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(2,1,2,9,1,'Client 0',NULL,NULL,0,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(3,2,3,4,1,'Planning',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(4,2,5,6,1,'Development',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(5,2,7,8,1,'Deployment',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(6,1,10,17,2,'Client 1',NULL,NULL,0,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(7,6,11,12,2,'Planning',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(8,6,13,14,2,'Development',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(9,6,15,16,2,'Deployment',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(10,1,18,25,3,'Client 2',NULL,NULL,0,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(11,10,19,20,3,'Planning',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(12,10,21,22,3,'Development',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(13,10,23,24,3,'Deployment',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(14,1,26,33,4,'Client 3',NULL,NULL,0,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(15,14,27,28,4,'Planning',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(16,14,29,30,4,'Development',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL),(17,14,31,32,4,'Deployment',NULL,NULL,1,'2014-05-23 02:10:37','2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rates`
--

DROP TABLE IF EXISTS `rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `amount` int(11) NOT NULL,
  `project_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rates`
--

LOCK TABLES `rates` WRITE;
/*!40000 ALTER TABLE `rates` DISABLE KEYS */;
INSERT INTO `rates` VALUES (1,'Rate 1',100,2,'2014-05-23 02:10:38','2014-05-23 02:10:38');
/*!40000 ALTER TABLE `rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rates_users`
--

DROP TABLE IF EXISTS `rates_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rates_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rate_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rates_users`
--

LOCK TABLES `rates_users` WRITE;
/*!40000 ALTER TABLE `rates_users` DISABLE KEYS */;
INSERT INTO `rates_users` VALUES (1,1,1);
/*!40000 ALTER TABLE `rates_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20090507204305'),('20100408213522'),('20100505181910'),('20100505181911'),('20100505181912'),('20100505181913'),('20100512065612'),('20100526015922'),('20100602053646'),('20100914011139'),('20110521022141'),('20120113005902'),('20130201211355'),('20130308061728'),('20130522223336'),('20130522233013'),('20130528042237'),('20130530221655'),('20130610204418'),('20130724212943'),('20130730232020'),('20130802223557'),('20130815234205'),('20130824233631'),('20131105220257'),('20131107021332'),('20140429231145'),('20140516223330');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_preferences`
--

DROP TABLE IF EXISTS `user_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recent_projects_count` int(11) DEFAULT '5',
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_preferences`
--

LOCK TABLES `user_preferences` WRITE;
/*!40000 ALTER TABLE `user_preferences` DISABLE KEYS */;
INSERT INTO `user_preferences` VALUES (1,5,NULL,'2014-05-23 02:10:04','2014-05-23 02:10:04');
/*!40000 ALTER TABLE `user_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `current_project_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `failed_attempts` int(11) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmation_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `unlock_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `github_user` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pivotal_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `inactive` tinyint(1) DEFAULT '0',
  `admin` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_unlock_token` (`unlock_token`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@timepulse.io',NULL,'Admin',0,0,NULL,NULL,NULL,NULL,NULL,'2014-05-23 02:10:03','2014-05-23 02:10:04','$2a$10$/vx06du/sPWOwbDOUTk/qOxNinAvCowtSfmgZfUZht0zsNsemJ4zG',NULL,'2014-05-23 02:10:04','2014-05-23 02:10:03',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1),(2,'user0','user0@example.com',NULL,'User 0',0,0,NULL,NULL,NULL,NULL,NULL,'2014-05-23 02:10:34','2014-05-23 02:10:35','$2a$10$0qchA8eYp9JMtCFT0zosV.k08CiwfseNhqJJBkvanpeBq7MCnBezu',NULL,'2014-05-23 02:10:35','2014-05-23 02:10:34',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(3,'user1','user1@example.com',NULL,'User 1',0,0,NULL,NULL,NULL,NULL,NULL,'2014-05-23 02:10:35','2014-05-23 02:10:36','$2a$10$oYRQ6CTS3BzV2VKnt1hvYuKHrFTzKUkqiZM6CcIt6UMe4FER.qCP6',NULL,'2014-05-23 02:10:36','2014-05-23 02:10:35',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(4,'user2','user2@example.com',NULL,'User 2',0,0,NULL,NULL,NULL,NULL,NULL,'2014-05-23 02:10:36','2014-05-23 02:10:36','$2a$10$V.FeAo9wfrDLN6wwJD4Q9.S3cN1gHVmBXR2/QMA/KQtpgFJVqC1..',NULL,'2014-05-23 02:10:36','2014-05-23 02:10:36',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(5,'user3','user3@example.com',NULL,'User 3',0,0,NULL,NULL,NULL,NULL,NULL,'2014-05-23 02:10:36','2014-05-23 02:10:36','$2a$10$gYl5LdlsxyKYCVxyi0wYx.Pbt5Dapc27dE72s1MebzCBwuQp9BidS',NULL,'2014-05-23 02:10:36','2014-05-23 02:10:36',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(6,'user4','user4@example.com',NULL,'User 4',0,0,NULL,NULL,NULL,NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37','$2a$10$cFwOq6TwptSyt8dVE7Ho8enEEq6YEc8YNW8D2gT5rZHMwpmaAF6kO',NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_units`
--

DROP TABLE IF EXISTS `work_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `work_units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `stop_time` datetime DEFAULT NULL,
  `hours` decimal(8,2) DEFAULT NULL,
  `notes` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `bill_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `billable` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_work_units_on_user_id` (`user_id`),
  KEY `index_work_units_on_hours_and_start_time` (`hours`,`start_time`),
  KEY `index_work_units_on_bill_id` (`bill_id`),
  KEY `index_work_units_on_invoice_id` (`invoice_id`),
  KEY `index_work_units_on_stop_time` (`stop_time`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_units`
--

LOCK TABLES `work_units` WRITE;
/*!40000 ALTER TABLE `work_units` DISABLE KEYS */;
INSERT INTO `work_units` VALUES (1,8,1,'2014-05-12 16:10:37','2014-05-12 16:55:37',0.75,'rem atque molestias',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(2,9,1,'2014-05-11 15:10:37','2014-05-11 15:55:37',0.75,'quis iusto rem itaque voluptatibus molestiae',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(3,4,1,'2014-05-10 14:10:37','2014-05-10 14:55:37',0.75,'sequi ipsa voluptatem amet',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(4,13,1,'2014-05-09 13:10:37','2014-05-09 13:55:37',0.75,'consequatur delectus',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(5,3,1,'2014-05-08 12:10:37','2014-05-08 12:55:37',0.75,'rerum aut occaecati magnam quibusdam',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(6,15,1,'2014-05-07 11:10:37','2014-05-07 11:55:37',0.75,'excepturi ut ipsam consectetur perferendis harum',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(7,16,1,'2014-05-06 10:10:37','2014-05-06 10:55:37',0.75,'velit ipsum et vel a sunt',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(8,12,1,'2014-05-05 09:10:37','2014-05-05 09:55:37',0.75,'temporibus et reprehenderit cumque',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(9,4,1,'2014-05-04 08:10:37','2014-05-04 08:55:37',0.75,'commodi quo nihil rerum totam ea',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(10,16,1,'2014-05-03 07:10:37','2014-05-03 07:55:37',0.75,'debitis eum beatae',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(11,11,1,'2014-05-02 06:10:37','2014-05-02 06:55:37',0.75,'voluptas et',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(12,7,2,'2014-05-12 16:10:37','2014-05-12 16:55:37',0.75,'voluptas nesciunt nobis optio fugiat',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(13,11,2,'2014-05-11 15:10:37','2014-05-11 15:55:37',0.75,'mollitia eos enim culpa voluptatem delectus',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(14,16,2,'2014-05-10 14:10:37','2014-05-10 14:55:37',0.75,'rerum voluptas fugit',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(15,5,2,'2014-05-09 13:10:37','2014-05-09 13:55:37',0.75,'ex adipisci iure fugiat',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(16,13,2,'2014-05-08 12:10:37','2014-05-08 12:55:37',0.75,'quidem quis itaque quos',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(17,12,2,'2014-05-07 11:10:37','2014-05-07 11:55:37',0.75,'numquam molestiae possimus aut similique',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(18,5,2,'2014-05-06 10:10:37','2014-05-06 10:55:37',0.75,'beatae ut recusandae aliquid corporis',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(19,13,2,'2014-05-05 09:10:37','2014-05-05 09:55:37',0.75,'rerum blanditiis',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(20,5,2,'2014-05-04 08:10:37','2014-05-04 08:55:37',0.75,'cum id',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(21,4,2,'2014-05-03 07:10:37','2014-05-03 07:55:37',0.75,'molestiae consequatur',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(22,7,2,'2014-05-02 06:10:37','2014-05-02 06:55:37',0.75,'maxime et et qui',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(23,9,3,'2014-05-12 16:10:37','2014-05-12 16:55:37',0.75,'a quam magni incidunt non',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(24,3,3,'2014-05-11 15:10:37','2014-05-11 15:55:37',0.75,'ab sunt repudiandae ex',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(25,4,3,'2014-05-10 14:10:37','2014-05-10 14:55:37',0.75,'cum consequatur eos atque omnis',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(26,4,3,'2014-05-09 13:10:37','2014-05-09 13:55:37',0.75,'ut enim ab',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(27,16,3,'2014-05-08 12:10:37','2014-05-08 12:55:37',0.75,'maxime dolorem voluptatem tempora',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(28,15,3,'2014-05-07 11:10:37','2014-05-07 11:55:37',0.75,'velit dolorum',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(29,17,3,'2014-05-06 10:10:37','2014-05-06 10:55:37',0.75,'labore velit culpa doloribus dignissimos',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(30,5,3,'2014-05-05 09:10:37','2014-05-05 09:55:37',0.75,'aut repellendus est at dolorum rerum',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(31,4,3,'2014-05-04 08:10:37','2014-05-04 08:55:37',0.75,'sunt nisi repellat',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(32,7,3,'2014-05-03 07:10:37','2014-05-03 07:55:37',0.75,'rem voluptatibus eos aut doloremque',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(33,3,3,'2014-05-02 06:10:37','2014-05-02 06:55:37',0.75,'doloremque praesentium quia voluptas aliquam laborum',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(34,7,4,'2014-05-12 16:10:37','2014-05-12 16:55:37',0.75,'voluptate odit rerum',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(35,11,4,'2014-05-11 15:10:37','2014-05-11 15:55:37',0.75,'fuga rerum',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(36,7,4,'2014-05-10 14:10:37','2014-05-10 14:55:37',0.75,'maiores corporis',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(37,17,4,'2014-05-09 13:10:37','2014-05-09 13:55:37',0.75,'eveniet architecto',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(38,9,4,'2014-05-08 12:10:37','2014-05-08 12:55:37',0.75,'eaque qui in natus',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(39,17,4,'2014-05-07 11:10:37','2014-05-07 11:55:37',0.75,'quia quam a qui sit',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(40,15,4,'2014-05-06 10:10:37','2014-05-06 10:55:37',0.75,'ea ut possimus ipsa',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(41,7,4,'2014-05-05 09:10:37','2014-05-05 09:55:37',0.75,'sapiente quidem quia sapiente quidem',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(42,9,4,'2014-05-04 08:10:37','2014-05-04 08:55:37',0.75,'et esse',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(43,17,4,'2014-05-03 07:10:37','2014-05-03 07:55:37',0.75,'quis asperiores est',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(44,7,4,'2014-05-02 06:10:37','2014-05-02 06:55:37',0.75,'enim libero quas est provident',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(45,7,5,'2014-05-12 16:10:37','2014-05-12 16:55:37',0.75,'iure aut iusto doloremque qui',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(46,13,5,'2014-05-11 15:10:37','2014-05-11 15:55:37',0.75,'consequatur veritatis',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(47,15,5,'2014-05-10 14:10:37','2014-05-10 14:55:37',0.75,'molestias et incidunt laudantium nihil',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(48,4,5,'2014-05-09 13:10:37','2014-05-09 13:55:37',0.75,'nihil nulla voluptatem repellendus',NULL,NULL,'2014-05-23 02:10:37','2014-05-23 02:10:37',1),(49,16,5,'2014-05-08 12:10:37','2014-05-08 12:55:37',0.75,'id omnis architecto vero tenetur culpa',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(50,17,5,'2014-05-07 11:10:38','2014-05-07 11:55:38',0.75,'doloremque perspiciatis consequatur',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(51,5,5,'2014-05-06 10:10:38','2014-05-06 10:55:38',0.75,'similique at',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(52,13,5,'2014-05-05 09:10:38','2014-05-05 09:55:38',0.75,'aperiam quidem',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(53,11,5,'2014-05-04 08:10:38','2014-05-04 08:55:38',0.75,'quia vel aut at nihil',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(54,7,5,'2014-05-03 07:10:38','2014-05-03 07:55:38',0.75,'accusamus cum doloribus nesciunt tempora',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(55,15,5,'2014-05-02 06:10:38','2014-05-02 06:55:38',0.75,'voluptates aut',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(56,16,6,'2014-05-12 16:10:38','2014-05-12 16:55:38',0.75,'consequatur placeat laboriosam officia aut fugit',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(57,9,6,'2014-05-11 15:10:38','2014-05-11 15:55:38',0.75,'nobis doloremque quo pariatur',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(58,13,6,'2014-05-10 14:10:38','2014-05-10 14:55:38',0.75,'porro quis',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(59,3,6,'2014-05-09 13:10:38','2014-05-09 13:55:38',0.75,'eius earum ut et non deserunt',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(60,5,6,'2014-05-08 12:10:38','2014-05-08 12:55:38',0.75,'optio voluptate rem',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(61,3,6,'2014-05-07 11:10:38','2014-05-07 11:55:38',0.75,'dolor et ut et odio',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(62,11,6,'2014-05-06 10:10:38','2014-05-06 10:55:38',0.75,'aperiam veniam est sapiente',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(63,15,6,'2014-05-05 09:10:38','2014-05-05 09:55:38',0.75,'quam ipsum neque itaque',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(64,4,6,'2014-05-04 08:10:38','2014-05-04 08:55:38',0.75,'dolor eveniet consequatur eligendi ipsa libero',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(65,11,6,'2014-05-03 07:10:38','2014-05-03 07:55:38',0.75,'officia itaque architecto dolor aliquid non',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1),(66,13,6,'2014-05-02 06:10:38','2014-05-02 06:55:38',0.75,'neque aliquid ipsum in labore',NULL,NULL,'2014-05-23 02:10:38','2014-05-23 02:10:38',1);
/*!40000 ALTER TABLE `work_units` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-22 19:38:39
