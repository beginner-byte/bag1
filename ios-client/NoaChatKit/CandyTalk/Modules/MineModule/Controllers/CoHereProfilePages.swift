//
//  CoHereProfilePages.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import SDWebImage
import UIKit

/// Figma“编辑个人资料”页面的 Swift 控制器，保留头像上传和昵称修改业务。
@objc(CoHereUserInfoViewController)
final class CoHereUserInfoViewController: CandyBaseViewController {

    /// Figma 个人资料页面。
    private let pageView = CoHereUserInfoPageView()

    /// 创建 Swift 页面并绑定三个资料行。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindActions()
        refreshUserInfo()
    }

    /// 从昵称编辑页返回时重新读取当前用户模型。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshUserInfo()
    }

    /// 将 Swift 页面铺满控制器视图。
    private func setupPage() {
        pageView.accessibilityIdentifier = "cohere.profile"
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 绑定返回、头像和昵称点击；账号保持原只读行为。
    private func bindActions() {
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onAvatarTap = { [weak self] in self?.changeAvatar() }
        pageView.onNicknameTap = { [weak self] in
            guard let self else {
                return
            }
            let controller = CoHereEditUserInfoViewController()
            controller.changeType = .nickname
            controller.originalContent =
                NoaUserManager.sharedInstance().userInfo?.nickname ?? ""
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    /// 使用当前缓存用户模型刷新头像、昵称和账号。
    private func refreshUserInfo() {
        let user = NoaUserManager.sharedInstance().userInfo
        pageView.configure(
            avatarURL: user?.avatar.getImageFullUrl(),
            nickname: user?.nickname ?? "",
            account: user?.userName ?? ""
        )
    }

    /// 请求相册权限并打开项目现有单图裁剪器。
    private func changeAvatar() {
        NoaToolManager.share().getPhotoLibraryAuth { [weak self] granted in
            guard let self else {
                return
            }
            guard granted else {
                NoaHUDManager.share().showWarningMessage(
                    localized("相册权限未开启，请在设置中选择当前应用，开启相册权限")
                )
                return
            }
            DispatchQueue.main.async {
                let picker = NoaImagePickerVC()
                picker.isSignlePhoto = true
                picker.isNeedEdit = true
                picker.hasCamera = true
                picker.pickerType = .image
                picker.delegate = self
                self.navigationController?.pushViewController(picker, animated: true)
            }
        }
    }

    /// 压缩裁剪头像、写入缓存并复用原文件上传队列。
    /// - Parameter image: 图片选择器返回的裁剪图。
    private func uploadAvatar(_ image: UIImage) {
        guard let resized = image.coHereResized(to: CGSize(width: 200, height: 200)),
              let data = resized.jpegData(compressionQuality: 0.6) else {
            NoaHUDManager.share().showMessage(localized("上传头像失败"))
            return
        }
        let userUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        let timestamp = Int64(Date().timeIntervalSince1970 * 1_000)
        let fileName = "\(userUID)_\(timestamp).jpg"
        let directory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("\(userUID)-\(userUID)", isDirectory: true)
        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            let fileURL = directory.appendingPathComponent(fileName)
            try data.write(to: fileURL, options: .atomic)
            startAvatarUpload(
                fileName: fileName,
                filePath: fileURL.path,
                dataLength: data.count
            )
        } catch {
            NoaHUDManager.share().showMessage(localized("上传头像失败"))
        }
    }

    /// 创建头像上传任务，成功后更新服务器和本地用户模型。
    /// - Parameters:
    ///   - fileName: 上传文件名。
    ///   - filePath: 缓存文件路径。
    ///   - dataLength: 文件字节数。
    private func startAvatarUpload(
        fileName: String,
        filePath: String,
        dataLength: Int
    ) {
        guard let manager = NoaFileUploadManager.sharedInstance(),
              let task = NoaFileUploadTask(
                taskId: fileName,
                filePath: filePath,
                originFilePath: "",
                fileName: fileName,
                fileType: "",
                isEncrypt: true,
                dataLength: UInt(dataLength),
                uploadType: .userAvatar,
                beSendMessage: nil,
                delegate: nil
              ) else {
            NoaHUDManager.share().showMessage(localized("上传头像失败"))
            return
        }
        NoaHUDManager.share().showActivityMessage("")
        let tokenTask = NoaFileUploadGetSTSTask()
        task.addDependency(tokenTask)
        let completion = BlockOperation { [weak self, weak task] in
            DispatchQueue.main.async {
                guard let self, let task, task.status == .completed else {
                    NoaHUDManager.share().hideHUD()
                    NoaHUDManager.share().showMessage(
                        self?.localized("上传头像失败") ?? ""
                    )
                    return
                }
                self.requestUpdateAvatar(task.originUrl)
            }
        }
        completion.addDependency(task)
        manager.add(task)
        manager.operationQueue.addOperation(completion)
        manager.operationQueue.addOperation(tokenTask)
    }

    /// 调用原更新头像接口并同步缓存用户模型。
    /// - Parameter avatarURL: 文件服务返回的相对头像地址。
    private func requestUpdateAvatar(_ avatarURL: String) {
        let parameters: NSMutableDictionary = [
            "avatar": avatarURL,
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ]
        NoaIMSDKManager.sharedTool().userAvatarChange(
            with: parameters,
            onSuccess: { [weak self] _, _ in
                guard let user = NoaUserManager.sharedInstance().userInfo else {
                    return
                }
                user.avatar = avatarURL
                user.saveUserInfo()
                NoaUserManager.sharedInstance().userInfo = user
                NoaHUDManager.share().hideHUD()
                NoaHUDManager.share().showMessage(
                    self?.localized("更新头像成功") ?? ""
                )
                self?.refreshUserInfo()
            },
            onFailure: { [weak self] _, _, _ in
                NoaHUDManager.share().hideHUD()
                NoaHUDManager.share().showMessage(
                    self?.localized("更新头像失败") ?? ""
                )
            }
        )
    }

    /// 获取 App 当前语言文本。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// 接收项目图片选择器的单图裁剪结果。
extension CoHereUserInfoViewController: ZImagePickerVCDelegate {

    /// 上传图片选择器返回的裁剪头像。
    /// - Parameters:
    ///   - resultImg: 裁剪后的头像。
    ///   - localIdenti: 相册本地标识，仅保留原委托签名。
    @objc func imagePickerClipImage(
        _ resultImg: UIImage,
        localIdenti: String
    ) {
        uploadAvatar(resultImg)
    }
}

/// 个人资料可编辑字段类型；账号类型保留旧接口但主页面仍按原逻辑只读。
enum CoHereUserInfoChangeType {
    case nickname
    case account
}

/// 昵称或账号编辑的 Swift 控制器，复用原校验和更新接口。
final class CoHereEditUserInfoViewController: CandyBaseViewController,
    UITextViewDelegate {

    /// 当前编辑字段类型。
    var changeType: CoHereUserInfoChangeType = .nickname

    /// 进入页面时的原始内容。
    var originalContent = ""

    /// 多行输入框。
    private let textView = UITextView()

    /// 字数计数标签。
    private let countLabel = UILabel()

    /// 顶部保存按钮。
    private let saveButton = UIButton(type: .system)

    /// 创建编辑页面并自动聚焦输入框。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupUI()
        textView.becomeFirstResponder()
        refreshState()
    }

    /// 构建导航栏和 70pt 圆角输入卡片。
    private func setupUI() {
        view.backgroundColor = UIColor(coHereProfileHex: 0xF5F6F9)

        let navigationBar = UIView()
        navigationBar.backgroundColor = .white
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(coHereProfileHex: 0x555555)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.text = localized(
            changeType == .nickname ? "修改昵称" : "修改账号"
        )
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(titleLabel)

        saveButton.setTitle(localized("保存"), for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor(coHereProfileHex: 0x6C63FF)
        saveButton.layer.cornerRadius = 6
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(saveButton)

        let inputCard = UIView()
        inputCard.backgroundColor = .white
        inputCard.layer.cornerRadius = 14
        inputCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputCard)

        textView.text = originalContent
        textView.delegate = self
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = UIColor(coHereProfileHex: 0x111111)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        inputCard.addSubview(textView)

        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = UIColor(coHereProfileHex: 0x999999)
        countLabel.textAlignment = .right
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        inputCard.addSubview(countLabel)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 58
            ),

            backButton.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 8),
            backButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -8),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            saveButton.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            saveButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 52),
            saveButton.heightAnchor.constraint(equalToConstant: 32),

            inputCard.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 16),
            inputCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputCard.heightAnchor.constraint(equalToConstant: 88),

            textView.topAnchor.constraint(equalTo: inputCard.topAnchor, constant: 4),
            textView.leadingAnchor.constraint(equalTo: inputCard.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: inputCard.trailingAnchor, constant: -56),
            textView.bottomAnchor.constraint(equalTo: inputCard.bottomAnchor, constant: -4),

            countLabel.trailingAnchor.constraint(equalTo: inputCard.trailingAnchor, constant: -10),
            countLabel.bottomAnchor.constraint(equalTo: inputCard.bottomAnchor, constant: -10),
            countLabel.widthAnchor.constraint(equalToConstant: 48)
        ])
    }

    /// 限制输入长度、过滤昵称引号并刷新保存状态。
    func textViewDidChange(_ textView: UITextView) {
        if changeType == .nickname {
            textView.text = textView.text
                .replacingOccurrences(of: "'", with: "")
                .replacingOccurrences(of: "’", with: "")
        }
        let maximum = changeType == .nickname ? 30 : 16
        if textView.text.count > maximum {
            textView.text = String(textView.text.prefix(maximum))
        }
        refreshState()
    }

    /// 更新字数和保存按钮启用状态。
    private func refreshState() {
        let maximum = changeType == .nickname ? 30 : 16
        countLabel.text = "\(textView.text.count)/\(maximum)"
        let trimmed = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        saveButton.isEnabled = !trimmed.isEmpty && trimmed != originalContent
        saveButton.alpha = saveButton.isEnabled ? 1 : 0.45
    }

    /// 返回上一级页面。
    @objc private func backTapped() {
        navBtnBackClicked()
    }

    /// 校验当前内容并调用对应更新接口。
    @objc private func saveTapped() {
        let value = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else {
            NoaHUDManager.share().showMessage(
                localized(changeType == .nickname ? "昵称不能为空" : "账号不能为空")
            )
            return
        }
        if changeType == .nickname {
            updateNickname(value)
        } else {
            updateAccount(value)
        }
    }

    /// 调用原昵称更新接口并同步本地用户模型。
    /// - Parameter nickname: 已去除首尾空白的新昵称。
    private func updateNickname(_ nickname: String) {
        let parameters: NSMutableDictionary = [
            "nickname": nickname,
            "userUid": currentUserUID
        ]
        NoaIMSDKManager.sharedTool().userNicknameChange(
            with: parameters,
            onSuccess: { [weak self] _, _ in
                guard let user = NoaUserManager.sharedInstance().userInfo else {
                    return
                }
                user.nickname = nickname
                user.saveUserInfo()
                NoaUserManager.sharedInstance().userInfo = user
                self?.navigationController?.popViewController(animated: true)
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 调用原账号更新接口并同步本地用户模型。
    /// - Parameter account: 已去除首尾空白的新账号。
    private func updateAccount(_ account: String) {
        let parameters: NSMutableDictionary = [
            "userName": account,
            "userUid": currentUserUID
        ]
        NoaIMSDKManager.sharedTool().userAccountChange(
            with: parameters,
            onSuccess: { [weak self] _, _ in
                guard let user = NoaUserManager.sharedInstance().userInfo else {
                    return
                }
                NoaUserModel.savePreAccount(
                    account,
                    type: Int32(UserAuthTypeAccount)
                )
                user.userName = account
                user.saveUserInfo()
                NoaUserManager.sharedInstance().userInfo = user
                self?.navigationController?.popViewController(animated: true)
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 当前登录用户 ID。
    private var currentUserUID: String {
        NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
    }

    /// 获取 App 当前语言文本。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Figma“编辑个人资料”完整页面。
final class CoHereUserInfoPageView: UIView {

    /// 点击返回按钮后的回调。
    var onBackTap: (() -> Void)?

    /// 点击头像行后的回调。
    var onAvatarTap: (() -> Void)?

    /// 点击昵称行后的回调。
    var onNicknameTap: (() -> Void)?

    /// 当前头像视图。
    private let avatarImageView = UIImageView()

    /// 当前昵称右侧文本。
    private let nicknameLabel = UILabel()

    /// 当前账号右侧文本。
    private let accountLabel = UILabel()

    /// 初始化并创建 Figma 页面。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 更新头像、昵称和账号展示。
    /// - Parameters:
    ///   - avatarURL: 完整头像 URL。
    ///   - nickname: 当前昵称。
    ///   - account: 当前账号。
    func configure(avatarURL: URL?, nickname: String, account: String) {
        avatarImageView.sd_setImage(
            with: avatarURL,
            placeholderImage: UIImage(named: "c_avatar_icon"),
            options: [.allowInvalidSSLCertificates]
        )
        nicknameLabel.text = nickname
        accountLabel.text = account
    }

    /// 构建浅灰背景、导航栏和三行资料列表。
    private func setupUI() {
        backgroundColor = UIColor(coHereProfileHex: 0xF5F5F5)

        let navigationBar = UIView()
        navigationBar.backgroundColor = .white
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationBar)

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(coHereProfileHex: 0x555555)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.text = localized("编辑个人资料")
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(titleLabel)

        let avatarRow = makeRow(title: "头像", valueLabel: nil, action: #selector(avatarTapped))
        let nicknameRow = makeRow(title: "昵称", valueLabel: nicknameLabel, action: #selector(nicknameTapped))
        let accountRow = makeRow(title: "账号", valueLabel: accountLabel, action: nil)

        avatarImageView.image = UIImage(named: "c_avatar_icon")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 6
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarRow.addSubview(avatarImageView)

        [avatarRow, nicknameRow, accountRow].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 58
            ),

            backButton.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 8),
            backButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -8),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            avatarRow.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            avatarRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarRow.heightAnchor.constraint(equalToConstant: 52),

            nicknameRow.topAnchor.constraint(equalTo: avatarRow.bottomAnchor, constant: 8),
            nicknameRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            nicknameRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            nicknameRow.heightAnchor.constraint(equalToConstant: 52),

            accountRow.topAnchor.constraint(equalTo: nicknameRow.bottomAnchor, constant: 8),
            accountRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            accountRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            accountRow.heightAnchor.constraint(equalToConstant: 52),

            avatarImageView.trailingAnchor.constraint(equalTo: avatarRow.trailingAnchor, constant: -40),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarRow.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    /// 创建资料行，右侧包含可选值和箭头。
    /// - Parameters:
    ///   - title: 行标题本地化键。
    ///   - valueLabel: 可选右侧值标签。
    ///   - action: 可选点击方法；nil 表示只读。
    /// - Returns: 配置完成的资料行。
    private func makeRow(
        title: String,
        valueLabel: UILabel?,
        action: Selector?
    ) -> UIView {
        let row = UIView()
        row.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.text = localized(title)
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(coHereProfileHex: 0x555555)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(titleLabel)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor(coHereProfileHex: 0xDDDDDD)
        chevron.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(chevron)

        if let valueLabel {
            valueLabel.font = .systemFont(ofSize: 14)
            valueLabel.textColor = UIColor(coHereProfileHex: 0xAAAAAA)
            valueLabel.textAlignment = .right
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(valueLabel)
            NSLayoutConstraint.activate([
                valueLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
                valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12)
            ])
        }

        if let action {
            let button = UIButton(type: .custom)
            button.addTarget(self, action: action, for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(button)
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: row.topAnchor),
                button.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                button.bottomAnchor.constraint(equalTo: row.bottomAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])
        return row
    }

    /// 转发返回点击。
    @objc private func backTapped() {
        onBackTap?()
    }

    /// 转发头像行点击。
    @objc private func avatarTapped() {
        onAvatarTap?()
    }

    /// 转发昵称行点击。
    @objc private func nicknameTapped() {
        onNicknameTap?()
    }

    /// 获取 App 当前语言文本。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

private extension UIImage {
    /// 将图片缩放到头像上传所需尺寸。
    /// - Parameter size: 目标像素尺寸。
    /// - Returns: 缩放后的图片；无 CGImage 时返回 nil。
    func coHereResized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

private extension UIColor {
    /// 使用 24 位十六进制值创建不透明颜色。
    /// - Parameter value: 0xRRGGBB 格式颜色值。
    convenience init(coHereProfileHex value: UInt32) {
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
