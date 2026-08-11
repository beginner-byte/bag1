//
//  CoHereNetworkDetectionViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import UIKit

/// “网络检测”Swift 控制器，使用 Figma 页面承载现有 Objective-C 网络检测业务。
@objc(CoHereNetworkDetectionViewController)
final class CoHereNetworkDetectionViewController: CandyBaseViewController {

    /// 当前邀请码；登录前入口允许传入空值，Objective-C 聊天入口也通过该属性传值。
    @objc var currentSsoNumber: String?

    /// 复用原有 DNS、导航、TCP 和 ECDH 检测流程的业务处理对象。
    private lazy var dataHandle = NoaNetworkDetectionHandle(
        currentSsoNumber: currentSsoNumber ?? ""
    )

    /// 按照 Figma 节点实现的完整网络检测页面。
    private let pageView = CoHereNetworkDetectionPageView()

    /// 创建页面、绑定交互与业务状态，并展示初始待检测状态。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        bindDataHandle()
        reloadDetectionItems()
        showReadyHeader()
        pageView.configureActionButton(state: .ready)
    }

    /// 记录页面释放并由业务处理对象取消仍在进行的异步检测。
    deinit {
        dataHandle.cancelAllDetections()
        NSLog("%@ dealloc", String(describing: Self.self))
    }

    /// 将 Swift 页面铺满控制器视图，交由页面内部处理安全区。
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

    /// 绑定返回、检测按钮和检测分组展开事件。
    private func bindPageActions() {
        pageView.onBackTap = { [weak self] in
            self?.navBtnBackClicked()
        }
        pageView.onActionTap = { [weak self] in
            self?.handleDetectionAction()
        }
        pageView.onSectionTap = { [weak self] section in
            self?.toggleSection(at: section)
        }
    }

    /// 订阅原业务对象的头部、列表、分组状态及检测完成信号。
    private func bindDataHandle() {
        _ = dataHandle.headerViewReloadDataSubject.subscribeNext { [weak self] value in
            self?.handleHeaderStatus(value)
        }
        _ = dataHandle.tableViewReloadDataSubject.subscribeNext { [weak self] _ in
            self?.reloadDetectionItems()
        }
        _ = dataHandle.startDetectionCommand.executionSignals
            .switchToLatest()
            .subscribeNext { [weak self] _ in
                self?.handleDetectionCommandCompletion()
            }

        for (section, model) in detectionModels.enumerated() {
            _ = model.changeStatusSubject.subscribeNext { [weak self] _ in
                self?.pageView.reloadSection(at: section)
            }
        }
    }

    /// 执行开始、重新检测或检测中取消操作，顺序与旧页面保持一致。
    private func handleDetectionAction() {
        let status = Int(dataHandle.networkDetectionStatus.rawValue)
        if status == 0 || status == 2 {
            pageView.configureActionButton(state: .detecting)
            dataHandle.startDetectionCommand.execute(nil)
        } else {
            pageView.configureActionButton(state: .ready)
            dataHandle.cleanLastDetectionData()
            dataHandle.cancelAllDetections()
        }
    }

    /// 在检测命令完成后根据业务对象最终状态刷新底部按钮。
    private func handleDetectionCommandCompletion() {
        let status = Int(dataHandle.networkDetectionStatus.rawValue)
        pageView.configureActionButton(
            state: status == 2 ? .finished : .ready
        )
    }

    /// 处理业务对象的头部状态字典，保留准备、进度、成功和异常文案。
    /// - Parameter value: `status` 为检测状态，`process` 为检测百分比。
    private func handleHeaderStatus(_ value: Any?) {
        guard let dictionary = value as? NSDictionary else {
            return
        }
        let status = (dictionary["status"] as? NSNumber)?.intValue ?? 0
        let progress = (dictionary["process"] as? NSNumber)?.intValue ?? 0

        switch status {
        case 1:
            pageView.configureHeader(
                title: localized("网络检测"),
                message: String(
                    format: localized("已检测 %ld%%..."),
                    progress
                ),
                imageName: "cohere_network_detection_header",
                highlightNumbers: true
            )
        case 2:
            let failureCount = dataHandle.getAllUnPassSubResultCount()
            if failureCount == 0 {
                pageView.configureHeader(
                    title: localized("网络状态正常"),
                    message: localized("完成网络检测，当前网络状况良好"),
                    imageName: "icon_network_detection_header",
                    highlightNumbers: false
                )
            } else {
                pageView.configureHeader(
                    title: localized("网络状态异常"),
                    message: String(
                        format: localized("发现 %ld 个异常项"),
                        failureCount
                    ),
                    imageName: "icon_network_detection_header_error",
                    highlightNumbers: true
                )
            }
        default:
            showReadyHeader()
        }
    }

    /// 展示 Figma 初始状态及当前入口传入的邀请码。
    private func showReadyHeader() {
        pageView.configureHeader(
            title: localized("网络检测"),
            message: localized("检测准备就绪，请点击开始检测"),
            imageName: "cohere_network_detection_header",
            highlightNumbers: false
        )
        pageView.configureInviteCode(currentSsoNumber)
    }

    /// 将业务对象当前固定分组重新交给 Swift 列表展示。
    private func reloadDetectionItems() {
        pageView.configure(models: detectionModels)
    }

    /// 当前业务对象中的全部检测分组，数量随登录状态和邀请码变化。
    private var detectionModels: [NoaNetworkDetectionMessageModel] {
        (dataHandle.tableDataSource as NSArray).compactMap {
            $0 as? NoaNetworkDetectionMessageModel
        }
    }

    /// 切换已开始检测分组的展开状态；待检测分组保持不可展开。
    /// - Parameter section: 被点击的检测分组下标。
    private func toggleSection(at section: Int) {
        let models = detectionModels
        guard models.indices.contains(section) else {
            return
        }
        let model = models[section]
        guard Int(model.messageStatus.rawValue) != 0 else {
            return
        }
        model.isFold.toggle()
        pageView.configure(models: models)
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
