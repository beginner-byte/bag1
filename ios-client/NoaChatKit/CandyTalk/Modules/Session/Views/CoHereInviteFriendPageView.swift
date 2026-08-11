//
//  CoHereInviteFriendPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import SDWebImage
import UIKit

/// 联系人多选页的 Swift 分组数据。
struct CoHereSelectionSection {

    /// 分组标题。
    var title: String

    /// 分组内联系人或会话。
    var users: [NoaBaseUserModel]

    /// 分组当前是否展开。
    var isExpanded: Bool
}

/// “创建群聊”页面视觉层，也为选择聊天页提供相同的 Figma 多选结构。
class CoHereInviteFriendPageView: UIView {

    /// 返回按钮点击回调。
    var onBackTap: (() -> Void)?

    /// 完成按钮点击回调。
    var onDoneTap: (() -> Void)?

    /// 搜索文字变化回调。
    var onSearchChanged: ((String) -> Void)?

    /// 联系人选择状态变化回调。
    var onUserToggle: ((NoaBaseUserModel) -> Void)?

    /// 分组展开状态变化回调。
    var onSectionToggle: ((Int) -> Void)?

    /// 分组全选状态变化回调。
    var onSectionSelectAll: ((Int, Bool) -> Void)?

    /// 删除顶部已选联系人回调。
    var onSelectedUserDelete: ((NoaBaseUserModel) -> Void)?

    /// 页面渐变。
    private let gradient = CAGradientLayer()

    /// 返回按钮。
    private let backButton = UIButton(type: .custom)

    /// 标题。
    private let titleLabel = UILabel()

    /// 完成按钮。
    private let doneButton = UIButton(type: .system)

    /// 搜索输入框。
    private let searchField = UITextField()

    /// 已选择联系人横向列表。
    private let selectedCollectionView: UICollectionView

    /// 分组联系人列表。
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 无结果提示。
    private let emptyLabel = UILabel()

    /// 已选择区域高度约束；无选择时收起。
    private var selectedHeightConstraint: NSLayoutConstraint?

    /// 当前页面分组。
    private var sections: [CoHereSelectionSection] = []

    /// 当前搜索结果。
    private var searchResults: [NoaBaseUserModel] = []

    /// 当前已选择联系人。
    private var selectedUsers: [NoaBaseUserModel] = []

    /// 当前是否处于搜索状态。
    private var isSearching = false

