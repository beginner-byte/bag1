//
//  CoHereSafeSettingViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import MJExtension
import MMKV
import UIKit

/// “安全设置”Swift 控制器，保留修改密码、手势密码和设备安全码的原有业务。
///
/// Objective-C 运行时使用 CoHere 类名，供设备安全码页面在导航栈中查找并刷新状态。
@objc(CoHereSafeSettingViewController)
final class CoHereSafeSettingViewController: CandyBaseViewController,
    ZGestureLockCheckVCDelegate {

    /// 服务器返回的当前用户设备安全码启用状态。
    private var isDeviceSafeCodeEnabled = false

    /// Figma 对应的完整安全设置页面。
    private let coHerePageView = CoHereSafeSettingPageView()

    /// 创建页面、绑定交互、请求设备安全码状态并监听手势密码变更。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        refreshPage()
        requestDeviceSafeCodeStatus()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadGesturePassword),
            name: Notification.Name("UserSetGesturePassword"),
            object: nil
        )
    }

    /// 移除手势密码状态通知，避免控制器销毁后继续接收回调。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 供现有 Objective-C 设备安全码页面在设置或关闭成功后刷新状态。
    @objc func checkDeviceSafeCodeStatus() {
        requestDeviceSafeCodeStatus()
    }

    /// 将 Swift 页面铺满控制器视图。
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

    /// 绑定返回和三个安全设置入口。
    private func bindPageActions() {
        coHerePageView.onBackTap = { [weak self] in
            self?.navBtnBackClicked()
        }
        coHerePageView.onItemTap = { [weak self] item in
            self?.handleItemTap(item)
        }
    }

    /// 使用 MMKV 手势密码状态和服务器设备安全码状态刷新页面。
    private func refreshPage() {
        coHerePageView.configure(
            gestureEnabled: isGesturePasswordEnabled,
            deviceSafeCodeEnabled: isDeviceSafeCodeEnabled
        )
    }

    /// 当前账号是否已保存非空手势密码。
    private var isGesturePasswordEnabled: Bool {
        guard let password = MMKV.default()?.string(forKey: gesturePasswordKey) else {
            return false
        }
        return !password.isEmpty
    }

    /// 当前账号的手势密码 MMKV Key，格式与旧页面完全一致。
    private var gesturePasswordKey: String {
        "\(currentUserUID)-GesturePassword"
    }

    /// 当前登录用户 ID；用户信息缺失时沿用旧字典安全写入语义，传递空字符串。
    private var currentUserUID: String {
        NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
    }

    /// 当前登录用户名，用于查询账号是否已经设置登录密码。
    private var currentUserName: String {
        NoaUserManager.sharedInstance().userInfo?.userName ?? ""
    }

    /// 处理安全设置行的点击并进入对应业务流程。
    /// - Parameter item: 被点击的安全设置项。
    private func handleItemTap(_ item: CoHereSafeSettingItem) {
        switch item {
        case .changePassword:
            requestCheckUserHasSetPassword()
        case .gestureUnlock:
            if isGesturePasswordEnabled {
                showGestureLockActions()
            } else {
                presentGestureLockSetup()
            }
        case .deviceSafeCode:
            if isDeviceSafeCodeEnabled {
                showDeviceSafeCodeActions()
            } else {
                let controller = CoHereSafeCodeEditorViewController()
                controller.mode = .create
                navigationController?.pushViewController(controller, animated: true)
            }
        case .trustedDevices:
            let controller = NoaTrustedDeviceViewController()
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    /// 检查当前账号是否已设置登录密码，并进入原有的新密码或旧密码页面。
    private func requestCheckUserHasSetPassword() {
        let parameters: NSMutableDictionary = [
            "loginInfo": currentUserName,
            "areaCode": "",
            "loginType": 1
        ]
        NoaIMSDKManager.sharedTool().authUserExistAndHasPwd(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self, let dictionary = data as? NSDictionary else {
                    return
                }
                let passwordExists = (dictionary["pwdExit"] as? NSNumber)?.boolValue ?? false
                let controller = CoHerePasswordSettingViewController()
                controller.isForcedReset = false
                controller.requiresOldPassword = passwordExists
                navigationController?.pushViewController(controller, animated: true)
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 请求当前用户信息，并从原用户模型读取设备安全码启用状态。
    private func requestDeviceSafeCodeStatus() {
        let parameters: NSMutableDictionary = ["userUid": currentUserUID]
        NoaIMSDKManager.sharedTool().getUserInfo(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self,
                      let dictionary = data as? NSDictionary,
                      let userModel = NoaUserModel.mj_object(
                          withKeyValues: dictionary
                      ) as? NoaUserModel else {
                    return
                }
                isDeviceSafeCodeEnabled = userModel.hasSecurityCode
                refreshPage()
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 全屏展示现有手势密码设置页。
    private func presentGestureLockSetup() {
        let controller = NoaGestureLockSetVC()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    /// 展示修改或关闭手势密码的现有底部操作面板。
    private func showGestureLockActions() {
        showActionSheet(
            primaryTitle: localized("修改手势密码"),
            secondaryTitle: localized("关闭手势密码"),
            primaryAction: { [weak self] in self?.changeGestureLock() },
            secondaryAction: { [weak self] in self?.closeGestureLock() }
        )
    }

    /// 先进入原有手势密码验证页，验证通过后修改手势密码。
    private func changeGestureLock() {
        let controller = NoaGestureLockCheckVC()
        controller.delegate = self
        controller.checkType = .change
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    /// 先进入原有手势密码验证页，验证通过后关闭手势密码。
    private func closeGestureLock() {
        let controller = NoaGestureLockCheckVC()
        controller.delegate = self
        controller.checkType = .close
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    /// 展示修改或关闭设备安全码的现有底部操作面板。
    private func showDeviceSafeCodeActions() {
        showActionSheet(
            primaryTitle: localized("修改安全码"),
            secondaryTitle: localized("关闭安全码"),
            primaryAction: { [weak self] in self?.changeDeviceSafeCode() },
            secondaryAction: { [weak self] in self?.closeDeviceSafeCode() }
        )
    }

    /// 进入现有设备安全码修改页。
    private func changeDeviceSafeCode() {
        let controller = CoHereSafeCodeEditorViewController()
        controller.mode = .change
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 进入现有设备安全码关闭页，并保持原关闭操作类型。
    private func closeDeviceSafeCode() {
        let controller = NoaSafeCodeCloseViewController()
        controller.operatorType = .close
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 使用现有 NoaPresentView 构建双操作项和取消项，并同步浅色/暗色主题。
    /// - Parameters:
    ///   - primaryTitle: 第一项操作标题。
    ///   - secondaryTitle: 第二项操作标题。
    ///   - primaryAction: 点击第一项后的业务操作。
    ///   - secondaryAction: 点击第二项后的业务操作。
    private func showActionSheet(
        primaryTitle: String,
        secondaryTitle: String,
        primaryAction: @escaping () -> Void,
        secondaryAction: @escaping () -> Void
    ) {
        let primaryItem = presentItem(title: primaryTitle, isCancel: false)
        let secondaryItem = presentItem(title: secondaryTitle, isCancel: false)
        let cancelItem = presentItem(title: localized("取消"), isCancel: true)

        tkThemeChangeBlock = { [weak self] _, themeIndex in
            guard self != nil else {
                return
            }
            let isDark = themeIndex != 0
            let backgroundColor = isDark
                ? UIColor(coHereSafeSettingHex: 0x111111)
                : .white
            let actionColor = isDark
                ? .white
                : UIColor(coHereSafeSettingHex: 0x111111)
            primaryItem.backgroundColor = backgroundColor
            primaryItem.textColor = actionColor
            secondaryItem.backgroundColor = backgroundColor
            secondaryItem.textColor = actionColor
            cancelItem.backgroundColor = backgroundColor
            cancelItem.textColor = isDark
                ? UIColor(coHereSafeSettingHex: 0x999999)
                : UIColor(coHereSafeSettingHex: 0xB3B3B3)
        }

        let actionSheet = NoaPresentView(
            frame: UIScreen.main.bounds,
            titleItem: nil,
            select: [primaryItem, secondaryItem],
            cancleItem: cancelItem,
            doneClick: { index in
                if index == 0 {
                    primaryAction()
                } else if index == 1 {
                    secondaryAction()
                }
            },
            cancleClick: {}
        )
        view.addSubview(actionSheet)
        actionSheet.showPresentView()
    }

    /// 创建现有操作面板使用的文本项。
    /// - Parameters:
    ///   - title: 当前操作标题。
    ///   - isCancel: 是否为取消项；取消项高度和颜色与旧页面不同。
    /// - Returns: 配置完成的 NoaPresentItem。
    private func presentItem(title: String, isCancel: Bool) -> NoaPresentItem {
        NoaPresentItem.creatPresentViewItem(
            withText: title,
            textColor: UIColor(
                coHereSafeSettingHex: isCancel ? 0xB3B3B3 : 0x111111
            ),
            font: .systemFont(ofSize: 17),
            itemHeight: isCancel ? 52 : 56,
            backgroundColor: .white
        )
    }

    /// 接收原手势密码验证结果，保持修改和关闭后的状态迁移。
    /// - Parameters:
    ///   - checkResultType: 原验证页返回的成功、错误或锁定状态。
    ///   - checkType: 当前验证用于普通验证、修改还是关闭。
    func gestureLockCheckResultType(
        _ checkResultType: GestureLockCheckResultType,
        checkType: GestureLockCheckType
    ) {
        guard checkResultType == .right else {
            return
        }
        switch checkType {
        case .close:
            NoaHUDManager.share().showMessage(localized("关闭手势密码"))
            MMKV.default()?.removeValue(forKey: gesturePasswordKey)
            refreshPage()
        case .change:
            presentGestureLockSetup()
        default:
            break
        }
    }

    /// 手势密码设置页发送通知后刷新 MMKV 展示状态。
    @objc private func reloadGesturePassword() {
        refreshPage()
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
