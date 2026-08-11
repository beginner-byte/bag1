//
//  CoHereNewFriendListPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import SDWebImage
import UIKit

/// “新的朋友”页面视觉层，按 Figma 展示搜索、时间分组和好友申请状态。
final class CoHereNewFriendListPageView: UIView {

    /// 返回按钮点击回调。
    var onBackTap: (() -> Void)?

    /// 添加朋友按钮点击回调。
    var onAddFriendTap: (() -> Void)?

    /// 搜索文字变化回调；控制器负责过滤业务数据。
    var onSearchChanged: ((String) -> Void)?

    /// 点击申请人的回调。
    var onRequestTap: ((NoaFriendApplyModel) -> Void)?

    /// 点击“添加”按钮的回调。
    var onAcceptTap: ((NoaFriendApplyModel) -> Void)?

    /// 左滑删除申请的回调。
    var onDeleteTap: ((NoaFriendApplyModel) -> Void)?

    /// 列表滚动回调，用于把分组后的真实申请模型交给控制器清除红点。
    var onVisibleRequestsChanged: (([NoaFriendApplyModel]) -> Void)?

    /// 下拉刷新回调。
    var onRefresh: (() -> Void)?

    /// 上拉加载更多回调。
    var onLoadMore: (() -> Void)?

    /// Figma 渐变头部。
    private let headerGradient = CAGradientLayer()

    /// 页面返回按钮。
    private let backButton = UIButton(type: .custom)

    /// 页面标题。
    private let titleLabel = UILabel()

    /// 右上角添加朋友入口。
    private let addButton = UIButton(type: .system)

    /// 搜索输入框。
    private let searchField = UITextField()

    /// 好友申请列表。
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 空态提示。
    private let emptyLabel = UILabel()

    /// 当前按时间分组后的展示数据。
    private var sections: [(title: String, models: [NoaFriendApplyModel])] = []

    /// 当前是否允许继续加载下一页。
    private var canLoadMore = true

    /// 避免同一滚动位置重复触发分页请求。
    private var isLoadingMore = false

    /// 创建页面层级并绑定控件事件。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bindActions()
    }

    /// Storyboard 初始化入口，与代码初始化保持一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bindActions()
    }

    /// 更新渐变层尺寸。
    override func layoutSubviews() {
        super.layoutSubviews()
        headerGradient.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 146)
    }

    /// 使用控制器提供的数据刷新申请列表。
    /// - Parameters:
    ///   - models: 过滤掉本地隐藏记录后的申请数据。
    ///   - canLoadMore: 服务端是否可能还有下一页。
    func configure(models: [NoaFriendApplyModel], canLoadMore: Bool) {
        sections = makeSections(from: models)
        self.canLoadMore = canLoadMore
        isLoadingMore = false
        emptyLabel.isHidden = !models.isEmpty
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }

    /// 结束失败请求造成的刷新动画。
    func endRefreshing() {
        isLoadingMore = false
        tableView.refreshControl?.endRefreshing()
    }

    /// 按 Figma 的“近三天/三天前”规则组织列表。
    /// - Parameter models: 原始申请列表。
    /// - Returns: 保持服务端顺序的两个可选分组。
    private func makeSections(
        from models: [NoaFriendApplyModel]
    ) -> [(title: String, models: [NoaFriendApplyModel])] {
        let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
        var recent: [NoaFriendApplyModel] = []
        var earlier: [NoaFriendApplyModel] = []
        for model in models {
            let milliseconds = Double(model.sendTime) ?? 0
            let seconds = milliseconds > 10_000_000_000 ? milliseconds / 1_000 : milliseconds
            let date = Date(timeIntervalSince1970: seconds)
            if seconds == 0 || date >= threeDaysAgo {
                recent.append(model)
            } else {
                earlier.append(model)
            }
        }
        var result: [(String, [NoaFriendApplyModel])] = []
        if !recent.isEmpty {
            result.append((localized("近三天"), recent))
        }
        if !earlier.isEmpty {
            result.append((localized("三天前"), earlier))
        }
        return result
    }

    /// 创建导航、搜索、列表和空态。
    private func setupView() {
        backgroundColor = .white
        headerGradient.colors = [
            UIColor(
                red: 242.0 / 255.0,
                green: 241.0 / 255.0,
                blue: 1,
                alpha: 1
            ).cgColor,
            UIColor.white.cgColor
        ]
        headerGradient.locations = [0, 1]
        headerGradient.startPoint = CGPoint(x: 0, y: 0)
        headerGradient.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(headerGradient, at: 0)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "icon_nav_back"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        addSubview(backButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = localized("新的朋友")
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.16, alpha: 1)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle(localized("添加朋友"), for: .normal)
        addButton.setTitleColor(UIColor(red: 0.35, green: 0.4, blue: 0.95, alpha: 1), for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        addSubview(addButton)

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
        searchField.font = .systemFont(ofSize: 12)
        searchField.textColor = UIColor(white: 0.2, alpha: 1)
        searchField.clearButtonMode = .whileEditing
        searchContainer.addSubview(searchField)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            CoHereNewFriendRequestCell.self,
            forCellReuseIdentifier: CoHereNewFriendRequestCell.reuseIdentifier
        )
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = localized("暂无好友申请")
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = UIColor(white: 0.6, alpha: 1)
        emptyLabel.font = .systemFont(ofSize: 14)
        addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 44),

            searchContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
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

            tableView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// 将 UIKit 事件转发给 Swift 控制器。
    private func bindActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addFriendTapped), for: .touchUpInside)
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(refreshTriggered),
            for: .valueChanged
        )
    }

    /// 处理返回点击。
    @objc private func backTapped() {
        onBackTap?()
    }

    /// 处理添加朋友点击。
    @objc private func addFriendTapped() {
        onAddFriendTap?()
    }

    /// 处理搜索文字变化。
    @objc private func searchChanged() {
        onSearchChanged?(searchField.text ?? "")
    }

    /// 处理下拉刷新。
    @objc private func refreshTriggered() {
        onRefresh?()
    }

    /// 获取当前语言的页面文案。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

