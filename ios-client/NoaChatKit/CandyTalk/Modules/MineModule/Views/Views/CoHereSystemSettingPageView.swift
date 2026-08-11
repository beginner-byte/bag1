import UIKit

/// 按照 Figma “系统设置”节点实现的 Swift 视觉层；设置接口、缓存清理和账号操作由 Swift 控制器负责。
@objc(CoHereSystemSettingPageView)
final class CoHereSystemSettingPageView: UIView {

    // MARK: - Controller callbacks

    /// 点击返回按钮后的业务回调。
    @objc var onBackTap: (() -> Void)?

    /// 用户切换新消息通知后的业务回调。
    @objc var onNewMessageChanged: ((Bool) -> Void)?

    /// 用户切换声音提醒后的业务回调。
    @objc var onSoundChanged: ((Bool) -> Void)?

    /// 用户切换震动提醒后的业务回调。
    @objc var onVibrationChanged: ((Bool) -> Void)?

    /// 点击清理缓存后的业务回调。
    @objc var onClearCacheTap: (() -> Void)?

    /// 点击删除账号后的业务回调。
    @objc var onDeleteAccountTap: (() -> Void)?

    /// 点击退出登录后的业务回调。
    @objc var onLogoutTap: (() -> Void)?

    // MARK: - Navigation

    /// 顶部状态栏与导航内容的浅色渐变背景。
    private let coHereNavigationView = CoHereSystemSettingGradientView()

    /// 返回按钮，使用从 Figma 下载的图标并保留 36pt 点击区域。
    private let coHereBackButton = UIButton(type: .custom)

    /// 页面居中的导航标题。
    private let coHereTitleLabel = UILabel()

    // MARK: - Setting rows

    /// 新消息通知设置行。
    private let coHereNewMessageRow = UIView()

    /// 声音设置行。
    private let coHereSoundRow = UIView()

    /// 震动设置行。
    private let coHereVibrationRow = UIView()

    /// 新消息通知开关，尺寸与 Figma 的 48×24pt 一致。
    private let coHereNewMessageToggle = CoHereSystemSettingToggleControl()

    /// 声音提醒开关。
    private let coHereSoundToggle = CoHereSystemSettingToggleControl()

    /// 震动提醒开关。
    private let coHereVibrationToggle = CoHereSystemSettingToggleControl()

    /// 第一组设置与缓存设置之间的 8pt 分组间隔。
    private let coHereFirstSectionGap = UIView()

    /// 清理缓存整行点击按钮。
    private let coHereClearCacheButton = UIButton(type: .custom)

    /// 当前缓存大小，来源为 Swift 控制器迁移后的原有计算逻辑。
    private let coHereCacheValueLabel = UILabel()

    /// 清理缓存后的 Figma 右箭头。
    private let coHereCacheArrowView = UIImageView(
        image: UIImage(named: "cohere_system_setting_chevron")
    )

    /// 缓存设置与删除账号之间的 8pt 分组间隔。
    private let coHereSecondSectionGap = UIView()

    /// 删除账号整行点击按钮。
    private let coHereDeleteAccountButton = UIButton(type: .custom)

    /// 删除账号不可恢复风险说明。
    private let coHereDeleteDescriptionLabel = UILabel()

    /// 删除说明与退出登录行之间的背景容器。
    private let coHereDeleteDescriptionView = UIView()

    /// 退出登录整行点击按钮。
    private let coHereLogoutButton = UIButton(type: .custom)

    /// 退出登录后的 Figma 右箭头。
    private let coHereLogoutArrowView = UIImageView(
        image: UIImage(named: "cohere_system_setting_chevron")
    )

    /// 创建系统设置视觉层并完成控件、约束和事件初始化。
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

    /// 使用 Swift 控制器现有状态刷新三个开关和缓存大小，不触发业务回调。
    /// - Parameters:
    ///   - newMessageEnabled: 新消息通知是否开启。
    ///   - soundEnabled: 声音提醒是否开启。
    ///   - vibrationEnabled: 震动提醒是否开启。
    ///   - cacheSize: 原缓存计算方法返回的 B、KB、MB 或 GB 文本。
    @objc(configureWithNewMessageEnabled:soundEnabled:vibrationEnabled:cacheSize:)
    func coHereConfigure(
        newMessageEnabled: Bool,
        soundEnabled: Bool,
        vibrationEnabled: Bool,
        cacheSize: String
    ) {
        coHereNewMessageToggle.coHereSetOn(newMessageEnabled, animated: false)
        coHereSoundToggle.coHereSetOn(soundEnabled, animated: false)
        coHereVibrationToggle.coHereSetOn(vibrationEnabled, animated: false)
        coHereCacheValueLabel.text = cacheSize
    }

