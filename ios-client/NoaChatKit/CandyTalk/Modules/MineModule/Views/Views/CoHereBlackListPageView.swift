import SDWebImage
import UIKit

/// 按照 Figma “黑名单”节点实现的 Swift 视觉层；数据请求、用户详情和移出黑名单由 Swift 控制器负责。
@objc(CoHereBlackListPageView)
final class CoHereBlackListPageView: UIView {

    /// 点击返回按钮后的业务回调。
    @objc var onBackTap: (() -> Void)?

    /// 点击用户行后的业务回调，参数为原始分组和行下标。
    @objc var onUserTap: ((Int, Int) -> Void)?

    /// 侧滑确认移出黑名单后的业务回调，参数为原始分组和行下标。
    @objc var onRemoveTap: ((Int, Int) -> Void)?

    /// 页面顶部浅紫到白色的 Figma 渐变背景。
    private let coHereGradientView = CoHereBlackListGradientView()

    /// 返回按钮，保留 36pt 点击区域。
    private let coHereBackButton = UIButton(type: .custom)

    /// 页面居中的“黑名单”标题。
    private let coHereTitleLabel = UILabel()

    /// 搜索框白色圆角容器。
    private let coHereSearchContainer = UIView()

    /// 从 Figma 下载的搜索图标。
    private let coHereSearchIconView = UIImageView(
        image: UIImage(named: "cohere_blacklist_search")
    )

    /// 仅过滤当前已加载黑名单的搜索输入框。
    private let coHereSearchTextField = UITextField()

    /// 承载分组列表并提供顶部圆角的白色容器。
    private let coHereListContainer = UIView()

    /// 显示真实黑名单数据的原生分组列表。
    private let coHereTableView = UITableView(frame: .zero, style: .plain)

    /// 无数据或无搜索结果时复用的 Figma 空状态组件。
    private let coHereEmptyStateView = CoHereEmptyStateView()

    /// Swift 控制器传入的完整分组数据。
    private var coHereAllSections: [CoHereBlackListSection] = []

    /// 根据搜索文本生成的当前展示分组数据。
    private var coHereVisibleSections: [CoHereBlackListSection] = []

