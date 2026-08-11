//
//  CoHereChatMultiSelectPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/31.
//

import UIKit

/// “选择聊天”页面视觉层，复用创建群聊的同源 Figma 多选结构。
final class CoHereChatMultiSelectPageView: CoHereInviteFriendPageView {

    /// 创建页面并设置“选择聊天”标题。
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTitle(NoaLanguageManager.share().matchLocalLanguage("选择聊天"))
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTitle(NoaLanguageManager.share().matchLocalLanguage("选择聊天"))
    }
}
