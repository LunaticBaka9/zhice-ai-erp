# 乡链 - 进销存管理系统

一个基于 Spring Boot + Vue 的进销存管理系统。

## 技术栈

### 后端

- Java 17
- Spring Boot 3.2.0
- MyBatis + PageHelper
- MySQL 5.7+
- JWT 认证

### 前端

- Vue 3.5
- Element Plus
- Vite
- Pinia
- Vue Router

## 环境要求

- JDK 17+
- Maven 3.6+
- MySQL 5.7+
- Node.js 18+

## 快速开始

### 1. 数据库初始化

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库
CREATE DATABASE testdb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

# 导入 SQL 文件
source database/testdb.sql
```

### 2. 后端配置

配置文件位于 `src/main/resources/application-dev.properties`：

```properties
# 数据库连接（根据实际情况修改）
spring.datasource.url=jdbc:mysql://localhost:3306/testdb
spring.datasource.username=root
spring.datasource.password=root

# JWT 密钥（生产环境请修改）
config.jwt.secret=YourSecureSecretKey
```

### 3. 启动后端

```bash
# 在项目根目录执行
./mvnw spring-boot:run

# 或打包后运行
./mvnw clean package
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

后端服务默认运行在 http://localhost:8080

### 4. 启动前端

```bash
cd Vue

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

前端服务默认运行在 http://localhost:5173

## 默认账号

| 角色     | 用户名 | 密码   |
| -------- | ------ | ------ |
| 管理员   | admin  | 123456 |
| 测试用户 | test   | test   |

## 项目结构

```
├── Vue/                      # Vue 前端项目
│   ├── src/
│   │   ├── components/       # 组件目录
│   │   │   ├── base/        # 基础数据管理（商品、客户、仓库等）
│   │   │   ├── inventory/   # 库存管理
│   │   │   ├── menu/       # 菜单组件
│   │   │   ├── notice/    # 公告管理
│   │   │   ├── purchase/   # 采购管理
│   │   │   ├── sales/     # 销售管理
│   │   │   └── system/    # 系统管理
│   │   ├── router/          # 路由配置
│   │   ├── store/          # Pinia 状态管理
│   │   ├── utils/          # 工具函数
│   │   └── views/          # 页面视图
│   │       └── login/      # 登录注册页
│   └── package.json
├── src/main/java/           # Java 后端代码
│   └── com/example/demo/
│       ├── controller/     # 控制器
│       ├── entity/         # 实体类
│       ├── mapper/         # MyBatis Mapper
│       ├── service/       # 业务逻辑
│       └── common/         # 公共类
├── database/               # 数据库 SQL 脚本
│   ├── testdb.sql         # 主数据库
│   └── sales/            # 销售模块
├── src/main/resources/
│   ├── mapper/           # MyBatis XML 映射文件
│   └── application*.properties  # 配置文件
└── pom.xml               # Maven 配置
```

## 主要功能模块

### 基础数据管理

- 商品管理：商品 SKU、分类、品牌、规格、价格
- 客户管理：客户信息、价格等级、信用额度
- 供应商管理
- 仓库管理
- 商品分类管理

### 库存管理

- 库存查询与预警
- 库存作业（入库、出库、调拨、盘点）
- 库存预警提醒

### 采购管理

- 采购订单
- 采购入库

### 销售管理

- 销售订单
- 销售发货

### 公告系统

- 公告发布与阅读

### 系统管理

- 用户管理
- 角色权限
- 系统菜单
- 操作日志

## API 接口

主要接口：`/api`

| 模块 | 接口路径          | 说明     |
| ---- | ----------------- | -------- |
| 登录 | `/api/login`      | 用户登录 |
| 注册 | `/api/register`   | 用户注册 |
| 商品 | `/api/goods/*`    | 商品管理 |
| 客户 | `/api/customer/*` | 客户管理 |
| 库存 | `/api/inventory*` | 库存管理 |
| 销售 | `/api/sale/*`     | 销售订单 |
| 公告 | `/api/notice/*`   | 公告管理 |
| 用户 | `/api/user/*`     | 用户管理 |

## 开发相关命令

```bash
# 后端打包
./mvnw clean package -DskipTests

# 前端构建生产版本
cd Vue && npm run build

# 运行测试
./mvnw test
```

## 注意事项

1. 首次运行需先创建数据库并导入 `database/testdb.sql`
2. 后端端口 8080，前端端口 5173，如遇端口冲突请修改配置文件
3. 生产环境请修改默认密码和 JWT 密钥
4. 前端代理配置在 `Vue/vite.config.js` 中

## 常见问题

**Q: 启动报错数据库连接失败**
A: 检查 MySQL 是否启动，确认数据库用户名密码配置正确

**Q: 前端请求 404**
A: 确认后端服务已启动，检查 Vite 代理配置

**Q: 登录失败**
A: 检查数据库是否正确导入，检查 JWT 配置是否一致
