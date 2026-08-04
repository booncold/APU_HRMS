# APU Hotel Room Management System (APU-HRMS)

## 项目计划与规格总览（讨论锁定版 + 实现进度）

| 项 | 内容 |
|---|---|
| 模块 | CT027-3-3 EPDA（Enterprise Programming for Distributed Applications） |
| 系统名称 | APU Hotel Room Management System（APU-HRMS） |
| 工程形态 | **单模块 Maven WAR**（非 EAR/EJB/WAR 多模块） |
| 文档日期 | 2026-08-05 |
| 状态 | M1–M8 功能已实现；进入演示与文档打磨 |

本文汇总：作业要求、Assumptions、双方讨论决议、技术架构、领域模型、功能清单、UI 约定、里程碑、种子数据与当前进度。

---

## 1. 作业目标概览

### 1.1 业务目标

实现一套 **多角色、需登录** 的酒店客房管理系统，覆盖：

- 人员管理（经理 / 前台 / 清洁员 / 顾客）
- 分级客房与定价
- 预订（一单多房）、全额预付、收据
- Check-in / Check-out
- 清洁任务
- 反馈与评论（含可选点名 staff）
- 经理报表（5 份 + 图表）
- 忘记密码（真发 Gmail SMTP 邮件）与登录后改密

### 1.2 酒店规模（锁定）

| 项 | 值 |
|---|---|
| 楼层 | 5 |
| 每层房间 | 10 |
| 总房间 | **50** |
| 房型分布 | **30 STANDARD / 15 VIP / 5 PRESIDENTIAL** |
| 默认房价 | STANDARD RM250 / VIP RM350 / PRESIDENTIAL RM500（每晚） |
| 改价规则 | **不影响已有预订**（订单行保存价格快照） |

### 1.3 用户角色（4 种）

| 角色 | 说明 |
|---|---|
| `MANAGER` | 管理员工、房价、查看反馈/评论、报表 |
| `COUNTER_STAFF` | 管理顾客、代订、CI/CO、派清洁、收款 |
| `HOUSEKEEPER` | 查看/完成清洁任务、按房间写反馈 |
| `CUSTOMER` | 自助预订/取消、历史、评论 |

**全局规则：** 所有用户必须登录；按角色授权访问。

### 1.4 评分与交付（来自作业 / Assumptions）

| 部分 | 权重（Assumptions 口径） | 说明 |
|---|---|---|
| Implementation（应用） | ~37.5–50% | JSP + Servlet + Entity + Facade |
| Part 1 研究报告 | ~15–20% | Next.js vs TanStack Start 等 |
| Part 2 系统文档 | ~20% | 架构、EJB、DB、UML、额外功能证据 |
| Presentation | ~7.5–10% | 演示、理解代码、可改代码 |

**实现技术硬性要求（Assumptions）：**

- JSP + Servlet + Entity（建表）+ Facade 访问数据库  
- 完整用户输入校验  
- 所有用户必须登录  

**官方技术表述（对齐）：**

- Presentation：JSP/JSF + Servlet 校验  
- Business：EJB + JDBC/JPA  
- Database：任意（本项目 MySQL + JTA DataSource）

---

## 2. 工程与架构决策

### 2.1 打包形态：单 WAR（已确认）

**不**采用朋友工程的 `EAR + EJB + WAR` 三模块拆分。

| 朋友结构 | 本项目对应 |
|---|---|
| EJB 模块（Entity + Session Bean） | `com.apu.hrms.entity` + `facade` |
| WAR 模块（Servlet + JSP） | `servlet` + `webapp` |
| EAR 打包 | 直接部署 `*.war` 到 Jakarta EE 服务器 |

逻辑上仍是 **三层架构**，物理上在一个 WAR 内：

```
Presentation  →  Servlet + JSP (+ JSTL)
Business      →  @Stateless EJB Facade
Persistence   →  JPA Entity + EntityManager
Database      →  MySQL（示例库名 apu_hrms）
```

### 2.2 技术栈（当前工程）

