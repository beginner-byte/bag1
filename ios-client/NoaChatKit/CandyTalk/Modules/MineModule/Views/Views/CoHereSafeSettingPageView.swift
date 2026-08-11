//
//  CoHereSafeSettingPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// 安全设置页面的四个固定业务入口。
enum CoHereSafeSettingItem: Int, CaseIterable {
    /// 修改当前账号登录密码。
    case changePassword

    /// 设置、修改或关闭当前账号手势密码。
    case gestureUnlock

    /// 设置、修改或关闭当前账号设备安全码。
    case deviceSafeCode

    /// 查看并管理当前账号的信任设备。
    case trustedDevices
}

/// 按照 Figma“安全设置”节点实现的 Swift 视觉层；所有业务由 Swift 控制器负责。
@objc(CoHereSafeSettingPageView)
final class CoHereSafeSettingPageView: UIView {

    /// 点击返回按钮后的业务回调。
    @objc var onBackTap: (() -> Void)?

    /// 点击安全设置行后的业务回调，参数为固定业务入口。
    var onItemTap: ((CoHereSafeSettingItem) -> Void)?

    /// 顶部状态栏与导航内容的 Figma 浅紫到白色渐变背景。
    private let coHereNavigationView = CoHereSafeSettingGradientView()

    /// 返回按钮，复用同一设计系统已有图标并保留 36pt 点击区域。
    private let coHereBackButton = UIButton(type: .custom)

    /// 页面居中的导航标题。
    private let coHereTitleLabel = UILabel()

    /// 修改密码整行点击控件。
    private let coHerePasswordRow = CoHereSafeSettingRowControl(
        item: .changePassword
    )

    /// 手势图案解锁整行点击控件。
    private let coHereGestureRow = CoHereSafeSettingRowControl(
        item: .gestureUnlock
    )

    /// 设备安全码整行点击控件。
    private let coHereDeviceSafeCodeRow = CoHereSafeSettingRowControl(
        item: .deviceSafeCode
    )

    /// 信任设备整行点击控件。
    private let coHereTrustedDevicesRow = CoHereSafeSettingRowControl(
        item: .trustedDevices
    )

    /// 修改密码与手势图案解锁之间的 8pt 分组间隔。
    private let coHereFirstSectionGap = UIView()

    /// 手势图案解锁与设备安全码之间的 8pt 分组间隔。
    private let coHereSecondSectionGap = UIView()

    /// 设备安全码与信任设备之间的 8pt 分组间隔。
    private let coHereThirdSectionGap = UIView()

    /// 创建安全设置视觉层并完成控件、约束和事件初始化。
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

    /// 使用控制器读取的实时状态刷新两个状态文本，不触发点击回调。
    /// - Parameters:
    ///   - gestureEnabled: 当前账号是否已经设置手势密码。
    ///   - deviceSafeCodeEnabled: 当前账号是否已经设置设备安全码。
    func configure(
        gestureEnabled: Bool,
        deviceSafeCodeEnabled: Bool
    ) {
        coHereGestureRow.configure(
            title: coHereLocalized("手势图案解锁"),
            status: coHereLocalized(gestureEnabled ? "开启" : "关闭")
        )
        coHereDeviceSafeCodeRow.configure(
            title: coHereLocalized("设备安全码"),
            status: coHereLocalized(deviceSafeCodeEnabled ? "开启" : "关闭")
        )
    }

    /// 创建并配置 Figma 导航、三个通栏设置行及分组背景。
    private func coHereSetupView() {
        let pageLightColor = UIColor(coHereSafeSettingHex: 0xF5F5F5)
        let pageDarkColor = UIColor(coHereSafeSettingHex: 0x111111)
        backgroundColor = pageLightColor
        tkThemebackgroundColors = [pageLightColor, pageDarkColor]

        coHereNavigationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coHereNavigationView)

        coHereBackButton.translatesAutoresizingMaskIntoConstraints = false
        coHereBackButton.setImage(
            UIImage(named: "cohere_system_setting_back"),
            for: .normal
        )
        coHereBackButton.accessibilityLabel = coHereLocalized("返回")
        addSubview(coHereBackButton)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.text = coHereLocalized("安全设置")
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coHereTitleLabel.textAlignment = .center
        coHereTitleLabel.tkThemetextColors = [
            UIColor(coHereSafeSettingHex: 0x333333),
            .white
        ]
        addSubview(coHereTitleLabel)

        coHerePasswordRow.translatesAutoresizingMaskIntoConstraints = false
        coHerePasswordRow.configure(
            title: coHereLocalized("修改密码"),
            status: nil
        )
        addSubview(coHerePasswordRow)

        coHereGestureRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coHereGestureRow)

        coHereDeviceSafeCodeRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coHereDeviceSafeCodeRow)

        coHereTrustedDevicesRow.translatesAutoresizingMaskIntoConstraints = false
        coHereTrustedDevicesRow.configure(
            title: coHereLocalized("信任设备"),
            status: nil
        )
        addSubview(coHereTrustedDevicesRow)

        for gapView in [
            coHereFirstSectionGap,
            coHereSecondSectionGap,
            coHereThirdSectionGap
        ] {
            gapView.translatesAutoresizingMaskIntoConstraints = false
            gapView.tkThemebackgroundColors = [pageLightColor, pageDarkColor]
            addSubview(gapView)
        }

        tkThemeChangeBlock = { [weak self] _, themeIndex in
            self?.coHereNavigationView.setDarkTheme(themeIndex != 0)
        }
    }

    /// 建立与 375×812 Figma 基准一致并适配设备安全区的导航和分组行约束。
    private func coHereSetupConstraints() {
        NSLayoutConstraint.activate([
            coHereNavigationView.topAnchor.constraint(equalTo: topAnchor),
            coHereNavigationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereNavigationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereNavigationView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 58
            ),

            coHereBackButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            coHereBackButton.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            coHereBackButton.widthAnchor.constraint(equalToConstant: 36),
            coHereBackButton.heightAnchor.constraint(equalToConstant: 36),

            coHereTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            coHereTitleLabel.centerYAnchor.constraint(equalTo: coHereBackButton.centerYAnchor),
            coHereTitleLabel.heightAnchor.constraint(equalToConstant: 24),

            coHerePasswordRow.topAnchor.constraint(equalTo: coHereNavigationView.bottomAnchor),
            coHerePasswordRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHerePasswordRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHerePasswordRow.heightAnchor.constraint(equalToConstant: 52),

            coHereFirstSectionGap.topAnchor.constraint(equalTo: coHerePasswordRow.bottomAnchor),
            coHereFirstSectionGap.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereFirstSectionGap.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereFirstSectionGap.heightAnchor.constraint(equalToConstant: 8),

            coHereGestureRow.topAnchor.constraint(equalTo: coHereFirstSectionGap.bottomAnchor),
            coHereGestureRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereGestureRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereGestureRow.heightAnchor.constraint(equalToConstant: 52),

            coHereSecondSectionGap.topAnchor.constraint(equalTo: coHereGestureRow.bottomAnchor),
            coHereSecondSectionGap.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereSecondSectionGap.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereSecondSectionGap.heightAnchor.constraint(equalToConstant: 8),

            coHereDeviceSafeCodeRow.topAnchor.constraint(
                equalTo: coHereSecondSectionGap.bottomAnchor
            ),
            coHereDeviceSafeCodeRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereDeviceSafeCodeRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereDeviceSafeCodeRow.heightAnchor.constraint(equalToConstant: 52),

            coHereThirdSectionGap.topAnchor.constraint(
                equalTo: coHereDeviceSafeCodeRow.bottomAnchor
            ),
            coHereThirdSectionGap.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereThirdSectionGap.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereThirdSectionGap.heightAnchor.constraint(equalToConstant: 8),

            coHereTrustedDevicesRow.topAnchor.constraint(
                equalTo: coHereThirdSectionGap.bottomAnchor
            ),
            coHereTrustedDevicesRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereTrustedDevicesRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereTrustedDevicesRow.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    /// 绑定返回和四个设置行事件。
    private func coHereBindActions() {
        coHereBackButton.addTarget(
            self,
            action: #selector(coHereHandleBackTap),
            for: .touchUpInside
        )
        for row in [
            coHerePasswordRow,
            coHereGestureRow,
            coHereDeviceSafeCodeRow,
            coHereTrustedDevicesRow
        ] {
            row.addTarget(
                self,
                action: #selector(coHereHandleItemTap(_:)),
                for: .touchUpInside
            )
        }
    }

    /// 转发返回点击，不直接处理导航栈。
    @objc private func coHereHandleBackTap() {
        onBackTap?()
    }

    /// 转发设置行对应的固定业务入口。
    /// - Parameter sender: 携带安全设置项的行控件。
    @objc private func coHereHandleItemTap(
        _ sender: CoHereSafeSettingRowControl
    ) {
        onItemTap?(sender.item)
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func coHereLocalized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// 单个安全设置行，负责标题、状态、箭头和整行触摸反馈。
private final class CoHereSafeSettingRowControl: UIControl {

    /// 当前行对应的固定业务入口。
    let item: CoHereSafeSettingItem

    /// 左侧设置项标题。
    private let coHereTitleLabel = UILabel()

    /// 右侧动态开启或关闭状态。
    private let coHereStatusLabel = UILabel()

    /// 复用同一设计系统的灰色右箭头。
    private let coHereChevronView = UIImageView(
        image: UIImage(named: "cohere_system_setting_chevron")
    )

    /// 创建指定业务入口的设置行。
    /// - Parameter item: 当前行对应的安全设置入口。
    init(item: CoHereSafeSettingItem) {
        self.item = item
        super.init(frame: .zero)
        coHereSetupView()
        coHereSetupConstraints()
    }

    /// Storyboard/XIB 不支持缺失固定业务入口的初始化。
    required init?(coder: NSCoder) {
        nil
    }

    /// 更新标题和可选状态文本。
    /// - Parameters:
    ///   - title: 当前语言下的设置项标题。
    ///   - status: 动态开启/关闭状态；修改密码行传 nil。
    func configure(title: String, status: String?) {
        coHereTitleLabel.text = title
        coHereStatusLabel.text = status
        coHereStatusLabel.isHidden = status == nil
        accessibilityLabel = status.map { "\(title)，\($0)" } ?? title
    }

    /// 配置 Figma 字体、主题颜色、箭头和触摸反馈。
    private func coHereSetupView() {
        let lightBackground = UIColor.white
        let darkBackground = UIColor(coHereSafeSettingHex: 0x444444)
        tkThemebackgroundColors = [lightBackground, darkBackground]

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        coHereTitleLabel.tkThemetextColors = [
            UIColor(coHereSafeSettingHex: 0x333333),
            .white
        ]
        addSubview(coHereTitleLabel)

        coHereStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereStatusLabel.font = .systemFont(ofSize: 14, weight: .regular)
        coHereStatusLabel.textAlignment = .right
        coHereStatusLabel.tkThemetextColors = [
            UIColor(coHereSafeSettingHex: 0x999999),
            UIColor(coHereSafeSettingHex: 0xCCCCCC)
        ]
        addSubview(coHereStatusLabel)

        coHereChevronView.translatesAutoresizingMaskIntoConstraints = false
        coHereChevronView.contentMode = .scaleAspectFit
        addSubview(coHereChevronView)

        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    /// 建立标题、状态和箭头的通栏行约束。
    private func coHereSetupConstraints() {
        NSLayoutConstraint.activate([
            coHereTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            coHereTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            coHereTitleLabel.heightAnchor.constraint(equalToConstant: 24),

            coHereChevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            coHereChevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            coHereChevronView.widthAnchor.constraint(equalToConstant: 8),
            coHereChevronView.heightAnchor.constraint(equalToConstant: 16),

            coHereStatusLabel.trailingAnchor.constraint(
                equalTo: coHereChevronView.leadingAnchor,
                constant: -10
            ),
            coHereStatusLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            coHereStatusLabel.heightAnchor.constraint(equalToConstant: 22),
            coHereStatusLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 96),

            coHereTitleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: coHereStatusLabel.leadingAnchor,
                constant: -10
            )
        ])
    }

    /// 在按压期间应用轻量背景反馈，松开后恢复主题背景。
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.72 : 1
        }
    }
}

