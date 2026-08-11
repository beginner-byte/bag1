# 邀请码、导航竞速与网络检测流程

本文档根据当前 iOS 项目代码整理，说明邀请码如何换取服务器节点、DNS 与导航竞速的作用，以及 `NoaNetworkDetectionHandle` 的检测流程。

## 一、核心概念

### 1. 邀请码

邀请码在项目中也称为：

- `liceseId`
- `appId`
- `appKey`
- 企业标识

它不是登录密码，而是用于确定用户应连接哪一套企业服务器。

### 2. 导航地址

导航地址不是最终聊天服务器。客户端先连接导航地址，携带邀请码获取真正的 IM、HTTP、TCP 节点和相关配置。

### 3. 竞速

项目中的“竞速”不是一个统一算法，而是多个阶段的统称：

1. **导航发现竞速**：五种 DNS/DoH 来源并发获取候选导航地址；某个来源返回有效候选后即可启动该来源对应的导航 TCP 请求。
2. **导航 TCP 竞速**：候选导航地址并发发送 `IMServerListRequest`，首个成功返回并解析出有效 `IMServerListResponseBody` 的结果生效。
3. **HTTP 节点选择**：当前邀请码主流程不测延迟，直接取导航响应中 HTTP 列表的第一个节点，统一转换为 HTTPS 后写入 SDK 和本地缓存。
4. **TCP/ECDH 竞速**：优先使用持续质量检测器已有的最优节点；没有缓存最优节点时，并发执行 ECDH 连通性探测，首个成功的节点生效。
5. **持续质量检测**：登录后按周期探测 TCP 节点，依据延迟、成功率和稳定性评分更新最优节点。

因此不能把所有阶段都概括为“延迟最低的节点胜出”。只有并发请求或探测阶段采用“首个有效成功结果”；HTTP 主流程当前是按列表顺序选择。

## 二、邀请码总体流程

```text
用户输入邀请码
    ↓
保存到 NoaSsoInfoModel
    ↓
启动 ZHostTool.startHostNodeRace
    ↓
多种 DNS/DoH 方式并发获取导航地址
    ↓
携带邀请码连接候选导航地址
    ↓
第一个成功返回有效节点的地址胜出
    ↓
解析 IMServerListResponseBody
    ↓
获得 HTTP、TCP、兜底地址及客户端配置
    ↓
选择 HTTP 列表第一个节点并配置 HTTPS Host
    ↓
优先复用质量检测最优 TCP 节点；否则并发 ECDH 探测
    ↓
请求系统配置
    ↓
进入注册/登录页面
```

邀请码输入入口：

```text
NoaChatKit/CandyTalk/Auth/Controllers/SsoAccount/
NoaSsoSetViewController.m
```

对应方法：

```objc
- (void)saveUserInputCompanyIdSSoInfo:(NSString *)liceseId;
```

### 1. 邀请码完整调用链

```text
[NoaSsoAccountManagerView] 登录按钮回调 clickLoginBtnAction
    ↓
[NoaSsoSetViewController] processData
    ↓
[NoaSsoSetViewController] saveUserInputCompanyIdSSoInfo:
    ↓
[NoaSsoInfoModel] saveSSOInfo
    ↓
[NoaUrlHostManager] startHostNodeRace
    ↓
[NoaUrlHostManager] hostNodeRace
    ↓
[NoaUrlHostManager] hostNodeRaceWithNetworkQualityTrigger:
    ↓
[NoaUrlHostManager] 五路 DNS/DoH 解析
    ↓
[NoaUrlHostManager] normalizeDomainToIP:
    ↓
[NoaUrlHostManager]
netWorkDirectWithFiltrateBestOssRacingWithOssList:
iscontinue:allowFallbackRetry:sourceTag:isNetworkQualityTrigger:
    ↓
[IOSTcpRaceManager] executeWithSuccess:failure:
    ↓
[IOSTcpRaceManager] establishConnection
    ↓
[IOSTcpRaceManager] createAuthMessageWithClientIP:
    ↓
[IOSTcpRaceManager] sendProtobufMessage:
    ↓
[NoaUrlHostManager] 解析并筛选 HTTP、TCP 节点
    ↓
[NoaUrlHostManager] netWorkFiltrateBestHttpRacingWithList:isNetworkQualityTrigger:
    ↓
[NoaUrlHostManager] netWorkFiltrateBestTcpRacingWithList:isNetworkQualityTrigger:
    ↓
[NoaUrlHostManager] requestSystemConfigInfo
    ↓
[NoaUrlHostManager]
packageRacingResultWithStep:result:racingCode:isNetworkQualityTrigger:
    ↓
[NoaSsoSetViewController] netWorkNodeRacingAndIpDomainConectResult:
```

