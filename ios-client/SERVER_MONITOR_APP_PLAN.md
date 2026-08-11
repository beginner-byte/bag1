# 服务器监控 App 功能规划

## 1. 产品定位

服务器监控 App 是一个面向服务器管理员、开发者和小团队的移动端运维监控工具。

第一版核心目标是让用户可以在手机上快速查看服务器运行状态、资源使用情况、数据库状态、服务健康情况和告警信息。

后续版本可以在此基础上增加 IM、消息通知、多人协作和更完整的运维管理能力。

## 2. 目标用户

- 拥有自建服务器的小团队
- 需要查看服务器状态的开发者
- 需要移动端监控能力的运维人员
- 需要私有化部署服务状态面板的管理员

## 3. 第一版核心功能

### 3.1 登录与身份验证

- 管理员账号登录
- 密码登录
- API Token 登录，可选
- 记住登录状态
- 登录失败提示
- Token 过期后重新登录
- 退出登录

登录页面需要明确说明这是服务器监控工具，只有授权管理员可以访问服务器和数据库状态信息。

### 3.2 服务器总览

- 服务器名称
- 在线 / 离线状态
- 节点名称或服务器地址
- 运行时长
- 系统版本
- 最近更新时间
- 健康评分

### 3.3 资源监控

- CPU 使用率
- 内存使用率
- 磁盘使用率
- 网络上传速率
- 网络下载速率
- Load Average
- 进程数量

### 3.4 数据库监控

- 数据库类型，例如 MySQL、PostgreSQL、Redis、MongoDB
- 数据库连接状态
- 当前连接数
- 最大连接数
- 数据库存储占用
- 查询 QPS
- 慢查询数量
- 最近备份时间

> 第一版只展示数据库状态和统计信息，不展示数据库表内容、用户数据、聊天记录或敏感字段。

### 3.5 服务健康检查

- API 服务状态
- Web 服务状态
- 数据库服务状态
- 缓存服务状态
- IM 服务状态

每个服务显示：

- 服务名称
- 当前状态：正常 / 警告 / 异常
- 响应时间
- 最近检查时间

### 3.6 告警中心

- CPU 过高
- 内存不足
- 磁盘空间不足
- 数据库连接异常
- 服务离线
- 网络异常

每条告警包含：

- 告警等级：低 / 中 / 高
- 告警来源
- 告警时间
- 告警详情
- 处理状态：未处理 / 已处理

### 3.7 设置

- 服务器接口地址
- API Token
- 自动刷新开关
- 自动刷新间隔
- 推送通知开关
- 深色模式开关

## 4. 页面结构

### 4.1 登录页

登录页是 App 的首个访问控制页面，未登录用户只能看到登录入口。

页面内容：

- App 名称
- 简短说明：服务器资源、数据库状态和服务健康监控
- 管理员账号输入框
- 密码输入框
- 登录按钮
- API Token 登录入口，可选
- 登录失败提示
- 隐私与安全提示

### 4.2 Dashboard 首页

首页是 App 的主入口，打开后直接展示服务器监控看板。

页面内容：

- 顶部展示服务器名称、在线状态、最近更新时间、健康评分
- 中部展示 CPU、内存、磁盘、网络四个核心指标卡片
- 下方展示服务健康列表
- 底部展示最近告警

### 4.3 资源详情页

用于查看服务器资源的详细趋势和实时状态。

页面内容：

- CPU 使用率折线图
- 内存使用率折线图
- 磁盘容量进度条
- 网络上传 / 下载流量图
- Load Average
- 进程数量摘要

### 4.4 数据库详情页

用于查看数据库运行状态。

页面内容：

- 数据库类型
- 数据库连接状态
- 当前连接数 / 最大连接数
- 数据库存储占用
- 查询 QPS
- 慢查询数量
- 最近备份时间

### 4.5 告警页

用于集中查看服务器和服务异常。

