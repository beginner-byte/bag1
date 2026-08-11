//
//  CoHereFileHelperViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import UIKit

/// 文件传输助手 Swift 控制器，以专属模式复用消息引擎并保留文件助手输入能力和权限退出行为。
@objc(CoHereFileHelperViewController)
final class CoHereFileHelperViewController: NoaChatViewController {

    /// Figma 文件助手专属头部。
    private let fileHelperHeader = CoHereFileHelperPageView()

    /// 在父控制器初始化前开启文件助手模式，再安装 Figma 专属导航。
    override func viewDidLoad() {
        isFileHelperMode = true
        chatType = .singleChat
        chatName = localized("文件传输助手")
        super.viewDidLoad()
        setupFileHelperHeader()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fileHelperAuthorityChanged),
            name: Notification.Name("UserRoleAuthorityFileHelperChangeNotification"),
            object: nil
        )
    }

    /// 移除文件助手权限通知。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 将 Swift 头部覆盖在通用聊天导航上，消息列表和输入栏继续由共享聊天引擎管理。
    private func setupFileHelperHeader() {
        fileHelperHeader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fileHelperHeader)
        NSLayoutConstraint.activate([
            fileHelperHeader.topAnchor.constraint(equalTo: view.topAnchor),
            fileHelperHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fileHelperHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fileHelperHeader.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 44
            )
        ])
        fileHelperHeader.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        fileHelperHeader.onSettingsTap = { [weak self] in
            guard let self else { return }
            let controller = NoaFileHelperSetVC()
            controller.sessionID = self.sessionID
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    /// 用户角色关闭文件助手权限时，保持旧页面立即退出行为。
    @objc private func fileHelperAuthorityChanged() {
        let value = NoaUserManager.sharedInstance()
            .userRoleAuthInfo?
            .isShowFileAssistant
            .configValue
        if value == "false" {
            navigationController?.popViewController(animated: true)
        }
    }

    /// 获取本地化文案。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
