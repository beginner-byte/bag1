//
//  CoHereContactViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import MJExtension
import UIKit

/// “通讯录”Swift 控制器，负责好友数据、SDK 回调、业务路由和 Figma 页面状态。
@objc(CoHereContactViewController)
final class CoHereContactViewController: CandyBaseViewController,
    NoaToolUserDelegate,
    UIGestureRecognizerDelegate
{

    /// 是否作为 Worker 导航栈二级页面显示返回按钮；原生 Tab 根页面默认不显示。
    var coHereShowsBackButtonWhenPushed = false

    /// 好友读取与排序使用的串行队列，避免 SDK 回调并发修改页面数据。
    private let coHereFriendQueue = DispatchQueue(
        label: "com.cohere.contact.friend-list"
    )

    /// 按拼音首字母分组后的好友模型。
    private var coHereGroupedFriends: [[LingIMFriendModel]] = []

    /// 与好友分组一一对应的 A-Z 或 # 标题。
    private var coHereSectionTitles: [String] = []

    /// Figma 对应的完整通讯录页面。
    private let coHerePageView = CoHereContactPageView()

    /// 根通讯录页面左侧边缘抽屉手势。
    private lazy var coHereEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(coHereHandleLeftEdgePan(_:))
        )
        gesture.edges = .left
        gesture.delegate = self
        return gesture
    }()

    /// 创建 Swift 页面、注册通知和 SDK delegate，并读取本地好友列表。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        coHereSetupPage()
        coHereBindPageActions()
        coHereSetupObservers()
        view.addGestureRecognizer(coHereEdgePanGesture)
        coHerePageView.tableView.panGestureRecognizer.require(
            toFail: coHereEdgePanGesture
        )
        NoaIMSDKManager.sharedTool().addUserDelegate(self)
        coHereReloadFriendsFromDatabase()
        coHereRefreshQuickActionsAndBadge()
    }

    /// 页面出现前刷新文件助手权限和好友申请红点。
    /// - Parameter animated: 是否使用系统页面切换动画。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coHereRefreshQuickActionsAndBadge()
    }

    /// 移除通知和 SDK delegate，防止控制器释放后继续接收回调。
    deinit {
        NotificationCenter.default.removeObserver(self)
        NoaIMSDKManager.sharedTool().removeUserDelegate(self)
    }

    /// 将 Figma Swift 页面约束到控制器可见区域和 TabBar Safe Area。
    private func coHereSetupPage() {
        coHerePageView.accessibilityIdentifier = "cohere.contact"
        coHerePageView.coHereSetBackButtonVisible(
            coHereShowsBackButtonWhenPushed
        )
        coHerePageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coHerePageView)
        NSLayoutConstraint.activate([
            coHerePageView.topAnchor.constraint(equalTo: view.topAnchor),
            coHerePageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coHerePageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coHerePageView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }

    /// 绑定搜索、添加好友、快捷入口和好友行点击事件。
    private func coHereBindPageActions() {
        coHerePageView.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        coHerePageView.onSearchTap = { [weak self] in
            self?.coHereOpenGlobalSearch()
        }
        coHerePageView.onAddFriendTap = { [weak self] in
            self?.coHereOpenAddFriend()
        }
        coHerePageView.onQuickActionTap = { [weak self] action in
            self?.coHereHandleQuickAction(action)
        }
        coHerePageView.onFriendTap = { [weak self] section, row in
            self?.coHereOpenFriend(section: section, row: row)
        }
    }

    /// 注册好友红点、文件助手权限变化和主列表滚动恢复通知。
    private func coHereSetupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(coHereFriendApplyCountDidChange),
            name: Notification.Name("FriendApplyCountChange"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(coHereFileHelperAuthorityDidChange),
            name: Notification.Name(
                "UserRoleAuthorityFileHelperChangeNotification"
            ),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(coHereRestoreMainScroll),
            name: Notification.Name("ContactScrollEnable"),
            object: nil
        )
    }

    /// 根据权限重建快捷入口，并同步好友申请红点到页面和 TabBar。
    private func coHereRefreshQuickActionsAndBadge() {
        var actions: [CoHereContactQuickAction] = [
            CoHereContactQuickAction(
                kind: .newFriend,
                title: coHereLocalized("新的朋友"),
                iconName: "cohere_contact_new_friend",
                iconBackgroundColor: UIColor(coHereContactHex: 0x6B3BFA),
                usesTemplateIcon: false
            )
        ]

        actions.append(
            contentsOf: [
                CoHereContactQuickAction(
                    kind: .friendGroup,
                    title: coHereLocalized("分组"),
                    iconName: "cohere_contact_friend_group",
                    iconBackgroundColor: UIColor(
                        coHereContactHex: 0x07C160
                    ),
                    usesTemplateIcon: false
                ),
                CoHereContactQuickAction(
                    kind: .groupChat,
                    title: coHereLocalized("群聊"),
                    iconName: "cohere_contact_group_chat",
                    iconBackgroundColor: UIColor(
                        coHereContactHex: 0xFA9D3B
                    ),
                    usesTemplateIcon: false
                )
            ]
        )

        let friendApplyCount =
            NoaIMSDKManager.sharedTool().toolFriendApplyCount()
        coHerePageView.coHereConfigure(
            quickActions: actions,
            friendSections: coHereFriendPresentationSections(),
            friendApplyCount: friendApplyCount
        )
        (tabBarController as? CandyTabBarController)?
            .setBadgeValue(1, number: friendApplyCount)
    }

    /// 读取 SDK 本地好友列表，在串行队列中完成过滤、排序和分组。
    private func coHereReloadFriendsFromDatabase() {
        coHereFriendQueue.async { [weak self] in
            guard let self else {
                return
            }
            let friends =
                NoaIMSDKManager.sharedTool().toolGetMyFriendList()
            let result = coHereGroupAndSortFriends(friends)
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                coHereSectionTitles = result.titles
                coHereGroupedFriends = result.groups
                coHereRefreshQuickActionsAndBadge()
            }
        }
    }

    /// 将业务好友转换为页面展示分组，同时保留原模型供点击和 SDK 更新使用。
    /// - Returns: Figma 页面可直接渲染的联系人分组。
    private func coHereFriendPresentationSections()
        -> [CoHereContactFriendSection]
    {
        coHereGroupedFriends.enumerated().map { sectionIndex, friends in
            let title = coHereSectionTitles.indices.contains(sectionIndex)
                ? coHereSectionTitles[sectionIndex] : ""
            let items = friends.map { friend -> CoHereContactFriendItem in
                let avatar = NSString.loadAvatar(
                    withUserStatus: friend.disableStatus,
                    avatarUri: friend.avatar
                )
                let displayName = NSString.loadNickName(
                    withUserStatus: friend.disableStatus,
                    realNickName: friend.showName
                )
                let usesDeletedAvatar = avatar.hasPrefix(
                    "user_accout_delete_avatar"
                )
                let roleName = NoaUserManager.sharedInstance()
                    .matchUserRoleConfigInfo(
                        friend.roleId,
                        disableStatus: friend.disableStatus
                    )
                return CoHereContactFriendItem(
                    displayName: displayName,
                    avatarURL: usesDeletedAvatar
                        ? nil : avatar.getImageFullUrl(),
                    usesDeletedAvatar: usesDeletedAvatar,
                    roleName: roleName
                )
            }
            return CoHereContactFriendSection(title: title, items: items)
        }
    }

    /// 按旧页面规则过滤系统账号、生成拼音首字母并把注销账号放入 # 末尾。
    /// - Parameter friends: SDK 本地好友列表。
    /// - Returns: 排序后的标题和好友二维数组。
    private func coHereGroupAndSortFriends(
        _ friends: [LingIMFriendModel]
    ) -> (titles: [String], groups: [[LingIMFriendModel]]) {
        var buckets: [String: [(model: LingIMFriendModel, sortName: String)]] =
            [:]
        var signedOutItems: [(model: LingIMFriendModel, sortName: String)] = []

        for friend in friends where friend.userType == 0 {
            let sortName = coHereProcessedSortName(friend)
            if friend.disableStatus == 4 {
                signedOutItems.append((friend, sortName))
                continue
            }
            let firstCharacter = sortName.first.map(String.init) ?? "#"
            let key = firstCharacter.range(
                of: "^[A-Z]$",
                options: .regularExpression
            ) == nil ? "#" : firstCharacter
            buckets[key, default: []].append((friend, sortName))
        }

        var titles = buckets.keys
            .filter { $0 != "#" }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        if buckets["#"] != nil || !signedOutItems.isEmpty {
            titles.append("#")
        }

        var groups: [[LingIMFriendModel]] = []
        for title in titles {
            var items = buckets[title] ?? []
            items.sort {
                coHereCompareSortNames($0.sortName, $1.sortName)
                    == .orderedAscending
            }
            if title == "#" {
                signedOutItems.sort {
                    coHereCompareSortNames($0.sortName, $1.sortName)
                        == .orderedAscending
                }
                items.append(contentsOf: signedOutItems)
            }
            groups.append(items.map(\.model))
        }
        return (titles, groups)
    }

    /// 生成旧页面使用的“显示名 + 账号”大写拼音首字母排序值。
    /// - Parameter friend: 需要计算排序值的好友。
    /// - Returns: 去除空格后的大写排序字符串。
    private func coHereProcessedSortName(
        _ friend: LingIMFriendModel
    ) -> String {
        let combined = "\(friend.showName ?? "")\(friend.userName ?? "")"
        var transformed = ""
        for scalar in combined.unicodeScalars {
            if (0x4E00...0x9FFF).contains(scalar.value) {
                let mutable = NSMutableString(string: String(scalar))
                CFStringTransform(
                    mutable,
                    nil,
                    kCFStringTransformMandarinLatin,
                    false
                )
                let pinyin = (mutable as String).folding(
                    options: .diacriticInsensitive,
                    locale: .current
                )
                if let initial = pinyin.first {
                    transformed.append(initial)
                }
            } else {
                transformed.append(Character(String(scalar)))
            }
        }
        return transformed.replacingOccurrences(of: " ", with: "").uppercased()
    }

    /// 按旧页面规则比较排序值：字母优先于数字，同类按字符码顺序。
    /// - Parameters:
    ///   - left: 左侧好友排序值。
    ///   - right: 右侧好友排序值。
    /// - Returns: Foundation 排序结果。
    private func coHereCompareSortNames(
        _ left: String,
        _ right: String
    ) -> ComparisonResult {
        let leftCharacters = Array(left.utf16)
        let rightCharacters = Array(right.utf16)
        let sharedCount = min(leftCharacters.count, rightCharacters.count)

        for index in 0..<sharedCount {
            let leftValue = leftCharacters[index]
            let rightValue = rightCharacters[index]
            if leftValue == rightValue {
                continue
            }
            let leftType = coHereSortCharacterType(leftValue)
            let rightType = coHereSortCharacterType(rightValue)
            guard leftType > 0, rightType > 0 else {
                return .orderedSame
            }
            if leftType != rightType {
                return leftType > rightType ? .orderedAscending : .orderedDescending
            }
            return leftValue < rightValue ? .orderedAscending : .orderedDescending
        }
        if leftCharacters.count == rightCharacters.count {
            return .orderedSame
        }
        return leftCharacters.count < rightCharacters.count
            ? .orderedAscending : .orderedDescending
    }

    /// 判断排序字符类型，字母返回 10、数字返回 8、其他返回 0。
    /// - Parameter value: UTF-16 字符值。
    /// - Returns: 旧 Objective-C 排序逻辑使用的优先级。
    private func coHereSortCharacterType(_ value: UInt16) -> Int {
        guard let scalar = UnicodeScalar(value) else {
            return 0
        }
        if CharacterSet.letters.contains(scalar) {
            return 10
        }
        if CharacterSet.decimalDigits.contains(scalar) {
            return 8
        }
        return 0
    }

    /// 处理 Figma 快捷入口对应的现有业务导航。
    /// - Parameter action: 被点击入口的稳定业务类型。
    private func coHereHandleQuickAction(
        _ action: CoHereContactQuickActionKind
    ) {
        switch action {
        case .newFriend:
            navigationController?.pushViewController(
                CoHereNewFriendListViewController(),
                animated: true
            )
        case .fileHelper:
            let controller = CoHereFileHelperViewController()
            controller.sessionID = "100002"
            navigationController?.pushViewController(controller, animated: true)
        case .friendGroup:
            coHereOpenEmbeddedList(
                title: coHereLocalized("分组"),
                controller: NoaFriendGroupListVC()
            ) { controller in
                (controller as? NoaFriendGroupListVC)?
                    .friendGroupListScrollEnable(true)
            }
        case .groupChat:
            coHereOpenEmbeddedList(
                title: coHereLocalized("群聊"),
                controller: NoaGroupListVC()
            ) { controller in
                (controller as? NoaGroupListVC)?
                    .groupListScrollEnable(true)
            }
        case .groupHelper:
            let controller = NoaSystemMessageVC()
            controller.groupHelperType = .sessionList
            controller.groupId = ""
            controller.sessionModel = NoaIMSDKManager.sharedTool()
                .toolCheckMySession(with: .systemMessage)
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    /// 使用 Swift 导航壳承载原分组或群聊业务控制器。
    /// - Parameters:
    ///   - title: 子页面标题。
    ///   - controller: 继续复用的 Objective-C 业务控制器。
    ///   - activate: 子控制器加载后启用独立滚动的回调。
    private func coHereOpenEmbeddedList(
        title: String,
        controller: UIViewController,
        activate: @escaping (UIViewController) -> Void
    ) {
        let wrapper = CoHereContactListContainerViewController(
            titleText: title,
            contentController: controller,
            activateContent: activate
        )
        wrapper.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(wrapper, animated: true)
    }

    /// 打开全局搜索页面。
    private func coHereOpenGlobalSearch() {
        navigationController?.pushViewController(
            NoaGlobalSearchVC(),
            animated: true
        )
    }

    /// 打开添加好友页面。
    private func coHereOpenAddFriend() {
        navigationController?.pushViewController(
            CoHereAddFriendViewController(),
            animated: true
        )
    }

    /// 打开指定分组和行对应的好友主页。
    /// - Parameters:
    ///   - section: 好友拼音分组下标。
    ///   - row: 分组内好友下标。
    private func coHereOpenFriend(section: Int, row: Int) {
        guard coHereGroupedFriends.indices.contains(section),
              coHereGroupedFriends[section].indices.contains(row) else {
            return
        }
        let friend = coHereGroupedFriends[section][row]
        guard friend.userType == 0 else {
            return
        }
        let controller = NoaUserHomePageVC()
        controller.userUID = friend.friendUserUID
        controller.groupID = ""
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 好友申请数量变化后刷新新朋友行和 TabBar 红点。
    @objc private func coHereFriendApplyCountDidChange() {
        coHereRefreshQuickActionsAndBadge()
    }

    /// 文件助手权限变化后重新生成快捷入口。
    @objc private func coHereFileHelperAuthorityDidChange() {
        coHereRefreshQuickActionsAndBadge()
    }

    /// 子列表回到顶部时恢复主通讯录列表滚动能力。
    @objc private func coHereRestoreMainScroll() {
        coHerePageView.tableView.isScrollEnabled = true
    }

    /// 根通讯录左侧滑动超过 60pt 时打开“我的”抽屉。
    /// - Parameter recognizer: 左侧边缘滑动手势。
    @objc private func coHereHandleLeftEdgePan(
        _ recognizer: UIScreenEdgePanGestureRecognizer
    ) {
        guard navigationController?.viewControllers.first === self else {
            return
        }
        let translation = recognizer.translation(in: view)
        if recognizer.state == .ended || recognizer.state == .cancelled,
           translation.x > 60 {
            CoHereMineViewController.presentMineDrawerFromTop()
        }
    }

    /// 允许边缘抽屉手势与列表滚动同时识别，保持旧页面触发概率。
    /// - Parameters:
    ///   - gestureRecognizer: 当前手势。
    ///   - otherGestureRecognizer: 另一个竞争手势。
    /// - Returns: 始终允许同时识别。
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    /// 仅允许根通讯录控制器响应左侧抽屉手势，避免覆盖系统返回。
    /// - Parameter gestureRecognizer: 待开始的手势。
    /// - Returns: 当前页面允许识别时返回 true。
    func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer === coHereEdgePanGesture {
            return navigationController?.viewControllers.first === self
        }
        return true
    }

    /// 好友确认成功后重新读取完整好友列表。
    /// - Parameter message: SDK 好友确认消息。
    func cimToolUserFriendConfirm(_ message: IMServerMessage) {
        if message.friendConfirmMessage.status == 1 {
            coHereReloadFriendsFromDatabase()
        }
    }

    /// 好友资料变化后重新读取本地好友列表。
    /// - Parameter message: 发生变化的好友模型。
    func cimToolUserFriendChange(_ message: LingIMFriendModel) {
        coHereReloadFriendsFromDatabase()
    }

    /// 好友备注变化后请求最新资料、更新 SDK 本地数据并刷新页面。
    /// - Parameter message: 包含好友会话 ID 的同步消息。
    func cimToolUserFriendRemarkChange(_ message: SynchroMessage) {
        let parameters: NSMutableDictionary = [
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? "",
            "friendUserUid": message.sessionId ?? ""
        ]
        NoaIMSDKManager.sharedTool().getFriendInfo(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let dictionary = data as? [String: Any],
                      let model = LingIMFriendModel.mj_object(
                        withKeyValues: dictionary
                      ) else {
                    return
                }
                NoaIMSDKManager.sharedTool().toolUpdateMyFriend(with: model)
                self?.coHereReloadFriendsFromDatabase()
            },
            onFailure: { _, _, _ in }
        )
    }

    /// 新增好友后重新读取完整好友列表。
    /// - Parameter friendAddModel: SDK 新增的好友。
    func imSdkUserFriendAdd(_ friendAddModel: LingIMFriendModel) {
        coHereReloadFriendsFromDatabase()
    }

    /// 删除好友后重新读取完整好友列表。
    /// - Parameter friendDeleteModel: SDK 删除的好友。
    func imSdkUserFriendDelete(_ friendDeleteModel: LingIMFriendModel) {
        coHereReloadFriendsFromDatabase()
    }

    /// 通讯录同步完成后重新读取完整好友列表。
    func imSdkUserContactsSyncFinish() {
        coHereReloadFriendsFromDatabase()
    }

    /// 通讯录同步失败时保留当前页面数据，等待 SDK 后续同步。
    /// - Parameter errorMsg: SDK 返回的同步失败信息。
    func imSdkUserContactsSyncFailed(_ errorMsg: String) {
        NSLog("通讯录好友同步服务器通讯录失败：%@", errorMsg)
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func coHereLocalized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Swift 导航壳，为旧分组和群聊业务页补充独立页面标题、返回和滚动环境。
private final class CoHereContactListContainerViewController:
    CandyBaseViewController
{

    /// 页面标题文本。
    private let coHereTitleText: String

    /// 被承载的现有业务控制器。
    private let coHereContentController: UIViewController

    /// 子控制器完成布局后启用独立滚动的回调。
    private let coHereActivateContent: (UIViewController) -> Void

    /// 使用标题、业务控制器和激活回调创建导航壳。
    /// - Parameters:
    ///   - titleText: 页面标题。
    ///   - contentController: 现有 Objective-C 业务控制器。
    ///   - activateContent: 页面加载后启用滚动的操作。
    init(
        titleText: String,
        contentController: UIViewController,
        activateContent: @escaping (UIViewController) -> Void
    ) {
        coHereTitleText = titleText
        coHereContentController = contentController
        coHereActivateContent = activateContent
        super.init(nibName: nil, bundle: nil)
    }

    /// Storyboard 初始化不适用于代码创建的业务页容器。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        return nil
    }

    /// 创建标题栏、返回按钮并嵌入现有业务控制器。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        view.backgroundColor = UIColor(coHereContactHex: 0xF8F9FB)
        coHereSetupHeader()
        coHereEmbedContent()
    }

    /// 创建符合项目样式的 44pt 返回标题栏。
    private func coHereSetupHeader() {
        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(
            UIImage(named: "c_nav_back") ?? UIImage(systemName: "chevron.left"),
            for: .normal
        )
        backButton.addTarget(
            self,
            action: #selector(coHereBackTapped),
            for: .touchUpInside
        )
        view.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = coHereTitleText
        titleLabel.textColor = UIColor(coHereContactHex: 0x333333)
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 8
            ),
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(
                equalTo: backButton.centerYAnchor
            )
        ])
    }

    /// 把旧业务控制器嵌入标题栏下方并启用其列表滚动。
    private func coHereEmbedContent() {
        addChild(coHereContentController)
        let contentView = coHereContentController.view!
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 44
            ),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        coHereContentController.didMove(toParent: self)
        coHereActivateContent(coHereContentController)
    }

    /// 返回上一页。
    @objc private func coHereBackTapped() {
        navigationController?.popViewController(animated: true)
    }
}
