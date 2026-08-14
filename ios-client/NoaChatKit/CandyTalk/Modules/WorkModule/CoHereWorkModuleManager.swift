import Flutter
import FlutterPluginRegistrant
import UIKit

/// 管理完整 Worker 主界面的单一 FlutterEngine，并桥接 CandyTalk 身份和原生能力。
@objcMembers
public final class CoHereWorkModuleManager: NSObject {
    /// Objective-C 可访问的进程级单例。
    public static let shared = CoHereWorkModuleManager()

    /// iOS 与完整 Worker Flutter 应用共用的通信通道名称。
    private static let channelName = "com.cohere.work/bridge"

    /// 完整 Worker 工作、团队、我的共享的唯一 FlutterEngine。
    private let engine: FlutterEngine

    /// 绑定单 Engine BinaryMessenger 的宿主通信通道。
    private let channel: FlutterMethodChannel

    /// 当前进行中的唯一 Worker 换票请求。
    private var exchangeTask: URLSessionDataTask?

    /// 用户或换票状态变化时递增，防止旧请求覆盖新用户会话。
    private var exchangeGeneration = 0

    /// 最近一次换票成功的内存凭据，不写入磁盘或日志。
    private var currentCredentials: CoHereWorkExchangeResult?

    /// 当前凭据对应的 CandyTalk 用户 UID。
    private var credentialsUserUID: String?

    /// Flutter 通道是否已完成 moduleReady 握手。
    private var moduleReady = false

    /// 是否已经注册 CandyTalk 用户变化通知。
    private var observingUserChanges = false

    /// 原生 IM 会话未读数，Flutter ready 后同步到工作页消息入口。
    private var messageUnreadCount = 0

    /// 原生会话列表控制器，避免重复点击创建多个会话首页实例。
    private lazy var messagesViewController: UIViewController? = {
        guard let controllerType = NSClassFromString("CandyTalkHomeViewController") as? UIViewController.Type else {
            return nil
        }
        return controllerType.init()
    }()

    /// Flutter 团队页使用的 CandyTalk 原生通讯录控制器，避免重复点击创建多个实例。
    private lazy var contactsViewController: CoHereContactViewController = {
        let controller = CoHereContactViewController()
        controller.coHereShowsBackButtonWhenPushed = true
        return controller
    }()

    /// 创建并运行唯一 FlutterEngine，插件和通道只注册一次。
    private override init() {
        let workerEngine = FlutterEngine(name: "cohere_worker_engine")
        engine = workerEngine
        channel = FlutterMethodChannel(
            name: Self.channelName,
            binaryMessenger: workerEngine.binaryMessenger
        )
        super.init()
        workerEngine.run(withEntrypoint: "main", initialRoute: "/work/main")
        GeneratedPluginRegistrant.register(with: workerEngine)
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
    }