### 2. 邀请码调用函数说明

| 阶段 | 类名 | 函数或属性 | 输入 | 输出或下一步 |
|---|---|---|---|---|
| 登录按钮事件 | `NoaSsoAccountManagerView` | `clickLoginBtnAction` | 输入框中的邀请码 | 通知控制器处理登录 |
| 绑定页面事件 | `NoaSsoSetViewController` | `processData` | 页面回调 | 调用保存邀请码的方法 |
| 保存邀请码 | `NoaSsoSetViewController` | `saveUserInputCompanyIdSSoInfo:` | `liceseId` | 保存 SSO 信息并启动竞速 |
| 保存 SSO 信息 | `NoaSsoInfoModel` | `saveSSOInfo` | 邀请码、当前导航配置 | 写入本地缓存 |
| 启动竞速 | `NoaUrlHostManager` | `startHostNodeRace` | 当前 SSO 信息 | 进入导航节点查找流程 |
| 执行竞速 | `NoaUrlHostManager` | `hostNodeRace` | 无 | 调用完整导航竞速 |
| 解析导航地址 | `NoaUrlHostManager` | `hostNodeRaceWithNetworkQualityTrigger:` | 是否由质量检测触发 | 并发执行五路 DNS/DoH |
| 规范化地址 | `NoaUrlHostManager` | `normalizeDomainToIP:` | DNS/DoH 返回数据 | 可连接的导航地址数组 |
| 导航竞速 | `NoaUrlHostManager` | `netWorkDirectWithFiltrateBestOssRacingWithOssList:...` | 候选导航地址 | 创建 TCP 导航请求 |
| TCP 导航请求 | `IOSTcpRaceManager` | `executeWithSuccess:failure:` | 邀请码、导航 IP、端口 | 成功返回 `IMServerListResponseBody` |
| 请求系统配置 | `NoaUrlHostManager` | `requestSystemConfigInfo` | 已选中的 HTTP/TCP Host | 获取登录前所需配置 |
| 封装竞速结果 | `NoaUrlHostManager` | `packageRacingResultWithStep:result:racingCode:isNetworkQualityTrigger:` | 阶段、结果、状态码 | 发布竞速结果通知 |
| 页面接收结果 | `NoaSsoSetViewController` | `netWorkNodeRacingAndIpDomainConectResult:` | 竞速通知 | 成功后继续注册/登录流程，失败时显示错误 |

说明：`ZHostTool` 是 `[NoaUrlHostManager shareManager]` 的宏，因此 `[ZHostTool startHostNodeRace]` 实际调用的是 `NoaUrlHostManager`。

## 三、导航地址从哪里获得

### 1. 第一阶段：五路并发解析

输入邀请码后，项目优先并发使用五个来源获取导航地址：

1. 阿里 DNS AAAA
2. 腾讯 DoH AAAA
3. Cloudflare DoH TXT
4. Cloudflare DoH AAAA
5. 阿里 DoH TXT

任意来源返回可用的导航地址后，会立即启动该批候选地址的 TCP 导航请求；其余来源仍可能继续返回结果。`NoaUrlHostManager` 会用竞速会话 ID 忽略过期回调，并取消仍在运行的 DoH/HTTP `NSURLSessionDataTask`。当前主流程没有统一持有并逐个调用所有 `IOSTcpRaceManager.cancel`。

