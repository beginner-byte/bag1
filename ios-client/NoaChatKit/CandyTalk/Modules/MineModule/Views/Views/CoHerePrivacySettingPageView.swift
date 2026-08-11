//
//  CoHerePrivacySettingPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// 按照 Figma“隐私设置”节点实现的 Swift 视觉层；用户状态和接口由 Swift 控制器负责。
@objc(CoHerePrivacySettingPageView)
final class CoHerePrivacySettingPageView: UIView {

    /// 点击返回按钮后的业务回调。
    @objc var onBackTap: (() -> Void)?

    /// 点击离线时长设置行后的业务回调。
    @objc var onOfflineDurationTap: (() -> Void)?

    /// 顶部状态栏与导航内容的浅紫到白色渐变背景。
    private let coHereNavigationView = CoHerePrivacySettingGradientView()

    /// 返回按钮，复用同一设计系统已有图标并保留 36pt 点击区域。
    private let coHereBackButton = UIButton(type: .custom)

    /// 页面居中的导航标题。
    private let coHereTitleLabel = UILabel()

    /// 离线时长整行点击控件，保持旧页面整行可触发的交互。
    private let coHereOfflineDurationRow = UIControl()

    /// 离线时长设置项标题。
    private let coHereOfflineDurationTitleLabel = UILabel()

    /// 关闭离线时长后的业务说明。
    private let coHereOfflineDurationDescriptionLabel = UILabel()

    /// 展示服务器确认状态的系统开关；事件由整行控件统一转发。
    private let coHereOfflineDurationSwitch = UISwitch()

    /// 创建隐私设置视觉层并完成控件、约束和事件初始化。
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

    /// 使用服务器确认的离线时长状态刷新开关，不触发业务回调。
    /// - Parameter isOfflineDurationVisible: 是否向其他用户展示离线时长。
    func configure(isOfflineDurationVisible: Bool) {
        coHereOfflineDurationSwitch.setOn(
            isOfflineDurationVisible,
            animated: false
        )
        coHereOfflineDurationRow.accessibilityValue = coHereLocalized(
            isOfflineDurationVisible ? "开启" : "关闭"
        )
    }

    /// 创建 Figma 导航和单条隐私设置项，并接入现有明暗主题。
    private func coHereSetupView() {
        let pageLightColor = UIColor(coHerePrivacySettingHex: 0xF5F5F5)
        let pageDarkColor = UIColor(coHerePrivacySettingHex: 0x111111)
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
        coHereTitleLabel.text = coHereLocalized("隐私设置")
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coHereTitleLabel.textAlignment = .center
        coHereTitleLabel.tkThemetextColors = [
            UIColor(coHerePrivacySettingHex: 0x333333),
            .white
        ]
        addSubview(coHereTitleLabel)

        coHereOfflineDurationRow.translatesAutoresizingMaskIntoConstraints = false
        coHereOfflineDurationRow.tkThemebackgroundColors = [
            .white,
            UIColor(coHerePrivacySettingHex: 0x444444)
        ]
        coHereOfflineDurationRow.isAccessibilityElement = true
        coHereOfflineDurationRow.accessibilityTraits = .button
        coHereOfflineDurationRow.accessibilityLabel = coHereLocalized("离线时长")
        addSubview(coHereOfflineDurationRow)

        coHereOfflineDurationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereOfflineDurationTitleLabel.text = coHereLocalized("离线时长")
        coHereOfflineDurationTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        coHereOfflineDurationTitleLabel.tkThemetextColors = [
            UIColor(coHerePrivacySettingHex: 0x333333),
            .white
        ]
        coHereOfflineDurationRow.addSubview(coHereOfflineDurationTitleLabel)

        coHereOfflineDurationDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereOfflineDurationDescriptionLabel.text = coHereLocalized(
            "关闭后，不展示离线时长"
        )
        coHereOfflineDurationDescriptionLabel.font = .systemFont(
            ofSize: 12,
            weight: .regular
        )
        coHereOfflineDurationDescriptionLabel.tkThemetextColors = [
            UIColor(coHerePrivacySettingHex: 0x999999),
            UIColor(coHerePrivacySettingHex: 0xCCCCCC)
        ]
        coHereOfflineDurationRow.addSubview(
            coHereOfflineDurationDescriptionLabel
        )

        coHereOfflineDurationSwitch.translatesAutoresizingMaskIntoConstraints = false
        coHereOfflineDurationSwitch.onTintColor = UIColor(
            coHerePrivacySettingHex: 0x6857F5
        )
        coHereOfflineDurationSwitch.isUserInteractionEnabled = false
        coHereOfflineDurationRow.addSubview(coHereOfflineDurationSwitch)

        tkThemeChangeBlock = { [weak self] _, themeIndex in
            self?.coHereNavigationView.setDarkTheme(themeIndex != 0)
        }
    }

