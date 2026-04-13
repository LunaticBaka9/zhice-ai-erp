/*
 Navicat Premium Dump SQL

 Source Server         : testdb
 Source Server Type    : MySQL
 Source Server Version : 50726 (5.7.26)
 Source Host           : localhost:3306
 Source Schema         : testdb

 Target Server Type    : MySQL
 Target Server Version : 50726 (5.7.26)
 File Encoding         : 65001

 Date: 13/04/2026 17:56:59
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for bill
-- ----------------------------
DROP TABLE IF EXISTS `bill`;
CREATE TABLE `bill`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `bill_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '单据编号（规则如 PO + 日期 + 流水）',
  `supplier_id` bigint(20) NULL DEFAULT NULL COMMENT '关联供应商ID',
  `warehouse_id` int(11) NULL DEFAULT NULL COMMENT '入库目标仓库',
  `total_amount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '含税总金额',
  `status` tinyint(4) NULL DEFAULT NULL COMMENT '状态：0-草稿，1-待审核，2-已完成，3-已作废',
  `in_stock_time` datetime NULL DEFAULT NULL COMMENT '实际入库时间（用于成本核算的截止点）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bill
-- ----------------------------

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
  INDEX `idx_parent_id`(`parent_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, 0, '食物', 0, '2026-04-13 15:38:31', '2026-04-13 17:45:51');
INSERT INTO `category` VALUES (2, 1, '水果', 0, '2026-04-13 17:45:56', '2026-04-13 17:45:56');

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
  UNIQUE INDEX `uk_code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '客户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer
-- ----------------------------

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SKU编码，全局唯一',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
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
  `del_flag` int(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sku_code`(`sku_code`) USING BTREE,
  INDEX `idx_category_id`(`category_id`) USING BTREE,
  INDEX `idx_barcode`(`barcode`) USING BTREE,
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES (1, 'FR001', '芒果', 2, '我不到啊', 'FR-01', '箱', '690123456789', 30.00, 50.00, 30.00, 10.00, 200.00, '2026-04-13 15:55:11', '2026-04-13 17:46:01', 0);
INSERT INTO `goods` VALUES (2, 'FR002', 'TEst', 2, 'ste', 'tewst', '箱', '123123123123', 20.00, 20.00, 20.00, 10.00, 100.00, '2026-04-13 17:47:14', '2026-04-13 17:47:14', 0);

-- ----------------------------
-- Table structure for message
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message`  (
  `msg_id` int(11) NOT NULL,
  `uid` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`msg_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of message
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统操作日志表' ROW_FORMAT = DYNAMIC;

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
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `bank_account` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '银行账号',
  `tax_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '税号',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of supplier
-- ----------------------------

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
) ENGINE = MyISAM CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------

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
INSERT INTO `user` VALUES (2, 'test', '$2a$10$S9dJRQmFd4FQatv//3QvN.Xi7zJoCXmSAgedfwspl2iZWbdOsPwkm', 'test', 'test@test.test', '测试工程师', '研发组', '12312312321', 'testste', '2026-03-21 00:00:00', '启用', '2026-03-21 15:35:05', '2026-04-13 15:40:39', '', 0);
INSERT INTO `user` VALUES (3, 'test2', '$2a$10$f2p9.WE7vc3rG/cbrmJt2O0ziouhfd4Ae.VwiIgrMBICjPcr/wvDi', '特色t', 'test@test.com', '开发工程师', '研发组', '15432432413', '123', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-04-13 15:40:40', NULL, 0);
INSERT INTO `user` VALUES (4, 'test3', '$2a$10$v7u7uktDVddIUpH8WUj71uzUqVvPughgFNjEWIYTG5mRqpKnuSbvm', 'test3', 'test@qqq.qwe', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-04-13 15:40:41', NULL, 0);
INSERT INTO `user` VALUES (5, 'teststtst', '$2a$10$x9kzxxdqvlePpNs0dOWPzef5GbQwbBBCv7RSUxj5IpzNqBsOPjLBG', 'teststtst', 'asd@123.com', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-04-13 15:40:41', NULL, 0);
INSERT INTO `user` VALUES (6, 'A_User_For_TEST', '$2a$10$ZHA7d7A02dEbJqfhMLx6GO.oMrrAjOVkVM6X9kZrByQo4V3j7v6Da', 'A_User_For_TEST', '123@123.com', '开发工程师', '研发组', '12312312321', 'I Want to Play DeathStranding', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-04-13 15:40:42', NULL, 0);
INSERT INTO `user` VALUES (7, 'serser', '$2a$10$NbEcx02Ca8ouQcy0lwsRc.BrQ2k7S9IGilWcmVZARSiodFpt1R5QO', 'serser', '123@123.com', '超级管理员', '研发组', '14325345231', '123', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-04-13 15:40:42', NULL, 0);
INSERT INTO `user` VALUES (8, '1231231', '$2a$10$IOwvt1PuvUO64U6SH.6q.ulW/vQhNvIG1XL6rZP/Mm/uO5YS/5Xxm', '1231231', 'test@test.test', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-04-13 15:40:44', NULL, 0);
INSERT INTO `user` VALUES (9, 'tetetetetet', '$2a$10$AD.fqE07e/wcnM2Eg/uKc.nPd7tRGGk6YQivcTkqEmGpAATuwG2.i', 'tetetetetet', 'test@test.test', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 15:35:31', '2026-04-13 15:40:44', NULL, 0);
INSERT INTO `user` VALUES (10, 'tetoteto', '$2a$10$CCwRZmkRGXs2AuWOnG/3T.NyqNDv8D5Lefqozrw6F5hddpiOvQ7RK', 'tetoteto', 'teto@teto.com', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 15:35:34', '2026-04-13 15:40:45', NULL, 0);
INSERT INTO `user` VALUES (13, '4141414', '$2a$10$QNyZ1gB.fDgxsRMfuNX9DOCZZI5JdR2c3UUyooi8QUv.6UiZikI7m', '4141414', 'Test@test.com', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 17:43:07', '2026-04-13 15:40:46', NULL, 0);
INSERT INTO `user` VALUES (24, '42', '$2a$10$K.dsblSk5bD4T33UEhMd6O/3.Xe3E7EndKV24RiS9SB4.QWiauIK.', '42', 'test@test.com', '开发工程师', '研发组', '14323453213', '42', '2026-03-19 22:30:00', '启用', '2026-03-30 12:19:43', '2026-04-13 15:40:47', NULL, 0);
INSERT INTO `user` VALUES (31, '123', '$2a$10$PVJwGbD.na2jtwp4A/eIqerkgyBjZb29C9CK3XALk8eSfKzwp9kRe', '123', 'test@test.com', '开发工程师', '研发组', '14323453214', '43', '2026-03-20 22:30:00', '启用', '2026-04-01 15:28:33', '2026-04-13 15:40:47', NULL, 0);
INSERT INTO `user` VALUES (32, '124', '$2a$10$y0PhlevZzEgIrVZ5FHB1ge5bX43vDuXh1egNJGsUuFA55zbmzZ56y', '124', 'test@test.com', '开发工程师', '研发组', '14323453215', '44', '2026-03-21 22:30:00', '启用', '2026-04-01 15:28:33', '2026-04-13 15:40:48', NULL, 0);
INSERT INTO `user` VALUES (33, '125', '$2a$10$C1mV3qLobTFVbM87VM1TLuYJPDWpv38vyxb3BoKjwzLaABoP3XZF6', '125', 'test@test.com', '开发工程师', '研发组', '14323453216', '45', '2026-03-22 22:30:00', '启用', '2026-04-01 15:28:33', '2026-04-13 15:40:50', NULL, 0);
INSERT INTO `user` VALUES (34, '126', '$2a$10$P9kkQ0/sLcEQ3tk9AlMJkOvfIbmUm5hy8hj/wdCQ68nqzzBYvs2Dy', '126', 'test@test.com', '开发工程师', '研发组', '14323453217', '46', '2026-03-23 22:30:00', '启用', '2026-04-01 15:28:33', '2026-04-13 15:40:49', NULL, 0);
INSERT INTO `user` VALUES (35, '127', '$2a$10$yV41NqzlSI9ViTKXGOi5UOAjwvhHeaWx2sjJAHPxQJ9IcuEktUnaO', '127', 'test@test.com', '开发工程师', '研发组', '14323453218', '47', '2026-03-24 22:30:00', '启用', '2026-04-01 15:28:33', '2026-04-13 15:40:51', NULL, 0);
INSERT INTO `user` VALUES (36, '128', '$2a$10$zRuP.d4C4E2FoCsznNo/VOSKNREe/4mXZgBycgnBkRu8ucjuXMO9S', '128', 'test@test.com', '开发工程师', '研发组', '14323453219', '48', '2026-03-25 22:30:00', '启用', '2026-04-01 15:28:33', '2026-04-13 15:40:52', NULL, 0);
INSERT INTO `user` VALUES (40, 'admin1', '$2a$10$K1Cqk46hTkm663sDkShDhOfRogbrsJeMxYjiRunbGdFIC55V9XFlu', 'admin1', 'test@test.com', NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-07 15:37:16', '2026-04-13 15:40:52', NULL, 0);

-- ----------------------------
-- Table structure for warehouse
-- ----------------------------
DROP TABLE IF EXISTS `warehouse`;
CREATE TABLE `warehouse`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '仓库ID',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库编码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库名称',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓库地址',
  `manager` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '负责人',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态 0-停用 1-启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of warehouse
-- ----------------------------
INSERT INTO `warehouse` VALUES (1, 'F1', ' 一号仓库', '不知道哪的一仓库', '管理员', 1, '2026-04-13 16:28:46');

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
