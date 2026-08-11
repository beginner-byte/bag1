//
//  CoHereCredentialPages.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// Figma“设置密码”页面的 Swift 控制器，按旧流程先校验原密码，再重置新密码。
@objc(CoHerePasswordSettingViewController)
final class CoHerePasswordSettingViewController: CandyBaseViewController {

    /// 是否为服务端强制重置；为 true 时禁止返回和侧滑。
    @objc var isForcedReset = false

    /// 当前账号是否已有密码；无密码时隐藏旧密码字段并直接设置新密码。
    @objc var requiresOldPassword = true

    /// Figma 密码表单页面。
    private let pageView = CoHereCredentialPageView(
        title: "设置密码",
        fields: [
            .init(title: "旧密码", placeholder: "请输入原密码"),
            .init(title: "新密码", placeholder: "请输入新密码"),
            .init(title: "确认新密码", placeholder: "请再次输入新密码")
        ],
        tip: "密码长度6-16位，须包含字母、数字",
        auxiliaryTitle: "忘记旧密码？"
    )

    /// 创建 Swift 页面并绑定表单动作。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindActions()
        pageView.setFieldHidden(at: 0, hidden: !requiresOldPassword)
    }

    /// 根据强制重置状态控制返回入口和系统侧滑。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageView.isBackHidden = isForcedReset
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !isForcedReset
    }

    /// 离开页面时恢复系统侧滑，避免影响后续页面。
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    /// 将表单铺满控制器视图。
    private func setupPage() {
        pageView.accessibilityIdentifier = "cohere.password"
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 绑定返回、完成和忘记密码入口。
    private func bindActions() {
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onDoneTap = { [weak self] values in self?.submit(values) }
        pageView.onAuxiliaryTap = { [weak self] in
            self?.navigationController?.pushViewController(
                NoaForgetPasswordViewController(),
                animated: true
            )
        }
    }

    /// 校验三个密码字段并启动旧密码校验请求。
    /// - Parameter values: 依次为旧密码、新密码和确认密码。
    private func submit(_ values: [String]) {
        guard values.count == 3 else {
            return
        }
        let oldPassword = values[0]
        let newPassword = values[1]
        let confirmation = values[2]
        guard !requiresOldPassword || !oldPassword.isEmpty else {
            showMessage("密码不能为空")
            return
        }
        guard isValidPassword(newPassword), isValidPassword(confirmation) else {
            showMessage("密码长度6-16位，须包含字母、数字")
            return
        }
        guard newPassword == confirmation else {
            showMessage("密码不一致")
            return
        }
        guard requiresOldPassword else {
            resetPassword(newPassword)
            return
        }
        requestEncryptKey { [weak self] encryptKey in
            self?.checkOldPassword(
                oldPassword,
                newPassword: newPassword,
                encryptKey: encryptKey
            )
        }
    }

    /// 请求本次密码操作使用的服务端加密 Key。
    /// - Parameter completion: Key 获取成功后的继续处理。
    private func requestEncryptKey(completion: @escaping (String) -> Void) {
        NoaHUDManager.share().showActivityMessage("", in: view)
        NoaIMSDKManager.sharedTool().authGetEncryptKeySuccess(
            { [weak self] data, _ in
                NoaHUDManager.share().hideHUD()
                guard let key = data as? String, !key.isEmpty else {
                    self?.showMessage("操作失败")
                    return
                }
                completion(key)
            },
            onFailure: { [weak self] code, message, _ in
                NoaHUDManager.share().hideHUD()
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? "",
                    in: self?.view
                )
            }
        )
    }

    /// 复用旧接口校验原密码，成功后才允许重置新密码。
    /// - Parameters:
    ///   - oldPassword: 用户输入的原密码。
    ///   - newPassword: 已通过本地格式校验的新密码。
    ///   - encryptKey: 服务端本次加密 Key。
    private func checkOldPassword(
        _ oldPassword: String,
        newPassword: String,
        encryptKey: String
    ) {
        let parameters: NSMutableDictionary = [
            "password": LXChatEncrypt.method4(encryptKey + oldPassword) ?? "",
            "encryptKey": encryptKey,
            "userUid": currentUserUID
        ]
        NoaIMSDKManager.sharedTool().userCheckUserPassword(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard (data as? NSNumber)?.boolValue == true else {
                    self?.showMessage("密码校验失败")
                    return
                }
                self?.resetPassword(newPassword)
            },
            onFailure: { [weak self] code, message, _ in
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? "",
                    in: self?.view
                )
            }
        )
    }

    /// 获取新 Key 并调用旧重置密码接口；成功后保持原逻辑返回登录页。
    /// - Parameter password: 已校验的新密码。
    private func resetPassword(_ password: String) {
        requestEncryptKey { [weak self] encryptKey in
            guard let self else {
                return
            }
            let parameters: NSMutableDictionary = [
                "password": LXChatEncrypt.method4(encryptKey + password) ?? "",
                "encryptKey": encryptKey,
                "userUid": currentUserUID
            ]
            NoaIMSDKManager.sharedTool().userResetPassword(
                with: parameters,
                onSuccess: { [weak self] data, _ in
                    guard (data as? NSNumber)?.boolValue == true else {
                        self?.showMessage("修改密码失败")
                        return
                    }
                    self?.showMessage("修改密码成功")
                    NoaToolManager.share().setupLoginUI()
                },
                onFailure: { [weak self] code, message, _ in
                    NoaHUDManager.share().showMessage(
                        withCode: code,
                        errorMsg: message ?? "",
                        in: self?.view
                    )
                }
            )
        }
    }

    /// 当前登录用户 ID；缺失时沿用旧字典安全写入语义传空字符串。
    private var currentUserUID: String {
        NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
    }

    /// 按旧规则校验 6-16 位且同时包含字母与数字。
    /// - Parameter password: 待校验密码。
    /// - Returns: 满足旧业务规则时返回 true。
    private func isValidPassword(_ password: String) -> Bool {
        guard (6...16).contains(password.count) else {
            return false
        }
        return password.range(of: "[A-Za-z]", options: .regularExpression) != nil
            && password.range(of: "[0-9]", options: .regularExpression) != nil
    }

    /// 使用 App 当前语言显示业务提示。
    /// - Parameter key: 简体中文本地化键。
    private func showMessage(_ key: String) {
        NoaHUDManager.share().showMessage(localized(key), in: view)
    }

    /// 获取 App 当前语言下的文本。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// 设备安全码编辑模式；设置使用两个字段，修改使用原安全码、新安全码和确认字段。
