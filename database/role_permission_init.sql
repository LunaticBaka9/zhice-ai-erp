-- 角色权限补全：已有库执行本脚本即可。
-- mysql -u root -p testdb < database/role_permission_init.sql

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- 1. 角色-菜单关联表（实体已有，原库缺失）
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `role_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色菜单关联ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` int NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_menu` (`role_id`,`menu_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户角色菜单关联表';

-- ---------------------------------------------------------------------------
-- 2. 补齐侧边栏已有、menu 表缺失的菜单
-- ---------------------------------------------------------------------------
INSERT INTO `menu` (`id`,`name`,`path`,`icon`,`description`,`pid`,`page_path`,`sort_num`,`status`) VALUES
(33,'会议管理','meeting','chat-square','会议相关操作',NULL,'/views/meeting/index',11,1),
(34,'发起会议','/meeting/create','chat-square','发起会议',33,'/views/meeting/create',1101,1),
(35,'会议列表','/meeting/index','chat-square','会议列表',33,'/views/meeting/index',1102,1),
(36,'部门列表','/dept/list','office-building','部门列表',26,'/views/dept/list',805,1),
(37,'职位管理','/system/post','office-building','职位管理',26,'/views/system/post',806,1),
(38,'AI助手','/ai/partner','chat-line-square','AI助手',NULL,'/views/ai/partner',12,1)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `path`=VALUES(`path`), `status`=VALUES(`status`);

-- ---------------------------------------------------------------------------
-- 3. 按钮权限树（type: 1目录 2菜单 3按钮）
-- ---------------------------------------------------------------------------
DELETE FROM `role_permission`;
DELETE FROM `permission`;

INSERT INTO `permission` (`id`,`parent_id`,`name`,`code`,`type`,`path`,`component`,`icon`,`sort`,`status`) VALUES
(1, 0, '工作台', 'dashboard', 1, '/', NULL, 'house', 1, 1),
(2, 1, '查看工作台', 'dashboard:view', 2, '/', NULL, 'house', 1, 1),

(10, 0, '系统公告', 'notice', 1, 'notice', NULL, 'notification', 2, 1),
(11, 10, '公告详情', 'notice:view', 2, '/notice/index', NULL, 'notification', 1, 1),
(12, 10, '公告发布', 'notice:post', 2, '/notice/post', NULL, 'notification', 2, 1),
(13, 10, '公告管理', 'notice:manage', 2, '/notice/manager', NULL, 'notification', 3, 1),
(14, 13, '新增公告', 'notice:add', 3, NULL, NULL, NULL, 1, 1),
(15, 13, '修改公告', 'notice:edit', 3, NULL, NULL, NULL, 2, 1),
(16, 13, '删除公告', 'notice:delete', 3, NULL, NULL, NULL, 3, 1),
(17, 13, '导出公告', 'notice:export', 3, NULL, NULL, NULL, 4, 1),

(20, 0, '基础资料', 'base', 1, 'base', NULL, 'goods', 3, 1),
(21, 20, '商品管理', 'goods:view', 2, '/base/goodsInfo', NULL, 'goods', 1, 1),
(22, 21, '新增商品', 'goods:add', 3, NULL, NULL, NULL, 1, 1),
(23, 21, '修改商品', 'goods:edit', 3, NULL, NULL, NULL, 2, 1),
(24, 21, '删除商品', 'goods:delete', 3, NULL, NULL, NULL, 3, 1),
(25, 21, '导出商品', 'goods:export', 3, NULL, NULL, NULL, 4, 1),
(26, 20, '供应商管理', 'supplier:view', 2, '/base/supplier', NULL, 'goods', 2, 1),
(27, 26, '新增供应商', 'supplier:add', 3, NULL, NULL, NULL, 1, 1),
(28, 26, '修改供应商', 'supplier:edit', 3, NULL, NULL, NULL, 2, 1),
(29, 26, '删除供应商', 'supplier:delete', 3, NULL, NULL, NULL, 3, 1),
(30, 20, '客户管理', 'customer:view', 2, '/base/customer', NULL, 'goods', 3, 1),
(31, 30, '新增客户', 'customer:add', 3, NULL, NULL, NULL, 1, 1),
(32, 30, '修改客户', 'customer:edit', 3, NULL, NULL, NULL, 2, 1),
(33, 30, '删除客户', 'customer:delete', 3, NULL, NULL, NULL, 3, 1),
(34, 20, '仓库管理', 'warehouse:view', 2, '/base/warehouse', NULL, 'goods', 4, 1),
(35, 34, '新增仓库', 'warehouse:add', 3, NULL, NULL, NULL, 1, 1),
(36, 34, '修改仓库', 'warehouse:edit', 3, NULL, NULL, NULL, 2, 1),
(37, 34, '删除仓库', 'warehouse:delete', 3, NULL, NULL, NULL, 3, 1),

