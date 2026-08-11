//
//  CoHereComplainViewController.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import Photos
import UIKit

/// “投诉与反馈”Swift 控制器，保留原系统投诉、企业投诉、图片上传和提交参数。
@objc(CoHereComplainViewController)
final class CoHereComplainViewController: CandyBaseViewController {

    /// 被投诉对象 ID；为空表示从“我的”进入普通反馈。
    @objc var complainID: String?

    /// 被投诉对象类型，继续支持单聊好友和群聊群组。
    @objc var complainType: CIMChatType = .singleChat

    /// Figma 对应的 Swift 表单页面。
    private let pageView = CoHereComplainPageView()

    /// 已选择的相册图片资源，最大数量沿用原业务的 9 张。
    private var selectedAssets: [PHAsset] = []

    /// 当前图片缩略图，与 selectedAssets 保持相同顺序。
    private var selectedThumbnails: [UIImage] = []

    /// 当前投诉接口类型，默认沿用原页面的系统投诉。
    private var complaintMode: ComplaintMode = .system

    /// 当前投诉原因，默认沿用原参数分类 1。
    private var selectedReason = ComplaintReason.defaultReason

    /// 当前投诉内容，提交前会去除首尾空白。
    private var complaintContent = ""

    /// 当前联系邮箱，提交按钮继续使用原邮箱正则校验。
    private var email = ""

    /// 防止上传或提交期间重复点击。
    private var isSubmitting = false

