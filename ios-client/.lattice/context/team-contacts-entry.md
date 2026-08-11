---
feature: Team Contacts Entry
requirement_doc: null
created: 2026-08-10
status: approved
---

# Team Contacts Entry

> 在 Flutter 团队页现有创建团队按钮旁增加通讯录入口，并复用 CandyTalk 原生完整通讯录页面。

## Decisions Log

<!-- Add new at bottom. Never remove. -->

| Date | Decision | Reasoning | Alternatives Considered |
|------|----------|-----------|------------------------|
| 2026-08-10 | 群聊入口放在团队页右上角的创建团队加号旁边 | 用户明确指定入口位置，符合团队与群聊的使用场景 | 放在工作页消息图标旁；不采用 |
| 2026-08-10 | 群聊列表复用原生 `NoaGroupListVC` | 项目已有完整群聊列表和会话跳转能力，避免重复实现 | 在 Flutter 中重新实现群聊列表；不采用 |
| 2026-08-10 | 入口需求由群聊修正为通讯录，复用 `CoHereContactViewController` | 用户澄清目标是完整通讯录；现有控制器已包含好友、搜索、添加和快捷入口 | 继续打开群聊列表；已撤销 |
| 2026-08-10 | 通讯录增加仅在团队页推入时启用的返回模式 | 原生导航栏全局隐藏，根通讯录页面自身没有返回入口；条件模式可避免影响旧 Tab 通讯录 | 直接推入导致无法返回；显示系统导航栏造成双导航；均不采用 |
| 2026-08-10 | 通讯录入口直接使用 Worker 根导航栈，不依赖 `CandyTabBarController` | 当前登录后根页面是 Worker Flutter，直接 push 原生通讯录可保持团队 Tab 状态并避开原生 TabBar 状态冲突 | 创建或切换旧 `CandyTabBarController`；禁止采用 |
| 2026-08-10 | Level 4 接口契约获批，设计状态设为 approved | 能力、组件、交互和接口已经确认，具备按契约实施的条件 | 未完成契约即开始编码；不采用 |

## Open Questions

None.

## Constraints

- 保留现有创建团队加号及 `onCreateTeam` 行为不变。
- ~~仅新增群聊入口和 Flutter 到 iOS 的导航桥接，不改变群聊业务逻辑。~~ 已由通讯录入口需求替代。
- 仅新增通讯录入口和 Flutter 到 iOS 的导航桥接，不改变通讯录业务逻辑。
- 不调整团队列表数据请求、布局和底部 Tab 切换逻辑。
- 禁止调用、创建或切换 `CandyTabBarController`，禁止修改原生 `selectedIndex` 或 `tabBar.selectedItem`。

## Key Files

| Path | Role |
|---|---|
| `work_module/lib/features/tabbar/teams/teams.screen.dart` | 团队页 AppBar 与入口位置 |
| `work_module/lib/core/host/work_host_bridge.dart` | Flutter 到 iOS 的统一宿主桥 |
| `NoaChatKit/CandyTalk/Modules/WorkModule/CoHereWorkModuleManager.swift` | iOS 方法通道处理与原生页面导航 |
| `NoaChatKit/CandyTalk/Tab/CoHereContactViewController.swift` | 现有原生完整通讯录控制器 |
| `NoaChatKit/CandyTalk/Tab/CoHereContactPageView.swift` | 通讯录标题栏与条件返回按钮 |

## Design: Level 2 -- Components

| Component | Layer | Responsibility |
|---|---|---|
| 团队页通讯录入口 | Flutter UI | 在创建团队加号左侧展示通讯录入口 |
| `WorkHostBridge` | Flutter 宿主适配 | 将打开通讯录的意图传递给 iOS 宿主 |
| `CoHereWorkModuleManager` | iOS 集成 | 处理方法通道调用并执行原生页面导航 |
| `CoHereContactViewController` | 现有原生业务 | 展示好友、搜索、添加好友及通讯录快捷入口 |
| `CoHereContactPageView` | 原生通讯录 UI | 仅在推入模式展示左侧返回按钮并回传点击事件 |