extension CoHereNewFriendListPageView: UITableViewDataSource, UITableViewDelegate {

    /// 返回当前时间分组数量。
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    /// 返回分组内申请数量。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].models.count
    }

    /// 创建并配置好友申请 Cell。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereNewFriendRequestCell.reuseIdentifier,
            for: indexPath
        ) as? CoHereNewFriendRequestCell else {
            return UITableViewCell()
        }
        let model = sections[indexPath.section].models[indexPath.row]
        cell.configure(model: model)
        cell.onAcceptTap = { [weak self] in self?.onAcceptTap?(model) }
        return cell
    }

    /// 使用 Figma 的 64pt 申请行高。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }

    /// 创建近三天/三天前分组标题。
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(white: 0.56, alpha: 1)
        label.text = sections[section].title
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }

    /// 使用 Figma 的 32pt 分组标题高度。
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }

    /// 点击行进入原有好友申请或用户主页流程。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onRequestTap?(sections[indexPath.section].models[indexPath.row])
    }

    /// 提供原有左滑隐藏好友申请功能。
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let model = sections[indexPath.section].models[indexPath.row]
        let delete = UIContextualAction(
            style: .destructive,
            title: localized("删除")
        ) { [weak self] _, _, completion in
            self?.onDeleteTap?(model)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    /// 上报可见行并在接近底部时触发下一页。
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleModels: [NoaFriendApplyModel] =
            (tableView.indexPathsForVisibleRows ?? []).compactMap { path in
            guard path.section < sections.count,
                  path.row < sections[path.section].models.count else {
                return nil
            }
            return sections[path.section].models[path.row]
        }
        onVisibleRequestsChanged?(visibleModels)
        guard canLoadMore, !isLoadingMore,
              scrollView.contentSize.height > scrollView.bounds.height,
              scrollView.contentOffset.y + scrollView.bounds.height >
                scrollView.contentSize.height - 120 else {
            return
        }
        isLoadingMore = true
        onLoadMore?()
    }
}

/// “新的朋友”页面专属申请 Cell。
private final class CoHereNewFriendRequestCell: UITableViewCell {

    /// Cell 复用标识。
    static let reuseIdentifier = "CoHereNewFriendRequestCell"

    /// 点击通过验证按钮的回调。
    var onAcceptTap: (() -> Void)?

    /// 用户头像。
    private let avatarView = UIImageView()

    /// 用户昵称。
    private let nameLabel = UILabel()

    /// 申请说明。
    private let messageLabel = UILabel()

    /// 申请状态或添加按钮。
    private let statusButton = UIButton(type: .system)

    /// 创建 Cell 视觉结构。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    /// 防止复用时保留旧点击状态。
    override func prepareForReuse() {
        super.prepareForReuse()
        onAcceptTap = nil
    }

    /// 使用好友申请模型刷新头像、昵称和状态。
    func configure(model: NoaFriendApplyModel) {
        let isOutgoing = model.fromUserUid ==
            (NoaUserManager.sharedInstance().userInfo?.userUID ?? "")
        let avatar = isOutgoing ? model.beUserAvatar : model.fromUserAvatar
        avatarView.sd_setImage(
            with: avatar.getImageFullUrl(),
            placeholderImage: UIImage(named: "c_avatar_icon"),
            options: .allowInvalidSSLCertificates
        )
        nameLabel.text = isOutgoing ? model.beUserNickname : model.nickname
        messageLabel.text = isOutgoing
            ? localized("等待对方通过好友申请")
            : localized("请求添加你为好友")

        statusButton.isEnabled = model.beStatus == 0 && !isOutgoing
        switch model.beStatus {
        case 0 where !isOutgoing:
            statusButton.setTitle(localized("添加"), for: .normal)
            statusButton.backgroundColor = UIColor(red: 0.39, green: 0.43, blue: 0.96, alpha: 1)
            statusButton.setTitleColor(.white, for: .normal)
        case 0:
            statusButton.setTitle(localized("等待验证"), for: .normal)
            configureDisabledStatus()
        case 1:
            statusButton.setTitle(localized("已添加"), for: .normal)
            configureDisabledStatus()
        default:
            statusButton.setTitle(localized("已过期"), for: .normal)
            configureDisabledStatus()
        }
    }

    /// 创建头像、文本与状态按钮布局。
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .white

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true
        contentView.addSubview(avatarView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = UIColor(white: 0.18, alpha: 1)
        contentView.addSubview(nameLabel)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 12)
        messageLabel.textColor = UIColor(white: 0.58, alpha: 1)
        contentView.addSubview(messageLabel)

        statusButton.translatesAutoresizingMaskIntoConstraints = false
        statusButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        statusButton.layer.cornerRadius = 12
        statusButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        contentView.addSubview(statusButton)

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 1),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusButton.leadingAnchor, constant: -8),

            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: -1),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusButton.leadingAnchor, constant: -8),

            statusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            statusButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    /// 设置等待、已添加和已过期的禁用外观。
    private func configureDisabledStatus() {
        statusButton.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
        statusButton.setTitleColor(UIColor(white: 0.58, alpha: 1), for: .normal)
    }

    /// 转发通过验证点击。
    @objc private func acceptTapped() {
        onAcceptTap?()
    }

    /// 获取当前语言文案。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
