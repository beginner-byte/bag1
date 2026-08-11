//
//  CoHereContactPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import SDWebImage
import UIKit

/// 通讯录快捷入口的稳定业务类型，不依赖展示文案或列表下标。
enum CoHereContactQuickActionKind {
    /// 新朋友申请列表。
    case newFriend
    /// 权限控制的文件助手。
    case fileHelper
    /// 好友分组列表。
    case friendGroup
    /// 群聊列表。
    case groupChat
    /// 群助手系统消息。
    case groupHelper
}

/// 通讯录快捷入口的 Swift 展示模型。
struct CoHereContactQuickAction {
    /// 业务类型。
    let kind: CoHereContactQuickActionKind
    /// 当前语言下的标题。
    let title: String
    /// Asset Catalog 图标名称。
    let iconName: String
    /// 40×40pt 图标容器背景色。
    let iconBackgroundColor: UIColor
    /// 是否把项目旧图标转换成白色模板图。
    let usesTemplateIcon: Bool
}

/// 通讯录单个好友的页面展示模型。
struct CoHereContactFriendItem {
    /// 处理账号状态后的显示昵称。
    let displayName: String
    /// 可加载的完整头像地址。
    let avatarURL: URL?
    /// 是否显示本地注销账号头像。
    let usesDeletedAvatar: Bool
    /// 当前用户角色展示文本；为空时隐藏。
    let roleName: String
}

/// 通讯录好友首字母分组。
struct CoHereContactFriendSection {
    /// A-Z 或 # 分组标题。
    let title: String
    /// 分组内好友。
    let items: [CoHereContactFriendItem]
}

