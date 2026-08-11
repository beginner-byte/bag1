//
//  CoHereComplainPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// “投诉与反馈”页面视图，只负责 Figma 布局、输入状态和事件回调。
final class CoHereComplainPageView: UIView {

    /// 点击返回按钮时通知控制器。
    var onBack: (() -> Void)?
    /// 点击投诉分类行时通知控制器。
    var onModeTap: (() -> Void)?
    /// 点击投诉原因行时通知控制器。
    var onReasonTap: (() -> Void)?
    /// 投诉内容变化时返回最多 200 字的文本。
    var onContentChanged: ((String) -> Void)?
    /// 邮箱内容变化时返回原始文本。
    var onEmailChanged: ((String) -> Void)?
    /// 点击添加图片入口时通知控制器。
    var onAddImage: (() -> Void)?
    /// 点击图片删除按钮时返回图片下标。
    var onDeleteImage: ((Int) -> Void)?
    /// 点击提交按钮时通知控制器。
    var onSubmit: (() -> Void)?

    /// 页面滚动容器，保证小屏和键盘环境下末尾内容可访问。
    private let scrollView = UIScrollView()
    /// 承载全部表单区域的垂直栈。
    private let contentStack = UIStackView()
    /// 当前投诉分类文本。
    private let modeValueLabel = UILabel()
    /// 当前投诉原因文本。
    private let reasonValueLabel = UILabel()
    /// 投诉内容输入框。
    private let contentTextView = UITextView()
    /// 投诉内容占位文本。
    private let contentPlaceholderLabel = UILabel()
    /// 投诉内容字数统计。
    private let contentCountLabel = UILabel()
    /// 邮箱输入框。
    private let emailTextField = UITextField()
    /// 邀请码或 IP/域名标题。
    private let domainTitleLabel = UILabel()
    /// 邀请码或 IP/域名展示区域。
    private let domainContainer = UIView()
    /// 邀请码或 IP/域名只读文本。
    private let domainValueLabel = UILabel()
    /// 图片网格数据。
    private var thumbnails: [UIImage] = []
    /// 图片网格高度，随图片行数更新。
    private var mediaHeightConstraint: NSLayoutConstraint?
    /// 底部固定提交按钮。
    private let submitButton = UIButton(type: .system)

