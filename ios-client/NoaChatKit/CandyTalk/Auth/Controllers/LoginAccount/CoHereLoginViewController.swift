//
//  CoHereLoginViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/28.
//

import UIKit

/// CoHere 登录控制器，负责承载登录页面并协调既有登录数据与导航流程。
@objc(CoHereLoginViewController)
final class CoHereLoginViewController: NoaLoginBaseViewController {

    /// 既有登录数据处理对象，继续负责请求、验证、加密和登录成功流程。
    private lazy var dataHandle = NoaLoginAccountDataHandle()

    /// 既有登录业务协调视图，内部承载 CoHere Swift 登录页面。
    private lazy var loginManagerView: NoaLoginAccountManagerView = {
        let managerView = NoaLoginAccountManagerView(
            frame: .zero,
            dataHandle: dataHandle
        )
        managerView.clickInviteCodeBlock = { [weak self] in
            self?.clickSetSsoAccount()
        }
        return managerView
    }()

    /// 紫色 Figma 头部使用白色状态栏图标和时间。
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    /// 加载基类环境后安装全屏登录页面并绑定既有数据事件。
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoginUI()
        bindDataEvents()
        setNeedsStatusBarAppearanceUpdate()
    }

    /// 页面重新显示时结束输入状态，保持原控制器的键盘处理行为。
    /// - Parameter animated: 是否使用页面显示动画。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.endEditing(true)
    }

    /// 使用登录协调视图覆盖旧基类界面，不改变 Swift 登录页面布局。
    private func configureLoginUI() {
        showNetworkDetectionAndSystemLanguageButton(false)
        showSsoAccountSetButton(false)
        topTitleLabel.isHidden = true
        blurView.isHidden = true

        loginManagerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginManagerView)
        NSLayoutConstraint.activate([
            loginManagerView.topAnchor.constraint(equalTo: view.topAnchor),
            loginManagerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginManagerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginManagerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 绑定登录数据层的页面跳转和提示事件，保持原 Objective-C 控制器调用链。
    private func bindDataEvents() {
        bindAreaCodeNavigation()
        bindRegisterNavigation()
        bindSafeCodeNavigation()
        bindToastPresentation()
        bindVerificationCodeNavigation()
        bindForgotPasswordNavigation()
    }

    /// 绑定手机区号选择，并在选择完成后刷新登录页面区号。
    private func bindAreaCodeNavigation() {
        _ = dataHandle.jumpChangeAreaCodeSubject.subscribeNext { [weak self] _ in
            guard let self = self else {
                return
            }

            let countryCodeViewController = NoaCountryCodeViewController()
            countryCodeViewController.selecgCountryCodeBlock = { [weak self] dictionary in
                guard
                    let self = self,
                    let prefix = dictionary["prefix"]
                else {
                    return
                }

                self.dataHandle.changeAreaCode("+\(prefix)")
                self.loginManagerView.refreshShowAreaCode()
            }
            self.navigationController?.pushViewController(countryCodeViewController, animated: true)
        }
    }

    /// 绑定 CoHere 注册入口，并沿用当前区号、注册方式和未使用账号信息。
    private func bindRegisterNavigation() {
        _ = dataHandle.jumpRegisterSubject.subscribeNext { [weak self] value in
            guard let self = self else {
                return
            }

            let registerViewController = CoHereRegisterViewController()
            registerViewController.areaCode = self.dataHandle.getAreaCode()
            // Objective-C 返回 NSMutableArray，注册页仅接收 NSNumber 类型的注册方式枚举值。
            registerViewController.registerTypes =
                self.dataHandle.getRegisterConfigureInfo() as? [NSNumber] ?? []
            registerViewController.initialRegisterType =
                Int(self.dataHandle.currentLoginTypeMenu.rawValue)
            registerViewController.prefilledAccount = value as? String ?? ""
            self.navigationController?.pushViewController(registerViewController, animated: true)
        }
    }

    /// 绑定登录安全码验证入口，并传递当前账号和登录类型。
    private func bindSafeCodeNavigation() {
        _ = dataHandle.jumpSafeCodeAuthSubject.subscribeNext { [weak self] value in
            guard
                let self = self,
                let securityKey = value as? String
            else {
                return
            }

            let safeCodeViewController = NoaSafeCodeAuthViewController()
            safeCodeViewController.scKey = securityKey
            safeCodeViewController.loginInfo = self.dataHandle.getAccountText()
            safeCodeViewController.loginType = self.dataHandle.covertInterfaceParam(
                withLoginTypeMenu: self.dataHandle.currentLoginTypeMenu
            )
            self.navigationController?.pushViewController(safeCodeViewController, animated: true)
        }
    }

    /// 绑定登录数据层提示，并确保 HUD 在主线程显示。
    private func bindToastPresentation() {
        _ = dataHandle.showToastSubject.subscribeNext { [weak self] value in
            guard
                let self = self,
                let message = value as? String
            else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                NoaHUDManager.share().showMessage(message, in: self.view)
            }
        }
    }

    /// 绑定验证码登录入口，并传递当前登录类型、区号和账号。
    private func bindVerificationCodeNavigation() {
        _ = dataHandle.jumpVerCodeLoginSubject.subscribeNext { [weak self] _ in
            guard let self = self else {
                return
            }

            let verificationCodeViewController = NoaVerCodeLoginViewController()
            verificationCodeViewController.currentVerCodeLoginType = self.dataHandle.currentLoginTypeMenu
            verificationCodeViewController.areaCode = self.dataHandle.getAreaCode()
            verificationCodeViewController.loginAccount = self.dataHandle.getAccountText()
            self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
        }
    }

    /// 绑定忘记密码入口，并传递当前登录类型、区号和账号。
    private func bindForgotPasswordNavigation() {
        _ = dataHandle.jumpForgetPasswordSubject.subscribeNext { [weak self] _ in
            guard let self = self else {
                return
            }

            let forgetPasswordViewController = NoaForgetPasswordViewController()
            forgetPasswordViewController.currentResetPasswordType = self.dataHandle.currentLoginTypeMenu
            forgetPasswordViewController.areaCode = self.dataHandle.getAreaCode()
            forgetPasswordViewController.resetAccount = self.dataHandle.getAccountText()
            self.navigationController?.pushViewController(forgetPasswordViewController, animated: true)
        }
    }

    /// 打开邀请码设置流程，复用现有工具层根控制器切换逻辑。
    override func clickSetSsoAccount() {
        NoaToolManager.share().setupSsoSetVcUI()
    }
}