(50, 0, '销售管理', 'sale', 1, 'sale', NULL, 'shopping-bag', 4, 1),
(51, 50, '销售订单', 'sale:order', 2, '/sale/order', NULL, 'shopping-bag', 1, 1),
(52, 51, '新增销售订单', 'sale:add', 3, NULL, NULL, NULL, 1, 1),
(53, 51, '修改销售订单', 'sale:edit', 3, NULL, NULL, NULL, 2, 1),
(54, 51, '删除销售订单', 'sale:delete', 3, NULL, NULL, NULL, 3, 1),
(55, 50, '销售发货', 'sale:delivery', 2, '/sale/delivery', NULL, 'shopping-bag', 2, 1),
(56, 55, '确认发货', 'sale:deliver', 3, NULL, NULL, NULL, 1, 1),

(70, 0, '采购管理', 'purchase', 1, 'purchase', NULL, 'shopping-cart', 5, 1),
(71, 70, '采购订单', 'purchase:order', 2, '/purchase/order', NULL, 'shopping-cart', 1, 1),
(72, 71, '新增采购订单', 'purchase:add', 3, NULL, NULL, NULL, 1, 1),
(73, 71, '修改采购订单', 'purchase:edit', 3, NULL, NULL, NULL, 2, 1),
(74, 71, '删除采购订单', 'purchase:delete', 3, NULL, NULL, NULL, 3, 1),
(75, 70, '采购入库', 'purchase:inbound', 2, '/purchase/inbound', NULL, 'shopping-cart', 2, 1),
(76, 75, '确认入库', 'purchase:inbound:confirm', 3, NULL, NULL, NULL, 1, 1),
(77, 70, '采购单据查询', 'purchase:query', 2, '/purchase/query', NULL, 'shopping-cart', 3, 1),

(90, 0, '库存管理', 'inventory', 1, 'inventory', NULL, 'box', 6, 1),
(91, 90, '库存查询', 'inventory:query', 2, '/inventory/query', NULL, 'box', 1, 1),
(92, 90, '仓库作业', 'inventory:operation', 2, '/inventory/operation', NULL, 'box', 2, 1),
(93, 92, '新增作业', 'inventory:operation:add', 3, NULL, NULL, NULL, 1, 1),
(94, 90, '库存预警', 'inventory:warning', 2, '/inventory/warning', NULL, 'box', 3, 1),

(110, 0, '会议管理', 'meeting', 1, 'meeting', NULL, 'chat-square', 7, 1),
(111, 110, '发起会议', 'meeting:create', 2, '/meeting/create', NULL, 'chat-square', 1, 1),
(112, 110, '会议列表', 'meeting:view', 2, '/meeting/index', NULL, 'chat-square', 2, 1),
(113, 112, '删除会议', 'meeting:delete', 3, NULL, NULL, NULL, 1, 1),

(120, 0, '报表分析', 'report', 1, 'report', NULL, 'pie-chart', 8, 1),
(121, 120, '核心报表', 'report:core', 2, '/report/core', NULL, 'pie-chart', 1, 1),
(122, 120, '销售分析', 'report:sales', 2, '/report/sales', NULL, 'pie-chart', 2, 1),
(123, 120, '库存分析', 'report:inventory', 2, '/report/inventory', NULL, 'pie-chart', 3, 1),