/// Figma“通讯录”页面视觉层，只负责渲染状态并回传用户操作。
final class CoHereContactPageView: UIView,
    UITableViewDataSource,
    UITableViewDelegate
{

    /// Worker 推入模式下的返回按钮点击回调。
    var onBackTap: (() -> Void)?

    /// 搜索框点击回调。
    var onSearchTap: (() -> Void)?

    /// 右上角添加好友点击回调。
    var onAddFriendTap: (() -> Void)?

    /// 快捷入口点击回调。
    var onQuickActionTap: ((CoHereContactQuickActionKind) -> Void)?

    /// 好友点击回调，参数分别为好友分组和分组内下标。
    var onFriendTap: ((Int, Int) -> Void)?

    /// 页面列表，控制器用它协调左侧边缘手势与滚动。
    let tableView = UITableView(frame: .zero, style: .plain)

    /// 顶部导航和搜索区域的淡紫色渐变背景。
    private let coHereGradientView = CoHereContactGradientView()

    /// 页面居中标题。
    private let coHereTitleLabel = UILabel()

    /// Worker 推入通讯录时显示的左上角返回按钮。
    private let coHereBackButton = UIButton(type: .custom)

    /// Figma 右上角添加好友按钮。
    private let coHereAddButton = UIButton(type: .custom)

    /// Figma 搜索框按钮，点击后进入现有全局搜索页面。
    private let coHereSearchButton = UIButton(type: .custom)

    /// 搜索框左侧 20×20pt 图标。
    private let coHereSearchIconView = UIImageView()

    /// 搜索框占位文案。
    private let coHereSearchLabel = UILabel()

    /// 当前权限下可见的快捷入口。
    private var coHereQuickActions: [CoHereContactQuickAction] = []

    /// 当前好友拼音分组。
    private var coHereFriendSections: [CoHereContactFriendSection] = []

    /// 新朋友行显示的好友申请数量。
    private var coHereFriendApplyCount = 0

    /// 初始化页面并创建 Figma 层级。
    /// - Parameter frame: 初始区域，最终尺寸由 Auto Layout 更新。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupView()
    }

    /// Storyboard 初始化入口，保持与代码初始化相同的页面结构。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView()
    }

    /// 使用控制器整理后的业务状态刷新快捷入口、好友列表和红点。
    /// - Parameters:
    ///   - quickActions: 当前权限下可见的快捷入口。
    ///   - friendSections: 排序后的好友分组。
    ///   - friendApplyCount: 好友申请未读数量。
    func coHereConfigure(
        quickActions: [CoHereContactQuickAction],
        friendSections: [CoHereContactFriendSection],
        friendApplyCount: Int
    ) {
        coHereQuickActions = quickActions
        coHereFriendSections = friendSections
        coHereFriendApplyCount = friendApplyCount
        tableView.reloadData()
    }

    /// 根据通讯录承载方式显示或隐藏返回按钮。
    /// - Parameter isVisible: true 表示通讯录由 Worker 原生导航栈推入。
    func coHereSetBackButtonVisible(_ isVisible: Bool) {
        coHereBackButton.isHidden = !isVisible
    }

    /// 创建渐变导航、搜索框和单一可滚动列表。
    private func coHereSetupView() {
        backgroundColor = .white

        coHereGradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coHereGradientView)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.text = coHereLocalized("通讯录")
        coHereTitleLabel.textColor = UIColor(coHereContactHex: 0x333333)
        coHereTitleLabel.font = UIFont(
            name: "PingFangSC-Semibold",
            size: 16
        ) ?? .systemFont(ofSize: 16, weight: .semibold)
        coHereTitleLabel.textAlignment = .center
        addSubview(coHereTitleLabel)

        coHereBackButton.translatesAutoresizingMaskIntoConstraints = false
        coHereBackButton.setImage(
            UIImage(named: "c_nav_back") ?? UIImage(systemName: "chevron.left"),
            for: .normal
        )
        coHereBackButton.tintColor = UIColor(coHereContactHex: 0x333333)
        coHereBackButton.accessibilityLabel = coHereLocalized("返回")
        coHereBackButton.isHidden = true
        coHereBackButton.addTarget(
            self,
            action: #selector(coHereBackTapped),
            for: .touchUpInside
        )
        addSubview(coHereBackButton)

        coHereAddButton.translatesAutoresizingMaskIntoConstraints = false
        coHereAddButton.setImage(
            UIImage(named: "cohere_contact_add"),
            for: .normal
        )
        coHereAddButton.accessibilityLabel = coHereLocalized("添加好友")
        coHereAddButton.addTarget(
            self,
            action: #selector(coHereAddTapped),
            for: .touchUpInside
        )
        addSubview(coHereAddButton)

        coHereSetupSearchButton()
        coHereSetupTableView()

        NSLayoutConstraint.activate([
            coHereGradientView.topAnchor.constraint(equalTo: topAnchor),
            coHereGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereGradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereGradientView.heightAnchor.constraint(equalToConstant: 163),

            coHereTitleLabel.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 12
            ),
            coHereTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            coHereTitleLabel.heightAnchor.constraint(equalToConstant: 24),

            coHereBackButton.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 8
            ),
            coHereBackButton.centerYAnchor.constraint(
                equalTo: coHereTitleLabel.centerYAnchor
            ),
            coHereBackButton.widthAnchor.constraint(equalToConstant: 44),
            coHereBackButton.heightAnchor.constraint(equalToConstant: 44),

            coHereAddButton.centerYAnchor.constraint(
                equalTo: coHereTitleLabel.centerYAnchor
            ),
            coHereAddButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            coHereAddButton.widthAnchor.constraint(equalToConstant: 40),
            coHereAddButton.heightAnchor.constraint(equalToConstant: 40),

            coHereSearchButton.topAnchor.constraint(
                equalTo: coHereTitleLabel.bottomAnchor,
                constant: 20
            ),
            coHereSearchButton.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            coHereSearchButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            coHereSearchButton.heightAnchor.constraint(equalToConstant: 40),

            tableView.topAnchor.constraint(
                equalTo: coHereSearchButton.bottomAnchor,
                constant: 16
            ),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// 创建 Figma 343×40pt 搜索框内部图标和占位文案。
    private func coHereSetupSearchButton() {
        coHereSearchButton.translatesAutoresizingMaskIntoConstraints = false
        coHereSearchButton.backgroundColor = .white
        coHereSearchButton.layer.cornerRadius = 8
        coHereSearchButton.layer.masksToBounds = true
        coHereSearchButton.addTarget(
            self,
            action: #selector(coHereSearchTapped),
            for: .touchUpInside
        )
        addSubview(coHereSearchButton)

        coHereSearchIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereSearchIconView.image = UIImage(
            named: "cohere_contact_search"
        )
        coHereSearchIconView.contentMode = .scaleAspectFit
        coHereSearchButton.addSubview(coHereSearchIconView)

        coHereSearchLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereSearchLabel.text = coHereLocalized("请搜索")
        coHereSearchLabel.textColor = UIColor(coHereContactHex: 0xB2B2B2)
        coHereSearchLabel.font = UIFont(
            name: "PingFangSC-Regular",
            size: 12
        ) ?? .systemFont(ofSize: 12)
        coHereSearchButton.addSubview(coHereSearchLabel)

        NSLayoutConstraint.activate([
            coHereSearchIconView.leadingAnchor.constraint(
                equalTo: coHereSearchButton.leadingAnchor,
                constant: 24
            ),
            coHereSearchIconView.centerYAnchor.constraint(
                equalTo: coHereSearchButton.centerYAnchor
            ),
            coHereSearchIconView.widthAnchor.constraint(equalToConstant: 20),
            coHereSearchIconView.heightAnchor.constraint(equalToConstant: 20),

            coHereSearchLabel.leadingAnchor.constraint(
                equalTo: coHereSearchIconView.trailingAnchor,
                constant: 10
            ),
            coHereSearchLabel.centerYAnchor.constraint(
                equalTo: coHereSearchButton.centerYAnchor
            ),
            coHereSearchLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: coHereSearchButton.trailingAnchor,
                constant: -16
            )
        ])
    }

    /// 配置 Figma 列表背景、复用 Cell、分区和滚动行为。
    private func coHereSetupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delaysContentTouches = false
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .onDrag
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            CoHereContactQuickActionCell.self,
            forCellReuseIdentifier: CoHereContactQuickActionCell.reuseIdentifier
        )
        tableView.register(
            CoHereContactFriendCell.self,
            forCellReuseIdentifier: CoHereContactFriendCell.reuseIdentifier
        )
        tableView.register(
            CoHereContactEmptyCell.self,
            forCellReuseIdentifier: CoHereContactEmptyCell.reuseIdentifier
        )
        addSubview(tableView)
    }

    /// 返回快捷入口分区加好友分区或空状态分区的总数。
    /// - Parameter tableView: 当前通讯录列表。
    /// - Returns: 页面总分区数。
    func numberOfSections(in tableView: UITableView) -> Int {
        1 + max(coHereFriendSections.count, 1)
    }

    /// 返回快捷入口、好友或空状态对应的行数。
    /// - Parameters:
    ///   - tableView: 当前通讯录列表。
    ///   - section: 列表分区下标。
    /// - Returns: 指定分区行数。
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if section == 0 {
            return coHereQuickActions.count
        }
        if coHereFriendSections.isEmpty {
            return 1
        }
        let friendSection = section - 1
        guard coHereFriendSections.indices.contains(friendSection) else {
            return 0
        }
        return coHereFriendSections[friendSection].items.count
    }

    /// 创建快捷入口、好友或空状态 Cell。
    /// - Parameters:
    ///   - tableView: 当前通讯录列表。
    ///   - indexPath: 待展示坐标。
    /// - Returns: 已按 Figma 状态配置的 Cell。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CoHereContactQuickActionCell.reuseIdentifier,
                for: indexPath
            ) as! CoHereContactQuickActionCell
            let action = coHereQuickActions[indexPath.row]
            let badgeCount = action.kind == .newFriend
                ? coHereFriendApplyCount : 0
            cell.coHereConfigure(action: action, badgeCount: badgeCount)
            return cell
        }

        if coHereFriendSections.isEmpty {
            return tableView.dequeueReusableCell(
                withIdentifier: CoHereContactEmptyCell.reuseIdentifier,
                for: indexPath
            )
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereContactFriendCell.reuseIdentifier,
            for: indexPath
        ) as! CoHereContactFriendCell
        let item = coHereFriendSections[indexPath.section - 1]
            .items[indexPath.row]
        cell.coHereConfigure(item)
        return cell
    }

    /// 返回 Figma 统一 64pt 行高或空状态高度。
    /// - Parameters:
    ///   - tableView: 当前通讯录列表。
    ///   - indexPath: 当前坐标。
    /// - Returns: Cell 高度。
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.section > 0, coHereFriendSections.isEmpty {
            return max(220, tableView.bounds.height - 256)
        }
        return 64
    }

    /// 创建好友首字母分区标题；快捷入口和空状态不创建标题。
    /// - Parameters:
    ///   - tableView: 当前通讯录列表。
    ///   - section: 当前分区。
    /// - Returns: A-Z/# 标题视图或 nil。
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        guard section > 0,
              !coHereFriendSections.isEmpty,
              coHereFriendSections.indices.contains(section - 1) else {
            return nil
        }
        let header = CoHereContactSectionHeaderView()
        header.coHereConfigure(
            title: coHereFriendSections[section - 1].title
        )
        return header
    }

    /// 返回好友分区 48pt 标题高度。
    /// - Parameters:
    ///   - tableView: 当前通讯录列表。
    ///   - section: 当前分区。
    /// - Returns: 标题高度。
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        section > 0 && !coHereFriendSections.isEmpty
            ? 48 : .leastNormalMagnitude
    }

    /// 将快捷入口或好友点击转换成类型安全回调。
    /// - Parameters:
    ///   - tableView: 当前通讯录列表。
    ///   - indexPath: 被点击坐标。
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            guard coHereQuickActions.indices.contains(indexPath.row) else {
                return
            }
            onQuickActionTap?(coHereQuickActions[indexPath.row].kind)
            return
        }
        guard !coHereFriendSections.isEmpty else {
            return
        }
        onFriendTap?(indexPath.section - 1, indexPath.row)
    }

    /// 为非 RTL 页面提供现有通讯录字母索引能力。
    /// - Parameter tableView: 当前通讯录列表。
    /// - Returns: A-Z/# 标题数组；RTL 或空列表时返回 nil。
    func sectionIndexTitles(
        for tableView: UITableView
    ) -> [String]? {
        guard UIView.userInterfaceLayoutDirection(
            for: semanticContentAttribute
        ) != .rightToLeft,
        coHereFriendSections.count > 1 else {
            return nil
        }
        return coHereFriendSections.map(\.title)
    }

    /// 将字母索引下标映射到跳过快捷入口后的好友分区。
    /// - Parameters:
    ///   - tableView: 当前通讯录列表。
    ///   - title: 被点击字母。
    ///   - index: 字母索引下标。
    /// - Returns: 对应的好友 TableView 分区。
    func tableView(
        _ tableView: UITableView,
        sectionForSectionIndexTitle title: String,
        at index: Int
    ) -> Int {
        index + 1
    }

    /// 把右上角按钮点击回传给控制器。
    @objc private func coHereAddTapped() {
        onAddFriendTap?()
    }

    /// 把左上角返回按钮点击回传给控制器。
    @objc private func coHereBackTapped() {
        onBackTap?()
    }

    /// 把搜索框点击回传给控制器。
    @objc private func coHereSearchTapped() {
        onSearchTap?()
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func coHereLocalized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Figma 顶部淡紫到白色背景。
private final class CoHereContactGradientView: UIView {

    /// 实际渲染两段渐变的 Core Animation 图层。
    private let coHereGradientLayer = CAGradientLayer()

    /// 创建并添加渐变图层。
    /// - Parameter frame: 初始区域。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupGradient()
    }

    /// Storyboard 初始化时创建相同渐变图层。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupGradient()
    }

    /// 尺寸变化时让渐变覆盖完整顶部区域。
    override func layoutSubviews() {
        super.layoutSubviews()
        coHereGradientLayer.frame = bounds
    }

    /// 配置 Figma 背景浅色渐变的颜色和方向。
    private func coHereSetupGradient() {
        coHereGradientLayer.colors = [
            UIColor(coHereContactHex: 0xF2F1FF).cgColor,
            UIColor.white.cgColor
        ]
        coHereGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        coHereGradientLayer.endPoint = CGPoint(x: 0.75, y: 1)
        layer.addSublayer(coHereGradientLayer)
    }
}