入口：

```objc
- (void)hostNodeRaceWithNetworkQualityTrigger:(BOOL)isNetworkQualityTrigger;
```

文件：

```text
NoaChatKit/CandyTalk/Base/Base/Manager/SsoRacing/
NoaUrlHostManager.m
```

五路解析对应的域名、服务和函数：

| 来源 | 查询域名 | 解析服务 | 端口 | 函数 |
|---|---|---|---|---|
| 阿里 DNSResolver AAAA | `nav.ziyouyi.com` | 阿里 `DNSResolver` SDK，`DNSResolverSchemeHttp` | 由 SDK 管理 | `getDirectOssUrlListFromALIDNSComplete:` |
| 腾讯 DoH AAAA | `pdd.jsimapp.com` | `https://doh.pub/dns-query`、失败后尝试 `https://dns.pub/dns-query` | HTTPS 默认 `443` | `getDirectOssUrlListFromTencentDoHAAAAComplete:` |
| Cloudflare DoH TXT | `jndnav.jiguanged.com` | `https://cloudflare-dns.com/dns-query` | HTTPS 默认 `443` | `getDirectOssUrlListFromCloudflareTXTComplete:` |
| Cloudflare DoH AAAA | `jndnav.jiguanged.com` | `https://cloudflare-dns.com/dns-query` | HTTPS 默认 `443` | `getDirectOssUrlListFromCloudflareAAAAComplete:` |
| 阿里 DoH TXT | `nav.ziyouyi.com` | `https://223.5.5.5/resolve`、失败后尝试 `https://223.6.6.6/resolve` | HTTPS 默认 `443` | `getDirectOssUrlListFromAliDoHTXTComplete:` |

上表域名分别来自 `ALI_HTTPDNS_TEST_DOMAIN`、`TENCENT_HTTPDNS_TEST_DOMAIN` 和 `CF_DOH_TEST_DOMAIN`；五路来源的单次请求和外层超时保护均为 `5` 秒。

### 2. 第二阶段：固定主副域名

如果五路解析都没有获得可用地址，项目使用旧的 `DNSResolver` 逻辑解析固定主副域名。

当前宏定义：

```objc
#define DirectNormarDomain @"nav.loadingworks.com"
#define DirectSpareDomain  @"6.loadingworks.com"
```

定义位置：

```text
NoaChatKit/CandyTalk/Base/Headers/NoaMacroHeader.h
```

主副域名是写入客户端代码的，修改后需要重新打包 App。

对应调用：

| 类名 | 函数 | 作用 |
|---|---|---|
| `NoaUrlHostManager` | `getDirectOssUrlListFromDNSComplete:` | 进入固定主、副域名解析 |
| `DNSResolver` | `getIpv6DataWithDomain:complete:` | 获取域名对应的 IPv6 编码数据 |
| `AliyCloundDNSDecoder` | `v6ToString:` | 将 IPv6 编码数据还原为导航地址 |

### 3. 第三阶段：本地兜底导航地址

如果解析出的导航地址仍然全部连接失败，项目使用本地保存的国内或海外兜底地址。

```text
国内网络 → domesticUrls
海外网络 → overseasUrls
```

这些地址保存在 `NSUserDefaults`。第一次没有缓存时使用代码内置默认值；导航服务器成功返回新地址后，可以动态更新。

相关文件：

```text
NoaChatKit/CandyTalk/Base/Base/Manager/SsoRacing/
NoaFallbackEndpointStore.m
```

对应类与函数：

| 类名 | 函数 | 作用 |
|---|---|---|
| `NoaFallbackEndpointStore` | `shared` | 获取兜底地址存储单例 |
| `NoaFallbackEndpointStore` | `loadFromDefaults` | 从 `NSUserDefaults` 加载兜底地址 |
| `NoaFallbackEndpointStore` | `saveToDefaults` | 保存当前兜底地址 |
| `NoaFallbackEndpointStore` | `updateIfDifferentDomestic:overseas:` | 使用导航响应更新国内、海外地址 |

### 4. 实际优先顺序

