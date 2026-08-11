import UIKit

/// 按照 Figma“设置语言”节点实现的 Swift 视觉层；语言选择、保存和页面重建由 Swift 控制器负责。
@objc(CoHereLanguageSettingPageView)
final class CoHereLanguageSettingPageView: UIView {

    /// 点击返回按钮后的业务回调。
    @objc var onBackTap: (() -> Void)?

    /// 点击完成按钮后的业务回调。
    @objc var onDoneTap: (() -> Void)?

    /// 点击语言行后的业务回调，参数为现有语言数组中的索引。
    @objc var onLanguageSelected: ((Int) -> Void)?

    /// 顶部状态栏与导航内容的 Figma 浅色渐变背景。
    private let coHereNavigationView = CoHereLanguageSettingGradientView()

    /// 使用既有 Figma 返回图标并保留 36pt 点击区域的返回按钮。
    private let coHereBackButton = UIButton(type: .custom)

    /// 页面居中的导航标题。
    private let coHereTitleLabel = UILabel()

    /// 右侧 48×28pt 紫色完成按钮。
    private let coHereDoneButton = UIButton(type: .custom)

    /// 垂直排列四个 52pt 语言选项的容器。
    private let coHereRowsStackView = UIStackView()

    /// 当前由控制器传入并显示的语言选项。
    private var coHereRows: [CoHereLanguageSettingRowControl] = []

    /// 创建设置语言视觉层并完成控件、约束和事件初始化。
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

    /// 使用 Swift 控制器现有语言数组和选中索引刷新列表，不触发业务回调。
    /// - Parameters:
    ///   - titles: 已按当前应用语言本地化的语言名称。
    ///   - selectedIndex: 当前选中语言在原语言数组中的索引。
    @objc(configureWithTitles:selectedIndex:)
    func coHereConfigure(titles: [String], selectedIndex: Int) {
        if coHereRows.count != titles.count {
            coHereRebuildRows(titles: titles)
        }

        for (index, row) in coHereRows.enumerated() {
            row.coHereConfigure(
                title: titles[index],
                isSelected: index == selectedIndex
            )
        }
    }

    /// 创建并配置 Figma 导航、完成按钮和语言列表容器。
    private func coHereSetupView() {
        backgroundColor = UIColor(coHereLanguageSettingHex: 0xF5F5F5)

        coHereNavigationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coHereNavigationView)

        coHereRowsStackView.translatesAutoresizingMaskIntoConstraints = false
        coHereRowsStackView.axis = .vertical
        coHereRowsStackView.alignment = .fill
        coHereRowsStackView.distribution = .fillEqually
        coHereRowsStackView.spacing = 0
        addSubview(coHereRowsStackView)

        coHereBackButton.translatesAutoresizingMaskIntoConstraints = false
        coHereBackButton.setImage(
            UIImage(named: "cohere_system_setting_back"),
            for: .normal
        )
        coHereBackButton.accessibilityLabel = coHereLocalized("返回")
        addSubview(coHereBackButton)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.text = coHereLocalized("设置语言")
        coHereTitleLabel.textColor = UIColor(coHereLanguageSettingHex: 0x333333)
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coHereTitleLabel.textAlignment = .center
        addSubview(coHereTitleLabel)

