---
feature: Task Native Group Lifecycle
requirement_doc: null
created: 2026-08-10
status: complete
---

# Task Native Group Lifecycle

> 将 Worker 任务、CandyTalk 用户身份、好友申请和原生群聊串成可恢复、可追踪、可双向清理的完整生命周期。

## Decisions Log

<!-- Add new at bottom. Never remove. -->

| Date | Decision | Reasoning | Alternatives Considered |
|------|----------|-----------|------------------------|
| 2026-08-10 | 团队成员继续由 Flutter 列表展示，成员身份与 CandyTalk 同步并保存到 Worker | Worker 负责协作数据，CandyTalk 负责 IM 用户与好友事实，需要稳定身份映射 | Flutter 与 CandyTalk 各自维护无映射用户；不采用 |
| 2026-08-10 | 非好友先发送 CandyTalk 好友申请，但不等待通过即可尝试加入群聊 | CandyTalk 已确认允许非好友进入群聊，避免把创建任务变成长时间等待流程 | 等好友通过后再建群；不采用 |
| 2026-08-10 | 总人数不足 CandyTalk 建群条件时先创建任务，并标记 `waiting_members` | 单负责人任务仍应成立，达到条件后可自动补建群聊 | 人数不足禁止创建任务；不采用 |
| 2026-08-10 | 任务删除自动解散关联群聊，群聊解散也自动删除关联任务 | 双向清理避免孤立任务或孤立群聊 | 仅群聊解散删除任务；不采用 |
| 2026-08-10 | 团队邀请使用 CandyTalk 原生搜索/选择与好友申请，成功后返回 IM 用户资料并同步 Worker | 复用成熟原生能力并确保 Worker 保存正确 `userUID` | Flutter 独立搜索并猜测 IM 身份；不采用 |
| 2026-08-10 | 任务候选人只展示当前操作人的 CandyTalk 好友，非好友不展示且不尝试入群 | CandyTalk 的直接拉群要求邀请人与被邀请人为好友；这是用户对早期“非好友也尝试”决定的明确替代 | 先申请好友或允许非好友尝试入群；不采用 |
| 2026-08-10 | 创群最低总人数为 3，包含自动入群的任务创建人；人数不足时仅服务端保存 `waiting_members` | 任务可先成立，同时不向页面暴露内部补偿状态 | 人数不足禁止创建任务；不采用 |
| 2026-08-10 | 创建人为群主，负责人必须入群，群名允许重名 | 保持任务责任与群权限一致，不使用群名作为关联键 | 负责人不入群或群名强制唯一；不采用 |
| 2026-08-10 | 任务和群采用可恢复状态机完成双向删除，只有任务创建人可重试、删除和解散 | 跨 Worker/CandyTalk 操作无法使用单一数据库事务，需要幂等操作 ID、来源标记和 `deleting` 补偿 | 客户端串行后直接物理删除；不采用 |
| 2026-08-10 | 历史任务保持旧行为，不自动补建群 | 避免迁移后批量创群或改变旧数据行为 | 对历史任务批量补建群；不采用 |

## Open Questions

- 已只读核对 Worker 线上源码，并将缺失的 `/v1/auth/ios/exchange` 实现同步回本地基线；当前无未决问题。

## Constraints

- CandyTalk `userUID` 与 Worker `userId` 是不同身份，不得互相替代或推断。
- CandyTalk 是好友关系、好友申请、IM 用户资料和群聊状态的事实来源。
- Worker 是团队、任务及任务与群聊关联状态的事实来源。
- 客户端跨系统操作不得假装原子事务；必须持久化状态并支持幂等重试和失败补偿。
- 不依赖 `CandyTabBarController` 完成 Worker 与原生页面桥接。
- 解散群聊和删除任务属于破坏性操作，必须使用稳定关联 ID、幂等接口和来源标记防止循环触发。
- 不得在未包含线上 `/v1/auth/ios/exchange` 实现的旧 Worker 基线上开发或部署新数据库/API 逻辑。

## Key Files

| Path | Role |
|---|---|
| `work_module/lib/features/createTask/create.task.controller.dart` | Flutter 创建任务编排入口 |
| `work_module/lib/features/addTeamMember/add.team.member.controller.dart` | Flutter 团队邀请入口 |
| `work_module/lib/core/host/work_host_bridge.dart` | Flutter 与 CandyTalk 方法通道 |
| `NoaChatKit/CandyTalk/Modules/WorkModule/CoHereWorkModuleManager.swift` | iOS 宿主能力编排 |
| `NoaChatKit/CandyTalk/Modules/WorkModule/CoHereTaskGroupService.swift` | 原生群创建、解散和会话控制器构建 |
| `NoaChatKit/CandyTalk/Modules/Session/Controllers/CoHereInviteFriendViewController.swift` | 现有原生联系人选择和建群代码来源 |
| `NoaChatKit/CandyTalk/Modules/ContactsModule/Controllers/Friend/CoHereAddFriendViewController.swift` | 现有好友校验和申请代码来源 |
| `/Users/gemini/Desktop/Apps/Auror/Worker/service/service.api` | Worker API 合同 |
| `/Users/gemini/Desktop/Apps/Auror/Worker/service/internal/logic/task/create_task_logic.go` | Worker 任务创建事务 |
| `/Users/gemini/Desktop/Apps/Auror/Worker/service/internal/logic/task/group_lifecycle_logic.go` | 群绑定、失败补偿和双向删除状态机 |
| `/Users/gemini/Desktop/Apps/Auror/Worker/service/migrations/007_task_group_lifecycle.sql` | 任务群关联与幂等状态字段迁移 |