```text
五路 DNS/DoH 动态解析
    ↓ 全部失败
固定主副域名的 DNSResolver 解析
    ↓ 解析地址全部连接失败
本地保存的动态兜底地址
```

本地兜底地址不是第一优先级，而是在前面线路均不可用后使用。

## 四、DNSResolver 的作用

`DNSResolver` 来自阿里云 `pdns-sdk-ios`。

它主要负责：

- 将域名解析为 IPv4 或 IPv6 数据。
- 降低运营商 DNS 污染、劫持或地区解析异常的影响。
- 支持缓存、预解析和不同网络环境。
- 为项目获取导航地址。

项目中的调用示例：

```objc
[[DNSResolver share] getIpv6DataWithDomain:domain
                                  complete:^(NSArray<NSString *> *dataArray) {
    // 处理 DNS 返回的数据
}];
```

这个项目有一处特殊设计：DNS 返回的 IPv6 数据还会通过下面的方法解码：

```objc
[AliyCloundDNSDecoder v6ToString:dataArray];
```

解码结果可能是导航地址或节点配置，而不只是普通 IPv6 地址。

## 五、邀请码请求内容

项目使用 TCP Socket 向导航服务器发送 Protobuf 数据，不是普通 JSON HTTP 请求。

实际模型为：

```objc
IMServerListRequest
```

为便于理解，下面用 JSON 表示等价内容：

```json
{
  "dataType": "ImServerListReq",
  "imServerListRequest": {
    "appId": "company123",
    "appType": 0,
    "clientVersion": "1.0.0",
    "region": "CN",
    "deviceType": "ios",
    "timestamp": 1781510400000,
    "signature": "AES加密后的签名",
    "clientIp": "203.0.113.10",
    "sdkVersion": "1.0",
    "nonce": "test_nonce_1781510400000"
  }
}
```

字段说明：

| 字段 | 作用 |
|---|---|
| `appId` | 用户输入的邀请码 |
| `appType` | 公共包或独立包 |
| `clientVersion` | 当前 App 版本 |
| `region` | 当前设备地区 |
| `deviceType` | 固定为 `ios` |
| `timestamp` | 请求时间戳 |
| `signature` | AES 加密后的请求签名 |
| `clientIp` | 设备公网 IP |
| `sdkVersion` | SDK 版本 |
| `nonce` | 防止重放请求的随机值 |

构造请求的位置：

```text
NoaChatKit/CandyTalk/Base/Base/Manager/SsoRacing/
IOSTcpRaceManager.m
```

对应方法：

```objc
- (NavMessage *)createAuthMessageWithClientIP:(NSString *)clientIP;
```

TCP 导航请求的类与函数：

| 阶段 | 类名 | 函数 | 作用 |
|---|---|---|---|
| 创建管理器 | `IOSTcpRaceManager` | `initWithAppId:appType:bucket:useProxy:publicIp:` | 保存邀请码、导航地址和公网 IP |
| 开始请求 | `IOSTcpRaceManager` | `executeWithSuccess:failure:` | 启动 TCP 导航请求 |
| 建立连接 | `IOSTcpRaceManager` | `establishConnection` | 根据配置建立直连或代理连接 |
| TCP 直连 | `IOSTcpRaceManager` | `connectDirectly:port:` | 直接连接导航服务器 |
| SOCKS5 连接 | `IOSTcpRaceManager` | `connectThroughSocks5Proxy:port:proxyConfig:` | 通过代理连接导航服务器 |
| 构造请求 | `IOSTcpRaceManager` | `createAuthMessageWithClientIP:` | 创建 `IMServerListRequest` |
| AES 加密 | `IOSTcpRaceManager` | `encryptWithAES:` | 加密签名或请求数据 |
| 发送请求 | `IOSTcpRaceManager` | `sendProtobufMessage:` | 发送 Protobuf 消息 |
| 取消单个导航任务 | `IOSTcpRaceManager` | `cancel` | 设置取消状态并关闭当前 Socket；当前邀请码主流程未统一持有所有实例并逐个调用 |