    /// 创建黑名单视觉层并完成控件、约束和事件初始化。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupView()
        coHereSetupConstraints()
        coHereBindActions()
    }

    /// Storyboard/XIB 初始化入口，保持与代码初始化一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView()
        coHereSetupConstraints()
        coHereBindActions()
    }

    /// 使用 Swift 控制器已排序的数据刷新页面，不改变服务器数据和业务模型。
    /// - Parameter sections: 每个分组包含 title 和 items；item 包含展示字段及原始 section、row。
    @objc(configureWithSections:)
    func coHereConfigure(sections: [[String: Any]]) {
        coHereAllSections = sections.compactMap(CoHereBlackListSection.init(dictionary:))
        coHereApplyFilter(coHereSearchTextField.text ?? "")
    }

    /// 创建页面控件并应用 Figma 的颜色、字体、圆角和列表规格。
    private func coHereSetupView() {
        backgroundColor = UIColor(coHereBlackListHex: 0xFFFFFF)

        coHereGradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coHereGradientView)

        coHereBackButton.translatesAutoresizingMaskIntoConstraints = false
        coHereBackButton.setImage(UIImage(named: "cohere_blacklist_back"), for: .normal)
        coHereBackButton.accessibilityLabel = coHereLocalized("返回")
        addSubview(coHereBackButton)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.text = coHereLocalized("黑名单")
        coHereTitleLabel.textColor = UIColor(coHereBlackListHex: 0x333333)
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coHereTitleLabel.textAlignment = .center
        addSubview(coHereTitleLabel)

        coHereSearchContainer.translatesAutoresizingMaskIntoConstraints = false
        coHereSearchContainer.backgroundColor = UIColor.white.withAlphaComponent(0.78)
        coHereSearchContainer.layer.cornerRadius = 8
        coHereSearchContainer.layer.masksToBounds = true
        addSubview(coHereSearchContainer)

        coHereSearchIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereSearchIconView.contentMode = .scaleAspectFit
        coHereSearchContainer.addSubview(coHereSearchIconView)

        coHereSearchTextField.translatesAutoresizingMaskIntoConstraints = false
        coHereSearchTextField.attributedPlaceholder = NSAttributedString(
            string: coHereLocalized("请搜索"),
            attributes: [
                .foregroundColor: UIColor(coHereBlackListHex: 0xB2B2B2),
                .font: UIFont.systemFont(ofSize: 12, weight: .regular)
            ]
        )
        coHereSearchTextField.textColor = UIColor(coHereBlackListHex: 0x333333)
        coHereSearchTextField.font = .systemFont(ofSize: 14, weight: .regular)
        coHereSearchTextField.returnKeyType = .search
        coHereSearchTextField.clearButtonMode = .whileEditing
        coHereSearchTextField.autocorrectionType = .no
        coHereSearchTextField.autocapitalizationType = .none
        coHereSearchTextField.accessibilityLabel = coHereLocalized("请搜索")
        coHereSearchContainer.addSubview(coHereSearchTextField)

        coHereListContainer.translatesAutoresizingMaskIntoConstraints = false
        coHereListContainer.backgroundColor = .white
        coHereListContainer.layer.cornerRadius = 8
        coHereListContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        coHereListContainer.layer.masksToBounds = true
        addSubview(coHereListContainer)

        coHereTableView.translatesAutoresizingMaskIntoConstraints = false
        coHereTableView.backgroundColor = .white
        coHereTableView.dataSource = self
        coHereTableView.delegate = self
        coHereTableView.rowHeight = 64
        coHereTableView.sectionHeaderHeight = 48
        coHereTableView.estimatedRowHeight = 0
        coHereTableView.estimatedSectionHeaderHeight = 0
        coHereTableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            coHereTableView.sectionHeaderTopPadding = 0
        }
        coHereTableView.separatorStyle = .singleLine
        coHereTableView.separatorColor = UIColor(coHereBlackListHex: 0xE5E5E5)
            .withAlphaComponent(0.2)
        coHereTableView.separatorInset = .zero
        coHereTableView.layoutMargins = .zero
        coHereTableView.keyboardDismissMode = .onDrag
        coHereTableView.showsVerticalScrollIndicator = false
        coHereTableView.register(
            CoHereBlackListCell.self,
            forCellReuseIdentifier: CoHereBlackListCell.coHereReuseIdentifier
        )
        coHereTableView.register(
            CoHereBlackListSectionHeaderView.self,
            forHeaderFooterViewReuseIdentifier: CoHereBlackListSectionHeaderView.coHereReuseIdentifier
        )
        coHereListContainer.addSubview(coHereTableView)

        coHereEmptyStateView.translatesAutoresizingMaskIntoConstraints = false
        coHereEmptyStateView.isHidden = true
        coHereEmptyStateView.isUserInteractionEnabled = false
        coHereListContainer.addSubview(coHereEmptyStateView)
    }

    /// 建立与 Figma 纵向位置一致的导航、搜索框和列表约束。
    private func coHereSetupConstraints() {
        NSLayoutConstraint.activate([
            coHereGradientView.topAnchor.constraint(equalTo: topAnchor),
            coHereGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereGradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereGradientView.bottomAnchor.constraint(equalTo: bottomAnchor),

            coHereBackButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            coHereBackButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            coHereBackButton.widthAnchor.constraint(equalToConstant: 36),
            coHereBackButton.heightAnchor.constraint(equalToConstant: 36),

            coHereTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            coHereTitleLabel.centerYAnchor.constraint(equalTo: coHereBackButton.centerYAnchor),
            coHereTitleLabel.heightAnchor.constraint(equalToConstant: 24),

            coHereSearchContainer.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 56
            ),
            coHereSearchContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            coHereSearchContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            coHereSearchContainer.heightAnchor.constraint(equalToConstant: 40),

            coHereSearchIconView.leadingAnchor.constraint(
                equalTo: coHereSearchContainer.leadingAnchor,
                constant: 24
            ),
            coHereSearchIconView.centerYAnchor.constraint(equalTo: coHereSearchContainer.centerYAnchor),
            coHereSearchIconView.widthAnchor.constraint(equalToConstant: 20),
            coHereSearchIconView.heightAnchor.constraint(equalToConstant: 20),

            coHereSearchTextField.leadingAnchor.constraint(
                equalTo: coHereSearchContainer.leadingAnchor,
                constant: 54
            ),
            coHereSearchTextField.trailingAnchor.constraint(
                equalTo: coHereSearchContainer.trailingAnchor,
                constant: -12
            ),
            coHereSearchTextField.topAnchor.constraint(equalTo: coHereSearchContainer.topAnchor),
            coHereSearchTextField.bottomAnchor.constraint(equalTo: coHereSearchContainer.bottomAnchor),

            coHereListContainer.topAnchor.constraint(
                equalTo: coHereSearchContainer.bottomAnchor,
                constant: 23
            ),
            coHereListContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereListContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereListContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            coHereTableView.topAnchor.constraint(equalTo: coHereListContainer.topAnchor),
            coHereTableView.leadingAnchor.constraint(equalTo: coHereListContainer.leadingAnchor),
            coHereTableView.trailingAnchor.constraint(equalTo: coHereListContainer.trailingAnchor),
            coHereTableView.bottomAnchor.constraint(equalTo: coHereListContainer.bottomAnchor),

            coHereEmptyStateView.centerXAnchor.constraint(equalTo: coHereListContainer.centerXAnchor),
            coHereEmptyStateView.topAnchor.constraint(
                equalTo: coHereListContainer.topAnchor,
                constant: -10
            ),
            coHereEmptyStateView.widthAnchor.constraint(equalToConstant: 200),
            coHereEmptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    /// 绑定返回和搜索输入事件。
    private func coHereBindActions() {
        coHereBackButton.addTarget(
            self,
            action: #selector(coHereHandleBackTap),
            for: .touchUpInside
        )
        coHereSearchTextField.addTarget(
            self,
            action: #selector(coHereSearchTextDidChange),
            for: .editingChanged
        )
    }

    /// 根据搜索文本过滤昵称，同时保留每个用户的原始分组坐标。
    /// - Parameter searchText: 搜索框当前文本；空文本恢复完整列表。
    private func coHereApplyFilter(_ searchText: String) {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyword.isEmpty {
            coHereVisibleSections = coHereAllSections
        } else {
            coHereVisibleSections = coHereAllSections.compactMap { section in
                let items = section.items.filter {
                    $0.name.range(
                        of: keyword,
                        options: [.caseInsensitive, .diacriticInsensitive]
                    ) != nil
                }
                guard !items.isEmpty else {
                    return nil
                }
                return CoHereBlackListSection(title: section.title, items: items)
            }
        }
        coHereTableView.reloadData()
        coHereEmptyStateView.isHidden = !coHereVisibleSections.isEmpty
    }

    /// 获取项目当前语言对应的显示文本。
    /// - Parameter key: Localizable.strings 中使用的中文键。
    /// - Returns: 当前语言对应文案。
    private func coHereLocalized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    /// 转发返回按钮点击。
    @objc private func coHereHandleBackTap() {
        onBackTap?()
    }

    /// 实时响应搜索文本变化，只更新当前视觉列表。
    @objc private func coHereSearchTextDidChange() {
        coHereApplyFilter(coHereSearchTextField.text ?? "")
    }
}

extension CoHereBlackListPageView: UITableViewDataSource, UITableViewDelegate {

    /// 返回当前搜索结果中的分组数量。
    func numberOfSections(in tableView: UITableView) -> Int {
        coHereVisibleSections.count
    }

    /// 返回指定分组中的用户数量。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coHereVisibleSections[section].items.count
    }

    /// 配置一个 64pt 高的 Figma 用户行。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereBlackListCell.coHereReuseIdentifier,
            for: indexPath
        ) as? CoHereBlackListCell else {
            return UITableViewCell()
        }
        cell.coHereConfigure(with: coHereVisibleSections[indexPath.section].items[indexPath.row])
        return cell
    }

    /// 配置 48pt 高的字母分组标题。
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: CoHereBlackListSectionHeaderView.coHereReuseIdentifier
        ) as? CoHereBlackListSectionHeaderView else {
            return nil
        }
        header.coHereConfigure(title: coHereVisibleSections[section].title)
        return header
    }

    /// 转发用户行点击，并使用过滤前的原始分组坐标。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = coHereVisibleSections[indexPath.section].items[indexPath.row]
        onUserTap?(item.originalSection, item.originalRow)
    }

    /// 使用原生右侧滑动操作保留“移出黑名单”功能。
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let item = coHereVisibleSections[indexPath.section].items[indexPath.row]
        let removeAction = UIContextualAction(
            style: .destructive,
            title: coHereLocalized("移出黑名单")
        ) { [weak self] _, _, completion in
            self?.onRemoveTap?(item.originalSection, item.originalRow)
            completion(true)
        }
        removeAction.backgroundColor = UIColor(coHereBlackListHex: 0xFF504E)
        let configuration = UISwipeActionsConfiguration(actions: [removeAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

/// Swift 页面内部使用的分组展示模型。
private struct CoHereBlackListSection {

    /// 分组字母标题。
    let title: String

    /// 当前分组内的用户展示项。
    let items: [CoHereBlackListItem]

    /// 从控制器传入的字典创建分组模型。
    /// - Parameter dictionary: 包含 title 和 items 的展示字典。
    init?(dictionary: [String: Any]) {
        guard let title = dictionary["title"] as? String,
              let itemDictionaries = dictionary["items"] as? [[String: Any]] else {
            return nil
        }
        self.title = title
        items = itemDictionaries.compactMap(CoHereBlackListItem.init(dictionary:))
    }

    /// 创建搜索结果分组。
    /// - Parameters:
    ///   - title: 原始分组字母。
    ///   - items: 匹配搜索文本的用户。
    init(title: String, items: [CoHereBlackListItem]) {
        self.title = title
        self.items = items
    }
}

/// Swift 页面内部使用的单个用户展示模型。
private struct CoHereBlackListItem {

    /// 已处理账号状态后的显示昵称。
    let name: String

    /// 可供 SDWebImage 加载的完整头像地址。
    let avatarURL: URL?

    /// 是否使用本地注销账号头像。
    let usesDeletedAvatar: Bool

    /// 过滤前所在分组，用于业务回调。
    let originalSection: Int

    /// 过滤前所在行，用于业务回调。
    let originalRow: Int

    /// 从控制器传入的展示字典创建用户模型。
    /// - Parameter dictionary: 包含昵称、头像和原始坐标的展示字典。
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let usesDeletedAvatar = dictionary["usesDeletedAvatar"] as? Bool,
              let originalSection = dictionary["originalSection"] as? Int,
              let originalRow = dictionary["originalRow"] as? Int else {
            return nil
        }
        self.name = name
        self.usesDeletedAvatar = usesDeletedAvatar
        self.originalSection = originalSection
        self.originalRow = originalRow
        if let avatarURLString = dictionary["avatarURL"] as? String {
            avatarURL = URL(string: avatarURLString)
        } else {
            avatarURL = nil
        }
    }
}

/// 复刻 Figma 头像、昵称和选中背景的列表 Cell。
private final class CoHereBlackListCell: UITableViewCell {

    /// 列表复用标识。
    static let coHereReuseIdentifier = "CoHereBlackListCell"

    /// 40×40pt 用户头像。
    private let coHereAvatarView = UIImageView()

    /// 16pt Medium 用户昵称。
    private let coHereNameLabel = UILabel()

    /// 创建列表 Cell 并初始化布局。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        coHereSetupCell()
    }

    /// Storyboard/XIB 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupCell()
    }

    /// 复用前取消旧头像请求，避免快速滚动时图片错位。
    override func prepareForReuse() {
        super.prepareForReuse()
        coHereAvatarView.sd_cancelCurrentImageLoad()
        coHereAvatarView.image = UIImage(named: "c_avatar_icon")
        coHereNameLabel.text = nil
    }

    /// 使用展示模型刷新真实头像和昵称。
    /// - Parameter item: 当前用户的展示信息。
    func coHereConfigure(with item: CoHereBlackListItem) {
        coHereNameLabel.text = item.name
        if item.usesDeletedAvatar {
            coHereAvatarView.sd_cancelCurrentImageLoad()
            coHereAvatarView.image = UIImage(named: "user_accout_delete_avatar")
        } else {
            coHereAvatarView.sd_setImage(
                with: item.avatarURL,
                placeholderImage: UIImage(named: "c_avatar_icon"),
                options: [.allowInvalidSSLCertificates]
            )
        }
    }

    /// 配置 Figma Cell 的背景、头像、昵称和选中态。
    private func coHereSetupCell() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        layoutMargins = .zero
        preservesSuperviewLayoutMargins = false

        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(coHereBlackListHex: 0xF8F9FF)
        selectedBackgroundView = selectedView

        coHereAvatarView.translatesAutoresizingMaskIntoConstraints = false
        coHereAvatarView.contentMode = .scaleAspectFill
        coHereAvatarView.layer.cornerRadius = 8
        coHereAvatarView.layer.masksToBounds = true
        coHereAvatarView.image = UIImage(named: "c_avatar_icon")
        contentView.addSubview(coHereAvatarView)

        coHereNameLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereNameLabel.textColor = UIColor(coHereBlackListHex: 0x333333)
        coHereNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(coHereNameLabel)

        NSLayoutConstraint.activate([
            coHereAvatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coHereAvatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coHereAvatarView.widthAnchor.constraint(equalToConstant: 40),
            coHereAvatarView.heightAnchor.constraint(equalToConstant: 40),

            coHereNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 68),
            coHereNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            coHereNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coHereNameLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}

