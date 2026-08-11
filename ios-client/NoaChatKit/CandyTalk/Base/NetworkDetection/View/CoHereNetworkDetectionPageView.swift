//
//  CoHereNetworkDetectionPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// 网络检测底部按钮的三个业务状态。
enum CoHereNetworkDetectionActionState {
    /// 尚未开始或检测已取消。
    case ready

    /// 当前正在检测，点击按钮将取消检测。
    case detecting

    /// 检测已经结束，可再次检测。
    case finished
}

/// 按照 Figma“网络检测”节点实现的 Swift 页面；检测任务仍由控制器和旧业务对象负责。
@objc(CoHereNetworkDetectionPageView)
final class CoHereNetworkDetectionPageView: UIView {

    /// 点击返回按钮后的导航回调。
    @objc var onBackTap: (() -> Void)?

    /// 点击底部检测按钮后的业务回调。
    @objc var onActionTap: (() -> Void)?

    /// 点击检测分组后的回调，参数为业务分组下标。
    var onSectionTap: ((Int) -> Void)?

    /// 页面浅紫到白色的 Figma 渐变背景。
    private let gradientView = CoHereNetworkDetectionGradientView()

    /// 返回按钮，复用 CoHere 设置页已有返回资源。
    private let backButton = UIButton(type: .custom)

    /// 居中的页面导航标题。
    private let navigationTitleLabel = UILabel()

    /// Figma 顶部卫星插画或检测完成状态插画。
    private let headerImageView = UIImageView()

    /// 检测状态主标题。
    private let headerTitleLabel = UILabel()

    /// 检测准备、进度或异常信息。
    private let headerMessageLabel = UILabel()

    /// 当前邀请码胶囊标签；邀请码为空时不显示。
    private let inviteCodeLabel = UILabel()

    /// 邀请码标签高度，用于无邀请码入口收起空间。
    private var inviteCodeHeightConstraint: NSLayoutConstraint?

    /// 动态展示登录前后检测分组和展开结果的列表。
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 固定在底部安全区上方的检测按钮。
    private let actionButton = UIButton(type: .custom)

    /// 业务对象当前提供的检测分组。
    private var models: [NoaNetworkDetectionMessageModel] = []