(130, 0, '组织管理', 'org', 1, '/dept', NULL, 'office-building', 9, 1),
(131, 130, '部门列表', 'dept:view', 2, '/dept/list', NULL, 'office-building', 1, 1),
(132, 131, '新增部门', 'dept:add', 3, NULL, NULL, NULL, 1, 1),
(133, 131, '修改部门', 'dept:edit', 3, NULL, NULL, NULL, 2, 1),
(134, 131, '删除部门', 'dept:delete', 3, NULL, NULL, NULL, 3, 1),
(135, 130, '用户管理', 'user:view', 2, '/system/user', NULL, 'setting', 2, 1),
(136, 135, '新增用户', 'user:add', 3, NULL, NULL, NULL, 1, 1),
(137, 135, '修改用户', 'user:edit', 3, NULL, NULL, NULL, 2, 1),
(138, 135, '删除用户', 'user:delete', 3, NULL, NULL, NULL, 3, 1),
(139, 130, '职位管理', 'post:view', 2, '/system/post', NULL, 'setting', 3, 1),
(140, 139, '新增职位', 'post:add', 3, NULL, NULL, NULL, 1, 1),
(141, 139, '修改职位', 'post:edit', 3, NULL, NULL, NULL, 2, 1),
(142, 139, '删除职位', 'post:delete', 3, NULL, NULL, NULL, 3, 1),
(143, 130, '角色管理', 'role:view', 2, '/system/role', NULL, 'setting', 4, 1),
(144, 143, '新增角色', 'role:add', 3, NULL, NULL, NULL, 1, 1),
(145, 143, '修改角色', 'role:edit', 3, NULL, NULL, NULL, 2, 1),
(146, 143, '删除角色', 'role:delete', 3, NULL, NULL, NULL, 3, 1),
(147, 143, '分配菜单', 'role:assignMenu', 3, NULL, NULL, NULL, 4, 1),
(148, 143, '分配权限', 'role:assignPermission', 3, NULL, NULL, NULL, 5, 1),

(170, 0, '系统管理', 'system', 1, '/system', NULL, 'setting', 10, 1),
(171, 170, '菜单管理', 'menu:view', 2, '/system/menu', NULL, 'setting', 1, 1),
(172, 171, '新增菜单', 'menu:add', 3, NULL, NULL, NULL, 1, 1),
(173, 171, '修改菜单', 'menu:edit', 3, NULL, NULL, NULL, 2, 1),
(174, 171, '删除菜单', 'menu:delete', 3, NULL, NULL, NULL, 3, 1),
(175, 170, '操作日志', 'log:view', 2, '/monitor/operationLog', NULL, 'setting', 2, 1),

(180, 0, '消息中心', 'message', 1, '/message', NULL, 'message', 11, 1),
(181, 180, '查看消息', 'message:view', 2, '/message', NULL, 'message', 1, 1),

(190, 0, 'AI助手', 'ai', 1, '/ai/partner', NULL, 'chat-line-square', 12, 1),
(191, 190, '使用AI助手', 'ai:use', 2, '/ai/partner', NULL, 'chat-line-square', 1, 1),

(200, 0, '个人主页', 'userinfo', 1, '/userInfo', NULL, 'avatar', 13, 1),
(201, 200, '查看个人主页', 'userinfo:view', 2, '/userInfo', NULL, 'avatar', 1, 1);

-- ---------------------------------------------------------------------------
-- 4. 角色-菜单：超管全量，业务角色按模块
-- ---------------------------------------------------------------------------
DELETE FROM `role_menu`;

-- 超级管理员、系统管理员：全部菜单
INSERT INTO `role_menu` (`role_id`,`menu_id`) SELECT 1, `id` FROM `menu`;
INSERT INTO `role_menu` (`role_id`,`menu_id`) SELECT 2, `id` FROM `menu`;

-- 采购管理员/采购员：工作台、基础、采购、库存、消息、个人主页
INSERT INTO `role_menu` (`role_id`,`menu_id`)
SELECT r, m FROM
  (SELECT 3 AS r UNION SELECT 11) roles,
  (SELECT id AS m FROM menu WHERE id IN (1,6,7,8,9,10,14,15,16,17,18,19,20,21,31,32)) menus;

