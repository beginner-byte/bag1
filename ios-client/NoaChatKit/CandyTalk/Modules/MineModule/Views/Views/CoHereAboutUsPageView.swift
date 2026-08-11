//
//  CoHereAboutUsPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// “关于我们”页面支持的协议类型。
enum CoHereAboutUsPolicy: Int {

    /// 服务协议。
    case service = 0

    /// 隐私政策。
    case privacy = 1
}

/// Swift 原生“关于我们”视觉层，负责 Logo、版本和协议入口布局。
final class CoHereAboutUsPageView: UIView {

    /// 用户点击协议行时触发，并携带稳定协议类型。
    var onPolicyTap: ((CoHereAboutUsPolicy) -> Void)?

    /// App 品牌 Logo，复用现有明暗主题图片资源。
    private let logoImageView = UIImageView()

    /// 当前 App 版本与构建号。
    private let versionLabel = UILabel()

    /// 承载两个协议入口的圆角卡片。
    private let policyCardView = UIView()

    /// 服务协议整行点击控件。
    private let servicePolicyRow = UIControl()

    /// 隐私政策整行点击控件。
    private let privacyPolicyRow = UIControl()

    /// 两个协议入口之间的分隔线。
    private let separatorView = UIView()

    /// 使用代码布局创建页面。
    /// - Parameter frame: 页面初始尺寸。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupActions()
    }

    /// Storyboard 初始化入口，当前项目未使用。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
        setupActions()
    }

    /// 使用控制器提供的版本信息刷新版本标签。
    /// - Parameter versionText: 已完成本地化的版本号与构建号。
    func configure(versionText: String) {
        versionLabel.text = versionText
    }

    /// 创建 Logo、版本标签和两个原生协议入口，并接入现有主题。
    private func setupView() {
        let pageLightColor = UIColor(coHereAboutUsHex: 0xF5F6F9)
        let pageDarkColor = UIColor(coHereAboutUsHex: 0x111111)
        backgroundColor = pageLightColor
        tkThemebackgroundColors = [pageLightColor, pageDarkColor]

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "img_login_logo")
        logoImageView.contentMode = .scaleAspectFit
        addSubview(logoImageView)

        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        versionLabel.textAlignment = .center
        versionLabel.tkThemetextColors = [
            UIColor(coHereAboutUsHex: 0x666666),
            UIColor(coHereAboutUsHex: 0xCCCCCC)
        ]
        addSubview(versionLabel)

        policyCardView.translatesAutoresizingMaskIntoConstraints = false
        policyCardView.layer.cornerRadius = 12
        policyCardView.layer.masksToBounds = true
        policyCardView.tkThemebackgroundColors = [
            .white,
            UIColor(coHereAboutUsHex: 0x333333)
        ]
        addSubview(policyCardView)

        configurePolicyRow(
            servicePolicyRow,
            title: localized("服务协议")
        )
        configurePolicyRow(
            privacyPolicyRow,
            title: localized("隐私政策")
        )

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.tkThemebackgroundColors = [
            UIColor(coHereAboutUsHex: 0xE5E5E5),
            UIColor(coHereAboutUsHex: 0x555555)
        ]
        policyCardView.addSubview(separatorView)
    }

    /// 建立与旧页面一致的 Logo、版本和 100pt 协议卡片布局。
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 82),
            logoImageView.heightAnchor.constraint(equalToConstant: 82),

            versionLabel.topAnchor.constraint(
                equalTo: logoImageView.bottomAnchor,
                constant: 16
            ),
            versionLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 10
            ),
            versionLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -10
            ),
            versionLabel.heightAnchor.constraint(equalToConstant: 22),

            policyCardView.topAnchor.constraint(
                equalTo: versionLabel.bottomAnchor,
                constant: 16
            ),
            policyCardView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            policyCardView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            policyCardView.heightAnchor.constraint(equalToConstant: 100),

            servicePolicyRow.topAnchor.constraint(
                equalTo: policyCardView.topAnchor,
                constant: 6
            ),
            servicePolicyRow.leadingAnchor.constraint(
                equalTo: policyCardView.leadingAnchor
            ),
            servicePolicyRow.trailingAnchor.constraint(
                equalTo: policyCardView.trailingAnchor
            ),
            servicePolicyRow.heightAnchor.constraint(equalToConstant: 44),

            separatorView.topAnchor.constraint(
                equalTo: servicePolicyRow.bottomAnchor
            ),
            separatorView.leadingAnchor.constraint(
                equalTo: policyCardView.leadingAnchor,
                constant: 16
            ),
            separatorView.trailingAnchor.constraint(
                equalTo: policyCardView.trailingAnchor
            ),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),

            privacyPolicyRow.topAnchor.constraint(
                equalTo: separatorView.bottomAnchor
            ),
            privacyPolicyRow.leadingAnchor.constraint(
                equalTo: policyCardView.leadingAnchor
            ),
            privacyPolicyRow.trailingAnchor.constraint(
                equalTo: policyCardView.trailingAnchor
            ),
            privacyPolicyRow.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    /// 绑定两个协议行的点击事件。
    private func setupActions() {
        servicePolicyRow.addTarget(
            self,
            action: #selector(handleServicePolicyTap),
            for: .touchUpInside
        )
        privacyPolicyRow.addTarget(
            self,
            action: #selector(handlePrivacyPolicyTap),
            for: .touchUpInside
        )
    }

    /// 配置一个包含本地化标题和右箭头的协议入口。
    /// - Parameters:
    ///   - row: 需要配置的整行点击控件。
    ///   - title: 当前语言下的协议标题。
    private func configurePolicyRow(_ row: UIControl, title: String) {
        row.translatesAutoresizingMaskIntoConstraints = false
        row.accessibilityLabel = title
        row.accessibilityTraits = .button
        policyCardView.addSubview(row)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.tkThemetextColors = [
            UIColor(coHereAboutUsHex: 0x333333),
            .white
        ]
        row.addSubview(titleLabel)

        let arrowImageView = UIImageView(
            image: UIImage(named: "c_arrow_right_gray")
        )
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.contentMode = .scaleAspectFit
        row.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: row.leadingAnchor,
                constant: 12
            ),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: arrowImageView.leadingAnchor,
                constant: -12
            ),

            arrowImageView.trailingAnchor.constraint(
                equalTo: row.trailingAnchor,
                constant: -12
            ),
            arrowImageView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    /// 转发服务协议点击。
    @objc private func handleServicePolicyTap() {
        onPolicyTap?(.service)
    }

    /// 转发隐私政策点击。
    @objc private func handlePrivacyPolicyTap() {
        onPolicyTap?(.privacy)
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

private extension UIColor {

    /// 使用 24 位 RGB 色值创建“关于我们”页面颜色。
    /// - Parameters:
    ///   - hex: 0xRRGGBB 格式色值。
    ///   - alpha: 透明度，默认完全不透明。
    convenience init(coHereAboutUsHex hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
