//
//  CoHereInviteFriendViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import UIKit

/// “创建群聊”Swift 控制器，同时承载两个相同 Figma Frame 的运行逻辑。
@objc(CoHereInviteFriendViewController)
final class CoHereInviteFriendViewController: CandyBaseViewController {

    /// When true the page returns selected friends instead of creating a CandyTalk group.
    var selectionOnly = false

    /// Optional allowlist supplied by Worker so non-team friends never appear in task assignment.
    var allowedUserUIDs: Set<String>?

    /// Selection result used by the Flutter host bridge; invoked once before the controller pops.
    var onSelectionComplete: (([[String: String]]) -> Void)?

    /// Cancellation callback completes a pending Flutter method call when the user taps back.
    var onSelectionCancel: (() -> Void)?

    /// 最多可选择人数；由首页或单聊设置页传入。
    @objc var maxNum = 0

    /// 至少选择人数；由入口按创建场景传入。
    @objc var minNum = 0

    /// 从单聊详情创建群聊时自动包含的好友 UID。
    @objc var friendUid = ""

    /// 从单聊详情创建群聊时自动包含的好友昵称。
    @objc var friendNickname = ""

    /// Figma 创建群聊页面。
    private let pageView = CoHereInviteFriendPageView()

    /// 最近联系人及好友分组。
    private var sections: [CoHereSelectionSection] = []

    /// 搜索结果。
    private var searchResults: [NoaBaseUserModel] = []

    /// 当前选择的群成员。
    private var selectedUsers: [NoaBaseUserModel] = []

    /// 当前搜索关键字。
    private var searchText = ""