## 六、导航服务返回内容

### 1. 外层响应

导航服务返回 `IMServerListResponse`：

```json
{
  "statusCode": 200000,
  "message": "success",
  "responseBody": "加密的Protobuf数据",
  "serverTimestamp": 1781510400123
}
```

`responseBody` 使用邀请码 MD5 派生出的密钥解密：

```objc
[AesEncryptUtils decryptBytes:serverResponse.responseBody
                        secret:[self.appId MD5Encryption]];
```

### 2. 解密后的响应体

解密后得到 `IMServerListResponseBody`。以下是根据模型构造的示例，不是真实服务器数据：

```json
{
  "imEndpoints": [
    {
      "ip": "192.0.2.10",
      "port": 8087,
      "weight": 100,
      "region": "CN",
      "status": "ACTIVE",
      "serverId": "im-01",
      "clusterId": "cluster-a",
      "load": 20,
      "protocols": ["tcp"]
    },
    {
      "ip": "api.example.com",
      "port": 443,
      "weight": 80,
      "status": "ACTIVE",
      "protocols": ["http"]
    }
  ],
  "cacheTtl": 3600,
  "meta": {
    "navVersion": "1.0",
    "traceId": "trace-123",
    "config": {
      "connectTimeout": 10000,
      "readTimeout": 5000,
      "maxRetryCount": 3,
      "raceTimeout": 3000,
      "cacheDuration": 3600,
      "enableNetworkDetect": true,
      "sentryUrls": [],
      "loganUrls": []
    }
  },
  "fallbackEndpoints": {
    "domestic": ["192.0.2.20:8087"],
    "overseas": ["198.51.100.20:8087"]
  }
}
```

返回内容主要用于：

- 保存 IM TCP 长连接节点。
- 保存业务 HTTP 节点。
- 更新国内、海外兜底导航地址。
- 更新 Sentry 和 Logan 地址。
- 下发超时、重试和缓存配置。
- 决定是否启动持续网络质量检测。

响应涉及的主要模型类：

| 类名 | 作用 |
|---|---|
| `NavMessage` | TCP 导航协议的外层消息 |
| `IMServerListRequest` | 邀请码和客户端信息请求 |
| `IMServerListResponse` | 状态码、提示信息和加密响应体 |
| `IMServerListResponseBody` | 解密后的节点、配置和兜底地址 |
| `IMServerEndpoint` | 单个 HTTP 或 TCP 节点 |
| `NavigationMeta` | 导航版本、追踪信息及配置 |
| `NavigationConfig` | 超时、重试、缓存和网络检测开关 |
| `FallbackEndpoints` | 国内、海外兜底导航地址 |

## 七、邀请码错误

项目定义的主要导航状态码：

| 状态码 | 含义 |
|---|---|
| `200000` | 成功 |
| `400001` | 必填字段缺失 |
| `400002` | 邀请码或应用 ID 无效 |
| `400003` | 地区无效 |
| `400004` | 客户端版本无效 |
| `500001` | 服务器内部错误 |
| `500002` | 导航数据格式错误 |
| `500003` | JSON 解析错误 |
| `500004` | 服务器节点解析错误 |

错误邀请码通常对应：

```json
{
  "statusCode": 400002,
  "message": "无效的应用ID"
}
```

## 八、返回节点如何处理

项目会遍历 `imEndpointsArray`：

1. 忽略 `status == INACTIVE` 的节点。
2. `protocols` 包含 `tcp` 时加入 TCP 节点列表。
3. `protocols` 包含 `http` 时加入 HTTP 节点列表。
4. 同一节点同时支持 TCP 和 HTTP 时，可以加入两个列表。

随后：

```text
HTTP 节点 → 请求竞速与接口 Host 选择
TCP 节点  → 连接与 ECDH 密钥交换
```

## 九、NoaNetworkDetectionHandle 流程

`NoaNetworkDetectionHandle` 是网络检测页面的业务核心。

开始检测：

```objc
[self.dataHandle.startDetectionCommand execute:nil];
```

