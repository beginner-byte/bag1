# CIM

## 无界对话-畅聊
简介
[无界对话-畅聊] 是一款基于 iOS 平台的即时通讯应用，旨在为用户提供快速、稳定、安全的实时通信体验。项目支持单聊、群聊、文件传输、语音/视频通话等多种通信功能，并集成了消息通知、离线消息及多终端同步等特性。

## 主要功能
* 实时聊天：支持点对点聊天和群组聊天，消息传输迅速可靠。

* 多媒体消息：支持文字、图片、语音、视频、表情等多种类型的消息发送和接收。

* 语音与视频通话：提供高质量的语音通话和视频通话服务。

* 消息通知：支持本地推送和远程通知，确保用户不会错过重要信息。

* 离线消息同步：无论何时登录，用户都能同步之前的聊天记录。

* 多平台支持：提供与其他平台（如 Web 或 Android）消息同步的能力。

## 环境要求
* Xcode：最新版或与项目兼容的 Xcode 版本

* iOS：最低支持 iOS 13.2 及以上版本

* Objective-C：Objective-C 2.0

* 依赖管理工具：CocoaPods

## 安装与配置
1. 克隆仓库
```
git clone https://git@codeup.aliyun.com:linghe/lingxin/ios/cimsdkcore.git
```
cd your-im-project

2. 安装依赖项

如果项目使用 CocoaPods，请执行：
```
pod install
```
3. 打开项目

使用 Xcode 打开生成的 *.xcworkspace 文件，然后编译并运行项目。

## 项目结构
CIM
```
├── Main                
    └── AppDelegate.h            # 应用入口
    └── Resources                # 资源文件（图片、音频、视频等）
├── BaseModule         
    └── NetWork                  # 网络请求响应处理
        └── ZFileUpload          # 文件上传、下载操作及任务管理
    └── Base                     # 基础类(控制器、页面、模型等)
        └── Manager              # 基础管理类(用户信息、竞速模块、工具类模块、多语言管理等)
            └── NetWorkRacing    # 竞速模块处理
    └── Tools                    # 工具类、三方库、常用工具扩展(字符串、日期等扩展）   
    └── Headers                  # 头文件、宏定义、枚举扩展等
├── Classes     
    └── Team                     # 团队模块 (创建团队、解散团队、添加团队成员等)
    └── MiniApp                  # 小程序模块 (创建小程序、删除小程序、编辑小程序等)
    └── MediaCall                # 音视频通话模块 (单聊音视频、群聊音视频等)
    └── Session                  # 会话列表模块 (置顶、免打扰、删除等操作)
    └── Chat                     # 聊天页面模块 (发送文本消息、图片消息、视频消息等, 引用消息, 转发消息, 翻译消息及红包操作等)
    └── Contacts                 # 联系人模块 (好友列表、群组等 管理好友及群组操作等)
    └── Mine                     # 个人中心模块 (修改昵称、修改头像、查看历史记录、意见反馈等)
    └── Auth                     # 登录注册模块 (邀请码验证、注册账号、登录账号等)
└── Language                     # 多语言模块 (中文、英语、俄语等)

CIMSDKCore
├── Logan                        # 日志上报及管理模块                
├── Connect         
    └── MediaCall                # 音视频连接类 (集成ZeGo及LiveKit音视频功能)
    └── Http                     # 网络请求管理及网络请求接口
    └── Common                   # SDK加解密、公共方法、工具类实现等
    └── Protobuf                 # SDK Protobuf文件
    └── Socket                   # SDK Socket连接管理及配置功能
├── Modules                      # SDK 提供的聊天相关操作接口 (消息发送接收、会话删除、团队创建等)
└── DataBase                     # SDK 本地数据库操作及管理 (消息存储、会话操作存储、群组或好友关系存储等)
```

## 依赖项
* SocketRocket：用于实时通讯的 socket 连接

* AFNetworking：网络请求库

* SDWebImage：图片加载和缓存库

* MJExtension：json转模型库

* WCDB：本地数据库

