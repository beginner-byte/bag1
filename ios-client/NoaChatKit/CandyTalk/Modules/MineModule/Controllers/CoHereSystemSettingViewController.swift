//
//  CoHereSystemSettingViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import MMKV
import SDWebImage
import UIKit

/// “系统设置”Swift 控制器，保留消息提醒、缓存、注销和删除账号业务。
@objc(CoHereSystemSettingViewController)
final class CoHereSystemSettingViewController: CandyBaseViewController {

    /// 新消息通知开关，值来自用户消息提醒接口。
    private var isNewMessageEnabled = false

    /// 声音提醒开关，值来自用户消息提醒接口。
    private var isSoundEnabled = false

    /// 震动提醒开关，值来自用户消息提醒接口。
    private var isVibrationEnabled = false

    /// Figma 对应的完整系统设置页面。
    private let coHerePageView = CoHereSystemSettingPageView()

    /// 创建页面、绑定操作并请求当前设置。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        refreshPage()
        requestSettings()
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

    /// 绑定所有设置项交互。
    private func bindPageActions() {
        coHerePageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        coHerePageView.onNewMessageChanged = { [weak self] isOn in
            self?.updateToggle(index: 0, isOn: isOn)
        }
        coHerePageView.onSoundChanged = { [weak self] isOn in
            self?.updateToggle(index: 1, isOn: isOn)
        }
        coHerePageView.onVibrationChanged = { [weak self] isOn in
            self?.updateToggle(index: 2, isOn: isOn)
        }
        coHerePageView.onClearCacheTap = { [weak self] in self?.confirmClearCache() }
        coHerePageView.onDeleteAccountTap = { [weak self] in self?.confirmDeleteAccount() }
        coHerePageView.onLogoutTap = { [weak self] in self?.confirmLogout() }
    }

    /// 使用当前开关状态和实时缓存大小刷新页面。
    private func refreshPage() {
        coHerePageView.coHereConfigure(
            newMessageEnabled: isNewMessageEnabled,
            soundEnabled: isSoundEnabled,
            vibrationEnabled: isVibrationEnabled,
            cacheSize: cacheSizeText()
        )
    }

