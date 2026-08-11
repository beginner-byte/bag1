# CandyTalk 项目结构与功能说明

> 本文根据当前仓库源码、工程配置和实际页面入口整理，不依赖现有 README。  
> 文档中的“当前启用”表示代码已接入当前启动或导航流程；“源码具备”表示仓库中存在实现，但是否展示还受服务端配置、账号权限或入口开关影响。

## 1. 项目定位

这是一个以即时通讯为核心的原生 iOS 客户端，整体采用以下架构：

- UIKit + Objective-C：主要业务页面和应用生命周期。
- Swift：新页面、网络状态、本地组件及部分现代化能力。
- NoaChatCore SDK：负责登录、长连接、消息、群组、好友、数据库和同步。
- CocoaPods：管理应用、SDK 和第三方依赖。

当前页面均由 UIKit、Objective-C 或 Swift 原生实现。

## 2. 工程组成

| 路径 | 作用 |
| --- | --- |
| `CIMSDK.xcworkspace` | CocoaPods 集成后的主工作区，日常开发应优先打开它 |
| `NoaChatKit/CandyTalk.xcodeproj` | iOS 应用工程，主要 Target 为 `CandyTalk` |
| `NoaChatKit/CandyTalk/` | 应用层源码、页面、资源和业务模块 |
| `NoaChatSDKCore/CandyTalkPro.xcodeproj` | IM 核心 SDK 工程，Target 为 `CandyTalkPro` |
| `NoaChatSDKCore/NoaChatSDKCore/` | 通信、消息、数据库和 SDK 公共能力 |
| `NetWorkStatus/` | 网络连通状态监听组件 |
| `EncryptLib/` | 本地文件加密组件 |
| `TKThemeConfig/` | 多主题、浅色和深色模式组件 |
| `GaOnchainLib/` | GaOnchain 链上数据请求组件 |
| `LocalLogLib/` | 独立本地日志组件源码，当前 Podfile 未直接声明该本地 Pod |
| `web/` | 仓库内的 Web 静态资源 |
| `Podfile` | iOS 13.0 起的应用、SDK 和依赖配置 |

## 3. 应用层目录

`NoaChatKit/CandyTalk/` 是客户端主体，主要目录如下：

| 目录 | 职责 |
| --- | --- |
| `AppDelegate/` | 应用启动、数据库、推送、音视频和全局服务初始化 |
| `Auth/` | 服务器设置、登录、注册、验证码和安全认证 |
| `Base/` | 基类、导航、通用组件、网络、上传、主题、工具和错误页 |
| `CandyLaunchViewController/` | 启动页及启动阶段的入口控制 |
| `Main/` | 应用主流程相关页面 |
| `Tab/` | 主 TabBar、消息、通讯录、签到、团队和原生“我的”入口 |
| `Modules/ChatModule/` | 单聊、群聊、消息展示和聊天设置 |
| `Modules/ContactsModule/` | 好友、群组、联系人和全局搜索 |
| `Modules/Session/` | 会话列表、文件助手和群发消息 |
| `Modules/MediaCallModule/` | LiveKit、Zego 音视频通话 |
| `Modules/MineModule/` | 用户资料、安全、隐私、语言、收藏和系统设置 |
| `Modules/MiniAppModule/` | 小程序 Web 容器及悬浮窗 |
| `Modules/NoaTeamInviteModule/` | 团队邀请、团队列表及人数管理 |
| `Modules/Team/` | 团队创建、详情和管理 |
| `Resource/` | 图片、语言、字体和其他应用资源 |

## 4. 启动与页面切换流程

### 4.1 启动阶段

`AppDelegate` 启动时主要完成：

1. 初始化本地文件加密，可根据配置使用 XOR、AES 或不加密。
2. 初始化本地日志、Logan 日志和 Sentry 异常采集。
3. 配置 SDWebImage 缓存、图片解密和 SVG、WebP、GIF 解码。
4. 启动网络状态监听。
5. 加载语言、主题、键盘和通用滚动配置。
6. 初始化 IM SDK、数据库、Socket 和音视频模块。
7. 初始化推送通知和应用角标。
8. 执行服务器节点测速及可用地址选择。
9. 先以 `CandyLaunchViewController` 作为根页面，再根据状态进入服务器设置、登录页或主页。

### 4.2 登录后的主界面

