//
//  CoHereSsoPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/27.
//

import UIKit

/// 邀请码与 IP 域名加入页的 Swift 可视层，负责 Figma 布局、输入状态和交互转发。
@objc(CoHereSsoPageView)
final class CoHereSsoPageView: UIView, UITextFieldDelegate {

    /// 点击返回按钮后的业务回调。
    @objc var onBackTap: (() -> Void)?

    /// 点击系统语言入口后的业务回调。
    @objc var onLanguageTap: (() -> Void)?

    /// 点击网络设置入口后的业务回调。
    @objc var onNetworkSettingsTap: (() -> Void)?

    /// 点击帮助入口后的业务回调。
    @objc var onHelpTap: (() -> Void)?

    /// 点击扫一扫入口后的业务回调。
    @objc var onScanTap: (() -> Void)?

    /// 点击网络监测入口后的业务回调，参数为当前邀请码。
    @objc var onNetworkDetectionTap: ((String) -> Void)?

    /// 点击加入按钮后的业务回调，参数依次为类型和规范化后的输入内容。
    @objc var onJoinTap: ((Int, String) -> Void)?

    /// 当前选择类型，1 表示邀请码，2 表示 IP 域名。
    @objc private(set) var selectedSsoType = SsoMode.invite.rawValue

    /// 页面顶部浅色渐变层。
    private let gradientLayer = CAGradientLayer()

    /// 返回按钮。
    private let backButton = UIButton(type: .custom)

    /// 页面标题。
    private let titleLabel = UILabel()

    /// 系统语言入口。
    private let languageButton = UIButton(type: .custom)

    /// Figma 异形页签与白色内容背景。
    private let surfaceView = CoHereSsoTabSurfaceView()

    /// 邀请码页签。
    private let inviteTabButton = UIButton(type: .custom)

    /// IP 域名页签。
    private let ipTabButton = UIButton(type: .custom)

    /// 页签选中指示线。
    private let tabIndicator = UIView()

    /// 指示线相对页面左侧的动态约束。
    private var tabIndicatorCenterConstraint: NSLayoutConstraint?

    /// 邀请码输入框。
    private let inviteTextField = UITextField()

    /// IP 或域名输入框。
    private let ipTextField = UITextField()

    /// 端口输入框。
    private let portTextField = UITextField()

    /// IP 与端口之间的冒号。
    private let colonLabel = UILabel()

    /// 加入按钮。
    private let joinButton = UIButton(type: .custom)

    /// 网络设置入口。
    private let networkSettingsButton = UIButton(type: .custom)

    /// 帮助入口。
    private let helpButton = UIButton(type: .custom)

    /// 扫一扫入口。
    private let scanButton = UIButton(type: .custom)

    /// 网络监测入口。
    private let networkDetectionButton = UIButton(type: .custom)

    /// 版本信息。
    private let versionLabel = UILabel()

    /// 页面当前展示模式。
    private var mode = SsoMode.invite

