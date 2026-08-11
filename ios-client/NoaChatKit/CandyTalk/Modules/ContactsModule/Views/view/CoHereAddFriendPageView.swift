//
//  CoHereAddFriendPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import SDWebImage
import UIKit

/// “添加好友”页面视觉层，展示搜索、真实二维码、账号及搜索结果。
final class CoHereAddFriendPageView: UIView {

    /// 返回按钮点击回调。
    var onBackTap: (() -> Void)?

    /// 用户提交搜索回调。
    var onSearchSubmit: ((String) -> Void)?

    /// 搜索文字清空回调。
    var onSearchCleared: (() -> Void)?

    /// 点击搜索结果回调。
    var onUserTap: ((NoaUserModel) -> Void)?

    /// 点击搜索结果添加按钮回调。
    var onAddUserTap: ((NoaUserModel) -> Void)?

    /// 点击二维码回调。
    var onQRCodeTap: (() -> Void)?

    /// 长按账号复制回调。
    var onAccountLongPress: (() -> Void)?

    /// 页面渐变背景。
    private let gradient = CAGradientLayer()

    /// 返回按钮。
    private let backButton = UIButton(type: .custom)

    /// 页面标题。
    private let titleLabel = UILabel()

    /// 搜索输入框。
    private let searchField = UITextField()

    /// 二维码展示容器。
    private let qrContainer = UIView()

    /// 真实二维码图片。
    private let qrImageView = UIImageView()

    /// 当前账号说明。
    private let accountLabel = UILabel()

    /// 搜索结果列表。
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 无搜索结果提示。
    private let emptyLabel = UILabel()

    /// 当前搜索到的用户列表。
    private var users: [NoaUserModel] = []

    /// 创建页面层级。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bindActions()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bindActions()
    }

    /// 更新背景渐变尺寸。
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    /// 刷新当前账号和二维码。
    /// - Parameters:
    ///   - account: 当前用户账号。
    ///   - qrImage: 接口内容生成的真实二维码；为空时保留加载占位。
    func configureAccount(_ account: String, qrImage: UIImage?) {
        accountLabel.text = String(
            format: localized("我的账号：%@"),
            account
        )
        qrImageView.image = qrImage
    }

    /// 展示用户搜索结果或无结果状态。
    /// - Parameter users: 精确搜索接口返回的用户。
    func configureSearchResults(_ users: [NoaUserModel]) {
        self.users = users
        qrContainer.isHidden = !users.isEmpty
        accountLabel.isHidden = !users.isEmpty
        tableView.isHidden = users.isEmpty
        emptyLabel.isHidden = true
        tableView.reloadData()
    }

    /// 展示“该用户不存在”状态。
    func showNoResult() {
        users.removeAll()
        qrContainer.isHidden = true
        accountLabel.isHidden = true
        tableView.isHidden = true
        emptyLabel.isHidden = false
        emptyLabel.text = localized("该用户不存在")
    }

    /// 清空搜索后恢复二维码首页状态。
    func showDefaultState() {
        users.removeAll()
        qrContainer.isHidden = false
        accountLabel.isHidden = false
        tableView.isHidden = true
        emptyLabel.isHidden = true
        tableView.reloadData()
    }

    /// 创建 Figma 导航、搜索、二维码和结果区域。
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
        titleLabel.text = localized("添加好友")
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        addSubview(titleLabel)

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
        searchField.returnKeyType = .search
        searchField.clearButtonMode = .whileEditing
        searchField.font = .systemFont(ofSize: 12)
        searchField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        searchContainer.addSubview(searchField)

        qrContainer.translatesAutoresizingMaskIntoConstraints = false
        qrContainer.backgroundColor = .clear
        addSubview(qrContainer)

        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.isUserInteractionEnabled = true
        qrContainer.addSubview(qrImageView)

        accountLabel.translatesAutoresizingMaskIntoConstraints = false
        accountLabel.font = .systemFont(ofSize: 14)
        accountLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        accountLabel.textAlignment = .center
        accountLabel.isUserInteractionEnabled = true
        addSubview(accountLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            CoHereAddFriendResultCell.self,
            forCellReuseIdentifier: CoHereAddFriendResultCell.reuseIdentifier
        )
        addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.isHidden = true
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.textColor = UIColor(white: 0.55, alpha: 1)
        emptyLabel.textAlignment = .center
        addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            searchContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 4),
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

            qrContainer.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 56),
            qrContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            qrContainer.widthAnchor.constraint(equalToConstant: 140),
            qrContainer.heightAnchor.constraint(equalToConstant: 140),

            qrImageView.topAnchor.constraint(equalTo: qrContainer.topAnchor),
            qrImageView.leadingAnchor.constraint(equalTo: qrContainer.leadingAnchor),
            qrImageView.trailingAnchor.constraint(equalTo: qrContainer.trailingAnchor),
            qrImageView.bottomAnchor.constraint(equalTo: qrContainer.bottomAnchor),

            accountLabel.topAnchor.constraint(equalTo: qrContainer.bottomAnchor, constant: 8),
            accountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            accountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            accountLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            accountLabel.heightAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 14),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 54)
        ])
    }

    /// 绑定页面控件事件。
    private func bindActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        qrImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(qrTapped))
        )
        accountLabel.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(accountLongPressed(_:))
            )
        )
    }

    /// 转发返回点击。
    @objc private func backTapped() {
        onBackTap?()
    }

    /// 输入框清空时恢复默认二维码状态。
    @objc private func searchTextChanged() {
        if (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            onSearchCleared?()
        }
    }

    /// 转发二维码点击。
    @objc private func qrTapped() {
        onQRCodeTap?()
    }

    /// 仅在长按开始阶段转发复制事件。
    @objc private func accountLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        onAccountLongPress?()
    }

    /// 获取本地化文案。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

