//
//  CoHereRegisterPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/28.
//

import UIKit

/// CoHere 注册页的 Swift 可视层，负责呈现三个 Figma 注册状态并保存各注册方式的输入草稿。
final class CoHereRegisterPageView: UIView, UITextFieldDelegate, UITextViewDelegate {

    /// 点击注册按钮后的业务回调。
    var onRegisterTap: (() -> Void)?

    /// 点击获取验证码后的业务回调。
    var onVerificationCodeTap: (() -> Void)?

    /// 点击手机区号区域后的业务回调。
    var onAreaCodeTap: (() -> Void)?

    /// 点击已有账号入口后的业务回调。
    var onLoginTap: (() -> Void)?

    /// 点击用户协议后的业务回调。
    var onUserAgreementTap: (() -> Void)?

    /// 点击隐私协议后的业务回调。
    var onPrivacyAgreementTap: (() -> Void)?

    /// 切换注册方式后的业务回调，参数为注册类型原始值。
    var onRegisterTypeChanged: ((Int) -> Void)?

    /// 当前是否已同意注册协议。
    private(set) var policyAccepted = false

    /// 当前展示的注册类型原始值；0 手机号、1 邮箱、2 账号。
    private(set) var currentRegisterType = 2

    /// 当前手机号注册使用的国家或地区区号。
    private var areaCode = "+86"

    /// 后端是否要求注册时填写邀请码。
    private var inviteCodeRequired = false

    /// 各注册方式独立保存的输入草稿。
    private var drafts: [Int: RegisterDraft] = [:]

    /// 与页签标题顺序一致的注册类型原始值。
    private var registerTypes: [Int] = []

    /// 手机号和邮箱注册各自剩余的验证码倒计时秒数。
    private var verificationCountdownSeconds: [Int: Int] = [:]

    /// 手机号和邮箱注册各自使用的验证码倒计时计时器。
    private var verificationCountdownTimers: [Int: Timer] = [:]

    /// 页签按钮集合，用于切换选中视觉状态。
    private var tabButtons: [UIButton] = []

    /// 页面底层紫色渐变头图。
    private let headerView = CoHereAuthGradientView(
        colors: [UIColor(coHereHex: 0x6C63FF), UIColor(coHereHex: 0x7835E7)]
    )

    /// Figma 右上角渐变装饰。
    private let headerDecorationView = UIImageView(image: UIImage(named: "login_header_decoration"))

    /// Figma 头部星点装饰。
    private let headerStarsView = CoHereAuthHeaderStarsView()

    /// 月光语图标光晕。
    private let logoGlowView = UIImageView(image: UIImage(named: "login_logo_glow"))

    /// 月光语品牌图标。
    private let logoView = UIImageView(image: UIImage(named: "login_logo"))

    /// 品牌英文副标题。
    private let brandLabel = UILabel()

    /// 注册欢迎标题。
    private let welcomeLabel = UILabel()

    /// 欢迎标题下方的渐隐线和圆点。
    private let headerDividerView = CoHereAuthHeaderDividerView()

    /// 白色圆角内容卡片。
    private let contentCard = UIView()

    /// 表单滚动视图，兼容键盘和较小屏幕。
    private let scrollView = UIScrollView()

    /// 滚动视图内的 Auto Layout 内容容器。
    private let scrollContentView = UIView()

    /// 注册类型页签容器。
    private let tabsStackView = UIStackView()

    /// 页签底部分隔线。
    private let tabsDivider = UIView()

    /// 当前页签指示线。
    private let tabIndicator = UIView()

    /// 指示线相对页签容器左侧的动态约束。
    private var tabIndicatorLeadingConstraint: NSLayoutConstraint?

    /// 账号、手机号或邮箱输入框。
    private let identityField = CoHereAuthFieldView()

    /// 手机号或邮箱验证码输入框。
    private let verificationField = CoHereAuthFieldView()

    /// 设置密码输入框。
    private let passwordField = CoHereAuthFieldView()

    /// 确认密码输入框。
    private let confirmPasswordField = CoHereAuthFieldView()

    /// 后台强制邀请码时显示的邀请码输入框。
    private let inviteCodeField = CoHereAuthFieldView()