    /// 创建页面并绑定全部交互回调。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindPageActions()
        refreshPage()
    }

    /// 页面释放时清理共享图片选择器状态，保持原控制器行为。
    deinit {
        NoaImagePickerManager.shared().zSelectedAssets.removeAllObjects()
    }

    /// 将 Swift 页面铺满控制器视图。
    private func setupPage() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 把页面事件路由到控制器，避免视图层持有业务请求。
    private func bindPageActions() {
        pageView.onBack = { [weak self] in
            self?.handleBack()
        }
        pageView.onModeTap = { [weak self] in
            self?.presentModeSelection()
        }
        pageView.onReasonTap = { [weak self] in
            self?.presentReasonSelection()
        }
        pageView.onContentChanged = { [weak self] content in
            self?.complaintContent = content
        }
        pageView.onEmailChanged = { [weak self] email in
            self?.email = email
            self?.refreshSubmitState()
        }
        pageView.onAddImage = { [weak self] in
            self?.requestPhotoAccessAndOpenPicker()
        }
        pageView.onDeleteImage = { [weak self] index in
            self?.deleteImage(at: index)
        }
        pageView.onSubmit = { [weak self] in
            self?.submitComplaint()
        }
    }

    /// 使用当前模式、原因、图片和输入状态刷新页面。
    private func refreshPage() {
        pageView.configure(
            modeTitle: complaintMode.title,
            reasonTitle: selectedReason.title,
            domainText: currentCompanyDisplayText(),
            showsDomain: complaintMode == .company,
            thumbnails: selectedThumbnails,
            submitEnabled: canSubmit,
            isSubmitting: isSubmitting
        )
    }

    /// 仅更新提交按钮状态，避免输入邮箱时重载图片列表。
    private func refreshSubmitState() {
        pageView.updateSubmitState(enabled: canSubmit, isSubmitting: isSubmitting)
    }

    /// 沿用原规则：至少一张图片且邮箱格式正确时才允许提交。
    private var canSubmit: Bool {
        !selectedAssets.isEmpty && isValidEmail(email) && !isSubmitting
    }

    /// 返回上一层导航；无导航栈时关闭当前呈现页面。
    private func handleBack() {
        if let navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    /// 展示系统投诉或邀请码/IP域名投诉选择，替代旧页面顶部双 Tab。
    private func presentModeSelection() {
        let alert = UIAlertController(
            title: complaintLocalized("选择投诉分类"),
            message: nil,
            preferredStyle: .actionSheet
        )
        ComplaintMode.allCases.forEach { mode in
            alert.addAction(UIAlertAction(title: mode.title, style: .default) { [weak self] _ in
                self?.complaintMode = mode
                self?.refreshPage()
            })
        }
        alert.addAction(UIAlertAction(title: complaintLocalized("取消"), style: .cancel))
        configurePopover(for: alert)
        present(alert, animated: true)
    }

    /// 展示原页面的八种投诉原因，保持 ufbContentGroup 参数含义不变。
    private func presentReasonSelection() {
        let alert = UIAlertController(
            title: complaintLocalized("投诉原因"),
            message: nil,
            preferredStyle: .actionSheet
        )
        ComplaintReason.allReasons.forEach { reason in
            alert.addAction(UIAlertAction(title: reason.title, style: .default) { [weak self] _ in
                self?.selectedReason = reason
                self?.refreshPage()
            })
        }
        alert.addAction(UIAlertAction(title: complaintLocalized("取消"), style: .cancel))
        configurePopover(for: alert)
        present(alert, animated: true)
    }

    /// 为 iPad ActionSheet 设置锚点，避免无 popover source 导致崩溃。
    /// - Parameter alert: 即将展示的选择弹窗。
    private func configurePopover(for alert: UIAlertController) {
        guard traitCollection.userInterfaceIdiom == .pad,
              let popover = alert.popoverPresentationController else {
            return
        }
        popover.sourceView = pageView
        popover.sourceRect = CGRect(
            x: pageView.bounds.midX,
            y: pageView.bounds.midY,
            width: 1,
            height: 1
        )
    }

    /// 请求系统相册权限，授权后继续使用项目原有图片选择器。
    private func requestPhotoAccessAndOpenPicker() {
        guard selectedAssets.count < 9 else {
            return
        }
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            openImagePicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    if self?.isPhotoAccessGranted(newStatus) == true {
                        self?.openImagePicker()
                    } else {
                        self?.showPhotoPermissionWarning()
                    }
                }
            }
        default:
            if isPhotoAccessGranted(status) {
                openImagePicker()
            } else {
                showPhotoPermissionWarning()
            }
        }
    }

    /// 判断系统相册权限是否允许选择图片，并兼容 iOS 14 的有限照片权限。
    /// - Parameter status: 系统返回的当前相册授权状态。
    /// - Returns: 是否可以继续打开项目图片选择器。
    private func isPhotoAccessGranted(_ status: PHAuthorizationStatus) -> Bool {
        if status == .authorized {
            return true
        }
        if #available(iOS 14, *) {
            return status == .limited
        }
        return false
    }

    /// 推入项目原有图片选择器并限制剩余可选数量。
    private func openImagePicker() {
        let picker = NoaImagePickerVC()
        picker.maxSelectNum = 9 - selectedAssets.count
        picker.isNeedEdit = false
        picker.hasCamera = true
        picker.delegate = self
        picker.pickerType = .image
        navigationController?.pushViewController(picker, animated: true)
    }

    /// 提示用户在系统设置中开启相册权限。
    private func showPhotoPermissionWarning() {
        NoaHUDManager.share().showWarningMessage(
            complaintLocalized("相册权限未开启，请在设置中选择当前应用，开启相册权限")
        )
    }

    /// 删除指定图片并同步更新缩略图和按钮状态。
    /// - Parameter index: 图片在当前选择数组中的下标。
    private func deleteImage(at index: Int) {
        guard selectedAssets.indices.contains(index) else {
            return
        }
        selectedAssets.remove(at: index)
        if selectedThumbnails.indices.contains(index) {
            selectedThumbnails.remove(at: index)
        }
        refreshPage()
    }

    /// 从 PHAsset 生成页面缩略图，完成后刷新图片网格。
    private func rebuildThumbnails() {
        guard !selectedAssets.isEmpty else {
            selectedThumbnails = []
            refreshPage()
            return
        }
        let assets = selectedAssets
        var thumbnails = Array<UIImage?>(repeating: nil, count: assets.count)
        let group = DispatchGroup()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true

        for (index, asset) in assets.enumerated() {
            group.enter()
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 240, height: 240),
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                let degraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                guard !degraded else {
                    return
                }
                thumbnails[index] = image
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self, self.selectedAssets.map(\.localIdentifier) == assets.map(\.localIdentifier) else {
                return
            }
            self.selectedThumbnails = thumbnails.compactMap { $0 }
            self.refreshPage()
        }
    }

    /// 校验邮箱格式，正则与原 Objective-C 页面保持一致。
    /// - Parameter value: 用户输入的邮箱原始值。
    /// - Returns: 去除首尾空白后是否满足原邮箱格式。
    private func isValidEmail(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed)
    }

    /// 校验状态后开始把选中图片压缩并写入投诉沙盒目录。
    private func submitComplaint() {
        guard canSubmit else {
            return
        }
        isSubmitting = true
        refreshSubmitState()
        NoaHUDManager.share().showMessage(complaintLocalized("处理中..."))
        prepareLocalImageFiles { [weak self] files in
            guard let self else {
                return
            }
            guard files.count == self.selectedAssets.count, !files.isEmpty else {
                self.finishSubmittingWithError(complaintLocalized("操作失败"))
                return
            }
            self.uploadImageFiles(files)
        }
    }

    /// 将 PHAsset 压缩为 JPEG 并写入当前用户的投诉缓存目录。
    /// - Parameter completion: 返回成功写入的本地文件信息。
    private func prepareLocalImageFiles(completion: @escaping ([ComplaintLocalFile]) -> Void) {
        let assets = selectedAssets
        let group = DispatchGroup()
        let lock = NSLock()
        var files: [ComplaintLocalFile] = []
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        for (index, asset) in assets.enumerated() {
            group.enter()
            PHImageManager.default().requestImageDataAndOrientation(
                for: asset,
                options: options
            ) { [weak self] data, _, _, _ in
                defer { group.leave() }
                guard
                    let self,
                    let data,
                    let image = UIImage(data: data),
                    let jpegData = image.jpegData(compressionQuality: 0.5),
                    let file = self.writeComplaintImage(jpegData, index: index)
                else {
                    return
                }
                lock.lock()
                files.append(file)
                lock.unlock()
            }
        }

        group.notify(queue: .main) {
            completion(files.sorted { $0.index < $1.index })
        }
    }

    /// 将压缩图片写入 Caches 下的用户投诉目录。
    /// - Parameters:
    ///   - data: 压缩后的 JPEG 数据。
    ///   - index: 当前图片顺序，用于保证文件名唯一和上传顺序稳定。
    /// - Returns: 写入成功后的本地文件信息；失败返回 nil。
    private func writeComplaintImage(_ data: Data, index: Int) -> ComplaintLocalFile? {
        let userUID = NoaUserManager.sharedInstance().userInfo?.userUID ?? "unknown"
        let directory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("\(userUID)-app_complain", isDirectory: true)
        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            let timestamp = Int64(Date().timeIntervalSince1970 * 1_000)
            let fileName = "\(userUID)_\(timestamp)_\(index).jpg"
            let fileURL = directory.appendingPathComponent(fileName)
            try data.write(to: fileURL, options: .atomic)
            return ComplaintLocalFile(
                index: index,
                name: fileName,
                path: fileURL.path,
                dataLength: data.count
            )
        } catch {
            return nil
        }
    }

    /// 使用原 NoaFileUploadManager 上传图片，全部成功后提交投诉接口。
    /// - Parameter files: 已写入沙盒的图片文件。
    private func uploadImageFiles(_ files: [ComplaintLocalFile]) {
        guard let manager = NoaFileUploadManager.sharedInstance() else {
            finishSubmittingWithError(complaintLocalized("上传图片失败"))
            return
        }
        let tokenTask = NoaFileUploadGetSTSTask()
        manager.operationQueue.addOperation(tokenTask)
        var uploadTasks: [NoaFileUploadTask] = []

        for file in files {
            guard let task = NoaFileUploadTask(
                taskId: file.name,
                filePath: file.path,
                originFilePath: "",
                fileName: file.name,
                fileType: "",
                isEncrypt: true,
                dataLength: UInt(file.dataLength),
                uploadType: .universal,
                beSendMessage: nil,
                delegate: nil
            ) else {
                finishSubmittingWithError(complaintLocalized("上传图片失败"))
                return
            }
            task.addDependency(tokenTask)
            uploadTasks.append(task)
        }
        uploadTasks.forEach { manager.add($0) }

        let completionOperation = BlockOperation { [weak self] in
            let failed = uploadTasks.contains { $0.status != .completed }
            let relativeURLs = uploadTasks.compactMap(\.originUrl)
            let fullURLs = relativeURLs.map {
                $0.getImageFullUrl().absoluteString
            }
            DispatchQueue.main.async {
                guard let self else {
                    return
                }
                if failed || relativeURLs.count != uploadTasks.count {
                    self.finishSubmittingWithError(complaintLocalized("上传图片失败"))
                    return
                }
                self.requestComplaintSubmit(
                    relativeImages: relativeURLs.joined(separator: ","),
                    fullImages: fullURLs.joined(separator: ",")
                )
            }
        }
        uploadTasks.forEach { completionOperation.addDependency($0) }
        manager.operationQueue.addOperation(completionOperation)
    }

    /// 根据当前分类调用系统反馈或邀请码/IP域名反馈接口。
    /// - Parameters:
    ///   - relativeImages: 系统投诉使用的相对图片地址。
    ///   - fullImages: 邀请码/IP域名投诉使用的完整图片地址。
    private func requestComplaintSubmit(relativeImages: String, fullImages: String) {
        let parameters = buildSubmitParameters(
            imageValue: complaintMode == .system ? relativeImages : fullImages
        )
        if complaintMode == .system {
            NoaIMSDKManager.sharedTool().userAddFeedBack(
                with: parameters,
                onSuccess: { [weak self] _, _ in
                    self?.handleSubmitSuccess()
                },
                onFailure: { [weak self] code, message, _ in
                    self?.handleSubmitFailure(code: code, message: message)
                }
            )
        } else {
            NoaIMSDKManager.sharedTool().ssoFeedBack(
                with: parameters,
                onSuccess: { [weak self] _, _ in
                    self?.handleSubmitSuccess()
                },
                onFailure: { [weak self] code, message, _ in
                    self?.handleSubmitFailure(code: code, message: message)
                }
            )
        }
    }

    /// 按原接口键构造投诉参数，保留好友、群组和“我的”三种目标。
    /// - Parameter imageValue: 当前接口要求的图片地址字符串。
    /// - Returns: 可直接传给 SDK 的参数字典。
    private func buildSubmitParameters(imageValue: String) -> NSMutableDictionary {
        let user = NoaUserManager.sharedInstance().userInfo
        let parameters = NSMutableDictionary()
        parameters["userUid"] = user?.userUID ?? ""
        parameters["nickname"] = user?.nickname ?? ""
        parameters["username"] = user?.userName ?? ""
        parameters["ufbImages"] = imageValue
        parameters["ufbContentGroup"] = selectedReason.value

        let trimmedContent = complaintContent.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedContent.isEmpty {
            parameters["ufbComment"] = trimmedContent
        }
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedEmail.isEmpty {
            parameters["ufbUserEmail"] = trimmedEmail
        }
        if complaintMode == .company {
            let company = currentCompanyValue()
            if !company.isEmpty {
                parameters["ufbTo"] = company
            }
            parameters["productCode"] = "alex"
        }

        if let complainID, !complainID.isEmpty {
            if complainType == .singleChat {
                parameters["ufbToType"] = "0"
                parameters["ufbToUserId"] = complainID
            } else if complainType == .groupChat {
                parameters["ufbToType"] = "1"
                parameters["ufbToGroupId"] = complainID
            }
        } else {
            parameters["ufbToType"] = "3"
        }
        return parameters
    }

    /// 获取企业投诉实际提交的邀请码或 IP/域名，IP/域名优先级沿用旧逻辑。
    /// - Returns: 去除首尾空白后的企业标识。
    private func currentCompanyValue() -> String {
        let info: NoaSsoInfoModel? = NoaSsoInfoModel.getSSOInfo()
        var value = info?.liceseId.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let domain = info?.ipDomainPortStr.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !domain.isEmpty {
            value = domain
        }
        return value
    }

    /// 生成人类可读的邀请码或域名展示文本。
    /// - Returns: 包含类型前缀的只读文本；无数据时返回提示。
    private func currentCompanyDisplayText() -> String {
        let info: NoaSsoInfoModel? = NoaSsoInfoModel.getSSOInfo()
        let domain = info?.ipDomainPortStr.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !domain.isEmpty {
            return "\(complaintLocalized("域名"))：\(domain)"
        }
        let license = info?.liceseId.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !license.isEmpty {
            return "\(complaintLocalized("邀请码"))：\(license)"
        }
        return complaintLocalized("暂无数据")
    }

    /// 处理投诉提交成功，提示后返回上一页。
    private func handleSubmitSuccess() {
        DispatchQueue.main.async { [weak self] in
            NoaHUDManager.share().showMessage(complaintLocalized("操作成功"))
            self?.handleBack()
        }
    }

    /// 处理投诉接口失败并恢复提交按钮。
    /// - Parameters:
    ///   - code: SDK 返回的错误码。
    ///   - message: SDK 返回的错误信息。
    private func handleSubmitFailure(code: Int, message: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.isSubmitting = false
            self?.refreshSubmitState()
            NoaHUDManager.share().showMessage(withCode: code, errorMsg: message ?? "")
        }
    }

    /// 处理图片准备或上传失败并恢复提交按钮。
    /// - Parameter message: 需要展示给用户的错误提示。
    private func finishSubmittingWithError(_ message: String) {
        isSubmitting = false
        refreshSubmitState()
        NoaHUDManager.share().showMessage(message)
    }
}

