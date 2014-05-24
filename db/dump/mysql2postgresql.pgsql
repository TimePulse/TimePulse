--
-- Generated from mysql2pgsql.perl
-- http://gborg.postgresql.org/project/mysql2psql/
-- (c) 2001 - 2007 Jose M. Duarte, Joseph Speigle
--

-- warnings are printed for drop tables if they do not exist
-- please see http://archives.postgresql.org/pgsql-novice/2004-10/msg00158.php

-- ##############################################################
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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
-- MySQL dump 10.13  Distrib 5.6.14, for osx10.7 (x86_64)
--
-- Host: localhost    Database: timepulse_dev
-- ------------------------------------------------------
-- Server version	5.6.14


--
-- Table structure for table activities
--

DROP TABLE "activities" CASCADE\g
DROP SEQUENCE "activities_id_seq" CASCADE ;

CREATE SEQUENCE "activities_id_seq" ;

CREATE TABLE  "activities" (
   "id" integer DEFAULT nextval('"activities_id_seq"') NOT NULL,
   "source"   varchar(255) DEFAULT NULL, 
   "time"   timestamp without time zone DEFAULT NULL, 
   "action"   varchar(255) DEFAULT NULL, 
   "description"   text, 
   "reference_1"   varchar(255) DEFAULT NULL, 
   "reference_2"   varchar(255) DEFAULT NULL, 
   "project_id"   int DEFAULT NULL, 
   "user_id"   int DEFAULT NULL, 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   "reference_3"   varchar(255) DEFAULT NULL, 
   primary key ("id")
)   ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE activities DISABLE KEYS */;
/*!40000 ALTER TABLE activities ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Dumping data for table activities
--


--
-- Table structure for table bills
--

DROP TABLE "bills" CASCADE\g
DROP SEQUENCE "bills_id_seq" CASCADE ;

CREATE SEQUENCE "bills_id_seq" ;

CREATE TABLE  "bills" (
   "id" integer DEFAULT nextval('"bills_id_seq"') NOT NULL,
   "user_id"   int DEFAULT NULL, 
   "notes"   text, 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   "due_on"   date DEFAULT NULL, 
   "paid_on"   date DEFAULT NULL, 
   "reference_number"   varchar(255) DEFAULT NULL, 
   primary key ("id")
)   ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE bills DISABLE KEYS */;
/*!40000 ALTER TABLE bills ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Dumping data for table bills
--


--
-- Table structure for table clients
--

DROP TABLE "clients" CASCADE\g
DROP SEQUENCE "clients_id_seq" CASCADE ;

CREATE SEQUENCE "clients_id_seq"  START WITH 5 ;

CREATE TABLE  "clients" (
   "id" integer DEFAULT nextval('"clients_id_seq"') NOT NULL,
   "name"   varchar(255) DEFAULT NULL, 
   "billing_email"   varchar(255) DEFAULT NULL, 
   "address_1"   varchar(255) DEFAULT NULL, 
   "address_2"   varchar(255) DEFAULT NULL, 
   "city"   varchar(255) DEFAULT NULL, 
   "state"   varchar(255) DEFAULT NULL, 
   "postal"   varchar(255) DEFAULT NULL, 
   "abbreviation"   varchar(255) DEFAULT NULL, 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   primary key ("id")
)    ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE clients DISABLE KEYS */;

--
-- Dumping data for table clients
--

INSERT INTO "clients" VALUES (1,E'Client 0',E'client_0@example.com',NULL,NULL,NULL,NULL,NULL,E'CL0',E'2014-05-23 02:10:37',E'2014-05-23 02:10:37');
INSERT INTO "clients" VALUES (2,E'Client 1',E'client_1@example.com',NULL,NULL,NULL,NULL,NULL,E'CL1',E'2014-05-23 02:10:37',E'2014-05-23 02:10:37');
INSERT INTO "clients" VALUES (3,E'Client 2',E'client_2@example.com',NULL,NULL,NULL,NULL,NULL,E'CL2',E'2014-05-23 02:10:37',E'2014-05-23 02:10:37');
INSERT INTO "clients" VALUES (4,E'Client 3',E'client_3@example.com',NULL,NULL,NULL,NULL,NULL,E'CL3',E'2014-05-23 02:10:37',E'2014-05-23 02:10:37');

