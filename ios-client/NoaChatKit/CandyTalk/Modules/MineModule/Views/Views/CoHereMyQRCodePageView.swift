//
//  CoHereMyQRCodePageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import SDWebImage
import UIKit

/// CoHere“我的二维码”页面视觉层，按 Figma 呈现真实用户资料和二维码，并将业务操作回传给 Swift 控制器。
@objc(CoHereMyQRCodePageView)
final class CoHereMyQRCodePageView: UIView {

    /// 返回按钮点击回调，由 Swift 控制器执行原有返回逻辑。
    @objc var onBackTap: (() -> Void)?

    /// 保存图片按钮点击回调，由 Swift 控制器执行原有相册保存逻辑。
    @objc var onSaveTap: (() -> Void)?

    /// 分享好友按钮点击回调，由 Swift 控制器执行原有好友选择分享逻辑。
    @objc var onShareTap: (() -> Void)?

    /// 供 Swift 控制器保存、分享方法截取的头像与二维码卡片区域。
    @objc var coHereShareContentView: UIView {
        coHereExportView
    }

    /// 页面纵向滚动容器，兼容高度小于 Figma 812pt 基准的小屏设备。
    private let coHereScrollView = UIScrollView()

    /// 按 375×812pt Figma 基准组织页面元素的内容容器。
    private let coHereContentView = UIView()

    /// 页面淡紫到淡青色背景。
    private let coHereGradientView = CoHereQRCodeGradientView()

    /// 顶部返回按钮，使用 Figma 导出的 20pt 箭头并提供 36pt 点击区域。
    private let coHereBackButton = UIButton(type: .custom)

    /// 顶部居中的“我的二维码”标题。
    private let coHereNavigationTitleLabel = UILabel()

    /// 页面主标题“添加我为好友”。
    private let coHereHeadlineLabel = UILabel()

    /// 标题右侧 80pt Figma 装饰图片。
    private let coHereTopDecorationView = UIImageView()

    /// 白色卡片、头像、二维码及提示文案的可导出容器。
    private let coHereExportView = UIView()

    /// Figma 中高 428pt、圆角 16pt 的白色信息卡片。
    private let coHereCardView = UIView()

    /// 头像后方 88pt 白色圆形 Figma 资源。
    private let coHereAvatarHaloView = UIImageView()

    /// 当前用户 88pt 圆形头像。
    private let coHereAvatarView = UIImageView()

    /// 当前用户昵称。
    private let coHereNicknameLabel = UILabel()

    /// 当前用户账号说明。
    private let coHereAccountLabel = UILabel()

    /// 220pt 二维码展示区域。
    private let coHereQRCodeContainerView = UIView()

    /// Figma 导出的 192.5pt 紫色扫码边框。
    private let coHereQRCodeFrameView = UIImageView()

    /// 根据控制器传入内容生成的 148pt 真实二维码。
    private let coHereQRCodeImageView = UIImageView()

    /// 二维码下方扫码说明。
    private let coHereTipLabel = UILabel()

    /// 卡片右下侧 50pt Figma 装饰图片。
    private let coHereBottomDecorationView = UIImageView()

    /// 左侧保存图片按钮。
    private let coHereSaveButton = UIButton(type: .custom)

    /// 右侧马上分享好友按钮。
    private let coHereShareButton = UIButton(type: .custom)

    /// 内容高度约束，至少保持 Figma 812pt，并在更高设备上填满屏幕。
    private var coHereContentHeightConstraint: NSLayoutConstraint?