| 项 | 选择 |
|---|---|
| Java | 21 |
| Jakarta EE | 11 API（provided） |
| Packaging | `war` |
| 视图 | JSP + JSTL |
| 业务 | EJB `@Stateless` Facade |
| 持久化 | JPA / Hibernate（`hbm2ddl.auto=update`） |
| 数据源 | `java:/jdbc/APUHRMSDS` |
| 密码 | SHA-256（`PasswordUtil`） |
| 服务器 | WildFly 等 Jakarta EE 容器 |

### 2.3 代码组织原则（讨论确认）

- **单 WAR ≠ 单文件**：按职责拆成多小文件。  
- Servlet：HTTP、校验、转发；不写复杂 SQL。  
- Facade：业务规则、事务、查询。  
- Entity：表映射。  
- JSP：展示；共用 layout / CSS。  
- util：校验、电话、密码、Session、权限等 **可复用**。

目标包结构：

```
com.apu.hrms
├── entity/
├── facade/
├── servlet/          # auth, manager, counter, housekeeper, customer...
├── filter/
├── listener/
└── util/

webapp/
├── assets/css/       # theme.css, layout.css
├── assets/images/
└── WEB-INF/views/
    ├── common/       # layout, sidebar
    ├── auth/
    ├── manager/
    ├── counter/
    ├── housekeeper/
    └── customer/
```

---

## 3. 已锁定的业务设计决策

| # | 主题 | 决议 |
|---|---|---|
| 1 | 房价 | 分级定价；改价不影响已有预订（快照价） |
| 2 | 预订窗口 | **仅入住日**须在今天起 **未来 5 天内**；不限制最长晚数；不要求整段 stay 落在 5 天内 |
| 3 | Customer 预订 | Customer **可自助预订**；**Check-in 仅 Counter**；Counter 有「今日待 Check-in」列表 + 按钮 |
| 4 | Manager 权限 | **仅 seed Manager**（`seedAdmin=true`）可管其他 Manager；**不能删自己**；非 seed **完全不能碰 Manager 账号** |
| 5 | 付款 | **全额预付**；Counter 代订与 Customer 自订均进 Payment Detail；付款成功后收据 |
| 6 | Feedback / Comment | **分表** |
| 7 | 评论点名 staff | **需要**；可选、可多选；仅本单相关 Counter + 相关房 HK；可不点名只评服务 |
| 8 | Feedback | **必须关联房间**（无 Room 不可提交） |
| 9 | 房间编号 | 必须有编号（如 101–510）；CI/CO 列表显示具体房号 |
| 10 | 多房订单 | **一个订单号，多房间**；预订时 **立刻占具体房间** |
| 11 | 取消预订 | **仅 Customer**；仅整单仍为 `RESERVED`（未 Check-in）；提示「退款 3 天内原路退回」（演示级，非真实支付网关） |
| 12 | Check-out | **不再收款**；只改状态 + 触发清洁 |
| 13 | 一单日期 | **统一入住日/离店日/晚数**（订单级一致） |
| 14 | 取消粒度 | **整单取消** |
| 15 | Housekeeper 可用 | **无未完成 ASSIGNED 任务** 即为可用 |
| 16 | 密码规则 | ≥8 位，含字母和数字 |
| 17 | 订单号 | 如 `ORD-yyyyMMdd-XXXX` |
| 18 | 收据号 | 如 `RCP-yyyyMMdd-XXXX` |
| 19 | 删除用户 | **软删除**；并释放 email/IC 唯一键（避免删了不能重注册） |
| 20 | Email 校验 | **通用合法 email**；seed 示例全用 `@gmail.com` |
| 21 | Phone | 展示 `+60 1XXXXXXXX`；**存储无空格** `+601XXXXXXXX` |
| 22 | IC | `XXXXXX-XX-XXXX` |
| 23 | 改密 | **两套**：登录页 Forgot Password（邮件）+ 登录后 Change Password |
| 24 | SMTP | **Gmail**；本地配置；不做假发送开发模式 |
| 25 | UI 主题 | 全角色 **统一暖色酒店风**（Counter 不单独用绿色系） |
| 26 | Sidebar | 功能入口在上；**Logout 固定在底部**（与功能入口分离） |
| 27 | Extra 功能 | 能做的正向功能尽量做（见第 8 节） |
| 28 | Staff 列表 UI | **按职位分表**（Managers / Counter Staff / Housekeepers） |

---

## 4. 状态机（全部保留）

### 4.1 Room