    /// 手机号模式下覆盖左侧图标的透明区号点击区域。
    private let areaCodeButton = UIButton(type: .custom)

    /// 获取验证码按钮。
    private let verificationCodeButton = UIButton(type: .custom)

    /// 设置密码显示或隐藏按钮。
    private let passwordVisibilityButton = UIButton(type: .custom)

    /// 确认密码显示或隐藏按钮。
    private let confirmPasswordVisibilityButton = UIButton(type: .custom)

    /// 密码格式提示。
    private let passwordHintLabel = UILabel()

    /// Figma 注册主按钮。
    private let registerButton = CoHereAuthGradientButton()

    /// 注册按钮中文字和箭头的组合容器。
    private let registerButtonContent = UIStackView()

    /// 注册按钮标题。
    private let registerButtonTitleLabel = UILabel()

    /// 注册按钮箭头。
    private let registerArrowView = UIImageView(image: UIImage(named: "login_submit_arrow"))

    /// 协议勾选按钮。
    private let policyButton = UIButton(type: .custom)

    /// 协议说明和两个可点击链接。
    private let policyTextView = UITextView()

    /// 已有账号提示。
    private let loginPrefixLabel = UILabel()

    /// 立即登录按钮。
    private let loginButton = UIButton(type: .custom)

    /// App 版本信息。
    private let versionLabel = UILabel()

    /// 表单字段纵向容器。
    private let fieldsStackView = UIStackView()

    /// 页签指示线宽度约束。
    private var tabIndicatorWidthConstraint: NSLayoutConstraint?