    /// 图片网格，保持原业务的图片选择与删除能力。
    private lazy var mediaCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CoHereComplainImageCell.self,
            forCellWithReuseIdentifier: CoHereComplainImageCell.reuseIdentifier
        )
        collectionView.register(
            CoHereComplainAddImageCell.self,
            forCellWithReuseIdentifier: CoHereComplainAddImageCell.reuseIdentifier
        )
        return collectionView
    }()

    /// 使用代码创建页面并完成布局。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        registerKeyboardNotifications()
    }

    /// Storyboard 初始化时完成相同布局。
    /// - Parameter coder: 系统解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        registerKeyboardNotifications()
    }

    /// 页面释放时移除键盘通知。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 根据当前业务状态刷新页面可见内容。
    /// - Parameters:
    ///   - modeTitle: 当前投诉分类名称。
    ///   - reasonTitle: 当前投诉原因名称。
    ///   - domainText: 当前邀请码或 IP/域名展示文本。
    ///   - showsDomain: 是否显示企业信息区域。
    ///   - thumbnails: 已选图片缩略图。
    ///   - submitEnabled: 提交条件是否满足。
    ///   - isSubmitting: 是否正在上传或提交。
    func configure(
        modeTitle: String,
        reasonTitle: String,
        domainText: String,
        showsDomain: Bool,
        thumbnails: [UIImage],
        submitEnabled: Bool,
        isSubmitting: Bool
    ) {
        modeValueLabel.text = modeTitle
        reasonValueLabel.text = reasonTitle
        domainValueLabel.text = domainText
        domainTitleLabel.isHidden = !showsDomain
        domainContainer.isHidden = !showsDomain
        self.thumbnails = thumbnails
        mediaCollectionView.reloadData()
        updateMediaHeight()
        updateSubmitState(enabled: submitEnabled, isSubmitting: isSubmitting)
    }

    /// 更新提交按钮是否可点击以及提交中的标题。
    /// - Parameters:
    ///   - enabled: 当前表单是否满足原提交条件。
    ///   - isSubmitting: 是否正在上传或提交。
    func updateSubmitState(enabled: Bool, isSubmitting: Bool) {
        submitButton.isEnabled = enabled
        submitButton.setTitle(
            isSubmitting ? localized("处理中...") : localized("确认提交投诉"),
            for: .normal
        )
        submitButton.backgroundColor = enabled
            ? UIColor(red: 0.36, green: 0.40, blue: 0.95, alpha: 1)
            : UIColor(red: 0.78, green: 0.79, blue: 0.90, alpha: 1)
    }

    /// 根据当前宽度同步三列图片尺寸。
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = mediaCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let itemWidth = floor((mediaCollectionView.bounds.width - 20) / 3)
        let size = CGSize(width: itemWidth, height: itemWidth)
        if itemWidth > 0, layout.itemSize != size {
            layout.itemSize = size
            layout.invalidateLayout()
            updateMediaHeight()
        }
    }

    /// 创建 Figma 风格的导航、表单卡片和固定提交区域。
    private func setupUI() {
        backgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1)
                : UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
        }

        let header = makeHeader()
        let bottomArea = makeBottomArea()
        header.translatesAutoresizingMaskIntoConstraints = false
        bottomArea.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(header)
        addSubview(scrollView)
        addSubview(bottomArea)
        scrollView.addSubview(contentStack)

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 18, right: 16)
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true

        contentStack.addArrangedSubview(makeSelectionCard())
        contentStack.addArrangedSubview(makeContentCard())
        contentStack.addArrangedSubview(makeMediaCard())
        contentStack.addArrangedSubview(makeContactCard())

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor),
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomArea.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomArea.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomArea.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomArea.topAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    /// 创建带淡紫渐变的自定义导航栏。
    /// - Returns: 顶部导航容器。
    private func makeHeader() -> UIView {
        let header = CoHereComplainGradientView()
        let backButton = UIButton(type: .system)
        let titleLabel = UILabel()
        let separator = UIView()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(backButton)
        header.addSubview(titleLabel)
        header.addSubview(separator)

        backButton.tintColor = .label
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        titleLabel.text = localized("投诉与反馈")
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.35)

        NSLayoutConstraint.activate([
            header.heightAnchor.constraint(equalToConstant: 96),
            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
            backButton.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        return header
    }

    /// 创建投诉分类与投诉原因两行选择卡片。
    /// - Returns: 选择区域卡片。
    private func makeSelectionCard() -> UIView {
        let card = makeCard()
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        card.addSubview(stack)
        stack.addArrangedSubview(
            makeSelectionRow(
                title: "* \(localized("选择投诉分类"))",
                valueLabel: modeValueLabel,
                action: #selector(handleModeTap)
            )
        )
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(
            makeSelectionRow(
                title: localized("投诉原因"),
                valueLabel: reasonValueLabel,
                action: #selector(handleReasonTap)
            )
        )
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        return card
    }

    /// 创建一行带右箭头的选择控件。
    /// - Parameters:
    ///   - title: 左侧业务标题。
    ///   - valueLabel: 右侧当前值标签。
    ///   - action: 点击后触发的页面方法。
    /// - Returns: 高度固定的选择行。
    private func makeSelectionRow(
        title: String,
        valueLabel: UILabel,
        action: Selector
    ) -> UIView {
        let row = UIControl()
        let titleLabel = UILabel()
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        row.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        arrow.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(titleLabel)
        row.addSubview(valueLabel)
        row.addSubview(arrow)
        row.addTarget(self, action: action, for: .touchUpInside)

        titleLabel.text = title
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 15)
        valueLabel.textColor = .secondaryLabel
        valueLabel.font = .systemFont(ofSize: 14)
        valueLabel.textAlignment = .right
        valueLabel.lineBreakMode = .byTruncatingMiddle
        arrow.tintColor = .tertiaryLabel
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 54),
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            arrow.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            arrow.widthAnchor.constraint(equalToConstant: 8),
            arrow.heightAnchor.constraint(equalToConstant: 14),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    /// 创建投诉内容输入卡片。
    /// - Returns: 包含标题、输入框和计数器的卡片。
    private func makeContentCard() -> UIView {
        let card = makeCard()
        let titleLabel = makeSectionTitle("* \(localized("投诉内容"))")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentCountLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        card.addSubview(contentTextView)
        card.addSubview(contentPlaceholderLabel)
        card.addSubview(contentCountLabel)

        contentTextView.backgroundColor = .clear
        contentTextView.textColor = .label
        contentTextView.font = .systemFont(ofSize: 15)
        contentTextView.textContainerInset = .zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.delegate = self
        contentPlaceholderLabel.text = localized("请描述您要反馈的内容")
        contentPlaceholderLabel.textColor = .placeholderText
        contentPlaceholderLabel.font = .systemFont(ofSize: 14)
        contentCountLabel.text = "0/200"
        contentCountLabel.textColor = .tertiaryLabel
        contentCountLabel.font = .systemFont(ofSize: 12)
        contentCountLabel.textAlignment = .right
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            contentTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            contentTextView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalToConstant: 92),
            contentPlaceholderLabel.topAnchor.constraint(equalTo: contentTextView.topAnchor),
            contentPlaceholderLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            contentCountLabel.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 8),
            contentCountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            contentCountLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    /// 创建图片上传卡片并保存动态网格高度约束。
    /// - Returns: 图片标题与三列网格卡片。
    private func makeMediaCard() -> UIView {
        let card = makeCard()
        let titleLabel = makeSectionTitle(localized("上传图片（必填，最多9张）"))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        mediaCollectionView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        card.addSubview(mediaCollectionView)
        let heightConstraint = mediaCollectionView.heightAnchor.constraint(equalToConstant: 96)
        mediaHeightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mediaCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            mediaCollectionView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mediaCollectionView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mediaCollectionView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            heightConstraint
        ])
        return card
    }

    /// 创建邮箱及可选企业信息卡片。
    /// - Returns: 联系方式输入区域。
    private func makeContactCard() -> UIView {
        let card = makeCard()
        let stack = UIStackView()
        let emailTitle = makeSectionTitle(localized("邮箱地址"))
        let emailContainer = UIView()
        domainTitleLabel.text = localized("邀请码/IP域名")
        domainTitleLabel.textColor = .label
        domainTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        stack.translatesAutoresizingMaskIntoConstraints = false
        emailContainer.translatesAutoresizingMaskIntoConstraints = false
        domainContainer.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        domainValueLabel.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        card.addSubview(stack)

        emailContainer.backgroundColor = .secondarySystemBackground
        emailContainer.layer.cornerRadius = 8
        emailContainer.addSubview(emailTextField)
        emailTextField.placeholder = localized("请输入您的邮箱，方便与您联系")
        emailTextField.textColor = .label
        emailTextField.font = .systemFont(ofSize: 14)
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.addTarget(self, action: #selector(handleEmailChanged), for: .editingChanged)

        domainContainer.backgroundColor = .secondarySystemBackground
        domainContainer.layer.cornerRadius = 8
        domainContainer.addSubview(domainValueLabel)
        domainValueLabel.textColor = .secondaryLabel
        domainValueLabel.font = .systemFont(ofSize: 14)
        domainValueLabel.lineBreakMode = .byTruncatingMiddle

        stack.addArrangedSubview(emailTitle)
        stack.addArrangedSubview(emailContainer)
        stack.setCustomSpacing(14, after: emailContainer)
        stack.addArrangedSubview(domainTitleLabel)
        stack.addArrangedSubview(domainContainer)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            emailContainer.heightAnchor.constraint(equalToConstant: 44),
            emailTextField.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 12),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -12),
            emailTextField.topAnchor.constraint(equalTo: emailContainer.topAnchor),
            emailTextField.bottomAnchor.constraint(equalTo: emailContainer.bottomAnchor),
            domainContainer.heightAnchor.constraint(equalToConstant: 44),
            domainValueLabel.leadingAnchor.constraint(equalTo: domainContainer.leadingAnchor, constant: 12),
            domainValueLabel.trailingAnchor.constraint(equalTo: domainContainer.trailingAnchor, constant: -12),
            domainValueLabel.centerYAnchor.constraint(equalTo: domainContainer.centerYAnchor)
        ])
        domainTitleLabel.isHidden = true
        domainContainer.isHidden = true
        return card
    }

    /// 创建固定在安全区底部的提交区域。
    /// - Returns: 含提交按钮的底部容器。
    private func makeBottomArea() -> UIView {
        let area = UIView()
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        area.addSubview(submitButton)
        area.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.97)
        submitButton.layer.cornerRadius = 22
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .disabled)
        submitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        submitButton.addTarget(self, action: #selector(handleSubmitTap), for: .touchUpInside)
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: area.topAnchor, constant: 10),
            submitButton.leadingAnchor.constraint(equalTo: area.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: area.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            submitButton.bottomAnchor.constraint(equalTo: area.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        updateSubmitState(enabled: false, isSubmitting: false)
        return area
    }

    /// 创建统一圆角表单卡片。
    /// - Returns: 自适应深浅色的卡片。
    private func makeCard() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }

    /// 创建表单分区标题。
    /// - Parameter text: 标题内容。
    /// - Returns: 已配置字体与颜色的标签。
    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }

    /// 创建选择区域分隔线。
    /// - Returns: 仅占半点高度的分隔视图。
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.45)
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return separator
    }

    /// 根据图片数量计算三列网格高度，最多显示三行。
    private func updateMediaHeight() {
        let itemCount = thumbnails.count < 9 ? thumbnails.count + 1 : thumbnails.count
        let rows = max(1, Int(ceil(Double(itemCount) / 3.0)))
        let width = mediaCollectionView.bounds.width
        let itemWidth = width > 20 ? floor((width - 20) / 3) : 96
        mediaHeightConstraint?.constant = CGFloat(rows) * itemWidth + CGFloat(rows - 1) * 10
        setNeedsLayout()
    }

    /// 订阅键盘显示与隐藏通知以调整滚动区域。
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardFrameChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 键盘出现或高度变化时为滚动区域增加底部空间。
    /// - Parameter notification: 包含键盘最终屏幕坐标的系统通知。
    @objc private func handleKeyboardFrameChange(_ notification: Notification) {
        guard
            let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let window
        else {
            return
        }
        let keyboardFrame = window.convert(frame, from: nil)
        let overlap = max(0, window.bounds.maxY - keyboardFrame.minY)
        scrollView.contentInset.bottom = overlap
        scrollView.verticalScrollIndicatorInsets.bottom = overlap
    }

    /// 键盘隐藏后恢复滚动区域原始间距。
    /// - Parameter notification: 系统键盘隐藏通知。
    @objc private func handleKeyboardHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    /// 转发返回按钮点击。
    @objc private func handleBackTap() {
        onBack?()
    }

    /// 收起键盘并转发投诉分类点击。
    @objc private func handleModeTap() {
        endEditing(true)
        onModeTap?()
    }

    /// 收起键盘并转发投诉原因点击。
    @objc private func handleReasonTap() {
        endEditing(true)
        onReasonTap?()
    }

    /// 转发邮箱输入变化。
    @objc private func handleEmailChanged() {
        onEmailChanged?(emailTextField.text ?? "")
    }

    /// 收起键盘并转发提交点击。
    @objc private func handleSubmitTap() {
        endEditing(true)
        onSubmit?()
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// 投诉内容输入长度限制。
extension CoHereComplainPageView: UITextViewDelegate {

    /// 限制输入结果不超过 200 个字符，兼容中文输入法选中态。
    /// - Parameters:
    ///   - textView: 投诉内容输入框。
    ///   - range: 即将替换的文本范围。
    ///   - text: 用户准备输入的文本。
    /// - Returns: 是否允许系统直接应用本次变更。
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard textView.markedTextRange == nil else {
            return true
        }
        guard let swiftRange = Range(range, in: textView.text) else {
            return false
        }
        return textView.text.replacingCharacters(in: swiftRange, with: text).count <= 200
    }

    /// 同步占位文本、字数统计和控制器内容状态。
    /// - Parameter textView: 当前投诉内容输入框。
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil, textView.text.count > 200 {
            textView.text = String(textView.text.prefix(200))
        }
        contentPlaceholderLabel.isHidden = !textView.text.isEmpty
        contentCountLabel.text = "\(textView.text.count)/200"
        onContentChanged?(textView.text)
    }
}