    /// 创建邀请码页面并初始化全部视图。
    /// - Parameter frame: 初始页面区域，最终由 Auto Layout 更新。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
        applyMode(.invite, animated: false)
    }

    /// Storyboard 初始化入口，当前项目通过代码创建但仍保持完整支持。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupActions()
        applyMode(.invite, animated: false)
    }

    /// 更新渐变和异形页签路径以适配当前屏幕宽度。
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        surfaceView.selectedMode = mode
        tabIndicatorCenterConstraint?.constant = bounds.width * (mode == .invite ? 0.25 : 0.75)
    }

    /// 更新页面展示的版本号。
    /// - Parameter text: 版本号与构建号组合文本。
    @objc(setVersionText:)
    func setVersionText(_ text: String) {
        versionLabel.text = text
    }

    /// 控制返回按钮是否展示并允许点击。
    /// - Parameter visible: YES 展示返回按钮，NO 隐藏。
    @objc(setBackButtonVisible:)
    func setBackButtonVisible(_ visible: Bool) {
        backButton.isHidden = !visible
        backButton.isUserInteractionEnabled = visible
    }

    /// 根据扫码结果切换输入类型并回填内容。
    /// - Parameters:
    ///   - type: 1 表示邀请码，2 表示 IP 域名。
    ///   - text: 扫码得到的邀请码或 IP/域名加端口。
    @objc(updateSsoType:text:)
    func updateSsoType(_ type: Int, text: String) {
        let targetMode = SsoMode(rawValue: type) ?? .invite
        applyMode(targetMode, animated: true)
        if targetMode == .invite {
            inviteTextField.text = sanitizeInvite(text)
        } else {
            applyIPDomainText(text)
        }
        updateJoinButtonState()
    }

    /// 创建页面背景、导航、页签、表单和底部入口。
    private func setupView() {
        backgroundColor = .white
        setupGradient()
        setupNavigation()
        setupSurface()
        setupTabs()
        setupInputs()
        setupActionsArea()
        setupFooter()
    }

    /// 创建与 Figma 一致的左上淡紫到右下白色渐变。
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 242 / 255, green: 241 / 255, blue: 1, alpha: 1).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.82, y: 0.62)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    /// 创建返回、动态标题和系统语言入口。
    private func setupNavigation() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "sso_back"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        addSubview(backButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(hex: 0x333333)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        languageButton.translatesAutoresizingMaskIntoConstraints = false
        languageButton.setTitle(localized("系统语言"), for: .normal)
        languageButton.setTitleColor(UIColor(hex: 0x333333), for: .normal)
        languageButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        languageButton.setImage(UIImage(named: "sso_language"), for: .normal)
        languageButton.imageView?.contentMode = .scaleAspectFit
        languageButton.semanticContentAttribute = .forceLeftToRight
        applyCompactButtonLayout(languageButton, imagePadding: 6, imageOnRight: false)
        addSubview(languageButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 52),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),

            languageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            languageButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            languageButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    /// 创建从页签延伸到底部的白色异形内容背景。
    private func setupSurface() {
        surfaceView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(surfaceView)

        NSLayoutConstraint.activate([
            surfaceView.topAnchor.constraint(equalTo: topAnchor, constant: 114),
            surfaceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            surfaceView.trailingAnchor.constraint(equalTo: trailingAnchor),
            surfaceView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// 创建邀请码和 IP 域名页签及选中指示线。
    private func setupTabs() {
        configureTabButton(inviteTabButton, title: localized("邀请码"), tag: SsoMode.invite.rawValue)
        configureTabButton(ipTabButton, title: localized("IP/域名"), tag: SsoMode.ipDomain.rawValue)
        surfaceView.addSubview(inviteTabButton)
        surfaceView.addSubview(ipTabButton)

        tabIndicator.translatesAutoresizingMaskIntoConstraints = false
        tabIndicator.backgroundColor = UIColor(hex: 0x6C63FF)
        tabIndicator.layer.cornerRadius = 1.5
        surfaceView.addSubview(tabIndicator)

        NSLayoutConstraint.activate([
            inviteTabButton.topAnchor.constraint(equalTo: surfaceView.topAnchor),
            inviteTabButton.leadingAnchor.constraint(equalTo: surfaceView.leadingAnchor),
            inviteTabButton.widthAnchor.constraint(equalTo: surfaceView.widthAnchor, multiplier: 0.5),
            inviteTabButton.heightAnchor.constraint(equalToConstant: 61),

            ipTabButton.topAnchor.constraint(equalTo: surfaceView.topAnchor),
            ipTabButton.trailingAnchor.constraint(equalTo: surfaceView.trailingAnchor),
            ipTabButton.widthAnchor.constraint(equalTo: surfaceView.widthAnchor, multiplier: 0.5),
            ipTabButton.heightAnchor.constraint(equalToConstant: 61),

            tabIndicator.topAnchor.constraint(equalTo: surfaceView.topAnchor, constant: 50),
            tabIndicator.widthAnchor.constraint(equalToConstant: 48),
            tabIndicator.heightAnchor.constraint(equalToConstant: 3)
        ])

        tabIndicatorCenterConstraint = tabIndicator.centerXAnchor.constraint(
            equalTo: surfaceView.leadingAnchor,
            constant: bounds.width * 0.25
        )
        tabIndicatorCenterConstraint?.isActive = true
    }

    /// 创建邀请码、IP 和端口输入框。
    private func setupInputs() {
        configureTextField(inviteTextField, placeholder: localized("请输入邀请码"))
        configureTextField(ipTextField, placeholder: localized("请输入IP/域名"))
        configureTextField(portTextField, placeholder: localized("端口号"))
        inviteTextField.keyboardType = .asciiCapable
        ipTextField.keyboardType = .URL
        portTextField.keyboardType = .numberPad

        colonLabel.translatesAutoresizingMaskIntoConstraints = false
        colonLabel.text = "："
        colonLabel.textColor = UIColor(hex: 0x333333)
        colonLabel.font = .systemFont(ofSize: 14, weight: .regular)
        colonLabel.textAlignment = .center

        surfaceView.addSubview(inviteTextField)
        surfaceView.addSubview(ipTextField)
        surfaceView.addSubview(colonLabel)
        surfaceView.addSubview(portTextField)

        NSLayoutConstraint.activate([
            inviteTextField.topAnchor.constraint(equalTo: surfaceView.topAnchor, constant: 89),
            inviteTextField.leadingAnchor.constraint(equalTo: surfaceView.leadingAnchor, constant: 24),
            inviteTextField.trailingAnchor.constraint(equalTo: surfaceView.trailingAnchor, constant: -24),
            inviteTextField.heightAnchor.constraint(equalToConstant: 52),

            ipTextField.topAnchor.constraint(equalTo: inviteTextField.topAnchor),
            ipTextField.leadingAnchor.constraint(equalTo: surfaceView.leadingAnchor, constant: 24),
            ipTextField.trailingAnchor.constraint(equalTo: colonLabel.leadingAnchor),
            ipTextField.heightAnchor.constraint(equalToConstant: 52),

            colonLabel.centerXAnchor.constraint(equalTo: surfaceView.centerXAnchor),
            colonLabel.centerYAnchor.constraint(equalTo: ipTextField.centerYAnchor),
            colonLabel.widthAnchor.constraint(equalToConstant: 15),

            portTextField.topAnchor.constraint(equalTo: ipTextField.topAnchor),
            portTextField.leadingAnchor.constraint(equalTo: colonLabel.trailingAnchor),
            portTextField.trailingAnchor.constraint(equalTo: surfaceView.trailingAnchor, constant: -24),
            portTextField.heightAnchor.constraint(equalToConstant: 52),

            ipTextField.widthAnchor.constraint(equalTo: portTextField.widthAnchor)
        ])
    }

    /// 创建加入按钮、网络设置、帮助和扫码入口。
    private func setupActionsArea() {
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.setTitle(localized("加入"), for: .normal)
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        joinButton.backgroundColor = UIColor(hex: 0x6C63FF)
        joinButton.layer.cornerRadius = 8
        surfaceView.addSubview(joinButton)

        configureShortcutButton(
            networkSettingsButton,
            title: localized("网络设置"),
            imageName: "sso_settings",
            titleColor: UIColor(hex: 0x6C63FF),
            imagePadding: 6
        )
        configureShortcutButton(
            helpButton,
            title: localized("帮助"),
            imageName: "sso_help",
            titleColor: UIColor(hex: 0x333333),
            imagePadding: 8,
            imageOnRight: true
        )
        configureShortcutButton(
            scanButton,
            title: localized("扫一扫加入服务器"),
            imageName: "sso_scan",
            titleColor: UIColor(hex: 0x6C63FF),
            imagePadding: 6
        )

        surfaceView.addSubview(networkSettingsButton)
        surfaceView.addSubview(helpButton)
        surfaceView.addSubview(scanButton)

        NSLayoutConstraint.activate([
            joinButton.topAnchor.constraint(equalTo: surfaceView.topAnchor, constant: 165),
            joinButton.leadingAnchor.constraint(equalTo: surfaceView.leadingAnchor, constant: 24),
            joinButton.trailingAnchor.constraint(equalTo: surfaceView.trailingAnchor, constant: -24),
            joinButton.heightAnchor.constraint(equalToConstant: 44),

            networkSettingsButton.leadingAnchor.constraint(equalTo: surfaceView.leadingAnchor, constant: 24),
            networkSettingsButton.topAnchor.constraint(equalTo: surfaceView.topAnchor, constant: 217),
            networkSettingsButton.heightAnchor.constraint(equalToConstant: 38),

            helpButton.trailingAnchor.constraint(equalTo: surfaceView.trailingAnchor, constant: -24),
            helpButton.centerYAnchor.constraint(equalTo: networkSettingsButton.centerYAnchor),
            helpButton.heightAnchor.constraint(equalToConstant: 38),

            scanButton.centerXAnchor.constraint(equalTo: surfaceView.centerXAnchor),
            scanButton.topAnchor.constraint(equalTo: surfaceView.topAnchor, constant: 269),
            scanButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    /// 创建邀请码状态下的网络监测和版本信息。
    private func setupFooter() {
        configureShortcutButton(
            networkDetectionButton,
            title: localized("网络监测"),
            imageName: "sso_detection",
            titleColor: UIColor(hex: 0x333333),
            imagePadding: 10
        )
        surfaceView.addSubview(networkDetectionButton)

        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.font = .systemFont(ofSize: 11, weight: .regular)
        versionLabel.textColor = UIColor(hex: 0xBBBBC8)
        versionLabel.textAlignment = .center
        surfaceView.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            networkDetectionButton.centerXAnchor.constraint(equalTo: surfaceView.centerXAnchor),
            networkDetectionButton.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -12),
            networkDetectionButton.heightAnchor.constraint(equalToConstant: 44),

            versionLabel.centerXAnchor.constraint(equalTo: surfaceView.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15),
            versionLabel.heightAnchor.constraint(equalToConstant: 17)
        ])
    }

    /// 绑定页面全部控件事件和输入变化。
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        languageButton.addTarget(self, action: #selector(languageTapped), for: .touchUpInside)
        inviteTabButton.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        ipTabButton.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        networkSettingsButton.addTarget(self, action: #selector(networkSettingsTapped), for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        scanButton.addTarget(self, action: #selector(scanTapped), for: .touchUpInside)
        networkDetectionButton.addTarget(self, action: #selector(networkDetectionTapped), for: .touchUpInside)

        [inviteTextField, ipTextField, portTextField].forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
    }

    /// 应用页面模式并更新标题、页签、表单和底部信息。
    /// - Parameters:
    ///   - newMode: 目标邀请码类型。
    ///   - animated: 是否对页签切换执行短动画。
    private func applyMode(_ newMode: SsoMode, animated: Bool) {
        mode = newMode
        selectedSsoType = newMode.rawValue
        surfaceView.selectedMode = newMode

        let isInvite = newMode == .invite
        titleLabel.text = localized(isInvite ? "邀请码加入" : "IP域名加入")
        inviteTextField.isHidden = !isInvite
        ipTextField.isHidden = isInvite
        portTextField.isHidden = isInvite
        colonLabel.isHidden = isInvite
        networkDetectionButton.isHidden = !isInvite
        versionLabel.isHidden = !isInvite

        inviteTabButton.setTitleColor(
            isInvite ? UIColor(hex: 0x6C63FF) : UIColor(hex: 0x333333),
            for: .normal
        )
        ipTabButton.setTitleColor(
            isInvite ? UIColor(hex: 0x333333) : UIColor(hex: 0x6C63FF),
            for: .normal
        )
        inviteTabButton.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: isInvite ? .medium : .regular
        )
        ipTabButton.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: isInvite ? .regular : .medium
        )

        tabIndicatorCenterConstraint?.constant = bounds.width * (isInvite ? 0.25 : 0.75)
        let changes = {
            self.surfaceView.layoutIfNeeded()
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: changes)
        } else {
            changes()
        }
        updateJoinButtonState()
    }

    /// 配置页签按钮的公共视觉属性。
    /// - Parameters:
    ///   - button: 需要配置的页签按钮。
    ///   - title: 本地化页签标题。
    ///   - tag: 对应的邀请码类型。
    private func configureTabButton(_ button: UIButton, title: String, tag: Int) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tag = tag
    }

    /// 配置输入框的背景、文字、占位和内边距。
    /// - Parameters:
    ///   - textField: 需要配置的输入框。
    ///   - placeholder: 本地化占位文字。
    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(hex: 0xF8F9FF)
        textField.layer.cornerRadius = 8
        textField.textColor = UIColor(hex: 0x333333)
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(hex: 0x94A3B8),
                .font: UIFont.systemFont(ofSize: 14, weight: .regular)
            ]
        )
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textField.rightViewMode = .always
        textField.returnKeyType = .done
    }

    /// 配置带图标的快捷入口按钮。
    /// - Parameters:
    ///   - button: 需要配置的按钮。
    ///   - title: 本地化标题。
    ///   - imageName: 工程内图标名称。
    ///   - titleColor: 标题颜色。
    ///   - imagePadding: 图标和标题间距。
    ///   - imageOnRight: YES 将图标放在文字右侧。
    private func configureShortcutButton(
        _ button: UIButton,
        title: String,
        imageName: String,
        titleColor: UIColor,
        imagePadding: CGFloat,
        imageOnRight: Bool = false
    ) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: imageName == "sso_scan" ? 16 : 14, weight: .medium)
        button.imageView?.contentMode = .scaleAspectFit
        button.semanticContentAttribute = imageOnRight ? .forceRightToLeft : .forceLeftToRight
        applyCompactButtonLayout(button, imagePadding: imagePadding, imageOnRight: imageOnRight)
    }

    /// 应用兼容 iOS 13 的紧凑图文布局。
    /// - Parameters:
    ///   - button: 需要清除系统边距的按钮。
    ///   - imagePadding: 图标与文字之间的总间距。
    ///   - imageOnRight: YES 表示图标位于文字右侧。
    private func applyCompactButtonLayout(
        _ button: UIButton,
        imagePadding: CGFloat,
        imageOnRight: Bool
    ) {
        button.contentEdgeInsets = .zero
        let halfPadding = imagePadding * 0.5
        if imageOnRight {
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: halfPadding, bottom: 0, right: -halfPadding)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -halfPadding, bottom: 0, right: halfPadding)
        } else {
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -halfPadding, bottom: 0, right: halfPadding)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: halfPadding, bottom: 0, right: -halfPadding)
        }
    }

    /// 保持加入按钮为 Figma 的完整主色状态，空输入错误由控制器统一提示。
    private func updateJoinButtonState() {
        joinButton.isEnabled = true
        joinButton.alpha = 1
    }

    /// 过滤邀请码，只保留字母和数字。
    /// - Parameter value: 原始输入或扫码字符串。
    /// - Returns: 移除非法字符后的邀请码。
    private func sanitizeInvite(_ value: String) -> String {
        value.unicodeScalars
            .filter { CharacterSet.alphanumerics.contains($0) }
            .map(String.init)
            .joined()
    }

    /// 将 IP/域名加端口字符串拆分并回填两个输入框。
    /// - Parameter value: 可包含 http、https 和端口的原始地址。
    private func applyIPDomainText(_ value: String) {
        var normalized = value
            .replacingOccurrences(of: "http://", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "https://", with: "", options: .caseInsensitive)
        while normalized.hasSuffix("/") {
            normalized.removeLast()
        }

        guard let separator = normalized.lastIndex(of: ":") else {
            ipTextField.text = normalized
            portTextField.text = ""
            return
        }

        let host = String(normalized[..<separator])
        let port = String(normalized[normalized.index(after: separator)...])
        if !host.isEmpty, port.allSatisfy(\.isNumber) {
            ipTextField.text = host
            portTextField.text = port
        } else {
            ipTextField.text = normalized
            portTextField.text = ""
        }
    }

    /// 获取应用当前语言对应的本地化文本。
    /// - Parameter key: 多语言资源键。
    /// - Returns: 当前应用语言下的显示文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }

    /// 转发返回按钮点击。
    @objc private func backTapped() {
        onBackTap?()
    }

    /// 转发系统语言入口点击。
    @objc private func languageTapped() {
        onLanguageTap?()
    }

    /// 切换邀请码或 IP 域名页签。
    /// - Parameter sender: 携带目标类型 tag 的页签按钮。
    @objc private func tabTapped(_ sender: UIButton) {
        guard let newMode = SsoMode(rawValue: sender.tag), newMode != mode else {
            return
        }
        endEditing(true)
        applyMode(newMode, animated: true)
    }

    /// 规范化当前输入并转发加入事件。
    @objc private func joinTapped() {
        endEditing(true)
        if mode == .invite {
            let value = sanitizeInvite(inviteTextField.text ?? "").lowercased()
            onJoinTap?(mode.rawValue, value)
            return
        }

        let host = (ipTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let port = (portTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let value = host.isEmpty ? "" : (port.isEmpty ? host : "\(host):\(port)")
        onJoinTap?(mode.rawValue, value)
    }

    /// 转发网络设置入口点击。
    @objc private func networkSettingsTapped() {
        onNetworkSettingsTap?()
    }

    /// 转发帮助入口点击。
    @objc private func helpTapped() {
        onHelpTap?()
    }

    /// 转发扫一扫入口点击。
    @objc private func scanTapped() {
        onScanTap?()
    }

    /// 转发网络监测入口点击并附带当前邀请码。
    @objc private func networkDetectionTapped() {
        onNetworkDetectionTap?(sanitizeInvite(inviteTextField.text ?? "").lowercased())
    }

    /// 响应输入变化并更新加入按钮。
    @objc private func textFieldChanged() {
        updateJoinButtonState()
    }

    /// 过滤空格、邀请码非法字符和端口非数字字符。
    /// - Parameters:
    ///   - textField: 当前输入框。
    ///   - range: 即将替换的文本范围。
    ///   - string: 用户即将输入的字符串。
    /// - Returns: YES 允许输入，NO 阻止输入。
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty {
            return true
        }
        if string.rangeOfCharacter(from: .whitespacesAndNewlines) != nil {
            return false
        }
        if textField === inviteTextField {
            return string.unicodeScalars.allSatisfy { CharacterSet.alphanumerics.contains($0) }
        }
        if textField === portTextField {
            return string.allSatisfy(\.isNumber)
        }
        return true
    }

    /// Return 键收起当前输入框。
    /// - Parameter textField: 当前响应 Return 键的输入框。
    /// - Returns: YES 允许系统完成 Return 键处理。
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

/// 邀请码页面的两种表单状态，与既有 Objective-C 枚举值保持一致。
private enum SsoMode: Int {
    /// 邀请码加入。
    case invite = 1

    /// IP 或域名加入。
    case ipDomain = 2
}

/// 绘制 Figma 中随页签状态切换的白色异形内容背景。
private final class CoHereSsoTabSurfaceView: UIView {

    /// 当前选中模式，变化后重绘异形顶部轮廓。
    var selectedMode = SsoMode.invite {
        didSet {
            setNeedsLayout()
        }
    }

    /// 白色内容背景形状。
    private let shapeLayer = CAShapeLayer()

    /// 创建透明容器并安装白色形状层。
    /// - Parameter frame: 初始区域，最终由 Auto Layout 更新。
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        shapeLayer.fillColor = UIColor.white.cgColor
        layer.insertSublayer(shapeLayer, at: 0)
    }

    /// Storyboard 初始化入口。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        shapeLayer.fillColor = UIColor.white.cgColor
        layer.insertSublayer(shapeLayer, at: 0)
    }

    /// 根据页面宽度和选中页签更新白色背景路径。
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        shapeLayer.path = makeSurfacePath().cgPath
    }

    /// 构建邀请码或 IP 域名状态对应的异形顶部路径。
    /// - Returns: 覆盖页签选中区域和下方内容的白色路径。
    private func makeSurfacePath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let middle = width * 0.5
        let shoulder = width * 0.38
        let topHeight: CGFloat = 61
        let radius: CGFloat = 12

        if selectedMode == .invite {
            path.move(to: CGPoint(x: 0, y: radius))
            path.addQuadCurve(to: CGPoint(x: radius, y: 0), controlPoint: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: shoulder, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: shoulder + 15, y: 9),
                controlPoint: CGPoint(x: shoulder + 9, y: 0)
            )
            path.addLine(to: CGPoint(x: middle - 4, y: topHeight - 8))
            path.addQuadCurve(
                to: CGPoint(x: middle + 8, y: topHeight),
                controlPoint: CGPoint(x: middle, y: topHeight)
            )
            path.addLine(to: CGPoint(x: width - radius, y: topHeight))
            path.addQuadCurve(
                to: CGPoint(x: width, y: topHeight + radius),
                controlPoint: CGPoint(x: width, y: topHeight)
            )
        } else {
            path.move(to: CGPoint(x: 0, y: topHeight + radius))
            path.addQuadCurve(
                to: CGPoint(x: radius, y: topHeight),
                controlPoint: CGPoint(x: 0, y: topHeight)
            )
            path.addLine(to: CGPoint(x: middle - 8, y: topHeight))
            path.addQuadCurve(
                to: CGPoint(x: middle + 4, y: topHeight - 8),
                controlPoint: CGPoint(x: middle, y: topHeight)
            )
            path.addLine(to: CGPoint(x: width - shoulder - 15, y: 9))
            path.addQuadCurve(
                to: CGPoint(x: width - shoulder, y: 0),
                controlPoint: CGPoint(x: width - shoulder - 9, y: 0)
            )
            path.addLine(to: CGPoint(x: width - radius, y: 0))
            path.addQuadCurve(to: CGPoint(x: width, y: radius), controlPoint: CGPoint(x: width, y: 0))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()
        return path
    }
}

/// Swift 页面使用的十六进制颜色快捷构造。
private extension UIColor {

    /// 从 24 位 RGB 数值创建不透明颜色。
    /// - Parameter hex: 例如 0x6C63FF。
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