```
AVAILABLE → BOOKED → OCCUPIED → NEEDS_CLEANING → AVAILABLE
```

| 时机 | 状态变化 |
|---|---|
| 预订成功占房 | → `BOOKED` |
| Check-in | → `OCCUPIED` |
| Check-out | → `NEEDS_CLEANING` |
| 清洁完成 | → `AVAILABLE` |
| 取消预订 | → `AVAILABLE`（释放） |

### 4.2 BookingOrder（订单级，可汇总）

```
PENDING_PAYMENT → CONFIRMED → PARTIAL_CHECKED_IN → CHECKED_IN → CHECKED_OUT
                ↘ CANCELLED
```

### 4.3 BookingRoom（订单行 = 一间具体房）

```
RESERVED → CHECKED_IN → CHECKED_OUT
RESERVED → CANCELLED
```

### 4.4 Payment

```
PENDING → PAID
（取消后可展示 REFUND_PENDING）
```

### 4.5 CleaningTask

```
ASSIGNED → COMPLETED
```

---

## 5. 领域模型

### 5.1 实体一览

| 实体 | 说明 |
|---|---|
| `User` | 四角色用户；`seedAdmin`、`deleted`、时间戳 |
| `Room` | 房号、楼层、类型、当前价、状态 |
| `BookingOrder` | 订单号、顾客、创建者、可选 counter、日期、总额、状态 |
| `BookingRoom` | 一单多房的一行；房号快照、价格快照、行状态 |
| `Payment` | 关联订单、金额、状态、收据号、支付方式 |
| `CleaningTask` | 房间、HK、指派人、状态、时间 |
| `Feedback` | HK 写；**强制 room** |
| `Comment` | Customer 对订单评论 |
| `CommentMention` | 评论点名 staff（可选多条） |
| `PasswordResetToken` | 忘记密码 token |

### 5.2 枚举

- `UserRole`：MANAGER, COUNTER_STAFF, HOUSEKEEPER, CUSTOMER  
- `RoomType`：STANDARD, VIP, PRESIDENTIAL（带默认价）  
- `RoomStatus`：AVAILABLE, BOOKED, OCCUPIED, NEEDS_CLEANING  
- `OrderStatus`：PENDING_PAYMENT, CONFIRMED, PARTIAL_CHECKED_IN, CHECKED_IN, CHECKED_OUT, CANCELLED  
- `BookingRoomStatus`：RESERVED, CHECKED_IN, CHECKED_OUT, CANCELLED  
- `PaymentStatus`：PENDING, PAID, REFUND_PENDING  
- `CleaningTaskStatus`：ASSIGNED, COMPLETED  

### 5.3 房间编号与分布（Seed）

- 编号：`{floor}01`–`{floor}10` → 101–110 … 501–510  
- 1–3 层：全部 STANDARD（30）  
- 4 层：全部 VIP（10）  
- 5 层：501–505 VIP；506–510 PRESIDENTIAL  

---

## 6. 按角色功能清单

### 6.1 全局

| 功能 | 说明 | 状态 |
|---|---|---|
| 登录 / 登出 | Session；角色路由 | ✅ 已有 |
| 鉴权 Filter | 未登录拦截 | ✅ |
| 角色 Filter | 禁止跨角色 URL | ✅ |
| 完整表单校验 | IC / Phone / Email / Password 等 | ✅ 人员模块；业务表单后续补全 |
| Profile 占位 | 后续改资料 | ✅ M8 完整资料编辑 |
| Forgot Password | 真 Gmail SMTP | ✅ M8（未配 SMTP 时演示链接） |
| Change Password | 登录后旧密码改新 | ✅ M8 |

### 6.2 Manager

| 功能 | 说明 | 状态 |
|---|---|---|
| 预注册 seed Manager | `seedAdmin=true` | ✅ |
| 注册 Staff（3 类） | Manager 仅 seed 可建 | ✅ |
| 搜索 / 更新 / 删除 Staff | 按角色分表；软删除 | ✅ |
| 设置房价 | 按房/类型改 `currentPrice` | ✅ M4 |
| 查看全部 Feedback | | ✅ M8 |
| 查看全部 Comment | | ✅ M8 |
| 5 个报表 + 图表 | 见 6.6 | ✅ M8 |