* ZegoExpressEngine：音视频通话库

* Logan：日志SDK库

* TKThemeConfig：主题配置库

* AliyunOSSiOS：阿里云OSS库

* AlicloudPDNS：aliyun云解析DNS库

* AWSS3：亚马逊云存储库

* QCloudCOSXML：腾讯云存储库

* libOpenInstallSDK：数据统计库

* Protobuf：Protobuf库

## 打包方法:
1. http://10.226.1.11:8080/ 打开上述Jenkins地址
2. 选择iOS_lingxin_new工程进入，进行接下来的变量配置
3. 选择正确的分支branch: origin/master_独立打包
4. 配置打包环境:
   1. complainBaseurl（平台投诉）：使用121212环境域名地址
   2. publishUrlOriginal（logan日志上传地址）：使用121212环境域名地址
   3. aliUrl（阿里云oss地址-不带桶名称，最前面有个点(英文符号)  ，不要遗漏，地址里的%@前面加上反斜杠\）：使用独立打包环境默认值
   4. awsUrl（aws地址，地址里的%@前面加上反斜杠\）：使用独立打包环境默认值
   5. policyUrl（服务协议隐私政策地址）：使用独立打包环境默认值
   6. normarlHttpDNSDomain（解析阿里云桶名的主域名-每天更换桶名）：使用独立打包环境默认值
   7. spareHttpDNSDomain（解析阿里云桶名的备用域名-每周更换桶名）：使用独立打包环境默认值
   8. builtInBucketName（阿里云内置桶名称）：使用独立打包环境默认值
   9. cnAppName（简体中文应用名）：XXX
   10. twAppName（繁体中文应用名）：XXX
   11. enAppName（英文应用名）：XXX
   12. BundleId（应用包名id 示例:xxx.xxx.xxx）： 符合格式即可
   13. versionNum（此处输入应用的版本号，例如：1.2.3或2.1.1等，版本号一般由三位数字及组成中间用英文的 . 进行链接）：版本号
   14. res.zip（App的Logo：AppIcon.appiconset、启动图LaunchImage：LaunchImage.imageset、“关于我们”里图标：img_login_logo.imageset）：App的Logo、启动图LaunchImage、关于我们”里图标，将对应的图片参考下方规则进行替换 
res
```
 ├── AppIcon.appiconset ------------------------------- App的Logo
 │   ├── 1024x1024.png
 │   ├── 120x120 1.png
 │   ├── 120x120.png
 │   ├── 180x180.png
 │   ├── 40x40.png
 │   ├── 58x58.png
 │   ├── 60x60.png
 │   ├── 80x80.png
 │   ├── 87x87.png
 │   └── Contents.json --------------------- 不用修改
 ├── img_login_logo.imageset ---------------- 关于我们-App图标，light是浅色模式的图片，dart是暗黑模图片
 │   ├── Contents.json ---------------------- 不用修改
 │   ├── img_login_logo@2x.png --------------------浅色模式2倍图
 │   ├── img_login_logo@3x.png--------------------浅色模式3倍图
 │   ├── img_login_logo_dark@2x.png--------------------暗黑模式2倍图
 │   └── img_login_logo_dark@3x.png--------------------暗黑模式3倍图
 └── LaunchImage.imageset --------------- App的启动图，light是浅色模式片dart是暗黑模
     ├── Contents.json ---------------------- 不用修改
     ├── LaunchImage_dark.png
     └── LaunchImage_light.png
```

备注：只需要将3个文件夹里，所有的图片进行替换，替换时，新图片的名称和尺寸大小一定要和原来图片保持一致，图片格式为png；3个文件夹里的Contents.json文件不要动，Contents.json文件不要动，Contents.json文件不要动；图片替换完成后打包res.zip，使用jenkins打包时上传res.zip即可。

5. 点击开始构建,等待打包完成
6. 获取ipa包：工作空间/Release/XXX.ipa

注:如遇到打包失败可以尝试重新打包,如果连续失败两次请联系开发


