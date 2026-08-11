//
//  CoHereRegisterViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/28.
//

import UIKit

/// CoHere 注册控制器，负责承载 Figma 注册页并协调既有注册、验证码和自动登录流程。
@objc(CoHereRegisterViewController)
final class CoHereRegisterViewController: UIViewController {

    /// 手机号注册默认区号，由登录页传入。
    @objc var areaCode = "+86"

    /// 后端允许的注册类型原始值，顺序决定页签顺序。
    @objc var registerTypes: [NSNumber] = []

    /// 登录页当前方式对应的首选注册类型原始值。
    @objc var initialRegisterType = 2

    /// 登录页检测到的未注册账号、手机号或邮箱。
    @objc var prefilledAccount = ""

    /// 既有注册数据处理对象，使用登录页传入配置完成原初始化逻辑，并继续负责校验、请求、加密和注册成功自动登录。
    private lazy var dataHandle: NoaRegisterDataHandle = {
        let supportedTypes = normalizedRegisterTypes()
        let safeInitialType = supportedTypes.contains(initialRegisterType)
            ? initialRegisterType
            : supportedTypes[0]
        return NoaRegisterDataHandle(
            registerWay: registerMenu(for: safeInitialType),
            areaCode: areaCode.isEmpty ? "+86" : areaCode,
            unRegisterAccount: prefilledAccount
        )
    }()

    /// Figma 注册页的 Swift 可视层。
    private let pageView = CoHereRegisterPageView()

    /// 防止验证码请求流程因快速切换页签而使用错误注册类型。
    private var pendingVerificationType: Int?