/// 项目图片选择器完成回调。
extension CoHereComplainViewController: ZImagePickerVCDelegate {

    /// 合并本次选中的图片资源并重新生成缩略图。
    @objc func imagePickerVCSelected() {
        let manager = NoaImagePickerManager.shared()
        let newAssets = manager.zSelectedAssets.compactMap { $0 as? PHAsset }
        let remainingCount = max(0, 9 - selectedAssets.count)
        selectedAssets.append(contentsOf: newAssets.prefix(remainingCount))
        manager.zSelectedAssets.removeAllObjects()
        rebuildThumbnails()
    }

    /// 用户取消图片选择时不改变当前表单。
    @objc func imagePickerVCCancel() {
        NoaImagePickerManager.shared().zSelectedAssets.removeAllObjects()
    }
}

/// 投诉接口类型，对应原系统投诉和邀请码/IP域名投诉两个页面。
private enum ComplaintMode: CaseIterable {
    case system
    case company

    /// 页面展示名称。
    var title: String {
        switch self {
        case .system:
            return complaintLocalized("系统投诉")
        case .company:
            return "\(complaintLocalized("邀请码"))/\(complaintLocalized("IP/域名"))"
        }
    }
}

/// 投诉原因及其原接口 ufbContentGroup 参数值。
private struct ComplaintReason {

