# work_module

`work_module` 是从 Worker 客户端拆出的工作域 Flutter Module，供
`ios-client` 以 Add-to-App 方式承载。

当前模块只包含工作台、团队、任务和通知功能，不包含登录、注册、个人中心或
Flutter 内部底部导航。Worker 服务仍保持独立部署。

## 宿主启动契约

MethodChannel 名称为 `com.cohere.work/bridge`：

- Flutter 启动并建立监听后发送 `moduleReady`。
- ios-client 收到后调用 `bootstrap`，传入非空的 `apiBaseUrl`、`session`、
  `workerUserId`，可选传入 `locale` 和 `themeMode`。
- Worker API 返回 401 时，模块清空内存会话并发送 `sessionExpired`，不进入
  Worker 登录页。
- 二级页面需要控制宿主 TabBar 时，模块发送 `setTabBarHidden`。

本阶段只生成并验证模块产物；ios-client 原生 Engine、Podfile 和 TabBar 接入不在
本目录的修改范围内。