    /// 紫色 Figma 头部使用白色状态栏图标和时间。
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    /// 初始化注册数据、安装页面并绑定全部既有业务事件。
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataHandle()
        configurePage()
        bindPageActions()
        bindInputProvider()
        bindDataEvents()
        setNeedsStatusBarAppearanceUpdate()
    }

    /// 页面离开时恢复 SDK 验证码渠道，保持旧注册控制器的清理行为。
    /// - Parameter animated: 是否使用页面消失动画。
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataHandle.resetSDKCaptchaChannel()
    }

    /// 将登录页配置写入注册数据层，并为缺失配置提供安全默认值。
    private func configureDataHandle() {
        let supportedTypes = normalizedRegisterTypes()
        let safeInitialType = supportedTypes.contains(initialRegisterType)
            ? initialRegisterType
            : supportedTypes[0]
        initialRegisterType = safeInitialType
        dataHandle.currentLoginTypeMenu = registerMenu(for: safeInitialType)
        dataHandle.changeAreaCode(areaCode.isEmpty ? "+86" : areaCode)
    }

    /// 安装全屏 Swift 注册页面并写入页签、初始账号、区号和版本。
    private func configurePage() {
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let types = normalizedRegisterTypes()
        pageView.configure(
            titles: types.map(registerTitle(for:)),
            types: types,
            initialType: initialRegisterType,
            requiresInviteCode: dataHandle.getInviteCodeSupportState()
        )
        pageView.setAreaCode(dataHandle.getAreaCode())
        pageView.setPrefilledIdentity(prefilledAccount, registerType: initialRegisterType)
        pageView.setVersionText(
            "V\(NoaToolManager.share().getCurretnVersion()) \(NoaToolManager.share().getBuildVersion())"
        )
    }

    /// 绑定注册页面操作到现有数据层、协议路由和导航流程。
    private func bindPageActions() {
        pageView.onRegisterTypeChanged = { [weak self] rawValue in
            guard let self else {
                return
            }
            self.dataHandle.currentLoginTypeMenu = self.registerMenu(for: rawValue)
            if rawValue == 0 {
                self.pageView.setAreaCode(self.dataHandle.getAreaCode())
            }
        }

        pageView.onAreaCodeTap = { [weak self] in
            self?.dataHandle.jumpChangeAreaCodeSubject.sendNext(NSNumber(value: 0))
        }

        pageView.onVerificationCodeTap = { [weak self] in
            self?.requestVerificationCode()
        }

        pageView.onRegisterTap = { [weak self] in
            self?.registerTapped()
        }

        pageView.onLoginTap = { [weak self] in
            self?.dataHandle.popLoginVCSubject.sendNext(NSNumber(value: 1))
        }

        pageView.onUserAgreementTap = {
            NoaToolManager.share().setupServeAgreement()
        }

        pageView.onPrivacyAgreementTap = {
            NoaToolManager.share().setupPrivePolicy()
        }
    }

    /// 向 Objective-C 数据层提供当前 Swift 页面内的注册输入值。
    private func bindInputProvider() {
        dataHandle.getInputTextBlock = { [weak self] registerType in
            guard let self else {
                return [:]
            }
            let rawValue = Int(registerType.rawValue)
            let values = self.pageView.textValues(for: rawValue)
            let identity = values["identity"] ?? ""
            var result: [String: String] = [
                "LoginModuleParamPasswordKey": values["password"] ?? "",
                "LoginModuleParamConfirmPasswordKey": values["confirmPassword"] ?? "",
                "LoginModuleParamVerCodeKey": values["verificationCode"] ?? "",
                "LoginModuleParamInviteCodeKey": values["inviteCode"] ?? ""
            ]

            switch rawValue {
            case 0:
                result["LoginModuleParamPhoneNumberKey"] = identity
            case 1:
                result["LoginModuleParamEmailKey"] = identity
            default:
                result["LoginModuleParamAccountKey"] = identity
            }
            return result
        }
    }

    /// 统一绑定注册业务所需的提示、密钥、用户检查、验证码和最终结果。
    private func bindDataEvents() {
        bindToastPresentation()
        bindNavigationEvents()
        bindEncryptKeyResult()
        bindUserExistResult()
        bindImageCaptchaPresentation()
        bindImageCaptchaResult()
        bindVerificationCodeResult()
        bindInvisibleCaptchaResults()
        bindRegisterResult()
    }

    /// 继续订阅旧注册流程的导航、区号选择和倒计时事件，保证 Swift 页面不绕过既有业务事件。
    private func bindNavigationEvents() {
        _ = dataHandle.jumpChangeAreaCodeSubject.subscribeNext { [weak self] _ in
            self?.openCountryCodePicker()
        }
        _ = dataHandle.popLoginVCSubject.subscribeNext { [weak self] _ in
            self?.returnToLogin()
        }
        _ = dataHandle.startVerCodeCountDownSubject.subscribeNext { [weak self] _ in
            self?.pageView.startVerificationCodeCountdown()
        }
    }

    /// 绑定数据层提示，并确保 HUD 在主线程显示。
    private func bindToastPresentation() {
        _ = dataHandle.showToastSubject.subscribeNext { [weak self] value in
            guard
                let self,
                let message = value as? String
            else {
                return
            }
            DispatchQueue.main.async {
                NoaHUDManager.share().showMessage(message, in: self.view)
            }
        }
    }

    /// 处理加密密钥请求并继续既有注册命令。
    private func bindEncryptKeyResult() {
        _ = dataHandle.getEncryptKeyCommand.executionSignals.switchToLatest().subscribeNext {
            [weak self] value in
            guard let self else {
                return
            }
            guard let response = self.dictionary(from: value) else {
                self.hideLoading()
                return
            }
            guard self.responseSucceeded(response) else {
                self.hideLoading()
                self.presentResponseError(response)
                return
            }
            guard
                let keyData = response["data"] as? String,
                !keyData.isEmpty
            else {
                self.hideLoading()
                return
            }
            let keyGuard = NoaEncryptKeyGuard(key: keyData)
            guard
                let encryptKey = keyGuard.consume(),
                !encryptKey.isEmpty
            else {
                self.hideLoading()
                return
            }
            self.dataHandle.registerAndLoginCommand.execute(encryptKey as NSString)
        }
    }

    /// 处理账号存在性检查，分别延续账号注册和手机/邮箱验证码流程。
    private func bindUserExistResult() {
        _ = dataHandle.checkUserIsExistCommand.executionSignals.switchToLatest().subscribeNext {
            [weak self] value in
            guard let self else {
                return
            }
            guard let response = self.dictionary(from: value) else {
                self.hideLoading()
                return
            }
            guard self.responseSucceeded(response) else {
                self.hideLoading()
                self.presentResponseError(response, uploadToSentry: true)
                return
            }

            let currentType = Int(self.dataHandle.currentLoginTypeMenu.rawValue)
            if let pendingType = self.pendingVerificationType {
                guard pendingType == currentType else {
                    self.hideLoading()
                    self.pendingVerificationType = nil
                    return
                }
            } else if currentType != 2 {
                self.hideLoading()
                return
            }

            let userExists = (response["data"] as? NSNumber)?.boolValue ?? false
            if userExists {
                self.hideLoading()
                self.presentExistingUserMessage()
                self.pendingVerificationType = nil
                return
            }

            if currentType == 2 {
                self.dataHandle.getEncryptKeyCommand.execute(nil)
            } else {
                self.continueVerificationCodeRequest(for: currentType)
            }
        }
    }

    /// 绑定图形验证码弹窗事件，并在确认后继续发送手机验证码。
    private func bindImageCaptchaPresentation() {
        _ = dataHandle.showImgVerCodeSubject.subscribeNext { [weak self] value in
            guard
                let self,
                let payload = self.dictionary(from: value)
            else {
                return
            }
            let imageCode = payload["code"] as? String ?? ""
            let verificationType = (payload["verCodeType"] as? NSNumber)?.intValue ?? 1
            let controller = NoaGetImgVerCodeViewController()
            controller.account = self.dataHandle.getAccountText()
            controller.imgVerCode = imageCode
            controller.verCodeType = verificationType
            controller.configureImgVerCodeSuccessBlock = { [weak self] inputCode in
                guard let self else {
                    return
                }
                let parameters = self.dataHandle.getVerCodeParam(
                    withImgCode: inputCode,
                    ticket: "",
                    randstr: "",
                    captchaVerifyParam: ""
                )
                self.showLoading()
                self.dataHandle.getVerCommand.execute(parameters as NSDictionary)
                self.dataHandle.resetSDKCaptchaChannel()
            }
            controller.cancelInputImgVerCodeBlock = { [weak self] in
                self?.dataHandle.resetSDKCaptchaChannel()
            }
            controller.show()
        }
    }

    /// 处理图形验证码字符请求，成功后交由数据层触发原弹窗事件。
    private func bindImageCaptchaResult() {
        _ = dataHandle.getImgVerCommand.executionSignals.switchToLatest().subscribeNext {
            [weak self] value in
            guard let self else {
                return
            }
            self.hideLoading()
            guard let response = self.dictionary(from: value) else {
                return
            }
            guard self.responseSucceeded(response) else {
                self.presentResponseError(response)
                return
            }
            let code = response["code"] as? String ?? ""
            self.dataHandle.showImgVerCodePopWindow(withCode: code)
        }
    }

    /// 处理手机或邮箱验证码发送结果，并启动页面倒计时。
    private func bindVerificationCodeResult() {
        _ = dataHandle.getVerCommand.executionSignals.switchToLatest().subscribeNext {
            [weak self] value in
            guard let self else {
                return
            }
            self.hideLoading()
            guard let response = self.dictionary(from: value) else {
                return
            }
            guard self.responseSucceeded(response) else {
                self.handleVerificationCodeError(response)
                return
            }
            self.dataHandle.showToastSubject.sendNext(
                self.localized("验证码已发送") as NSString
            )
            self.dataHandle.resetSDKCaptchaChannel()
            self.pendingVerificationType = nil
            self.dataHandle.startVerCodeCountDownSubject.sendNext(nil)
        }
    }

    /// 处理腾讯和阿里无痕验证码，失败时回退到图形验证码。
    private func bindInvisibleCaptchaResults() {
        _ = dataHandle.getTencentCaptchaCommand.executionSignals.switchToLatest().subscribeNext {
            [weak self] value in
            guard let self else {
                return
            }
            guard
                let response = self.dictionary(from: value),
                self.responseSucceeded(response),
                let captchaData = response["captchaData"] as? [String: Any]
            else {
                self.dataHandle.showImgVerCodePopWindow(withCode: "")
                return
            }
            let ticket = captchaData["ticket"] as? String ?? ""
            let randomString = captchaData["randstr"] as? String ?? ""
            let parameters = self.dataHandle.getVerCodeParam(
                withImgCode: "",
                ticket: ticket,
                randstr: randomString,
                captchaVerifyParam: ""
            )
            self.showLoading()
            self.dataHandle.getVerCommand.execute(parameters as NSDictionary)
        }

        _ = dataHandle.getAliCaptchaCommand.executionSignals.switchToLatest().subscribeNext {
            [weak self] value in
            guard let self else {
                return
            }
            guard
                let response = self.dictionary(from: value),
                self.responseSucceeded(response),
                let captchaData = response["captchaData"] as? [String: Any]
            else {
                self.dataHandle.showImgVerCodePopWindow(withCode: "")
                return
            }
            let verifyParameter = captchaData["captchaVerifyParam"] as? String ?? ""
            let parameters = self.dataHandle.getVerCodeParam(
                withImgCode: "",
                ticket: "",
                randstr: "",
                captchaVerifyParam: verifyParameter
            )
            self.showLoading()
            self.dataHandle.getVerCommand.execute(parameters as NSDictionary)
        }
    }

    /// 绑定最终注册命令结果，保留原有成功和失败日志。
    private func bindRegisterResult() {
        _ = dataHandle.registerAndLoginCommand.executionSignals.switchToLatest().subscribeNext { value in
            if (value as? NSNumber)?.boolValue == true {
                NSLog("CoHere registration succeeded")
            } else {
                NSLog("CoHere registration failed")
            }
        }
    }

    /// 打开国家或地区区号选择页面并回填选择结果。
    private func openCountryCodePicker() {
        let controller = NoaCountryCodeViewController()
        controller.selecgCountryCodeBlock = { [weak self] dictionary in
            guard
                let self,
                let prefix = dictionary["prefix"]
            else {
                return
            }
            let newAreaCode = "+\(prefix)"
            self.dataHandle.changeAreaCode(newAreaCode)
            self.pageView.setAreaCode(newAreaCode)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 校验手机号或邮箱后启动既有用户检查及验证码流程。
    private func requestVerificationCode() {
        let currentType = Int(dataHandle.currentLoginTypeMenu.rawValue)
        guard currentType == 0 || currentType == 1 else {
            return
        }
        pendingVerificationType = currentType
        showLoading()
        dataHandle.checkUserIsExistCommand.execute(nil)
    }

    /// 处理注册按钮：先执行原参数校验，再执行协议确认和加密注册。
    private func registerTapped() {
        guard dataHandle.checkParamIsAvaliable() else {
            return
        }
        guard pageView.policyAccepted else {
            showPolicyConfirmation()
            return
        }
        executeRegistration()
    }

    /// 根据当前注册类型启动账号存在性检查或直接获取加密密钥。
    private func executeRegistration() {
        pendingVerificationType = nil
        showLoading()
        if Int(dataHandle.currentLoginTypeMenu.rawValue) == 2 {
            dataHandle.checkUserIsExistCommand.execute(nil)
        } else {
            dataHandle.getEncryptKeyCommand.execute(nil)
        }
    }

    /// 展示未勾选协议时的确认弹窗，同意后继续本次注册。
    private func showPolicyConfirmation() {
        let alert = UIAlertController(
            title: localized("提示"),
            message: localized("请阅读并同意《用户协议》和《隐私协议》"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: localized("取消"), style: .cancel))
        alert.addAction(
            UIAlertAction(title: localized("同意并继续"), style: .default) { [weak self] _ in
                guard let self else {
                    return
                }
                self.pageView.updatePolicyAccepted(true)
                self.executeRegistration()
            }
        )
        present(alert, animated: true)
    }

    /// 账号不存在后按照手机或邮箱注册类型继续验证码流程。
    /// - Parameter rawValue: 注册类型原始值。
    private func continueVerificationCodeRequest(for rawValue: Int) {
        guard pendingVerificationType == rawValue else {
            hideLoading()
            return
        }
        if rawValue == 1 {
            sendVerificationCodeDirectly()
            return
        }

        dataHandle.resetSDKCaptchaChannel()
        switch NoaUrlHostManager.share().appSysSetModel.captchaChannel {
        case 1:
            sendVerificationCodeDirectly()
        case 2:
            dataHandle.getImgVerCommand.execute(nil)
        case 3:
            dataHandle.getTencentCaptchaCommand.execute(nil)
        case 4:
            dataHandle.getAliCaptchaCommand.execute(NSNumber(value: true))
        default:
            hideLoading()
        }
    }

    /// 使用空验证码参数直接发送手机或邮箱验证码。
    private func sendVerificationCodeDirectly() {
        let parameters = dataHandle.getVerCodeParam(
            withImgCode: "",
            ticket: "",
            randstr: "",
            captchaVerifyParam: ""
        )
        dataHandle.getVerCommand.execute(parameters as NSDictionary)
    }

    /// 处理验证码发送错误，并保留阿里重试与图形验证码回退规则。
    /// - Parameter response: `getVerCommand` 返回的响应字典。
    private func handleVerificationCodeError(_ response: [String: Any]) {
        guard let error = response["error"] as? [String: Any] else {
            return
        }
        let code = (error["code"] as? NSNumber)?.intValue ?? 0
        if code == 51_002 {
            dataHandle.getAliCaptchaCommand.execute(NSNumber(value: false))
            return
        }
        if code == 51_006 || code == 450_010 {
            dataHandle.showImgVerCodePopWindow(withCode: "")
        }
        presentError(
            code: code,
            message: error["msg"] as? String ?? "",
            uploadToSentry: true
        )
    }

    /// 展示当前注册类型已经存在的本地化提示。
    private func presentExistingUserMessage() {
        let message: String
        switch Int(dataHandle.currentLoginTypeMenu.rawValue) {
        case 0:
            message = localized("手机号已注册，请登录")
        case 1:
            message = localized("邮箱已注册，请登录")
        default:
            message = localized("账号已存在，请登录")
        }
        dataHandle.showToastSubject.sendNext(message as NSString)
    }

    /// 返回导航栈中的 CoHere 登录页面；找不到时执行普通返回。
    private func returnToLogin() {
        guard let navigationController else {
            dismiss(animated: true)
            return
        }
        if let loginController = navigationController.viewControllers.last(
            where: { $0 is CoHereLoginViewController }
        ) {
            navigationController.popToViewController(loginController, animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }

    /// 将后端注册配置规范为非空且不重复的原始值数组。
    /// - Returns: 仅包含 0、1、2 的注册类型数组。
    private func normalizedRegisterTypes() -> [Int] {
        let configured = registerTypes.map(\.intValue).filter { (0...2).contains($0) }
        let unique = configured.reduce(into: [Int]()) { values, item in
            if !values.contains(item) {
                values.append(item)
            }
        }
        return unique.isEmpty ? [2, 0, 1] : unique
    }

    /// 将注册类型原始值转换为 Objective-C 登录注册枚举。
    /// - Parameter rawValue: 0 手机号、1 邮箱、2 账号。
    /// - Returns: 数据层使用的 `ZLoginAndRegisterTypeMenu`。
    private func registerMenu(for rawValue: Int) -> ZLoginAndRegisterTypeMenu {
        ZLoginAndRegisterTypeMenu(rawValue: UInt(rawValue))
            ?? ZLoginAndRegisterTypeMenu(rawValue: 2)!
    }

    /// 返回注册类型对应的本地化页签标题。
    /// - Parameter rawValue: 注册类型原始值。
    /// - Returns: 账号、手机号或邮箱。
    private func registerTitle(for rawValue: Int) -> String {
        switch rawValue {
        case 0:
            return localized("手机号")
        case 1:
            return localized("邮箱")
        default:
            return localized("账号")
        }
    }

    /// 将不确定类型的 RAC 回调值安全转换为字符串键字典。
    /// - Parameter value: RACCommand 或 RACSubject 回调值。
    /// - Returns: 可处理的响应字典，类型不符时返回 nil。
    private func dictionary(from value: Any?) -> [String: Any]? {
        value as? [String: Any]
    }

    /// 判断统一响应字典是否标记请求成功。
    /// - Parameter response: 包含 `res` 字段的响应。
    /// - Returns: `res` 为 true 时返回 true。
    private func responseSucceeded(_ response: [String: Any]) -> Bool {
        (response["res"] as? NSNumber)?.boolValue ?? false
    }

    /// 从统一响应字典提取并展示错误。
    /// - Parameters:
    ///   - response: 包含 error 字典的响应。
    ///   - uploadToSentry: 是否继续原有 HTTP 错误上报。
    private func presentResponseError(
        _ response: [String: Any],
        uploadToSentry: Bool = false
    ) {
        guard let error = response["error"] as? [String: Any] else {
            return
        }
        presentError(
            code: (error["code"] as? NSNumber)?.intValue ?? 0,
            message: error["msg"] as? String ?? "",
            uploadToSentry: uploadToSentry
        )
    }

    /// 本地化并展示服务端错误，按需继续 Sentry 上报。
    /// - Parameters:
    ///   - code: 服务端错误码。
    ///   - message: 服务端错误信息。
    ///   - uploadToSentry: 是否执行 HTTP 类型的 Sentry 上报。
    private func presentError(code: Int, message: String, uploadToSentry: Bool) {
        let translated = NoaLanguageManager.share().matchTranslateMessage(
            fromCode: code,
            errorMsg: message
        )
        dataHandle.showToastSubject.sendNext(translated as NSString)
        guard
            uploadToSentry,
            let uploadType = ZSentryUploadType(rawValue: 3)
        else {
            return
        }
        NoaToolManager.share().sentryUpload(
            with: translated,
            sentryUploadType: uploadType,
            errorCode: "\(code)"
        )
    }

    /// 使用项目语言管理器获取本地化文本。
    /// - Parameter key: Localizable.strings 中的中文键。
    /// - Returns: 当前语言对应的显示文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }

    /// 在当前注册页面展示加载状态。
    private func showLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            NoaHUDManager.share().showActivityMessage("", in: self.view)
        }
    }

    /// 隐藏当前页面的加载状态。
    private func hideLoading() {
        DispatchQueue.main.async {
            NoaHUDManager.share().hideHUD()
        }
    }
}