页面内容：

- 告警列表
- 告警等级筛选
- 告警来源筛选
- 未处理 / 已处理状态
- 告警详情

### 4.6 设置页

用于配置服务器连接和显示偏好。

页面内容：

- 服务器接口地址
- API Token 输入框
- 自动刷新间隔
- 推送通知开关
- 深色模式开关

## 5. 子功能界面规划

### 5.1 登录模块

#### 5.1.1 账号密码登录页

用途：管理员通过账号和密码进入服务器监控系统。

页面内容：

- 管理员账号输入框
- 密码输入框
- 显示 / 隐藏密码按钮
- 记住登录状态开关
- 登录按钮
- 登录失败提示

主要操作：

- 输入账号和密码
- 提交登录
- 登录失败后显示错误原因
- 登录成功后进入 Dashboard 首页

#### 5.1.2 API Token 登录页

用途：给高级用户或私有化部署用户提供 Token 登录方式。

页面内容：

- 服务器接口地址输入框
- API Token 输入框
- Token 权限说明
- 连接测试按钮
- 登录按钮

主要操作：

- 输入服务器地址和 Token
- 测试 Token 是否可用
- 登录成功后进入 Dashboard 首页

#### 5.1.3 登录异常页

用途：展示网络异常、Token 过期、权限不足等登录失败场景。

页面内容：

- 异常图标
- 异常标题
- 异常原因
- 重试按钮
- 返回登录按钮

### 5.2 Dashboard 模块

#### 5.2.1 服务器概览卡片

用途：快速展示服务器整体健康情况。

页面内容：

- 服务器名称
- 在线状态
- 健康评分
- 运行时长
- 系统版本
- 最近更新时间

点击行为：

- 点击服务器名称进入服务器详情页
- 点击健康评分进入健康评分详情页

#### 5.2.2 核心指标卡片

用途：展示 CPU、内存、磁盘、网络四个核心指标。

页面内容：

- CPU 使用率卡片
- 内存使用率卡片
- 磁盘使用率卡片
- 网络流量卡片

点击行为：

- 点击 CPU 进入 CPU 详情页
- 点击内存进入内存详情页
- 点击磁盘进入磁盘详情页
- 点击网络进入网络详情页

#### 5.2.3 最近告警列表

用途：在首页快速看到最近发生的问题。

页面内容：

- 告警等级
- 告警来源
- 告警摘要
- 发生时间
- 处理状态

点击行为：

- 点击单条告警进入告警详情页
- 点击全部进入告警列表页

### 5.3 服务器详情模块

#### 5.3.1 服务器基础信息页

用途：展示服务器基础信息。

页面内容：

- 服务器名称
- 节点标识
- 服务器地区
- 系统版本
- CPU 核心数
- 内存总量
- 磁盘总量
- 运行时长
- 最后重启时间

#### 5.3.2 健康评分详情页

用途：说明健康评分由哪些指标组成。

页面内容：

- 总健康评分
- CPU 权重和状态
- 内存权重和状态
- 磁盘权重和状态
- 数据库权重和状态
- 服务健康权重和状态
- 最近影响评分的异常

### 5.4 资源监控模块

#### 5.4.1 CPU 详情页

用途：查看 CPU 当前使用率和历史趋势。

页面内容：

- 当前 CPU 使用率
- 1 小时趋势图
- 24 小时趋势图
- Load Average
- 最高使用率时间点

#### 5.4.2 内存详情页

用途：查看内存使用情况。

页面内容：

- 总内存
- 已用内存
- 可用内存
- 缓存占用
- 内存使用趋势图
- 内存压力状态

#### 5.4.3 磁盘详情页

用途：查看磁盘容量和分区使用情况。

页面内容：

- 磁盘总容量
- 已用容量
- 可用容量
- 分区列表
- 每个分区的使用率
- 磁盘告警阈值

#### 5.4.4 网络详情页

