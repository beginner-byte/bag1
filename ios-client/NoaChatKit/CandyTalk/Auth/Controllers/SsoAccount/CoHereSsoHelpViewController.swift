//
//  CoHereSsoHelpViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// 原生网络设置说明控制器，负责承载 Swift 页面并处理返回导航。
final class CoHereSsoHelpViewController: UIViewController {

    /// Swift 实现的网络设置说明页面。
    private let pageView = CoHereSsoHelpPageView()

    /// 创建控制器并使用代码布局。
    /// - Parameters:
    ///   - nibNameOrNil: 未使用的 nib 名称。
    ///   - nibBundleOrNil: 未使用的 nib Bundle。
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    /// 创建控制器的默认初始化入口。
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    /// Storyboard 初始化入口，当前项目未使用。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// 创建 Swift 页面并绑定返回行为。
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupPage()
        bindPageActions()
    }

    /// 页面出现时保持项目自定义导航栏样式。
    /// - Parameter animated: 是否带有系统转场动画。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    /// 将网络设置说明页面铺满控制器。
    private func setupPage() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 将页面返回事件绑定到当前导航栈。
    private func bindPageActions() {
        pageView.onBackTap = { [weak self] in
            self?.handleBack()
        }
    }

    /// 返回邀请码配置页；无导航栈时兼容关闭模态页面。
    private func handleBack() {
        if let navigationController,
           navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
            return
        }
        dismiss(animated: true)
    }
}