extension CoHereAddFriendPageView: UITextFieldDelegate {

    /// 在键盘搜索键触发精确搜索。
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onSearchSubmit?(
            (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        )
        return true
    }
}

extension CoHereAddFriendPageView: UITableViewDataSource, UITableViewDelegate {

    /// 返回搜索结果数量。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    /// 创建搜索结果 Cell。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereAddFriendResultCell.reuseIdentifier,
            for: indexPath
        ) as? CoHereAddFriendResultCell else {
            return UITableViewCell()
        }
        let user = users[indexPath.row]
        cell.configure(user: user)
        cell.onAddTap = { [weak self] in self?.onAddUserTap?(user) }
        return cell
    }

    /// 使用原页面 76pt 结果行高。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }

    /// 点击用户进入用户主页。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onUserTap?(users[indexPath.row])
    }
}

/// 添加好友页面专属搜索结果 Cell。
private final class CoHereAddFriendResultCell: UITableViewCell {

    /// Cell 复用标识。
    static let reuseIdentifier = "CoHereAddFriendResultCell"

    /// 添加按钮点击回调。
    var onAddTap: (() -> Void)?

    /// 用户头像。
    private let avatarView = UIImageView()

    /// 用户昵称。
    private let nameLabel = UILabel()

    /// 添加或已添加按钮。
    private let addButton = UIButton(type: .system)

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

    /// 清理复用回调。
    override func prepareForReuse() {
        super.prepareForReuse()
        onAddTap = nil
    }

    /// 使用搜索用户刷新 Cell。
    func configure(user: NoaUserModel) {
        avatarView.sd_setImage(
            with: user.avatar.getImageFullUrl(),
            placeholderImage: UIImage(named: "c_avatar_icon"),
            options: .allowInvalidSSLCertificates
        )
        nameLabel.text = user.nickname
        let existingFriend: LingIMFriendModel? = NoaIMSDKManager.sharedTool()
            .toolCheckMyFriend(with: user.userUID)
        let isFriend = existingFriend != nil
        addButton.isEnabled = !isFriend
        addButton.setTitle(
            localized(isFriend ? "已添加" : "添加好友"),
            for: .normal
        )
        addButton.backgroundColor = isFriend
            ? UIColor(white: 0.86, alpha: 1)
            : UIColor(red: 0.39, green: 0.43, blue: 0.96, alpha: 1)
    }

    /// 创建搜索结果布局。
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 22
        avatarView.clipsToBounds = true
        contentView.addSubview(avatarView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = UIColor(white: 0.15, alpha: 1)
        contentView.addSubview(nameLabel)

        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        addButton.layer.cornerRadius = 12
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        contentView.addSubview(addButton)

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 44),
            avatarView.heightAnchor.constraint(equalToConstant: 44),

            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: addButton.leadingAnchor, constant: -12),

            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 80),
            addButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    /// 转发添加按钮点击。
    @objc private func addTapped() {
        onAddTap?()
    }

    /// 获取本地化文案。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