enum CoHereSafeCodeEditorMode {
    case create
    case change
}

/// Figma“设置安全码”页面的 Swift 控制器，保留设置和修改两套服务端契约。
@objc(CoHereSafeCodeEditorViewController)
final class CoHereSafeCodeEditorViewController: CandyBaseViewController {

    /// 页面业务模式，默认用于首次设置。
    var mode: CoHereSafeCodeEditorMode = .create

    /// 安全码表单；修改模式在展示前重建为三个字段。
    private var pageView: CoHereCredentialPageView!

    /// 创建对应模式的 Swift 页面并绑定动作。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        pageView = makePage()
        setupPage()
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onDoneTap = { [weak self] values in self?.submit(values) }
    }

    /// 构建首次设置或修改安全码的字段结构。
    /// - Returns: 已按当前模式配置的表单页面。
    private func makePage() -> CoHereCredentialPageView {
        let fields: [CoHereCredentialFieldConfiguration]
        if mode == .create {
            fields = [
                .init(title: "安全码", placeholder: "请输入安全码"),
                .init(title: "确认安全码", placeholder: "请再次输入安全码")
            ]
        } else {
            fields = [
                .init(title: "原安全码", placeholder: "请输入原安全码"),
                .init(title: "新安全码", placeholder: "请输入新安全码"),
                .init(title: "确认安全码", placeholder: "请再次输入安全码")
            ]
        }
        return CoHereCredentialPageView(
            title: mode == .create ? "设置安全码" : "修改安全码",
            fields: fields,
            tip: "为了加强安全防护，请设置您的设备安全码，新设备首次登录时须输入安全码。安全码6位，同时包含字母、数字",
            auxiliaryTitle: nil
        )
    }

    /// 将表单铺满控制器视图。
    private func setupPage() {
        pageView.accessibilityIdentifier = "cohere.safe-code"
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 校验安全码格式和一致性后请求加密 Key。
    /// - Parameter values: 当前模式下各输入字段的值。
    private func submit(_ values: [String]) {
        let expectedCount = mode == .create ? 2 : 3
        guard values.count == expectedCount, values.allSatisfy(isValidSafeCode) else {
            showMessage("请输入6位包含字母、数字的安全码")
            return
        }
        let newCode = mode == .create ? values[0] : values[1]
        let confirmation = mode == .create ? values[1] : values[2]
        guard newCode == confirmation else {
            showMessage("两次安全码需保持一致")
            return
        }
        requestEncryptKey { [weak self] key in
            guard let self else {
                return
            }
            if mode == .create {
                saveSafeCode(newCode, encryptKey: key)
            } else {
                changeSafeCode(
                    original: values[0],
                    newCode: newCode,
                    encryptKey: key
                )
            }
        }
    }

    /// 请求安全码接口使用的服务端加密 Key。
    /// - Parameter completion: Key 获取成功后的继续处理。
    private func requestEncryptKey(completion: @escaping (String) -> Void) {
        NoaHUDManager.share().showActivityMessage("", in: view)
        NoaIMSDKManager.sharedTool().authGetEncryptKeySuccess(
            { [weak self] data, _ in
                NoaHUDManager.share().hideHUD()
                guard let key = data as? String, !key.isEmpty else {
                    self?.showMessage("操作失败")
                    return
                }
                completion(key)
            },
            onFailure: { [weak self] code, message, _ in
                NoaHUDManager.share().hideHUD()
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? "",
                    in: self?.view
                )
            }
        )
    }

    /// 调用原首次设置安全码接口。
    /// - Parameters:
    ///   - code: 通过校验的安全码。
    ///   - encryptKey: 服务端加密 Key。
    private func saveSafeCode(_ code: String, encryptKey: String) {
        let parameters: NSMutableDictionary = [
            "encryptKey": encryptKey,
            "securityCode": LXChatEncrypt.method4(encryptKey + code.trimmingCharacters(in: .whitespacesAndNewlines)) ?? "",
            "userUid": currentUserUID
        ]
        NoaIMSDKManager.sharedTool().authSaveSecurityCode(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard (data as? NSNumber)?.boolValue == true else {
                    self?.showMessage("操作失败")
                    return
                }
                self?.showMessage("设置成功")
                self?.refreshSafeSettingPage()
                self?.navigationController?.popViewController(animated: true)
            },
            onFailure: { [weak self] code, message, _ in
                self?.handleSafeCodeFailure(code: code, message: message)
            }
        )
    }

    /// 调用原修改安全码接口并同时提交旧、新安全码密文。
    /// - Parameters:
    ///   - original: 原安全码。
    ///   - newCode: 新安全码。
    ///   - encryptKey: 服务端加密 Key。
    private func changeSafeCode(
        original: String,
        newCode: String,
        encryptKey: String
    ) {
        let parameters: NSMutableDictionary = [
            "encryptKey": encryptKey,
            "securityCode": LXChatEncrypt.method4(encryptKey + newCode.trimmingCharacters(in: .whitespacesAndNewlines)) ?? "",
            "userUid": currentUserUID,
            "originalSecurityCode": LXChatEncrypt.method4(encryptKey + original.trimmingCharacters(in: .whitespacesAndNewlines)) ?? ""
        ]
        NoaIMSDKManager.sharedTool().authUpdatecurityCode(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard (data as? NSNumber)?.boolValue == true else {
                    self?.showMessage("操作失败")
                    return
                }
                self?.showMessage("修改成功")
                self?.navigationController?.popViewController(animated: true)
            },
            onFailure: { [weak self] code, message, _ in
                self?.handleSafeCodeFailure(code: code, message: message)
            }
        )
    }

    /// 对安全码业务错误沿用服务端提示策略，其他错误显示通用请求提示。
    /// - Parameters:
    ///   - code: 服务端错误码。
    ///   - message: 服务端错误文本。
    private func handleSafeCodeFailure(code: Int, message: String?) {
        let silentCodes = [
            Auth_Login_SecurityCode_Has_Set_Error_Code,
            Auth_Login_SecurityCode_No_Set_Error_Code,
            Auth_Login_SecurityCode_Format_Error_Code,
            Auth_Login_SecurityCode_otherFormat_Error_Code
        ]
        guard !silentCodes.contains(Int32(code)) else {
            return
        }
        NoaHUDManager.share().showMessage(
            withCode: code,
            errorMsg: message ?? "",
            in: view
        )
    }

    /// 通知导航栈中的安全设置页重新请求启用状态。
    private func refreshSafeSettingPage() {
        navigationController?.viewControllers
            .compactMap { $0 as? CoHereSafeSettingViewController }
            .forEach { $0.checkDeviceSafeCodeStatus() }
    }

    /// 安全码必须为 6 位且同时包含字母与数字。
    /// - Parameter code: 待校验安全码。
    /// - Returns: 满足旧业务规则时返回 true。
    private func isValidSafeCode(_ code: String) -> Bool {
        guard code.count == 6 else {
            return false
        }
        return code.range(of: "[A-Za-z]", options: .regularExpression) != nil
            && code.range(of: "[0-9]", options: .regularExpression) != nil
    }

    /// 当前登录用户 ID；缺失时沿用旧参数安全写入语义传空字符串。
    private var currentUserUID: String {
        NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
    }

    /// 使用 App 当前语言显示业务提示。
    /// - Parameter key: 简体中文本地化键。
    private func showMessage(_ key: String) {
        NoaHUDManager.share().showMessage(
            NoaLanguageManager.share().matchLocalLanguage(key),
            in: view
        )
    }
}

