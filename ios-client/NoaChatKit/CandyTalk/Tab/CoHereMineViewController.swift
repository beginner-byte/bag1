//
//  CoHereMineViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import MJExtension
import ObjectiveC
import UIKit

/// “我的”Swift 控制器，承载抽屉展示、菜单路由和用户二维码业务。
@objc(CoHereMineViewController)
final class CoHereMineViewController: CandyBaseViewController {

    /// 当前菜单二维数据，保留原 section/row 供 Swift UI 回调。
    private var menuSections: NSMutableArray = []

    /// Figma 对应的完整“我的”页面。
    private let coHerePageView = CoHereMinePageView()

    /// 以原 0.8 屏宽抽屉形式展示“我的”页面。
    @objc class func presentMineDrawerFromTop() {
        guard let presenter = rootNavigationController() else {
            return
        }
        if let presentedNavigation = presenter.presentedViewController as? UINavigationController,
           presentedNavigation.viewControllers.first is CoHereMineViewController,
           presentedNavigation.transitioningDelegate != nil {
            return
        }

        let controller = CoHereMineViewController()
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.modalPresentationStyle = .custom
        let transition = NoaDrawerTransitioningDelegate()
        transition.contentWidthRatio = 0.8
        transition.duration = 0.28
        navigation.transitioningDelegate = transition
        objc_setAssociatedObject(
            navigation,
            &CoHereMineAssociationKeys.transitioningDelegate,
            transition,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        presenter.present(navigation, animated: true)
    }

    /// 创建页面、注册通知并生成菜单数据。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        setupNotifications()
        rebuildMenu()
    }