-- 仓储管理员/仓管员
INSERT INTO `role_menu` (`role_id`,`menu_id`)
SELECT r, m FROM
  (SELECT 5 AS r UNION SELECT 13) roles,
  (SELECT id AS m FROM menu WHERE id IN (1,6,7,10,18,19,20,21,31,32)) menus;

-- 销售管理员/销售员
INSERT INTO `role_menu` (`role_id`,`menu_id`)
SELECT r, m FROM
  (SELECT 6 AS r UNION SELECT 14) roles,
  (SELECT id AS m FROM menu WHERE id IN (1,6,9,11,12,13,22,24,31,32)) menus;

-- 财务管理员/财务人员
INSERT INTO `role_menu` (`role_id`,`menu_id`)
SELECT r, m FROM
  (SELECT 8 AS r UNION SELECT 17) roles,
  (SELECT id AS m FROM menu WHERE id IN (1,17,22,23,24,25,31,32)) menus;

-- 综合管理
INSERT INTO `role_menu` (`role_id`,`menu_id`)
SELECT 9, id FROM menu WHERE id IN (1,2,3,4,5,26,27,28,29,30,31,32,33,34,35,36,37);

-- 普通员工：工作台、公告详情、消息、个人主页
INSERT INTO `role_menu` (`role_id`,`menu_id`)
SELECT 18, id FROM menu WHERE id IN (1,2,3,31,32);

-- ---------------------------------------------------------------------------
-- 5. 角色-权限：超管全量，其余按编码前缀
-- 列名 permision_id 与现有表保持一致
-- ---------------------------------------------------------------------------
INSERT INTO `role_permission` (`role_id`,`permision_id`) SELECT 1, `id` FROM `permission`;
INSERT INTO `role_permission` (`role_id`,`permision_id`) SELECT 2, `id` FROM `permission`;

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 3, id FROM permission WHERE code LIKE 'dashboard%' OR code LIKE 'base%' OR code LIKE 'goods%' OR code LIKE 'supplier%' OR code LIKE 'customer%' OR code LIKE 'warehouse%' OR code LIKE 'purchase%' OR code LIKE 'inventory%' OR code LIKE 'message%' OR code LIKE 'userinfo%';

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 11, id FROM permission WHERE code LIKE 'dashboard%' OR code LIKE 'goods%' OR code LIKE 'supplier%' OR code LIKE 'purchase%' OR code LIKE 'userinfo%';

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 5, id FROM permission WHERE code LIKE 'dashboard%' OR code LIKE 'warehouse%' OR code LIKE 'inventory%' OR code LIKE 'goods:view' OR code LIKE 'message%' OR code LIKE 'userinfo%';

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 13, id FROM permission WHERE code LIKE 'dashboard%' OR code LIKE 'warehouse%' OR code LIKE 'inventory%' OR code LIKE 'userinfo%';

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 6, id FROM permission WHERE code LIKE 'dashboard%' OR code LIKE 'customer%' OR code LIKE 'sale%' OR code LIKE 'report%' OR code LIKE 'message%' OR code LIKE 'userinfo%';

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 14, id FROM permission WHERE code LIKE 'dashboard%' OR code LIKE 'customer%' OR code LIKE 'sale%' OR code LIKE 'userinfo%';

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 8, id FROM permission WHERE code LIKE 'dashboard%' OR code LIKE 'report%' OR code LIKE 'purchase:query' OR code LIKE 'userinfo%';

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 17, id FROM permission WHERE code LIKE 'dashboard%' OR code LIKE 'report%' OR code LIKE 'userinfo%';

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 9, id FROM permission WHERE code LIKE 'dashboard%' OR code LIKE 'notice%' OR code LIKE 'meeting%' OR code LIKE 'org%' OR code LIKE 'dept%' OR code LIKE 'user%' OR code LIKE 'post%' OR code LIKE 'role%' OR code LIKE 'message%' OR code LIKE 'userinfo%';

INSERT INTO `role_permission` (`role_id`,`permision_id`)
SELECT 18, id FROM permission WHERE code IN ('dashboard','dashboard:view','notice','notice:view','message','message:view','userinfo','userinfo:view');
