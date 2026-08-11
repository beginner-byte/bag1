//
//  CoHereFileHelperPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import UIKit

/// 文件传输助手页面专属 Swift 头部，覆盖通用聊天引擎的导航外观。
final class CoHereFileHelperPageView: UIView {

    /// 返回按钮点击回调。
    var onBackTap: (() -> Void)?

    /// 文件助手设置按钮点击回调。
    var onSettingsTap: (() -> Void)?

    /// Figma 渐变背景。
    private let gradient = CAGradientLayer()

    /// 返回按钮。
    private let backButton = UIButton(type: .custom)

    /// 页面标题。
    private let titleLabel = UILabel()

    /// 右侧更多设置按钮。
    private let settingsButton = UIButton(type: .custom)

    /// 创建文件助手头部。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bindActions()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bindActions()
    }

    /// 更新渐变尺寸。
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    /// 创建与 Figma 一致的返回、标题和更多按钮。
    private func setupView() {
        backgroundColor = UIColor(red: 0.86, green: 0.86, blue: 1, alpha: 1)
        gradient.colors = [
            UIColor(red: 0.73, green: 0.74, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.84, green: 0.9, blue: 1, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradient, at: 0)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "icon_nav_back"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        addSubview(backButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NoaLanguageManager.share()
            .matchLocalLanguage("文件传输助手")
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.16, alpha: 1)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setImage(UIImage(named: "c_nav_more_black"), for: .normal)
        settingsButton.imageView?.contentMode = .scaleAspectFit
        addSubview(settingsButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            settingsButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    /// 绑定返回和设置事件。
    private func bindActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
    }

    /// 转发返回点击。
    @objc private func backTapped() {
        onBackTap?()
    }

    /// 转发设置点击。
    @objc private func settingsTapped() {
        onSettingsTap?()
    }
}