    /// 创建页面并完成控件、约束和事件初始化。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        bindActions()
    }

    /// Storyboard/XIB 初始化入口，保持与代码初始化一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
        bindActions()
    }

    /// 使用最新头部状态刷新文案和插画。
    /// - Parameters:
    ///   - title: 当前检测状态标题。
    ///   - message: 当前检测状态说明。
    ///   - imageName: Figma 或原状态资源名称。
    ///   - highlightNumbers: 是否突出进度或异常数字。
    func configureHeader(
        title: String,
        message: String,
        imageName: String,
        highlightNumbers: Bool
    ) {
        headerTitleLabel.text = title
        headerImageView.image = UIImage(named: imageName)
        headerMessageLabel.attributedText = attributedMessage(
            message,
            highlightNumbers: highlightNumbers
        )
    }

    /// 更新当前邀请码；空值入口隐藏胶囊并收起其高度。
    /// - Parameter inviteCode: 登录前输入或本地保存的邀请码。
    func configureInviteCode(_ inviteCode: String?) {
        let code = inviteCode ?? ""
        let shouldShow = !code.isEmpty
        inviteCodeLabel.isHidden = !shouldShow
        inviteCodeHeightConstraint?.constant = shouldShow ? 24 : 0
        inviteCodeLabel.text = shouldShow
            ? String(format: localized("邀请码：%@"), code)
            : nil
        inviteCodeLabel.accessibilityLabel = inviteCodeLabel.text
    }

    /// 替换当前检测分组并刷新列表。
    /// - Parameter models: 原业务对象提供的动态分组。
    func configure(models: [NoaNetworkDetectionMessageModel]) {
        self.models = models
        tableView.reloadData()
    }

    /// 刷新指定检测分组；越界时回退为刷新整个列表。
    /// - Parameter section: 需要刷新的业务分组下标。
    func reloadSection(at section: Int) {
        guard models.indices.contains(section) else {
            tableView.reloadData()
            return
        }
        tableView.reloadSections(
            IndexSet(integer: section),
            with: .none
        )
    }

    /// 根据检测阶段刷新按钮文案，不直接启动或取消任务。
    /// - Parameter state: 当前按钮业务状态。
    func configureActionButton(
        state: CoHereNetworkDetectionActionState
    ) {
        let title: String
        switch state {
        case .ready:
            title = localized("开始检测")
        case .detecting:
            title = localized("退出检测")
        case .finished:
            title = localized("重新检测")
        }
        actionButton.setTitle(title, for: .normal)
        actionButton.accessibilityLabel = title
    }

    /// 配置 Figma 视觉、列表复用和项目明暗主题。
    private func setupView() {
        let darkBackground = UIColor(coHereNetworkHex: 0x111111)
        backgroundColor = .white
        tkThemebackgroundColors = [.white, darkBackground]

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(
            UIImage(named: "cohere_system_setting_back"),
            for: .normal
        )
        backButton.accessibilityLabel = localized("返回")
        addSubview(backButton)

        navigationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationTitleLabel.text = localized("网络检测")
        navigationTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        navigationTitleLabel.textAlignment = .center
        navigationTitleLabel.tkThemetextColors = [
            UIColor(coHereNetworkHex: 0x333333),
            .white
        ]
        addSubview(navigationTitleLabel)

        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.contentMode = .scaleAspectFit
        addSubview(headerImageView)

        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.tkThemetextColors = [
            UIColor(coHereNetworkHex: 0x333333),
            .white
        ]
        addSubview(headerTitleLabel)

        headerMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        headerMessageLabel.font = .systemFont(ofSize: 12, weight: .regular)
        headerMessageLabel.textAlignment = .center
        headerMessageLabel.numberOfLines = 1
        addSubview(headerMessageLabel)

        inviteCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        inviteCodeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        inviteCodeLabel.textAlignment = .center
        inviteCodeLabel.layer.cornerRadius = 12
        inviteCodeLabel.layer.borderWidth = 1
        inviteCodeLabel.layer.borderColor = UIColor(
            coHereNetworkHex: 0x9B8EF8
        ).cgColor
        inviteCodeLabel.tkThemetextColors = [
            UIColor(coHereNetworkHex: 0x6857F5),
            UIColor(coHereNetworkHex: 0x9B8EF8)
        ]
        addSubview(inviteCodeLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 32
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = .leastNormalMagnitude
        tableView.sectionFooterHeight = .leastNormalMagnitude
        tableView.layer.cornerRadius = 12
        tableView.clipsToBounds = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            CoHereNetworkDetectionMainCell.self,
            forCellReuseIdentifier: CoHereNetworkDetectionMainCell.reuseID
        )
        tableView.register(
            CoHereNetworkDetectionSubResultCell.self,
            forCellReuseIdentifier: CoHereNetworkDetectionSubResultCell.reuseID
        )
        addSubview(tableView)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.backgroundColor = UIColor(coHereNetworkHex: 0x6857F5)
        actionButton.layer.cornerRadius = 8
        actionButton.layer.masksToBounds = true
        addSubview(actionButton)

        tkThemeChangeBlock = { [weak self] _, themeIndex in
            self?.gradientView.setDarkTheme(themeIndex != 0)
        }
    }

    /// 建立与 375×812 Figma 基准一致并适配安全区的页面约束。
    private func setupConstraints() {
        let inviteHeight = inviteCodeLabel.heightAnchor.constraint(
            equalToConstant: 24
        )
        inviteCodeHeightConstraint = inviteHeight

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),

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
            navigationTitleLabel.heightAnchor.constraint(equalToConstant: 24),

            headerImageView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 83
            ),
            headerImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 160),
            headerImageView.heightAnchor.constraint(equalToConstant: 160),

            headerTitleLabel.topAnchor.constraint(
                equalTo: headerImageView.bottomAnchor,
                constant: 6
            ),
            headerTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerTitleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: 30
            ),
            headerTitleLabel.heightAnchor.constraint(equalToConstant: 22),

            headerMessageLabel.topAnchor.constraint(
                equalTo: headerTitleLabel.bottomAnchor,
                constant: 4
            ),
            headerMessageLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 30
            ),
            headerMessageLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -30
            ),
            headerMessageLabel.heightAnchor.constraint(equalToConstant: 20),

            inviteCodeLabel.topAnchor.constraint(
                equalTo: headerMessageLabel.bottomAnchor,
                constant: 8
            ),
            inviteCodeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            inviteCodeLabel.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 92
            ),
            inviteCodeLabel.widthAnchor.constraint(
                lessThanOrEqualTo: widthAnchor,
                constant: -60
            ),
            inviteHeight,

            tableView.topAnchor.constraint(
                equalTo: inviteCodeLabel.bottomAnchor,
                constant: 24
            ),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            tableView.bottomAnchor.constraint(
                equalTo: actionButton.topAnchor,
                constant: -24
            ),

            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            actionButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -12
            )
        ])
    }

    /// 绑定返回和底部检测按钮触摸事件。
    private func bindActions() {
        backButton.addTarget(
            self,
            action: #selector(handleBackTap),
            for: .touchUpInside
        )
        actionButton.addTarget(
            self,
            action: #selector(handleActionTap),
            for: .touchUpInside
        )
    }

    /// 转发返回点击，不直接操作导航栈。
    @objc private func handleBackTap() {
        onBackTap?()
    }

    /// 转发检测按钮点击，不在视图层调用业务对象。
    @objc private func handleActionTap() {
        onActionTap?()
    }

    /// 创建状态说明富文本，按旧页面规则突出进度或异常数字。
    /// - Parameters:
    ///   - message: 完整状态说明。
    ///   - highlightNumbers: 是否高亮其中的数字及百分号。
    /// - Returns: 可直接展示的状态说明富文本。
    private func attributedMessage(
        _ message: String,
        highlightNumbers: Bool
    ) -> NSAttributedString {
        let normalColor = UIColor(coHereNetworkHex: 0x999999)
        let result = NSMutableAttributedString(
            string: message,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: normalColor
            ]
        )
        guard highlightNumbers,
              let expression = try? NSRegularExpression(
                  pattern: "\\d+%?"
              ) else {
            return result
        }
        let range = NSRange(message.startIndex..., in: message)
        expression.enumerateMatches(
            in: message,
            range: range
        ) { match, _, _ in
            guard let match else {
                return
            }
            result.addAttributes(
                [
                    .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                    .foregroundColor: UIColor(coHereNetworkHex: 0x6857F5)
                ],
                range: match.range
            )
        }
        return result
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