    /// 读取当前用户的服务器消息提醒设置。
    private func requestSettings() {
        let userUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        let parameters: NSMutableDictionary = ["userUid": userUID]
        NoaIMSDKManager.sharedTool().userGetMessageRemind(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self, let dictionary = data as? NSDictionary else {
                    return
                }
                isNewMessageEnabled = (dictionary["isNewMsgNotify"] as? NSNumber)?.intValue == 1
                isVibrationEnabled = (dictionary["isShakeNotice"] as? NSNumber)?.intValue == 1
                isSoundEnabled = (dictionary["isVoiceNotice"] as? NSNumber)?.intValue == 1
                refreshPage()
                updateSDKReminderState()
            },
            onFailure: { _, _, _ in }
        )
    }

    /// 更新指定提醒开关并提交服务器。
    /// - Parameters:
    ///   - index: 0 为新消息，1 为声音，2 为震动。
    ///   - isOn: 用户选择的新开关值。
    private func updateToggle(index: Int, isOn: Bool) {
        switch index {
        case 0:
            isNewMessageEnabled = isOn
        case 1:
            isSoundEnabled = isOn
        case 2:
            isVibrationEnabled = isOn
        default:
            return
        }
        requestSetSettings()
    }

    /// 向服务器提交三个提醒开关的完整状态。
    private func requestSetSettings() {
        let userUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        let parameters: NSMutableDictionary = [
            "userUid": userUID,
            "isNewMsgNotify": isNewMessageEnabled ? 1 : 0,
            "isShakeNotice": isVibrationEnabled ? 1 : 0,
            "isVoiceNotice": isSoundEnabled ? 1 : 0
        ]
        NoaIMSDKManager.sharedTool().userMessageRemindSet(
            with: parameters,
            onSuccess: { [weak self] _, _ in
                self?.refreshPage()
                self?.updateSDKReminderState()
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
            }
        )
    }

    /// 把服务器设置同步到 SDK 收消息提醒开关。
    private func updateSDKReminderState() {
        let sdk = NoaIMSDKManager.sharedTool()
        sdk.toolMessageReceiveRemindOpen(isNewMessageEnabled)
        sdk.toolMessageReceiveRemindVoiceOpen(isSoundEnabled)
        sdk.toolMessageReceiveRemindVibrationOpen(isVibrationEnabled)
    }

    /// 展示清理缓存确认弹窗。
    private func confirmClearCache() {
        let alert = NoaMessageAlertView(msgAlertType: .title, supView: nil)
        alert.lblTitle.text = localized("清理缓存")
        alert.lblContent.text = localized("只清理本地图片视频等缓存，不清理文本信息")
        alert.btnSure.setTitle(localized("立即清理"), for: .normal)
        alert.btnCancel.setTitle(localized("取消"), for: .normal)
        alert.sureBtnBlock = { [weak self] _ in self?.clearLocalCache() }
        alert.alertShow()
    }

    /// 展示退出登录确认弹窗。
    private func confirmLogout() {
        let alert = NoaMessageAlertView(msgAlertType: .title, supView: nil)
        alert.lblTitle.text = localized("退出登录")
        alert.lblContent.text = localized("确定要退出当前账户?")
        alert.btnSure.setTitle(localized("确认"), for: .normal)
        alert.btnCancel.setTitle(localized("取消"), for: .normal)
        alert.sureBtnBlock = { [weak self] _ in self?.logout() }
        alert.alertShow()
    }

    /// 展示删除账号说明，确认后进入现有删除账号流程。
    private func confirmDeleteAccount() {
        let alert = NoaMessageAlertView(msgAlertType: .title, supView: view)
        alert.lblTitle.text = localized("删除账号")
        alert.lblContent.text = localized("删除账号详细说明")
        alert.lblContent.numberOfLines = 0
        alert.btnSure.setTitle(localized("确认"), for: .normal)
        alert.btnCancel.setTitle(localized("取消"), for: .normal)
        alert.sureBtnBlock = { [weak self] _ in
            self?.navigationController?.pushViewController(
                NoaAccountRemoveViewController(),
                animated: true
            )
        }
        alert.alertShow()
    }

    /// 调用原退出接口，并在延迟后切换回登录页面。
    private func logout() {
        let user = NoaUserModel.getUserInfo() as? NoaUserModel
        let parameters: NSMutableDictionary = [
            "userUid": user?.userUID ?? "",
            "tokenLogin": user?.token ?? ""
        ]
        NoaIMSDKManager.sharedTool().authUserLogout(
            with: parameters,
            onSuccess: nil,
            onFailure: nil
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NoaHUDManager.share().showMessage(self.localized("退出账号成功"))
            NoaToolManager.share().setupLoginUI()
        }
    }

    /// 计算 OpenIM 临时文件和 SDWebImage 磁盘缓存总大小。
    /// - Returns: 带 B、KB、MB 或 GB 单位的缓存大小。
    private func cacheSizeText() -> String {
        let fileManager = FileManager.default
        let directory = NSTemporaryDirectory().appending("OpenIM/")
        var totalSize: UInt64 = 0
        for child in (try? fileManager.contentsOfDirectory(atPath: directory)) ?? [] {
            let path = directory.appending(child)
            var isDirectory = ObjCBool(false)
            guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory),
                  !isDirectory.boolValue,
                  let attributes = try? fileManager.attributesOfItem(atPath: path),
                  let size = attributes[.size] as? NSNumber else {
                continue
            }
            totalSize += size.uint64Value
        }
        totalSize += UInt64(SDImageCache.shared.totalDiskSize())
        switch totalSize {
        case 0..<1_024:
            return "\(totalSize)B"
        case 1_024..<(1_024 * 1_024):
            return String(format: "%.1fKB", Double(totalSize) / 1_024)
        case (1_024 * 1_024)..<(1_024 * 1_024 * 1_024):
            return String(format: "%.1fMB", Double(totalSize) / (1_024 * 1_024))
        default:
            return String(format: "%.1fGB", Double(totalSize) / (1_024 * 1_024 * 1_024))
        }
    }

    /// 删除 OpenIM 临时文件和 SDWebImage 磁盘缓存，并刷新缓存大小。
    private func clearLocalCache() {
        NoaHUDManager.share().showMessage(localized("正在清理缓存..."))
        let fileManager = FileManager.default
        let directory = NSTemporaryDirectory().appending("OpenIM/")
        for child in (try? fileManager.contentsOfDirectory(atPath: directory)) ?? [] {
            try? fileManager.removeItem(atPath: directory.appending(child))
        }
        let ssoInfo = NoaSsoInfoModel.getSSOInfo()
        MMKV.default()?.removeValue(forKey: "connectCache\(ssoInfo.liceseId)")
        NoaSsoInfoModel.clearSSOInfo(withLiceseId: ssoInfo.liceseId)
        SDImageCache.shared.clearDisk { [weak self] in
            guard let self else {
                return
            }
            NoaHUDManager.share().showMessage(localized("清理完成"))
            refreshPage()
        }
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
