//
//  CoHereBlackListViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import MJExtension
import UIKit

/// “黑名单”Swift 控制器，负责加载、排序、查看和移出黑名单。
@objc(CoHereBlackListViewController)
final class CoHereBlackListViewController: CandyBaseViewController {

    /// 按拼音首字母分组后的用户数组。
    private var groupedUsers: [[LingIMFriendModel]] = []

    /// 与用户分组一一对应的拼音首字母。
    private var sectionTitles: [String] = []

    /// Figma 对应的完整黑名单页面。
    private let coHerePageView = CoHereBlackListPageView()

    /// 创建页面并请求服务器黑名单。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        requestBlackList()
    }

    /// 将 Swift UI 铺满控制器视图。
    private func setupPage() {
        coHerePageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coHerePageView)
        NSLayoutConstraint.activate([
            coHerePageView.topAnchor.constraint(equalTo: view.topAnchor),
            coHerePageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coHerePageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coHerePageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 绑定返回、查看用户和移出黑名单事件。
    private func bindPageActions() {
        coHerePageView.onBackTap = { [weak self] in
            self?.navBtnBackClicked()
        }
        coHerePageView.onUserTap = { [weak self] section, row in
            self?.openUser(section: section, row: row)
        }
        coHerePageView.onRemoveTap = { [weak self] section, row in
            self?.removeUser(section: section, row: row)
        }
    }

    /// 从服务器读取黑名单，并复用原中文排序规则生成页面分组。
    private func requestBlackList() {
        let userUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        let parameters: NSMutableDictionary = ["userUid": userUID]
        NoaIMSDKManager.sharedTool().getBlackListFromServer(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self else {
                    return
                }
                let dictionaries = data as? [[String: Any]] ?? []
                let users: [LingIMFriendModel] = dictionaries.compactMap { dictionary in
                    guard let model = LingIMFriendModel.mj_object(withKeyValues: dictionary) else {
                        return nil
                    }
                    let baseName = (NSString.isNil(model.remarks) ? model.nickname : model.remarks) ?? ""
                    model.showName = NSString.loadNickName(
                        withUserStatus: model.disableStatus,
                        realNickName: baseName
                    )
                    return model
                }
                configureSortedUsers(users)
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
            }
        )
    }

    /// 使用现有中文排序工具生成拼音分组。
    /// - Parameter users: 已完成展示名称规范化的黑名单用户。
    private func configureSortedUsers(_ users: [LingIMFriendModel]) {
        guard !users.isEmpty else {
            groupedUsers = []
            sectionTitles = []
            refreshPage()
            return
        }
        let setting = NoaChineseSortSetting.share()
        setting?.specialCharPositionIsFront = false
        NoaChineseSort.sortAndGroup(users, key: "showName") { [weak self] success, _, titles, groups in
            guard let self, success else {
                return
            }
            sectionTitles = titles as? [String] ?? []
            groupedUsers = groups as? [[LingIMFriendModel]] ?? []
            refreshPage()
        }
    }

    /// 把业务模型转换为 Swift 页面所需的展示字典。
    private func refreshPage() {
        let sections: [[String: Any]] = groupedUsers.enumerated().map { sectionIndex, users in
            let items: [[String: Any]] = users.enumerated().map { rowIndex, model in
                let avatar = NSString.loadAvatar(
                    withUserStatus: model.disableStatus,
                    avatarUri: model.avatar
                )
                let usesDeletedAvatar = avatar.hasPrefix("user_accout_delete_avatar")
                let displayName = NSString.loadNickName(
                    withUserStatus: model.disableStatus,
                    realNickName: model.showName
                )
                return [
                    "name": displayName,
                    "avatarURL": usesDeletedAvatar ? "" : avatar.getImageFullUrl().absoluteString,
                    "usesDeletedAvatar": usesDeletedAvatar,
                    "originalSection": sectionIndex,
                    "originalRow": rowIndex
                ]
            }
            return [
                "title": sectionTitles.indices.contains(sectionIndex) ? sectionTitles[sectionIndex] : "",
                "items": items
            ]
        }
        coHerePageView.coHereConfigure(sections: sections)
    }

    /// 打开指定黑名单用户的现有个人主页。
    /// - Parameters:
    ///   - section: 原始拼音分组下标。
    ///   - row: 分组内用户下标。
    private func openUser(section: Int, row: Int) {
        guard let model = user(section: section, row: row) else {
            return
        }
        let controller = NoaUserHomePageVC()
        controller.userUID = model.friendUserUID
        controller.groupID = ""
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 请求把指定用户移出黑名单，成功后同步本地分组。
    /// - Parameters:
    ///   - section: 原始拼音分组下标。
    ///   - row: 分组内用户下标。
    private func removeUser(section: Int, row: Int) {
        guard let model = user(section: section, row: row) else {
            return
        }
        let userUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        let parameters: NSMutableDictionary = [
            "userUid": userUID,
            "friendUserUid": model.friendUserUID ?? "",
            "status": 0
        ]
        NoaIMSDKManager.sharedTool().removeUserFromBlackList(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self else {
                    return
                }
                guard (data as? NSNumber)?.boolValue == true else {
                    NoaHUDManager.share().showMessage(localized("移除失败"))
                    return
                }
                groupedUsers[section].remove(at: row)
                if groupedUsers[section].isEmpty {
                    groupedUsers.remove(at: section)
                    sectionTitles.remove(at: section)
                }
                refreshPage()
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
            }
        )
    }

    /// 安全读取指定坐标的黑名单用户。
    /// - Parameters:
    ///   - section: 拼音分组下标。
    ///   - row: 分组内下标。
    /// - Returns: 坐标有效时返回用户模型，否则返回 nil。
    private func user(section: Int, row: Int) -> LingIMFriendModel? {
        guard groupedUsers.indices.contains(section),
              groupedUsers[section].indices.contains(row) else {
            return nil
        }
        return groupedUsers[section][row]
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