### 6.3 Counter Staff

| 功能 | 说明 | 状态 |
|---|---|---|
| 编辑个人资料 | | ✅ M8（Profile） |
| 注册 / 搜 / 改 / 删 Customer | | ✅ |
| 代客预订（5 天内入住、多房） | | ✅ M4 |
| 付款页 Payment Detail | | ✅ M4 |
| 今日 Check-in（显示房号） | | ✅ M5 |
| Check-out（显示房号） | | ✅ M5 |
| 指派清洁任务给可用 HK | | ✅ M6 |
| 收据 PDF / 打印 | | ✅ M4 打印友好页 |

### 6.4 Housekeeper

| 功能 | 说明 | 状态 |
|---|---|---|
| 编辑个人资料 | | ✅ M8（Profile） |
| 查看我的任务 | | ✅ M6 |
| 完成任务 | → 房间 AVAILABLE | ✅ M6 |
| 按房间写 Feedback | room 必填 | ✅ M6 |

### 6.5 Customer

| 功能 | 说明 | 状态 |
|---|---|---|
| 编辑个人资料 | | ✅ M8（Profile） |
| 自助预订（日期、晚数、多间具体房） | | ✅ M4 |
| 付款成功页 | | ✅ M4 |
| 取消预订（RESERVED） | 退款文案 3 天 | ✅ M7 |
| 预订 / 支付历史 | | ✅ M4 |
| 对 booking 评论 + 可选点名 staff | | ✅ M7 |
| 收据查看 / 打印 | | ✅ M4 |

### 6.6 经理报表（5 个 + 图表，建议锁定）

1. 入住率（按日期 / 楼层 / 房型）— 柱状/折线  
2. 收入汇总（按日/周/月）— 柱状/折线  
3. 预订状态分布 — 饼图  
4. Housekeeper 任务完成量 — 柱状  
5. 反馈/评论数量或客户活跃 — 柱状/饼图  

色板：`#a8793d`、`#2b241d`、`#6f6458` 等。

---

## 7. 核心业务流程

### 7.1 Counter 代客预订

```
选客户 → 选入住日(≤+5天) / 晚数 → 选多间具体房
  → Payment Detail（房型、房号、日期、快照单价、合计）
  → 付款成功 → 收据(PDF/打印)
  → 订单 CONFIRMED；房间 BOOKED
```

### 7.2 Customer 自助预订

```
选日期/晚数/多房 → 付款 → 成功页 + 收据
  → 可取消（仅 RESERVED）
  → 到店由 Counter Check-in
```

### 7.3 到店 / 离店 / 清洁

```
Counter：今日 CI 列表（房号）→ Check-in → OCCUPIED
Counter：Check-out → CHECKED_OUT + NEEDS_CLEANING
Counter：派可用 HK → Task ASSIGNED
HK：完成 → COMPLETED → 房间 AVAILABLE
HK：可对该房写 Feedback
```

### 7.4 评论点名

Customer 对某订单写 Comment：

- 可不点名  
- 可多选：本单 `counterStaff` + 本单相关房清洁 HK  

Manager 可查看全部 Comment 与 Feedback。

---

## 8. Extra / 正向功能清单

讨论确认：能做的都做，作为加分与文档「至少 2 个额外功能」证据。

| 功能 | 说明 | 状态 |
|---|---|---|
| 密码哈希 | SHA-256 | ✅ |
| Auth + Role Filter | | ✅ |
| 软删除 + 释放唯一键 | 删后可重注册同 email | ✅ |
| 房间搜索过滤器 | 类型/楼层/状态 | ✅ M4 |
| 收据 PDF / 打印友好页 | 付款后提供 | ✅ M4 打印页 |
| 报表图表 | Chart.js 等 | ✅ M8 |
| 取消预订 | Customer | ✅ M7 |
| Customer 自助预订 | | ✅ M4 |
| 评论点名 staff | | ✅ M7 |
| 房间分级定价 + 快照 | 改价 + 下单快照 | ✅ M4 |
| 真邮件重置密码 | Gmail SMTP | ✅ M8 |
| Staff 按角色分表 UI | | ✅ |

---

## 9. UI / UX 规范

### 9.1 主题（沿用 login 暖色酒店风）