/// Figma 输入字段的标题和占位文案。
struct CoHereCredentialFieldConfiguration {
    /// 输入字段标题。
    let title: String
    /// 输入字段占位文案。
    let placeholder: String
}

/// 密码和安全码共用的 Figma 表单页面。
final class CoHereCredentialPageView: UIView {

    /// 点击返回按钮后的回调。
    var onBackTap: (() -> Void)?

    /// 点击完成后的回调，参数按页面字段顺序返回。
    var onDoneTap: (([String]) -> Void)?

    /// 点击辅助入口后的回调，例如“忘记旧密码”。
    var onAuxiliaryTap: (() -> Void)?

    /// 是否隐藏返回按钮，用于强制重置密码场景。
    var isBackHidden: Bool {
        get { backButton.isHidden }
        set { backButton.isHidden = newValue }
    }

    /// 当前页面标题本地化键。
    private let titleKey: String

    /// 页面字段配置。
    private let fieldConfigurations: [CoHereCredentialFieldConfiguration]

    /// 页面说明文案本地化键。
    private let tipKey: String

    /// 可选辅助入口本地化键。
    private let auxiliaryKey: String?

    /// 顶部返回按钮。
    private let backButton = UIButton(type: .system)

    /// 顶部完成按钮。
    private let doneButton = UIButton(type: .system)