extension CoHereNetworkDetectionPageView: UITableViewDataSource,
    UITableViewDelegate {

    /// 返回业务对象当前提供的检测分组数量。
    func numberOfSections(in tableView: UITableView) -> Int {
        models.count
    }

    /// 根据分组折叠状态返回主行和子结果行数量。
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard models.indices.contains(section) else {
            return 0
        }
        let model = models[section]
        return model.isFold ? 1 : model.subFunctionResultArr.count + 1
    }

    /// 创建主检测状态行或展开后的子结果行。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let model = models[indexPath.section]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CoHereNetworkDetectionMainCell.reuseID,
                for: indexPath
            ) as! CoHereNetworkDetectionMainCell
            cell.configure(model: model)
            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereNetworkDetectionSubResultCell.reuseID,
            for: indexPath
        ) as! CoHereNetworkDetectionSubResultCell
        let resultIndex = indexPath.row - 1
        let results = model.subFunctionResultArr as NSArray
        let result = results[resultIndex] as? NoaNetworkDetectionSubResultModel
        cell.configure(
            model: result,
            isLast: resultIndex == results.count - 1
        )
        return cell
    }

    /// 保持主检测行为 48pt，子结果按多语言内容自动扩展。
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        indexPath.row == 0 ? 48 : UITableView.automaticDimension
    }

    /// 将主检测行点击转发给控制器处理展开状态。
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard indexPath.row == 0 else {
            return
        }
        onSectionTap?(indexPath.section)
    }

    /// 消除系统默认分组头部间距。
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        .leastNormalMagnitude
    }

    /// 消除系统默认分组尾部间距。
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        .leastNormalMagnitude
    }
}

