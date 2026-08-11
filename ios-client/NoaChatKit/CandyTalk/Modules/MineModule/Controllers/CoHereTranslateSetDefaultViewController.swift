//
//  CoHereTranslateSetDefaultViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/8/3.
//

import MJExtension
import UIKit

/// “翻译管理”Swift 控制器，保留原默认通道、默认语种及服务器同步逻辑。
@objc(CoHereTranslateSetDefaultViewController)
final class CoHereTranslateSetDefaultViewController: CandyBaseViewController {

    /// 页面两组列表数据；每组依次为标题、通道和语种。
    private var sectionTitles: [[String]] = []

    /// 服务器返回并由用户选择持续更新的翻译默认配置。
    private var defaultModel = NoaTranslateDefaultModel()

    /// 传递给现有通道、语种选择弹窗的会话翻译状态。
    private var sessionModel = LingIMSessionModel()

    /// 按原顺序创建默认数据、列表，并请求服务器配置。
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitleStr = localized("翻译管理")
        navBtnBack.setImage(UIImage(named: "cohere_system_setting_back"), for: .normal)
        setupDefaultData()
        setupTableView()
        requestDefaultData()
    }

    /// 重建固定的接收和发送翻译默认值列表。
    private func setupDefaultData() {
        sectionTitles = [
            [localized("消息翻译默认值"), localized("通道"), localized("语种")],
            [localized("发送翻译默认值"), localized("通道"), localized("语种")]
        ]
    }

    /// 配置原分组列表样式、交互属性和安全区约束。
    private func setupTableView() {
        baseTableViewStyle = .grouped
        baseTableView.delegate = self
        baseTableView.dataSource = self
        baseTableView.bounces = false
        baseTableView.delaysContentTouches = false

        let pageLightColor = UIColor(red: 245 / 255, green: 246 / 255, blue: 249 / 255, alpha: 1)
        let pageDarkColor = UIColor(red: 17 / 255, green: 17 / 255, blue: 17 / 255, alpha: 1)
        view.tkThemebackgroundColors = [pageLightColor, pageDarkColor]
        baseTableView.tkThemebackgroundColors = [pageLightColor, pageDarkColor]

        baseTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(baseTableView)
        NSLayoutConstraint.activate([
            baseTableView.topAnchor.constraint(equalTo: navView.bottomAnchor),
            baseTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            baseTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        baseTableView.register(
            NoaTranslateSettingCell.self,
            forCellReuseIdentifier: NSStringFromClass(NoaTranslateSettingCell.self)
        )
    }

    /// 请求当前用户的翻译默认值，并同步到页面模型和弹窗会话模型。
    private func requestDefaultData() {
        let parameters = NSMutableDictionary()
        if let userUID = NoaUserManager.sharedInstance().userInfo?.userUID,
           !userUID.isEmpty {
            parameters["userUid"] = userUID
        }

        NoaIMSDKManager.sharedTool().userTranslateDefault(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard
                    let self,
                    let data,
                    let model = NoaTranslateDefaultModel.mj_object(withKeyValues: data)
                else {
                    return
                }
                defaultModel = model
                synchronizeSessionModel()
                baseTableView.reloadData()
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
            }
        )
    }

    /// 将服务器配置复制到选择弹窗使用的会话模型。
    private func synchronizeSessionModel() {
        sessionModel.receiveTranslateChannel = defaultModel.receiveChannel
        sessionModel.receiveTranslateChannelName = defaultModel.receiveChannelName
        sessionModel.receiveTranslateLanguage = defaultModel.receiveTargetLang
        sessionModel.receiveTranslateLanguageName = defaultModel.receiveTargetLangName
        sessionModel.sendTranslateChannel = defaultModel.sendChannel
        sessionModel.sendTranslateChannelName = defaultModel.sendChannelName
        sessionModel.sendTranslateLanguage = defaultModel.sendTargetLang
        sessionModel.sendTranslateLanguageName = defaultModel.sendTargetLangName
    }

    /// 根据列表位置打开接收或发送的通道、语种选择弹窗。
    /// - Parameter indexPath: 被点击的翻译设置行。
    private func handleSelection(at indexPath: IndexPath) {
        guard indexPath.row == 1 || indexPath.row == 2 else {
            return
        }

        if indexPath.section == 0 {
            if indexPath.row == 1 {
                showSelection(type: .receiveMsgTranslateTypeChannel)
            } else if hasValue(defaultModel.receiveChannel) {
                showSelection(type: .receiveMsgTranslateTypeLanguage)
            } else {
                NoaHUDManager.share().showMessage(localized("请先选择消息翻译的通道"))
                showSelection(type: .receiveMsgTranslateTypeChannel)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                showSelection(type: .sendMsgTranslateTypeChannel)
            } else if hasValue(defaultModel.sendChannel) {
                showSelection(type: .sendMsgTranslateTypeLanguage)
            } else {
                NoaHUDManager.share().showMessage(localized("请先选择发送翻译的通道"))
                showSelection(type: .sendMsgTranslateTypeChannel)
            }
        }
    }

    /// 使用现有 Objective-C 选择视图展示指定翻译配置类型。
    /// - Parameter type: 接收或发送场景下的通道、语种类型。
    private func showSelection(type: ZMsgTranslateType) {
        let selectionView = NoaTranslateChannelLanguageView(
            translateType: type,
            sessionModel: sessionModel
        )
        selectionView.delegate = self
        selectionView.channelLanguageViewShow()
    }

    /// 应用选择结果，刷新列表，并按原字段集合上传服务器。
    /// - Parameters:
    ///   - model: 选择弹窗返回的会话翻译状态。
    ///   - type: 本次选择对应的翻译配置类型。
    private func applySelection(model: LingIMSessionModel, type: ZMsgTranslateType) {
        sessionModel = model
        switch type {
        case .receiveMsgTranslateTypeChannel:
            defaultModel.receiveChannel = model.receiveTranslateChannel
            defaultModel.receiveChannelName = model.receiveTranslateChannelName
            defaultModel.receiveTargetLang = ""
            defaultModel.receiveTargetLangName = ""
        case .receiveMsgTranslateTypeLanguage:
            defaultModel.receiveTargetLang = model.receiveTranslateLanguage
            defaultModel.receiveTargetLangName = model.receiveTranslateLanguageName
        case .sendMsgTranslateTypeChannel:
            defaultModel.sendChannel = model.sendTranslateChannel
            defaultModel.sendChannelName = model.sendTranslateChannelName
            defaultModel.sendTargetLang = ""
            defaultModel.sendTargetLangName = ""
        case .sendMsgTranslateTypeLanguage:
            defaultModel.sendTargetLang = model.sendTranslateLanguage
            defaultModel.sendTargetLangName = model.sendTranslateLanguageName
        default:
            break
        }
        baseTableView.reloadData()
        requestUploadTranslateSetting()
    }

    /// 上传当前翻译默认配置；成功提示保持原行为，失败继续静默处理。
    private func requestUploadTranslateSetting() {
        let parameters = NSMutableDictionary()
        parameters["sendChannel"] = defaultModel.sendChannel
        parameters["sendChannelName"] = defaultModel.sendChannelName
        parameters["sendTargetLang"] = defaultModel.sendTargetLang
        parameters["sendTargetLangName"] = defaultModel.sendTargetLangName
        parameters["receiveChannel"] = defaultModel.receiveChannel
        parameters["receiveChannelName"] = defaultModel.receiveChannelName
        parameters["receiveTargetLang"] = defaultModel.receiveTargetLang
        parameters["receiveTargetLangName"] = defaultModel.receiveTargetLangName
        parameters["userUid"] = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""

        NoaIMSDKManager.sharedTool().userTranslateDefaultUpload(
            parameters,
            onSuccess: { [weak self] _, _ in
                guard let self else {
                    return
                }
                NoaHUDManager.share().showMessage(localized("设置成功"))
            },
            onFailure: { _, _, _ in }
        )
    }

    /// 判断配置字符串是否包含有效内容。
    /// - Parameter value: 通道或语种配置值。
    /// - Returns: 非空且不为空字符串时返回 true。
    private func hasValue(_ value: String?) -> Bool {
        guard let value else {
            return false
        }
        return !value.isEmpty
    }

    /// 获取当前 App 语言对应的本地化文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言下的显示文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

extension CoHereTranslateSetDefaultViewController: UITableViewDataSource, UITableViewDelegate {

    /// 返回固定的接收、发送两个设置分组。
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }

    /// 返回指定分组的标题、通道和语种行数。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionTitles[section].count
    }

    /// 保持原列表 54pt 缩放行高。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .DWScale(54)
    }

    /// 保持两个设置分组之间的 16pt 缩放间隔。
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .DWScale(16)
    }

    /// 创建与原页面颜色一致的分组间隔视图。
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.tkThemebackgroundColors = [
            UIColor(red: 245 / 255, green: 246 / 255, blue: 249 / 255, alpha: 1),
            UIColor(red: 17 / 255, green: 17 / 255, blue: 17 / 255, alpha: 1)
        ]
        return headerView
    }

    /// 移除 grouped table 默认 footer 高度。
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    /// 复用原 Objective-C Cell，并填充当前通道、语种名称。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = NSStringFromClass(NoaTranslateSettingCell.self)
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath
        ) as? NoaTranslateSettingCell else {
            return UITableViewCell()
        }

        let titles = sectionTitles[indexPath.section]
        cell.leftTitleStr = titles[indexPath.row]
        if indexPath.section == 0, indexPath.row == 1 {
            cell.rightTitleStr = hasValue(defaultModel.receiveChannelName)
                ? defaultModel.receiveChannelName
                : localized("请选择")
        } else if indexPath.section == 0, indexPath.row == 2 {
            cell.rightTitleStr = hasValue(defaultModel.receiveTargetLangName)
                ? defaultModel.receiveTargetLangName
                : localized("请选择")
        } else if indexPath.section == 1, indexPath.row == 1 {
            cell.rightTitleStr = hasValue(defaultModel.sendChannelName)
                ? defaultModel.sendChannelName
                : localized("请选择")
        } else if indexPath.section == 1, indexPath.row == 2 {
            cell.rightTitleStr = hasValue(defaultModel.sendTargetLangName)
                ? defaultModel.sendTargetLangName
                : localized("请选择")
        }
        cell.configCellRound(withCellIndex: indexPath.row, totalIndex: titles.count)
        cell.baseCellIndexPath = indexPath
        cell.baseDelegate = self
        return cell
    }

    /// 保留原列表选中后立即取消高亮的行为。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CoHereTranslateSetDefaultViewController: ZBaseCellDelegate {

    /// 接收原 Cell 按钮回调并打开对应选择弹窗。
    /// - Parameter indexPath: Cell 保存的原列表位置。
    func cellClickAction(_ indexPath: IndexPath) {
        handleSelection(at: indexPath)
    }
}

extension CoHereTranslateSetDefaultViewController: ZTranslateChannelLanguageViewDelegate {

    /// 接收现有选择弹窗结果并同步页面与服务器。
    /// - Parameters:
    ///   - sessionModel: 已更新的会话翻译状态。
    ///   - translateType: 本次完成选择的配置类型。
    func selectActionFinish(
        with sessionModel: LingIMSessionModel,
        translateType: ZMsgTranslateType
    ) {
        applySelection(model: sessionModel, type: translateType)
    }
}