        coHereDoneButton.translatesAutoresizingMaskIntoConstraints = false
        coHereDoneButton.backgroundColor = UIColor(coHereLanguageSettingHex: 0x6C63FF)
        coHereDoneButton.setTitle(coHereLocalized("完成"), for: .normal)
        coHereDoneButton.setTitleColor(.white, for: .normal)
        coHereDoneButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        coHereDoneButton.layer.cornerRadius = 4
        coHereDoneButton.layer.masksToBounds = true
        addSubview(coHereDoneButton)
    }

    /// 建立与 375×812 Figma 基准一致并适配设备安全区的导航和列表约束。
    private func coHereSetupConstraints() {
        NSLayoutConstraint.activate([
            coHereNavigationView.topAnchor.constraint(equalTo: topAnchor),
            coHereNavigationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereNavigationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereNavigationView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 58
            ),

            coHereRowsStackView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 54
            ),
            coHereRowsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereRowsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),

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

            coHereDoneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            coHereDoneButton.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 12
            ),
            coHereDoneButton.widthAnchor.constraint(equalToConstant: 48),
            coHereDoneButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    /// 绑定返回和完成按钮事件；语言行事件在重建列表时按索引绑定。
    private func coHereBindActions() {
        coHereBackButton.addTarget(
            self,
            action: #selector(coHereHandleBackTap),
            for: .touchUpInside
        )
        coHereDoneButton.addTarget(
            self,
            action: #selector(coHereHandleDoneTap),
            for: .touchUpInside
        )
    }

    /// 按当前语言数量重建 52pt 选项行，并保留索引与业务数组的一一对应关系。
    /// - Parameter titles: 已本地化的语言标题数组。
    private func coHereRebuildRows(titles: [String]) {
        coHereRows.forEach { row in
            coHereRowsStackView.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        coHereRows.removeAll(keepingCapacity: true)

        for (index, title) in titles.enumerated() {
            let row = CoHereLanguageSettingRowControl()
            row.tag = index
            row.translatesAutoresizingMaskIntoConstraints = false
            row.coHereConfigure(title: title, isSelected: false)
            row.addTarget(
                self,
                action: #selector(coHereHandleLanguageTap(_:)),
                for: .touchUpInside
            )
            coHereRowsStackView.addArrangedSubview(row)
            row.heightAnchor.constraint(equalToConstant: 52).isActive = true
            coHereRows.append(row)
        }
    }

    /// 转发返回点击，不直接处理导航栈。
    @objc private func coHereHandleBackTap() {
        onBackTap?()
    }

    /// 转发完成点击，不直接保存语言或重建根页面。
    @objc private func coHereHandleDoneTap() {
        onDoneTap?()
    }

    /// 转发选中语言的原数组索引，由 Swift 控制器更新业务状态。
    /// - Parameter sender: 携带语言数组索引的选项行。
    @objc private func coHereHandleLanguageTap(
        _ sender: UIControl
    ) {
        onLanguageSelected?(sender.tag)
    }

    /// 使用项目现有语言管理器匹配本地化字符串。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前应用语言下的显示文本。
    private func coHereLocalized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// 单个 Figma 语言选项行，负责标题、分割线和选中对勾的视觉状态。
private final class CoHereLanguageSettingRowControl: UIControl {

    /// 语言名称标签。
    private let coHereTitleLabel = UILabel()

    /// 仅在当前语言被选中时显示的 20pt Figma 对勾。
    private let coHereCheckView = UIImageView(
        image: UIImage(named: "cohere_language_setting_check")
    )

    /// 行底部低透明度分割线。
    private let coHereDividerView = UIView()

    /// 创建语言选项行并应用 Figma 样式和约束。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupView()
    }

    /// Storyboard/XIB 初始化入口，保持与代码初始化一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView()
    }

    /// 更新当前行的语言标题和对勾显示状态。
    /// - Parameters:
    ///   - title: 当前应用语言下的语言名称。
    ///   - isSelected: 是否为控制器当前选中的语言。
    func coHereConfigure(title: String, isSelected: Bool) {
        coHereTitleLabel.text = title
        coHereCheckView.isHidden = !isSelected
        accessibilityLabel = title
        accessibilityTraits = isSelected ? [.button, .selected] : [.button]
    }

    /// 创建白色行背景、标题、Figma 对勾和底部分割线。
    private func coHereSetupView() {
        backgroundColor = .white

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.textColor = UIColor(coHereLanguageSettingHex: 0x333333)
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addSubview(coHereTitleLabel)

        coHereCheckView.translatesAutoresizingMaskIntoConstraints = false
        coHereCheckView.contentMode = .scaleAspectFit
        addSubview(coHereCheckView)

        coHereDividerView.translatesAutoresizingMaskIntoConstraints = false
        coHereDividerView.backgroundColor = UIColor(
            coHereLanguageSettingHex: 0xE5E5E5
        ).withAlphaComponent(0.2)
        addSubview(coHereDividerView)

        NSLayoutConstraint.activate([
            coHereTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            coHereTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            coHereTitleLabel.heightAnchor.constraint(equalToConstant: 24),

            coHereCheckView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            coHereCheckView.centerYAnchor.constraint(equalTo: centerYAnchor),
            coHereCheckView.widthAnchor.constraint(equalToConstant: 20),
            coHereCheckView.heightAnchor.constraint(equalToConstant: 20),

            coHereDividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereDividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereDividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            coHereDividerView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

/// 绘制 Figma 小导航从淡紫到白色的纵向渐变。
private final class CoHereLanguageSettingGradientView: UIView {

    /// 使用渐变图层作为当前视图的底层图层。
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    /// 创建渐变视图并应用 Figma 色值与方向。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupGradient()
    }

    /// Storyboard/XIB 初始化入口，保持与代码初始化一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupGradient()
    }

    /// 配置从 #F2F1FF 到白色的近纵向渐变。
    private func coHereSetupGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        gradientLayer.colors = [
            UIColor(coHereLanguageSettingHex: 0xF2F1FF).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

private extension UIColor {

    /// 使用 0xRRGGBB 色值创建不透明颜色。
    /// - Parameter coHereLanguageSettingHex: Figma 标注的六位 RGB 色值。
    convenience init(coHereLanguageSettingHex: UInt32) {
        self.init(
            red: CGFloat((coHereLanguageSettingHex >> 16) & 0xFF) / 255,
            green: CGFloat((coHereLanguageSettingHex >> 8) & 0xFF) / 255,
            blue: CGFloat(coHereLanguageSettingHex & 0xFF) / 255,
            alpha: 1
        )
    }
}
