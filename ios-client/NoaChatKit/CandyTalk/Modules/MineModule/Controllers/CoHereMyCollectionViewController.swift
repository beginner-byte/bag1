//
//  CoHereMyCollectionViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import MJExtension
import UIKit

/// “我的收藏”Swift 控制器，保留分页、预览、转发、删除和保存业务。
@objc(CoHereMyCollectionViewController)
final class CoHereMyCollectionViewController: CandyBaseViewController, KNPhotoBrowserDelegate {

    /// 是否从聊天页面进入；为 true 时点击收藏会直接回传消息。
    @objc var isFromChat = false

    /// 上游聊天会话 ID，保留原公开契约。
    @objc var chatSession = ""

    /// 上游聊天类型，保留原公开契约。
    @objc var chatType: CIMChatType = .singleChat

    /// 从聊天页面进入时发送收藏消息的回调。
    @objc var sendCollectionMsgBlock: ((NoaMyCollectionItemModel) -> Void)?

    /// 当前已加载的收藏业务模型。
    private var collectionModels: [NoaMyCollectionModel] = []

    /// 当前分页页码，从 1 开始。
    private var pageNumber = 1

    /// 服务器返回的收藏总数。
    private var totalCount = Int.max

    /// 图片或视频浏览器当前操作的收藏模型。
    private var currentPreviewModel: NoaMyCollectionModel?

    /// 防止列表到底部时重复发起同一分页请求。
    private var isLoading = false

    /// Swift 实现的完整收藏页面。
    private let coHerePageView = CoHereMyCollectionPageView()

    /// 创建页面并请求首批收藏。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        requestCollectionData()
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

    /// 绑定返回、选择、删除和分页动作。
    private func bindPageActions() {
        coHerePageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        coHerePageView.onItemTap = { [weak self] index in self?.handleItemTap(at: index) }
        coHerePageView.onDeleteTap = { [weak self] index in self?.confirmDelete(at: index) }
        coHerePageView.onLoadMore = { [weak self] in self?.loadMore() }
    }

    /// 列表未加载完毕时请求下一页。
    private func loadMore() {
        guard collectionModels.count < totalCount, !isLoading else {
            return
        }
        pageNumber += 1
        requestCollectionData()
    }

