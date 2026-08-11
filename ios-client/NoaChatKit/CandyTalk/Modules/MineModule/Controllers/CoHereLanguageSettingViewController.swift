//
//  CoHereLanguageSettingViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import MMKV
import UIKit

/// 设置语言后的页面重建范围。
@objc enum CoHereLanguageChangeUIType: Int {
    /// 登录阶段切换语言后重建邀请码页面。
    case login = 1
    /// 登录后切换语言时重建主 Tab 页面。
    case tabbar = 2
}

/// “设置语言”Swift 控制器，负责选择、持久化语言并触发现有页面重建逻辑。
@objc(CoHereLanguageSettingViewController)
final class CoHereLanguageSettingViewController: CandyBaseViewController {

    /// 语言保存后需要重建的页面范围，默认保持登录后 Tab 行为。
    @objc var changeType: CoHereLanguageChangeUIType = .tabbar

    /// 当前待保存的语言模型。
    private var selectedLanguage: NoaLanguageInfo

    /// 当前支持的语言列表，来源于语言管理器。
    private var languages: [NoaLanguageInfo]

    /// Figma 对应的完整语言设置页面。
    private let coHerePageView = CoHereLanguageSettingPageView()

    /// 从语言管理器读取当前选择和语言列表。
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let manager = NoaLanguageManager.share()
        selectedLanguage = manager.currentLanguage
        languages = manager.languageList
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    /// 默认代码初始化入口。
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    /// Storyboard 初始化入口，使用语言管理器当前状态恢复页面。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        let manager = NoaLanguageManager.share()
        selectedLanguage = manager.currentLanguage
        languages = manager.languageList
        super.init(coder: coder)
    }

    /// 创建页面并绑定语言选择和保存动作。
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

    /// 绑定返回、语言选择和完成事件。
    private func bindPageActions() {
        coHerePageView.onBackTap = { [weak self] in
            self?.navBtnBackClicked()
        }
        coHerePageView.onLanguageSelected = { [weak self] index in
            self?.selectLanguage(at: index)
        }
        coHerePageView.onDoneTap = { [weak self] in
            self?.saveLanguage()
        }
    }

    /// 选择指定语言并刷新选中标记，不立即持久化。
    /// - Parameter index: 语言列表下标。
    private func selectLanguage(at index: Int) {
        guard languages.indices.contains(index) else {
            return
        }
        selectedLanguage = languages[index]
        refreshPage()
    }

    /// 使用当前语言列表和待保存语言刷新页面。
    private func refreshPage() {
        let titles = languages.map { localized($0.languageName_zn) }
        let selectedIndex = languages.firstIndex {
            $0.languageName_zn == selectedLanguage.languageName_zn
        } ?? 0
        coHerePageView.coHereConfigure(titles: titles, selectedIndex: selectedIndex)
    }

    /// 持久化语言、同步文件助手文案并重建对应根页面。
    private func saveLanguage() {
        MMKV.default()?.set(
            selectedLanguage.languageName_zn,
            forKey: "Z_LANGUAGE_SELECTES_TYPE_1.0.11"
        )
        updateFileHelperLanguage()
        if changeType == .login {
            NoaToolManager.share().setupSsoSetVcUI()
        } else {
            // 已登录状态切换语言后，重建完整的 Worker Flutter 根页面。
            NoaToolManager.share().setupWorkerUI()
        }
    }

    /// 同步会话列表与通讯录内文件助手的本地化名称。
    private func updateFileHelperLanguage() {
        NoaToolManager.share().sessionFileHelperLanguageUpdate()
        NoaToolManager.share().connectFileHelperLanguageUpdate()
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
