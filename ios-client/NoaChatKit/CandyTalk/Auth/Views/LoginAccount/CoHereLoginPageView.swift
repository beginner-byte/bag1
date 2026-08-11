//
//  CoHereLoginPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/27.
//

import UIKit

/// 登录页的 Swift 可视层，负责呈现 Figma 布局、保存各登录方式的输入草稿并转发交互事件。
@objc(CoHereLoginPageView)
final class CoHereLoginPageView: UIView, UITextFieldDelegate, UITextViewDelegate {

    /// 点击登录按钮后的业务回调。
    @objc var onLoginTap: (() -> Void)?

    /// 点击注册入口后的业务回调。
    @objc var onRegisterTap: (() -> Void)?

    /// 点击验证码登录入口后的业务回调。
    @objc var onVerificationLoginTap: (() -> Void)?

    /// 点击忘记密码入口后的业务回调。
    @objc var onForgotPasswordTap: (() -> Void)?

    /// 点击手机区号后的业务回调。
    @objc var onAreaCodeTap: (() -> Void)?

    /// 点击图文验证码刷新按钮后的业务回调。
    @objc var onCaptchaRefreshTap: (() -> Void)?

    /// 点击邀请码设置入口后的业务回调。
    @objc var onInviteTap: (() -> Void)?

    /// 点击用户协议后的业务回调。
    @objc var onUserAgreementTap: (() -> Void)?

    /// 点击隐私协议后的业务回调。
    @objc var onPrivacyAgreementTap: (() -> Void)?

    /// 切换登录方式后的业务回调，参数依次为登录枚举值和页签下标。
    @objc var onLoginTypeChanged: ((Int, Int) -> Void)?

    /// 当前是否已同意登录协议，由业务层在登录前读取或更新。
    @objc private(set) var policyAccepted = false

    /// 当前展示的登录枚举值；0 手机号、1 邮箱、2 账号。
    @objc private(set) var currentLoginType = 2

    /// 当前登录方式对应的手机区号，通过手机号图标入口修改。
    private var areaCode = "+86"

    /// 每种登录方式独立保存的输入草稿，避免切换页签时互相覆盖。
    private var drafts: [Int: LoginDraft] = [:]

    /// 当前登录方式是否需要展示图文验证码。
    private var captchaVisibility: [Int: Bool] = [:]

    /// 当前登录方式对应的图文验证码展示文本。
    private var captchaTexts: [Int: String] = [:]

    /// 后端配置下发的页签标题。
    private var loginTitles: [String] = []

    /// 与页签标题顺序一致的登录枚举值。
    private var loginTypes: [Int] = []

    /// 页签按钮集合，用于切换选中样式。
    private var tabButtons: [UIButton] = []

    /// 页面底层渐变头图。
    private let headerView = CoHereAuthGradientView(
        colors: [UIColor(coHereHex: 0x6C63FF), UIColor(coHereHex: 0x7835E7)]
    )

    /// Figma 导出的右上星点装饰。
    private let headerDecorationView = UIImageView(image: UIImage(named: "login_header_decoration"))

    /// Figma 登录稿中的全屏星点装饰。
    private let headerStarsView = CoHereAuthHeaderStarsView()

    /// Figma 导出的月光语图标光晕与白色底座。
    private let logoGlowView = UIImageView(image: UIImage(named: "login_logo_glow"))

    /// Figma 导出的月光语品牌图标内容。
    private let logoView = UIImageView(image: UIImage(named: "login_logo"))

    /// 邀请码设置入口。
    private let inviteButton = UIButton(type: .custom)

    /// 品牌英文副标题。
    private let brandLabel = UILabel()

    /// 页面主标题。
    private let welcomeLabel = UILabel()

    /// 欢迎标题下方的渐隐线和三个圆点。
    private let headerDividerView = CoHereAuthHeaderDividerView()

    /// 白色内容卡片。
    private let contentCard = UIView()

    /// 内容滚动容器，保证小屏真机和键盘弹出时仍可访问底部内容。
    private let scrollView = UIScrollView()

    /// 滚动容器内承载布局约束的视图。
    private let scrollContentView = UIView()

    /// 登录方式页签容器。
    private let tabsStackView = UIStackView()

    /// 页签底部分隔线。
    private let tabsDivider = UIView()

    /// 页签选中指示线。
    private let tabIndicator = UIView()