| 用途 | 值 |
|---|---|
| 主文字 | `#2b241d` |
| 次要文字 | `#6f6458` / `#75695d` |
| 强调色 | `#a8793d` |
| 强调悬停 | `#865c2c` |
| 页面底 | `#f3efe8` |
| 侧栏 | `#2b241d` |
| 卡片/表 | 白底、圆角 8px、暖边框 |
| 标题字体 | Georgia |
| 正文字体 | Arial |
| 品牌 | 文本 `APU Hotel`，`APU` 用 accent |

公共文件：`assets/css/theme.css`、`layout.css`；`views/common/layout-top.jsp` / `sidebar.jsp` / `layout-bottom.jsp`。

### 9.2 Sidebar 结构（按角色）

**共同：** 品牌 → 用户名/角色 → 功能菜单 → **底部 Profile + Logout**

| Manager | Counter | Housekeeper | Customer |
|---|---|---|---|
| Dashboard | Dashboard | Dashboard | Dashboard |
| Add Staff | Customers | My Tasks | Book a Room |
| Manage Staff | Bookings | Write Feedback | My Bookings |
| Rooms & Pricing | Check-in (Today) | | Payments & Receipts |
| Feedbacks | Check-out | | Write Comment |
| Comments | Assign Cleaning | | |
| Reports | Receipts | | |
| Profile / Logout | Profile / Logout | Profile / Logout | Profile / Logout |

### 9.3 列表美观约定（全局锁定，后续所有列表页统一）

| # | 规则 | 说明 |
|---|---|---|
| T1 | **多表等列纵向对齐** | 同一页面若有多张结构相同的表（如 Staff 分职位），列宽必须固定且一致，全局扫视时 Name / Email / Phone / IC / Actions 等列应对齐，不得因内容长短导致逐表偏移 |
| T2 | **行内文字同一水平高度** | 同一行内，纯文本单元格与 Actions 内的 Edit / Delete 等控件须在同一水平中线；不得出现文字偏上、按钮居中的错位 |
| T3 | 分组展示 | Staff：**一职位一表**；房间等后续列表建议一房型一表或过滤 + 分组 |
| T4 | 分区计数文案 | 表头右上角用业务名词（如 `N Staff`），不用 `account(s)` |
| T5 | 实现手段 | `table-layout: fixed` + 统一列宽（CSS 变量 / colgroup）；`vertical-align: middle`；正文 `line-height` 与按钮高度一致（当前 32px）；**禁止**对 `td` 直接 `display: flex`（改用内层 `.actions-inner`） |

公共样式：`assets/css/theme.css` 中 `.data-table` / `.staff-table`；后续新列表复用同一套模式，不得另起一套导致错位。

---

## 10. 校验与格式

| 字段 | 规则 |
|---|---|
| Name / Address | 必填 |
| Gender | Male / Female |
| Email | 通用 `local@domain.tld` |
| Phone 展示 | `+60` + 空格 + 本地号 |
| Phone 存储 | `+60` + 8–11 位数字（无空格） |
| IC | `XXXXXX-XX-XXXX` |
| Password（新建） | ≥8，含字母和数字 |
| Password（编辑） | 可留空表示不改 |

工具类：`ValidationUtil`、`PhoneUtil`、`PasswordUtil`。

---

## 11. 权限矩阵（摘要）

| 操作 | Seed Manager | 其他 Manager | Counter | HK | Customer |
|---|---|---|---|---|---|
| 管 Counter/HK | ✓ | ✓ | — | — | — |
| 创建/改/删 Manager | ✓（不删自己） | ✗ | — | — | — |
| 设房价 / 报表 / 看反馈评论 | ✓ | ✓ | — | — | — |
| 顾客 CRUD、代订、CI/CO、派工、收款 | — | — | ✓ | — | — |
| 自己任务、按房 Feedback | — | — | — | ✓ | — |
| 自订/取消/历史/评论 | — | — | — | — | ✓ |
| Profile / 改密 | ✓ | ✓ | ✓ | ✓ | ✓ |

识别 seed：`User.seedAdmin = true`。

---

## 12. 种子数据（演示硬性）

