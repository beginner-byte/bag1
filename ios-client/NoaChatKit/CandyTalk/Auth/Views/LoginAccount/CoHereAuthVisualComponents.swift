//
//  CoHereAuthVisualComponents.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/28.
//

import UIKit

/// 统一实现 CoHere 认证页面输入框的背景、边框、图标和可插拔前后区域。
final class CoHereAuthFieldView: UIView {

    /// 实际文本输入控件。
    let textField = UITextField()

    /// 图文验证码专用预览按钮，普通输入框保持为空。
    weak var captchaPreviewButton: CoHereAuthCaptchaPreviewButton?

    /// 左侧认证场景图标。
    private let iconView = UIImageView()

    /// 左侧可选业务区域，例如手机区号。
    private var prefixView: UIView?

    /// 左侧业务区域宽度约束。
    private var prefixWidthConstraint: NSLayoutConstraint?

    /// 右侧可选操作区域，例如眼睛按钮。
    private var trailingView: UIView?

    /// 右侧操作区域宽度约束。
    private var trailingWidthConstraint: NSLayoutConstraint?

    /// 文本框右侧动态约束。
    private var textTrailingConstraint: NSLayoutConstraint?

    /// 文本框左侧动态约束，手机号方式下改为跟随区号区域。
    private var textLeadingConstraint: NSLayoutConstraint?

    /// 初始化输入容器的基础视觉样式。
    /// - Parameter frame: 初始区域。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    /// Storyboard 初始化当前未使用。
    /// - Parameter coder: 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    /// 更新输入框图标和占位文本。
    /// - Parameters:
    ///   - icon: 当前认证场景的左侧图标。
    ///   - placeholder: 本地化后的占位文字。
    func configure(icon: UIImage?, placeholder: String) {
        iconView.image = icon
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(coHereHex: 0x94A3B8),
                .font: UIFont.systemFont(ofSize: 14)
            ]
        )
    }

    /// 设置左侧业务区域。
    /// - Parameters:
    ///   - view: 区号等业务视图；nil 表示移除。
    ///   - width: 业务区域固定宽度，单位为点。
    func setPrefixView(_ view: UIView?, width: CGFloat) {
        prefixView?.removeFromSuperview()
        prefixView = view
        prefixWidthConstraint?.isActive = false
        textLeadingConstraint?.isActive = false

        guard let view else {
            iconView.isHidden = false
            let leading = textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10)
            textLeadingConstraint = leading
            leading.isActive = true
            return
        }

        iconView.isHidden = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let widthConstraint = view.widthAnchor.constraint(equalToConstant: width)
        prefixWidthConstraint = widthConstraint
        let leading = textField.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8)
        textLeadingConstraint = leading
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint,
            leading
        ])
    }

    /// 设置右侧操作区域。
    /// - Parameters:
    ///   - view: 密码眼睛或验证码预览等视图。
    ///   - width: 操作区域固定宽度，单位为点。
    func setTrailingView(_ view: UIView, width: CGFloat) {
        trailingView?.removeFromSuperview()
        trailingWidthConstraint?.isActive = false
        textTrailingConstraint?.isActive = false
        trailingView = view
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let widthConstraint = view.widthAnchor.constraint(equalToConstant: width)
        trailingWidthConstraint = widthConstraint
        let trailing = textField.trailingAnchor.constraint(equalTo: view.leadingAnchor)
        textTrailingConstraint = trailing
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint,
            trailing
        ])
    }

    /// 创建输入容器内部的基础约束和 Figma 视觉样式。
    private func setupView() {
        backgroundColor = UIColor(coHereHex: 0xF8F9FF)
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(coHereHex: 0x5966F2).withAlphaComponent(0.20).cgColor

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = UIColor(coHereHex: 0x334155)
        textField.font = .systemFont(ofSize: 14)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        addSubview(textField)

        let trailing = textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        textTrailingConstraint = trailing
        let leading = textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10)
        textLeadingConstraint = leading

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            leading,
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            trailing
        ])
    }
}

/// 绘制服务端图文验证码字符并提供刷新点击区域。
final class CoHereAuthCaptchaPreviewButton: UIButton {

    /// 服务端返回的验证码字符，更新后会重新绘制。
    var captchaText = "" {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 绘制验证码背景、字符和干扰线。
    /// - Parameter rect: 当前按钮绘制区域。
    override func draw(_ rect: CGRect) {
        let insetRect = rect.insetBy(dx: 6, dy: 7)
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 6)
        UIColor(coHereHex: 0xF1F2FF).setFill()
        path.fill()

        let text = captchaText.isEmpty ? "↻" : captchaText
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor(coHereHex: 0x6C63FF)
        ]
        let size = text.size(withAttributes: attributes)
        text.draw(
            at: CGPoint(x: insetRect.midX - size.width / 2, y: insetRect.midY - size.height / 2),
            withAttributes: attributes
        )