    /// 初始化注册页并创建 Figma 视图层级。
    /// - Parameter frame: 初始区域，最终由控制器约束为全屏。
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
        verificationCountdownTimers.values.forEach { $0.invalidate() }
        NotificationCenter.default.removeObserver(self)
    }

    /// 使用后端支持的注册方式配置页签和初始状态。
    /// - Parameters:
    ///   - titles: 与注册类型顺序一致的本地化标题。
    ///   - types: 注册类型原始值集合。
    ///   - initialType: 登录页当前方式对应的首选注册类型。
    ///   - requiresInviteCode: 后端是否要求填写注册邀请码。
    func configure(
        titles: [String],
        types: [Int],
        initialType: Int,
        requiresInviteCode: Bool
    ) {
        saveCurrentDraft()
        registerTypes = types
        inviteCodeRequired = requiresInviteCode
        rebuildTabs(titles: titles)

        guard !registerTypes.isEmpty else {
            return
        }
        let initialIndex = registerTypes.firstIndex(of: initialType) ?? 0
        applyRegisterType(at: initialIndex, notifyBusiness: false)
        updateRegisterButtonAvailability()
    }

    /// 回填登录页检测到的未注册账号。
    /// - Parameters:
    ///   - text: 未注册账号、手机号或邮箱。
    ///   - registerType: 该账号对应的注册类型原始值。
    func setPrefilledIdentity(_ text: String, registerType: Int) {
        guard !text.isEmpty else {
            return
        }
        var draft = drafts[registerType] ?? RegisterDraft()
        draft.identity = text
        drafts[registerType] = draft
        if currentRegisterType == registerType {
            identityField.textField.text = text
        }
    }

    /// 更新手机号注册使用的区号。
    /// - Parameter text: 包含加号的完整区号，例如 +86。
    func setAreaCode(_ text: String) {
        areaCode = text
        areaCodeButton.accessibilityValue = text
    }

    /// 更新版本显示文字。
    /// - Parameter text: App 版本号和构建号。
    func setVersionText(_ text: String) {
        versionLabel.text = text
    }

    /// 返回指定注册方式下的全部输入值。
    /// - Parameter registerType: 注册类型原始值。
    /// - Returns: 固定包含 identity、verificationCode、password、confirmPassword 和 inviteCode。
    func textValues(for registerType: Int) -> [String: String] {
        if currentRegisterType == registerType {
            saveCurrentDraft()
        }
        let draft = drafts[registerType] ?? RegisterDraft()
        return [
            "identity": draft.identity,
            "verificationCode": draft.verificationCode,
            "password": draft.password,
            "confirmPassword": draft.confirmPassword,
            "inviteCode": draft.inviteCode
        ]
    }

    /// 更新协议勾选状态。
    /// - Parameter accepted: true 表示用户已同意协议。
    func updatePolicyAccepted(_ accepted: Bool) {
        policyAccepted = accepted
        policyButton.setImage(
            accepted ? UIImage(named: "login_checkbox_selected") : nil,
            for: .normal
        )
        policyButton.layer.borderWidth = accepted ? 0 : 1
    }

    /// 为当前手机号或邮箱注册方式开始独立的 60 秒验证码倒计时。
    func startVerificationCodeCountdown() {
        let registerType = currentRegisterType
        guard
            registerType == 0 || registerType == 1,
            verificationCountdownTimers[registerType] == nil
        else {
            return
        }
        verificationCountdownSeconds[registerType] = 60
        refreshVerificationCountdownPresentation()

        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            let remainingSeconds = max(
                0,
                (self.verificationCountdownSeconds[registerType] ?? 0) - 1
            )
            if remainingSeconds == 0 {
                timer.invalidate()
                self.verificationCountdownSeconds.removeValue(forKey: registerType)
                self.verificationCountdownTimers.removeValue(forKey: registerType)
            } else {
                self.verificationCountdownSeconds[registerType] = remainingSeconds
            }
            self.refreshVerificationCountdownPresentation()
        }
        verificationCountdownTimers[registerType] = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    /// 结束页面内所有输入状态并保存当前草稿。
    func endInputEditing() {
        saveCurrentDraft()
        endEditing(true)
    }

    /// 布局完成后同步圆角和页签指示线位置。
    override func layoutSubviews() {
        super.layoutSubviews()
        contentCard.layer.cornerRadius = 16
        contentCard.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        updateTabIndicator(animated: false)
    }

    /// 创建注册页面全部视觉区域。
    private func setupView() {
        backgroundColor = .white
        setupHeader()
        setupContentCard()
        setupTabs()
        setupFields()
        setupRegisterAction()
        setupPolicy()
        setupFooter()
    }

    /// 创建紫色渐变头部、品牌图标和欢迎标题。
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
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
        headerView.addSubview(logoGlowView)

        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.contentMode = .scaleAspectFill
        logoView.clipsToBounds = true
        logoView.layer.cornerRadius = 4
        headerView.addSubview(logoView)

        brandLabel.translatesAutoresizingMaskIntoConstraints = false
        brandLabel.attributedText = attributedBrandText()
        headerView.addSubview(brandLabel)

        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.text = localized("欢迎加入") + " ✨"
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

    /// 创建覆盖头部下缘的白色圆角卡片和滚动区域。
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

    /// 创建三个等宽注册页签、分隔线和选中指示线。
    private func setupTabs() {
        tabsStackView.translatesAutoresizingMaskIntoConstraints = false
        tabsStackView.axis = .horizontal
        tabsStackView.distribution = .fillEqually
        scrollContentView.addSubview(tabsStackView)

        tabsDivider.translatesAutoresizingMaskIntoConstraints = false
        tabsDivider.backgroundColor = UIColor(coHereHex: 0xF3F4F6)
        scrollContentView.addSubview(tabsDivider)

        tabIndicator.translatesAutoresizingMaskIntoConstraints = false
        tabIndicator.backgroundColor = UIColor(coHereHex: 0x6C63FF)
        tabIndicator.layer.cornerRadius = 1.5
        scrollContentView.addSubview(tabIndicator)

        let leading = tabIndicator.leadingAnchor.constraint(equalTo: tabsStackView.leadingAnchor)
        let width = tabIndicator.widthAnchor.constraint(equalToConstant: 56)
        tabIndicatorLeadingConstraint = leading
        tabIndicatorWidthConstraint = width

        NSLayoutConstraint.activate([
            tabsStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            tabsStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            tabsStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            tabsStackView.heightAnchor.constraint(equalToConstant: 48),
            tabsDivider.topAnchor.constraint(equalTo: tabsStackView.bottomAnchor),
            tabsDivider.leadingAnchor.constraint(equalTo: tabsStackView.leadingAnchor),
            tabsDivider.trailingAnchor.constraint(equalTo: tabsStackView.trailingAnchor),
            tabsDivider.heightAnchor.constraint(equalToConstant: 1),
            tabIndicator.bottomAnchor.constraint(equalTo: tabsDivider.topAnchor),
            tabIndicator.heightAnchor.constraint(equalToConstant: 3),
            leading,
            width
        ])
    }

    /// 创建账号、验证码、密码、确认密码和条件邀请码输入区。
    private func setupFields() {
        fieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        fieldsStackView.axis = .vertical
        fieldsStackView.spacing = 16
        scrollContentView.addSubview(fieldsStackView)

        [identityField, verificationField, passwordField, confirmPasswordField, inviteCodeField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            fieldsStackView.addArrangedSubview($0)
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }

        identityField.textField.delegate = self
        verificationField.textField.delegate = self
        passwordField.textField.delegate = self
        confirmPasswordField.textField.delegate = self
        inviteCodeField.textField.delegate = self

        verificationField.configure(
            icon: UIImage(named: "img_vercode_input_tip"),
            placeholder: localized("请输入验证码")
        )
        verificationField.textField.keyboardType = .numberPad

        verificationCodeButton.setTitle(localized("获取验证码"), for: .normal)
        verificationCodeButton.setTitleColor(UIColor(coHereHex: 0x2563EB), for: .normal)
        verificationCodeButton.setTitleColor(UIColor(coHereHex: 0x94A3B8), for: .disabled)
        verificationCodeButton.titleLabel?.font = .systemFont(ofSize: 14)
        verificationField.setTrailingView(verificationCodeButton, width: 110)

        passwordField.configure(
            icon: UIImage(named: "login_password"),
            placeholder: localized("设置密码")
        )
        passwordField.textField.isSecureTextEntry = true
        passwordField.textField.textContentType = .newPassword
        passwordVisibilityButton.setImage(UIImage(named: "login_eye_hidden"), for: .normal)
        passwordVisibilityButton.setImage(UIImage(named: "login_eye_visible"), for: .selected)
        passwordField.setTrailingView(passwordVisibilityButton, width: 48)

        confirmPasswordField.configure(
            icon: UIImage(named: "login_password"),
            placeholder: localized("确认密码")
        )
        confirmPasswordField.textField.isSecureTextEntry = true
        confirmPasswordField.textField.textContentType = .newPassword
        confirmPasswordVisibilityButton.setImage(UIImage(named: "login_eye_hidden"), for: .normal)
        confirmPasswordVisibilityButton.setImage(UIImage(named: "login_eye_visible"), for: .selected)
        confirmPasswordField.setTrailingView(confirmPasswordVisibilityButton, width: 48)

        inviteCodeField.configure(
            icon: UIImage(named: "login_account"),
            placeholder: localized("请输入邀请码")
        )
        inviteCodeField.textField.isSecureTextEntry = true

        areaCodeButton.accessibilityLabel = localized("选择区号")
        areaCodeButton.backgroundColor = .clear
        areaCodeButton.translatesAutoresizingMaskIntoConstraints = false
        identityField.addSubview(areaCodeButton)
        NSLayoutConstraint.activate([
            areaCodeButton.leadingAnchor.constraint(equalTo: identityField.leadingAnchor),
            areaCodeButton.topAnchor.constraint(equalTo: identityField.topAnchor),
            areaCodeButton.bottomAnchor.constraint(equalTo: identityField.bottomAnchor),
            areaCodeButton.widthAnchor.constraint(equalToConstant: 54)
        ])

        passwordHintLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordHintLabel.textColor = UIColor(coHereHex: 0x333333)
        passwordHintLabel.font = .systemFont(ofSize: 14)
        passwordHintLabel.numberOfLines = 0
        passwordHintLabel.text = passwordHintText()
        scrollContentView.addSubview(passwordHintLabel)

        NSLayoutConstraint.activate([
            fieldsStackView.topAnchor.constraint(equalTo: tabsDivider.bottomAnchor, constant: 20),
            fieldsStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            fieldsStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            passwordHintLabel.topAnchor.constraint(equalTo: fieldsStackView.bottomAnchor, constant: 12),
            passwordHintLabel.leadingAnchor.constraint(equalTo: fieldsStackView.leadingAnchor),
            passwordHintLabel.trailingAnchor.constraint(equalTo: fieldsStackView.trailingAnchor)
        ])
    }

    /// 创建注册渐变按钮并保持文字与箭头整体居中。
    private func setupRegisterAction() {
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.accessibilityLabel = localized("注册")
        registerButton.layer.cornerRadius = 8
        registerButton.clipsToBounds = true
        scrollContentView.addSubview(registerButton)

        registerButtonContent.translatesAutoresizingMaskIntoConstraints = false
        registerButtonContent.axis = .horizontal
        registerButtonContent.alignment = .center
        registerButtonContent.spacing = 8
        registerButtonContent.isUserInteractionEnabled = false
        registerButton.addSubview(registerButtonContent)

        registerButtonTitleLabel.text = localized("注册")
        registerButtonTitleLabel.textColor = .white
        registerButtonTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        registerButtonContent.addArrangedSubview(registerButtonTitleLabel)

        registerArrowView.contentMode = .scaleAspectFit
        registerButtonContent.addArrangedSubview(registerArrowView)

        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: passwordHintLabel.bottomAnchor, constant: 24),
            registerButton.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 48),
            registerButtonContent.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            registerButtonContent.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor),
            registerArrowView.widthAnchor.constraint(equalToConstant: 16),
            registerArrowView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    /// 创建协议勾选框和可点击协议文字。
    private func setupPolicy() {
        policyButton.translatesAutoresizingMaskIntoConstraints = false
        policyButton.backgroundColor = .white
        policyButton.layer.cornerRadius = 4
        policyButton.layer.borderWidth = 1
        policyButton.layer.borderColor = UIColor(coHereHex: 0xDADADA).cgColor
        scrollContentView.addSubview(policyButton)

        policyTextView.translatesAutoresizingMaskIntoConstraints = false
        policyTextView.backgroundColor = .clear
        policyTextView.isEditable = false
        policyTextView.isScrollEnabled = false
        policyTextView.textContainerInset = .zero
        policyTextView.textContainer.lineFragmentPadding = 0
        policyTextView.delegate = self
        policyTextView.linkTextAttributes = [
            .foregroundColor: UIColor(coHereHex: 0x6C63FF)
        ]
        policyTextView.attributedText = policyAttributedText()
        scrollContentView.addSubview(policyTextView)

        NSLayoutConstraint.activate([
            policyButton.leadingAnchor.constraint(equalTo: registerButton.leadingAnchor),
            policyButton.widthAnchor.constraint(equalToConstant: 16),
            policyButton.heightAnchor.constraint(equalToConstant: 16),
            policyTextView.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 12),
            policyButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 13),
            policyTextView.leadingAnchor.constraint(equalTo: policyButton.trailingAnchor, constant: 8),
            policyTextView.trailingAnchor.constraint(equalTo: registerButton.trailingAnchor),
            policyTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 22)
        ])
    }

    /// 创建已有账号入口和版本信息。
    private func setupFooter() {
        loginPrefixLabel.translatesAutoresizingMaskIntoConstraints = false
        loginPrefixLabel.text = localized("已有账号？")
        loginPrefixLabel.textColor = UIColor(coHereHex: 0x333333)
        loginPrefixLabel.font = .systemFont(ofSize: 14)
        scrollContentView.addSubview(loginPrefixLabel)

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle(localized("立即登录"), for: .normal)
        loginButton.setTitleColor(UIColor(coHereHex: 0x6C63FF), for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        scrollContentView.addSubview(loginButton)

        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.textColor = UIColor(coHereHex: 0xBBBBC8)
        versionLabel.font = .systemFont(ofSize: 11)
        versionLabel.textAlignment = .center
        scrollContentView.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            loginPrefixLabel.topAnchor.constraint(greaterThanOrEqualTo: policyTextView.bottomAnchor, constant: 8),
            loginPrefixLabel.topAnchor.constraint(greaterThanOrEqualTo: scrollContentView.topAnchor, constant: 483),
            loginPrefixLabel.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor, constant: -34),
            loginPrefixLabel.heightAnchor.constraint(equalToConstant: 24),
            loginButton.leadingAnchor.constraint(equalTo: loginPrefixLabel.trailingAnchor, constant: 4),
            loginButton.centerYAnchor.constraint(equalTo: loginPrefixLabel.centerYAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 32),
            versionLabel.topAnchor.constraint(equalTo: loginPrefixLabel.bottomAnchor, constant: 20),
            versionLabel.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            versionLabel.heightAnchor.constraint(equalToConstant: 17),
            versionLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollContentView.bottomAnchor, constant: -28)
        ])
    }

    /// 绑定页面按钮和输入变化事件。
    private func setupActions() {
        verificationCodeButton.addTarget(self, action: #selector(verificationCodeTapped), for: .touchUpInside)
        areaCodeButton.addTarget(self, action: #selector(areaCodeTapped), for: .touchUpInside)
        passwordVisibilityButton.addTarget(self, action: #selector(passwordVisibilityTapped), for: .touchUpInside)
        confirmPasswordVisibilityButton.addTarget(
            self,
            action: #selector(confirmPasswordVisibilityTapped),
            for: .touchUpInside
        )
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        policyButton.addTarget(self, action: #selector(policyTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        [
            identityField.textField,
            verificationField.textField,
            passwordField.textField,
            confirmPasswordField.textField,
            inviteCodeField.textField
        ].forEach {
            $0.addTarget(self, action: #selector(inputTextChanged), for: .editingChanged)
        }
    }

    /// 监听键盘变化并调整表单可滚动区域。
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

    /// 根据后端标题重新创建页签按钮。
    /// - Parameter titles: 与注册类型一一对应的页签标题。
    private func rebuildTabs(titles: [String]) {
        tabsStackView.arrangedSubviews.forEach {
            tabsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        tabButtons.removeAll()

        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            tabsStackView.addArrangedSubview(button)
            tabButtons.append(button)
        }
    }

    /// 按页签下标切换表单状态并恢复对应草稿。
    /// - Parameters:
    ///   - index: 页签下标。
    ///   - notifyBusiness: 是否通知控制器更新数据层注册类型。
    private func applyRegisterType(at index: Int, notifyBusiness: Bool) {
        guard registerTypes.indices.contains(index) else {
            return
        }
        saveCurrentDraft()
        currentRegisterType = registerTypes[index]
        restoreCurrentDraft()
        updateTabStyles(selectedIndex: index)
        updateFieldPresentation()
        updateRegisterButtonAvailability()
        updateTabIndicator(animated: notifyBusiness)
        if notifyBusiness {
            onRegisterTypeChanged?(currentRegisterType)
        }
    }

    /// 更新三个页签的字体和颜色。
    /// - Parameter selectedIndex: 当前选中页签下标。
    private func updateTabStyles(selectedIndex: Int) {
        for (index, button) in tabButtons.enumerated() {
            let selected = index == selectedIndex
            button.setTitleColor(
                selected ? UIColor(coHereHex: 0x6C63FF) : UIColor(coHereHex: 0x9CA3AF),
                for: .normal
            )
            button.titleLabel?.font = .systemFont(
                ofSize: 16,
                weight: selected ? .medium : .regular
            )
        }
    }

    /// 根据当前注册类型配置输入图标、键盘和可见字段。
    private func updateFieldPresentation() {
        let isAccount = currentRegisterType == 2
        let isPhone = currentRegisterType == 0

        if isPhone {
            identityField.configure(
                icon: UIImage(named: "login_phone"),
                placeholder: localized("请输入手机号")
            )
            identityField.textField.keyboardType = .phonePad
        } else if currentRegisterType == 1 {
            identityField.configure(
                icon: UIImage(named: "login_email"),
                placeholder: localized("请输入邮箱地址")
            )
            identityField.textField.keyboardType = .emailAddress
        } else {
            identityField.configure(
                icon: UIImage(named: "login_account"),
                placeholder: localized("请输入账号")
            )
            identityField.textField.keyboardType = .asciiCapable
        }

        verificationField.isHidden = isAccount
        areaCodeButton.isHidden = !isPhone
        inviteCodeField.isHidden = !inviteCodeRequired
        areaCodeButton.accessibilityValue = areaCode
        refreshVerificationCountdownPresentation()
    }

    /// 保存当前表单输入，避免切换页签时丢失。
    private func saveCurrentDraft() {
        guard registerTypes.contains(currentRegisterType) else {
            return
        }
        drafts[currentRegisterType] = RegisterDraft(
            identity: identityField.textField.text ?? "",
            verificationCode: verificationField.textField.text ?? "",
            password: passwordField.textField.text ?? "",
            confirmPassword: confirmPasswordField.textField.text ?? "",
            inviteCode: inviteCodeField.textField.text ?? ""
        )
    }

    /// 将当前注册方式保存的草稿恢复到输入框。
    private func restoreCurrentDraft() {
        let draft = drafts[currentRegisterType] ?? RegisterDraft()
        identityField.textField.text = draft.identity
        verificationField.textField.text = draft.verificationCode
        passwordField.textField.text = draft.password
        confirmPasswordField.textField.text = draft.confirmPassword
        inviteCodeField.textField.text = draft.inviteCode
    }

    /// 按旧注册页面规则根据当前必填项控制注册按钮是否可点击。
    private func updateRegisterButtonAvailability() {
        let values = textValues(for: currentRegisterType)
        var isAvailable =
            !(values["identity"] ?? "").isEmpty
            && !(values["password"] ?? "").isEmpty
            && !(values["confirmPassword"] ?? "").isEmpty
        if currentRegisterType != 2 {
            isAvailable = isAvailable && !(values["verificationCode"] ?? "").isEmpty
        }
        if inviteCodeRequired {
            isAvailable = isAvailable && !(values["inviteCode"] ?? "").isEmpty
        }
        registerButton.isEnabled = isAvailable
        registerButton.alpha = isAvailable ? 1 : 0.7
    }

    /// 根据当前页签自己的剩余秒数刷新验证码按钮，避免手机号和邮箱倒计时互相影响。
    private func refreshVerificationCountdownPresentation() {
        guard currentRegisterType == 0 || currentRegisterType == 1 else {
            verificationCodeButton.isEnabled = false
            verificationCodeButton.setTitle(localized("获取验证码"), for: .normal)
            return
        }
        guard let seconds = verificationCountdownSeconds[currentRegisterType] else {
            verificationCodeButton.isEnabled = true
            verificationCodeButton.setTitle(localized("获取验证码"), for: .normal)
            return
        }
        verificationCodeButton.isEnabled = false
        updateVerificationCodeButton(seconds: seconds)
    }

    /// 将页签指示线移动到选中页签下方。
    /// - Parameter animated: 是否使用短动画。
    private func updateTabIndicator(animated: Bool) {
        guard
            let index = registerTypes.firstIndex(of: currentRegisterType),
            !tabButtons.isEmpty
        else {
            return
        }
        let slotWidth = tabsStackView.bounds.width / CGFloat(tabButtons.count)
        let indicatorWidth: CGFloat = currentRegisterType == 0 ? 72 : 56
        tabIndicatorWidthConstraint?.constant = indicatorWidth
        tabIndicatorLeadingConstraint?.constant =
            slotWidth * CGFloat(index) + (slotWidth - indicatorWidth) / 2

        let updates: () -> Void = { [weak self] in
            self?.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: updates)
        } else {
            updates()
        }
    }

    /// 生成带字间距的品牌副标题。
    /// - Returns: 月光语中英文品牌富文本。
    private func attributedBrandText() -> NSAttributedString {
        NSAttributedString(
            string: "Co here",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.75),
                .font: UIFont.systemFont(ofSize: 10.5, weight: .medium),
                .kern: 2.4
            ]
        )
    }

    /// 根据服务端密码策略生成提示文字。
    /// - Returns: 当前注册密码规则说明。
    private func passwordHintText() -> String {
        if NoaUrlHostManager.share().appSysSetModel.checkEnglishSymbol {
            return localized("密码至少6个字符，同时包含字母、数字、符号")
        }
        return localized("密码至少6个字符，不能全是字母或数字")
    }

    /// 生成包含两个内部链接并沿用登录页默认字形行高的注册协议文字。
    /// - Returns: 注册协议富文本。
    private func policyAttributedText() -> NSAttributedString {
        let prefix = localized("我已阅读并同意")
        let userAgreement = localized("《用户协议》")
        let conjunction = localized("和")
        let privacyAgreement = localized("《隐私协议》")
        let fullText = prefix + userAgreement + conjunction + privacyAgreement
        let result = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor(coHereHex: 0x35404E)
            ]
        )
        if let range = fullText.range(of: userAgreement) {
            result.addAttribute(
                .link,
                value: "cohere-register://user-agreement",
                range: NSRange(range, in: fullText)
            )
        }
        if let range = fullText.range(of: privacyAgreement) {
            result.addAttribute(
                .link,
                value: "cohere-register://privacy-agreement",
                range: NSRange(range, in: fullText)
            )
        }
        return result
    }

    /// 使用项目语言管理器获取本地化文本。
    /// - Parameter key: Localizable.strings 中的中文键。
    /// - Returns: 当前语言对应的显示文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }

    /// 更新验证码倒计时显示。
    /// - Parameter seconds: 剩余秒数。
    private func updateVerificationCodeButton(seconds: Int) {
        verificationCodeButton.setTitle(
            String(format: localized("重新获取(%d)"), seconds),
            for: .normal
        )
    }

    /// 处理页签点击并通知控制器。
    /// - Parameter sender: 被点击的页签按钮。
    @objc private func tabTapped(_ sender: UIButton) {
        applyRegisterType(at: sender.tag, notifyBusiness: true)
    }

    /// 保存输入变化。
    @objc private func inputTextChanged() {
        saveCurrentDraft()
        updateRegisterButtonAvailability()
    }

    /// 转发获取验证码点击。
    @objc private func verificationCodeTapped() {
        saveCurrentDraft()
        onVerificationCodeTap?()
    }

    /// 转发区号选择点击。
    @objc private func areaCodeTapped() {
        onAreaCodeTap?()
    }

    /// 切换设置密码的明文和密文状态。
    @objc private func passwordVisibilityTapped() {
        passwordVisibilityButton.isSelected.toggle()
        passwordField.textField.isSecureTextEntry = !passwordVisibilityButton.isSelected
    }

    /// 切换确认密码的明文和密文状态。
    @objc private func confirmPasswordVisibilityTapped() {
        confirmPasswordVisibilityButton.isSelected.toggle()
        confirmPasswordField.textField.isSecureTextEntry =
            !confirmPasswordVisibilityButton.isSelected
    }

    /// 转发注册按钮点击。
    @objc private func registerTapped() {
        endInputEditing()
        onRegisterTap?()
    }

    /// 切换协议勾选状态。
    @objc private func policyTapped() {
        updatePolicyAccepted(!policyAccepted)
    }

    /// 转发立即登录点击。
    @objc private func loginTapped() {
        endInputEditing()
        onLoginTap?()
    }

    /// 根据键盘最终位置调整滚动区域底部留白。
    /// - Parameter notification: 包含键盘最终位置的系统通知。
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

    /// 键盘隐藏后移除滚动区域额外留白。
    /// - Parameter notification: 键盘隐藏通知，仅用于统一方法签名。
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    /// 处理键盘 Return 键并移动到下一个输入框。
    /// - Parameter textField: 当前响应 Return 键的输入框。
    /// - Returns: true 表示系统可继续处理 Return 键。
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === identityField.textField, currentRegisterType != 2 {
            verificationField.textField.becomeFirstResponder()
        } else if textField === identityField.textField || textField === verificationField.textField {
            passwordField.textField.becomeFirstResponder()
        } else if textField === passwordField.textField {
            confirmPasswordField.textField.becomeFirstResponder()
        } else if textField === confirmPasswordField.textField, inviteCodeRequired {
            inviteCodeField.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    /// 拦截协议内部链接并转发至现有原生协议页面。
    /// - Parameters:
    ///   - textView: 协议文本控件。
    ///   - URL: 被点击的内部链接。
    ///   - characterRange: 点击字符范围。
    ///   - interaction: 系统识别的交互类型。
    /// - Returns: false，阻止系统尝试打开内部 URL。
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

/// 单个注册方式下独立保存的输入草稿。
private struct RegisterDraft {

    /// 账号、手机号或邮箱。
    var identity = ""

    /// 手机或邮箱验证码。
    var verificationCode = ""

    /// 设置密码。
    var password = ""

    /// 确认密码。
    var confirmPassword = ""

    /// 后台要求时填写的注册邀请码。
    var inviteCode = ""
}