用途：查看服务器网络上传和下载情况。

页面内容：

- 当前上传速率
- 当前下载速率
- 今日上传流量
- 今日下载流量
- 网络趋势图
- 网络异常记录

#### 5.4.5 进程摘要页

用途：展示高资源占用的进程摘要。

页面内容：

- 进程名称
- PID
- CPU 占用
- 内存占用
- 运行时间

> 第一版只展示进程摘要，不提供杀进程、重启进程等高风险操作。

### 5.5 数据库监控模块

#### 5.5.1 数据库总览页

用途：展示数据库整体运行状态。

页面内容：

- 数据库类型
- 数据库版本
- 连接状态
- 当前连接数
- 最大连接数
- 存储占用
- 查询 QPS
- 慢查询数量

#### 5.5.2 数据库连接详情页

用途：查看数据库连接使用情况。

页面内容：

- 当前连接数
- 最大连接数
- 连接使用率
- 空闲连接数
- 连接趋势图
- 连接异常记录

#### 5.5.3 数据库存储详情页

用途：查看数据库存储占用趋势。

页面内容：

- 当前存储占用
- 今日增长量
- 7 天增长趋势
- 30 天增长趋势
- 备份占用
- 可用空间预估

#### 5.5.4 慢查询摘要页

用途：展示慢查询统计，不展示完整 SQL 内容。

页面内容：

- 慢查询数量
- 平均查询耗时
- 最慢查询耗时
- 慢查询来源模块
- 最近慢查询时间

> 为降低安全风险，第一版不展示完整 SQL 语句。

#### 5.5.5 备份状态页

用途：查看数据库备份是否正常。

页面内容：

- 最近备份时间
- 最近备份结果
- 备份文件大小
- 备份耗时
- 下一次计划备份时间
- 备份失败记录

### 5.6 服务健康模块

#### 5.6.1 服务列表页

用途：集中展示所有服务的状态。

页面内容：

- API 服务
- Web 服务
- 数据库服务
- 缓存服务
- IM 服务
- 文件服务

每个服务展示：

- 服务状态
- 响应时间
- 最近检查时间
- 最近异常时间

#### 5.6.2 服务详情页

用途：查看单个服务的健康情况。

页面内容：

- 服务名称
- 服务状态
- Endpoint
- 响应时间趋势
- 成功率
- 最近错误
- 最近部署时间

#### 5.6.3 IM 服务状态页

用途：为后续增加 IM 功能预留服务监控入口。

页面内容：

- IM 服务在线状态
- Socket 连接数
- 在线用户数
- 今日消息数
- 消息发送失败数
- 最近异常时间

### 5.7 告警模块

#### 5.7.1 告警列表页

用途：查看所有告警。

页面内容：

- 告警等级筛选
- 告警来源筛选
- 处理状态筛选
- 告警列表

#### 5.7.2 告警详情页

用途：查看单条告警的完整信息。

页面内容：

- 告警标题
- 告警等级
- 告警来源
- 告警时间
- 告警详情
- 影响范围
- 建议处理方式
- 当前处理状态

主要操作：

- 标记为已处理
- 标记为误报
- 返回告警列表

#### 5.7.3 告警规则页

用途：查看告警触发规则。

页面内容：

- CPU 告警阈值
- 内存告警阈值
- 磁盘告警阈值
- 数据库连接告警阈值
- 服务响应时间告警阈值

> 第一版可以只展示规则，不提供编辑能力。

### 5.8 设置模块

#### 5.8.1 服务器连接设置页

用途：配置监控接口连接信息。

页面内容：

- 服务器接口地址
- API Token
- 连接测试按钮
- 当前连接状态
- 最近连接时间

#### 5.8.2 刷新设置页

用途：配置数据刷新策略。

页面内容：

- 手动刷新
- 自动刷新开关
- 自动刷新间隔
- 后台刷新说明

