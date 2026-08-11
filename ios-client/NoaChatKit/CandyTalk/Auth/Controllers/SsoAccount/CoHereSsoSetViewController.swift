//
//  CoHereSsoSetViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/27.
//

import CocoaAsyncSocket
import MMKV
import UIKit

/// Swift 邀请码控制器，负责承载 Figma 页面并协调既有 SSO 竞速、扫码和导航业务。
@objc(CoHereSsoSetViewController)
final class CoHereSsoSetViewController: UIViewController, GCDAsyncUdpSocketDelegate {

    /// 是否作为窗口根控制器展示，竞速成功后用于决定登录页跳转方式。
    @objc var isRoot = false

    /// 是否从竞速错误页进入重新设置流程。
    @objc var isReset = false

    /// 兼容旧接口的悬浮窗标记；当前仓库没有赋值调用方。
    @objc var isPopWindows = false

    /// 非根页面配置成功后的完成回调。
    @objc var configSsoInfoFinish: (() -> Void)?

    /// Swift 实现的完整邀请码页面。
    private let pageView = CoHereSsoPageView()

    /// 首次使用时展示的用户协议弹窗。
    private var agreementView: AppUseTipView?

    /// 用于触发 iOS 本地网络权限提示的 UDP Socket。
    private var udpSocket: GCDAsyncUdpSocket?

    /// 一次竞速过程中是否已经处理错误，避免多个失败通知重复提示。
    private var hasHandledRacingError = false

    /// 创建控制器并使用代码布局。
    /// - Parameters:
    ///   - nibNameOrNil: 未使用的 nib 名称。
    ///   - nibBundleOrNil: 未使用的 nib Bundle。
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    /// 创建控制器的默认初始化入口。
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    /// Storyboard 初始化入口，当前项目未使用。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// 移除通知并释放本地网络权限 Socket。
    deinit {
        NotificationCenter.default.removeObserver(self)
        udpSocket?.close()
    }

    /// 创建 Swift 页面、绑定业务，并保持原控制器的网络初始化流程。
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupPage()
        bindPageActions()
        configureNetworkAuthorityIfNeeded()