    /// 初始化集合布局和页面结构。
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 58, height: 74)
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        selectedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setupView()
        bindActions()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 58, height: 74)
        selectedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
        setupView()
        bindActions()
    }

    /// 更新背景渐变尺寸。
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    /// 配置页面标题。
    /// - Parameter title: “创建群聊”或“选择聊天”。
    func configureTitle(_ title: String) {
        titleLabel.text = title
    }

    /// 刷新分组、搜索、已选中和完成按钮状态。
    /// - Parameters:
    ///   - sections: 非搜索状态展示的分组。
    ///   - searchResults: 搜索状态展示的数据。
    ///   - selectedUsers: 当前已选择对象。
    ///   - isSearching: 是否使用搜索结果。
    func configure(
        sections: [CoHereSelectionSection],
        searchResults: [NoaBaseUserModel],
        selectedUsers: [NoaBaseUserModel],
        isSearching: Bool
    ) {
        self.sections = sections
        self.searchResults = searchResults
        self.selectedUsers = selectedUsers
        self.isSearching = isSearching
        selectedHeightConstraint?.constant = selectedUsers.isEmpty ? 0 : 82
        selectedCollectionView.isHidden = selectedUsers.isEmpty
        doneButton.isEnabled = !selectedUsers.isEmpty
        doneButton.backgroundColor = selectedUsers.isEmpty
            ? UIColor(white: 0.78, alpha: 1)
            : UIColor(red: 0.39, green: 0.43, blue: 0.96, alpha: 1)
        doneButton.setTitle(
            selectedUsers.isEmpty
                ? localized("完成")
                : "\(localized("完成"))(\(selectedUsers.count))",
            for: .normal
        )
        emptyLabel.isHidden = !isSearching || !searchResults.isEmpty
        selectedCollectionView.reloadData()
        tableView.reloadData()
    }

    /// 创建 Figma 导航、搜索、已选列表及分组列表。
    private func setupView() {
        backgroundColor = .white
        gradient.colors = [
            UIColor(
                red: 242.0 / 255.0,
                green: 241.0 / 255.0,
                blue: 1,
                alpha: 1
            ).cgColor,
            UIColor.white.cgColor
        ]
        gradient.locations = [0, 0.61]
        gradient.startPoint = CGPoint(x: 0.15, y: 0)
        gradient.endPoint = CGPoint(x: 0.85, y: 1)
        layer.insertSublayer(gradient, at: 0)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "icon_nav_back"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        addSubview(backButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.16, alpha: 1)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle(localized("完成"), for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 14)
        doneButton.layer.cornerRadius = 4
        doneButton.contentEdgeInsets = .zero
        addSubview(doneButton)

        let searchContainer = UIView()
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.backgroundColor = UIColor.white.withAlphaComponent(0.82)
        searchContainer.layer.cornerRadius = 8
        addSubview(searchContainer)

        let searchIcon = UIImageView(image: UIImage(named: "cim_contacts_search_icon_grey"))
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.contentMode = .scaleAspectFit
        searchContainer.addSubview(searchIcon)

        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = localized("请搜索")
        searchField.clearButtonMode = .whileEditing
        searchField.font = .systemFont(ofSize: 12)
        searchContainer.addSubview(searchField)

        selectedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        selectedCollectionView.backgroundColor = .clear
        selectedCollectionView.showsHorizontalScrollIndicator = false
        selectedCollectionView.dataSource = self
        selectedCollectionView.delegate = self
        selectedCollectionView.register(
            CoHereSelectedUserCell.self,
            forCellWithReuseIdentifier: CoHereSelectedUserCell.reuseIdentifier
        )
        addSubview(selectedCollectionView)
        selectedHeightConstraint = selectedCollectionView.heightAnchor.constraint(equalToConstant: 0)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            CoHereSelectionUserCell.self,
            forCellReuseIdentifier: CoHereSelectionUserCell.reuseIdentifier
        )
        tableView.register(
            CoHereSelectionHeaderView.self,
            forHeaderFooterViewReuseIdentifier: CoHereSelectionHeaderView.reuseIdentifier
        )
        addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = localized("无搜索结果")
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.textColor = UIColor(white: 0.58, alpha: 1)
        emptyLabel.isHidden = true
        addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 28),
            doneButton.widthAnchor.constraint(equalToConstant: 48),

            searchContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),
            searchContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 40),

            searchIcon.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 24),
            searchIcon.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),

            searchField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 10),
            searchField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -10),
            searchField.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),

            selectedCollectionView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 8),
            selectedCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectedCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectedHeightConstraint!,

            tableView.topAnchor.constraint(equalTo: selectedCollectionView.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 56)
        ])
    }

    /// 绑定页面事件。
    private func bindActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
    }

    /// 转发返回点击。
    @objc private func backTapped() {
        onBackTap?()
    }

    /// 转发完成点击。
    @objc private func doneTapped() {
        onDoneTap?()
    }

    /// 转发搜索变化。
    @objc private func searchChanged() {
        onSearchChanged?(
            (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    /// 判断联系人当前是否已选。
    private func isSelected(_ user: NoaBaseUserModel) -> Bool {
        selectedUsers.contains { $0.userId == user.userId && $0.isGroup == user.isGroup }
    }

    /// 获取本地化文案。
    fileprivate func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

extension CoHereInviteFriendPageView: UITableViewDataSource, UITableViewDelegate {

    /// 搜索时仅展示一个结果分组，否则展示原分组数量。
    func numberOfSections(in tableView: UITableView) -> Int {
        isSearching ? 1 : sections.count
    }

    /// 返回搜索结果或展开分组中的用户数量。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchResults.count
        }
        return sections[section].isExpanded ? sections[section].users.count : 0
    }

    /// 创建带头像和勾选状态的用户行。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereSelectionUserCell.reuseIdentifier,
            for: indexPath
        ) as? CoHereSelectionUserCell else {
            return UITableViewCell()
        }
        let user = isSearching
            ? searchResults[indexPath.row]
            : sections[indexPath.section].users[indexPath.row]
        cell.configure(user: user, selected: isSelected(user))
        return cell
    }

    /// 使用 Figma 的 64pt 联系人行高。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }

    /// 点击联系人切换选择状态。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = isSearching
            ? searchResults[indexPath.row]
            : sections[indexPath.section].users[indexPath.row]
        onUserToggle?(user)
    }

    /// 非搜索状态展示可展开和全选的 Figma 分组标题。
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        guard !isSearching,
              let header = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: CoHereSelectionHeaderView.reuseIdentifier
              ) as? CoHereSelectionHeaderView else {
            return nil
        }
        let model = sections[section]
        let allSelected = !model.users.isEmpty && model.users.allSatisfy(isSelected)
        header.configure(
            title: model.title,
            expanded: model.isExpanded,
            allSelected: allSelected
        )
        header.onExpandTap = { [weak self] in self?.onSectionToggle?(section) }
        header.onSelectAllTap = { [weak self] in
            self?.onSectionSelectAll?(section, !allSelected)
        }
        return header
    }

    /// 非搜索状态使用 46pt 分组标题。
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        isSearching ? 0.01 : 46
    }
}

extension CoHereInviteFriendPageView:
    UICollectionViewDataSource,
    UICollectionViewDelegate {

    /// 返回已选择对象数量。
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        selectedUsers.count
    }

    /// 创建顶部已选头像。
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CoHereSelectedUserCell.reuseIdentifier,
            for: indexPath
        ) as? CoHereSelectedUserCell else {
            return UICollectionViewCell()
        }
        cell.configure(user: selectedUsers[indexPath.item])
        return cell
    }

    /// 点击顶部头像删除对应已选对象。
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectedUserDelete?(selectedUsers[indexPath.item])
    }
}