#### 5.8.3 通知设置页

用途：配置告警通知。

页面内容：

- 推送通知开关
- 高危告警通知
- 中级告警通知
- 服务恢复通知

#### 5.8.4 账号安全页

用途：管理当前管理员账号的安全状态。

页面内容：

- 当前账号
- 当前角色
- Token 过期时间
- 重新登录按钮
- 退出登录按钮

## 6. 页面跳转关系

```text
登录页
  -> Dashboard 首页

Dashboard 首页
  -> 服务器基础信息页
  -> 健康评分详情页
  -> CPU 详情页
  -> 内存详情页
  -> 磁盘详情页
  -> 网络详情页
  -> 服务列表页
  -> 告警详情页
  -> 告警列表页

资源详情页
  -> CPU 详情页
  -> 内存详情页
  -> 磁盘详情页
  -> 网络详情页
  -> 进程摘要页

数据库详情页
  -> 数据库连接详情页
  -> 数据库存储详情页
  -> 慢查询摘要页
  -> 备份状态页

服务健康页
  -> 服务详情页
  -> IM 服务状态页

告警页
  -> 告警详情页
  -> 告警规则页

设置页
  -> 服务器连接设置页
  -> 刷新设置页
  -> 通知设置页
  -> 账号安全页
```

## 7. 数据接口规划

### 7.1 登录接口

```http
POST /api/auth/login
```

请求示例：

```json
{
  "username": "admin",
  "password": "password"
}
```

返回示例：

```json
{
  "token": "monitor_access_token",
  "expiresIn": 7200,
  "user": {
    "id": "admin_001",
    "name": "Server Admin",
    "role": "admin"
  }
}
```

### 7.2 退出登录接口

```http
POST /api/auth/logout
```

### 7.3 服务器总览接口

```http
GET /api/monitor/overview
```

返回示例：

```json
{
  "serverName": "Production Node 01",
  "status": "online",
  "healthScore": 92,
  "uptime": "18 days 4 hours",
  "systemVersion": "Ubuntu 22.04",
  "lastUpdated": "2026-06-16 14:30:00"
}
```

### 7.4 资源监控接口

```http
GET /api/monitor/resources
```

返回示例：

```json
{
  "cpuUsage": 38.5,
  "memoryUsage": 64.2,
  "diskUsage": 71.8,
  "networkUpload": "2.4 MB/s",
  "networkDownload": "8.7 MB/s",
  "loadAverage": "1.24, 1.58, 1.72",
  "processCount": 148
}
```

### 7.5 数据库监控接口

```http
GET /api/monitor/database
```

返回示例：

```json
{
  "type": "MySQL",
  "status": "healthy",
  "activeConnections": 42,
  "maxConnections": 200,
  "storageUsage": "18.6 GB",
  "qps": 126,
  "slowQueries": 3,
  "lastBackupTime": "2026-06-16 03:00:00"
}
```

### 7.6 服务健康接口

```http
GET /api/monitor/services
```

返回示例：

```json
{
  "services": [
    {
      "name": "API Service",
      "status": "healthy",
      "responseTime": 86,
      "lastChecked": "2026-06-16 14:30:00"
    },
    {
      "name": "Database",
      "status": "warning",
      "responseTime": 212,
      "lastChecked": "2026-06-16 14:30:00"
    }
  ]
}
```

### 7.7 告警接口

```http
GET /api/monitor/alerts
```

返回示例：

```json
{
  "alerts": [
    {
      "id": "alert_001",
      "level": "warning",
      "source": "Database",
      "message": "Database response time is higher than expected.",
      "status": "unresolved",
      "createdAt": "2026-06-16 14:10:00"
    }
  ]
}
```

## 8. 权限与安全

