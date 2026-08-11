//
//  CoHerePrivacySettingViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import MJExtension
import UIKit

/// “隐私设置”Swift 控制器，保留离线时长设置的原有查询和切换业务。
@objc(CoHerePrivacySettingViewController)
final class CoHerePrivacySettingViewController: CandyBaseViewController {

    /// 服务器确认的离线时长展示状态；默认关闭，用户信息返回后刷新。
    private var isOfflineDurationVisible = false

    /// Figma 对应的完整隐私设置页面。
    private let coHerePageView = CoHerePrivacySettingPageView()

    /// 创建页面、绑定返回与设置项事件，并请求当前用户隐私状态。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        refreshPage()
        requestUserInfo()
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

    /// 绑定返回按钮和离线时长整行点击事件。
    private func bindPageActions() {
        coHerePageView.onBackTap = { [weak self] in
            self?.navBtnBackClicked()
        }
        coHerePageView.onOfflineDurationTap = { [weak self] in
            self?.setOfflineDurationStatus()
        }
    }

    /// 使用服务器最后确认的状态刷新页面开关，不主动触发切换请求。
    private func refreshPage() {
        coHerePageView.configure(
            isOfflineDurationVisible: isOfflineDurationVisible
        )
    }

    /// 当前登录用户 ID；用户信息缺失时沿用旧请求参数的空值语义。
    private var currentUserUID: String {
        NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
    }

    /// 请求当前用户信息，并读取原模型中的离线时长展示状态。
    private func requestUserInfo() {
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
                isOfflineDurationVisible = userModel.showOfflineStatus == 1
                refreshPage()
            },
            onFailure: { _, _, _ in
                // 与旧页面一致：首次用户信息请求失败只记录调试信息，不弹出提示。
                NSLog("获取用户信息失败")
            }
        )
    }

    /// 调用原接口切换离线时长展示状态，并以服务器返回值刷新开关。
    private func setOfflineDurationStatus() {
        let parameters = NSMutableDictionary()
        if !currentUserUID.isEmpty {
            parameters["userUid"] = currentUserUID
        }

        NoaIMSDKManager.sharedTool().userSetShowOffLineStatus(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self else {
                    return
                }
                let result = (data as? NSNumber)?.intValue
                    ?? (data as? NSString)?.integerValue
                    ?? 0
                isOfflineDurationVisible = result == 1
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
}