    /// 所有安全输入框，顺序与配置一致。
    private var textFields: [UITextField] = []

    /// 输入字段容器，供无旧密码场景隐藏第一项。
    private var fieldContainers: [UIView] = []

    /// iOS 13 兼容的显隐按钮到安全输入框映射。
    private var secureFieldByButton: [UIButton: UITextField] = [:]

    /// 使用配置创建密码或安全码表单。
    /// - Parameters:
    ///   - title: 页面标题本地化键。
    ///   - fields: 字段标题和占位文案。
    ///   - tip: 页面说明本地化键。
    ///   - auxiliaryTitle: 可选辅助入口本地化键。
    init(
        title: String,
        fields: [CoHereCredentialFieldConfiguration],
        tip: String,
        auxiliaryTitle: String?
    ) {
        titleKey = title
        fieldConfigurations = fields
        tipKey = tip
        auxiliaryKey = auxiliaryTitle
        super.init(frame: .zero)
        setupUI()
    }

    /// Interface Builder 不支持动态字段配置。
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 隐藏或显示指定字段，同时保留回调值顺序。
    /// - Parameters:
    ///   - index: 字段配置下标。
    ///   - hidden: 是否隐藏。
    func setFieldHidden(at index: Int, hidden: Bool) {
        guard fieldContainers.indices.contains(index) else {
            return
        }
        fieldContainers[index].isHidden = hidden
    }

    /// 构建 Figma 导航区、滚动表单、输入框和辅助入口。
    private func setupUI() {
        backgroundColor = .white

        let navigationBar = UIView()
        navigationBar.backgroundColor = UIColor(coHereCredentialHex: 0xF9F9FF)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationBar)

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(coHereCredentialHex: 0x555555)
        backButton.accessibilityLabel = localized("返回")
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.text = localized(titleKey)
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(coHereCredentialHex: 0x222222)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(titleLabel)