    /// 创建页面控件并应用 Figma 的颜色、字体、行高和分组背景。
    private func coHereSetupView() {
        backgroundColor = UIColor(coHereSystemSettingHex: 0xF5F5F5)

        coHereNavigationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coHereNavigationView)

        coHereBackButton.translatesAutoresizingMaskIntoConstraints = false
        coHereBackButton.setImage(UIImage(named: "cohere_system_setting_back"), for: .normal)
        coHereBackButton.accessibilityLabel = coHereLocalized("返回")
        coHereNavigationView.addSubview(coHereBackButton)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.text = coHereLocalized("系统设置")
        coHereTitleLabel.textColor = UIColor(coHereSystemSettingHex: 0x333333)
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coHereTitleLabel.textAlignment = .center
        coHereNavigationView.addSubview(coHereTitleLabel)

        coHereConfigureToggleRow(
            coHereNewMessageRow,
            title: coHereLocalized("新消息通知"),
            toggle: coHereNewMessageToggle
        )
        coHereConfigureToggleRow(
            coHereSoundRow,
            title: coHereLocalized("声音"),
            toggle: coHereSoundToggle
        )
        coHereConfigureToggleRow(
            coHereVibrationRow,
            title: coHereLocalized("震动"),
            toggle: coHereVibrationToggle
        )

        coHereFirstSectionGap.translatesAutoresizingMaskIntoConstraints = false
        coHereFirstSectionGap.backgroundColor = backgroundColor
        addSubview(coHereFirstSectionGap)

        coHereConfigureClearCacheRow()

        coHereSecondSectionGap.translatesAutoresizingMaskIntoConstraints = false
        coHereSecondSectionGap.backgroundColor = backgroundColor
        addSubview(coHereSecondSectionGap)

