//
//  CoHereSsoHelpPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// Swift 实现的网络设置说明页面，负责多语言文案、主题和滚动布局。
final class CoHereSsoHelpPageView: UIView {

    /// 用户点击左上角返回按钮时触发。
    var onBackTap: (() -> Void)?

    /// 页面返回按钮。
    private let backButton = UIButton(type: .custom)

    /// 页面导航标题。
    private let navigationTitleLabel = UILabel()

    /// 承载长文案并适配小屏幕的滚动视图。
    private let scrollView = UIScrollView()

    /// 滚动视图的内容容器，用于建立完整的 Auto Layout 高度链。
    private let contentView = UIView()

    /// 按顺序排列三个说明分组的垂直容器。
    private let sectionStackView = UIStackView()

    /// 说明分组的数据模型。
    private struct HelpSection {

        /// 分组标题。
        let title: String

        /// 分组正文。
        let content: String
    }

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

    /// 创建导航栏、滚动容器和本地化说明内容。
    private func setupView() {
        backgroundColor = .white
        tkThemebackgroundColors = [
            .white,
            UIColor(coHereSsoHelpHex: 0x111111)
        ]

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "sso_back"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.accessibilityLabel = localized("返回")
        addSubview(backButton)

        navigationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationTitleLabel.text = localized("网络设置说明")
        navigationTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        navigationTitleLabel.textAlignment = .center
        navigationTitleLabel.tkThemetextColors = [
            UIColor(coHereSsoHelpHex: 0x333333),
            .white
        ]
        addSubview(navigationTitleLabel)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.tkThemebackgroundColors = [
            .white,
            UIColor(coHereSsoHelpHex: 0x111111)
        ]
        scrollView.addSubview(contentView)

        sectionStackView.translatesAutoresizingMaskIntoConstraints = false
        sectionStackView.axis = .vertical
        sectionStackView.alignment = .fill
        sectionStackView.spacing = 30
        contentView.addSubview(sectionStackView)

        makeSections().forEach { section in
            sectionStackView.addArrangedSubview(
                makeSectionView(title: section.title, content: section.content)
            )
        }
    }

    /// 建立安全区导航和可滚动正文的完整约束。
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            navigationTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            navigationTitleLabel.centerYAnchor.constraint(
                equalTo: backButton.centerYAnchor
            ),
            navigationTitleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: backButton.trailingAnchor,
                constant: 12
            ),
            navigationTitleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: -56
            ),

            scrollView.topAnchor.constraint(
                equalTo: backButton.bottomAnchor,
                constant: 12
            ),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor
            ),

            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            contentView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),

            sectionStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            sectionStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            sectionStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),
            sectionStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -32
            )
        ])
    }

    /// 绑定返回按钮点击事件。
    private func setupActions() {
        backButton.addTarget(
            self,
            action: #selector(handleBackTap),
            for: .touchUpInside
        )
    }

    /// 创建与原页面顺序和内容一致的本地化说明分组。
    /// - Returns: 三个按展示顺序排列的说明分组。
    private func makeSections() -> [HelpSection] {
        [
            HelpSection(
                title: localized("为什么需要进行网络设置？"),
                content: localized(
                    "可以通过客户端随时随地享受数据服务的存储和管理。服务器归属于私有化部署的经营主体，只有经过经营主体许可的人员才能使用，安全性更高、私密性更强，提供非常好的信息安全服务。"
                )
            ),
            HelpSection(
                title: localized("一、加入服务器"),
                content: localized(
                    "登录账户时需要加入服务器，以便您能精准找到所属企业或服务主体，支持邀请码、域名加入服务器。邀请码、域名需要您与平台客服人员进行联系或者由公司内部人员告知。服务器登录后，需填写账号密码完成登录，第二次登录不需要再次进行邀请码设置。"
                )
            ),
            HelpSection(
                title: localized("二、输入规范"),
                content: localized(
                    "邀请码方式：100000\n域名方式：xxx.com（系统自动匹配http://或https://）"
                )
            )
        ]
    }

    /// 创建一个包含标题和正文的自适应高度说明区域。
    /// - Parameters:
    ///   - title: 当前分组的本地化标题。
    ///   - content: 当前分组的本地化正文。
    /// - Returns: 可加入垂直容器的说明视图。
    private func makeSectionView(title: String, content: String) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.alignment = .fill
        container.spacing = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.tkThemetextColors = [
            UIColor(coHereSsoHelpHex: 0x333333),
            .white
        ]

        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = .systemFont(ofSize: 14, weight: .regular)
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .left
        contentLabel.tkThemetextColors = [
            UIColor(coHereSsoHelpHex: 0x666666),
            UIColor(coHereSsoHelpHex: 0xB3B3B3)
        ]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.lineBreakMode = .byWordWrapping
        contentLabel.attributedText = NSAttributedString(
            string: content,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .paragraphStyle: paragraphStyle
            ]
        )

        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(contentLabel)
        return container
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }

    /// 转发返回按钮点击。
    @objc private func handleBackTap() {
        onBackTap?()
    }
}

private extension UIColor {

    /// 使用 24 位 RGB 色值创建网络设置说明页面颜色。
    /// - Parameters:
    ///   - hex: 0xRRGGBB 格式色值。
    ///   - alpha: 透明度，默认完全不透明。
    convenience init(coHereSsoHelpHex hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