/// 单个检测分组主行，展示等待、检测中、成功或失败状态。
private final class CoHereNetworkDetectionMainCell: UITableViewCell {

    /// UITableView 复用标识。
    static let reuseID = "CoHereNetworkDetectionMainCell"

    /// 左侧检测项目标题。
    private let titleLabel = UILabel()

    /// 右侧初始等待状态。
    private let waitLabel = UILabel()

    /// 检测中、成功或失败状态图标。
    private let statusImageView = UIImageView()

    /// 检测开始后的展开方向图标。
    private let arrowImageView = UIImageView()

    /// 创建检测主行并配置布局。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }

    /// Storyboard/XIB 不用于动态检测行。
    required init?(coder: NSCoder) {
        nil
    }

    /// 停止复用前一模型留下的加载动画。
    override func prepareForReuse() {
        super.prepareForReuse()
        stopLoadingAnimation()
    }

    /// 使用业务模型刷新标题、等待、加载、成功、失败和折叠状态。
    /// - Parameter model: 当前检测业务分组。
    func configure(model: NoaNetworkDetectionMessageModel) {
        titleLabel.text = model.sectionTitle
        let status = Int(model.messageStatus.rawValue)
        waitLabel.isHidden = status != 0
        statusImageView.isHidden = status == 0
        arrowImageView.isHidden = status == 0

        switch status {
        case 1:
            statusImageView.image = UIImage(
                named: "icon_network_detection_loading"
            )
            startLoadingAnimation()
        case 2:
            statusImageView.image = UIImage(
                named: model.isAllSubFunctionPass()
                    ? "icon_network_detection_result_success"
                    : "icon_network_detection_result_fail"
            )
            stopLoadingAnimation()
        default:
            statusImageView.image = nil
            stopLoadingAnimation()
        }
        arrowImageView.image = UIImage(
            named: model.isFold
                ? "c_arrow_right_gray"
                : "c_arrow_down_gray"
        )
        accessibilityLabel = [
            model.sectionTitle,
            status == 0 ? waitLabel.text : nil
        ].compactMap { $0 }.joined(separator: "，")
    }

    /// 配置 Figma 行背景、字体和状态图标。
    private func setupView() {
        selectionStyle = .none
        contentView.tkThemebackgroundColors = [
            .white,
            UIColor(coHereNetworkHex: 0x444444)
        ]

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.tkThemetextColors = [
            UIColor(coHereNetworkHex: 0x333333),
            .white
        ]
        contentView.addSubview(titleLabel)

        waitLabel.translatesAutoresizingMaskIntoConstraints = false
        waitLabel.text = NoaLanguageManager.share().matchLocalLanguage("待检测")
        waitLabel.font = .systemFont(ofSize: 12, weight: .regular)
        waitLabel.textAlignment = .right
        waitLabel.tkThemetextColors = [
            UIColor(coHereNetworkHex: 0x999999),
            UIColor(coHereNetworkHex: 0xCCCCCC)
        ]
        contentView.addSubview(waitLabel)

        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.contentMode = .scaleAspectFit
        contentView.addSubview(statusImageView)

        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.contentMode = .scaleAspectFit
        contentView.addSubview(arrowImageView)
    }

    /// 建立 48pt 主行中的标题、状态和箭头约束。
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: waitLabel.leadingAnchor,
                constant: -12
            ),

            waitLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            waitLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            arrowImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            arrowImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12),

            statusImageView.trailingAnchor.constraint(
                equalTo: arrowImageView.leadingAnchor,
                constant: -7
            ),
            statusImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            statusImageView.widthAnchor.constraint(equalToConstant: 16),
            statusImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    /// 为检测中状态添加单一、可复用的旋转动画。
    private func startLoadingAnimation() {
        guard statusImageView.layer.animation(
            forKey: "cohere.network.rotate"
        ) == nil else {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        statusImageView.layer.add(
            animation,
            forKey: "cohere.network.rotate"
        )
    }

    /// 移除检测中旋转动画并恢复图标角度。
    private func stopLoadingAnimation() {
        statusImageView.layer.removeAnimation(forKey: "cohere.network.rotate")
        statusImageView.transform = .identity
    }
}