    /// 指示线与当前选中页签按钮保持水平居中的动态约束。
    private var tabIndicatorCenterXConstraint: NSLayoutConstraint?

    /// 账号、手机号或邮箱输入容器。
    private let identityField = CoHereAuthFieldView()

    /// 密码输入容器。
    private let passwordField = CoHereAuthFieldView()

    /// 图文验证码输入容器。
    private let captchaField = CoHereAuthFieldView()

    /// 图文验证码容器高度，隐藏时会被更新为 0。
    private var captchaHeightConstraint: NSLayoutConstraint?

    /// 图文验证码与密码输入框之间的间距，隐藏时会被更新为 0。
    private var captchaTopConstraint: NSLayoutConstraint?

    /// 覆盖手机号图标的透明区号按钮，仅在手机号方式下响应。
    private let areaCodeButton = UIButton(type: .custom)

    /// 密码可见状态按钮。
    private let passwordVisibilityButton = UIButton(type: .custom)

    /// 验证码登录入口，仅手机号和邮箱方式展示。
    private let verificationLoginButton = UIButton(type: .custom)

    /// 忘记密码入口。
    private let forgotPasswordButton = UIButton(type: .custom)

    /// Figma 渐变登录按钮。
    private let loginButton = CoHereAuthGradientButton()

    /// 登录按钮内居中的文字与箭头容器。
    private let loginContentStack = UIStackView()

    /// 登录按钮文字，和箭头作为一个整体居中。
    private let loginTitleLabel = UILabel()

    /// Figma 导出的登录箭头。
    private let loginArrowView = UIImageView(image: UIImage(named: "login_submit_arrow"))

    /// 协议勾选按钮。
    private let policyButton = UIButton(type: .custom)

    /// 协议说明及可点击链接。
    private let policyTextView = UITextView()

    /// 注册提示文字。
    private let registerPrefixLabel = UILabel()

    /// 注册入口。
    private let registerButton = UIButton(type: .custom)

    /// 版本信息。
    private let versionLabel = UILabel()