    /// 页面出现后同步可能变化的用户资料。
    /// - Parameter animated: 是否使用系统转场动画。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshPage()
    }

    /// 返回“我的”页时恢复抽屉宽度。
    /// - Parameter animated: 是否使用系统转场动画。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard navigationController?.topViewController === self,
              let drawer = navigationController?.presentationController as? NoaDrawerPresentationController else {
            return
        }
        drawer.updateContentWidthRatio(0.8, animated: true)
    }

    /// 移除用户资料与权限变化通知。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 将 Swift UI 铺满控制器视图。
    private func setupPage() {
        coHerePageView.accessibilityIdentifier = "cohere.mine"
        coHerePageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coHerePageView)
        NSLayoutConstraint.activate([
            coHerePageView.topAnchor.constraint(equalTo: view.topAnchor),
            coHerePageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coHerePageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coHerePageView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }

    /// 绑定菜单和资料区事件。
    private func bindPageActions() {
        coHerePageView.onMenuTap = { [weak self] section, row in
            self?.handleMenu(section: section, row: row)
        }
        coHerePageView.onInfoAction = { [weak self] action in
            self?.handleInfoAction(action)
        }
    }

    /// 监听用户资料、权限和翻译开关变化。
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshPage),
            name: Notification.Name("MineUserInfoUpdate"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rebuildMenu),
            name: Notification.Name("UserRoleAuthorityShowTeamChangeNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rebuildMenu),
            name: NSNotification.Name.UserRoleAuthorityTranslateFlagDidChange,
            object: nil
        )
    }

    /// 按原权限规则重建菜单二维数组。
    @objc private func rebuildMenu() {
        let team: NSDictionary = ["imageName": "b_team", "titleName": localized("我的团队")]
        let collection: NSDictionary = ["imageName": "b_star", "titleName": localized("我的收藏")]
        let blacklist: NSDictionary = ["imageName": "b_ban", "titleName": localized("黑名单")]
        let translation: NSDictionary = ["imageName": "b_language", "titleName": localized("翻译管理")]
        let language: NSDictionary = ["imageName": "b_la", "titleName": localized("应用语言")]
        let privacy: NSDictionary = ["imageName": "b_pri", "titleName": localized("隐私设置")]
        let security: NSDictionary = ["imageName": "b_safe", "titleName": localized("安全设置")]
        let support: NSDictionary = ["imageName": "b_suggest", "titleName": localized("投诉与支持")]
        let network: NSDictionary = ["imageName": "mine_networkDetect", "titleName": localized("网络检测")]
        let about: NSDictionary = ["imageName": "mine_about", "titleName": localized("关于我们")]

        let settingRows = NSMutableArray(object: language)
        if NoaUserManager.sharedInstance().isTranslateEnabled() {
            settingRows.add(translation)
        }
        settingRows.addObjects(from: [security, privacy, network, support])
        menuSections = NSMutableArray(array: [
            [team],
            [collection, blacklist],
            settingRows,
            [about]
        ])
        refreshPage()
    }

    /// 使用当前用户资料和菜单刷新页面。
    @objc private func refreshPage() {
        let user = NoaUserManager.sharedInstance().userInfo
        coHerePageView.coHereConfigure(
            avatarURL: user?.avatar.getImageFullUrl(),
            nickname: user?.nickname ?? "",
            account: user?.userName ?? "",
            sections: menuSections
        )
    }

    /// 根据原 section/row 菜单坐标执行现有导航。
    /// - Parameters:
    ///   - section: 菜单分组下标。
    ///   - row: 分组内下标。
    private func handleMenu(section: Int, row: Int) {
        guard
            menuSections.count > section,
            let rows = menuSections[section] as? NSArray,
            rows.count > row,
            let dictionary = rows[row] as? NSDictionary,
            let title = dictionary["titleName"] as? String
        else {
            return
        }

        switch title {
        case localized("我的团队"):
            openFullScreen(CoHereTeamListViewController())
        case localized("每日签到"):
            openFullScreen(CoHereDailySignInViewController())
        case localized("我的收藏"):
            let controller = CoHereMyCollectionViewController()
            controller.isFromChat = false
            openFullScreen(controller)
        case localized("黑名单"):
            openFullScreen(CoHereBlackListViewController())
        case localized("翻译管理"):
            openFullScreen(CoHereTranslateSetDefaultViewController())
        case localized("应用语言"):
            let controller = CoHereLanguageSettingViewController()
            controller.changeType = .tabbar
            openFullScreen(controller)
        case localized("隐私设置"):
            openFullScreen(CoHerePrivacySettingViewController())
        case localized("安全设置"):
            openFullScreen(CoHereSafeSettingViewController())
        case localized("投诉与支持"):
            openFullScreen(CoHereComplainViewController())
        case localized("关于我们"):
            openFullScreen(CoHereAboutUsViewController())
        case localized("系统设置"):
            openFullScreen(CoHereSystemSettingViewController())
        case localized("网络检测"):
            let controller = CoHereNetworkDetectionViewController()
            controller.currentSsoNumber = NoaSsoInfoModel.getSSOInfo().liceseId
            openFullScreen(controller)
        case localized("二维码"):
            requestQRCodeContent()
        default:
            break
        }
    }

    /// 处理资料区固定 actionTag。
    /// - Parameter action: 200/202 为资料，201 为系统设置，9901 为二维码，9902 为签到。
    private func handleInfoAction(_ action: Int) {
        switch action {
        case 200, 202:
            openFullScreen(CoHereUserInfoViewController())
        case 201:
            openFullScreen(CoHereSystemSettingViewController())
        case 9901:
            requestQRCodeContent()
        case 9902:
            openFullScreen(CoHereDailySignInViewController())
        default:
            break
        }
    }

    /// 从抽屉或普通导航环境打开全屏业务页面。
    /// - Parameter controller: 需要打开的目标页面。
    private func openFullScreen(_ controller: UIViewController) {
        controller.hidesBottomBarWhenPushed = true
        if navigationController?.presentationController is NoaDrawerPresentationController {
            navigationController?.dismiss(animated: true) {
                Self.rootNavigationController()?.pushViewController(controller, animated: true)
            }
            return
        }
        if let navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            Self.rootNavigationController()?.pushViewController(controller, animated: true)
        }
    }

    /// 请求个人二维码内容并打开 Swift 二维码页面。
    private func requestQRCodeContent() {
        let parameters: NSMutableDictionary = [
            "content": "",
            "type": 1,
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ]
        NoaHUDManager.share().showActivityMessage("")
        NoaIMSDKManager.sharedTool().userGetCreatQrcodeContent(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                NoaHUDManager.share().hideHUD()
                let model = NoaQRCodeModel.mj_object(withKeyValues: data)
                let controller = CoHereMyQRCodeViewController()
                controller.qrcodeContent = model?.content ?? ""
                self?.openFullScreen(controller)
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().hideHUD()
                NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
            }
        )
    }

    /// 获取 App 当前可见 Tab 对应的根导航控制器。
    /// - Returns: 可用于 present 或 push 的导航控制器；无法解析时返回 nil。
    private class func rootNavigationController() -> UINavigationController? {
        let root = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
        if let navigation = root as? UINavigationController {
            return navigation
        }
        if let tab = root as? UITabBarController {
            return tab.selectedViewController as? UINavigationController
        }
        return nil
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Objective-C 关联对象键，负责延长抽屉转场代理生命周期。
private enum CoHereMineAssociationKeys {
    /// 抽屉导航控制器持有转场代理使用的唯一关联键。
    static var transitioningDelegate: UInt8 = 0
}