业务调用顺序：

```text
[NoaNetworkDetectionView] networkDetectionSwitchBtn 点击事件
    ↓
[NoaNetworkDetectionHandle] startDetectionCommand execute:nil
    ↓
[NoaNetworkDetectionHandle] startNetworkDetection
    ↓
[NoaNetworkDetectionHandle] cleanLastDetectionData
    ↓
[NoaNetworkDetectionHandle] processData
    ↓
[NoaNetworkDetectionHandle] checkNetworkPermission
    ↓
[NoaNetworkDetectionHandle] checkDomainNameResolution
    ↓
[NoaNetworkDetectionHandle]
domainNameResolutionWithMainDomainComplete:SpareDomainComplete:FinishComplete:
    ↓
[NoaNetworkDetectionHandle] resolveDomain:withMainTypes:completion:
    ↓
[NoaNetworkDetectionHandle] navConnectDetectionWithOssList:
    ↓
[NoaNetworkDetectionHandle] getDevicePublicNetworkIPWithCompletion:
    ↓
[NoaNetworkDetectionHandle]
executeNavDetectionWithUrlModel:ssoNumber:publicIp:group:
    ↓
[IOSTcpRaceManager] executeWithSuccess:failure:
    ↓
[NoaNetworkDetectionHandle] serverConnectDetection
    ↓
[NoaNetworkDetectionHandle]
executeServerConnectivityCheckWithHost:port:tcpItem:group:
    ↓
[NoaNetworkDetectionHandle] checkTcpConnectivityWithHost:port:completion:
    ↓
[NoaNetworkDetectionHandle]
changeNetworkDetectionStatus:ZNetworkDetectFinish
```

### 1. 检测入口与状态管理

| 阶段 | 类名 | 函数或属性 | 作用 |
|---|---|---|---|
| 页面创建业务对象 | `NoaNetworkDetectionVC` | `dataHandle` | 创建并持有 `NoaNetworkDetectionHandle` |
| 点击开始检测 | `NoaNetworkDetectionView` | `networkDetectionSwitchBtn` 点击订阅 | 执行业务对象的检测命令 |
| 命令入口 | `NoaNetworkDetectionHandle` | `startDetectionCommand` | 将按钮事件映射到检测流程 |
| 正式开始 | `NoaNetworkDetectionHandle` | `startNetworkDetection` | 清理旧结果并依次执行检测 |
| 清理结果 | `NoaNetworkDetectionHandle` | `cleanLastDetectionData` | 避免上一次检测数据影响本次结果 |
| 准备分组 | `NoaNetworkDetectionHandle` | `processData` | 根据登录和邀请码状态创建检测项目 |
| 更新状态 | `NoaNetworkDetectionHandle` | `changeNetworkDetectionStatus:` | 更新检测中、成功、失败或完成状态 |
| 统计失败 | `NoaNetworkDetectionHandle` | `getAllUnPassSubResultCount` | 统计未通过的检测分组 |
| 取消检测 | `NoaNetworkDetectionHandle` | `cancelAllDetections` | 取消当前所有网络检测任务 |

### 2. 设备联网检测

通过下面的方法判断设备是否有网络：

```objc
[[NetWorkStatusManager shared] getConnectStatus];
```

生成：

- 设备是否联网
- 网络连接状态是否正常

即使设备未联网，当前代码也不会立即停止，后面的检测仍会执行并产生失败结果。

对应类与函数：

| 类名 | 函数 | 作用 |
|---|---|---|
| `NoaNetworkDetectionHandle` | `checkNetworkPermission` | 创建设备联网检测结果 |
| `NetWorkStatusManager` | `getConnectStatus` | 获取当前设备网络连接状态 |

### 3. DNS 解析检测

同时解析：

- `DirectNormarDomain`
- `DirectSpareDomain`

主、副域名只要有一个成功，该检测分组就算通过。

对应类与函数：

