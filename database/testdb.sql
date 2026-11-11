-- MySQL dump 10.13  Distrib 8.4.10, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: testdb
-- ------------------------------------------------------
-- Server version	8.4.10

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
-- Table structure for table `ai_conversation`
--

DROP TABLE IF EXISTS `ai_conversation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_conversation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `conversation_id` varchar(64) NOT NULL COMMENT '会话唯一标识',
  `title` varchar(100) DEFAULT '新对话' COMMENT '会话标题',
  `user_id` varchar(64) DEFAULT NULL COMMENT '用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_conversation_id` (`conversation_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI会话表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_conversation`
--

LOCK TABLES `ai_conversation` WRITE;
/*!40000 ALTER TABLE `ai_conversation` DISABLE KEYS */;
INSERT INTO `ai_conversation` VALUES (1,'b516e3ece65a4af8873f73d963343368','测试对话记录生成','1','2026-08-19 16:41:04','2026-08-19 16:41:08');
/*!40000 ALTER TABLE `ai_conversation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_message`
--

DROP TABLE IF EXISTS `ai_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `conversation_id` varchar(64) NOT NULL COMMENT '会话唯一标识',
  `role` varchar(20) NOT NULL COMMENT '角色: user/assistant/system',
  `content` text NOT NULL COMMENT '消息内容',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_conversation_id` (`conversation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI消息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_message`
--

LOCK TABLES `ai_message` WRITE;
/*!40000 ALTER TABLE `ai_message` DISABLE KEYS */;
INSERT INTO `ai_message` VALUES (1,'b516e3ece65a4af8873f73d963343368','user','测试对话记录生成','2026-08-19 16:41:04'),(2,'b516e3ece65a4af8873f73d963343368','assistant','您好，我是智策AI，很高兴为您服务！\n\n如果您想测试对话记录生成功能，请按照以下步骤操作：\n\n1. **进入对话记录模块**：在系统左侧导航栏中点击「智能助手」→「对话记录」\n2. **生成测试记录**：点击页面右上角「新建测试记录」按钮，系统会自动生成一条包含库存、销售或采购场景的示例对话\n3. **验证完整性**：生成的记录会包含对话时间、用户问题、AI回复及关联业务单据编号\n\n同时，您也可以：\n- **筛选查询**：按日期、类型（库存/销售/采购）或关键词筛选历史记录\n- **导出记录**：点击「导出Excel」用于存档或分析\n\n如果您在测试过程中发现记录内容缺失、时间异常或关联单据错误，请告诉我具体现象，我来帮您排查。需要我直接生成一条测试示例吗？','2026-08-19 16:41:08'),(3,'conv_1787132429949','user','测试新对话生成','2026-08-19 17:43:03'),(4,'conv_1787132429949','assistant','你好，我是智策AI，你的进销存ERP智能助手。新对话已就绪，随时可以为你分析库存、销售、采购数据，或解答系统使用问题。请告诉我你的需求！','2026-08-19 17:43:06');
/*!40000 ALTER TABLE `ai_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `parent_id` int unsigned DEFAULT '0' COMMENT '上级分类ID，0表示顶级',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE,
  KEY `idx_category_parent_id` (`parent_id`) USING BTREE,
  KEY `idx_category_name` (`name`) USING BTREE,
  KEY `idx_category_sort_order` (`sort_order`) USING BTREE,
  KEY `idx_category_parent_sort` (`parent_id`,`sort_order`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='商品分类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,0,'水果',0,'2026-04-13 15:38:31','2026-04-15 12:50:06'),(3,0,'饮料',1,'2026-04-10 09:00:00','2026-04-10 09:00:00'),(4,3,'碳酸饮料',0,'2026-04-10 09:30:00','2026-04-10 09:30:00'),(5,3,'果汁饮料',1,'2026-04-10 09:30:00','2026-04-10 09:30:00'),(6,1,'热带水果',1,'2026-04-11 10:00:00','2026-04-11 10:00:00'),(7,1,'苹果类',2,'2026-04-11 10:30:00','2026-04-11 10:30:00'),(8,0,'零食',2,'2026-04-12 08:00:00','2026-04-12 08:00:00'),(9,8,'坚果类',0,'2026-04-12 08:30:00','2026-04-12 08:30:00'),(10,8,'糖果类',1,'2026-04-12 08:30:00','2026-04-12 08:30:00');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '客户ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户名称',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `price_level` tinyint DEFAULT '1' COMMENT '价格等级（1-零售价 2-批发价 3-VIP价）',
  `credit_limit` decimal(12,2) DEFAULT '0.00' COMMENT '信用额度',
  `status` tinyint(1) DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_code` (`code`) USING BTREE,
  KEY `idx_customer_name` (`name`) USING BTREE,
  KEY `idx_customer_contact_person` (`contact_person`) USING BTREE,
  KEY `idx_customer_phone` (`phone`) USING BTREE,
  KEY `idx_customer_status` (`status`) USING BTREE,
  KEY `idx_customer_status_id` (`status`,`id`) USING BTREE,
  KEY `idx_customer_name_status` (`name`,`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='客户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (1,'C001','鲜丰水果店','张三','13800138001','zhangsan@fresh.com','杭州市西湖区文三路123号',1,50000.00,1,'2026-04-10 09:30:00','2026-04-10 09:30:00'),(2,'C002','百果园','李四','13800138002','lisi@baiguoyuan.com','上海市浦东新区世纪大道456号',2,100000.00,1,'2026-04-10 10:00:00','2026-04-10 10:00:00'),(3,'C003','盒马鲜生','王五','13800138003','wangwu@hema.com','北京市朝阳区建国路789号',3,200000.00,1,'2026-04-11 09:00:00','2026-04-11 09:00:00'),(4,'C004','永辉超市','赵六','13800138004','zhaoliu@yonghui.com','深圳市南山区科技园南路999号',2,150000.00,1,'2026-04-11 14:00:00','2026-04-11 14:00:00'),(5,'C005','大润发','钱七','13800138005','qianqi@drtmart.com','广州市天河区天河路1111号',1,80000.00,0,'2026-04-12 11:00:00','2026-04-12 11:00:00');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dept`
--

DROP TABLE IF EXISTS `dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dept` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门名称',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门编码',
  `parent_id` bigint unsigned NOT NULL DEFAULT '0' COMMENT '父部门ID，0表示根部门',
  `parent_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '父部门名称',
  `intro` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部门简介',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部门电话',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部门地址',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `status` int NOT NULL DEFAULT '1' COMMENT '状态（1启用 0禁用）',
  `user_id` bigint DEFAULT NULL COMMENT '负责人ID',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '负责人名称',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dept_code` (`code`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='部门表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dept`
--

LOCK TABLES `dept` WRITE;
/*!40000 ALTER TABLE `dept` DISABLE KEYS */;
INSERT INTO `dept` VALUES (2,'总经理办公室','GM',0,'公司','公司经营管理','','','2026-06-29 18:07:15',1,1,'管理员'),(3,'综合管理中心','ADMIN',0,'公司','行政、人事、IT管理','','','2026-06-29 18:07:15',1,1,'管理员'),(4,'财务中心','FINANCE',0,'公司','财务管理',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(5,'采购中心','PURCHASE',0,'公司','农产品采购',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(6,'品质中心','QUALITY',0,'公司','品质与食品安全',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(7,'仓储中心','WAREHOUSE',0,'公司','仓储管理',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(8,'销售中心','SALES',0,'公司','销售业务',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(9,'配送中心','DELIVERY',0,'公司','物流配送',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(10,'行政部','ADMIN_OFFICE',3,'综合管理中心','行政事务',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(11,'人力资源部','ADMIN_HR',3,'综合管理中心','人员管理',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(12,'信息技术部','ADMIN_IT',3,'综合管理中心','系统维护',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(13,'法务部','ADMIN_LEGAL',3,'综合管理中心','合同法务',NULL,NULL,'2026-06-29 18:07:15',1,NULL,NULL),(14,'应收管理','FINANCE_AR',4,'财务中心','客户收款',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(15,'应付管理','FINANCE_AP',4,'财务中心','供应商付款',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(16,'成本核算','FINANCE_COST',4,'财务中心','成本统计',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(17,'审计','FINANCE_AUDIT',4,'财务中心','内部审计',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(18,'基地采购','PURCHASE_BASE',5,'采购中心','基地及合作社采购',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(19,'市场采购','PURCHASE_MARKET',5,'采购中心','批发市场采购',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(20,'供应商管理','PURCHASE_SUPPLIER',5,'采购中心','供应商维护',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(21,'采购质检','PURCHASE_QC',5,'采购中心','采购验收',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(22,'来货质检','QUALITY_CHECK',6,'品质中心','来货检验',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(23,'分级分选','QUALITY_GRADE',6,'品质中心','农产品等级划分',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(24,'食品安全检测','QUALITY_SAFE',6,'品质中心','食品安全检测',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(25,'溯源管理','QUALITY_TRACE',6,'品质中心','农产品溯源',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(26,'常温仓','WH_NORMAL',7,'仓储中心','常温库存',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(27,'冷藏仓','WH_COLD',7,'仓储中心','冷藏库存',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(28,'冷冻仓','WH_FREEZE',7,'仓储中心','冷冻库存',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(29,'包装区','WH_PACK',7,'仓储中心','包装加工',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(30,'分拣区','WH_SORT',7,'仓储中心','订单分拣',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(31,'退货仓','WH_RETURN',7,'仓储中心','退货商品',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(32,'库存管理','WH_STOCK',7,'仓储中心','库存盘点',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(33,'批发销售','SALES_WHOLESALE',8,'销售中心','批发客户',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(34,'商超销售','SALES_MARKET',8,'销售中心','商超客户',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(35,'餐饮销售','SALES_CATERING',8,'销售中心','餐饮客户',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(36,'电商销售','SALES_ONLINE',8,'销售中心','电商平台',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(37,'社区团购','SALES_GROUP',8,'销售中心','社区团购',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(38,'客服','SALES_SERVICE',8,'销售中心','售前客服',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(39,'售后','SALES_AFTER',8,'销售中心','售后服务',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(40,'配送调度','DELIVERY_DISPATCH',9,'配送中心','配送计划',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(41,'司机管理','DELIVERY_DRIVER',9,'配送中心','司机管理',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(42,'配送员','DELIVERY_STAFF',9,'配送中心','配送人员',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(43,'第三方物流','DELIVERY_3PL',9,'配送中心','物流合作',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(44,'回单管理','DELIVERY_RECEIPT',9,'配送中心','签收回单',NULL,NULL,'2026-06-29 18:07:16',1,NULL,NULL),(47,'真理部','TURTH',2,NULL,'真理部，即是真理',NULL,NULL,'2026-07-01 10:29:31',1,NULL,NULL);
/*!40000 ALTER TABLE `dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goods`
--

DROP TABLE IF EXISTS `goods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `goods` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SKU编码，全局唯一',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '图片URL',
  `category_id` int unsigned DEFAULT NULL COMMENT '分类ID',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '品牌',
  `spec` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '规格型号',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '个' COMMENT '基本单位',
  `barcode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '主条码',
  `purchase_price` decimal(12,2) DEFAULT '0.00' COMMENT '参考采购价',
  `sale_price` decimal(12,2) DEFAULT '0.00' COMMENT '标准售价',
  `cost_price` decimal(12,2) DEFAULT '0.00' COMMENT '当前移动加权平均成本',
  `stock_low` decimal(12,2) DEFAULT '0.00' COMMENT '库存预警下限',
  `stock_high` decimal(12,2) DEFAULT '0.00' COMMENT '库存预警上限',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `del_flag` int DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_sku_code` (`sku_code`) USING BTREE,
  KEY `idx_category_id` (`category_id`) USING BTREE,
  KEY `idx_barcode` (`barcode`) USING BTREE,
  KEY `idx_goods_name` (`name`) USING BTREE,
  KEY `idx_goods_brand` (`brand`) USING BTREE,
  KEY `idx_goods_category_id` (`category_id`) USING BTREE,
  KEY `idx_goods_barcode` (`barcode`) USING BTREE,
  KEY `idx_goods_category_status_time` (`category_id`,`del_flag`,`create_time`) USING BTREE,
  KEY `idx_goods_spec` (`spec`) USING BTREE,
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='商品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goods`
--

LOCK TABLES `goods` WRITE;
/*!40000 ALTER TABLE `goods` DISABLE KEYS */;
INSERT INTO `goods` VALUES (1,'FR001','芒果',NULL,6,'海南农场','50个/箱','箱','690123456789',30.00,50.00,35.00,10.00,200.00,'2026-04-13 15:55:11','2026-06-11 17:17:28',0),(2,'FR002','榴莲',NULL,6,'泰国进口','500g~/个','个','690123456790',80.00,150.00,85.00,5.00,50.00,'2026-04-13 17:47:14','2026-04-15 17:38:36',0),(3,'FR003','阿克苏苹果',NULL,7,'新疆基地','50个/箱','箱','690123456791',25.00,45.00,28.00,20.00,300.00,'2026-04-10 09:30:00','2026-04-15 17:37:36',0),(4,'FR004','智利车厘子',NULL,6,'智利进口','50个/箱','箱','690123456792',120.00,200.00,130.00,10.00,100.00,'2026-04-11 10:00:00','2026-04-15 17:37:38',0),(5,'FR005','红心火龙果',NULL,6,'越南进口','50个/箱','箱','690123456793',35.00,60.00,38.00,15.00,150.00,'2026-04-11 11:00:00','2026-04-15 17:37:40',0),(6,'FR006','脐橙',NULL,7,'赣南农场','50个/箱','箱','690123456794',18.00,35.00,20.00,30.00,400.00,'2026-04-12 08:00:00','2026-04-15 17:37:44',0),(7,'DR001','可乐',NULL,4,'可口可乐','500ml/瓶','瓶','690123456795',3.00,5.00,3.50,50.00,500.00,'2026-04-10 09:00:00','2026-04-15 22:41:16',0),(8,'DR002','雪碧',NULL,4,'可口可乐','500ml/瓶','瓶','690123456796',3.00,5.00,3.50,50.00,500.00,'2026-04-10 09:00:00','2026-04-15 17:37:54',0),(9,'DR003','橙汁',NULL,5,'汇源','250ml/盒','盒','690123456797',8.00,15.00,9.00,30.00,200.00,'2026-04-10 10:00:00','2026-04-15 17:38:29',0),(10,'DR004','农夫山泉',NULL,3,'农夫山泉','500ml/瓶','瓶','690123456798',1.00,2.00,1.20,100.00,1000.00,'2026-04-10 10:00:00','2026-04-15 17:37:56',0),(11,'SN001','开心果',NULL,9,'加州农场','500g/袋','袋','690123456799',45.00,80.00,50.00,20.00,150.00,'2026-04-12 08:30:00','2026-04-15 17:38:08',0),(12,'SN002','腰果',NULL,9,'越南进口','500g/袋','袋','690123456800',40.00,75.00,45.00,20.00,150.00,'2026-04-12 08:30:00','2026-04-15 17:38:13',0),(13,'SN003','大白兔奶糖',NULL,10,'冠生园','500g/袋','袋','690123456801',15.00,25.00,18.00,50.00,400.00,'2026-04-12 09:00:00','2026-04-15 17:38:16',0),(15,'DR007','007',NULL,5,'','500ml/瓶','瓶','690123456802',0.00,0.00,0.00,0.00,0.00,'2026-04-15 16:59:11','2026-04-15 17:36:26',0);
/*!40000 ALTER TABLE `goods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `goods_id` int unsigned NOT NULL COMMENT '商品ID',
  `warehouse_id` int unsigned NOT NULL COMMENT '仓库ID',
  `location` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '默认库位',
  `batch_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '批次号（非批次商品为空字符串）',
  `qty_on_hand` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '在手量（实际物理库存）',
  `qty_available` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '可用量（在手量 - 锁定量）',
  `locked_qty` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '销售订单锁定数量',
  `total_cost` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '库存总成本',
  `last_inbound_time` datetime DEFAULT NULL COMMENT '最后入库时间',
  `last_outbound_time` datetime DEFAULT NULL COMMENT '最后出库时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` int DEFAULT NULL COMMENT '创建人 ID',
  `update_by` int DEFAULT NULL COMMENT '更新人 ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_inventory_goods_warehouse` (`goods_id`,`warehouse_id`) USING BTREE,
  UNIQUE KEY `uk_inventory` (`goods_id`,`warehouse_id`,`batch_no`) USING BTREE,
  KEY `idx_inventory_goods_id` (`goods_id`) USING BTREE,
  KEY `idx_inventory_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_inventory_qty_on_hand` (`qty_on_hand`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='库存快照表（实时库存）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (1,1,1,'A-1','1',100.00,100.00,0.00,3000.00,'2026-04-14 11:17:57',NULL,'2026-04-14 11:17:12','2026-04-14 11:53:53',NULL,NULL),(2,2,1,'A-2','1',20.00,20.00,0.00,1700.00,'2026-04-13 14:00:00',NULL,'2026-04-14 09:00:00','2026-04-14 09:30:00',NULL,NULL),(3,3,1,'B-1','1',150.00,150.00,10.00,4200.00,'2026-04-12 10:00:00',NULL,'2026-04-13 16:00:00','2026-04-14 10:00:00',NULL,NULL),(4,4,1,'A-3','1',30.00,30.00,0.00,3900.00,'2026-04-11 11:00:00',NULL,'2026-04-14 08:00:00','2026-04-14 11:00:00',NULL,NULL),(5,5,1,'A-4','1',80.00,80.00,0.00,3040.00,'2026-04-11 12:00:00',NULL,'2026-04-14 10:00:00','2026-04-14 12:00:00',NULL,NULL),(6,6,1,'B-2','2',200.00,200.00,0.00,4000.00,'2026-04-12 09:00:00',NULL,'2026-04-13 15:00:00','2026-04-14 08:00:00',NULL,NULL),(7,7,2,'C-1','1',300.00,280.00,20.00,1050.00,'2026-04-10 10:00:00',NULL,'2026-04-14 11:00:00','2026-04-14 14:00:00',NULL,NULL),(8,8,2,'C-2','1',250.00,250.00,0.00,875.00,'2026-04-10 10:00:00',NULL,'2026-04-14 11:00:00','2026-04-14 14:00:00',NULL,NULL),(9,9,2,'D-1','1',120.00,120.00,0.00,1080.00,'2026-04-10 11:00:00',NULL,'2026-04-13 14:00:00','2026-04-14 09:00:00',NULL,NULL),(10,10,2,'D-2','1',600.00,600.00,0.00,720.00,'2026-04-10 11:00:00',NULL,'2026-04-14 08:00:00','2026-04-14 10:00:00',NULL,NULL);
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_alert`
--

DROP TABLE IF EXISTS `inventory_alert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_alert` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '预警ID',
  `goods_id` bigint unsigned NOT NULL COMMENT '商品ID',
  `goods_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
  `sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SKU编码',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '品牌',
  `spec` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '规格型号',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '个' COMMENT '单位',
  `stock_quantity` decimal(12,2) DEFAULT '0.00' COMMENT '当前库存数量',
  `stock_low` decimal(12,2) DEFAULT '0.00' COMMENT '库存预警下限',
  `stock_high` decimal(12,2) DEFAULT '0.00' COMMENT '库存预警上限',
  `alert_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '预警类型：out_of_stock-缺货，low_stock-库存不足，high_stock-库存过多，expiring_soon-即将到期',
  `alert_level` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '预警级别：high-高，medium-中，low-低',
  `acknowledged` tinyint(1) DEFAULT '0' COMMENT '是否已确认：0-未确认，1-已确认',
  `acknowledged_by` int DEFAULT NULL COMMENT '确认人ID',
  `acknowledged_time` datetime DEFAULT NULL COMMENT '确认时间',
  `days_to_expiry` int DEFAULT NULL COMMENT '到期天数',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_goods_id` (`goods_id`) USING BTREE,
  KEY `idx_sku_code` (`sku_code`) USING BTREE,
  KEY `idx_alert_type` (`alert_type`) USING BTREE,
  KEY `idx_alert_level` (`alert_level`) USING BTREE,
  KEY `idx_acknowledged` (`acknowledged`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='库存预警表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_alert`
--

LOCK TABLES `inventory_alert` WRITE;
/*!40000 ALTER TABLE `inventory_alert` DISABLE KEYS */;
INSERT INTO `inventory_alert` VALUES (1,1,'芒果','FR001','我不到啊','FR-01','箱',100.00,10.00,200.00,'low_stock','medium',0,NULL,NULL,NULL,'2026-04-14 12:00:00','2026-04-14 12:00:00'),(2,2,'TEst','FR002','ste','tewst','箱',8.00,10.00,100.00,'out_of_stock','high',0,NULL,NULL,NULL,'2026-04-14 13:00:00','2026-04-14 13:00:00');
/*!40000 ALTER TABLE `inventory_alert` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_operation`
--

DROP TABLE IF EXISTS `inventory_operation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_operation` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '作业 ID',
  `operation_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作业单号',
  `operation_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作业类型：inbound-入库，outbound-出库，transfer-调拨，adjustment-盘点',
  `from_warehouse_id` int unsigned DEFAULT NULL COMMENT '源仓库 ID（出库/调拨时有值）',
  `from_warehouse_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '源仓库名称（冗余字段，方便查询）',
  `to_warehouse_id` int unsigned DEFAULT NULL COMMENT '目标仓库 ID（入库/调拨时有值）',
  `to_warehouse_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '目标仓库名称（冗余字段，方便查询）',
  `goods_id` int unsigned NOT NULL COMMENT '商品 ID',
  `goods_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称（冗余字段，方便查询）',
  `sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SKU 编码（冗余字段，方便查询）',
  `quantity` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '作业数量',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '单位',
  `operator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '操作员',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'pending' COMMENT '状态：pending-待处理，completed-已完成，cancelled-已取消',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '来源类型：purchase-采购，sales-销售，manual-手工',
  `source_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '来源单号（关联采购单/销售单等）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `complete_time` datetime DEFAULT NULL COMMENT '完成时间',
  `create_by` int DEFAULT NULL COMMENT '创建人 ID',
  `update_by` int DEFAULT NULL COMMENT '更新人 ID',
  `del_flag` tinyint(1) NOT NULL DEFAULT '0' COMMENT '删除标志：0-未删除，1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_operation_no` (`operation_no`) USING BTREE,
  KEY `idx_operation_type` (`operation_type`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_goods_id` (`goods_id`) USING BTREE,
  KEY `idx_from_warehouse` (`from_warehouse_id`) USING BTREE,
  KEY `idx_to_warehouse` (`to_warehouse_id`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE,
  KEY `idx_inv_op_operation_no` (`operation_no`) USING BTREE,
  KEY `idx_inv_op_goods_id` (`goods_id`) USING BTREE,
  KEY `idx_inv_op_operation_type` (`operation_type`) USING BTREE,
  KEY `idx_inv_op_status` (`status`) USING BTREE,
  KEY `idx_inv_op_create_time` (`create_time`) USING BTREE,
  KEY `idx_inv_op_goods_warehouse_time` (`goods_id`,`from_warehouse_id`,`create_time`) USING BTREE,
  KEY `idx_inv_op_source_no` (`source_no`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='库存作业表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_operation`
--

LOCK TABLES `inventory_operation` WRITE;
/*!40000 ALTER TABLE `inventory_operation` DISABLE KEYS */;
INSERT INTO `inventory_operation` VALUES (1,'WH1776155534114','inbound',NULL,NULL,1,'一号仓库',1,'苹果','APL001',5.00,'个','Test','completed','','manual',NULL,'2026-04-14 16:32:30','2026-04-14 17:14:26','2026-04-14 17:14:24',NULL,NULL,0),(2,'WH1776156962129','transfer',1,'一号仓库',2,'二号仓库',1,'苹果','APL001',2.00,'个','Test','cancelled','','manual',NULL,'2026-04-14 16:56:16','2026-04-14 17:14:31','2026-04-14 17:14:27',NULL,NULL,0),(3,'WH1776157025744','outbound',1,'一号仓库',NULL,NULL,1,'苹果','APL001',1.00,'个','Test','completed','','manual',NULL,'2026-04-14 16:57:16','2026-04-14 16:57:21',NULL,NULL,NULL,0),(4,'WH1776157051705','adjustment',1,'一号仓库',1,'一号仓库',1,'苹果','APL001',5.00,'个','TEST','completed','','manual',NULL,'2026-04-14 16:57:48','2026-04-14 17:14:15','2026-04-14 17:14:15',NULL,NULL,0);
/*!40000 ALTER TABLE `inventory_operation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting`
--

DROP TABLE IF EXISTS `meeting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '会议ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '会议标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '会议内容',
  `publish_time` datetime DEFAULT NULL COMMENT '发布时间',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '结束时间',
  `status` int DEFAULT NULL COMMENT '会议状态 0:未开始 1:进行中 2:已结束',
  `make_user` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '参加人员',
  `actual_user` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '实到人员',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '会议地点',
  `dept_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '部门名称',
  `dept_id` int DEFAULT NULL COMMENT '部门ID',
  `user_id` bigint DEFAULT NULL COMMENT '会议主持人ID',
  `user_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '会议主持人名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting`
--

LOCK TABLES `meeting` WRITE;
/*!40000 ALTER TABLE `meeting` DISABLE KEYS */;
INSERT INTO `meeting` VALUES (2,'test','<p>teststststst</p>','2026-07-02 14:59:09','2026-07-02 14:58:51','2026-07-03 07:00:00',2,'管理员','管理员','est','真理部',47,1,'管理员'),(3,'test','<p>testststststst</p>','2026-07-02 15:02:29','2026-07-03 00:00:00','2026-07-04 00:00:00',2,'管理员,test,特色t,test3,teststtst,A_User_For_TEST,serser','管理员','teststs','综合管理中心',3,1,'管理员'),(4,'审判测试','<h1>审判！</h1>','2026-07-02 16:07:13','2026-07-03 00:00:00','2026-07-03 21:50:00',2,'管理员,test,test3,teststtst,A_User_For_TEST,serser,1231231,tetetetetet,tetoteto,4141414,42,123,124,125,126,127,128,admin1','test,管理员','操场','真理部',47,1,'管理员'),(5,'test','<h1>测试一下</h1>','2026-07-02 16:58:26','2026-07-02 16:58:24','2026-07-02 16:58:25',2,'test',NULL,'test',NULL,2,1,'管理员'),(6,'正经会议——今晚吃啥','<h1>今晚吃啥</h1>','2026-07-02 17:01:05','2026-07-02 17:00:32','2026-07-02 17:00:33',2,'管理员,test,特色t',NULL,'饭堂','综合管理中心',3,1,'管理员'),(7,'cttt','<p>tttttt</p>','2026-07-02 17:30:27','2026-07-02 17:30:22','2026-07-02 17:30:23',2,'管理员,test,特色t',NULL,'ttttt','总经理办公室',2,1,'管理员'),(8,'测试会议定时','<h1>测试定时</h1>','2026-07-03 15:20:53','2026-07-03 15:25:53','2026-07-03 16:21:00',2,'管理员,test','A_User_For_TEST','机房','信息技术部',12,1,'管理员');
/*!40000 ALTER TABLE `meeting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu` (
  `id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `pid` int DEFAULT NULL,
  `page_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `sort_num` int DEFAULT NULL,
  `status` int DEFAULT NULL COMMENT '菜单状态',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='系统菜单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES `menu` WRITE;
/*!40000 ALTER TABLE `menu` DISABLE KEYS */;
INSERT INTO `menu` VALUES (1,'工作台','/','house','工作台',NULL,'/views/dashboard/index',1,1),(2,'系统公告','notice','notification','公告相关操作',NULL,'/views/notice/index',2,1),(3,'公告详情','/notice/index','notification','公告详情',2,'/views/notice/index',201,1),(4,'公告发布','/notice/post','notification','公告发布',2,'/views/notice/post',202,1),(5,'公告管理','/notice/manager','notification','公告管理',2,'/views/notice/manager',203,1),(6,'基础资料','base','goods','基础资料管理',NULL,'/views/base/index',3,1),(7,'商品管理','/base/goodsInfo','goods','商品管理',6,'/views/base/goodsInfo',301,1),(8,'供应商管理','/base/supplier','goods','供应商管理',6,'/views/base/supplier',302,1),(9,'客户管理','/base/customer','goods','客户管理',6,'/views/base/customer',303,1),(10,'仓库管理','/base/warehouse','goods','仓库管理',6,'/views/base/warehouse',304,1),(11,'销售管理','sale','shopping-bag','销售相关操作',NULL,'/views/sale/index',4,1),(12,'销售订单','/sale/order','shopping-bag','销售订单',11,'/views/sale/order',401,1),(13,'销售发货','/sale/delivery','shopping-bag','销售发货',11,'/views/sale/delivery',402,1),(14,'采购管理','purchase','shopping-cart','采购相关操作',NULL,'/views/purchase/index',5,1),(15,'采购订单','/purchase/order','shopping-cart','采购订单',14,'/views/purchase/order',501,1),(16,'采购入库','/purchase/inbound','shopping-cart','采购入库',14,'/views/purchase/inbound',502,1),(17,'采购单据查询','/purchase/query','shopping-cart','采购单据查询',14,'/views/purchase/query',503,1),(18,'库存管理','inventory','box','库存相关操作',NULL,'/views/inventory/index',6,1),(19,'库存查询','/inventory/query','box','库存查询',18,'/views/inventory/query',601,1),(20,'仓库作业','/inventory/operation','box','仓库作业',18,'/views/inventory/operation',602,1),(21,'库存预警','/inventory/warning','box','库存预警',18,'/views/inventory/warning',603,1),(22,'报表分析','report','pie-chart','报表分析',NULL,'/views/report/index',7,1),(23,'核心报表','/report/core','pie-chart','核心报表',22,'/views/report/core',701,1),(24,'销售分析','/report/sales','pie-chart','销售分析',22,'/views/report/sales',702,1),(25,'库存分析','/report/inventory','pie-chart','库存分析',22,'/views/report/inventory',703,1),(26,'系统管理','/system','setting','系统基础配置',NULL,'/views/system/index',8,1),(27,'用户管理','/system/user','setting','用户管理',26,'/views/system/user',801,1),(28,'角色管理','/system/role','setting','角色管理',26,'/views/system/role',802,1),(29,'菜单管理','/system/menu','setting','菜单管理',26,'/views/system/menu',803,1),(30,'操作日志','/monitor/operationLog','setting','操作日志',26,'/views/monitor/operationLog',804,1),(31,'消息中心','/message','message','消息中心',NULL,'/views/message/index',9,1),(32,'个人主页','/userInfo','avatar','个人主页',NULL,'/views/userInfo/index',10,1);
/*!40000 ALTER TABLE `menu` ENABLE KEYS */;
UNLOCK TABLES;

INSERT INTO `menu` (`id`,`name`,`path`,`icon`,`description`,`pid`,`page_path`,`sort_num`,`status`) VALUES
(33,'会议管理','meeting','chat-square','会议相关操作',NULL,'/views/meeting/index',11,1),
(34,'发起会议','/meeting/create','chat-square','发起会议',33,'/views/meeting/create',1101,1),
(35,'会议列表','/meeting/index','chat-square','会议列表',33,'/views/meeting/index',1102,1),
(36,'部门列表','/dept/list','office-building','部门列表',26,'/views/dept/list',805,1),
(37,'职位管理','/system/post','office-building','职位管理',26,'/views/system/post',806,1),
(38,'AI助手','/ai/partner','chat-line-square','AI助手',NULL,'/views/ai/partner',12,1);

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message` (
  `msg_id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int DEFAULT NULL,
  `receiver_id` int DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'æ¶ˆæ¯æ ‡é¢˜',
  `summary` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'æ¶ˆæ¯æ‘˜è¦',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '消息正文',
  `priority` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'medium' COMMENT 'ä¼˜å…ˆçº§ï¼šhigh/medium/low',
  `need_action` tinyint NOT NULL DEFAULT '0' COMMENT 'æ˜¯å¦éœ€è¦å¤„ç†ï¼š0-å¦ 1-æ˜¯',
  `is_processed` tinyint NOT NULL DEFAULT '0' COMMENT 'æ˜¯å¦å·²å¤„ç†ï¼š0-å¦ 1-æ˜¯',
  `deadline` datetime DEFAULT NULL COMMENT 'å¤„ç†æˆªæ­¢æ—¶é—´',
  `related_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'å…³è”ä¸šåŠ¡å•å·',
  `attachments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `publish_date` datetime DEFAULT NULL,
  `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '是否已读：0-未读 1-已读',
  `del_flag` tinyint NOT NULL DEFAULT '0' COMMENT '逻辑删除：0-正常 1-已删除',
  PRIMARY KEY (`msg_id`) USING BTREE,
  KEY `idx_message_receiver` (`receiver_id`,`del_flag`,`publish_date`),
  KEY `idx_message_receiver_read` (`receiver_id`,`is_read`,`del_flag`)
) ENGINE=InnoDB AUTO_INCREMENT=260 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='消息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message`
--

LOCK TABLES `message` WRITE;
/*!40000 ALTER TABLE `message` DISABLE KEYS */;
INSERT INTO `message` VALUES (175,NULL,1,'system','系统维护通知','ERP 系统将于本周六 22:00-24:00 进行版本升级，届时暂停服务','ERP 系统将于本周六 22:00-24:00 进行版本升级维护，期间采购、销售、库存、财务模块将暂停服务。\n\n请各位同事提前保存工作内容，避免在维护窗口内提交审批单据。如遇紧急业务，请联系系统运维部值班电话 8001。\n\n感谢配合！','high',0,0,'2026-09-22 08:13:19',NULL,NULL,'2026-09-20 06:13:19',1,0),(176,NULL,1,'system','安全策略更新','系统安全策略已更新，请及时修改登录密码并开启二次校验','为提升账号安全性，系统已升级密码策略：密码长度不少于 8 位，且需包含大小写字母与数字。\n\n请于 7 天内完成密码修改，逾期未修改的账号将被限制登录。修改入口：个人中心 → 安全设置 → 修改密码。','medium',1,0,'2026-09-27 08:13:19',NULL,NULL,'2026-09-20 03:13:19',1,0),(177,NULL,1,'system','新模块上线通知','采购管理模块已上线，支持询价、比价与自动生成采购订单','采购管理模块 v1.0 已正式上线，主要能力包括：\n1. 采购申请在线提交与多级审批；\n2. 供应商询价、比价与中标推荐；\n3. 审批通过后自动生成采购订单并同步入库计划。\n\n使用过程中如有问题，请联系产品经理或提交工单。','low',0,0,NULL,NULL,NULL,'2026-09-19 08:13:19',1,0),(178,NULL,1,'system','数据库升级预告','数据库将于明日凌晨 02:00 进行性能优化升级','数据库将于明日凌晨 02:00-03:00 进行索引优化与统计信息重建，期间可能出现短暂查询变慢，不影响数据写入。\n\n升级完成后报表查询速度预计提升 30% 以上。','low',0,0,NULL,NULL,NULL,'2026-09-18 08:13:19',1,0),(179,NULL,1,'system','异常登录提醒','检测到您的账号在异地设备登录，请确认是否为本人操作','系统检测到您的账号于今日 09:12 在一台新设备（IP：112.65.***.23，地点：上海）登录。\n\n如非本人操作，请立即修改密码并联系系统管理员冻结账号。','high',1,0,'2026-09-21 08:13:19',NULL,NULL,'2026-09-20 07:43:19',1,0),(180,NULL,1,'system','版本更新日志 v2.4.0','本次更新优化了移动端适配、消息中心与报表导出体验','本次更新内容：\n1. 新增消息中心，支持按类型/优先级筛选与批量操作；\n2. 移动端自适应布局优化；\n3. 报表导出支持自定义列；\n4. 修复了若干已知问题。','low',0,0,NULL,NULL,NULL,'2026-09-16 08:13:19',1,0),(181,NULL,1,'system','密码即将过期','您的登录密码将在 3 天后过期，请及时更换','您的登录密码将在 3 天后过期。为避免影响正常使用，请前往个人中心及时更换密码。','medium',1,0,'2026-09-23 08:13:19',NULL,NULL,'2026-09-14 08:13:19',1,0),(182,NULL,1,'system','数据备份完成','每日增量备份已完成，备份文件大小 1.2GB','系统已于今日 01:00 完成每日增量数据备份，备份文件大小 1.2GB，校验通过。\n\n如需恢复数据，请联系运维人员。','low',0,0,NULL,NULL,NULL,'2026-09-20 00:13:19',1,0),(183,2,1,'approval','采购申请待审批','张三提交的采购申请单 PO-2024001，金额 ¥12,800，等待您审批','申请人：张三（采购部）\n申请单号：PO-2024001\n采购内容：办公笔记本电脑 8 台\n申请金额：¥12,800.00\n\n该申请已通过部门经理初审，现提交至您审批，请在截止时间前处理。','high',1,0,'2026-09-20 14:13:19','PO-2024001','[{\"name\":\"采购申请单_PO-2024001.pdf\",\"size\":\"186 KB\",\"url\":\"\"},{\"name\":\"三家比价表.xlsx\",\"size\":\"42 KB\",\"url\":\"\"}]','2026-09-20 07:33:19',1,0),(184,2,1,'approval','费用报销申请','李四提交的差旅费用报销 ¥3,200，请审核','申请人：李四（销售部）\n报销事由：华东区客户拜访差旅费\n报销金额：¥3,200.00\n\n附件包含机票、酒店发票共 6 张，请核对后审批。','high',1,0,'2026-09-21 08:13:19','EXP-2024042','[{\"name\":\"差旅发票汇总.pdf\",\"size\":\"512 KB\",\"url\":\"\"}]','2026-09-20 06:13:19',1,0),(185,3,1,'approval','合同审批提醒','销售合同 SALE-2024005 待您审批，客户为杭州云启科技','客户名称：杭州云启科技有限公司\n合同编号：SALE-2024005\n合同金额：¥286,000.00\n合同期限：12 个月\n\n合同条款已由法务初审通过，请重点确认付款方式与交付周期。','high',1,0,'2026-09-22 08:13:19','SALE-2024005','[{\"name\":\"销售合同_SALE-2024005.docx\",\"size\":\"96 KB\",\"url\":\"\"},{\"name\":\"法务审核意见.pdf\",\"size\":\"210 KB\",\"url\":\"\"}]','2026-09-20 03:13:19',1,0),(186,NULL,1,'approval','请假申请待审批','王五提交的年假申请，共 3 天（已审批通过）','申请人：王五（技术部）\n请假类型：年假\n请假时间：3 天\n请假事由：个人事务\n\n该申请已由直属主管审批通过，系统留档。','medium',1,1,NULL,'LEAVE-2024018',NULL,'2026-09-17 08:13:19',1,0),(187,2,1,'approval','销售合同审批','销售合同 SALE-2024011 待审批，金额 ¥158,000','客户名称：南京智联制造有限公司\n合同编号：SALE-2024011\n合同金额：¥158,000.00\n\n请确认折扣比例是否符合公司价格政策。','high',1,0,'2026-09-24 08:13:19','SALE-2024011',NULL,'2026-09-19 23:13:19',1,0),(188,3,1,'approval','用印申请待审批','行政部提交的合同用印申请，需加盖公司公章','申请部门：行政部\n用印文件：战略合作协议\n用印类型：公章\n用印份数：4 份\n\n请审批后至行政前台办理用印。','medium',1,0,NULL,'SEAL-2024021',NULL,'2026-09-16 08:13:19',1,0),(189,2,1,'approval','出差申请待审批','赵六提交的深圳出差申请，共 4 天（已审批通过）','申请人：赵六（市场部）\n出差地点：深圳\n出差时间：4 天\n预计费用：¥6,800\n\n已审批通过，系统留档。','low',1,1,NULL,'TRIP-2024022',NULL,'2026-09-08 08:13:19',1,0),(190,NULL,1,'todo','待处理工单提醒','您有 3 个工单待处理，其中 1 个已临近超时','您好，当前有 3 个工单分配给您：\n1. 【高】客户系统登录异常排查（剩余 2 小时）；\n2. 【中】打印机驱动安装；\n3. 【低】会议室投影仪报修。\n\n请及时响应，超时工单将自动升级至部门主管。','high',1,0,'2026-09-20 11:13:19','TK-20241108',NULL,'2026-09-20 07:13:19',1,0),(191,NULL,1,'todo','库存盘点任务','仓库 A 区库存盘点任务已分配给您，请于本周五前完成','任务名称：仓库 A 区月度库存盘点\n负责区域：A1-A12 货架\n计划完成时间：本周五 18:00\n\n请使用 PDA 扫码盘点，并在系统中提交盘点差异表。','medium',1,0,'2026-09-22 08:13:19','INV-20241101',NULL,'2026-09-20 05:13:19',1,0),(192,NULL,1,'todo','月度报表待提交','10 月份销售报表请于今日下班前提交','请于今日 18:00 前提交 10 月份销售报表，报表模板已更新，请使用最新版本填写。\n\n路径：报表中心 → 销售报表 → 月度汇总 → 导出并上传。','low',1,0,NULL,'RPT-202410',NULL,'2026-09-19 08:13:19',1,0),(193,NULL,1,'todo','供应商对账提醒','本月供应商对账单已生成，请于 5 个工作日内核对','本月共生成 12 家供应商对账单，合计金额 ¥482,300.00，其中 2 家存在差异需重点核对。\n\n请前往财务中心 → 供应商对账 完成核对与确认。','medium',1,0,'2026-09-25 08:13:19','REC-202411',NULL,'2026-09-20 01:13:19',1,0),(194,NULL,1,'todo','客户回访任务','重点客户「杭州云启科技」需在本周内完成回访','客户名称：杭州云启科技有限公司\n客户等级：A 级\n回访方式：电话 + 上门\n\n回访完成后请在 CRM 中登记回访记录，并同步潜在增购需求。','high',1,0,'2026-09-23 08:13:19','CRM-20241112',NULL,'2026-09-19 22:13:19',1,0),(195,NULL,1,'todo','固定资产盘点','年度固定资产盘点已启动，请配合完成本部门资产核对','年度固定资产盘点已启动，请各部门于 10 个工作日内完成本部门资产核对，并提交盘点表。\n\n如有资产调拨未登记，请先补录调拨单。','low',1,0,NULL,'ASSET-2024',NULL,'2026-09-15 08:13:19',1,0),(196,NULL,1,'todo','项目里程碑提醒','「ERP 二期」项目需求评审里程碑将于 3 天后到期','项目名称：ERP 二期\n里程碑：需求评审完成\n计划日期：3 天后\n负责人：您\n\n请确认需求文档已评审并归档，逾期将影响后续排期。','medium',1,0,'2026-09-23 08:13:19','PRJ-ERP2-03',NULL,'2026-09-14 08:13:19',1,0),(197,NULL,1,'todo','紧急工单升级','工单 TK-20241103 已超时 2 小时，已自动升级至您','工单编号：TK-20241103\n标题：生产环境接口 500 异常\n超时时长：2 小时\n\n该工单已自动升级至您，请立即协调处理并同步客户。','high',1,0,'2026-09-20 09:13:19','TK-20241103',NULL,'2026-09-20 07:53:19',1,0),(198,NULL,1,'finance','付款审批提醒','供应商付款申请 PAY-2024032 待审批，金额 ¥86,400','供应商名称：苏州精密五金有限公司\n付款单号：PAY-2024032\n付款金额：¥86,400.00\n付款方式：银行转账\n\n请核对合同与发票信息后进行审批。','high',1,0,'2026-09-22 08:13:19','PAY-2024032','[{\"name\":\"付款申请单_PAY-2024032.pdf\",\"size\":\"132 KB\",\"url\":\"\"}]','2026-09-20 06:43:19',1,0),(199,NULL,1,'finance','发票到期通知','发票号 INV-20241023 将于 3 天后到期，请及时处理','发票号码：INV-20241023\n开票金额：¥23,500.00\n到期日期：3 天后\n\n请及时完成认证抵扣，逾期将无法抵扣。','medium',1,0,'2026-09-23 08:13:19','INV-20241023',NULL,'2026-09-20 04:13:19',1,0),(200,NULL,1,'finance','预算超支预警','研发部本月预算使用率已达 92%，请注意控制支出','部门：研发部\n本月预算：¥300,000.00\n已使用：¥276,000.00（92%）\n\n请合理安排剩余支出，如需追加预算请提交预算调整申请。','high',1,0,'2026-09-25 08:13:19','BUD-202411',NULL,'2026-09-20 00:13:19',1,0),(201,NULL,1,'finance','工资条已生成','10 月工资条已生成，请登录系统查看','10 月份工资条已生成，请前往「个人中心 → 薪酬福利 → 工资条」查看。\n\n如对薪酬明细有疑问，请在 5 个工作日内联系人力资源部。','low',0,0,NULL,NULL,NULL,'2026-09-18 08:13:19',1,0),(202,NULL,1,'finance','应收账款逾期提醒','客户「南京智联制造」应收账款 ¥96,000 已逾期 5 天','客户名称：南京智联制造有限公司\n应收金额：¥96,000.00\n逾期天数：5 天\n\n请尽快跟进催收，并同步销售负责人。','medium',1,0,'2026-09-24 08:13:19','AR-20241009',NULL,'2026-09-19 21:13:19',1,0),(203,NULL,1,'finance','报销到账通知','您提交的报销单 EXP-2024035 已打款到账','报销单号：EXP-2024035\n打款金额：¥1,860.00\n到账时间：今日 15:20\n\n请注意查收。','low',0,0,NULL,'EXP-2024035',NULL,'2026-09-17 08:13:19',1,0),(204,NULL,1,'finance','供应商发票待核对','本月共 8 张供应商发票待核对，合计 ¥214,700','本月共 8 张供应商发票待核对，合计金额 ¥214,700.00，其中 1 张发票信息与合同不一致。\n\n请前往财务中心完成核对。','medium',1,0,NULL,'INV-BATCH-11',NULL,'2026-09-14 08:13:19',1,0),(205,NULL,1,'hr','入职手续提醒','新员工王五今日入职，请完成相关手续办理','新员工：王五\n入职部门：技术部\n岗位：后端开发工程师\n入职日期：今日\n\n请协助完成工牌办理、办公设备领用与系统账号开通。','medium',1,0,'2026-09-21 08:13:19','HR-20241108',NULL,'2026-09-20 06:13:19',1,0),(206,NULL,1,'hr','绩效考核通知','季度绩效考核已开启，请于本周内完成自评','本季度绩效考核已开启，请于本周五 18:00 前完成个人自评，并提交直属主管评分。\n\n考核维度：业绩达成、协作能力、专业成长。','medium',1,0,'2026-09-24 08:13:19','KPI-2024Q4',NULL,'2026-09-20 03:13:19',1,0),(207,NULL,1,'hr','培训报名确认','您已成功报名「领导力提升训练营」课程','课程名称：领导力提升训练营\n培训时间：下周三 09:00-17:00\n培训地点：公司 3 楼多功能厅\n\n请提前 10 分钟签到，如无法参加请提前 2 天请假。','low',0,0,NULL,'TRN-202411',NULL,'2026-09-19 08:13:19',1,0),(208,NULL,1,'hr','生日祝福','祝您生日快乐，公司为您准备了专属惊喜礼品','祝您生日快乐！公司为您准备了一份专属生日礼品，请于本周内至行政部前台领取。\n\n愿您新的一岁万事顺遂，工作愉快！','low',0,0,NULL,NULL,NULL,'2026-09-18 08:13:19',1,0),(209,NULL,1,'hr','考勤异常提醒','您本月存在 2 次考勤异常记录，请及时申诉','异常日期：本月 3 日（迟到 12 分钟）、本月 9 日（未打卡）\n\n如因公外出导致，请于 3 个工作日内提交补卡/申诉，逾期将计入考勤考核。','medium',1,0,'2026-09-23 08:13:19','ATT-202411',NULL,'2026-09-19 23:13:19',1,0),(210,NULL,1,'hr','劳动合同到期提醒','您的劳动合同将于 30 天后到期，请配合续签手续','您的劳动合同将于 30 天后到期，人力资源部将安排续签面谈，请留意后续通知。\n\n如不续签，请提前 30 天提交书面申请。','high',1,0,'2026-10-20 08:13:19','CON-202412',NULL,'2026-09-19 12:13:19',1,0),(211,NULL,1,'hr','员工生日会通知','本月员工集体生日会将于周五 16:00 举行','本月员工集体生日会将于本周五 16:00 在 2 楼休息区举行，欢迎各位同事参加。\n\n现场准备了蛋糕与茶歇。','low',0,0,NULL,NULL,NULL,'2026-09-13 08:13:19',1,0),(212,NULL,2,'system','系统维护通知','ERP 系统将于本周六 22:00-24:00 进行版本升级，届时暂停服务','ERP 系统将于本周六 22:00-24:00 进行版本升级维护，期间采购、销售、库存、财务模块将暂停服务。\n\n请各位同事提前保存工作内容，避免在维护窗口内提交审批单据。如遇紧急业务，请联系系统运维部值班电话 8001。\n\n感谢配合！','high',0,0,'2026-09-22 08:13:19',NULL,NULL,'2026-09-20 02:13:19',0,0),(213,NULL,2,'system','安全策略更新','系统安全策略已更新，请及时修改登录密码并开启二次校验','为提升账号安全性，系统已升级密码策略：密码长度不少于 8 位，且需包含大小写字母与数字。\n\n请于 7 天内完成密码修改，逾期未修改的账号将被限制登录。修改入口：个人中心 → 安全设置 → 修改密码。','medium',1,0,'2026-09-27 08:13:19',NULL,NULL,'2026-09-20 02:13:19',0,0),(214,NULL,2,'system','新模块上线通知','采购管理模块已上线，支持询价、比价与自动生成采购订单','采购管理模块 v1.0 已正式上线，主要能力包括：\n1. 采购申请在线提交与多级审批；\n2. 供应商询价、比价与中标推荐；\n3. 审批通过后自动生成采购订单并同步入库计划。\n\n使用过程中如有问题，请联系产品经理或提交工单。','low',0,0,NULL,NULL,NULL,'2026-09-20 02:13:19',1,0),(215,NULL,2,'system','数据库升级预告','数据库将于明日凌晨 02:00 进行性能优化升级','数据库将于明日凌晨 02:00-03:00 进行索引优化与统计信息重建，期间可能出现短暂查询变慢，不影响数据写入。\n\n升级完成后报表查询速度预计提升 30% 以上。','low',0,0,NULL,NULL,NULL,'2026-09-20 02:13:19',1,0),(216,NULL,2,'system','异常登录提醒','检测到您的账号在异地设备登录，请确认是否为本人操作','系统检测到您的账号于今日 09:12 在一台新设备（IP：112.65.***.23，地点：上海）登录。\n\n如非本人操作，请立即修改密码并联系系统管理员冻结账号。','high',1,0,'2026-09-21 08:13:19',NULL,NULL,'2026-09-20 02:13:19',0,0),(217,NULL,2,'system','版本更新日志 v2.4.0','本次更新优化了移动端适配、消息中心与报表导出体验','本次更新内容：\n1. 新增消息中心，支持按类型/优先级筛选与批量操作；\n2. 移动端自适应布局优化；\n3. 报表导出支持自定义列；\n4. 修复了若干已知问题。','low',0,0,NULL,NULL,NULL,'2026-09-20 02:13:19',1,0),(218,NULL,2,'system','密码即将过期','您的登录密码将在 3 天后过期，请及时更换','您的登录密码将在 3 天后过期。为避免影响正常使用，请前往个人中心及时更换密码。','medium',1,0,'2026-09-23 08:13:19',NULL,NULL,'2026-09-20 02:13:19',0,0),(219,NULL,2,'system','数据备份完成','每日增量备份已完成，备份文件大小 1.2GB','系统已于今日 01:00 完成每日增量数据备份，备份文件大小 1.2GB，校验通过。\n\n如需恢复数据，请联系运维人员。','low',0,0,NULL,NULL,NULL,'2026-09-20 02:13:19',1,0),(220,2,2,'approval','采购申请待审批','张三提交的采购申请单 PO-2024001，金额 ¥12,800，等待您审批','申请人：张三（采购部）\n申请单号：PO-2024001\n采购内容：办公笔记本电脑 8 台\n申请金额：¥12,800.00\n\n该申请已通过部门经理初审，现提交至您审批，请在截止时间前处理。','high',1,0,'2026-09-20 14:13:19','PO-2024001','[{\"name\":\"采购申请单_PO-2024001.pdf\",\"size\":\"186 KB\",\"url\":\"\"},{\"name\":\"三家比价表.xlsx\",\"size\":\"42 KB\",\"url\":\"\"}]','2026-09-20 02:13:19',0,0),(221,2,2,'approval','费用报销申请','李四提交的差旅费用报销 ¥3,200，请审核','申请人：李四（销售部）\n报销事由：华东区客户拜访差旅费\n报销金额：¥3,200.00\n\n附件包含机票、酒店发票共 6 张，请核对后审批。','high',1,0,'2026-09-21 08:13:19','EXP-2024042','[{\"name\":\"差旅发票汇总.pdf\",\"size\":\"512 KB\",\"url\":\"\"}]','2026-09-20 02:13:19',0,0),(222,3,2,'approval','合同审批提醒','销售合同 SALE-2024005 待您审批，客户为杭州云启科技','客户名称：杭州云启科技有限公司\n合同编号：SALE-2024005\n合同金额：¥286,000.00\n合同期限：12 个月\n\n合同条款已由法务初审通过，请重点确认付款方式与交付周期。','high',1,0,'2026-09-22 08:13:19','SALE-2024005','[{\"name\":\"销售合同_SALE-2024005.docx\",\"size\":\"96 KB\",\"url\":\"\"},{\"name\":\"法务审核意见.pdf\",\"size\":\"210 KB\",\"url\":\"\"}]','2026-09-20 02:13:19',0,0),(223,NULL,2,'approval','请假申请待审批','王五提交的年假申请，共 3 天（已审批通过）','申请人：王五（技术部）\n请假类型：年假\n请假时间：3 天\n请假事由：个人事务\n\n该申请已由直属主管审批通过，系统留档。','medium',1,1,NULL,'LEAVE-2024018',NULL,'2026-09-20 02:13:19',1,0),(224,2,2,'approval','销售合同审批','销售合同 SALE-2024011 待审批，金额 ¥158,000','客户名称：南京智联制造有限公司\n合同编号：SALE-2024011\n合同金额：¥158,000.00\n\n请确认折扣比例是否符合公司价格政策。','high',1,0,'2026-09-24 08:13:19','SALE-2024011',NULL,'2026-09-20 02:13:19',0,0),(225,3,2,'approval','用印申请待审批','行政部提交的合同用印申请，需加盖公司公章','申请部门：行政部\n用印文件：战略合作协议\n用印类型：公章\n用印份数：4 份\n\n请审批后至行政前台办理用印。','medium',1,0,NULL,'SEAL-2024021',NULL,'2026-09-20 02:13:19',1,0),(226,2,2,'approval','出差申请待审批','赵六提交的深圳出差申请，共 4 天（已审批通过）','申请人：赵六（市场部）\n出差地点：深圳\n出差时间：4 天\n预计费用：¥6,800\n\n已审批通过，系统留档。','low',1,1,NULL,'TRIP-2024022',NULL,'2026-09-20 02:13:19',1,0),(227,NULL,2,'todo','待处理工单提醒','您有 3 个工单待处理，其中 1 个已临近超时','您好，当前有 3 个工单分配给您：\n1. 【高】客户系统登录异常排查（剩余 2 小时）；\n2. 【中】打印机驱动安装；\n3. 【低】会议室投影仪报修。\n\n请及时响应，超时工单将自动升级至部门主管。','high',1,0,'2026-09-20 11:13:19','TK-20241108',NULL,'2026-09-20 02:13:19',0,0),(243,NULL,3,'system','系统维护通知','ERP 系统将于本周六 22:00-24:00 进行版本升级，届时暂停服务','ERP 系统将于本周六 22:00-24:00 进行版本升级维护，期间采购、销售、库存、财务模块将暂停服务。\n\n请各位同事提前保存工作内容，避免在维护窗口内提交审批单据。如遇紧急业务，请联系系统运维部值班电话 8001。\n\n感谢配合！','high',0,0,'2026-09-22 08:13:19',NULL,NULL,'2026-09-19 20:13:19',0,0),(244,NULL,3,'system','安全策略更新','系统安全策略已更新，请及时修改登录密码并开启二次校验','为提升账号安全性，系统已升级密码策略：密码长度不少于 8 位，且需包含大小写字母与数字。\n\n请于 7 天内完成密码修改，逾期未修改的账号将被限制登录。修改入口：个人中心 → 安全设置 → 修改密码。','medium',1,0,'2026-09-27 08:13:19',NULL,NULL,'2026-09-19 20:13:19',0,0),(245,NULL,3,'system','新模块上线通知','采购管理模块已上线，支持询价、比价与自动生成采购订单','采购管理模块 v1.0 已正式上线，主要能力包括：\n1. 采购申请在线提交与多级审批；\n2. 供应商询价、比价与中标推荐；\n3. 审批通过后自动生成采购订单并同步入库计划。\n\n使用过程中如有问题，请联系产品经理或提交工单。','low',0,0,NULL,NULL,NULL,'2026-09-19 20:13:19',1,0),(246,NULL,3,'system','数据库升级预告','数据库将于明日凌晨 02:00 进行性能优化升级','数据库将于明日凌晨 02:00-03:00 进行索引优化与统计信息重建，期间可能出现短暂查询变慢，不影响数据写入。\n\n升级完成后报表查询速度预计提升 30% 以上。','low',0,0,NULL,NULL,NULL,'2026-09-19 20:13:19',1,0),(247,NULL,3,'system','异常登录提醒','检测到您的账号在异地设备登录，请确认是否为本人操作','系统检测到您的账号于今日 09:12 在一台新设备（IP：112.65.***.23，地点：上海）登录。\n\n如非本人操作，请立即修改密码并联系系统管理员冻结账号。','high',1,0,'2026-09-21 08:13:19',NULL,NULL,'2026-09-19 20:13:19',0,0),(248,NULL,3,'system','版本更新日志 v2.4.0','本次更新优化了移动端适配、消息中心与报表导出体验','本次更新内容：\n1. 新增消息中心，支持按类型/优先级筛选与批量操作；\n2. 移动端自适应布局优化；\n3. 报表导出支持自定义列；\n4. 修复了若干已知问题。','low',0,0,NULL,NULL,NULL,'2026-09-19 20:13:19',1,0),(249,NULL,3,'system','密码即将过期','您的登录密码将在 3 天后过期，请及时更换','您的登录密码将在 3 天后过期。为避免影响正常使用，请前往个人中心及时更换密码。','medium',1,0,'2026-09-23 08:13:19',NULL,NULL,'2026-09-19 20:13:19',0,0),(250,NULL,3,'system','数据备份完成','每日增量备份已完成，备份文件大小 1.2GB','系统已于今日 01:00 完成每日增量数据备份，备份文件大小 1.2GB，校验通过。\n\n如需恢复数据，请联系运维人员。','low',0,0,NULL,NULL,NULL,'2026-09-19 20:13:19',1,0),(251,2,3,'approval','采购申请待审批','张三提交的采购申请单 PO-2024001，金额 ¥12,800，等待您审批','申请人：张三（采购部）\n申请单号：PO-2024001\n采购内容：办公笔记本电脑 8 台\n申请金额：¥12,800.00\n\n该申请已通过部门经理初审，现提交至您审批，请在截止时间前处理。','high',1,0,'2026-09-20 14:13:19','PO-2024001','[{\"name\":\"采购申请单_PO-2024001.pdf\",\"size\":\"186 KB\",\"url\":\"\"},{\"name\":\"三家比价表.xlsx\",\"size\":\"42 KB\",\"url\":\"\"}]','2026-09-19 20:13:19',0,0),(252,2,3,'approval','费用报销申请','李四提交的差旅费用报销 ¥3,200，请审核','申请人：李四（销售部）\n报销事由：华东区客户拜访差旅费\n报销金额：¥3,200.00\n\n附件包含机票、酒店发票共 6 张，请核对后审批。','high',1,0,'2026-09-21 08:13:19','EXP-2024042','[{\"name\":\"差旅发票汇总.pdf\",\"size\":\"512 KB\",\"url\":\"\"}]','2026-09-19 20:13:19',0,0),(253,3,3,'approval','合同审批提醒','销售合同 SALE-2024005 待您审批，客户为杭州云启科技','客户名称：杭州云启科技有限公司\n合同编号：SALE-2024005\n合同金额：¥286,000.00\n合同期限：12 个月\n\n合同条款已由法务初审通过，请重点确认付款方式与交付周期。','high',1,0,'2026-09-22 08:13:19','SALE-2024005','[{\"name\":\"销售合同_SALE-2024005.docx\",\"size\":\"96 KB\",\"url\":\"\"},{\"name\":\"法务审核意见.pdf\",\"size\":\"210 KB\",\"url\":\"\"}]','2026-09-19 20:13:19',0,0),(254,NULL,3,'approval','请假申请待审批','王五提交的年假申请，共 3 天（已审批通过）','申请人：王五（技术部）\n请假类型：年假\n请假时间：3 天\n请假事由：个人事务\n\n该申请已由直属主管审批通过，系统留档。','medium',1,1,NULL,'LEAVE-2024018',NULL,'2026-09-19 20:13:19',1,0),(258,NULL,NULL,'system','国庆节放假安排通知','公司国庆节放假安排：10 月 1 日至 10 月 7 日，共 7 天','根据国家法定节假日安排，公司国庆节放假时间为 10 月 1 日至 10 月 7 日，共 7 天。\n\n请各部门提前安排好值班与业务交接，放假期间注意出行安全。','medium',0,0,NULL,NULL,NULL,'2026-09-19 08:13:19',1,0),(259,NULL,NULL,'system','全员安全培训通知','公司将于下周三组织全员信息安全培训，请准时参加','公司将于下周三 14:00 组织全员信息安全培训，地点为 3 楼多功能厅，请准时参加。\n\n培训内容：账号安全、数据合规、钓鱼邮件识别。','medium',0,0,NULL,NULL,NULL,'2026-09-17 08:13:19',1,0);
/*!40000 ALTER TABLE `message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice`
--

DROP TABLE IF EXISTS `notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notice` (
  `nid` int NOT NULL AUTO_INCREMENT,
  `uid` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `publishDate` datetime DEFAULT NULL,
  `views` int DEFAULT '0',
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `attachments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`nid`) USING BTREE,
  KEY `idx_publishDate_status` (`publishDate`,`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice`
--

LOCK TABLES `notice` WRITE;
/*!40000 ALTER TABLE `notice` DISABLE KEYS */;
INSERT INTO `notice` VALUES (2,2,'TESTt','test','系统更新',NULL,'<p>I do not kown</p>','2026-04-02 17:12:31',1,'已发布',NULL),(3,1,'123123123','管理员','维护通知',NULL,'***************************\r\nAPPLICATION FAILED TO START\r\n***************************\r\nDescription:\r\nFailed to configure a DataSource: \'url\' attribute is not specified and no embedded datasource could be configured.\r\nReason: Failed to determine a suitable driver class\r\nAction:\r\n///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////','2026-03-31 16:25:57',45,'已发布',NULL),(4,1,'鹰峰同学请穿上衣服','管理员','其他公告',NULL,'普通学生白田无意中发现校园女神鹰峰同学拥有通过脱下内裤来穿越时空、改变因果的超能力。为了能够随心所欲地使用这个能力，鹰峰设计陷害白田使其成为内衣柜，从而引发了一系列搞笑且充满奇幻色彩的故事。','2026-03-31 17:09:38',1,'已发布',NULL),(5,1,'黑执事 -绿之魔女篇','管理员','其他公告',NULL,'奉女王之命前往德国调查离奇死亡事件的塞巴斯蒂安与西雅尔。在探查踏入者即遭咒杀的\"人狼之森\"真相时，骇人诅咒正向二人倾泻而下――。 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','2026-03-31 17:10:34',70,'已发布',NULL),(6,1,'DORO','管理员','其他公告',NULL,'doro,doro?Doro!DORO!','2026-04-01 10:19:44',54,'已发布',NULL),(7,1,'整点整点','管理员','功能上线',NULL,'上码头整点薯条去','2026-04-01 11:28:58',104,'已发布',NULL),(8,1,'我想玩死亡搁浅2','管理员','维护通知',NULL,'哎呀，送货送到一半我的F5节点都还没有接通','2026-04-01 11:30:17',137,'已发布',NULL),(9,1,'OTSUPEKO！','管理员','系统更新','PEKORA!','KONPEKO！','2026-04-01 11:30:00',1319,'已发布',NULL),(10,1,'今天是TETO的生日','管理员','维护通知','今天是TETO的生日','今天是愚人节，也是TETO的生日，但是还得上班','2026-04-01 11:30:00',3,'已发布',NULL),(12,1,'ImportTest','管理员','功能上线','测试','测试一下导入','2026-04-01 18:31:13',10,'已发布',NULL),(15,1,'asdfasdfsadfsadf','管理员','系统更新',NULL,'<h1><em>asdfadsfsadfsad</em></h1><p>asdfadsfasdfsadfsadfasdfasdf</p>','2026-04-02 10:46:44',6,'已发布',NULL),(16,1,'测试公告发布','管理员','功能上线','测试富文本编辑','<h1>测试一下<span style=\"color: rgb(207, 19, 34);\"><em>富文本</em></span>编辑</h1><blockquote>世界上多数的话，大体都是我说的吧 &nbsp; &nbsp;——鲁迅</blockquote><div data-w-e-type=\"todo\"><input type=\"checkbox\" disabled >整点怪东西</div><ul><li>test1</li><li style=\"text-align: center;\">test2</li></ul><ol><li>1</li><li>2</li></ol><p>👻👻👍👍👍👍👍👍👍👍👍🤘🤘👌👌✌️✌️✊✊🤛🤝👍👍👍👍</p><p><br></p>','2026-04-02 10:54:34',19,'已发布',NULL),(18,1,'asdfasdfadsf','管理员','系统更新','asdfasdfdsaf','<h1><span style=\"font-size: 40px;\"><u><em><strong>asdfasdfadsf</strong></em></u></span><u><em><strong>🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣</strong></em></u></h1><p style=\"text-align: right;\">asdfasdf</p><table style=\"width: auto;\"><tbody><tr><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">111</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">111</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">2323</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">1231231</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">a\'s\'d\'f</td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr></tbody></table><p><br></p>','2026-04-02 15:29:15',15,'已发布',NULL),(19,1,'asdfasdfadsf','管理员','其他公告','123123123','<p>🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏👍👍👍👍👍👍👍👍👍👍😤😤😤😤😤😤😤😤😤</p>','2026-04-02 15:50:27',41,'已发布',NULL),(20,2,'尝试用别的账号进行一个发布','test','系统更新','','<ul><li>WAAAAAAAAA</li><li>:-D</li><li>:-)</li></ul>','2026-04-02 16:50:07',6,'已发布',NULL),(21,2,'!!!!!!','test','系统更新','','<p>😍😍😍😍😍😍😍😍😍😘😘😘😘😘😘😘😋😋😋😋😋😋😋</p>','2026-04-02 16:54:29',6,'已发布',NULL),(22,2,'测试定时发布','test','系统更新','','<p>啊手动阀手动阀手动阀</p>','2026-04-03 09:50:00',8,'已发布',''),(23,1,'测试附件发布','管理员','功能上线','','<p>测试上传附件</p><p>👍👍👍👍👍👍👍👍👍👍😍😍😍😍😍😍😍😍😍</p>','2026-04-03 15:03:05',12,'已发布',''),(24,1,'写点啥，','管理员','维护通知','','<blockquote>12332112345677654321</blockquote><p><span style=\"color: rgb(0, 0, 0); background-color: rgb(0, 0, 0); font-size: 48px; font-family: 微软雅黑;\"><s><u><em><strong>写点东西试试，反正就是写点玩意</strong></em></u></s></span></p><p><a href=\"https://www.bilibili.com\" target=\"_blank\"><u>asdfasdf &nbsp; &nbsp; </u></a></p><hr/><p>🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣😘😘😘😘😘😘👊👊👀💀👻💩😬😡😣😖🙏🙏🤝😊😀😃😁😛😙😋😛😋😋😋😋😋</p><p><br></p>','2026-04-03 16:38:33',16,'已发布',''),(25,2,'Notice Test for normal user','test','其他公告','测试一下','<p>测试一下</p>','2026-04-07 09:56:12',1,'已发布','[]'),(27,2,'测试公告已读未读功能','test','功能上线','','<h1>测试公告已读未读功能</h1>','2026-04-07 11:01:43',4,'已发布','[]'),(28,1,'测试系统日志','管理员','功能上线','','<p>测试更改</p>','2026-04-07 11:46:30',1,'已发布','[{\"name\":\"124397002.jpg\",\"url\":\"/api/static/upload/picture/1775543068731_124397002.jpg\",\"size\":8537}]'),(29,1,'Test','管理员','系统更新','Test','<p>testststststst</p>','2026-06-11 17:36:30',12,'已发布','[{\"name\":\"A_small_cup_of_coffee.JPG\",\"url\":\"http://localhost:8080/static/upload/picture/1781170586313_A_small_cup_of_coffee.JPG\",\"size\":32886}]'),(31,1,'测试WebSocket','管理员','其他公告','test','<p>teststststststst</p>','2026-07-01 17:16:22',1,'已发布','[]'),(32,1,'再次测试公告页面','管理员','其他公告','teststststs','<p>ststststetsatetasetaset</p>','2026-07-01 17:19:40',1,'已发布','[]'),(33,1,'测试定时','管理员','维护通知','','<p>testtesttest</p>','2026-07-02 16:55:57',1,'已发布','[]'),(34,1,'测试公告','管理员','维护通知','te s t','<p>te s t s t s t s t</p>','2026-07-03 16:55:25',9,'已发布','[]'),(35,1,'测试','管理员','维护通知','a t','<p>t s t s t s s t s t</p>','2026-07-03 16:53:02',3,'已发布','[]');
/*!40000 ALTER TABLE `notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice_read_record`
--

DROP TABLE IF EXISTS `notice_read_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notice_read_record` (
  `id` int NOT NULL AUTO_INCREMENT,
  `notice_id` int NOT NULL COMMENT '公告ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `read_time` datetime DEFAULT NULL COMMENT '阅读时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_notice_user` (`notice_id`,`user_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='公告阅读记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice_read_record`
--

LOCK TABLES `notice_read_record` WRITE;
/*!40000 ALTER TABLE `notice_read_record` DISABLE KEYS */;
INSERT INTO `notice_read_record` VALUES (7,26,2,'2026-04-07 10:38:43'),(9,24,2,'2026-04-07 10:41:03'),(10,23,2,'2026-04-07 10:41:16'),(37,27,2,'2026-04-07 11:06:42'),(38,27,1,'2026-04-07 11:13:09'),(39,26,1,'2026-04-07 11:16:14'),(40,28,1,'2026-04-07 14:27:08'),(41,25,1,'2026-04-07 14:27:12'),(42,24,1,'2026-04-07 14:27:13'),(43,23,1,'2026-04-07 14:27:15'),(44,22,1,'2026-04-07 14:27:20'),(45,2,1,'2026-04-07 14:27:31'),(46,21,1,'2026-04-07 14:27:34'),(47,20,1,'2026-04-07 14:27:36'),(48,19,1,'2026-04-07 14:27:38'),(49,18,1,'2026-04-07 14:27:43'),(50,16,1,'2026-04-07 14:27:44'),(51,15,1,'2026-04-07 14:27:46'),(52,12,1,'2026-04-07 14:27:48'),(53,8,1,'2026-04-07 14:27:49'),(54,9,1,'2026-04-07 14:27:53'),(55,10,1,'2026-04-07 14:27:55'),(56,7,1,'2026-04-07 14:27:57'),(57,6,1,'2026-04-07 14:28:02'),(58,5,1,'2026-04-07 14:28:03'),(59,4,1,'2026-04-07 14:28:06'),(60,3,1,'2026-04-07 14:28:08'),(61,29,1,'2026-06-11 17:36:35'),(62,29,2,'2026-07-01 14:31:15'),(63,30,1,'2026-07-01 17:15:49'),(64,31,1,'2026-07-01 17:26:06'),(65,32,1,'2026-07-01 17:26:08'),(66,31,2,'2026-07-01 17:26:20'),(67,32,2,'2026-07-01 17:26:23'),(68,2,2,'2026-07-02 17:57:13'),(69,33,2,'2026-07-03 15:18:39'),(70,34,1,'2026-07-03 16:50:31'),(71,37,1,'2026-07-21 16:59:46'),(72,35,1,'2026-07-24 16:47:23'),(73,33,1,'2026-09-20 16:00:12');
/*!40000 ALTER TABLE `notice_read_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operation_log`
--

DROP TABLE IF EXISTS `operation_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `operation_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '操作用户',
  `operation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '操作描述',
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '方法名',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '参数',
  `time` bigint DEFAULT NULL COMMENT '执行时间(ms)',
  `ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'IP地址',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `module` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '模块名称',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '操作类型',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_username` (`username`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=248 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='系统操作日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operation_log`
--

LOCK TABLES `operation_log` WRITE;
/*!40000 ALTER TABLE `operation_log` DISABLE KEYS */;
INSERT INTO `operation_log` VALUES (1,'系统','新增公告','controller.com.lunabaka.NoticeController.postNotice()','[{\"公告标题\":\"测试系统日志\",\"公告类型\":\"功能上线\",\"公告摘要\":\"\",\"公告内容\":\"<p>测试</p>\",\"发布时间\":1775533590377,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"附件\":\"[]\"}]',33,'127.0.0.1','2026-04-07 11:46:30','公告管理','新增'),(2,'系统','修改公告','controller.com.lunabaka.NoticeController.updateNotice()','[{\"公告标题\":\"测试系统日志\",\"公告类型\":\"功能上线\",\"公告摘要\":\"\",\"公告内容\":\"<p>测试更改</p>\",\"发布时间\":1775533590000,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"附件\":\"[{\\\"name\\\":\\\"124397002.jpg\\\",\\\"url\\\":\\\"/api/static/upload/picture/1775543068731_124397002.jpg\\\",\\\"size\\\":8537}]\"}]',40,'127.0.0.1','2026-04-07 14:24:32','公告管理','修改'),(3,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin1\",\"密码\":\"123456\"}]',67,'127.0.0.1','2026-04-07 14:59:17','用户管理','登录'),(4,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',3,'127.0.0.1','2026-04-07 15:01:23','用户管理','登录'),(5,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',5,'127.0.0.1','2026-04-07 15:06:15','用户管理','登录'),(6,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',3,'127.0.0.1','2026-04-07 15:12:06','用户管理','登录'),(7,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',3,'127.0.0.1','2026-04-07 15:16:15','用户管理','登录'),(8,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',133,'127.0.0.1','2026-04-07 15:37:40','用户管理','登录'),(9,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',863,'127.0.0.1','2026-04-13 11:11:35','用户管理','登录'),(10,'系统','修改用户状态','controller.com.lunabaka.UserController.updateStatus()','[{\"昵称\":\"芒果\",\"状态\":\"禁用\"}]',13,'127.0.0.1','2026-04-13 17:14:59','用户管理','修改'),(11,'系统','修改用户状态','controller.com.lunabaka.UserController.updateStatus()','[{\"昵称\":\"芒果\",\"状态\":\"禁用\"}]',1,'127.0.0.1','2026-04-13 17:15:03','用户管理','修改'),(12,'系统','修改用户','controller.com.lunabaka.UserController.updateInfo()','[{\"昵称\":\"芒果\"}]',27,'127.0.0.1','2026-04-13 17:46:26','用户管理','修改'),(13,'系统','新增商品','controller.com.lunabaka.GoodsController.insertGoods()','[{\"SKU编码\":\"FR002\",\"商品名称\":\"TEst\",\"品牌\":\"ste\",\"规格型号\":\"tewst\",\"基础单位\":\"箱\",\"参考采购价\":\"20\",\"标准售价\":20,\"成本价格\":20,\"主条码\":\"123123123123\"}]',6,'127.0.0.1','2026-04-13 17:47:15','商品管理','新增'),(14,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',140,'127.0.0.1','2026-04-14 11:22:34','用户管理','登录'),(15,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',168,'127.0.0.1','2026-04-14 13:29:29','用户管理','登录'),(16,'系统','修改用户状态','controller.com.lunabaka.UserController.updateStatus()','[{\"昵称\":\" 一号仓库\",\"状态\":\"2\"}]',17,'127.0.0.1','2026-04-14 14:10:41','用户管理','修改'),(17,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:24:14','用户管理','修改'),(18,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',11,'127.0.0.1','2026-04-14 14:24:22','用户管理','修改'),(19,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]',8,'127.0.0.1','2026-04-14 14:24:29','用户管理','修改'),(20,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',11,'127.0.0.1','2026-04-14 14:24:30','用户管理','修改'),(21,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]',19,'127.0.0.1','2026-04-14 14:26:02','用户管理','修改'),(22,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',9,'127.0.0.1','2026-04-14 14:26:04','用户管理','修改'),(23,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]',17,'127.0.0.1','2026-04-14 14:26:13','用户管理','修改'),(24,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',8,'127.0.0.1','2026-04-14 14:26:15','用户管理','修改'),(25,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:26:15','用户管理','修改'),(26,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',11,'127.0.0.1','2026-04-14 14:26:16','用户管理','修改'),(27,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]',11,'127.0.0.1','2026-04-14 14:26:16','用户管理','修改'),(28,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',5,'127.0.0.1','2026-04-14 14:26:58','用户管理','修改'),(29,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',21,'127.0.0.1','2026-04-14 14:26:59','用户管理','修改'),(30,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:27:10','用户管理','修改'),(31,'系统','修改仓库信息','controller.com.lunabaka.WarehouseController.updateWarehouse()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:27:30','用户管理','修改'),(32,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',11,'127.0.0.1','2026-04-14 14:27:33','用户管理','修改'),(33,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:28:07','用户管理','修改'),(34,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',9,'127.0.0.1','2026-04-14 14:28:47','用户管理','修改'),(35,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',23,'127.0.0.1','2026-04-14 14:29:16','用户管理','修改'),(36,'系统','修改仓库信息','controller.com.lunabaka.WarehouseController.updateWarehouse()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',5,'127.0.0.1','2026-04-14 14:29:41','用户管理','修改'),(37,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:29:44','用户管理','修改'),(38,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',11,'127.0.0.1','2026-04-14 14:31:07','用户管理','修改'),(39,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:32:07','用户管理','修改'),(40,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',6,'127.0.0.1','2026-04-14 14:32:13','用户管理','修改'),(41,'系统','修改仓库信息','controller.com.lunabaka.WarehouseController.updateWarehouse()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',10,'127.0.0.1','2026-04-14 14:32:20','用户管理','修改'),(42,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',8,'127.0.0.1','2026-04-14 14:32:24','用户管理','修改'),(43,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',18,'127.0.0.1','2026-04-14 14:33:47','用户管理','修改'),(44,'系统','新增仓库','controller.com.lunabaka.WarehouseController.insertGoods()','[{\"code\":\"F2\",\"name\":\"Test2\",\"address\":\"2号地址\",\"phone\":\"13242134512\",\"status\":1,\"delFlag\":0}]',19,'127.0.0.1','2026-04-14 14:35:00','仓库管理','新增'),(45,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"address\":\"2号地址\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',17,'127.0.0.1','2026-04-14 14:35:00','用户管理','修改'),(46,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"address\":\"2号地址\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',6,'127.0.0.1','2026-04-14 14:35:04','用户管理','修改'),(47,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:35:04','用户管理','修改'),(48,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:35:57','用户管理','修改'),(49,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"address\":\"2号地址\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',8,'127.0.0.1','2026-04-14 14:35:57','用户管理','修改'),(50,'系统','修改仓库信息','controller.com.lunabaka.WarehouseController.updateWarehouse()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]',5,'127.0.0.1','2026-04-14 14:36:07','用户管理','修改'),(51,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',8,'127.0.0.1','2026-04-14 14:36:10','用户管理','修改'),(52,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',12,'127.0.0.1','2026-04-14 14:36:10','用户管理','修改'),(53,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:36:11','用户管理','修改'),(54,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]',8,'127.0.0.1','2026-04-14 14:36:12','用户管理','修改'),(55,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:36:16','用户管理','修改'),(56,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:36:16','用户管理','修改'),(57,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',9,'127.0.0.1','2026-04-14 14:36:30','用户管理','修改'),(58,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:36:30','用户管理','修改'),(59,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',6,'127.0.0.1','2026-04-14 14:39:14','用户管理','修改'),(60,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',17,'127.0.0.1','2026-04-14 14:39:14','用户管理','修改'),(61,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',5,'127.0.0.1','2026-04-14 14:39:17','用户管理','修改'),(62,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',5,'127.0.0.1','2026-04-14 14:39:17','用户管理','修改'),(63,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',6,'127.0.0.1','2026-04-14 14:43:36','用户管理','修改'),(64,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',10,'127.0.0.1','2026-04-14 14:43:36','用户管理','修改'),(65,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',6,'127.0.0.1','2026-04-14 14:52:28','用户管理','修改'),(66,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',6,'127.0.0.1','2026-04-14 14:52:28','用户管理','修改'),(67,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:52:28','用户管理','修改'),(68,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',12,'127.0.0.1','2026-04-14 14:52:28','用户管理','修改'),(69,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:52:28','用户管理','修改'),(70,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',39,'127.0.0.1','2026-04-14 14:52:28','用户管理','修改'),(71,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',5,'127.0.0.1','2026-04-14 14:52:30','用户管理','修改'),(72,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',6,'127.0.0.1','2026-04-14 14:52:30','用户管理','修改'),(73,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',8,'127.0.0.1','2026-04-14 14:52:31','用户管理','修改'),(74,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]',9,'127.0.0.1','2026-04-14 14:52:32','用户管理','修改'),(75,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',5,'127.0.0.1','2026-04-14 14:52:34','用户管理','修改'),(76,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',13,'127.0.0.1','2026-04-14 14:52:34','用户管理','修改'),(77,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',5,'127.0.0.1','2026-04-14 14:52:39','用户管理','修改'),(78,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',6,'127.0.0.1','2026-04-14 14:52:39','用户管理','修改'),(79,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',5,'127.0.0.1','2026-04-14 14:53:03','用户管理','修改'),(80,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',4,'127.0.0.1','2026-04-14 14:53:03','用户管理','修改'),(81,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',8,'127.0.0.1','2026-04-14 14:53:06','用户管理','修改'),(82,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',11,'127.0.0.1','2026-04-14 14:53:06','用户管理','修改'),(83,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:53:14','用户管理','修改'),(84,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',9,'127.0.0.1','2026-04-14 14:53:14','用户管理','修改'),(85,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',6,'127.0.0.1','2026-04-14 14:53:16','用户管理','修改'),(86,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',11,'127.0.0.1','2026-04-14 14:53:36','用户管理','修改'),(87,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',13,'127.0.0.1','2026-04-14 14:53:36','用户管理','修改'),(88,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]',7,'127.0.0.1','2026-04-14 14:53:53','用户管理','修改'),(89,'系统','修改仓库状态','controller.com.lunabaka.WarehouseController.updateStatus()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]',24,'127.0.0.1','2026-04-14 14:53:53','用户管理','修改'),(90,'系统','修改仓库信息','controller.com.lunabaka.WarehouseController.updateWarehouse()','[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]',4,'127.0.0.1','2026-04-14 14:58:09','用户管理','修改'),(91,'系统','删除商品','controller.com.lunabaka.WarehouseController.deleteGoods()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]',2,'127.0.0.1','2026-04-14 14:58:41','商品管理','删除'),(92,'系统','删除商品','controller.com.lunabaka.WarehouseController.deleteGoods()','[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]',2,'127.0.0.1','2026-04-14 14:59:04','商品管理','删除'),(93,'系统','新增库存作业','controller.com.lunabaka.InventoryOperationController.insert()','[{\"作业单号\":\"WH1776155534114\",\"作业类型\":\"inbound\",\"目标仓库\":\"一号仓库\",\"商品名称\":\"苹果\",\"SKU 编码\":\"APL001\",\"数量\":5,\"单位\":\"个\",\"操作员\":\"Test\",\"状态\":\"pending\",\"备注\":\"\"}]',12,'127.0.0.1','2026-04-14 16:32:31','库存作业管理','新增'),(94,'系统','新增库存作业','controller.com.lunabaka.InventoryOperationController.insert()','[{\"作业单号\":\"WH1776156962129\",\"作业类型\":\"transfer\",\"源仓库\":\"一号仓库\",\"目标仓库\":\"二号仓库\",\"商品名称\":\"苹果\",\"SKU 编码\":\"APL001\",\"数量\":2,\"单位\":\"个\",\"操作员\":\"Test\",\"状态\":\"pending\",\"备注\":\"\"}]',27,'127.0.0.1','2026-04-14 16:56:17','库存作业管理','新增'),(95,'系统','更新库存作业状态','controller.com.lunabaka.InventoryOperationController.updateStatus()','[1,\"completed\"]',8,'127.0.0.1','2026-04-14 16:56:24','库存作业管理','修改'),(96,'系统','更新库存作业状态','controller.com.lunabaka.InventoryOperationController.updateStatus()','[2,\"cancelled\"]',9,'127.0.0.1','2026-04-14 16:56:45','库存作业管理','修改'),(97,'系统','新增库存作业','controller.com.lunabaka.InventoryOperationController.insert()','[{\"作业单号\":\"WH1776157025744\",\"作业类型\":\"outbound\",\"源仓库\":\"一号仓库\",\"商品名称\":\"苹果\",\"SKU 编码\":\"APL001\",\"数量\":1,\"单位\":\"个\",\"操作员\":\"Test\",\"状态\":\"pending\",\"备注\":\"\"}]',17,'127.0.0.1','2026-04-14 16:57:16','库存作业管理','新增'),(98,'系统','更新库存作业状态','controller.com.lunabaka.InventoryOperationController.updateStatus()','[3,\"completed\"]',5,'127.0.0.1','2026-04-14 16:57:21','库存作业管理','修改'),(99,'系统','新增库存作业','controller.com.lunabaka.InventoryOperationController.insert()','[{\"作业单号\":\"WH1776157051705\",\"作业类型\":\"adjustment\",\"源仓库\":\"一号仓库\",\"目标仓库\":\"一号仓库\",\"商品名称\":\"苹果\",\"SKU 编码\":\"APL001\",\"数量\":5,\"单位\":\"个\",\"操作员\":\"TEST\",\"状态\":\"pending\",\"备注\":\"\"}]',7,'127.0.0.1','2026-04-14 16:57:48','库存作业管理','新增'),(100,'系统','更新库存作业状态','controller.com.lunabaka.InventoryOperationController.updateStatus()','[4,\"completed\"]',8,'127.0.0.1','2026-04-14 17:14:15','库存作业管理','修改'),(101,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',388,'127.0.0.1','2026-04-15 12:42:53','用户管理','登录'),(102,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',121,'127.0.0.1','2026-04-15 16:25:02','用户管理','登录'),(103,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',74,'127.0.0.1','2026-04-15 16:33:20','用户管理','登录'),(104,'系统','新增商品','controller.com.lunabaka.GoodsController.insertGoods()','[{\"SKU编码\":\"\",\"img\":\"\",\"商品名称\":\"007\",\"品牌\":\"\",\"规格型号\":\"\",\"基础单位\":\"个\",\"参考采购价\":\"0\",\"标准售价\":0,\"成本价格\":0,\"主条码\":\"\",\"库存数量\":0,\"库存预警上限\":0,\"库存预警下限\":0}]',47,'127.0.0.1','2026-04-15 16:53:22','商品管理','新增'),(105,'系统','新增商品','controller.com.lunabaka.GoodsController.insertGoods()','[{\"SKU编码\":\"\",\"img\":\"\",\"商品名称\":\"007\",\"品牌\":\"\",\"规格型号\":\"500ml/瓶\",\"基础单位\":\"瓶\",\"参考采购价\":\"0\",\"标准售价\":0,\"成本价格\":0,\"主条码\":\"\",\"库存数量\":0,\"库存预警上限\":0,\"库存预警下限\":0}]',53,'127.0.0.1','2026-04-15 16:59:12','商品管理','新增'),(106,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',117,'127.0.0.1','2026-04-15 22:40:31','用户管理','登录'),(107,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',530,'127.0.0.1','2026-04-16 15:03:24','用户管理','登录'),(108,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',180,'127.0.0.1','2026-04-16 15:47:54','用户管理','登录'),(109,'系统','用户登录','controller.com.lunabaka.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',454,'127.0.0.1','2026-05-08 15:11:22','用户管理','登录'),(110,'系统','修改用户','com.lunabaka.controller.UserController.updateInfo()','[{\"UID\":1,\"昵称\":\"管理员\",\"角色\":\"超级管理员\",\"部门\":\"研发组\",\"备注\":\"BioHazard 1\",\"入职时间\":\"2026-03-19 22:30:00\"}]',15,'127.0.0.1','2026-06-11 17:20:16','用户管理','修改'),(111,'系统','新增公告','com.lunabaka.controller.NoticeController.postNotice()','[{\"公告标题\":\"Test\",\"公告类型\":\"系统更新\",\"公告摘要\":\"Test\",\"公告内容\":\"<p>testststststst</p>\",\"发布时间\":1781170590247,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"附件\":\"[{\\\"name\\\":\\\"A_small_cup_of_coffee.JPG\\\",\\\"url\\\":\\\"http://localhost:8080/static/upload/picture/1781170586313_A_small_cup_of_coffee.JPG\\\",\\\"size\\\":32886}]\"}]',117,'127.0.0.1','2026-06-11 17:36:30','公告管理','新增'),(112,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',625,'127.0.0.1','2026-06-22 14:24:28','用户管理','登录'),(113,'系统','修改用户状态','com.lunabaka.controller.UserController.updateStatus()','[{\"昵称\":\"系统管理员\",\"备注\":\" 系统管理员\",\"状态\":\"禁用\"}]',75,'127.0.0.1','2026-06-22 15:47:51','用户管理','修改'),(114,'系统','修改用户状态','com.lunabaka.controller.UserController.updateStatus()','[{\"昵称\":\"系统管理员\",\"备注\":\" 系统管理员\",\"状态\":\"禁用\"}]',5,'127.0.0.1','2026-06-22 15:48:10','用户管理','修改'),(115,'系统','修改用户状态','com.lunabaka.controller.UserController.updateStatus()','[{\"昵称\":\"系统管理员\",\"备注\":\" 系统管理员\",\"状态\":\"禁用\"}]',8,'127.0.0.1','2026-06-22 15:48:30','用户管理','修改'),(116,'系统','修改用户状态','com.lunabaka.controller.UserController.updateStatus()','[{\"昵称\":\"系统管理员\",\"备注\":\" 系统管理员\",\"状态\":\"禁用\"}]',7,'127.0.0.1','2026-06-22 15:49:02','用户管理','修改'),(117,'系统','修改用户状态','com.lunabaka.controller.UserController.updateStatus()','[{\"昵称\":\"系统管理员\",\"备注\":\" 系统管理员\",\"状态\":\"0\"}]',2,'127.0.0.1','2026-06-22 15:50:33','用户管理','修改'),(118,'系统','修改用户状态','com.lunabaka.controller.UserController.updateStatus()','[{\"昵称\":\"系统管理员\",\"备注\":\" 系统管理员\",\"状态\":\"0\"}]',7,'127.0.0.1','2026-06-22 15:50:51','用户管理','修改'),(119,'系统','修改用户状态','com.lunabaka.controller.UserController.updateStatus()','[{\"昵称\":\"系统管理员\",\"备注\":\" 系统管理员\",\"状态\":\"0\"}]',2,'127.0.0.1','2026-06-22 15:51:06','用户管理','修改'),(120,'系统','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":1,\"status\":0}]',43,'127.0.0.1','2026-06-22 16:45:43','用户角色管理','修改'),(121,'系统','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":1,\"status\":1}]',7,'127.0.0.1','2026-06-22 16:45:47','用户角色管理','修改'),(122,'系统','添加用户角色','com.lunabaka.controller.RoleController.addRole()','[{\"id\":2,\"name\":\"采购员\",\"bio\":\"采购\",\"status\":1}]',9,'127.0.0.1','2026-06-22 16:47:21','用户角色管理','新增'),(123,'系统','添加用户角色','com.lunabaka.controller.RoleController.addRole()','[{\"id\":3,\"name\":\"销售员\",\"bio\":\"销售\",\"status\":1}]',4,'127.0.0.1','2026-06-22 16:47:44','用户角色管理','新增'),(124,'系统','添加用户角色','com.lunabaka.controller.RoleController.addRole()','[{\"id\":4,\"name\":\"仓库管理员\",\"bio\":\"仓库管理员\",\"status\":1}]',3,'127.0.0.1','2026-06-22 16:47:52','用户角色管理','新增'),(125,'系统','添加用户角色','com.lunabaka.controller.RoleController.addRole()','[{\"id\":5,\"name\":\"财务人员\",\"bio\":\"财务人员\",\"status\":1}]',13,'127.0.0.1','2026-06-22 16:48:01','用户角色管理','新增'),(126,'系统','添加用户角色','com.lunabaka.controller.RoleController.addRole()','[{\"id\":6,\"name\":\"测试\",\"bio\":\"测试员\",\"status\":1}]',33,'127.0.0.1','2026-06-22 17:20:01','用户角色管理','新增'),(127,'系统','删除用户角色','com.lunabaka.controller.RoleController.deleteById()','[{\"id\":6,\"name\":\"测试\",\"bio\":\"测试员\",\"status\":1}]',8,'127.0.0.1','2026-06-22 17:20:03','用户角色管理','删除'),(128,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',121,'127.0.0.1','2026-06-23 21:22:34','用户管理','登录'),(129,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',125,'127.0.0.1','2026-06-24 14:19:00','用户管理','登录'),(130,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',93,'127.0.0.1','2026-06-25 10:52:47','用户管理','登录'),(131,'系统','修改菜单信息','com.lunabaka.controller.MenuController.updateInfo()','[{\"id\":1,\"name\":\"开始\",\"status\":true}]',19,'127.0.0.1','2026-06-25 15:02:10','菜单管理','修改'),(132,'系统','修改菜单信息','com.lunabaka.controller.MenuController.updateInfo()','[{\"id\":1,\"name\":\"工作台\",\"status\":true}]',1,'127.0.0.1','2026-06-25 15:02:20','菜单管理','修改'),(133,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',248,'127.0.0.1','2026-06-28 17:10:12','用户管理','登录'),(134,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',105,'127.0.0.1','2026-06-28 17:42:34','用户管理','登录'),(135,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',88,'127.0.0.1','2026-06-29 12:09:07','用户管理','登录'),(136,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',118,'127.0.0.1','2026-06-29 18:08:29','用户管理','登录'),(137,'系统','新增部门','com.lunabaka.controller.DeptController.add()','[{\"id\":45,\"name\":\"test\",\"code\":\"test\",\"intro\":\"test\",\"status\":1}]',21,'127.0.0.1','2026-06-30 16:06:31','部门管理','新增'),(138,'系统','新增部门','com.lunabaka.controller.DeptController.add()','[{\"id\":46,\"name\":\"testtest\",\"code\":\"testtest\",\"intro\":\"testtest\",\"parentId\":45,\"status\":1}]',9,'127.0.0.1','2026-06-30 16:06:39','部门管理','新增'),(139,'系统','删除部门','com.lunabaka.controller.DeptController.delete()','[{\"id\":45,\"name\":\"test\",\"code\":\"test\",\"intro\":\"test\",\"parentId\":0,\"createTime\":1782806791000,\"status\":1,\"children\":[{\"id\":46,\"name\":\"testtest\",\"code\":\"testtest\",\"intro\":\"testtest\",\"parentId\":45,\"createTime\":1782806799000,\"status\":1}]}]',25,'127.0.0.1','2026-06-30 16:06:42','部门管理','删除'),(140,'系统','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":0}]',19,'127.0.0.1','2026-06-30 17:05:03','用户角色管理','修改'),(141,'系统','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":1}]',5,'127.0.0.1','2026-06-30 17:05:20','用户角色管理','修改'),(142,'系统','新增部门','com.lunabaka.controller.DeptController.add()','[{\"id\":47,\"name\":\"真理部\",\"code\":\"TURTH\",\"intro\":\"真理部，即是真理\",\"parentId\":2,\"status\":1}]',192,'127.0.0.1','2026-07-01 10:29:31','部门管理','新增'),(143,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"test\",\"密码\":\"test\"}]',102,'127.0.0.1','2026-07-01 14:30:51','用户管理','登录'),(144,'系统','修改用户密码','com.lunabaka.controller.UserController.updatePassword()','[{\"UID\":2}]',19,'127.0.0.1','2026-07-01 14:32:28','用户管理','修改'),(145,'系统','修改用户密码','com.lunabaka.controller.UserController.updatePassword()','[{\"UID\":2}]',63,'127.0.0.1','2026-07-01 14:33:21','用户管理','修改'),(146,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"test\",\"密码\":\"123456\"}]',63,'127.0.0.1','2026-07-01 14:34:39','用户管理','登录'),(147,'系统','修改用户密码','com.lunabaka.controller.UserController.updatePassword()','[{\"UID\":2,\"密码\":\"$2a$10$hryPztoTlHka87cXAfXnfuA0m9RrDPqplsbdr4CoCS6PKkw69bQUq\"}]',74,'127.0.0.1','2026-07-01 14:35:56','用户管理','修改'),(148,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"test\",\"密码\":\"testtest\"}]',60,'127.0.0.1','2026-07-01 14:36:19','用户管理','登录'),(149,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',62,'127.0.0.1','2026-07-01 14:37:52','用户管理','登录'),(150,'系统','修改用户','com.lunabaka.controller.UserController.updateInfo()','[{\"UID\":1,\"用户名\":\"admin\",\"昵称\":\"管理员\",\"邮箱\":\"admin@test.com\",\"部门\":\"总经理办公室/真理部\",\"电话\":\"14325345231\",\"备注\":\"BioHazard 1\",\"入职时间\":\"2026-03-19 22:30:00\",\"状态\":\"启用\"}]',28,'127.0.0.1','2026-07-01 15:00:10','用户管理','修改'),(151,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',169,'127.0.0.1','2026-07-01 15:08:11','用户管理','登录'),(152,'系统','修改用户','com.lunabaka.controller.UserController.updateInfo()','[{\"UID\":1,\"用户名\":\"admin\",\"昵称\":\"管理员\",\"邮箱\":\"admin@test.com\",\"角色\":\"超级管理员\",\"部门\":\"真理部\",\"电话\":\"14325345231\",\"备注\":\"BioHazard 1\",\"入职时间\":\"2026-03-19 22:30:00\",\"状态\":\"启用\"}]',21,'127.0.0.1','2026-07-01 15:08:21','用户管理','修改'),(153,'系统','修改用户职位状态','com.lunabaka.controller.PostController.updateStatus()','[{\"id\":10,\"status\":0}]',47,'127.0.0.1','2026-07-01 15:25:54','用户职位管理','修改'),(154,'系统','修改用户职位状态','com.lunabaka.controller.PostController.updateStatus()','[{\"id\":10,\"status\":1}]',14,'127.0.0.1','2026-07-01 15:26:09','用户职位管理','修改'),(155,'系统','创建新会议','com.lunabaka.controller.MeetingController.create()','[{\"id\":1,\"title\":\"审判异端\",\"content\":\"<p><span style=\\\"font-size: 29px;\\\"><strong>异端审判执行</strong></span></p>\",\"publishTime\":1782891799537,\"startTime\":1782891626000,\"endTime\":\"2026-07-01 16:40:29\",\"status\":0,\"makeUser\":\"管理员,test,特色t,test3,teststtst\",\"address\":\"真理部审判室\",\"deptId\":47}]',94,'127.0.0.1','2026-07-01 15:43:19','会议管理','创建'),(156,'系统','新增公告','com.lunabaka.controller.NoticeController.postNotice()','[{\"公告标题\":\"测试一下公告的同步\",\"公告类型\":\"其他公告\",\"公告摘要\":\"\",\"公告内容\":\"<p>TESTSETSETSETSTSETESTSET</p>\",\"发布时间\":1782896820703,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"附件\":\"[]\"}]',212,'127.0.0.1','2026-07-01 17:07:00','公告管理','新增'),(157,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',169,'127.0.0.1','2026-07-01 17:15:39','用户管理','登录'),(158,'系统','删除公告','com.lunabaka.controller.NoticeController.deleteById()','[{\"公告标题\":\"测试一下公告的同步\",\"公告类型\":\"其他公告\",\"公告摘要\":\"\",\"公告内容\":\"<p>TESTSETSETSETSTSETESTSET</p>\",\"发布时间\":1782896820000,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"查看数量\":1,\"附件\":\"[]\"}]',35,'127.0.0.1','2026-07-01 17:15:54','公告管理','删除'),(159,'系统','新增公告','com.lunabaka.controller.NoticeController.postNotice()','[{\"公告标题\":\"测试WebSocket\",\"公告类型\":\"其他公告\",\"公告摘要\":\"test\",\"公告内容\":\"<p>teststststststst</p>\",\"发布时间\":1782897382826,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"附件\":\"[]\"}]',50,'127.0.0.1','2026-07-01 17:16:22','公告管理','新增'),(160,'系统','新增公告','com.lunabaka.controller.NoticeController.postNotice()','[{\"公告标题\":\"再次测试公告页面\",\"公告类型\":\"其他公告\",\"公告摘要\":\"teststststs\",\"公告内容\":\"<p>ststststetsatetasetaset</p>\",\"发布时间\":1782897580102,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"附件\":\"[]\"}]',182,'127.0.0.1','2026-07-01 17:19:40','公告管理','新增'),(161,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',4,'127.0.0.1','2026-07-01 17:56:29','会议管理','签到'),(162,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',114,'127.0.0.1','2026-07-01 17:56:34','用户管理','登录'),(163,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',2,'127.0.0.1','2026-07-01 17:56:40','会议管理','签到'),(164,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',2,'127.0.0.1','2026-07-01 17:56:55','会议管理','签到'),(165,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"test\",\"密码\":\"testtest\"}]',62,'127.0.0.1','2026-07-01 17:57:24','用户管理','登录'),(166,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',2,'127.0.0.1','2026-07-01 17:57:34','会议管理','签到'),(167,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',2,'127.0.0.1','2026-07-01 17:57:46','会议管理','签到'),(168,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',1,'127.0.0.1','2026-07-01 17:58:01','会议管理','签到'),(169,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',2,'127.0.0.1','2026-07-01 17:58:10','会议管理','签到'),(170,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',17,'127.0.0.1','2026-07-01 18:00:35','会议管理','签到'),(171,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',38,'127.0.0.1','2026-07-01 18:00:41','会议管理','签到'),(172,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',3,'127.0.0.1','2026-07-01 18:01:51','会议管理','签到'),(173,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[1]',2,'127.0.0.1','2026-07-01 18:02:12','会议管理','签到'),(174,'系统','创建新会议','com.lunabaka.controller.MeetingController.create()','[{\"id\":2,\"title\":\"test\",\"content\":\"<p>teststststst</p>\",\"publishTime\":1782975549199,\"startTime\":1782975531000,\"endTime\":\"2026-07-03 07:00:00\",\"status\":0,\"makeUser\":\"1,2,3\",\"address\":\"est\",\"deptId\":47}]',102,'127.0.0.1','2026-07-02 14:59:09','会议管理','创建'),(175,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[2]',10,'127.0.0.1','2026-07-02 15:01:00','会议管理','签到'),(176,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[2]',2,'127.0.0.1','2026-07-02 15:01:48','会议管理','签到'),(177,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[2]',1,'127.0.0.1','2026-07-02 15:02:01','会议管理','签到'),(178,'系统','创建新会议','com.lunabaka.controller.MeetingController.create()','[{\"id\":3,\"title\":\"test\",\"content\":\"<p>testststststst</p>\",\"publishTime\":1782975749185,\"startTime\":1783008000000,\"endTime\":\"2026-07-04 00:00:00\",\"status\":0,\"makeUser\":\"管理员,test,特色t,test3,teststtst,A_User_For_TEST,serser\",\"address\":\"teststs\",\"deptId\":3}]',7,'127.0.0.1','2026-07-02 15:02:29','会议管理','创建'),(179,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[3]',58,'127.0.0.1','2026-07-02 15:56:45','会议管理','签到'),(180,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[3]',24,'127.0.0.1','2026-07-02 15:57:02','会议管理','签到'),(181,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[3]',50,'127.0.0.1','2026-07-02 15:58:13','会议管理','签到'),(182,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[3]',106,'127.0.0.1','2026-07-02 15:58:47','会议管理','签到'),(183,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[3]',40,'127.0.0.1','2026-07-02 16:00:15','会议管理','签到'),(184,'系统','创建新会议','com.lunabaka.controller.MeetingController.create()','[{\"id\":4,\"title\":\"审判测试\",\"content\":\"<h1>审判！</h1>\",\"publishTime\":1782979633987,\"startTime\":1783008000000,\"endTime\":\"2026-07-03 21:50:00\",\"status\":0,\"makeUser\":\"管理员,test,test3,teststtst,A_User_For_TEST,serser,1231231,tetetetetet,tetoteto,4141414,42,123,124,125,126,127,128,admin1\",\"address\":\"操场\",\"deptId\":47}]',16,'127.0.0.1','2026-07-02 16:07:14','会议管理','创建'),(185,'系统','新增公告','com.lunabaka.controller.NoticeController.postNotice()','[{\"公告标题\":\"测试定时\",\"公告类型\":\"维护通知\",\"公告摘要\":\"\",\"公告内容\":\"<p>testtesttest</p>\",\"发布时间\":1782982557000,\"发布作者\":\"管理员\",\"公告状态\":\"定时发布\",\"附件\":\"[]\"}]',62,'127.0.0.1','2026-07-02 16:53:24','公告管理','新增'),(186,'系统','创建新会议','com.lunabaka.controller.MeetingController.create()','[{\"id\":5,\"title\":\"test\",\"content\":\"<h1>测试一下</h1>\",\"publishTime\":1782982706966,\"startTime\":1782982704000,\"endTime\":\"2026-07-02 16:58:25\",\"status\":0,\"makeUser\":\"test\",\"address\":\"test\",\"deptId\":2}]',279,'127.0.0.1','2026-07-02 16:58:27','会议管理','创建'),(187,'系统','创建新会议','com.lunabaka.controller.MeetingController.create()','[{\"id\":6,\"title\":\"正经会议——今晚吃啥\",\"content\":\"<h1>今晚吃啥</h1>\",\"publishTime\":1782982865745,\"startTime\":1782982832000,\"endTime\":\"2026-07-02 17:00:33\",\"status\":0,\"makeUser\":\"管理员,test,特色t\",\"address\":\"饭堂\",\"deptName\":\"综合管理中心\",\"deptId\":3}]',113,'127.0.0.1','2026-07-02 17:01:05','会议管理','创建'),(188,'系统','创建新会议','com.lunabaka.controller.MeetingController.create()','[{\"id\":7,\"title\":\"cttt\",\"content\":\"<p>tttttt</p>\",\"publishTime\":1782984627100,\"startTime\":1782984622000,\"endTime\":1782984623000,\"status\":0,\"makeUser\":\"管理员,test,特色t\",\"address\":\"ttttt\",\"deptName\":\"总经理办公室\",\"deptId\":2}]',15,'127.0.0.1','2026-07-02 17:30:27','会议管理','创建'),(189,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"test\",\"密码\":\"testtest\"}]',111,'127.0.0.1','2026-07-02 17:59:08','用户管理','登录'),(190,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',93,'127.0.0.1','2026-07-02 18:02:03','用户管理','登录'),(191,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[4]',18,'127.0.0.1','2026-07-03 15:18:59','会议管理','签到'),(192,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[4]',29,'127.0.0.1','2026-07-03 15:19:24','会议管理','签到'),(193,'系统','创建新会议','com.lunabaka.controller.MeetingController.create()','[{\"id\":8,\"title\":\"测试会议定时\",\"content\":\"<h1>测试定时</h1>\",\"publishTime\":1783063253087,\"startTime\":1783063553000,\"endTime\":1783066860000,\"status\":0,\"makeUser\":\"管理员,test\",\"address\":\"机房\",\"deptName\":\"信息技术部\",\"deptId\":12}]',44,'127.0.0.1','2026-07-03 15:20:53','会议管理','创建'),(194,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',122,'127.0.0.1','2026-07-03 15:24:23','用户管理','登录'),(195,'系统','创建新会议','com.lunabaka.controller.MeetingController.create()','[{\"id\":9,\"title\":\"测试富文本\",\"content\":\"<p>测试一下富文本编辑器，感觉确实是Firefox的问题（</p>\",\"publishTime\":1783063526686,\"startTime\":1783063501000,\"endTime\":1783149906000,\"status\":0,\"makeUser\":\"管理员,test\",\"address\":\"自行车V\",\"deptName\":\"财务中心\",\"deptId\":4,\"userId\":1,\"userName\":\"管理员\"}]',50,'127.0.0.1','2026-07-03 15:25:26','会议管理','创建'),(196,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[9]',149,'127.0.0.1','2026-07-03 15:25:34','会议管理','签到'),(197,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[8]',1,'127.0.0.1','2026-07-03 15:25:40','会议管理','签到'),(198,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',82,'127.0.0.1','2026-07-03 15:37:22','用户管理','登录'),(199,'系统','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":0}]',6,'127.0.0.1','2026-07-03 15:44:42','用户角色管理','修改'),(200,'系统','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":1}]',87,'127.0.0.1','2026-07-03 15:44:52','用户角色管理','修改'),(201,'系统','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":0}]',17,'127.0.0.1','2026-07-03 15:47:49','用户角色管理','修改'),(202,'系统','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":1}]',13,'127.0.0.1','2026-07-03 15:47:58','用户角色管理','修改'),(203,'系统','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[9]',46,'127.0.0.1','2026-07-03 15:49:39','会议管理','签到'),(204,'管理员','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":0}]',36,'127.0.0.1','2026-07-03 15:52:01','用户角色管理','修改'),(205,'test','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":1}]',33,'0:0:0:0:0:0:0:1','2026-07-03 15:52:16','用户角色管理','修改'),(206,'test','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":0}]',26,'127.0.0.1','2026-07-03 15:55:48','用户角色管理','修改'),(207,'test','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":1}]',13,'127.0.0.1','2026-07-03 15:55:52','用户角色管理','修改'),(208,'test','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":0}]',4,'127.0.0.1','2026-07-03 15:58:08','用户角色管理','修改'),(209,'test','修改用户角色状态','com.lunabaka.controller.RoleController.updateStatus()','[{\"id\":10,\"status\":1}]',7,'127.0.0.1','2026-07-03 15:58:17','用户角色管理','修改'),(210,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',80,'127.0.0.1','2026-07-03 16:00:43','用户管理','登录'),(211,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"test\",\"密码\":\"testtest\"}]',67,'127.0.0.1','2026-07-03 16:00:57','用户管理','登录'),(212,'管理员','删除会议','com.lunabaka.controller.MeetingController.delete()','[{\"id\":9}]',23,'127.0.0.1','2026-07-03 16:08:56','会议管理','删除'),(213,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"A_User_For_TEST\",\"密码\":\"testtest\"}]',70,'127.0.0.1','2026-07-03 16:10:31','用户管理','登录'),(214,'A_User_For_TEST','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[8]',45,'127.0.0.1','2026-07-03 16:10:40','会议管理','签到'),(215,'A_User_For_TEST','参加会议签到','com.lunabaka.controller.MeetingController.checkin()','[8]',1,'127.0.0.1','2026-07-03 16:10:50','会议管理','签到'),(216,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"A_User_For_TEST\",\"密码\":\"testtest\"}]',136,'127.0.0.1','2026-07-03 16:24:08','用户管理','登录'),(217,'管理员','新增公告','com.lunabaka.controller.NoticeController.postNotice()','[{\"公告标题\":\"测试公告\",\"公告类型\":\"维护通知\",\"公告摘要\":\"te s t\",\"公告内容\":\"<p>te s t s t s t s t</p>\",\"发布时间\":1783068625514,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"附件\":\"[]\"}]',17,'127.0.0.1','2026-07-03 16:50:25','公告管理','新增'),(218,'管理员','修改公告','com.lunabaka.controller.NoticeController.updateNotice()','[{\"公告标题\":\"测试公告\",\"公告类型\":\"维护通知\",\"公告摘要\":\"te s t\",\"公告内容\":\"<p>te s t s t s t s t</p>\",\"发布时间\":1783068925000,\"发布作者\":\"管理员\",\"公告状态\":\"定时发布\",\"附件\":\"[]\"}]',9,'127.0.0.1','2026-07-03 16:50:46','公告管理','修改'),(219,'管理员','新增公告','com.lunabaka.controller.NoticeController.postNotice()','[{\"公告标题\":\"测试\",\"公告类型\":\"维护通知\",\"公告摘要\":\"a t\",\"公告内容\":\"<p>t s t s t s s t s t</p>\",\"发布时间\":1783068782000,\"发布作者\":\"管理员\",\"公告状态\":\"定时发布\",\"附件\":\"[]\"}]',41,'127.0.0.1','2026-07-03 16:51:14','公告管理','新增'),(220,'管理员','修改用户','com.lunabaka.controller.UserController.updateInfo()','[{\"UID\":1,\"昵称\":\"管理员\",\"角色\":\"超级管理员\",\"部门\":\"真理部\",\"职位\":\"系统管理员\",\"备注\":\"BioHazard 1\",\"入职时间\":\"2026-03-19 22:30:00\"}]',36,'127.0.0.1','2026-07-03 17:02:55','用户管理','修改'),(221,'管理员','新增公告','com.lunabaka.controller.NoticeController.postNotice()','[{\"公告标题\":\"测试定时发布\",\"公告类型\":\"维护通知\",\"公告摘要\":\"侧\",\"公告内容\":\"<p>te s t s t s s t</p>\",\"发布时间\":1783070780000,\"发布作者\":\"管理员\",\"公告状态\":\"定时发布\",\"附件\":\"[]\"}]',109,'127.0.0.1','2026-07-03 17:22:36','公告管理','新增'),(222,'管理员','删除公告','com.lunabaka.controller.NoticeController.deleteById()','[{\"公告标题\":\"测试定时发布\",\"公告类型\":\"维护通知\",\"公告摘要\":\"侧\",\"公告内容\":\"<p>te s t s t s s t</p>\",\"发布时间\":1783070780000,\"发布作者\":\"管理员\",\"公告状态\":\"定时发布\",\"查看数量\":0,\"附件\":\"[]\"}]',15,'127.0.0.1','2026-07-03 17:22:43','公告管理','删除'),(223,'管理员','新增公告','com.lunabaka.controller.NoticeController.postNotice()','[{\"公告标题\":\"测试\",\"公告类型\":\"维护通知\",\"公告摘要\":\"test\",\"公告内容\":\"<p>test</p>\",\"发布时间\":1783070704000,\"发布作者\":\"管理员\",\"公告状态\":\"定时发布\",\"附件\":\"[]\"}]',41,'127.0.0.1','2026-07-03 17:23:13','公告管理','新增'),(224,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',95,'127.0.0.1','2026-07-21 16:58:53','用户管理','登录'),(225,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',134,'127.0.0.1','2026-07-24 16:46:12','用户管理','登录'),(226,'管理员','修改用户','com.lunabaka.controller.UserController.updateInfo()','[{\"UID\":1,\"昵称\":\"管理员\",\"角色\":\"超级管理员\",\"部门\":\"47\",\"职位\":\"部门经理\",\"备注\":\"BioHazard 1\",\"入职时间\":\"2026-03-19 22:30:00\"}]',14,'127.0.0.1','2026-07-24 16:48:15','用户管理','修改'),(227,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',123,'127.0.0.1','2026-07-24 17:44:33','用户管理','登录'),(228,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"test\",\"密码\":\"testtest\"}]',62,'127.0.0.1','2026-07-24 17:46:23','用户管理','登录'),(229,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',60,'127.0.0.1','2026-07-24 17:47:41','用户管理','登录'),(230,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',118,'127.0.0.1','2026-07-27 15:48:48','用户管理','登录'),(231,'管理员','修改用户','com.lunabaka.controller.UserController.updateInfo()','[{\"UID\":1,\"昵称\":\"管理员\",\"角色\":\"超级管理员\",\"部门\":\"47\",\"职位\":\"部门经理\",\"备注\":\"BioHazard 1\",\"入职时间\":\"2026-03-19 22:30:00\"}]',15,'127.0.0.1','2026-07-27 16:06:19','用户管理','修改'),(232,'管理员','修改用户','com.lunabaka.controller.UserController.updateInfo()','[{\"UID\":1,\"昵称\":\"管理员\",\"角色\":\"超级管理员\",\"职位\":\"部门经理\",\"备注\":\"BioHazard 1\",\"入职时间\":\"2026-03-19 22:30:00\"}]',62,'127.0.0.1','2026-07-27 16:14:15','用户管理','修改'),(233,'管理员','修改用户','com.lunabaka.controller.UserController.updateInfo()','[{\"UID\":1,\"昵称\":\"管理员\",\"角色\":\"超级管理员\",\"职位\":\"部门经理\",\"备注\":\"BioHazard 1\",\"入职时间\":\"2026-03-19 22:30:00\"}]',30,'127.0.0.1','2026-07-27 16:37:48','用户管理','修改'),(234,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',103,'127.0.0.1','2026-08-19 11:11:03','用户管理','登录'),(235,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',161,'127.0.0.1','2026-08-19 17:38:22','用户管理','登录'),(236,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',60,'127.0.0.1','2026-08-19 17:43:58','用户管理','登录'),(237,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',67,'127.0.0.1','2026-08-19 17:46:20','用户管理','登录'),(238,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',103,'127.0.0.1','2026-09-11 22:31:51','用户管理','登录'),(239,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',164,'127.0.0.1','2026-09-16 11:29:34','用户管理','登录'),(240,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',131,'127.0.0.1','2026-09-17 21:09:20','用户管理','登录'),(241,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',124,'127.0.0.1','2026-09-20 15:27:34','用户管理','登录'),(242,'管理员','删除公告','com.lunabaka.controller.NoticeController.deleteById()','[{\"公告标题\":\"测试\",\"公告类型\":\"维护通知\",\"公告摘要\":\"test\",\"公告内容\":\"<p>test</p>\",\"发布时间\":1783036800000,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"查看数量\":5,\"附件\":\"[]\"}]',100,'127.0.0.1','2026-09-20 15:47:50','公告管理','删除'),(243,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',126,'127.0.0.1','2026-09-20 16:12:41','用户管理','登录'),(244,'管理员','删除消息','com.lunabaka.controller.MessageController.delete()','[{},{\"msgId\":112}]',11,'127.0.0.1','2026-09-20 16:13:16','消息中心','删除'),(245,'管理员','批量删除消息','com.lunabaka.controller.MessageController.batchDelete()','[{},{\"msgIds\":[94,98]}]',10,'127.0.0.1','2026-09-20 16:13:17','消息中心','删除'),(246,'管理员','清空消息','com.lunabaka.controller.MessageController.clearAll()','[{}]',8,'127.0.0.1','2026-09-20 16:13:19','消息中心','删除'),(247,'系统','用户登录','com.lunabaka.controller.WebController.login()','[{\"用户名\":\"admin\",\"密码\":\"123456\"}]',106,'127.0.0.1','2026-09-20 16:16:58','用户管理','登录');
/*!40000 ALTER TABLE `operation_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `parent_id` bigint unsigned NOT NULL DEFAULT '0' COMMENT '父权限ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '权限名称',
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '权限编码',
  `type` tinyint NOT NULL COMMENT '权限类型（1目录 2菜单 3按钮）',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '前端路由',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '前端组件',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '图标',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_permission_code` (`code`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='权限表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission`
--

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post`
--

DROP TABLE IF EXISTS `post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '职位ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '职位名称',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '职位编码',
  `level` tinyint NOT NULL DEFAULT '4' COMMENT '职位等级（1最高）',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '岗位说明',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态（1启用 0禁用）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_code` (`code`),
  UNIQUE KEY `uk_post_name` (`name`),
  KEY `idx_level` (`level`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='职位表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post`
--

LOCK TABLES `post` WRITE;
/*!40000 ALTER TABLE `post` DISABLE KEYS */;
INSERT INTO `post` VALUES (1,'总经理','GENERAL_MANAGER',1,10,'负责公司整体经营管理',1,'2026-06-30 17:08:08'),(2,'部门经理','DEPT_MANAGER',2,20,'负责部门整体业务',1,'2026-06-30 17:08:08'),(3,'部门主管','DEPT_SUPERVISOR',3,30,'负责班组及业务管理',1,'2026-06-30 17:08:08'),(4,'采购专员','PURCHASE_SPECIALIST',4,40,'负责农产品采购',1,'2026-06-30 17:08:08'),(5,'采购质检员','PURCHASE_QC',4,50,'负责采购验收',1,'2026-06-30 17:08:08'),(6,'供应商专员','SUPPLIER_SPECIALIST',4,60,'负责供应商管理',1,'2026-06-30 17:08:08'),(7,'质检员','QUALITY_INSPECTOR',4,70,'负责品质检测',1,'2026-06-30 17:08:08'),(8,'仓库主管','WAREHOUSE_MANAGER',3,80,'负责仓库管理',1,'2026-06-30 17:08:08'),(9,'仓管员','WAREHOUSE_KEEPER',4,90,'负责出入库管理',1,'2026-06-30 17:08:08'),(10,'分拣员','SORTING_OPERATOR',4,100,'负责订单分拣',1,'2026-06-30 17:08:08'),(11,'包装员','PACKING_OPERATOR',4,110,'负责包装作业',1,'2026-06-30 17:08:08'),(12,'配送调度员','DISPATCHER',4,120,'负责配送调度',1,'2026-06-30 17:08:08'),(13,'司机','DRIVER',4,130,'负责运输配送',1,'2026-06-30 17:08:08'),(14,'配送员','DELIVERY_OPERATOR',4,140,'负责配送',1,'2026-06-30 17:08:08'),(15,'销售经理','SALES_MANAGER',2,150,'负责销售团队',1,'2026-06-30 17:08:08'),(16,'销售专员','SALES_SPECIALIST',4,160,'负责客户销售',1,'2026-06-30 17:08:08'),(17,'客服专员','CUSTOMER_SERVICE',4,170,'负责客户服务',1,'2026-06-30 17:08:08'),(18,'售后专员','AFTER_SALES',4,180,'负责售后处理',1,'2026-06-30 17:08:08'),(19,'会计','ACCOUNTANT',4,190,'负责财务核算',1,'2026-06-30 17:08:08'),(20,'出纳','CASHIER',4,200,'负责资金收付',1,'2026-06-30 17:08:08'),(21,'系统管理员','SYSTEM_ADMIN',3,210,'负责系统维护',1,'2026-06-30 17:08:08'),(22,'行政专员','ADMIN_SPECIALIST',4,220,'负责行政事务',1,'2026-06-30 17:08:08'),(23,'人事专员','HR_SPECIALIST',4,230,'负责人事管理',1,'2026-06-30 17:08:08');
/*!40000 ALTER TABLE `post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase`
--

DROP TABLE IF EXISTS `purchase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `bill_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '单据编号（规则如 PO + 日期 + 流水）',
  `supplier_id` bigint DEFAULT NULL COMMENT '关联供应商ID',
  `warehouse_id` int DEFAULT NULL COMMENT '入库目标仓库',
  `total_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '含税总金额',
  `status` tinyint DEFAULT NULL COMMENT '状态：0-草稿，1-待审核，2-已完成，3-已作废',
  `in_stock_time` datetime DEFAULT NULL COMMENT '实际入库时间（用于成本核算的截止点）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `confirm_time` datetime DEFAULT NULL COMMENT '确认时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='采购订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase`
--

LOCK TABLES `purchase` WRITE;
/*!40000 ALTER TABLE `purchase` DISABLE KEYS */;
INSERT INTO `purchase` VALUES (1,'PO20260414001',1,1,'15000.00',2,'2026-04-14 10:00:00',NULL,'2026-04-14 09:00:00','2026-04-14 09:00:00',NULL),(2,'PO20260414002',2,1,'25000.00',1,NULL,NULL,'2026-04-14 09:30:00','2026-04-14 09:30:00',NULL),(3,'PO20260414003',3,2,'8000.00',0,NULL,NULL,'2026-04-14 10:00:00','2026-04-14 10:00:00',NULL),(4,'PO20260414004',4,1,'35000.00',2,'2026-04-13 15:30:00',NULL,'2026-04-13 14:00:00','2026-04-13 15:30:00','2026-04-13 15:30:00'),(5,'PO20260414005',5,2,'12000.00',2,'2026-04-12 11:00:00',NULL,'2026-04-12 10:00:00','2026-04-12 11:00:00','2026-04-12 11:00:00');
/*!40000 ALTER TABLE `purchase` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_inbound`
--

DROP TABLE IF EXISTS `purchase_inbound`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_inbound` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '入库单ID',
  `purchase_id` int NOT NULL COMMENT '关联采购订单ID',
  `bill_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '入库单号',
  `warehouse_id` int unsigned DEFAULT NULL COMMENT '入库仓库ID',
  `status` tinyint DEFAULT '0' COMMENT '状态：0-待确认，1-已确认',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `confirm_time` datetime DEFAULT NULL COMMENT '确认时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_bill_no` (`bill_no`) USING BTREE,
  KEY `idx_purchase_id` (`purchase_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='采购入库单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_inbound`
--

LOCK TABLES `purchase_inbound` WRITE;
/*!40000 ALTER TABLE `purchase_inbound` DISABLE KEYS */;
INSERT INTO `purchase_inbound` VALUES (1,1,'IB20260414001',1,1,'芒果入库完成','2026-04-14 10:00:00','2026-04-14 10:30:00'),(2,4,'IB20260413001',1,1,'智利车厘子等入库','2026-04-13 15:30:00','2026-04-13 16:00:00'),(3,5,'IB20260412001',2,1,'饮料类入库','2026-04-12 11:00:00','2026-04-12 11:30:00');
/*!40000 ALTER TABLE `purchase_inbound` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_inbound_item`
--

DROP TABLE IF EXISTS `purchase_inbound_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_inbound_item` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '入库明细ID',
  `inbound_id` bigint unsigned NOT NULL COMMENT '入库单ID',
  `purchase_item_id` bigint unsigned DEFAULT NULL COMMENT '采购明细ID',
  `goods_id` int unsigned NOT NULL COMMENT '商品ID',
  `quantity` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '入库数量',
  `unit_price` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '入库单价',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_inbound_id` (`inbound_id`) USING BTREE,
  KEY `idx_goods_id` (`goods_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='采购入库明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_inbound_item`
--

LOCK TABLES `purchase_inbound_item` WRITE;
/*!40000 ALTER TABLE `purchase_inbound_item` DISABLE KEYS */;
INSERT INTO `purchase_inbound_item` VALUES (1,1,1,1,500.00,30.00),(2,2,7,4,150.00,120.00),(3,2,8,6,500.00,16.00),(4,2,9,3,300.00,25.00),(5,3,10,9,200.00,7.50),(6,3,11,11,100.00,42.00),(7,3,12,12,100.00,38.00),(8,3,13,13,100.00,14.00);
/*!40000 ALTER TABLE `purchase_inbound_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_item`
--

DROP TABLE IF EXISTS `purchase_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_item` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `purchase_id` int NOT NULL COMMENT '采购订单ID',
  `goods_id` int unsigned NOT NULL COMMENT '商品ID',
  `quantity` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '数量',
  `unit_price` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '单价',
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT '金额',
  `sort_no` int DEFAULT '0' COMMENT '排序号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_purchase_id` (`purchase_id`) USING BTREE,
  KEY `idx_goods_id` (`goods_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='采购明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_item`
--

LOCK TABLES `purchase_item` WRITE;
/*!40000 ALTER TABLE `purchase_item` DISABLE KEYS */;
INSERT INTO `purchase_item` VALUES (1,1,1,500.00,30.00,15000.00,1),(2,2,2,200.00,80.00,16000.00,1),(3,2,5,300.00,30.00,9000.00,2),(4,3,7,1000.00,2.80,2800.00,1),(5,3,8,1000.00,2.80,2800.00,2),(6,3,10,2000.00,0.90,1800.00,3),(7,4,4,150.00,120.00,18000.00,1),(8,4,6,500.00,16.00,8000.00,2),(9,4,3,300.00,25.00,7500.00,3),(10,5,9,200.00,7.50,1500.00,1),(11,5,11,100.00,42.00,4200.00,2),(12,5,12,100.00,38.00,3800.00,3),(13,5,13,100.00,14.00,1400.00,4);
/*!40000 ALTER TABLE `purchase_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色名称',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色编码',
  `bio` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '角色简介',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
  `is_system` tinyint NOT NULL DEFAULT '0' COMMENT '是否系统角色（1是 0否）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态（1启用 0禁用）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`code`),
  UNIQUE KEY `uk_role_name` (`name`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,'超级管理员','SUPER_ADMIN','拥有系统全部权限',1,1,1,'2026-06-30 16:56:38'),(2,'系统管理员','SYSTEM_ADMIN','负责系统配置与用户权限管理',2,1,1,'2026-06-30 16:56:38'),(3,'采购管理员','PURCHASE_ADMIN','采购业务管理',10,0,1,'2026-06-30 16:56:38'),(4,'品质管理员','QUALITY_ADMIN','品质检测与食品安全管理',20,0,1,'2026-06-30 16:56:38'),(5,'仓储管理员','WAREHOUSE_ADMIN','仓储及库存管理',30,0,1,'2026-06-30 16:56:38'),(6,'销售管理员','SALES_ADMIN','销售订单及客户管理',40,0,1,'2026-06-30 16:56:38'),(7,'配送管理员','DELIVERY_ADMIN','配送及物流管理',50,0,1,'2026-06-30 16:56:38'),(8,'财务管理员','FINANCE_ADMIN','财务、应收应付管理',60,0,1,'2026-06-30 16:56:38'),(9,'综合管理','OFFICE_ADMIN','行政、人事、IT综合管理',70,0,1,'2026-06-30 16:56:38'),(10,'门店管理员','STORE_ADMIN','门店业务管理',80,0,1,'2026-06-30 16:56:38'),(11,'采购员','PURCHASE_USER','采购业务操作',100,0,1,'2026-06-30 16:56:38'),(12,'质检员','QUALITY_USER','来货检验、分级',110,0,1,'2026-06-30 16:56:38'),(13,'仓管员','WAREHOUSE_USER','出入库及库存操作',120,0,1,'2026-06-30 16:56:38'),(14,'销售员','SALES_USER','销售订单管理',130,0,1,'2026-06-30 16:56:38'),(15,'配送员','DELIVERY_USER','配送任务执行',140,0,1,'2026-06-30 16:56:38'),(16,'客服','CUSTOMER_SERVICE','售前售后服务',150,0,1,'2026-06-30 16:56:38'),(17,'财务人员','FINANCE_USER','财务业务处理',160,0,1,'2026-06-30 16:56:38'),(18,'普通员工','EMPLOYEE','基础业务权限',999,0,1,'2026-06-30 16:56:38');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permission`
--

DROP TABLE IF EXISTS `role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permission` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` int DEFAULT NULL,
  `permision_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permission`
--

LOCK TABLES `role_permission` WRITE;
/*!40000 ALTER TABLE `role_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_menu`
--

DROP TABLE IF EXISTS `role_menu`;
CREATE TABLE `role_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色菜单关联ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` int NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_menu` (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户角色菜单关联表';

--
-- Table structure for table `sal_order`
--

DROP TABLE IF EXISTS `sal_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sal_order` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号',
  `customer_id` bigint unsigned DEFAULT NULL COMMENT '客户ID',
  `warehouse_id` int unsigned DEFAULT NULL COMMENT '出库仓库ID',
  `order_date` datetime DEFAULT NULL COMMENT '订单日期',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '订单总额',
  `discount_amount` decimal(12,2) DEFAULT '0.00' COMMENT '折扣金额',
  `final_amount` decimal(12,2) DEFAULT '0.00' COMMENT '最终金额',
  `status` tinyint DEFAULT '0' COMMENT '状态：0-草稿，1-已确认，2-已完成，3-已作废',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `confirm_time` datetime DEFAULT NULL COMMENT '确认时间',
  `deliver_time` datetime DEFAULT NULL COMMENT '发货时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_order_no` (`order_no`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_created_at` (`created_at`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='销售订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sal_order`
--

LOCK TABLES `sal_order` WRITE;
/*!40000 ALTER TABLE `sal_order` DISABLE KEYS */;
INSERT INTO `sal_order` VALUES (1,'SO20260415001',1,1,'2026-04-15 09:00:00',5000.00,200.00,4800.00,1,'鲜丰水果店采购订单','admin','2026-04-15 09:00:00','2026-04-15 09:30:00','2026-04-15 09:30:00',NULL),(2,'SO20260415002',2,2,'2026-04-15 10:00:00',8000.00,500.00,7500.00,2,'百果园饮料采购','admin','2026-04-15 10:00:00','2026-04-15 14:00:00','2026-04-15 10:30:00','2026-04-15 14:00:00'),(3,'SO20260415003',3,1,'2026-04-15 11:00:00',15000.00,0.00,15000.00,1,'盒马鲜生批量采购','admin','2026-04-15 11:00:00','2026-04-15 11:00:00','2026-04-15 11:30:00',NULL),(4,'SO20260416001',4,2,'2026-04-16 08:00:00',3500.00,300.00,3200.00,0,'永辉超市零食采购','test','2026-04-16 08:00:00','2026-04-16 08:00:00',NULL,NULL),(5,'SO20260416002',1,1,'2026-04-16 09:00:00',12000.00,1000.00,11000.00,1,'鲜丰水果店追加订单','admin','2026-04-16 09:00:00','2026-04-16 09:00:00','2026-04-16 10:00:00',NULL);
/*!40000 ALTER TABLE `sal_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sal_order_item`
--

DROP TABLE IF EXISTS `sal_order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sal_order_item` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` bigint unsigned NOT NULL COMMENT '订单ID',
  `product_id` bigint unsigned DEFAULT NULL COMMENT '商品ID',
  `product_name_snapshot` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品名称快照',
  `price` decimal(12,2) DEFAULT '0.00' COMMENT '单价',
  `quantity` int DEFAULT '0' COMMENT '数量',
  `subtotal` decimal(12,2) DEFAULT '0.00' COMMENT '小计',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='销售订单明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sal_order_item`
--

LOCK TABLES `sal_order_item` WRITE;
/*!40000 ALTER TABLE `sal_order_item` DISABLE KEYS */;
INSERT INTO `sal_order_item` VALUES (1,1,1,'芒果',50.00,50,2500.00,'2026-04-15 09:00:00'),(2,1,3,'阿克苏苹果',45.00,30,1350.00,'2026-04-15 09:00:00'),(3,1,5,'红心火龙果',60.00,15,900.00,'2026-04-15 09:00:00'),(4,2,7,'可乐',5.00,500,2500.00,'2026-04-15 10:00:00'),(5,2,8,'雪碧',5.00,400,2000.00,'2026-04-15 10:00:00'),(6,2,9,'橙汁',15.00,150,2250.00,'2026-04-15 10:00:00'),(7,2,10,'农夫山泉',2.00,500,1000.00,'2026-04-15 10:00:00'),(8,3,4,'智利车厘子',200.00,40,8000.00,'2026-04-15 11:00:00'),(9,3,6,'脐橙',35.00,200,7000.00,'2026-04-15 11:00:00'),(10,4,11,'开心果',80.00,20,1600.00,'2026-04-16 08:00:00'),(11,4,12,'腰果',75.00,20,1500.00,'2026-04-16 08:00:00'),(12,5,1,'芒果',50.00,100,5000.00,'2026-04-16 09:00:00'),(13,5,2,'榴莲',150.00,30,4500.00,'2026-04-16 09:00:00'),(14,5,4,'智利车厘子',200.00,10,2000.00,'2026-04-16 09:00:00');
/*!40000 ALTER TABLE `sal_order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale_outbound`
--

DROP TABLE IF EXISTS `sale_outbound`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale_outbound` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '出库单ID',
  `sale_order_id` bigint unsigned NOT NULL COMMENT '关联销售订单ID',
  `bill_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '出库单号',
  `warehouse_id` int unsigned DEFAULT NULL COMMENT '出库仓库ID',
  `status` tinyint DEFAULT '0' COMMENT '状态：0-待确认，1-已确认',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `confirm_time` datetime DEFAULT NULL COMMENT '确认时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_bill_no` (`bill_no`) USING BTREE,
  KEY `idx_sale_order_id` (`sale_order_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='销售出库单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale_outbound`
--

LOCK TABLES `sale_outbound` WRITE;
/*!40000 ALTER TABLE `sale_outbound` DISABLE KEYS */;
INSERT INTO `sale_outbound` VALUES (1,1,'OB20260415001',1,1,'鲜丰水果店发货','2026-04-15 10:00:00','2026-04-15 10:30:00'),(2,2,'OB20260415002',2,1,'百果园饮料发货','2026-04-15 14:00:00','2026-04-15 14:30:00'),(3,3,'OB20260415003',1,0,'盒马鲜生待发货','2026-04-15 12:00:00',NULL);
/*!40000 ALTER TABLE `sale_outbound` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale_outbound_item`
--

DROP TABLE IF EXISTS `sale_outbound_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale_outbound_item` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '出库明细ID',
  `outbound_id` bigint unsigned NOT NULL COMMENT '出库单ID',
  `sale_order_item_id` bigint unsigned DEFAULT NULL COMMENT '订单明细ID',
  `product_id` bigint unsigned DEFAULT NULL COMMENT '商品ID',
  `quantity` int DEFAULT '0' COMMENT '出库数量',
  `price` decimal(12,2) DEFAULT '0.00' COMMENT '出库单价',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_outbound_id` (`outbound_id`) USING BTREE,
  KEY `idx_product_id` (`product_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='销售出库明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale_outbound_item`
--

LOCK TABLES `sale_outbound_item` WRITE;
/*!40000 ALTER TABLE `sale_outbound_item` DISABLE KEYS */;
INSERT INTO `sale_outbound_item` VALUES (1,1,1,1,50,50.00),(2,1,2,3,30,45.00),(3,1,3,5,15,60.00),(4,2,4,7,500,5.00),(5,2,5,8,400,5.00),(6,2,6,9,150,15.00),(7,2,7,10,500,2.00);
/*!40000 ALTER TABLE `sale_outbound_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sign_record`
--

DROP TABLE IF EXISTS `sign_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sign_record` (
  `sid` int NOT NULL AUTO_INCREMENT,
  `uid` int NOT NULL COMMENT '用户ID',
  `sign_in_time` datetime DEFAULT NULL COMMENT '签到时间',
  `sign_out_time` datetime DEFAULT NULL COMMENT '签退时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `sign_in_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `sign_out_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`sid`) USING BTREE,
  KEY `idx_user_id` (`uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='签到记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sign_record`
--

LOCK TABLES `sign_record` WRITE;
/*!40000 ALTER TABLE `sign_record` DISABLE KEYS */;
INSERT INTO `sign_record` VALUES (87,1,'2026-03-27 09:55:17','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','准时','早退'),(88,1,'2026-03-27 10:12:05','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(89,1,'2026-03-27 10:12:06','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(90,1,'2026-03-27 10:12:07','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(91,1,'2026-03-27 10:12:08','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(92,1,'2026-03-27 10:12:09','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(93,1,'2026-03-27 10:12:10','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(94,1,'2026-03-27 10:12:11','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(95,1,'2026-03-27 10:12:12','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(96,3,'2026-03-27 10:12:13','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(98,1,'2026-03-30 12:10:14','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(107,1,'2026-04-01 17:36:17','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(108,1,'2026-04-02 09:39:12','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(109,1,'2026-04-02 12:12:38','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(110,2,'2026-04-02 16:51:46','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(113,2,'2026-04-03 17:53:48','2026-04-03 17:53:50',NULL,'2026-04-03 17:53:48','迟到','早退'),(114,1,'2026-04-07 09:28:00',NULL,NULL,'2026-04-07 09:43:00','准时',NULL);
/*!40000 ALTER TABLE `sign_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplier` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '供应商ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '供应商编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '供应商名称',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '供应商类型',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '邮箱',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '地址',
  `bank_account` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '银行账号',
  `bank_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '开户银行',
  `tax_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '税人识别号',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_code` (`code`) USING BTREE,
  UNIQUE KEY `uk_supplier_code` (`code`) USING BTREE,
  KEY `idx_supplier_name` (`name`) USING BTREE,
  KEY `idx_supplier_contact_person` (`contact_person`) USING BTREE,
  KEY `idx_supplier_phone` (`phone`) USING BTREE,
  KEY `idx_supplier_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='供应商表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier`
--

LOCK TABLES `supplier` WRITE;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
INSERT INTO `supplier` VALUES (1,'S001','海南芒果农场',NULL,'陈经理','13912340001','chen@mango-farm.com','海南省三亚市海棠区芒果园1号','6222021234567890',NULL,'91460000MA5TWX1234',1,'2026-04-10 08:00:00','2026-04-10 08:00:00'),(2,'S002','泰国榴莲进口公司',NULL,'Mr.Somchai','13912340002','somchai@thai-durian.com','泰国曼谷辉煌区榴莲街88号','6222021234567891',NULL,'91410000MA5TWX5678',1,'2026-04-10 09:00:00','2026-04-10 09:00:00'),(3,'S003','新疆阿克苏苹果基地',NULL,'李场长','13912340003','li@xj-apple.com','新疆阿克苏市红富士路200号','6222021234567892',NULL,'91652900MA5TWX9012',1,'2026-04-11 10:00:00','2026-04-11 10:00:00'),(4,'S004','智利车厘子合作社',NULL,'Carlos','13912340004','carlos@chile-cherry.com','智利圣地亚哥市樱桃谷农场','6222021234567893',NULL,'91765000MA5TWX3456',1,'2026-04-12 08:30:00','2026-04-12 08:30:00'),(5,'S005','越南火龙果供应商',NULL,'Nguyen Thi Lan','13912340005','lan@vietnam-dragon.com','越南胡志明市火龙果产区','6222021234567894',NULL,'91811000MA5TWX7890',1,'2026-04-13 09:00:00','2026-04-13 09:00:00'),(6,'S006','江西赣南脐橙农场',NULL,'刘老板','13912340006','liu@gan-nan-orange.com','江西省赣州市安远县脐橙基地','6222021234567895',NULL,'91360700MA5TWX2468',0,'2026-04-14 10:00:00','2026-04-14 10:00:00');
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `uid` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `dept_id` bigint DEFAULT NULL COMMENT '部门ID',
  `dept_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `post_id` bigint DEFAULT NULL COMMENT '所属职位',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '所属职位',
  `role_id` bigint DEFAULT NULL COMMENT '角色ID',
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '角色名',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `bio` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `employed` int DEFAULT NULL COMMENT '在职状态 0:实习 1:试用 2:转正 3:离职',
  `join_date` datetime DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '启用',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `del_flag` int DEFAULT '0',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE KEY `unique_id` (`uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','$2a$10$TAaQrJuqFfcc8qx.ClKWDedN7QPFQaRFTuo2oMskPZsUqljjXMpqm','管理员','admin@test.com',47,'真理部',21,'部门经理',1,'超级管理员','14325345231','BioHazard 1',2,'2026-03-19 22:30:00','启用','2026-03-19 15:34:57','2026-07-27 08:37:47','/static/upload/avatars/1785138537821_avatar_1.jpg',0),(2,'test','$2a$10$hryPztoTlHka87cXAfXnfuA0m9RrDPqplsbdr4CoCS6PKkw69bQUq','test','test@test.test',12,'信息技术部',2,'部门经理',2,'系统管理员','12312312321','testste',2,'2026-03-21 00:00:00','启用','2026-03-21 15:35:05','2026-07-01 14:35:56','',0),(3,'test2','$2a$10$f2p9.WE7vc3rG/cbrmJt2O0ziouhfd4Ae.VwiIgrMBICjPcr/wvDi','特色t','test@test.com',12,'信息技术部',3,'部门主管',2,'系统管理员','15432432413','123',2,'2026-03-21 00:00:00','启用','2026-03-22 15:35:13','2026-06-30 17:28:31',NULL,0),(4,'test3','$2a$10$v7u7uktDVddIUpH8WUj71uzUqVvPughgFNjEWIYTG5mRqpKnuSbvm','test3','test@qqq.qwe',12,'信息技术部',21,'系统管理员',2,'系统管理员','15432432413',NULL,2,NULL,'启用','2026-03-22 15:35:13','2026-06-30 17:28:31',NULL,0),(5,'teststtst','$2a$10$x9kzxxdqvlePpNs0dOWPzef5GbQwbBBCv7RSUxj5IpzNqBsOPjLBG','teststtst','asd@123.com',12,'信息技术部',21,'系统管理员',2,'系统管理员','15432432413',NULL,2,NULL,'启用','2026-03-22 15:35:13','2026-06-30 17:28:31',NULL,0),(6,'A_User_For_TEST','$2a$10$ZHA7d7A02dEbJqfhMLx6GO.oMrrAjOVkVM6X9kZrByQo4V3j7v6Da','A_User_For_TEST','123@123.com',12,'信息技术部',19,'会计',9,'综合管理','12312312321','I Want to Play DeathStranding',2,'2026-03-21 00:00:00','启用','2026-03-22 15:35:13','2026-07-03 16:21:19',NULL,0),(7,'serser','$2a$10$NbEcx02Ca8ouQcy0lwsRc.BrQ2k7S9IGilWcmVZARSiodFpt1R5QO','serser','123@123.com',14,'应收管理',19,'会计',8,'财务管理员','14325345231','123',2,'2026-03-21 00:00:00','启用','2026-03-22 15:35:13','2026-07-03 16:21:19',NULL,0),(8,'1231231','$2a$10$IOwvt1PuvUO64U6SH.6q.ulW/vQhNvIG1XL6rZP/Mm/uO5YS/5Xxm','1231231','test@test.test',16,'成本核算',19,'会计',8,'财务管理员','15432432413',NULL,2,NULL,'启用','2026-03-22 15:35:13','2026-06-30 17:28:31',NULL,0),(9,'tetetetetet','$2a$10$AD.fqE07e/wcnM2Eg/uKc.nPd7tRGGk6YQivcTkqEmGpAATuwG2.i','tetetetetet','test@test.test',16,'成本核算',19,'会计',8,'财务管理员','15432432413',NULL,2,NULL,'启用','2026-03-23 15:35:31','2026-06-30 17:28:31',NULL,0),(10,'tetoteto','$2a$10$CCwRZmkRGXs2AuWOnG/3T.NyqNDv8D5Lefqozrw6F5hddpiOvQ7RK','tetoteto','teto@teto.com',21,'采购质检',5,'采购质检员',12,'质检员','15432432413',NULL,2,NULL,'启用','2026-03-23 15:35:34','2026-06-30 17:28:31',NULL,0),(13,'4141414','$2a$10$QNyZ1gB.fDgxsRMfuNX9DOCZZI5JdR2c3UUyooi8QUv.6UiZikI7m','4141414','Test@test.com',21,'采购质检',5,'采购质检员',12,'质检员','15432432413',NULL,2,NULL,'启用','2026-03-23 17:43:07','2026-06-30 17:28:31',NULL,0),(24,'42','$2a$10$K.dsblSk5bD4T33UEhMd6O/3.Xe3E7EndKV24RiS9SB4.QWiauIK.','42','test@test.com',21,'采购质检',5,'采购质检员',12,'质检员','14323453213','42',2,'2026-03-19 22:30:00','启用','2026-03-30 12:19:43','2026-06-30 17:28:31',NULL,0),(31,'123','$2a$10$PVJwGbD.na2jtwp4A/eIqerkgyBjZb29C9CK3XALk8eSfKzwp9kRe','123','test@test.com',22,'来货质检',NULL,NULL,12,'质检员','14323453214','43',2,'2026-03-20 22:30:00','启用','2026-04-01 15:28:33','2026-06-30 17:28:31',NULL,0),(32,'124','$2a$10$y0PhlevZzEgIrVZ5FHB1ge5bX43vDuXh1egNJGsUuFA55zbmzZ56y','124','test@test.com',22,'来货质检',NULL,NULL,12,'质检员','14323453215','44',2,'2026-03-21 22:30:00','启用','2026-04-01 15:28:33','2026-06-30 17:28:31',NULL,0),(33,'125','$2a$10$C1mV3qLobTFVbM87VM1TLuYJPDWpv38vyxb3BoKjwzLaABoP3XZF6','125','test@test.com',22,'来货质检',NULL,NULL,12,'质检员','14323453216','45',2,'2026-03-22 22:30:00','启用','2026-04-01 15:28:33','2026-06-30 17:28:31',NULL,0),(34,'126','$2a$10$P9kkQ0/sLcEQ3tk9AlMJkOvfIbmUm5hy8hj/wdCQ68nqzzBYvs2Dy','126','test@test.com',11,'行政部',19,'会计',9,'综合管理','14323453217','46',2,'2026-03-23 22:30:00','启用','2026-04-01 15:28:33','2026-06-30 17:28:31',NULL,0),(35,'127','$2a$10$yV41NqzlSI9ViTKXGOi5UOAjwvhHeaWx2sjJAHPxQJ9IcuEktUnaO','127','test@test.com',11,'行政部',20,'出纳',9,'综合管理','14323453218','47',2,'2026-03-24 22:30:00','启用','2026-04-01 15:28:33','2026-06-30 17:28:31',NULL,0),(36,'128','$2a$10$zRuP.d4C4E2FoCsznNo/VOSKNREe/4mXZgBycgnBkRu8ucjuXMO9S','128','test@test.com',10,'人力资源部',17,'客服专员',18,'普通员工','14323453219','48',2,'2026-03-25 22:30:00','启用','2026-04-01 15:28:33','2026-06-30 17:28:31',NULL,0),(40,'admin1','$2a$10$K1Cqk46hTkm663sDkShDhOfRogbrsJeMxYjiRunbGdFIC55V9XFlu','admin1','test@test.com',10,'人力资源部',NULL,NULL,18,'普通员工',NULL,NULL,2,NULL,'启用','2026-04-07 15:37:16','2026-06-30 17:28:31',NULL,0);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `warehouse`
--

DROP TABLE IF EXISTS `warehouse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouse` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT '仓库ID',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库编码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库名称',
  `kind` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '仓库类型',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '仓库地址',
  `manager` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '负责人',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '负责人电话',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态 0-停用 1-启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_code` (`code`) USING BTREE,
  UNIQUE KEY `uk_warehouse_code` (`code`) USING BTREE,
  KEY `idx_warehouse_name` (`name`) USING BTREE,
  KEY `idx_warehouse_kind` (`kind`) USING BTREE,
  KEY `idx_warehouse_status` (`status`) USING BTREE,
  KEY `idx_warehouse_status_time` (`status`,`create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='仓库表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `warehouse`
--

LOCK TABLES `warehouse` WRITE;
/*!40000 ALTER TABLE `warehouse` DISABLE KEYS */;
INSERT INTO `warehouse` VALUES (1,'F1',' 一号仓库','原料仓','不知道哪的一仓库','管理员','15421312341',1,'2026-04-13 16:28:46',0),(2,'F2','Test2','半成品仓','2号地址','Test2','13242134512',1,'2026-04-14 14:34:59',0);
/*!40000 ALTER TABLE `warehouse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'testdb'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-08 12:35:27
