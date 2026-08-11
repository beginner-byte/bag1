//
//  CoHereDailySignInViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import UIKit

/// “每日签到”Swift 控制器，保留签到详情、记录、积分和签到请求业务。
@objc(CoHereDailySignInViewController)
final class CoHereDailySignInViewController: CandyBaseViewController {

    /// 当天是否已经签到，来源于签到详情接口。
    private var isSignedIn = false

    /// 当前月已签到日期集合，元素取值 1...31。
    private var signedDays: [NSNumber] = []

    /// 当前月签到记录，传递给签到记录页面。
    private var signInRecords: NSArray = []

    /// 当前累计积分，传递给签到记录页面。
    private var totalLoyalty = "0"

    /// Figma 对应的完整每日签到页面。
    private let coHerePageView = CoHereDailySignInPageView()

    /// 创建页面、绑定业务并加载签到详情与记录。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        refreshCalendar()
        requestSignInfo()
        requestSignRecords()
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

    /// 绑定返回、记录、积分和签到事件。
    private func bindPageActions() {
        coHerePageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        coHerePageView.onRecordTap = { [weak self] in self?.openSignInRecords() }
        coHerePageView.onPointsTap = { [weak self] in self?.openPointsDetail() }
        coHerePageView.onSignInTap = { [weak self] in self?.signIn() }
    }

    /// 请求当前用户签到详情并更新页面统计。
    private func requestSignInfo() {
        let parameters: NSMutableDictionary = [
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ]
        NoaIMSDKManager.sharedTool().imSignIn(
            withInfo: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self, let dictionary = data as? NSDictionary else {
                    return
                }
                isSignedIn = (dictionary["isSignIn"] as? NSNumber)?.intValue == 1
                refreshStatistics(with: dictionary)
                requestSignRecords()
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
            }
        )
    }

    /// 使用签到详情接口字段刷新统计卡片。
    /// - Parameter dictionary: 签到详情接口返回字典。
    private func refreshStatistics(with dictionary: NSDictionary) {
        coHerePageView.coHereConfigure(
            isSignedIn: isSignedIn,
            todayPoints: textValue(dictionary["loyalty"]),
            totalSignDays: textValue(dictionary["signTotalDay"]),
            totalPoints: textValue(dictionary["signTotalLoyalty"]),
            monthSignDays: textValue(dictionary["monthTotalDay"])
        )
    }

    /// 请求当前年月签到记录并更新月历。
    private func requestSignRecords() {
        let calendar = Calendar.current
        let parameters: NSMutableDictionary = [
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? "",
            "year": calendar.component(.year, from: Date()),
            "month": calendar.component(.month, from: Date())
        ]
        NoaIMSDKManager.sharedTool().imSignIn(
            withRecord: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self, let dictionary = data as? NSDictionary else {
                    return
                }
                signInRecords = dictionary["signInRecords"] as? NSArray ?? []
                totalLoyalty = textValue(dictionary["totalLoyalty"])
                signedDays = signedDayNumbers(from: signInRecords)
                refreshCalendar()
            },
            onFailure: { [weak self] code, message, _ in
                self?.refreshCalendar()
                NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
            }
        )
    }

    /// 从签到记录时间戳提取日号。
    /// - Parameter records: 签到记录数组，createTime 使用毫秒时间戳。
    /// - Returns: 当前月已签到日号数组。
    private func signedDayNumbers(from records: NSArray) -> [NSNumber] {
        records.compactMap { value in
            guard let dictionary = value as? NSDictionary else {
                return nil
            }
            let milliseconds = (dictionary["createTime"] as? NSNumber)?.doubleValue
                ?? Double("\(dictionary["createTime"] ?? "")")
                ?? 0
            guard milliseconds > 0 else {
                return nil
            }
            let date = Date(timeIntervalSince1970: milliseconds / 1_000)
            return NSNumber(value: Calendar.current.component(.day, from: date))
        }
    }

    /// 使用当前年月和已签到日号刷新 Swift 月历。
    private func refreshCalendar() {
        let calendar = Calendar.current
        coHerePageView.coHereUpdateCalendar(
            signedDays: signedDays,
            year: calendar.component(.year, from: Date()),
            month: calendar.component(.month, from: Date())
        )
    }

    /// 打开积分明细页面。
    private func openPointsDetail() {
        navigationController?.pushViewController(
            NoaIntegralDetailViewController(),
            animated: true
        )
    }

    /// 打开签到记录页面并传递当前记录和累计积分。
    private func openSignInRecords() {
        let controller = CoHereSignInRecordsViewController()
        controller.signInRecords = signInRecords
        controller.totalLoyalty = totalLoyalty
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 当天未签到时提交签到请求，成功后刷新详情与月历。
    private func signIn() {
        guard !isSignedIn else {
            return
        }
        let parameters: NSMutableDictionary = [
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ]
        NoaIMSDKManager.sharedTool().imSignInRecord(
            withSign: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self else {
                    return
                }
                let today = Calendar.current.component(.day, from: Date())
                if !signedDays.contains(NSNumber(value: today)) {
                    signedDays.append(NSNumber(value: today))
                }
                refreshCalendar()
                requestSignInfo()
                let loyalty = (data as? NSDictionary)?["loyalty"]
                let message = loyalty == nil
                    ? localized("签到成功")
                    : "\(localized("签到成功")),+\(textValue(loyalty))"
                NoaHUDManager.share().showMessage(message)
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
            }
        )
    }

    /// 把接口数字或字符串统一转换成页面字符串。
    /// - Parameter value: 接口字段值，可为空。
    /// - Returns: 非空字符串，空值返回 "0"。
    private func textValue(_ value: Any?) -> String {
        guard let value else {
            return "0"
        }
        return String(describing: value)
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
