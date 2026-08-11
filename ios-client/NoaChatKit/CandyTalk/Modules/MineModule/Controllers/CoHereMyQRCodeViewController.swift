//
//  CoHereMyQRCodeViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import UIKit

/// “我的二维码”Swift 控制器，承载 CoHere 视觉层并保留保存、分享业务。
@objc(CoHereMyQRCodeViewController)
final class CoHereMyQRCodeViewController: CandyBaseViewController {

    /// 上游二维码接口返回的原始内容；为空时生成空内容二维码。
    @objc var qrcodeContent = ""

    /// Figma 对应的完整二维码页面。
    private let coHerePageView = CoHereMyQRCodePageView()

    /// 当前保存和分享时需要截图的二维码卡片区域。
    private var coHereShareContentView: UIView {
        coHerePageView.coHereShareContentView
    }

    /// 创建页面、生成二维码并绑定保存和分享事件。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        configurePage()
        bindPageActions()
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

    /// 使用当前用户资料和二维码内容刷新页面。
    private func configurePage() {
        let userInfo = NoaUserManager.sharedInstance().userInfo
        let qrCodeImage = UIImage.getQRCodeImage(
            with: qrcodeContent,
            qrCodeColor: .black,
            inputCorrectionLevel: .M
        )
        coHerePageView.coHereConfigure(
            avatarURL: userInfo?.avatar.getImageFullUrl(),
            nickname: userInfo?.nickname ?? "",
            account: userInfo?.userName ?? "",
            qrCodeImage: qrCodeImage ?? UIImage()
        )
    }

    /// 将返回、保存、分享事件连接到原有业务行为。
    private func bindPageActions() {
        coHerePageView.onBackTap = { [weak self] in
            self?.navBtnBackClicked()
        }
        coHerePageView.onSaveTap = { [weak self] in
            self?.saveQRCodeToAlbum()
        }
        coHerePageView.onShareTap = { [weak self] in
            self?.shareQRCode()
        }
    }

    /// 把二维码卡片渲染为图片。
    /// - Returns: 当前二维码卡片截图；区域尚未布局时返回 nil。
    private func renderedQRCodeCard() -> UIImage? {
        view.layoutIfNeeded()
        guard !coHereShareContentView.bounds.isEmpty else {
            return nil
        }
        let renderer = UIGraphicsImageRenderer(bounds: coHereShareContentView.bounds)
        return renderer.image { context in
            coHereShareContentView.layer.render(in: context.cgContext)
        }
    }

    /// 保存二维码卡片到系统相册，并继续使用系统保存回调展示结果。
    private func saveQRCodeToAlbum() {
        guard let image = renderedQRCodeCard() else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(imageSavedToPhotosAlbum(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }

    /// 将二维码卡片交给现有会话多选页面发送。
    private func shareQRCode() {
        guard let image = renderedQRCodeCard() else {
            return
        }
        let controller = CoHereChatMultiSelectViewController()
        controller.multiSelectType = .shareQRImg
        controller.fromSessionId = ""
        controller.qrCodeImg = image
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 处理系统相册写入结果并展示原有提示。
    /// - Parameters:
    ///   - image: 已提交到系统相册的二维码图片。
    ///   - error: 系统相册保存错误；为空表示成功。
    ///   - contextInfo: 系统回调上下文，本页面不使用。
    @objc private func imageSavedToPhotosAlbum(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeMutableRawPointer?
    ) {
        let message = error?.localizedDescription ?? localized("已保存至相册")
        NoaHUDManager.share().showMessage(message)
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
