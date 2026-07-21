# Co Here App

Flutter 客户端默认关闭 Mock，并连接 `https://web.cohereweb.xyz`。直接运行即可使用线上 Co Here 服务：

```bash
flutter run
```

需要连接 `service/` 中的本地 Go-Zero 服务时，通过编译期参数覆盖 API 地址：

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8888
```

Android 模拟器访问宿主机时，将地址替换为 `http://10.0.2.2:8888`。需要使用本地 Mock 后端时，显式传入 `--dart-define=ENABLE_MOCK=true`。