/*!40000 ALTER TABLE clients ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Table structure for table invoice_items
--

DROP TABLE "invoice_items" CASCADE\g
DROP SEQUENCE "invoice_items_id_seq" CASCADE ;

CREATE SEQUENCE "invoice_items_id_seq" ;

CREATE TABLE  "invoice_items" (
   "id" integer DEFAULT nextval('"invoice_items_id_seq"') NOT NULL,
   "name"   varchar(255) DEFAULT NULL, 
   "amount"   decimal(8,2) DEFAULT NULL, 
   "hours"   decimal(8,2) DEFAULT NULL, 
   "total"   decimal(8,2) DEFAULT NULL, 
   "invoice_id"   int DEFAULT NULL, 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   primary key ("id")
)   ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE invoice_items DISABLE KEYS */;
/*!40000 ALTER TABLE invoice_items ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Dumping data for table invoice_items
--


--
-- Table structure for table invoices
--

DROP TABLE "invoices" CASCADE\g
DROP SEQUENCE "invoices_id_seq" CASCADE ;

CREATE SEQUENCE "invoices_id_seq" ;

CREATE TABLE  "invoices" (
   "id" integer DEFAULT nextval('"invoices_id_seq"') NOT NULL,
   "client_id"   int DEFAULT NULL, 
   "notes"   text, 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   "due_on"   date DEFAULT NULL, 
   "paid_on"   date DEFAULT NULL, 
   "reference_number"   varchar(255) DEFAULT NULL, 
   primary key ("id")
)   ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE invoices DISABLE KEYS */;
/*!40000 ALTER TABLE invoices ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Dumping data for table invoices
--


--
-- Table structure for table projects
--

DROP TABLE "projects" CASCADE\g
DROP SEQUENCE "projects_id_seq" CASCADE ;

CREATE SEQUENCE "projects_id_seq"  START WITH 18 ;

CREATE TABLE  "projects" (
   "id" integer DEFAULT nextval('"projects_id_seq"') NOT NULL,
   "parent_id"   int DEFAULT NULL, 
   "lft"   int DEFAULT NULL, 
   "rgt"   int DEFAULT NULL, 
   "client_id"   int DEFAULT NULL, 
   "name"   varchar(255) NOT NULL, 
   "account"   varchar(255) DEFAULT NULL, 
   "description"   text, 
   "clockable"    smallint NOT NULL DEFAULT '0', 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   "billable"    smallint DEFAULT '1', 
   "flat_rate"    smallint DEFAULT '0', 
   "archived"    smallint DEFAULT NULL, 
   "github_url"   varchar(255) DEFAULT NULL, 
   "pivotal_id"   int DEFAULT NULL, 
   primary key ("id")
)    ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE projects DISABLE KEYS */;

--
-- Dumping data for table projects
--