        NoaIMSDKManager.sharedTool().toolDisconnectNoReconnect()
        NoaUrlHostManager.share().stopNetworkQualityDetection()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRacingResult(_:)),
            name: Notification.Name("AppSsoRacingAndIpDomainConectResultNotification"),
            object: nil
        )
        showAppUserAgreementIfNeeded()
    }

    /// 页面重新出现时恢复尚未处理完成的用户协议弹窗。
    /// - Parameter animated: 是否带有系统转场动画。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if agreementView?.isHidden == true {
            agreementView?.isHidden = false
        }
    }

    /// 页面离开时暂时隐藏用户协议弹窗，防止覆盖后续控制器。
    /// - Parameter animated: 是否带有系统转场动画。
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if agreementView?.isHidden == false {
            agreementView?.isHidden = true
        }
    }

    /// 将 Figma Swift 页面铺满控制器并写入版本与返回状态。
    private func setupPage() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let tool = NoaToolManager.share()
        pageView.setVersionText("V\(tool.getCurretnVersion()) \(tool.getBuildVersion())")
        let canReturn = (navigationController?.viewControllers.count ?? 0) > 1 || NoaSsoInfoModel.isConfigSSO()
        pageView.setBackButtonVisible(canReturn)
    }

    /// 将 Swift 页面事件绑定到现有原生业务流程。
    private func bindPageActions() {
        pageView.onBackTap = { [weak self] in
            self?.handleBack()
        }
        pageView.onLanguageTap = { [weak self] in
            self?.openLanguageSettings()
        }
        pageView.onNetworkSettingsTap = { [weak self] in
            self?.openNetworkSettings()
        }
        pageView.onHelpTap = { [weak self] in
            self?.openHelp()
        }
        pageView.onScanTap = { [weak self] in
            self?.openScanner()
        }
        pageView.onNetworkDetectionTap = { [weak self] inviteCode in
            self?.openNetworkDetection(inviteCode: inviteCode)
        }
        pageView.onJoinTap = { [weak self] type, value in
            self?.joinServer(type: type, value: value)
        }
    }

    /// 根据导航层级返回上级页面，根页面则恢复现有登录页。
    private func handleBack() {
        if let navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
            return
        }
        if NoaSsoInfoModel.isConfigSSO() {
            NoaToolManager.share().setupLoginUI()
        }
    }

    /// 打开现有网络设置控制器。
    private func openNetworkSettings() {
        navigationController?.pushViewController(NoaNetSetViewController(), animated: true)
    }

    /// 打开现有系统语言控制器，并标记为登录阶段语言切换。
    private func openLanguageSettings() {
        let controller = CoHereLanguageSettingViewController()
        controller.changeType = .login
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 打开 Swift 实现的原生网络设置说明页面。
    private func openHelp() {
        let controller = CoHereSsoHelpViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 打开网络监测页面并携带当前邀请码。
    /// - Parameter inviteCode: 当前邀请码，可为空。
    private func openNetworkDetection(inviteCode: String) {
        let controller = CoHereNetworkDetectionViewController()
        controller.currentSsoNumber = inviteCode
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 打开二维码扫描页并绑定邀请码与服务器导航结果。
    private func openScanner() {
        let controller = NoaQRcodeScanViewController()
        controller.isRacing = true
        controller.qRcodeSacnLicenseBlock = { [weak self] licenseID, ipDomainPort in
            self?.handleScannedLicense(licenseID: licenseID, ipDomainPort: ipDomainPort)
        }
        controller.qRcodeSacnNavBlock = { [weak self] model, appKey in
            self?.handleScannedNavigation(model: model, appKey: appKey)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 处理扫码得到的邀请码或 IP 域名，并立即启动对应竞速。
    /// - Parameters:
    ///   - licenseID: 扫码得到的邀请码。
    ///   - ipDomainPort: 扫码得到的 IP、域名和端口。
    private func handleScannedLicense(licenseID: String, ipDomainPort: String) {
        if !licenseID.isEmpty {
            pageView.updateSsoType(1, text: licenseID)
            showLoading()
            saveCompanyID(licenseID)
            return
        }
        if !ipDomainPort.isEmpty {
            pageView.updateSsoType(2, text: ipDomainPort)
            showLoading()
            saveIPDomain(ipDomainPort)
        }
    }

    /// 处理扫码直接返回服务器导航模型的场景。
    /// - Parameters:
    ///   - model: 扫码解析出的服务器列表。
    ///   - appKey: 需要持久化并回填的邀请码。
    private func handleScannedNavigation(model: IMServerListResponseBody, appKey: String) {
        let infoModel = loadOrCreateSSOInfo()
        infoModel.liceseId = appKey
        infoModel.saveSSOInfo()
        pageView.updateSsoType(1, text: appKey)

        let hostManager = NoaUrlHostManager.share()
        hostManager.isReloadRacing = false
        hostManager.qRcodeSacnNav(model)
    }

    /// 校验页面输入并进入邀请码或 IP 域名竞速。
    /// - Parameters:
    ///   - type: 1 表示邀请码，2 表示 IP 域名。
    ///   - value: Swift 页面规范化后的输入。
    private func joinServer(type: Int, value: String) {
        guard !value.isEmpty else {
            let key = type == 1 ? "邀请码错误" : "域名错误"
            NoaHUDManager.share().showMessage(localized(key), in: view)
            return
        }

        showLoading()
        if type == 1 {
            saveCompanyID(value)
        } else {
            saveIPDomain(value)
        }
    }

    /// 读取已保存的 SSO 信息；首次配置或缓存缺失时创建空模型。
    /// - Returns: 可安全写入并持久化的 SSO 配置模型。
    private func loadOrCreateSSOInfo() -> NoaSsoInfoModel {
        let storedInfo: NoaSsoInfoModel? = NoaSsoInfoModel.getSSOInfo()
        return storedInfo ?? NoaSsoInfoModel()
    }

    /// 在当前页面显示节点连接加载状态；非主线程调用时安全切回主线程。
    private func showLoading() {
        if Thread.isMainThread {
            NoaHUDManager.share().showActivityMessage("", in: view)
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            NoaHUDManager.share().showActivityMessage("", in: self.view)
        }
    }

    /// 保存邀请码并在后台启动原有 SSO 节点竞速。
    /// - Parameter licenseID: 小写、非空的邀请码。
    private func saveCompanyID(_ licenseID: String) {
        hasHandledRacingError = false
        let infoModel = loadOrCreateSSOInfo()
        infoModel.liceseId = licenseID
        infoModel.ipDomainPortStr = ""
        infoModel.saveSSOInfo()

        MMKV.default()?.removeValue(forKey: "connectCache\(licenseID)")
        NoaSsoInfoModel.clearSSOInfo(withLiceseId: licenseID)
        startHostRace()
    }

    /// 保存去除协议前缀的 IP 域名信息并启动原有直连竞速。
    /// - Parameter value: IP、域名及可选端口。
    private func saveIPDomain(_ value: String) {
        hasHandledRacingError = false
        let normalized = value
            .replacingOccurrences(of: "http://", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "https://", with: "", options: .caseInsensitive)
        let infoModel = loadOrCreateSSOInfo()
        infoModel.liceseId = ""
        infoModel.ipDomainPortStr = normalized
        infoModel.saveSSOInfo()
        startHostRace()
    }

    /// 在后台线程启动现有节点竞速管理器。
    private func startHostRace() {
        DispatchQueue.global(qos: .userInitiated).async {
            let manager = NoaUrlHostManager.share()
            manager.isReloadRacing = false
            manager.startHostNodeRace()
        }
    }

    /// 处理邀请码竞速或 IP 域名直连的统一结果通知。
    /// - Parameter notification: 携带 step、code、result 和 errorCode 的通知。
    @objc private func handleRacingResult(_ notification: Notification) {
        let infoModel = loadOrCreateSSOInfo()
        let userInfo = notification.userInfo ?? [:]
        let step = (userInfo["step"] as? NSNumber)?.intValue ?? 0
        let code = (userInfo["code"] as? NSNumber)?.intValue ?? 0
        let succeeded = (userInfo["result"] as? NSNumber)?.boolValue ?? false
        let errorCode = userInfo["errorCode"] as? String ?? ""

        if succeeded {
            hasHandledRacingError = false
            infoModel.lastLiceseId = infoModel.liceseId
            infoModel.lastIPDomainPortStr = infoModel.ipDomainPortStr
            infoModel.saveSSOInfo()
            handleRacingSuccess()
            return
        }

        guard !hasHandledRacingError else {
            return
        }
        hasHandledRacingError = true
        infoModel.liceseId = infoModel.lastLiceseId
        infoModel.ipDomainPortStr = infoModel.lastIPDomainPortStr
        infoModel.saveSSOInfo()
        handleRacingFailure(step: step, code: code, errorCode: errorCode)
    }

    /// 按原 isRoot 与 isReset 语义处理竞速成功后的页面流转。
    private func handleRacingSuccess() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            if self.isReset || self.isRoot {
                NoaToolManager.share().setupLoginUI()
                return
            }
            self.navigationController?.popViewController(animated: true)
            self.configSsoInfoFinish?()
        }
    }

    /// 根据竞速步骤和错误码生成与旧控制器一致的错误信息。
    /// - Parameters:
    ///   - step: 竞速步骤原始值，1 至 5。
    ///   - code: 网络层返回码。
    ///   - errorCode: 可用于定位的完整错误码。
    private func handleRacingFailure(step: Int, code: Int, errorCode: String) {
        let message: String
        switch step {
        case 1:
            let suffix = String(errorCode.suffix(2))
            if suffix == "01" || code == 404 || code == 403 {
                message = localized("获取邀请码配置失败") + errorCode
            } else if code == 100000 {
                message = localized("服务器连接失败 ，请联系管理员") + errorCode
            } else {
                message = localized("服务器连接失败") + errorCode
            }
        case 2, 4:
            message = localized("获取配置失败") + errorCode
        case 3, 5:
            message = localized("IM连接失败") + errorCode
        default:
            return
        }
        showRacingError(message, errorCode: errorCode)
    }

    /// 在主线程展示错误并继续原有 Sentry 上报。
    /// - Parameters:
    ///   - message: 本地化后的完整错误信息。
    ///   - errorCode: 竞速错误码。
    private func showRacingError(_ message: String, errorCode: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            NoaHUDManager.share().showMessage(message, in: self.view)
            if let type = ZSentryUploadType(rawValue: 3) {
                NoaToolManager.share().sentryUpload(
                    with: message,
                    sentryUploadType: type,
                    errorCode: errorCode
                )
            }
        }
    }

    /// 首次使用时触发公网和本地网络权限申请。
    private func configureNetworkAuthorityIfNeeded() {
        guard MMKV.default()?.bool(forKey: "isFirstUseApp") == false else {
            return
        }
        NoaToolManager.share().getDevicePublicNetworkIP { _ in }
        requestLocalNetworkPermission()
        MMKV.default()?.set(true, forKey: "isFirstUseApp")
    }

    /// 在尚未同意协议时展示原有用户协议弹窗。
    private func showAppUserAgreementIfNeeded() {
        guard MMKV.default()?.bool(forKey: "AgreeUserAgreement") == false else {
            return
        }
        let agreementView = AppUseTipView()
        self.agreementView = agreementView
        agreementView.showAppUserAgreement()
    }

    /// 通过 UDP 广播触发系统本地网络权限弹窗。
    private func requestLocalNetworkPermission() {
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
        udpSocket = socket
        do {
            try socket.bind(toPort: 12_345)
            try socket.beginReceiving()
            let data = Data("Hello, local network!".utf8)
            socket.send(data, toHost: "255.255.255.255", port: 12_345, withTimeout: -1, tag: 0)
        } catch {
            NSLog("Local network permission socket error: \(error)")
        }
    }

    /// 记录 UDP 权限探测消息发送成功。
    /// - Parameters:
    ///   - sock: 当前 UDP Socket。
    ///   - tag: 消息标识。
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        NSLog("Local network permission data sent")
    }

    /// 记录 UDP 权限探测消息发送失败。
    /// - Parameters:
    ///   - sock: 当前 UDP Socket。
    ///   - tag: 消息标识。
    ///   - error: 发送失败原因。
    func udpSocket(
        _ sock: GCDAsyncUdpSocket,
        didNotSendDataWithTag tag: Int,
        dueToError error: Error?
    ) {
        NSLog("Local network permission send failed: \(String(describing: error))")
    }

    /// 接收 UDP 权限探测回包；该数据仅用于完成系统权限流程。
    /// - Parameters:
    ///   - sock: 当前 UDP Socket。
    ///   - data: 收到的数据。
    ///   - address: 对端地址。
    ///   - filterContext: Socket 过滤上下文。
    func udpSocket(
        _ sock: GCDAsyncUdpSocket,
        didReceive data: Data,
        fromAddress address: Data,
        withFilterContext filterContext: Any?
    ) {
        NSLog("Local network permission response received")
    }

    /// 获取应用当前语言对应的本地化文本。
    /// - Parameter key: 多语言资源键。
    /// - Returns: 当前应用语言下的显示文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