```text
团队页通讯录入口 -> WorkHostBridge -> CoHereWorkModuleManager -> CoHereContactViewController
```

补充约束：`CoHereContactViewController` 从旧原生 Tab 使用时保持根页面样式；仅从团队页推入时启用返回按钮，避免系统导航栏与页面标题栏重复。

## Design: Level 3 -- Interactions

1. 用户点击团队页 AppBar 中位于创建团队加号左侧的通讯录入口。
2. Flutter 团队页将打开通讯录的意图交给 `WorkHostBridge`。
3. `WorkHostBridge` 通过现有 MethodChannel 将该意图发送给 iOS 宿主。
4. `CoHereWorkModuleManager` 在主线程取得当前 Worker 根 `NoaNavigationController`。
5. 通讯录控制器已存在于该导航栈时，导航栈返回已有实例；否则直接创建或复用 `CoHereContactViewController`，启用推入模式并压栈。
6. 推入模式下通讯录标题栏显示返回按钮；用户点击后从当前 Worker 导航栈弹出通讯录。
7. 返回后原 Flutter 页面和路由未被替换，继续停留在团队 Tab。

失败处理：无法取得 Worker 根导航控制器时保持当前团队页，不操作 `CandyTabBarController`，也不直接修改任何 TabBar 受管属性。

## Design: Level 4 -- Contracts

### Flutter

```dart
/// 请求 iOS 宿主从当前 Worker 导航栈打开原生通讯录。
Future<void> WorkHostBridge.openContacts();
```

MethodChannel 契约：通道 `com.cohere.work/bridge`，方法 `openContacts`，无参数。

团队页通过 `Get.find<WorkHostBridge>()` 取得既有桥对象，在创建团队加号左侧新增 `Icons.contacts_outlined` 按钮；按钮 tooltip 使用新增本地化键 `contactsTitle`（中文“通讯录”，英文“Contacts”）。

### iOS Host

```swift
/// Worker 团队页使用的原生通讯录实例，避免连续点击重复创建页面。
private lazy var contactsViewController: CoHereContactViewController

/// 从当前 Worker 根导航栈直接打开通讯录。
private func openNativeContacts()
```

`CoHereWorkModuleManager` 的 MethodChannel handler 新增 `openContacts` 分支；只能直接使用 Worker 根 `NoaNavigationController`，不得调用 `CandyTabBarController`。

### Native Contacts

```swift
/// 是否作为 Worker 导航栈中的二级页面显示返回入口；默认 false。
var coHereShowsBackButtonWhenPushed: Bool = false

/// 推入模式下的返回点击回调。
var CoHereContactPageView.onBackTap: (() -> Void)?

/// 根据页面承载模式显示或隐藏左侧返回按钮。
func CoHereContactPageView.coHereSetBackButtonVisible(_ isVisible: Bool)
```

旧原生 Tab 使用默认 `false`；Worker 创建或复用通讯录实例时设为 `true`。

## Design Summary

- Flutter UI 仅新增团队页通讯录入口，不把宿主导航逻辑放入 `TeamsController`。
- `WorkHostBridge` 继续作为 Flutter 与 iOS 的单一通信边界。
- `CoHereWorkModuleManager` 直接复用 Worker 根导航栈打开 `CoHereContactViewController`。
- `CoHereContactViewController` 与 `CoHereContactPageView` 通过条件模式提供返回能力，旧原生 Tab 行为保持兼容。
- 该功能不新增领域实体、聚合、仓库或网络接口；DDD 建模不适用。
- 禁止依赖或修改 `CandyTabBarController` 及其受管 TabBar 状态。
- 无 requirement document，需求漂移检查已跳过。
- 当前无未解决问题。