登录成功后，`NoaToolManager` 创建 `CandyTabBarController`，并加载好友申请数和会话未读数。

当前实际启用三个 Tab：

| Tab | 当前控制器 | 说明 |
| --- | --- | --- |
| 消息 | `CandyTalkHomeViewController` | 会话列表、未读消息和聊天入口 |
| 通讯录 | `CandyTalkContactVC` | 好友、群组、联系人和搜索入口 |
| 我的 | `CoHereMineViewController` | Swift 原生个人中心与设置入口 |

源码中还保留“签到”和“团队”Tab 控制器，但在 `CandyTabBarController` 中被注释，当前不会作为主 Tab 展示。

### 4.3 退出与重新登录

退出登录时会清理当前用户状态、执行 SDK 登出、断开 Socket，并把根控制器切换为 `NoaLoginViewController`。修改密码、注销账号、手势锁异常等流程也可能触发重新登录。

## 5. 功能模块

### 5.1 服务器与 SSO 设置

主要入口：`CoHereSsoSetViewController`

源码具备：

- 使用邀请码或 License ID 查找所属服务器。
- 使用 IP 或域名配置服务器。
- 扫描二维码获取服务器信息。
- 服务器节点测速、可用地址选择和失败重试。
- 保存上次成功的服务器配置。
- 本地网络权限检测。
- 查看 Swift 原生网络设置说明页 `CoHereSsoHelpViewController`。
- 配置失败时展示测速错误或应用启动错误页面。

该模块位于账号登录之前，用于确定认证、HTTP、Socket 等服务地址。

### 5.2 登录、注册与认证

主要目录：`Auth/Controllers/`

源码具备：

- 账号密码登录。
- 手机号或邮箱验证码登录。
- 国家或地区区号选择。
- 注册方式选择和新用户注册。
- 找回密码、忘记密码和重置密码。
- 图片验证码。
- 阿里云、腾讯等验证码相关接入代码。
- 设备安全码认证。
- PC 登录授权与取消授权。
- 企业或服务器配置输入。
- 登录成功后同步用户、好友、群组、会话和消息数据。

具体能力是否显示，会受服务器配置、注册开关和账号类型控制。

### 5.3 消息与会话列表

主要入口：`CandyTalkHomeViewController`

源码具备：

- 从本地数据库加载会话。
- 从服务端同步会话和最新消息。
- 展示单聊、群聊和系统类会话。
- 未读消息数量统计和 Tab 红点。
- 会话置顶。
- 会话消息免打扰。
- 标记单个会话已读。
- 全部消息已读。
- 删除会话。
- 跳转到指定未读消息。
- 处理好友在线状态变化。
- 处理新消息、撤回、删除和群发消息更新。
- 断线重连后的会话恢复。
- 重复登录或多端登录相关会话处理。
- 文件助手入口。
- 好友邀请入口。

### 5.4 单聊与群聊

主要入口：`NoaChatViewController`

#### 消息类型

- 文本消息。
- 图片消息。
- 语音消息。
- 视频消息。
- 文件消息。
- 位置消息。
- 用户名片。
- 表情和游戏表情。
- 音视频通话消息。
- 系统通知。
- 群公告消息。
- 引用和回复消息。
- 合并转发聊天记录。
- `@` 群成员消息。

#### 消息操作

- 发送、接收和失败重试。
- 复制、删除和撤回。
- 单条转发和多选转发。
- 合并转发及聊天记录详情。
- 收藏消息。
- 消息翻译。
- 查看消息已读进度。
- 查看转发失败用户。
- 定时删除消息。
- 群消息或个人消息置顶。
- 根据时间、类型、文字或发送人查询历史消息。
- 查看聊天中的图片、视频、文件和文本记录。
- 保存输入草稿。
- 处理离线消息和断线补拉。

#### 单聊设置

- 查看对方资料。
- 消息免打扰。
- 会话置顶。
- 清空聊天记录。
- 投诉或举报。
- 与单聊相关的定时删除和隐私配置。

#### 群聊管理

- 创建群聊。
- 邀请和移除群成员。
- 查看群成员列表。
- 修改群名称、头像和本人群昵称。
- 查看和生成群二维码。
- 新建、修改、删除、查看和翻译群公告。
- 设置群主和管理员。
- 转让群主。
- 全员禁言或指定成员禁言。
- 设置入群方式。
- 设置群内私聊权限。
- 设置音视频通话权限。
- 设置新成员是否可查看历史消息。
- 设置群提醒和群二维码显示状态。
- 查看群机器人。
- 查看成员活跃度。
- 退出或解散群聊。
- 审核入群申请。
- 删除指定成员的历史消息。