/// 投诉图片网格数据源与点击事件。
extension CoHereComplainPageView: UICollectionViewDataSource, UICollectionViewDelegate {

    /// 返回已选图片数量，并在未满 9 张时追加一个添加入口。
    /// - Parameters:
    ///   - collectionView: 图片网格。
    ///   - section: 当前分区。
    /// - Returns: 当前网格单元格数量。
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        thumbnails.count < 9 ? thumbnails.count + 1 : thumbnails.count
    }

    /// 创建图片预览单元格或末尾添加入口。
    /// - Parameters:
    ///   - collectionView: 图片网格。
    ///   - indexPath: 当前单元格位置。
    /// - Returns: 已配置的图片或添加单元格。
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.item < thumbnails.count {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CoHereComplainImageCell.reuseIdentifier,
                for: indexPath
            ) as! CoHereComplainImageCell
            cell.configure(image: thumbnails[indexPath.item], index: indexPath.item) { [weak self] index in
                self?.onDeleteImage?(index)
            }
            return cell
        }
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: CoHereComplainAddImageCell.reuseIdentifier,
            for: indexPath
        )
    }

    /// 点击末尾添加入口时请求打开图片选择器。
    /// - Parameters:
    ///   - collectionView: 图片网格。
    ///   - indexPath: 被点击的单元格位置。
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard indexPath.item == thumbnails.count, thumbnails.count < 9 else {
            return
        }
        endEditing(true)
        onAddImage?()
    }
}

