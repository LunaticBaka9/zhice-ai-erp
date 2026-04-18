/*
 Navicat Premium Data Transfer

 Source Server         : mysql-5.7.26
 Source Server Type    : MySQL
 Source Server Version : 50726 (5.7.26)
 Source Host           : localhost:3306
 Source Schema         : testdb

 Target Server Type    : MySQL
 Target Server Version : 50726 (5.7.26)
 File Encoding         : 65001

 Date: 18/04/2026 15:49:31
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `parent_id` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '上级分类ID，0表示顶级',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id`) USING BTREE,
  INDEX `idx_category_parent_id`(`parent_id`) USING BTREE,
  INDEX `idx_category_name`(`name`) USING BTREE,
  INDEX `idx_category_sort_order`(`sort_order`) USING BTREE,
  INDEX `idx_category_parent_sort`(`parent_id`, `sort_order`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, 0, '水果', 0, '2026-04-13 15:38:31', '2026-04-15 12:50:06');
INSERT INTO `category` VALUES (3, 0, '饮料', 1, '2026-04-10 09:00:00', '2026-04-10 09:00:00');
INSERT INTO `category` VALUES (4, 3, '碳酸饮料', 0, '2026-04-10 09:30:00', '2026-04-10 09:30:00');
INSERT INTO `category` VALUES (5, 3, '果汁饮料', 1, '2026-04-10 09:30:00', '2026-04-10 09:30:00');
INSERT INTO `category` VALUES (6, 1, '热带水果', 1, '2026-04-11 10:00:00', '2026-04-11 10:00:00');
INSERT INTO `category` VALUES (7, 1, '苹果类', 2, '2026-04-11 10:30:00', '2026-04-11 10:30:00');
INSERT INTO `category` VALUES (8, 0, '零食', 2, '2026-04-12 08:00:00', '2026-04-12 08:00:00');
INSERT INTO `category` VALUES (9, 8, '坚果类', 0, '2026-04-12 08:30:00', '2026-04-12 08:30:00');
INSERT INTO `category` VALUES (10, 8, '糖果类', 1, '2026-04-12 08:30:00', '2026-04-12 08:30:00');

-- ----------------------------
-- Table structure for customer
-- ----------------------------
DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '客户ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户名称',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `price_level` tinyint(4) NULL DEFAULT 1 COMMENT '价格等级（1-零售价 2-批发价 3-VIP价）',
  `credit_limit` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '信用额度',
  `status` tinyint(1) NULL DEFAULT 1,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code`) USING BTREE,
  INDEX `idx_customer_name`(`name`) USING BTREE,
  INDEX `idx_customer_contact_person`(`contact_person`) USING BTREE,
  INDEX `idx_customer_phone`(`phone`) USING BTREE,
  INDEX `idx_customer_status`(`status`) USING BTREE,
  INDEX `idx_customer_status_id`(`status`, `id`) USING BTREE,
  INDEX `idx_customer_name_status`(`name`, `status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '客户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of customer
-- ----------------------------
INSERT INTO `customer` VALUES (1, 'C001', '鲜丰水果店', '张三', '13800138001', 'zhangsan@fresh.com', '杭州市西湖区文三路123号', 1, 50000.00, 1, '2026-04-10 09:30:00', '2026-04-10 09:30:00');
INSERT INTO `customer` VALUES (2, 'C002', '百果园', '李四', '13800138002', 'lisi@baiguoyuan.com', '上海市浦东新区世纪大道456号', 2, 100000.00, 1, '2026-04-10 10:00:00', '2026-04-10 10:00:00');
INSERT INTO `customer` VALUES (3, 'C003', '盒马鲜生', '王五', '13800138003', 'wangwu@hema.com', '北京市朝阳区建国路789号', 3, 200000.00, 1, '2026-04-11 09:00:00', '2026-04-11 09:00:00');
INSERT INTO `customer` VALUES (4, 'C004', '永辉超市', '赵六', '13800138004', 'zhaoliu@yonghui.com', '深圳市南山区科技园南路999号', 2, 150000.00, 1, '2026-04-11 14:00:00', '2026-04-11 14:00:00');
INSERT INTO `customer` VALUES (5, 'C005', '大润发', '钱七', '13800138005', 'qianqi@drtmart.com', '广州市天河区天河路1111号', 1, 80000.00, 0, '2026-04-12 11:00:00', '2026-04-12 11:00:00');

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SKU编码，全局唯一',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图片URL',
  `category_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '分类ID',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌',
  `spec` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '规格型号',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '个' COMMENT '基本单位',
  `barcode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主条码',
  `purchase_price` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '参考采购价',
  `sale_price` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '标准售价',
  `cost_price` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '当前移动加权平均成本',
  `stock_low` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '库存预警下限',
  `stock_high` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '库存预警上限',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `del_flag` int(255) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sku_code`(`sku_code`) USING BTREE,
  INDEX `idx_category_id`(`category_id`) USING BTREE,
  INDEX `idx_barcode`(`barcode`) USING BTREE,
  INDEX `idx_goods_name`(`name`) USING BTREE,
  INDEX `idx_goods_brand`(`brand`) USING BTREE,
  INDEX `idx_goods_category_id`(`category_id`) USING BTREE,
  INDEX `idx_goods_barcode`(`barcode`) USING BTREE,
  INDEX `idx_goods_category_status_time`(`category_id`, `del_flag`, `create_time`) USING BTREE,
  INDEX `idx_goods_spec`(`spec`) USING BTREE,
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES (1, 'FR001', '芒果', NULL, 6, '海南农场', '50个/箱', '箱', '690123456789', 30.00, 50.00, 35.00, 10.00, 200.00, '2026-04-13 15:55:11', '2026-04-15 21:34:54', 0);
INSERT INTO `goods` VALUES (2, 'FR002', '榴莲', NULL, 6, '泰国进口', '500g~/个', '个', '690123456790', 80.00, 150.00, 85.00, 5.00, 50.00, '2026-04-13 17:47:14', '2026-04-15 17:38:36', 0);
INSERT INTO `goods` VALUES (3, 'FR003', '阿克苏苹果', NULL, 7, '新疆基地', '50个/箱', '箱', '690123456791', 25.00, 45.00, 28.00, 20.00, 300.00, '2026-04-10 09:30:00', '2026-04-15 17:37:36', 0);
INSERT INTO `goods` VALUES (4, 'FR004', '智利车厘子', NULL, 6, '智利进口', '50个/箱', '箱', '690123456792', 120.00, 200.00, 130.00, 10.00, 100.00, '2026-04-11 10:00:00', '2026-04-15 17:37:38', 0);
INSERT INTO `goods` VALUES (5, 'FR005', '红心火龙果', NULL, 6, '越南进口', '50个/箱', '箱', '690123456793', 35.00, 60.00, 38.00, 15.00, 150.00, '2026-04-11 11:00:00', '2026-04-15 17:37:40', 0);
INSERT INTO `goods` VALUES (6, 'FR006', '脐橙', NULL, 7, '赣南农场', '50个/箱', '箱', '690123456794', 18.00, 35.00, 20.00, 30.00, 400.00, '2026-04-12 08:00:00', '2026-04-15 17:37:44', 0);
INSERT INTO `goods` VALUES (7, 'DR001', '可乐', NULL, 4, '可口可乐', '500ml/瓶', '瓶', '690123456795', 3.00, 5.00, 3.50, 50.00, 500.00, '2026-04-10 09:00:00', '2026-04-15 22:41:16', 0);
INSERT INTO `goods` VALUES (8, 'DR002', '雪碧', NULL, 4, '可口可乐', '500ml/瓶', '瓶', '690123456796', 3.00, 5.00, 3.50, 50.00, 500.00, '2026-04-10 09:00:00', '2026-04-15 17:37:54', 0);
INSERT INTO `goods` VALUES (9, 'DR003', '橙汁', NULL, 5, '汇源', '250ml/盒', '盒', '690123456797', 8.00, 15.00, 9.00, 30.00, 200.00, '2026-04-10 10:00:00', '2026-04-15 17:38:29', 0);
INSERT INTO `goods` VALUES (10, 'DR004', '农夫山泉', NULL, 3, '农夫山泉', '500ml/瓶', '瓶', '690123456798', 1.00, 2.00, 1.20, 100.00, 1000.00, '2026-04-10 10:00:00', '2026-04-15 17:37:56', 0);
INSERT INTO `goods` VALUES (11, 'SN001', '开心果', NULL, 9, '加州农场', '500g/袋', '袋', '690123456799', 45.00, 80.00, 50.00, 20.00, 150.00, '2026-04-12 08:30:00', '2026-04-15 17:38:08', 0);
INSERT INTO `goods` VALUES (12, 'SN002', '腰果', NULL, 9, '越南进口', '500g/袋', '袋', '690123456800', 40.00, 75.00, 45.00, 20.00, 150.00, '2026-04-12 08:30:00', '2026-04-15 17:38:13', 0);
INSERT INTO `goods` VALUES (13, 'SN003', '大白兔奶糖', NULL, 10, '冠生园', '500g/袋', '袋', '690123456801', 15.00, 25.00, 18.00, 50.00, 400.00, '2026-04-12 09:00:00', '2026-04-15 17:38:16', 0);
INSERT INTO `goods` VALUES (15, 'DR007', '007', NULL, 5, '', '500ml/瓶', '瓶', '690123456802', 0.00, 0.00, 0.00, 0.00, 0.00, '2026-04-15 16:59:11', '2026-04-15 17:36:26', 0);

-- ----------------------------
-- Table structure for inventory
-- ----------------------------
DROP TABLE IF EXISTS `inventory`;
CREATE TABLE `inventory`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `goods_id` int(10) UNSIGNED NOT NULL COMMENT '商品ID',
  `warehouse_id` int(10) UNSIGNED NOT NULL COMMENT '仓库ID',
  `location` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '默认库位',
  `batch_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '批次号（非批次商品为空字符串）',
  `qty_on_hand` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '在手量（实际物理库存）',
  `qty_available` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '可用量（在手量 - 锁定量）',
  `locked_qty` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '销售订单锁定数量',
  `total_cost` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '库存总成本',
  `last_inbound_time` datetime NULL DEFAULT NULL COMMENT '最后入库时间',
  `last_outbound_time` datetime NULL DEFAULT NULL COMMENT '最后出库时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` int(11) NULL DEFAULT NULL COMMENT '创建人 ID',
  `update_by` int(11) NULL DEFAULT NULL COMMENT '更新人 ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_inventory_goods_warehouse`(`goods_id`, `warehouse_id`) USING BTREE,
  UNIQUE INDEX `uk_inventory`(`goods_id`, `warehouse_id`, `batch_no`) USING BTREE,
  INDEX `idx_inventory_goods_id`(`goods_id`) USING BTREE,
  INDEX `idx_inventory_warehouse_id`(`warehouse_id`) USING BTREE,
  INDEX `idx_inventory_qty_on_hand`(`qty_on_hand`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存快照表（实时库存）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of inventory
-- ----------------------------
INSERT INTO `inventory` VALUES (1, 1, 1, 'A-1', '1', 95.00, 95.00, 0.00, 2850.00, '2026-04-14 11:17:57', '2026-04-18 13:43:12', '2026-04-14 11:17:12', '2026-04-18 13:43:12', NULL, NULL);
INSERT INTO `inventory` VALUES (2, 2, 1, 'A-2', '1', 20.00, 20.00, 0.00, 1700.00, '2026-04-13 14:00:00', NULL, '2026-04-14 09:00:00', '2026-04-14 09:30:00', NULL, NULL);
INSERT INTO `inventory` VALUES (3, 3, 1, 'B-1', '1', 150.00, 150.00, 10.00, 4200.00, '2026-04-12 10:00:00', NULL, '2026-04-13 16:00:00', '2026-04-14 10:00:00', NULL, NULL);
INSERT INTO `inventory` VALUES (4, 4, 1, 'A-3', '1', 30.00, 30.00, 0.00, 3900.00, '2026-04-11 11:00:00', NULL, '2026-04-14 08:00:00', '2026-04-14 11:00:00', NULL, NULL);
INSERT INTO `inventory` VALUES (5, 5, 1, 'A-4', '1', 80.00, 80.00, 0.00, 3040.00, '2026-04-11 12:00:00', NULL, '2026-04-14 10:00:00', '2026-04-14 12:00:00', NULL, NULL);
INSERT INTO `inventory` VALUES (6, 6, 1, 'B-2', '2', 200.00, 200.00, 0.00, 4000.00, '2026-04-12 09:00:00', NULL, '2026-04-13 15:00:00', '2026-04-14 08:00:00', NULL, NULL);
INSERT INTO `inventory` VALUES (7, 7, 2, 'C-1', '1', 300.00, 280.00, 20.00, 1050.00, '2026-04-10 10:00:00', NULL, '2026-04-14 11:00:00', '2026-04-14 14:00:00', NULL, NULL);
INSERT INTO `inventory` VALUES (8, 8, 2, 'C-2', '1', 250.00, 250.00, 0.00, 875.00, '2026-04-10 10:00:00', NULL, '2026-04-14 11:00:00', '2026-04-14 14:00:00', NULL, NULL);
INSERT INTO `inventory` VALUES (9, 9, 2, 'D-1', '1', 120.00, 120.00, 0.00, 1080.00, '2026-04-10 11:00:00', NULL, '2026-04-13 14:00:00', '2026-04-14 09:00:00', NULL, NULL);
INSERT INTO `inventory` VALUES (10, 10, 2, 'D-2', '1', 600.00, 600.00, 0.00, 720.00, '2026-04-10 11:00:00', NULL, '2026-04-14 08:00:00', '2026-04-14 10:00:00', NULL, NULL);
INSERT INTO `inventory` VALUES (11, 1, 2, NULL, '', 1.00, 1.00, 0.00, 0.00, '2026-04-18 13:42:20', NULL, '2026-04-18 13:42:19', '2026-04-18 13:42:19', NULL, NULL);

-- ----------------------------
-- Table structure for inventory_alert
-- ----------------------------
DROP TABLE IF EXISTS `inventory_alert`;
CREATE TABLE `inventory_alert`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '预警ID',
  `goods_id` bigint(20) UNSIGNED NOT NULL COMMENT '商品ID',
  `goods_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
  `sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SKU编码',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌',
  `spec` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '规格型号',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '个' COMMENT '单位',
  `stock_quantity` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '当前库存数量',
  `stock_low` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '库存预警下限',
  `stock_high` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '库存预警上限',
  `alert_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '预警类型：out_of_stock-缺货，low_stock-库存不足，high_stock-库存过多，expiring_soon-即将到期',
  `alert_level` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '预警级别：high-高，medium-中，low-低',
  `acknowledged` tinyint(1) NULL DEFAULT 0 COMMENT '是否已确认：0-未确认，1-已确认',
  `acknowledged_by` int(11) NULL DEFAULT NULL COMMENT '确认人ID',
  `acknowledged_time` datetime NULL DEFAULT NULL COMMENT '确认时间',
  `days_to_expiry` int(11) NULL DEFAULT NULL COMMENT '到期天数',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_goods_id`(`goods_id`) USING BTREE,
  INDEX `idx_sku_code`(`sku_code`) USING BTREE,
  INDEX `idx_alert_type`(`alert_type`) USING BTREE,
  INDEX `idx_alert_level`(`alert_level`) USING BTREE,
  INDEX `idx_acknowledged`(`acknowledged`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存预警表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of inventory_alert
-- ----------------------------
INSERT INTO `inventory_alert` VALUES (1, 1, '芒果', 'FR001', '我不到啊', 'FR-01', '箱', 100.00, 10.00, 200.00, 'low_stock', 'medium', 0, NULL, NULL, NULL, '2026-04-14 12:00:00', '2026-04-14 12:00:00');
INSERT INTO `inventory_alert` VALUES (2, 2, 'TEst', 'FR002', 'ste', 'tewst', '箱', 8.00, 10.00, 100.00, 'out_of_stock', 'high', 0, NULL, NULL, NULL, '2026-04-14 13:00:00', '2026-04-14 13:00:00');

-- ----------------------------
-- Table structure for inventory_operation
-- ----------------------------
DROP TABLE IF EXISTS `inventory_operation`;
CREATE TABLE `inventory_operation`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '作业 ID',
  `operation_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作业单号',
  `operation_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作业类型：inbound-入库，outbound-出库，transfer-调拨，adjustment-盘点',
  `from_warehouse_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '源仓库 ID（出库/调拨时有值）',
  `from_warehouse_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '源仓库名称（冗余字段，方便查询）',
  `to_warehouse_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '目标仓库 ID（入库/调拨时有值）',
  `to_warehouse_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '目标仓库名称（冗余字段，方便查询）',
  `goods_id` int(10) UNSIGNED NOT NULL COMMENT '商品 ID',
  `goods_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称（冗余字段，方便查询）',
  `sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SKU 编码（冗余字段，方便查询）',
  `quantity` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '作业数量',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '单位',
  `operator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作员',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'pending' COMMENT '状态：pending-待处理，completed-已完成，cancelled-已取消',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源类型：purchase-采购，sales-销售，manual-手工',
  `source_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源单号（关联采购单/销售单等）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `create_by` int(11) NULL DEFAULT NULL COMMENT '创建人 ID',
  `update_by` int(11) NULL DEFAULT NULL COMMENT '更新人 ID',
  `del_flag` tinyint(1) NOT NULL DEFAULT 0 COMMENT '删除标志：0-未删除，1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_operation_no`(`operation_no`) USING BTREE,
  INDEX `idx_operation_type`(`operation_type`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_goods_id`(`goods_id`) USING BTREE,
  INDEX `idx_from_warehouse`(`from_warehouse_id`) USING BTREE,
  INDEX `idx_to_warehouse`(`to_warehouse_id`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE,
  INDEX `idx_inv_op_operation_no`(`operation_no`) USING BTREE,
  INDEX `idx_inv_op_goods_id`(`goods_id`) USING BTREE,
  INDEX `idx_inv_op_operation_type`(`operation_type`) USING BTREE,
  INDEX `idx_inv_op_status`(`status`) USING BTREE,
  INDEX `idx_inv_op_create_time`(`create_time`) USING BTREE,
  INDEX `idx_inv_op_goods_warehouse_time`(`goods_id`, `from_warehouse_id`, `create_time`) USING BTREE,
  INDEX `idx_inv_op_source_no`(`source_no`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '库存作业表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of inventory_operation
-- ----------------------------
INSERT INTO `inventory_operation` VALUES (1, 'WH1776155534114', 'inbound', NULL, NULL, 1, '一号仓库', 1, '苹果', 'APL001', 5.00, '个', 'Test', 'completed', '', 'manual', NULL, '2026-04-14 16:32:30', '2026-04-14 17:14:26', '2026-04-14 17:14:24', NULL, NULL, 0);
INSERT INTO `inventory_operation` VALUES (2, 'WH1776156962129', 'transfer', 1, '一号仓库', 2, '二号仓库', 1, '苹果', 'APL001', 2.00, '个', 'Test', 'cancelled', '', 'manual', NULL, '2026-04-14 16:56:16', '2026-04-14 17:14:31', '2026-04-14 17:14:27', NULL, NULL, 0);
INSERT INTO `inventory_operation` VALUES (3, 'WH1776157025744', 'outbound', 1, '一号仓库', NULL, NULL, 1, '苹果', 'APL001', 1.00, '个', 'Test', 'completed', '', 'manual', NULL, '2026-04-14 16:57:16', '2026-04-14 16:57:21', NULL, NULL, NULL, 0);
INSERT INTO `inventory_operation` VALUES (4, 'WH1776157051705', 'adjustment', 1, '一号仓库', 1, '一号仓库', 1, '苹果', 'APL001', 5.00, '个', 'TEST', 'completed', '', 'manual', NULL, '2026-04-14 16:57:48', '2026-04-14 17:14:15', '2026-04-14 17:14:15', NULL, NULL, 0);
INSERT INTO `inventory_operation` VALUES (5, 'PI1776490939793345', 'inbound', NULL, NULL, 2, 'Test2', 1, '芒果', 'FR001', 1.00, '箱', '系统', 'completed', '采购入库', 'purchase', 'RK17764909356962647', '2026-04-18 13:42:19', '2026-04-18 13:42:19', '2026-04-18 13:42:20', NULL, NULL, 0);
INSERT INTO `inventory_operation` VALUES (6, 'XO1776490992615674', 'outbound', 1, ' 一号仓库', NULL, NULL, 1, '芒果', 'FR001', 5.00, '箱', '系统', 'completed', '销售出库', 'sales', 'CK17764909863291506', '2026-04-18 13:43:12', '2026-04-18 13:43:12', '2026-04-18 13:43:13', NULL, NULL, 0);

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `nid` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NULL DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `publishDate` datetime NULL DEFAULT NULL,
  `views` int(255) NULL DEFAULT 0,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `attachments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  PRIMARY KEY (`nid`) USING BTREE,
  INDEX `idx_publishDate_status`(`publishDate`, `status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (2, 2, 'TESTt', 'test', '系统更新', NULL, '<p>I do not kown</p>', '2026-04-02 17:12:31', 48, '已发布', NULL);
INSERT INTO `notice` VALUES (3, 1, '123123123', '管理员', '维护通知', NULL, '***************************\r\nAPPLICATION FAILED TO START\r\n***************************\r\nDescription:\r\nFailed to configure a DataSource: \'url\' attribute is not specified and no embedded datasource could be configured.\r\nReason: Failed to determine a suitable driver class\r\nAction:\r\n///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////', '2026-03-31 16:25:57', 45, '已发布', NULL);
INSERT INTO `notice` VALUES (4, 1, '鹰峰同学请穿上衣服', '管理员', '其他公告', NULL, '普通学生白田无意中发现校园女神鹰峰同学拥有通过脱下内裤来穿越时空、改变因果的超能力。为了能够随心所欲地使用这个能力，鹰峰设计陷害白田使其成为内衣柜，从而引发了一系列搞笑且充满奇幻色彩的故事。', '2026-03-31 17:09:38', 69, '已发布', NULL);
INSERT INTO `notice` VALUES (5, 1, '黑执事 -绿之魔女篇', '管理员', '其他公告', NULL, '奉女王之命前往德国调查离奇死亡事件的塞巴斯蒂安与西雅尔。在探查踏入者即遭咒杀的\"人狼之森\"真相时，骇人诅咒正向二人倾泻而下――。 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', '2026-03-31 17:10:34', 70, '已发布', NULL);
INSERT INTO `notice` VALUES (6, 1, 'DORO', '管理员', '其他公告', NULL, 'doro,doro?Doro!DORO!', '2026-04-01 10:19:44', 54, '已发布', NULL);
INSERT INTO `notice` VALUES (7, 1, '整点整点', '管理员', '功能上线', NULL, '上码头整点薯条去', '2026-04-01 11:28:58', 104, '已发布', NULL);
INSERT INTO `notice` VALUES (8, 1, '我想玩死亡搁浅2', '管理员', '维护通知', NULL, '哎呀，送货送到一半我的F5节点都还没有接通', '2026-04-01 11:30:17', 137, '已发布', NULL);
INSERT INTO `notice` VALUES (9, 1, 'OTSUPEKO！', '管理员', '系统更新', 'PEKORA!', 'KONPEKO！', '2026-04-01 11:30:00', 1319, '已发布', NULL);
INSERT INTO `notice` VALUES (10, 1, '今天是TETO的生日', '管理员', '维护通知', '今天是TETO的生日', '今天是愚人节，也是TETO的生日，但是还得上班', '2026-04-01 11:30:00', 3, '已发布', NULL);
INSERT INTO `notice` VALUES (12, 1, 'ImportTest', '管理员', '功能上线', '测试', '测试一下导入', '2026-04-01 18:31:13', 10, '已发布', NULL);
INSERT INTO `notice` VALUES (15, 1, 'asdfasdfsadfsadf', '管理员', '系统更新', NULL, '<h1><em>asdfadsfsadfsad</em></h1><p>asdfadsfasdfsadfsadfasdfasdf</p>', '2026-04-02 10:46:44', 6, '已发布', NULL);
INSERT INTO `notice` VALUES (16, 1, '测试公告发布', '管理员', '功能上线', '测试富文本编辑', '<h1>测试一下<span style=\"color: rgb(207, 19, 34);\"><em>富文本</em></span>编辑</h1><blockquote>世界上多数的话，大体都是我说的吧 &nbsp; &nbsp;——鲁迅</blockquote><div data-w-e-type=\"todo\"><input type=\"checkbox\" disabled >整点怪东西</div><ul><li>test1</li><li style=\"text-align: center;\">test2</li></ul><ol><li>1</li><li>2</li></ol><p>👻👻👍👍👍👍👍👍👍👍👍🤘🤘👌👌✌️✌️✊✊🤛🤝👍👍👍👍</p><p><br></p>', '2026-04-02 10:54:34', 19, '已发布', NULL);
INSERT INTO `notice` VALUES (18, 1, 'asdfasdfadsf', '管理员', '系统更新', 'asdfasdfdsaf', '<h1><span style=\"font-size: 40px;\"><u><em><strong>asdfasdfadsf</strong></em></u></span><u><em><strong>🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣</strong></em></u></h1><p style=\"text-align: right;\">asdfasdf</p><table style=\"width: auto;\"><tbody><tr><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">111</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">111</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">2323</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">1231231</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">a\'s\'d\'f</td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr></tbody></table><p><br></p>', '2026-04-02 15:29:15', 15, '已发布', NULL);
INSERT INTO `notice` VALUES (19, 1, 'asdfasdfadsf', '管理员', '其他公告', '123123123', '<p>🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏👍👍👍👍👍👍👍👍👍👍😤😤😤😤😤😤😤😤😤</p>', '2026-04-02 15:50:27', 41, '已发布', NULL);
INSERT INTO `notice` VALUES (20, 2, '尝试用别的账号进行一个发布', 'test', '系统更新', '', '<ul><li>WAAAAAAAAA</li><li>:-D</li><li>:-)</li></ul>', '2026-04-02 16:50:07', 6, '已发布', NULL);
INSERT INTO `notice` VALUES (21, 2, '!!!!!!', 'test', '系统更新', '', '<p>😍😍😍😍😍😍😍😍😍😘😘😘😘😘😘😘😋😋😋😋😋😋😋</p>', '2026-04-02 16:54:29', 6, '已发布', NULL);
INSERT INTO `notice` VALUES (22, 2, '测试定时发布', 'test', '系统更新', '', '<p>啊手动阀手动阀手动阀</p>', '2026-04-03 09:50:00', 8, '已发布', '');
INSERT INTO `notice` VALUES (23, 1, '测试附件发布', '管理员', '功能上线', '', '<p>测试上传附件</p><p>👍👍👍👍👍👍👍👍👍👍😍😍😍😍😍😍😍😍😍</p>', '2026-04-03 15:03:05', 12, '已发布', '');
INSERT INTO `notice` VALUES (24, 1, '写点啥，', '管理员', '维护通知', '', '<blockquote>12332112345677654321</blockquote><p><span style=\"color: rgb(0, 0, 0); background-color: rgb(0, 0, 0); font-size: 48px; font-family: 微软雅黑;\"><s><u><em><strong>写点东西试试，反正就是写点玩意</strong></em></u></s></span></p><p><a href=\"https://www.bilibili.com\" target=\"_blank\"><u>asdfasdf &nbsp; &nbsp; </u></a></p><hr/><p>🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣😘😘😘😘😘😘👊👊👀💀👻💩😬😡😣😖🙏🙏🤝😊😀😃😁😛😙😋😛😋😋😋😋😋</p><p><br></p>', '2026-04-03 16:38:33', 15, '已发布', '');
INSERT INTO `notice` VALUES (25, 2, 'Notice Test for normal user', 'test', '其他公告', '测试一下', '<p>测试一下</p>', '2026-04-07 09:56:12', 7, '已发布', '[]');
INSERT INTO `notice` VALUES (27, 2, '测试公告已读未读功能', 'test', '功能上线', '', '<h1>测试公告已读未读功能</h1>', '2026-04-07 11:01:43', 4, '已发布', '[]');
INSERT INTO `notice` VALUES (28, 1, '测试系统日志', '管理员', '功能上线', '', '<p>测试更改</p>', '2026-04-07 11:46:30', 3, '已发布', '[{\"name\":\"124397002.jpg\",\"url\":\"/api/static/upload/picture/1775543068731_124397002.jpg\",\"size\":8537}]');

-- ----------------------------
-- Table structure for notice_read_record
-- ----------------------------
DROP TABLE IF EXISTS `notice_read_record`;
CREATE TABLE `notice_read_record`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notice_id` int(11) NOT NULL COMMENT '公告ID',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `read_time` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_notice_user`(`notice_id`, `user_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 61 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '公告阅读记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notice_read_record
-- ----------------------------
INSERT INTO `notice_read_record` VALUES (7, 26, 2, '2026-04-07 10:38:43');
INSERT INTO `notice_read_record` VALUES (9, 24, 2, '2026-04-07 10:41:03');
INSERT INTO `notice_read_record` VALUES (10, 23, 2, '2026-04-07 10:41:16');
INSERT INTO `notice_read_record` VALUES (37, 27, 2, '2026-04-07 11:06:42');
INSERT INTO `notice_read_record` VALUES (38, 27, 1, '2026-04-07 11:13:09');
INSERT INTO `notice_read_record` VALUES (39, 26, 1, '2026-04-07 11:16:14');
INSERT INTO `notice_read_record` VALUES (40, 28, 1, '2026-04-07 14:27:08');
INSERT INTO `notice_read_record` VALUES (41, 25, 1, '2026-04-07 14:27:12');
INSERT INTO `notice_read_record` VALUES (42, 24, 1, '2026-04-07 14:27:13');
INSERT INTO `notice_read_record` VALUES (43, 23, 1, '2026-04-07 14:27:15');
INSERT INTO `notice_read_record` VALUES (44, 22, 1, '2026-04-07 14:27:20');
INSERT INTO `notice_read_record` VALUES (45, 2, 1, '2026-04-07 14:27:31');
INSERT INTO `notice_read_record` VALUES (46, 21, 1, '2026-04-07 14:27:34');
INSERT INTO `notice_read_record` VALUES (47, 20, 1, '2026-04-07 14:27:36');
INSERT INTO `notice_read_record` VALUES (48, 19, 1, '2026-04-07 14:27:38');
INSERT INTO `notice_read_record` VALUES (49, 18, 1, '2026-04-07 14:27:43');
INSERT INTO `notice_read_record` VALUES (50, 16, 1, '2026-04-07 14:27:44');
INSERT INTO `notice_read_record` VALUES (51, 15, 1, '2026-04-07 14:27:46');
INSERT INTO `notice_read_record` VALUES (52, 12, 1, '2026-04-07 14:27:48');
INSERT INTO `notice_read_record` VALUES (53, 8, 1, '2026-04-07 14:27:49');
INSERT INTO `notice_read_record` VALUES (54, 9, 1, '2026-04-07 14:27:53');
INSERT INTO `notice_read_record` VALUES (55, 10, 1, '2026-04-07 14:27:55');
INSERT INTO `notice_read_record` VALUES (56, 7, 1, '2026-04-07 14:27:57');
INSERT INTO `notice_read_record` VALUES (57, 6, 1, '2026-04-07 14:28:02');
INSERT INTO `notice_read_record` VALUES (58, 5, 1, '2026-04-07 14:28:03');
INSERT INTO `notice_read_record` VALUES (59, 4, 1, '2026-04-07 14:28:06');
INSERT INTO `notice_read_record` VALUES (60, 3, 1, '2026-04-07 14:28:08');

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作用户',
  `operation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作描述',
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法名',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '参数',
  `time` bigint(20) NULL DEFAULT NULL COMMENT '执行时间(ms)',
  `ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `module` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模块名称',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作类型',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_username`(`username`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 123 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of operation_log
-- ----------------------------
INSERT INTO `operation_log` VALUES (1, '系统', '新增公告', 'com.example.demo.controller.NoticeController.postNotice()', '[{\"公告标题\":\"测试系统日志\",\"公告类型\":\"功能上线\",\"公告摘要\":\"\",\"公告内容\":\"<p>测试</p>\",\"发布时间\":1775533590377,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"附件\":\"[]\"}]', 33, '0:0:0:0:0:0:0:1', '2026-04-07 11:46:30', '公告管理', '新增');
INSERT INTO `operation_log` VALUES (2, '系统', '修改公告', 'com.example.demo.controller.NoticeController.updateNotice()', '[{\"公告标题\":\"测试系统日志\",\"公告类型\":\"功能上线\",\"公告摘要\":\"\",\"公告内容\":\"<p>测试更改</p>\",\"发布时间\":1775533590000,\"发布作者\":\"管理员\",\"公告状态\":\"已发布\",\"附件\":\"[{\\\"name\\\":\\\"124397002.jpg\\\",\\\"url\\\":\\\"/api/static/upload/picture/1775543068731_124397002.jpg\\\",\\\"size\\\":8537}]\"}]', 40, '0:0:0:0:0:0:0:1', '2026-04-07 14:24:32', '公告管理', '修改');
INSERT INTO `operation_log` VALUES (3, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin1\",\"密码\":\"123456\"}]', 67, '0:0:0:0:0:0:0:1', '2026-04-07 14:59:17', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (4, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 3, '0:0:0:0:0:0:0:1', '2026-04-07 15:01:23', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (5, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 5, '0:0:0:0:0:0:0:1', '2026-04-07 15:06:15', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (6, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 3, '0:0:0:0:0:0:0:1', '2026-04-07 15:12:06', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (7, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 3, '0:0:0:0:0:0:0:1', '2026-04-07 15:16:15', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (8, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 133, '0:0:0:0:0:0:0:1', '2026-04-07 15:37:40', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (9, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 863, '0:0:0:0:0:0:0:1', '2026-04-13 11:11:35', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (10, '系统', '修改用户状态', 'com.example.demo.controller.UserController.updateStatus()', '[{\"昵称\":\"芒果\",\"状态\":\"禁用\"}]', 13, '0:0:0:0:0:0:0:1', '2026-04-13 17:14:59', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (11, '系统', '修改用户状态', 'com.example.demo.controller.UserController.updateStatus()', '[{\"昵称\":\"芒果\",\"状态\":\"禁用\"}]', 1, '0:0:0:0:0:0:0:1', '2026-04-13 17:15:03', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (12, '系统', '修改用户', 'com.example.demo.controller.UserController.updateInfo()', '[{\"昵称\":\"芒果\"}]', 27, '0:0:0:0:0:0:0:1', '2026-04-13 17:46:26', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (13, '系统', '新增商品', 'com.example.demo.controller.GoodsController.insertGoods()', '[{\"SKU编码\":\"FR002\",\"商品名称\":\"TEst\",\"品牌\":\"ste\",\"规格型号\":\"tewst\",\"基础单位\":\"箱\",\"参考采购价\":\"20\",\"标准售价\":20,\"成本价格\":20,\"主条码\":\"123123123123\"}]', 6, '0:0:0:0:0:0:0:1', '2026-04-13 17:47:15', '商品管理', '新增');
INSERT INTO `operation_log` VALUES (14, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 140, '0:0:0:0:0:0:0:1', '2026-04-14 11:22:34', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (15, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 168, '0:0:0:0:0:0:0:1', '2026-04-14 13:29:29', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (16, '系统', '修改用户状态', 'com.example.demo.controller.UserController.updateStatus()', '[{\"昵称\":\" 一号仓库\",\"状态\":\"2\"}]', 17, '0:0:0:0:0:0:0:1', '2026-04-14 14:10:41', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (17, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:24:14', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (18, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 11, '0:0:0:0:0:0:0:1', '2026-04-14 14:24:22', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (19, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 14:24:29', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (20, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 11, '0:0:0:0:0:0:0:1', '2026-04-14 14:24:30', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (21, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]', 19, '0:0:0:0:0:0:0:1', '2026-04-14 14:26:02', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (22, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 9, '0:0:0:0:0:0:0:1', '2026-04-14 14:26:04', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (23, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]', 17, '0:0:0:0:0:0:0:1', '2026-04-14 14:26:13', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (24, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 14:26:15', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (25, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:26:15', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (26, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 11, '0:0:0:0:0:0:0:1', '2026-04-14 14:26:16', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (27, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":2,\"createTime\":1776068926000,\"delFlag\":0}]', 11, '0:0:0:0:0:0:0:1', '2026-04-14 14:26:16', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (28, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 14:26:58', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (29, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 21, '0:0:0:0:0:0:0:1', '2026-04-14 14:26:59', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (30, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:27:10', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (31, '系统', '修改仓库信息', 'com.example.demo.controller.WarehouseController.updateWarehouse()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:27:30', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (32, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 11, '0:0:0:0:0:0:0:1', '2026-04-14 14:27:33', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (33, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:28:07', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (34, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 9, '0:0:0:0:0:0:0:1', '2026-04-14 14:28:47', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (35, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 23, '0:0:0:0:0:0:0:1', '2026-04-14 14:29:16', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (36, '系统', '修改仓库信息', 'com.example.demo.controller.WarehouseController.updateWarehouse()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 14:29:41', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (37, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:29:44', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (38, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 11, '0:0:0:0:0:0:0:1', '2026-04-14 14:31:07', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (39, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:32:07', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (40, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 6, '0:0:0:0:0:0:0:1', '2026-04-14 14:32:13', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (41, '系统', '修改仓库信息', 'com.example.demo.controller.WarehouseController.updateWarehouse()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 10, '0:0:0:0:0:0:0:1', '2026-04-14 14:32:20', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (42, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 14:32:24', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (43, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 18, '0:0:0:0:0:0:0:1', '2026-04-14 14:33:47', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (44, '系统', '新增仓库', 'com.example.demo.controller.WarehouseController.insertGoods()', '[{\"code\":\"F2\",\"name\":\"Test2\",\"address\":\"2号地址\",\"phone\":\"13242134512\",\"status\":1,\"delFlag\":0}]', 19, '0:0:0:0:0:0:0:1', '2026-04-14 14:35:00', '仓库管理', '新增');
INSERT INTO `operation_log` VALUES (45, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"address\":\"2号地址\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 17, '0:0:0:0:0:0:0:1', '2026-04-14 14:35:00', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (46, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"address\":\"2号地址\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 6, '0:0:0:0:0:0:0:1', '2026-04-14 14:35:04', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (47, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:35:04', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (48, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:35:57', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (49, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"address\":\"2号地址\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 14:35:57', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (50, '系统', '修改仓库信息', 'com.example.demo.controller.WarehouseController.updateWarehouse()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 14:36:07', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (51, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 14:36:10', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (52, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 12, '0:0:0:0:0:0:0:1', '2026-04-14 14:36:10', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (53, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:36:11', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (54, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 14:36:12', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (55, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:36:16', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (56, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:36:16', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (57, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 9, '0:0:0:0:0:0:0:1', '2026-04-14 14:36:30', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (58, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:36:30', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (59, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 6, '0:0:0:0:0:0:0:1', '2026-04-14 14:39:14', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (60, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 17, '0:0:0:0:0:0:0:1', '2026-04-14 14:39:14', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (61, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 14:39:17', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (62, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 14:39:17', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (63, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 6, '0:0:0:0:0:0:0:1', '2026-04-14 14:43:36', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (64, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 10, '0:0:0:0:0:0:0:1', '2026-04-14 14:43:36', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (65, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 6, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:28', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (66, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 6, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:28', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (67, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:28', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (68, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 12, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:28', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (69, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:28', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (70, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 39, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:28', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (71, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:30', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (72, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 6, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:30', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (73, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:31', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (74, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]', 9, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:32', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (75, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:34', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (76, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 13, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:34', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (77, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:39', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (78, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 6, '0:0:0:0:0:0:0:1', '2026-04-14 14:52:39', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (79, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:03', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (80, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 4, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:03', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (81, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:06', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (82, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 11, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:06', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (83, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:14', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (84, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 9, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:14', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (85, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 6, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:16', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (86, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 11, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:36', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (87, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 13, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:36', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (88, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":0,\"createTime\":1776068926000,\"delFlag\":0}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:53', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (89, '系统', '修改仓库状态', 'com.example.demo.controller.WarehouseController.updateStatus()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":0,\"createTime\":1776148499000,\"delFlag\":0}]', 24, '0:0:0:0:0:0:0:1', '2026-04-14 14:53:53', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (90, '系统', '修改仓库信息', 'com.example.demo.controller.WarehouseController.updateWarehouse()', '[{\"id\":1,\"code\":\"F1\",\"name\":\" 一号仓库\",\"kind\":\"原料仓\",\"address\":\"不知道哪的一仓库\",\"manager\":\"管理员\",\"phone\":\"15421312341\",\"status\":1,\"createTime\":1776068926000,\"delFlag\":0}]', 4, '0:0:0:0:0:0:0:1', '2026-04-14 14:58:09', '用户管理', '修改');
INSERT INTO `operation_log` VALUES (91, '系统', '删除商品', 'com.example.demo.controller.WarehouseController.deleteGoods()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]', 2, '0:0:0:0:0:0:0:1', '2026-04-14 14:58:41', '商品管理', '删除');
INSERT INTO `operation_log` VALUES (92, '系统', '删除商品', 'com.example.demo.controller.WarehouseController.deleteGoods()', '[{\"id\":2,\"code\":\"F2\",\"name\":\"Test2\",\"kind\":\"半成品仓\",\"address\":\"2号地址\",\"manager\":\"Test2\",\"phone\":\"13242134512\",\"status\":1,\"createTime\":1776148499000,\"delFlag\":0}]', 2, '0:0:0:0:0:0:0:1', '2026-04-14 14:59:04', '商品管理', '删除');
INSERT INTO `operation_log` VALUES (93, '系统', '新增库存作业', 'com.example.demo.controller.InventoryOperationController.insert()', '[{\"作业单号\":\"WH1776155534114\",\"作业类型\":\"inbound\",\"目标仓库\":\"一号仓库\",\"商品名称\":\"苹果\",\"SKU 编码\":\"APL001\",\"数量\":5,\"单位\":\"个\",\"操作员\":\"Test\",\"状态\":\"pending\",\"备注\":\"\"}]', 12, '0:0:0:0:0:0:0:1', '2026-04-14 16:32:31', '库存作业管理', '新增');
INSERT INTO `operation_log` VALUES (94, '系统', '新增库存作业', 'com.example.demo.controller.InventoryOperationController.insert()', '[{\"作业单号\":\"WH1776156962129\",\"作业类型\":\"transfer\",\"源仓库\":\"一号仓库\",\"目标仓库\":\"二号仓库\",\"商品名称\":\"苹果\",\"SKU 编码\":\"APL001\",\"数量\":2,\"单位\":\"个\",\"操作员\":\"Test\",\"状态\":\"pending\",\"备注\":\"\"}]', 27, '0:0:0:0:0:0:0:1', '2026-04-14 16:56:17', '库存作业管理', '新增');
INSERT INTO `operation_log` VALUES (95, '系统', '更新库存作业状态', 'com.example.demo.controller.InventoryOperationController.updateStatus()', '[1,\"completed\"]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 16:56:24', '库存作业管理', '修改');
INSERT INTO `operation_log` VALUES (96, '系统', '更新库存作业状态', 'com.example.demo.controller.InventoryOperationController.updateStatus()', '[2,\"cancelled\"]', 9, '0:0:0:0:0:0:0:1', '2026-04-14 16:56:45', '库存作业管理', '修改');
INSERT INTO `operation_log` VALUES (97, '系统', '新增库存作业', 'com.example.demo.controller.InventoryOperationController.insert()', '[{\"作业单号\":\"WH1776157025744\",\"作业类型\":\"outbound\",\"源仓库\":\"一号仓库\",\"商品名称\":\"苹果\",\"SKU 编码\":\"APL001\",\"数量\":1,\"单位\":\"个\",\"操作员\":\"Test\",\"状态\":\"pending\",\"备注\":\"\"}]', 17, '0:0:0:0:0:0:0:1', '2026-04-14 16:57:16', '库存作业管理', '新增');
INSERT INTO `operation_log` VALUES (98, '系统', '更新库存作业状态', 'com.example.demo.controller.InventoryOperationController.updateStatus()', '[3,\"completed\"]', 5, '0:0:0:0:0:0:0:1', '2026-04-14 16:57:21', '库存作业管理', '修改');
INSERT INTO `operation_log` VALUES (99, '系统', '新增库存作业', 'com.example.demo.controller.InventoryOperationController.insert()', '[{\"作业单号\":\"WH1776157051705\",\"作业类型\":\"adjustment\",\"源仓库\":\"一号仓库\",\"目标仓库\":\"一号仓库\",\"商品名称\":\"苹果\",\"SKU 编码\":\"APL001\",\"数量\":5,\"单位\":\"个\",\"操作员\":\"TEST\",\"状态\":\"pending\",\"备注\":\"\"}]', 7, '0:0:0:0:0:0:0:1', '2026-04-14 16:57:48', '库存作业管理', '新增');
INSERT INTO `operation_log` VALUES (100, '系统', '更新库存作业状态', 'com.example.demo.controller.InventoryOperationController.updateStatus()', '[4,\"completed\"]', 8, '0:0:0:0:0:0:0:1', '2026-04-14 17:14:15', '库存作业管理', '修改');
INSERT INTO `operation_log` VALUES (101, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 388, '0:0:0:0:0:0:0:1', '2026-04-15 12:42:53', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (102, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 121, '0:0:0:0:0:0:0:1', '2026-04-15 16:25:02', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (103, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 74, '0:0:0:0:0:0:0:1', '2026-04-15 16:33:20', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (104, '系统', '新增商品', 'com.example.demo.controller.GoodsController.insertGoods()', '[{\"SKU编码\":\"\",\"img\":\"\",\"商品名称\":\"007\",\"品牌\":\"\",\"规格型号\":\"\",\"基础单位\":\"个\",\"参考采购价\":\"0\",\"标准售价\":0,\"成本价格\":0,\"主条码\":\"\",\"库存数量\":0,\"库存预警上限\":0,\"库存预警下限\":0}]', 47, '0:0:0:0:0:0:0:1', '2026-04-15 16:53:22', '商品管理', '新增');
INSERT INTO `operation_log` VALUES (105, '系统', '新增商品', 'com.example.demo.controller.GoodsController.insertGoods()', '[{\"SKU编码\":\"\",\"img\":\"\",\"商品名称\":\"007\",\"品牌\":\"\",\"规格型号\":\"500ml/瓶\",\"基础单位\":\"瓶\",\"参考采购价\":\"0\",\"标准售价\":0,\"成本价格\":0,\"主条码\":\"\",\"库存数量\":0,\"库存预警上限\":0,\"库存预警下限\":0}]', 53, '0:0:0:0:0:0:0:1', '2026-04-15 16:59:12', '商品管理', '新增');
INSERT INTO `operation_log` VALUES (106, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 117, '0:0:0:0:0:0:0:1', '2026-04-15 22:40:31', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (107, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 530, '0:0:0:0:0:0:0:1', '2026-04-16 15:03:24', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (108, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 180, '0:0:0:0:0:0:0:1', '2026-04-16 15:47:54', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (109, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 130, '0:0:0:0:0:0:0:1', '2026-04-16 17:48:06', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (110, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 73, '0:0:0:0:0:0:0:1', '2026-04-16 17:48:30', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (111, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 466, '0:0:0:0:0:0:0:1', '2026-04-17 17:28:59', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (112, '系统', '保存采购订单', 'com.example.demo.controller.PurchaseOrderController.save()', '[{\"purchase\":{\"id\":3,\"billNo\":\"PO20260414003\",\"supplierId\":3,\"warehouseId\":2,\"totalAmount\":\"0.00\"},\"items\":[{\"id\":1,\"purchaseId\":3,\"goodsId\":1,\"quantity\":1,\"unitPrice\":0,\"amount\":0,\"sortNo\":0}]}]', 55, '0:0:0:0:0:0:0:1', '2026-04-18 13:42:05', '采购管理', '保存');
INSERT INTO `operation_log` VALUES (113, '系统', '确认采购订单', 'com.example.demo.controller.PurchaseOrderController.confirm()', '[3]', 20, '0:0:0:0:0:0:0:1', '2026-04-18 13:42:09', '采购管理', '确认');
INSERT INTO `operation_log` VALUES (114, '系统', '按采购订单生成入库单', 'com.example.demo.controller.PurchaseInboundController.create()', '[{\"purchaseId\":3}]', 51, '0:0:0:0:0:0:0:1', '2026-04-18 13:42:16', '采购管理', '新增');
INSERT INTO `operation_log` VALUES (115, '系统', '确认采购入库', 'com.example.demo.controller.PurchaseInboundController.confirm()', '[1]', 77, '0:0:0:0:0:0:0:1', '2026-04-18 13:42:20', '采购管理', '确认');
INSERT INTO `operation_log` VALUES (116, '系统', '保存销售订单', 'com.example.demo.controller.SaleController.add()', '[{\"id\":2,\"orderNo\":\"SO1776490972528\",\"customerId\":1,\"warehouseId\":1,\"orderDate\":1776470400000,\"totalAmount\":10,\"discountAmount\":0,\"finalAmount\":10,\"status\":0,\"items\":[{\"productId\":1,\"productNameSnapshot\":\"芒果\",\"price\":2,\"quantity\":5,\"subtotal\":10}]}]', 53, '0:0:0:0:0:0:0:1', '2026-04-18 13:42:53', '销售管理', '新增');
INSERT INTO `operation_log` VALUES (117, '系统', '确认销售订单', 'com.example.demo.controller.SaleController.confirm()', '[2]', 22, '0:0:0:0:0:0:0:1', '2026-04-18 13:43:01', '销售管理', '确认');
INSERT INTO `operation_log` VALUES (118, '系统', '生成销售出库单', 'com.example.demo.controller.SaleOutboundController.create()', '[{\"saleOrderId\":2}]', 52, '0:0:0:0:0:0:0:1', '2026-04-18 13:43:06', '销售管理', '新增');
INSERT INTO `operation_log` VALUES (119, '系统', '确认销售出库', 'com.example.demo.controller.SaleOutboundController.confirm()', '[1]', 547, '0:0:0:0:0:0:0:1', '2026-04-18 13:43:13', '销售管理', '确认');
INSERT INTO `operation_log` VALUES (120, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 94, '0:0:0:0:0:0:0:1', '2026-04-18 13:51:17', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (121, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"test\",\"密码\":\"test\"}]', 111, '0:0:0:0:0:0:0:1', '2026-04-18 14:33:14', '用户管理', '登录');
INSERT INTO `operation_log` VALUES (122, '系统', '用户登录', 'com.example.demo.controller.WebController.login()', '[{\"用户名\":\"admin\",\"密码\":\"123456\"}]', 72, '0:0:0:0:0:0:0:1', '2026-04-18 14:35:01', '用户管理', '登录');

-- ----------------------------
-- Table structure for purchase
-- ----------------------------
DROP TABLE IF EXISTS `purchase`;
CREATE TABLE `purchase`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `bill_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '单据编号（规则如 PO + 日期 + 流水）',
  `supplier_id` bigint(20) NULL DEFAULT NULL COMMENT '关联供应商ID',
  `warehouse_id` int(11) NULL DEFAULT NULL COMMENT '入库目标仓库',
  `total_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '含税总金额',
  `status` tinyint(4) NULL DEFAULT NULL COMMENT '状态：0-草稿，1-待审核，2-已完成，3-已作废',
  `in_stock_time` datetime NULL DEFAULT NULL COMMENT '实际入库时间（用于成本核算的截止点）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `confirm_time` datetime NULL DEFAULT NULL COMMENT '订单确认时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of purchase
-- ----------------------------
INSERT INTO `purchase` VALUES (1, 'PO20260414001', 1, 1, '15000.00', 2, '2026-04-14 10:00:00', NULL, '2026-04-18 13:03:46', '2026-04-18 13:03:46', NULL);
INSERT INTO `purchase` VALUES (2, 'PO20260414002', 2, 1, '25000.00', 1, NULL, NULL, '2026-04-18 13:03:46', '2026-04-18 13:03:46', NULL);
INSERT INTO `purchase` VALUES (3, 'PO20260414003', 3, 2, '0.00', 2, '2026-04-18 13:42:20', NULL, '2026-04-18 13:03:46', '2026-04-18 13:42:19', '2026-04-18 13:42:09');
INSERT INTO `purchase` VALUES (4, 'PO20260414004', 4, 1, '35000.00', 2, '2026-04-13 15:30:00', NULL, '2026-04-18 13:03:46', '2026-04-18 13:03:46', NULL);
INSERT INTO `purchase` VALUES (5, 'PO20260414005', 5, 2, '12000.00', 2, '2026-04-12 11:00:00', NULL, '2026-04-18 13:03:46', '2026-04-18 13:03:46', NULL);

-- ----------------------------
-- Table structure for purchase_inbound
-- ----------------------------
DROP TABLE IF EXISTS `purchase_inbound`;
CREATE TABLE `purchase_inbound`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `purchase_id` int(11) NOT NULL COMMENT '采购订单ID',
  `bill_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '入库单号',
  `warehouse_id` int(11) NOT NULL COMMENT '入库仓库',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0草稿 1已确认入账',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `confirm_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_purchase_id`(`purchase_id`) USING BTREE,
  INDEX `idx_bill_no`(`bill_no`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购入库单（一单仅一次）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of purchase_inbound
-- ----------------------------
INSERT INTO `purchase_inbound` VALUES (1, 3, 'RK17764909356962647', 2, 1, NULL, '2026-04-18 13:42:15', '2026-04-18 13:42:20');

-- ----------------------------
-- Table structure for purchase_inbound_item
-- ----------------------------
DROP TABLE IF EXISTS `purchase_inbound_item`;
CREATE TABLE `purchase_inbound_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `inbound_id` bigint(20) NOT NULL,
  `purchase_item_id` bigint(20) NOT NULL COMMENT '采购明细ID',
  `goods_id` int(10) UNSIGNED NOT NULL,
  `quantity` decimal(12, 2) NOT NULL,
  `unit_price` decimal(12, 2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_inbound_id`(`inbound_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购入库明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of purchase_inbound_item
-- ----------------------------
INSERT INTO `purchase_inbound_item` VALUES (1, 1, 1, 1, 1.00, 0.00);

-- ----------------------------
-- Table structure for purchase_item
-- ----------------------------
DROP TABLE IF EXISTS `purchase_item`;
CREATE TABLE `purchase_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `purchase_id` int(11) NOT NULL COMMENT '采购订单ID',
  `goods_id` int(10) UNSIGNED NOT NULL COMMENT '商品ID',
  `quantity` decimal(12, 2) NOT NULL COMMENT '数量',
  `unit_price` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '单价',
  `amount` decimal(14, 2) NOT NULL DEFAULT 0.00 COMMENT '金额',
  `sort_no` int(11) NOT NULL DEFAULT 0 COMMENT '行号',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_purchase_id`(`purchase_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of purchase_item
-- ----------------------------
INSERT INTO `purchase_item` VALUES (1, 3, 1, 1.00, 0.00, 0.00, 0);

-- ----------------------------
-- Table structure for sal_order
-- ----------------------------
DROP TABLE IF EXISTS `sal_order`;
CREATE TABLE `sal_order`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号 (业务主键)',
  `customer_id` bigint(20) NOT NULL COMMENT '关联客户ID',
  `warehouse_id` int(11) NULL DEFAULT NULL COMMENT '出库仓库ID',
  `order_date` date NOT NULL COMMENT '下单日期',
  `total_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '订单总金额',
  `discount_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '优惠金额',
  `final_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '实收金额',
  `status` tinyint(4) NOT NULL DEFAULT 10 COMMENT '订单状态: 10-待发货, 20-部分发货, 30-已发货, 40-已完成, 50-已取消',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `confirm_time` datetime NULL DEFAULT NULL COMMENT '订单确认时间',
  `deliver_time` datetime NULL DEFAULT NULL COMMENT '出库完成时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no`) USING BTREE,
  INDEX `idx_customer_id`(`customer_id`) USING BTREE,
  INDEX `idx_order_date`(`order_date`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售订单主表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sal_order
-- ----------------------------
INSERT INTO `sal_order` VALUES (1, 'ORFR01', 1, NULL, '2026-04-17', 5000.00, 0.00, 0.00, 10, NULL, 'admin', '2026-04-17 15:59:47', '2026-04-17 15:59:47', NULL, NULL);
INSERT INTO `sal_order` VALUES (2, 'SO1776490972528', 1, 1, '2026-04-18', 10.00, 0.00, 10.00, 2, NULL, NULL, '2026-04-18 13:42:52', '2026-04-18 13:43:12', '2026-04-18 13:43:01', '2026-04-18 13:43:13');

-- ----------------------------
-- Table structure for sal_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sal_order_item`;
CREATE TABLE `sal_order_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` bigint(20) NOT NULL COMMENT '关联订单ID',
  `product_id` bigint(20) NOT NULL COMMENT '关联商品ID',
  `product_name_snapshot` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称快照 (防止商品改名影响历史订单)',
  `price` decimal(12, 2) NOT NULL COMMENT '成交单价',
  `quantity` int(11) NOT NULL COMMENT '销售数量',
  `subtotal` decimal(12, 2) NOT NULL COMMENT '小计金额 (单价*数量)',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id`) USING BTREE,
  INDEX `idx_product_id`(`product_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售订单明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sal_order_item
-- ----------------------------
INSERT INTO `sal_order_item` VALUES (1, 1, 1, '芒果', 50.00, 100, 5000.00, '2026-04-17 16:00:23');
INSERT INTO `sal_order_item` VALUES (2, 2, 1, '芒果', 2.00, 5, 10.00, '2026-04-18 13:42:52');

-- ----------------------------
-- Table structure for sale_outbound
-- ----------------------------
DROP TABLE IF EXISTS `sale_outbound`;
CREATE TABLE `sale_outbound`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sale_order_id` bigint(20) NOT NULL COMMENT '销售订单ID',
  `bill_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '出库单号',
  `warehouse_id` int(11) NOT NULL COMMENT '出库仓库',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0草稿 1已确认出库',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `confirm_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sale_order_id`(`sale_order_id`) USING BTREE,
  INDEX `idx_bill_no`(`bill_no`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售出库单（一单仅一次）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sale_outbound
-- ----------------------------
INSERT INTO `sale_outbound` VALUES (1, 2, 'CK17764909863291506', 1, 1, NULL, '2026-04-18 13:43:06', '2026-04-18 13:43:13');

-- ----------------------------
-- Table structure for sale_outbound_item
-- ----------------------------
DROP TABLE IF EXISTS `sale_outbound_item`;
CREATE TABLE `sale_outbound_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `outbound_id` bigint(20) NOT NULL,
  `sale_order_item_id` bigint(20) NOT NULL COMMENT '销售明细ID',
  `product_id` bigint(20) NOT NULL COMMENT '商品ID',
  `quantity` int(11) NOT NULL,
  `price` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '成交单价快照',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_outbound_id`(`outbound_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '销售出库明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sale_outbound_item
-- ----------------------------
INSERT INTO `sale_outbound_item` VALUES (1, 1, 2, 1, 5, 2.00);

-- ----------------------------
-- Table structure for sign_record
-- ----------------------------
DROP TABLE IF EXISTS `sign_record`;
CREATE TABLE `sign_record`  (
  `sid` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL COMMENT '用户ID',
  `sign_in_time` datetime NULL DEFAULT NULL COMMENT '签到时间',
  `sign_out_time` datetime NULL DEFAULT NULL COMMENT '签退时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `sign_in_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sign_out_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`sid`) USING BTREE,
  INDEX `idx_user_id`(`uid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 115 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '签到记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sign_record
-- ----------------------------
INSERT INTO `sign_record` VALUES (87, 1, '2026-03-27 09:55:17', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '准时', '早退');
INSERT INTO `sign_record` VALUES (88, 1, '2026-03-27 10:12:05', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (89, 1, '2026-03-27 10:12:06', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (90, 1, '2026-03-27 10:12:07', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (91, 1, '2026-03-27 10:12:08', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (92, 1, '2026-03-27 10:12:09', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (93, 1, '2026-03-27 10:12:10', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (94, 1, '2026-03-27 10:12:11', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (95, 1, '2026-03-27 10:12:12', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (96, 3, '2026-03-27 10:12:13', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (98, 1, '2026-03-30 12:10:14', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (107, 1, '2026-04-01 17:36:17', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (108, 1, '2026-04-02 09:39:12', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (109, 1, '2026-04-02 12:12:38', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (110, 2, '2026-04-02 16:51:46', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (113, 2, '2026-04-03 17:53:48', '2026-04-03 17:53:50', NULL, '2026-04-03 17:53:48', '迟到', '早退');
INSERT INTO `sign_record` VALUES (114, 1, '2026-04-07 09:28:00', NULL, NULL, '2026-04-07 09:43:00', '准时', NULL);

-- ----------------------------
-- Table structure for supplier
-- ----------------------------
DROP TABLE IF EXISTS `supplier`;
CREATE TABLE `supplier`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '供应商ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '供应商编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '供应商名称',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商类型',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `bank_account` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '银行账号',
  `bank_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '开户银行',
  `tax_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '税人识别号',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code`) USING BTREE,
  UNIQUE INDEX `uk_supplier_code`(`code`) USING BTREE,
  INDEX `idx_supplier_name`(`name`) USING BTREE,
  INDEX `idx_supplier_contact_person`(`contact_person`) USING BTREE,
  INDEX `idx_supplier_phone`(`phone`) USING BTREE,
  INDEX `idx_supplier_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of supplier
-- ----------------------------
INSERT INTO `supplier` VALUES (1, 'S001', '海南芒果农场', NULL, '陈经理', '13912340001', 'chen@mango-farm.com', '海南省三亚市海棠区芒果园1号', '6222021234567890', NULL, '91460000MA5TWX1234', 1, '2026-04-10 08:00:00', '2026-04-10 08:00:00');
INSERT INTO `supplier` VALUES (2, 'S002', '泰国榴莲进口公司', NULL, 'Mr.Somchai', '13912340002', 'somchai@thai-durian.com', '泰国曼谷辉煌区榴莲街88号', '6222021234567891', NULL, '91410000MA5TWX5678', 1, '2026-04-10 09:00:00', '2026-04-10 09:00:00');
INSERT INTO `supplier` VALUES (3, 'S003', '新疆阿克苏苹果基地', NULL, '李场长', '13912340003', 'li@xj-apple.com', '新疆阿克苏市红富士路200号', '6222021234567892', NULL, '91652900MA5TWX9012', 1, '2026-04-11 10:00:00', '2026-04-11 10:00:00');
INSERT INTO `supplier` VALUES (4, 'S004', '智利车厘子合作社', NULL, 'Carlos', '13912340004', 'carlos@chile-cherry.com', '智利圣地亚哥市樱桃谷农场', '6222021234567893', NULL, '91765000MA5TWX3456', 1, '2026-04-12 08:30:00', '2026-04-12 08:30:00');
INSERT INTO `supplier` VALUES (5, 'S005', '越南火龙果供应商', NULL, 'Nguyen Thi Lan', '13912340005', 'lan@vietnam-dragon.com', '越南胡志明市火龙果产区', '6222021234567894', NULL, '91811000MA5TWX7890', 1, '2026-04-13 09:00:00', '2026-04-13 09:00:00');
INSERT INTO `supplier` VALUES (6, 'S006', '江西赣南脐橙农场', NULL, '刘老板', '13912340006', 'liu@gan-nan-orange.com', '江西省赣州市安远县脐橙基地', '6222021234567895', NULL, '91360700MA5TWX2468', 0, '2026-04-14 10:00:00', '2026-04-14 10:00:00');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `id` int(11) NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `pid` int(11) NULL DEFAULT NULL,
  `page_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sort_num` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', '/system', 'setting', '系统基础配置', NULL, '/views/system/index', 1);
INSERT INTO `sys_menu` VALUES (2, '用户管理', '/system/user', 'user', '用户列表', 1, '/views/system/user', 101);
INSERT INTO `sys_menu` VALUES (3, '角色管理', '/system/role', 'role', '角色列表', 1, '/views/system/role', 102);
INSERT INTO `sys_menu` VALUES (4, '菜单管理', '/system/menu', 'menu', '菜单列表', 1, '/views/system/menu', 103);
INSERT INTO `sys_menu` VALUES (5, '仓库管理', '/warehouse', 'box', '仓库基础配置', NULL, '/views/warehouse/index', 2);
INSERT INTO `sys_menu` VALUES (6, '仓库列表', '/warehouse/list', 'box', '仓库列表', 5, '/views/warehouse/list', 201);
INSERT INTO `sys_menu` VALUES (7, '商品管理', '/goods', 'shopping', '商品基础配置', NULL, '/views/goods/index', 3);
INSERT INTO `sys_menu` VALUES (8, '商品列表', '/goods/list', 'shopping', '商品列表', 7, '/views/goods/list', 301);
INSERT INTO `sys_menu` VALUES (9, '分类管理', '/goods/category', 'folder', '商品分类', 7, '/views/goods/category', 302);
INSERT INTO `sys_menu` VALUES (10, '库存管理', '/inventory', 'database', '库存相关操作', NULL, '/views/inventory/index', 4);
INSERT INTO `sys_menu` VALUES (11, '库存作业', '/inventory/operation', 'file', '出入库作业', 10, '/views/inventory/operation', 401);
INSERT INTO `sys_menu` VALUES (12, '库存预警', '/inventory/alert', 'warning', '库存预警', 10, '/views/inventory/alert', 402);
INSERT INTO `sys_menu` VALUES (13, '采购管理', '/purchase', 'shopping-cart', '采购相关操作', NULL, '/views/purchase/index', 5);
INSERT INTO `sys_menu` VALUES (14, '采购订单', '/purchase/order', 'shopping-cart', '采购订单', 13, '/views/purchase/order', 501);
INSERT INTO `sys_menu` VALUES (15, '供应商管理', '/purchase/supplier', 'team', '供应商列表', 13, '/views/purchase/supplier', 502);
INSERT INTO `sys_menu` VALUES (16, '客户管理', '/customer', 'contacts', '客户相关操作', NULL, '/views/customer/index', 6);
INSERT INTO `sys_menu` VALUES (17, '客户列表', '/customer/list', 'contacts', '客户列表', 16, '/views/customer/list', 601);
INSERT INTO `sys_menu` VALUES (18, '公告管理', '/notice', 'notification', '公告相关操作', NULL, '/views/notice/index', 7);
INSERT INTO `sys_menu` VALUES (19, '公告列表', '/notice/list', 'notification', '公告列表', 18, '/views/notice/list', 701);
INSERT INTO `sys_menu` VALUES (20, '签到管理', '/sign', 'calendar', '员工签到', NULL, '/views/sign/index', 8);
INSERT INTO `sys_menu` VALUES (21, '日志管理', '/log', 'file-text', '系统日志', NULL, '/views/log/index', 9);
INSERT INTO `sys_menu` VALUES (22, '操作日志', '/log/operation', 'file-text', '操作日志', 21, '/views/log/operation', 901);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `bio` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `joinDate` datetime NULL DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '启用',
  `createTime` datetime NULL DEFAULT NULL,
  `updateTime` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `del_flag` int(11) NULL DEFAULT 0,
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `unique_id`(`uid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '$2a$10$TAaQrJuqFfcc8qx.ClKWDedN7QPFQaRFTuo2oMskPZsUqljjXMpqm', '管理员', 'admin@test.com', '超级管理员', '研发组', '14325345231', 'BioHazard 1', '2026-03-19 22:30:00', '启用', '2026-03-19 15:34:57', '2026-04-13 15:40:39', '', 0);
INSERT INTO `user` VALUES (2, 'test', '$2a$10$S9dJRQmFd4FQatv//3QvN.Xi7zJoCXmSAgedfwspl2iZWbdOsPwkm', 'test', 'test@test.test', '管理员', '研发组', '12312312321', 'testste', '2026-03-21 00:00:00', '启用', '2026-03-21 15:35:05', '2026-04-18 14:26:01', '', 0);
INSERT INTO `user` VALUES (3, 'test2', '$2a$10$f2p9.WE7vc3rG/cbrmJt2O0ziouhfd4Ae.VwiIgrMBICjPcr/wvDi', '特色t', 'test@test.com', '销售经理', '销售组', '15432432413', '123', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-04-18 14:26:38', NULL, 0);
INSERT INTO `user` VALUES (4, 'test3', '$2a$10$v7u7uktDVddIUpH8WUj71uzUqVvPughgFNjEWIYTG5mRqpKnuSbvm', 'test3', 'test@qqq.qwe', '销售经理', '销售组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-04-18 14:26:33', NULL, 0);
INSERT INTO `user` VALUES (5, 'teststtst', '$2a$10$x9kzxxdqvlePpNs0dOWPzef5GbQwbBBCv7RSUxj5IpzNqBsOPjLBG', 'teststtst', 'asd@123.com', '采购经理', '采购组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-04-18 14:26:56', NULL, 0);
INSERT INTO `user` VALUES (6, 'A_User_For_TEST', '$2a$10$ZHA7d7A02dEbJqfhMLx6GO.oMrrAjOVkVM6X9kZrByQo4V3j7v6Da', 'A_User_For_TEST', '123@123.com', '采购经理', '采购组', '12312312321', 'I Want to Play DeathStranding', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-04-18 14:26:58', NULL, 0);
INSERT INTO `user` VALUES (7, 'serser', '$2a$10$NbEcx02Ca8ouQcy0lwsRc.BrQ2k7S9IGilWcmVZARSiodFpt1R5QO', 'serser', '123@123.com', '超级管理员', '研发组', '14325345231', '123', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-04-13 15:40:42', NULL, 0);
INSERT INTO `user` VALUES (8, '1231231', '$2a$10$IOwvt1PuvUO64U6SH.6q.ulW/vQhNvIG1XL6rZP/Mm/uO5YS/5Xxm', '1231231', 'test@test.test', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-04-13 15:40:44', NULL, 0);
INSERT INTO `user` VALUES (9, 'tetetetetet', '$2a$10$AD.fqE07e/wcnM2Eg/uKc.nPd7tRGGk6YQivcTkqEmGpAATuwG2.i', 'tetetetetet', 'test@test.test', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 15:35:31', '2026-04-13 15:40:44', NULL, 0);

-- ----------------------------
-- Table structure for warehouse
-- ----------------------------
DROP TABLE IF EXISTS `warehouse`;
CREATE TABLE `warehouse`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '仓库ID',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库编码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库名称',
  `kind` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓库类型',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓库地址',
  `manager` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '负责人电话',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态 0-停用 1-启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` int(11) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code`) USING BTREE,
  UNIQUE INDEX `uk_warehouse_code`(`code`) USING BTREE,
  INDEX `idx_warehouse_name`(`name`) USING BTREE,
  INDEX `idx_warehouse_kind`(`kind`) USING BTREE,
  INDEX `idx_warehouse_status`(`status`) USING BTREE,
  INDEX `idx_warehouse_status_time`(`status`, `create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of warehouse
-- ----------------------------
INSERT INTO `warehouse` VALUES (1, 'F1', ' 一号仓库', '原料仓', '不知道哪的一仓库', '管理员', '15421312341', 1, '2026-04-13 16:28:46', 0);
INSERT INTO `warehouse` VALUES (2, 'F2', 'Test2', '半成品仓', '2号地址', 'Test2', '13242134512', 1, '2026-04-14 14:34:59', 0);

-- ----------------------------
-- Procedure structure for UpdateNoticeStatusByDate
-- ----------------------------
DROP PROCEDURE IF EXISTS `UpdateNoticeStatusByDate`;
delimiter ;;
CREATE PROCEDURE `UpdateNoticeStatusByDate`()
BEGIN
    -- 将所有 publishDate 小于或等于当前时间，且 status 还不是 '已发布'(或你的目标状态) 的记录更新
    -- 假设：目标状态值设为 'PUBLISHED'，你的初始状态可能是 'PENDING' 或 'DRAFT'
    UPDATE notice
    SET status = '已发布'  -- 替换成你想要修改成的状态值
    WHERE publishDate <= NOW()
      AND status = '定时发布'; -- 避免重复更新，提高效率
END
;;
delimiter ;

-- ----------------------------
-- Event structure for updateStatus_evnet
-- ----------------------------
DROP EVENT IF EXISTS `updateStatus_evnet`;
delimiter ;;
CREATE EVENT `updateStatus_evnet`
ON SCHEDULE
EVERY '5' MINUTE STARTS '2026-04-03 09:40:00'
DO CALL UpdateNoticeStatusByDate()
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