        coHereConfigureAccountRows()
    }

    /// 配置一个带 Figma 自定义开关的 52pt 设置行。
    /// - Parameters:
    ///   - rowView: 当前设置行容器。
    ///   - title: 设置项本地化标题。
    ///   - toggle: 当前设置项对应开关。
    private func coHereConfigureToggleRow(
        _ rowView: UIView,
        title: String,
        toggle: CoHereSystemSettingToggleControl
    ) {
        rowView.translatesAutoresizingMaskIntoConstraints = false
        rowView.backgroundColor = .white
        addSubview(rowView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = UIColor(coHereSystemSettingHex: 0x333333)
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        rowView.addSubview(titleLabel)

        toggle.translatesAutoresizingMaskIntoConstraints = false
        rowView.addSubview(toggle)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(coHereSystemSettingHex: 0xE5E5E5).withAlphaComponent(0.2)
        rowView.addSubview(divider)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),

            toggle.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            toggle.widthAnchor.constraint(equalToConstant: 48),
            toggle.heightAnchor.constraint(equalToConstant: 24),

            divider.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    /// 配置清理缓存标题、缓存大小和右箭头。
    private func coHereConfigureClearCacheRow() {
        coHereClearCacheButton.translatesAutoresizingMaskIntoConstraints = false
        coHereClearCacheButton.backgroundColor = .white
        coHereClearCacheButton.contentHorizontalAlignment = .left
        coHereClearCacheButton.setTitle(coHereLocalized("清理缓存"), for: .normal)
        coHereClearCacheButton.setTitleColor(
            UIColor(coHereSystemSettingHex: 0x333333),
            for: .normal
        )
        coHereClearCacheButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        coHereClearCacheButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 84)
        addSubview(coHereClearCacheButton)

        coHereCacheValueLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereCacheValueLabel.text = "0B"
        coHereCacheValueLabel.textColor = UIColor(coHereSystemSettingHex: 0x999999)
        coHereCacheValueLabel.font = .systemFont(ofSize: 12, weight: .regular)
        coHereCacheValueLabel.textAlignment = .right
        coHereClearCacheButton.addSubview(coHereCacheValueLabel)

        coHereCacheArrowView.translatesAutoresizingMaskIntoConstraints = false
        coHereCacheArrowView.contentMode = .scaleAspectFit
        coHereClearCacheButton.addSubview(coHereCacheArrowView)
    }

    /// 配置删除账号、风险说明和退出登录行。
    private func coHereConfigureAccountRows() {
        coHereDeleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        coHereDeleteAccountButton.backgroundColor = .white
        coHereDeleteAccountButton.setTitle(coHereLocalized("删除账号"), for: .normal)
        coHereDeleteAccountButton.setTitleColor(
            UIColor(coHereSystemSettingHex: 0x333333),
            for: .normal
        )
        coHereDeleteAccountButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(coHereDeleteAccountButton)

        coHereDeleteDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        coHereDeleteDescriptionView.backgroundColor = backgroundColor
        addSubview(coHereDeleteDescriptionView)

        coHereDeleteDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereDeleteDescriptionLabel.text = coHereLocalized("删除账号页脚说明")
        coHereDeleteDescriptionLabel.textColor = UIColor(coHereSystemSettingHex: 0x999999)
        coHereDeleteDescriptionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        coHereDeleteDescriptionLabel.numberOfLines = 2
        coHereDeleteDescriptionLabel.adjustsFontSizeToFitWidth = true
        coHereDeleteDescriptionLabel.minimumScaleFactor = 0.85
        coHereDeleteDescriptionView.addSubview(coHereDeleteDescriptionLabel)

        coHereLogoutButton.translatesAutoresizingMaskIntoConstraints = false
        coHereLogoutButton.backgroundColor = .white
        coHereLogoutButton.setTitle(coHereLocalized("退出登录"), for: .normal)
        coHereLogoutButton.setTitleColor(
            UIColor(coHereSystemSettingHex: 0x333333),
            for: .normal
        )
        coHereLogoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(coHereLogoutButton)

        coHereLogoutArrowView.translatesAutoresizingMaskIntoConstraints = false
        coHereLogoutArrowView.contentMode = .scaleAspectFit
        coHereLogoutButton.addSubview(coHereLogoutArrowView)
    }

    /// 建立与 Figma 纵向位置一致的导航、设置行和账号操作约束。
    private func coHereSetupConstraints() {
        NSLayoutConstraint.activate([
            coHereNavigationView.topAnchor.constraint(equalTo: topAnchor),
            coHereNavigationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereNavigationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereNavigationView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 58
            ),

            coHereBackButton.leadingAnchor.constraint(equalTo: coHereNavigationView.leadingAnchor, constant: 8),
            coHereBackButton.bottomAnchor.constraint(equalTo: coHereNavigationView.bottomAnchor, constant: -8),
            coHereBackButton.widthAnchor.constraint(equalToConstant: 36),
            coHereBackButton.heightAnchor.constraint(equalToConstant: 36),

            coHereTitleLabel.centerXAnchor.constraint(equalTo: coHereNavigationView.centerXAnchor),
            coHereTitleLabel.centerYAnchor.constraint(equalTo: coHereBackButton.centerYAnchor),
            coHereTitleLabel.heightAnchor.constraint(equalToConstant: 24),

            coHereNewMessageRow.topAnchor.constraint(equalTo: coHereNavigationView.bottomAnchor),
            coHereNewMessageRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereNewMessageRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereNewMessageRow.heightAnchor.constraint(equalToConstant: 52),

            coHereSoundRow.topAnchor.constraint(equalTo: coHereNewMessageRow.bottomAnchor),
            coHereSoundRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereSoundRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereSoundRow.heightAnchor.constraint(equalToConstant: 52),

            coHereVibrationRow.topAnchor.constraint(equalTo: coHereSoundRow.bottomAnchor),
            coHereVibrationRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereVibrationRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereVibrationRow.heightAnchor.constraint(equalToConstant: 52),

            coHereFirstSectionGap.topAnchor.constraint(equalTo: coHereVibrationRow.bottomAnchor),
            coHereFirstSectionGap.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereFirstSectionGap.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereFirstSectionGap.heightAnchor.constraint(equalToConstant: 8),

            coHereClearCacheButton.topAnchor.constraint(equalTo: coHereFirstSectionGap.bottomAnchor),
            coHereClearCacheButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereClearCacheButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereClearCacheButton.heightAnchor.constraint(equalToConstant: 52),

            coHereCacheArrowView.trailingAnchor.constraint(
                equalTo: coHereClearCacheButton.trailingAnchor,
                constant: -16
            ),
            coHereCacheArrowView.centerYAnchor.constraint(equalTo: coHereClearCacheButton.centerYAnchor),
            coHereCacheArrowView.widthAnchor.constraint(equalToConstant: 16),
            coHereCacheArrowView.heightAnchor.constraint(equalToConstant: 16),

            coHereCacheValueLabel.trailingAnchor.constraint(
                equalTo: coHereCacheArrowView.leadingAnchor,
                constant: -10
            ),
            coHereCacheValueLabel.centerYAnchor.constraint(equalTo: coHereClearCacheButton.centerYAnchor),
            coHereCacheValueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 56),
            coHereCacheValueLabel.heightAnchor.constraint(equalToConstant: 20),

            coHereSecondSectionGap.topAnchor.constraint(equalTo: coHereClearCacheButton.bottomAnchor),
            coHereSecondSectionGap.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereSecondSectionGap.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereSecondSectionGap.heightAnchor.constraint(equalToConstant: 8),

            coHereDeleteAccountButton.topAnchor.constraint(equalTo: coHereSecondSectionGap.bottomAnchor),
            coHereDeleteAccountButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereDeleteAccountButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereDeleteAccountButton.heightAnchor.constraint(equalToConstant: 52),

            coHereDeleteDescriptionView.topAnchor.constraint(equalTo: coHereDeleteAccountButton.bottomAnchor),
            coHereDeleteDescriptionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereDeleteDescriptionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereDeleteDescriptionView.heightAnchor.constraint(equalToConstant: 36),

            coHereDeleteDescriptionLabel.leadingAnchor.constraint(
                equalTo: coHereDeleteDescriptionView.leadingAnchor,
                constant: 14
            ),
            coHereDeleteDescriptionLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: coHereDeleteDescriptionView.trailingAnchor,
                constant: -14
            ),
            coHereDeleteDescriptionLabel.topAnchor.constraint(
                equalTo: coHereDeleteDescriptionView.topAnchor,
                constant: 8
            ),
            coHereDeleteDescriptionLabel.heightAnchor.constraint(equalToConstant: 20),

            coHereLogoutButton.topAnchor.constraint(equalTo: coHereDeleteDescriptionView.bottomAnchor),
            coHereLogoutButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereLogoutButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereLogoutButton.heightAnchor.constraint(equalToConstant: 52),

            coHereLogoutArrowView.trailingAnchor.constraint(
                equalTo: coHereLogoutButton.trailingAnchor,
                constant: -16
            ),
            coHereLogoutArrowView.centerYAnchor.constraint(equalTo: coHereLogoutButton.centerYAnchor),
            coHereLogoutArrowView.widthAnchor.constraint(equalToConstant: 16),
            coHereLogoutArrowView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    /// 绑定所有按钮和开关事件；业务行为通过回调交给 Swift 控制器。
    private func coHereBindActions() {
        coHereBackButton.addTarget(
            self,
            action: #selector(coHereHandleBackTap),
            for: .touchUpInside
        )
        coHereNewMessageToggle.addTarget(
            self,
            action: #selector(coHereHandleNewMessageChanged),
            for: .valueChanged
        )
        coHereSoundToggle.addTarget(
            self,
            action: #selector(coHereHandleSoundChanged),
            for: .valueChanged
        )
        coHereVibrationToggle.addTarget(
            self,
            action: #selector(coHereHandleVibrationChanged),
            for: .valueChanged
        )
        coHereClearCacheButton.addTarget(
            self,
            action: #selector(coHereHandleClearCacheTap),
            for: .touchUpInside
        )
        coHereDeleteAccountButton.addTarget(
            self,
            action: #selector(coHereHandleDeleteAccountTap),
            for: .touchUpInside
        )
        coHereLogoutButton.addTarget(
            self,
            action: #selector(coHereHandleLogoutTap),
            for: .touchUpInside
        )
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

    /// 转发新消息通知开关变化。
    @objc private func coHereHandleNewMessageChanged() {
        onNewMessageChanged?(coHereNewMessageToggle.coHereIsOn)
    }

    /// 转发声音提醒开关变化。
    @objc private func coHereHandleSoundChanged() {
        onSoundChanged?(coHereSoundToggle.coHereIsOn)
    }

    /// 转发震动提醒开关变化。
    @objc private func coHereHandleVibrationChanged() {
        onVibrationChanged?(coHereVibrationToggle.coHereIsOn)
    }

    /// 转发清理缓存点击。
    @objc private func coHereHandleClearCacheTap() {
        onClearCacheTap?()
    }

    /// 转发删除账号点击。
    @objc private func coHereHandleDeleteAccountTap() {
        onDeleteAccountTap?()
    }

    /// 转发退出登录点击。
    @objc private func coHereHandleLogoutTap() {
        onLogoutTap?()
    }
}

