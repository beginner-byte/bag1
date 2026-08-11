//
//  CoHereNewFriendListViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import MMKV
import UIKit

/// “新的朋友”Swift 控制器，保留原好友申请分页、已读、隐藏和通过验证逻辑。
@objc(CoHereNewFriendListViewController)
final class CoHereNewFriendListViewController: CandyBaseViewController, NoaToolUserDelegate {

    /// Figma 页面视觉层。
    private let pageView = CoHereNewFriendListPageView()

    /// 当前服务端分页页码，从 1 开始。
    private var pageNumber = 1

    /// 服务端返回且未被本地隐藏的好友申请。
    private var requests: [NoaFriendApplyModel] = []

    /// 当前搜索结果；空搜索时等于完整申请列表。
    private var filteredRequests: [NoaFriendApplyModel] = []

    /// 本地隐藏申请的 `hashKey-sendTime` 标识。
    private var hiddenRequestKeys: [String] = []

    /// 本地已读申请的 `hashKey-sendTime` 标识。
    private var readRequestKeys: [String] = []

    /// 服务端是否可能仍有下一页。
    private var canLoadMore = true

    /// 当前搜索关键字。
    private var searchText = ""

    /// 初始化页面、读取本地状态并请求第一页。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        loadLocalRequestState()
        setupPage()
        bindPageActions()
        NoaIMSDKManager.sharedTool().addUserDelegate(self)
        requestApplications(reset: true, showLoading: true)
    }

    /// 返回页面时刷新申请状态。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySearchFilter()
    }

    /// 移除 SDK 代理，避免控制器释放后继续接收回调。
    deinit {
        NoaIMSDKManager.sharedTool().removeUserDelegate(self)
    }

    /// 收到新的好友邀请后按原逻辑重新请求第一页。
    func cimToolUserFriendInvite(_ message: FriendInviteMessage) {
        requestApplications(reset: true, showLoading: false)
    }

    /// 将 Figma 页面铺满控制器。
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

    /// 连接页面事件与原有业务方法。
    private func bindPageActions() {
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onAddFriendTap = { [weak self] in
            self?.navigationController?.pushViewController(
                CoHereAddFriendViewController(),
                animated: true
            )
        }
        pageView.onSearchChanged = { [weak self] text in
            self?.searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.applySearchFilter()
        }
        pageView.onRequestTap = { [weak self] model in self?.openApplication(model) }
        pageView.onAcceptTap = { [weak self] model in self?.acceptApplication(model) }
        pageView.onDeleteTap = { [weak self] model in self?.hideApplication(model) }
        pageView.onRefresh = { [weak self] in
            self?.requestApplications(reset: true, showLoading: false)
        }
        pageView.onLoadMore = { [weak self] in
            self?.requestApplications(reset: false, showLoading: false)
        }
        pageView.onVisibleRequestsChanged = { [weak self] models in
            self?.markVisibleApplicationsRead(models)
        }
    }

    /// 读取原 Objective-C 页面使用的 MMKV 隐藏与已读数组。
    private func loadLocalRequestState() {
        hiddenRequestKeys = MMKV.default()?
            .string(forKey: "HiddenFriendApply")?
            .split(separator: ",")
            .map(String.init) ?? []
        readRequestKeys = MMKV.default()?
            .string(forKey: "ReadFriendApply")?
            .split(separator: ",")
            .map(String.init) ?? []
    }

    /// 请求好友申请分页，参数和原页面保持一致。
    /// - Parameters:
    ///   - reset: 是否从第一页重新加载。
    ///   - showLoading: 是否展示全屏加载提示。
    private func requestApplications(reset: Bool, showLoading: Bool) {
        if reset {
            pageNumber = 1
        } else {
            guard canLoadMore else {
                pageView.endRefreshing()
                return
            }
            pageNumber += 1
        }
        if showLoading {
            NoaHUDManager.share().showActivityMessage("")
        }
        let parameters = NSMutableDictionary(dictionary: [
            "pageStart": (pageNumber - 1) * 20,
            "pageSize": 20,
            "pageNumber": pageNumber,
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ])
        NoaIMSDKManager.sharedTool().getFriendApplyListFromServer(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self else { return }
                NoaHUDManager.share().hideHUD()
                let dictionary = data as? [String: Any]
                let rows = dictionary?["rows"] as? [[String: Any]] ?? []
                let models = NoaFriendApplyModel.mj_objectArray(
                    withKeyValuesArray: rows
                ) as? [NoaFriendApplyModel] ?? []
                if reset {
                    self.requests.removeAll()
                }
                self.requests.append(
                    contentsOf: models.filter {
                        !self.hiddenRequestKeys.contains(self.requestKey(for: $0))
                    }
                )
                self.canLoadMore = rows.count >= 20
                self.applySearchFilter()
            },
            onFailure: { [weak self] code, message, _ in
                guard let self else { return }
                if !reset {
                    self.pageNumber = max(1, self.pageNumber - 1)
                }
                NoaHUDManager.share().hideHUD()
                self.pageView.endRefreshing()
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 根据搜索关键字过滤昵称，并刷新 Figma 页面。
    private func applySearchFilter() {
        if searchText.isEmpty {
            filteredRequests = requests
        } else {
            filteredRequests = requests.filter {
                $0.nickname.localizedCaseInsensitiveContains(searchText) ||
                    $0.beUserNickname.localizedCaseInsensitiveContains(searchText)
            }
        }
        pageView.configure(models: filteredRequests, canLoadMore: canLoadMore)
    }

    /// 打开申请人的好友主页或好友申请验证页。
    private func openApplication(_ model: NoaFriendApplyModel) {
        let currentUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        let userUID = model.fromUserUid == currentUID
            ? model.beUserUid
            : model.fromUserUid
        let existingFriend: LingIMFriendModel? = NoaIMSDKManager.sharedTool()
            .toolCheckMyFriend(with: userUID)
        if existingFriend != nil {
            let controller = NoaUserHomePageVC()
            controller.userUID = userUID
            controller.groupID = ""
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = NoaFriendApplyPassVC()
            controller.applyModel = model
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    /// 通过对方发起且仍在申请中的好友申请。
    private func acceptApplication(_ model: NoaFriendApplyModel) {
        let currentUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        guard model.beStatus == 0, model.fromUserUid != currentUID else {
            return
        }
        let parameters = NSMutableDictionary(dictionary: [
            "friendUserUid": model.fromUserUid,
            "userUid": currentUID
        ])
        NoaIMSDKManager.sharedTool().confirmFriendApply(
            with: parameters,
            onSuccess: { [weak self] _, _ in
                model.beStatus = 1
                NoaHUDManager.share().showMessage(self?.localized("添加成功") ?? "")
                self?.removeReadState(for: model)
                self?.fetchAndStoreFriend(model)
                self?.applySearchFilter()
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 获取通过申请后的完整好友资料并写入现有本地好友数据库。
    private func fetchAndStoreFriend(_ model: NoaFriendApplyModel) {
        let parameters = NSMutableDictionary(dictionary: [
            "friendUserUid": model.fromUserUid,
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ])
        NoaIMSDKManager.sharedTool().getFriendInfo(
            with: parameters,
            onSuccess: { data, _ in
                guard let dictionary = data as? [String: Any],
                      let friend = LingIMFriendModel.mj_object(
                        withKeyValues: dictionary
                      ) else {
                    return
                }
                NoaIMSDKManager.sharedTool().toolAddMyFriend(with: friend)
            },
            onFailure: { _, _, _ in }
        )
    }

    /// 将好友申请加入原有本地隐藏列表并从页面移除。
    private func hideApplication(_ model: NoaFriendApplyModel) {
        let key = requestKey(for: model)
        if !hiddenRequestKeys.contains(key) {
            hiddenRequestKeys.append(key)
        }
        MMKV.default()?.set(
            hiddenRequestKeys.joined(separator: ","),
            forKey: "HiddenFriendApply"
        )
        requests.removeAll { $0 === model }
        removeReadState(for: model)
        applySearchFilter()
    }

    /// 根据当前可见模型清除同步红点列表，避免分组后使用行号映射到错误申请。
    private func markVisibleApplicationsRead(_ visibleModels: [NoaFriendApplyModel]) {
        guard !visibleModels.isEmpty else { return }
        let storageKey = "FriendSyncReqList_\(NoaUserManager.sharedInstance().userInfo?.userUID ?? "")"
        guard let list = MMKV.default()?.object(
            of: NSMutableArray.self,
            forKey: storageKey
        ) as? NSMutableArray else {
            return
        }
        for model in visibleModels {
            for case let request as NoaFriendReqModel in list.copy() as? [Any] ?? [] {
                if request.hashKey == model.hashKey {
                    list.remove(request)
                }
            }
        }
        MMKV.default()?.set(list, forKey: storageKey)
        NoaIMSDKManager.sharedTool().toolUpdateFriendApplyCount(list.count)
        NotificationCenter.default.post(
            name: Notification.Name("FriendApplyCountChange"),
            object: nil
        )
    }

    /// 从已读列表删除一条申请。
    private func removeReadState(for model: NoaFriendApplyModel) {
        readRequestKeys.removeAll { $0 == requestKey(for: model) }
        persistReadState()
    }

    /// 保存原有 `ReadFriendApply` MMKV 字符串。
    private func persistReadState() {
        MMKV.default()?.set(
            readRequestKeys.joined(separator: ","),
            forKey: "ReadFriendApply"
        )
    }

    /// 生成好友申请的稳定本地标识。
    private func requestKey(for model: NoaFriendApplyModel) -> String {
        "\(model.hashKey)-\(model.sendTime)"
    }

    /// 获取当前语言文案。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
