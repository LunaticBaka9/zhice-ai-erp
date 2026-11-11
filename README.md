# 乡链 · 进销存管理系统

Spring Boot + Vue 的进销存系统，覆盖商品、库存、采购、销售，以及组织与权限。另有 UniApp 移动端，接口与 Web 共用。

## 能做什么

| 模块 | 内容 |
| --- | --- |
| 基础资料 | 商品、分类、供应商、客户、仓库 |
| 库存 | 查询、出入库/调拨/盘点作业、库存预警 |
| 采购 | 采购订单、采购入库、单据查询 |
| 销售 | 销售订单、销售发货 |
| 组织 | 部门、用户、职位、角色、菜单 |
| 协同 | 公告、消息中心、会议 |
| 报表 | 核心报表、销售分析、库存分析 |
| 系统 | 操作日志、AI 助手（需自行配置 DeepSeek API Key） |

侧边栏按当前用户的角色显示。超级管理员看到全部菜单；其他角色只看到已分配的菜单。工作台和个人主页始终可进。

## 技术栈

- 后端：Java 21、Spring Boot 4、MyBatis-Plus、JWT、MySQL 8、Redis 8
- Web：Vue 3.5、Element Plus、Vite、Pinia、Vue Router
- 移动端：UniApp（与 Web 共用后端）

## 环境

- JDK 21
- Maven 3.6+（可用仓库内 `back/mvnw`）
- MySQL 8
- Redis 8
- Node.js 18+

## 快速开始

### 1. 准备数据库

```sql
CREATE DATABASE testdb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```

```bash
# 导入主库
mysql -u root -p testdb < database/testdb.sql

# 补齐角色-菜单、角色-权限（已有库也执行这一条）
mysql -u root -p testdb < database/role_permission_init.sql
```

若 MySQL 跑在 Docker 里：

```bash
docker exec -i <mysql容器名> mysql -uroot -proot testdb < database/testdb.sql
docker exec -i <mysql容器名> mysql -uroot -proot testdb < database/role_permission_init.sql
```

只导入 `testdb.sql`、不跑第二份脚本时，角色可以增删改，但分配菜单会因缺表或缺权限数据失败，侧边栏也无法按角色过滤。

### 2. 核对后端配置

开发配置在 `back/src/main/resources/application-dev.yml`，按本机修改：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/testdb?serverTimezone=Asia/Shanghai&useUnicode=true&characterEncoding=utf8&useSSL=true
    username: root
    password: root
  data:
    redis:
      host: 127.0.0.1
      port: 6379

config:
  jwt:
    secret: 请换成至少 64 字符的密钥
    expire: 86400
```

激活的 profile 是 `dev`（见 `application.yml`）。

### 3. 启动后端

```bash
cd back
./mvnw spring-boot:run
```

或：

```bash
cd back
./mvnw clean package -DskipTests
java -jar target/zhice-ai-erp-0.0.1.jar
```

后端：http://localhost:8080

### 4. 启动 Web 前端

```bash
cd vue
npm install
npm run dev
```

前端：http://localhost:5173  
Vite 把 `/api` 代理到 `8080`，并去掉 `/api` 前缀，所以浏览器请求 `/api/login`，后端实际收到 `/login`。

### 5. 启动 UniApp（可选）

```bash
cd uniapp
npm install
npm run dev:h5
```

同样走 `/api` → `8080`。微信小程序用 `npm run dev:mp-weixin`。

## 默认账号

| 说明 | 用户名 | 密码 |
| --- | --- | --- |
| 超级管理员 | admin | 123456 |

库里还有 `test`、`admin1` 等演示账号，密码以当前 `user` 表为准。生产环境请改掉默认密码和 JWT 密钥。

## 角色权限怎么用

1. **部门管理 → 角色列表**：维护角色；给角色勾选菜单和按钮权限。
2. **用户列表**：给用户指定角色（同时写入角色 ID 和名称）。
3. 该用户重新登录后，侧边栏只保留已分配菜单。
4. 系统角色（如超级管理员）不能删除。新增角色必须填写名称和编码，编码唯一。

菜单管「能看见哪些页面」，权限码管按钮（如 `role:add`、`goods:edit`）。后端目前按登录态鉴权，不按权限码拦截每一个 URL。

## 两条主业务链

采购：

```
采购订单（草稿）→ 确认 → 生成入库单 → 确认入库 → 库存增加
```

销售：

```
销售订单（草稿）→ 确认 → 生成出库单 → 确认出库 → 库存减少
```

## 目录

```
├── back/                      后端（Spring Boot）
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/lunabaka/  controller / service / entity / mapper
│       └── resources/          application-*.yml、MyBatis XML
├── vue/                       Web 前端
│   └── src/
│       ├── api/               接口封装
│       ├── components/        页面（登录、基础资料、进销存、部门、系统等）
│       ├── router/
│       ├── store/             Pinia（含当前用户菜单与权限）
│       └── utils/
├── uniapp/                    移动端
├── database/
│   ├── testdb.sql             全库结构与演示数据
│   └── role_permission_init.sql  角色菜单 / 权限初始数据
└── README.md
```

## 接口

前端开发时统一加 `/api` 前缀。后端映射不含 `/api`。

| 模块 | 后端路径 | 说明 |
| --- | --- | --- |
| 登录 / 注册 | `/login`、`/register` | 账号登录、注册；另有邮箱验证码登录 |
| 用户 | `/user/*` | 用户 CRUD、导入导出 |
| 角色 | `/role/*` | 角色 CRUD、分配菜单/权限、当前用户菜单 |
| 权限树 | `/permission/tree` | 按钮权限树 |
| 菜单 | `/menu/*` | 系统菜单 |
| 商品 / 客户 / 库存 / 销售 / 采购 / 公告 | `/goods/*`、`/customer/*`、`/inventory*`、`/sale/*`、`/purchase*`、`/notice/*` | 对应业务 |

开发环境 OpenAPI：http://localhost:8080/swagger-ui.html

AI 助手不在配置文件里写 API Key。用户在「AI 助手 → API Key 设置」里保存自己的 DeepSeek Key，后端按用户写入 Redis。

## 常用命令

```bash
# 后端打包
cd back && ./mvnw clean package -DskipTests

# Web 生产构建
cd vue && npm run build

# 后端测试（仓库内测试很少）
cd back && ./mvnw test
```

## 常见问题

**数据库连不上**  
确认 MySQL 已启动，且 `application-dev.yml` 里的库名、账号、密码与本机一致。

**前端请求 404**  
先开后端。代理在 `vue/vite.config.js`（UniApp 在 `uniapp/vite.config.js`）。

**登录失败**  
确认已导入 `testdb.sql`。JWT `secret` 改过之后，旧 token 会失效，重新登录即可。

**分配菜单报错 / 侧边栏不按角色变化**  
补跑 `database/role_permission_init.sql`，然后重新登录。

**端口被占用**  
后端改 `application-dev.yml` 的 `server.port`，前端改 Vite 端口。

**跑一段时间后接口全 500**  
开发配置里已关掉 Spring DevTools 自动重启，避免编译中途重启导致 Mapper 丢失。不要在 `application-dev.yml` 里重新打开 `spring.devtools.restart.enabled`。
