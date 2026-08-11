//
//  CoHereChatMultiSelectViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import UIKit

/// “选择聊天”Swift 控制器，保留转发、合并转发、推荐名片和二维码分享四种模式。
@objc(CoHereChatMultiSelectViewController)
final class CoHereChatMultiSelectViewController: CandyBaseViewController {

    /// 当前选择页业务类型。
    @objc var multiSelectType: ZMultiSelectType = .singleForward

    /// 原消息会话 ID，用于转发回原会话时回传本地消息。
    @objc var fromSessionId = ""

    /// 单条或逐条转发的原消息列表。
    @objc var forwardMsgList: [Any] = []

    /// 单条转发完成后回传发送到原会话的消息。
    @objc var forwardMsgSendSuccess: (([NoaIMChatMessageModel]) -> Void)?

    /// 消息转发失败回调。
    @objc var forwardMsgSendFail: (() -> Void)?

    /// 合并转发的消息数量。
    @objc var mergeMsgCount = 0

    /// 合并转发选定接收者回调。
    @objc var messageRecordReceverListBlock: (([Any]) -> Void)?

    /// 推荐给朋友的用户资料。
    @objc var cardFriendInfo: NoaUserModel?

    /// 需要分享的二维码卡片图片。
    @objc var qrCodeImg: UIImage?

    /// 二维码分享至原会话后的消息回调。
    @objc var shareQrCodeMsgSendSuccess: ((NoaIMChatMessageModel) -> Void)?

    /// Figma “选择聊天”页面。
    private let pageView = CoHereChatMultiSelectPageView()

    /// 最近会话、群聊和好友分组。
    private var sections: [CoHereSelectionSection] = []

    /// 搜索结果。
    private var searchResults: [NoaBaseUserModel] = []

    /// 当前已选择会话。
    private var selectedUsers: [NoaBaseUserModel] = []

    /// 当前搜索关键字。
    private var searchText = ""

    /// 因群消息发送间隔限制暂不可发送的群会话。
    private var intervalDisabledUsers: [NoaBaseUserModel] = []

    /// 复用原消息转发、名片及二维码发送处理器。
    private let sendHandler = NoaChatMultiSelectSendHander()

    /// 原 Objective-C 页面允许同时选择的最大会话数量。
    private let maximumSelectionCount = 50