| 类名 | 函数 | 作用 |
|---|---|---|
| `NoaNetworkDetectionHandle` | `checkDomainNameResolution` | 启动主、副域名解析 |
| `NoaNetworkDetectionHandle` | `domainNameResolutionWithMainDomainComplete:SpareDomainComplete:FinishComplete:` | 汇总主、副域名结果 |
| `NoaNetworkDetectionHandle` | `configureDNSResolver` | 配置 DNS 解析器 |
| `NoaNetworkDetectionHandle` | `resolveDomain:withMainTypes:completion:` | 解析单个域名 |
| `DNSResolver` | `getIpv6DataWithDomain:complete:` | 返回域名的 IPv6 编码数据 |
| `NoaNetworkDetectionHandle` | `parseIPv6Data:` | 将 DNS 数据转换为导航地址 |
| `NoaNetworkDetectionHandle` | `processOssUrls:withTypes:ossUrlList:` | 整理可用于检测的导航地址 |

### 4. 导航连接检测

使用解析得到的导航地址，并携带邀请码请求节点列表。

没有邀请码时会随机生成两个字符作为邀请码，仅用于判断导航服务是否可访问。

从导航响应中提取支持 TCP 的有效节点，保存到：

```objc
self.tcpRacingResultArr
```

对应类与函数：

| 类名 | 函数 | 作用 |
|---|---|---|
| `NoaNetworkDetectionHandle` | `navConnectDetectionWithOssList:` | 遍历导航地址并启动连接检测 |
| `NoaNetworkDetectionHandle` | `getDevicePublicNetworkIPWithCompletion:` | 获取设备公网 IP |
| `NoaNetworkDetectionHandle` | `executeNavDetectionWithUrlModel:ssoNumber:publicIp:group:` | 对单个导航地址执行请求 |
| `IOSTcpRaceManager` | `executeWithSuccess:failure:` | 携带邀请码请求节点列表 |
| `IMServerListResponseBody` | `imEndpointsArray` | 提供导航返回的 HTTP/TCP 节点 |

### 5. TCP 与 ECDH 检测

对每个返回的 TCP 节点执行：

```objc
[[NoaIMSDKManager sharedTool]
    probeECDHConnectivityWithHost:host
    port:port
    timeout:-1
    type:0
    completion:...];
```

该步骤检测：

- IP 和端口能否连接。
- ECDH 密钥交换是否成功。
- 连接耗时。

失败结果区分为：

- 无法连接服务器。
- ECDH 密钥交换失败。

对应类与函数：

| 类名 | 函数 | 作用 |
|---|---|---|
| `NoaNetworkDetectionHandle` | `serverConnectDetection` | 开始遍历 TCP 节点 |
| `NoaNetworkDetectionHandle` | `executeServerConnectivityCheckWithHost:port:tcpItem:group:` | 对指定节点执行检测 |
| `NoaNetworkDetectionHandle` | `checkTcpConnectivityWithHost:port:completion:` | 检测 TCP 和 ECDH 是否成功 |
| `NoaIMSDKManager` | `probeECDHConnectivityWithHost:port:timeout:type:completion:` | 实际执行 TCP 连接及 ECDH 探测 |

## 十、不同状态下的检测项目

| 当前状态 | 网络 | DNS | 导航 | TCP/ECDH |
|---|---:|---:|---:|---:|
| 已登录 | 是 | 否 | 否 | 是 |
| 未登录，有邀请码 | 是 | 是 | 是 | 是 |
| 未登录，无邀请码 | 是 | 是 | 是 | 否 |

## 十一、检测结果判定

不同分组的通过规则：

| 分组 | 通过规则 |
|---|---|
| 网络连接 | 所有子项必须成功 |
| DNS 解析 | 至少一个子项成功 |
| 导航检测 | 至少一个地址成功 |
| TCP/ECDH | 至少一个节点成功 |

统计异常分组：

```objc
- (NSInteger)getAllUnPassSubResultCount;
```

这里统计的是失败的分组数量，不是单个失败请求的总数量。

检测结果模型：