/// 复刻 Figma 48pt 字母分组标题。
private final class CoHereBlackListSectionHeaderView: UITableViewHeaderFooterView {

    /// 分组头复用标识。
    static let coHereReuseIdentifier = "CoHereBlackListSectionHeaderView"

    /// 左对齐的分组字母。
    private let coHereTitleLabel = UILabel()

    /// 创建分组头并初始化布局。
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        coHereSetupHeader()
    }

    /// Storyboard/XIB 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupHeader()
    }

    /// 更新当前分组字母。
    /// - Parameter title: 排序逻辑生成的分组标题。
    func coHereConfigure(title: String) {
        coHereTitleLabel.text = title
    }

    /// 配置 Figma 分组头的白色背景和 12pt 字体。
    private func coHereSetupHeader() {
        contentView.backgroundColor = .white

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.textColor = UIColor(coHereBlackListHex: 0x333333)
        coHereTitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        contentView.addSubview(coHereTitleLabel)

        NSLayoutConstraint.activate([
            coHereTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coHereTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coHereTitleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

/// 可供业务页面共同复用的 Figma “暂无数据”组件。
@objc(CoHereEmptyStateView)
final class CoHereEmptyStateView: UIView {

    /// 固定为 200×200pt 的 Figma 坐标画布，使组件被 DZN 横向拉伸时仍保持居中。
    private let coHereCanvasView = UIView()

    /// Figma 空状态中的背景光晕和装饰元素。
    private let coHereGroundView = UIImageView(
        image: UIImage(named: "cohere_blacklist_empty_ground")
    )

    /// Figma 空状态中的蓝色空盒主体。
    private let coHereBoxView = UIImageView(
        image: UIImage(named: "cohere_blacklist_empty_box")
    )

    /// 空状态本地化说明文字。
    private let coHereTitleLabel = UILabel()

    /// DZNEmptyDataSet 在未指定 frame 时使用的设计稿尺寸。
    override var intrinsicContentSize: CGSize {
        CGSize(width: 200, height: 200)
    }

    /// 创建共享空状态组件并配置 Figma 视觉和布局。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupView()
        coHereSetupConstraints()
    }

    /// Storyboard/XIB 初始化入口，保持与代码初始化一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView()
        coHereSetupConstraints()
    }

    /// 创建两层 Figma SVG 和本地化说明文字。
    private func coHereSetupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        coHereCanvasView.translatesAutoresizingMaskIntoConstraints = false
        coHereCanvasView.backgroundColor = .clear
        addSubview(coHereCanvasView)

        coHereGroundView.translatesAutoresizingMaskIntoConstraints = false
        coHereGroundView.contentMode = .scaleAspectFit
        coHereCanvasView.addSubview(coHereGroundView)

        coHereBoxView.translatesAutoresizingMaskIntoConstraints = false
        coHereBoxView.contentMode = .scaleAspectFit
        coHereCanvasView.addSubview(coHereBoxView)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.text = NSLocalizedString("暂无数据", comment: "")
        coHereTitleLabel.textColor = UIColor(coHereBlackListHex: 0x202F49)
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        coHereTitleLabel.textAlignment = .center
        coHereCanvasView.addSubview(coHereTitleLabel)
    }

    /// 按 Figma 子节点 `575:362` 的 200×200 坐标组合两层矢量和说明文字。
    private func coHereSetupConstraints() {
        NSLayoutConstraint.activate([
            coHereCanvasView.centerXAnchor.constraint(equalTo: centerXAnchor),
            coHereCanvasView.topAnchor.constraint(equalTo: topAnchor),
            coHereCanvasView.widthAnchor.constraint(equalToConstant: 200),
            coHereCanvasView.heightAnchor.constraint(equalToConstant: 200),

            coHereGroundView.leadingAnchor.constraint(
                equalTo: coHereCanvasView.leadingAnchor,
                constant: 17.84
            ),
            coHereGroundView.topAnchor.constraint(
                equalTo: coHereCanvasView.topAnchor,
                constant: 85.94
            ),
            coHereGroundView.widthAnchor.constraint(equalToConstant: 164.31),
            coHereGroundView.heightAnchor.constraint(equalToConstant: 108.98),

            coHereBoxView.leadingAnchor.constraint(
                equalTo: coHereCanvasView.leadingAnchor,
                constant: 66.4
            ),
            coHereBoxView.topAnchor.constraint(
                equalTo: coHereCanvasView.topAnchor,
                constant: 48.82
            ),
            coHereBoxView.widthAnchor.constraint(equalToConstant: 72.46),
            coHereBoxView.heightAnchor.constraint(equalToConstant: 77.93),

            coHereTitleLabel.leadingAnchor.constraint(equalTo: coHereCanvasView.leadingAnchor),
            coHereTitleLabel.trailingAnchor.constraint(equalTo: coHereCanvasView.trailingAnchor),
            coHereTitleLabel.topAnchor.constraint(
                equalTo: coHereCanvasView.topAnchor,
                constant: 162
            ),
            coHereTitleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}

/// 页面背景使用的 Figma 浅紫到白色渐变视图。
private final class CoHereBlackListGradientView: UIView {

    /// 页面背景渐变图层。
    private let coHereGradientLayer = CAGradientLayer()

    /// 创建渐变视图并写入设计稿颜色。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupGradient()
    }

    /// Storyboard/XIB 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupGradient()
    }

    /// 随视图尺寸同步渐变图层范围。
    override func layoutSubviews() {
        super.layoutSubviews()
        coHereGradientLayer.frame = bounds
    }

    /// 配置设计稿使用的浅紫到白色对角渐变。
    private func coHereSetupGradient() {
        coHereGradientLayer.colors = [
            UIColor(coHereBlackListHex: 0xF2F1FF).cgColor,
            UIColor.white.cgColor
        ]
        coHereGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        coHereGradientLayer.endPoint = CGPoint(x: 0.62, y: 0.6)
        layer.insertSublayer(coHereGradientLayer, at: 0)
    }
}

private extension UIColor {

    /// 将 Figma 十六进制颜色转换为 UIColor。
    /// - Parameter coHereBlackListHex: 0xRRGGBB 格式颜色值。
    convenience init(coHereBlackListHex: UInt32) {
        self.init(
            red: CGFloat((coHereBlackListHex >> 16) & 0xFF) / 255,
            green: CGFloat((coHereBlackListHex >> 8) & 0xFF) / 255,
            blue: CGFloat(coHereBlackListHex & 0xFF) / 255,
            alpha: 1
        )
    }
}