### 5.5 系统消息

主要控制器：

- `NoaSystemMessageVC`
- `NoaSystemMessageAllVC`
- `NoaSystemMessagePendReviewVC`

源码具备：

- 展示系统通知。
- 展示待审核申请。
- 查看全部申请记录。
- 处理好友或群组相关申请。

### 5.6 表情商店

主要目录：`ChatModule/Controllers/EmojiShop/`

源码具备：

- 表情商店首页。
- 推荐表情包。
- 表情包列表。
- 表情包详情。
- 聊天输入区使用已加载表情资源。

### 5.7 通讯录

主要入口：`CandyTalkContactVC`

源码具备：

- 好友列表。
- 新朋友和好友申请数量提示。
- 添加好友。
- 通过好友申请。
- 好友资料主页。
- 好友管理。
- 好友分组、分组列表和分组管理。
- 群组列表。
- 文件助手入口。
- 群助手相关入口。
- 全局搜索联系人、群组和消息。
- 从联系人发起聊天或查看资料。

### 5.8 文件助手与群发消息

主要目录：`Modules/Session/Controllers/`

源码具备：

- 文件助手会话。
- 文件助手设置。
- 新建群发消息。
- 选择群发接收人。
- 查看群发记录。
- 查看群发用户列表。
- 查看群发文件详情。
- 查看发送失败用户。
- 删除群发记录。

### 5.9 音视频通话

主要目录：`Modules/MediaCallModule/`

项目同时保留两套媒体实现：

- LiveKit：`MediaCallModule/LiveKit/`
- Zego：`MediaCallModule/Zego/`

源码具备：

- 单人语音或视频通话。
- 多人或群组通话。
- 邀请更多成员加入通话。
- 接听、拒绝、挂断和取消。
- 摄像头、麦克风和扬声器控制。
- 前后摄像头切换。
- 通话成员和视频布局。
- 通话最小化悬浮窗。
- 来电提醒、铃声和震动。
- 通话状态与聊天消息联动。

实际使用 LiveKit 还是 Zego，由应用配置和服务端能力决定。

### 5.10 “我的”与个人设置

原生完整实现位于 `Modules/MineModule/`，核心页面是 `CandyTallkMineViewController`。源码具备：

- 查看和编辑头像、昵称、账号等个人资料。
- 展示个人二维码。
- 分享邀请。
- 我的收藏。
- 黑名单。
- 应用语言切换。
- 翻译语言、默认翻译和翻译配置管理。
- 安全设置。
- 隐私设置。
- 系统设置。
- 网络与代理设置。
- 网络检测。
- 投诉和问题反馈入口。
- 关于、服务协议和隐私政策。
- 修改登录密码。
- 设置、修改和关闭设备安全码。
- 设置和验证手势锁。
- 注销账号。
- 签到记录、积分详情和签到规则。
- 角色注册、绑定和管理。
- 图片浏览。
- 退出登录。

#### 当前实际状态

当前主 Tab 的“我的”进入 `CoHereMineViewController`，以 Swift 原生页面展示用户资料、收藏、黑名单、语言、安全、隐私、网络检测、投诉支持和关于等菜单，并复用现有业务导航。

### 5.11 网络检测与代理

主要实现：

- `NetWorkStatusManager`
- `NoaNetworkDetectionVC`
- `NoaNetworkDetectionHandle`
- `NoaUrlHostManager`
- `IOSTcpRaceManager`
- `NoaNetworkQualityDetector`

源码具备：

- 使用 `NWPathMonitor` 判断断网、Wi-Fi 和蜂窝网络。
- 网络变化时通知聊天、Socket、TCP 请求和节点管理模块。
- 网络恢复后触发 Socket 重连。
- 检测当前网络状态。
- 检测域名解析。
- 检测导航服务或业务服务器。
- 检测 ECDH 或通信链路。
- 对多个服务器节点测速并选择可用节点。
- 展示测速错误和失败原因。
- 配置网络代理。

### 5.12 团队

相关目录：