/// 顶部导航浅紫到白色的 Figma 渐变背景，并保留旧页面暗色主题。
private final class CoHereSafeSettingGradientView: UIView {

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

    /// 根据项目主题切换 Figma 浅色渐变或旧页面暗色背景。
    /// - Parameter isDark: 当前是否为暗色主题。
    func setDarkTheme(_ isDark: Bool) {
        coHereGradientLayer.colors = isDark
            ? [
                UIColor(coHereSafeSettingHex: 0x111111).cgColor,
                UIColor(coHereSafeSettingHex: 0x111111).cgColor
            ]
            : [
                UIColor(coHereSafeSettingHex: 0xF2F1FF).cgColor,
                UIColor.white.cgColor
            ]
    }

    /// 配置渐变方向并应用默认浅色状态。
    private func coHereSetupGradient() {
        coHereGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        coHereGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(coHereGradientLayer, at: 0)
        setDarkTheme(false)
    }
}

extension UIColor {

    /// 将安全设置 Figma 十六进制颜色转换为 UIColor。
    /// - Parameter coHereSafeSettingHex: 0xRRGGBB 格式颜色值。
    convenience init(coHereSafeSettingHex: UInt32) {
        self.init(
            red: CGFloat((coHereSafeSettingHex >> 16) & 0xFF) / 255,
            green: CGFloat((coHereSafeSettingHex >> 8) & 0xFF) / 255,
            blue: CGFloat(coHereSafeSettingHex & 0xFF) / 255,
            alpha: 1
        )
    }
}