    /// 初始化页面并创建 Figma 视图层级。
    /// - Parameter frame: 初始区域，最终尺寸由 Auto Layout 更新。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupView()
        coHereBindActions()
    }

    /// Storyboard 初始化入口，保持和代码初始化一致的页面结构。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView()
        coHereBindActions()
    }

    /// 根据当前设备高度刷新滚动内容尺寸，小屏可滚动，大屏背景完整铺满。
    override func layoutSubviews() {
        super.layoutSubviews()
        coHereContentHeightConstraint?.constant = max(812, bounds.height)
    }

    /// 使用 Swift 控制器现有数据刷新头像、昵称、账号和二维码。
    /// - Parameters:
    ///   - avatarURL: 用户头像完整地址；为空时使用项目默认头像。
    ///   - nickname: 当前用户昵称。
    ///   - account: 当前用户账号，不包含展示前缀。
    ///   - qrCodeImage: 由项目现有二维码生成逻辑创建的图片。
    @objc(configureWithAvatarURL:nickname:account:qrCodeImage:)
    func coHereConfigure(
        avatarURL: URL?,
        nickname: String,
        account: String,
        qrCodeImage: UIImage
    ) {
        coHereAvatarView.sd_setImage(
            with: avatarURL,
            placeholderImage: UIImage(named: "c_avatar_icon"),
            options: .allowInvalidSSLCertificates
        )
        coHereNicknameLabel.text = nickname
        coHereAccountLabel.text = String(
            format: coHereLocalized("我的账号：%@"),
            account
        )
        coHereQRCodeImageView.image = qrCodeImage
    }

    /// 创建滚动区域、导航区、二维码卡片和底部操作按钮。
    private func coHereSetupView() {
        backgroundColor = UIColor(coHereQRCodeHex: 0xF6F5FF)

        coHereScrollView.translatesAutoresizingMaskIntoConstraints = false
        coHereScrollView.contentInsetAdjustmentBehavior = .never
        coHereScrollView.showsVerticalScrollIndicator = false
        coHereScrollView.alwaysBounceVertical = false
        addSubview(coHereScrollView)

        coHereContentView.translatesAutoresizingMaskIntoConstraints = false
        coHereScrollView.addSubview(coHereContentView)

        coHereGradientView.translatesAutoresizingMaskIntoConstraints = false
        coHereContentView.addSubview(coHereGradientView)

        coHereConfigureNavigation()
        coHereConfigureHeadline()
        coHereConfigureExportContent()
        coHereConfigureButtons()

        coHereContentHeightConstraint = coHereContentView.heightAnchor.constraint(equalToConstant: 812)
        coHereContentHeightConstraint?.priority = .required

        NSLayoutConstraint.activate([
            coHereScrollView.topAnchor.constraint(equalTo: topAnchor),
            coHereScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            coHereContentView.topAnchor.constraint(equalTo: coHereScrollView.contentLayoutGuide.topAnchor),
            coHereContentView.leadingAnchor.constraint(equalTo: coHereScrollView.contentLayoutGuide.leadingAnchor),
            coHereContentView.trailingAnchor.constraint(equalTo: coHereScrollView.contentLayoutGuide.trailingAnchor),
            coHereContentView.bottomAnchor.constraint(equalTo: coHereScrollView.contentLayoutGuide.bottomAnchor),
            coHereContentView.widthAnchor.constraint(equalTo: coHereScrollView.frameLayoutGuide.widthAnchor),
            coHereContentHeightConstraint!,

            coHereGradientView.topAnchor.constraint(equalTo: coHereContentView.topAnchor),
            coHereGradientView.leadingAnchor.constraint(equalTo: coHereContentView.leadingAnchor),
            coHereGradientView.trailingAnchor.constraint(equalTo: coHereContentView.trailingAnchor),
            coHereGradientView.bottomAnchor.constraint(equalTo: coHereContentView.bottomAnchor)
        ])
    }

    /// 配置 Figma 顶部返回按钮和居中导航标题。
    private func coHereConfigureNavigation() {
        coHereBackButton.translatesAutoresizingMaskIntoConstraints = false
        coHereBackButton.setImage(UIImage(named: "cohere_qrcode_back"), for: .normal)
        coHereBackButton.imageView?.contentMode = .scaleAspectFit
        coHereContentView.addSubview(coHereBackButton)

        coHereNavigationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereNavigationTitleLabel.font = CoHereQRCodeFont.semibold(size: 16)
        coHereNavigationTitleLabel.textColor = UIColor(coHereQRCodeHex: 0x333333)
        coHereNavigationTitleLabel.textAlignment = .center
        coHereNavigationTitleLabel.text = coHereLocalized("我的二维码")
        coHereContentView.addSubview(coHereNavigationTitleLabel)

        NSLayoutConstraint.activate([
            coHereBackButton.leadingAnchor.constraint(equalTo: coHereContentView.leadingAnchor, constant: 8),
            coHereBackButton.topAnchor.constraint(equalTo: coHereContentView.topAnchor, constant: 52),
            coHereBackButton.widthAnchor.constraint(equalToConstant: 36),
            coHereBackButton.heightAnchor.constraint(equalToConstant: 36),

            coHereNavigationTitleLabel.centerXAnchor.constraint(equalTo: coHereContentView.centerXAnchor),
            coHereNavigationTitleLabel.topAnchor.constraint(equalTo: coHereContentView.topAnchor, constant: 58),
            coHereNavigationTitleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    /// 配置页面主标题和标题旁的 80pt 装饰图片。
    private func coHereConfigureHeadline() {
        coHereHeadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereHeadlineLabel.font = CoHereQRCodeFont.heavy(size: 24)
        coHereHeadlineLabel.textColor = UIColor(coHereQRCodeHex: 0x5C6FFF)
        coHereHeadlineLabel.textAlignment = .center
        coHereHeadlineLabel.text = coHereLocalized("添加我为好友")
        coHereContentView.addSubview(coHereHeadlineLabel)

        coHereTopDecorationView.translatesAutoresizingMaskIntoConstraints = false
        coHereTopDecorationView.image = UIImage(named: "cohere_qrcode_decor")
        coHereTopDecorationView.contentMode = .scaleAspectFit
        coHereTopDecorationView.alpha = 0.5
        coHereContentView.addSubview(coHereTopDecorationView)

        NSLayoutConstraint.activate([
            coHereHeadlineLabel.centerXAnchor.constraint(equalTo: coHereContentView.centerXAnchor),
            coHereHeadlineLabel.topAnchor.constraint(equalTo: coHereContentView.topAnchor, constant: 114),
            coHereHeadlineLabel.heightAnchor.constraint(equalToConstant: 26),

            coHereTopDecorationView.trailingAnchor.constraint(equalTo: coHereContentView.trailingAnchor, constant: -20),
            coHereTopDecorationView.topAnchor.constraint(equalTo: coHereContentView.topAnchor, constant: 127),
            coHereTopDecorationView.widthAnchor.constraint(equalToConstant: 80),
            coHereTopDecorationView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    /// 配置可导出的白色卡片、真实用户资料、二维码和说明文案。
    private func coHereConfigureExportContent() {
        coHereExportView.translatesAutoresizingMaskIntoConstraints = false
        coHereExportView.backgroundColor = .clear
        coHereContentView.addSubview(coHereExportView)

        coHereCardView.translatesAutoresizingMaskIntoConstraints = false
        coHereCardView.backgroundColor = .white
        coHereCardView.layer.cornerRadius = 16
        coHereCardView.layer.masksToBounds = true
        coHereExportView.addSubview(coHereCardView)

        coHereAvatarHaloView.translatesAutoresizingMaskIntoConstraints = false
        coHereAvatarHaloView.image = UIImage(named: "cohere_qrcode_avatar_halo")
        coHereAvatarHaloView.contentMode = .scaleAspectFit
        coHereExportView.addSubview(coHereAvatarHaloView)

        coHereAvatarView.translatesAutoresizingMaskIntoConstraints = false
        coHereAvatarView.contentMode = .scaleAspectFill
        coHereAvatarView.layer.cornerRadius = 44
        coHereAvatarView.layer.masksToBounds = true
        coHereExportView.addSubview(coHereAvatarView)

        coHereNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereNicknameLabel.font = CoHereQRCodeFont.heavy(size: 20)
        coHereNicknameLabel.textColor = .black
        coHereNicknameLabel.textAlignment = .center
        coHereNicknameLabel.lineBreakMode = .byTruncatingTail
        coHereExportView.addSubview(coHereNicknameLabel)

        coHereAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereAccountLabel.font = CoHereQRCodeFont.medium(size: 14)
        coHereAccountLabel.textColor = UIColor(coHereQRCodeHex: 0x999999)
        coHereAccountLabel.textAlignment = .center
        coHereAccountLabel.lineBreakMode = .byTruncatingMiddle
        coHereExportView.addSubview(coHereAccountLabel)

        coHereConfigureQRCode()

        coHereTipLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTipLabel.font = CoHereQRCodeFont.semibold(size: 16)
        coHereTipLabel.textColor = UIColor(coHereQRCodeHex: 0x333333)
        coHereTipLabel.textAlignment = .center
        coHereTipLabel.text = coHereLocalized("扫一扫我的二维码，添加我为好友")
        coHereTipLabel.adjustsFontSizeToFitWidth = true
        coHereTipLabel.minimumScaleFactor = 0.8
        coHereExportView.addSubview(coHereTipLabel)

        coHereBottomDecorationView.translatesAutoresizingMaskIntoConstraints = false
        coHereBottomDecorationView.image = UIImage(named: "cohere_qrcode_decor")
        coHereBottomDecorationView.contentMode = .scaleAspectFit
        coHereBottomDecorationView.alpha = 0.5
        coHereContentView.addSubview(coHereBottomDecorationView)

        NSLayoutConstraint.activate([
            coHereExportView.leadingAnchor.constraint(equalTo: coHereContentView.leadingAnchor, constant: 20),
            coHereExportView.trailingAnchor.constraint(equalTo: coHereContentView.trailingAnchor, constant: -20),
            coHereExportView.topAnchor.constraint(equalTo: coHereContentView.topAnchor, constant: 180),
            coHereExportView.heightAnchor.constraint(equalToConstant: 477),

            coHereCardView.leadingAnchor.constraint(equalTo: coHereExportView.leadingAnchor),
            coHereCardView.trailingAnchor.constraint(equalTo: coHereExportView.trailingAnchor),
            coHereCardView.topAnchor.constraint(equalTo: coHereExportView.topAnchor, constant: 49),
            coHereCardView.heightAnchor.constraint(equalToConstant: 428),

            coHereAvatarHaloView.centerXAnchor.constraint(equalTo: coHereExportView.centerXAnchor, constant: 2),
            coHereAvatarHaloView.topAnchor.constraint(equalTo: coHereExportView.topAnchor),
            coHereAvatarHaloView.widthAnchor.constraint(equalToConstant: 88),
            coHereAvatarHaloView.heightAnchor.constraint(equalToConstant: 88),

            coHereAvatarView.centerXAnchor.constraint(equalTo: coHereExportView.centerXAnchor),
            coHereAvatarView.topAnchor.constraint(equalTo: coHereExportView.topAnchor, constant: 3),
            coHereAvatarView.widthAnchor.constraint(equalToConstant: 88),
            coHereAvatarView.heightAnchor.constraint(equalToConstant: 88),

            coHereNicknameLabel.leadingAnchor.constraint(equalTo: coHereExportView.leadingAnchor, constant: 20),
            coHereNicknameLabel.trailingAnchor.constraint(equalTo: coHereExportView.trailingAnchor, constant: -20),
            coHereNicknameLabel.topAnchor.constraint(equalTo: coHereExportView.topAnchor, constant: 109),
            coHereNicknameLabel.heightAnchor.constraint(equalToConstant: 26),

            coHereAccountLabel.leadingAnchor.constraint(equalTo: coHereExportView.leadingAnchor, constant: 20),
            coHereAccountLabel.trailingAnchor.constraint(equalTo: coHereExportView.trailingAnchor, constant: -20),
            coHereAccountLabel.topAnchor.constraint(equalTo: coHereExportView.topAnchor, constant: 139),
            coHereAccountLabel.heightAnchor.constraint(equalToConstant: 22),

            coHereQRCodeContainerView.centerXAnchor.constraint(equalTo: coHereExportView.centerXAnchor),
            coHereQRCodeContainerView.topAnchor.constraint(equalTo: coHereExportView.topAnchor, constant: 168),
            coHereQRCodeContainerView.widthAnchor.constraint(equalToConstant: 220),
            coHereQRCodeContainerView.heightAnchor.constraint(equalToConstant: 220),

            coHereTipLabel.leadingAnchor.constraint(equalTo: coHereExportView.leadingAnchor, constant: 20),
            coHereTipLabel.trailingAnchor.constraint(equalTo: coHereExportView.trailingAnchor, constant: -20),
            coHereTipLabel.topAnchor.constraint(equalTo: coHereExportView.topAnchor, constant: 413),
            coHereTipLabel.heightAnchor.constraint(equalToConstant: 24),

            coHereBottomDecorationView.trailingAnchor.constraint(equalTo: coHereContentView.trailingAnchor, constant: 5),
            coHereBottomDecorationView.topAnchor.constraint(equalTo: coHereContentView.topAnchor, constant: 623),
            coHereBottomDecorationView.widthAnchor.constraint(equalToConstant: 50),
            coHereBottomDecorationView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    /// 配置 220pt 扫码区，并分别约束 192.5pt Figma 边框和 148pt 动态二维码。
    private func coHereConfigureQRCode() {
        coHereQRCodeContainerView.translatesAutoresizingMaskIntoConstraints = false
        coHereExportView.addSubview(coHereQRCodeContainerView)

        coHereQRCodeFrameView.translatesAutoresizingMaskIntoConstraints = false
        coHereQRCodeFrameView.image = UIImage(named: "cohere_qrcode_frame")
        coHereQRCodeFrameView.contentMode = .scaleAspectFit
        coHereQRCodeContainerView.addSubview(coHereQRCodeFrameView)

        coHereQRCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        coHereQRCodeImageView.contentMode = .scaleAspectFit
        coHereQRCodeContainerView.addSubview(coHereQRCodeImageView)

        NSLayoutConstraint.activate([
            coHereQRCodeFrameView.centerXAnchor.constraint(equalTo: coHereQRCodeContainerView.centerXAnchor, constant: 0.25),
            coHereQRCodeFrameView.centerYAnchor.constraint(equalTo: coHereQRCodeContainerView.centerYAnchor, constant: 0.25),
            coHereQRCodeFrameView.widthAnchor.constraint(equalToConstant: 192.5),
            coHereQRCodeFrameView.heightAnchor.constraint(equalToConstant: 192.5),

            coHereQRCodeImageView.centerXAnchor.constraint(equalTo: coHereQRCodeContainerView.centerXAnchor),
            coHereQRCodeImageView.centerYAnchor.constraint(equalTo: coHereQRCodeContainerView.centerYAnchor),
            coHereQRCodeImageView.widthAnchor.constraint(equalToConstant: 148),
            coHereQRCodeImageView.heightAnchor.constraint(equalToConstant: 148)
        ])
    }

    /// 配置 Figma 的 120×44pt 保存按钮和 180×44pt 分享按钮。
    private func coHereConfigureButtons() {
        coHereSaveButton.translatesAutoresizingMaskIntoConstraints = false
        coHereSaveButton.backgroundColor = .white
        coHereSaveButton.layer.cornerRadius = 8
        coHereSaveButton.setTitle(coHereLocalized("保存图片"), for: .normal)
        coHereSaveButton.setTitleColor(UIColor(coHereQRCodeHex: 0x6C63FF), for: .normal)
        coHereSaveButton.titleLabel?.font = CoHereQRCodeFont.medium(size: 16)
        coHereContentView.addSubview(coHereSaveButton)

        coHereShareButton.translatesAutoresizingMaskIntoConstraints = false
        coHereShareButton.backgroundColor = UIColor(coHereQRCodeHex: 0x6C63FF)
        coHereShareButton.layer.cornerRadius = 8
        coHereShareButton.setTitle(coHereLocalized("马上分享好友"), for: .normal)
        coHereShareButton.setTitleColor(.white, for: .normal)
        coHereShareButton.titleLabel?.font = CoHereQRCodeFont.medium(size: 16)
        coHereContentView.addSubview(coHereShareButton)

        NSLayoutConstraint.activate([
            coHereSaveButton.leadingAnchor.constraint(equalTo: coHereContentView.leadingAnchor, constant: 20),
            coHereSaveButton.topAnchor.constraint(equalTo: coHereContentView.topAnchor, constant: 689),
            coHereSaveButton.widthAnchor.constraint(equalToConstant: 120),
            coHereSaveButton.heightAnchor.constraint(equalToConstant: 44),

            coHereShareButton.trailingAnchor.constraint(equalTo: coHereContentView.trailingAnchor, constant: -20),
            coHereShareButton.topAnchor.constraint(equalTo: coHereContentView.topAnchor, constant: 689),
            coHereShareButton.widthAnchor.constraint(equalToConstant: 180),
            coHereShareButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    /// 绑定三个按钮，并只通过回调转发到迁移后的原业务功能。
    private func coHereBindActions() {
        coHereBackButton.addTarget(self, action: #selector(coHereBackTapped), for: .touchUpInside)
        coHereSaveButton.addTarget(self, action: #selector(coHereSaveTapped), for: .touchUpInside)
        coHereShareButton.addTarget(self, action: #selector(coHereShareTapped), for: .touchUpInside)
    }

    /// 转发返回点击。
    @objc private func coHereBackTapped() {
        onBackTap?()
    }

    /// 转发保存图片点击。
    @objc private func coHereSaveTapped() {
        onSaveTap?()
    }

    /// 转发马上分享好友点击。
    @objc private func coHereShareTapped() {
        onShareTap?()
    }

    /// 使用项目现有语言管理器读取本地化文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前应用语言对应的显示文案。
    private func coHereLocalized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// CoHere 二维码页面使用的三段式 Figma 渐变背景。
private final class CoHereQRCodeGradientView: UIView {

    /// 当前视图直接使用 CAGradientLayer 作为 backing layer。
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    /// 初始化 Figma 渐变。
    /// - Parameter frame: 初始区域。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereConfigureGradient()
    }

    /// Storyboard 初始化入口。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereConfigureGradient()
    }

    /// 配置 Figma 的淡紫、浅紫和淡青渐变色及方向。
    private func coHereConfigureGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        gradientLayer.colors = [
            UIColor(coHereQRCodeHex: 0xF6F5FF).cgColor,
            UIColor(coHereQRCodeHex: 0xEBE8FD).cgColor,
            UIColor(coHereQRCodeHex: 0xE5F5F5).cgColor
        ]
        gradientLayer.locations = [0.0094, 0.5952, 1]
        gradientLayer.startPoint = CGPoint(x: 0.18, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.82, y: 1)
    }
}

/// 集中提供 Figma 指定的 PingFang SC 字重，并为异常字体环境保留系统字体回退。
private enum CoHereQRCodeFont {

    /// 返回 PingFang SC Medium。
    /// - Parameter size: 字号。
    /// - Returns: 指定字号的字体。
    static func medium(size: CGFloat) -> UIFont {
        UIFont(name: "PingFangSC-Medium", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }

    /// 返回 PingFang SC Semibold。
    /// - Parameter size: 字号。
    /// - Returns: 指定字号的字体。
    static func semibold(size: CGFloat) -> UIFont {
        UIFont(name: "PingFangSC-Semibold", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    /// 返回 PingFang SC Heavy。
    /// - Parameter size: 字号。
    /// - Returns: 指定字号的字体。
    static func heavy(size: CGFloat) -> UIFont {
        UIFont(name: "PingFangSC-Heavy", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .heavy)
    }
}

/// CoHere 二维码页面使用的十六进制颜色初始化方法。
private extension UIColor {

    /// 由 0xRRGGBB 创建不透明颜色。
    /// - Parameter value: 六位 RGB 整数。
    convenience init(coHereQRCodeHex value: UInt32) {
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
