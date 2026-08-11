//
//  CoHereMinePageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import SDWebImage
import UIKit

/// CoHere“我的”页面视觉层，负责按 Figma 呈现用户资料和菜单，并将业务操作回传给 Swift 控制器。
@objc(CoHereMinePageView)
final class CoHereMinePageView: UIView {

    /// 菜单点击回调，参数分别为原始业务数据中的 section 和 row。
    @objc var onMenuTap: ((Int, Int) -> Void)?

    /// 资料区操作回调，沿用迁移前控制器的 actionTag。
    @objc var onInfoAction: ((Int) -> Void)?

    /// 页面纵向滚动容器，兼容抽屉宽度、小屏设备和动态翻译入口。
    private let coHereScrollView = UIScrollView()

    /// 滚动区域的 Auto Layout 内容容器。
    private let coHereContentView = UIView()

    /// Figma 顶部淡紫色渐变背景。
    private let coHereHeaderGradientView = CoHereMineGradientView()

    /// 用户头像、昵称、账号和快捷入口区域。
    private let coHereProfileView = CoHereMineProfileView()

    /// 分组菜单的纵向容器。
    private let coHereSectionsStackView = UIStackView()

    /// 当前账号原始值，仅用于复制到系统剪贴板。
    private var coHereAccount = ""

