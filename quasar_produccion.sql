-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: quasar_staging
-- Dump filtrado para producción a partir de quasar_staging.
-- Obras conservadas: 5 (L2 TRAMONTI) y 7 (BELLAGIO B-23),
-- con sus actividades, fotos, documentos, asistencia, bitácoras y auditoría.
-- Las keys de S3 quedaron con el prefijo quasar-prod/.
-- Se conservan todas las personas, roles, usuarios, trabajadores, cargos,
-- capítulos, subcapítulos, zonas y actividades generales.
-- refresh_tokens queda vacío: las sesiones de staging no pasan a producción.
--
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
INSERT INTO `documents` VALUES (2,'56f0d288-ded1-49ea-9410-e96237b7d3d8',7,NULL,'Planos Finales Bellagio',NULL,'quasar-prod/obras/7/documentos/aa2fb08a0eb54016bfd295aeb364e91b.dwg',0,2,'2026-11-14 09:22:09'),(3,'1375536a-96d2-48aa-baf7-13ac70c46036',5,NULL,'Planos L2 Tramonti Finales',NULL,'quasar-prod/obras/5/documentos/f2edfd3467164b7c94ac81907809d718.dwg',0,2,'2026-11-14 09:46:05');
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
INSERT INTO `obra_daily_attendance` VALUES (8,5,'2026-11-13',9,'2026-11-13 17:00:37','acknowledgment','Registrado por administrador en obra',2,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-13 17:00:37',NULL,NULL),(9,5,'2026-11-14',16,'2026-11-14 10:07:34','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:33',NULL,NULL),(10,5,'2026-11-14',19,'2026-11-14 10:07:40','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:39',NULL,NULL),(11,5,'2026-11-14',18,'2026-11-14 10:07:43','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:43',NULL,NULL),(12,5,'2026-11-14',17,'2026-11-14 10:07:47','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:46',NULL,NULL),(13,5,'2026-11-14',10,'2026-11-14 10:07:56','acknowledgment','Registrado por administrador en obra',3,'172.16.1.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36','2026-11-14 10:07:55',NULL,NULL);
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
INSERT INTO `obras` VALUES (5,'L2 TRAMONTI',NULL,1,'Conjunto tramonti','Villa del rosario','Bocono','2026-11-01','2027-05-30',NULL,NULL,'in_progress','quasar-prod/obras/5/cover/08a5d23ece2e4c56980013de84973088.webp',1,'2026-11-07 10:39:26','2026-11-07 10:40:00'),(7,'BELLAGIO B-23',NULL,1,'Conjunto Bellagio','Villa del rosario','Bocono','2026-07-01','2027-01-30',NULL,NULL,'in_progress','quasar-prod/obras/7/cover/7f9c10eef272434ea9bf4e20642fe4ce.webp',1,'2026-11-12 12:41:45','2026-11-12 12:41:47');
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
INSERT INTO `task_comments` VALUES (2,'906dd242-d6d5-4375-aa9a-997d9208c599',19,3,'comment','Falta Provisional de Luz, El agua ya se conectó','2026-11-14 11:41:31',NULL);
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
INSERT INTO `task_photos` VALUES (5,'5dc643f4-5a1d-4160-9d73-562c39e2d58f',11,'quasar-prod/obras/5/tareas/11/fotos/822576c14afa4b2486dd2c7e74b427b3.webp',NULL,NULL,2,'2026-11-07 10:54:03'),(6,'086de4a3-0531-4110-985c-f41cffa02a28',12,'quasar-prod/obras/5/tareas/12/fotos/18bc5c572a0749e38e54fdb22eba352d.webp',NULL,NULL,2,'2026-11-07 10:54:39'),(7,'9f5ce7e6-bf1b-4004-954e-e1a1e831fd8a',12,'quasar-prod/obras/5/tareas/12/fotos/81b9daa5a6534cd0a5f932debf542a38.webp',NULL,NULL,2,'2026-11-07 10:54:45'),(8,'b0d6c73e-17ea-4847-b089-0ab79df4ad82',14,'quasar-prod/obras/5/tareas/14/fotos/27bc9329a1a743e8a6c75bd2b6162f1e.webp',NULL,NULL,2,'2026-11-07 10:55:29'),(9,'93d96aa5-a383-412c-8b13-eb06af8d364c',14,'quasar-prod/obras/5/tareas/14/fotos/1cebf77ab5eb45fea8626a2fff7cc5c8.webp',NULL,NULL,2,'2026-11-07 10:55:37'),(10,'d0a616f8-c183-49f1-820f-f773353ac72d',15,'quasar-prod/obras/5/tareas/15/fotos/b4d384e65dd14c84aabad609d9515276.webp',NULL,NULL,2,'2026-11-07 10:59:13'),(11,'7f6172dc-2efc-4eb9-8c9b-d944d03cf183',16,'quasar-prod/obras/5/tareas/16/fotos/6ecaac4d8d9242c6acb69c45e97fcc46.webp',NULL,NULL,2,'2026-11-07 11:00:48'),(12,'08832063-dbf7-4831-94fd-6476c30e364a',17,'quasar-prod/obras/5/tareas/17/fotos/68cae4c3d88742968410e5cf852efb25.webp',NULL,NULL,2,'2026-11-07 11:01:32'),(13,'40f55208-1a37-4db8-99fa-00acf6aca45e',17,'quasar-prod/obras/5/tareas/17/fotos/9fa4e901ba2a4e8ca63f808ab3ff4c71.webp',NULL,NULL,2,'2026-11-07 11:01:38'),(14,'4b53d2e4-5fb1-4d57-bda2-d604fbfcde51',17,'quasar-prod/obras/5/tareas/17/fotos/d2a69991c3e94749a2946de0557dc551.webp',NULL,NULL,2,'2026-11-07 11:01:50'),(15,'bf879815-2ce4-4907-aa16-22693f036b0c',17,'quasar-prod/obras/5/tareas/17/fotos/7e8775919e3b4a15b3fe0808284e6cfc.webp',NULL,NULL,2,'2026-11-07 11:01:56'),(16,'792b58e0-f0ab-4ff3-8730-bfc3539c6738',17,'quasar-prod/obras/5/tareas/17/fotos/942f9f0d297645b7a184eaaa54c14bb3.webp',NULL,NULL,2,'2026-11-07 11:02:01'),(17,'aa6e16b8-4017-4cc3-bf96-f428643d27a1',92,'quasar-prod/obras/5/tareas/92/fotos/1d36f6a934ad4a9397104b034a294f17.webp',NULL,NULL,3,'2026-11-13 12:55:48'),(18,'968b1db9-086a-481e-ada5-a501dbddfd26',93,'quasar-prod/obras/5/tareas/93/fotos/d11ce3c5de8a49a582971d717e8b398f.webp',NULL,NULL,3,'2026-11-13 15:18:17'),(19,'bed1d6d5-0d9c-44ef-95ea-5595998d4bd0',38,'quasar-prod/obras/5/tareas/38/fotos/1c69be14ca2144ca99112759f24ce9a8.webp',NULL,NULL,3,'2026-11-13 15:19:31'),(20,'607f8099-0aec-41de-8b19-66682bf5f3f4',38,'quasar-prod/obras/5/tareas/38/fotos/7ecfd5424b5c4acab29659d4b50e7ac4.webp',NULL,NULL,3,'2026-11-13 15:19:40'),(21,'1294c36d-1147-4830-af5f-3d707d618170',38,'quasar-prod/obras/5/tareas/38/fotos/68a61533feb44a1c9eaec793a871f98c.webp',NULL,NULL,3,'2026-11-13 15:19:48'),(22,'d99b1f93-4d92-4cf5-abd0-321f168f0d8d',29,'quasar-prod/obras/5/tareas/29/fotos/90978e263e714b7cbc94debcd693e52c.webp',NULL,NULL,2,'2026-11-17 10:14:42'),(23,'6002b4c3-0b1e-4901-abe4-5328c9b1f1ae',29,'quasar-prod/obras/5/tareas/29/fotos/5fb4a4940fe94dd3aa4107968ba12c73.webp',NULL,NULL,2,'2026-11-17 10:15:08');
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
INSERT INTO `task_status_history` VALUES (27,11,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:47:47'),(28,12,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:47:47'),(29,13,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:47:47'),(30,13,'scheduled','in_progress',NULL,2,'2026-11-07 10:48:51'),(31,12,'scheduled','in_progress',NULL,2,'2026-11-07 10:48:55'),(32,11,'scheduled','in_progress',NULL,2,'2026-11-07 10:48:59'),(33,13,'in_progress','completed',NULL,2,'2026-11-07 10:49:05'),(34,12,'in_progress','completed',NULL,2,'2026-11-07 10:49:07'),(35,11,'in_progress','completed',NULL,2,'2026-11-07 10:49:11'),(36,14,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:51:31'),(37,15,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:51:46'),(38,16,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 10:52:02'),(39,15,'scheduled','in_progress',NULL,2,'2026-11-07 10:53:08'),(40,15,'in_progress','completed',NULL,2,'2026-11-07 10:53:11'),(41,16,'scheduled','in_progress',NULL,2,'2026-11-07 10:53:20'),(42,16,'in_progress','completed',NULL,2,'2026-11-07 10:53:28'),(43,14,'scheduled','in_progress',NULL,2,'2026-11-07 10:53:30'),(44,14,'in_progress','completed',NULL,2,'2026-11-07 10:53:33'),(45,17,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 11:00:23'),(46,17,'scheduled','in_progress',NULL,2,'2026-11-07 11:00:28'),(47,18,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-07 11:25:17'),(48,19,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 11:28:22'),(49,20,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-07 11:36:24'),(51,22,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:03:28'),(52,23,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:03:39'),(53,24,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:03:48'),(54,25,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:03:58'),(56,27,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:04:19'),(58,29,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:04:35'),(59,30,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:04:48'),(60,31,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:04:58'),(61,32,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:08'),(63,34,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:31'),(64,35,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:39'),(65,36,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:47'),(66,37,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:05:57'),(67,38,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:06:06'),(69,40,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:06:28'),(72,43,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:02'),(73,44,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:10'),(74,45,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:18'),(75,46,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:27'),(76,47,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:35'),(77,48,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:43'),(78,49,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:52'),(79,50,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:07:59'),(80,51,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:13'),(81,52,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:22'),(82,53,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:33'),(83,54,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:42'),(84,55,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:08:54'),(85,56,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:04'),(86,57,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:12'),(87,58,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:22'),(88,59,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:32'),(89,60,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:41'),(90,61,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:50'),(91,62,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:09:58'),(92,63,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:08'),(93,64,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:16'),(94,65,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:26'),(95,66,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:34'),(96,67,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:10:42'),(97,68,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:12'),(98,69,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:20'),(99,70,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:28'),(100,71,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:36'),(101,72,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:47'),(102,73,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:11:57'),(103,74,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:06'),(104,75,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:15'),(105,76,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:25'),(106,77,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:33'),(107,78,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:41'),(108,79,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:12:51'),(109,80,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:00'),(110,81,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:07'),(111,82,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:14'),(112,83,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:26'),(113,84,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:34'),(114,85,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:43'),(115,86,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:13:52'),(116,87,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:14:00'),(117,88,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:14:10'),(118,89,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:14:18'),(119,90,NULL,'scheduled','Registrada en el periodo, sin versión',1,'2026-11-09 14:14:26'),(120,91,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-11 16:32:52'),(121,17,'in_progress','completed',NULL,3,'2026-11-11 16:33:47'),(122,91,'scheduled','in_progress',NULL,3,'2026-11-11 16:33:53'),(123,19,'scheduled','in_progress',NULL,3,'2026-11-11 16:34:02'),(124,92,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-11 16:35:46'),(125,92,'scheduled','in_progress',NULL,3,'2026-11-11 16:35:56'),(126,38,'scheduled','in_progress',NULL,3,'2026-11-12 10:59:16'),(127,93,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-12 11:04:16'),(128,93,'scheduled','in_progress',NULL,3,'2026-11-12 11:04:38'),(129,91,'in_progress','completed',NULL,3,'2026-11-12 11:04:55'),(130,94,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-12 11:58:37'),(131,95,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(132,96,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(133,97,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(134,98,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(135,99,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(136,100,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(137,101,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(138,102,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(139,103,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(140,104,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(141,105,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(142,106,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(143,107,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(144,108,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(145,109,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(146,110,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(147,111,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(148,112,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(149,113,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(150,114,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(151,115,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(152,116,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(153,117,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(154,118,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(155,119,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(156,120,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(157,121,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(158,122,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(159,123,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(160,124,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(161,125,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(162,126,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(163,127,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(164,128,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(165,129,NULL,'completed','Marcada como hecha al crear la obra: el capítulo ya venía completado',3,'2026-11-12 12:41:45'),(166,130,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(167,131,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(168,132,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(169,133,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(170,134,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(171,135,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(172,136,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(173,137,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(174,138,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(175,139,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(176,140,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(177,141,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(178,142,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(179,143,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(180,144,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(181,145,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(182,146,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(183,147,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(184,148,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(185,149,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(186,150,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(187,151,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(188,152,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(189,153,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(190,154,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:45'),(191,155,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(192,156,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:45'),(193,157,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(194,158,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(195,159,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(196,160,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(197,161,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(198,162,NULL,'completed','Ya estaba lista al crear la obra: el capítulo llega a medias',3,'2026-11-12 12:41:46'),(199,163,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(200,164,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(201,165,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(202,166,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(203,167,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(204,168,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(205,169,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(206,170,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(207,171,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(208,172,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(209,173,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(210,174,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(211,175,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(212,176,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(213,177,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(214,178,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(215,179,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(216,180,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(217,181,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(218,182,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(219,183,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(220,184,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(221,185,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(222,186,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(223,187,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(224,188,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(225,189,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(226,190,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(227,191,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(228,192,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(229,193,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(230,194,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(231,195,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(232,196,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(233,197,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(234,198,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(235,199,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(236,200,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(237,201,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(238,202,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(239,203,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(240,204,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(241,205,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(242,206,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(243,207,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(244,208,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(245,209,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(246,210,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(247,211,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(248,212,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(249,213,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(250,214,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(251,215,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(252,216,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(253,217,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(254,218,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(255,219,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(256,220,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(257,221,NULL,'scheduled','Copiada al crear la obra porque la actividad está marcada como fija',3,'2026-11-12 12:41:46'),(258,92,'in_progress','completed',NULL,3,'2026-11-13 12:56:08'),(259,93,'in_progress','completed',NULL,3,'2026-11-13 15:18:21'),(260,38,'in_progress','completed',NULL,3,'2026-11-13 15:19:50'),(261,222,NULL,'scheduled','Registrada en el periodo, sin versión',2,'2026-11-14 09:28:54'),(262,223,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-14 11:49:24'),(263,224,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-14 11:52:44'),(264,225,NULL,'scheduled','Registrada en el periodo, sin versión',3,'2026-11-14 11:55:08'),(265,29,'scheduled','in_progress',NULL,2,'2026-11-17 10:14:17');
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
INSERT INTO `tasks` VALUES (11,'63acf77a-d7b9-4230-b715-72520b8b0821',5,4,NULL,NULL,'Campamento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,20.00,2,'2026-11-07 10:47:47',2,'2026-11-07 15:54:12',1,1,NULL),(12,'5bb820f0-a0b1-4463-9673-bfefafcae2d8',5,1,NULL,NULL,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,20.00,2,'2026-11-07 10:47:47',2,'2026-11-07 15:54:54',1,1,NULL),(13,'fd865679-0c6f-4cfb-ae4e-29949300fea1',5,3,NULL,NULL,'Localización Y Replanteo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,20.00,2,'2026-11-07 10:47:47',NULL,'2026-11-07 10:49:05',1,1,NULL),(14,'10141006-693f-411b-a5aa-9fdc0b502eff',5,9,NULL,NULL,'Excavación mecánica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,4.55,2,'2026-11-07 10:51:31',2,'2026-11-07 15:58:39',2,3,NULL),(15,'508084da-8bf1-4b8f-81cb-85d3b80318f7',5,11,NULL,NULL,'Perfilada de zapatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,4.55,2,'2026-11-07 10:51:46',NULL,'2026-11-12 11:36:41',2,3,1),(16,'c9d8b43a-3c7a-4979-a9a3-659b16e9ecd6',5,13,NULL,NULL,'Solados',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-02','2026-11-07','2026-11-07','2026-11-07','completed',NULL,4.55,2,'2026-11-07 10:52:02',2,'2026-11-07 16:00:52',2,3,NULL),(17,'eafe6e5a-9372-4d70-a351-9186fcfb246f',5,120,NULL,NULL,'Figuracion de Acero Zapatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-07','2026-11-11','completed',NULL,3.70,2,'2026-11-07 11:00:23',2,'2026-11-13 15:19:04',2,3,1),(18,'6f012618-f9cd-441c-88e1-4a4b75f692a0',5,8,NULL,NULL,'Excavación manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-07 11:25:17',NULL,'2026-11-12 11:36:10',2,3,1),(19,'0fa6ce8c-553a-44bb-a1af-11732c93b79c',5,5,NULL,NULL,'Provisionales Electricas y Agua',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21','2026-11-11',NULL,'in_progress',NULL,20.00,2,'2026-11-07 11:28:22',3,'2026-11-14 11:45:03',1,1,NULL),(20,'844ea6cc-2aac-4d28-8489-dab09941e49b',5,10,NULL,NULL,'Relleno compactado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,2,'2026-11-07 11:36:24',NULL,NULL,2,3,NULL),(22,'3e1dace8-441a-434d-b777-99a202c90474',5,18,NULL,NULL,'Columnas en concreto N1 a N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:03:28',NULL,'2026-11-12 11:35:12',2,3,1),(23,'77928c36-0753-44b1-9e02-b009fd4b1eeb',5,25,NULL,NULL,'Columnas en concreto N2 a N3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:03:39',NULL,'2026-11-12 11:35:18',2,3,1),(24,'a0212e91-aa9c-4c79-8479-0871dcb42d11',5,12,NULL,NULL,'Concreto ciclopeo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:03:48',NULL,'2026-11-12 11:35:33',2,3,1),(25,'9bd38ca7-8a6f-4287-b230-8fe9b7ccaec1',5,29,NULL,NULL,'Desencofrado formaleta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:03:58',NULL,'2026-11-12 11:35:44',2,3,1),(27,'ce871162-9745-479b-89f4-32a9dc69e6d1',5,22,NULL,NULL,'Fundida pasos escalera',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:04:19',NULL,'2026-11-12 11:36:27',2,3,1),(29,'33e8b37e-da94-42c5-a79f-c5d880c060cf',5,14,NULL,NULL,'Pedestal en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21','2026-11-17',NULL,'in_progress',NULL,4.35,1,'2026-11-09 14:04:35',2,'2026-11-17 15:15:46',2,3,NULL),(30,'0a37e5ec-9268-4f6b-b895-096a8b91441b',5,27,NULL,NULL,'Placa cubierta en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:04:48',NULL,NULL,2,3,NULL),(31,'4fd38ba9-8711-4f01-bb77-ed489f923aca',5,16,NULL,NULL,'Placa de cimentación en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:04:58',NULL,NULL,2,3,NULL),(32,'39a7f3ac-fd89-45d0-a58a-bf5a3af86a7a',5,17,NULL,NULL,'Placa de contrapiso con malla e=0,10max',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:08',NULL,NULL,2,3,NULL),(34,'c7ae1f61-e2c4-41e4-8353-60a562b9be84',5,24,NULL,NULL,'Placa entrepiso en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:31',NULL,NULL,2,3,NULL),(35,'d52a2924-f5f3-445b-a82a-c6e078e79e17',5,7,NULL,NULL,'Viga de amarre en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:39',NULL,NULL,2,3,NULL),(36,'3fc10519-2788-4556-80ab-d6cd4ce77504',5,26,NULL,NULL,'Vigas aereas de cubierta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:47',NULL,NULL,2,3,NULL),(37,'67d57783-4410-423b-a33a-428685e50ba5',5,23,NULL,NULL,'Vigas aereas entrepisos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,4.35,1,'2026-11-09 14:05:57',NULL,NULL,2,3,NULL),(38,'3bbe1d27-00d4-43e1-8b1b-747a09a69604',5,6,NULL,NULL,'Zapatas en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-12','2026-11-13','completed',NULL,3.70,1,'2026-11-09 14:06:06',3,'2026-11-13 20:19:52',2,3,1),(40,'94488b93-0831-41b0-9938-34fda1b5000e',5,21,NULL,NULL,'Escalera metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:06:28',NULL,'2026-11-12 11:36:01',2,2,1),(43,'71175166-2543-49ac-9094-2222728b7518',5,56,NULL,NULL,'Conexiones & puesta en funcionamiento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:02',NULL,NULL,4,5,NULL),(44,'730ba365-1429-4ef3-83e4-09915da466a1',5,51,NULL,NULL,'Instalación cajas y accesorios',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:10',NULL,NULL,4,5,NULL),(45,'dd0890a1-1566-4b3a-8e07-e2335cb1532c',5,53,NULL,NULL,'Instalación de tablero',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:18',NULL,NULL,4,5,NULL),(46,'060b8f41-0172-441c-a6af-76447a38258b',5,55,NULL,NULL,'Instalación luminarias',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:27',NULL,NULL,4,5,NULL),(47,'a35895d4-8477-490c-a6bc-6ea5e2257428',5,54,NULL,NULL,'Instalación tomacorrientes-interruptores',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:35',NULL,NULL,4,5,NULL),(48,'7ff1c706-52b0-4730-81ba-af26165d97bc',5,50,NULL,NULL,'Regatas y/o cajas eléctricas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:43',NULL,NULL,4,5,NULL),(49,'ed03839a-85ad-4eab-9a23-cc18aec5cdf4',5,52,NULL,NULL,'Tendido cableado eléctrico',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:52',NULL,NULL,4,5,NULL),(50,'b5b06f2f-921d-421d-903a-7498ac621141',5,49,NULL,NULL,'Tendido de tuberia eléctrica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:07:59',NULL,NULL,4,5,NULL),(51,'aa4b047d-4465-4b85-bf4b-4052725e272e',5,40,NULL,NULL,'Bajantes aguas lluvias',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:13',NULL,NULL,3,4,NULL),(52,'77e570cd-be23-4777-96df-a3b570d404f1',5,39,NULL,NULL,'Bajantes sanitarios',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:22',NULL,NULL,3,4,NULL),(53,'d6b56339-48ed-4d74-94af-66bea5175f2b',5,34,NULL,NULL,'Caja de inspección',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:33',NULL,NULL,3,4,NULL),(54,'d3849576-3278-41c5-b807-e459f7e2b443',5,32,NULL,NULL,'Excavacion manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:42',NULL,NULL,3,4,NULL),(55,'88513207-cb70-4cfa-8af9-c936445d888e',5,46,NULL,NULL,'Instalación de tanques + pruebas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:08:54',NULL,NULL,3,4,NULL),(56,'84a39d58-ca63-447b-a5e7-2637f45eaae9',5,48,NULL,NULL,'Instalación sistema de bombeo piscina',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:04',NULL,NULL,3,4,2),(57,'62593b5b-7a62-48c9-9c17-2ca354c97c6a',5,47,NULL,NULL,'Instalación sistema de bombeo tanque subt',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:12',NULL,NULL,3,4,NULL),(58,'db7fb0e6-53a5-41e3-9df5-68ef80a82848',5,38,NULL,NULL,'Puntos desagües sanitarios N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:22',NULL,NULL,3,4,NULL),(59,'e22b9dc6-c006-48c8-a937-d40767562a19',5,42,NULL,NULL,'Puntos desagües sanitarios N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:32',NULL,NULL,3,4,NULL),(60,'e3ba924f-d622-44ff-a340-0d436875598a',5,45,NULL,NULL,'Puntos hidraulicos agua caliente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:41',NULL,NULL,3,4,NULL),(61,'8011e185-473d-4496-9438-8801cbe0330b',5,44,NULL,NULL,'Puntos hidraulicos agua fria',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:50',NULL,NULL,3,4,NULL),(62,'eba10900-d3b0-41aa-b891-05b4634ce96c',5,33,NULL,NULL,'Tapadas de tuberia',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:09:58',NULL,NULL,3,4,NULL),(63,'6d38c60b-bf7e-455e-8cce-0ccd6f61519f',5,36,NULL,NULL,'Tuberia aguas lluvias principal N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:08',NULL,NULL,3,4,NULL),(64,'ca24b77d-8aa2-47e0-8b0c-76f705e0329e',5,43,NULL,NULL,'Tuberia Hidraulica Vertical',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:16',NULL,NULL,3,4,NULL),(65,'f0185067-16fa-40c9-b1e1-c6df212c394b',5,37,NULL,NULL,'Tuberia presión N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:26',NULL,NULL,3,4,NULL),(66,'2f868052-0f0e-4c03-9c41-2567ab8a7784',5,41,NULL,NULL,'Tuberia sanitaria descolgada placa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:34',NULL,NULL,3,4,NULL),(67,'6313faa0-7067-4910-8fde-228e9a189b35',5,35,NULL,NULL,'Tuberia sanitaria principal N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,1,'2026-11-09 14:10:42',NULL,NULL,3,4,NULL),(68,'3bdfcbd5-6e8d-4dc5-a42a-b2a06ecb016f',5,66,NULL,NULL,'Columneta de confinamiento bloque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:12',NULL,NULL,5,6,NULL),(69,'a7339fee-7c28-4b64-abda-d4b47e8b804b',5,62,NULL,NULL,'Dinteles en varilla',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:20',NULL,NULL,5,6,NULL),(70,'dcd4c300-458f-4b27-8934-dd9ce4d16b9f',5,63,NULL,NULL,'Muro bloque cemento e=0,09',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:28',NULL,NULL,5,6,NULL),(71,'c1aef9ac-c795-4b51-aa8a-59fb5fa082bb',5,64,NULL,NULL,'Muro bloque cemento e=0,12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:36',NULL,NULL,5,6,NULL),(72,'eaa2ac32-bdae-47ec-bb23-7e2261246de4',5,65,NULL,NULL,'Muro bloque cemento e=0,20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:47',NULL,NULL,5,6,NULL),(73,'f5d1d0cf-1172-49bb-9244-2c202c7bfc88',5,59,NULL,NULL,'Muro en bloque #5 1er piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:11:57',NULL,NULL,5,6,NULL),(74,'55e48662-d4eb-47b8-8910-75cded314d07',5,60,NULL,NULL,'Muro en bloque #5 2do piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:06',NULL,NULL,5,6,NULL),(75,'12bff2b9-6f1d-4bfa-a0a3-36252ff468cd',5,61,NULL,NULL,'Muro en bloque #5 culatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:15',NULL,NULL,5,6,NULL),(76,'db7e1608-8d84-4358-be6b-83ce293cbde3',5,58,NULL,NULL,'Muro en ladrillo de obra doble',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:25',NULL,NULL,5,6,NULL),(77,'a682884c-4392-425b-8f32-0d3f2002c28b',5,57,NULL,NULL,'Muro en ladrillo de obra sencillo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:33',NULL,NULL,5,6,NULL),(78,'d47e01d7-bb00-4b1d-a22d-0775e9b41858',5,67,NULL,NULL,'Relleno celdas bloque estructural',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,1,'2026-11-09 14:12:41',NULL,NULL,5,6,NULL),(79,'9e4ea398-9cf4-461c-8ce4-fafc92bdbe23',5,79,NULL,NULL,'Dilataciones en z muro',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:12:51',NULL,NULL,5,8,NULL),(80,'1c9f9dec-f7b0-4ecc-b6d7-53df94c57fe0',5,77,NULL,NULL,'Muro doble en drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:13:00',NULL,NULL,5,8,NULL),(81,'8a35e155-b399-49f7-bf7a-85bb0e16b4a9',5,78,NULL,NULL,'Muro doble en superboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:13:07',NULL,NULL,5,8,NULL),(82,'19f0bc71-0bfc-4382-8cc7-cb7fed2c71f2',5,76,NULL,NULL,'Muro sencillo en drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,1,'2026-11-09 14:13:14',NULL,NULL,5,8,NULL),(83,'d32cd1cd-5034-42fc-97b9-beefdcd02720',5,73,NULL,NULL,'Dilataciones en pañetes',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:13:26',NULL,NULL,5,7,NULL),(84,'f3baae15-c30a-4ab8-8e23-fb2b06d45a6e',5,74,NULL,NULL,'Filos en pañetes',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:13:34',NULL,NULL,5,7,NULL),(85,'6eb5f635-34eb-493d-bd47-4817dec8149c',5,72,NULL,NULL,'Goteros en borde de placas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:13:43',NULL,NULL,5,7,NULL),(86,'ccc058ba-72ef-4e4d-a145-18c5163f1ce8',5,75,NULL,NULL,'Media caña cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:13:52',NULL,NULL,5,7,NULL),(87,'d2c5a5f9-7a2a-41e2-b422-3f7ccf8cd37b',5,69,NULL,NULL,'Pañete de muros fachada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:14:00',NULL,NULL,5,7,NULL),(88,'c5037ff2-c697-4cbb-8b90-622f383b4e0d',5,68,NULL,NULL,'Pañete de muros internos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:14:10',NULL,NULL,5,7,NULL),(89,'739cea0a-7fac-4a98-8b2a-deaf8834b6a4',5,70,NULL,NULL,'Pañete de placas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:14:18',NULL,NULL,5,7,NULL),(90,'68a6350d-5114-421e-bafc-3c4b3241e79b',5,71,NULL,NULL,'Pañete de placas fachada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,1,'2026-11-09 14:14:26',NULL,NULL,5,7,NULL),(91,'ec61141c-0e7e-463a-984e-398f1a32069b',5,125,NULL,NULL,'Figuracion Acero Pedestal',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-11','2026-11-12','completed',NULL,4.17,3,'2026-11-11 16:32:52',NULL,'2026-11-12 11:04:55',2,3,1),(92,'b8ec2610-37d4-4bbd-84a2-ac4c8f5c88a4',5,126,NULL,NULL,'Figuracion placa de piso Tanque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-11','2026-11-13','completed',NULL,4.00,3,'2026-11-11 16:35:46',3,'2026-11-13 17:56:13',2,3,2),(93,'478a1748-c1a8-4bd7-8ff6-46f77e4febd4',5,127,NULL,NULL,'Placa de concreto Tanque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-09','2026-11-14','2026-11-12','2026-11-13','completed',NULL,3.85,3,'2026-11-12 11:04:16',3,'2026-11-13 20:18:23',2,3,2),(94,'9827a6bb-5767-4cc4-986d-3f35ec0302de',5,128,NULL,NULL,'Figuracion Acero Viga de Amarre',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'scheduled',NULL,3.70,3,'2026-11-12 11:58:37',NULL,'2026-11-14 11:45:58',2,3,1),(95,'c1dfd359-01f7-4ac4-9f13-c278c199d7ee',7,4,NULL,NULL,'Campamento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(96,'c52c6268-e42b-4b6f-9085-036c542860cc',7,2,NULL,NULL,'Cerramiento En Tela Verde',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(97,'cc87f7f7-a058-4370-95df-6d11e5238df5',7,1,NULL,NULL,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(98,'927e562b-d7e8-4bcc-83a9-ec2aec4d6050',7,3,NULL,NULL,'Localización Y Replanteo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(99,'9c4fb0f0-eb65-4d36-bcf4-24ace65fd3cd',7,5,NULL,NULL,'Provisionales Electricas y Agua',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,20.00,3,'2026-11-12 12:41:45',NULL,NULL,1,1,NULL),(100,'a5ee5072-a9d2-4633-82a8-8262cf314c2c',7,18,NULL,NULL,'Columnas en concreto N1 a N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(101,'0aa554a7-ae7b-4eb9-a690-9e5d3658739e',7,25,NULL,NULL,'Columnas en concreto N2 a N3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(102,'c982b2a8-d44a-4158-b660-24f7cb9233da',7,30,NULL,NULL,'Columnas en tuberia metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,25.00,3,'2026-11-12 12:41:45',NULL,NULL,2,2,NULL),(103,'ac8fb532-f5a1-402d-b5d2-a4bb4a6e58ef',7,12,NULL,NULL,'Concreto ciclopeo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(104,'4978a7c3-3657-42e7-a306-b6f2ac996c90',7,29,NULL,NULL,'Desencofrado formaleta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(105,'438403b1-2400-40b5-9491-0e1a6a149509',7,20,NULL,NULL,'Escalera en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(106,'7797cec4-57d4-4444-a445-ce0dfa4c3ade',7,21,NULL,NULL,'Escalera metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,25.00,3,'2026-11-12 12:41:45',NULL,NULL,2,2,1),(107,'8fa272bd-3476-4e24-8614-82df838227ba',7,8,NULL,NULL,'Excavación manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(108,'f76db3f4-24ea-4731-a3b4-c5ad00d7e33f',7,9,NULL,NULL,'Excavación mecánica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(109,'87c09855-53a6-4260-9d38-064114ec4114',7,125,NULL,NULL,'Figuracion Acero Pedestal',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(110,'77237c8a-e278-443d-b002-a09cee14b05c',7,120,NULL,NULL,'Figuracion de Acero Zapatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(111,'6495b373-e226-491b-94db-a8fa31fc25b0',7,126,NULL,NULL,'Figuracion placa de piso Tanque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,2),(112,'2505cd5b-d911-4f4a-b6ac-c231bc365cfa',7,22,NULL,NULL,'Fundida pasos escalera',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(113,'569256b3-568e-4520-b02e-1985d00b2459',7,19,NULL,NULL,'Pantalla en concreto N1 a N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(114,'54fea935-ec5f-472d-92ee-5b9646789528',7,14,NULL,NULL,'Pedestal en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(115,'6c02e0f0-69c1-4bc3-a5b5-c67eb9ecafbe',7,11,NULL,NULL,'Perfilada de zapatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,1),(116,'af285800-0684-424a-9e78-f0f16571bb85',7,27,NULL,NULL,'Placa cubierta en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(117,'525dc42b-6e53-40df-89f0-6c9ce8a7e960',7,16,NULL,NULL,'Placa de cimentación en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(118,'37dc3a66-5c38-4973-968a-7d3be8213264',7,127,NULL,NULL,'Placa de cimentacion en concreto Tanque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,2),(119,'c51b7fc2-5aa9-48f3-8d02-db5e26b55d60',7,17,NULL,NULL,'Placa de contrapiso con malla e=0,10max',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(120,'9bf65585-cda0-426d-b9c6-da416879964a',7,28,NULL,NULL,'Placa de entrepiso con bloque #5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(121,'2be7793e-4c8a-4889-81bc-48c47f77bdfb',7,24,NULL,NULL,'Placa entrepiso en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(122,'8fc8163a-15d8-4f02-890e-3d1ec6961aec',7,10,NULL,NULL,'Relleno compactado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(123,'085c4596-f631-4ccd-9245-d676a019f9d5',7,13,NULL,NULL,'Solados',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(124,'f0b51279-2403-4789-ad1c-6792de910d65',7,7,NULL,NULL,'Viga de amarre en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(125,'1d2c1ad8-cfc3-451b-8f6c-84fd75452b3b',7,15,NULL,NULL,'Viga de amarre metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,25.00,3,'2026-11-12 12:41:45',NULL,NULL,2,2,NULL),(126,'04333110-6c68-442b-9fd9-45c35b66c1fb',7,26,NULL,NULL,'Vigas aereas de cubierta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(127,'695cbfb2-edce-4962-9fc1-dee2ba8bf649',7,23,NULL,NULL,'Vigas aereas entrepisos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,NULL,2,3,NULL),(128,'c5814e55-1d4b-46e3-938e-308e277f8102',7,31,NULL,NULL,'Vigas en tuberia metalica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,25.00,3,'2026-11-12 12:41:45',NULL,NULL,2,2,NULL),(129,'a794df02-277b-428c-976e-e02f51e05de0',7,6,NULL,NULL,'Zapatas en concreto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completed',NULL,3.70,3,'2026-11-12 12:41:45',NULL,'2026-11-13 15:18:52',2,3,1),(130,'92833f22-7914-4eea-9cb1-e45495348ed4',7,51,NULL,NULL,'Instalación cajas y accesorios',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(131,'f7934770-5723-444b-a1b0-fa9288dc2976',7,53,NULL,NULL,'Instalación de tablero',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(132,'139aa2f9-8e30-4dc5-a37a-2fcfed87761a',7,54,NULL,NULL,'Instalación tomacorrientes-interruptores',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(133,'c75fb52a-2ec8-42d3-b6f0-3dcfcf2a3fa5',7,50,NULL,NULL,'Regatas y/o cajas eléctricas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(134,'616733b7-577a-4a38-b70b-4608b8e6d392',7,52,NULL,NULL,'Tendido cableado eléctrico',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(135,'4983dd7a-3902-4bcd-9a62-77469c50ec47',7,49,NULL,NULL,'Tendido de tuberia eléctrica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',4,5,NULL),(136,'6a488a53-a248-45df-bc44-764dd2f8d723',7,56,NULL,NULL,'Conexiones & puesta en funcionamiento',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:45',NULL,NULL,4,5,NULL),(137,'ea8c5b37-9589-4367-878a-80ab0d2069cb',7,55,NULL,NULL,'Instalación luminarias',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:45',NULL,NULL,4,5,NULL),(138,'569c5ac1-631f-421e-87c9-0d53bcd6929d',7,34,NULL,NULL,'Caja de inspección',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(139,'a6f6a35c-8410-4d5e-8a39-8fca2b7b645b',7,32,NULL,NULL,'Excavacion manual',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(140,'5f0d871c-e84c-49ec-8810-0aa9726d1028',7,46,NULL,NULL,'Instalación de tanques + pruebas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(141,'c1b89c28-accc-4918-a0b1-cd098bc37106',7,38,NULL,NULL,'Puntos desagües sanitarios N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(142,'eb822a94-13f5-46d6-9ae6-707100b1217a',7,42,NULL,NULL,'Puntos desagües sanitarios N2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(143,'f16ea64f-806e-4467-ab26-7d4132d18ef9',7,45,NULL,NULL,'Puntos hidraulicos agua caliente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(144,'914572b1-2a7d-45d4-ae3f-48bb72367dd3',7,44,NULL,NULL,'Puntos hidraulicos agua fria',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(145,'3fce6867-bc99-4939-954b-3244da944f64',7,33,NULL,NULL,'Tapadas de tuberia',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(146,'313c7a09-244e-438b-b4fc-81ea7138deb6',7,36,NULL,NULL,'Tuberia aguas lluvias principal N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(147,'f5a6927e-e649-45d9-87b6-799cf87f831d',7,41,NULL,NULL,'Tuberia sanitaria descolgada placa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(148,'534490e3-3210-482c-91fd-7385ae49f3cc',7,35,NULL,NULL,'Tuberia sanitaria principal N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,5.88,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',3,4,NULL),(149,'adb3d36d-014a-48d3-9ab7-1c2b4f9297a9',7,40,NULL,NULL,'Bajantes aguas lluvias',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(150,'010531e0-0573-4542-bb97-2c38bdea6665',7,39,NULL,NULL,'Bajantes sanitarios',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(151,'2c718482-696e-404d-b1c7-6ccccc2f4620',7,48,NULL,NULL,'Instalación sistema de bombeo piscina',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,2),(152,'3acb2b5c-a1cb-4e9e-85a4-d67328e386c2',7,47,NULL,NULL,'Instalación sistema de bombeo tanque subt',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(153,'50409ae2-a962-4d82-8792-800038f40abd',7,43,NULL,NULL,'Tuberia Hidraulica Vertical',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(154,'3d68355c-e38f-44db-9d65-fd01080c30c7',7,37,NULL,NULL,'Tuberia presión N1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,5.88,3,'2026-11-12 12:41:45',NULL,NULL,3,4,NULL),(155,'c111a995-0a24-4670-b70f-cfdf58a57849',7,66,NULL,NULL,'Columneta de confinamiento bloque',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',5,6,NULL),(156,'a5716bb7-837f-46ad-b320-f630dc679133',7,73,NULL,NULL,'Dilataciones en pañetes',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',5,7,NULL),(157,'4d725363-c332-40ba-a876-82f6ac3f92e1',7,74,NULL,NULL,'Filos en pañetes',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:45',5,7,NULL),(158,'357fe5e4-8f44-4030-852c-2605107f3b2a',7,75,NULL,NULL,'Media caña cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,12.50,3,'2026-11-12 12:41:45',NULL,'2026-11-12 12:41:46',5,7,NULL),(159,'dcc4f0bb-dcd3-4e3c-89ad-e42bc85ae8e5',7,59,NULL,NULL,'Muro en bloque #5 1er piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:46',NULL,'2026-11-12 12:41:46',5,6,NULL),(160,'63999364-75c6-47dd-a27d-b059d5b8dd89',7,60,NULL,NULL,'Muro en bloque #5 2do piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:46',NULL,'2026-11-12 12:41:46',5,6,NULL),(161,'17c60c02-3f73-4af9-b976-5ea2e6cd5ad0',7,58,NULL,NULL,'Muro en ladrillo de obra doble',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:46',NULL,'2026-11-12 12:41:46',5,6,NULL),(162,'36f864fc-f9a0-43c3-bec6-3dde664d640c',7,57,NULL,NULL,'Muro en ladrillo de obra sencillo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-12','completed',NULL,9.09,3,'2026-11-12 12:41:46',NULL,'2026-11-12 12:41:46',5,6,NULL),(163,'355c00d9-ce7e-4968-98d6-c0d79d3e51db',7,79,NULL,NULL,'Dilataciones en z muro',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,5,8,NULL),(164,'416409e6-3fae-4269-8d2d-349ee7a17d0d',7,62,NULL,NULL,'Dinteles en varilla',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(165,'d7c48b57-24e8-4758-848b-c698526f8463',7,72,NULL,NULL,'Goteros en borde de placas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(166,'3ee6d748-7ee1-4000-9ff3-7c4c3f3144c1',7,63,NULL,NULL,'Muro bloque cemento e=0,09',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(167,'e51e61cb-e10e-4e11-88c2-ed4dbb720f86',7,64,NULL,NULL,'Muro bloque cemento e=0,12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(168,'d698f3b7-5c27-4cc1-ba92-a4e95e731021',7,65,NULL,NULL,'Muro bloque cemento e=0,20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(169,'aad44a2e-0c7a-4343-afa6-6cd1cf634e04',7,77,NULL,NULL,'Muro doble en drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,5,8,NULL),(170,'c43efe6c-28ed-4162-b705-80701ee72169',7,78,NULL,NULL,'Muro doble en superboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,5,8,NULL),(171,'50403c22-320a-483d-8dcd-e3917dafcf21',7,61,NULL,NULL,'Muro en bloque #5 culatas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(172,'9fab89fd-d317-4475-b25e-9769712988a0',7,76,NULL,NULL,'Muro sencillo en drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,5,8,NULL),(173,'9ab58403-0d64-46e2-ac1f-a571f86826ec',7,69,NULL,NULL,'Pañete de muros fachada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(174,'2604c461-6500-4704-98a0-254f00c1ead5',7,68,NULL,NULL,'Pañete de muros internos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(175,'369353f4-57ef-42cd-b1fa-d558239aa068',7,70,NULL,NULL,'Pañete de placas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(176,'836efdc7-00e0-4934-afbe-685d0200cb35',7,71,NULL,NULL,'Pañete de placas fachada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,12.50,3,'2026-11-12 12:41:46',NULL,NULL,5,7,NULL),(177,'93387c63-b1d6-4d06-817a-e006802c4c26',7,67,NULL,NULL,'Relleno celdas bloque estructural',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,9.09,3,'2026-11-12 12:41:46',NULL,NULL,5,6,NULL),(178,'ec39f6ac-c6e7-4101-96d1-f570989f7dd8',7,91,NULL,NULL,'Anden piso en adoquin',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(179,'755a1a5e-bc70-4ce6-af47-9b76747a9f73',7,119,NULL,NULL,'Barra de cocina en material seleccionado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(180,'af8497b5-ed0a-4528-a6ba-4a58b44a9b99',7,95,NULL,NULL,'Biselada de enchape muro',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(181,'2ea79cf9-257f-4748-ab9c-374c9a8bd716',7,104,NULL,NULL,'Closets de madera',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(182,'0badba60-a37e-4133-b9e1-4796fbeee7ca',7,105,NULL,NULL,'Cubierta metálica en cerchas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(183,'18803c8a-426b-4c5d-9727-30b4ab0ea1a7',7,82,NULL,NULL,'Cubiertas en cielo raso drywall',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(184,'b8635fb4-d4c3-4849-a9ed-e2f6d1557ab8',7,99,NULL,NULL,'División de baños en vidrio templado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,11,NULL),(185,'2bb4c0da-53e0-4865-8d8b-4aff6fe7e466',7,84,NULL,NULL,'Domos en placa cubierta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(186,'21629c8c-11be-4d3f-ad4a-130eec3744fc',7,88,NULL,NULL,'Enchape de escalera biselada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(187,'6a78a901-9d2e-415a-b6b8-fd296b5e25b9',7,93,NULL,NULL,'Enchape de muro en cerámica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(188,'2af46739-5bb2-459a-aab3-042272c4ddb4',7,94,NULL,NULL,'Enchape de muro en porcelanato',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(189,'d8618ccb-ddb2-484c-ba09-568c261e9383',7,86,NULL,NULL,'Enchape de piso en cerámica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(190,'dd50a6b4-9ca1-41b8-9ca7-322d99e2d4c0',7,87,NULL,NULL,'Enchape de piso en porcelanato',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(191,'5986feeb-85d4-46e7-a1fe-fa8c63cf698f',7,109,NULL,NULL,'Estructura metálica de cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,13,NULL),(192,'c614f262-db17-48ab-9a4e-f25997268f0f',7,108,NULL,NULL,'Estructura Métalica soporte superboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,13,NULL),(193,'4083760f-fb69-4251-a6ad-a58f194af328',7,89,NULL,NULL,'Guardaescobas en cerámica',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(194,'42768c68-9598-4259-a97c-1350ca858fd5',7,90,NULL,NULL,'Guardaescobas en porcelanato',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(195,'07e796a4-2cd2-4df3-aab2-32797f419a37',7,81,NULL,NULL,'Impermeabilización de cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(196,'6fe1e53c-e00e-4fb3-842d-f6c334b56ac7',7,83,NULL,NULL,'Inst. cubierta tipo sandwich',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(197,'b9640050-484b-4f26-993b-5f50a255b76f',7,112,NULL,NULL,'Instalación accesorios baño',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(198,'3994adf1-36a2-4ee3-83bf-6565fe0e02a5',7,110,NULL,NULL,'Instalación aparatos de baños',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(199,'050e8174-08d8-47aa-ab83-501087a446cc',7,117,NULL,NULL,'Instalación campana cocina',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(200,'df04688f-4065-4c7b-ab89-2e4100924312',7,96,NULL,NULL,'Instalación de rejillas de piso',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(201,'fde7bc9d-638b-48e9-88b3-3ed60af99b58',7,111,NULL,NULL,'Instalación duchas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(202,'f9c80a9d-4c36-47b8-9ce1-e91ccadeed0c',7,116,NULL,NULL,'Instalación estufa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(203,'2c111319-43bc-4694-a968-2d3604e6da74',7,115,NULL,NULL,'Instalación horno cocina',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(204,'5b2d516a-12ac-4d63-9583-87cb97fbfff8',7,113,NULL,NULL,'Instalación Lavadero',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(205,'f3d2f950-b658-4048-bd82-1c29cdd8e125',7,114,NULL,NULL,'Instalación Lavaplatos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,14,NULL),(206,'c84989c4-189b-4036-a7b2-14b383311031',7,118,NULL,NULL,'Meson de cocina en material seleccionado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,17,NULL),(207,'da60e55c-cb01-404a-8a5d-3f823b2619b3',7,80,NULL,NULL,'Mortero nivelación de cubiertas',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,9,NULL),(208,'7d7be6d4-86a9-43ec-bc01-1fe6d74a5b61',7,85,NULL,NULL,'Mortero nivelación de pisos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,NULL),(209,'741c91d4-14dc-44cd-8430-6f2769a42ca0',7,102,NULL,NULL,'Mueble de baño madera lavamanos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(210,'3a800ca8-02b3-4105-b6bf-028548881893',7,103,NULL,NULL,'Mueble de cocina madera bajo & alto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(211,'03b388cf-cb23-4a31-92d4-729a613cc46c',7,100,NULL,NULL,'Pasamanos en vidrio templado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,11,NULL),(212,'83ef02ac-9817-424f-9e4d-ba5710810dbc',7,92,NULL,NULL,'Piso zona verde',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,8.33,3,'2026-11-12 12:41:46',NULL,NULL,6,10,2),(213,'3c16b128-41c9-40d2-a922-4b8eef918747',7,107,NULL,NULL,'Portones corredizos metálicos',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,13,NULL),(214,'ec32f536-45cd-4cda-a7ae-0d91a5b0adcd',7,98,NULL,NULL,'Puerta correderas en aluminio y vidrio',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,11,NULL),(215,'ca66ab5a-68a1-412b-b8e9-b3304a165b00',7,101,NULL,NULL,'Puertas de madera general',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,20.00,3,'2026-11-12 12:41:46',NULL,NULL,6,12,NULL),(216,'347a7976-18da-4671-967d-06e83d31aa9f',7,122,NULL,NULL,'Revestimiento de muros fachada (pasta-pintura ext)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,50.00,3,'2026-11-12 12:41:46',NULL,NULL,6,15,NULL),(217,'9afd51eb-cab6-4156-b6db-c014d3d40f40',7,121,NULL,NULL,'Revestimiento de muros internos (pasta-pintura)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,50.00,3,'2026-11-12 12:41:46',NULL,NULL,6,15,NULL),(218,'e54a9fba-1efd-43ce-9c76-7d0351c9dec5',7,124,NULL,NULL,'Revestimiento en aluminio compuesto',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,50.00,3,'2026-11-12 12:41:46',NULL,NULL,6,16,NULL),(219,'65666bde-82a8-4175-a14e-974258cdc022',7,123,NULL,NULL,'Revestimiento en superboard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,50.00,3,'2026-11-12 12:41:46',NULL,NULL,6,16,NULL),(220,'47af24d0-ff76-445b-844d-3b5e2fbe3278',7,106,NULL,NULL,'Ventanas en aluminio',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,13,NULL),(221,'32b66637-306d-4fa4-92df-432fb7a1656f',7,97,NULL,NULL,'Ventaneria en aluminio y vidrio',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,25.00,3,'2026-11-12 12:41:46',NULL,NULL,6,11,NULL),(222,'31353273-7891-4abc-bbff-4dac7180684c',5,129,NULL,NULL,'Figuracion Vigas de Amarre',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'scheduled',NULL,3.57,2,'2026-11-14 09:28:54',NULL,NULL,2,3,1),(223,'b86ef5f5-88d7-430f-9519-ddbb990e716d',5,130,NULL,NULL,'Excavacion Manual Viga de Amarre',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'scheduled',NULL,3.45,3,'2026-11-14 11:49:24',NULL,'2026-11-14 11:49:42',2,3,1),(224,'86453a29-3a74-44ba-af5e-8fb54d7d7d90',5,131,NULL,NULL,'Solado Vigas de Amarre',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'scheduled',NULL,3.33,3,'2026-11-14 11:52:44',NULL,'2026-11-14 11:53:01',2,3,1),(225,'990d42cc-38ac-4cea-baed-648dcb9321b2',5,132,NULL,NULL,'Zapatas Muro Cerramiento Posterior',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'scheduled',NULL,3.23,3,'2026-11-14 11:55:08',NULL,'2026-11-14 11:55:27',2,3,2);
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
INSERT INTO `user_notifications` VALUES (7,1,'Nota de Luis Carlos Navarro Gallon','L2 TRAMONTI · Provisionales Electricas y Agua\nFalta Provisional de Luz, El agua ya se conectó','/dashboard/obras/5/tareas?tarea=19','2026-11-17 12:33:21','2026-11-14 11:41:31'),(8,2,'Nota de Luis Carlos Navarro Gallon','L2 TRAMONTI · Provisionales Electricas y Agua\nFalta Provisional de Luz, El agua ya se conectó','/dashboard/obras/5/tareas?tarea=19','2026-11-17 07:48:55','2026-11-14 11:41:31'),(9,4,'Nota de Luis Carlos Navarro Gallon','L2 TRAMONTI · Provisionales Electricas y Agua\nFalta Provisional de Luz, El agua ya se conectó','/dashboard/obras/5/tareas?tarea=19',NULL,'2026-11-14 11:41:31');
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
INSERT INTO `work_plan_signature_events` VALUES (27,5,2,'created','2026-11-07 10:47:47','Plan creado con 3 tarea(s)'),(28,5,2,'edited','2026-11-07 10:51:31','Se añadió «Excavación mecánica». Justificación: Se ejecuto de acuerdo a la planeacion'),(29,5,2,'edited','2026-11-07 10:51:46','Se añadió «Perfilada de zapatas». Justificación: Se ejecuto de acuerdo a la planeacion'),(30,5,2,'edited','2026-11-07 10:52:02','Se añadió «Solados». Justificación: Se ejecuto de acuerdo a la planeacion'),(31,5,2,'edited','2026-11-07 11:00:23','Se añadió «Figuracion de Acero Zapatas». Justificación: Se ejecuto de acuerdo a la planeacion'),(32,5,2,'edited','2026-11-07 11:28:22','Se añadió «Provisionales Electricas y Agua». Justificación: porqbijnijoj'),(33,6,3,'created','2026-11-11 16:32:52','Plan creado con 3 tarea(s)'),(34,6,3,'edited','2026-11-11 16:35:46','Se añadió «Figuracion placa de piso Tanque». Justificación: Se va ejecutar esta semana'),(35,6,3,'edited','2026-11-12 10:46:36','Tarea agregada: Zapatas en concreto'),(36,6,3,'edited','2026-11-12 10:58:47','Tarea quitada: Zapatas en concreto'),(37,6,3,'edited','2026-11-12 10:59:07','Tarea agregada: Zapatas en concreto'),(38,6,3,'edited','2026-11-12 11:04:33','Tarea agregada: Placa de concreto Tanque'),(39,7,3,'created','2026-11-14 11:45:03','Plan creado con 1 tarea(s)'),(40,7,3,'edited','2026-11-14 11:45:40','Tarea agregada: Pedestal en concreto'),(41,7,3,'edited','2026-11-14 11:45:58','Tarea agregada: Figuracion Acero Viga de Amarre'),(42,7,3,'edited','2026-11-14 11:49:42','Tarea agregada: Excavacion Manual Viga de Amarre'),(43,7,3,'edited','2026-11-14 11:53:01','Tarea agregada: Solado Vigas de Amarre'),(44,7,3,'edited','2026-11-14 11:55:27','Tarea agregada: Zapatas Muro Cerramiento Posterior');
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
INSERT INTO `work_plan_tasks` VALUES (16,5,11,'Campamento',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:47:47'),(17,5,12,'Descapote y Limpieza De Lote Manual',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:47:47'),(18,5,13,'Localización Y Replanteo',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:47:47'),(19,5,14,'Excavación mecánica',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:51:31'),(20,5,15,'Perfilada de zapatas',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:51:46'),(21,5,16,'Solados',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 10:52:02'),(22,5,17,'Figuracion de Acero Zapatas',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 11:00:23'),(23,5,19,'Provisionales Electricas y Agua',NULL,NULL,NULL,'2026-11-02','2026-11-07',NULL,NULL,'2026-11-07 11:28:22'),(24,6,17,'Figuracion de Acero Zapatas',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-11 16:32:52'),(25,6,19,'Provisionales Electricas y Agua',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-11 16:32:52'),(26,6,91,'Figuracion Acero Pedestal',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-11 16:32:52'),(27,6,92,'Figuracion placa de piso Tanque',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-11 16:35:46'),(29,6,38,'Zapatas en concreto',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-12 10:59:07'),(30,6,93,'Placa de concreto Tanque',NULL,NULL,NULL,'2026-11-09','2026-11-14',NULL,NULL,'2026-11-12 11:04:33'),(31,7,19,'Provisionales Electricas y Agua',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:45:03'),(32,7,29,'Pedestal en concreto',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:45:40'),(33,7,94,'Figuracion Acero Viga de Amarre',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:45:58'),(34,7,223,'Excavacion Manual Viga de Amarre',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:49:42'),(35,7,224,'Solado Vigas de Amarre',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:53:01'),(36,7,225,'Zapatas Muro Cerramiento Posterior',NULL,NULL,NULL,'2026-11-16','2026-11-21',NULL,NULL,'2026-11-14 11:55:27');
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
INSERT INTO `work_plan_versions` VALUES (5,3,1,2,'2026-11-07 10:47:47',NULL),(6,4,1,3,'2026-11-11 16:32:52',NULL),(7,5,1,3,'2026-11-14 11:45:03',NULL);
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
INSERT INTO `work_plans` VALUES (3,'bfb8ca60-6127-47bd-b6db-eb895916af13',5,'Bitacora de Obra N1','2026-11-02','2026-11-07','finished',5,2,'2026-11-07 10:47:47','2026-11-10 13:49:38'),(4,'4f99c44d-ace5-4d2c-bbea-b3ab03ecf1bb',5,'Plan 2026-11-09 — L2 TRAMONTI','2026-11-09','2026-11-14','finished',6,3,'2026-11-11 16:32:52','2026-11-15 00:38:29'),(5,'fce761a5-360b-4631-91eb-4f794fc43851',5,'Bitácora semana 3 noviembre','2026-11-16','2026-11-21','in_execution',7,3,'2026-11-14 11:45:03','2026-11-14 11:45:03');
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