/// 多选页面联系人行。
private final class CoHereSelectionUserCell: UITableViewCell {

    /// Cell 复用标识。
    static let reuseIdentifier = "CoHereSelectionUserCell"

    /// 圆形勾选图标。
    private let checkView = UIImageView()

    /// 联系人或群聊头像。
    private let avatarView = UIImageView()

    /// 联系人或群聊名称。
    private let nameLabel = UILabel()

    /// 创建 Cell。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    /// 刷新头像、名称和选择状态。
    func configure(user: NoaBaseUserModel, selected: Bool) {
        avatarView.sd_setImage(
            with: user.avatar.getImageFullUrl(),
            placeholderImage: UIImage(named: "c_avatar_icon"),
            options: .allowInvalidSSLCertificates
        )
        nameLabel.text = user.name
        checkView.image = UIImage(named: selected ? "c_select_yes" : "c_select_no")
    }

    /// 创建勾选、头像和名称布局。
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .white

        checkView.translatesAutoresizingMaskIntoConstraints = false
        checkView.contentMode = .scaleAspectFit
        contentView.addSubview(checkView)

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true
        contentView.addSubview(avatarView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 15)
        nameLabel.textColor = UIColor(white: 0.18, alpha: 1)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            checkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkView.widthAnchor.constraint(equalToConstant: 24),
            checkView.heightAnchor.constraint(equalToConstant: 24),

            avatarView.leadingAnchor.constraint(equalTo: checkView.trailingAnchor, constant: 12),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

/// 多选页面可展开分组标题。
private final class CoHereSelectionHeaderView: UITableViewHeaderFooterView {

    /// Header 复用标识。
    static let reuseIdentifier = "CoHereSelectionHeaderView"

    /// 展开按钮回调。
    var onExpandTap: (() -> Void)?

    /// 全选按钮回调。
    var onSelectAllTap: (() -> Void)?

    /// 展开箭头按钮。
    private let expandButton = UIButton(type: .system)

    /// 分组标题。
    private let titleLabel = UILabel()

    /// 分组全选按钮。
    private let selectAllButton = UIButton(type: .system)

    /// 创建 Header。
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    /// 清理复用回调。
    override func prepareForReuse() {
        super.prepareForReuse()
        onExpandTap = nil
        onSelectAllTap = nil
    }

    /// 刷新标题、展开和全选状态。
    func configure(title: String, expanded: Bool, allSelected: Bool) {
        titleLabel.text = title
        expandButton.setImage(UIImage(named: "c_arrow_down_gray"), for: .normal)
        expandButton.transform = expanded
            ? .identity
            : CGAffineTransform(rotationAngle: -.pi / 2)
        selectAllButton.setImage(
            UIImage(named: allSelected ? "c_select_yes" : "c_select_no"),
            for: .normal
        )
    }

    /// 创建 Header 布局。
    private func setupView() {
        contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1)

        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.addTarget(self, action: #selector(expandTapped), for: .touchUpInside)
        contentView.addSubview(expandButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(white: 0.24, alpha: 1)
        contentView.addSubview(titleLabel)

        selectAllButton.translatesAutoresizingMaskIntoConstraints = false
        selectAllButton.addTarget(self, action: #selector(selectAllTapped), for: .touchUpInside)
        contentView.addSubview(selectAllButton)

        NSLayoutConstraint.activate([
            expandButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            expandButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            expandButton.widthAnchor.constraint(equalToConstant: 36),
            expandButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: expandButton.trailingAnchor, constant: 2),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            selectAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            selectAllButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectAllButton.widthAnchor.constraint(equalToConstant: 36),
            selectAllButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    /// 转发展开点击。
    @objc private func expandTapped() {
        onExpandTap?()
    }

    /// 转发全选点击。
    @objc private func selectAllTapped() {
        onSelectAllTap?()
    }
}

/// 多选页面顶部已选联系人 Cell。
private final class CoHereSelectedUserCell: UICollectionViewCell {

    /// Cell 复用标识。
    static let reuseIdentifier = "CoHereSelectedUserCell"

    /// 已选用户头像。
    private let avatarView = UIImageView()

    /// 已选用户名称。
    private let nameLabel = UILabel()

    /// 创建 Cell。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    /// 刷新已选用户头像和名称。
    func configure(user: NoaBaseUserModel) {
        avatarView.sd_setImage(
            with: user.avatar.getImageFullUrl(),
            placeholderImage: UIImage(named: "c_avatar_icon"),
            options: .allowInvalidSSLCertificates
        )
        nameLabel.text = user.name
    }

    /// 创建已选头像与名称布局。
    private func setupView() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true
        contentView.addSubview(avatarView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 10)
        nameLabel.textColor = UIColor(white: 0.35, alpha: 1)
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