    /// 初始化页面并创建 Figma 视图层级。
    /// - Parameter frame: 初始区域，最终尺寸由 Auto Layout 更新。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupView()
        coHereBindActions()
    }

    /// Storyboard 初始化入口，保持和代码初始化相同的视图结构。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView()
        coHereBindActions()
    }

    /// 使用 Swift 控制器现有用户数据和菜单数据刷新页面。
    /// - Parameters:
    ///   - avatarURL: 用户头像完整地址；为空时显示项目默认头像。
    ///   - nickname: 当前用户昵称。
    ///   - account: 当前用户账号，不包含 Figma 展示用的“ID：”前缀。
    ///   - sections: 原菜单二维数组，保留 section/row 供点击回调使用。
    @objc(configureWithAvatarURL:nickname:account:sections:)
    func coHereConfigure(
        avatarURL: URL?,
        nickname: String,
        account: String,
        sections: NSArray
    ) {
        coHereAccount = account
        coHereProfileView.coHereConfigure(
            avatarURL: avatarURL,
            nickname: nickname,
            account: account
        )
        coHereRebuildSections(from: sections)
    }

    /// 创建固定渐变与资料头部、滚动菜单容器和菜单分组。
    ///
    /// 渐变和用户资料属于页面根视图，不进入滚动内容层；只有下方菜单保持纵向滚动行为。
    private func coHereSetupView() {
        backgroundColor = UIColor(coHereMineHex: 0xF5F5F5)

        coHereHeaderGradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coHereHeaderGradientView)

        coHereProfileView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coHereProfileView)

        coHereScrollView.translatesAutoresizingMaskIntoConstraints = false
        coHereScrollView.backgroundColor = .clear
        coHereScrollView.alwaysBounceVertical = true
        coHereScrollView.isScrollEnabled = true
        coHereScrollView.showsVerticalScrollIndicator = false
        addSubview(coHereScrollView)

        coHereContentView.translatesAutoresizingMaskIntoConstraints = false
        coHereContentView.backgroundColor = .clear
        coHereScrollView.addSubview(coHereContentView)

        coHereSectionsStackView.translatesAutoresizingMaskIntoConstraints = false
        coHereSectionsStackView.axis = .vertical
        coHereSectionsStackView.spacing = 8
        coHereContentView.addSubview(coHereSectionsStackView)

        NSLayoutConstraint.activate([
            coHereHeaderGradientView.topAnchor.constraint(equalTo: topAnchor),
            coHereHeaderGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereHeaderGradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereHeaderGradientView.heightAnchor.constraint(equalToConstant: 196),

            coHereProfileView.topAnchor.constraint(equalTo: topAnchor),
            coHereProfileView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereProfileView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereProfileView.heightAnchor.constraint(equalToConstant: 196),

            coHereScrollView.topAnchor.constraint(equalTo: topAnchor, constant: 204),
            coHereScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            coHereContentView.topAnchor.constraint(equalTo: coHereScrollView.contentLayoutGuide.topAnchor),
            coHereContentView.leadingAnchor.constraint(equalTo: coHereScrollView.contentLayoutGuide.leadingAnchor),
            coHereContentView.trailingAnchor.constraint(equalTo: coHereScrollView.contentLayoutGuide.trailingAnchor),
            coHereContentView.bottomAnchor.constraint(equalTo: coHereScrollView.contentLayoutGuide.bottomAnchor),
            coHereContentView.widthAnchor.constraint(equalTo: coHereScrollView.frameLayoutGuide.widthAnchor),
            coHereContentView.heightAnchor.constraint(
                greaterThanOrEqualTo: coHereScrollView.frameLayoutGuide.heightAnchor
            ),

            coHereSectionsStackView.topAnchor.constraint(equalTo: coHereContentView.topAnchor),
            coHereSectionsStackView.leadingAnchor.constraint(equalTo: coHereContentView.leadingAnchor),
            coHereSectionsStackView.trailingAnchor.constraint(equalTo: coHereContentView.trailingAnchor),
            coHereSectionsStackView.bottomAnchor.constraint(
                equalTo: coHereContentView.bottomAnchor,
                constant: -16
            )
        ])
    }

    /// 将资料区交互转换为迁移前控制器已有 actionTag 或本地复制操作。
    private func coHereBindActions() {
        coHereProfileView.onProfileTap = { [weak self] in
            self?.onInfoAction?(200)
        }
        coHereProfileView.onQRCodeTap = { [weak self] in
            self?.onInfoAction?(9901)
        }
        coHereProfileView.onCopyTap = { [weak self] in
            self?.coHereCopyAccount()
        }
    }

    /// 根据原菜单数据重建 Figma 分组，同时保留动态翻译管理入口。
    /// - Parameter sections: 原菜单 section 数组。
    private func coHereRebuildSections(from sections: NSArray) {
        coHereSectionsStackView.arrangedSubviews.forEach {
            coHereSectionsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        var coHereTeamItems: [CoHereMineMenuItem] = []
        var coHereCollectionItems: [CoHereMineMenuItem] = []
        var coHereSettingItems: [CoHereMineMenuItem] = []

        for (sectionIndex, sectionValue) in sections.enumerated() {
            guard let rows = sectionValue as? [NSDictionary] else {
                continue
            }
            for (rowIndex, dictionary) in rows.enumerated() {
                guard let item = coHereMakeMenuItem(
                    dictionary: dictionary,
                    section: sectionIndex,
                    row: rowIndex
                ) else {
                    continue
                }
                if item.originalTitle == coHereLocalized("我的团队") {
                    coHereTeamItems.append(item)
                } else if item.originalTitle == coHereLocalized("我的收藏")
                    || item.originalTitle == coHereLocalized("黑名单") {
                    coHereCollectionItems.append(item)
                } else {
                    coHereSettingItems.append(item)
                }
            }
        }

        [coHereTeamItems, coHereCollectionItems, coHereSettingItems]
            .filter { !$0.isEmpty }
            .forEach(coHereAddSection(items:))

        let coHereSystemItem = CoHereMineMenuItem(
            originalTitle: coHereLocalized("系统设置"),
            displayTitle: coHereLocalized("系统设置"),
            iconName: "cohere_mine_system",
            sourceSection: nil,
            sourceRow: nil,
            infoAction: 201,
            showsAboutInnerMark: false,
            usesRegularFont: false
        )
        coHereAddSection(items: [coHereSystemItem])
    }

    /// 把一组菜单项转换为 52pt 高的 Figma 菜单分组。
    /// - Parameter items: 同一白色分组中的菜单项。
    private func coHereAddSection(items: [CoHereMineMenuItem]) {
        let sectionView = CoHereMineMenuSectionView(items: items)
        sectionView.onItemTap = { [weak self] item in
            guard let self else {
                return
            }
            if let action = item.infoAction {
                self.onInfoAction?(action)
            } else if let section = item.sourceSection, let row = item.sourceRow {
                self.onMenuTap?(section, row)
            }
        }
        coHereSectionsStackView.addArrangedSubview(sectionView)
    }

    /// 将业务字典转换为 Swift 视觉模型，并只调整 Figma 要求的展示文案和图标。
    /// - Parameters:
    ///   - dictionary: 包含 imageName 和 titleName 的原菜单字典。
    ///   - section: 原始 section 下标。
    ///   - row: 原始 row 下标。
    /// - Returns: 可展示的菜单项；标题缺失时返回 nil。
    private func coHereMakeMenuItem(
        dictionary: NSDictionary,
        section: Int,
        row: Int
    ) -> CoHereMineMenuItem? {
        guard let title = dictionary["titleName"] as? String else {
            return nil
        }

        let coHereVisual = coHereVisualConfiguration(for: title)
        return CoHereMineMenuItem(
            originalTitle: title,
            displayTitle: coHereVisual.title,
            iconName: coHereVisual.iconName,
            sourceSection: section,
            sourceRow: row,
            infoAction: nil,
            showsAboutInnerMark: coHereVisual.showsAboutInnerMark,
            usesRegularFont: coHereVisual.usesRegularFont
        )
    }

    /// 返回每个现有菜单标题对应的 Figma 展示资源。
    /// - Parameter title: 业务数据层提供的本地化标题。
    /// - Returns: 展示标题、图片名和字体例外配置。
    private func coHereVisualConfiguration(
        for title: String
    ) -> (title: String, iconName: String, showsAboutInnerMark: Bool, usesRegularFont: Bool) {
        switch title {
        case coHereLocalized("我的团队"):
            return (title, "cohere_mine_team", false, false)
        case coHereLocalized("我的收藏"):
            return (title, "cohere_mine_collection", false, false)
        case coHereLocalized("黑名单"):
            return (title, "cohere_mine_blacklist", false, false)
        case coHereLocalized("应用语言"):
            return (title, "cohere_mine_language", false, false)
        case coHereLocalized("安全设置"):
            return (title, "cohere_mine_security", false, false)
        case coHereLocalized("隐私设置"):
            return (title, "cohere_mine_privacy", false, false)
        case coHereLocalized("网络检测"):
            return (coHereLocalized("网络监测"), "cohere_mine_network", false, false)
        case coHereLocalized("投诉与支持"):
            return (coHereLocalized("投诉与反馈"), "cohere_mine_feedback", false, true)
        case coHereLocalized("关于我们"):
            return (title, "cohere_mine_about_outer", true, false)
        default:
            let fallbackIcon = (dictionaryImageName(for: title) ?? "b_language")
            return (title, fallbackIcon, false, false)
        }
    }

    /// 为 Figma 未列出但业务配置可能动态出现的入口提供既有图片名。
    /// - Parameter title: 动态入口标题。
    /// - Returns: 已知动态入口的项目图片名。
    private func dictionaryImageName(for title: String) -> String? {
        if title == coHereLocalized("翻译管理") {
            return "b_language"
        }
        return nil
    }

    /// 将当前账号复制到剪贴板并显示项目统一成功提示。
    private func coHereCopyAccount() {
        guard !coHereAccount.isEmpty else {
            return
        }
        UIPasteboard.general.string = coHereAccount
        NoaHUDManager.share().showMessage(coHereLocalized("复制成功"), in: self)
    }

    /// 使用项目语言管理器返回当前语言文本。
    /// - Parameter key: Localizable.strings 中的中文键。
    /// - Returns: 当前语言对应文字。
    private func coHereLocalized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Swift 页面内部使用的菜单视觉模型，保留原始索引以复用现有业务处理。
private struct CoHereMineMenuItem {

    /// 业务数据层提供的原始本地化标题。
    let originalTitle: String

    /// Figma 页面实际展示的标题。
    let displayTitle: String

    /// Asset Catalog 中的图标名称。
    let iconName: String

    /// 原始 section；固定系统设置项为空。
    let sourceSection: Int?

    /// 原始 row；固定系统设置项为空。
    let sourceRow: Int?

    /// 资料区 actionTag；普通菜单项为空。
    let infoAction: Int?

    /// 是否叠加“关于我们”图标中独立的竖线资源。
    let showsAboutInnerMark: Bool

    /// 是否使用 Figma 指定的 Regular 字体例外。
    let usesRegularFont: Bool
}

/// Figma 白色菜单分组，内部菜单行无间距连续排列。
private final class CoHereMineMenuSectionView: UIView {

    /// 菜单项点击回调。
    var onItemTap: ((CoHereMineMenuItem) -> Void)?

    /// 分组内菜单行的纵向容器。
    private let coHereRowsStackView = UIStackView()

    /// 使用菜单模型创建一个白色分组。
    /// - Parameter items: 分组内按展示顺序排列的菜单项。
    init(items: [CoHereMineMenuItem]) {
        super.init(frame: .zero)
        coHereSetupRows(items: items)
    }

    /// Storyboard 初始化当前不使用。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupRows(items: [])
    }

    /// 创建白色背景和所有 52pt 菜单行。
    /// - Parameter items: 分组菜单项。
    private func coHereSetupRows(items: [CoHereMineMenuItem]) {
        backgroundColor = .white

        coHereRowsStackView.translatesAutoresizingMaskIntoConstraints = false
        coHereRowsStackView.axis = .vertical
        coHereRowsStackView.spacing = 0
        addSubview(coHereRowsStackView)

        NSLayoutConstraint.activate([
            coHereRowsStackView.topAnchor.constraint(equalTo: topAnchor),
            coHereRowsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereRowsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereRowsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        items.forEach { item in
            let rowView = CoHereMineMenuRowView(item: item)
            rowView.onTap = { [weak self] tappedItem in
                self?.onItemTap?(tappedItem)
            }
            coHereRowsStackView.addArrangedSubview(rowView)
            rowView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        }
    }
}

/// 单个 Figma 菜单行，统一实现图标、标题、箭头、分隔线和点击热区。
private final class CoHereMineMenuRowView: UIControl {

    /// 当前菜单视觉模型。
    private let coHereItem: CoHereMineMenuItem

    /// 菜单点击回调。
    var onTap: ((CoHereMineMenuItem) -> Void)?

    /// 24pt 图标外框。
    private let coHereIconContainer = UIView()

    /// 普通菜单使用的完整图标。
    private let coHereIconView = UIImageView()

    /// “关于我们”使用的 2×10pt 内层标记。
    private let coHereAboutInnerView = UIImageView()

    /// 菜单标题。
    private let coHereTitleLabel = UILabel()

    /// 右侧 16pt Figma 箭头。
    private let coHereArrowView = UIImageView()

    /// 行底部半透明分隔线。
    private let coHereSeparatorView = UIView()

    /// 使用视觉模型创建菜单行。
    /// - Parameter item: 当前行的标题、图标和原业务索引。
    init(item: CoHereMineMenuItem) {
        coHereItem = item
        super.init(frame: .zero)
        coHereSetupView()
    }

    /// Storyboard 初始化当前不使用。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        return nil
    }

    /// 创建菜单行视图和精确尺寸约束。
    private func coHereSetupView() {
        backgroundColor = .white
        addTarget(self, action: #selector(coHereTapped), for: .touchUpInside)

        coHereIconContainer.translatesAutoresizingMaskIntoConstraints = false
        coHereIconContainer.isUserInteractionEnabled = false
        addSubview(coHereIconContainer)

        coHereIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereIconView.contentMode = .scaleAspectFit
        coHereIconView.image = UIImage(named: coHereItem.iconName)
        coHereIconContainer.addSubview(coHereIconView)

        coHereAboutInnerView.translatesAutoresizingMaskIntoConstraints = false
        coHereAboutInnerView.contentMode = .scaleAspectFit
        coHereAboutInnerView.image = UIImage(named: "cohere_mine_about_inner")
        coHereAboutInnerView.isHidden = !coHereItem.showsAboutInnerMark
        coHereIconContainer.addSubview(coHereAboutInnerView)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.text = coHereItem.displayTitle
        coHereTitleLabel.textColor = UIColor(coHereMineHex: 0x333333)
        coHereTitleLabel.font = coHereItem.usesRegularFont
            ? CoHereMineFont.regular(size: 16)
            : CoHereMineFont.medium(size: 16)
        coHereTitleLabel.isUserInteractionEnabled = false
        addSubview(coHereTitleLabel)

        coHereArrowView.translatesAutoresizingMaskIntoConstraints = false
        coHereArrowView.contentMode = .scaleAspectFit
        coHereArrowView.image = UIImage(named: "cohere_mine_row_arrow")
        coHereArrowView.isUserInteractionEnabled = false
        addSubview(coHereArrowView)

        coHereSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        coHereSeparatorView.backgroundColor = UIColor(coHereMineHex: 0xE5E5E5).withAlphaComponent(0.2)
        coHereSeparatorView.isUserInteractionEnabled = false
        addSubview(coHereSeparatorView)

        let coHereMainIconSize: CGFloat = coHereItem.showsAboutInnerMark ? 20 : 24
        NSLayoutConstraint.activate([
            coHereIconContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            coHereIconContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            coHereIconContainer.widthAnchor.constraint(equalToConstant: 24),
            coHereIconContainer.heightAnchor.constraint(equalToConstant: 24),

            coHereIconView.centerXAnchor.constraint(equalTo: coHereIconContainer.centerXAnchor),
            coHereIconView.centerYAnchor.constraint(equalTo: coHereIconContainer.centerYAnchor),
            coHereIconView.widthAnchor.constraint(equalToConstant: coHereMainIconSize),
            coHereIconView.heightAnchor.constraint(equalToConstant: coHereMainIconSize),

            coHereAboutInnerView.centerXAnchor.constraint(equalTo: coHereIconContainer.centerXAnchor),
            coHereAboutInnerView.centerYAnchor.constraint(equalTo: coHereIconContainer.centerYAnchor),
            coHereAboutInnerView.widthAnchor.constraint(equalToConstant: 2),
            coHereAboutInnerView.heightAnchor.constraint(equalToConstant: 10),

            coHereTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 52),
            coHereTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            coHereTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: coHereArrowView.leadingAnchor, constant: -12),

            coHereArrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            coHereArrowView.centerYAnchor.constraint(equalTo: centerYAnchor),
            coHereArrowView.widthAnchor.constraint(equalToConstant: 16),
            coHereArrowView.heightAnchor.constraint(equalToConstant: 16),

            coHereSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            coHereSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    /// 将整行点击转发给页面并携带原始业务索引。
    @objc private func coHereTapped() {
        onTap?(coHereItem)
    }

    /// 提供轻量按压反馈，不改变菜单功能。
    /// - Parameter highlighted: 当前是否处于按压状态。
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted
                ? UIColor(coHereMineHex: 0xF5F5F5)
                : .white
        }
    }
}

/// Figma 用户资料头部，显示动态头像、昵称、ID 和三个原有操作入口。
private final class CoHereMineProfileView: UIView {

    /// 点击用户资料区域回调。
    var onProfileTap: (() -> Void)?

    /// 点击二维码回调。
    var onQRCodeTap: (() -> Void)?

    /// 点击账号复制回调。
    var onCopyTap: (() -> Void)?

    /// 62×61pt 用户头像。
    private let coHereAvatarView = UIImageView()

    /// 头像右下角 12pt 编辑标记。
    private let coHereEditView = UIImageView()

    /// 用户昵称。
    private let coHereNicknameLabel = UILabel()

    /// 带“ID：”前缀的账号文字。
    private let coHereAccountLabel = UILabel()

    /// 18pt 二维码按钮。
    private let coHereQRCodeButton = UIButton(type: .custom)

    /// 16pt 账号复制按钮。
    private let coHereCopyButton = UIButton(type: .custom)

    /// 16pt 资料详情箭头按钮。
    private let coHereProfileArrowButton = UIButton(type: .custom)

    /// 覆盖头像的资料点击热区。
    private let coHereAvatarButton = UIButton(type: .custom)

    /// 覆盖昵称和账号空白区的资料点击热区。
    private let coHereInfoButton = UIButton(type: .custom)

    /// 初始化资料区域并创建全部控件。
    /// - Parameter frame: 初始区域。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupView()
    }

    /// Storyboard 初始化入口。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView()
    }

    /// 更新用户头像、昵称和账号。
    /// - Parameters:
    ///   - avatarURL: 头像完整地址。
    ///   - nickname: 当前用户昵称。
    ///   - account: 当前账号原始值。
    func coHereConfigure(avatarURL: URL?, nickname: String, account: String) {
        coHereNicknameLabel.text = nickname
        coHereAccountLabel.text = "ID：\(account)"
        coHereAvatarView.sd_setImage(
            with: avatarURL,
            placeholderImage: UIImage(named: "c_avatar_icon"),
            options: [.allowInvalidSSLCertificates]
        )
    }

    /// 创建 Figma 资料区控件、尺寸和点击区域。
    private func coHereSetupView() {
        backgroundColor = .clear

        coHereAvatarView.translatesAutoresizingMaskIntoConstraints = false
        coHereAvatarView.contentMode = .scaleAspectFill
        coHereAvatarView.layer.cornerRadius = 8
        coHereAvatarView.layer.masksToBounds = true
        coHereAvatarView.image = UIImage(named: "c_avatar_icon")
        addSubview(coHereAvatarView)

        coHereEditView.translatesAutoresizingMaskIntoConstraints = false
        coHereEditView.contentMode = .scaleAspectFit
        coHereEditView.image = UIImage(named: "cohere_mine_edit")
        addSubview(coHereEditView)

        coHereNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereNicknameLabel.textColor = UIColor(coHereMineHex: 0x333333)
        coHereNicknameLabel.font = CoHereMineFont.semibold(size: 18)
        addSubview(coHereNicknameLabel)

        coHereAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereAccountLabel.textColor = UIColor(coHereMineHex: 0x999999)
        coHereAccountLabel.font = CoHereMineFont.regular(size: 16)
        coHereAccountLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(coHereAccountLabel)

        coHereQRCodeButton.translatesAutoresizingMaskIntoConstraints = false
        coHereQRCodeButton.setImage(UIImage(named: "cohere_mine_qrcode"), for: .normal)
        coHereQRCodeButton.imageView?.contentMode = .scaleAspectFit
        coHereQRCodeButton.addTarget(self, action: #selector(coHereQRCodeTapped), for: .touchUpInside)
        addSubview(coHereQRCodeButton)

        coHereCopyButton.translatesAutoresizingMaskIntoConstraints = false
        coHereCopyButton.setImage(UIImage(named: "cohere_mine_copy"), for: .normal)
        coHereCopyButton.imageView?.contentMode = .scaleAspectFit
        coHereCopyButton.addTarget(self, action: #selector(coHereCopyTapped), for: .touchUpInside)
        addSubview(coHereCopyButton)

        coHereProfileArrowButton.translatesAutoresizingMaskIntoConstraints = false
        coHereProfileArrowButton.setImage(UIImage(named: "cohere_mine_profile_arrow"), for: .normal)
        coHereProfileArrowButton.imageView?.contentMode = .scaleAspectFit
        coHereProfileArrowButton.addTarget(self, action: #selector(coHereProfileTapped), for: .touchUpInside)
        addSubview(coHereProfileArrowButton)

        coHereAvatarButton.translatesAutoresizingMaskIntoConstraints = false
        coHereAvatarButton.addTarget(self, action: #selector(coHereProfileTapped), for: .touchUpInside)
        addSubview(coHereAvatarButton)

        coHereInfoButton.translatesAutoresizingMaskIntoConstraints = false
        coHereInfoButton.addTarget(self, action: #selector(coHereProfileTapped), for: .touchUpInside)
        insertSubview(coHereInfoButton, belowSubview: coHereCopyButton)

        NSLayoutConstraint.activate([
            coHereAvatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            coHereAvatarView.topAnchor.constraint(equalTo: topAnchor, constant: 104),
            coHereAvatarView.widthAnchor.constraint(equalToConstant: 62),
            coHereAvatarView.heightAnchor.constraint(equalToConstant: 61),

            coHereEditView.leadingAnchor.constraint(equalTo: coHereAvatarView.leadingAnchor, constant: 54),
            coHereEditView.topAnchor.constraint(equalTo: coHereAvatarView.topAnchor, constant: 53),
            coHereEditView.widthAnchor.constraint(equalToConstant: 12),
            coHereEditView.heightAnchor.constraint(equalToConstant: 12),

            coHereNicknameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 102),
            coHereNicknameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 106),
            coHereNicknameLabel.trailingAnchor.constraint(lessThanOrEqualTo: coHereQRCodeButton.leadingAnchor, constant: -12),

            coHereAccountLabel.leadingAnchor.constraint(equalTo: coHereNicknameLabel.leadingAnchor),
            coHereAccountLabel.topAnchor.constraint(equalTo: topAnchor, constant: 136),
            coHereAccountLabel.trailingAnchor.constraint(lessThanOrEqualTo: coHereCopyButton.leadingAnchor, constant: -4),

            coHereQRCodeButton.centerXAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            coHereQRCodeButton.centerYAnchor.constraint(equalTo: topAnchor, constant: 113),
            coHereQRCodeButton.widthAnchor.constraint(equalToConstant: 44),
            coHereQRCodeButton.heightAnchor.constraint(equalToConstant: 44),
            coHereQRCodeButton.imageView!.widthAnchor.constraint(equalToConstant: 18),
            coHereQRCodeButton.imageView!.heightAnchor.constraint(equalToConstant: 18),

            coHereCopyButton.leadingAnchor.constraint(equalTo: coHereAccountLabel.trailingAnchor, constant: 4),
            coHereCopyButton.centerYAnchor.constraint(equalTo: coHereAccountLabel.centerYAnchor),
            coHereCopyButton.widthAnchor.constraint(equalToConstant: 36),
            coHereCopyButton.heightAnchor.constraint(equalToConstant: 44),
            coHereCopyButton.imageView!.widthAnchor.constraint(equalToConstant: 16),
            coHereCopyButton.imageView!.heightAnchor.constraint(equalToConstant: 16),

            coHereProfileArrowButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            coHereProfileArrowButton.centerYAnchor.constraint(equalTo: topAnchor, constant: 146),
            coHereProfileArrowButton.widthAnchor.constraint(equalToConstant: 44),
            coHereProfileArrowButton.heightAnchor.constraint(equalToConstant: 44),
            coHereProfileArrowButton.imageView!.widthAnchor.constraint(equalToConstant: 16),
            coHereProfileArrowButton.imageView!.heightAnchor.constraint(equalToConstant: 16),

            coHereAvatarButton.leadingAnchor.constraint(equalTo: coHereAvatarView.leadingAnchor),
            coHereAvatarButton.topAnchor.constraint(equalTo: coHereAvatarView.topAnchor),
            coHereAvatarButton.trailingAnchor.constraint(equalTo: coHereEditView.trailingAnchor),
            coHereAvatarButton.bottomAnchor.constraint(equalTo: coHereEditView.bottomAnchor),

            coHereInfoButton.leadingAnchor.constraint(equalTo: coHereNicknameLabel.leadingAnchor, constant: -8),
            coHereInfoButton.topAnchor.constraint(equalTo: coHereNicknameLabel.topAnchor, constant: -8),
            coHereInfoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            coHereInfoButton.bottomAnchor.constraint(equalTo: coHereAccountLabel.bottomAnchor, constant: 8)
        ])
    }

    /// 转发资料区域点击。
    @objc private func coHereProfileTapped() {
        onProfileTap?()
    }

    /// 转发二维码点击。
    @objc private func coHereQRCodeTapped() {
        onQRCodeTap?()
    }

    /// 转发复制账号点击。
    @objc private func coHereCopyTapped() {
        onCopyTap?()
    }
}

/// 顶部淡紫到白色渐变，尺寸变化时同步底层 CAGradientLayer。
private final class CoHereMineGradientView: UIView {

    /// 当前视图直接使用渐变层作为 backing layer。
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    /// 初始化渐变颜色和方向。
    /// - Parameter frame: 初始区域。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereConfigureGradient()
    }

    /// Storyboard 初始化入口。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereConfigureGradient()
    }

    /// 配置 Figma 的淡紫到白色纵向渐变。
    private func coHereConfigureGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        gradientLayer.colors = [
            UIColor(coHereMineHex: 0xF2F1FF).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.47, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.53, y: 1)
    }
}

/// 集中提供 Figma 指定的 PingFang SC 字重，并为异常字体环境保留系统字体回退。
private enum CoHereMineFont {

    /// 返回 PingFang SC Regular。
    /// - Parameter size: 字号。
    /// - Returns: 指定字号的字体。
    static func regular(size: CGFloat) -> UIFont {
        UIFont(name: "PingFangSC-Regular", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }

    /// 返回 PingFang SC Medium。
    /// - Parameter size: 字号。
    /// - Returns: 指定字号的字体。
    static func medium(size: CGFloat) -> UIFont {
        UIFont(name: "PingFangSC-Medium", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }

    /// 返回 PingFang SC Semibold。
    /// - Parameter size: 字号。
    /// - Returns: 指定字号的字体。
    static func semibold(size: CGFloat) -> UIFont {
        UIFont(name: "PingFangSC-Semibold", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
}

/// CoHere“我的”页面使用的十六进制颜色初始化方法。
private extension UIColor {

    /// 由 0xRRGGBB 创建不透明颜色。
    /// - Parameter value: 六位 RGB 整数。
    convenience init(coHereMineHex value: UInt32) {
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