        doneButton.setTitle(localized("完成"), for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = UIColor(coHereCredentialHex: 0x6C63FF)
        doneButton.layer.cornerRadius = 4
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(doneButton)

        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        for configuration in fieldConfigurations {
            let fieldGroup = makeFieldGroup(configuration)
            stackView.addArrangedSubview(fieldGroup.container)
            fieldContainers.append(fieldGroup.container)
            textFields.append(fieldGroup.textField)
        }

        let tipLabel = UILabel()
        tipLabel.text = localized(tipKey)
        tipLabel.font = .systemFont(ofSize: 14)
        tipLabel.textColor = UIColor(coHereCredentialHex: 0x999999)
        tipLabel.numberOfLines = 0
        stackView.addArrangedSubview(tipLabel)

        if let auxiliaryKey {
            let auxiliaryButton = UIButton(type: .system)
            auxiliaryButton.contentHorizontalAlignment = .leading
            auxiliaryButton.setTitle(localized(auxiliaryKey), for: .normal)
            auxiliaryButton.setTitleColor(
                UIColor(coHereCredentialHex: 0x8290C3),
                for: .normal
            )
            auxiliaryButton.titleLabel?.font = .systemFont(ofSize: 14)
            auxiliaryButton.addTarget(
                self,
                action: #selector(auxiliaryTapped),
                for: .touchUpInside
            )
            stackView.addArrangedSubview(auxiliaryButton)
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

            doneButton.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            doneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 48),
            doneButton.heightAnchor.constraint(equalToConstant: 28),

            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    /// 创建带标题、圆角安全输入框和显隐按钮的字段组。
    /// - Parameter configuration: 字段标题和占位文案。
    /// - Returns: 字段容器和内部文本框。
    private func makeFieldGroup(
        _ configuration: CoHereCredentialFieldConfiguration
    ) -> (container: UIView, textField: UITextField) {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.text = localized(configuration.title)
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(coHereCredentialHex: 0x1A1D2E)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        let fieldBackground = UIView()
        fieldBackground.backgroundColor = UIColor(coHereCredentialHex: 0xF7F8FF)
        fieldBackground.layer.cornerRadius = 8
        fieldBackground.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(fieldBackground)

        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.keyboardType = .asciiCapable
        textField.textContentType = .oneTimeCode
        textField.font = .systemFont(ofSize: 14)
        textField.textColor = UIColor(coHereCredentialHex: 0x1A1D2E)
        textField.attributedPlaceholder = NSAttributedString(
            string: localized(configuration.placeholder),
            attributes: [.foregroundColor: UIColor(coHereCredentialHex: 0xAAB3CC)]
        )
        textField.translatesAutoresizingMaskIntoConstraints = false
        fieldBackground.addSubview(textField)

        let eyeButton = UIButton(type: .system)
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.tintColor = UIColor(coHereCredentialHex: 0x9EACD0)
        eyeButton.accessibilityLabel = localized("显示密码")
        secureFieldByButton[eyeButton] = textField
        eyeButton.addTarget(
            self,
            action: #selector(toggleSecureField(_:)),
            for: .touchUpInside
        )
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        fieldBackground.addSubview(eyeButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),

            fieldBackground.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            fieldBackground.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            fieldBackground.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            fieldBackground.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            fieldBackground.heightAnchor.constraint(equalToConstant: 52),

            textField.leadingAnchor.constraint(equalTo: fieldBackground.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: fieldBackground.topAnchor),
            textField.bottomAnchor.constraint(equalTo: fieldBackground.bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: eyeButton.leadingAnchor, constant: -8),

            eyeButton.trailingAnchor.constraint(equalTo: fieldBackground.trailingAnchor, constant: -12),
            eyeButton.centerYAnchor.constraint(equalTo: fieldBackground.centerYAnchor),
            eyeButton.widthAnchor.constraint(equalToConstant: 32),
            eyeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        return (container, textField)
    }

    /// 在 iOS 13 及以上切换指定安全输入框的明文显示状态。
    /// - Parameter sender: 被点击的眼睛按钮。
    @objc private func toggleSecureField(_ sender: UIButton) {
        guard let textField = secureFieldByButton[sender] else {
            return
        }
        textField.isSecureTextEntry.toggle()
        sender.setImage(
            UIImage(systemName: textField.isSecureTextEntry ? "eye" : "eye.slash"),
            for: .normal
        )
        sender.accessibilityLabel = localized(
            textField.isSecureTextEntry ? "显示密码" : "隐藏密码"
        )
    }

    /// 转发返回点击。
    @objc private func backTapped() {
        onBackTap?()
    }

    /// 按字段顺序收集输入并转发完成点击。
    @objc private func doneTapped() {
        onDoneTap?(textFields.map { $0.text ?? "" })
    }

    /// 转发辅助入口点击。
    @objc private func auxiliaryTapped() {
        onAuxiliaryTap?()
    }

    /// 获取 App 当前语言下的文本。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

private extension UIColor {
    /// 使用 24 位十六进制值创建不透明颜色。
    /// - Parameter value: 0xRRGGBB 格式颜色值。
    convenience init(coHereCredentialHex value: UInt32) {
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