/// 已选投诉图片单元格。
private final class CoHereComplainImageCell: UICollectionViewCell {

    /// Xcode 注册与复用使用的标识。
    static let reuseIdentifier = "CoHereComplainImageCell"
    /// 图片预览。
    private let imageView = UIImageView()
    /// 图片删除按钮。
    private let deleteButton = UIButton(type: .system)
    /// 当前图片在控制器数组中的下标。
    private var index = 0
    /// 删除图片回调。
    private var onDelete: ((Int) -> Void)?

    /// 使用代码创建单元格并完成布局。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Storyboard 初始化时完成相同布局。
    /// - Parameter coder: 系统解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 配置图片内容、数组下标与删除回调。
    /// - Parameters:
    ///   - image: 当前缩略图。
    ///   - index: 图片数组下标。
    ///   - onDelete: 删除按钮点击回调。
    func configure(image: UIImage, index: Int, onDelete: @escaping (Int) -> Void) {
        imageView.image = image
        self.index = index
        self.onDelete = onDelete
    }

    /// 创建图片预览和右上角删除按钮。
    private func setupUI() {
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        deleteButton.tintColor = .white
        deleteButton.backgroundColor = UIColor.black.withAlphaComponent(0.56)
        deleteButton.layer.cornerRadius = 11
        deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        deleteButton.addTarget(self, action: #selector(handleDeleteTap), for: .touchUpInside)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            deleteButton.widthAnchor.constraint(equalToConstant: 22),
            deleteButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    /// 转发当前图片删除操作。
    @objc private func handleDeleteTap() {
        onDelete?(index)
    }
}

/// 投诉图片末尾添加入口。
private final class CoHereComplainAddImageCell: UICollectionViewCell {

    /// Xcode 注册与复用使用的标识。
    static let reuseIdentifier = "CoHereComplainAddImageCell"

    /// 使用代码创建添加入口。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Storyboard 初始化时完成相同布局。
    /// - Parameter coder: 系统解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 创建相机图标和上传图片文字。
    private func setupUI() {
        let icon = UIImageView(image: UIImage(systemName: "camera"))
        let label = UILabel()
        icon.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(icon)
        contentView.addSubview(label)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor
        icon.tintColor = .secondaryLabel
        label.text = NoaLanguageManager.share().matchLocalLanguage("上传图片")
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 24),
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 7),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
}

/// 投诉页面顶部淡紫色渐变背景。
private final class CoHereComplainGradientView: UIView {

    /// 使用渐变层作为视图底层。
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    /// 创建并配置浅色渐变。
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureGradient()
    }

    /// Storyboard 初始化时配置相同渐变。
    /// - Parameter coder: 系统解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureGradient()
    }

    /// 设置渐变颜色与方向。
    private func configureGradient() {
        guard let gradient = layer as? CAGradientLayer else {
            return
        }
        gradient.colors = [
            UIColor(red: 0.93, green: 0.92, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.97, blue: 1, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
    }
}