| 数据 | 数量 / 内容 |
|---|---|
| Seed Manager | 1：`manager@gmail.com` / `Manager@123`（`seedAdmin=true`） |
| 其他 Manager | 1：`manager2@gmail.com` / `Manager@123` |
| Counter | ≥2：`counter1/2@gmail.com` / `Counter@123` |
| Housekeeper | ≥5：`hk1..hk5@gmail.com` / `House@123` |
| Customer | ≥10：`customer1..10@gmail.com` / `Customer@123` |
| Rooms | 50（30/15/5） |
| 进行中预订 | ≥2（待业务 seed） |
| 已完成预订 | ≥5（待业务 seed） |

兼容：若存在旧账号 `manager@apu.com`，启动时可晋升为 seedAdmin。

演示要求（Assumptions）：至少 1 manager、2 counter、5 HK、10 customers、2 ongoing + 5 completed bookings。

---

## 13. 实现里程碑与进度

| 阶段 | 内容 | 状态 |
|---|---|---|
| **M1** | 主题 CSS、Sidebar 布局、Logout 底部、Auth/Role Filter、四角色 Dashboard 壳、Customer 登录路由、Forgot/Profile 占位 | ✅ 完成并验收 |
| **M2** | 全部 Entity + Facade 骨架 + Seed（用户 + 50 房）+ persistence 注册 | ✅ 完成并验收 |
| **M3** | Manager Staff CRUD（权限 + 分表 UI）、Counter Customer CRUD、校验工具、软删除唯一键修复 | ✅ 验收完成 |
| **M4** | 房间列表/过滤/改价；预订 + 占房 + 全额付款 + 收据页 | ✅ 完成 |
| **M5** | Check-in / Check-out（房号列表） | ✅ 完成 |
| **M6** | 清洁任务 + 按房 Feedback | ✅ 完成 |
| **M7** | Customer 评论点名 + 取消预订 | ✅ 完成 |
| **M8** | 5 报表 + 图表；Forgot/Reset 真邮件；Profile/Change Password | ✅ 完成 |

### 13.1 已实现 URL（节选）

| URL | 说明 |
|---|---|
| `/login`, `/logout` | 登录登出 |
| `/forgot-password` | 占位 |
| `/profile` | 占位 |
| `/manager/dashboard` | |
| `/manager/staff`, `/new`, `/edit`, `/delete` | Staff CRUD |
| `/manager/rooms`, `/manager/rooms/price` | 房间列表/过滤/改价 |
| `/manager/feedbacks` | 全部 HK Feedback |
| `/manager/comments` | 全部 Customer Comment |
| `/manager/reports` | 5+ 图表报表 |
| `/profile` | 资料 + 改密 |
| `/forgot-password`, `/reset-password` | 重置密码 |
| `/counter/dashboard` | |
| `/counter/customers`, `/new`, `/edit`, `/delete` | Customer CRUD |
| `/counter/bookings`, `/counter/bookings/new` | 代客预订 + 付款 |
| `/counter/check-in` | 今日入住 Check-in |
| `/counter/check-out` | 在住 Check-out |
| `/counter/assign-cleaning` | 派清洁任务 |
| `/counter/receipts`, `/counter/receipts/view` | 收据列表/打印 |
| `/housekeeper/dashboard` | |
| `/housekeeper/tasks` | 我的清洁任务 / 完成 |
| `/housekeeper/feedback` | 按房 Feedback |
| `/customer/dashboard` | |
| `/customer/book` | 自助预订 + 付款 |
| `/customer/bookings`, `/customer/bookings/cancel` | 我的预订 / 取消 |
| `/customer/comments` | 评论 + 点名 |
| `/customer/receipts`, `/customer/receipts/view` | 收据 |

### 13.2 已知修复记录

| 问题 | 处理 |
|---|---|
| 旧 `users` 表缺 `created_at` 等列导致启动失败 | SQL 迁移 `sql/m2-fix-users-table.sql` / 或重建库 |
| 软删除后同 email 重注册 Duplicate entry | `softDelete` 释放唯一键 + `createOrRestore` 恢复已删账号 |
| Staff 单表混杂不美观 | 按 Managers / Counter / Housekeepers 分表 |

---

## 14. 配置与运维注意

### 14.1 数据库

- 示例库：`apu_hrms`  
- `hibernate.hbm2ddl.auto=update` **不能完全依赖** 于「有数据的旧表加 NOT NULL 列」  
- 结构变更时可用 `sql/` 下脚本或 drop/create  