    /// 启动用户变化监听；可重复调用且不会重复注册。
    public func start() {
        guard !observingUserChanges else {
            return
        }
        observingUserChanges = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currentUserDidChange),
            name: Notification.Name.NoaCurrentUserDidChange,
            object: nil
        )
    }

    /// 创建承载完整 Worker MainScreen 的 Flutter 根控制器。
    public func makeRootViewController() -> UIViewController {
        start()
        return FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    }

    /// 兼容旧工作 Tab 调用；新入口统一使用 makeRootViewController。
    @available(*, deprecated, message: "Use makeRootViewController for the complete Worker shell")
    public func makeWorkViewController() -> UIViewController {
        makeRootViewController()
    }

    /// 兼容旧团队 Tab 调用；新入口统一由 Worker MainScreen 管理团队页面。
    @available(*, deprecated, message: "Use makeRootViewController for the complete Worker shell")
    public func makeTeamsViewController() -> UIViewController {
        makeRootViewController()
    }

    /// 处理 Flutter 生命周期和宿主能力请求，并确保所有分支完成回调。
    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                result(FlutterError(code: "manager_unavailable", message: nil, details: nil))
                return
            }
            switch call.method {
            case "moduleReady":
                self.moduleReady = true
                self.bootstrapOrRefreshSession()
                self.syncMessageUnreadCount()
                result(true)
            case "sessionExpired":
                self.invalidateWorkerSessionAndRefresh()
                result(true)
            case "openMessages":
                self.openNativeMessages()
                result(true)
            case "openContacts":
                self.openNativeContacts()
                result(true)
            case "updateCurrentUserProfile":
                self.updateCurrentUserProfile(call: call, result: result)
            case "selectTaskFriends":
                self.selectTaskFriends(call: call, result: result)
            case "createTaskGroup":
                self.createTaskGroup(call: call, result: result)
            case "createTeamGroup":
                self.createTeamGroup(call: call, result: result)
            case "inviteTeamGroupMember":
                self.inviteTeamGroupMember(call: call, result: result)
            case "openTaskGroup":
                self.openTaskGroup(call: call, result: result)
            case "dissolveTaskGroup":
                self.dissolveTaskGroup(call: call, result: result)
            case "logout":
                self.logoutFromCandyTalk()
                result(true)
            case "setTabBarHidden":
                // Worker 使用 Flutter 自身底栏，不再控制原生 TabBar。
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Flutter ready 后优先复用同用户凭据，否则发起一次安全换票。
    private func bootstrapOrRefreshSession() {
        let currentUserUID = NoaUserManager.sharedInstance().userInfo?.userUID
        if
            let currentCredentials,
            credentialsUserUID == currentUserUID,
            currentUserUID?.isEmpty == false
        {
            bootstrapFlutter(credentials: currentCredentials)
            return
        }
        refreshWorkerSession()
    }

    /// CandyTalk 用户变化时清除旧 Worker 会话并为新用户重新换票。
    @objc private func currentUserDidChange() {
        invalidateCachedExchange()
        clearFlutterSession()
        refreshWorkerSession()
    }

    /// Worker 会话失效时清除当前凭据并重新换取同一 CandyTalk 用户会话。
    private func invalidateWorkerSessionAndRefresh() {
        invalidateCachedExchange()
        clearFlutterSession()
        refreshWorkerSession()
    }

    /// 取消当前换票并清除只存在内存中的 Worker 凭据。
    private func invalidateCachedExchange() {
        exchangeGeneration += 1
        exchangeTask?.cancel()
        exchangeTask = nil
        currentCredentials = nil
        credentialsUserUID = nil
    }

    /// 使用当前 CandyTalk 用户声明换取 Worker 会话并注入单 Engine。
    private func refreshWorkerSession() {
        guard moduleReady, exchangeTask == nil else {
            return
        }
        guard
            let user = NoaUserManager.sharedInstance().userInfo,
            !user.userUID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let service = CoHereWorkExchangeService.configuredService()
        else {
            clearFlutterSession()
            return
        }
        exchangeGeneration += 1
        let generation = exchangeGeneration
        let expectedUserUID = user.userUID
        exchangeTask = service.exchange(
            user: user,
            deviceID: FCUUID.uuidForDevice(),
            deviceName: UIDevice.current.name
        ) { [weak self] exchangeResult in
            guard let self, generation == self.exchangeGeneration else {
                return
            }
            guard NoaUserManager.sharedInstance().userInfo?.userUID == expectedUserUID else {
                return
            }
            self.exchangeTask = nil
            self.handleExchangeResult(exchangeResult, expectedUserUID: expectedUserUID)
        }
    }

    /// 保存成功凭据并启动 Flutter；失败时保持等待状态且不泄露服务端细节。
    private func handleExchangeResult(
        _ exchangeResult: Result<CoHereWorkExchangeResult, Error>,
        expectedUserUID: String
    ) {
        switch exchangeResult {
        case let .success(credentials):
            currentCredentials = credentials
            credentialsUserUID = expectedUserUID
            bootstrapFlutter(credentials: credentials)
        case .failure:
            currentCredentials = nil
            credentialsUserUID = nil
            clearFlutterSession()
        }
    }

    /// 将 Worker 内存凭据和 CandyTalk 非敏感展示资料注入 Flutter。
    private func bootstrapFlutter(credentials: CoHereWorkExchangeResult) {
        guard
            moduleReady,
            let user = NoaUserManager.sharedInstance().userInfo,
            let rawBaseURL = Bundle.main.object(forInfoDictionaryKey: "WorkerAPIBaseURL") as? String
        else {
            clearFlutterSession()
            return
        }
        let bootstrap: [String: Any] = [
            "apiBaseUrl": rawBaseURL,
            "session": credentials.token,
            "workerUserId": credentials.workerUserID,
            "userUid": user.userUID ?? "",
            "account": user.userName ?? "",
            "displayName": user.nickname ?? "",
            "avatarUrl": user.avatar ?? "",
            "locale": Locale.preferredLanguages.first ?? "",
            "themeMode": "system",
        ]
        channel.invokeMethod("bootstrap", arguments: bootstrap)
    }

    /// 通知 Flutter 清空 GetX 依赖和内存会话。
    private func clearFlutterSession() {
        guard moduleReady else {
            return
        }
        channel.invokeMethod("clearSession", arguments: nil)
    }

    /// 保存原生 IM 未读数并同步到 Worker 工作页消息入口。
    /// - Parameter count: 原生会话总未读数；负数按 0 处理。
    public func updateMessageUnreadCount(_ count: Int) {
        messageUnreadCount = max(0, count)
        syncMessageUnreadCount()
    }

    /// Reports a CandyTalk-owned dissolution event to Worker using the current in-memory session.
    /// - Parameter groupID: Stable group identifier carried by `DelGroupMessage`; empty values are ignored.
    public func notifyTaskGroupDissolved(groupID: String) {
        guard
            !groupID.isEmpty,
            let credentials = currentCredentials,
            let rawBaseURL = Bundle.main.object(forInfoDictionaryKey: "WorkerAPIBaseURL") as? String,
            let baseURL = URL(string: rawBaseURL),
            baseURL.scheme?.lowercased() == "https"
        else {
            return
        }
        var request = URLRequest(
            url: baseURL.appendingPathComponent("v1/tasks/group/dissolved")
        )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(credentials.token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "groupId": groupID,
            "source": "candy_group_event"
        ])
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.httpCookieStorage = nil
        configuration.urlCache = nil
        URLSession(configuration: configuration).dataTask(with: request).resume()
    }

    /// 将当前未读数注入 ready 的 Flutter Engine。
    private func syncMessageUnreadCount() {
        guard moduleReady else {
            return
        }
        channel.invokeMethod(
            "setMessageUnreadCount",
            arguments: ["count": messageUnreadCount]
        )
    }

    /// 从 Worker 工作页打开 CandyTalk 原生会话列表并复用根导航栈。
    private func openNativeMessages() {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let navigationController = appDelegate.window?.rootViewController as? UINavigationController,
            let messagesViewController
        else {
            return
        }
        if navigationController.viewControllers.contains(messagesViewController) {
            navigationController.popToViewController(messagesViewController, animated: true)
            return
        }
        navigationController.pushViewController(messagesViewController, animated: true)
    }

    /// 从当前 Worker 根导航栈直接打开 CandyTalk 原生通讯录。
    private func openNativeContacts() {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let navigationController = appDelegate.window?.rootViewController as? UINavigationController
        else {
            return
        }
        if navigationController.viewControllers.contains(contactsViewController) {
            navigationController.popToViewController(contactsViewController, animated: true)
            return
        }
        navigationController.pushViewController(contactsViewController, animated: true)
    }

    /// 更新 CandyTalk IM 主资料；名字成功后按需上传并更新头像。
    /// - Parameters:
    ///   - call: Flutter 参数，包含新名字以及可选头像字节和文件名。
    ///   - result: 返回 IM 最终名字、头像地址，或可展示的桥接错误。
    private func updateCurrentUserProfile(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard
            let arguments = call.arguments as? [String: Any],
            let rawDisplayName = arguments["displayName"] as? String,
            let user = NoaUserManager.sharedInstance().userInfo
        else {
            result(FlutterError(code: "profile_invalid", message: "当前用户资料不可用", details: nil))
            return
        }
        let displayName = rawDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let userUID = user.userUID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !displayName.isEmpty, !userUID.isEmpty else {
            result(FlutterError(code: "profile_invalid", message: "名字或用户标识无效", details: nil))
            return
        }
        let avatarData = (arguments["avatarBytes"] as? FlutterStandardTypedData)?.data
        let avatarFileName = arguments["avatarFileName"] as? String
        let updateAvatar = { [weak self] in
            self?.uploadAndUpdateCurrentUserAvatar(
                data: avatarData,
                originalFileName: avatarFileName,
                result: result
            )
        }
        if user.nickname == displayName {
            updateAvatar()
            return
        }
        let parameters: NSMutableDictionary = [
            "nickname": displayName,
            "userUid": userUID
        ]
        NoaIMSDKManager.sharedTool().userNicknameChange(
            with: parameters,
            onSuccess: { [weak self] _, _ in
                self?.saveCurrentUser(displayName: displayName, avatarURL: nil)
                updateAvatar()
            },
            onFailure: { code, message, _ in
                result(FlutterError(
                    code: "im_nickname_\(code)",
                    message: message ?? "更新名字失败",
                    details: nil
                ))
            }
        )
    }

    /// 将头像写入 CandyTalk 加密文件队列，并用返回地址更新 IM 头像。
    /// - Parameters:
    ///   - data: Flutter 选择的头像字节；为空表示保留当前头像。
    ///   - originalFileName: 原文件名，仅用于保留安全的图片扩展名。
    ///   - result: 返回最终资料或上传、IM 更新错误。
    private func uploadAndUpdateCurrentUserAvatar(
        data: Data?,
        originalFileName: String?,
        result: @escaping FlutterResult
    ) {
        guard let data else {
            finishCurrentUserProfileUpdate(result: result)
            return
        }
        guard !data.isEmpty, data.count <= 5 * 1024 * 1024 else {
            result(FlutterError(code: "avatar_invalid", message: "头像文件无效或超过 5 MB", details: nil))
            return
        }
        guard let userUID = NoaUserManager.sharedInstance().userInfo?.userUID else {
            result(FlutterError(code: "profile_invalid", message: "当前用户资料不可用", details: nil))
            return
        }
        let allowedExtensions = Set(["jpg", "jpeg", "png", "heic"])
        let requestedExtension = (originalFileName as NSString?)?.pathExtension.lowercased() ?? ""
        let fileExtension = allowedExtensions.contains(requestedExtension) ? requestedExtension : "jpg"
        let fileName = "\(userUID)_\(UUID().uuidString).\(fileExtension)"
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("cohere-worker-avatar", isDirectory: true)
        let fileURL = directory.appendingPathComponent(fileName)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            result(FlutterError(code: "avatar_cache_failed", message: "头像缓存失败", details: nil))
            return
        }
        guard
            let manager = NoaFileUploadManager.sharedInstance(),
            let task = NoaFileUploadTask(
                taskId: fileName,
                filePath: fileURL.path,
                originFilePath: "",
                fileName: fileName,
                fileType: "",
                isEncrypt: true,
                dataLength: UInt(data.count),
                uploadType: .userAvatar,
                beSendMessage: nil,
                delegate: nil
            )
        else {
            try? FileManager.default.removeItem(at: fileURL)
            result(FlutterError(code: "avatar_upload_unavailable", message: "头像上传服务不可用", details: nil))
            return
        }
        let tokenTask = NoaFileUploadGetSTSTask()
        task.addDependency(tokenTask)
        let completion = BlockOperation { [weak self, weak task] in
            DispatchQueue.main.async {
                try? FileManager.default.removeItem(at: fileURL)
                guard let self, let task, task.status == .completed, !task.originUrl.isEmpty else {
                    result(FlutterError(code: "avatar_upload_failed", message: "头像上传失败", details: nil))
                    return
                }
                self.updateCurrentUserAvatar(avatarURL: task.originUrl, result: result)
            }
        }
        completion.addDependency(task)
        manager.add(task)
        manager.operationQueue.addOperation(completion)
        manager.operationQueue.addOperation(tokenTask)
    }

    /// 使用 CandyTalk 用户接口保存头像地址，并同步当前原生用户缓存。
    /// - Parameters:
    ///   - avatarURL: CandyTalk 文件服务返回的头像地址。
    ///   - result: 返回最终资料或 IM 更新错误。
    private func updateCurrentUserAvatar(
        avatarURL: String,
        result: @escaping FlutterResult
    ) {
        let userUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        let parameters: NSMutableDictionary = [
            "avatar": avatarURL,
            "userUid": userUID
        ]
        NoaIMSDKManager.sharedTool().userAvatarChange(
            with: parameters,
            onSuccess: { [weak self] _, _ in
                self?.saveCurrentUser(displayName: nil, avatarURL: avatarURL)
                self?.finishCurrentUserProfileUpdate(result: result)
            },
            onFailure: { code, message, _ in
                result(FlutterError(
                    code: "im_avatar_\(code)",
                    message: message ?? "更新头像失败",
                    details: nil
                ))
            }
        )
    }

    /// 将 IM 已确认成功的展示字段写入 CandyTalk 当前用户模型和 SDK 内存配置。
    /// - Parameters:
    ///   - displayName: 新名字；nil 表示不改名字。
    ///   - avatarURL: 新头像地址；nil 表示不改头像。
    private func saveCurrentUser(displayName: String?, avatarURL: String?) {
        guard let user = NoaUserManager.sharedInstance().userInfo else {
            return
        }
        if let displayName {
            user.nickname = displayName
            NoaIMSDKManager.sharedTool().configNewUserNickName(displayName)
        }
        if let avatarURL {
            user.avatar = avatarURL
            NoaIMSDKManager.sharedTool().configNewUserAvatar(avatarURL)
        }
        // 当前对象已由 NoaUserManager 持有，只需持久化展示资料，避免 setter
        // 把昵称或头像更新误判为登录用户切换并清空 Flutter 的 GetX 依赖。
        user.saveUserInfo()
    }

    /// 读取当前 IM 主资料并完成 Flutter 通道回调。
    /// - Parameter result: 接收名字和头像地址的 Flutter 回调。
    private func finishCurrentUserProfileUpdate(result: @escaping FlutterResult) {
        guard let user = NoaUserManager.sharedInstance().userInfo else {
            result(FlutterError(code: "profile_invalid", message: "当前用户资料不可用", details: nil))
            return
        }
        result([
            "displayName": user.nickname ?? "",
            "avatarUrl": user.avatar ?? ""
        ])
    }

    /// Opens the existing CandyTalk friend selector in return-only mode for Worker assignments.
    /// - Parameters:
    ///   - call: Flutter call containing the team member CandyTalk UID allowlist.
    ///   - result: Completed with selected friend dictionaries, an empty list on cancel, or a bridge error.
    private func selectTaskFriends(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let navigationController = rootNavigationController() else {
            result(FlutterError(code: "navigation_unavailable", message: nil, details: nil))
            return
        }
        let arguments = call.arguments as? [String: Any]
        let allowedUserUIDs = arguments?["allowedCandyUserUids"] as? [String] ?? []
        let controller = CoHereInviteFriendViewController()
        controller.selectionOnly = true
        controller.minNum = 0
        controller.maxNum = allowedUserUIDs.count
        let allowlist = Set(allowedUserUIDs.filter { !$0.isEmpty })
        controller.allowedUserUIDs = allowlist.isEmpty ? nil : allowlist
        controller.onSelectionComplete = { selected in result(selected) }
        controller.onSelectionCancel = { result([]) }
        navigationController.pushViewController(controller, animated: true)
    }

    /// Creates a task-owned CandyTalk group without presenting the ordinary create-group page.
    /// - Parameters:
    ///   - call: Flutter call containing the task title and selected friend identities.
    ///   - result: Group id and exact member UID list, or a FlutterError on SDK failure.
    private func createTaskGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "invalid_arguments", message: nil, details: nil))
            return
        }
        let title = arguments["title"] as? String ?? ""
        let rawMembers = arguments["members"] as? [[String: Any]] ?? []
        let members = rawMembers.compactMap { raw -> CoHereTaskGroupMember? in
            guard let userUID = raw["candyUserUid"] as? String, !userUID.isEmpty else {
                return nil
            }
            return CoHereTaskGroupMember(userUID: userUID, nickname: raw["name"] as? String ?? "")
        }
        CoHereTaskGroupService.shared.createGroup(title: title, members: members) { creationResult in
            switch creationResult {
            case let .success(group):
                let ownerUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
                let memberUIDs = Array(Set(members.map(\.userUID) + [ownerUID])).filter { !$0.isEmpty }
                result(["groupId": group.groupId ?? "", "memberCandyUserUids": memberUIDs])
            case let .failure(error):
                result(FlutterError(code: "create_group_failed", message: error.localizedDescription, details: nil))
            }
        }
    }

    /// Creates a team-owned CandyTalk group for the current team creator.
    /// - Parameters:
    ///   - call: Flutter call containing the Worker-approved team title and complete member list.
    ///   - result: Stable group id only, or a bounded FlutterError when validation or SDK creation fails.
    private func createTeamGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let currentUserUID = NoaUserManager.sharedInstance().userInfo?.userUID,
              !currentUserUID.isEmpty else {
            result(FlutterError(code: "invalid_team_group_arguments", message: nil, details: nil))
            return
        }
        let title = arguments["title"] as? String ?? ""
        let rawMembers = arguments["members"] as? [[String: Any]] ?? []
        let members = rawMembers.compactMap { raw -> CoHereTaskGroupMember? in
            guard let userUID = raw["candyUserUid"] as? String, !userUID.isEmpty else {
                return nil
            }
            return CoHereTaskGroupMember(userUID: userUID, nickname: raw["name"] as? String ?? "")
        }
        let uniqueMemberUIDs = Set(members.map(\.userUID))
        guard uniqueMemberUIDs.contains(currentUserUID), uniqueMemberUIDs.count >= 3 else {
            result(FlutterError(code: "invalid_team_members", message: "Team group requires the current creator and at least three members", details: nil))
            return
        }
        CoHereTaskGroupService.shared.createGroup(title: title, members: members) { creationResult in
            switch creationResult {
            case let .success(group):
                let groupID = group.groupId
                guard !groupID.isEmpty else {
                    result(FlutterError(code: "invalid_group", message: "CandyTalk returned an empty group id", details: nil))
                    return
                }
                let ownerUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
                let memberUIDs = Array(Set(members.map(\.userUID) + [ownerUID])).filter { !$0.isEmpty }
                result(["groupId": groupID, "memberCandyUserUids": memberUIDs])
            case let .failure(error):
                result(FlutterError(code: "create_team_group_failed", message: error.localizedDescription, details: nil))
            }
        }
    }

    /// Invites one newly joined Worker team member into an existing CandyTalk group.
    /// - Parameters:
    ///   - call: Flutter call containing group id, CandyTalk user id and current display name.
    ///   - result: True only after CandyTalk accepts the invite request, otherwise a bounded FlutterError.
    private func inviteTeamGroupMember(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "invalid_member_invite", message: nil, details: nil))
            return
        }
        let groupID = arguments["groupId"] as? String ?? ""
        let userUID = arguments["candyUserUid"] as? String ?? ""
        let name = arguments["name"] as? String ?? ""
        CoHereTaskGroupService.shared.inviteMember(groupID: groupID, member: CoHereTaskGroupMember(userUID: userUID, nickname: name)) { inviteResult in
            switch inviteResult {
            case .success:
                result(true)
            case let .failure(error):
                result(FlutterError(code: "invite_team_member_failed", message: error.localizedDescription, details: nil))
            }
        }
    }

    /// Opens the native CandyTalk chat controller for one locally known task group.
    private func openTaskGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? [String: Any])?["groupId"] as? String ?? ""
        guard let navigationController = rootNavigationController(),
              let controller = CoHereTaskGroupService.shared.chatViewController(groupID: groupID) else {
            result(FlutterError(code: "group_unavailable", message: nil, details: nil))
            return
        }
        navigationController.pushViewController(controller, animated: true)
        result(true)
    }

    /// Dissolves a task group as the current CandyTalk owner and returns only after SDK confirmation.
    private func dissolveTaskGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? [String: Any])?["groupId"] as? String ?? ""
        CoHereTaskGroupService.shared.dissolveGroup(groupID: groupID) { dissolutionResult in
            switch dissolutionResult {
            case .success:
                result(true)
            case let .failure(error):
                result(FlutterError(code: "dissolve_group_failed", message: error.localizedDescription, details: nil))
            }
        }
    }

    /// Returns the single native navigation stack that owns the embedded Worker controller.
    private func rootNavigationController() -> UINavigationController? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.window?.rootViewController as? UINavigationController
    }

    /// 清除 Worker 内存凭据并调用 CandyTalk 原生完整退出流程。
    private func logoutFromCandyTalk() {
        invalidateCachedExchange()
        clearFlutterSession()
        NoaToolManager.share().setupLoginUI()
    }

    /// 兼容旧调用；完整 Worker 主框架由 Flutter MainController 自行切换。
    @available(*, deprecated, message: "Worker MainController owns root tab selection")
    public func showWorkRoot() {}

    /// 兼容旧调用；完整 Worker 主框架由 Flutter MainController 自行切换。
    @available(*, deprecated, message: "Worker MainController owns root tab selection")
    public func showTeamsRoot() {}

    /// 解除系统通知监听；进程级单例通常与应用同生命周期。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