/// 展开检测分组后展示单条成功或失败结果。
private final class CoHereNetworkDetectionSubResultCell: UITableViewCell {

    /// UITableView 复用标识。
    static let reuseID = "CoHereNetworkDetectionSubResultCell"

    /// 允许多行展示的检测结果文本。
    private let resultLabel = UILabel()

    /// 创建子结果行并配置布局。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }

    /// Storyboard/XIB 不用于动态子结果行。
    required init?(coder: NSCoder) {
        nil
    }

    /// 使用业务结果刷新文案、成功或失败颜色及末行间距。
    /// - Parameters:
    ///   - model: 单项网络检测结果。
    ///   - isLast: 是否为当前分组最后一项结果。
    func configure(
        model: NoaNetworkDetectionSubResultModel?,
        isLast: Bool
    ) {
        resultLabel.text = model?.resultTitleStr
        resultLabel.textColor = (model?.isPass ?? false)
            ? UIColor(coHereNetworkHex: 0x00B86B)
            : UIColor(coHereNetworkHex: 0xF93A2F)
        resultLabel.layoutMargins = UIEdgeInsets(
            top: 4,
            left: 0,
            bottom: isLast ? 10 : 4,
            right: 0
        )
        accessibilityLabel = resultLabel.text
    }

    /// 配置多语言结果文本及明暗主题背景。
    private func setupView() {
        selectionStyle = .none
        contentView.tkThemebackgroundColors = [
            .white,
            UIColor(coHereNetworkHex: 0x444444)
        ]
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.font = .systemFont(ofSize: 12, weight: .regular)
        resultLabel.numberOfLines = 0
        resultLabel.lineBreakMode = .byCharWrapping
        contentView.addSubview(resultLabel)
    }

    /// 建立可自动扩展高度的子结果文本约束。
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            resultLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            resultLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            resultLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4
            ),
            resultLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -8
            )
        ])
    }
}

/// 网络检测页面全屏浅紫到白色渐变，并保留项目暗色主题。
private final class CoHereNetworkDetectionGradientView: UIView {

    /// 页面背景使用的渐变图层。
    private let gradientLayer = CAGradientLayer()

    /// 创建背景并应用默认浅色渐变。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    /// Storyboard/XIB 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    /// 随页面尺寸变化同步渐变范围。
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    /// 根据项目主题切换浅色渐变或统一暗色背景。
    /// - Parameter isDark: 当前是否为暗色主题。
    func setDarkTheme(_ isDark: Bool) {
        gradientLayer.colors = isDark
            ? [
                UIColor(coHereNetworkHex: 0x111111).cgColor,
                UIColor(coHereNetworkHex: 0x111111).cgColor
            ]
            : [
                UIColor(coHereNetworkHex: 0xF2F1FF).cgColor,
                UIColor.white.cgColor
            ]
    }

    /// 配置纵向渐变方向和默认颜色。
    private func setupGradient() {
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.58)
        layer.insertSublayer(gradientLayer, at: 0)
        setDarkTheme(false)
    }
}

extension UIColor {

    /// 将网络检测 Figma 十六进制颜色转换为 UIColor。
    /// - Parameter coHereNetworkHex: 0xRRGGBB 格式颜色值。
    convenience init(coHereNetworkHex: UInt32) {
        self.init(
            red: CGFloat((coHereNetworkHex >> 16) & 0xFF) / 255,
            green: CGFloat((coHereNetworkHex >> 8) & 0xFF) / 255,
            blue: CGFloat(coHereNetworkHex & 0xFF) / 255,
            alpha: 1
        )
    }
}