- `Modules/NoaTeamInviteModule/`
- `Modules/Team/`

源码具备：

- 创建团队。
- 查看团队列表。
- 查看团队详情。
- 团队管理。
- 创建团队邀请。
- 查看邀请详情。
- 修改团队名称。
- 查看团队成员或总人数。

团队主 Tab 当前被注释，但原生页面和 SDK 接口仍在项目中。

### 5.13 小程序

主要目录：`Modules/MiniAppModule/`

源码具备：

- 小程序列表和模型管理。
- 使用 WebView 打开小程序。
- 小程序悬浮窗。
- 悬浮小程序列表。
- 小程序关闭和删除。
- 小程序密码或安全验证。
- 从 SDK 同步小程序配置。

小程序入口会受服务端下发配置和账号权限影响。

### 5.14 签到

源码具备：

- 签到页面。
- 签到消息。
- 签到记录。
- 积分详情。
- 签到规则。

签到主 Tab 当前被注释，相关页面仍可能从其他入口打开。

### 5.15 多语言与主题

源码具备：

- 简体中文。
- 繁体中文。
- 英文。
- 运行时语言切换。
- 浅色和深色主题。
- 跟随系统或使用自定义主题配置。
- TabBar、页面和通用控件的主题更新。

## 6. 原生页面迁移

- 网络设置说明由 `CoHereSsoHelpViewController` 和 `CoHereSsoHelpPageView` 使用 Swift 原生实现。
- 关于我们由 `CoHereAboutUsViewController` 和 `CoHereAboutUsPageView` 使用 Swift 原生实现，服务协议与隐私政策直接进入原生 WebView。
- “我的”由 `CoHereMineViewController` 和 `CoHereMinePageView` 使用 Swift 原生实现，并保留原有菜单路由和业务行为。

## 7. NoaChatCore SDK

SDK 主入口为 `NoaIMSDKManager`，使用 Category 按领域拆分：

| SDK 分类 | 职责 |
| --- | --- |
| `Auth` | 登录、注册、验证码和认证 |
| `Connect` | 连接状态、登出、断开和重连 |
| `Session` | 会话数据和未读状态 |
| `ChatMessage` | 消息发送、接收、历史、撤回、删除和转发 |
| `Friend` | 好友申请、好友关系和好友数据 |
| `Group` | 群创建、资料、公告、权限和群管理 |
| `GroupMember` | 群成员同步、查询和本地存储 |
| `User` | 用户搜索、资料、头像和账号信息 |
| `Call` | 音视频通话接口 |
| `MiniApp` | 小程序配置与数据 |
| `Team` | 团队接口 |
| `Translate` | 翻译配置和翻译能力 |
| `Stickers` | 表情包能力 |
| `SyncServer` | 服务端数据同步 |
| `MessageRemind` | 消息声音、震动和通话提醒 |
| `ServiceMessage` | 服务消息处理 |
| `AppInfo` | 应用和服务端配置 |
| `Probe` | 网络探测 |
| `Logan` | 日志写入、上传和清理 |
| `signin` | 签到相关能力 |

### 7.1 通信层

- HTTP 请求：`ConnectModule/HttpRequest/`
- HTTP 转 TCP：`ConnectModule/HttpToTcpRequest/`
- 长连接：`ConnectModule/Socket/`
- TCP 管理：`ConnectModule/Socket/TcpManager/`
- 协议模型：`ConnectModule/MessagePbobjc/`
- 消息协议使用 Protobuf。
- Socket 依赖 SocketRocket 和 CocoaAsyncSocket。
- 网络恢复后支持重连和离线消息补拉。

### 7.2 加密

- ECDH 和通信解密逻辑位于 `DeCryptorManager/`。
- SDK 内包含 `LXChatEncrypt` 静态库。
- 应用层 `EncryptLib` 负责本地文件加密。
- 图片加载流程包含本地加密图片解密器。

### 7.3 数据库与缓存

- SDK 数据库位于 `DataBaseModule/`。
- 使用 WCDB 保存消息、会话、好友、群组、群成员、小程序、表情和应用配置。
- 使用 MMKV 保存轻量配置、状态和部分待处理数据。
- 应用层还声明 FMDB 依赖，用于原生侧数据库能力。
- SAMKeychain 用于钥匙串数据。

### 7.4 日志与异常