    /// 初始化登录页并创建全部 Figma 可视组件。
    /// - Parameter frame: 初始视图区域，后续由 Auto Layout 更新。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
        observeKeyboard()
    }

    /// Storyboard 初始化当前未使用。
    /// - Parameter coder: 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupActions()
        observeKeyboard()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 根据后端支持项配置页签，并选中指定下标。
    /// - Parameters:
    ///   - titles: 本地化后的页签标题。
    ///   - types: 与标题顺序一致的登录枚举值。
    ///   - selectedIndex: 首次选中的页签下标，越界时回退到第一个。
    @objc(configureWithTitles:loginTypes:selectedIndex:)
    func configure(titles: [String], loginTypes types: [NSNumber], selectedIndex: Int) {
        saveCurrentDraft()
        loginTitles = titles
        loginTypes = types.map(\.intValue)
        rebuildTabs()

        guard !loginTypes.isEmpty else {
            return
        }
        let safeIndex = loginTypes.indices.contains(selectedIndex) ? selectedIndex : 0
        applyLoginType(at: safeIndex, notifyBusiness: false)
    }

    /// 更新手机登录显示的区号。
    /// - Parameter newAreaCode: 包含加号的完整区号，例如 +86。
    @objc(setAreaCodeText:)
    func setAreaCodeText(_ newAreaCode: String) {
        areaCode = newAreaCode
        areaCodeButton.accessibilityValue = newAreaCode
    }

    /// 更新版本文字。
    /// - Parameter text: 业务层生成的版本号与构建号。
    @objc(setVersionText:)
    func setVersionText(_ text: String) {
        versionLabel.text = text
    }

    /// 更新指定登录方式的图文验证码展示状态和图片文字。
    /// - Parameters:
    ///   - visible: 是否展示验证码输入框。
    ///   - text: 服务端返回的验证码字符，可为空。
    ///   - loginType: 对应登录枚举值。
    @objc(setCaptchaVisible:text:loginType:)
    func setCaptchaVisible(_ visible: Bool, text: String?, loginType: Int) {
        captchaVisibility[loginType] = visible
        if let text {
            captchaTexts[loginType] = text
        }
        if loginType == currentLoginType {
            updateCaptchaPresentation()
        }
    }

    /// 更新协议勾选状态。
    /// - Parameter accepted: YES 表示用户已同意协议。
    @objc(updatePolicyAccepted:)
    func updatePolicyAccepted(_ accepted: Bool) {
        policyAccepted = accepted
        updatePolicyButtonImage()
    }

    /// 返回指定登录方式的账号、密码和图文验证码输入值。
    /// - Parameter loginType: 登录枚举值。
    /// - Returns: 固定包含 identity、password、captcha 三个键的字典。
    @objc(textValuesForLoginType:)
    func textValues(for loginType: Int) -> [String: String] {
        if loginType == currentLoginType {
            saveCurrentDraft()
        }
        let draft = drafts[loginType] ?? LoginDraft()
        return [
            "identity": draft.identity,
            "password": draft.password,
            "captcha": draft.captcha
        ]
    }

    /// 结束页面内所有输入状态。
    @objc func endInputEditing() {
        endEditing(true)
    }

    /// 页面布局完成后更新渐变、圆角和选中指示线位置。
    override func layoutSubviews() {
        super.layoutSubviews()
        contentCard.layer.cornerRadius = 16
        contentCard.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        updateTabIndicator(animated: false)
    }

    /// 创建与 Figma 登录稿一致的视图层级和约束。
    private func setupView() {
        backgroundColor = .white
        layer.zPosition = 2_001
        setupHeader()
        setupContentCard()
        setupTabs()
        setupInputFields()
        setupActionButtons()
        setupPolicy()
        setupFooter()
    }

    /// 创建紫色渐变头部、品牌图标、邀请码入口和欢迎标题。
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        // 真机首次合成渐变层前先显示同色底，避免旧登录基类背景短暂透出。
        headerView.backgroundColor = UIColor(coHereHex: 0x6C63FF)
        addSubview(headerView)

        headerDecorationView.translatesAutoresizingMaskIntoConstraints = false
        headerDecorationView.contentMode = .scaleAspectFit
        headerDecorationView.alpha = 0.72
        headerView.addSubview(headerDecorationView)

        headerStarsView.translatesAutoresizingMaskIntoConstraints = false
        headerStarsView.backgroundColor = .clear
        headerStarsView.isOpaque = false
        headerStarsView.isUserInteractionEnabled = false
        headerView.addSubview(headerStarsView)

        logoGlowView.translatesAutoresizingMaskIntoConstraints = false
        logoGlowView.contentMode = .scaleAspectFit
        logoGlowView.isUserInteractionEnabled = false
        headerView.addSubview(logoGlowView)

        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.contentMode = .scaleAspectFill
        logoView.clipsToBounds = true
        logoView.layer.cornerRadius = 4
        headerView.addSubview(logoView)

        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.setTitle(localized("设置邀请码"), for: .normal)
        inviteButton.setTitleColor(.white, for: .normal)
        inviteButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        inviteButton.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        inviteButton.layer.cornerRadius = 16
        inviteButton.layer.borderWidth = 1
        inviteButton.layer.borderColor = UIColor.white.withAlphaComponent(0.32).cgColor
        headerView.addSubview(inviteButton)

        brandLabel.translatesAutoresizingMaskIntoConstraints = false
        brandLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        brandLabel.font = .systemFont(ofSize: 10.5, weight: .medium)
        brandLabel.attributedText = attributedBrandText()
        headerView.addSubview(brandLabel)

        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.text = localized("你好，欢迎回来") + " ✨"
        welcomeLabel.textColor = .white
        welcomeLabel.font = .systemFont(ofSize: 26, weight: .semibold)
        headerView.addSubview(welcomeLabel)

        headerDividerView.translatesAutoresizingMaskIntoConstraints = false
        headerDividerView.backgroundColor = .clear
        headerDividerView.isOpaque = false
        headerDividerView.isUserInteractionEnabled = false
        headerView.addSubview(headerDividerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 252),

            headerDecorationView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 4),
            headerDecorationView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 35),
            headerDecorationView.widthAnchor.constraint(equalToConstant: 130),
            headerDecorationView.heightAnchor.constraint(equalToConstant: 140),

            headerStarsView.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerStarsView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerStarsView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerStarsView.heightAnchor.constraint(equalToConstant: 212),

            logoGlowView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 36),
            logoGlowView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            logoGlowView.widthAnchor.constraint(equalToConstant: 132),
            logoGlowView.heightAnchor.constraint(equalToConstant: 132),

            logoView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 68),
            logoView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 44),
            logoView.heightAnchor.constraint(equalToConstant: 44),

            inviteButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 88),
            inviteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            inviteButton.widthAnchor.constraint(equalToConstant: 86),
            inviteButton.heightAnchor.constraint(equalToConstant: 32),

            brandLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 132),
            brandLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            welcomeLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 164),
            welcomeLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            headerDividerView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 206),
            headerDividerView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerDividerView.widthAnchor.constraint(equalToConstant: 200),
            headerDividerView.heightAnchor.constraint(equalToConstant: 6)
        ])
    }

    /// 创建覆盖头部下缘的白色圆角内容卡片和滚动区域。
    private func setupContentCard() {
        contentCard.translatesAutoresizingMaskIntoConstraints = false
        contentCard.backgroundColor = .white
        contentCard.layer.masksToBounds = true
        addSubview(contentCard)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        contentCard.addSubview(scrollView)

        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollContentView)

        NSLayoutConstraint.activate([
            contentCard.topAnchor.constraint(equalTo: topAnchor, constant: 236),
            contentCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentCard.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentCard.bottomAnchor.constraint(equalTo: bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: contentCard.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentCard.bottomAnchor),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            scrollContentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    /// 创建动态登录方式页签、底部分隔线和选中指示线。
    private func setupTabs() {
        tabsStackView.translatesAutoresizingMaskIntoConstraints = false
        tabsStackView.axis = .horizontal
        tabsStackView.distribution = .fillEqually
        scrollContentView.addSubview(tabsStackView)

        tabsDivider.translatesAutoresizingMaskIntoConstraints = false
        tabsDivider.backgroundColor = UIColor(coHereHex: 0xEEF0F6)
        scrollContentView.addSubview(tabsDivider)

        tabIndicator.translatesAutoresizingMaskIntoConstraints = false
        tabIndicator.backgroundColor = UIColor(coHereHex: 0x6C63FF)
        tabIndicator.layer.cornerRadius = 1.5
        scrollContentView.addSubview(tabIndicator)

        NSLayoutConstraint.activate([
            tabsStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            tabsStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            tabsStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            tabsStackView.heightAnchor.constraint(equalToConstant: 48),

            tabsDivider.topAnchor.constraint(equalTo: tabsStackView.bottomAnchor),
            tabsDivider.leadingAnchor.constraint(equalTo: tabsStackView.leadingAnchor),
            tabsDivider.trailingAnchor.constraint(equalTo: tabsStackView.trailingAnchor),
            tabsDivider.heightAnchor.constraint(equalToConstant: 1),

            tabIndicator.topAnchor.constraint(equalTo: tabsStackView.topAnchor, constant: 42),
            tabIndicator.widthAnchor.constraint(equalToConstant: 56),
            tabIndicator.heightAnchor.constraint(equalToConstant: 3)
        ])
    }

    /// 创建身份、密码和图文验证码输入区域。
    private func setupInputFields() {
        [identityField, passwordField, captchaField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollContentView.addSubview($0)
        }

        identityField.textField.delegate = self
        identityField.textField.returnKeyType = .next
        identityField.textField.addTarget(self, action: #selector(inputTextChanged), for: .editingChanged)

        areaCodeButton.translatesAutoresizingMaskIntoConstraints = false
        areaCodeButton.isHidden = true
        areaCodeButton.accessibilityLabel = localized("选择国家和地区")
        identityField.addSubview(areaCodeButton)

        passwordField.configure(
            icon: UIImage(named: "login_password"),
            placeholder: localized("请输入密码")
        )
        passwordField.textField.delegate = self
        passwordField.textField.isSecureTextEntry = true
        passwordField.textField.returnKeyType = .done
        passwordField.textField.addTarget(self, action: #selector(inputTextChanged), for: .editingChanged)
        passwordField.setTrailingView(passwordVisibilityButton, width: 48)

        passwordVisibilityButton.setImage(UIImage(named: "login_eye_hidden"), for: .normal)
        passwordVisibilityButton.setImage(UIImage(named: "login_eye_visible"), for: .selected)
        passwordVisibilityButton.accessibilityLabel = localized("显示密码")

        captchaField.configure(icon: UIImage(named: "login_account"), placeholder: localized("验证码"))
        captchaField.textField.delegate = self
        captchaField.textField.returnKeyType = .done
        captchaField.textField.addTarget(self, action: #selector(inputTextChanged), for: .editingChanged)

        let captchaPreview = CoHereAuthCaptchaPreviewButton()
        captchaPreview.translatesAutoresizingMaskIntoConstraints = false
        captchaPreview.addTarget(self, action: #selector(captchaRefreshTapped), for: .touchUpInside)
        captchaField.setTrailingView(captchaPreview, width: 96)
        captchaField.captchaPreviewButton = captchaPreview

        let captchaTop = captchaField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 18)
        let captchaHeight = captchaField.heightAnchor.constraint(equalToConstant: 0)
        captchaTopConstraint = captchaTop
        captchaHeightConstraint = captchaHeight

        NSLayoutConstraint.activate([
            identityField.topAnchor.constraint(equalTo: tabsDivider.bottomAnchor, constant: 20),
            identityField.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            identityField.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            identityField.heightAnchor.constraint(equalToConstant: 48),

            areaCodeButton.topAnchor.constraint(equalTo: identityField.topAnchor),
            areaCodeButton.leadingAnchor.constraint(equalTo: identityField.leadingAnchor),
            areaCodeButton.bottomAnchor.constraint(equalTo: identityField.bottomAnchor),
            areaCodeButton.widthAnchor.constraint(equalToConstant: 60),

            passwordField.topAnchor.constraint(equalTo: identityField.bottomAnchor, constant: 18),
            passwordField.leadingAnchor.constraint(equalTo: identityField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: identityField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 48),

            captchaTop,
            captchaField.leadingAnchor.constraint(equalTo: identityField.leadingAnchor),
            captchaField.trailingAnchor.constraint(equalTo: identityField.trailingAnchor),
            captchaHeight
        ])
    }

    /// 创建辅助操作行、渐变登录按钮，并保持 Figma 的间距关系。
    private func setupActionButtons() {
        verificationLoginButton.translatesAutoresizingMaskIntoConstraints = false
        verificationLoginButton.setTitle(localized("验证码登录"), for: .normal)
        verificationLoginButton.setTitleColor(UIColor(coHereHex: 0x6C63FF), for: .normal)
        verificationLoginButton.titleLabel?.font = .systemFont(ofSize: 14)
        scrollContentView.addSubview(verificationLoginButton)

        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.setTitle(localized("忘记密码") + "?", for: .normal)
        forgotPasswordButton.setTitleColor(UIColor(coHereHex: 0x6C63FF), for: .normal)
        forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 14)
        scrollContentView.addSubview(forgotPasswordButton)

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.accessibilityLabel = localized("登录")
        loginButton.layer.cornerRadius = 8
        loginButton.layer.masksToBounds = true
        scrollContentView.addSubview(loginButton)

        loginContentStack.translatesAutoresizingMaskIntoConstraints = false
        loginContentStack.axis = .horizontal
        loginContentStack.alignment = .center
        loginContentStack.spacing = 8
        loginContentStack.isUserInteractionEnabled = false
        loginButton.addSubview(loginContentStack)

        loginTitleLabel.text = localized("登录")
        loginTitleLabel.textColor = .white
        loginTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        loginContentStack.addArrangedSubview(loginTitleLabel)

        loginArrowView.contentMode = .scaleAspectFit
        loginContentStack.addArrangedSubview(loginArrowView)

        NSLayoutConstraint.activate([
            verificationLoginButton.topAnchor.constraint(equalTo: captchaField.bottomAnchor, constant: 8),
            verificationLoginButton.leadingAnchor.constraint(equalTo: identityField.leadingAnchor),
            verificationLoginButton.heightAnchor.constraint(equalToConstant: 32),

            forgotPasswordButton.centerYAnchor.constraint(equalTo: verificationLoginButton.centerYAnchor),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: identityField.trailingAnchor),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 32),

            loginButton.topAnchor.constraint(equalTo: verificationLoginButton.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: identityField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: identityField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48),

            loginContentStack.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            loginContentStack.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            loginArrowView.widthAnchor.constraint(equalToConstant: 16),
            loginArrowView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    /// 创建协议勾选区域，并通过 UITextView 链接保持两项协议可独立点击。
    private func setupPolicy() {
        policyButton.translatesAutoresizingMaskIntoConstraints = false
        policyButton.layer.cornerRadius = 3
        policyButton.layer.borderWidth = 1
        policyButton.layer.borderColor = UIColor(coHereHex: 0xD7DAE2).cgColor
        scrollContentView.addSubview(policyButton)

        policyTextView.translatesAutoresizingMaskIntoConstraints = false
        policyTextView.backgroundColor = .clear
        policyTextView.delegate = self
        policyTextView.isEditable = false
        policyTextView.isScrollEnabled = false
        policyTextView.textContainerInset = .zero
        policyTextView.textContainer.lineFragmentPadding = 0
        policyTextView.linkTextAttributes = [
            .foregroundColor: UIColor(coHereHex: 0x6C63FF)
        ]
        policyTextView.attributedText = policyAttributedText()
        scrollContentView.addSubview(policyTextView)

        NSLayoutConstraint.activate([
            policyButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 15),
            policyButton.leadingAnchor.constraint(equalTo: identityField.leadingAnchor),
            policyButton.widthAnchor.constraint(equalToConstant: 16),
            policyButton.heightAnchor.constraint(equalToConstant: 16),

            policyTextView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 14),
            policyTextView.leadingAnchor.constraint(equalTo: policyButton.trailingAnchor, constant: 7),
            policyTextView.trailingAnchor.constraint(equalTo: identityField.trailingAnchor),
            policyTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 22)
        ])
    }

    /// 创建底部注册入口与版本号，并让其在高屏底部对齐、小屏随内容滚动。
    private func setupFooter() {
        registerPrefixLabel.translatesAutoresizingMaskIntoConstraints = false
        registerPrefixLabel.text = localized("没有账号？")
        registerPrefixLabel.textColor = UIColor(coHereHex: 0x333333)
        registerPrefixLabel.font = .systemFont(ofSize: 14)
        scrollContentView.addSubview(registerPrefixLabel)

        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle(localized("立即注册"), for: .normal)
        registerButton.setTitleColor(UIColor(coHereHex: 0x6C63FF), for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        scrollContentView.addSubview(registerButton)

        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.textColor = UIColor(coHereHex: 0xBBBBC8)
        versionLabel.font = .systemFont(ofSize: 11)
        versionLabel.textAlignment = .center
        scrollContentView.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            registerPrefixLabel.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor),
            registerPrefixLabel.trailingAnchor.constraint(equalTo: scrollContentView.centerXAnchor, constant: 2),

            registerButton.topAnchor.constraint(greaterThanOrEqualTo: policyTextView.bottomAnchor, constant: 32),
            registerButton.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -22),
            registerButton.leadingAnchor.constraint(equalTo: registerPrefixLabel.trailingAnchor, constant: 6),
            registerButton.heightAnchor.constraint(equalToConstant: 32),

            versionLabel.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.bottomAnchor, constant: -2),
            versionLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    /// 绑定页面内控件事件，业务行为通过公开闭包交给 Objective-C 协调层。
    private func setupActions() {
        inviteButton.addTarget(self, action: #selector(inviteTapped), for: .touchUpInside)
        passwordVisibilityButton.addTarget(self, action: #selector(passwordVisibilityTapped), for: .touchUpInside)
        verificationLoginButton.addTarget(self, action: #selector(verificationLoginTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        policyButton.addTarget(self, action: #selector(policyTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        areaCodeButton.addTarget(self, action: #selector(areaCodeTapped), for: .touchUpInside)
    }

    /// 监听键盘高度变化并调整滚动区域，避免输入框被遮挡。
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 根据当前后端配置重新创建页签按钮。
    private func rebuildTabs() {
        tabButtons.forEach {
            tabsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        tabButtons = loginTitles.enumerated().map { index, title in
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            tabsStackView.addArrangedSubview(button)
            return button
        }
        tabIndicator.isHidden = tabButtons.isEmpty
    }

    /// 切换到指定页签，恢复对应输入草稿并刷新视觉状态。
    /// - Parameters:
    ///   - index: 登录方式页签下标。
    ///   - notifyBusiness: 是否向 Objective-C 协调层发送切换事件。
    private func applyLoginType(at index: Int, notifyBusiness: Bool) {
        guard loginTypes.indices.contains(index) else {
            return
        }
        saveCurrentDraft()
        currentLoginType = loginTypes[index]

        tabButtons.enumerated().forEach { buttonIndex, button in
            let isSelected = buttonIndex == index
            button.setTitleColor(
                isSelected ? UIColor(coHereHex: 0x6C63FF) : UIColor(coHereHex: 0x9CA3AF),
                for: .normal
            )
            button.titleLabel?.font = .systemFont(
                ofSize: 16,
                weight: isSelected ? .medium : .regular
            )
        }

        updateIdentityPresentation()
        restoreCurrentDraft()
        updateCaptchaPresentation()
        updateTabIndicator(animated: notifyBusiness)

        if notifyBusiness {
            onLoginTypeChanged?(currentLoginType, index)
        }
    }

    /// 根据当前登录方式更新首个输入框图标、键盘和手机区号。
    private func updateIdentityPresentation() {
        switch currentLoginType {
        case 0:
            identityField.configure(icon: UIImage(named: "login_phone"), placeholder: localized("请输入手机号"))
            identityField.textField.keyboardType = .phonePad
            identityField.setPrefixView(nil, width: 0)
            areaCodeButton.isHidden = false
            verificationLoginButton.isHidden = false
        case 1:
            identityField.configure(icon: UIImage(named: "login_email"), placeholder: localized("请输入邮箱"))
            identityField.textField.keyboardType = .emailAddress
            identityField.setPrefixView(nil, width: 0)
            areaCodeButton.isHidden = true
            verificationLoginButton.isHidden = false
        default:
            identityField.configure(icon: UIImage(named: "login_account"), placeholder: localized("请输入账号"))
            identityField.textField.keyboardType = .default
            identityField.setPrefixView(nil, width: 0)
            areaCodeButton.isHidden = true
            verificationLoginButton.isHidden = true
        }
        forgotPasswordButton.isHidden = false
    }

    /// 根据当前登录方式更新图文验证码输入区域的高度和预览文字。
    private func updateCaptchaPresentation() {
        let visible = captchaVisibility[currentLoginType] ?? false
        captchaField.isHidden = !visible
        captchaHeightConstraint?.constant = visible ? 48 : 0
        captchaTopConstraint?.constant = visible ? 18 : 0
        captchaField.captchaPreviewButton?.captchaText = captchaTexts[currentLoginType] ?? ""
    }

    /// 将当前文本框内容保存到对应登录方式草稿。
    private func saveCurrentDraft() {
        guard !loginTypes.isEmpty else {
            return
        }
        drafts[currentLoginType] = LoginDraft(
            identity: identityField.textField.text ?? "",
            password: passwordField.textField.text ?? "",
            captcha: captchaField.textField.text ?? ""
        )
    }

    /// 恢复当前登录方式的输入草稿。
    private func restoreCurrentDraft() {
        let draft = drafts[currentLoginType] ?? LoginDraft()
        identityField.textField.text = draft.identity
        passwordField.textField.text = draft.password
        captchaField.textField.text = draft.captcha
    }

    /// 更新页签选中指示线的位置。
    /// - Parameter animated: YES 时以短动画跟随页签切换。
    private func updateTabIndicator(animated: Bool) {
        guard
            let selectedIndex = loginTypes.firstIndex(of: currentLoginType),
            tabButtons.indices.contains(selectedIndex)
        else {
            return
        }

        if animated {
            layoutIfNeeded()
        }
        tabIndicatorCenterXConstraint?.isActive = false
        let centerXConstraint = tabIndicator.centerXAnchor.constraint(
            equalTo: tabButtons[selectedIndex].centerXAnchor
        )
        tabIndicatorCenterXConstraint = centerXConstraint
        centerXConstraint.isActive = true

        let updates = {
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: updates)
        } else {
            updates()
        }
    }

    /// 更新协议选择图标和边框样式。
    private func updatePolicyButtonImage() {
        policyButton.setImage(
            policyAccepted ? UIImage(named: "login_checkbox_selected") : nil,
            for: .normal
        )
        policyButton.layer.borderWidth = policyAccepted ? 0 : 1
    }

    /// 构造带字间距的品牌副标题。
    /// - Returns: 可直接显示的品牌富文本。
    private func attributedBrandText() -> NSAttributedString {
        NSAttributedString(
            string: "月光语 · YUEGUANGYU",
            attributes: [
                .kern: 2.4,
                .foregroundColor: UIColor.white.withAlphaComponent(0.75),
                .font: UIFont.systemFont(ofSize: 10.5, weight: .medium)
            ]
        )
    }

    /// 构造包含用户协议与隐私协议链接的登录说明。
    /// - Returns: 可点击的协议富文本。
    private func policyAttributedText() -> NSAttributedString {
        let prefix = localized("我已阅读并同意")
        let userAgreement = localized("《用户协议》")
        let conjunction = localized("和")
        let privacyAgreement = localized("《隐私协议》")
        let fullText = "\(prefix)\(userAgreement)\(conjunction)\(privacyAgreement)"
        let result = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor(coHereHex: 0x35404E)
            ]
        )
        if let range = fullText.range(of: userAgreement) {
            result.addAttribute(.link, value: "noa-login://user-agreement", range: NSRange(range, in: fullText))
        }
        if let range = fullText.range(of: privacyAgreement) {
            result.addAttribute(.link, value: "noa-login://privacy-agreement", range: NSRange(range, in: fullText))
        }
        return result
    }

    /// 使用项目语言管理器获取本地化文本。
    /// - Parameter key: Localizable.strings 中的中文键。
    /// - Returns: 当前语言对应的显示文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }

    /// 处理页签点击并通知业务层。
    /// - Parameter sender: 被点击的页签按钮。
    @objc private func tabTapped(_ sender: UIButton) {
        applyLoginType(at: sender.tag, notifyBusiness: true)
    }

    /// 保存输入变化，确保业务层随时可以取得当前文本。
    @objc private func inputTextChanged() {
        saveCurrentDraft()
    }

    /// 切换密码明文与密文显示。
    @objc private func passwordVisibilityTapped() {
        passwordVisibilityButton.isSelected.toggle()
        passwordField.textField.isSecureTextEntry = !passwordVisibilityButton.isSelected
    }

    /// 转发登录点击，并先收起键盘和保存草稿。
    @objc private func loginTapped() {
        saveCurrentDraft()
        endEditing(true)
        onLoginTap?()
    }

    /// 切换协议同意状态。
    @objc private func policyTapped() {
        updatePolicyAccepted(!policyAccepted)
    }

    /// 转发注册入口点击。
    @objc private func registerTapped() {
        onRegisterTap?()
    }

    /// 转发验证码登录入口点击。
    @objc private func verificationLoginTapped() {
        saveCurrentDraft()
        onVerificationLoginTap?()
    }

    /// 转发忘记密码入口点击。
    @objc private func forgotPasswordTapped() {
        saveCurrentDraft()
        onForgotPasswordTap?()
    }

    /// 转发手机区号入口点击。
    @objc private func areaCodeTapped() {
        onAreaCodeTap?()
    }

    /// 转发邀请码设置入口点击。
    @objc private func inviteTapped() {
        onInviteTap?()
    }

    /// 转发图文验证码刷新入口点击。
    @objc private func captchaRefreshTapped() {
        onCaptchaRefreshTap?()
    }

    /// 根据键盘最终位置调整滚动区域底部留白。
    /// - Parameter notification: 包含键盘最终 frame 的系统通知。
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let window
        else {
            return
        }
        let keyboardFrame = window.convert(value.cgRectValue, to: self)
        let overlap = max(0, bounds.maxY - keyboardFrame.minY)
        scrollView.contentInset.bottom = overlap
        scrollView.verticalScrollIndicatorInsets.bottom = overlap
    }

    /// 键盘隐藏后移除滚动区域的额外留白。
    /// - Parameter notification: 键盘隐藏通知，参数仅用于统一通知签名。
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    /// 处理键盘 Return 键：首个输入框跳到密码，其他输入框收起键盘。
    /// - Parameter textField: 当前响应 Return 键的输入框。
    /// - Returns: YES 表示系统可继续处理 Return 键。
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === identityField.textField {
            passwordField.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    /// 拦截协议文本链接并转发到现有原生协议页面。
    /// - Parameters:
    ///   - textView: 协议文本控件。
    ///   - URL: 被点击的内部链接。
    ///   - characterRange: 点击字符范围。
    ///   - interaction: 系统识别的交互类型。
    /// - Returns: NO，阻止系统尝试打开内部 URL。
    @available(iOS 10.0, *)
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        if URL.host == "user-agreement" {
            onUserAgreementTap?()
        } else if URL.host == "privacy-agreement" {
            onPrivacyAgreementTap?()
        }
        return false
    }
}

/// 单个登录方式的输入草稿。
private struct LoginDraft {
    /// 账号、手机号或邮箱。
    var identity = ""

    /// 登录密码。
    var password = ""

    /// 图文验证码。
    var captcha = ""
}
