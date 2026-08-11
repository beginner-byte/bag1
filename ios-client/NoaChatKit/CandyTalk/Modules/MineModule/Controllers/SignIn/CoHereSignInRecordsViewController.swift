//
//  CoHereSignInRecordsViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import UIKit

/// “签到记录”Swift 控制器，保留原月份选择与记录查询业务。
@objc(CoHereSignInRecordsViewController)
final class CoHereSignInRecordsViewController: CandyBaseViewController {

    /// 上游每日签到页传入的初始记录。
    @objc var signInRecords: NSArray = []

    /// 上游每日签到页传入的累计积分。
    @objc var totalLoyalty = "0"

    /// 当前查询年份。
    private var selectedYear = Calendar.current.component(.year, from: Date())

    /// 当前查询月份，取值 1...12。
    private var selectedMonth = Calendar.current.component(.month, from: Date())

    /// Figma 对应的完整签到记录页面。
    private let coHerePageView = CoHereSignInRecordsPageView()

    /// 创建页面并展示上游传入的初始记录。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        refreshPage()
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

    /// 绑定返回和月份选择事件。
    private func bindPageActions() {
        coHerePageView.onBackTap = { [weak self] in
            self?.navBtnBackClicked()
        }
        coHerePageView.onMonthTap = { [weak self] in
            self?.showDatePicker()
        }
    }

    /// 使用当前记录、累计积分和年月刷新页面。
    private func refreshPage() {
        let normalizedRecords = signInRecords.compactMap { $0 as? [String: Any] }
        coHerePageView.coHereConfigure(
            records: normalizedRecords,
            totalPoints: totalLoyalty,
            year: selectedYear,
            month: selectedMonth
        )
    }

    /// 展示现有年月选择器，并在选择后查询对应月份记录。
    private func showDatePicker() {
        let picker = NoaFDatePickerView(
            datePackerWithSUperView: view
        ) { [weak self] _, year, month in
            guard let self else {
                return
            }
            let resolvedYear = year ?? String(selectedYear)
            let resolvedMonth = month ?? String(selectedMonth)
            selectedYear = Int(resolvedYear) ?? selectedYear
            selectedMonth = Int(resolvedMonth) ?? selectedMonth
            refreshPage()
            requestRecords(year: resolvedYear, month: resolvedMonth)
        }
        picker?.show()
    }

    /// 查询指定年月的签到记录并刷新页面。
    /// - Parameters:
    ///   - year: 四位年份字符串。
    ///   - month: 月份字符串，取值 1...12。
    private func requestRecords(year: String, month: String) {
        let userUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        let parameters: NSMutableDictionary = [
            "userUid": userUID,
            "year": year,
            "month": month
        ]
        NoaIMSDKManager.sharedTool().imSignIn(
            withRecord: parameters,
            onSuccess: { [weak self] data, _ in
                guard
                    let self,
                    let dictionary = data as? NSDictionary
                else {
                    return
                }
                signInRecords = dictionary["signInRecords"] as? NSArray ?? []
                totalLoyalty = String(describing: dictionary["totalLoyalty"] ?? "0")
                refreshPage()
            },
            onFailure: { _, _, _ in }
        )
    }
}