/// 精确复刻 Figma 48×24pt 开关的 UIControl，仅在用户点击时发送 valueChanged。
private final class CoHereSystemSettingToggleControl: UIControl {

    /// 当前开启状态；外部只能读取，通过 coHereSetOn 更新。
    private(set) var coHereIsOn = false

    /// 白色圆形滑块。
    private let coHereKnobView = UIView()

    /// 创建开关并配置圆角、阴影和交互。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupControl()
    }

    /// Storyboard/XIB 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupControl()
    }

    /// 根据当前尺寸保持轨道和圆点位置与设计稿一致。
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        coHereApplyVisualState()
    }

    /// 更新开关状态，不主动发送 valueChanged，避免接口刷新触发重复请求。
    /// - Parameters:
    ///   - isOn: 新的开启状态。
    ///   - animated: 是否使用 0.2 秒滑动动画。
    func coHereSetOn(_ isOn: Bool, animated: Bool) {
        guard coHereIsOn != isOn else {
            coHereApplyVisualState()
            return
        }
        coHereIsOn = isOn
        let updates = {
            self.coHereApplyVisualState()
        }
        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseInOut],
                animations: updates
            )
        } else {
            updates()
        }
    }

    /// 配置滑块阴影、可访问性和点击事件。
    private func coHereSetupControl() {
        isAccessibilityElement = true
        accessibilityTraits = .button
        layer.masksToBounds = false

        coHereKnobView.backgroundColor = .white
        coHereKnobView.layer.cornerRadius = 10
        coHereKnobView.layer.shadowColor = UIColor.black.cgColor
        coHereKnobView.layer.shadowOpacity = 0.1
        coHereKnobView.layer.shadowRadius = 2
        coHereKnobView.layer.shadowOffset = CGSize(width: 0, height: 1)
        addSubview(coHereKnobView)

        addTarget(self, action: #selector(coHereToggleFromUser), for: .touchUpInside)
        coHereApplyVisualState()
    }

    /// 应用当前开关背景色、圆点位置和可访问性值。
    private func coHereApplyVisualState() {
        backgroundColor = UIColor(
            coHereSystemSettingHex: coHereIsOn ? 0x6C63FF : 0xD1D5DB
        )
        let knobX = coHereIsOn ? max(2, bounds.width - 22) : 2
        coHereKnobView.frame = CGRect(x: knobX, y: 2, width: 20, height: 20)
        accessibilityValue = coHereIsOn
            ? NSLocalizedString("开启", comment: "")
            : NSLocalizedString("关闭", comment: "")
    }

    /// 响应用户点击、切换视觉状态并发送 valueChanged。
    @objc private func coHereToggleFromUser() {
        coHereSetOn(!coHereIsOn, animated: true)
        sendActions(for: .valueChanged)
    }
}

/// 顶部导航浅紫到白色的 Figma 渐变背景。
private final class CoHereSystemSettingGradientView: UIView {

    /// 导航背景使用的渐变图层。
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

    /// 配置从顶部浅紫到底部白色的渐变。
    private func coHereSetupGradient() {
        coHereGradientLayer.colors = [
            UIColor(coHereSystemSettingHex: 0xF2F1FF).cgColor,
            UIColor.white.cgColor
        ]
        coHereGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        coHereGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(coHereGradientLayer, at: 0)
    }
}

private extension UIColor {

    /// 将 Figma 十六进制颜色转换为 UIColor。
    /// - Parameter coHereSystemSettingHex: 0xRRGGBB 格式颜色值。
    convenience init(coHereSystemSettingHex: UInt32) {
        self.init(
            red: CGFloat((coHereSystemSettingHex >> 16) & 0xFF) / 255,
            green: CGFloat((coHereSystemSettingHex >> 8) & 0xFF) / 255,
            blue: CGFloat(coHereSystemSettingHex & 0xFF) / 255,
            alpha: 1
        )
    }
}