    /// 初始化页面并读取本地联系人。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        buildLocalSections()
    }

    /// 将 Figma 页面铺满控制器。
    private func setupPage() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        pageView.configureTitle(localized("创建群聊"))
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 连接返回、搜索、选择和创建群聊事件。
    private func bindPageActions() {
        pageView.onBackTap = { [weak self] in self?.cancelOrGoBack() }
        pageView.onDoneTap = { [weak self] in self?.completeSelectionOrCreateGroup() }
        pageView.onSearchChanged = { [weak self] text in self?.updateSearch(text) }
        pageView.onUserToggle = { [weak self] user in self?.toggle(user) }
        pageView.onSelectedUserDelete = { [weak self] user in self?.remove(user) }
        pageView.onSectionToggle = { [weak self] section in
            guard let self, self.sections.indices.contains(section) else { return }
            self.sections[section].isExpanded.toggle()
            self.refreshPage()
        }
        pageView.onSectionSelectAll = { [weak self] section, selected in
            self?.setAll(in: section, selected: selected)
        }
    }

    /// 读取最近单聊和好友分组，过滤系统用户、已注销用户及预置好友。
    private func buildLocalSections() {
        var recent: [NoaBaseUserModel] = []
        let sessions = NoaIMSDKManager.sharedTool()
            .toolGetMySessionListFromSignlChatWithOffServer() as? [LingIMSessionModel] ?? []
        for session in sessions {
            if !friendUid.isEmpty, session.sessionID == friendUid {
                continue
            }
            let friend: LingIMFriendModel? = NoaIMSDKManager.sharedTool()
                .toolCheckMyFriend(with: session.sessionID)
            guard let friend,
                  isAllowed(friend.friendUserUID),
                  friend.userType != 1,
                  friend.disableStatus != 4 else {
                continue
            }
            recent.append(
                makeUser(
                    id: session.sessionID,
                    name: friend.showName.isEmpty ? session.sessionName : friend.showName,
                    avatar: session.sessionAvatar,
                    roleId: friend.roleId,
                    disabled: friend.disableStatus,
                    isGroup: false
                )
            )
            if recent.count >= 50 {
                break
            }
        }
        sections = [
            CoHereSelectionSection(
                title: "\(localized("最近联系人"))(\(recent.count))",
                users: recent,
                isExpanded: true
            )
        ]

        let groups = NoaIMSDKManager.sharedTool()
            .toolGetMyFriendGroupList() as? [LingIMFriendGroupModel] ?? []
        for group in groups {
            var friends: [LingIMFriendModel] = []
            if group.ugType == -1 {
                friends.append(
                    contentsOf: NoaIMSDKManager.sharedTool()
                        .toolGetMyFriendGroupFriends(with: group.ugUuid) as? [LingIMFriendModel] ?? []
                )
                friends.append(
                    contentsOf: NoaIMSDKManager.sharedTool()
                        .toolGetMyFriendGroupFriends(with: "") as? [LingIMFriendModel] ?? []
                )
            } else {
                friends = NoaIMSDKManager.sharedTool()
                    .toolGetMyFriendGroupFriends(with: group.ugUuid) as? [LingIMFriendModel] ?? []
            }
            let users = friends.compactMap { friend -> NoaBaseUserModel? in
                guard friend.friendUserUID != friendUid,
                      isAllowed(friend.friendUserUID),
                      friend.userType != 1,
                      friend.disableStatus != 4 else {
                    return nil
                }
                return makeUser(
                    id: friend.friendUserUID,
                    name: friend.showName.isEmpty ? friend.nickname : friend.showName,
                    avatar: friend.avatar,
                    roleId: friend.roleId,
                    disabled: friend.disableStatus,
                    isGroup: false
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

    /// 使用项目现有好友搜索能力刷新搜索结果。
    private func updateSearch(_ text: String) {
        searchText = text
        searchResults.removeAll()
        if !text.isEmpty {
            let friends = NoaIMSDKManager.sharedTool()
                .toolSearchMyFriend(with: text) as? [LingIMFriendModel] ?? []
            searchResults = friends.compactMap { friend -> NoaBaseUserModel? in
                guard friend.friendUserUID != friendUid,
                      isAllowed(friend.friendUserUID),
                      friend.userType != 1,
                      friend.disableStatus != 4 else {
                    return nil
                }
                return makeUser(
                    id: friend.friendUserUID,
                    name: friend.showName,
                    avatar: friend.avatar,
                    roleId: friend.roleId,
                    disabled: friend.disableStatus,
                    isGroup: false
                )
            }
        }
        refreshPage()
    }

    /// 切换一个联系人的选中状态并执行最大人数限制。
    private func toggle(_ user: NoaBaseUserModel) {
        if isSelected(user) {
            remove(user)
            return
        }
        let limit = maxNum > 0 ? maxNum : Int.max
        guard selectedUsers.count < limit else {
            NoaHUDManager.share().showMessage(
                String(format: localized("最多只能选择%ld人"), limit)
            )
            return
        }
        selectedUsers.append(user)
        refreshPage()
    }

    /// 删除一个已选择联系人。
    private func remove(_ user: NoaBaseUserModel) {
        selectedUsers.removeAll {
            $0.userId == user.userId && $0.isGroup == user.isGroup
        }
        refreshPage()
    }

    /// 全选或取消一个分组，并持续遵守最大人数限制。
    private func setAll(in section: Int, selected: Bool) {
        guard sections.indices.contains(section) else { return }
        if selected {
            let limit = maxNum > 0 ? maxNum : Int.max
            for user in sections[section].users where !isSelected(user) {
                guard selectedUsers.count < limit else {
                    NoaHUDManager.share().showMessage(
                        String(format: localized("最多只能选择%ld人"), limit)
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

    /// 调用原创建群聊接口，保存群资料并进入新群聊。
    private func createGroup() {
        let effectiveCount = selectedUsers.count + (friendUid.isEmpty ? 0 : 1)
        guard effectiveCount >= minNum else {
            NoaHUDManager.share().showMessage(
                String(format: localized("至少选择%ld人"), minNum)
            )
            return
        }
        var members: [CoHereTaskGroupMember] = []
        if !friendUid.isEmpty {
            members.append(CoHereTaskGroupMember(userUID: friendUid, nickname: friendNickname))
        }
        members.append(
            contentsOf: selectedUsers.map {
                CoHereTaskGroupMember(userUID: $0.userId, nickname: $0.name)
            }
        )
        NoaHUDManager.share().showActivityMessage(localized("创建群聊中..."))
        CoHereTaskGroupService.shared.createGroup(title: "", members: members) { [weak self] result in
            switch result {
            case let .success(group):
                NoaHUDManager.share().hideHUD()
                self?.openCreatedGroup(group)
            case let .failure(error):
                NoaHUDManager.share().showMessage(error.localizedDescription)
            }
        }
    }

    /// Completes Worker friend selection or preserves the ordinary native create-group behavior.
    private func completeSelectionOrCreateGroup() {
        guard selectionOnly else {
            createGroup()
            return
        }
        let result = selectedUsers.map {
            ["candyUserUid": $0.userId, "name": $0.name, "avatarUrl": $0.avatar]
        }
        onSelectionComplete?(result)
        onSelectionComplete = nil
        onSelectionCancel = nil
        navigationController?.popViewController(animated: true)
    }

    /// Completes a pending bridge call before returning from selection-only mode.
    private func cancelOrGoBack() {
        if selectionOnly {
            onSelectionCancel?()
            onSelectionComplete = nil
            onSelectionCancel = nil
        }
        navBtnBackClicked()
    }

    /// Checks the optional Worker allowlist while leaving ordinary CandyTalk group creation unrestricted.
    private func isAllowed(_ userUID: String) -> Bool {
        allowedUserUIDs?.contains(userUID) ?? true
    }

    /// 创建成功后进入群聊，并保持原页面只保留根控制器和群聊页的导航栈。
    private func openCreatedGroup(_ group: LingIMGroup) {
        let controller = NoaChatViewController()
        controller.groupInfo = group
        controller.chatType = .groupChat
        controller.chatName = group.groupName
        controller.sessionID = group.groupId
        navigationController?.pushViewController(controller, animated: true)
        if let root = navigationController?.viewControllers.first {
            navigationController?.viewControllers = [root, controller]
        }
    }

    /// 创建多选页通用用户模型。
    private func makeUser(
        id: String,
        name: String,
        avatar: String,
        roleId: Int,
        disabled: Int,
        isGroup: Bool
    ) -> NoaBaseUserModel {
        let model = NoaBaseUserModel()
        model.userId = id
        model.name = name
        model.avatar = avatar
        model.roleId = roleId
        model.disableStatus = disabled
        model.isGroup = isGroup
        model.showRole = !isGroup
        return model
    }

    /// 判断对象是否已选。
    private func isSelected(_ user: NoaBaseUserModel) -> Bool {
        selectedUsers.contains {
            $0.userId == user.userId && $0.isGroup == user.isGroup
        }
    }

    /// 刷新页面全部选择状态。
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