INSERT INTO "projects" VALUES (1,NULL,1,34,NULL,E'root',NULL,NULL,0,E'2014-05-23 02:10:04',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (2,1,2,9,1,E'Client 0',NULL,NULL,0,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (3,2,3,4,1,E'Planning',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (4,2,5,6,1,E'Development',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (5,2,7,8,1,E'Deployment',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (6,1,10,17,2,E'Client 1',NULL,NULL,0,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (7,6,11,12,2,E'Planning',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (8,6,13,14,2,E'Development',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (9,6,15,16,2,E'Deployment',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (10,1,18,25,3,E'Client 2',NULL,NULL,0,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (11,10,19,20,3,E'Planning',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (12,10,21,22,3,E'Development',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (13,10,23,24,3,E'Deployment',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (14,1,26,33,4,E'Client 3',NULL,NULL,0,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (15,14,27,28,4,E'Planning',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (16,14,29,30,4,E'Development',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);
INSERT INTO "projects" VALUES (17,14,31,32,4,E'Deployment',NULL,NULL,1,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1,0,NULL,NULL,NULL);

/*!40000 ALTER TABLE projects ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE INDEX "projects_lft_idx" ON "projects" USING btree ("lft");
CREATE INDEX "projects_1_idx" ON "projects" USING btree ("lft", "rgt");
CREATE INDEX "projects_client_id_idx" ON "projects" USING btree ("client_id");

--
-- Table structure for table rates
--

DROP TABLE "rates" CASCADE\g
DROP SEQUENCE "rates_id_seq" CASCADE ;

CREATE SEQUENCE "rates_id_seq"  START WITH 2 ;

CREATE TABLE  "rates" (
   "id" integer DEFAULT nextval('"rates_id_seq"') NOT NULL,
   "name"   varchar(255) NOT NULL, 
   "amount"   int NOT NULL, 
   "project_id"   int DEFAULT NULL, 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   primary key ("id")
)    ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE rates DISABLE KEYS */;

--
-- Dumping data for table rates
--

INSERT INTO "rates" VALUES (1,E'Rate 1',100,2,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38'); 
/*!40000 ALTER TABLE rates ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Table structure for table rates_users
--

DROP TABLE "rates_users" CASCADE\g
DROP SEQUENCE "rates_users_id_seq" CASCADE ;

CREATE SEQUENCE "rates_users_id_seq"  START WITH 2 ;

CREATE TABLE  "rates_users" (
   "id" integer DEFAULT nextval('"rates_users_id_seq"') NOT NULL,
   "rate_id"   int DEFAULT NULL, 
   "user_id"   int DEFAULT NULL, 
   primary key ("id")
)    ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE rates_users DISABLE KEYS */;

--
-- Dumping data for table rates_users
--

INSERT INTO "rates_users" VALUES (1,1,1); 
/*!40000 ALTER TABLE rates_users ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Table structure for table schema_migrations
--

DROP TABLE "schema_migrations" CASCADE\g
CREATE TABLE  "schema_migrations" (
   "version"   varchar(255) NOT NULL, 
 unique ("version") 
)   ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE schema_migrations DISABLE KEYS */;

--
-- Dumping data for table schema_migrations
--

INSERT INTO "schema_migrations" VALUES (E'20090507204305');
INSERT INTO "schema_migrations" VALUES (E'20100408213522');
INSERT INTO "schema_migrations" VALUES (E'20100505181910');
INSERT INTO "schema_migrations" VALUES (E'20100505181911');
INSERT INTO "schema_migrations" VALUES (E'20100505181912');
INSERT INTO "schema_migrations" VALUES (E'20100505181913');
INSERT INTO "schema_migrations" VALUES (E'20100512065612');
INSERT INTO "schema_migrations" VALUES (E'20100526015922');
INSERT INTO "schema_migrations" VALUES (E'20100602053646');
INSERT INTO "schema_migrations" VALUES (E'20100914011139');
INSERT INTO "schema_migrations" VALUES (E'20110521022141');
INSERT INTO "schema_migrations" VALUES (E'20120113005902');
INSERT INTO "schema_migrations" VALUES (E'20130201211355');
INSERT INTO "schema_migrations" VALUES (E'20130308061728');
INSERT INTO "schema_migrations" VALUES (E'20130522223336');
INSERT INTO "schema_migrations" VALUES (E'20130522233013');
INSERT INTO "schema_migrations" VALUES (E'20130528042237');
INSERT INTO "schema_migrations" VALUES (E'20130530221655');
INSERT INTO "schema_migrations" VALUES (E'20130610204418');
INSERT INTO "schema_migrations" VALUES (E'20130724212943');
INSERT INTO "schema_migrations" VALUES (E'20130730232020');
INSERT INTO "schema_migrations" VALUES (E'20130802223557');
INSERT INTO "schema_migrations" VALUES (E'20130815234205');
INSERT INTO "schema_migrations" VALUES (E'20130824233631');
INSERT INTO "schema_migrations" VALUES (E'20131105220257');
INSERT INTO "schema_migrations" VALUES (E'20131107021332');
INSERT INTO "schema_migrations" VALUES (E'20140429231145');
INSERT INTO "schema_migrations" VALUES (E'20140516223330');

/*!40000 ALTER TABLE schema_migrations ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Table structure for table user_preferences
--

DROP TABLE "user_preferences" CASCADE\g
DROP SEQUENCE "user_preferences_id_seq" CASCADE ;

CREATE SEQUENCE "user_preferences_id_seq"  START WITH 2 ;

CREATE TABLE  "user_preferences" (
   "id" integer DEFAULT nextval('"user_preferences_id_seq"') NOT NULL,
   "recent_projects_count"   int DEFAULT '5', 
   "user_id"   int DEFAULT NULL, 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   primary key ("id")
)    ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE user_preferences DISABLE KEYS */;

--
-- Dumping data for table user_preferences
--

INSERT INTO "user_preferences" VALUES (1,5,NULL,E'2014-05-23 02:10:04',E'2014-05-23 02:10:04'); 
/*!40000 ALTER TABLE user_preferences ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Table structure for table users
--

DROP TABLE "users" CASCADE\g
DROP SEQUENCE "users_id_seq" CASCADE ;

CREATE SEQUENCE "users_id_seq"  START WITH 7 ;

CREATE TABLE  "users" (
   "id" integer DEFAULT nextval('"users_id_seq"') NOT NULL,
   "login"   varchar(255) NOT NULL, 
   "email"   varchar(255) NOT NULL, 
   "current_project_id"   int DEFAULT NULL, 
   "name"   varchar(255) NOT NULL, 
   "sign_in_count"   int NOT NULL DEFAULT '0', 
   "failed_attempts"   int NOT NULL DEFAULT '0', 
   "last_request_at"   timestamp without time zone DEFAULT NULL, 
   "current_sign_in_at"   timestamp without time zone DEFAULT NULL, 
   "last_sign_in_at"   timestamp without time zone DEFAULT NULL, 
   "current_sign_in_ip"   varchar(255) DEFAULT NULL, 
   "last_sign_in_ip"   varchar(255) DEFAULT NULL, 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   "encrypted_password"   varchar(255) DEFAULT NULL, 
   "confirmation_token"   varchar(255) DEFAULT NULL, 
   "confirmed_at"   timestamp without time zone DEFAULT NULL, 
   "confirmation_sent_at"   timestamp without time zone DEFAULT NULL, 
   "reset_password_token"   varchar(255) DEFAULT NULL, 
   "reset_password_sent_at"   timestamp without time zone DEFAULT NULL, 
   "remember_token"   varchar(255) DEFAULT NULL, 
   "remember_created_at"   timestamp without time zone DEFAULT NULL, 
   "unlock_token"   varchar(255) DEFAULT NULL, 
   "locked_at"   timestamp without time zone DEFAULT NULL, 
   "unconfirmed_email"   varchar(255) DEFAULT NULL, 
   "github_user"   varchar(255) DEFAULT NULL, 
   "pivotal_name"   varchar(255) DEFAULT NULL, 
   "inactive"    smallint DEFAULT '0', 
   "admin"    smallint DEFAULT '0', 
   primary key ("id"),
 unique ("email") ,
 unique ("confirmation_token") ,
 unique ("reset_password_token") ,
 unique ("unlock_token") 
)    ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE users DISABLE KEYS */;

--
-- Dumping data for table users
--

INSERT INTO "users" VALUES (1,E'admin',E'admin@timepulse.io',NULL,E'Admin',0,0,NULL,NULL,NULL,NULL,NULL,E'2014-05-23 02:10:03',E'2014-05-23 02:10:04',E'$2a$10$/vx06du/sPWOwbDOUTk/qOxNinAvCowtSfmgZfUZht0zsNsemJ4zG',NULL,E'2014-05-23 02:10:04',E'2014-05-23 02:10:03',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,1);
INSERT INTO "users" VALUES (2,E'user0',E'user0@example.com',NULL,E'User 0',0,0,NULL,NULL,NULL,NULL,NULL,E'2014-05-23 02:10:34',E'2014-05-23 02:10:35',E'$2a$10$0qchA8eYp9JMtCFT0zosV.k08CiwfseNhqJJBkvanpeBq7MCnBezu',NULL,E'2014-05-23 02:10:35',E'2014-05-23 02:10:34',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0);
INSERT INTO "users" VALUES (3,E'user1',E'user1@example.com',NULL,E'User 1',0,0,NULL,NULL,NULL,NULL,NULL,E'2014-05-23 02:10:35',E'2014-05-23 02:10:36',E'$2a$10$oYRQ6CTS3BzV2VKnt1hvYuKHrFTzKUkqiZM6CcIt6UMe4FER.qCP6',NULL,E'2014-05-23 02:10:36',E'2014-05-23 02:10:35',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0);
INSERT INTO "users" VALUES (4,E'user2',E'user2@example.com',NULL,E'User 2',0,0,NULL,NULL,NULL,NULL,NULL,E'2014-05-23 02:10:36',E'2014-05-23 02:10:36',E'$2a$10$V.FeAo9wfrDLN6wwJD4Q9.S3cN1gHVmBXR2/QMA/KQtpgFJVqC1..',NULL,E'2014-05-23 02:10:36',E'2014-05-23 02:10:36',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0);
INSERT INTO "users" VALUES (5,E'user3',E'user3@example.com',NULL,E'User 3',0,0,NULL,NULL,NULL,NULL,NULL,E'2014-05-23 02:10:36',E'2014-05-23 02:10:36',E'$2a$10$gYl5LdlsxyKYCVxyi0wYx.Pbt5Dapc27dE72s1MebzCBwuQp9BidS',NULL,E'2014-05-23 02:10:36',E'2014-05-23 02:10:36',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0);
INSERT INTO "users" VALUES (6,E'user4',E'user4@example.com',NULL,E'User 4',0,0,NULL,NULL,NULL,NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',E'$2a$10$cFwOq6TwptSyt8dVE7Ho8enEEq6YEc8YNW8D2gT5rZHMwpmaAF6kO',NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0);

/*!40000 ALTER TABLE users ENABLE KEYS */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

--
-- Table structure for table work_units
--

DROP TABLE "work_units" CASCADE\g
DROP SEQUENCE "work_units_id_seq" CASCADE ;

CREATE SEQUENCE "work_units_id_seq"  START WITH 67 ;

CREATE TABLE  "work_units" (
   "id" integer DEFAULT nextval('"work_units_id_seq"') NOT NULL,
   "project_id"   int DEFAULT NULL, 
   "user_id"   int DEFAULT NULL, 
   "start_time"   timestamp without time zone DEFAULT NULL, 
   "stop_time"   timestamp without time zone DEFAULT NULL, 
   "hours"   decimal(8,2) DEFAULT NULL, 
   "notes"   varchar(255) DEFAULT NULL, 
   "invoice_id"   int DEFAULT NULL, 
   "bill_id"   int DEFAULT NULL, 
   "created_at"   timestamp without time zone DEFAULT NULL, 
   "updated_at"   timestamp without time zone DEFAULT NULL, 
   "billable"    smallint DEFAULT NULL, 
   primary key ("id")
)    ;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40000 ALTER TABLE work_units DISABLE KEYS */;

--
-- Dumping data for table work_units
--

INSERT INTO "work_units" VALUES (1,8,1,E'2014-05-12 16:10:37',E'2014-05-12 16:55:37',0.75,E'rem atque molestias',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (2,9,1,E'2014-05-11 15:10:37',E'2014-05-11 15:55:37',0.75,E'quis iusto rem itaque voluptatibus molestiae',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (3,4,1,E'2014-05-10 14:10:37',E'2014-05-10 14:55:37',0.75,E'sequi ipsa voluptatem amet',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (4,13,1,E'2014-05-09 13:10:37',E'2014-05-09 13:55:37',0.75,E'consequatur delectus',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (5,3,1,E'2014-05-08 12:10:37',E'2014-05-08 12:55:37',0.75,E'rerum aut occaecati magnam quibusdam',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (6,15,1,E'2014-05-07 11:10:37',E'2014-05-07 11:55:37',0.75,E'excepturi ut ipsam consectetur perferendis harum',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (7,16,1,E'2014-05-06 10:10:37',E'2014-05-06 10:55:37',0.75,E'velit ipsum et vel a sunt',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (8,12,1,E'2014-05-05 09:10:37',E'2014-05-05 09:55:37',0.75,E'temporibus et reprehenderit cumque',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (9,4,1,E'2014-05-04 08:10:37',E'2014-05-04 08:55:37',0.75,E'commodi quo nihil rerum totam ea',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (10,16,1,E'2014-05-03 07:10:37',E'2014-05-03 07:55:37',0.75,E'debitis eum beatae',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (11,11,1,E'2014-05-02 06:10:37',E'2014-05-02 06:55:37',0.75,E'voluptas et',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (12,7,2,E'2014-05-12 16:10:37',E'2014-05-12 16:55:37',0.75,E'voluptas nesciunt nobis optio fugiat',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (13,11,2,E'2014-05-11 15:10:37',E'2014-05-11 15:55:37',0.75,E'mollitia eos enim culpa voluptatem delectus',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (14,16,2,E'2014-05-10 14:10:37',E'2014-05-10 14:55:37',0.75,E'rerum voluptas fugit',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (15,5,2,E'2014-05-09 13:10:37',E'2014-05-09 13:55:37',0.75,E'ex adipisci iure fugiat',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (16,13,2,E'2014-05-08 12:10:37',E'2014-05-08 12:55:37',0.75,E'quidem quis itaque quos',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (17,12,2,E'2014-05-07 11:10:37',E'2014-05-07 11:55:37',0.75,E'numquam molestiae possimus aut similique',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (18,5,2,E'2014-05-06 10:10:37',E'2014-05-06 10:55:37',0.75,E'beatae ut recusandae aliquid corporis',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (19,13,2,E'2014-05-05 09:10:37',E'2014-05-05 09:55:37',0.75,E'rerum blanditiis',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (20,5,2,E'2014-05-04 08:10:37',E'2014-05-04 08:55:37',0.75,E'cum id',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (21,4,2,E'2014-05-03 07:10:37',E'2014-05-03 07:55:37',0.75,E'molestiae consequatur',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (22,7,2,E'2014-05-02 06:10:37',E'2014-05-02 06:55:37',0.75,E'maxime et et qui',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (23,9,3,E'2014-05-12 16:10:37',E'2014-05-12 16:55:37',0.75,E'a quam magni incidunt non',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (24,3,3,E'2014-05-11 15:10:37',E'2014-05-11 15:55:37',0.75,E'ab sunt repudiandae ex',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (25,4,3,E'2014-05-10 14:10:37',E'2014-05-10 14:55:37',0.75,E'cum consequatur eos atque omnis',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (26,4,3,E'2014-05-09 13:10:37',E'2014-05-09 13:55:37',0.75,E'ut enim ab',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (27,16,3,E'2014-05-08 12:10:37',E'2014-05-08 12:55:37',0.75,E'maxime dolorem voluptatem tempora',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (28,15,3,E'2014-05-07 11:10:37',E'2014-05-07 11:55:37',0.75,E'velit dolorum',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (29,17,3,E'2014-05-06 10:10:37',E'2014-05-06 10:55:37',0.75,E'labore velit culpa doloribus dignissimos',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (30,5,3,E'2014-05-05 09:10:37',E'2014-05-05 09:55:37',0.75,E'aut repellendus est at dolorum rerum',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (31,4,3,E'2014-05-04 08:10:37',E'2014-05-04 08:55:37',0.75,E'sunt nisi repellat',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (32,7,3,E'2014-05-03 07:10:37',E'2014-05-03 07:55:37',0.75,E'rem voluptatibus eos aut doloremque',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (33,3,3,E'2014-05-02 06:10:37',E'2014-05-02 06:55:37',0.75,E'doloremque praesentium quia voluptas aliquam laborum',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (34,7,4,E'2014-05-12 16:10:37',E'2014-05-12 16:55:37',0.75,E'voluptate odit rerum',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (35,11,4,E'2014-05-11 15:10:37',E'2014-05-11 15:55:37',0.75,E'fuga rerum',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (36,7,4,E'2014-05-10 14:10:37',E'2014-05-10 14:55:37',0.75,E'maiores corporis',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (37,17,4,E'2014-05-09 13:10:37',E'2014-05-09 13:55:37',0.75,E'eveniet architecto',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (38,9,4,E'2014-05-08 12:10:37',E'2014-05-08 12:55:37',0.75,E'eaque qui in natus',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (39,17,4,E'2014-05-07 11:10:37',E'2014-05-07 11:55:37',0.75,E'quia quam a qui sit',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (40,15,4,E'2014-05-06 10:10:37',E'2014-05-06 10:55:37',0.75,E'ea ut possimus ipsa',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (41,7,4,E'2014-05-05 09:10:37',E'2014-05-05 09:55:37',0.75,E'sapiente quidem quia sapiente quidem',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (42,9,4,E'2014-05-04 08:10:37',E'2014-05-04 08:55:37',0.75,E'et esse',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (43,17,4,E'2014-05-03 07:10:37',E'2014-05-03 07:55:37',0.75,E'quis asperiores est',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (44,7,4,E'2014-05-02 06:10:37',E'2014-05-02 06:55:37',0.75,E'enim libero quas est provident',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (45,7,5,E'2014-05-12 16:10:37',E'2014-05-12 16:55:37',0.75,E'iure aut iusto doloremque qui',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (46,13,5,E'2014-05-11 15:10:37',E'2014-05-11 15:55:37',0.75,E'consequatur veritatis',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (47,15,5,E'2014-05-10 14:10:37',E'2014-05-10 14:55:37',0.75,E'molestias et incidunt laudantium nihil',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (48,4,5,E'2014-05-09 13:10:37',E'2014-05-09 13:55:37',0.75,E'nihil nulla voluptatem repellendus',NULL,NULL,E'2014-05-23 02:10:37',E'2014-05-23 02:10:37',1);
INSERT INTO "work_units" VALUES (49,16,5,E'2014-05-08 12:10:37',E'2014-05-08 12:55:37',0.75,E'id omnis architecto vero tenetur culpa',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (50,17,5,E'2014-05-07 11:10:38',E'2014-05-07 11:55:38',0.75,E'doloremque perspiciatis consequatur',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (51,5,5,E'2014-05-06 10:10:38',E'2014-05-06 10:55:38',0.75,E'similique at',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (52,13,5,E'2014-05-05 09:10:38',E'2014-05-05 09:55:38',0.75,E'aperiam quidem',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (53,11,5,E'2014-05-04 08:10:38',E'2014-05-04 08:55:38',0.75,E'quia vel aut at nihil',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (54,7,5,E'2014-05-03 07:10:38',E'2014-05-03 07:55:38',0.75,E'accusamus cum doloribus nesciunt tempora',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (55,15,5,E'2014-05-02 06:10:38',E'2014-05-02 06:55:38',0.75,E'voluptates aut',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (56,16,6,E'2014-05-12 16:10:38',E'2014-05-12 16:55:38',0.75,E'consequatur placeat laboriosam officia aut fugit',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (57,9,6,E'2014-05-11 15:10:38',E'2014-05-11 15:55:38',0.75,E'nobis doloremque quo pariatur',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (58,13,6,E'2014-05-10 14:10:38',E'2014-05-10 14:55:38',0.75,E'porro quis',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (59,3,6,E'2014-05-09 13:10:38',E'2014-05-09 13:55:38',0.75,E'eius earum ut et non deserunt',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (60,5,6,E'2014-05-08 12:10:38',E'2014-05-08 12:55:38',0.75,E'optio voluptate rem',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (61,3,6,E'2014-05-07 11:10:38',E'2014-05-07 11:55:38',0.75,E'dolor et ut et odio',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (62,11,6,E'2014-05-06 10:10:38',E'2014-05-06 10:55:38',0.75,E'aperiam veniam est sapiente',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (63,15,6,E'2014-05-05 09:10:38',E'2014-05-05 09:55:38',0.75,E'quam ipsum neque itaque',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (64,4,6,E'2014-05-04 08:10:38',E'2014-05-04 08:55:38',0.75,E'dolor eveniet consequatur eligendi ipsa libero',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (65,11,6,E'2014-05-03 07:10:38',E'2014-05-03 07:55:38',0.75,E'officia itaque architecto dolor aliquid non',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);
INSERT INTO "work_units" VALUES (66,13,6,E'2014-05-02 06:10:38',E'2014-05-02 06:55:38',0.75,E'neque aliquid ipsum in labore',NULL,NULL,E'2014-05-23 02:10:38',E'2014-05-23 02:10:38',1);

/*!40000 ALTER TABLE work_units ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
CREATE INDEX "work_units_user_id_idx" ON "work_units" USING btree ("user_id");
CREATE INDEX "work_units_1_idx" ON "work_units" USING btree ("hours", "start_time");
CREATE INDEX "work_units_bill_id_idx" ON "work_units" USING btree ("bill_id");
CREATE INDEX "work_units_invoice_id_idx" ON "work_units" USING btree ("invoice_id");
CREATE INDEX "work_units_stop_time_idx" ON "work_units" USING btree ("stop_time");