/// Figma 64pt 快捷入口 Cell。
private final class CoHereContactQuickActionCell: UITableViewCell {

    /// 列表复用标识。
    static let reuseIdentifier = "CoHereContactQuickActionCell"

    /// 40×40pt 彩色圆角图标容器。
    private let coHereIconContainer = UIView()

    /// 容器内 20×20pt Figma 图形。
    private let coHereIconView = UIImageView()

    /// 16pt Medium 入口标题。
    private let coHereTitleLabel = UILabel()

    /// 新朋友未读数量红点。
    private let coHereBadgeLabel = UILabel()

    /// 0.5pt 行分隔线。
    private let coHereDivider = UIView()

    /// 创建并布局快捷入口 Cell。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        coHereSetupCell()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupCell()
    }

    /// 使用入口模型和未读数量刷新图标、文案及红点。
    /// - Parameters:
    ///   - action: 快捷入口展示模型。
    ///   - badgeCount: 新朋友未读数量，其他入口传 0。
    func coHereConfigure(
        action: CoHereContactQuickAction,
        badgeCount: Int
    ) {
        coHereTitleLabel.text = action.title
        coHereIconContainer.backgroundColor = action.iconBackgroundColor
        let image = UIImage(named: action.iconName)
        coHereIconView.image = action.usesTemplateIcon
            ? image?.withRenderingMode(.alwaysTemplate) : image
        coHereIconView.tintColor = .white

        coHereBadgeLabel.isHidden = badgeCount <= 0
        coHereBadgeLabel.text = badgeCount > 99 ? "99+" : "\(badgeCount)"
    }

    /// 配置 Figma 背景、20/40pt 图标几何、标题、红点和分隔线。
    private func coHereSetupCell() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .default
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(coHereContactHex: 0xF8F9FF)
        selectedBackgroundView = selectedView

        coHereIconContainer.translatesAutoresizingMaskIntoConstraints = false
        coHereIconContainer.layer.cornerRadius = 8
        coHereIconContainer.layer.masksToBounds = true
        contentView.addSubview(coHereIconContainer)

        coHereIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereIconView.contentMode = .scaleAspectFit
        coHereIconContainer.addSubview(coHereIconView)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.textColor = UIColor(coHereContactHex: 0x333333)
        coHereTitleLabel.font = UIFont(
            name: "PingFangSC-Medium",
            size: 16
        ) ?? .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(coHereTitleLabel)

        coHereBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereBadgeLabel.backgroundColor = UIColor(
            coHereContactHex: 0xF93A2F
        )
        coHereBadgeLabel.textColor = .white
        coHereBadgeLabel.font = .systemFont(ofSize: 11, weight: .medium)
        coHereBadgeLabel.textAlignment = .center
        coHereBadgeLabel.layer.cornerRadius = 9
        coHereBadgeLabel.layer.masksToBounds = true
        coHereBadgeLabel.isHidden = true
        contentView.addSubview(coHereBadgeLabel)

        coHereDivider.translatesAutoresizingMaskIntoConstraints = false
        coHereDivider.backgroundColor = UIColor(
            coHereContactHex: 0xE5E5E5
        ).withAlphaComponent(0.2)
        contentView.addSubview(coHereDivider)

        NSLayoutConstraint.activate([
            coHereIconContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            coHereIconContainer.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            coHereIconContainer.widthAnchor.constraint(equalToConstant: 40),
            coHereIconContainer.heightAnchor.constraint(equalToConstant: 40),

            coHereIconView.centerXAnchor.constraint(
                equalTo: coHereIconContainer.centerXAnchor
            ),
            coHereIconView.centerYAnchor.constraint(
                equalTo: coHereIconContainer.centerYAnchor
            ),
            coHereIconView.widthAnchor.constraint(equalToConstant: 20),
            coHereIconView.heightAnchor.constraint(equalToConstant: 20),

            coHereTitleLabel.leadingAnchor.constraint(
                equalTo: coHereIconContainer.trailingAnchor,
                constant: 12
            ),
            coHereTitleLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),

            coHereBadgeLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: coHereTitleLabel.trailingAnchor,
                constant: 8
            ),
            coHereBadgeLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            coHereBadgeLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            coHereBadgeLabel.heightAnchor.constraint(equalToConstant: 18),
            coHereBadgeLabel.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 18
            ),

            coHereDivider.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            coHereDivider.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            coHereDivider.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            coHereDivider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

