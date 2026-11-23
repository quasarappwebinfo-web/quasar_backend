-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: quasar_staging
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
-- Table structure for table `alembic_version`
--

DROP TABLE IF EXISTS `alembic_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alembic_version`
--

LOCK TABLES `alembic_version` WRITE;
/*!40000 ALTER TABLE `alembic_version` DISABLE KEYS */;
INSERT INTO `alembic_version` VALUES ('027_chapter_opening_zone');
/*!40000 ALTER TABLE `alembic_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` int NOT NULL,
  `action` varchar(50) NOT NULL,
  `field_changed` varchar(100) DEFAULT NULL,
  `old_value` varchar(255) DEFAULT NULL,
  `new_value` varchar(255) DEFAULT NULL,
  `reason` text,
  `changed_by` int NOT NULL,
  `changed_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `changed_by` (`changed_by`),
  CONSTRAINT `audit_log_ibfk_1` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (1,'obra',5,'actividad_quitada','actividad','Cerramiento En Tela Verde','quitada','«Cerramiento En Tela Verde». Capítulo: Actividades Preliminares. Subcapítulo: Preliminares. Zona: Sin zona.',3,'2026-11-10 14:57:51'),(2,'obra',5,'actividad_quitada','actividad','Escalera en concreto','quitada','«Escalera en concreto». Capítulo: Estructura. Subcapítulo: Estructura Concreto. Zona: Sin zona.',3,'2026-11-10 14:58:44'),(3,'obra',5,'actividad_quitada','actividad','Pantalla en concreto N1 a N2','quitada','«Pantalla en concreto N1 a N2». Capítulo: Estructura. Subcapítulo: Estructura Concreto. Zona: Sin zona.',3,'2026-11-10 14:58:59'),(4,'obra',5,'actividad_quitada','actividad','Columnas en tuberia metalica','quitada','«Columnas en tuberia metalica». Capítulo: Estructura. Subcapítulo: Estructura Metalica. Zona: Sin zona.',3,'2026-11-10 14:59:48'),(5,'obra',5,'actividad_quitada','actividad','Placa de entrepiso con bloque #5','quitada','«Placa de entrepiso con bloque #5». Capítulo: Estructura. Subcapítulo: Estructura Concreto. Zona: Todas las zonas.',3,'2026-11-12 15:45:13'),(6,'obra',5,'actividad_quitada','actividad','Viga de amarre metalica','quitada','«Viga de amarre metalica». Capítulo: Estructura. Subcapítulo: Estructura Metalica. Zona: Todas las zonas.',3,'2026-11-12 16:56:56'),(7,'obra',5,'actividad_quitada','actividad','Vigas en tuberia metalica','quitada','«Vigas en tuberia metalica». Capítulo: Estructura. Subcapítulo: Estructura Metalica. Zona: Todas las zonas.',3,'2026-11-12 16:57:06');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crew_members`
--

DROP TABLE IF EXISTS `crew_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crew_members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `crew_id` int NOT NULL,
  `worker_id` int NOT NULL,
  `joined_at` datetime NOT NULL DEFAULT (now()),
  `left_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `crew_id` (`crew_id`),
  KEY `worker_id` (`worker_id`),
  CONSTRAINT `crew_members_ibfk_1` FOREIGN KEY (`crew_id`) REFERENCES `crews` (`id`),
  CONSTRAINT `crew_members_ibfk_2` FOREIGN KEY (`worker_id`) REFERENCES `workers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crew_members`
--

LOCK TABLES `crew_members` WRITE;
/*!40000 ALTER TABLE `crew_members` DISABLE KEYS */;
/*!40000 ALTER TABLE `crew_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crews`
--

DROP TABLE IF EXISTS `crews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `leader_worker_id` int DEFAULT NULL,
  `obra_id` int DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `leader_worker_id` (`leader_worker_id`),
  KEY `obra_id` (`obra_id`),
  CONSTRAINT `crews_ibfk_1` FOREIGN KEY (`leader_worker_id`) REFERENCES `workers` (`id`),
  CONSTRAINT `crews_ibfk_2` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crews`
--

LOCK TABLES `crews` WRITE;
/*!40000 ALTER TABLE `crews` DISABLE KEYS */;
/*!40000 ALTER TABLE `crews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delay_reasons`
--

DROP TABLE IF EXISTS `delay_reasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delay_reasons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `description` text,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delay_reasons`
--

LOCK TABLES `delay_reasons` WRITE;
/*!40000 ALTER TABLE `delay_reasons` DISABLE KEYS */;
/*!40000 ALTER TABLE `delay_reasons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_types`
--

DROP TABLE IF EXISTS `document_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `description` text,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_types`
--

LOCK TABLES `document_types` WRITE;
/*!40000 ALTER TABLE `document_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `document_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `obra_id` int NOT NULL,
  `document_type_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `file_url` varchar(500) NOT NULL,
  `is_visible_to_client` int DEFAULT NULL,
  `uploaded_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_documents_uuid` (`uuid`),
  KEY `obra_id` (`obra_id`),
  KEY `document_type_id` (`document_type_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`),
  CONSTRAINT `documents_ibfk_2` FOREIGN KEY (`document_type_id`) REFERENCES `document_types` (`id`),
  CONSTRAINT `documents_ibfk_3` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (1,'c1a690ec-5149-4646-b973-b5e26047d067',2,NULL,'Hacienda Trapiches J15-B','Prueba de archivo subido','quasar-tests/obras/2/documentos/6e63a1ffb7174edebd93429c12c2c27a.pdf',0,1,'2026-11-07 11:10:37'),(2,'56f0d288-ded1-49ea-9410-e96237b7d3d8',7,NULL,'Planos Finales Bellagio',NULL,'quasar-tests/obras/7/documentos/aa2fb08a0eb54016bfd295aeb364e91b.dwg',0,2,'2026-11-14 09:22:09'),(3,'1375536a-96d2-48aa-baf7-13ac70c46036',5,NULL,'Planos L2 Tramonti Finales',NULL,'quasar-tests/obras/5/documentos/f2edfd3467164b7c94ac81907809d718.dwg',0,2,'2026-11-14 09:46:05');
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `measurement_units`
--

DROP TABLE IF EXISTS `measurement_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `measurement_units` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `symbol` varchar(30) NOT NULL,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `measurement_units`
--

LOCK TABLES `measurement_units` WRITE;
/*!40000 ALTER TABLE `measurement_units` DISABLE KEYS */;
/*!40000 ALTER TABLE `measurement_units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `obra_chapter_openings`
--

DROP TABLE IF EXISTS `obra_chapter_openings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `obra_chapter_openings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `obra_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `mode` varchar(20) NOT NULL,
  `progress_percent` decimal(5,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `zone_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_obra_chapter_zone_opening` (`obra_id`,`chapter_id`,`zone_id`),
  KEY `chapter_id` (`chapter_id`),
  KEY `fk_obra_chapter_opening_zone` (`zone_id`),
  KEY `ix_obra_chapter_opening_obra` (`obra_id`),
  CONSTRAINT `fk_obra_chapter_opening_zone` FOREIGN KEY (`zone_id`) REFERENCES `task_zones` (`id`),
  CONSTRAINT `obra_chapter_openings_ibfk_1` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`),
  CONSTRAINT `obra_chapter_openings_ibfk_2` FOREIGN KEY (`chapter_id`) REFERENCES `task_chapters` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `obra_chapter_openings`
--

LOCK TABLES `obra_chapter_openings` WRITE;
/*!40000 ALTER TABLE `obra_chapter_openings` DISABLE KEYS */;
INSERT INTO `obra_chapter_openings` VALUES (1,7,1,'completed',100.00,'2026-11-12 12:41:45',NULL),(2,7,2,'completed',100.00,'2026-11-12 12:41:45',NULL),(3,7,4,'partial',80.00,'2026-11-12 12:41:45',NULL),(4,7,3,'partial',60.00,'2026-11-12 12:41:45',NULL),(5,7,5,'partial',50.00,'2026-11-12 12:41:46',NULL);
/*!40000 ALTER TABLE `obra_chapter_openings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `obra_clients`
--

DROP TABLE IF EXISTS `obra_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `obra_clients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `obra_id` int NOT NULL,
  `person_id` int NOT NULL,
  `role` varchar(30) NOT NULL,
  `is_primary` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `obra_id` (`obra_id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `obra_clients_ibfk_1` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`),
  CONSTRAINT `obra_clients_ibfk_2` FOREIGN KEY (`person_id`) REFERENCES `persons` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `obra_clients`
--

LOCK TABLES `obra_clients` WRITE;
/*!40000 ALTER TABLE `obra_clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `obra_clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `obra_daily_attendance`
--

DROP TABLE IF EXISTS `obra_daily_attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `obra_daily_attendance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `obra_id` int NOT NULL,
  `work_date` date NOT NULL,
  `worker_id` int NOT NULL,
  `signed_at` datetime NOT NULL,
  `signature_type` varchar(30) NOT NULL,
  `signature_data` text,
  `recorded_by` int NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `removed_at` datetime DEFAULT NULL,
  `removed_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `obra_id` (`obra_id`),
  KEY `worker_id` (`worker_id`),
  KEY `recorded_by` (`recorded_by`),
  KEY `removed_by` (`removed_by`),
  CONSTRAINT `obra_daily_attendance_ibfk_1` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`),
  CONSTRAINT `obra_daily_attendance_ibfk_2` FOREIGN KEY (`worker_id`) REFERENCES `workers` (`id`),
  CONSTRAINT `obra_daily_attendance_ibfk_3` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`),
  CONSTRAINT `obra_daily_attendance_ibfk_4` FOREIGN KEY (`removed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `obra_daily_attendance`
--

LOCK TABLES `obra_daily_attendance` WRITE;
/*!40000 ALTER TABLE `obra_daily_attendance` DISABLE KEYS */;
INSERT INTO `obra_daily_attendance` VALUES (1,2,'2026-10-22',1,'2026-10-22 15:57:01','acknowledgment','Registrado por administrador en obra',2,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','2026-10-22 15:57:01',NULL,NULL),(2,3,'2026-10-26',7,'2026-10-26 15:29:30','acknowledgment','Registrado por administrador en obra',2,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','2026-10-26 15:29:29',NULL,NULL),(3,3,'2026-10-26',5,'2026-10-26 15:29:36','acknowledgment','Registrado por administrador en obra',2,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','2026-10-26 15:29:35',NULL,NULL),(4,3,'2026-10-26',4,'2026-10-26 15:29:38','acknowledgment','Registrado por administrador en obra',2,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','2026-10-26 15:29:38',NULL,NULL),(5,3,'2026-10-26',3,'2026-10-26 15:29:41','acknowledgment','Registrado por administrador en obra',2,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','2026-10-26 15:29:40',NULL,NULL),(6,3,'2026-10-26',2,'2026-10-26 15:29:43','acknowledgment','Registrado por administrador en obra',2,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','2026-10-26 15:29:43',NULL,NULL),(7,3,'2026-10-26',1,'2026-10-26 15:29:45','acknowledgment','Registrado por administrador en obra',2,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','2026-10-26 15:29:44',NULL,NULL),(8,5,'2026-11-13',9,'2026-11-13 17:00:37','acknowledgment','Registrado por administrador en obra',2,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-13 17:00:37',NULL,NULL),(9,5,'2026-11-14',16,'2026-11-14 10:07:34','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:33',NULL,NULL),(10,5,'2026-11-14',19,'2026-11-14 10:07:40','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:39',NULL,NULL),(11,5,'2026-11-14',18,'2026-11-14 10:07:43','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:43',NULL,NULL),(12,5,'2026-11-14',17,'2026-11-14 10:07:47','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:46',NULL,NULL),(13,5,'2026-11-14',10,'2026-11-14 10:07:56','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:55',NULL,NULL);
/*!40000 ALTER TABLE `obra_daily_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `obra_photos`
--

DROP TABLE IF EXISTS `obra_photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `obra_photos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `obra_id` int NOT NULL,
  `file_url` varchar(500) NOT NULL,
  `description` text NOT NULL,
  `uploaded_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `fk_obra_photos_uploaded_by` (`uploaded_by`),
  KEY `ix_obra_photos_uuid` (`uuid`),
  KEY `ix_obra_photos_obra_id` (`obra_id`),
  CONSTRAINT `fk_obra_photos_obra_id` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`),
  CONSTRAINT `fk_obra_photos_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `obra_photos`
--

LOCK TABLES `obra_photos` WRITE;
/*!40000 ALTER TABLE `obra_photos` DISABLE KEYS */;
INSERT INTO `obra_photos` VALUES (1,'871fe3d3-11b6-4bf6-a3c2-6d06eb0d3e2a',2,'quasar-tests/obras/2/fotos/34e2e6a3f9f344d583c3b3a0ca0fd090.webp','Probando que esté funcionando la subida de la imagen',1,'2026-10-31 10:18:22'),(2,'dc0a35ea-1979-4a55-9b49-c296de2fcd81',3,'quasar-tests/obras/3/fotos/061ecfc46cf342a0b8be413c773399ac.webp','Pañete de fachadas',3,'2026-10-31 11:02:31');
/*!40000 ALTER TABLE `obra_photos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `obra_sale_types`
--

DROP TABLE IF EXISTS `obra_sale_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `obra_sale_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `obra_sale_types`
--

LOCK TABLES `obra_sale_types` WRITE;
/*!40000 ALTER TABLE `obra_sale_types` DISABLE KEYS */;
INSERT INTO `obra_sale_types` VALUES (1,'Por encargo',1),(2,'Post Construcción',1);
/*!40000 ALTER TABLE `obra_sale_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `obra_stage_history`
--

DROP TABLE IF EXISTS `obra_stage_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `obra_stage_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `obra_id` int NOT NULL,
  `stage_id` int NOT NULL,
  `planned_start_date` date DEFAULT NULL,
  `planned_end_date` date DEFAULT NULL,
  `actual_start_date` date DEFAULT NULL,
  `actual_end_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `obra_id` (`obra_id`),
  KEY `stage_id` (`stage_id`),
  CONSTRAINT `obra_stage_history_ibfk_1` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`),
  CONSTRAINT `obra_stage_history_ibfk_2` FOREIGN KEY (`stage_id`) REFERENCES `obra_stages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `obra_stage_history`
--

LOCK TABLES `obra_stage_history` WRITE;
/*!40000 ALTER TABLE `obra_stage_history` DISABLE KEYS */;
INSERT INTO `obra_stage_history` VALUES (1,2,1,NULL,NULL,NULL,NULL,'2026-10-22 15:49:05'),(2,3,4,NULL,NULL,NULL,NULL,'2026-10-26 15:29:02'),(3,4,1,NULL,NULL,NULL,NULL,'2026-11-04 13:22:06'),(4,6,1,NULL,NULL,NULL,NULL,'2026-11-11 15:19:16');
/*!40000 ALTER TABLE `obra_stage_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `obra_stages`
--

DROP TABLE IF EXISTS `obra_stages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `obra_stages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `description` text,
  `display_order` int NOT NULL,
  `weight_percent` decimal(6,2) DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `obra_stages`
--

LOCK TABLES `obra_stages` WRITE;
/*!40000 ALTER TABLE `obra_stages` DISABLE KEYS */;
INSERT INTO `obra_stages` VALUES (1,'Actividades Preliminares',NULL,10,1.00,1),(2,'Estructura',NULL,20,30.00,1),(3,'Instalaciones',NULL,30,10.00,1),(4,'Obra Gris',NULL,40,14.00,1),(5,'Acabados',NULL,50,40.00,1);
/*!40000 ALTER TABLE `obra_stages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `obras`
--

DROP TABLE IF EXISTS `obras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `obras` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `code` varchar(100) DEFAULT NULL,
  `sale_type_id` int NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(150) DEFAULT NULL,
  `neighborhood` varchar(150) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `estimated_end_date` date DEFAULT NULL,
  `actual_end_date` date DEFAULT NULL,
  `current_stage_id` int DEFAULT NULL,
  `status` varchar(30) NOT NULL,
  `cover_image_key` varchar(500) DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `sale_type_id` (`sale_type_id`),
  KEY `current_stage_id` (`current_stage_id`),
  CONSTRAINT `obras_ibfk_1` FOREIGN KEY (`sale_type_id`) REFERENCES `obra_sale_types` (`id`),
  CONSTRAINT `obras_ibfk_2` FOREIGN KEY (`current_stage_id`) REFERENCES `obra_stages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `obras`
--

LOCK TABLES `obras` WRITE;
/*!40000 ALTER TABLE `obras` DISABLE KEYS */;
INSERT INTO `obras` VALUES (1,'nkjnxcz','kxhbdsh',1,'dsdjnjdfs','lljdnsj','sjdnfkjs','2026-10-22','2026-10-22',NULL,NULL,'planning',NULL,2,'2026-10-22 14:28:38','2026-11-04 13:22:19'),(2,'Corozal Armotek','OBR-001',1,'Corozal','Los patios','Corozal','2026-10-22','2027-10-22',NULL,1,'in_progress','quasar-tests/obras/2/cover/3b48dc1fd62847af93acbd6fcd9d2d8b.webp',2,'2026-10-22 15:49:05','2026-11-12 11:32:20'),(3,'Bellagio B-23','OBR-02',1,'Bellagio Deluxe - Lote B-23','Villa del Rosario','Boconó','2026-07-01','2026-12-31',NULL,4,'in_progress','quasar-tests/obras/3/cover/f47d49d96a904ee9b50122e03dac3448.webp',2,'2026-10-26 15:29:02','2026-11-12 11:33:47'),(4,'TRAMONTI L2',NULL,1,'Conjunto tramonti bocono','Villa del rosario','Bocono','2026-11-01',NULL,NULL,1,'in_progress','quasar-tests/obras/4/cover/86ba0293f68d44049d43489ef948b8e8.webp',2,'2026-11-04 13:22:06','2026-11-07 10:37:34'),(5,'L2 TRAMONTI',NULL,1,'Conjunto tramonti','Villa del rosario','Bocono','2026-11-01','2027-05-30',NULL,NULL,'in_progress','quasar-tests/obras/5/cover/08a5d23ece2e4c56980013de84973088.webp',1,'2026-11-07 10:39:26','2026-11-07 10:40:00'),(6,'jnkdjndk',NULL,1,'jdnjnd','jskjs','qww','2026-11-11','2026-11-18',NULL,1,'in_progress',NULL,2,'2026-11-11 15:19:16','2026-11-12 11:32:31'),(7,'BELLAGIO B-23',NULL,1,'Conjunto Bellagio','Villa del rosario','Bocono','2026-07-01','2027-01-30',NULL,NULL,'in_progress','quasar-tests/obras/7/cover/7f9c10eef272434ea9bf4e20642fe4ce.webp',1,'2026-11-12 12:41:45','2026-11-12 12:41:47');
/*!40000 ALTER TABLE `obras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_codes`
--

DROP TABLE IF EXISTS `password_reset_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `code_hash` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `attempts` int NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_password_reset_codes_user_id` (`user_id`),
  CONSTRAINT `fk_password_reset_codes_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_codes`
--

LOCK TABLES `password_reset_codes` WRITE;
/*!40000 ALTER TABLE `password_reset_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `persons`
--

DROP TABLE IF EXISTS `persons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `persons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `document_number` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `document_number` (`document_number`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `persons`
--

LOCK TABLES `persons` WRITE;
/*!40000 ALTER TABLE `persons` DISABLE KEYS */;
INSERT INTO `persons` VALUES (1,'1','Juan David Navarro',NULL,'2026-10-22 14:26:10'),(2,'1090511641','Camilo Meza',NULL,'2026-10-22 15:54:34'),(3,'1093740533','Carlos Peña Pamplona',NULL,'2026-10-22 15:56:46'),(4,'1091967303','Andres Camilo Bautista Fernandez',NULL,'2026-10-26 15:22:40'),(5,'1243339234','Jair guerrero leal',NULL,'2026-10-26 15:23:19'),(6,'1090401986','Arturo Pineda rincón',NULL,'2026-10-26 15:25:17'),(7,'30031091','Jesús Alberto machado García',NULL,'2026-10-26 15:26:23'),(8,'4008897','Henrry jose Andrade sulbaran',NULL,'2026-10-26 15:27:13'),(9,'13457741','Luis Alfonso romero',NULL,'2026-10-26 15:27:48'),(10,'34967687','Junior jose rada castro',NULL,'2026-10-26 15:28:51'),(11,'5534376','Marcos verá sandoval',NULL,'2026-10-26 15:32:17'),(12,'4981178','Ervinson Durán cárdenas',NULL,'2026-10-26 15:33:05'),(13,'1090500749','Luis Carlos Navarro Gallon',NULL,'2026-10-30 13:24:30'),(14,'13690235','German Pineda Rincon',NULL,'2026-11-14 09:54:36'),(15,'5506205','Salvador Ochoa Tellez',NULL,'2026-11-14 09:55:04'),(16,'1090399301','Wilfred Duran Alvarez',NULL,'2026-11-14 09:55:36'),(17,'1090410289','Diosemel Martinez',NULL,'2026-11-14 09:56:55'),(18,'14888778','Jose Luis Parroquia',NULL,'2026-11-14 09:57:31'),(19,'13489733','Braulio Rios',NULL,'2026-11-14 09:58:46'),(20,'7007468','Alexander Peña',NULL,'2026-11-14 09:59:10'),(21,'1005046481','Camilo Abril',NULL,'2026-11-14 09:59:39'),(22,'1094288219','Nelson Enrique',NULL,'2026-11-14 10:00:28'),(23,'5688773','Pastor Hernandez',NULL,'2026-11-14 10:03:03');
/*!40000 ALTER TABLE `persons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refresh_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `jti` varchar(64) NOT NULL,
  `token_hash` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `replaced_by_jti` varchar(64) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `user_agent` varchar(512) DEFAULT NULL,
  `ip_address` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `jti` (`jti`),
  UNIQUE KEY `ix_refresh_tokens_token_hash` (`token_hash`),
  KEY `ix_refresh_tokens_user_id` (`user_id`),
  CONSTRAINT `refresh_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=385 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
INSERT INTO `refresh_tokens` VALUES (1,1,'89507df9-c092-4135-9bac-ac67e9e16c41','a55cbba95224f6f0e47ee241689aa4f5ca0d6850bc9099633c17dae94aeb7361','2026-11-05 19:26:40','2026-10-22 19:27:10','aff1425b-b3d3-4687-b74a-7d342d72d170','2026-10-22 19:26:40','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(2,1,'aff1425b-b3d3-4687-b74a-7d342d72d170','439424ce8aa1b4a69577232d1be0b19ed903154ff2b8aa27b8d9dbeb40b62163','2026-11-05 19:27:10','2026-10-22 19:45:06','c4847f1d-efe4-4b20-a08d-c5a8b0495e61','2026-10-22 19:27:10','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(3,1,'333e9967-b899-46aa-9310-bb0da323defd','272841ebd939bb49586bb81ccf97c18d1971487d5ad9365b2051a5f3f3ae3ac9','2026-11-05 19:43:17','2026-11-08 17:37:34',NULL,'2026-10-22 19:43:17','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(4,1,'8d7f8eac-6d9f-4af9-9997-e0fb0fdadea5','6289471aec5613d445f3f2abfaf37936abe750856d4af39ed4fa0c7a907cd0a3','2026-11-05 19:44:56','2026-10-22 21:17:04','28c53637-7d7b-4278-b092-30b203b9a882','2026-10-22 19:44:56','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(5,1,'c4847f1d-efe4-4b20-a08d-c5a8b0495e61','660d96de6eba5ed95c6aaf7f99070cf519da9acb75486d6363659a131570f4bb','2026-11-05 19:45:06','2026-10-22 20:24:43','391a8761-96db-485f-a377-20c3bf4319a3','2026-10-22 19:45:06','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(6,1,'29e47b6c-a412-446a-a9ad-dc3bb38494c9','184b1e84b39383ba1eac035d9c08b13d1ec07ee23640ccff1c13ccd12fe2d09a','2026-11-05 20:23:06','2026-10-22 20:24:03','3d4dc057-583e-4073-8e25-34012722f9da','2026-10-22 20:23:06','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(7,1,'3d4dc057-583e-4073-8e25-34012722f9da','37fc41717580874812cd911ea4a86bf7815eb6a8f68c57bea684065618c2a0e8','2026-11-05 20:24:03','2026-10-22 20:24:16','1da91474-e747-45ac-b7fe-b8100b1eb164','2026-10-22 20:24:03','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(8,1,'1da91474-e747-45ac-b7fe-b8100b1eb164','aa4e8fd7f240026589439274ef25f14cc322970018f45f2142fd3627b519d24c','2026-11-05 20:24:16','2026-10-22 20:25:50','97def559-0cef-4bb7-8abf-3fc21f438b5f','2026-10-22 20:24:16','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(9,1,'391a8761-96db-485f-a377-20c3bf4319a3','6c0b7533a7c321ce84e5c8a031becf484dd3a813165acb62bbac221d460b9a23','2026-11-05 20:24:43','2026-10-22 20:24:43','de50aa82-0925-45ca-9902-58dc6a38bce0','2026-10-22 20:24:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(10,1,'de50aa82-0925-45ca-9902-58dc6a38bce0','d8bfebc146544cfc5e31d8e433d7aa030c3228d8a6937cb330623db7d51d9e29','2026-11-05 20:24:43','2026-10-22 20:24:53','1ecea439-8c64-4552-9f5b-85b302d889e0','2026-10-22 20:24:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(11,1,'1ecea439-8c64-4552-9f5b-85b302d889e0','4e134f00275e7ccff72a98979cddc5471deeef83b926d9d6d5b0b966bc25c889','2026-11-05 20:24:53','2026-10-22 20:25:17','aec7808e-7d6f-4043-a149-51f66302d14e','2026-10-22 20:24:53','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(12,1,'aec7808e-7d6f-4043-a149-51f66302d14e','8db15d7dc0098c911618167bc7beed901e2cde2a5ff230faa8453b84dfe92a91','2026-11-05 20:25:17','2026-10-22 20:25:19','4c11b838-9261-4a9e-bf7b-dc2bc8a56b37','2026-10-22 20:25:17','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(13,1,'4c11b838-9261-4a9e-bf7b-dc2bc8a56b37','d1efbfa99409a16a50d0f9b6abe25b9fbea63084aac803c93825c3549a06037a','2026-11-05 20:25:19','2026-10-22 20:41:20','863dcd6c-c0cd-4427-994a-b7173c8445ab','2026-10-22 20:25:19','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(14,1,'97def559-0cef-4bb7-8abf-3fc21f438b5f','1b5a4eff0bb09c2561f6d858f77486f6aabe096f8eff4785c7101f6ebe4279b5','2026-11-05 20:25:50','2026-10-22 21:22:44','d9fb860d-6565-42a8-98ce-898982417232','2026-10-22 20:25:50','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(15,1,'863dcd6c-c0cd-4427-994a-b7173c8445ab','dfff71b150e47ef282a6543800f7c7726cf1269588fc0cab4b6e269592ed0f07','2026-11-05 20:41:20','2026-10-22 20:56:41','9d9c8475-6d30-4c6f-85b5-235ce3f0f62a','2026-10-22 20:41:20','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(16,1,'34a33e20-f500-4872-9b79-3979dacb374e','6a2326cab2fd043be9a8b61bcb1f2867237a898666128a90825e9a9059f8bba1','2026-11-05 20:41:21','2026-10-22 20:54:40',NULL,'2026-10-22 20:41:21','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(17,2,'f7992914-bf92-4af3-ad7e-175e8841bdd1','73e5e2855c7ff81fc73715632855308ba4b6e5fae00e60a3f958b367a1fe7e72','2026-11-05 20:54:55','2026-10-22 21:05:40',NULL,'2026-10-22 20:54:55','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(18,1,'9d9c8475-6d30-4c6f-85b5-235ce3f0f62a','03ceadeddad5a484a509d977ff4528b310ebbd7fbaf82bb48f867f0f01080043','2026-11-05 20:56:41','2026-10-22 21:12:41','a6564719-3951-4cfa-bd4f-6c4111415a9d','2026-10-22 20:56:41','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(19,1,'c03cada9-68bf-4ae0-885b-1c0893c2c411','1b5228c87de4f0ef1ae20740429ae26ca99a67cd6f0227e97f25447ce6579fa4','2026-11-05 21:05:51','2026-10-22 21:09:05',NULL,'2026-10-22 21:05:51','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(20,2,'dd3004ed-57cd-4e40-b715-eb97eab36f54','d589c8540da6bbfcf3811fba698e57b8febb82a2cbcc876447d7e5ac76be4f49','2026-11-05 21:09:17','2026-10-22 21:14:14',NULL,'2026-10-22 21:09:17','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(21,1,'a6564719-3951-4cfa-bd4f-6c4111415a9d','f29d6fe67fbc01541ea8565a98516713bf456c371801e4ded1cf6c52490e0cc5','2026-11-05 21:12:41','2026-10-23 00:17:46','12f4901a-4ee1-44f7-ac6b-46347688212d','2026-10-22 21:12:41','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(22,1,'7535b17c-733b-43a2-b96a-dd466dc3bd2f','32d5bde860cd29734808c892674d2ed587c84e0b4876c6f9cb263c6aa102f3b2','2026-11-05 21:14:30','2026-10-22 21:15:38','9528f88d-4007-453a-a9f6-33ec3598a9ef','2026-10-22 21:14:30','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(23,1,'9528f88d-4007-453a-a9f6-33ec3598a9ef','9f033c666b6ebea07cdce34f3ba8d8e212077e29f1d1d94401e9a9c1bd7a14ef','2026-11-05 21:15:38','2026-10-22 21:15:39','8263cba6-617b-4f57-a382-71f6d30e501a','2026-10-22 21:15:38','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(24,1,'8263cba6-617b-4f57-a382-71f6d30e501a','dab462f29ccf286d99defc0570972b2ad0fba1dc494fdb09a4a01084bc0dbb71','2026-11-05 21:15:39','2026-10-22 21:30:57','e33e8d43-e38b-4f49-862f-9fca453ee3db','2026-10-22 21:15:39','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(25,1,'28c53637-7d7b-4278-b092-30b203b9a882','6331d306b71394829cf9c8a6d916a4d6ebea041076c9f0b567d6d11c6a26253e','2026-11-05 21:17:04','2026-10-22 21:32:36','39b414d5-6204-4810-a341-478e7ceb5d58','2026-10-22 21:17:04','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(26,1,'d9fb860d-6565-42a8-98ce-898982417232','53bd326adb01a34db51d35ac487cdcb2a738d021245d42d8eef4799b686db78c','2026-11-05 21:22:44','2026-10-22 21:22:49','b348d7ab-547e-490e-b9c6-d414af412c39','2026-10-22 21:22:44','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(27,1,'b348d7ab-547e-490e-b9c6-d414af412c39','b64709bca91f85f2d34ba035125651186de2c9d5a9e3bb6e495852786607582e','2026-11-05 21:22:49','2026-10-22 21:22:54','a99ec431-4fa5-430e-be89-44b437dd487f','2026-10-22 21:22:49','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(28,1,'a99ec431-4fa5-430e-be89-44b437dd487f','16c6a44afbb8d716c2df9b73bfa827b2c0e6d37df2805711ef68ff8c75c61ee1','2026-11-05 21:22:54','2026-10-22 21:23:09','30c34e38-75bf-4c7e-885e-afb23c07b4b4','2026-10-22 21:22:54','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(29,1,'30c34e38-75bf-4c7e-885e-afb23c07b4b4','e688e99ca961d643c1bddac9a5bcc28bd38e9c2035af30d5cfe60c55f4494a1a','2026-11-05 21:23:09','2026-10-22 21:38:48','e88acc84-5482-4784-a915-b9bddff933ce','2026-10-22 21:23:09','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(30,1,'e33e8d43-e38b-4f49-862f-9fca453ee3db','68710229ef5ec62644c4ef2b715fefce2819c477f2faf099d1aa6444c9a46183','2026-11-05 21:30:57','2026-10-22 21:42:19','0fe2bad3-49ac-4027-8c8c-0d17bafb32c3','2026-10-22 21:30:57','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(31,1,'39b414d5-6204-4810-a341-478e7ceb5d58','2dd304cfb91e8920fd157d8b86b94c0c0b1964c1aef0d9212520453fb96b9332','2026-11-05 21:32:36','2026-10-23 02:30:35','8ad7cd78-6349-4380-975b-c43b50d4d78d','2026-10-22 21:32:36','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(32,1,'e88acc84-5482-4784-a915-b9bddff933ce','136705307387988ac9577f877e705aa0a95271b5ba6eacf583458cdfa8ba145d','2026-11-05 21:38:48','2026-10-22 22:44:27','7ad567e5-dead-40a3-a232-844a3e92c492','2026-10-22 21:38:48','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(33,1,'0fe2bad3-49ac-4027-8c8c-0d17bafb32c3','4d80cc85dcf6d1de12f2e8c0330606b10e5162880a025a2553b1b226a083dd64','2026-11-05 21:42:19','2026-10-22 21:42:20','3f05c64c-8727-4196-98bd-edeabb190f5e','2026-10-22 21:42:19','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(34,1,'3f05c64c-8727-4196-98bd-edeabb190f5e','8f9a4d58d0dab72d461596ee1ec9b320c2e0b27bcfe5883b0dd42b717ef3f0e3','2026-11-05 21:42:20','2026-10-22 21:42:27','ad7c1b61-1207-403c-95b7-443d713ba200','2026-10-22 21:42:20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(35,1,'ad7c1b61-1207-403c-95b7-443d713ba200','2b9a5766b7a6027ff3e6b22252e07db363ae9f389ed80d29ef5bdf67b7913b31','2026-11-05 21:42:27','2026-10-23 19:53:19','3977a07f-05cf-410f-96f7-45ce2007515c','2026-10-22 21:42:27','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(36,1,'7ad567e5-dead-40a3-a232-844a3e92c492','5f0c3cd19f039a2d1363e4bc5f09c260929a5820ce8f7fecb4b7c7f89889fc79','2026-11-05 22:44:27','2026-11-08 17:37:34',NULL,'2026-10-22 22:44:27','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(37,1,'12f4901a-4ee1-44f7-ac6b-46347688212d','68376fff5991e983b6748cb6ae6b82d28a56d9eb8c11531b12eb647a915c2948','2026-11-06 00:17:46','2026-10-23 00:17:46','d06ed230-e8e5-4d88-b20e-e4af39e450f6','2026-10-23 00:17:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(38,1,'d06ed230-e8e5-4d88-b20e-e4af39e450f6','2d063b2b83015abcab24e52100f2fd97bf72dda191fe1f1faa4ddad851e34f27','2026-11-06 00:17:46','2026-10-23 00:47:01','780159c6-5918-4d81-9965-9a62360e22dd','2026-10-23 00:17:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(39,1,'780159c6-5918-4d81-9965-9a62360e22dd','8ea4d640e1e2da624b6120b058b98658b035cfedc0b66a66ce59acf76f7ccdcc','2026-11-06 00:47:01','2026-10-23 01:02:27','13a904f9-89d7-4d42-b5cc-e4578f073834','2026-10-23 00:47:01','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(40,1,'13a904f9-89d7-4d42-b5cc-e4578f073834','8e24cf3392fb960632a8b4a00b3b054b00c057f2a72e63e92206b05e1cb3c5c6','2026-11-06 01:02:27','2026-10-23 01:19:23','7303b63e-5adb-4fb9-9c78-99a5ee6f8686','2026-10-23 01:02:27','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(41,1,'7303b63e-5adb-4fb9-9c78-99a5ee6f8686','f5fd3f889299a0466af46198f1371760c8fbfa8bb496dd235457c57397d6c3f9','2026-11-06 01:19:23','2026-10-23 01:57:14','970b8cc2-f14f-4fc3-b65e-11405c223777','2026-10-23 01:19:23','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(42,1,'970b8cc2-f14f-4fc3-b65e-11405c223777','f5f81e08bc15d95d3f9c76cf5451ffe6fc14f5772782ce3f49c8555d566c9eb5','2026-11-06 01:57:14','2026-10-23 02:13:46','dab1be97-9dca-416f-8822-a8eb48f26c92','2026-10-23 01:57:14','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(43,1,'dab1be97-9dca-416f-8822-a8eb48f26c92','3113ec69949e2acee10b46ea5a18aafb6ff6e96728873e101f0666224023b65b','2026-11-06 02:13:46','2026-10-23 02:30:19','bd369041-c7ea-41ab-b364-ef797fc51c2d','2026-10-23 02:13:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(44,1,'bd369041-c7ea-41ab-b364-ef797fc51c2d','5d659164344ea504fcb36d2eae7ce4125d535b1d885d18c99969240a022b0ff9','2026-11-06 02:30:19','2026-10-23 02:54:33','2d5f93b7-38ad-4adb-89a8-0836a0d3063a','2026-10-23 02:30:19','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(45,1,'8ad7cd78-6349-4380-975b-c43b50d4d78d','1bdae449875cc0296535e98d4f17aecb4ad9c99b5d40b8a2a5f2e86bd006f6ca','2026-11-06 02:30:35','2026-10-23 02:31:03','a029bc65-0fa1-4f2c-a6d2-57c3d3ebc450','2026-10-23 02:30:35','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(46,1,'a029bc65-0fa1-4f2c-a6d2-57c3d3ebc450','341fe7c0e044987dd674ae03c4fc94e08bdda18669166c33112837a64b1a6897','2026-11-06 02:31:03','2026-10-23 02:31:29','82be6f05-e170-4853-bfd0-9feb1ad9bb7c','2026-10-23 02:31:03','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(47,1,'82be6f05-e170-4853-bfd0-9feb1ad9bb7c','93cf4ea3b0cf68c2cee9a83de524e2009421a9e0b278aebcf12ad16e59c854a8','2026-11-06 02:31:29','2026-10-27 15:28:45','f8e06db1-3eeb-4e26-9cc8-17509f3081d4','2026-10-23 02:31:29','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(48,1,'2d5f93b7-38ad-4adb-89a8-0836a0d3063a','2a2f6a8d7cc8b56f03f20267dc9861505d08b28849f4815363e517ca53bf3f30','2026-11-06 02:54:33','2026-10-23 03:15:19','18b7e6a8-70e6-4530-a000-5ca566d25fa9','2026-10-23 02:54:33','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(49,1,'18b7e6a8-70e6-4530-a000-5ca566d25fa9','884b1669b496166e417f97308d3f7451b585aedcf35f4a9d274610dd19418f64','2026-11-06 03:15:19','2026-10-23 04:15:58','b2b218ea-c830-47ee-ac1e-764452635ef9','2026-10-23 03:15:19','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(50,1,'b2b218ea-c830-47ee-ac1e-764452635ef9','81d270202f60b78dd7d959299b734dc9de209f0d2371138d87b65fac1822467e','2026-11-06 04:15:58','2026-10-23 07:11:42','a9b96714-c29b-4071-8c28-37ea522dd0b0','2026-10-23 04:15:58','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(51,1,'a9b96714-c29b-4071-8c28-37ea522dd0b0','eb769f1c739bffca2d501880a363fa8f6a553de4e34b1ea05a216e5495a473bd','2026-11-06 07:11:42','2026-10-23 12:50:09','d4936262-04a9-45f7-bf75-1fed21d30f87','2026-10-23 07:11:42','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(52,1,'d4936262-04a9-45f7-bf75-1fed21d30f87','363c6534fe049d78abf46d15c840ed25a9908dd0346d69bd1b4687166c908454','2026-11-06 12:50:09','2026-10-23 13:15:21','bdbf92e1-63a2-4bf0-b911-9ef79cdb8d53','2026-10-23 12:50:09','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(53,1,'bdbf92e1-63a2-4bf0-b911-9ef79cdb8d53','0a29b95faa48f9209d6b4f97723e3e3d17faf5554251e047eaa8c1a3cff9e858','2026-11-06 13:15:21','2026-10-23 13:16:06','4c6888e9-abcd-4c3f-a043-60fa9b535433','2026-10-23 13:15:21','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(54,1,'4c6888e9-abcd-4c3f-a043-60fa9b535433','b323651f2b37a0e682129b90c8ea289de7b5867f4410e41322e3df0fa5ff41ec','2026-11-06 13:16:06','2026-10-23 13:16:09','b29a3caa-eb1b-407c-a57d-890732cbface','2026-10-23 13:16:06','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(55,1,'b29a3caa-eb1b-407c-a57d-890732cbface','c1ff37a129b16da968b9009a609e03ac78a538acce57d89f3252f1ddb7329def','2026-11-06 13:16:09','2026-11-04 18:20:20','5dd9c07e-4cea-4680-9af4-4c485c06350e','2026-10-23 13:16:09','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(56,1,'3977a07f-05cf-410f-96f7-45ce2007515c','7e879c991f1599ea5bd4175f6e88a651e1fa5d4514d2d5ad153479374a9d44cf','2026-11-06 19:53:19','2026-10-23 19:53:22',NULL,'2026-10-23 19:53:19','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(57,2,'fd47eb94-cc71-46cb-8f40-c1702f678023','1e934c81dac60178b3e6e85830b4c239975bc2985793be40f932ef7c93f30197','2026-11-09 20:18:32','2026-10-26 20:21:39','3f053704-707d-4113-a355-74b6b1ced2b0','2026-10-26 20:18:32','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(58,2,'db0c9e6b-48e6-4cf8-9392-714c38b206b7','402cacd101d0961f50eded92913d0f2252c4cbe4e29f55975e52803097a5d767','2026-11-09 20:19:44','2026-10-26 20:23:25','a6b9bad4-f9e5-471f-a724-e335e6bf367f','2026-10-26 20:19:44','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(59,2,'3f053704-707d-4113-a355-74b6b1ced2b0','cef3445bd9c27d1962099a22375626a1a4a32b0b0a6ab862070feed4df47f03a','2026-11-09 20:21:39','2026-10-26 21:24:50',NULL,'2026-10-26 20:21:39','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(60,2,'a6b9bad4-f9e5-471f-a724-e335e6bf367f','5cd55a21832563545127015d5a6244fafd65536d47a377fa4f95d7454e168259','2026-11-09 20:23:25','2026-10-26 20:33:14','5ba40381-18f5-4e48-89d1-2908f293151b','2026-10-26 20:23:25','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(61,2,'5ba40381-18f5-4e48-89d1-2908f293151b','8cd82ec7d0a06f5f094205b1f7ea79e4f38bb6f2a0404376326843d0227b73cb','2026-11-09 20:33:14','2026-10-26 21:24:50',NULL,'2026-10-26 20:33:14','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36','172.16.1.1'),(62,1,'f8e06db1-3eeb-4e26-9cc8-17509f3081d4','2a5ded33bad06d6b0d11ee2be7b8e3a5ea1b9e99947323c7e10802ae254e7f91','2026-11-10 15:28:45','2026-10-27 16:03:28','5b86587d-00f5-4969-98df-ed8f795a76fb','2026-10-27 15:28:45','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(63,1,'580e3ae6-271d-4287-83f7-a6d0a1077472','e45b1a37aef049cafb0de05735fd600294f9db77c6d809ead908cd801e759e03','2026-11-10 16:02:36','2026-10-27 18:34:38','efbe5fad-e213-4092-8607-cce23f13aa5b','2026-10-27 16:02:36','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(64,1,'5b86587d-00f5-4969-98df-ed8f795a76fb','e8f9026a93b66a8bed06f3d50af78d5f1c47c3417a914e5d45064b1c562e7952','2026-11-10 16:03:28','2026-10-30 18:23:31','34e3426a-df74-4d0e-8486-020dc783334b','2026-10-27 16:03:28','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(65,1,'efbe5fad-e213-4092-8607-cce23f13aa5b','7d3a0b09668096de8421ca1cf634047d76cf1378c4a426fce76d522e36e19391','2026-11-10 18:34:38','2026-11-08 17:37:34',NULL,'2026-10-27 18:34:38','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(66,1,'81c3c356-91fe-419e-9a55-b11d134aa58a','d81c7591e9023e899e1e05ef8c934502f8a46d372675443da93b0da9e78314d8','2026-11-13 18:23:09','2026-10-30 18:24:40',NULL,'2026-10-30 18:23:09','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(67,1,'34e3426a-df74-4d0e-8486-020dc783334b','e90ba09f947efbdf1f87f190682bf1748399a7e0af0c44771e2417715e72b505','2026-11-13 18:23:31','2026-10-31 15:17:39','02d71684-7d48-4147-b404-17e5c402e066','2026-10-30 18:23:31','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(68,3,'b2c91897-a2df-4f31-85d0-690c1b2ddee5','cbb8db984f21dbdb4bb0b5ee98069c49880930373773e9ee3f60577dcb7da02a','2026-11-13 18:24:55','2026-10-30 18:25:33',NULL,'2026-10-30 18:24:55','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(69,3,'b04b20b2-6780-4a8b-a0af-e415b1383669','cf4e35357bf9e453e597881526ad88c505a7d96781034bedfe44565ab09c856e','2026-11-13 18:51:07','2026-10-30 18:52:03',NULL,'2026-10-30 18:51:07','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(70,3,'d0ed9c7d-c7fa-4de2-82e5-be12f338d4b6','622eae7faa3820387cdbaa70fb8514a9a9e76ca4b965f503f87cd3bb1935e6bd','2026-11-13 23:26:27','2026-10-30 23:26:46',NULL,'2026-10-30 23:26:27','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(71,3,'1648a23a-bbf0-4511-88db-7e865a5677a5','5a96c72b6c233dfd21180115155087954164be70a9bcf54725a8adb3b1131795','2026-11-13 23:26:55','2026-10-30 23:36:07','3f00a931-c4fb-4308-84c9-5bdbce554bdb','2026-10-30 23:26:55','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(72,3,'3f00a931-c4fb-4308-84c9-5bdbce554bdb','10bbc44ee529192dda2ecd080b078f9c10af129ba6373e6207989a0e52e59f3d','2026-11-13 23:36:07','2026-10-31 15:54:41','4d9546a6-ad17-4130-9ce9-efb027a1b6b9','2026-10-30 23:36:07','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(73,2,'b995bb4d-8f77-43b8-98db-3a52243ac03f','1c7e8d6551af34a61cfb64e9c4bd32e7cf809523440c91b03c704835d88814fe','2026-11-14 13:52:58','2026-11-01 00:21:28','126232ef-b1d6-4391-8299-e2c5f4e136cb','2026-10-31 13:52:58','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(74,1,'02d71684-7d48-4147-b404-17e5c402e066','7191196d995a39d8f091812189dd59e4f897b99d217ee919fbac190e75093490','2026-11-14 15:17:39','2026-10-31 15:18:41','7e68fef5-0bb6-4513-bfa7-9ec2840a73a7','2026-10-31 15:17:39','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(75,1,'7e68fef5-0bb6-4513-bfa7-9ec2840a73a7','9512cd600fb28b854e6888e753d8454806f6f0ed2dd6d9ba54fda18a83a60d20','2026-11-14 15:18:41','2026-10-31 15:19:20','e0e3ec14-a01d-4b6c-85db-5f9835698dd0','2026-10-31 15:18:41','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(76,1,'e0e3ec14-a01d-4b6c-85db-5f9835698dd0','a96e7aed8228514f46949786ae99eb48b3cb926e2723a52f60f69b42cc82e20a','2026-11-14 15:19:20','2026-11-03 16:28:09','d83d872b-9106-4feb-904b-cbe0b1aa64e8','2026-10-31 15:19:20','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(77,3,'4d9546a6-ad17-4130-9ce9-efb027a1b6b9','b703e01279ed74f02cb91ba2adc9f161c6942163147e161b1a501a328e1ad8c4','2026-11-14 15:54:41','2026-10-31 15:54:57',NULL,'2026-10-31 15:54:41','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(78,3,'ecefb6eb-1cc1-4dde-a852-0ed81ee31844','1ec7d52150c58318b072fad384a50c6c1894790f0619c73bf889295dc6305dd1','2026-11-14 16:00:56','2026-10-31 16:10:10','ca6d1898-ea47-4f32-aa4f-fb8e05e7cff3','2026-10-31 16:00:56','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(79,3,'ca6d1898-ea47-4f32-aa4f-fb8e05e7cff3','be2ba5e0fffe1b7ba1d5f7e14fed9af23b8f87dab2bb8ec4da6e57efff2bc1c8','2026-11-14 16:10:10','2026-10-31 16:42:59','e01439a1-a1c1-4149-b459-1da42e2fb23e','2026-10-31 16:10:10','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(80,3,'e01439a1-a1c1-4149-b459-1da42e2fb23e','33992bbeabe7384cdb59d51315097ea94e04c1fd3920fa5fbf7fdf5cfd40bc58','2026-11-14 16:42:59','2026-10-31 17:24:20','3b7e53b5-40d6-4fd8-8b05-6ef219f99131','2026-10-31 16:42:59','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(81,3,'3b7e53b5-40d6-4fd8-8b05-6ef219f99131','afe4eec836ebe79e7eddc997a8c18b08f469651c99b15219da835309f4b9ac4f','2026-11-14 17:24:20','2026-10-31 17:24:25',NULL,'2026-10-31 17:24:20','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(82,3,'35a8ae13-920d-4400-920b-8a7d547ad1db','352c9428c5da8187d52fdab04cd508fe244d16accecffc5e06799457419149d7','2026-11-14 17:24:49','2026-11-03 18:13:44','6c09d388-7591-46b3-b607-041c7c63d4e5','2026-10-31 17:24:49','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(83,2,'126232ef-b1d6-4391-8299-e2c5f4e136cb','0b47e1a0767c5c42a7e40f4357f76cf60d0176fe15f61667b6fe61687d18ce21','2026-11-15 00:21:28','2026-11-01 15:48:04','085b6ec0-7748-4dba-8d2b-96a531e33077','2026-11-01 00:21:28','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(84,2,'085b6ec0-7748-4dba-8d2b-96a531e33077','e51b96e8d42f7039810bf68c42425743e066b429aacef736ea1ed10e0f68fe6b','2026-11-15 15:48:04','2026-11-14 14:49:51','291c29cd-b4cd-400d-9b9a-7b113d05193e','2026-11-01 15:48:05','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(85,1,'d83d872b-9106-4feb-904b-cbe0b1aa64e8','f57179fc088c107417578af828f1ecde9754a5ca7ac7193e662222378ece93f8','2026-11-17 16:28:09','2026-11-03 18:11:49','199dcf70-b917-40b7-b353-7a25139071e7','2026-11-03 16:28:09','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(86,1,'199dcf70-b917-40b7-b353-7a25139071e7','ebdb245fd94c0a90de063832b10e184b653f62eb899323449a2c823bbe977a1f','2026-11-17 18:11:49','2026-11-04 18:24:27','d6726e92-dadd-4f0f-8b9c-4c3c145d5df7','2026-11-03 18:11:49','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(87,3,'6c09d388-7591-46b3-b607-041c7c63d4e5','29e0d1b0d6128168b854760c36bacd3e84bc4af874bddac1b5863e17965ed9e1','2026-11-17 18:13:44','2026-11-03 18:15:24',NULL,'2026-11-03 18:13:44','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(88,3,'423da24e-e22c-4e35-bbde-ecf058b71924','c24f7cddfe1268959ec75e71d223384865da3a8f69f39ade516bb02187e92508','2026-11-18 18:17:06','2026-11-04 18:23:39','aec0c248-a4cd-49b7-8e66-cfc6b895f66d','2026-11-04 18:17:06','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(89,1,'5dd9c07e-4cea-4680-9af4-4c485c06350e','081aea9082e444ef67d309a08f3182a5a2ba5bd95d695dd02292f8b8f563ef72','2026-11-18 18:20:20','2026-11-04 18:20:26',NULL,'2026-11-04 18:20:20','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(90,3,'14a1e4ad-899d-4a8a-87f6-0d27e8ef616d','2f2bc3308c4800c632f0a92855522f9f83cb7cdc7912d569d08e255dd2c60849','2026-11-18 18:20:41','2026-11-04 18:30:48','24c47554-a69b-4c23-a476-ce5f22fb67a3','2026-11-04 18:20:41','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(91,3,'aec0c248-a4cd-49b7-8e66-cfc6b895f66d','8a44371475b60193e930a2fef892911fdaebaae71695be473801cd0abe6f6f4c','2026-11-18 18:23:39','2026-11-04 19:19:09','1e7b83c9-10fa-49c4-9511-1f474d65e913','2026-11-04 18:23:39','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(92,1,'d6726e92-dadd-4f0f-8b9c-4c3c145d5df7','d7b6724a770d3c0789118505e4a29d5936413dac048f0e971a1031b34b1a442f','2026-11-18 18:24:27','2026-11-04 18:43:22','440d8375-a0e2-4440-910f-62657f871413','2026-11-04 18:24:27','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(93,3,'24c47554-a69b-4c23-a476-ce5f22fb67a3','8f4a7e00413be319a66729c47bdbfe2414a9705be177d20b265a0a9dd7286842','2026-11-18 18:30:48','2026-11-04 18:30:50','99e95c0f-87b5-4af3-b359-83f008bbad0f','2026-11-04 18:30:48','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(94,3,'99e95c0f-87b5-4af3-b359-83f008bbad0f','ee8cb2b86b21e95b26659e539988e73f4618e72bbef8b3bd8eb733c3a364ad2b','2026-11-18 18:30:50','2026-11-04 18:45:51','6d3d0207-d63b-45cd-97fc-21134c683aee','2026-11-04 18:30:50','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(95,1,'440d8375-a0e2-4440-910f-62657f871413','323167b5cf03f8e4d9a431cb57f5d3f1d1aea779d2b3c946626bc61a6cec4220','2026-11-18 18:43:22','2026-11-04 19:13:49','bfc8ccc5-7085-4972-85e8-35a84a08b653','2026-11-04 18:43:22','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(96,3,'6d3d0207-d63b-45cd-97fc-21134c683aee','77073c26f8dea9d7c17fa2e67da7e8bd95a9136b8e61363720765d8f2713fa03','2026-11-18 18:45:51','2026-11-04 19:01:50','e781a19c-5151-4c55-be68-6abe3ae31207','2026-11-04 18:45:51','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(97,3,'e781a19c-5151-4c55-be68-6abe3ae31207','b470de81db6aefc118523532dc4c672526521d4b4f4fdb8012939ee5b7ac856f','2026-11-18 19:01:50','2026-11-04 19:17:05','a1a266ac-b089-4324-969c-23f7c44073be','2026-11-04 19:01:50','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(98,1,'bfc8ccc5-7085-4972-85e8-35a84a08b653','ae72e83ac72652a43110f7a4aa7d5bfa4144c48e57a88c433498ebee01b79553','2026-11-18 19:13:49','2026-11-05 17:17:43','e9d38297-eac7-4362-a1b9-9ac011a9c441','2026-11-04 19:13:49','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(99,3,'a1a266ac-b089-4324-969c-23f7c44073be','b6c19d3109f78271bb7d5e5de9ae4d0be61e9795aea221d1b9dfd67cdb206146','2026-11-18 19:17:05','2026-11-04 19:32:50','2a8f1189-a92a-480a-8061-9c3aa59b010c','2026-11-04 19:17:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(100,3,'1e7b83c9-10fa-49c4-9511-1f474d65e913','b687e7ea00547bc5b9cd264302a804253959860a1b8354fcab4e3f9f3f5fb7fc','2026-11-18 19:19:09','2026-11-04 19:19:58',NULL,'2026-11-04 19:19:09','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(101,3,'2a8f1189-a92a-480a-8061-9c3aa59b010c','cbc7c6dcd84ccde592674567f3068fda3980aa584dacd0c7c9c82deae0241d99','2026-11-18 19:32:50','2026-11-04 19:48:05','f4129306-0edc-4a8c-8da6-9a4aa2bd4ebe','2026-11-04 19:32:50','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(102,3,'f4129306-0edc-4a8c-8da6-9a4aa2bd4ebe','a0e8f23d6b033c8f5ca299b43f0082d0bc555d8ea9a64fea34f253044c110ac1','2026-11-18 19:48:05','2026-11-04 20:04:05','e017c559-3399-4978-8c85-6753ede9c918','2026-11-04 19:48:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(103,3,'e017c559-3399-4978-8c85-6753ede9c918','db39d147a0bb6fa30547147dc527b774c1eb2402c90362373957942dbfe74481','2026-11-18 20:04:05','2026-11-04 20:20:05','104eab97-a03c-4a30-a6f4-4f055c311fb4','2026-11-04 20:04:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(104,3,'104eab97-a03c-4a30-a6f4-4f055c311fb4','5f96530ab8c053e43e36cfd111839cc01e4e9d1c3274c11eea51d57c7ff8603e','2026-11-18 20:20:05','2026-11-04 20:36:05','d6c2864a-5bad-4e01-8719-7388458a5ede','2026-11-04 20:20:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(105,3,'d6c2864a-5bad-4e01-8719-7388458a5ede','33261fd3376aa6e9be890ac1359961d8c052472036a44d9c31dc45135529947e','2026-11-18 20:36:05','2026-11-04 20:52:05','b53d3d15-332a-4ee8-9949-2542d44e3186','2026-11-04 20:36:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(106,3,'b53d3d15-332a-4ee8-9949-2542d44e3186','323e49980f12a137d94350018d001869763bebcc1d90454b0798231679938915','2026-11-18 20:52:05','2026-11-04 21:08:05','37b14d1b-8ec7-404e-ac8d-5fb9a9bda31b','2026-11-04 20:52:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(107,3,'37b14d1b-8ec7-404e-ac8d-5fb9a9bda31b','c4610d5cc39f82031c543e1c6d5cc44c315de9057fc99323924b01721eb1ed5b','2026-11-18 21:08:05','2026-11-04 21:24:05','c06752f4-5aaf-4e5b-88ce-00b356b7b3a4','2026-11-04 21:08:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(108,3,'c06752f4-5aaf-4e5b-88ce-00b356b7b3a4','8ba238a85b14714bfaad21c992eeea4715ad0eb55953b18c6650363ca83b7e71','2026-11-18 21:24:05','2026-11-04 21:40:05','44991a6f-7779-4e46-9871-2b32dfa6401c','2026-11-04 21:24:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(109,3,'44991a6f-7779-4e46-9871-2b32dfa6401c','c6c15fd24ccd46cd4629940143dc4f12cc93ac8abd98a0d462bd56a1d4268574','2026-11-18 21:40:05','2026-11-04 21:56:05','2dba2996-c122-4adf-91be-3f4ebbd95a3d','2026-11-04 21:40:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(110,3,'2dba2996-c122-4adf-91be-3f4ebbd95a3d','cc918f5a280a22a28b074924a9f47f45791b1ec4fd32f722216fff261c584a4c','2026-11-18 21:56:05','2026-11-04 22:11:50','b87ba83f-24d5-446e-a801-d3365af7d809','2026-11-04 21:56:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(111,3,'b87ba83f-24d5-446e-a801-d3365af7d809','b0c88564aca0f9f20b5cbe7f8e040b6fb185f7734dc1e105f6fed783f947e677','2026-11-18 22:11:50','2026-11-04 22:27:05','229964c1-8214-4ddb-9582-1ddb100aed5a','2026-11-04 22:11:50','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(112,3,'229964c1-8214-4ddb-9582-1ddb100aed5a','daed8cfa0f94770d22c13b812b1162a5f1f1a160d4627c2856a9e32924d152e0','2026-11-18 22:27:05','2026-11-04 22:43:05','710f5e0d-7d05-4777-9556-a73d2bf9f5d8','2026-11-04 22:27:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(113,3,'710f5e0d-7d05-4777-9556-a73d2bf9f5d8','bdbbc2af1b2cb175953b8a4e65be1cdc4242599afee1cb35817b987713570b15','2026-11-18 22:43:05','2026-11-04 22:59:05','f70eb73e-4b63-4c9e-a52d-59c1ae7ed540','2026-11-04 22:43:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(114,3,'f70eb73e-4b63-4c9e-a52d-59c1ae7ed540','4f873878cee07f1b568e8a9ad28c0e882279bdeb4fab89d80b6ff8ec48e1b938','2026-11-18 22:59:05','2026-11-04 23:15:05','ba5c560b-9be7-4eb9-b3cf-6ee13449480a','2026-11-04 22:59:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(115,3,'ba5c560b-9be7-4eb9-b3cf-6ee13449480a','f57f1ccaeba66a493340cb56c718b781b706854c6371ccf8530bd2ae9b302336','2026-11-18 23:15:05','2026-11-04 23:31:05','144b9150-7b95-4fcd-a5d9-8a1cfea31c44','2026-11-04 23:15:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(116,3,'144b9150-7b95-4fcd-a5d9-8a1cfea31c44','1ddfcf4f98e7900694efa110a6134ef8b3323b79c1e061d7fac74061ea94bb37','2026-11-18 23:31:05','2026-11-04 23:47:05','ff174ac6-ad3d-4c3b-9f28-b52f36bd5c4a','2026-11-04 23:31:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(117,3,'ff174ac6-ad3d-4c3b-9f28-b52f36bd5c4a','8f2f376cd53432a5d7f97f839350efa099bf8e78e2d02510f5c4e7fad8575758','2026-11-18 23:47:05','2026-11-05 00:03:05','b22404da-3e98-4f00-bc18-61413e4449a4','2026-11-04 23:47:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(118,3,'b22404da-3e98-4f00-bc18-61413e4449a4','eadb66f3cc6b14a355461e49c2cb38c8506e61ae697e548b066f2d3c27b48b6e','2026-11-19 00:03:05','2026-11-05 00:04:58','7f5c4d47-3e53-439c-b019-545a80dadd7f','2026-11-05 00:03:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(119,3,'7f5c4d47-3e53-439c-b019-545a80dadd7f','07ea4063ae753b86bd3145957488832af6b922c71bafa49de1bf81f2b28ef93d','2026-11-19 00:04:58','2026-11-05 00:20:05','ec44778e-b75f-4315-829d-2e619e616efc','2026-11-05 00:04:58','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(120,3,'ec44778e-b75f-4315-829d-2e619e616efc','2bf414e6cd2872aa86279189b37e4f24cff1733ba37da5d2a735957e0d54ec0c','2026-11-19 00:20:05','2026-11-05 00:24:56','2e0320a9-58e5-4db8-a631-a249f3f34c39','2026-11-05 00:20:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(121,3,'2e0320a9-58e5-4db8-a631-a249f3f34c39','5ac0954d3d38653c0d4a13e140967a5539ed0af5ff34f5e0d9b4cefd13f66669','2026-11-19 00:24:56','2026-11-05 00:40:05','72cd7ef4-6467-47e8-b6d9-9d101c2db329','2026-11-05 00:24:56','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(122,3,'72cd7ef4-6467-47e8-b6d9-9d101c2db329','66a84745566b6e8f336e379562be625c5355f32da9be6b1cdc4352a0e39f056c','2026-11-19 00:40:05','2026-11-05 00:56:05','4def3242-8884-48d4-818c-bee50f582d04','2026-11-05 00:40:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(123,3,'4def3242-8884-48d4-818c-bee50f582d04','1828056c05b5125b9d2d1b202b13adbb8a933fd0a687ad91a0e10623183069c0','2026-11-19 00:56:05','2026-11-05 01:12:05','6bc74877-a611-4897-9cde-6d81ad4e92e2','2026-11-05 00:56:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(124,3,'6bc74877-a611-4897-9cde-6d81ad4e92e2','fe01aa22a0e52e06c9446566850211fc234f88abe61c51d718a5ac22dc4c4bac','2026-11-19 01:12:05','2026-11-05 01:28:05','253a63f2-97ef-4a94-bcd1-eb4e1260d5f3','2026-11-05 01:12:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(125,3,'253a63f2-97ef-4a94-bcd1-eb4e1260d5f3','14598f8e15ca0815d33bca4e260a60be716286138634c05f739baf7fb1993cf1','2026-11-19 01:28:05','2026-11-05 01:44:05','46eb2c14-0fde-46e2-af51-346cd5839932','2026-11-05 01:28:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(126,3,'46eb2c14-0fde-46e2-af51-346cd5839932','874c08ca13f8c32e82fa3f6bb82e717a9a7d1992df6db1c6891c21490e62b133','2026-11-19 01:44:05','2026-11-05 02:00:05','f2c6b05b-fdbf-4609-a01e-7b2dae31d0f1','2026-11-05 01:44:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(127,3,'f2c6b05b-fdbf-4609-a01e-7b2dae31d0f1','950b6bc8c399585bb44cc4f0eeb6f407889556ef4c57b3c12b7f5b2a83b761b2','2026-11-19 02:00:05','2026-11-05 02:16:05','16b778dd-2106-46ae-bf74-d714f946abc3','2026-11-05 02:00:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(128,3,'16b778dd-2106-46ae-bf74-d714f946abc3','dbc72a4c611c07c415c217429fb36137e250e1cb65650b5554305549b7690bdd','2026-11-19 02:16:05','2026-11-05 02:32:05','a542f35b-71da-4d72-84b2-dcee9298164c','2026-11-05 02:16:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(129,3,'a542f35b-71da-4d72-84b2-dcee9298164c','397f85aae2a9e9075dff6b7063f8ae0ab74fe83c580ea00412fdf8e05c9bbb13','2026-11-19 02:32:05','2026-11-05 02:48:05','6d7b340d-9328-4207-8df5-d5ec14b7a88d','2026-11-05 02:32:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(130,3,'6d7b340d-9328-4207-8df5-d5ec14b7a88d','59a717470b58973959d47fb1494bdc9a931f65b483f5d44bc14e75945ea044c3','2026-11-19 02:48:05','2026-11-05 03:04:05','752bfa28-5310-4a27-a91d-88670dd49576','2026-11-05 02:48:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(131,3,'752bfa28-5310-4a27-a91d-88670dd49576','6890434919c92b819b021a9e801696782c30dee982eb9de2354c9dddd836c14d','2026-11-19 03:04:05','2026-11-05 03:20:05','e938138a-a61f-400a-bae9-2fa9e3c3b0b0','2026-11-05 03:04:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(132,3,'e938138a-a61f-400a-bae9-2fa9e3c3b0b0','d28e00b659909fa2e323fb4af5862d4fcea998e56ff99b0222c8221ff24ffc42','2026-11-19 03:20:05','2026-11-05 03:36:05','6f5db61c-8344-4058-8d3b-29419eb89a3e','2026-11-05 03:20:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(133,3,'6f5db61c-8344-4058-8d3b-29419eb89a3e','43924bbbc4b9287160b73b13a9307b6bc6262d7a8323e2a0e3b402f26423ee17','2026-11-19 03:36:05','2026-11-05 03:52:05','0dafaf20-7124-456c-8e3b-714158ef89f2','2026-11-05 03:36:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(134,3,'0dafaf20-7124-456c-8e3b-714158ef89f2','c3670df804e79d8e05a74e2d9609670847b249791e7f30ada9a8dcb031989e2b','2026-11-19 03:52:05','2026-11-05 04:09:33','4a7203c1-e0ee-4285-b692-c6f3ae9c7eaa','2026-11-05 03:52:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(135,3,'4a7203c1-e0ee-4285-b692-c6f3ae9c7eaa','3e48d5e1ffc63c89640cf8b3dac38515631cdbce96da081e6b1d233792d963a7','2026-11-19 04:09:33','2026-11-05 07:34:16','7ee70efd-9d90-4792-a066-c53db0a1695e','2026-11-05 04:09:33','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(136,3,'cf401016-c892-48ee-aa75-86fe10078378','60739847c098445530ffe613bbf3b4391227c42bd06721eda4a0855ba05a2248','2026-11-19 04:45:22','2026-11-05 05:00:37','cb675a04-4b7f-421f-b787-8e15e48baa0f','2026-11-05 04:45:22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(137,3,'cb675a04-4b7f-421f-b787-8e15e48baa0f','2918f35fcec2f2a9568e5ee5ff336b4cc3cfc8d6aeaba41851480c1d1954db7c','2026-11-19 05:00:37','2026-11-05 05:00:46',NULL,'2026-11-05 05:00:37','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(138,3,'7ee70efd-9d90-4792-a066-c53db0a1695e','a827a7b9f7424429ea3ab2b335b93de8480ba470f6f8fd17aef9e52f3d1010ee','2026-11-19 07:34:16','2026-11-05 12:12:55','132f4a2e-76f2-4603-802f-0a2cafb616c8','2026-11-05 07:34:16','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(139,3,'132f4a2e-76f2-4603-802f-0a2cafb616c8','1cafccf732308755f74b2bee07aaa2fab4437bf14737c42979c23d159a68cc61','2026-11-19 12:12:55','2026-11-05 12:31:49','de602cc4-6f30-4c8c-a6c2-e41535d17540','2026-11-05 12:12:55','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(140,3,'de602cc4-6f30-4c8c-a6c2-e41535d17540','0197d74ddd242dca198ce2159f97450664193ed8f96cd1c328f8405fca44084f','2026-11-19 12:31:49','2026-11-05 12:54:01','d5b3f594-4f49-4753-ac2c-16da905013a3','2026-11-05 12:31:49','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(141,3,'d5b3f594-4f49-4753-ac2c-16da905013a3','dd5ea6c2c0ba58ad57b14c6c8cc503e0a8e654dd4d7adb350180863cda44daaf','2026-11-19 12:54:01','2026-11-05 13:17:16','f197334f-4862-4745-a244-80d6439df549','2026-11-05 12:54:01','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(142,3,'f197334f-4862-4745-a244-80d6439df549','a66d4c1491c71e1303fb4ab509f4800490d01c6f3e43d82a8f185bc3a14cd03c','2026-11-19 13:17:16','2026-11-05 13:32:24','dea2661d-88cb-467b-ac96-36c16f08f413','2026-11-05 13:17:16','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(143,3,'dea2661d-88cb-467b-ac96-36c16f08f413','9ccced67bedac8c3a84edfc9ff3ec69ebbcbded2c49e031ece531c9cd8755b1c','2026-11-19 13:32:24','2026-11-05 13:55:24','f227002f-99b9-4c21-9aac-39bcbaca96ec','2026-11-05 13:32:24','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(144,3,'f227002f-99b9-4c21-9aac-39bcbaca96ec','6a71c4c2e791d50159c921554486d410d0ca8de90159eb157e0e4b9094c4c3d4','2026-11-19 13:55:24','2026-11-05 14:16:03','06b9c6e0-847b-4994-98e5-fdf046b0220e','2026-11-05 13:55:24','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(145,3,'06b9c6e0-847b-4994-98e5-fdf046b0220e','ff87ec96259ff61bd504d94d65d7630fdf0f739d03c5c16da61634942b1b85e4','2026-11-19 14:16:03','2026-11-05 14:34:05','53d38a57-59e0-44c8-8064-85179e20d06d','2026-11-05 14:16:03','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(146,3,'53d38a57-59e0-44c8-8064-85179e20d06d','7c1d0688fed8ddc7cd85f19fc79f6d40b73eaaf49933d0598fe04423d885c16d','2026-11-19 14:34:05','2026-11-05 17:12:23','954fbd0c-c7e9-4088-add9-50da940e0fbc','2026-11-05 14:34:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(147,3,'954fbd0c-c7e9-4088-add9-50da940e0fbc','3701c5ab5d6b5be92ce6985753171d84f114d4d5cc94d3a034ce0e8f815a4c55','2026-11-19 17:12:23','2026-11-05 17:16:31','6977bd30-7afa-4e7b-a08f-d72bb07656bf','2026-11-05 17:12:23','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(148,3,'6977bd30-7afa-4e7b-a08f-d72bb07656bf','d21ce84366ba38ac5826cc59b76bfc62fa597714f8ff9aa9734d82b00ae1fd5d','2026-11-19 17:16:31','2026-11-05 17:31:31','1941a4fc-f426-4ad1-965d-e2ca8ed273c8','2026-11-05 17:16:31','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(149,1,'e9d38297-eac7-4362-a1b9-9ac011a9c441','cfe87f584c62f0adf816531a3c631231fea881dcfbc96604b6f4ad0f667a1e82','2026-11-19 17:17:43','2026-11-05 17:59:48','59fd6263-f400-4971-aa20-6675569a4c91','2026-11-05 17:17:43','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(150,3,'1941a4fc-f426-4ad1-965d-e2ca8ed273c8','9b30471892950141db58d80b5278f1da5cb16473a86b3f648475d49c67601924','2026-11-19 17:31:31','2026-11-05 17:31:31','9d5148f7-54d4-477f-a23c-d9aac2558b1b','2026-11-05 17:31:31','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(151,3,'9d5148f7-54d4-477f-a23c-d9aac2558b1b','52a20a6caf369e27e21f150e23480f00d61c8bebb7f55a08a492fa5c81305ff0','2026-11-19 17:31:31','2026-11-05 17:47:31','6f285a7e-e494-4c58-ae79-70c75daf3e0d','2026-11-05 17:31:31','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(152,3,'628311e0-3695-4aae-ad5e-96ab8000b165','ff53f4634b9d5459b4353a3ebf98c7cd08a426f094a75b710e4086ebd01996db','2026-11-19 17:37:58','2026-11-05 17:39:36',NULL,'2026-11-05 17:37:58','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(153,3,'6f285a7e-e494-4c58-ae79-70c75daf3e0d','36ad3c8d974df309241e05bc392a6db3347dcc26b233c24bd191374abad6b885','2026-11-19 17:47:31','2026-11-05 18:03:05','a7f23c9f-0c0c-4611-b019-586bf305d955','2026-11-05 17:47:31','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(154,1,'59fd6263-f400-4971-aa20-6675569a4c91','31022218fa5fd4f236df10303264eda0e6251edc42ae3604b43440e9dca93be8','2026-11-19 17:59:48','2026-11-05 18:07:48','ba9a3db6-ffca-4a02-a30a-45ab288e2bec','2026-11-05 17:59:48','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(155,3,'a7f23c9f-0c0c-4611-b019-586bf305d955','92a48cdb4af8088728883d0e53fa797c53172b8c228794d4e9ad6230b1df9a50','2026-11-19 18:03:05','2026-11-05 18:19:05','37dfe515-70dd-4d87-b633-3ab4c64640c4','2026-11-05 18:03:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(156,3,'55b2a323-7027-4ac0-8de5-b8b9169b7d05','21730200f0ba1d8396e4c342b9b544d372c36bcaf55dfcacaac3ef7f6c1660d3','2026-11-19 18:05:14','2026-11-05 18:10:15',NULL,'2026-11-05 18:05:14','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(157,1,'ba9a3db6-ffca-4a02-a30a-45ab288e2bec','057a8d26cff382f11fac7b5756cf16eb7c95334637ccf98cffee85cfa4d67338','2026-11-19 18:07:48','2026-11-06 18:05:54','ca91d457-6c96-446a-b7d8-d0acc00f45fa','2026-11-05 18:07:48','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(158,3,'707d79f1-716d-4f04-9074-77f3f253f9c5','96cf7dae6cb723355d8645211025a3cc85e15e5b3d13fd723886b43b97aa446c','2026-11-19 18:11:26','2026-11-05 18:12:28',NULL,'2026-11-05 18:11:26','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(159,3,'37dfe515-70dd-4d87-b633-3ab4c64640c4','30d56cffa40311094382129bbe1ae4e7c5dfbd8104d4096107bc25e4a2e8ef3c','2026-11-19 18:19:05','2026-11-05 18:35:05','b08dcfd0-b960-43ff-9cf7-c44f84031a25','2026-11-05 18:19:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(160,3,'b08dcfd0-b960-43ff-9cf7-c44f84031a25','f63b2aa25533118d154c4e815ef921d1000108b4708251a7182543a3a115cfd7','2026-11-19 18:35:05','2026-11-05 18:51:05','20ae7ec0-9a3b-4761-8c99-8a0d3045912a','2026-11-05 18:35:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(161,3,'20ae7ec0-9a3b-4761-8c99-8a0d3045912a','2a1de7c0dbd9b1395568935a49fa035befbcc90ecb82bbfd631b0d86dae563f2','2026-11-19 18:51:05','2026-11-05 19:07:05','02341ca7-be8f-4585-859f-7371ddbc6187','2026-11-05 18:51:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(162,3,'02341ca7-be8f-4585-859f-7371ddbc6187','1bc603836d5c8baec45c886727d37df10d4bba5b5428f1a8899ed8010c007cf6','2026-11-19 19:07:05','2026-11-05 19:23:05','04ab37c4-5ec7-4678-9de4-3fe996a6eff4','2026-11-05 19:07:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(163,3,'04ab37c4-5ec7-4678-9de4-3fe996a6eff4','391ebe705a3bcbce37057c3a19cca02b0aa6067bdbd1c19977d4cc137a73bbc6','2026-11-19 19:23:05','2026-11-05 19:40:20','4c928b83-0288-409b-8c70-8d62f7ea94a4','2026-11-05 19:23:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(164,3,'4c928b83-0288-409b-8c70-8d62f7ea94a4','fe6630f95bb71f4d7821f6fae9916c2328804a94fe9eeda7d551a260ff1b527b','2026-11-19 19:40:20','2026-11-05 19:59:12','9225c61f-1963-4a30-bc68-ba1c1682cea1','2026-11-05 19:40:20','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(165,3,'9225c61f-1963-4a30-bc68-ba1c1682cea1','483ed1cb328bdb6dffc59ea9285d26a6cdc3ff37db32aab71fcaee3f24f35c71','2026-11-19 19:59:12','2026-11-05 20:15:09','c7554e41-10f2-4ec4-a764-3d11ad3fa2c7','2026-11-05 19:59:12','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(166,3,'c7554e41-10f2-4ec4-a764-3d11ad3fa2c7','4a5e672ba67143f0afd7a82d3cccb0feaa492206430ad977f73b37becd62e5d2','2026-11-19 20:15:09','2026-11-05 20:33:07','265b7f76-2fe5-44aa-b7a0-16c4ca667cfb','2026-11-05 20:15:09','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(167,3,'265b7f76-2fe5-44aa-b7a0-16c4ca667cfb','986e1e20864a83741ed389032d36d67219322804bd065e68f677eac39eb6f822','2026-11-19 20:33:07','2026-11-05 20:50:10','5f00754e-5848-4f4b-b80c-5600e8a9113a','2026-11-05 20:33:07','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(168,3,'5f00754e-5848-4f4b-b80c-5600e8a9113a','d6d2c1d3e516f684273ed2542af3a270620e90588fe12f0a34eead38f6a91db2','2026-11-19 20:50:10','2026-11-05 21:19:23','99141112-6343-4109-842d-1a42f4b54cda','2026-11-05 20:50:10','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(169,3,'99141112-6343-4109-842d-1a42f4b54cda','a3c1525db61f2a7387e61d9a7c70a9f0fc2aa3e287a6745a068e77a6111f8697','2026-11-19 21:19:23','2026-11-05 21:59:57','d3fa27a5-b79d-4d58-a673-767da55087d4','2026-11-05 21:19:23','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(170,3,'d3fa27a5-b79d-4d58-a673-767da55087d4','32390198a10166c0f73e28e8ad0d7f7ad6d65ce0c26122b990419588105ba65c','2026-11-19 21:59:57','2026-11-05 22:31:34','6e52a20b-de3a-4ac4-aed1-64c260bbf0aa','2026-11-05 21:59:57','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(171,3,'6e52a20b-de3a-4ac4-aed1-64c260bbf0aa','be939363e28025d63591f14b52fce289e1ea0b2195b80e12abee72c2196a55ff','2026-11-19 22:31:34','2026-11-05 22:49:51','54582bbd-6958-41e4-9991-1a6c4b2b354e','2026-11-05 22:31:34','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(172,3,'54582bbd-6958-41e4-9991-1a6c4b2b354e','1784743c24ee12fe7af43ee2505f81ebdf3970d5de8f5942528805542e48aa1d','2026-11-19 22:49:51','2026-11-05 23:24:45','39addcbc-0de4-4812-9207-6b70df35b01a','2026-11-05 22:49:51','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(173,3,'39addcbc-0de4-4812-9207-6b70df35b01a','4308820a2a18d618fa0bb463d58c71709f30766f459f37565a7866c8b13a2156','2026-11-19 23:24:45','2026-11-06 01:10:11','5da21194-6792-4717-bfa4-fcc30181ca38','2026-11-05 23:24:45','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(174,3,'5da21194-6792-4717-bfa4-fcc30181ca38','040288b118e6e70e4a912aae01cbf1a89311c65ad29bcf5fc2995f3f18e829fd','2026-11-20 01:10:11','2026-11-06 02:19:51','e1856121-3b54-4ba2-ae09-6d4d98d12a9b','2026-11-06 01:10:11','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(175,3,'e1856121-3b54-4ba2-ae09-6d4d98d12a9b','69a68f9ff52495f4afe633c834ec81e31a50b0e054bda487dd98e57dc7c531b3','2026-11-20 02:19:51','2026-11-06 02:48:54','34881953-ef4e-4f15-a029-387b3dbb724b','2026-11-06 02:19:51','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(176,3,'34881953-ef4e-4f15-a029-387b3dbb724b','4045bb350cdf25b74ead9d2ad6871bf1f1b2f2e9160de3dc0021f98567cc0860','2026-11-20 02:48:54','2026-11-06 03:06:13','e8949fb8-bd43-4421-aa11-90f2fce41069','2026-11-06 02:48:54','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(177,3,'e8949fb8-bd43-4421-aa11-90f2fce41069','a0c217dc4ba693feadd0beff508c6aacddec3044117ed4167993d793875cb163','2026-11-20 03:06:13','2026-11-06 03:23:56','17e2896d-ad39-4733-ab69-e5fe14d5eaf3','2026-11-06 03:06:13','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(178,3,'17e2896d-ad39-4733-ab69-e5fe14d5eaf3','8a664f72f30e23ca6de110660d3c4568f4fab16c8be055f0b257a8f70decbb83','2026-11-20 03:23:56','2026-11-06 04:27:59','49dc2e75-2096-4494-811f-1d314ee4c65b','2026-11-06 03:23:56','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(179,3,'49dc2e75-2096-4494-811f-1d314ee4c65b','64b81c0f625779081b2e1de8513f11b929c34606feaa1401f0cbfd18f65c3abb','2026-11-20 04:27:59','2026-11-06 04:43:01','b6f0b39c-3723-4cee-9545-322c415d9971','2026-11-06 04:27:59','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(180,3,'b6f0b39c-3723-4cee-9545-322c415d9971','4f40f260b3cb802fb1d873caf7178a274be547bd33f3b54225e8b959c4940ab0','2026-11-20 04:43:01','2026-11-06 05:00:21','b9441bf8-9755-4587-bf59-0cb4d31e3add','2026-11-06 04:43:01','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(181,3,'b9441bf8-9755-4587-bf59-0cb4d31e3add','ba1ba5f0fbced5214770ecbbe711a3a0c356d64233b017e0b2b87455170ab518','2026-11-20 05:00:21','2026-11-06 06:50:22','39d1c1c1-5254-4cb3-993a-179aff963c0a','2026-11-06 05:00:21','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(182,3,'39d1c1c1-5254-4cb3-993a-179aff963c0a','ceb5d8a2ad467944342e6cf05bdd4c0d1a190bd1f20bf446e2d9450bcdf53c4d','2026-11-20 06:50:22','2026-11-06 12:46:27','65afd7a3-e6a3-4cd0-bfca-188e91fe80b9','2026-11-06 06:50:22','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(183,3,'65afd7a3-e6a3-4cd0-bfca-188e91fe80b9','df1d58cd5aff34c37aff51138816c93956c27d93e876114858316f07fe2d3d4c','2026-11-20 12:46:27','2026-11-06 13:18:28','61db4327-f73c-4a22-896f-ee653ff92661','2026-11-06 12:46:27','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(184,3,'61db4327-f73c-4a22-896f-ee653ff92661','1262af64708fd076f6f9c708e65ee0e6c82178cae04d982357d17a0f554b4b32','2026-11-20 13:18:28','2026-11-06 13:38:48','607879f5-b527-4904-b03c-96d12039a8d5','2026-11-06 13:18:28','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(185,3,'607879f5-b527-4904-b03c-96d12039a8d5','26d54fa222af61f7629c808e354c751994be30779fd51f8c27ebf0d71710d40b','2026-11-20 13:38:48','2026-11-06 13:57:31','c10c8d53-bf8e-41eb-94a3-dc9b740fc397','2026-11-06 13:38:48','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(186,3,'c10c8d53-bf8e-41eb-94a3-dc9b740fc397','bc71c1d80674f5309ab8649dd86f5174b6fed2aac7755452d9e48da8b9964034','2026-11-20 13:57:31','2026-11-06 14:15:21','9f06f067-871b-4cbf-96e1-46828497f0be','2026-11-06 13:57:31','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(187,3,'9f06f067-871b-4cbf-96e1-46828497f0be','8225bf914ea9d354ade924b85f1f08732e6e520440bf0e4f1cb1941e71271b65','2026-11-20 14:15:21','2026-11-06 14:42:47',NULL,'2026-11-06 14:15:21','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(188,1,'ca91d457-6c96-446a-b7d8-d0acc00f45fa','0a7a23ad826940932a334d72b74a813385ddbfb5c7f5ed723914e09b64869ae1','2026-11-20 18:05:54','2026-11-07 01:30:47','78ff2434-185f-4bc0-9fcf-c03a1546cef0','2026-11-06 18:05:54','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(189,1,'97c383ec-3e74-4ca9-bcc7-c7fd0a9cb90e','8a80609aac6e47b74cbd80adaf96c7efa53c595a4748a8e6d48fb05825121aff','2026-11-20 18:10:48','2026-11-06 18:25:49','a62d32dd-6338-4b80-86d5-2697a22a6516','2026-11-06 18:10:48','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(190,1,'a62d32dd-6338-4b80-86d5-2697a22a6516','0e5ceaa4df4ecd5fd388d59d1361b9acaa171ec3afaa8b416f3e9136e9243093','2026-11-20 18:25:49','2026-11-06 18:41:43','bb855616-8057-440f-b54a-6ca90bd08b12','2026-11-06 18:25:49','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(191,1,'bb855616-8057-440f-b54a-6ca90bd08b12','a6dfaf9afbd60017907e165b47df486a6d2ea7a1bedfb9c0f4f4d706341273ff','2026-11-20 18:41:43','2026-11-06 18:57:43','0923ff70-fe7e-4db4-b440-342389f819eb','2026-11-06 18:41:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(192,1,'0923ff70-fe7e-4db4-b440-342389f819eb','3a5a82fd8a356267be3509aca9cbe427302444ebe24a7b94c5702402c59c6693','2026-11-20 18:57:43','2026-11-06 19:13:43','03f7cf88-883d-4fcd-b945-9a159398fde0','2026-11-06 18:57:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(193,1,'03f7cf88-883d-4fcd-b945-9a159398fde0','47308c0499c3c46c56b099df604f05898330b4e18b77491a3dee9f8f4c458e39','2026-11-20 19:13:43','2026-11-06 19:29:43','c1059948-c7e2-4bad-b677-7f3d84df531b','2026-11-06 19:13:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(194,1,'c1059948-c7e2-4bad-b677-7f3d84df531b','54a284a9fb3d19e318a14262500c49cbffbeb23cb87ca16c59cf56afafa03f7a','2026-11-20 19:29:43','2026-11-06 19:45:43','04bf1bb1-3eb3-4d3c-81e2-b0ef4a5a4192','2026-11-06 19:29:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(195,1,'04bf1bb1-3eb3-4d3c-81e2-b0ef4a5a4192','7b0927fc1edf7ab211baf9f490f892b89a0c0d50409d0ca4d012c9fb2bee6645','2026-11-20 19:45:43','2026-11-06 20:01:43','9a13c858-d625-4ae2-ad59-7933a1fcda84','2026-11-06 19:45:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(196,1,'9a13c858-d625-4ae2-ad59-7933a1fcda84','4f39236d6f4b8a1e0989c776953f4a807001e037f81092bff09b5f96f7a137fe','2026-11-20 20:01:43','2026-11-06 20:16:43','00631e8d-050f-4872-97fc-be235b91a7db','2026-11-06 20:01:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(197,1,'00631e8d-050f-4872-97fc-be235b91a7db','f7edde18523933f8ac1d6e894e497b08d8e87eb5c3f34ecedcc7370cf59d17ca','2026-11-20 20:16:43','2026-11-06 20:32:43','9ccdb6b1-c608-4dbb-860d-b372e17917a5','2026-11-06 20:16:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(198,1,'9ccdb6b1-c608-4dbb-860d-b372e17917a5','33e297ea46012b8b63731414701813bcd145737bd21f0cdea851b6427a512799','2026-11-20 20:32:43','2026-11-06 20:48:43','5b3720e9-7a39-4942-9cf7-ac4a57b09d0f','2026-11-06 20:32:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(199,1,'5b3720e9-7a39-4942-9cf7-ac4a57b09d0f','0b8ca740efc6f7429992875a026253277745cf20d6a46e7ec6928802a74a228d','2026-11-20 20:48:43','2026-11-06 21:04:43','d42c66c1-5943-4e66-af48-a5e429941ce7','2026-11-06 20:48:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(200,1,'d42c66c1-5943-4e66-af48-a5e429941ce7','16bf8b57644c3ab432b70e9a13fe6eef0f33cadf8f1f95290afb3bebd01e39f3','2026-11-20 21:04:43','2026-11-06 21:20:43','cf29034d-d5a4-435e-ac06-878fc1aef731','2026-11-06 21:04:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(201,1,'cf29034d-d5a4-435e-ac06-878fc1aef731','f65952444e3b40e4f90c3f6711f25546c1cae2b45165ce9f404d2cccc117e582','2026-11-20 21:20:43','2026-11-06 21:41:24','cf7b5adf-0d6f-4c8e-a543-70913429554e','2026-11-06 21:20:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(202,1,'cf7b5adf-0d6f-4c8e-a543-70913429554e','45641866c7d3d57739f7db742f494196ab59431109a74482063d63dfb127493d','2026-11-20 21:41:24','2026-11-06 22:44:33','65d7a333-baec-40be-9322-4d8841dfb5f2','2026-11-06 21:41:24','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(203,1,'65d7a333-baec-40be-9322-4d8841dfb5f2','35f3255fa7a685c422bff76a02175dc6b4e4d0d6a642b46be5ae510d1a8f28b9','2026-11-20 22:44:33','2026-11-06 23:28:18','4a6ed7c2-26c6-48a1-8639-89282468a852','2026-11-06 22:44:33','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(204,1,'4a6ed7c2-26c6-48a1-8639-89282468a852','d9fba0d70c6b2187dfeffad8c319d0e9aedcb4c05bf8c19514af84abc00ec6d9','2026-11-20 23:28:18','2026-11-07 14:45:31','b5981d27-51e8-4954-84b5-8afc410127e5','2026-11-06 23:28:18','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(205,1,'78ff2434-185f-4bc0-9fcf-c03a1546cef0','b2f2fa12ddf43cf59dc3a7ea75940ca7dddc370e88c41019fac1d8360196b6dd','2026-11-21 01:30:47','2026-11-07 16:08:50','a8908a3c-b128-42a5-be05-5867aaad70df','2026-11-07 01:30:47','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(206,1,'b5981d27-51e8-4954-84b5-8afc410127e5','f5210ee498322e5694a6d147afdfd97e25cac46c1acd8fbf6edbdcd9498f6694','2026-11-21 14:45:31','2026-11-07 15:00:35','9cf89a03-c89d-47cf-bfee-357474451d76','2026-11-07 14:45:31','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(207,1,'9cf89a03-c89d-47cf-bfee-357474451d76','3d1aeecde17556808dc8b481f239bf44569ddb999dd973e962d22cd15d56787f','2026-11-21 15:00:35','2026-11-07 15:16:35','158dd09c-0ac6-4086-be8e-ac61bb8c1e49','2026-11-07 15:00:35','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(208,1,'158dd09c-0ac6-4086-be8e-ac61bb8c1e49','53096312415821824900e5c544b4696637e66f3d6b70bcbca29d7d19262e3fc2','2026-11-21 15:16:35','2026-11-07 15:32:29','34d1e82f-9567-4ee3-9e54-16a34067b78d','2026-11-07 15:16:35','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(209,2,'e59982e3-520a-4002-b225-558d5dd1fe88','62d1567c4f630350d189e65a473368894f9e2d6e4dcc9ff6622ffc17acf13e3d','2026-11-21 15:30:49','2026-11-07 15:45:49','ce8653a6-66ee-4a7c-967d-7f3878f30fb3','2026-11-07 15:30:49','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(210,1,'34d1e82f-9567-4ee3-9e54-16a34067b78d','e36d855a9feae336e7c8347bc691d1e1dff72319d9ef2370cdf120d4e91d8e25','2026-11-21 15:32:29','2026-11-07 15:47:35','6e736658-e95f-40d9-a2f8-77fcb4cef5a8','2026-11-07 15:32:29','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(211,2,'ce8653a6-66ee-4a7c-967d-7f3878f30fb3','068086ec8504b8f5adfa1bc586dc11fd669665531378828a6e1af35c325bef37','2026-11-21 15:45:49','2026-11-07 16:00:51','74f6b2b1-6e6d-474c-8b0f-5d6c74be3cd2','2026-11-07 15:45:49','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(212,1,'6e736658-e95f-40d9-a2f8-77fcb4cef5a8','c36082b4b612724b4c722d55817845506662c43c4f383ba457d98a2676b54126','2026-11-21 15:47:35','2026-11-07 16:03:30','1fb5e78d-13fa-4fc1-b478-8c4c53dbb325','2026-11-07 15:47:35','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(213,2,'74f6b2b1-6e6d-474c-8b0f-5d6c74be3cd2','08f9ed8c3b1e4b9032316fa36022db8588ac4b4134c99dd2e1addb6fd5198a90','2026-11-21 16:00:51','2026-11-07 16:16:51','a5ae6732-413f-44b7-9809-4cc619243a35','2026-11-07 16:00:51','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(214,1,'1fb5e78d-13fa-4fc1-b478-8c4c53dbb325','602738dfbad31259d4f97f8e63767e9fec8fdc8398a2ec6a7ccddbd4e6637ef6','2026-11-21 16:03:30','2026-11-07 16:05:34','a45d053c-1896-4a98-92d4-ea3c67c46e45','2026-11-07 16:03:30','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(215,1,'a45d053c-1896-4a98-92d4-ea3c67c46e45','72d3242a8debaa84716a40cbcc4ffbddefed1dc19da3e2ee31acf421ee849d9b','2026-11-21 16:05:34','2026-11-07 17:14:39','99efd36b-dc6a-4890-ab9f-20659c56b013','2026-11-07 16:05:34','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(216,1,'a8908a3c-b128-42a5-be05-5867aaad70df','dbb5abf210797ce52bb4566148aad73cfda7fc128c18fc6886833d28afee0569','2026-11-21 16:08:50','2026-11-07 16:17:17','3abee967-177c-4649-8d6b-476909190529','2026-11-07 16:08:50','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(217,2,'a5ae6732-413f-44b7-9809-4cc619243a35','b60d30b311117bb602fd0a935efcb208dcc496d402d9bdb939bf0a7f04d45eaf','2026-11-21 16:16:51','2026-11-07 16:25:27','4fc5f74a-2578-49a5-a548-4ab684534b2b','2026-11-07 16:16:51','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(218,1,'3abee967-177c-4649-8d6b-476909190529','a1572e5e2eafaf00d2738cda2238aaa3ffce89d2f3cf8a87919713e739ee75bf','2026-11-21 16:17:17','2026-11-07 16:35:02','4a0a03d6-b00a-4006-8e0d-baf826eb3f89','2026-11-07 16:17:17','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(219,2,'4fc5f74a-2578-49a5-a548-4ab684534b2b','1091dec5ec4307d0c8fdfb668e58816195272f4e6e4766daf586060ae22fc7c3','2026-11-21 16:25:27','2026-11-07 16:40:27','1b6104c6-2865-46ec-b53a-8d2529b4bf93','2026-11-07 16:25:27','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(220,1,'4a0a03d6-b00a-4006-8e0d-baf826eb3f89','0447f95f722bcd877cc35eeb5e0b794ecc65c4cfd2c85f7ffef719c5af91d48a','2026-11-21 16:35:02','2026-11-08 17:37:34',NULL,'2026-11-07 16:35:02','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(221,2,'1b6104c6-2865-46ec-b53a-8d2529b4bf93','a77fa49f62327dc5a6aee60ace8f31f904b9c02ac1217239568b4bab94d80185','2026-11-21 16:40:27','2026-11-07 16:55:51','b02a9ebd-77c6-450c-af8e-96aad48fa4c6','2026-11-07 16:40:27','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(222,2,'b02a9ebd-77c6-450c-af8e-96aad48fa4c6','10266658f1edf48d1415ae390917d573bb12e8609e0e5afa4fd8a3f3b3ee06f2','2026-11-21 16:55:51','2026-11-07 17:08:38',NULL,'2026-11-07 16:55:51','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(223,1,'99efd36b-dc6a-4890-ab9f-20659c56b013','5a39a70eb53893206e7f4d6755146e7d29bfd32b54647aaa18282d0ce6bb7755','2026-11-21 17:14:39','2026-11-07 18:02:52','551e0406-dac2-46c5-9129-9e1c35e4b737','2026-11-07 17:14:39','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(224,1,'551e0406-dac2-46c5-9129-9e1c35e4b737','ea54a431bc44e4233086945a7ad8bfdc797d06b176c7d51df996564db5c4e987','2026-11-21 18:02:52','2026-11-07 19:28:02','1a75e5e0-fad1-4a07-b043-356f95836fb3','2026-11-07 18:02:52','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(225,1,'1a75e5e0-fad1-4a07-b043-356f95836fb3','7023d67a8955310b295626367143a986304e3b245ff63c0dbe6e5e7c9f41c93c','2026-11-21 19:28:02','2026-11-07 20:17:38','8acf8910-fe4f-4ce3-a11f-bd762fb027e8','2026-11-07 19:28:02','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(226,1,'8acf8910-fe4f-4ce3-a11f-bd762fb027e8','4335cd9959a643669eb76817c25fbf91ae6f45306f57546e5c7a05dd3e6afdd6','2026-11-21 20:17:38','2026-11-07 20:33:02','c6b1b26c-1dd0-4f95-ba2d-0ef9bc31a28e','2026-11-07 20:17:38','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(227,1,'c6b1b26c-1dd0-4f95-ba2d-0ef9bc31a28e','dda287698762d922cd3b8325b49c6f06a82eb8bafc2edf02d685b9f0854b353f','2026-11-21 20:33:02','2026-11-07 20:53:52','dceb3d0b-d7a3-4143-905e-d32fa97536bb','2026-11-07 20:33:02','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(228,1,'dceb3d0b-d7a3-4143-905e-d32fa97536bb','9a7f9f620a21e117be93d8290a99f01d037cd47f68fd561cb508413e3d5d10f3','2026-11-21 20:53:52','2026-11-07 21:22:17','bfbc28a2-f21d-4ab2-86fa-87690eb590e2','2026-11-07 20:53:52','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(229,1,'bfbc28a2-f21d-4ab2-86fa-87690eb590e2','9a15cabcabda523e5a2adac3077ed076a100bca27fb8534d2904a6f76118c1d3','2026-11-21 21:22:17','2026-11-07 22:00:21','2590fb10-3819-4711-8b60-2fcc8739fb39','2026-11-07 21:22:17','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(230,1,'2590fb10-3819-4711-8b60-2fcc8739fb39','67a88f05fe43ae0dc741e40ad6cf62db2adc8252d33213ef27b042c40f1ae474','2026-11-21 22:00:21','2026-11-07 23:19:43','4fe85d8a-ae62-4177-84b9-81c58ce64050','2026-11-07 22:00:21','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(231,1,'4fe85d8a-ae62-4177-84b9-81c58ce64050','56028a7b73a72a48eea90624202e10ebcde94e2e931f19f0c2aa0a9f8ca4ed4c','2026-11-21 23:19:43','2026-11-08 00:06:45','e2b91af5-16cd-4b31-b59c-afb3d6f4cb11','2026-11-07 23:19:43','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(232,1,'e2b91af5-16cd-4b31-b59c-afb3d6f4cb11','7e2145ea57d8e6c94234a7fcefe83817028bfd062878e1836f75c3b0941b410f','2026-11-22 00:06:45','2026-11-08 02:24:33','eb930fa9-3b72-41d6-901b-47b8c7c66d86','2026-11-08 00:06:45','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(233,1,'eb930fa9-3b72-41d6-901b-47b8c7c66d86','bcea3e9c1992aed0293c29f8004a49a1d16fdcb50454af40e8544bfd70c05a6f','2026-11-22 02:24:33','2026-11-08 04:40:31','e4ac1200-59ff-4ef7-b1a7-7196cd375cf5','2026-11-08 02:24:33','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(234,1,'e4ac1200-59ff-4ef7-b1a7-7196cd375cf5','ac7458c311e735fbd3f6d54646d93d0be5741e9d1910fe05c35278a09e482f99','2026-11-22 04:40:31','2026-11-08 05:18:11','317cbb36-3095-4b9b-80ec-19f0521dbe1e','2026-11-08 04:40:31','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(235,1,'317cbb36-3095-4b9b-80ec-19f0521dbe1e','21d00c3e0ea28b1a76ed0375aba3ab29520d8e02b8ce7176b8f9bbde46f94bbe','2026-11-22 05:18:11','2026-11-08 05:34:05','6ea25150-494f-4f2d-be1d-c3d0cb44ef41','2026-11-08 05:18:11','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(236,1,'6ea25150-494f-4f2d-be1d-c3d0cb44ef41','0d6e74b2eb7831ad45318bd5f85680eb968e7336b56e3a28ef5763f5e6c67578','2026-11-22 05:34:05','2026-11-08 14:24:18','fde46a9d-6beb-45fa-9c04-60278b5afa89','2026-11-08 05:34:05','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(237,1,'fde46a9d-6beb-45fa-9c04-60278b5afa89','c6f0f6ee2cb386ac9c65d09b89097fcc3054378fcd4bb30004693aa0b95b9818','2026-11-22 14:24:18','2026-11-08 17:37:34',NULL,'2026-11-08 14:24:18','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(238,3,'e1ee9bdc-9532-437e-8b46-d5537321a677','0d71f5484ec004f573c7c94be678e240f2db76ac5635c6255ca40a3d61aa5732','2026-11-22 19:40:54','2026-11-10 14:51:03','d79aa2ce-e0f2-499e-bd6f-fbdeabc130b6','2026-11-08 19:40:54','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(239,1,'3542ab9d-4073-44ba-ac39-1908cf9d5fb6','88227bb2581f8db590abaddbeb3b4e4089c071a7b4731ac489cf98e0e4c3e202','2026-11-23 14:12:47','2026-11-09 14:27:48','7e080836-ff7c-428c-817a-f49709961e98','2026-11-09 14:12:47','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(240,1,'7e080836-ff7c-428c-817a-f49709961e98','7885db73033ceef9687a04c89c93a61b5a243d018f7089a495227e322a77978d','2026-11-23 14:27:48','2026-11-09 14:43:46','e19ed1a5-c06e-4040-8b6c-2d365cd57068','2026-11-09 14:27:49','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(241,1,'e19ed1a5-c06e-4040-8b6c-2d365cd57068','a6e13d2145e82ecd89e9b43854cc2f7057426a8dd7fc57aac7d7eda21236d6b9','2026-11-23 14:43:46','2026-11-09 15:00:46','dc5a344a-ee43-4201-8c31-a7abb30ab1d4','2026-11-09 14:43:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(242,1,'dc5a344a-ee43-4201-8c31-a7abb30ab1d4','31648c4127e3ae5df920e2196bd4c9afb7fbf4ab4f25e87581955f0f2ddf67f3','2026-11-23 15:00:46','2026-11-09 15:16:46','08ff7677-ead8-4fbf-9059-fd871222bbd0','2026-11-09 15:00:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(243,1,'08ff7677-ead8-4fbf-9059-fd871222bbd0','54a5a1922cd1191b14ad3d1c963e5e00e73c396d6f9b5ad9706eb6b72fb354dc','2026-11-23 15:16:46','2026-11-09 15:32:46','f226f0fa-fd56-440f-beb0-9bc9c943e325','2026-11-09 15:16:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(244,1,'f226f0fa-fd56-440f-beb0-9bc9c943e325','43c6a0b1ecdf8d09f7a8281d01aff129f12f4e41ae63bb7715409a7c45522e1b','2026-11-23 15:32:46','2026-11-09 15:48:46','04e6628e-b46c-478c-8857-2d0e96739474','2026-11-09 15:32:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(245,1,'04e6628e-b46c-478c-8857-2d0e96739474','71a10bbabd1b2e4a21b836ca292213c6a7aae7514db34db786ba54e580fa59cd','2026-11-23 15:48:46','2026-11-09 16:04:46','35ebe0a7-4a20-45cc-8d12-20f503d1c243','2026-11-09 15:48:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(246,1,'35ebe0a7-4a20-45cc-8d12-20f503d1c243','abe24d06c126db767b5a9b733ce46fcb6d90071fe131a49e49c5e3a5d28e0db9','2026-11-23 16:04:46','2026-11-09 16:21:46','ec825115-7eba-4347-97fa-0e7058aa74b4','2026-11-09 16:04:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(247,1,'ec825115-7eba-4347-97fa-0e7058aa74b4','9944ca6ca351ed5143ebdbe463de01f3c0c3e6e596bb61abe933fd77531b59ac','2026-11-23 16:21:46','2026-11-09 16:37:46','52dc6404-0863-4b33-ba09-15dc1e189da3','2026-11-09 16:21:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(248,1,'52dc6404-0863-4b33-ba09-15dc1e189da3','f1045e609409e17b25a46ad8fdece938c43513fd5493c8548ecbcc983470c1c9','2026-11-23 16:37:46','2026-11-09 16:53:46','1db84697-69d4-48d8-b665-dc3278e11b61','2026-11-09 16:37:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(249,1,'1db84697-69d4-48d8-b665-dc3278e11b61','f424c14dbcfe81d63aff854125c18d2ed95785ea8b29c7ed7b48e9741d02b848','2026-11-23 16:53:46','2026-11-09 17:09:46','59f5fe89-8ccb-4f31-898e-3c3930fc4f33','2026-11-09 16:53:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(250,1,'59f5fe89-8ccb-4f31-898e-3c3930fc4f33','f4f1b37e85137aa61f8f5e5a6481b0e16238373b5a04a3e98f8c2a4cf0812b58','2026-11-23 17:09:46','2026-11-09 17:25:46','e750cace-d345-4ac4-ad7f-68c19068c5ab','2026-11-09 17:09:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(251,1,'e750cace-d345-4ac4-ad7f-68c19068c5ab','78968d4857209ec1f048da6b96f8a4db831a64a3a33f5304ab09478fd163f473','2026-11-23 17:25:46','2026-11-09 17:41:46','2ee70394-fb06-41bf-acbd-2ae3bfec0caf','2026-11-09 17:25:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(252,1,'2ee70394-fb06-41bf-acbd-2ae3bfec0caf','a1e456ea9a0ec5ed376d04d614eca9cc6475d00aabd54d83f3a159cf9049267b','2026-11-23 17:41:46','2026-11-09 17:57:46','929c3000-ddec-4426-9d0f-c6ec63c1f948','2026-11-09 17:41:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(253,1,'929c3000-ddec-4426-9d0f-c6ec63c1f948','e91b38b909643c66a1451b0183e86ad17ce32614590a502324b0ed195ba53df6','2026-11-23 17:57:46','2026-11-09 18:13:46','ad74f5af-cbd1-403b-b5a5-f9df2ed412c2','2026-11-09 17:57:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(254,1,'ad74f5af-cbd1-403b-b5a5-f9df2ed412c2','82d0f4f2f497e0fca48a493753f907127b6b38ea70437621b99fedc13fac710e','2026-11-23 18:13:46','2026-11-09 18:29:46','1942111c-bb36-4034-8a7b-a55b6d24b33f','2026-11-09 18:13:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(255,1,'1942111c-bb36-4034-8a7b-a55b6d24b33f','1cac6c3091422a93f64637d352bd8fa7c316bd25ca95b289f9336480b78de8b8','2026-11-23 18:29:46','2026-11-09 18:45:46','9a0d6ddf-e0c8-4f2c-8c22-afce6711e604','2026-11-09 18:29:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(256,1,'9a0d6ddf-e0c8-4f2c-8c22-afce6711e604','62b7f4080e22bfbfaf5948c85af87d9dc74dcc4d20fa02087ace67ee268ec040','2026-11-23 18:45:46','2026-11-09 19:01:34','92499208-8c80-42c8-a1cc-f86470c0187f','2026-11-09 18:45:46','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(257,1,'92499208-8c80-42c8-a1cc-f86470c0187f','e78be9afe9162b47cbbd1a579dd4d442c4bf587ceb16bf625355d8623e171cb4','2026-11-23 19:01:34','2026-11-09 19:02:49','ac8376a1-ef96-428f-b9ad-0058fa2cb0de','2026-11-09 19:01:34','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(258,1,'ac8376a1-ef96-428f-b9ad-0058fa2cb0de','5addb6540fb4b6e340fa5d650c33d56eceaaf5c701c48e987562c67ce3f8013c','2026-11-23 19:02:49','2026-11-09 19:51:01','d9e16f03-956f-405d-874c-b0392cc99f89','2026-11-09 19:02:49','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(259,1,'d9e16f03-956f-405d-874c-b0392cc99f89','7374622347a45d558e70df5a9b9e4a19dc5f232a079c6b3c1c1564104147b444','2026-11-23 19:51:01','2026-11-09 20:23:53','5c99ce1c-c03d-47f6-b9cd-1b5c19139ea8','2026-11-09 19:51:01','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(260,1,'5c99ce1c-c03d-47f6-b9cd-1b5c19139ea8','7333a078e08c772ee37ba8f3481f42a690f398316ba40761956619e1e9d6c9e5','2026-11-23 20:23:53','2026-11-09 21:02:16',NULL,'2026-11-09 20:23:53','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(261,1,'1a80e758-433b-41e1-98f8-df9190069784','a1c529a67288d8d22967ec659ac1d21f504f0192b9415cb7f190835cb6ea53c1','2026-11-23 21:02:25','2026-11-09 21:48:34',NULL,'2026-11-09 21:02:25','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(262,1,'c73a6607-697a-4bd2-9969-f9e48c12bb65','4ae350f7f11c42669ebebf9b701044a7027fd328064a7b011b5c3a47e2151079','2026-11-23 23:52:19','2026-11-09 23:53:04','41641429-61b7-48e0-b37b-d9e90940662f','2026-11-09 23:52:19','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(263,1,'41641429-61b7-48e0-b37b-d9e90940662f','2092560a8691b99b3e713fb41bb9f599af98fa42499c5ed43de407a6f9275298','2026-11-23 23:53:04','2026-11-10 00:08:04','3686a312-f624-4212-a089-f2c844cae126','2026-11-09 23:53:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(264,1,'3686a312-f624-4212-a089-f2c844cae126','1095e3302ff92290f9ff6243de920676d87499dfe88051cb232c335f06aab3ac','2026-11-24 00:08:04','2026-11-10 00:09:04','3d78040a-ceb7-4788-8049-36c413457a76','2026-11-10 00:08:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(265,1,'3d78040a-ceb7-4788-8049-36c413457a76','bc93ad322442be5f6d91c9764f060b6a9568a51af90eadd6837eef25d06f5509','2026-11-24 00:09:04','2026-11-10 00:24:04','e1f6c250-ea72-4d75-af5a-1babb01ca291','2026-11-10 00:09:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(266,1,'e1f6c250-ea72-4d75-af5a-1babb01ca291','cd39d9fe29286721d89a2f236d8c7ecb10a690464d764792a032261f8e8c1b3d','2026-11-24 00:24:04','2026-11-10 00:25:04','b90d44bb-8284-4fd3-abdd-74323e21d19e','2026-11-10 00:24:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(267,1,'b90d44bb-8284-4fd3-abdd-74323e21d19e','458b2791a494739c006893b95903868bef0dc9a49880f54343c84e2a83fc17ff','2026-11-24 00:25:04','2026-11-10 00:40:04','35d82b20-6cae-4b03-ab77-5a44e093619b','2026-11-10 00:25:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(268,1,'35d82b20-6cae-4b03-ab77-5a44e093619b','62dd10844d208a6f8e0dfcb41d4d2267e421d9cf398baa829bdc75b1d0e55437','2026-11-24 00:40:04','2026-11-10 00:41:04','2f85053d-8fec-4234-8075-ad706ce15b29','2026-11-10 00:40:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(269,1,'2f85053d-8fec-4234-8075-ad706ce15b29','cff0c067cdcd774e80c84dda32d0e44ec791baa94478c96bd7f5ba6cbf262d03','2026-11-24 00:41:04','2026-11-10 00:56:04','fde54e5c-5251-4948-ac67-2b72b869b01c','2026-11-10 00:41:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(270,1,'fde54e5c-5251-4948-ac67-2b72b869b01c','c1c9c9d301e80f80be2b85646b49a0c616bb0b808b7e151ee50ace160071bd24','2026-11-24 00:56:04','2026-11-10 00:57:04','01a12026-9866-4472-9a84-16a03a963e1a','2026-11-10 00:56:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(271,1,'01a12026-9866-4472-9a84-16a03a963e1a','42e185100e491015a0675dc626b572141dff1ea24161a7e03f5561ba4a8930f4','2026-11-24 00:57:04','2026-11-10 01:12:04','46cceadd-d1b4-4f6b-9c6e-c2b7ac889e81','2026-11-10 00:57:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(272,1,'46cceadd-d1b4-4f6b-9c6e-c2b7ac889e81','0c25dbe991bf8e66f49a7a9214854c46e7def2029ea454eb0d1a783586490237','2026-11-24 01:12:04','2026-11-10 01:13:04','1f2f7623-2d9d-47f1-94c3-0744656cc6b2','2026-11-10 01:12:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(273,1,'1f2f7623-2d9d-47f1-94c3-0744656cc6b2','eb6a5588f413139bd96f62507ecd072916d0d4bf9182bfa37cfff16f4a0e5845','2026-11-24 01:13:04','2026-11-10 01:28:04','e9744850-f333-48f1-8ee9-3182f239ea6c','2026-11-10 01:13:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(274,1,'e9744850-f333-48f1-8ee9-3182f239ea6c','9c0657edcc23f0d39a564f35ad279193f74bf8656deb8339a7211ecd38368f59','2026-11-24 01:28:04','2026-11-10 01:30:04','ba722ef9-b749-4991-8fb7-b12d012deb16','2026-11-10 01:28:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(275,1,'ba722ef9-b749-4991-8fb7-b12d012deb16','19167334f2d2c8d838a5564c2995509289f5c668a4376590b20944d601992d08','2026-11-24 01:30:04','2026-11-10 01:44:04','f9725c6d-fae7-46b4-be84-73c5591d2c9a','2026-11-10 01:30:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(276,1,'f9725c6d-fae7-46b4-be84-73c5591d2c9a','5e73acd29be433b9e04eb7941346d86b57327b664f4b3bd3868d9d4e06e76543','2026-11-24 01:44:04','2026-11-10 01:45:33','6fb7bee9-5fcf-453c-a24a-8d137a04253b','2026-11-10 01:44:04','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(277,1,'6fb7bee9-5fcf-453c-a24a-8d137a04253b','055e4599897ad75962005b9b134100797b4138472e0846d0f962297d5faa9e51','2026-11-24 01:45:33','2026-11-10 01:59:06','401f8fae-7cb5-4c5e-bd29-6900c64466f1','2026-11-10 01:45:33','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(278,1,'401f8fae-7cb5-4c5e-bd29-6900c64466f1','3dcf33d3d006572a87f3e2454214cf171c62f9973676f755e221a3f0570715b8','2026-11-24 01:59:06','2026-11-10 02:14:37','51cdafea-fe76-4115-af3b-6c6312320ad7','2026-11-10 01:59:06','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(279,1,'51cdafea-fe76-4115-af3b-6c6312320ad7','46c708918768afd5a1e6e2f320fe06b79ea806e9471c048df81dd861d3a6d036','2026-11-24 02:14:37','2026-11-10 02:30:22','3d154081-db7c-4108-b693-750c0631c176','2026-11-10 02:14:37','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(280,1,'3d154081-db7c-4108-b693-750c0631c176','ffa04443fb3b8473b8e6f5e17e55d783c9b79e9bcc90be10fc42db20a921e0a3','2026-11-24 02:30:22','2026-11-10 02:41:41','ff83a696-1790-4c88-b97e-b90572629089','2026-11-10 02:30:22','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(281,1,'ff83a696-1790-4c88-b97e-b90572629089','74b277e714b32f5ffec0958cecb68c5277fff87c3112943dedea5d403c5e8929','2026-11-24 02:41:41','2026-11-10 03:43:38','d573ad86-76cd-4289-8cad-2ac305d146df','2026-11-10 02:41:41','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(282,1,'d573ad86-76cd-4289-8cad-2ac305d146df','00a4a07a5b2abb1ec4c69ddeb438b70e66eccb37242edfad4caad2fec8cb8a80','2026-11-24 03:43:38','2026-11-10 03:59:06','6f4f70cd-b66d-43b4-bd45-9d3c8783559b','2026-11-10 03:43:38','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(283,1,'6f4f70cd-b66d-43b4-bd45-9d3c8783559b','850ac5b42537845c8c6da25f292cf6369b49ef93d362f3551209ef76b9b7ddda','2026-11-24 03:59:06','2026-11-10 14:17:57',NULL,'2026-11-10 03:59:06','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(284,1,'4afe95b3-2b4a-4e0c-a89d-848c7602e0f5','3f978ab2f1feb1f988c53a0b95a4aef3f69be7d745fc31388ad66da0f82fd427','2026-11-24 14:18:15','2026-11-10 15:04:34','612dcbb6-c78f-405e-9252-2f6b3b9c10a6','2026-11-10 14:18:15','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(285,3,'d79aa2ce-e0f2-499e-bd6f-fbdeabc130b6','c9eeada2aa41f7f96c5ab38d74078b5d4943e2b5aea2988061f59debf2186998','2026-11-24 14:51:03','2026-11-10 14:51:08',NULL,'2026-11-10 14:51:03','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(286,3,'a22ad19f-c11a-4e58-93df-99b14ad77dbd','85cb5f7451347f4245cc057f5a2d4d8ed55741706c736bfeca642acc52c02e0e','2026-11-24 14:54:04','2026-11-10 15:05:38','15e4fa54-f578-4037-8d67-4e7c4dcb1443','2026-11-10 14:54:04','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(287,1,'612dcbb6-c78f-405e-9252-2f6b3b9c10a6','3c1fc99214711434194a61010747b1fe4415330434fa1219136c758a86d3f47f','2026-11-24 15:04:34','2026-11-10 16:07:50','d3e8d374-9372-4461-bbfb-62249dc861b3','2026-11-10 15:04:34','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(288,3,'15e4fa54-f578-4037-8d67-4e7c4dcb1443','a7b8fd9636cd784633c3cb2b7467370d86dd4ff53e64b2df1520cd9c04897e66','2026-11-24 15:05:38','2026-11-10 15:06:48','18f52bdb-a170-4d1c-8175-f8b07c482c66','2026-11-10 15:05:38','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(289,3,'18f52bdb-a170-4d1c-8175-f8b07c482c66','2d502357fd5eea7e985e575c3ca30f34fe12dfc96104cfa4f8402e63d3bd6686','2026-11-24 15:06:48','2026-11-10 15:12:08','503ea96d-1622-4168-90d3-254d0ce3b13f','2026-11-10 15:06:48','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(290,3,'503ea96d-1622-4168-90d3-254d0ce3b13f','c79a6e66528584c6791b2f3735003fd9a8d6cd659eb93587991a735bb6c2fdad','2026-11-24 15:12:08','2026-11-10 15:22:29','e3ecf3af-1631-4c19-9274-4104328fab1d','2026-11-10 15:12:08','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(291,3,'e3ecf3af-1631-4c19-9274-4104328fab1d','e00a15a32daaaea21e35f5a866e70ad33b09d563bfc5c05758b127a3e3c71de4','2026-11-24 15:22:29','2026-11-11 04:35:37','ee25a4f8-2697-4040-b4a9-98447a1106ba','2026-11-10 15:22:29','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(292,1,'d3e8d374-9372-4461-bbfb-62249dc861b3','36a7f5bfb4e7998a10fbf1b898789a96f43eff210b23b88bffed39f3647c4f54','2026-11-24 16:07:50','2026-11-10 16:13:57',NULL,'2026-11-10 16:07:50','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(293,1,'94789447-fa3c-4e65-b9b5-7bf0cb8d77b8','6f058865ebb1cc68413961840be781a76f31814181e30334b06f120e368e0924','2026-11-24 16:15:00','2026-11-10 16:30:50','a651809f-5008-4920-a6fd-6d14c6d6d674','2026-11-10 16:15:00','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(294,1,'a651809f-5008-4920-a6fd-6d14c6d6d674','92139ee80d67275d028b68a648f5b50b32bcb70d263e21ed72f2bb800a3264f7','2026-11-24 16:30:50','2026-11-10 16:44:24',NULL,'2026-11-10 16:30:50','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(295,1,'db9605c3-699c-4c03-a119-7b331d86a877','e93949cef60309bdd89590a9ec90566c4fcdf86d44428e5d15c61c5495534df4','2026-11-24 16:44:33','2026-11-10 16:46:21',NULL,'2026-11-10 16:44:33','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(296,1,'7a6607e3-0af9-4847-9e08-580d9e29afa9','89901f4558eaf26c08d9b332d3ba54952fe8e8666021717ac1ef11c138ed4034','2026-11-24 18:49:32','2026-11-10 18:52:44',NULL,'2026-11-10 18:49:32','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(297,1,'23e60d42-8487-4e8b-a285-1fee105a533c','a6a33f528681fbd76a3221d64191862a5592e519abcb77743ec0de9fa8f429b7','2026-11-24 18:52:54','2026-11-10 19:48:35',NULL,'2026-11-10 18:52:54','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(298,1,'0d396f7c-1d46-4818-8c2e-97773daf266d','ee8d846a2a622649e5fc514d02226f9183e3510ab070d95713fb15b97ce5f908','2026-11-24 20:09:42','2026-11-10 20:11:36',NULL,'2026-11-10 20:09:42','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(299,1,'5cce98ca-4ea9-433c-88b6-586383e52481','869e9c240a79a282470bebcdbdc22dbaefe59d6c6bd1575a02484c5e90467c0f','2026-11-24 21:22:31','2026-11-10 21:24:06',NULL,'2026-11-10 21:22:31','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(300,3,'ee25a4f8-2697-4040-b4a9-98447a1106ba','f580f85be8b86bc12dc24163a2ff96eae18a859a3d2075dec48fa7b14ddfaa7b','2026-11-25 04:35:37','2026-11-11 05:00:23','4e1076be-84e2-410a-9c26-a65c6186dbf7','2026-11-11 04:35:37','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(301,1,'98caaebf-e410-442e-969a-bde9459800b7','93f4df5730a9a24e3ad2aa0cb2b6e3da2a3b5b1b3b7a5e9f97ae9c039584b6ef','2026-11-25 04:42:19','2026-11-11 05:08:17','8edf1736-049e-4d14-bfa0-c3be12bd1b27','2026-11-11 04:42:19','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(302,3,'4e1076be-84e2-410a-9c26-a65c6186dbf7','cb78a796171f649ee40d4ce3b733a8645e710855db740115b956590b531b10ad','2026-11-25 05:00:23','2026-11-11 05:25:34','e4e9cdfe-f0fe-4421-8fca-691a9a798b47','2026-11-11 05:00:23','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(303,1,'8edf1736-049e-4d14-bfa0-c3be12bd1b27','4cd78677c2d6750739129f364cb3680f2f15d6caac6ffdee26a49e528f99ecd6','2026-11-25 05:08:17','2026-11-11 05:26:17','e226830e-03e1-4067-a014-7110e3f2c8c8','2026-11-11 05:08:17','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(304,3,'e4e9cdfe-f0fe-4421-8fca-691a9a798b47','9010654947c4a1732bbaad572a7ebf5986876eb64ca4b8367937cbadbeff5feb','2026-11-25 05:25:34','2026-11-11 13:31:06','aa36a7d5-5534-4a9d-be50-4d3cfdd8a28d','2026-11-11 05:25:34','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(305,1,'e226830e-03e1-4067-a014-7110e3f2c8c8','79e1e25b5e617e42e65ce2231d593c514d134a630481d104ed66efe1fdc1b6c6','2026-11-25 05:26:17','2026-11-11 05:33:03','94ccfa62-5d2c-4561-ab4c-29b868162b03','2026-11-11 05:26:17','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(306,1,'94ccfa62-5d2c-4561-ab4c-29b868162b03','b6a7d08f15a5c6b978a73e07424e1cca3345934655a38e92bc23119a08780417','2026-11-25 05:33:03','2026-11-11 05:37:46','19ecb99b-896c-4631-958c-6690514b34cb','2026-11-11 05:33:03','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(307,1,'19ecb99b-896c-4631-958c-6690514b34cb','38bdf45b366d8c273cb71ed0b5836cac0bf3cba61e6e73b32806152d6c98a97f','2026-11-25 05:37:46','2026-11-11 13:11:27','484b8fe6-453c-4ff5-b1ec-13d54a77d161','2026-11-11 05:37:46','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(308,1,'484b8fe6-453c-4ff5-b1ec-13d54a77d161','1164a9e8791952ad856931ed6172aaf2719755ac63d0f27930fe6163eaf72fbb','2026-11-25 13:11:27','2026-11-11 19:46:20',NULL,'2026-11-11 13:11:27','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(309,3,'aa36a7d5-5534-4a9d-be50-4d3cfdd8a28d','cc21f7c9b1a6fed5d615be606bab3c423d3bbf28a56fdf750e986e6575bd0f10','2026-11-25 13:31:06','2026-11-11 14:53:09','d849a3e4-576f-4e3f-9e0c-f3432d8aafd4','2026-11-11 13:31:06','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(310,3,'d849a3e4-576f-4e3f-9e0c-f3432d8aafd4','01b9e2aeec49b2409d35b04fba2ef201a5c5d3b4ba87b71986c11a9310b22b10','2026-11-25 14:53:09','2026-11-11 14:53:10',NULL,'2026-11-11 14:53:09','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(311,3,'80420b29-8ffb-4b02-a28c-006a165c8b11','92b1a803c27fa51be988854f51c69ec143c2a1b1b900a8a47caa92a9eab96810','2026-11-25 14:53:24','2026-11-11 15:08:29','1df5bc31-1710-490d-a7de-32e65ccf50ac','2026-11-11 14:53:24','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(312,3,'1df5bc31-1710-490d-a7de-32e65ccf50ac','ec38da6f2b89deda2b765fce0e625b884ef4d34b7c70726f62ac254c07ebd1d1','2026-11-25 15:08:29','2026-11-11 15:08:30','a536dfbf-ba44-45d2-b47c-5849348c0ce6','2026-11-11 15:08:29','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(313,3,'a536dfbf-ba44-45d2-b47c-5849348c0ce6','340f29f1974fa39f85827445457a57f88e86d887b536fa0a39f090afaed581df','2026-11-25 15:08:30','2026-11-11 15:12:44',NULL,'2026-11-11 15:08:30','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(314,3,'0b27ea28-b869-42be-ae0c-92d531ec379f','ea7e13bc81e81db772a5e7261f80c391070b4224302845b0bc89710cea1bfa5d','2026-11-25 19:40:39','2026-11-11 19:54:27',NULL,'2026-11-11 19:40:39','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(315,1,'5d2722f4-ff56-4923-bba4-9747f19c981c','393d2b877160172bb40ea951cc3dbb0e6f9426476ff2c50e9fe2daf72e92948d','2026-11-25 19:46:30','2026-11-11 20:01:52','f12407d0-c45e-48ce-8d1d-03a758bfe1a7','2026-11-11 19:46:30','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(316,1,'f12407d0-c45e-48ce-8d1d-03a758bfe1a7','8579bc5e4eacee9b0cb5de8afebbd0d28c68f290f70ff11d05a2f43a0dd9ca72','2026-11-25 20:01:52','2026-11-11 20:17:15','ff91da04-3adc-47ad-9592-ad602c02d0d8','2026-11-11 20:01:52','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(317,1,'ff91da04-3adc-47ad-9592-ad602c02d0d8','6cafba1395065aabcc89fa8df991e52ed32c5c209ba86ad8a22fc026ab0d3ed1','2026-11-25 20:17:15','2026-11-11 20:17:32','d5abb217-7949-456d-9028-36f730bd361f','2026-11-11 20:17:15','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(318,1,'d5abb217-7949-456d-9028-36f730bd361f','e4b690a7b9c6d85229f81022d994ceaf5b1de3035677a172f40a8a76eb9beb9b','2026-11-25 20:17:32','2026-11-11 20:32:52','671eaa0f-62a1-41e9-b66e-0fffaedf6441','2026-11-11 20:17:32','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(319,1,'671eaa0f-62a1-41e9-b66e-0fffaedf6441','21bb0414bd05fe78b995b9663226a08d6e967fd52072d1e3db52f10d6d5cd105','2026-11-25 20:32:52','2026-11-11 20:32:52',NULL,'2026-11-11 20:32:52','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(320,1,'0fa7ecc9-89aa-48e4-b567-aa062e8b5050','8c633f7b0200f16ccc2029bc27db0d12ad5996af0f33735a0d5854b952ad0ddb','2026-11-25 20:50:29','2026-11-11 21:04:51','c3cf4d43-4540-43bc-979d-5d43e0d9cc7d','2026-11-11 20:50:29','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(321,1,'c3cf4d43-4540-43bc-979d-5d43e0d9cc7d','dced95ad0e4337be6d0e62e76e071f5f26deb83f405c932d5db12af850af352d','2026-11-25 21:04:51','2026-11-11 21:41:42','f6cdf7c4-b7ae-487b-bed1-a0626a48849d','2026-11-11 21:04:51','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(322,3,'fcf6d82a-3909-4bf5-8d85-375d680a5eb1','a19242dbef20118f11b75c1ae28c37a7cddb25f996291d2a575fd9f7c260e50f','2026-11-25 21:17:44','2026-11-11 21:32:45','cba8df11-c347-4646-944d-48178e3e6b18','2026-11-11 21:17:44','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(323,3,'cba8df11-c347-4646-944d-48178e3e6b18','5604c1a9047ca568240326fe54099ebb26fdd68a2c23a2074d8ab52c80b37bd2','2026-11-25 21:32:45','2026-11-11 21:47:45','58c7dce9-0a12-4cf5-a92d-87b140e1f16b','2026-11-11 21:32:45','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(324,1,'f6cdf7c4-b7ae-487b-bed1-a0626a48849d','5af564a60758af2a3f833e0439f05952dd6c7fd0d171a705306d1e71352ad210','2026-11-25 21:41:42','2026-11-12 05:13:29','a7b6978a-750c-4100-aaf0-cd1fa7e627e1','2026-11-11 21:41:42','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(325,3,'58c7dce9-0a12-4cf5-a92d-87b140e1f16b','72072adbc7760a135169e109af785c4d0b2148f70ecb5be60227aa31b2ac2b06','2026-11-25 21:47:45','2026-11-11 22:03:23','913b248f-0393-45c8-b800-c917eb724185','2026-11-11 21:47:45','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(326,3,'913b248f-0393-45c8-b800-c917eb724185','383ef9ea1a9565a67355b0c86336c4c89449d9a1594a4a9372a0a789be2ad2a9','2026-11-25 22:03:23','2026-11-11 22:19:07','cf69b75d-7bfc-4dde-bca4-dee1d9673905','2026-11-11 22:03:23','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(327,3,'cf69b75d-7bfc-4dde-bca4-dee1d9673905','74ed3d902f5cf33b298092cf26ddcf043456943d444338b3b6993ee71812a401','2026-11-25 22:19:07','2026-11-12 15:26:34','95a474c3-3851-4c84-8196-bbbdf6010460','2026-11-11 22:19:07','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(328,1,'a7b6978a-750c-4100-aaf0-cd1fa7e627e1','40c699efb1d5b4bb097d4b10f9cdd194d7a7e50923fb6cb95a2552820f92d31a','2026-11-26 05:13:29','2026-11-12 15:38:03',NULL,'2026-11-12 05:13:29','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(329,3,'95a474c3-3851-4c84-8196-bbbdf6010460','ea9caac7c812fd5df250321b33f106ca2386460043a0ccb44d75c961f7fc6a88','2026-11-26 15:26:34','2026-11-12 15:31:33','bc02cee0-a446-4c8e-9674-7e8fb74a435d','2026-11-12 15:26:35','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(330,3,'bc02cee0-a446-4c8e-9674-7e8fb74a435d','4ee507de89c910e840b5788825a391b1aa839a32353c2033cf5673747d7d26b5','2026-11-26 15:31:33','2026-11-12 15:46:36','a4a6f5c6-38e6-459d-ab7b-d69ea9668b10','2026-11-12 15:31:33','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(331,1,'6f05713d-4e83-4563-a269-6cb8b3508301','da3d339ef7b9082531b9fb5f10e85af99d4493427f32e2d1db7fd4241a4a038d','2026-11-26 15:38:11','2026-11-12 15:53:13','589e5d3e-3d29-4cb9-936c-94e3f4e22e70','2026-11-12 15:38:11','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(332,3,'a4a6f5c6-38e6-459d-ab7b-d69ea9668b10','976bf9258d9a1cb334c21fc98e24a81053db51ae4be81370bb6730a955d14fb7','2026-11-26 15:46:36','2026-11-12 15:58:02','b743c60a-dc02-478d-9145-1fca845c73b4','2026-11-12 15:46:36','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(333,1,'589e5d3e-3d29-4cb9-936c-94e3f4e22e70','37fa16c8ba2501c490a9040448eeacb7879923734c35a8bb80712f082033cc6c','2026-11-26 15:53:13','2026-11-12 15:57:02','61606bb6-73bb-4ed5-8e06-c1e93cdd3722','2026-11-12 15:53:13','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(334,1,'61606bb6-73bb-4ed5-8e06-c1e93cdd3722','b1a8e63f945902b31b147f27115c62380f5074b73ae1f417fa0d33461d3506ab','2026-11-26 15:57:02','2026-11-12 16:05:00',NULL,'2026-11-12 15:57:02','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(335,3,'b743c60a-dc02-478d-9145-1fca845c73b4','479d679ca4cbfc1e28260d118de3ef80b1a5d4605013408985a217a70214cc9f','2026-11-26 15:58:02','2026-11-12 16:13:05','c48861e8-9f23-4628-8f1e-20f484079f5b','2026-11-12 15:58:02','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(336,1,'b951c570-b0d8-44e3-a61f-9b76be3dac56','ef404c025cccb47358b545d3bbc3464bcfa33286c34e48057a59382971e43b75','2026-11-26 16:05:08','2026-11-12 16:12:03',NULL,'2026-11-12 16:05:08','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(337,3,'c48861e8-9f23-4628-8f1e-20f484079f5b','9345231f63ed1414a20cd9fec3892635711fbc3cf9a875580735558cefb12303','2026-11-26 16:13:05','2026-11-12 16:29:05','fa455431-9c9b-4552-8160-cc4120b2e55d','2026-11-12 16:13:05','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(338,3,'fa455431-9c9b-4552-8160-cc4120b2e55d','729069feb286b1fca7e764553d86f80a13e68cff083dbd26a5a90d4b02b23326','2026-11-26 16:29:05','2026-11-12 16:32:12','b4970781-0247-419b-9eb6-70eb0573e964','2026-11-12 16:29:05','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(339,3,'b4970781-0247-419b-9eb6-70eb0573e964','9cc2c14475ac259736812eefb190026dca1f722c14a15d21b966d44d12a6590c','2026-11-26 16:32:12','2026-11-12 16:32:14','d9c3db66-ae7e-414d-8bfa-13a43f907650','2026-11-12 16:32:12','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(340,3,'d9c3db66-ae7e-414d-8bfa-13a43f907650','fa7bb16b486cbc52215d7689624d177e9005ad46589d2e26aaf6eb29b6d0c5f3','2026-11-26 16:32:14','2026-11-12 16:48:14','08c16c67-7605-4e1b-8c14-9a2de1c2e184','2026-11-12 16:32:14','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(341,1,'8f1e7f62-69b3-4da6-936a-ba391eb33245','80c8a017af9f1a931b8ff6f36b823d8cd584a74b53f16f9c0733a524a7e7e08a','2026-11-26 16:38:06','2026-11-12 16:51:14','87ebeeba-0974-4911-80dc-820066fef305','2026-11-12 16:38:06','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(342,3,'08c16c67-7605-4e1b-8c14-9a2de1c2e184','22008423a7217a968a6b1119d283a24344d783b7a32393b758f45be62e2fca2f','2026-11-26 16:48:14','2026-11-12 17:00:43','4708b77b-7878-422b-a357-fd952c19ff2a','2026-11-12 16:48:14','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(343,1,'87ebeeba-0974-4911-80dc-820066fef305','2b4a2a7b1257f292f0141e7389440afc0888cdf8779d7e8effa13073f0dbb8fd','2026-11-26 16:51:14','2026-11-12 17:06:19','26c5a457-cee5-433d-bbe5-c8e963a59da5','2026-11-12 16:51:14','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(344,3,'4708b77b-7878-422b-a357-fd952c19ff2a','4a0117c51b7876ffdea7fc0fe428a41964f2e69aa5aa12f5a06f0c206f017699','2026-11-26 17:00:43','2026-11-12 17:16:44','6ef732a8-fca7-4963-bb86-3bdc108a000e','2026-11-12 17:00:43','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(345,1,'26c5a457-cee5-433d-bbe5-c8e963a59da5','def5e1520b8db94e7e3bca5221d84df263b10a96226ef749fdada7596a7b43c3','2026-11-26 17:06:19','2026-11-12 17:06:20','3448eb2e-d08c-484e-b3aa-8b85eb06a3d2','2026-11-12 17:06:19','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(346,1,'3448eb2e-d08c-484e-b3aa-8b85eb06a3d2','61b63f9d4c6bbf313a764d59a720478b73940f1615c91a7bec85e26e0f5cdf21','2026-11-26 17:06:20','2026-11-12 17:07:25','acb41e5c-400e-40cb-9b0a-a5278a2b5e87','2026-11-12 17:06:20','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(347,1,'acb41e5c-400e-40cb-9b0a-a5278a2b5e87','cb98896ff586d8a2e9113b610362ccf651d864522aa5b8f902dcfc5050979847','2026-11-26 17:07:25','2026-11-12 17:07:35','13a78cd4-1e5d-4581-bef3-c8f135256c99','2026-11-12 17:07:25','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(348,1,'13a78cd4-1e5d-4581-bef3-c8f135256c99','d6e83558b5a464d4afa33558bb182acb06d32f893ecedfe455fe8f0ea5925670','2026-11-26 17:07:35','2026-11-12 17:22:39','4162f097-dfa2-42d6-a2b5-19faf9916438','2026-11-12 17:07:35','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(349,3,'6ef732a8-fca7-4963-bb86-3bdc108a000e','6bf38750e3be2e73b93a1b7c2881a2845277268d25d73a2613c721ef6082fb06','2026-11-26 17:16:44','2026-11-12 17:29:17','6a764b40-ab66-4dba-a8b9-888f4ad5195b','2026-11-12 17:16:44','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(350,1,'4162f097-dfa2-42d6-a2b5-19faf9916438','3ef5daab25ca5fea5cc2bfc192f2757ca7c0ceea812825fd429afd6c3d5a2a8f','2026-11-26 17:22:39','2026-11-12 17:37:59','857fb211-f8b2-45d7-a53e-d45d1fad6bd1','2026-11-12 17:22:39','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(351,3,'6a764b40-ab66-4dba-a8b9-888f4ad5195b','a000de2880e902b61d3f956ca602c515e66dc7d851d071338e23a5d98374538f','2026-11-26 17:29:17','2026-11-13 20:17:25','46b2be2d-9343-4bef-beb3-aa2a6ea6bb15','2026-11-12 17:29:17','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36','172.16.1.1'),(352,1,'857fb211-f8b2-45d7-a53e-d45d1fad6bd1','a0cc5f6bedd74f629f6fd7c7edfebb1251c60b397d7e9036be13c23e3c867c3b','2026-11-26 17:37:59','2026-11-12 17:45:55',NULL,'2026-11-12 17:37:59','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(353,1,'03a29e22-9e1a-4520-abbc-e674cf48fe04','0eef8b7b7457170606237310a94196157cf7e72a25e674511429e4dfd98ac3cf','2026-11-26 17:46:16','2026-11-12 18:47:27',NULL,'2026-11-12 17:46:16','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(354,3,'7e763707-cca9-4fba-8418-66fd08c49109','0e4cce13ef997723f6c436a9438507578b60f9250f4cca3149002d48c83863ad','2026-11-27 17:54:50','2026-11-13 17:59:13',NULL,'2026-11-13 17:54:50','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(355,3,'46b2be2d-9343-4bef-beb3-aa2a6ea6bb15','a3c68ef423c6761973bb9474777256ff019413798d2fa0b3b8daf5c9528e29dc','2026-11-27 20:17:25',NULL,NULL,'2026-11-13 20:17:25','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(356,2,'bbc3d62a-5d17-4929-aa8d-f3c6027900bf','cd849e00a35cd3779d8059111588e41a651a783468e58038de59630c619a6521','2026-11-27 21:36:52','2026-11-13 21:52:52','061e360f-8675-45a9-a5f7-dc8d8e1fa2a1','2026-11-13 21:36:52','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(357,2,'061e360f-8675-45a9-a5f7-dc8d8e1fa2a1','ae19163af3e24dbf8cf3b81b98c4c6be9b089d0248661db22147fea3ae8a17c3','2026-11-27 21:52:52','2026-11-13 22:07:53','b840cadc-f5e1-477f-b207-938ed9181c6c','2026-11-13 21:52:52','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(358,2,'b840cadc-f5e1-477f-b207-938ed9181c6c','cfdb84bb991f37143da521a1c35f6fe4fbc6214faa1b7f2e7e1d13d1f0c430bc','2026-11-27 22:07:53','2026-11-14 14:09:04','fa0fb0d9-298e-4644-a250-082d095eb983','2026-11-13 22:07:53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(359,2,'fa0fb0d9-298e-4644-a250-082d095eb983','0188a4061de007d98e6b057ad0ee1ac08d5fcb668d30b35c7da9da9202ed62bc','2026-11-28 14:09:04','2026-11-14 14:24:05','6187689f-4a6c-4f1d-892a-fd8db83dd676','2026-11-14 14:09:04','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(360,2,'6187689f-4a6c-4f1d-892a-fd8db83dd676','bed712f88b8b3a694b010d9a6072653dc824abf4b6d71ec438c71b008ac3ad5c','2026-11-28 14:24:05','2026-11-14 14:39:05','2bfd3824-3b2e-4c47-8c34-3532fe04a159','2026-11-14 14:24:05','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(361,2,'2bfd3824-3b2e-4c47-8c34-3532fe04a159','80ddd88f353380fa24b45499c7fe510af4a881006f90737cc7568aea64ea42da','2026-11-28 14:39:05','2026-11-14 14:46:56',NULL,'2026-11-14 14:39:05','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(362,3,'52b93da6-1d58-4211-b254-ab6bc16e8454','acab720d4ce39b0b82d363bbcb8b99b16a2e74a05e597ed866ec0c5ce40a5ace','2026-11-28 14:47:17','2026-11-14 15:02:17','06be6901-fa16-4928-8b25-f36f59226357','2026-11-14 14:47:17','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(363,4,'9e5d53ba-1313-4c12-950d-0a79ebf63ffe','d7e479551a652f2ff74f4051b5e4b5e0c6ed8ddb0bdede42064052247b4e125d','2026-11-28 14:48:43',NULL,NULL,'2026-11-14 14:48:43','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(364,2,'291c29cd-b4cd-400d-9b9a-7b113d05193e','c8403a7740126bb789cb8fe17b1d464c913dd82dc149e781a427c38951850be6','2026-11-28 14:49:51','2026-11-17 12:39:23','58f3e8f2-8c04-4114-bf38-361bcdc076e6','2026-11-14 14:49:51','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(365,3,'06be6901-fa16-4928-8b25-f36f59226357','a13a250932bfe4a5f8afc9e24109a765e7d7b2b312c0087c387cb2084ddb9831','2026-11-28 15:02:17','2026-11-14 15:04:19','5f15ae65-8779-4d23-a092-752650b6c54c','2026-11-14 15:02:17','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(366,3,'5f15ae65-8779-4d23-a092-752650b6c54c','8f0e8977ec9cc5fcb6d7a281ec84b9ae7573e13e93c1ad66d304b8d7c3e61c0a','2026-11-28 15:04:19','2026-11-14 15:19:20','3ed314ae-af28-49dc-91d9-61f45de5338a','2026-11-14 15:04:19','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(367,3,'3ed314ae-af28-49dc-91d9-61f45de5338a','ddf8878f52e68735832e3386b876086bc0053b8d69e28ba058929292a5067ab3','2026-11-28 15:19:20','2026-11-14 15:34:49','50e398f1-aa94-4249-aa58-43494383d87b','2026-11-14 15:19:20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(368,3,'50e398f1-aa94-4249-aa58-43494383d87b','9bcc6c2b1708b0d02c8e5423ec174206915fc5773876d60988e274115ca915ef','2026-11-28 15:34:49','2026-11-14 15:50:49','7174fe31-0cbe-4beb-9f05-15b33927bd89','2026-11-14 15:34:49','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(369,3,'7174fe31-0cbe-4beb-9f05-15b33927bd89','6a1a00e907d2df04778ca218538e8244c81116d37287cc5d6ccb712ca30ad7fa','2026-11-28 15:50:49','2026-11-14 16:06:49','0e42b5fc-8661-4b48-85e2-98e406641808','2026-11-14 15:50:49','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(370,3,'0e42b5fc-8661-4b48-85e2-98e406641808','91fb55a3920e3b7eb7f39cc8fc825badf068ec6a7bb23e9f2389fe7ef9390da3','2026-11-28 16:06:49','2026-11-14 16:22:49','ab742881-8e33-474c-aaae-53f849388784','2026-11-14 16:06:49','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(371,3,'ab742881-8e33-474c-aaae-53f849388784','c051691427cacb4c424858fc4c2ee5f60fb29f17c6154d174f8d8597f4dd6392','2026-11-28 16:22:49','2026-11-14 16:38:49','4493f68c-2ea8-4a81-ae2f-531a97f35483','2026-11-14 16:22:49','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(372,3,'4493f68c-2ea8-4a81-ae2f-531a97f35483','4049e157be122bbcd7cc0b6bdc3806edf5383ed90785c1998b9ab41e5615a4e8','2026-11-28 16:38:49','2026-11-14 16:54:19','24a6f929-b77c-41c0-8b38-d05a31a17476','2026-11-14 16:38:49','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(373,3,'24a6f929-b77c-41c0-8b38-d05a31a17476','a72219fc677a77fff8a055c66497b1a35f221cb369fa98da7fec9d13318d3435','2026-11-28 16:54:19',NULL,NULL,'2026-11-14 16:54:19','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1'),(374,1,'a38a3eb8-f28a-46e1-83c9-4c9d51922a1d','14837f3f4d008447138269858dff3215b067a12b38d2052cc24f42159e461d92','2026-11-28 21:35:10','2026-11-15 21:44:10','2e1b3f51-47d0-446d-80ad-e8a21446052a','2026-11-14 21:35:10','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(375,3,'ad6ede92-7b4c-43c3-9674-f1f5b722d729','50e7e0eb726b1321d11300ee3d9dce00edca23f91663bc2151f5f484a3afbcaa','2026-11-29 05:38:25','2026-11-17 12:38:05','26eaa699-c159-4c28-adb5-3b15382a48fb','2026-11-15 05:38:25','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(376,1,'2e1b3f51-47d0-446d-80ad-e8a21446052a','e0f4fe142fd96dfe597dfe8a4d6225dea99ec2eca21bea87736e5ea00ecaa0c1','2026-11-29 21:44:10','2026-11-17 17:33:04',NULL,'2026-11-15 21:44:10','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(377,3,'26eaa699-c159-4c28-adb5-3b15382a48fb','00a52cacad5ca9e3eb908897101eac9e7a31d4fffa2b8472667ecf92b4c84f7d','2026-12-01 12:38:04','2026-11-17 16:58:05','147e6b63-e8a0-4c2a-9a27-bbdd47ca5f57','2026-11-17 12:38:05','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(378,2,'58f3e8f2-8c04-4114-bf38-361bcdc076e6','06b543e7e6d06f7a521ced31f0362f07dbf4e14fa21ca124ac7d8ef8a569df9e','2026-12-01 12:39:23','2026-11-17 12:43:59','bd840bfb-47df-47b5-8651-c9409a33ecda','2026-11-17 12:39:23','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(379,2,'bd840bfb-47df-47b5-8651-c9409a33ecda','8a8db8b226aec457ddddbefb84179f72525d86d493bdb34fb197f77168b487d6','2026-12-01 12:43:59','2026-11-17 13:15:07','b0669dd8-1793-43b7-b3b1-a1bb80a8d7c5','2026-11-17 12:43:59','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(380,2,'b0669dd8-1793-43b7-b3b1-a1bb80a8d7c5','94f599e890d7398fa2f40bccdff4feabbc0eacc794643129e1f17fd5296b6223','2026-12-01 13:15:07','2026-11-17 15:13:21','48926909-97bc-4463-8546-b834c5308873','2026-11-17 13:15:07','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(381,2,'48926909-97bc-4463-8546-b834c5308873','e7cb6167a27a776084a3f55462227d9352e092720b141b049e7a5c63d35a3dd9','2026-12-01 15:13:21','2026-11-17 17:14:32','391592b1-53d4-460f-a0a1-d4d4a20578ed','2026-11-17 15:13:21','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(382,3,'147e6b63-e8a0-4c2a-9a27-bbdd47ca5f57','d6f82b42f3f14751749f56cb8611b063e39fdc38d9633b560fa52686db1d22d4','2026-12-01 16:58:05',NULL,NULL,'2026-11-17 16:58:05','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(383,2,'391592b1-53d4-460f-a0a1-d4d4a20578ed','49e59d5feb98f14ac934f6c17bbd62b499c2d12b99f69f8bef1f145e4694ab70','2026-12-01 17:14:32',NULL,NULL,'2026-11-17 17:14:32','Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1','172.16.1.1'),(384,1,'903bf56e-f36c-47b8-b812-ea3fb587296b','3c96b91192be99ac45e5f672534263044150c7336b325ad4541b880bcfe42b65','2026-12-01 17:33:10',NULL,NULL,'2026-11-17 17:33:10','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','172.16.1.1');
/*!40000 ALTER TABLE `refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `specialties`
--

DROP TABLE IF EXISTS `specialties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `specialties` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `worker_position_id` int DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `worker_position_id` (`worker_position_id`),
  CONSTRAINT `specialties_ibfk_1` FOREIGN KEY (`worker_position_id`) REFERENCES `worker_positions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `specialties`
--

LOCK TABLES `specialties` WRITE;
/*!40000 ALTER TABLE `specialties` DISABLE KEYS */;
/*!40000 ALTER TABLE `specialties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_assignments`
--

DROP TABLE IF EXISTS `task_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `worker_id` int NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `assigned_at` datetime NOT NULL DEFAULT (now()),
  `assigned_by` int NOT NULL,
  `removed_at` datetime DEFAULT NULL,
  `removed_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `worker_id` (`worker_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `removed_by` (`removed_by`),
  CONSTRAINT `task_assignments_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_assignments_ibfk_2` FOREIGN KEY (`worker_id`) REFERENCES `workers` (`id`),
  CONSTRAINT `task_assignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`),
  CONSTRAINT `task_assignments_ibfk_4` FOREIGN KEY (`removed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_assignments`
--

LOCK TABLES `task_assignments` WRITE;
/*!40000 ALTER TABLE `task_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_budget_activities`
--

DROP TABLE IF EXISTS `task_budget_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_budget_activities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `chapter_id` int DEFAULT NULL,
  `zone_id` int DEFAULT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `display_order` int NOT NULL,
  `chapter_weight_percent` decimal(6,2) DEFAULT NULL,
  `zone_weight_percent` decimal(6,2) DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `chapter_id` (`chapter_id`),
  KEY `zone_id` (`zone_id`),
  CONSTRAINT `task_budget_activities_ibfk_1` FOREIGN KEY (`chapter_id`) REFERENCES `task_chapters` (`id`),
  CONSTRAINT `task_budget_activities_ibfk_2` FOREIGN KEY (`zone_id`) REFERENCES `task_zones` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_budget_activities`
--

LOCK TABLES `task_budget_activities` WRITE;
/*!40000 ALTER TABLE `task_budget_activities` DISABLE KEYS */;
INSERT INTO `task_budget_activities` VALUES (1,1,NULL,'Preliminares',NULL,0,100.00,NULL,1,'2026-10-22 15:28:28',NULL),(2,2,NULL,'Estructura Metalica',NULL,0,50.00,NULL,1,'2026-10-22 15:29:54',NULL),(3,2,NULL,'Estructura Concreto',NULL,0,50.00,NULL,1,'2026-10-22 15:30:17','2026-11-11 08:12:45'),(4,3,NULL,'Instalaciones Hidrosanitarias - Aguas Lluvias',NULL,0,100.00,NULL,1,'2026-10-22 15:31:02',NULL),(5,4,NULL,'Instalaciones Eléctricas',NULL,0,100.00,NULL,1,'2026-10-22 15:31:21',NULL),(6,5,NULL,'Mamposteria',NULL,0,33.30,NULL,1,'2026-10-22 15:31:46',NULL),(7,5,NULL,'Pañetes',NULL,0,33.30,NULL,1,'2026-10-22 15:32:00',NULL),(8,5,NULL,'Mamposteria Liviana',NULL,0,33.40,NULL,1,'2026-10-22 15:32:23',NULL),(9,6,NULL,'Cubiertas',NULL,0,NULL,NULL,1,'2026-11-07 09:53:43',NULL),(10,6,NULL,'Enchapes de piso y muro',NULL,0,NULL,NULL,1,'2026-11-07 09:53:54',NULL),(11,6,NULL,'Carpinteria de aluminio',NULL,0,NULL,NULL,1,'2026-11-07 09:54:07',NULL),(12,6,NULL,'Carpinteria de madera',NULL,0,NULL,NULL,1,'2026-11-07 09:54:16',NULL),(13,6,NULL,'Carpinteria metalica',NULL,0,NULL,NULL,1,'2026-11-07 09:54:28',NULL),(14,6,NULL,'Aparatos sanitarios',NULL,0,NULL,NULL,1,'2026-11-07 09:54:39',NULL),(15,6,NULL,'Revestimientos pintura',NULL,0,NULL,NULL,1,'2026-11-07 09:54:50',NULL),(16,6,NULL,'Revestimiento mamp liviana',NULL,0,NULL,NULL,1,'2026-11-07 09:55:06','2026-11-07 10:43:08'),(17,6,NULL,'Equipos especiales',NULL,0,NULL,NULL,1,'2026-11-07 09:55:18',NULL);
/*!40000 ALTER TABLE `task_budget_activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_chapters`
--

DROP TABLE IF EXISTS `task_chapters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_chapters` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `description` text,
  `display_order` int NOT NULL,
  `stage_id` int DEFAULT NULL,
  `weight_percent` decimal(6,2) DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime DEFAULT NULL,
  `is_global` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `stage_id` (`stage_id`),
  CONSTRAINT `task_chapters_ibfk_1` FOREIGN KEY (`stage_id`) REFERENCES `obra_stages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_chapters`
--

LOCK TABLES `task_chapters` WRITE;
/*!40000 ALTER TABLE `task_chapters` DISABLE KEYS */;
INSERT INTO `task_chapters` VALUES (1,'Actividades Preliminares',NULL,0,NULL,1.00,1,'2026-10-22 14:48:27','2026-11-05 12:14:51',1),(2,'Estructura',NULL,0,NULL,30.00,1,'2026-10-22 14:48:41','2026-11-11 08:12:33',1),(3,'Instalaciones Hidrosanitarias',NULL,0,NULL,6.00,1,'2026-10-22 14:49:57','2026-11-11 00:26:53',1),(4,'Instalaciones Eléctricas',NULL,0,NULL,9.00,1,'2026-10-22 15:26:56','2026-11-11 00:26:45',1),(5,'Obra Gris',NULL,0,NULL,14.00,1,'2026-10-22 15:27:20','2026-11-11 00:27:05',1),(6,'Acabados',NULL,0,NULL,40.00,1,'2026-10-22 15:27:37','2026-11-11 00:26:34',1);
/*!40000 ALTER TABLE `task_chapters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_comments`
--

DROP TABLE IF EXISTS `task_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `task_id` int NOT NULL,
  `user_id` int NOT NULL,
  `type` varchar(30) NOT NULL,
  `content` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_task_comments_uuid` (`uuid`),
  KEY `task_id` (`task_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `task_comments_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_comments`
--

LOCK TABLES `task_comments` WRITE;
/*!40000 ALTER TABLE `task_comments` DISABLE KEYS */;
INSERT INTO `task_comments` VALUES (1,'85ff21db-09b0-4032-9880-4430f8226f6f',3,1,'comment','manana quiero que se haga esto','2026-10-22 16:08:56',NULL),(2,'906dd242-d6d5-4375-aa9a-997d9208c599',19,3,'comment','Falta Provisional de Luz, El agua ya se conectó','2026-11-14 11:41:31',NULL);
/*!40000 ALTER TABLE `task_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_crew_assignments`
--

DROP TABLE IF EXISTS `task_crew_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_crew_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `crew_id` int NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `assigned_at` datetime NOT NULL DEFAULT (now()),
  `assigned_by` int NOT NULL,
  `removed_at` datetime DEFAULT NULL,
  `removed_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `crew_id` (`crew_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `removed_by` (`removed_by`),
  CONSTRAINT `task_crew_assignments_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_crew_assignments_ibfk_2` FOREIGN KEY (`crew_id`) REFERENCES `crews` (`id`),
  CONSTRAINT `task_crew_assignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`),
  CONSTRAINT `task_crew_assignments_ibfk_4` FOREIGN KEY (`removed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_crew_assignments`
--

LOCK TABLES `task_crew_assignments` WRITE;
/*!40000 ALTER TABLE `task_crew_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_crew_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_daily_assignments`
--

DROP TABLE IF EXISTS `task_daily_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_daily_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `work_date` date NOT NULL,
  `worker_id` int NOT NULL,
  `assigned_at` datetime NOT NULL DEFAULT (now()),
  `assigned_by` int NOT NULL,
  `removed_at` datetime DEFAULT NULL,
  `removed_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `worker_id` (`worker_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `removed_by` (`removed_by`),
  CONSTRAINT `task_daily_assignments_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_daily_assignments_ibfk_2` FOREIGN KEY (`worker_id`) REFERENCES `workers` (`id`),
  CONSTRAINT `task_daily_assignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`),
  CONSTRAINT `task_daily_assignments_ibfk_4` FOREIGN KEY (`removed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_daily_assignments`
--

LOCK TABLES `task_daily_assignments` WRITE;
/*!40000 ALTER TABLE `task_daily_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_daily_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_delay_events`
--

DROP TABLE IF EXISTS `task_delay_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_delay_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `task_id` int NOT NULL,
  `delay_reason_id` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `days_lost` decimal(10,2) DEFAULT NULL,
  `description` text,
  `created_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_task_delay_events_uuid` (`uuid`),
  KEY `task_id` (`task_id`),
  KEY `delay_reason_id` (`delay_reason_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `task_delay_events_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_delay_events_ibfk_2` FOREIGN KEY (`delay_reason_id`) REFERENCES `delay_reasons` (`id`),
  CONSTRAINT `task_delay_events_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_delay_events`
--

LOCK TABLES `task_delay_events` WRITE;
/*!40000 ALTER TABLE `task_delay_events` DISABLE KEYS */;
INSERT INTO `task_delay_events` VALUES (1,'3fb1602b-920f-4ffc-ac91-a62f4b3e12e1',2,NULL,'2026-10-22','2026-10-22',NULL,NULL,1,'2026-10-22 16:16:13');
/*!40000 ALTER TABLE `task_delay_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_dependencies`
--

DROP TABLE IF EXISTS `task_dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_dependencies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `depends_on_task_id` int NOT NULL,
  `dependency_type` varchar(30) NOT NULL,
  `is_required` int DEFAULT NULL,
  `blocks_start` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `depends_on_task_id` (`depends_on_task_id`),
  CONSTRAINT `task_dependencies_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_dependencies_ibfk_2` FOREIGN KEY (`depends_on_task_id`) REFERENCES `tasks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_dependencies`
--

LOCK TABLES `task_dependencies` WRITE;
/*!40000 ALTER TABLE `task_dependencies` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_dependencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_dependency_overrides`
--

DROP TABLE IF EXISTS `task_dependency_overrides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_dependency_overrides` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `template_dependency_id` int NOT NULL,
  `override_type` varchar(30) NOT NULL,
  `reason` text,
  `created_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `template_dependency_id` (`template_dependency_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `task_dependency_overrides_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_dependency_overrides_ibfk_2` FOREIGN KEY (`template_dependency_id`) REFERENCES `task_template_dependencies` (`id`),
  CONSTRAINT `task_dependency_overrides_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_dependency_overrides`
--

LOCK TABLES `task_dependency_overrides` WRITE;
/*!40000 ALTER TABLE `task_dependency_overrides` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_dependency_overrides` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_documents`
--

DROP TABLE IF EXISTS `task_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_documents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `task_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `file_url` varchar(500) NOT NULL,
  `content_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` int DEFAULT NULL,
  `uploaded_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_task_documents_uuid` (`uuid`),
  KEY `task_id` (`task_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `task_documents_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_documents_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_documents`
--

LOCK TABLES `task_documents` WRITE;
/*!40000 ALTER TABLE `task_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_photos`
--

DROP TABLE IF EXISTS `task_photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_photos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `task_id` int NOT NULL,
  `file_url` varchar(500) NOT NULL,
  `description` text,
  `taken_at` datetime DEFAULT NULL,
  `uploaded_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_task_photos_uuid` (`uuid`),
  KEY `task_id` (`task_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `task_photos_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_photos_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_photos`
--

LOCK TABLES `task_photos` WRITE;
/*!40000 ALTER TABLE `task_photos` DISABLE KEYS */;
INSERT INTO `task_photos` VALUES (1,'947a3010-8265-4374-8b79-c0007a11fd40',3,'quasar-tests/obras/2/tareas/3/fotos/548cd67e796244c1a19d55e9c4187840.webp',NULL,NULL,1,'2026-10-22 16:07:24'),(2,'9c5134f0-0eba-4f85-827a-9a805747c3f8',3,'quasar-tests/obras/2/tareas/3/fotos/5d463c9351b64bb3b8564e230d644a80.webp',NULL,NULL,1,'2026-10-22 16:07:47'),(3,'c531870b-325b-4e89-b8a7-2c6e04d8762a',2,'quasar-tests/obras/2/tareas/2/fotos/f0e37d52dea045aea54358bbcf8fa4e6.webp',NULL,NULL,1,'2026-10-27 11:03:10'),(4,'51831bfd-9635-4def-baf8-ece38471cbfa',1,'quasar-tests/obras/2/tareas/1/fotos/c9abd441ae7143ac8ce03a0b6b51bc0a.webp',NULL,NULL,1,'2026-10-27 11:04:56'),(5,'5dc643f4-5a1d-4160-9d73-562c39e2d58f',11,'quasar-tests/obras/5/tareas/11/fotos/822576c14afa4b2486dd2c7e74b427b3.webp',NULL,NULL,2,'2026-11-07 10:54:03'),(6,'086de4a3-0531-4110-985c-f41cffa02a28',12,'quasar-tests/obras/5/tareas/12/fotos/18bc5c572a0749e38e54fdb22eba352d.webp',NULL,NULL,2,'2026-11-07 10:54:39'),(7,'9f5ce7e6-bf1b-4004-954e-e1a1e831fd8a',12,'quasar-tests/obras/5/tareas/12/fotos/81b9daa5a6534cd0a5f932debf542a38.webp',NULL,NULL,2,'2026-11-07 10:54:45'),(8,'b0d6c73e-17ea-4847-b089-0ab79df4ad82',14,'quasar-tests/obras/5/tareas/14/fotos/27bc9329a1a743e8a6c75bd2b6162f1e.webp',NULL,NULL,2,'2026-11-07 10:55:29'),(9,'93d96aa5-a383-412c-8b13-eb06af8d364c',14,'quasar-tests/obras/5/tareas/14/fotos/1cebf77ab5eb45fea8626a2fff7cc5c8.webp',NULL,NULL,2,'2026-11-07 10:55:37'),(10,'d0a616f8-c183-49f1-820f-f773353ac72d',15,'quasar-tests/obras/5/tareas/15/fotos/b4d384e65dd14c84aabad609d9515276.webp',NULL,NULL,2,'2026-11-07 10:59:13'),(11,'7f6172dc-2efc-4eb9-8c9b-d944d03cf183',16,'quasar-tests/obras/5/tareas/16/fotos/6ecaac4d8d9242c6acb69c45e97fcc46.webp',NULL,NULL,2,'2026-11-07 11:00:48'),(12,'08832063-dbf7-4831-94fd-6476c30e364a',17,'quasar-tests/obras/5/tareas/17/fotos/68cae4c3d88742968410e5cf852efb25.webp',NULL,NULL,2,'2026-11-07 11:01:32'),(13,'40f55208-1a37-4db8-99fa-00acf6aca45e',17,'quasar-tests/obras/5/tareas/17/fotos/9fa4e901ba2a4e8ca63f808ab3ff4c71.webp',NULL,NULL,2,'2026-11-07 11:01:38'),(14,'4b53d2e4-5fb1-4d57-bda2-d604fbfcde51',17,'quasar-tests/obras/5/tareas/17/fotos/d2a69991c3e94749a2946de0557dc551.webp',NULL,NULL,2,'2026-11-07 11:01:50'),(15,'bf879815-2ce4-4907-aa16-22693f036b0c',17,'quasar-tests/obras/5/tareas/17/fotos/7e8775919e3b4a15b3fe0808284e6cfc.webp',NULL,NULL,2,'2026-11-07 11:01:56'),(16,'792b58e0-f0ab-4ff3-8730-bfc3539c6738',17,'quasar-tests/obras/5/tareas/17/fotos/942f9f0d297645b7a184eaaa54c14bb3.webp',NULL,NULL,2,'2026-11-07 11:02:01'),(17,'aa6e16b8-4017-4cc3-bf96-f428643d27a1',92,'quasar-tests/obras/5/tareas/92/fotos/1d36f6a934ad4a9397104b034a294f17.webp',NULL,NULL,3,'2026-11-13 12:55:48'),(18,'968b1db9-086a-481e-ada5-a501dbddfd26',93,'quasar-tests/obras/5/tareas/93/fotos/d11ce3c5de8a49a582971d717e8b398f.webp',NULL,NULL,3,'2026-11-13 15:18:17'),(19,'bed1d6d5-0d9c-44ef-95ea-5595998d4bd0',38,'quasar-tests/obras/5/tareas/38/fotos/1c69be14ca2144ca99112759f24ce9a8.webp',NULL,NULL,3,'2026-11-13 15:19:31'),(20,'607f8099-0aec-41de-8b19-66682bf5f3f4',38,'quasar-tests/obras/5/tareas/38/fotos/7ecfd5424b5c4acab29659d4b50e7ac4.webp',NULL,NULL,3,'2026-11-13 15:19:40'),(21,'1294c36d-1147-4830-af5f-3d707d618170',38,'quasar-tests/obras/5/tareas/38/fotos/68a61533feb44a1c9eaec793a871f98c.webp',NULL,NULL,3,'2026-11-13 15:19:48'),(22,'d99b1f93-4d92-4cf5-abd0-321f168f0d8d',29,'quasar-tests/obras/5/tareas/29/fotos/90978e263e714b7cbc94debcd693e52c.webp',NULL,NULL,2,'2026-11-17 10:14:42'),(23,'6002b4c3-0b1e-4901-abe4-5328c9b1f1ae',29,'quasar-tests/obras/5/tareas/29/fotos/5fb4a4940fe94dd3aa4107968ba12c73.webp',NULL,NULL,2,'2026-11-17 10:15:08');
/*!40000 ALTER TABLE `task_photos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_reschedules`
--

DROP TABLE IF EXISTS `task_reschedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_reschedules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `task_id` int NOT NULL,
  `previous_start_date` date DEFAULT NULL,
  `previous_end_date` date DEFAULT NULL,
  `new_start_date` date DEFAULT NULL,
  `new_end_date` date DEFAULT NULL,
  `reason_id` int DEFAULT NULL,
  `reason` text,
  `rescheduled_by` int NOT NULL,
  `rescheduled_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_task_reschedules_uuid` (`uuid`),
  KEY `task_id` (`task_id`),
  KEY `reason_id` (`reason_id`),
  KEY `rescheduled_by` (`rescheduled_by`),
  CONSTRAINT `task_reschedules_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_reschedules_ibfk_2` FOREIGN KEY (`reason_id`) REFERENCES `delay_reasons` (`id`),
  CONSTRAINT `task_reschedules_ibfk_3` FOREIGN KEY (`rescheduled_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_reschedules`
--

LOCK TABLES `task_reschedules` WRITE;
/*!40000 ALTER TABLE `task_reschedules` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_reschedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_status_history`
--

DROP TABLE IF EXISTS `task_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_status_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `from_status` varchar(30) DEFAULT NULL,
  `to_status` varchar(30) NOT NULL,
  `reason` text,
  `changed_by` int NOT NULL,
  `changed_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `changed_by` (`changed_by`),
  CONSTRAINT `task_status_history_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `task_status_history_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=266 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_status_history`
--

LOCK TABLES `task_status_history` WRITE;
/*!40000 ALTER TABLE `task_status_history` DISABLE KEYS */;
INSERT INTO `task_status_history` VALUES (1,1,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-10-22 16:05:02'),(2,2,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-10-22 16:05:02'),(3,3,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-10-22 16:05:02'),(4,3,'scheduled','in_progress',NULL,1,'2026-10-22 16:06:56'),(5,3,'in_progress','completed',NULL,1,'2026-10-22 16:07:59'),(6,4,NULL,'scheduled','Actividad única de la obra',2,'2026-10-22 16:13:35'),(7,3,'completed','verified',NULL,1,'2026-10-22 16:15:13'),(8,4,'scheduled','in_progress',NULL,1,'2026-10-22 16:15:29'),(9,4,'in_progress','completed',NULL,1,'2026-10-22 16:15:31'),(10,4,'completed','in_progress',NULL,1,'2026-10-22 16:15:52'),(11,4,'in_progress','completed',NULL,1,'2026-10-22 16:15:55'),(12,4,'completed','in_progress',NULL,1,'2026-10-22 16:15:57'),(13,4,'in_progress','scheduled',NULL,1,'2026-10-22 16:16:02'),(14,2,'scheduled','in_progress',NULL,1,'2026-10-22 16:16:05'),(15,2,'in_progress','completed',NULL,1,'2026-10-22 16:41:50'),(16,2,'completed','verified',NULL,1,'2026-10-22 16:41:52'),(17,1,'scheduled','in_progress',NULL,1,'2026-10-27 11:04:24'),(18,5,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-10-30 18:31:01'),(19,6,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-04 13:51:31'),(20,7,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-04 13:51:31'),(21,8,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-04 13:51:31'),(22,7,'scheduled','in_progress',NULL,3,'2026-11-04 13:53:29'),(23,6,'scheduled','in_progress',NULL,3,'2026-11-04 13:53:34'),(24,7,'in_progress','completed',NULL,3,'2026-11-04 13:54:01'),(25,9,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-05 12:13:29'),(26,10,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-05 12:13:40'),(27,11,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:47:47'),(28,12,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:47:47'),(29,13,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:47:47'),(30,13,'scheduled','in_progress',NULL,2,'2026-11-07 10:48:51'),(31,12,'scheduled','in_progress',NULL,2,'2026-11-07 10:48:55'),(32,11,'scheduled','in_progress',NULL,2,'2026-11-07 10:48:59'),(33,13,'in_progress','completed',NULL,2,'2026-11-07 10:49:05'),(34,12,'in_progress','completed',NULL,2,'2026-11-07 10:49:07'),(35,11,'in_progress','completed',NULL,2,'2026-11-07 10:49:11'),(36,14,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:51:31'),(37,15,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:51:46'),(38,16,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:52:02'),(39,15,'scheduled','in_progress',NULL,2,'2026-11-07 10:53:08'),(40,15,'in_progress','completed',NULL,2,'2026-11-07 10:53:11'),(41,16,'scheduled','in_progress',NULL,2,'2026-11-07 10:53:20'),(42,16,'in_progress','completed',NULL,2,'2026-11-07 10:53:28'),(43,14,'scheduled','in_progress',NULL,2,'2026-11-07 10:53:30'),(44,14,'in_progress','completed',NULL,2,'2026-11-07 10:53:33'),(45,17,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 11:00:23'),(46,17,'scheduled','in_progress',NULL,2,'2026-11-07 11:00:28'),(47,18,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-07 11:25:17'),(48,19,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 11:28:22'),(49,20,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 11:36:24'),(51,22,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:03:28'),(52,23,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:03:39'),(53,24,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:03:48'),(54,25,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:03:58'),(56,27,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:04:19'),(58,29,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:04:35'),(59,30,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:04:48'),(60,31,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:04:58'),(61,32,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:08'),(63,34,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:31'),(64,35,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:39'),(65,36,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:47'),(66,37,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:57'),(67,38,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:06:06'),(69,40,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:06:28'),(72,43,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:02'),(73,44,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:10'),(74,45,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:18'),(75,46,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:27'),(76,47,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:35'),(77,48,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:43'),(78,49,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:52'),(79,50,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:59'),(80,51,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:13'),(81,52,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:22'),(82,53,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:33'),(83,54,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:42'),(84,55,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:54'),(85,56,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:04'),(86,57,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:12'),(87,58,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:22'),(88,59,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:32'),(89,60,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:41'),(90,61,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:50'),(91,62,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:58'),(92,63,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:08'),(93,64,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:16'),(94,65,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:26'),(95,66,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:34'),(96,67,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:42'),(97,68,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:12'),(98,69,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:20'),(99,70,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:28'),(100,71,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:36'),(101,72,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:47'),(102,73,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:57'),(103,74,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:06'),(104,75,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:15'),(105,76,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:25'),(106,77,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:33'),(107,78,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:41'),(108,79,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:51'),(109,80,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:00'),(110,81,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:07'),(111,82,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:14'),(112,83,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:26'),(113,84,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:34'),(114,85,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:43'),(115,86,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:52'),(116,87,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:14:00'),(117,88,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:14:10'),(118,89,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:14:18'),(119,90,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:14:26'),(120,91,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-11 16:32:52'),(121,17,'in_progress','completed',NULL,3,'2026-11-11 16:33:47'),(122,91,'scheduled','in_progress',NULL,3,'2026-11-11 16:33:53'),(123,19,'scheduled','in_progress',NULL,3,'2026-11-11 16:34:02'),(124,92,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-11 16:35:46'),(125,92,'scheduled','in_progress',NULL,3,'2026-11-11 16:35:56'),(126,38,'scheduled','in_progress',NULL,3,'2026-11-12 10:59:16'),(127,93,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-12 11:04:16'),(128,93,'scheduled','in_progress',NULL,3,'2026-11-12 11:04:38'),(129,91,'in_progress','completed',NULL,3,'2026-11-12 11:04:55'),(130,94,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-12 11:58:37'),(131,95,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(132,96,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(133,97,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(134,98,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(135,99,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(136,100,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(137,101,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(138,102,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(139,103,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(140,104,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(141,105,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(142,106,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(143,107,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(144,108,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(145,109,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(146,110,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(147,111,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(148,112,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(149,113,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(150,114,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(151,115,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(152,116,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(153,117,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(154,118,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(155,119,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(156,120,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(157,121,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(158,122,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(159,123,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(160,124,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(161,125,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(162,126,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(163,127,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(164,128,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(165,129,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(166,130,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(167,131,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(168,132,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(169,133,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(170,134,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(171,135,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(172,136,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(173,137,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(174,138,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(175,139,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(176,140,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(177,141,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(178,142,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(179,143,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(180,144,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(181,145,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(182,146,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(183,147,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(184,148,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(185,149,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(186,150,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(187,151,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(188,152,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(189,153,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(190,154,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(191,155,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(192,156,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(193,157,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(194,158,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(195,159,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(196,160,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(197,161,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(198,162,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(199,163,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(200,164,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(201,165,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(202,166,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(203,167,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(204,168,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(205,169,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(206,170,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(207,171,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(208,172,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(209,173,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(210,174,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(211,175,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(212,176,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(213,177,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(214,178,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(215,179,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(216,180,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(217,181,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(218,182,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(219,183,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(220,184,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(221,185,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(222,186,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(223,187,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(224,188,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(225,189,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(226,190,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(227,191,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(228,192,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(229,193,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(230,194,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(231,195,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(232,196,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(233,197,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(234,198,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(235,199,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(236,200,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(237,201,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(238,202,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(239,203,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(240,204,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(241,205,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(242,206,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(243,207,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(244,208,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(245,209,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(246,210,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(247,211,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(248,212,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(249,213,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(250,214,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(251,215,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(252,216,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(253,217,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(254,218,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(255,219,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(256,220,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(257,221,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(258,92,'in_progress','completed',NULL,3,'2026-11-13 12:56:08'),(259,93,'in_progress','completed',NULL,3,'2026-11-13 15:18:21'),(260,38,'in_progress','completed',NULL,3,'2026-11-13 15:19:50'),(261,222,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-14 09:28:54'),(262,223,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-14 11:49:24'),(263,224,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-14 11:52:44'),(264,225,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-14 11:55:08'),(265,29,'scheduled','in_progress',NULL,2,'2026-11-17 10:14:17');
/*!40000 ALTER TABLE `task_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_template_crews`
--

DROP TABLE IF EXISTS `task_template_crews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_template_crews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_version_id` int NOT NULL,
  `crew_id` int NOT NULL,
  `is_preferred` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `template_version_id` (`template_version_id`),
  KEY `crew_id` (`crew_id`),
  CONSTRAINT `task_template_crews_ibfk_1` FOREIGN KEY (`template_version_id`) REFERENCES `task_template_versions` (`id`),
  CONSTRAINT `task_template_crews_ibfk_2` FOREIGN KEY (`crew_id`) REFERENCES `crews` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_template_crews`
--

LOCK TABLES `task_template_crews` WRITE;
/*!40000 ALTER TABLE `task_template_crews` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_template_crews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_template_dependencies`
--

DROP TABLE IF EXISTS `task_template_dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_template_dependencies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_version_id` int NOT NULL,
  `depends_on_template_id` int NOT NULL,
  `dependency_type` varchar(30) NOT NULL,
  `is_required` int DEFAULT NULL,
  `blocks_start` int DEFAULT NULL,
  `description` text,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `template_version_id` (`template_version_id`),
  KEY `depends_on_template_id` (`depends_on_template_id`),
  CONSTRAINT `task_template_dependencies_ibfk_1` FOREIGN KEY (`template_version_id`) REFERENCES `task_template_versions` (`id`),
  CONSTRAINT `task_template_dependencies_ibfk_2` FOREIGN KEY (`depends_on_template_id`) REFERENCES `task_templates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_template_dependencies`
--

LOCK TABLES `task_template_dependencies` WRITE;
/*!40000 ALTER TABLE `task_template_dependencies` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_template_dependencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_template_measurements`
--

DROP TABLE IF EXISTS `task_template_measurements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_template_measurements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_version_id` int NOT NULL,
  `unit_id` int NOT NULL,
  `is_primary` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `template_version_id` (`template_version_id`),
  KEY `unit_id` (`unit_id`),
  CONSTRAINT `task_template_measurements_ibfk_1` FOREIGN KEY (`template_version_id`) REFERENCES `task_template_versions` (`id`),
  CONSTRAINT `task_template_measurements_ibfk_2` FOREIGN KEY (`unit_id`) REFERENCES `measurement_units` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_template_measurements`
--

LOCK TABLES `task_template_measurements` WRITE;
/*!40000 ALTER TABLE `task_template_measurements` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_template_measurements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_template_positions`
--

DROP TABLE IF EXISTS `task_template_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_template_positions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_version_id` int NOT NULL,
  `worker_position_id` int NOT NULL,
  `specialty_id` int DEFAULT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `is_required` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `template_version_id` (`template_version_id`),
  KEY `worker_position_id` (`worker_position_id`),
  KEY `specialty_id` (`specialty_id`),
  CONSTRAINT `task_template_positions_ibfk_1` FOREIGN KEY (`template_version_id`) REFERENCES `task_template_versions` (`id`),
  CONSTRAINT `task_template_positions_ibfk_2` FOREIGN KEY (`worker_position_id`) REFERENCES `worker_positions` (`id`),
  CONSTRAINT `task_template_positions_ibfk_3` FOREIGN KEY (`specialty_id`) REFERENCES `specialties` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_template_positions`
--

LOCK TABLES `task_template_positions` WRITE;
/*!40000 ALTER TABLE `task_template_positions` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_template_positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_template_subtasks`
--

DROP TABLE IF EXISTS `task_template_subtasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_template_subtasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_version_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `display_order` int NOT NULL,
  `is_required` int DEFAULT NULL,
  `weight_percent` decimal(6,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `template_version_id` (`template_version_id`),
  CONSTRAINT `task_template_subtasks_ibfk_1` FOREIGN KEY (`template_version_id`) REFERENCES `task_template_versions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_template_subtasks`
--

LOCK TABLES `task_template_subtasks` WRITE;
/*!40000 ALTER TABLE `task_template_subtasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_template_subtasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_template_versions`
--

DROP TABLE IF EXISTS `task_template_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_template_versions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_template_id` int NOT NULL,
  `version_number` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL,
  `base_quantity` decimal(15,4) DEFAULT NULL,
  `base_duration_days` decimal(10,2) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `task_template_id` (`task_template_id`),
  CONSTRAINT `task_template_versions_ibfk_1` FOREIGN KEY (`task_template_id`) REFERENCES `task_templates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_template_versions`
--

LOCK TABLES `task_template_versions` WRITE;
/*!40000 ALTER TABLE `task_template_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_template_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_templates`
--

DROP TABLE IF EXISTS `task_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `chapter_id` int NOT NULL,
  `zone_id` int DEFAULT NULL,
  `budget_activity_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(100) NOT NULL,
  `description` text,
  `budget_weight_percent` decimal(6,2) DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime DEFAULT NULL,
  `is_fixed` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `chapter_id` (`chapter_id`),
  KEY `zone_id` (`zone_id`),
  KEY `budget_activity_id` (`budget_activity_id`),
  CONSTRAINT `task_templates_ibfk_1` FOREIGN KEY (`chapter_id`) REFERENCES `task_chapters` (`id`),
  CONSTRAINT `task_templates_ibfk_2` FOREIGN KEY (`zone_id`) REFERENCES `task_zones` (`id`),
  CONSTRAINT `task_templates_ibfk_3` FOREIGN KEY (`budget_activity_id`) REFERENCES `task_budget_activities` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_templates`
--

LOCK TABLES `task_templates` WRITE;
/*!40000 ALTER TABLE `task_templates` DISABLE KEYS */;
INSERT INTO `task_templates` VALUES (1,1,NULL,1,'Descapote y Limpieza De Lote Manual','AP-01',NULL,20.00,1,'2026-10-22 15:34:09','2026-10-22 15:37:00',1),(2,1,NULL,1,'Cerramiento En Tela Verde','AP-02',NULL,20.00,1,'2026-10-22 15:35:15','2026-10-22 15:37:00',1),(3,1,NULL,1,'Localización Y Replanteo','AP-03',NULL,20.00,1,'2026-10-22 15:36:08','2026-10-22 15:37:00',1),(4,1,NULL,1,'Campamento','AP-04',NULL,20.00,1,'2026-10-22 15:36:33','2026-10-22 15:37:00',1),(5,1,NULL,1,'Provisionales Electricas y Agua','AP-05',NULL,20.00,1,'2026-10-22 15:37:00','2026-10-22 15:37:00',1),(6,2,1,3,'Zapatas en concreto','EST',NULL,3.23,1,'2026-11-04 14:10:18','2026-11-14 11:54:22',1),(7,2,NULL,3,'Viga de amarre en concreto','02',NULL,3.23,1,'2026-11-04 14:11:00','2026-11-14 11:54:22',1),(8,2,1,3,'Excavación manual','ACT-DFFE425719F5',NULL,3.23,1,'2026-11-05 12:19:53','2026-11-14 11:54:22',1),(9,2,NULL,3,'Excavación mecánica','ACT-6C50F658601E',NULL,3.23,1,'2026-11-05 12:20:17','2026-11-14 11:54:22',1),(10,2,NULL,3,'Relleno compactado','ACT-C24193A28B01',NULL,3.23,1,'2026-11-05 12:21:08','2026-11-14 11:54:22',1),(11,2,1,3,'Perfilada de zapatas','ACT-E17BA2438AF1',NULL,3.23,1,'2026-11-05 12:22:01','2026-11-14 11:54:22',1),(12,2,1,3,'Concreto ciclopeo','ACT-FB861354D6A3',NULL,3.23,1,'2026-11-05 12:22:38','2026-11-14 11:54:22',1),(13,2,NULL,3,'Solados','ACT-FC3E0B3C8818',NULL,3.23,1,'2026-11-05 12:22:57','2026-11-14 11:54:22',1),(14,2,1,3,'Pedestal en concreto','ACT-37CA88393C93',NULL,3.23,1,'2026-11-05 12:23:25','2026-11-14 11:54:22',1),(15,2,NULL,2,'Viga de amarre metalica','ACT-5C4D8051D260',NULL,25.00,1,'2026-11-05 12:23:48','2026-11-05 12:30:20',1),(16,2,NULL,3,'Placa de cimentación en concreto','ACT-B1C18A5B347D',NULL,3.23,1,'2026-11-05 12:24:19','2026-11-14 11:54:22',1),(17,2,NULL,3,'Placa de contrapiso con malla e=0,10max','ACT-26C7817392F7',NULL,3.23,1,'2026-11-05 12:24:59','2026-11-14 11:54:22',1),(18,2,1,3,'Columnas en concreto N1 a N2','ACT-7AA9082D76E7',NULL,3.23,1,'2026-11-05 12:25:15','2026-11-14 11:54:22',1),(19,2,NULL,3,'Pantalla en concreto N1 a N2','ACT-7539BDAA13C0',NULL,3.23,1,'2026-11-05 12:25:37','2026-11-14 11:54:22',1),(20,2,NULL,3,'Escalera en concreto','ACT-35C2E1001486',NULL,3.23,1,'2026-11-05 12:25:51','2026-11-14 11:54:22',1),(21,2,1,2,'Escalera metalica','ACT-0CF60554EA15',NULL,25.00,1,'2026-11-05 12:26:09','2026-11-12 11:36:01',1),(22,2,1,3,'Fundida pasos escalera','ACT-C09D172780F7',NULL,3.23,1,'2026-11-05 12:27:12','2026-11-14 11:54:22',1),(23,2,NULL,3,'Vigas aereas entrepisos','ACT-9E7DBFCA2EBA',NULL,3.23,1,'2026-11-05 12:27:33','2026-11-14 11:54:22',1),(24,2,NULL,3,'Placa entrepiso en concreto','ACT-D9554D381BE6',NULL,3.23,1,'2026-11-05 12:27:54','2026-11-14 11:54:22',1),(25,2,1,3,'Columnas en concreto N2 a N3','ACT-33A0E1B2FBE3',NULL,3.23,1,'2026-11-05 12:28:14','2026-11-14 11:54:22',1),(26,2,NULL,3,'Vigas aereas de cubierta','ACT-76D040F65D56',NULL,3.23,1,'2026-11-05 12:28:31','2026-11-14 11:54:22',1),(27,2,NULL,3,'Placa cubierta en concreto','ACT-C9EB6BCB51BF',NULL,3.23,1,'2026-11-05 12:28:46','2026-11-14 11:54:22',1),(28,2,NULL,3,'Placa de entrepiso con bloque #5','ACT-59DF5E12FC98',NULL,3.23,1,'2026-11-05 12:29:13','2026-11-14 11:54:22',1),(29,2,1,3,'Desencofrado formaleta','ACT-70DB6D5B5170',NULL,3.23,1,'2026-11-05 12:29:43','2026-11-14 11:54:22',1),(30,2,NULL,2,'Columnas en tuberia metalica','ACT-56BF73692887',NULL,25.00,1,'2026-11-05 12:30:04','2026-11-05 12:30:20',1),(31,2,NULL,2,'Vigas en tuberia metalica','ACT-CBCEEFDBE2F0',NULL,25.00,1,'2026-11-05 12:30:20','2026-11-05 12:30:20',1),(32,3,NULL,4,'Excavacion manual','ACT-3A7A74D3E57C',NULL,5.88,1,'2026-11-05 12:31:13','2026-11-05 12:37:40',1),(33,3,NULL,4,'Tapadas de tuberia','ACT-FBD4D97063F2',NULL,5.88,1,'2026-11-05 12:31:22','2026-11-05 12:37:40',1),(34,3,NULL,4,'Caja de inspección','ACT-AC2DB6630CC9',NULL,5.88,1,'2026-11-05 12:31:30','2026-11-05 12:37:40',1),(35,3,NULL,4,'Tuberia sanitaria principal N1','ACT-540AAB7DD24B',NULL,5.88,1,'2026-11-05 12:31:56','2026-11-05 12:37:40',1),(36,3,NULL,4,'Tuberia aguas lluvias principal N1','ACT-1818C6353733',NULL,5.88,1,'2026-11-05 12:32:20','2026-11-05 12:37:40',1),(37,3,NULL,4,'Tuberia presión N1','ACT-6EC3DB1F9222',NULL,5.88,1,'2026-11-05 12:32:51','2026-11-05 12:37:40',1),(38,3,NULL,4,'Puntos desagües sanitarios N1','ACT-87C172044548',NULL,5.88,1,'2026-11-05 12:33:43','2026-11-05 12:37:40',1),(39,3,NULL,4,'Bajantes sanitarios','ACT-F237B708E739',NULL,5.88,1,'2026-11-05 12:34:00','2026-11-05 12:37:40',1),(40,3,NULL,4,'Bajantes aguas lluvias','ACT-6D676FA69203',NULL,5.88,1,'2026-11-05 12:34:13','2026-11-05 12:37:40',1),(41,3,NULL,4,'Tuberia sanitaria descolgada placa','ACT-7EC5614C34C1',NULL,5.88,1,'2026-11-05 12:34:37','2026-11-05 12:37:40',1),(42,3,NULL,4,'Puntos desagües sanitarios N2','ACT-CE253EB3ACA2',NULL,5.88,1,'2026-11-05 12:34:57','2026-11-05 12:37:40',1),(43,3,NULL,4,'Tuberia Hidraulica Vertical','ACT-4258E23C6E36',NULL,5.88,1,'2026-11-05 12:35:33','2026-11-05 12:37:40',1),(44,3,NULL,4,'Puntos hidraulicos agua fria','ACT-8E6974F1C5BD',NULL,5.88,1,'2026-11-05 12:36:05','2026-11-05 12:37:40',1),(45,3,NULL,4,'Puntos hidraulicos agua caliente','ACT-42560A9BA889',NULL,5.88,1,'2026-11-05 12:36:10','2026-11-05 12:37:40',1),(46,3,NULL,4,'Instalación de tanques + pruebas','ACT-8CF275B5C09D',NULL,5.88,1,'2026-11-05 12:36:36','2026-11-05 12:38:00',1),(47,3,NULL,4,'Instalación sistema de bombeo tanque subt','ACT-359A4B253860',NULL,5.88,1,'2026-11-05 12:36:58','2026-11-05 12:38:21',1),(48,3,2,4,'Instalación sistema de bombeo piscina','ACT-9366BD1536F4',NULL,5.88,1,'2026-11-05 12:37:40','2026-11-05 12:38:38',1),(49,4,NULL,5,'Tendido de tuberia eléctrica','ACT-0FBC1AA39689',NULL,12.50,1,'2026-11-05 23:32:23','2026-11-05 23:36:58',1),(50,4,NULL,5,'Regatas y/o cajas eléctricas','ACT-3DF5A415A378',NULL,12.50,1,'2026-11-05 23:33:37','2026-11-05 23:36:58',1),(51,4,NULL,5,'Instalación cajas y accesorios','ACT-3A9C6099AFE3',NULL,12.50,1,'2026-11-05 23:34:32','2026-11-05 23:36:58',1),(52,4,NULL,5,'Tendido cableado eléctrico','ACT-47E4E678BD3A',NULL,12.50,1,'2026-11-05 23:34:56','2026-11-05 23:36:58',1),(53,4,NULL,5,'Instalación de tablero','ACT-A6C814E64A83',NULL,12.50,1,'2026-11-05 23:35:15','2026-11-05 23:36:58',1),(54,4,NULL,5,'Instalación tomacorrientes-interruptores','ACT-42E464CF4F56',NULL,12.50,1,'2026-11-05 23:35:38','2026-11-05 23:36:58',1),(55,4,NULL,5,'Instalación luminarias','ACT-E7DEB17396E2',NULL,12.50,1,'2026-11-05 23:36:00','2026-11-05 23:36:58',1),(56,4,NULL,5,'Conexiones & puesta en funcionamiento','ACT-E7A9E9BCF5B3',NULL,12.50,1,'2026-11-05 23:36:58','2026-11-05 23:36:58',1),(57,5,NULL,6,'Muro en ladrillo de obra sencillo','ACT-A16D08BF5335',NULL,9.09,1,'2026-11-06 13:11:52','2026-11-06 13:14:36',1),(58,5,NULL,6,'Muro en ladrillo de obra doble','ACT-7ADDCE5131B4',NULL,9.09,1,'2026-11-06 13:12:12','2026-11-06 13:14:36',1),(59,5,NULL,6,'Muro en bloque #5 1er piso','ACT-A278A63DFBE1',NULL,9.09,1,'2026-11-06 13:12:35','2026-11-06 13:14:36',1),(60,5,NULL,6,'Muro en bloque #5 2do piso','ACT-161B0A86F2FD',NULL,9.09,1,'2026-11-06 13:12:45','2026-11-06 13:14:36',1),(61,5,NULL,6,'Muro en bloque #5 culatas','ACT-C4F8EEC5B5BE',NULL,9.09,1,'2026-11-06 13:13:02','2026-11-06 13:14:36',1),(62,5,NULL,6,'Dinteles en varilla','ACT-A132BA4526F1',NULL,9.09,1,'2026-11-06 13:13:24','2026-11-06 13:14:36',1),(63,5,NULL,6,'Muro bloque cemento e=0,09','ACT-DB066DCA4071',NULL,9.09,1,'2026-11-06 13:13:45','2026-11-06 13:14:36',1),(64,5,NULL,6,'Muro bloque cemento e=0,12','ACT-52BE786ACFBC',NULL,9.09,1,'2026-11-06 13:13:50','2026-11-06 13:14:36',1),(65,5,NULL,6,'Muro bloque cemento e=0,20','ACT-66E7714BC9FA',NULL,9.09,1,'2026-11-06 13:13:59','2026-11-06 13:14:36',1),(66,5,NULL,6,'Columneta de confinamiento bloque','ACT-38180AAF2BE5',NULL,9.09,1,'2026-11-06 13:14:14','2026-11-06 13:14:36',1),(67,5,NULL,6,'Relleno celdas bloque estructural','ACT-251C385964BE',NULL,9.09,1,'2026-11-06 13:14:36','2026-11-06 13:14:36',1),(68,5,NULL,7,'Pañete de muros internos','ACT-DD3D398204C0',NULL,12.50,1,'2026-11-06 13:15:02','2026-11-06 13:16:29',1),(69,5,NULL,7,'Pañete de muros fachada','ACT-149B7B7E53CA',NULL,12.50,1,'2026-11-06 13:15:11','2026-11-06 13:16:29',1),(70,5,NULL,7,'Pañete de placas','ACT-04FE675ADC91',NULL,12.50,1,'2026-11-06 13:15:25','2026-11-06 13:16:29',1),(71,5,NULL,7,'Pañete de placas fachada','ACT-5BD4F6D539C3',NULL,12.50,1,'2026-11-06 13:15:39','2026-11-06 13:16:29',1),(72,5,NULL,7,'Goteros en borde de placas','ACT-FE43ED8BCF2D',NULL,12.50,1,'2026-11-06 13:15:49','2026-11-06 13:16:29',1),(73,5,NULL,7,'Dilataciones en pañetes','ACT-7F7797F712A5',NULL,12.50,1,'2026-11-06 13:16:08','2026-11-06 13:16:29',1),(74,5,NULL,7,'Filos en pañetes','ACT-5F259136406F',NULL,12.50,1,'2026-11-06 13:16:15','2026-11-06 13:16:29',1),(75,5,NULL,7,'Media caña cubiertas','ACT-9C1DA281E48A',NULL,12.50,1,'2026-11-06 13:16:29','2026-11-06 13:16:29',1),(76,5,NULL,8,'Muro sencillo en drywall','ACT-BF3840FA5363',NULL,25.00,1,'2026-11-06 13:16:50','2026-11-06 13:17:28',1),(77,5,NULL,8,'Muro doble en drywall','ACT-92608B0D6153',NULL,25.00,1,'2026-11-06 13:17:01','2026-11-06 13:17:28',1),(78,5,NULL,8,'Muro doble en superboard','ACT-F707FB6BC4A5',NULL,25.00,1,'2026-11-06 13:17:14','2026-11-06 13:17:28',1),(79,5,NULL,8,'Dilataciones en z muro','ACT-4F161C2AFAD0',NULL,25.00,1,'2026-11-06 13:17:28','2026-11-06 13:17:28',1),(80,6,NULL,9,'Mortero nivelación de cubiertas','ACT-F0BFA6A0A5CA',NULL,20.00,1,'2026-11-07 09:56:00','2026-11-07 09:57:47',1),(81,6,NULL,9,'Impermeabilización de cubiertas','ACT-BA9CE27DE45A',NULL,20.00,1,'2026-11-07 09:56:31','2026-11-07 09:57:47',1),(82,6,NULL,9,'Cubiertas en cielo raso drywall','ACT-BC563B33AE56',NULL,20.00,1,'2026-11-07 09:57:05','2026-11-07 09:57:47',1),(83,6,NULL,9,'Inst. cubierta tipo sandwich','ACT-09A3F789672A',NULL,20.00,1,'2026-11-07 09:57:29','2026-11-07 09:57:47',1),(84,6,NULL,9,'Domos en placa cubierta','ACT-EECA917C79E0',NULL,20.00,1,'2026-11-07 09:57:47','2026-11-07 09:57:47',1),(85,6,NULL,10,'Mortero nivelación de pisos','ACT-8DDFB3A2AEB0',NULL,8.33,1,'2026-11-07 09:58:20','2026-11-07 10:03:00',1),(86,6,NULL,10,'Enchape de piso en cerámica','ACT-80FF957F8363',NULL,8.33,1,'2026-11-07 09:58:35','2026-11-07 10:03:00',1),(87,6,NULL,10,'Enchape de piso en porcelanato','ACT-89426BE639AA',NULL,8.33,1,'2026-11-07 09:58:54','2026-11-07 10:03:00',1),(88,6,NULL,10,'Enchape de escalera biselada','ACT-B773EC35E5A1',NULL,8.33,1,'2026-11-07 09:59:46','2026-11-07 10:03:00',1),(89,6,NULL,10,'Guardaescobas en cerámica','ACT-CA176BDB87C3',NULL,8.33,1,'2026-11-07 10:00:08','2026-11-07 10:03:00',1),(90,6,NULL,10,'Guardaescobas en porcelanato','ACT-EB6970B67B2F',NULL,8.33,1,'2026-11-07 10:00:41','2026-11-07 10:03:00',1),(91,6,NULL,10,'Anden piso en adoquin','ACT-0252B14FA273',NULL,8.33,1,'2026-11-07 10:01:04','2026-11-11 15:51:00',1),(92,6,2,10,'Piso zona verde','ACT-A0194E3C127A',NULL,8.33,1,'2026-11-07 10:01:26','2026-11-07 10:03:00',1),(93,6,NULL,10,'Enchape de muro en cerámica','ACT-1D6CABFC49E8',NULL,8.33,1,'2026-11-07 10:01:56','2026-11-07 10:03:00',1),(94,6,NULL,10,'Enchape de muro en porcelanato','ACT-117B5E7C18DC',NULL,8.33,1,'2026-11-07 10:02:05','2026-11-07 10:03:00',1),(95,6,NULL,10,'Biselada de enchape muro','ACT-5B5FF702906F',NULL,8.33,1,'2026-11-07 10:02:32','2026-11-07 10:03:00',1),(96,6,NULL,10,'Instalación de rejillas de piso','ACT-6D7F0ED4646B',NULL,8.33,1,'2026-11-07 10:03:00','2026-11-07 10:03:00',1),(97,6,NULL,11,'Ventaneria en aluminio y vidrio','ACT-5C626A83F02B',NULL,25.00,1,'2026-11-07 10:03:46','2026-11-07 10:05:01',1),(98,6,NULL,11,'Puerta correderas en aluminio y vidrio','ACT-1211B864EBF3',NULL,25.00,1,'2026-11-07 10:04:14','2026-11-07 10:05:01',1),(99,6,NULL,11,'División de baños en vidrio templado','ACT-95B3150F5C69',NULL,25.00,1,'2026-11-07 10:04:47','2026-11-07 10:05:01',1),(100,6,NULL,11,'Pasamanos en vidrio templado','ACT-9D5295951FF0',NULL,25.00,1,'2026-11-07 10:05:01','2026-11-07 10:05:01',1),(101,6,NULL,12,'Puertas de madera general','ACT-217D3D43BBAD',NULL,20.00,1,'2026-11-07 10:05:32','2026-11-07 10:07:16',1),(102,6,NULL,12,'Mueble de baño madera lavamanos','ACT-CB84DF025AF7',NULL,20.00,1,'2026-11-07 10:05:51','2026-11-07 10:07:16',1),(103,6,NULL,12,'Mueble de cocina madera bajo & alto','ACT-E87287159D77',NULL,20.00,1,'2026-11-07 10:06:39','2026-11-07 10:07:16',1),(104,6,NULL,12,'Closets de madera','ACT-DAE67C43FF39',NULL,20.00,1,'2026-11-07 10:06:52','2026-11-07 10:07:16',1),(105,6,NULL,12,'Cubierta metálica en cerchas','ACT-B081FC71B684',NULL,20.00,1,'2026-11-07 10:07:16','2026-11-07 10:07:16',1),(106,6,NULL,13,'Ventanas en aluminio','ACT-CEACC111AD4A',NULL,25.00,1,'2026-11-07 10:08:11','2026-11-07 10:09:19',1),(107,6,NULL,13,'Portones corredizos metálicos','ACT-36D1E04E635B',NULL,25.00,1,'2026-11-07 10:08:41','2026-11-07 10:09:19',1),(108,6,NULL,13,'Estructura Métalica soporte superboard','ACT-CA933C34AA3E',NULL,25.00,1,'2026-11-07 10:09:07','2026-11-07 10:09:19',1),(109,6,NULL,13,'Estructura metálica de cubiertas','ACT-6ECC9ED11A06',NULL,25.00,1,'2026-11-07 10:09:19','2026-11-07 10:09:19',1),(110,6,NULL,14,'Instalación aparatos de baños','ACT-1C88AEDBFA05',NULL,20.00,1,'2026-11-07 10:36:44','2026-11-07 10:37:48',1),(111,6,NULL,14,'Instalación duchas','ACT-173296515AC1',NULL,20.00,1,'2026-11-07 10:37:01','2026-11-07 10:37:48',1),(112,6,NULL,14,'Instalación accesorios baño','ACT-98946524E3D0',NULL,20.00,1,'2026-11-07 10:37:17','2026-11-07 10:37:48',1),(113,6,NULL,14,'Instalación Lavadero','ACT-E6D7A01A87D0',NULL,20.00,1,'2026-11-07 10:37:34','2026-11-07 10:37:48',1),(114,6,NULL,14,'Instalación Lavaplatos','ACT-E060134F0E0A',NULL,20.00,1,'2026-11-07 10:37:48','2026-11-07 10:37:48',1),(115,6,NULL,17,'Instalación horno cocina','ACT-96BA6EFE6042',NULL,20.00,1,'2026-11-07 10:41:01','2026-11-07 10:41:59',1),(116,6,NULL,17,'Instalación estufa','ACT-72FB9BF2E78D',NULL,20.00,1,'2026-11-07 10:41:16','2026-11-07 10:41:59',1),(117,6,NULL,17,'Instalación campana cocina','ACT-FBA1A9F48FD8',NULL,20.00,1,'2026-11-07 10:41:26','2026-11-07 10:41:59',1),(118,6,NULL,17,'Meson de cocina en material seleccionado','ACT-EAE21AD980D1',NULL,20.00,1,'2026-11-07 10:41:45','2026-11-07 10:41:59',1),(119,6,NULL,17,'Barra de cocina en material seleccionado','ACT-A0CF9A8C5611',NULL,20.00,1,'2026-11-07 10:41:59','2026-11-07 10:41:59',1),(120,2,1,3,'Figuracion de Acero Zapatas','ACT-5B291B58E7A7',NULL,3.23,1,'2026-11-07 11:00:06','2026-11-14 11:54:22',1),(121,6,NULL,15,'Revestimiento de muros internos (pasta-pintura)','ACT-7B7A625EFAB4',NULL,50.00,1,'2026-11-09 10:50:09','2026-11-09 10:50:24',1),(122,6,NULL,15,'Revestimiento de muros fachada (pasta-pintura ext)','ACT-71A625488FA6',NULL,50.00,1,'2026-11-09 10:50:24','2026-11-09 10:50:24',1),(123,6,NULL,16,'Revestimiento en superboard','ACT-CC893BF7917A',NULL,50.00,1,'2026-11-09 10:50:42','2026-11-09 10:51:45',1),(124,6,NULL,16,'Revestimiento en aluminio compuesto','ACT-CB6D0CA47A09',NULL,50.00,1,'2026-11-09 10:51:45','2026-11-09 10:51:45',1),(125,2,1,3,'Figuracion Acero Pedestal','ACT-4A25BD2135CD',NULL,3.23,1,'2026-11-11 16:29:30','2026-11-14 11:54:22',1),(126,2,2,3,'Figuracion placa de piso Tanque','ACT-15AF95B052DE',NULL,3.23,1,'2026-11-11 16:34:28','2026-11-14 11:54:22',1),(127,2,2,3,'Placa de cimentacion en concreto Tanque','ACT-7B2975F01CC2',NULL,3.23,1,'2026-11-12 11:00:15','2026-11-14 11:54:22',1),(128,2,1,3,'Figuracion Acero Viga de Amarre','ACT-AB0428EAF6DD',NULL,3.23,1,'2026-11-12 11:58:20','2026-11-14 11:54:22',0),(129,2,1,3,'Figuracion Vigas de Amarre','ACT-5C26FCFEB5AD',NULL,3.23,1,'2026-11-14 09:28:10','2026-11-14 11:54:22',1),(130,2,1,3,'Excavacion Manual Viga de Amarre','ACT-F24DF71411BD',NULL,3.23,1,'2026-11-14 11:48:27','2026-11-14 11:54:22',1),(131,2,1,3,'Solado Vigas de Amarre','ACT-8E876DA39C31',NULL,3.23,1,'2026-11-14 11:52:26','2026-11-14 11:54:22',1),(132,2,2,3,'Zapatas Muro Cerramiento Posterior','ACT-414AF4CEA8B2',NULL,3.23,1,'2026-11-14 11:54:22','2026-11-14 11:54:22',1);
/*!40000 ALTER TABLE `task_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_zones`
--

DROP TABLE IF EXISTS `task_zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_zones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `description` text,
  `display_order` int NOT NULL,
  `is_active` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime DEFAULT NULL,
  `weight_percent` decimal(6,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_zones`
--

LOCK TABLES `task_zones` WRITE;
/*!40000 ALTER TABLE `task_zones` DISABLE KEYS */;
INSERT INTO `task_zones` VALUES (1,'Casa',NULL,0,1,'2026-11-05 12:17:04','2026-11-11 15:50:41',70.00),(2,'Zona social',NULL,0,1,'2026-11-05 12:17:08','2026-11-11 15:50:50',30.00);
/*!40000 ALTER TABLE `task_zones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `obra_id` int NOT NULL,
  `source_template_id` int DEFAULT NULL,
  `source_template_version_id` int DEFAULT NULL,
  `parent_task_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `unit_id` int DEFAULT NULL,
  `planned_quantity` decimal(15,4) DEFAULT NULL,
  `template_base_quantity` decimal(15,4) DEFAULT NULL,
  `template_base_duration_days` decimal(10,2) DEFAULT NULL,
  `estimated_duration_days` decimal(10,2) DEFAULT NULL,
  `approved_duration_days` decimal(10,2) DEFAULT NULL,
  `planned_start_date` date DEFAULT NULL,
  `planned_end_date` date DEFAULT NULL,
  `actual_start_date` date DEFAULT NULL,
  `actual_end_date` date DEFAULT NULL,
  `status` varchar(30) NOT NULL,
  `weight_percent` decimal(6,2) DEFAULT NULL,
  `budget_weight_percent` decimal(6,2) DEFAULT NULL,
  `created_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `chapter_id` int DEFAULT NULL,
  `budget_activity_id` int DEFAULT NULL,
  `zone_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_tasks_uuid` (`uuid`),
  KEY `obra_id` (`obra_id`),
  KEY `source_template_id` (`source_template_id`),
  KEY `source_template_version_id` (`source_template_version_id`),
  KEY `parent_task_id` (`parent_task_id`),
  KEY `unit_id` (`unit_id`),
  KEY `created_by` (`created_by`),
  KEY `updated_by` (`updated_by`),
  KEY `fk_tasks_chapter` (`chapter_id`),
  KEY `fk_tasks_budget_activity` (`budget_activity_id`),
  KEY `fk_tasks_zone` (`zone_id`),
  CONSTRAINT `fk_tasks_budget_activity` FOREIGN KEY (`budget_activity_id`) REFERENCES `task_budget_activities` (`id`),
  CONSTRAINT `fk_tasks_chapter` FOREIGN KEY (`chapter_id`) REFERENCES `task_chapters` (`id`),
  CONSTRAINT `fk_tasks_zone` FOREIGN KEY (`zone_id`) REFERENCES `task_zones` (`id`),
  CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`),
  CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`source_template_id`) REFERENCES `task_templates` (`id`),
  CONSTRAINT `tasks_ibfk_3` FOREIGN KEY (`source_template_version_id`) REFERENCES `task_template_versions` (`id`),
  CONSTRAINT `tasks_ibfk_4` FOREIGN KEY (`parent_task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `tasks_ibfk_5` FOREIGN KEY (`unit_id`) REFERENCES `measurement_units` (`id`),
  CONSTRAINT `tasks_ibfk_6` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `tasks_ibfk_7` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=226 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` VALUES (1,'b0a96730-aea8-4eb2-acf0-c180f71e2fc8',2,1,NULL,NULL,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-10-26','2026-10-31','2026-10-27',NULL,'in_progress',NULL,20.00,2,'2026-10-22 16:05:02',1,'2026-10-27 16:07:54',1,1,NULL),(2,'7bf9a207-036f-4b9d-a764-7430029cab28',2,2,NULL,NULL,'Cerramiento En Tela Verde',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-10-26','2026-10-31','2026-10-22','2026-10-22','verified',NULL,20.00,2,'2026-10-22 16:05:02',1,'2026-10-22 16:41:52',1,1,NULL),(3,'6b869982-5bc1-4dec-b36c-4fb5ac70215a',2,3,NULL,NULL,'Localización Y Replanteo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-10-26','2026-10-31','2026-10-22','2026-10-22','verified',NULL,20.00,2,'2026-10-22 16:05:02',1,'2026-10-22 16:15:13',1,1,NULL),(4,'8a766214-6119-4aa1-a1f0-a6924e716cc9',2,NULL,NULL,NULL,'jsjsjs','wwww',NULL,NULL,NULL,NULL,NULL,NULL,'2026-10-26','2026-10-31','2026-10-22','2026-10-22','scheduled',NULL,NULL,2,'2026-10-22 16:13:35',NULL,'2026-10-22 16:16:02',NULL,NULL,NULL),(5,'f5e08407-6b16-428b-a137-1624e00736cb',2,4,NULL,NULL,'Campamento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'scheduled',NULL,20.00,3,'2026-10-30 18:31:01',NULL,NULL,1,1,NULL),(6,'28f33c88-69b6-41ab-aed8-ad294c22fb58',4,3,NULL,NULL,'Localización Y Replanteo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-04',NULL,'in_progress',NULL,20.00,3,'2026-11-04 13:51:31',NULL,'2026-11-04 13:53:34',1,1,NULL),(7,'643941d6-0720-4ba1-9fe8-a09cfd36d315',4,4,NULL,NULL,'Campamento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-04','2026-11-04','completed',NULL,20.00,3,'2026-11-04 13:51:31',NULL,'2026-11-04 13:54:01',1,1,NULL),(8,'0ebb6ed0-56ac-439c-9059-9c605e145047',4,5,NULL,NULL,'Provisionales Electricas y Agua',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-04 13:51:31',NULL,NULL,1,1,NULL),(9,'5a788dd7-fe80-474f-a3d7-2d0d5204bb11',4,2,NULL,NULL,'Cerramiento En Tela Verde',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-05 12:13:29',NULL,NULL,1,1,NULL),(10,'9bf164fc-a6a6-4595-8979-dc7cd55e6d3c',4,1,NULL,NULL,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-05 12:13:40',NULL,NULL,1,1,NULL),(11,'63acf77a-d7b9-4230-b715-72520b8b0821',5,4,NULL,NULL,'Campamento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,20.00,2,'2026-11-07 10:47:47',2,'2026-11-07 15:54:12',1,1,NULL),(12,'5bb820f0-a0b1-4463-9673-bfefafcae2d8',5,1,NULL,NULL,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,20.00,2,'2026-11-07 10:47:47',2,'2026-11-07 15:54:54',1,1,NULL),(13,'fd865679-0c6f-4cfb-ae4e-29949300fea1',5,3,NULL,NULL,'Localización Y Replanteo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,20.00,2,'2026-11-07 10:47:47',NULL,'2026-11-07 10:49:05',1,1,NULL),(14,'10141006-693f-411b-a5aa-9fdc0b502eff',5,9,NULL,NULL,'Excavación mecánica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,4.55,2,'2026-11-07 10:51:31',2,'2026-11-07 15:58:39',2,3,NULL),(15,'508084da-8bf1-4b8f-81cb-85d3b80318f7',5,11,NULL,NULL,'Perfilada de zapatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,4.55,2,'2026-11-07 10:51:46',NULL,'2026-11-12 11:36:41',2,3,1),(16,'c9d8b43a-3c7a-4979-a9a3-659b16e9ecd6',5,13,NULL,NULL,'Solados',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,4.55,2,'2026-11-07 10:52:02',2,'2026-11-07 16:00:52',2,3,NULL),(17,'eafe6e5a-9372-4d70-a351-9186fcfb246f',5,120,NULL,NULL,'Figuracion de Acero Zapatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-07','2026-11-11','completed',NULL,3.70,2,'2026-11-07 11:00:23',2,'2026-11-13 15:19:04',2,3,1),(18,'6f012618-f9cd-441c-88e1-4a4b75f692a0',5,8,NULL,NULL,'Excavación manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-07 11:25:17',NULL,'2026-11-12 11:36:10',2,3,1),(19,'0fa6ce8c-553a-44bb-a1af-11732c93b79c',5,5,NULL,NULL,'Provisionales Electricas y Agua',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21','2026-11-11',NULL,'in_progress',NULL,20.00,2,'2026-11-07 11:28:22',3,'2026-11-14 11:45:03',1,1,NULL),(20,'844ea6cc-2aac-4d28-8489-dab09941e49b',5,10,NULL,NULL,'Relleno compactado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,2,'2026-11-07 11:36:24',NULL,NULL,2,3,NULL),(22,'3e1dace8-441a-434d-b777-99a202c90474',5,18,NULL,NULL,'Columnas en concreto N1 a N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:03:28',NULL,'2026-11-12 11:35:12',2,3,1),(23,'77928c36-0753-44b1-9e02-b009fd4b1eeb',5,25,NULL,NULL,'Columnas en concreto N2 a N3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:03:39',NULL,'2026-11-12 11:35:18',2,3,1),(24,'a0212e91-aa9c-4c79-8479-0871dcb42d11',5,12,NULL,NULL,'Concreto ciclopeo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:03:48',NULL,'2026-11-12 11:35:33',2,3,1),(25,'9bd38ca7-8a6f-4287-b230-8fe9b7ccaec1',5,29,NULL,NULL,'Desencofrado formaleta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:03:58',NULL,'2026-11-12 11:35:44',2,3,1),(27,'ce871162-9745-479b-89f4-32a9dc69e6d1',5,22,NULL,NULL,'Fundida pasos escalera',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:04:19',NULL,'2026-11-12 11:36:27',2,3,1),(29,'33e8b37e-da94-42c5-a79f-c5d880c060cf',5,14,NULL,NULL,'Pedestal en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21','2026-11-17',NULL,'in_progress',NULL,4.35,1,'2026-11-09 14:04:35',2,'2026-11-17 15:15:46',2,3,NULL),(30,'0a37e5ec-9268-4f6b-b895-096a8b91441b',5,27,NULL,NULL,'Placa cubierta en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:04:48',NULL,NULL,2,3,NULL),(31,'4fd38ba9-8711-4f01-bb77-ed489f923aca',5,16,NULL,NULL,'Placa de cimentación en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:04:58',NULL,NULL,2,3,NULL),(32,'39a7f3ac-fd89-45d0-a58a-bf5a3af86a7a',5,17,NULL,NULL,'Placa de contrapiso con malla e=0,10max',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:08',NULL,NULL,2,3,NULL),(34,'c7ae1f61-e2c4-41e4-8353-60a562b9be84',5,24,NULL,NULL,'Placa entrepiso en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:31',NULL,NULL,2,3,NULL),(35,'d52a2924-f5f3-445b-a82a-c6e078e79e17',5,7,NULL,NULL,'Viga de amarre en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:39',NULL,NULL,2,3,NULL),(36,'3fc10519-2788-4556-80ab-d6cd4ce77504',5,26,NULL,NULL,'Vigas aereas de cubierta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:47',NULL,NULL,2,3,NULL),(37,'67d57783-4410-423b-a33a-428685e50ba5',5,23,NULL,NULL,'Vigas aereas entrepisos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:57',NULL,NULL,2,3,NULL),(38,'3bbe1d27-00d4-43e1-8b1b-747a09a69604',5,6,NULL,NULL,'Zapatas en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-12','2026-11-13','completed',NULL,3.70,1,'2026-11-09 14:06:06',3,'2026-11-13 20:19:52',2,3,1),(40,'94488b93-0831-41b0-9938-34fda1b5000e',5,21,NULL,NULL,'Escalera metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:06:28',NULL,'2026-11-12 11:36:01',2,2,1),(43,'71175166-2543-49ac-9094-2222728b7518',5,56,NULL,NULL,'Conexiones & puesta en funcionamiento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:02',NULL,NULL,4,5,NULL),(44,'730ba365-1429-4ef3-83e4-09915da466a1',5,51,NULL,NULL,'Instalación cajas y accesorios',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:10',NULL,NULL,4,5,NULL),(45,'dd0890a1-1566-4b3a-8e07-e2335cb1532c',5,53,NULL,NULL,'Instalación de tablero',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:18',NULL,NULL,4,5,NULL),(46,'060b8f41-0172-441c-a6af-76447a38258b',5,55,NULL,NULL,'Instalación luminarias',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:27',NULL,NULL,4,5,NULL),(47,'a35895d4-8477-490c-a6bc-6ea5e2257428',5,54,NULL,NULL,'Instalación tomacorrientes-interruptores',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:35',NULL,NULL,4,5,NULL),(48,'7ff1c706-52b0-4730-81ba-af26165d97bc',5,50,NULL,NULL,'Regatas y/o cajas eléctricas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:43',NULL,NULL,4,5,NULL),(49,'ed03839a-85ad-4eab-9a23-cc18aec5cdf4',5,52,NULL,NULL,'Tendido cableado eléctrico',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:52',NULL,NULL,4,5,NULL),(50,'b5b06f2f-921d-421d-903a-7498ac621141',5,49,NULL,NULL,'Tendido de tuberia eléctrica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:59',NULL,NULL,4,5,NULL),(51,'aa4b047d-4465-4b85-bf4b-4052725e272e',5,40,NULL,NULL,'Bajantes aguas lluvias',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:13',NULL,NULL,3,4,NULL),(52,'77e570cd-be23-4777-96df-a3b570d404f1',5,39,NULL,NULL,'Bajantes sanitarios',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:22',NULL,NULL,3,4,NULL),(53,'d6b56339-48ed-4d74-94af-66bea5175f2b',5,34,NULL,NULL,'Caja de inspección',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:33',NULL,NULL,3,4,NULL),(54,'d3849576-3278-41c5-b807-e459f7e2b443',5,32,NULL,NULL,'Excavacion manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:42',NULL,NULL,3,4,NULL),(55,'88513207-cb70-4cfa-8af9-c936445d888e',5,46,NULL,NULL,'Instalación de tanques + pruebas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:54',NULL,NULL,3,4,NULL),(56,'84a39d58-ca63-447b-a5e7-2637f45eaae9',5,48,NULL,NULL,'Instalación sistema de bombeo piscina',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:04',NULL,NULL,3,4,2),(57,'62593b5b-7a62-48c9-9c17-2ca354c97c6a',5,47,NULL,NULL,'Instalación sistema de bombeo tanque subt',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:12',NULL,NULL,3,4,NULL),(58,'db7fb0e6-53a5-41e3-9df5-68ef80a82848',5,38,NULL,NULL,'Puntos desagües sanitarios N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:22',NULL,NULL,3,4,NULL),(59,'e22b9dc6-c006-48c8-a937-d40767562a19',5,42,NULL,NULL,'Puntos desagües sanitarios N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:32',NULL,NULL,3,4,NULL),(60,'e3ba924f-d622-44ff-a340-0d436875598a',5,45,NULL,NULL,'Puntos hidraulicos agua caliente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:41',NULL,NULL,3,4,NULL),(61,'8011e185-473d-4496-9438-8801cbe0330b',5,44,NULL,NULL,'Puntos hidraulicos agua fria',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:50',NULL,NULL,3,4,NULL),(62,'eba10900-d3b0-41aa-b891-05b4634ce96c',5,33,NULL,NULL,'Tapadas de tuberia',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:58',NULL,NULL,3,4,NULL),(63,'6d38c60b-bf7e-455e-8cce-0ccd6f61519f',5,36,NULL,NULL,'Tuberia aguas lluvias principal N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:08',NULL,NULL,3,4,NULL),(64,'ca24b77d-8aa2-47e0-8b0c-76f705e0329e',5,43,NULL,NULL,'Tuberia Hidraulica Vertical',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:16',NULL,NULL,3,4,NULL),(65,'f0185067-16fa-40c9-b1e1-c6df212c394b',5,37,NULL,NULL,'Tuberia presión N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:26',NULL,NULL,3,4,NULL),(66,'2f868052-0f0e-4c03-9c41-2567ab8a7784',5,41,NULL,NULL,'Tuberia sanitaria descolgada placa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:34',NULL,NULL,3,4,NULL),(67,'6313faa0-7067-4910-8fde-228e9a189b35',5,35,NULL,NULL,'Tuberia sanitaria principal N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:42',NULL,NULL,3,4,NULL),(68,'3bdfcbd5-6e8d-4dc5-a42a-b2a06ecb016f',5,66,NULL,NULL,'Columneta de confinamiento bloque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:12',NULL,NULL,5,6,NULL),(69,'a7339fee-7c28-4b64-abda-d4b47e8b804b',5,62,NULL,NULL,'Dinteles en varilla',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:20',NULL,NULL,5,6,NULL),(70,'dcd4c300-458f-4b27-8934-dd9ce4d16b9f',5,63,NULL,NULL,'Muro bloque cemento e=0,09',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:28',NULL,NULL,5,6,NULL),(71,'c1aef9ac-c795-4b51-aa8a-59fb5fa082bb',5,64,NULL,NULL,'Muro bloque cemento e=0,12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:36',NULL,NULL,5,6,NULL),(72,'eaa2ac32-bdae-47ec-bb23-7e2261246de4',5,65,NULL,NULL,'Muro bloque cemento e=0,20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:47',NULL,NULL,5,6,NULL),(73,'f5d1d0cf-1172-49bb-9244-2c202c7bfc88',5,59,NULL,NULL,'Muro en bloque #5 1er piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:57',NULL,NULL,5,6,NULL),(74,'55e48662-d4eb-47b8-8910-75cded314d07',5,60,NULL,NULL,'Muro en bloque #5 2do piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:06',NULL,NULL,5,6,NULL),(75,'12bff2b9-6f1d-4bfa-a0a3-36252ff468cd',5,61,NULL,NULL,'Muro en bloque #5 culatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:15',NULL,NULL,5,6,NULL),(76,'db7e1608-8d84-4358-be6b-83ce293cbde3',5,58,NULL,NULL,'Muro en ladrillo de obra doble',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:25',NULL,NULL,5,6,NULL),(77,'a682884c-4392-425b-8f32-0d3f2002c28b',5,57,NULL,NULL,'Muro en ladrillo de obra sencillo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:33',NULL,NULL,5,6,NULL),(78,'d47e01d7-bb00-4b1d-a22d-0775e9b41858',5,67,NULL,NULL,'Relleno celdas bloque estructural',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:41',NULL,NULL,5,6,NULL),(79,'9e4ea398-9cf4-461c-8ce4-fafc92bdbe23',5,79,NULL,NULL,'Dilataciones en z muro',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:12:51',NULL,NULL,5,8,NULL),(80,'1c9f9dec-f7b0-4ecc-b6d7-53df94c57fe0',5,77,NULL,NULL,'Muro doble en drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:13:00',NULL,NULL,5,8,NULL),(81,'8a35e155-b399-49f7-bf7a-85bb0e16b4a9',5,78,NULL,NULL,'Muro doble en superboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:13:07',NULL,NULL,5,8,NULL),(82,'19f0bc71-0bfc-4382-8cc7-cb7fed2c71f2',5,76,NULL,NULL,'Muro sencillo en drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:13:14',NULL,NULL,5,8,NULL),(83,'d32cd1cd-5034-42fc-97b9-beefdcd02720',5,73,NULL,NULL,'Dilataciones en pañetes',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:13:26',NULL,NULL,5,7,NULL),(84,'f3baae15-c30a-4ab8-8e23-fb2b06d45a6e',5,74,NULL,NULL,'Filos en pañetes',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:13:34',NULL,NULL,5,7,NULL),(85,'6eb5f635-34eb-493d-bd47-4817dec8149c',5,72,NULL,NULL,'Goteros en borde de placas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:13:43',NULL,NULL,5,7,NULL),(86,'ccc058ba-72ef-4e4d-a145-18c5163f1ce8',5,75,NULL,NULL,'Media caña cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:13:52',NULL,NULL,5,7,NULL),(87,'d2c5a5f9-7a2a-41e2-b422-3f7ccf8cd37b',5,69,NULL,NULL,'Pañete de muros fachada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:14:00',NULL,NULL,5,7,NULL),(88,'c5037ff2-c697-4cbb-8b90-622f383b4e0d',5,68,NULL,NULL,'Pañete de muros internos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:14:10',NULL,NULL,5,7,NULL),(89,'739cea0a-7fac-4a98-8b2a-deaf8834b6a4',5,70,NULL,NULL,'Pañete de placas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:14:18',NULL,NULL,5,7,NULL),(90,'68a6350d-5114-421e-bafc-3c4b3241e79b',5,71,NULL,NULL,'Pañete de placas fachada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:14:26',NULL,NULL,5,7,NULL),(91,'ec61141c-0e7e-463a-984e-398f1a32069b',5,125,NULL,NULL,'Figuracion Acero Pedestal',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-11','2026-11-12','completed',NULL,4.17,3,'2026-11-11 16:32:52',NULL,'2026-11-12 11:04:55',2,3,1),(92,'b8ec2610-37d4-4bbd-84a2-ac4c8f5c88a4',5,126,NULL,NULL,'Figuracion placa de piso Tanque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-11','2026-11-13','completed',NULL,4.00,3,'2026-11-11 16:35:46',3,'2026-11-13 17:56:13',2,3,2),(93,'478a1748-c1a8-4bd7-8ff6-46f77e4febd4',5,127,NULL,NULL,'Placa de concreto Tanque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-12','2026-11-13','completed',NULL,3.85,3,'2026-11-12 11:04:16',3,'2026-11-13 20:18:23',2,3,2),(94,'9827a6bb-5767-4cc4-986d-3f35ec0302de',5,128,NULL,NULL,'Figuracion Acero Viga de Amarre',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'scheduled',NULL,3.70,3,'2026-11-12 11:58:37',NULL,'2026-11-14 11:45:58',2,3,1),(95,'c1dfd359-01f7-4ac4-9f13-c278c199d7ee',7,4,NULL,NULL,'Campamento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(96,'c52c6268-e42b-4b6f-9085-036c542860cc',7,2,NULL,NULL,'Cerramiento En Tela Verde',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(97,'cc87f7f7-a058-4370-95df-6d11e5238df5',7,1,NULL,NULL,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(98,'927e562b-d7e8-4bcc-83a9-ec2aec4d6050',7,3,NULL,NULL,'Localización Y Replanteo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(99,'9c4fb0f0-eb65-4d36-bcf4-24ace65fd3cd',7,5,NULL,NULL,'Provisionales Electricas y Agua',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(100,'a5ee5072-a9d2-4633-82a8-8262cf314c2c',7,18,NULL,NULL,'Columnas en concreto N1 a N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(101,'0aa554a7-ae7b-4eb9-a690-9e5d3658739e',7,25,NULL,NULL,'Columnas en concreto N2 a N3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(102,'c982b2a8-d44a-4158-b660-24f7cb9233da',7,30,NULL,NULL,'Columnas en tuberia metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,25.00,3,'2026-11-12 12:41:45',NULL,NULL,2,2,NULL),(103,'ac8fb532-f5a1-402d-b5d2-a4bb4a6e58ef',7,12,NULL,NULL,'Concreto ciclopeo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(104,'4978a7c3-3657-42e7-a306-b6f2ac996c90',7,29,NULL,NULL,'Desencofrado formaleta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(105,'438403b1-2400-40b5-9491-0e1a6a149509',7,20,NULL,NULL,'Escalera en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(106,'7797cec4-57d4-4444-a445-ce0dfa4c3ade',7,21,NULL,NULL,'Escalera metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,25.00,3,'2026-11-12 12:41:45',NULL,NULL,2,2,1),(107,'8fa272bd-3476-4e24-8614-82df838227ba',7,8,NULL,NULL,'Excavación manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(108,'f76db3f4-24ea-4731-a3b4-c5ad00d7e33f',7,9,NULL,NULL,'Excavación mecánica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(109,'87c09855-53a6-4260-9d38-064114ec4114',7,125,NULL,NULL,'Figuracion Acero Pedestal',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(110,'77237c8a-e278-443d-b002-a09cee14b05c',7,120,NULL,NULL,'Figuracion de Acero Zapatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(111,'6495b373-e226-491b-94db-a8fa31fc25b0',7,126,NULL,NULL,'Figuracion placa de piso Tanque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,2),(112,'2505cd5b-d911-4f4a-b6ac-c231bc365cfa',7,22,NULL,NULL,'Fundida pasos escalera',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(113,'569256b3-568e-4520-b02e-1985d00b2459',7,19,NULL,NULL,'Pantalla en concreto N1 a N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(114,'54fea935-ec5f-472d-92ee-5b9646789528',7,14,NULL,NULL,'Pedestal en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(115,'6c02e0f0-69c1-4bc3-a5b5-c67eb9ecafbe',7,11,NULL,NULL,'Perfilada de zapatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(116,'af285800-0684-424a-9e78-f0f16571bb85',7,27,NULL,NULL,'Placa cubierta en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(117,'525dc42b-6e53-40df-89f0-6c9ce8a7e960',7,16,NULL,NULL,'Placa de cimentación en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(118,'37dc3a66-5c38-4973-968a-7d3be8213264',7,127,NULL,NULL,'Placa de cimentacion en concreto Tanque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,2),(119,'c51b7fc2-5aa9-48f3-8d02-db5e26b55d60',7,17,NULL,NULL,'Placa de contrapiso con malla e=0,10max',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(120,'9bf65585-cda0-426d-b9c6-da416879964a',7,28,NULL,NULL,'Placa de entrepiso con bloque #5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(121,'2be7793e-4c8a-4889-81bc-48c47f77bdfb',7,24,NULL,NULL,'Placa entrepiso en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(122,'8fc8163a-15d8-4f02-890e-3d1ec6961aec',7,10,NULL,NULL,'Relleno compactado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(123,'085c4596-f631-4ccd-9245-d676a019f9d5',7,13,NULL,NULL,'Solados',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(124,'f0b51279-2403-4789-ad1c-6792de910d65',7,7,NULL,NULL,'Viga de amarre en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(125,'1d2c1ad8-cfc3-451b-8f6c-84fd75452b3b',7,15,NULL,NULL,'Viga de amarre metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,25.00,3,'2026-11-12 12:41:45',NULL,NULL,2,2,NULL),(126,'04333110-6c68-442b-9fd9-45c35b66c1fb',7,26,NULL,NULL,'Vigas aereas de cubierta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(127,'695cbfb2-edce-4962-9fc1-dee2ba8bf649',7,23,NULL,NULL,'Vigas aereas entrepisos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(128,'c5814e55-1d4b-46e3-938e-308e277f8102',7,31,NULL,NULL,'Vigas en tuberia metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,25.00,3,'2026-11-12 12:41:45',NULL,NULL,2,2,NULL),(129,'a794df02-277b-428c-976e-e02f51e05de0',7,6,NULL,NULL,'Zapatas en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,'2026-11-13 15:18:52',2,3,1),(130,'92833f22-7914-4eea-9cb1-e45495348ed4',7,51,NULL,NULL,'Instalación cajas y accesorios',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(131,'f7934770-5723-444b-a1b0-fa9288dc2976',7,53,NULL,NULL,'Instalación de tablero',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(132,'139aa2f9-8e30-4dc5-a37a-2fcfed87761a',7,54,NULL,NULL,'Instalación tomacorrientes-interruptores',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(133,'c75fb52a-2ec8-42d3-b6f0-3dcfcf2a3fa5',7,50,NULL,NULL,'Regatas y/o cajas eléctricas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(134,'616733b7-577a-4a38-b70b-4608b8e6d392',7,52,NULL,NULL,'Tendido cableado eléctrico',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(135,'4983dd7a-3902-4bcd-9a62-77469c50ec47',7,49,NULL,NULL,'Tendido de tuberia eléctrica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(136,'6a488a53-a248-45df-bc44-764dd2f8d723',7,56,NULL,NULL,'Conexiones & puesta en funcionamiento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:45',NULL,NULL,4,5,NULL),(137,'ea8c5b37-9589-4367-878a-80ab0d2069cb',7,55,NULL,NULL,'Instalación luminarias',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:45',NULL,NULL,4,5,NULL),(138,'569c5ac1-631f-421e-87c9-0d53bcd6929d',7,34,NULL,NULL,'Caja de inspección',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(139,'a6f6a35c-8410-4d5e-8a39-8fca2b7b645b',7,32,NULL,NULL,'Excavacion manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(140,'5f0d871c-e84c-49ec-8810-0aa9726d1028',7,46,NULL,NULL,'Instalación de tanques + pruebas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(141,'c1b89c28-accc-4918-a0b1-cd098bc37106',7,38,NULL,NULL,'Puntos desagües sanitarios N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(142,'eb822a94-13f5-46d6-9ae6-707100b1217a',7,42,NULL,NULL,'Puntos desagües sanitarios N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(143,'f16ea64f-806e-4467-ab26-7d4132d18ef9',7,45,NULL,NULL,'Puntos hidraulicos agua caliente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(144,'914572b1-2a7d-45d4-ae3f-48bb72367dd3',7,44,NULL,NULL,'Puntos hidraulicos agua fria',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(145,'3fce6867-bc99-4939-954b-3244da944f64',7,33,NULL,NULL,'Tapadas de tuberia',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(146,'313c7a09-244e-438b-b4fc-81ea7138deb6',7,36,NULL,NULL,'Tuberia aguas lluvias principal N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(147,'f5a6927e-e649-45d9-87b6-799cf87f831d',7,41,NULL,NULL,'Tuberia sanitaria descolgada placa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(148,'534490e3-3210-482c-91fd-7385ae49f3cc',7,35,NULL,NULL,'Tuberia sanitaria principal N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(149,'adb3d36d-014a-48d3-9ab7-1c2b4f9297a9',7,40,NULL,NULL,'Bajantes aguas lluvias',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(150,'010531e0-0573-4542-bb97-2c38bdea6665',7,39,NULL,NULL,'Bajantes sanitarios',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(151,'2c718482-696e-404d-b1c7-6ccccc2f4620',7,48,NULL,NULL,'Instalación sistema de bombeo piscina',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,2),(152,'3acb2b5c-a1cb-4e9e-85a4-d67328e386c2',7,47,NULL,NULL,'Instalación sistema de bombeo tanque subt',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(153,'50409ae2-a962-4d82-8792-800038f40abd',7,43,NULL,NULL,'Tuberia Hidraulica Vertical',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(154,'3d68355c-e38f-44db-9d65-fd01080c30c7',7,37,NULL,NULL,'Tuberia presión N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(155,'c111a995-0a24-4670-b70f-cfdf58a57849',7,66,NULL,NULL,'Columneta de confinamiento bloque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',5,6,NULL),(156,'a5716bb7-837f-46ad-b320-f630dc679133',7,73,NULL,NULL,'Dilataciones en pañetes',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',5,7,NULL),(157,'4d725363-c332-40ba-a876-82f6ac3f92e1',7,74,NULL,NULL,'Filos en pañetes',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',5,7,NULL),(158,'357fe5e4-8f44-4030-852c-2605107f3b2a',7,75,NULL,NULL,'Media caña cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:46',5,7,NULL),(159,'dcc4f0bb-dcd3-4e3c-89ad-e42bc85ae8e5',7,59,NULL,NULL,'Muro en bloque #5 1er piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:46',NULL,'2026-11-12 12:41:46',5,6,NULL),(160,'63999364-75c6-47dd-a27d-b059d5b8dd89',7,60,NULL,NULL,'Muro en bloque #5 2do piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:46',NULL,'2026-11-12 12:41:46',5,6,NULL),(161,'17c60c02-3f73-4af9-b976-5ea2e6cd5ad0',7,58,NULL,NULL,'Muro en ladrillo de obra doble',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:46',NULL,'2026-11-12 12:41:46',5,6,NULL),(162,'36f864fc-f9a0-43c3-bec6-3dde664d640c',7,57,NULL,NULL,'Muro en ladrillo de obra sencillo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:46',NULL,'2026-11-12 12:41:46',5,6,NULL),(163,'355c00d9-ce7e-4968-98d6-c0d79d3e51db',7,79,NULL,NULL,'Dilataciones en z muro',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,5,8,NULL),(164,'416409e6-3fae-4269-8d2d-349ee7a17d0d',7,62,NULL,NULL,'Dinteles en varilla',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(165,'d7c48b57-24e8-4758-848b-c698526f8463',7,72,NULL,NULL,'Goteros en borde de placas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(166,'3ee6d748-7ee1-4000-9ff3-7c4c3f3144c1',7,63,NULL,NULL,'Muro bloque cemento e=0,09',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(167,'e51e61cb-e10e-4e11-88c2-ed4dbb720f86',7,64,NULL,NULL,'Muro bloque cemento e=0,12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(168,'d698f3b7-5c27-4cc1-ba92-a4e95e731021',7,65,NULL,NULL,'Muro bloque cemento e=0,20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(169,'aad44a2e-0c7a-4343-afa6-6cd1cf634e04',7,77,NULL,NULL,'Muro doble en drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,5,8,NULL),(170,'c43efe6c-28ed-4162-b705-80701ee72169',7,78,NULL,NULL,'Muro doble en superboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,5,8,NULL),(171,'50403c22-320a-483d-8dcd-e3917dafcf21',7,61,NULL,NULL,'Muro en bloque #5 culatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(172,'9fab89fd-d317-4475-b25e-9769712988a0',7,76,NULL,NULL,'Muro sencillo en drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,5,8,NULL),(173,'9ab58403-0d64-46e2-ac1f-a571f86826ec',7,69,NULL,NULL,'Pañete de muros fachada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(174,'2604c461-6500-4704-98a0-254f00c1ead5',7,68,NULL,NULL,'Pañete de muros internos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(175,'369353f4-57ef-42cd-b1fa-d558239aa068',7,70,NULL,NULL,'Pañete de placas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(176,'836efdc7-00e0-4934-afbe-685d0200cb35',7,71,NULL,NULL,'Pañete de placas fachada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(177,'93387c63-b1d6-4d06-817a-e006802c4c26',7,67,NULL,NULL,'Relleno celdas bloque estructural',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(178,'ec39f6ac-c6e7-4101-96d1-f570989f7dd8',7,91,NULL,NULL,'Anden piso en adoquin',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(179,'755a1a5e-bc70-4ce6-af47-9b76747a9f73',7,119,NULL,NULL,'Barra de cocina en material seleccionado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(180,'af8497b5-ed0a-4528-a6ba-4a58b44a9b99',7,95,NULL,NULL,'Biselada de enchape muro',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(181,'2ea79cf9-257f-4748-ab9c-374c9a8bd716',7,104,NULL,NULL,'Closets de madera',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(182,'0badba60-a37e-4133-b9e1-4796fbeee7ca',7,105,NULL,NULL,'Cubierta metálica en cerchas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(183,'18803c8a-426b-4c5d-9727-30b4ab0ea1a7',7,82,NULL,NULL,'Cubiertas en cielo raso drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(184,'b8635fb4-d4c3-4849-a9ed-e2f6d1557ab8',7,99,NULL,NULL,'División de baños en vidrio templado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,11,NULL),(185,'2bb4c0da-53e0-4865-8d8b-4aff6fe7e466',7,84,NULL,NULL,'Domos en placa cubierta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(186,'21629c8c-11be-4d3f-ad4a-130eec3744fc',7,88,NULL,NULL,'Enchape de escalera biselada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(187,'6a78a901-9d2e-415a-b6b8-fd296b5e25b9',7,93,NULL,NULL,'Enchape de muro en cerámica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(188,'2af46739-5bb2-459a-aab3-042272c4ddb4',7,94,NULL,NULL,'Enchape de muro en porcelanato',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(189,'d8618ccb-ddb2-484c-ba09-568c261e9383',7,86,NULL,NULL,'Enchape de piso en cerámica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(190,'dd50a6b4-9ca1-41b8-9ca7-322d99e2d4c0',7,87,NULL,NULL,'Enchape de piso en porcelanato',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(191,'5986feeb-85d4-46e7-a1fe-fa8c63cf698f',7,109,NULL,NULL,'Estructura metálica de cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,13,NULL),(192,'c614f262-db17-48ab-9a4e-f25997268f0f',7,108,NULL,NULL,'Estructura Métalica soporte superboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,13,NULL),(193,'4083760f-fb69-4251-a6ad-a58f194af328',7,89,NULL,NULL,'Guardaescobas en cerámica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(194,'42768c68-9598-4259-a97c-1350ca858fd5',7,90,NULL,NULL,'Guardaescobas en porcelanato',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(195,'07e796a4-2cd2-4df3-aab2-32797f419a37',7,81,NULL,NULL,'Impermeabilización de cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(196,'6fe1e53c-e00e-4fb3-842d-f6c334b56ac7',7,83,NULL,NULL,'Inst. cubierta tipo sandwich',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(197,'b9640050-484b-4f26-993b-5f50a255b76f',7,112,NULL,NULL,'Instalación accesorios baño',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(198,'3994adf1-36a2-4ee3-83bf-6565fe0e02a5',7,110,NULL,NULL,'Instalación aparatos de baños',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(199,'050e8174-08d8-47aa-ab83-501087a446cc',7,117,NULL,NULL,'Instalación campana cocina',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(200,'df04688f-4065-4c7b-ab89-2e4100924312',7,96,NULL,NULL,'Instalación de rejillas de piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(201,'fde7bc9d-638b-48e9-88b3-3ed60af99b58',7,111,NULL,NULL,'Instalación duchas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(202,'f9c80a9d-4c36-47b8-9ce1-e91ccadeed0c',7,116,NULL,NULL,'Instalación estufa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(203,'2c111319-43bc-4694-a968-2d3604e6da74',7,115,NULL,NULL,'Instalación horno cocina',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(204,'5b2d516a-12ac-4d63-9583-87cb97fbfff8',7,113,NULL,NULL,'Instalación Lavadero',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(205,'f3d2f950-b658-4048-bd82-1c29cdd8e125',7,114,NULL,NULL,'Instalación Lavaplatos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(206,'c84989c4-189b-4036-a7b2-14b383311031',7,118,NULL,NULL,'Meson de cocina en material seleccionado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(207,'da60e55c-cb01-404a-8a5d-3f823b2619b3',7,80,NULL,NULL,'Mortero nivelación de cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(208,'7d7be6d4-86a9-43ec-bc01-1fe6d74a5b61',7,85,NULL,NULL,'Mortero nivelación de pisos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(209,'741c91d4-14dc-44cd-8430-6f2769a42ca0',7,102,NULL,NULL,'Mueble de baño madera lavamanos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(210,'3a800ca8-02b3-4105-b6bf-028548881893',7,103,NULL,NULL,'Mueble de cocina madera bajo & alto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(211,'03b388cf-cb23-4a31-92d4-729a613cc46c',7,100,NULL,NULL,'Pasamanos en vidrio templado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,11,NULL),(212,'83ef02ac-9817-424f-9e4d-ba5710810dbc',7,92,NULL,NULL,'Piso zona verde',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,2),(213,'3c16b128-41c9-40d2-a922-4b8eef918747',7,107,NULL,NULL,'Portones corredizos metálicos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,13,NULL),(214,'ec32f536-45cd-4cda-a7ae-0d91a5b0adcd',7,98,NULL,NULL,'Puerta correderas en aluminio y vidrio',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,11,NULL),(215,'ca66ab5a-68a1-412b-b8e9-b3304a165b00',7,101,NULL,NULL,'Puertas de madera general',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(216,'347a7976-18da-4671-967d-06e83d31aa9f',7,122,NULL,NULL,'Revestimiento de muros fachada (pasta-pintura ext)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,50.00,3,'2026-11-12 12:41:46',NULL,NULL,6,15,NULL),(217,'9afd51eb-cab6-4156-b6db-c014d3d40f40',7,121,NULL,NULL,'Revestimiento de muros internos (pasta-pintura)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,50.00,3,'2026-11-12 12:41:46',NULL,NULL,6,15,NULL),(218,'e54a9fba-1efd-43ce-9c76-7d0351c9dec5',7,124,NULL,NULL,'Revestimiento en aluminio compuesto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,50.00,3,'2026-11-12 12:41:46',NULL,NULL,6,16,NULL),(219,'65666bde-82a8-4175-a14e-974258cdc022',7,123,NULL,NULL,'Revestimiento en superboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,50.00,3,'2026-11-12 12:41:46',NULL,NULL,6,16,NULL),(220,'47af24d0-ff76-445b-844d-3b5e2fbe3278',7,106,NULL,NULL,'Ventanas en aluminio',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,13,NULL),(221,'32b66637-306d-4fa4-92df-432fb7a1656f',7,97,NULL,NULL,'Ventaneria en aluminio y vidrio',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,11,NULL),(222,'31353273-7891-4abc-bbff-4dac7180684c',5,129,NULL,NULL,'Figuracion Vigas de Amarre',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,3.57,2,'2026-11-14 09:28:54',NULL,NULL,2,3,1),(223,'b86ef5f5-88d7-430f-9519-ddbb990e716d',5,130,NULL,NULL,'Excavacion Manual Viga de Amarre',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'scheduled',NULL,3.45,3,'2026-11-14 11:49:24',NULL,'2026-11-14 11:49:42',2,3,1),(224,'86453a29-3a74-44ba-af5e-8fb54d7d7d90',5,131,NULL,NULL,'Solado Vigas de Amarre',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'scheduled',NULL,3.33,3,'2026-11-14 11:52:44',NULL,'2026-11-14 11:53:01',2,3,1),(225,'990d42cc-38ac-4cea-baed-648dcb9321b2',5,132,NULL,NULL,'Zapatas Muro Cerramiento Posterior',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'scheduled',NULL,3.23,3,'2026-11-14 11:55:08',NULL,'2026-11-14 11:55:27',2,3,2);
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_notifications`
--

DROP TABLE IF EXISTS `user_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `link` varchar(255) DEFAULT NULL,
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `ix_user_notifications_user_id` (`user_id`),
  CONSTRAINT `user_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_notifications`
--

LOCK TABLES `user_notifications` WRITE;
/*!40000 ALTER TABLE `user_notifications` DISABLE KEYS */;
INSERT INTO `user_notifications` VALUES (1,2,'Nota de Juan David Navarro','Corozal Armotek · Localización Y Replanteo\nmanana quiero que se haga esto','/dashboard/obras/2/tareas?tarea=3','2026-10-22 16:09:47','2026-10-22 16:08:56'),(2,1,'Firma pendiente · Plan 2026-10-19 — Corozal Armotek','Se añadió «jsjsjs». Justificación: assssssssss','/dashboard/planes/1','2026-10-22 16:14:34','2026-10-22 16:13:35'),(3,2,'Firma pendiente · Plan 2026-10-19 — Corozal Armotek','Se añadió «jsjsjs». Justificación: assssssssss','/dashboard/planes/1','2026-10-22 16:13:59','2026-10-22 16:13:35'),(4,1,'Firma pendiente · Plan 2026-10-19 — Corozal Armotek','Se añadió «Campamento». Justificación: Inicio de obra','/dashboard/planes/1','2026-10-31 10:17:44','2026-10-30 18:31:02'),(5,2,'Firma pendiente · Plan 2026-10-19 — Corozal Armotek','Se añadió «Campamento». Justificación: Inicio de obra','/dashboard/planes/1','2026-11-07 10:37:46','2026-10-30 18:31:02'),(6,3,'Firma pendiente · Plan 2026-10-19 — Corozal Armotek','Se añadió «Campamento». Justificación: Inicio de obra','/dashboard/planes/1','2026-10-30 18:31:21','2026-10-30 18:31:02'),(7,1,'Nota de Luis Carlos Navarro Gallon','L2 TRAMONTI · Provisionales Electricas y Agua\nFalta Provisional de Luz, El agua ya se conectó','/dashboard/obras/5/tareas?tarea=19','2026-11-17 12:33:21','2026-11-14 11:41:31'),(8,2,'Nota de Luis Carlos Navarro Gallon','L2 TRAMONTI · Provisionales Electricas y Agua\nFalta Provisional de Luz, El agua ya se conectó','/dashboard/obras/5/tareas?tarea=19','2026-11-17 07:48:55','2026-11-14 11:41:31'),(9,4,'Nota de Luis Carlos Navarro Gallon','L2 TRAMONTI · Provisionales Electricas y Agua\nFalta Provisional de Luz, El agua ya se conectó','/dashboard/obras/5/tareas?tarea=19',NULL,'2026-11-14 11:41:31');
/*!40000 ALTER TABLE `user_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_permissions`
--

DROP TABLE IF EXISTS `user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_permission` (`user_id`,`permission`),
  KEY `ix_user_permissions_user_id` (`user_id`),
  CONSTRAINT `user_permissions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_permissions`
--

LOCK TABLES `user_permissions` WRITE;
/*!40000 ALTER TABLE `user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `person_id` int NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` text NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `role_id` int DEFAULT NULL,
  `is_super` int DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  `deactivation_reason` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_id` (`person_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `ix_users_person_id` (`person_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `persons` (`id`),
  CONSTRAINT `users_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `users_roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,1,'JuanD','$bcrypt-sha256$v=2,t=2b,r=12$fUl5/H3kSQyBplbu8bkVsO$vrszElfdsm5plQsOsCF7kctC1MtjHu.','jdnavarro95@gmail.com',1,1,1,NULL,'2026-10-22 14:26:11',NULL),(2,2,'1090511641','$bcrypt-sha256$v=2,t=2b,r=12$CWasHiZacWti4SgPjCP/3.$W0QiEgtCBdckxQVzS5KOfe115ggGRp.','camilomeza36@gmail.com',2,0,1,NULL,'2026-10-22 15:54:34',NULL),(3,13,'1090500749','$bcrypt-sha256$v=2,t=2b,r=12$20uZg8KbGnBzmY9WIGEqne$veArNMqG.yp80rAnw48mbftaTqXII/2',NULL,2,1,1,NULL,'2026-10-30 13:24:31',NULL),(4,4,'1091967303','$bcrypt-sha256$v=2,t=2b,r=12$Oi2NcC8yKZuX5kNBBHveoe$/EBbO6yKABmEsyiTDznBVMJvuarWCfe','andrescamilobautista118@gmail.com',2,0,1,NULL,'2026-11-14 09:48:31',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_roles`
--

DROP TABLE IF EXISTS `users_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_roles`
--

LOCK TABLES `users_roles` WRITE;
/*!40000 ALTER TABLE `users_roles` DISABLE KEYS */;
INSERT INTO `users_roles` VALUES (1,'super_admin',1),(2,'admin',1),(3,'supervisor',1),(4,'maestro',1),(5,'cliente',1);
/*!40000 ALTER TABLE `users_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_plan_signature_events`
--

DROP TABLE IF EXISTS `work_plan_signature_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_plan_signature_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `work_plan_version_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `event_type` varchar(50) NOT NULL,
  `event_at` datetime NOT NULL DEFAULT (now()),
  `details` text,
  PRIMARY KEY (`id`),
  KEY `work_plan_version_id` (`work_plan_version_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `work_plan_signature_events_ibfk_1` FOREIGN KEY (`work_plan_version_id`) REFERENCES `work_plan_versions` (`id`),
  CONSTRAINT `work_plan_signature_events_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_plan_signature_events`
--

LOCK TABLES `work_plan_signature_events` WRITE;
/*!40000 ALTER TABLE `work_plan_signature_events` DISABLE KEYS */;
INSERT INTO `work_plan_signature_events` VALUES (1,1,2,'created','2026-10-22 16:05:02','Plan creado con 3 tarea(s)'),(2,1,2,'edited','2026-10-22 16:05:17','Firmante agregado: Juan David Navarro'),(3,1,2,'edited','2026-10-22 16:05:19','Firmante agregado: Camilo Meza'),(4,1,2,'requested','2026-10-22 16:05:27','Solicitud de firma a 2 firmante(s)'),(5,1,2,'viewed','2026-10-22 16:05:27','Versión vista'),(6,1,2,'signed','2026-10-22 16:05:33','Camilo Meza firmó (electronic)'),(7,1,2,'viewed','2026-10-22 16:05:34','Versión vista'),(8,1,1,'viewed','2026-10-22 16:05:59','Versión vista'),(9,1,1,'signed','2026-10-22 16:06:04','Juan David Navarro firmó (electronic)'),(10,2,2,'created','2026-10-22 16:13:35','Nueva versión 2 por una actividad agregada'),(11,2,2,'requested','2026-10-22 16:13:35','Se añadió «jsjsjs». Justificación: assssssssss'),(12,2,2,'viewed','2026-10-22 16:13:43','Versión vista'),(13,2,2,'viewed','2026-10-22 16:13:58','Versión vista'),(14,2,2,'signed','2026-10-22 16:14:06','Camilo Meza firmó (electronic)'),(15,2,2,'viewed','2026-10-22 16:14:06','Versión vista'),(16,2,1,'viewed','2026-10-22 16:14:34','Versión vista'),(17,2,1,'signed','2026-10-22 16:14:39','Juan David Navarro firmó (electronic)'),(18,3,3,'created','2026-10-30 18:31:01','Nueva versión 3 por una actividad agregada'),(19,3,3,'requested','2026-10-30 18:31:02','Se añadió «Campamento». Justificación: Inicio de obra'),(20,3,3,'viewed','2026-10-30 18:31:21','Versión vista'),(21,3,3,'cancelled','2026-10-30 18:31:43','Solicitud de firma cancelada; vuelve a draft'),(22,3,3,'edited','2026-10-30 18:31:51','Tarea quitada: jsjsjs'),(23,4,3,'created','2026-11-04 13:51:31','Plan creado con 3 tarea(s)'),(24,4,3,'edited','2026-11-04 13:52:24','Firmante agregado: Luis Carlos Navarro Gallon'),(25,4,3,'requested','2026-11-04 13:52:35','Solicitud de firma a 1 firmante(s)'),(26,4,3,'signed','2026-11-04 13:53:02','Luis Carlos Navarro Gallon firmó (electronic)'),(27,5,2,'created','2026-11-07 10:47:47','Plan creado con 3 tarea(s)'),(28,5,2,'edited','2026-11-07 10:51:31','Se añadió «Excavación mecánica». Justificación: Se ejecuto de acuerdo a la planeacion'),(29,5,2,'edited','2026-11-07 10:51:46','Se añadió «Perfilada de zapatas». Justificación: Se ejecuto de acuerdo a la planeacion'),(30,5,2,'edited','2026-11-07 10:52:02','Se añadió «Solados». Justificación: Se ejecuto de acuerdo a la planeacion'),(31,5,2,'edited','2026-11-07 11:00:23','Se añadió «Figuracion de Acero Zapatas». Justificación: Se ejecuto de acuerdo a la planeacion'),(32,5,2,'edited','2026-11-07 11:28:22','Se añadió «Provisionales Electricas y Agua». Justificación: porqbijnijoj'),(33,6,3,'created','2026-11-11 16:32:52','Plan creado con 3 tarea(s)'),(34,6,3,'edited','2026-11-11 16:35:46','Se añadió «Figuracion placa de piso Tanque». Justificación: Se va ejecutar esta semana'),(35,6,3,'edited','2026-11-12 10:46:36','Tarea agregada: Zapatas en concreto'),(36,6,3,'edited','2026-11-12 10:58:47','Tarea quitada: Zapatas en concreto'),(37,6,3,'edited','2026-11-12 10:59:07','Tarea agregada: Zapatas en concreto'),(38,6,3,'edited','2026-11-12 11:04:33','Tarea agregada: Placa de concreto Tanque'),(39,7,3,'created','2026-11-14 11:45:03','Plan creado con 1 tarea(s)'),(40,7,3,'edited','2026-11-14 11:45:40','Tarea agregada: Pedestal en concreto'),(41,7,3,'edited','2026-11-14 11:45:58','Tarea agregada: Figuracion Acero Viga de Amarre'),(42,7,3,'edited','2026-11-14 11:49:42','Tarea agregada: Excavacion Manual Viga de Amarre'),(43,7,3,'edited','2026-11-14 11:53:01','Tarea agregada: Solado Vigas de Amarre'),(44,7,3,'edited','2026-11-14 11:55:27','Tarea agregada: Zapatas Muro Cerramiento Posterior');
/*!40000 ALTER TABLE `work_plan_signature_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_plan_signatures`
--

DROP TABLE IF EXISTS `work_plan_signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_plan_signatures` (
  `id` int NOT NULL AUTO_INCREMENT,
  `work_plan_signer_id` int NOT NULL,
  `user_id` int NOT NULL,
  `signature_type` varchar(30) NOT NULL,
  `signature_data` text,
  `signed_at` datetime NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `work_plan_signer_id` (`work_plan_signer_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `work_plan_signatures_ibfk_1` FOREIGN KEY (`work_plan_signer_id`) REFERENCES `work_plan_signers` (`id`),
  CONSTRAINT `work_plan_signatures_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_plan_signatures`
--

LOCK TABLES `work_plan_signatures` WRITE;
/*!40000 ALTER TABLE `work_plan_signatures` DISABLE KEYS */;
INSERT INTO `work_plan_signatures` VALUES (1,2,2,'electronic','data:image/png;base64,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','2026-10-22 21:05:34','172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36'),(2,1,1,'electronic','data:image/png;base64,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','2026-10-22 21:06:04','172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36'),(3,4,2,'electronic','data:image/png;base64,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','2026-10-22 21:14:06','172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36'),(4,3,1,'electronic','data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAfoAAADhCAYAAAAgc3elAAAQAElEQVR4AezdCXhU5b3H8d8MBESsDW3VW7MnEEKQ1aCI5VpobRUSba9X68X1aqUUabWodaG2T1UUa22fUhBQn9Yqpai1QlFEEYFyRVyKAWQRYhYSWnFFUFmT3PecSVhCtpPZzvKNOTPJzP+8530/b57n53vOzBCu5wsBBBBAAAEEfCsQFl8IIIAAAggg4FsBZ0HvWwYGhgACCCCAgD8FCHp/ziujQgABBBBAwBaIZ9DbB+AGAQQQQAABBJInQNAnz54jI4AAAgggEHcB9wR93IfKARBAAAEEEAieAEEfvDlnxAgggAACARLwatAHaIoYKgIIIIAAAh0XIOg7bseeCCCAAAIIuF4gGEHv+mmggwgggAACCMRHgKCPjyutIoAAAggg4AoBgv7oaeARBBBAAAEEfCNA0PtmKhkIAggggAACRwsQ9EebOHuEagQQQAABBFwsQNC7eHLoGgIIIIAAAtEKEPTRCjrbn2oEEEAAAQQSKkDQJ5SbgyGAAAIIIJBYAYI+sd7OjkY1AggggAACUQoQ9FECsjsCCCCAAAJuFiDo3Tw7zvpGNQIIIIAAAkcJEPRHkfAAAggggAAC/hEg6P0zl85GQjUCCCCAQCAECPpATDODRAABBBAIqgBBH9SZdzZuqhFAAAEEPCpA0Ht04ug2AggggAAC7REg6NujRI0zAaoRQAABBFwjQNC7ZiroCAIIIIAAArEXIOhjb0qLzgSoRgABBBCIowBBH0dcmkYAAQQQQCDZAgR9smeA4zsToBoBBBBAwJEAQe+Ii2IEEEAAAQS8JUDQe2u+6K0zAaoRQACBwAsQ9IH/EwAAAQQQQMDPAgS9n2eXsTkToBoBBBDwoQBB78NJZUgIIIAAAgg0ChD0jRLcI+BMgGoEEEDAEwIEvSemiU4igAACCCDQMQGCvmNu7IWAMwGqEUAAgSQJEPRJguewCCCAAAIIJEKAoE+EMsdAwJkA1QgggEDMBAj6mFHSEAIIIIAAAu4TIOjdNyf0CAFnAlQjgAACrQgQ9K3g8BQCCCCAAAJeFyDovT6D9B8BZwJUI4BAwAQI+oBNOMNFAAEEEAiWAEEfrPlmtAg4E6AaAQQ8L0DQe34KGQACCCCAAAItCxD0LdvwDAIIOBOgGgEEXChA0LtwUugSAggggAACsRIg6GMlSTsIIOBMgGoEEEiIAEGfEGYOggACCCCAQHIECPrkuHNUBBBwJkA1Agh0UICg7yAcuyGAAAIIIOAFAYLeC7NEHxFAwJkA1QggcFCAoD9IwQ8IIIAAAgj4T4Cg99+cMiIEEHAmQDUCvhYg6H09vQwOAQQQQCDoAgR90P8CGD8CCDgToBoBjwkQ9B6bMLqLAAIIIICAEwGC3okWtQgggIAzAaoRSLoAQZ/0KaADCCCAgD8E3nv/fa1e/abm/32Bpk2foVtum6RLL7tCd951tz8G6NFREPQenTi6jQACPhRI0JA++ugjPfnkk7r11km64ILvadiZw1XYd4Cyc3sqp2e++vTt72gr7DdAOXn5GjR4iErO/67GX/sj3TPlXj322J+1dNlyzZz1oFa+sipBo+MwTQUI+qYi/I4AAgh4XGDZsmW69977dPnlV2rEN85W/wGDldeztzIyc5WWma1+5vfrJ96kR2f/Watee1VVW6v1yc5PtH//Ae3bu087d+50tH2y4xPt27evRbX+/frJ2los4Im4ChD0ceWlcQQQQCC2Ahs2bNDMmQ/p2mt/pFHF5+nUIacrv3ehMrN7Kj0jW2lmu+SyKzV12nQtWbpMmzdv0YdmBb9n717V1ddJ9bHtj9VaOBxWXm6uRo4coSuvuFw/m3SrZjwwTfOffkqvv/qKnlu4QMcd190qZUuCAEGfBHQOiQAC/hDYsWOHCdLNWrlypZ555hn94U+P6je/mao77pisiTfdonHjx9ur6gsvvFijS76jb5x9joafNVJDh35Ng4tOU/+Bg9XXnPbu3fcU9czvY6+6rVPgWbm9THDnKiPLbJk5Sre2jBwT4jk6+9ujdOfkyZpnroOvWbNW7767XZ99/rlqaw+0M8NDCncKq9uxx+qEE05QYZ8++vY539INN/xET8z9i7ZVVzreqqvK9Y/lL+mxP/1Rk++6Qz8c9wOdV1KsoqJTdfLJXxVfyRUg6JPrz9ERQCBJAmvXrtWUKVN04cUX64wzzlRBYT/lmGvU6Vk59so43QSrtVkrZHszp7zte7Nibrzv22+gOTX+LV34vTH6wQ8n6Paf/Vz3//Y3mvXQQ3p87lwtWLDQXlWvXLVKpaWl2rRpk8rLy1W9rUbbt7+nDz/8SDvMae9Pd36q3bt3y1p1W6fAD+zfb4K7TnV1ZquvV7212THe9nI8FA6pS9cuSk1NVa5ZZQ8f/jVd/f2rNPOB6dry9gYT4hWqrixXmfm5dPXrWvzCc/rDQw9q4vXX6cwzz0jSbHDYeAqE49k4bSOAAAKJFli6dKluvu02lZR8V4Ot09oFhcqyAtysihsD2ro/d/R5+v30mVr58iptrdmmXbt2aZ+5Rl1fZ4LVdNq6tTbzY+S77YyN1MXzNhRS586dzWnw45SWlqbBpw7SRd+7SJPvvlP/t2KZCfFK1VRVqKJss9avK9UKs8qeO2e27vjFz43HaB1rVvHx7B5tu1Mg7M5u0SsEEEDgSIHH//pXTZhwvb5pTl0PGFykXr0KzOntPPu0tvUCMyu8re3Sy/9Xsx+bo9Wlb2q7dVr7s891wApwsyo+ssWO/GalfUj2fyZ0Q6GQwtZmrlF3CofVOSVFXbp00TFdj1G3bsfagZya+kV9+ctf0kknnqjM9Azl5eWpjzldPnDgQA0berpGfv3rKi4Zpf8ZM0bjxo7VT2+8UXffc5dmzZimJx+fo6VLXrBD2z6lvrVCVRVlenvjW3pt1ctaMO9p/fbXv9KVl12mnOxsxfCLpnwkEPbRWBgKAgh4TODfH3yg6dNn6aqrxuqskd9Uv36DlJvXW5lZeUprsgKf+JMb9fT8edq4YYM+eP8Dfb5njzm9XWuf1rbPard77FZY15uwlkIha4Xcyax0u+mrJ52ogYMGmBXyhZo1c7q9OrbD9Yhr1lXm8QrVVJvNhG6N2aqtzVyj3mq2qvItqnhns94p26SyzRvsQF6/bo3Wlq7W6n++pldeWaF/LFuiF83p8mcXzNOTTz6uxx57RLMeeEC/vvdu3X77bbruugm64tJLVVxcrGHDhik/P98+DS++EOigAEHfQTh2QwCBtgWWL1+pK674vgYVna7cnvnm2nfk+neauf5tbUWDinT3lHv0/OIXVLalTB/t+Fh79+1VbV2tTIK3fYAmFdZKWzK3ZnWdYlbXxx33BWVkZGjoGUPt1fL8p+eZoK6yt5pqc5rbhHRVxTvm2vVGvfHGa3r27/PNCvk+FY8eLb4cCFDqagGC3tXTQ+cQcL/APffcp5Fnn6Pehacow1qJH/ZitTGXjtGLL72o97Zv1969+8zCu/Gqd70ZmLWZu/Z8h0yRWX13CndSSkoX9eiRKuuFZt8YMdKc6r7JPo1trb6tlfY2a7VtVteVZnX99sZ1WrVyhZ56Yq69Wi4qGmga4huBYAkQ9MGab0aLgGOBllfl2UrLyNK0B6br7U2b9OmuT1VnrcTbe4RQpNDkt8ImwLt1O8a+lt2nd2+VmBX1r6ZMlnVq3ArwbVsrtc2svrdWvaPK8s16a22p/UKzRx/9gznVfa39wrRIa9x6QIAuJliAoE8wOIdDwI0CHVuVWyMJWTetbOZ5k+SdOoWVevzx6j+gn269+SYdDG/79Hmlqk2Al23eZF/LfvHF5zXTXCO/5JJLFAqZ/VtpnacQQKBtAYK+bSMqEPC8QLxW5XYMmzAOh8Pq2rWr0k8+WcUlo7XouWciYW5Oo9sr8cpyrV+/Vs89s0ATJlzreU8GkEABDhW1AEEfNSENIOAOgUStygcM7KdJt/7UDnLrBW1WkFeba+LlZW/r1VdXapY5ld/vlFPcgUIvEEBABD1/BAh4QGDnzp268cZbNew/Ryovv4+ysnLt94+nH3zhW8evlYes8Teuyo+JrMpLzhutxc8vtMPcenGbFeZbG1blCxcs0Pjx46292BBwmwD9aUaAoG8GhYcQSLTAggWLdNGYMRo0qEg5OfnKyMqWHeLp1gvesu1/MvQvj/9FVRXl2rN7tw7U1SnysaiNPbXjuvGXZu7N8ybMG6+VDxzYX7dPusUO8iNW5Vsiq/KZ06ersLCwmXZ4CAEEvCZA0HttxuivJwWsz1Q/++xzVVDQX5nZubLeQ56WnmPuI0E+bvw4vbxipd774APtO7BPJsdlv/nM5HN7BmyXmSA//Fp5yfnFWrJ4kR3mTVflzy74u8aNG9eepqlBwL8CARkZQR+QiWaY8RNYt26drrlmvIYMOUO5PXubU+pWkEcCPM2cWrdW5tZnqm/YtFG7Ptup2to60xkT4yGzmZ/a/jYx3lAaCoWU0qmzUo//ggr7FWri9RPtID9iVd5wrXzmtGnmfywKxBcCCARbgKAP9vwz+nYIPPzwwyop+Y769h+krJw8swrP0cl2gOeYn7N1zqgSLVy0UP9699/au3evOaVuBfmhhhsy+tADzfxkotx+K1lIIXXpkqIT/+MkjTjr65r96B9NkFdoW02lua+031deWVmm9evXafHChbrhhh830xoPIYBAHAQ822TYsz2n4wjEUGDx4sUaPmKEfX08LSMS4GkmzK3tF7+8S6tLS7Xj44914ECtOWq9iWOZU+v15ue2v63wbqwKhzur+3Hd1TM3V1ddeZW2Vr4TCfDqSIhbn+xW8c4Wvfn6q5o9+xGNMH1q3Jd7BBBAoCMCBH1H1NjHswItBfqVV12j8rIK+/q4FeEdGWAoFFZKSmd9uUcPDT1tqO6/b0pDiJsVuQly60NiqqvKtHnjei1f/pLuvPPn6tSpk/hCAAEfCrhoSAS9iyaDrsROIKaBXh+yOxYOh9StazdlZWTogv86XyuWr7CD3Apwa6vZWq7K8jKtXfumnnpqri6++GJ7P24QQACBZAoQ9MnU59hRC8Qq0EMK2X2xwjz1+OM1+txRh0K8JrIir66qUFnZRq1cuUJTf/c75eZm2PtwgwACCEQpENfdCfq48tJ4rATiF+ij7UC3ro1bq3IrzNevX6sHH3wgVl2nHQQQQCCpAgR9Uvk5eFOB+AV6cQuBPr1pF/gdAQQQcLeAw94R9A7BKI+NQLwCvXhUSQuBPi02HacVBBBAwGMCBL3HJsyL3b355pvVq1eB0jKylJYZeeua01e5h5pcQy8pbj7QZ836vReJ6DMCCCAQLwER9HGjDWbDjaGenpl9MNRnz3lcn+/ZY0BCUn29uW/5O9Qk0M8rPq/ZFfrMGQR6y4o8gwACCBwSIOgPWfCTQ4HWQt3Oc/um+UbbG+gzZkxtvgEeRQABBBBol4CjoG9XixT5UiCaUG8E6ZySoqLBRc2u0An0RiXuXbbWuAAAC4NJREFUEUAAgdgKEPSx9fRFa7EOdetta9ZWVb5F8+f/1RdGDAIBBBDwikAcg94rBMHuZyxCPcWs1Iecepq9UrcC3doI9WD/XTF6BBBwjwBB7565iHtP4hXqlWalPm/eE3HvPwdAAAEEEHAu4Jqgd9519mhNgFBvTYfnEEAAgeAIEPQ+mOtJk36p3F591Nxb2uwXvts3rQ/UOv1+WtGRp99ZqbduxrMIIICAFwQ8GvReoI1PHx95ZK4KCvoeEeqPPPpH7d2zO/IW9XaG+ulDjg71p5/m9Ht8Zo1WEUAAgeQJEPTJs2/zyOvWrdMppwxSWka20jMinyg36fZbtOuzz6IO9b/9jVBvcwIoQAABBHwgEIig98o8DT79dGVk5NrBboX7OaNK9PEnH9vdr1crnygXkkKhkMLhsArNat961XvjZp1+J9TFFwIIIBBYAYI+SVM/fORIZWbmHQx1K9i3/2u76sx/bXbJCvZwSJnpmaqqKNO2rZWq2Vqh6qpyLV78bJu7U4AAAgggEBwBgv6ouY79A+eff74yc3raoZ5uTsNboV6+pVy19bWtHszkuf18KBTSSSecqNdWvSx7pW4Fe1WFXnnlH+rcubNdww0CCCCAAALNCRD0zalE8djVV1+t7Lz8yIvlGq6rv7F6jWoPHLBbbfkEfCTWQ2al/oUvpurhB2eoprrSDnZrtb569WtKS0uz2+AGAQQQQACB9goQ9O2VaqZu7Nixys62Tr9n2f9Sm7VaX/TCEu3fty/yYrkWr6uHFLLbC6lb92N0w09+bAK9wmyVqjEr9U1vlercc8+1K7hBAAEEEEAgGgGCvp16jaF++HvVn33uBe2vtU6/m9iub/nlcuZZc5SQunRO0QUXXWACvaJhtV6hsk2bNHHiRPM83wgggAACCMReIBz7Jr3fYmuhbvK89X9T3U71kFI6ddaZZ3zNhLpZpdun4CtUUbFFU++/3/tAjAABBBBAwDMCgQ/6qEK9YZqtt7Xl9+xth7r1Cvht1RWqrCzTE0/MbqjgDgEEEEAAgeQIBCroYx7q9kq90n5b29Klz8d8BmkQAQQQQACBaAV8G/SxC/WCyEqdUI/2b439EUAAAQSSIODpoJ869SENHDhEGdl5Ss/MOeJ96o0vlGvzmnoDeuT0e3Ohvqihwu139A8BBBBAAIGjBVwf9CUl/63sngUHg9z6sJnG7d77Juv9D99XXW2t6u1EV4tvaDt86Fao9+5FqB9uws8IIIAAAv4UcFXQX3PNBKVnRVbmkTDP0urSN7R/756DQe50GqxQL8g/OtRfeinYK3WnjtQjgAACCHhTIOlBf3i4L1z0jOrrDv/sOPu9as3LNjwVuQspbP7r2q2Lzho+7Khr6kuWEOriCwEEEEAgkAJJCfrWw73pPJgot76tLRzWV770Ff30xtsUeRtb5cEPnqmuLlf55s2aM2dO0wb4PWoBGkAAAQQQ8KpAVEFf0L+/Tm74PPfIqfZs+wVxbf189Mr9ML5QyKzNpfXrSmX/Ay7VFbJCvcb+h1zKtWbNG7ruurHiCwEEEEAAAQTaFuhQ0O/evdv+bPddH+9UqF0vf2ujIw3hvnnTehPqFaqurlRqamobO/G0WwXoFwIIIICAewQ6FPR5vftKDa9y7/BQGsK9snzLwXDv3r17h5tjRwQQQAABBBA4WqBDQb9+zT8lE9Syvsy91Ygd2GYlHjndXqk277dGVu4pKSlWK2yBFWDgCCCAAALxFLAy2nH7PXr00DYT1HaYm3vrVDuB7ZiRHRBAAAEEEIi7QIeCPu694gAItCDAwwgggAACzgQIemdeVCOAAAIIIOApAYLeU9NFZ50JUI0AAgggQNDzN4AAAggggICPBQh6H08uQ3MmQDUCCCDgRwGC3o+zypgQQAABBBBoECDoGyC4Q8CZANUIIICANwQIem/ME71EAAEEEECgQwIEfYfY2AkBZwJUI4AAAskSIOiTJc9xEUAAAQQQSIAAQZ8AZA6BgDMBqhFAAIHYCRD0sbOkJQQQQAABBFwnQNC7bkroEALOBKhGAAEEWhMg6FvT4TkEEEAAAQQ8LkDQe3wC6T4CzgSoRgCBoAkQ9EGbccaLAAIIIBAoAYI+UNPNYBFwJkA1Agh4X4Cg9/4cMgIEEEAAAQRaFCDoW6ThCQQQcCZANQIIuFGAoHfjrNAnBBBAAAEEYiRA0McIkmYQQMCZANUIIJAYAYI+Mc4cBQEEEEAAgaQIEPRJYeegCCDgTIBqBBDoqABB31E59kMAAQQQQMADAgS9ByaJLiKAgDMBqhFA4JAAQX/Igp8QQAABBBDwnQBB77spZUAIIOBMgGoE/C1A0Pt7fhkdAggggEDABQj6gP8BMHwEEHAmQDUCXhMg6L02Y/QXAQQQQAABBwIEvQMsShFAAAFnAlQjkHwBgj75c0APEEAAAQQQiJsAQR83WhpGAAEEnAlQjUA8BAj6eKjSJgIIIIAAAi4RIOhdMhF0AwEEEHAmQDUC7RMg6NvnRBUCCCCAAAKeFCDoPTltdBoBBBBwJkB1cAUI+uDOPSNHAAEEEAiAAEEfgElmiAgggIAzAar9JEDQ+2k2GQsCCCCAAAJNBAj6JiD8igACCCDgTIBqdwsQ9O6eH3qHAAIIIIBAVAIEfVR87IwAAggg4EyA6kQLEPSJFud4CCCAAAIIJFCAoE8gNodCAAEEEHAmQHX0AgR99Ia0gAACCCCAgGsFCHrXTg0dQwABBBBwJkB1cwIEfXMqPIYAAggggIBPBAh6n0wkw0AAAQQQcCYQlGqCPigzzTgRQAABBAIpQNAHctoZNAIIIICAMwHvVhP03p07eo4AAggggECbAgR9m0QUIIAAAggg4EzATdUEvZtmg74ggAACCCAQYwGCPsagNIcAAggggIAzgfhWE/Tx9aV1BBBAAAEEkipA0CeVn4MjgAACCCDgTMBpNUHvVIx6BBBAAAEEPCRA0HtosugqAggggAACzgQkgt6pGPUIIIAAAgh4SICg99Bk0VUEEEAAAQScCjgJeqdtU48AAggggAACSRYg6JM8ARweAQQQQACBeArEL+jj2WvaRgABBBBAAIF2CRD07WKiCAEEEEAAAW8KuCXovalHrxFAAAEEEHC5AEHv8gmiewgggAACCEQj4M2gj2bE7IsAAggggECABAj6AE02Q0UAAQQQCJ5AEII+eLPKiBFAAAEEEGgQIOgbILhDAAEEEEDAjwIEfdNZ5XcEEEAAAQR8JEDQ+2gyGQoCCCCAAAJNBQj6piLOfqcaAQQQQAABVwsQ9K6eHjqHAAIIIIBAdAIEfXR+zvamGgEEEEAAgQQLEPQJBudwCCCAAAIIJFKAoE+ktrNjUY0AAggggEDUAgR91IQ0gAACCCCAgHsFCHr3zo2znlGNAAIIIIBAMwIEfTMoPIQAAggggIBfBAh6v8yks3FQjQACCCAQEAGCPiATzTARQAABBIIpQNAHc96djZpqBBBAAAHPChD0np06Oo4AAggggEDbAgR920ZUOBOgGgEEEEDARQIEvYsmg64ggAACCCAQawGCPtaitOdMgGoEEEAAgbgKEPRx5aVxBBBAAAEEkitA0CfXn6M7E6AaAQQQQMChAEHvEIxyBBBAAAEEvCRA0HtptuirMwGqEUAAAQRE0PNHgAACCCCAgI8FCHofTy5DcyRAMQIIIOBLAYLel9PKoBBAAAEEEIgIEPQRB24RcCZANQIIIOARAYLeIxNFNxFAAAEEEOiIAEHfETX2QcCZANUIIIBA0gQI+qTRc2AEEEAAAQTiL0DQx9+YIyDgTIBqBBBAIIYCBH0MMWkKAQQQQAABtwkQ9G6bEfqDgDMBqhFAAIFWBQj6Vnl4EgEEEEAAAW8LEPTenj96j4AzAaoRQCBwAgR94KacASOAAAIIBEmAoA/SbDNWBJwJUI0AAj4Q+H8AAAD//wbmOJcAAAAGSURBVAMA2tShvADA3XAAAAAASUVORK5CYII=','2026-10-22 21:14:40','172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36'),(5,8,3,'electronic','data:image/png;base64,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','2026-11-04 18:53:02','172.16.1.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36');
/*!40000 ALTER TABLE `work_plan_signatures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_plan_signers`
--

DROP TABLE IF EXISTS `work_plan_signers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_plan_signers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `work_plan_version_id` int NOT NULL,
  `user_id` int NOT NULL,
  `signature_order` int DEFAULT NULL,
  `status` varchar(30) NOT NULL,
  `requested_at` datetime NOT NULL DEFAULT (now()),
  `signed_at` datetime DEFAULT NULL,
  `rejected_at` datetime DEFAULT NULL,
  `rejection_reason` text,
  PRIMARY KEY (`id`),
  KEY `work_plan_version_id` (`work_plan_version_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `work_plan_signers_ibfk_1` FOREIGN KEY (`work_plan_version_id`) REFERENCES `work_plan_versions` (`id`),
  CONSTRAINT `work_plan_signers_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_plan_signers`
--

LOCK TABLES `work_plan_signers` WRITE;
/*!40000 ALTER TABLE `work_plan_signers` DISABLE KEYS */;
INSERT INTO `work_plan_signers` VALUES (1,1,1,NULL,'signed','2026-10-22 16:05:17','2026-10-22 21:06:04',NULL,NULL),(2,1,2,NULL,'signed','2026-10-22 16:05:19','2026-10-22 21:05:34',NULL,NULL),(3,2,1,1,'signed','2026-10-22 16:13:35','2026-10-22 21:14:40',NULL,NULL),(4,2,2,2,'signed','2026-10-22 16:13:35','2026-10-22 21:14:06',NULL,NULL),(5,3,1,1,'pending','2026-10-30 18:31:02',NULL,NULL,NULL),(6,3,2,2,'pending','2026-10-30 18:31:02',NULL,NULL,NULL),(7,3,3,5,'pending','2026-10-30 18:31:02',NULL,NULL,NULL),(8,4,3,NULL,'signed','2026-11-04 13:52:24','2026-11-04 18:53:02',NULL,NULL);
/*!40000 ALTER TABLE `work_plan_signers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_plan_tasks`
--

DROP TABLE IF EXISTS `work_plan_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_plan_tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `work_plan_version_id` int NOT NULL,
  `task_id` int NOT NULL,
  `task_name_snapshot` varchar(255) NOT NULL,
  `task_description_snapshot` text,
  `quantity_snapshot` decimal(15,4) DEFAULT NULL,
  `unit_snapshot` varchar(30) DEFAULT NULL,
  `planned_start_date` date NOT NULL,
  `planned_end_date` date NOT NULL,
  `estimated_duration_days_snapshot` decimal(10,2) DEFAULT NULL,
  `approved_duration_days_snapshot` decimal(10,2) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `work_plan_version_id` (`work_plan_version_id`),
  KEY `task_id` (`task_id`),
  CONSTRAINT `work_plan_tasks_ibfk_1` FOREIGN KEY (`work_plan_version_id`) REFERENCES `work_plan_versions` (`id`),
  CONSTRAINT `work_plan_tasks_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_plan_tasks`
--

LOCK TABLES `work_plan_tasks` WRITE;
/*!40000 ALTER TABLE `work_plan_tasks` DISABLE KEYS */;
INSERT INTO `work_plan_tasks` VALUES (1,1,1,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-22 16:05:02'),(2,1,2,'Cerramiento En Tela Verde',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-22 16:05:02'),(3,1,3,'Localización Y Replanteo',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-22 16:05:02'),(4,2,1,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-22 16:13:35'),(5,2,2,'Cerramiento En Tela Verde',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-22 16:13:35'),(6,2,3,'Localización Y Replanteo',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-22 16:13:35'),(7,2,4,'jsjsjs','wwww',NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-22 16:13:35'),(8,3,1,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-30 18:31:02'),(9,3,2,'Cerramiento En Tela Verde',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-30 18:31:02'),(10,3,3,'Localización Y Replanteo',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-30 18:31:02'),(12,3,5,'Campamento',NULL,NULL,NULL,'2026-10-26','2026-10-31',NULL,NULL,'2026-10-30 18:31:02'),(13,4,6,'Localización Y Replanteo',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-04 13:51:31'),(14,4,7,'Campamento',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-04 13:51:31'),(15,4,8,'Provisionales Electricas y Agua',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-04 13:51:31'),(16,5,11,'Campamento',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:47:47'),(17,5,12,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:47:47'),(18,5,13,'Localización Y Replanteo',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:47:47'),(19,5,14,'Excavación mecánica',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:51:31'),(20,5,15,'Perfilada de zapatas',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:51:46'),(21,5,16,'Solados',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:52:02'),(22,5,17,'Figuracion de Acero Zapatas',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 11:00:23'),(23,5,19,'Provisionales Electricas y Agua',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 11:28:22'),(24,6,17,'Figuracion de Acero Zapatas',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-11 16:32:52'),(25,6,19,'Provisionales Electricas y Agua',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-11 16:32:52'),(26,6,91,'Figuracion Acero Pedestal',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-11 16:32:52'),(27,6,92,'Figuracion placa de piso Tanque',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-11 16:35:46'),(29,6,38,'Zapatas en concreto',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-12 10:59:07'),(30,6,93,'Placa de concreto Tanque',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-12 11:04:33'),(31,7,19,'Provisionales Electricas y Agua',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:45:03'),(32,7,29,'Pedestal en concreto',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:45:40'),(33,7,94,'Figuracion Acero Viga de Amarre',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:45:58'),(34,7,223,'Excavacion Manual Viga de Amarre',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:49:42'),(35,7,224,'Solado Vigas de Amarre',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:53:01'),(36,7,225,'Zapatas Muro Cerramiento Posterior',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:55:27');
/*!40000 ALTER TABLE `work_plan_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_plan_versions`
--

DROP TABLE IF EXISTS `work_plan_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_plan_versions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `work_plan_id` int NOT NULL,
  `version_number` int NOT NULL,
  `created_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `signed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `work_plan_id` (`work_plan_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `work_plan_versions_ibfk_1` FOREIGN KEY (`work_plan_id`) REFERENCES `work_plans` (`id`),
  CONSTRAINT `work_plan_versions_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_plan_versions`
--

LOCK TABLES `work_plan_versions` WRITE;
/*!40000 ALTER TABLE `work_plan_versions` DISABLE KEYS */;
INSERT INTO `work_plan_versions` VALUES (1,1,1,2,'2026-10-22 16:05:02','2026-10-22 21:06:04'),(2,1,2,2,'2026-10-22 16:13:35','2026-10-22 21:14:40'),(3,1,3,3,'2026-10-30 18:31:01',NULL),(4,2,1,3,'2026-11-04 13:51:31','2026-11-04 18:53:02'),(5,3,1,2,'2026-11-07 10:47:47',NULL),(6,4,1,3,'2026-11-11 16:32:52',NULL),(7,5,1,3,'2026-11-14 11:45:03',NULL);
/*!40000 ALTER TABLE `work_plan_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `work_plans`
--

DROP TABLE IF EXISTS `work_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_plans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `obra_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` varchar(30) NOT NULL,
  `current_version_id` int DEFAULT NULL,
  `requested_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_work_plans_uuid` (`uuid`),
  KEY `obra_id` (`obra_id`),
  KEY `requested_by` (`requested_by`),
  CONSTRAINT `work_plans_ibfk_1` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`),
  CONSTRAINT `work_plans_ibfk_2` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `work_plans`
--

LOCK TABLES `work_plans` WRITE;
/*!40000 ALTER TABLE `work_plans` DISABLE KEYS */;
INSERT INTO `work_plans` VALUES (1,'1780d076-996f-4a24-8efd-83dcbe971dc1',2,'Plan 2026-10-19 — Corozal Armotek','2026-10-26','2026-10-31','finished',3,3,'2026-10-22 16:05:02','2026-11-11 14:53:12'),(2,'9b6ce209-5ae0-4318-a355-f9cba9654329',4,'Plan 2026-11-02 — TRAMONTI L2','2026-11-02','2026-11-07','signed',4,3,'2026-11-04 13:51:31','2026-11-04 13:53:02'),(3,'bfb8ca60-6127-47bd-b6db-eb895916af13',5,'Bitacora de Obra N1','2026-11-02','2026-11-07','finished',5,2,'2026-11-07 10:47:47','2026-11-10 13:49:38'),(4,'4f99c44d-ace5-4d2c-bbea-b3ab03ecf1bb',5,'Plan 2026-11-09 — L2 TRAMONTI','2026-11-09','2026-11-14','finished',6,3,'2026-11-11 16:32:52','2026-11-15 00:38:29'),(5,'fce761a5-360b-4631-91eb-4f794fc43851',5,'Bitácora semana 3 noviembre','2026-11-16','2026-11-21','in_execution',7,3,'2026-11-14 11:45:03','2026-11-14 11:45:03');
/*!40000 ALTER TABLE `work_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `worker_assignments`
--

DROP TABLE IF EXISTS `worker_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `worker_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `worker_id` int NOT NULL,
  `obra_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `assigned_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `worker_id` (`worker_id`),
  KEY `obra_id` (`obra_id`),
  KEY `assigned_by` (`assigned_by`),
  CONSTRAINT `worker_assignments_ibfk_1` FOREIGN KEY (`worker_id`) REFERENCES `workers` (`id`),
  CONSTRAINT `worker_assignments_ibfk_2` FOREIGN KEY (`obra_id`) REFERENCES `obras` (`id`),
  CONSTRAINT `worker_assignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `worker_assignments`
--

LOCK TABLES `worker_assignments` WRITE;
/*!40000 ALTER TABLE `worker_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `worker_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `worker_positions`
--

DROP TABLE IF EXISTS `worker_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `worker_positions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `worker_positions`
--

LOCK TABLES `worker_positions` WRITE;
/*!40000 ALTER TABLE `worker_positions` DISABLE KEYS */;
INSERT INTO `worker_positions` VALUES (1,'Maestro',1),(2,'Oficial',1),(3,'Ayudante',1);
/*!40000 ALTER TABLE `worker_positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workers`
--

DROP TABLE IF EXISTS `workers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `person_id` int NOT NULL,
  `worker_position_id` int DEFAULT NULL,
  `specialty_id` int DEFAULT NULL,
  `linked_user_id` int DEFAULT NULL,
  `daily_rate` decimal(12,2) DEFAULT NULL,
  `bank_account` varchar(40) DEFAULT NULL,
  `is_active` int DEFAULT NULL,
  `deactivation_reason` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_id` (`person_id`),
  UNIQUE KEY `ix_workers_person_id` (`person_id`),
  KEY `worker_position_id` (`worker_position_id`),
  KEY `specialty_id` (`specialty_id`),
  KEY `linked_user_id` (`linked_user_id`),
  CONSTRAINT `workers_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `persons` (`id`),
  CONSTRAINT `workers_ibfk_2` FOREIGN KEY (`worker_position_id`) REFERENCES `worker_positions` (`id`),
  CONSTRAINT `workers_ibfk_3` FOREIGN KEY (`specialty_id`) REFERENCES `specialties` (`id`),
  CONSTRAINT `workers_ibfk_4` FOREIGN KEY (`linked_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workers`
--

LOCK TABLES `workers` WRITE;
/*!40000 ALTER TABLE `workers` DISABLE KEYS */;
INSERT INTO `workers` VALUES (1,3,2,NULL,NULL,100000.00,'3122545',1,NULL,'2026-10-22 15:56:47'),(2,5,3,NULL,NULL,NULL,NULL,1,NULL,'2026-10-26 15:23:19'),(3,6,2,NULL,NULL,NULL,NULL,1,NULL,'2026-10-26 15:25:17'),(4,7,2,NULL,NULL,NULL,NULL,1,NULL,'2026-10-26 15:26:23'),(5,8,2,NULL,NULL,NULL,NULL,1,NULL,'2026-10-26 15:27:13'),(6,9,2,NULL,NULL,NULL,NULL,1,NULL,'2026-10-26 15:27:48'),(7,10,3,NULL,NULL,NULL,NULL,1,NULL,'2026-10-26 15:28:51'),(8,11,3,NULL,NULL,NULL,NULL,1,NULL,'2026-10-26 15:32:17'),(9,12,3,NULL,NULL,NULL,NULL,1,NULL,'2026-10-26 15:33:06'),(10,14,2,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 09:54:36'),(11,15,3,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 09:55:04'),(12,16,2,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 09:55:36'),(13,17,2,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 09:56:55'),(14,18,2,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 09:57:31'),(15,19,3,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 09:58:46'),(16,20,2,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 09:59:10'),(17,21,3,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 09:59:39'),(18,22,3,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 10:00:28'),(19,23,3,NULL,NULL,NULL,NULL,1,NULL,'2026-11-14 10:03:04');
/*!40000 ALTER TABLE `workers` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-17 17:45:06
