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

 Date: 02/04/2026 17:49:38
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
  `uid` int(11) NULL DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `publishDate` datetime(0) NULL DEFAULT NULL,
  `views` int(255) NULL DEFAULT 0,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`nid`) USING BTREE,
  INDEX `idx_publishDate_status`(`publishDate`, `status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (2, 2, 'TESTt', 'test', '系统更新', NULL, '<p>I do not kown</p>', '2026-04-02 17:12:31', 44, '已发布');
INSERT INTO `notice` VALUES (3, 1, '123123123', '管理员', '维护通知', NULL, '***************************\r\nAPPLICATION FAILED TO START\r\n***************************\r\nDescription:\r\nFailed to configure a DataSource: \'url\' attribute is not specified and no embedded datasource could be configured.\r\nReason: Failed to determine a suitable driver class\r\nAction:\r\n///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////', '2026-03-31 16:25:57', 42, '草稿');
INSERT INTO `notice` VALUES (4, 1, '鹰峰同学请穿上衣服', '管理员', '其他公告', NULL, '普通学生白田无意中发现校园女神鹰峰同学拥有通过脱下内裤来穿越时空、改变因果的超能力。为了能够随心所欲地使用这个能力，鹰峰设计陷害白田使其成为内衣柜，从而引发了一系列搞笑且充满奇幻色彩的故事。', '2026-03-31 17:09:38', 66, '已发布');
INSERT INTO `notice` VALUES (5, 1, '黑执事 -绿之魔女篇', '管理员', '其他公告', NULL, '奉女王之命前往德国调查离奇死亡事件的塞巴斯蒂安与西雅尔。在探查踏入者即遭咒杀的\"人狼之森\"真相时，骇人诅咒正向二人倾泻而下――。 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', '2026-03-31 17:10:34', 67, '已发布');
INSERT INTO `notice` VALUES (6, 1, 'DORO', '管理员', '其他公告', NULL, 'doro,doro?Doro!DORO!', '2026-04-01 10:19:44', 51, '已发布');
INSERT INTO `notice` VALUES (7, 1, '整点整点', '管理员', '功能上线', NULL, '上码头整点薯条去', '2026-04-01 11:28:58', 101, '已发布');
INSERT INTO `notice` VALUES (8, 1, '我想玩死亡搁浅2', '管理员', '维护通知', NULL, '哎呀，送货送到一半我的F5节点都还没有接通', '2026-04-01 11:30:17', 134, '已发布');
INSERT INTO `notice` VALUES (9, 1, 'OTSUPEKO！', '管理员', '系统更新', 'PEKORA!', 'KONPEKO！', '2026-04-01 11:30:00', 1316, '已发布');
INSERT INTO `notice` VALUES (10, 1, '今天是TETO的生日', '管理员', '维护通知', '今天是TETO的生日', '今天是愚人节，也是TETO的生日，但是还得上班', '2026-04-01 11:30:00', 0, '草稿');
INSERT INTO `notice` VALUES (12, 1, 'ImportTest', '管理员', '功能上线', '测试', '测试一下导入', '2026-04-01 18:31:13', 7, '已发布');
INSERT INTO `notice` VALUES (15, 1, 'asdfasdfsadfsadf', '管理员', '系统更新', NULL, '<h1><em>asdfadsfsadfsad</em></h1><p>asdfadsfasdfsadfsadfasdfasdf</p>', '2026-04-02 10:46:44', 3, '已发布');
INSERT INTO `notice` VALUES (16, 1, '测试公告发布', '管理员', '功能上线', '测试富文本编辑', '<h1>测试一下<span style=\"color: rgb(207, 19, 34);\"><em>富文本</em></span>编辑</h1><blockquote>世界上多数的话，大体都是我说的吧 &nbsp; &nbsp;——鲁迅</blockquote><div data-w-e-type=\"todo\"><input type=\"checkbox\" disabled >整点怪东西</div><ul><li>test1</li><li style=\"text-align: center;\">test2</li></ul><ol><li>1</li><li>2</li></ol><p>👻👻👍👍👍👍👍👍👍👍👍🤘🤘👌👌✌️✌️✊✊🤛🤝👍👍👍👍</p><p><br></p>', '2026-04-02 10:54:34', 16, '已发布');
INSERT INTO `notice` VALUES (18, 1, 'asdfasdfadsf', '管理员', '系统更新', 'asdfasdfdsaf', '<h1><span style=\"font-size: 40px;\"><u><em><strong>asdfasdfadsf</strong></em></u></span><u><em><strong>🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣🤣</strong></em></u></h1><p style=\"text-align: right;\">asdfasdf</p><table style=\"width: auto;\"><tbody><tr><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">111</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">111</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">2323</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">1231231</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></th></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">a\'s\'d\'f</td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"></td></tr></tbody></table><p><br></p>', '2026-04-02 15:29:15', 12, '已发布');
INSERT INTO `notice` VALUES (19, 1, 'asdfasdfadsf', '管理员', '其他公告', '123123123', '<p>🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏🙏👍👍👍👍👍👍👍👍👍👍😤😤😤😤😤😤😤😤😤</p>', '2026-04-02 15:50:27', 36, '已发布');
INSERT INTO `notice` VALUES (20, 2, '尝试用别的账号进行一个发布', 'test', '系统更新', '', '<ul><li>WAAAAAAAAA</li><li>:-D</li><li>:-)</li></ul>', '2026-04-02 16:50:07', 2, '已发布');
INSERT INTO `notice` VALUES (21, 2, '!!!!!!', 'test', '系统更新', '', '<p>😍😍😍😍😍😍😍😍😍😘😘😘😘😘😘😘😋😋😋😋😋😋😋</p>', '2026-04-02 16:54:29', 1, '已发布');
INSERT INTO `notice` VALUES (22, 2, '测试定时发布', 'test', '系统更新', '', '<p>啊手动阀手动阀手动阀</p>', '2026-04-03 08:42:27', 0, '定时发布');

-- ----------------------------
-- Table structure for sign_record
-- ----------------------------
DROP TABLE IF EXISTS `sign_record`;
CREATE TABLE `sign_record`  (
  `sid` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL COMMENT '用户ID',
  `sign_in_time` datetime(0) NULL DEFAULT NULL COMMENT '签到时间',
  `sign_out_time` datetime(0) NULL DEFAULT NULL COMMENT '签退时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP,
  `sign_in_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sign_out_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`sid`) USING BTREE,
  INDEX `idx_user_id`(`uid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 111 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '签到记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sign_record
-- ----------------------------
INSERT INTO `sign_record` VALUES (87, 1, '2026-03-27 09:55:17', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '准时', '早退');
INSERT INTO `sign_record` VALUES (88, 1, '2026-03-27 10:12:05', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (89, 1, '2026-03-27 10:12:06', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (90, 1, '2026-03-27 10:12:07', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (91, 1, '2026-03-27 10:12:08', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (92, 1, '2026-03-27 10:12:09', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (93, 1, '2026-03-27 10:12:10', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (94, 1, '2026-03-27 10:12:11', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (95, 1, '2026-03-27 10:12:12', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (96, 3, '2026-03-27 10:12:13', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (98, 1, '2026-03-30 12:10:14', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (107, 1, '2026-04-01 17:36:17', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (108, 1, '2026-04-02 09:39:12', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (109, 1, '2026-04-02 12:12:38', '2026-04-02 12:12:39', NULL, '2026-04-02 12:12:38', '迟到', '早退');
INSERT INTO `sign_record` VALUES (110, 2, '2026-04-02 16:51:46', NULL, NULL, '2026-04-02 16:51:46', '迟到', NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '12345', '管理员', 'admin@test.com', '超级管理员', '研发组', '14325345231', 'BioHazard 1', '2026-03-19 22:30:00', '启用', '2026-03-19 15:34:57', '2026-04-02 16:50:25', 'api/static/upload/avatars/1775103176803_avatar_1.jpg');
INSERT INTO `user` VALUES (2, 'test', 'test', 'test', 'test@test.test', '测试工程师', '研发组', '12312312321', 'testste', '2026-03-21 00:00:00', '启用', '2026-03-21 15:35:05', '2026-04-01 11:12:29', '');
INSERT INTO `user` VALUES (3, 'test2', 'tetstst', '特色t', 'test@test.com', '开发工程师', '研发组', '15432432413', '123', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-03-26 10:14:46', NULL);
INSERT INTO `user` VALUES (4, 'test3', 'tetstst', 'test3', 'test@qqq.qwe', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-03-26 10:27:00', NULL);
INSERT INTO `user` VALUES (5, 'teststtst', 'asdfasdfa', 'teststtst', 'asd@123.com', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-03-26 10:27:01', NULL);
INSERT INTO `user` VALUES (6, 'A_User_For_TEST', 'testtest', 'A_User_For_TEST', '123@123.com', '开发工程师', '研发组', '12312312321', 'I Want to Play DeathStranding', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-03-25 17:03:26', NULL);
INSERT INTO `user` VALUES (7, 'serser', 'serser', 'serser', '123@123.com', '超级管理员', '研发组', '14325345231', '123', '2026-03-21 00:00:00', '启用', '2026-03-22 15:35:13', '2026-04-01 11:37:59', NULL);
INSERT INTO `user` VALUES (8, '1231231', '123', '1231231', 'test@test.test', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-22 15:35:13', '2026-03-26 10:27:02', NULL);
INSERT INTO `user` VALUES (9, 'tetetetetet', 'tototototot', 'tetetetetet', 'test@test.test', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 15:35:31', '2026-03-26 10:27:03', NULL);
INSERT INTO `user` VALUES (10, 'tetoteto', 'tetetetetetete', 'tetoteto', 'teto@teto.com', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 15:35:34', '2026-03-26 10:27:05', NULL);
INSERT INTO `user` VALUES (13, '4141414', '1414141', '4141414', 'Test@test.com', '开发工程师', '研发组', '15432432413', NULL, NULL, '启用', '2026-03-23 17:43:07', '2026-03-26 10:27:06', NULL);
INSERT INTO `user` VALUES (24, '42', '42', '42', 'test@test.com', '开发工程师', '研发组', '14323453213', '42', '2026-03-19 22:30:00', '启用', '2026-03-30 12:19:43', NULL, NULL);
INSERT INTO `user` VALUES (31, '123', '123', '123', 'test@test.com', '开发工程师', '研发组', '14323453214', '43', '2026-03-20 22:30:00', '启用', '2026-04-01 15:28:33', NULL, NULL);
INSERT INTO `user` VALUES (32, '124', '124', '124', 'test@test.com', '开发工程师', '研发组', '14323453215', '44', '2026-03-21 22:30:00', '启用', '2026-04-01 15:28:33', NULL, NULL);
INSERT INTO `user` VALUES (33, '125', '125', '125', 'test@test.com', '开发工程师', '研发组', '14323453216', '45', '2026-03-22 22:30:00', '启用', '2026-04-01 15:28:33', NULL, NULL);
INSERT INTO `user` VALUES (34, '126', '126', '126', 'test@test.com', '开发工程师', '研发组', '14323453217', '46', '2026-03-23 22:30:00', '启用', '2026-04-01 15:28:33', NULL, NULL);
INSERT INTO `user` VALUES (35, '127', '127', '127', 'test@test.com', '开发工程师', '研发组', '14323453218', '47', '2026-03-24 22:30:00', '启用', '2026-04-01 15:28:33', NULL, NULL);
INSERT INTO `user` VALUES (36, '128', '128', '128', 'test@test.com', '开发工程师', '研发组', '14323453219', '48', '2026-03-25 22:30:00', '启用', '2026-04-01 15:28:33', NULL, NULL);

-- ----------------------------
-- Procedure structure for UpdateNoticeStatusByDate
-- ----------------------------
DROP PROCEDURE IF EXISTS `UpdateNoticeStatusByDate`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateNoticeStatusByDate`()
BEGIN
    -- 将所有 publishDate 小于或等于当前时间，且 status 还不是 '已发布'(或你的目标状态) 的记录更新
    -- 假设：目标状态值设为 'PUBLISHED'，你的初始状态可能是 'PENDING' 或 'DRAFT'
    UPDATE notice
    SET status = '已发布'  -- 替换成你想要修改成的状态值
    WHERE publishDate <= NOW()
      AND status != '已发布'; -- 避免重复更新，提高效率
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