    /// 建立与 375×812 Figma 基准一致并适配设备安全区的导航和 74pt 设置行约束。
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

            coHereOfflineDurationRow.topAnchor.constraint(
                equalTo: coHereNavigationView.bottomAnchor
            ),
            coHereOfflineDurationRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereOfflineDurationRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereOfflineDurationRow.heightAnchor.constraint(equalToConstant: 74),

            coHereOfflineDurationTitleLabel.leadingAnchor.constraint(
                equalTo: coHereOfflineDurationRow.leadingAnchor,
                constant: 16
            ),
            coHereOfflineDurationTitleLabel.topAnchor.constraint(
                equalTo: coHereOfflineDurationRow.topAnchor,
                constant: 14
            ),
            coHereOfflineDurationTitleLabel.heightAnchor.constraint(equalToConstant: 24),

            coHereOfflineDurationDescriptionLabel.leadingAnchor.constraint(
                equalTo: coHereOfflineDurationTitleLabel.leadingAnchor
            ),
            coHereOfflineDurationDescriptionLabel.topAnchor.constraint(
                equalTo: coHereOfflineDurationTitleLabel.bottomAnchor,
                constant: 2
            ),
            coHereOfflineDurationDescriptionLabel.heightAnchor.constraint(
                equalToConstant: 18
            ),

            coHereOfflineDurationSwitch.trailingAnchor.constraint(
                equalTo: coHereOfflineDurationRow.trailingAnchor,
                constant: -16
            ),
            coHereOfflineDurationSwitch.centerYAnchor.constraint(
                equalTo: coHereOfflineDurationRow.centerYAnchor
            ),

            coHereOfflineDurationTitleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: coHereOfflineDurationSwitch.leadingAnchor,
                constant: -12
            ),
            coHereOfflineDurationDescriptionLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: coHereOfflineDurationSwitch.leadingAnchor,
                constant: -12
            )
        ])
    }

    /// 绑定返回按钮和离线时长整行触摸事件。
    private func coHereBindActions() {
        coHereBackButton.addTarget(
            self,
            action: #selector(coHereHandleBackTap),
            for: .touchUpInside
        )
        coHereOfflineDurationRow.addTarget(
            self,
            action: #selector(coHereHandleOfflineDurationTap),
            for: .touchUpInside
        )
    }

    /// 转发返回点击，不直接处理导航栈。
    @objc private func coHereHandleBackTap() {
        onBackTap?()
    }

    /// 转发离线时长设置项点击，由控制器执行原切换接口。
    @objc private func coHereHandleOfflineDurationTap() {
        onOfflineDurationTap?()
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func coHereLocalized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// 顶部导航浅紫到白色的 Figma 渐变背景，并保留旧页面暗色主题。
private final class CoHerePrivacySettingGradientView: UIView {

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
                UIColor(coHerePrivacySettingHex: 0x111111).cgColor,
                UIColor(coHerePrivacySettingHex: 0x111111).cgColor
            ]
            : [
                UIColor(coHerePrivacySettingHex: 0xF2F1FF).cgColor,
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

    /// 将隐私设置 Figma 十六进制颜色转换为 UIColor。
    /// - Parameter coHerePrivacySettingHex: 0xRRGGBB 格式颜色值。
    convenience init(coHerePrivacySettingHex: UInt32) {
        self.init(
            red: CGFloat((coHerePrivacySettingHex >> 16) & 0xFF) / 255,
            green: CGFloat((coHerePrivacySettingHex >> 8) & 0xFF) / 255,
            blue: CGFloat(coHerePrivacySettingHex & 0xFF) / 255,
            alpha: 1
        )
    }
}