    /// 请求当前分页收藏数据并追加到列表。
    private func requestCollectionData() {
        guard !isLoading else {
            return
        }
        isLoading = true
        let parameters: NSMutableDictionary = [
            "pageNumber": pageNumber,
            "pageSize": 10,
            "pageStart": collectionModels.count,
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ]
        NoaHUDManager.share().showActivityMessage("")
        NoaIMSDKManager.sharedTool().userMyCollectionList(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self else {
                    return
                }
                isLoading = false
                NoaHUDManager.share().hideHUD()
                guard let dictionary = data as? NSDictionary else {
                    return
                }
                totalCount = (dictionary["totalCount"] as? NSNumber)?.intValue ?? collectionModels.count
                let items = dictionary["items"] as? [Any] ?? []
                let models: [NoaMyCollectionItemModel] =
                    NoaMyCollectionItemModel.mj_objectArray(withKeyValuesArray: items)
                        as? [NoaMyCollectionItemModel] ?? []
                collectionModels.append(contentsOf: models.map(NoaMyCollectionModel.init(collectionModel:)))
                coHerePageView.configure(models: collectionModels)
            },
            onFailure: { [weak self] code, message, _ in
                self?.isLoading = false
                NoaHUDManager.share().hideHUD()
                NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
            }
        )
    }

    /// 点击收藏后根据来源执行消息回传或内容预览。
    /// - Parameter index: 当前收藏下标。
    private func handleItemTap(at index: Int) {
        guard collectionModels.indices.contains(index) else {
            return
        }
        let model = collectionModels[index]
        if isFromChat {
            sendCollectionMsgBlock?(model.itemModel)
            navigationController?.popViewController(animated: true)
            return
        }
        currentPreviewModel = model
        switch model.itemModel.mtype.rawValue {
        case 1:
            presentBrowser(
                url: model.itemModel.body.name.getImageFull(),
                thumbnailURL: model.itemModel.body.iImg.getImageFull(),
                isVideo: false
            )
        case 2:
            presentBrowser(
                url: model.itemModel.body.name.getImageFull(),
                thumbnailURL: model.itemModel.body.cImg.getImageFull(),
                isVideo: true
            )
        case 5:
            openFile(model)
        default:
            break
        }
    }

    /// 打开现有图片或视频浏览器。
    /// - Parameters:
    ///   - url: 原图或视频完整地址。
    ///   - thumbnailURL: 缩略图或视频封面完整地址。
    ///   - isVideo: 是否为视频。
    private func presentBrowser(url: String, thumbnailURL: String, isVideo: Bool) {
        let item = KNPhotoItems()
        item.isVideo = isVideo
        item.url = url
        if isVideo {
            item.videoPlaceHolderImageUrl = thumbnailURL
        } else {
            item.thumbnailUrl = thumbnailURL
        }
        KNPhotoBrowserConfig.share().isNeedCustomActionBar = false
        let browser = KNPhotoBrowser()
        browser.delegate = self
        browser.itemsArr = [item]
        browser.placeHolderColor = .lightText
        browser.currentIndex = 0
        browser.isSoloAmbient = true
        browser.isNeedPageNumView = false
        browser.isNeedRightTopBtn = true
        browser.isNeedLongPress = false
        browser.isNeedPanGesture = true
        browser.isNeedPrefetch = true
        browser.isNeedAutoPlay = true
        browser.isNeedOnlinePlay = false
        browser.present()
    }

    /// 打开现有收藏文件详情页面。
    /// - Parameter model: 当前文件收藏业务模型。
    private func openFile(_ model: NoaMyCollectionModel) {
        let fileName = model.itemModel.body.name
        let localPath = "\(NSString.getCollcetionMessageFileDiectoryPath())/\(fileName)"
        let controller = NoaChatFileDetailViewController()
        controller.collectionMsgModel = model
        controller.localFilePath = localPath
        controller.isShowRightBtn = false
        controller.isFromCollcet = true
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 浏览器更多按钮点击后展示保存到手机操作。
    /// - Parameters:
    ///   - photoBrowser: 当前浏览器。
    ///   - index: 当前浏览项下标，本页面始终为 0。
    func photoBrowser(
        _ photoBrowser: KNPhotoBrowser,
        rightBtnOperationActionWith index: Int
    ) {
        guard let model = currentPreviewModel else {
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: localized("保存到手机"), style: .default) { [weak self] _ in
            guard let self else {
                return
            }
            if model.itemModel.mtype.rawValue == 1 {
                NoaToolManager.share().saveImageToAlbum(
                    with: model.itemModel.body.name.getImageFull(),
                    cusotm: ""
                )
            } else if model.itemModel.mtype.rawValue == 2 {
                saveVideo(url: model.itemModel.body.name.getImageFull())
            }
        })
        alert.addAction(UIAlertAction(title: localized("取消"), style: .cancel))
        present(alert, animated: true)
    }

    /// 展示删除收藏确认弹窗。
    /// - Parameter index: 待删除收藏下标。
    private func confirmDelete(at index: Int) {
        guard collectionModels.indices.contains(index) else {
            return
        }
        let alert = NoaMessageAlertView(msgAlertType: .nomal, supView: nil)
        alert.lblContent.text = localized("删除该条收藏")
        alert.btnSure.setTitle(localized("确认"), for: .normal)
        alert.btnCancel.setTitle(localized("取消"), for: .normal)
        alert.sureBtnBlock = { [weak self] _ in self?.deleteCollection(at: index) }
        alert.alertShow()
    }

    /// 请求删除指定收藏，成功后刷新 Swift 列表。
    /// - Parameter index: 待删除收藏下标。
    private func deleteCollection(at index: Int) {
        guard collectionModels.indices.contains(index) else {
            return
        }
        let model = collectionModels[index]
        let parameters: NSMutableDictionary = [
            "collectId": model.itemModel.collectId,
            "userUid": NoaUserManager.sharedInstance().userInfo?.userUID ?? ""
        ]
        NoaHUDManager.share().showActivityMessage("")
        NoaIMSDKManager.sharedTool().userCollectionMsgDelete(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self else {
                    return
                }
                NoaHUDManager.share().hideHUD()
                guard (data as? NSNumber)?.boolValue == true else {
                    NoaHUDManager.share().showMessage(localized("删除失败"))
                    return
                }
                NoaHUDManager.share().showMessage(localized("删除成功"))
                collectionModels.remove(at: index)
                totalCount = max(0, totalCount - 1)
                coHerePageView.configure(models: collectionModels)
            },
            onFailure: { _, _, _ in
                NoaHUDManager.share().hideHUD()
            }
        )
    }

    /// 优先保存本地缓存视频；无缓存时下载后保存。
    /// - Parameter url: 视频完整网络地址。
    private func saveVideo(url: String) {
        NoaHUDManager.share().showActivityMessage(localized("正在保存..."))
        let tool = NoaToolManager.share()
        let localPath = tool.videoExists(with: url)
        if !localPath.isEmpty {
            tool.saveVideoToAlbum(with: localPath)
            return
        }
        tool.downloadVideo(with: url) { success, path in
            if success {
                tool.saveVideoToAlbum(with: path)
            }
        }
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}
