/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 50744
 Source Host           : localhost:3306
 Source Schema         : testdb

 Target Server Type    : MySQL
 Target Server Version : 50744
 File Encoding         : 65001

 Date: 31/03/2026 17:50:13
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for message
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message`  (
  `msg_id` int(11) NOT NULL,
  `uid` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`msg_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `nid` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `publishDate` datetime(0) NULL DEFAULT NULL,
  `uid` int(11) NULL DEFAULT NULL,
  `views` int(255) NULL DEFAULT NULL,
  PRIMARY KEY (`nid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (1, 'TEST', '系统更新', 'tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt', '2026-03-31 15:14:56', 1, 42);
INSERT INTO `notice` VALUES (2, 'TESTt', '系统更新', 'tttttttttttttttttt', '2026-03-31 15:19:50', 2, 42);
INSERT INTO `notice` VALUES (3, '123123123', '维护通知', '***************************\r\nAPPLICATION FAILED TO START\r\n***************************\r\nDescription:\r\nFailed to configure a DataSource: \'url\' attribute is not specified and no embedded datasource could be configured.\r\nReason: Failed to determine a suitable driver class\r\nAction:', '2026-03-31 16:25:57', 1, 42);
INSERT INTO `notice` VALUES (4, '鹰峰同学请穿上衣服', '其他公告', '普通学生白田无意中发现校园女神鹰峰同学拥有通过脱下内裤来穿越时空、改变因果的超能力。为了能够随心所欲地使用这个能力，鹰峰设计陷害白田使其成为内衣柜，从而引发了一系列搞笑且充满奇幻色彩的故事。', '2026-03-31 17:09:38', 1, 66);
INSERT INTO `notice` VALUES (5, '黑执事 -绿之魔女篇', '其他公告', '奉女王之命前往德国调查离奇死亡事件的塞巴斯蒂安与西雅尔。在探查踏入者即遭咒杀的\"人狼之森\"真相时，骇人诅咒正向二人倾泻而下――。', '2026-03-31 17:10:34', 1, 67);
INSERT INTO `notice` VALUES (6, '写点什么，反正就是吧内容撑开', '功能上线', 'Doro, Doro, Doro', '2026-03-31 17:15:37', 1, 43);

-- ----------------------------
-- Table structure for sign_record
-- ----------------------------
DROP TABLE IF EXISTS `sign_record`;
CREATE TABLE `sign_record`  (
  `sid` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL COMMENT '用户ID',
  `sign_date` date NOT NULL COMMENT '签到日期',
  `sign_in_time` datetime(0) NULL DEFAULT NULL COMMENT '签到时间',
  `sign_out_time` datetime(0) NULL DEFAULT NULL COMMENT '签退时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP,
  `sign_in_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sign_out_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`sid`) USING BTREE,
  INDEX `idx_user_id`(`uid`) USING BTREE,
  INDEX `idx_sign_date`(`sign_date`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '签到记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sign_record
-- ----------------------------
INSERT INTO `sign_record` VALUES (87, 1, '2026-03-27', '2026-03-27 09:55:17', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '准时', '早退');
INSERT INTO `sign_record` VALUES (88, 1, '2026-03-27', '2026-03-27 10:12:05', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (89, 1, '2026-03-27', '2026-03-27 10:12:06', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (90, 1, '2026-03-27', '2026-03-27 10:12:07', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (91, 1, '2026-03-27', '2026-03-27 10:12:08', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (92, 1, '2026-03-27', '2026-03-27 10:12:09', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (93, 1, '2026-03-27', '2026-03-27 10:12:10', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (94, 1, '2026-03-27', '2026-03-27 10:12:11', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (95, 1, '2026-03-27', '2026-03-27 10:12:12', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (96, 3, '2026-03-27', '2026-03-27 10:12:13', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (98, 1, '2026-03-30', '2026-03-30 12:10:14', '2026-03-30 12:10:15', NULL, '2026-03-30 12:10:14', '迟到', '早退');
INSERT INTO `sign_record` VALUES (99, 1, '2026-03-31', '2026-03-31 09:38:45', NULL, NULL, '2026-03-31 09:38:45', '迟到', NULL);

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
  `joinDate` datetime(0) NULL DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '启用',
  `createTime` datetime(0) NULL DEFAULT NULL,
  `updateTime` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0),
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `unique_id`(`uid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '12345', '管理员', 'admin@test.com', '超级管理员', '研发组', '14325345231', 'BioHazard 1', '2026-03-19 22:30:00', '启用', '2026-03-19 15:34:57', '2026-03-31 14:20:46', 'api/static/upload/avatars/1774926833811_avatar_1.jpg');
INSERT INTO `user` VALUES (2, 'test', 'test', 'test', 'test@test.test', '测试工程师', '研发组', '12312312321', 'testste', '2026-03-21 00:00:00', '启用', '2026-03-21 15:35:05', '2026-03-31 11:12:12', 'api/static/upload/avatars/1774926613879_avatar_2.jpg');
INSERT INTO `user` VALUES (3, 'test2', 'tetstst', '特色t', 'test@test.com', '开发工程师', '研发组', '15432432413', '123', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-03-26 10:14:46', NULL);
INSERT INTO `user` VALUES (4, 'test3', 'tetstst', 'test3', 'test@qqq.qwe', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-03-26 10:27:00', NULL);
INSERT INTO `user` VALUES (5, 'teststtst', 'asdfasdfa', 'teststtst', 'asd@123.com', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-03-26 10:27:01', NULL);
INSERT INTO `user` VALUES (6, 'A_User_For_TEST', 'testtest', 'A_User_For_TEST', '123@123.com', '开发工程师', '研发组', '12312312321', 'I Want to Play DeathStranding', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-03-25 17:03:26', NULL);
INSERT INTO `user` VALUES (7, 'serser', 'serser', 'serser', '123@123.com', '超级管理员', '研发组', '14325345231', '123', '2026-03-21 00:00:00', '禁用', '2026-03-22 15:35:13', '2026-03-26 11:51:36', NULL);
INSERT INTO `user` VALUES (8, '1231231', '123', '1231231', 'test@test.test', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-03-26 10:27:02', NULL);
INSERT INTO `user` VALUES (9, 'tetetetetet', 'tototototot', 'tetetetetet', 'test@test.test', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 15:35:31', '2026-03-26 10:27:03', NULL);
INSERT INTO `user` VALUES (10, 'tetoteto', 'tetetetetetete', 'tetoteto', 'teto@teto.com', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 15:35:34', '2026-03-26 10:27:05', NULL);
INSERT INTO `user` VALUES (13, '4141414', '1414141', '4141414', 'Test@test.com', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 17:43:07', '2026-03-26 10:27:06', NULL);
INSERT INTO `user` VALUES (24, '42', '42', '42', 'test@test.com', '开发工程师', '研发组', '14323453213', '42', '2026-03-19 22:30:00', '启用', '2026-03-30 12:19:43', NULL, NULL);
INSERT INTO `user` VALUES (25, '123', '123', '444', 'test@test.com', '开发工程师', '研发组', '14323453214', '43', '2026-03-20 22:30:00', '启用', '2026-03-30 12:19:43', NULL, NULL);
INSERT INTO `user` VALUES (26, '124', '124', '445', 'test@test.com', '开发工程师', '研发组', '14323453215', '44', '2026-03-21 22:30:00', '启用', '2026-03-30 12:19:43', NULL, NULL);
INSERT INTO `user` VALUES (27, '125', '125', '446', 'test@test.com', '开发工程师', '研发组', '14323453216', '45', '2026-03-22 22:30:00', '启用', '2026-03-30 12:19:43', NULL, NULL);
INSERT INTO `user` VALUES (28, '126', '126', '447', 'test@test.com', '开发工程师', '研发组', '14323453217', '46', '2026-03-23 22:30:00', '启用', '2026-03-30 12:19:43', NULL, NULL);
INSERT INTO `user` VALUES (29, '127', '127', '448', 'test@test.com', '开发工程师', '研发组', '14323453218', '47', '2026-03-24 22:30:00', '启用', '2026-03-30 12:19:43', NULL, NULL);
INSERT INTO `user` VALUES (30, '128', '128', '449', 'test@test.com', '开发工程师', '研发组', '14323453219', '48', '2026-03-25 22:30:00', '启用', '2026-03-30 12:19:43', NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;
