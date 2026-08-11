//
//  CoHereAddFriendViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import UIKit

/// “添加好友”Swift 控制器，保留精确搜索、好友校验、申请发送和二维码业务。
@objc(CoHereAddFriendViewController)
final class CoHereAddFriendViewController: CandyBaseViewController {

    /// Figma 页面视觉层。
    private let pageView = CoHereAddFriendPageView()

    /// 接口返回的二维码原始内容，供本页和完整二维码页共用。
    private var qrCodeContent = ""

    /// 初始化 Figma 页面并请求真实二维码。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        pageView.configureAccount(currentAccount, qrImage: nil)
        requestQRCode()
    }

    /// 当前用户账号。
    private var currentAccount: String {
        NoaUserManager.sharedInstance().userInfo?.userName ?? ""
    }

    /// 将页面铺满控制器。
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

    /// 连接搜索、二维码、账号和导航事件。
    private func bindPageActions() {
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onSearchSubmit = { [weak self] text in self?.search(text) }
        pageView.onSearchCleared = { [weak self] in self?.pageView.showDefaultState() }
        pageView.onUserTap = { [weak self] user in self?.openUser(user) }
        pageView.onAddUserTap = { [weak self] user in self?.checkAndAdd(user) }
        pageView.onQRCodeTap = { [weak self] in self?.openFullQRCodePage() }
        pageView.onAccountLongPress = { [weak self] in self?.copyAccount() }
    }

    /// 请求个人二维码内容并使用项目现有二维码生成器展示。
    private func requestQRCode() {
        let parameters = NSMutableDictionary(dictionary: [
            "content": "",
            "type": 1,
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ])
        NoaIMSDKManager.sharedTool().userGetCreatQrcodeContent(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self else { return }
                let model = NoaQRCodeModel.mj_object(withKeyValues: data)
                self.qrCodeContent = model?.content ?? ""
                let image = UIImage.getQRCodeImage(
                    with: self.qrCodeContent,
                    qrCodeColor: .black,
                    inputCorrectionLevel: .M
                )
                self.pageView.configureAccount(self.currentAccount, qrImage: image)
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 使用原接口执行账号、手机号或邮箱精确搜索。
    private func search(_ text: String) {
        guard !text.isEmpty else {
            pageView.showDefaultState()
            return
        }
        guard text != currentAccount else {
            NoaHUDManager.share().showMessage(localized("这是你自己的账号哦~"))
            return
        }
        NoaIMSDKManager.sharedTool().userSearch(
            with: NSMutableDictionary(dictionary: ["userName": text]),
            onSuccess: { [weak self] data, _ in
                guard let self else { return }
                let values = data as? [Any] ?? []
                let users = NoaUserModel.mj_objectArray(
                    withKeyValuesArray: values
                ) as? [NoaUserModel] ?? []
                if users.isEmpty {
                    self.pageView.showNoResult()
                } else {
                    self.pageView.configureSearchResults(users)
                }
            },
            onFailure: { [weak self] code, message, _ in
                self?.pageView.showDefaultState()
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 校验目标是否已为好友，未添加时继续发送好友申请。
    private func checkAndAdd(_ user: NoaUserModel) {
        let parameters = NSMutableDictionary(dictionary: [
            "friendUserUid": user.userUID,
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ])
        NoaIMSDKManager.sharedTool().checkMyFriend(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                if (data as? NSNumber)?.boolValue == true {
                    NoaHUDManager.share().showMessage(
                        self?.localized("该用户已是你的好友") ?? ""
                    )
                } else {
                    self?.sendFriendApplication(parameters)
                }
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 发送好友申请并保持原成功、失败提示。
    private func sendFriendApplication(_ parameters: NSMutableDictionary) {
        NoaIMSDKManager.sharedTool().addContact(
            with: parameters,
            onSuccess: { [weak self] _, _ in
                NoaHUDManager.share().showMessage(self?.localized("已发送") ?? "")
            },
            onFailure: { [weak self] _, message, _ in
                NoaHUDManager.share().showMessage(
                    self?.localized(message ?? "") ?? ""
                )
            }
        )
    }

    /// 打开搜索用户主页。
    private func openUser(_ user: NoaUserModel) {
        let controller = NoaUserHomePageVC()
        controller.userUID = user.userUID
        controller.groupID = ""
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 点击二维码时进入现有完整二维码保存、分享页面。
    private func openFullQRCodePage() {
        let controller = CoHereMyQRCodeViewController()
        controller.qrcodeContent = qrCodeContent
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 长按复制当前账号。
    private func copyAccount() {
        UIPasteboard.general.string = currentAccount
        NoaHUDManager.share().showMessage(localized("复制成功"))
    }

    /// 获取本地化文案。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