/// Figma 64pt 联系人 Cell。
private final class CoHereContactFriendCell: UITableViewCell {

    /// 列表复用标识。
    static let reuseIdentifier = "CoHereContactFriendCell"

    /// 40×40pt、8pt 圆角好友头像。
    private let coHereAvatarView = UIImageView()

    /// 16pt Medium 好友昵称。
    private let coHereNameLabel = UILabel()

    /// 旧页面保留的好友角色标识。
    private let coHereRoleLabel = UILabel()

    /// 0.5pt 行分隔线。
    private let coHereDivider = UIView()

    /// 创建并布局联系人 Cell。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        coHereSetupCell()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupCell()
    }

    /// 复用前取消头像请求并清理旧展示值。
    override func prepareForReuse() {
        super.prepareForReuse()
        coHereAvatarView.sd_cancelCurrentImageLoad()
        coHereAvatarView.image = UIImage(named: "c_avatar_icon")
        coHereNameLabel.text = nil
        coHereRoleLabel.text = nil
        coHereRoleLabel.isHidden = true
    }

    /// 使用好友展示模型刷新头像、昵称和角色标识。
    /// - Parameter item: 当前好友展示信息。
    func coHereConfigure(_ item: CoHereContactFriendItem) {
        coHereNameLabel.text = item.displayName
        if item.usesDeletedAvatar {
            coHereAvatarView.sd_cancelCurrentImageLoad()
            coHereAvatarView.image = UIImage(
                named: "user_accout_delete_avatar"
            )
        } else {
            coHereAvatarView.sd_setImage(
                with: item.avatarURL,
                placeholderImage: UIImage(named: "c_avatar_icon"),
                options: [.allowInvalidSSLCertificates]
            )
        }
        coHereRoleLabel.text = item.roleName
        coHereRoleLabel.isHidden = item.roleName.isEmpty
    }

    /// 配置 Figma 头像、昵称、选中态，并保留旧页面动态角色标签。
    private func coHereSetupCell() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(coHereContactHex: 0xF8F9FF)
        selectedBackgroundView = selectedView

        coHereAvatarView.translatesAutoresizingMaskIntoConstraints = false
        coHereAvatarView.contentMode = .scaleAspectFill
        coHereAvatarView.layer.cornerRadius = 8
        coHereAvatarView.layer.masksToBounds = true
        coHereAvatarView.image = UIImage(named: "c_avatar_icon")
        contentView.addSubview(coHereAvatarView)

        coHereNameLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereNameLabel.textColor = UIColor(coHereContactHex: 0x333333)
        coHereNameLabel.font = UIFont(
            name: "PingFangSC-Medium",
            size: 16
        ) ?? .systemFont(ofSize: 16, weight: .medium)
        coHereNameLabel.numberOfLines = 1
        contentView.addSubview(coHereNameLabel)

        coHereRoleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereRoleLabel.textColor = .white
        coHereRoleLabel.backgroundColor = UIColor(
            coHereContactHex: 0xEAB243
        )
        coHereRoleLabel.font = .systemFont(ofSize: 7)
        coHereRoleLabel.textAlignment = .center
        coHereRoleLabel.layer.cornerRadius = 6
        coHereRoleLabel.layer.masksToBounds = true
        coHereRoleLabel.isHidden = true
        contentView.addSubview(coHereRoleLabel)

        coHereDivider.translatesAutoresizingMaskIntoConstraints = false
        coHereDivider.backgroundColor = UIColor(
            coHereContactHex: 0xE5E5E5
        ).withAlphaComponent(0.2)
        contentView.addSubview(coHereDivider)

        NSLayoutConstraint.activate([
            coHereAvatarView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            coHereAvatarView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            coHereAvatarView.widthAnchor.constraint(equalToConstant: 40),
            coHereAvatarView.heightAnchor.constraint(equalToConstant: 40),

            coHereNameLabel.leadingAnchor.constraint(
                equalTo: coHereAvatarView.trailingAnchor,
                constant: 12
            ),
            coHereNameLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            coHereNameLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -24
            ),

            coHereRoleLabel.leadingAnchor.constraint(
                equalTo: coHereAvatarView.leadingAnchor,
                constant: -1
            ),
            coHereRoleLabel.trailingAnchor.constraint(
                equalTo: coHereAvatarView.trailingAnchor,
                constant: 1
            ),
            coHereRoleLabel.bottomAnchor.constraint(
                equalTo: coHereAvatarView.bottomAnchor
            ),
            coHereRoleLabel.heightAnchor.constraint(equalToConstant: 12),

            coHereDivider.leadingAnchor.constraint(
                equalTo: coHereNameLabel.leadingAnchor
            ),
            coHereDivider.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            coHereDivider.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            coHereDivider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

/// 好友首字母 48pt 分区标题。
private final class CoHereContactSectionHeaderView: UIView {

    /// A-Z 或 # 标题。
    private let coHereTitleLabel = UILabel()

    /// 创建并布局分区标题。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupHeader()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupHeader()
    }

    /// 设置当前分区字母。
    /// - Parameter title: A-Z 或 #。
    func coHereConfigure(title: String) {
        coHereTitleLabel.text = title
    }

    /// 配置 Figma 12pt 字母及 16pt 左边距。
    private func coHereSetupHeader() {
        backgroundColor = .white
        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.textColor = UIColor(coHereContactHex: 0x333333)
        coHereTitleLabel.font = UIFont(
            name: "PingFangSC-Medium",
            size: 12
        ) ?? .systemFont(ofSize: 12, weight: .medium)
        addSubview(coHereTitleLabel)
        NSLayoutConstraint.activate([
            coHereTitleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            coHereTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

/// 通讯录无好友时显示的页面内空状态。
private final class CoHereContactEmptyCell: UITableViewCell {

    /// 列表复用标识。
    static let reuseIdentifier = "CoHereContactEmptyCell"

    /// 项目既有空好友插图。
    private let coHereImageView = UIImageView(
        image: UIImage(named: "c_no_friend")
    )

    /// 当前语言下的无好友提示。
    private let coHereMessageLabel = UILabel()

    /// 创建空状态内容。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        coHereSetupEmptyState()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupEmptyState()
    }

    /// 配置项目空态插图、文案和不可选中行为。
    private func coHereSetupEmptyState() {
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white

        coHereImageView.translatesAutoresizingMaskIntoConstraints = false
        coHereImageView.contentMode = .scaleAspectFit
        contentView.addSubview(coHereImageView)

        coHereMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereMessageLabel.text = NoaLanguageManager.share()
            .matchLocalLanguage("暂无好友")
        coHereMessageLabel.textColor = UIColor(coHereContactHex: 0x999999)
        coHereMessageLabel.font = .systemFont(ofSize: 14)
        contentView.addSubview(coHereMessageLabel)

        NSLayoutConstraint.activate([
            coHereImageView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            coHereImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor,
                constant: -30
            ),
            coHereImageView.widthAnchor.constraint(equalToConstant: 120),
            coHereImageView.heightAnchor.constraint(equalToConstant: 100),

            coHereMessageLabel.topAnchor.constraint(
                equalTo: coHereImageView.bottomAnchor,
                constant: 12
            ),
            coHereMessageLabel.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            )
        ])
    }
}

/// 将 Figma 十六进制颜色值转换为 UIKit 颜色。
extension UIColor {

    /// 使用 0xRRGGBB 创建不透明颜色。
    /// - Parameter value: 24 位 RGB 数值。
    convenience init(coHereContactHex value: UInt32) {
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