        let line = UIBezierPath()
        line.move(to: CGPoint(x: insetRect.minX + 6, y: insetRect.maxY - 10))
        line.addLine(to: CGPoint(x: insetRect.maxX - 6, y: insetRect.minY + 10))
        UIColor(coHereHex: 0xA7A4FF).withAlphaComponent(0.6).setStroke()
        line.lineWidth = 1
        line.stroke()
    }
}

/// 绘制 CoHere 认证头部在左侧与中部散布的星点。
final class CoHereAuthHeaderStarsView: UIView {

    /// 按 375 点设计宽度缩放并绘制五个半透明星点。
    /// - Parameter rect: 当前头部装饰区域。
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let scaleX = rect.width / 375
        let stars: [(x: CGFloat, y: CGFloat, diameter: CGFloat, alpha: CGFloat)] = [
            (48, 64, 3.6, 0.55),
            (153, 40, 3.6, 0.55),
            (58, 140, 3.6, 0.55),
            (195.5, 134, 2.4, 0.38),
            (125.5, 118, 1.8, 0.30)
        ]
        stars.forEach { star in
            let circle = CGRect(
                x: star.x * scaleX,
                y: star.y,
                width: star.diameter,
                height: star.diameter
            )
            UIColor.white.withAlphaComponent(star.alpha).setFill()
            UIBezierPath(ovalIn: circle).fill()
        }
    }
}

/// 绘制 CoHere 认证标题下方的两条渐隐线和三枚圆点。
final class CoHereAuthHeaderDividerView: UIView {

    /// 绘制宽 200 点、高 6 点的标题分隔装饰。
    /// - Parameter rect: 当前分隔装饰区域。
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let transparent = UIColor.white.withAlphaComponent(0).cgColor
        let visible = UIColor.white.withAlphaComponent(0.20).cgColor
        if let leftGradient = CGGradient(
            colorsSpace: nil,
            colors: [transparent, visible] as CFArray,
            locations: [0, 1]
        ) {
            context.saveGState()
            context.clip(to: CGRect(x: 0, y: rect.midY - 0.5, width: 75, height: 1))
            context.drawLinearGradient(
                leftGradient,
                start: CGPoint(x: 0, y: rect.midY),
                end: CGPoint(x: 75, y: rect.midY),
                options: []
            )
            context.restoreGState()
        }
        if let rightGradient = CGGradient(
            colorsSpace: nil,
            colors: [visible, transparent] as CFArray,
            locations: [0, 1]
        ) {
            context.saveGState()
            context.clip(to: CGRect(x: 125, y: rect.midY - 0.5, width: 75, height: 1))
            context.drawLinearGradient(
                rightGradient,
                start: CGPoint(x: 125, y: rect.midY),
                end: CGPoint(x: 200, y: rect.midY),
                options: []
            )
            context.restoreGState()
        }

        UIColor.white.withAlphaComponent(0.35).setFill()
        UIBezierPath(ovalIn: CGRect(x: 87, y: 1, width: 4, height: 4)).fill()
        UIColor.white.withAlphaComponent(0.50).setFill()
        UIBezierPath(ovalIn: CGRect(x: 97, y: 0, width: 6, height: 6)).fill()
        UIColor.white.withAlphaComponent(0.35).setFill()
        UIBezierPath(ovalIn: CGRect(x: 109, y: 1, width: 4, height: 4)).fill()
    }
}

/// 提供认证页面可自适应尺寸的线性渐变背景。
final class CoHereAuthGradientView: UIView {

    /// 渐变颜色集合。
    private let gradientColors: [UIColor]

    /// 当前视图使用的渐变层。
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    /// 使用给定颜色创建渐变视图。
    /// - Parameter colors: 从顶部到底部排列的渐变颜色。
    init(colors: [UIColor]) {
        gradientColors = colors
        super.init(frame: .zero)
        configureGradient()
    }

    /// Storyboard 初始化当前未使用。
    /// - Parameter coder: 解码器。
    required init?(coder: NSCoder) {
        gradientColors = [
            UIColor(coHereHex: 0x6C63FF),
            UIColor(coHereHex: 0x7835E7)
        ]
        super.init(coder: coder)
        configureGradient()
    }

    /// 将颜色和方向写入底层 CAGradientLayer。
    private func configureGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        gradientLayer.colors = gradientColors.map(\.cgColor)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

/// 使用 Figma 蓝紫渐变的认证主按钮。
final class CoHereAuthGradientButton: UIButton {

    /// 按钮底层渐变。
    private let gradientLayer = CAGradientLayer()

    /// 初始化按钮并安装渐变层。
    /// - Parameter frame: 初始区域。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    /// Storyboard 初始化当前未使用。
    /// - Parameter coder: 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    /// 布局变化时同步渐变层大小和圆角。
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }

    /// 创建从蓝紫到亮紫的认证按钮渐变。
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(coHereHex: 0x5E67F7).cgColor,
            UIColor(coHereHex: 0x8B3DF0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

/// CoHere Figma 十六进制颜色的 UIKit 便捷初始化。
extension UIColor {

    /// 由 0xRRGGBB 整数创建不透明颜色。
    /// - Parameter value: 六位 RGB 整数。
    convenience init(coHereHex value: UInt32) {
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