### 14.2 邮件（M8）

- Gmail SMTP + App Password  
- 配置放本地/环境变量，**不要把密钥提交进公开仓库**  
- 流程：email → 一次性 token → 链接设新密码 → 统一提示防枚举  

### 14.3 部署

- 部署 WAR 到 WildFly 等  
- 配置 JTA DataSource `java:/jdbc/APUHRMSDS`  
- Context path 示例：`/APU-HRMS-1.0-SNAPSHOT`  

---

## 15. 文档与报告（非代码，交付仍需）

### Part 1（研究，约 3000 词）

- 分布式计算简史与架构演化  
- Next.js  
- TanStack Start  
- 对比  
- 为何选/不选及与 Part 2 的关系  
- 图表、示例代码  

### Part 2（系统文档）

- Cover、目录、页码  
- Web 组件设计（Servlet/JSP）  
- 页面与 Sitemap  
- 业务层 EJB  
- 架构与 UML（用例 + 类图）  
- DB 设计、E-R、访问 API  
- **≥2 额外功能** 描述与证据  
- References（≥10：5 书 + 5 在线）  

---

## 16. 验收检查（阶段性）

### M1

- 登录后 Sidebar；Logout 在底部  
- 未登录被拦；跨角色被拦  
- Customer 可进 `/customer/dashboard`  

### M2

- Seed 账号可登录  
- 库中约 19 用户 + 50 房间  
- 无启动 EJB/JPA 致命错误  

### M3

- Manager 分表管理 Staff；seed 权限正确  
- Counter 管理 Customer  
- 校验生效；删后可重注册同 email  

### M5

- Counter 今日 CI 列表显示房号；Check-in → 房间 OCCUPIED、行状态 CHECKED_IN  
- Check-out 列表为在住房；Check-out → 房间 NEEDS_CLEANING、行状态 CHECKED_OUT  
- 订单状态随房行滚动（PARTIAL_CHECKED_IN / CHECKED_IN / CHECKED_OUT）  

### M6

- Counter 可将 NEEDS_CLEANING 房派给无 open 任务的 HK  
- HK 完成任务 → 房间 AVAILABLE  
- HK 可提交按房 Feedback（room 必填）  

### M7

- Customer 仅当全部房行仍为 RESERVED 时可取消；支付改 REFUND_PENDING + 3 天退款文案  
- Customer 可对本人订单评论；可选点名 counterStaff + 相关已完成清洁 HK  
- Manager 可查看全部 Comments  

### M8

- Profile 编辑资料 + 旧密码改新密码（全角色）  
- Forgot/Reset：一次性 token；配 Gmail SMTP 则发信，否则演示链接  
- Manager 5 报表 Chart.js + Feedbacks 列表  

### 最终演示前

- 演示 seed 人数与预订样本满足 Assumptions  
- 全流程：预订→付款→CI→CO→清洁→反馈/评论→报表  
- 至少 2 个 extra 可展示  

---

## 17. 下一步建议

1. 端到端演示走通：预订→付款→CI→CO→派清洁→Feedback→评论→报表  
2. 配置 Gmail SMTP 环境变量以演示真邮件（可选）  
3. 扩展 seed：≥5 completed 订单样本  
4. 完成 Part 1 / Part 2 文档（截图、ER、Sitemap、额外功能证据）  

---

## 18. 修订记录

| 日期 | 说明 |
|---|---|
| 2026-08 | 初版：合并作业要求、Assumptions、全部讨论决议、蓝图、M1–M3 进度与修复 |
| 2026-08 | 锁定列表 UI：多表等列纵向对齐、行内文字与 Actions 同一水平高度（§9.3） |
| 2026-08 | M3 验收完成；启动 M4：房间管理 + 预订全额预付 + 收据 |
| 2026-08 | M4–M6 完成：预订/收据、CI/CO、派清洁、HK 任务与 Feedback |
| 2026-08 | M7–M8 完成：取消/评论点名、Profile、重置密码、报表与 Manager 查看 |

---

*本文档随实现推进可继续更新「状态」列与修订记录。以仓库代码与本文冲突时，以双方最新确认 + 代码为准，并回写本文。*