    /// 初始化页面并读取本地会话、群聊及好友分组。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        buildLocalSections()
    }

    /// 保持该页面使用项目自定义导航而非系统导航栏。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    /// 将 Figma 页面铺满控制器。
    private func setupPage() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 连接页面返回、搜索、选择、全选和完成事件。
    private func bindPageActions() {
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onDoneTap = { [weak self] in self?.confirmSelection() }
        pageView.onSearchChanged = { [weak self] text in self?.updateSearch(text) }
        pageView.onUserToggle = { [weak self] user in self?.toggle(user) }
        pageView.onSelectedUserDelete = { [weak self] user in self?.remove(user) }
        pageView.onSectionToggle = { [weak self] index in
            guard let self, self.sections.indices.contains(index) else { return }
            self.sections[index].isExpanded.toggle()
            self.refreshPage()
        }
        pageView.onSectionSelectAll = { [weak self] index, selected in
            self?.setAll(in: index, selected: selected)
        }
    }

    /// 读取最近会话、群聊及好友分组，保持原页面数据来源和过滤规则。
    private func buildLocalSections() {
        var recent: [NoaBaseUserModel] = []
        let sessions = NoaIMSDKManager.sharedTool()
            .toolGetMySessionListWithOffServer() as? [LingIMSessionModel] ?? []
        for session in sessions.prefix(50) {
            if session.sessionType == .single {
                let friend: LingIMFriendModel? = NoaIMSDKManager.sharedTool()
                    .toolCheckMyFriend(with: session.sessionID)
                guard let friend, friend.userType != 1, friend.disableStatus != 4 else {
                    continue
                }
                recent.append(
                    makeUser(
                        id: session.sessionID,
                        name: session.sessionName,
                        avatar: session.sessionAvatar,
                        roleId: friend.roleId,
                        disabled: friend.disableStatus,
                        isGroup: false,
                        lastSendTime: 0
                    )
                )
            } else if session.sessionType == .group {
                recent.append(
                    makeUser(
                        id: session.sessionID,
                        name: session.sessionName,
                        avatar: session.sessionAvatar,
                        roleId: session.roleId,
                        disabled: 0,
                        isGroup: true,
                        lastSendTime: session.lastSendMsgTime
                    )
                )
            }
        }
        sections = [
            CoHereSelectionSection(
                title: "\(localized("最近会话"))(\(recent.count))",
                users: recent,
                isExpanded: true
            )
        ]

        let groups = NoaIMSDKManager.sharedTool().toolGetMyGroupList()
        let groupUsers = groups.map {
            makeUser(
                id: $0.groupId,
                name: $0.groupName,
                avatar: $0.groupAvatar,
                roleId: 0,
                disabled: $0.groupStatus,
                isGroup: true,
                lastSendTime: currentGroupLastMessageTime($0.groupId)
            )
        }
        sections.append(
            CoHereSelectionSection(
                title: "\(localized("群聊"))(\(groupUsers.count))",
                users: groupUsers,
                isExpanded: false
            )
        )

        let friendGroups = NoaIMSDKManager.sharedTool()
            .toolGetMyFriendGroupList()
        for group in friendGroups {
            var friends: [LingIMFriendModel] = []
            if group.ugType == -1 {
                friends.append(
                    contentsOf: NoaIMSDKManager.sharedTool()
                        .toolGetMyFriendGroupFriends(with: group.ugUuid)
                )
                friends.append(
                    contentsOf: NoaIMSDKManager.sharedTool()
                        .toolGetMyFriendGroupFriends(with: "")
                )
            } else {
                friends = NoaIMSDKManager.sharedTool()
                    .toolGetMyFriendGroupFriends(with: group.ugUuid)
            }
            let users = friends.compactMap { friend -> NoaBaseUserModel? in
                guard friend.userType != 1, friend.disableStatus != 4 else {
                    return nil
                }
                return makeUser(
                    id: friend.friendUserUID,
                    name: friend.showName,
                    avatar: friend.avatar,
                    roleId: friend.roleId,
                    disabled: friend.disableStatus,
                    isGroup: false,
                    lastSendTime: 0
                )
            }
            let groupName = group.ugName ?? ""
            let title = groupName.isEmpty
                ? localized("默认分组")
                : groupName
            sections.append(
                CoHereSelectionSection(
                    title: "\(title)(\(users.count))",
                    users: users,
                    isExpanded: false
                )
            )
        }
        refreshPage()
    }

    /// 搜索本地好友和群聊。
    private func updateSearch(_ text: String) {
        searchText = text
        searchResults.removeAll()
        if !text.isEmpty {
            let friends = NoaIMSDKManager.sharedTool()
                .toolSearchMyFriend(with: text) as? [LingIMFriendModel] ?? []
            searchResults.append(
                contentsOf: friends.compactMap {
                    guard $0.userType != 1, $0.disableStatus != 4 else { return nil }
                    return makeUser(
                        id: $0.friendUserUID,
                        name: $0.showName,
                        avatar: $0.avatar,
                        roleId: $0.roleId,
                        disabled: $0.disableStatus,
                        isGroup: false,
                        lastSendTime: 0
                    )
                }
            )
            let groups = NoaIMSDKManager.sharedTool()
                .toolSearchMyGroup(with: text)
            searchResults.append(
                contentsOf: groups.map {
                    makeUser(
                        id: $0.groupId,
                        name: $0.groupName,
                        avatar: $0.groupAvatar,
                        roleId: 0,
                        disabled: $0.groupStatus,
                        isGroup: true,
                        lastSendTime: currentGroupLastMessageTime($0.groupId)
                    )
                }
            )
        }
        refreshPage()
    }

    /// 切换会话选择状态并遵守原最大选择数量。
    private func toggle(_ user: NoaBaseUserModel) {
        if isSelected(user) {
            remove(user)
            return
        }
        guard selectedUsers.count < maximumSelectionCount else {
            NoaHUDManager.share().showMessage(
                String(format: localized("最多只能选择%ld个"), maximumSelectionCount)
            )
            return
        }
        selectedUsers.append(user)
        refreshPage()
    }

    /// 删除一个已选择会话。
    private func remove(_ user: NoaBaseUserModel) {
        selectedUsers.removeAll {
            $0.userId == user.userId && $0.isGroup == user.isGroup
        }
        refreshPage()
    }

    /// 全选或取消分组，并持续执行最大选择数量限制。
    private func setAll(in section: Int, selected: Bool) {
        guard sections.indices.contains(section) else { return }
        if selected {
            for user in sections[section].users where !isSelected(user) {
                guard selectedUsers.count < maximumSelectionCount else {
                    NoaHUDManager.share().showMessage(
                        String(format: localized("最多只能选择%ld个"), maximumSelectionCount)
                    )
                    refreshPage()
                    return
                }
                selectedUsers.append(user)
            }
        } else {
            let keys = Set(sections[section].users.map { "\($0.isGroup)-\($0.userId)" })
            selectedUsers.removeAll { keys.contains("\($0.isGroup)-\($0.userId)") }
        }
        refreshPage()
    }

    /// 完成选择后先恢复原有转发确认，再执行群间隔和服务端合规预检查。
    private func confirmSelection() {
        guard !selectedUsers.isEmpty else { return }
        let now = Int64(Date().timeIntervalSince1970 * 1_000)
        let configuredInterval = Int64(
            NoaUrlHostManager.share().appSysSetModel.groupMessageInterval
        )
        let requiredInterval = configuredInterval == 0 ? 2_000 : configuredInterval
        let valid = selectedUsers.filter {
            !$0.isGroup || $0.isOwerOrManager ||
                now - $0.lastSendMsgTime >= requiredInterval
        }
        intervalDisabledUsers = selectedUsers.filter { candidate in
            !valid.contains {
                $0.userId == candidate.userId && $0.isGroup == candidate.isGroup
            }
        }
        guard !valid.isEmpty else {
            showComplianceAlert(
                failures: makeIntervalFailureModels(intervalDisabledUsers)
            )
            return
        }
        let receiverInfo = selectedUsers.map(receiverDictionary)
        showSelectionConfirmation(receiverInfo: receiverInfo)
    }

    /// 按业务类型展示原有转发、名片或二维码确认弹窗。
    /// - Parameter receiverInfo: 弹窗展示头像所需的完整接收者信息。
    private func showSelectionConfirmation(receiverInfo: [[String: Any]]) {
        switch multiSelectType {
        case .singleForward, .mergeForward:
            let tip = NoaMessageForwardTipView(
                forwardMsg: forwardMsgList,
                toAvatarList: receiverInfo,
                mergeMsgCount: mergeMsgCount,
                fromSessionId: fromSessionId,
                multiSelectType: multiSelectType
            )
            tip.sureClick = { [weak self] in
                self?.checkCompliance(receiverInfo: receiverInfo)
            }
            tip.viewShow()
        case .recommentCard:
            let nickname = cardFriendInfo?.nickname ?? ""
            let content = "\(localized("[个人名片]"))\(nickname)"
            let tip = NoaChatMultiSelectTipsView(
                content: content,
                toAvatarList: receiverInfo
            )
            tip.sureClick = { [weak self] in
                self?.checkCompliance(receiverInfo: receiverInfo)
            }
            tip.viewShow()
        case .shareQRImg:
            let content = "\(localized("[图片]"))\(localized("二维码"))"
            let tip = NoaChatMultiSelectTipsView(
                content: content,
                toAvatarList: receiverInfo
            )
            tip.sureClick = { [weak self] in
                self?.checkCompliance(receiverInfo: receiverInfo)
            }
            tip.viewShow()
        default:
            checkCompliance(receiverInfo: receiverInfo)
        }
    }

    /// 请求服务端检查接收会话是否允许执行当前转发操作。
    /// - Parameter receiverInfo: 当前待检查的接收者字典。
    private func checkCompliance(receiverInfo: [[String: Any]]) {
        guard !receiverInfo.isEmpty else { return }
        let parameters = NSMutableDictionary(dictionary: [
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? "",
            "dialogs": receiverInfo,
            "forwardCount": multiSelectType == .singleForward
                ? forwardMsgList.count
                : 1
        ])
        NoaHUDManager.share().showActivityMessage("")
        NoaIMSDKManager.sharedTool().transpondComplianceMessage(
            parameters,
            onSuccess: { [weak self] data, _ in
                NoaHUDManager.share().hideHUD()
                let failures = data as? [Any] ?? []
                self?.handleComplianceResult(
                    failures: failures,
                    receiverInfo: receiverInfo
                )
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().hideHUD()
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 合并服务端异常和本地群间隔异常，并恢复异常详情与继续发送入口。
    private func handleComplianceResult(
        failures: [Any],
        receiverInfo: [[String: Any]]
    ) {
        let serverFailures = NoaForwardMsgPrecheckModel.mj_objectArray(
            withKeyValuesArray: failures
        ) as? [NoaForwardMsgPrecheckModel] ?? []
        let allFailures = makeIntervalFailureModels(intervalDisabledUsers) + serverFailures
        intervalDisabledUsers.removeAll()
        guard !allFailures.isEmpty else {
            continueSending(receivers: selectedUsers, receiverInfo: receiverInfo)
            return
        }
        showComplianceAlert(failures: allFailures)
    }

    /// 展示包含异常详情入口的提示，并在继续时剔除异常会话后重新预检。
    /// - Parameter failures: 本地间隔和服务端预检合并后的异常。
    private func showComplianceAlert(failures: [NoaForwardMsgPrecheckModel]) {
        let failedIDs = Set(failures.map { String($0.dialogInfo.dialogId) })
        let remaining = selectedUsers.filter { !failedIDs.contains($0.userId) }
        let alert = UIAlertController(
            title: localized("提示"),
            message: localized("所选会话存在异常，继续发送将排除异常会话"),
            preferredStyle: .alert
        )
        let detail = UIAlertAction(
            title: localized("异常详情"),
            style: .default
        ) { [weak self] _ in
            let controller = NoaMessageForwardFailVC()
            controller.forwardErroInfoList = failures
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        let continueAction = UIAlertAction(
            title: localized("继续发送"),
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            self.selectedUsers = remaining
            self.refreshPage()
            self.checkCompliance(receiverInfo: remaining.map(self.receiverDictionary))
        }
        continueAction.isEnabled = !remaining.isEmpty
        alert.addAction(detail)
        alert.addAction(continueAction)
        alert.addAction(UIAlertAction(title: localized("取消"), style: .cancel))
        present(alert, animated: true)
    }

    /// 把群发送间隔限制转换成异常详情页使用的预检模型。
    /// - Parameter users: 当前受群间隔限制的群会话。
    /// - Returns: 异常码 41000 对应的详情模型。
    private func makeIntervalFailureModels(
        _ users: [NoaBaseUserModel]
    ) -> [NoaForwardMsgPrecheckModel] {
        users.map { user in
            let dialog = NoaForwardDialogModel()
            dialog.avatar = user.avatar
            dialog.nickname = user.name
            dialog.dialogType = user.isGroup
                ? Int(CIMChatType.groupChat.rawValue)
                : Int(CIMChatType.singleChat.rawValue)
            dialog.dialogId = Int(user.userId) ?? 0
            let exception = NoaForwardExceptionModel()
            exception.code = 41_000
            let model = NoaForwardMsgPrecheckModel()
            model.dialogInfo = dialog
            model.exceptionInfo = exception
            return model
        }
    }

    /// 按当前业务模式执行转发、回调、推荐名片或二维码分享。
    private func continueSending(
        receivers: [NoaBaseUserModel],
        receiverInfo: [[String: Any]]
    ) {
        switch multiSelectType {
        case .mergeForward:
            messageRecordReceverListBlock?(receiverInfo)
            navigationController?.popViewController(animated: true)
        case .recommentCard:
            guard let friendUID = cardFriendInfo?.userUID else { return }
            configureSendHandlerCallbacks(successMessage: localized("已发送"))
            sendHandler.fromSessionId = fromSessionId
            sendHandler.chatMultiSelectRecommendFriendCard(
                friendUID,
                receiverList: receivers
            )
        case .shareQRImg:
            guard let image = qrCodeImg else { return }
            configureSendHandlerCallbacks(successMessage: localized("已发送"))
            sendHandler.fromSessionId = fromSessionId
            sendHandler.shareQRcodeComleteBlock = { [weak self] message in
                guard let message else { return }
                self?.shareQrCodeMsgSendSuccess?(message)
            }
            sendHandler.chatMultiSelectShareQRcodeMessage(
                image,
                selectObjectList: receivers
            )
        default:
            sendForwardMessages(to: receivers)
        }
        updateGroupLastSendTime(receivers)
    }

    /// 组装原接口需要的 IM 消息和接收者列表后交给现有发送处理器。
    private func sendForwardMessages(to receivers: [NoaBaseUserModel]) {
        let sorted = receivers.sorted { !$0.isGroup && $1.isGroup }
        guard let first = sorted.first else { return }
        let messageList = IMChatMessageList()
        messageList.source = "iOS"
        var imMessages: [IMChatMessage] = []
        for (index, item) in forwardMsgList.enumerated() {
            guard let model = item as? NoaMessageModel else {
                continue
            }
            normalizeForwardMessage(model)
            let result = NoaMessageTools.getIMMessage(
                    fromLingIMChatMessageModel: model.message,
                    withChatObject: first,
                    index: Int32(index)
                  )
            guard let chatMessage = result.chatMessage else {
                continue
            }
            chatMessage.deviceType = "IOS"
            chatMessage.deviceUuid = FCUUID.uuidForDevice()
            imMessages.append(chatMessage)
        }
        let toMessages: [ToMessage] = sorted.map { receiver in
            let destination = ToMessage()
            destination.msgIdArray = NSMutableArray(array: forwardMsgList.map { _ in
                NoaMessageTools.getMessageID()
            })
            destination.to = receiver.userId
            destination.chatType = receiver.isGroup ? .groupChat : .singleChat
            return destination
        }
        messageList.iMchatMessageArray = NSMutableArray(array: imMessages)
        messageList.toMessageArray = NSMutableArray(array: toMessages)

        configureSendHandlerCallbacks(successMessage: localized("转发成功"))
        sendHandler.fromSessionId = fromSessionId
        sendHandler.forwardComleteBlock = { [weak self] messages in
            self?.forwardMsgSendSuccess?(messages ?? [])
        }
        sendHandler.chatMultiSelectSendForwardMessageList(
            forwardMsgList,
            imMessage: messageList
        )
    }

    /// 沿用原多选转发页规则，将 @消息和接收消息的译文转换为实际转发文本。
    /// - Parameter model: 当前待转发的消息包装模型；方法会同步清空译文缓存字段。
    private func normalizeForwardMessage(_ model: NoaMessageModel) {
        let message = model.message
        if message.messageType == .atMessage {
            let source: String
            if model.isSelf {
                source = message.atContent ?? ""
            } else if let translated = message.atTranslateContent,
                      !translated.isEmpty {
                source = translated
            } else {
                source = message.atContent ?? ""
            }
            message.textContent = NoaMessageTools
                .forwardMessageAtContenTranslate(
                    toShowContent: source,
                    atUsersDictList: message.atUsersInfoList ?? []
                )
            message.messageType = .textMessage
        } else if !model.isSelf,
                  let translated = message.translateContent,
                  !translated.isEmpty {
            message.textContent = translated
        }
        message.translateContent = nil
        message.againTranslateContent = nil
        message.atTranslateContent = nil
        message.againAtTranslateContent = nil
    }

    /// 配置原发送器统一成功、失败和返回行为。
    private func configureSendHandlerCallbacks(successMessage: String) {
        NoaHUDManager.share().showActivityMessage("")
        sendHandler.navBackActionBlock = { [weak self] success, _, _ in
            NoaHUDManager.share().hideHUD()
            if success {
                NoaHUDManager.share().showMessage(successMessage)
            } else {
                self?.forwardMsgSendFail?()
                NoaHUDManager.share().showMessage(
                    self?.localized("操作失败") ?? ""
                )
            }
            self?.navigationController?.popViewController(animated: true)
        }
    }

    /// 更新群会话最后发送时间，保持原群发送间隔限制的数据来源。
    private func updateGroupLastSendTime(_ receivers: [NoaBaseUserModel]) {
        let now = Int64(Date().timeIntervalSince1970 * 1_000)
        for receiver in receivers where receiver.isGroup {
            let session: LingIMSessionModel? = NoaIMSDKManager.sharedTool()
                .toolCheckMySession(with: receiver.userId)
            guard let session else {
                continue
            }
            session.lastSendMsgTime = now
            NoaIMDBTool.shared().insertOrUpdateSessionModel(with: session)
        }
    }

    /// 创建服务端合规接口使用的接收者字典。
    private func receiverDictionary(_ user: NoaBaseUserModel) -> [String: Any] {
        [
            "dialogType": user.isGroup
                ? CIMChatType.groupChat.rawValue
                : CIMChatType.singleChat.rawValue,
            "dialogId": user.userId,
            "avatar": user.avatar,
            "nickname": user.name
        ]
    }

    /// 获取群会话最后发送时间。
    private func currentGroupLastMessageTime(_ sessionID: String) -> Int64 {
        let session: LingIMSessionModel? = NoaIMSDKManager.sharedTool()
            .toolCheckMySession(with: sessionID)
        return session?.lastSendMsgTime ?? 0
    }

    /// 创建联系人/会话多选模型，并记录群发送间隔所需状态。
    private func makeUser(
        id: String,
        name: String,
        avatar: String,
        roleId: Int,
        disabled: Int,
        isGroup: Bool,
        lastSendTime: Int64
    ) -> NoaBaseUserModel {
        let model = NoaBaseUserModel()
        model.userId = id
        model.name = name
        model.avatar = avatar
        model.roleId = roleId
        model.disableStatus = disabled
        model.isGroup = isGroup
        model.showRole = !isGroup
        model.lastSendMsgTime = lastSendTime
        model.isOwerOrManager = isGroup &&
            NoaIMSDKManager.sharedTool()
                .imSdkGetGroupOwnerAndManager(with: id)
                .contains {
                    $0.userUid ==
                        NoaUserManager.sharedInstance().userInfo?.userUID
                }
        return model
    }

    /// 判断会话是否已选择。
    private func isSelected(_ user: NoaBaseUserModel) -> Bool {
        selectedUsers.contains {
            $0.userId == user.userId && $0.isGroup == user.isGroup
        }
    }

    /// 刷新页面选择状态。
    private func refreshPage() {
        pageView.configure(
            sections: sections,
            searchResults: searchResults,
            selectedUsers: selectedUsers,
            isSearching: !searchText.isEmpty
        )
    }

    /// 获取本地化文案。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