- Logan 日志记录、查询和上传。
- 本地日志初始化。
- Sentry 异常采集。
- AvoidCrash 防护。
- SDK 异常处理模块。

## 8. 文件与媒体能力

源码及依赖中包含：

- 图片下载、缓存和解密。
- SVG、WebP、GIF 图片格式。
- 图片、视频、语音和普通文件上传。
- Aliyun OSS。
- AWS S3。
- 腾讯云 COS。
- 视频播放器。
- 相册、相机、麦克风和文件访问。
- 聊天媒体历史浏览。

具体上传平台由服务端返回的文件上传配置和 Token 决定。

## 9. 推送与后台能力

源码具备：

- APNs 推送注册和处理。
- 远程通知。
- 应用角标和未读数同步。
- 前台消息提醒。
- 声音和震动配置。
- 音视频来电提醒。
- 后台音频相关配置。

## 10. 关键依赖

| 类型 | 主要依赖 |
| --- | --- |
| 网络 | AFNetworking、SocketRocket、CocoaAsyncSocket |
| 数据 | WCDB、FMDB、MMKV、MJExtension、Protobuf |
| UI | Masonry、SnapKit、MJRefresh、MBProgressHUD、JXCategoryView |
| 图片 | SDWebImage、Kingfisher、SVG/WebP/GIF Coders |
| 音视频 | LiveKitClient、ZegoExpressEngine、TXLiteAVSDK_Player |
| 云存储 | AliyunOSSiOS、AWSS3、QCloudCOSXML |
| 稳定性 | Sentry、AvoidCrash、Logan |
| 系统能力 | SAMKeychain、IQKeyboardManager |
| 本地组件 | NetworkStatus、EncryptLib、TKThemeConfig、GaOnchainLib |

## 11. 典型业务链路

### 11.1 首次启动

`启动页 -> 服务器设置/节点测速 -> 登录或注册 -> 数据同步 -> 消息主页`

### 11.2 发送消息

`会话或联系人 -> 聊天页 -> 构造消息模型 -> SDK 发送 -> Socket/TCP -> 本地数据库更新 -> UI 状态更新`

### 11.3 接收消息

`Socket 收到 Protobuf 消息 -> SDK 解析 -> 保存数据库 -> 更新会话和未读数 -> 通知聊天页/会话页 -> 声音、震动或推送提醒`

### 11.4 网络恢复

`NWPathMonitor 发现网络恢复 -> 发送网络变化通知 -> Socket 重连 -> 补拉会话和离线消息 -> 刷新页面`

### 11.5 音视频通话

`聊天页发起通话 -> SDK 创建通话业务状态 -> LiveKit 或 Zego 建立媒体连接 -> 通话页面/悬浮窗 -> 结束后写入通话消息`

## 12. 当前代码状态要点

1. 当前主界面是“消息、通讯录、我的”三个 Tab。
2. “我的”当前使用 `CoHereMineViewController` 展示完整个人中心和设置功能。
3. 原生 `CandyTallkMineViewController` 仍保留了旧版个人中心和设置功能。
4. 团队和签到主 Tab 当前被注释，但模块源码仍存在。
5. 项目页面与构建链路均使用原生 iOS 实现。
6. 应用依赖服务器配置和多项服务端开关，看到源码存在某功能，不代表所有账号都会展示该入口。

## 13. 阅读源码建议

建议按以下顺序理解项目：

1. `AppDelegate/AppDelegate.m`：了解应用初始化。
2. `Base/Base/Manager/Tool/NoaToolManager.m`：了解登录页和主页切换。
3. `Tab/Tabbar/CandyTabBarController.m`：确认当前主入口。
4. `Tab/CandyTalkHomeViewController.m`：了解会话列表。
5. `Modules/ChatModule/Controllers/NoaChatViewController.m`：了解聊天主流程。
6. `Tab/CandyTalkContactVC.m`：了解通讯录。
7. `Tab/CoHereMineViewController.swift`：了解当前原生完整“我的”。
8. `Modules/MineModule/Controllers/CandyTallkMineViewController.m`：了解旧版原生“我的”。
9. `NoaChatSDKCore/.../SdkManager/`：了解 SDK 业务接口。
10. `NoaChatSDKCore/.../ConnectModule/`：了解网络和长连接。
11. `NoaChatSDKCore/.../DataBaseModule/`：了解本地数据保存。
