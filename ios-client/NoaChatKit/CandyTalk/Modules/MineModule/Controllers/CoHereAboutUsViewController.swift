//
//  CoHereAboutUsViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// Swift 原生“关于我们”控制器，负责版本信息和协议详情导航。
@objc(CoHereAboutUsViewController)
final class CoHereAboutUsViewController: CandyBaseViewController {

    /// “关于我们”页面的 Swift 视觉层。
    private let coHerePageView = CoHereAboutUsPageView()

    /// 创建页面、绑定协议入口并填充当前 App 版本。
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitleStr = localized("关于我们")
        setupPage()
        bindPageActions()
        configureVersion()
    }

    /// 将页面放在项目原生导航栏下方并铺满剩余区域。
    private func setupPage() {
        coHerePageView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(coHerePageView, belowSubview: navView)
        NSLayoutConstraint.activate([
            coHerePageView.topAnchor.constraint(equalTo: navView.bottomAnchor),
            coHerePageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coHerePageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coHerePageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 将两个协议行的点击事件绑定到原生协议详情页面。
    private func bindPageActions() {
        coHerePageView.onPolicyTap = { [weak self] policy in
            self?.openPolicyDetail(policy)
        }
    }

    /// 使用现有版本工具和本地化格式填充版本文案。
    private func configureVersion() {
        let tool = NoaToolManager.share()
        let versionText = String(
            format: localized("当前版本v%@ %@"),
            tool.getCurretnVersion(),
            tool.getBuildVersion()
        )
        coHerePageView.configure(versionText: versionText)
    }

    /// 按稳定枚举打开服务协议或隐私政策，避免依赖本地化标题判断。
    /// - Parameter policy: 用户点击的协议类型。
    private func openPolicyDetail(_ policy: CoHereAboutUsPolicy) {
        let controller = NoaBaseWebViewController()
        switch policy {
        case .service:
            controller.webViewTitle = localized("服务协议")
            controller.webViewUrl = servicePolicyUrl
        case .privacy:
            controller.webViewTitle = localized("隐私政策")
            controller.webViewUrl = privacyPolicyUrl
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