- 服务器监控功能只允许管理员访问。
- 未登录用户不能访问 Dashboard、资源监控、数据库监控和告警页面。
- App 不直接连接数据库。
- App 不直接通过 SSH 连接服务器。
- App 只通过 HTTPS 请求后端监控接口。
- API Token 必须支持失效和轮换。
- 接口返回数据必须脱敏。
- 不展示数据库表结构、用户数据、聊天记录或服务器密钥。
- 登录 Token 应保存在系统安全存储中。

## 9. 上架说明建议

第一版 App 的名称、描述、截图和审核备注应围绕服务器监控能力，不提前宣传尚未上线的 IM 功能。

审核备注可以说明：

- 这是一个服务器监控工具。
- 用户可以查看服务器资源、数据库状态、服务健康和告警信息。
- 如需登录，请提供可用的演示账号。
- 后端监控服务在审核期间保持可访问。

## 10. Stitch 生成页面提示词

```text
Design a mobile-first server monitoring dashboard app.

The app is for server administrators to monitor cloud server health, database status, and service availability. Create a polished iOS-style interface with a clean professional dashboard.

Main screens:
1. Login
- App name and short description.
- Admin username field.
- Password field.
- Primary login button.
- Optional API token login entry.
- Security note explaining that only authorized administrators can access server metrics.
- Clean, trustworthy, professional style.

2. Dashboard
- Header with server name, online status, last updated time, and health score.
- Four metric cards: CPU usage, memory usage, disk usage, network traffic.
- Service health section showing API service, database service, cache service, IM service, and web service.
- Recent alerts list at the bottom.
- Use green for healthy, orange for warning, red for critical.

3. Resource Details
- CPU usage line chart.
- Memory usage chart.
- Disk usage progress bars.
- Network upload/download chart.
- Load average and process count summary.

4. Database Monitor
- Database type card.
- Connection status.
- Active connections versus max connections.
- Storage usage.
- Query per second.
- Slow query count.
- Last backup time.

5. Alerts
- List of alerts with severity, source, time, and status.
- Filters for All, Warning, Critical, Resolved.
- Each alert row should be clear and scannable.

6. Settings
- Server endpoint.
- API token field.
- Auto refresh interval.
- Push notification toggle.
- Dark mode toggle.

Sub screens:
- Account password login screen.
- API token login screen.
- Server basic information screen.
- Health score detail screen.
- CPU detail screen with current usage and trend chart.
- Memory detail screen with total, used, available, cache, and pressure status.
- Disk detail screen with partitions and usage bars.
- Network detail screen with upload/download rate and traffic trend.
- Process summary screen showing top CPU and memory processes.
- Database connection detail screen.
- Database storage detail screen.
- Slow query summary screen without exposing full SQL text.
- Database backup status screen.
- Service list screen.
- Service detail screen.
- IM service status screen showing socket connections, online users, today message count, and send failure count.
- Alert detail screen.
- Alert rules screen.
- Server connection settings screen.
- Refresh settings screen.
- Notification settings screen.
- Account security screen.

Navigation:
- Login opens Dashboard after success.
- Dashboard cards open their matching detail screens.
- Database monitor opens connection, storage, slow query, and backup sub screens.
- Service health opens service detail and IM service status.
- Alerts list opens alert detail and alert rules.
- Settings opens server connection, refresh, notification, and account security.

Visual style:
- Professional SaaS monitoring tool.
- Clean cards, compact layout, high readability.
- Light background with subtle borders.
- Use charts, progress bars, status badges, and icons.
- Avoid marketing landing page style.
- First screen should be the actual dashboard, not a hero page.
```

## 11. 版本规划

### v1.0

- 登录与身份验证
- 服务器总览
- 资源监控
- 数据库状态
- 服务健康检查
- 告警列表
- 基础设置

### v1.1

- 推送告警
- 多服务器切换
- 历史趋势图
- 告警处理记录

### v2.0

- 增加 IM 模块
- 会话列表
- 单聊
- 消息收发
- 离线消息同步
- 管理员通知消息