| 类名 | 函数或属性 | 作用 |
|---|---|---|
| `NoaNetworkDetectionMessageModel` | `isAllSubFunctionPass` | 根据分组规则判断当前分组是否通过 |
| `NoaNetworkDetectionMessageModel` | 子结果数组 | 保存网络、DNS、导航或 TCP 分组结果 |
| `NoaNetworkDetectionSubResultModel` | 状态、耗时、错误信息 | 保存单个检测项的结果 |

## 十二、网络检测与持续质量检测的区别

### 手动网络检测

由 `NoaNetworkDetectionHandle` 执行，主要用于网络检测页面：

- 检查设备网络。
- 检查 DNS。
- 检查导航。
- 检查 TCP/ECDH。

### 持续网络质量检测

由 `NoaNetworkQualityDetector` 执行：

- 周期性检测 TCP 节点。
- 统计延迟和连续失败次数。
- 根据质量评分选择更优节点。
- 处理网络类型、IP 地址变化等异常。

导航服务器通过下面的配置决定是否启用：

```objc
serverResponse.meta.config.enableNetworkDetect
```

持续检测的类与函数：

| 类名 | 函数 | 作用 |
|---|---|---|
| `NoaNetworkQualityDetector` | `sharedDetector` | 获取持续网络质量检测单例 |
| `NoaNetworkQualityDetector` | `setEnableDetection:` | 开启或关闭持续检测 |
| `NoaUrlHostManager` | `startNetworkQualityDetection:` | 使用当前节点启动质量检测 |
| `NoaUrlHostManager` | `stopNetworkQualityDetection` | 停止持续质量检测 |

## 十三、关键文件索引

| 文件 | 主要类 | 关键函数或作用 |
|---|---|---|
| `NoaSsoAccountManagerView.m` | `NoaSsoAccountManagerView` | 输入邀请码并通过 `clickLoginBtnAction` 回调控制器 |
| `NoaSsoSetViewController.m` | `NoaSsoSetViewController` | `saveUserInputCompanyIdSSoInfo:`、`netWorkNodeRacingAndIpDomainConectResult:` |
| `NoaSsoInfoModel.m` | `NoaSsoInfoModel` | `saveSSOInfo`，保存邀请码及 SSO 配置 |
| `NoaUrlHostManager.m` | `NoaUrlHostManager` | DNS/DoH 解析、导航竞速、HTTP/TCP 节点处理 |
| `IOSTcpRaceManager.m` | `IOSTcpRaceManager` | `executeWithSuccess:failure:`、建立 TCP、发送 Protobuf、解析响应 |
| `Nav.pbobjc.h` | `IMServerListRequest` 等 | 邀请码请求和导航响应的数据结构 |
| `NoaFallbackEndpointStore.m` | `NoaFallbackEndpointStore` | 加载、保存和更新国内、海外兜底导航地址 |
| `NoaNetworkDetectionVC.m` | `NoaNetworkDetectionVC` | 创建网络检测业务对象并承载页面 |
| `NoaNetworkDetectionView.m` | `NoaNetworkDetectionView` | 执行 `startDetectionCommand` |
| `NoaNetworkDetectionHandle.m` | `NoaNetworkDetectionHandle` | 手动网络检测完整流程 |
| `NoaNetworkDetectionMessageModel.m` | `NoaNetworkDetectionMessageModel` | `isAllSubFunctionPass`，判断检测分组是否通过 |
| `NoaNetworkQualityDetector.m` | `NoaNetworkQualityDetector` | 登录后的持续节点质量检测 |
| `NoaMacroHeader.h` | 宏定义 | 固定主副导航域名和 DNS 配置 |

## 十四、简化理解

可以把整套流程理解为：

```text
邀请码 = 企业编号

固定域名、DNS/DoH、兜底地址
    = 用来寻找导航服务器

导航服务器
    = 根据邀请码返回该企业真正使用的服务器

HTTP/TCP 节点
    = App 最终请求接口和建立聊天连接的服务器

竞速
    = 多个候选线路同时请求，选择最快成功且数据有效的线路

网络检测
    = 验证设备网络、DNS、导航、TCP 和 ECDH 整条链路
```