    /// 本地化原因名称。
    let title: String

    /// 服务端分类参数值。
    let value: String

    /// 原页面默认的第一种原因。
    static var defaultReason: ComplaintReason {
        allReasons[0]
    }

    /// 原页面支持的全部八种投诉原因。
    static var allReasons: [ComplaintReason] {
        [
            ComplaintReason(title: complaintLocalized("发布违法有害信息"), value: "1"),
            ComplaintReason(title: complaintLocalized("发布垃圾广告"), value: "2"),
            ComplaintReason(title: complaintLocalized("种族歧视"), value: "3"),
            ComplaintReason(title: complaintLocalized("存在文化歧视"), value: "4"),
            ComplaintReason(title: complaintLocalized("辱骂骚扰"), value: "5"),
            ComplaintReason(title: complaintLocalized("帐号可能被盗"), value: "6"),
            ComplaintReason(title: complaintLocalized("存在欺诈行为"), value: "8"),
            ComplaintReason(title: complaintLocalized("其他"), value: "7")
        ]
    }
}

/// 已压缩并写入沙盒、等待上传的图片文件。
private struct ComplaintLocalFile {

    /// 图片在选择列表中的顺序。
    let index: Int

    /// 上传任务使用的唯一文件名。
    let name: String

    /// 图片沙盒绝对路径。
    let path: String

    /// 上传权限和任务使用的字节数。
    let dataLength: Int
}

/// 获取当前 App 语言下的投诉页面文案。
/// - Parameter key: 简体中文本地化键。
/// - Returns: 当前语言对应文本。
private func complaintLocalized(_ key: String) -> String {
    NoaLanguageManager.share().matchLocalLanguage(key)
}
