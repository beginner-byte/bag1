//
//  CoHereTeamPages.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/30.
//

import MJExtension
import MJRefresh
import SDWebImage
import UIKit

/// Figma“团队列表”Swift 控制器，保留首页统计、分页、详情和新建团队业务。
@objc(CoHereTeamListViewController)
final class CoHereTeamListViewController: CandyBaseViewController {

    /// 原团队列表数据处理器，继续负责请求和分页状态。
    private let dataHandle = NoaTeamListDataHandle()

    /// Figma 团队列表页面。
    private let pageView = CoHereTeamListPageView()

    /// 创建页面、绑定数据流并请求首屏。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindActions()
        bindDataHandle()
        reloadData()
    }

    /// 将 Swift 页面铺满控制器。
    private func setupPage() {
        pageView.accessibilityIdentifier = "cohere.team.list"
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 绑定返回、新建、详情、复制、刷新和分页动作。
    private func bindActions() {
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onCreateTap = { [weak self] in self?.openCreateTeam() }
        pageView.onTeamTap = { [weak self] model in self?.openDetail(model) }
        pageView.onCopyTap = { [weak self] code in
            UIPasteboard.general.string = code
            self?.showMessage("复制成功")
        }
        pageView.onRefresh = { [weak self] in
            self?.dataHandle.resumeDefaultConfigure()
            self?.reloadData()
        }
        pageView.onLoadMore = { [weak self] in
            guard let self else {
                return
            }
            dataHandle.requestMoreDataConfigure()
            dataHandle.requestTeamListCommand.execute(nil)
        }
    }

    /// 监听原 RACCommand 完成信号并刷新 Swift 页面。
    private func bindDataHandle() {
        _ = dataHandle.requestTeamHomeDataCommand.executionSignals
            .switchToLatest()
            .subscribeNext { [weak self] _ in self?.refreshPage() }
        _ = dataHandle.requestTeamListCommand.executionSignals
            .switchToLatest()
            .subscribeNext { [weak self] _ in
                self?.pageView.endRefreshing()
                self?.refreshPage()
            }
    }

    /// 重置后的首页统计和团队列表请求。
    private func reloadData() {
        dataHandle.requestTeamHomeDataCommand.execute(nil)
        dataHandle.requestTeamListCommand.execute(nil)
    }

    /// 将数据处理器中的模型同步到 Swift 页面。
    private func refreshPage() {
        pageView.configure(
            summary: dataHandle.defaultTeamModel,
            teams: dataHandle.teamListModelArr as? [NoaTeamModel] ?? []
        )
    }

    /// 打开 Swift 新建团队页，并在创建成功后刷新列表。
    private func openCreateTeam() {
        let controller = CoHereTeamCreateViewController()
        controller.onCreated = { [weak self] in
            self?.dataHandle.resumeDefaultConfigure()
            self?.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 打开 Swift 团队详情页，并在详情发生修改后刷新列表。
    /// - Parameter model: 被点击的团队模型。
    private func openDetail(_ model: NoaTeamModel) {
        let controller = CoHereTeamDetailViewController()
        controller.currentTeamModel = model
        controller.onChanged = { [weak self] in
            self?.dataHandle.resumeDefaultConfigure()
            self?.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 使用当前 App 语言显示提示。
    /// - Parameter key: 简体中文本地化键。
    private func showMessage(_ key: String) {
        NoaHUDManager.share().showMessage(
            NoaLanguageManager.share().matchLocalLanguage(key)
        )
    }
}

/// Figma“团队详情”Swift 控制器，保留置顶、改名、复制、保存二维码和成员入口。
final class CoHereTeamDetailViewController: CandyBaseViewController {

    /// 上一级传入的团队模型。
    var currentTeamModel: NoaTeamModel!

    /// 详情发生修改时通知团队列表刷新。
    var onChanged: (() -> Void)?

    /// 原团队详情数据处理器。
    private var dataHandle: NoaTeamInviteDetailDataHandle!

    /// Figma 团队详情页面。
    private let pageView = CoHereTeamDetailPageView()

    /// 创建页面、绑定请求并加载详情。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        dataHandle = NoaTeamInviteDetailDataHandle(teamModel: currentTeamModel)
        setupPage()
        bindActions()
        bindDataHandle()
        dataHandle.requestTeamDetailDataCommand.execute(nil)
    }

    /// 离开详情后按旧逻辑通知列表刷新。
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if dataHandle.isOperation {
            onChanged?()
        }
    }

    /// 将详情页面铺满控制器。
    private func setupPage() {
        pageView.accessibilityIdentifier = "cohere.team.detail"
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 绑定详情页全部可见操作。
    private func bindActions() {
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onTopTap = { [weak self] in
            self?.dataHandle.editTeamDetailInfoCommand.execute(nil)
        }
        pageView.onEditNameTap = { [weak self] in self?.editTeamName() }
        pageView.onCopyTap = { [weak self] value in
            UIPasteboard.general.string = value
            self?.showMessage("复制成功")
        }
        pageView.onSaveQRCodeTap = { [weak self] in self?.saveQRCode() }
        pageView.onMembersTap = { [weak self] in self?.openMembers() }
    }

    /// 监听详情、置顶和名称变化信号。
    private func bindDataHandle() {
        _ = dataHandle.requestTeamDetailDataCommand.executionSignals
            .switchToLatest()
            .subscribeNext { [weak self] value in
                guard (value as? NSNumber)?.boolValue == true else {
                    return
                }
                self?.refreshPage()
            }
        _ = dataHandle.editTeamDetailInfoCommand.executionSignals
            .switchToLatest()
            .subscribeNext { [weak self] value in
                guard (value as? NSNumber)?.boolValue == true else {
                    return
                }
                self?.dataHandle.isOperation = true
                self?.refreshPage()
            }
        _ = dataHandle.changeNewTeamSubject.subscribeNext { [weak self] value in
            guard let name = value as? String else {
                return
            }
            self?.dataHandle.changeNewTeamName(name)
            self?.dataHandle.isOperation = true
            self?.refreshPage()
        }
    }

    /// 把数据层当前持有的详情模型同步到 Swift 页面；请求失败由订阅回调提前拦截。
    private func refreshPage() {
        pageView.configure(model: dataHandle.teamDetailModel)
    }

    /// 复用原改名弹层并接收新名称。
    private func editTeamName() {
        let controller = NoaTeamInviteEditTeamNameVC()
        controller.modalPresentationStyle = .overFullScreen
        controller.currentTeamModel = currentTeamModel
        controller.changeTeamNameHandle = { [weak self] name in
            self?.dataHandle.changeNewTeamSubject.sendNext(name as NSString)
        }
        present(controller, animated: true)
    }

    /// 保存页面当前二维码到系统相册。
    private func saveQRCode() {
        guard let image = pageView.qrCodeImage else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }

    /// 处理系统相册保存结果。
    /// - Parameters:
    ///   - image: 提交保存的二维码。
    ///   - error: 系统保存错误，nil 表示成功。
    ///   - contextInfo: 系统回调上下文，本页不使用。
    @objc private func imageSaved(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer?
    ) {
        showMessage(error == nil ? "保存成功" : "保存失败")
    }

    /// 打开 Swift 团队成员页，并在踢人后重新加载详情。
    private func openMembers() {
        let controller = CoHereTeamMembersViewController()
        controller.teamID = currentTeamModel.teamId
        controller.onMemberRemoved = { [weak self] in
            self?.dataHandle.isOperation = true
            self?.dataHandle.requestTeamDetailDataCommand.execute(nil)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 使用当前 App 语言显示提示。
    /// - Parameter key: 简体中文本地化键。
    private func showMessage(_ key: String) {
        NoaHUDManager.share().showMessage(
            NoaLanguageManager.share().matchLocalLanguage(key)
        )
    }
}

/// Figma“团队成员”Swift 控制器，保留分页、搜索展示和踢人业务。
final class CoHereTeamMembersViewController: CandyBaseViewController {

    /// 当前团队 ID。
    var teamID = ""

    /// 成员被踢出后通知详情页刷新。
    var onMemberRemoved: (() -> Void)?

    /// 当前已加载的团队成员。
    private var members: [NoaTeamMemberModel] = []

    /// 当前分页页码，从 1 开始。
    private var pageNumber = 1

    /// 是否还有下一页。
    private var hasMore = false

    /// 防止重复分页请求。
    private var isLoading = false

    /// 是否成功移除过成员，用于离开页面时按旧页面时机通知详情刷新。
    private var didRemoveMember = false

    /// Figma 团队成员页面。
    private let pageView = CoHereTeamMembersPageView()

    /// 创建页面并请求首屏成员。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindActions()
        requestMembers(reset: true)
    }

    /// 离开成员页后通知团队详情刷新，保持原 Objective-C 页面的回调时机。
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if didRemoveMember {
            onMemberRemoved?()
        }
    }

    /// 将成员页面铺满控制器。
    private func setupPage() {
        pageView.accessibilityIdentifier = "cohere.team.members"
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 绑定返回、刷新、分页和踢人动作。
    private func bindActions() {
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onRefresh = { [weak self] in self?.requestMembers(reset: true) }
        pageView.onLoadMore = { [weak self] in
            guard let self, hasMore, !isLoading else {
                return
            }
            pageNumber += 1
            requestMembers(reset: false)
        }
        pageView.onKickTap = { [weak self] model in self?.confirmKick(model) }
    }

    /// 请求团队成员并处理旧接口分页字段。
    /// - Parameter reset: 是否从第一页重新加载。
    private func requestMembers(reset: Bool) {
        guard !isLoading else {
            return
        }
        isLoading = true
        if reset {
            pageNumber = 1
        }
        let parameters: NSMutableDictionary = [
            "teamId": teamID,
            "pageNumber": pageNumber,
            "pageSize": 50,
            "pageStart": (pageNumber - 1) * 50
        ]
        NoaIMSDKManager.sharedTool().imTeamMemberList(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self else {
                    return
                }
                isLoading = false
                guard let dictionary = data as? NSDictionary else {
                    pageView.endRefreshing()
                    return
                }
                let records = dictionary["records"] as? [Any] ?? []
                let newMembers =
                    NoaTeamMemberModel.mj_objectArray(withKeyValuesArray: records)
                        as? [NoaTeamMemberModel] ?? []
                if reset {
                    members = newMembers
                } else {
                    members.append(contentsOf: newMembers)
                }
                let pages = (dictionary["pages"] as? NSNumber)?.intValue ?? pageNumber
                hasMore = pageNumber < pages
                pageView.configure(members: members)
                pageView.endRefreshing()
            },
            onFailure: { [weak self] code, message, _ in
                self?.isLoading = false
                self?.pageView.endRefreshing()
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 展示原样式的踢人确认弹窗。
    /// - Parameter model: 待移出团队的成员。
    private func confirmKick(_ model: NoaTeamMemberModel) {
        let alert = NoaMessageAlertView(msgAlertType: .nomal, supView: nil)
        alert.lblContent.text = localized("是否确认将该用户踢出团队？ 踢出团队后不可恢复")
        alert.btnSure.setTitle(localized("确认"), for: .normal)
        alert.btnCancel.setTitle(localized("取消"), for: .normal)
        alert.sureBtnBlock = { [weak self] _ in self?.kick(model) }
        alert.alertShow()
    }

    /// 调用原踢人接口并从当前列表移除成功项。
    /// - Parameter model: 待移除成员。
    private func kick(_ model: NoaTeamMemberModel) {
        let parameters: NSMutableDictionary = [
            "memberId": model.userUid,
            "teamId": teamID
        ]
        NoaIMSDKManager.sharedTool().imTeamKickTeam(
            with: parameters,
            onSuccess: { [weak self] data, _ in
                guard let self, data != nil else {
                    return
                }
                showMessage("踢出团队成功")
                members.removeAll { $0.userUid == model.userUid }
                pageView.configure(members: members)
                didRemoveMember = true
            },
            onFailure: { code, message, _ in
                NoaHUDManager.share().showMessage(
                    withCode: code,
                    errorMsg: message ?? ""
                )
            }
        )
    }

    /// 获取当前 App 语言文本。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }

    /// 使用当前 App 语言显示提示。
    /// - Parameter key: 简体中文本地化键。
    private func showMessage(_ key: String) {
        NoaHUDManager.share().showMessage(localized(key))
    }
}

/// Figma“新建团队”Swift 控制器，保留随机邀请码、格式校验和置顶参数。
final class CoHereTeamCreateViewController: CandyBaseViewController {

    /// 创建成功后通知团队列表刷新。
    var onCreated: (() -> Void)?

    /// 原创建团队数据处理器。
    private let dataHandle = NoaTeamCreateDataHandle()

    /// Figma 新建团队页面。
    private let pageView = CoHereTeamCreatePageView()

    /// 创建页面并绑定 RACCommand。
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.isHidden = true
        setupPage()
        bindActions()
        bindDataHandle()
    }

    /// 将新建团队页铺满控制器。
    private func setupPage() {
        pageView.accessibilityIdentifier = "cohere.team.create"
        pageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 绑定返回、随机邀请码和保存动作。
    private func bindActions() {
        pageView.onBackTap = { [weak self] in self?.navBtnBackClicked() }
        pageView.onRandomTap = { [weak self] in
            self?.dataHandle.requestRandomCodeCommand.execute(nil)
        }
        pageView.onSaveTap = { [weak self] name, code, isTop in
            guard let self else {
                return
            }
            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                showMessage("请输入团队名称")
                return
            }
            guard dataHandle.validateInviteCode(code) else {
                return
            }
            let parameters: NSDictionary = [
                "teamName": name,
                "code": code,
                "isTop": NSNumber(value: isTop)
            ]
            dataHandle.createTeamCommand.execute(parameters)
        }
    }

    /// 监听随机邀请码、创建结果和服务端邀请码冲突。
    private func bindDataHandle() {
        _ = dataHandle.requestRandomCodeCommand.executionSignals
            .switchToLatest()
            .subscribeNext { [weak self] value in
                guard (value as? NSNumber)?.boolValue == true else {
                    return
                }
                self?.pageView.inviteCode = self?.dataHandle.randomCode ?? ""
            }
        _ = dataHandle.createTeamCommand.executionSignals
            .switchToLatest()
            .subscribeNext { [weak self] value in
                guard (value as? NSNumber)?.boolValue == true else {
                    return
                }
                self?.onCreated?()
                self?.navigationController?.popViewController(animated: true)
            }
        _ = dataHandle.showCodeErrorSubject.subscribeNext { [weak self] _ in
            self?.pageView.showInviteCodeError()
        }
    }

    /// 使用当前 App 语言显示提示。
    /// - Parameter key: 简体中文本地化键。
    private func showMessage(_ key: String) {
        NoaHUDManager.share().showMessage(
            NoaLanguageManager.share().matchLocalLanguage(key)
        )
    }
}

/// Figma 团队列表页面。
final class CoHereTeamListPageView: UIView, UITableViewDataSource,
    UITableViewDelegate {

    /// 点击返回按钮后的回调。
    var onBackTap: (() -> Void)?
    /// 点击新建团队后的回调。
    var onCreateTap: (() -> Void)?
    /// 点击团队行后的回调。
    var onTeamTap: ((NoaTeamModel) -> Void)?
    /// 点击邀请码复制后的回调。
    var onCopyTap: ((String) -> Void)?
    /// 下拉刷新回调。
    var onRefresh: (() -> Void)?
    /// 滚动到底部后的分页回调。
    var onLoadMore: (() -> Void)?

    /// 当前团队列表模型。
    private var teams: [NoaTeamModel] = []

    /// 顶部统计卡片。
    private let summaryView = CoHereTeamSummaryView()

    /// 团队列表。
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 无团队数据时复用“我的收藏”同款 Figma 空状态。
    private let emptyView = CoHereEmptyStateView()

    /// 初始化并构建页面。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 更新统计和团队列表。
    /// - Parameters:
    ///   - summary: 团队首页统计模型。
    ///   - teams: 当前已加载团队。
    func configure(summary: NoaTeamModel?, teams: [NoaTeamModel]) {
        self.teams = teams
        summaryView.configure(model: summary)
        emptyView.isHidden = !teams.isEmpty
        tableView.reloadData()
    }

    /// 停止下拉刷新动画。
    func endRefreshing() {
        tableView.refreshControl?.endRefreshing()
    }

    /// 构建渐变背景、导航栏、统计卡片和团队列表。
    private func setupUI() {
        backgroundColor = UIColor(coHereTeamHex: 0xF9F9FF)
        coHereAddGradient()

        let navigationBar = CoHereTeamNavigationBar(
            title: "团队列表",
            trailingTitle: "新建团队",
            backImageName: "cohere_team_back",
            contentBottomInset: 10
        )
        navigationBar.onBackTap = { [weak self] in self?.onBackTap?() }
        navigationBar.onTrailingTap = { [weak self] in self?.onCreateTap?() }
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationBar)

        summaryView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(summaryView)

        let sectionLabel = UILabel()
        sectionLabel.text = localized("我的团队")
        sectionLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        sectionLabel.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
            .withAlphaComponent(0.7)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sectionLabel)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            CoHereTeamListCell.self,
            forCellReuseIdentifier: CoHereTeamListCell.reuseIdentifier
        )
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        tableView.refreshControl = refresh
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)

        emptyView.isHidden = true
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyView)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),

            summaryView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 6),
            summaryView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            summaryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            summaryView.heightAnchor.constraint(equalToConstant: 169),

            sectionLabel.topAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: 20),
            sectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            sectionLabel.heightAnchor.constraint(equalToConstant: 22),

            tableView.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            emptyView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 40)
        ])
    }

    /// 返回团队行数。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        teams.count
    }

    /// 创建并配置团队卡片。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereTeamListCell.reuseIdentifier,
            for: indexPath
        ) as? CoHereTeamListCell else {
            return UITableViewCell()
        }
        let model = teams[indexPath.row]
        cell.configure(model: model)
        cell.onCopyTap = { [weak self] in self?.onCopyTap?(model.inviteCode) }
        return cell
    }

    /// 返回 Figma 76pt 团队卡片高度和 8pt 间距。
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        84
    }

    /// 打开被点击的团队详情。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onTeamTap?(teams[indexPath.row])
    }

    /// 列表接近底部时请求下一页。
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize.height > 0,
              scrollView.contentOffset.y + scrollView.bounds.height
                > scrollView.contentSize.height - 120 else {
            return
        }
        onLoadMore?()
    }

    /// 转发下拉刷新。
    @objc private func refreshTriggered() {
        onRefresh?()
    }

    /// 获取当前 App 语言文本。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Figma 团队首页统计卡片。
final class CoHereTeamSummaryView: UIView {

    /// 三个统计数字标签。
    private let valueLabels = [UILabel(), UILabel(), UILabel()]

    /// 初始化统计卡片。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 更新昨日、今日和本月邀请统计。
    /// - Parameter model: 团队首页统计模型。
    func configure(model: NoaTeamModel?) {
        valueLabels[0].text = "\(model?.yesterdayInviteNum ?? 0)"
        valueLabels[1].text = "\(model?.todayInviteNum ?? 0)"
        valueLabels[2].text = "\(model?.mouthInviteCount ?? 0)"
    }

    /// 构建半透明白色卡片和三列统计。
    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.7)
        layer.cornerRadius = 8
        layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        layer.borderWidth = 1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 1
        layer.shadowOffset = CGSize(width: 0, height: 1)

        let title = UILabel()
        title.text = localized("团队总数据")
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        title.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
            .withAlphaComponent(0.7)
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let labels = ["昨日邀请", "今日邀请", "本月邀请"]
        let colors: [UIColor] = [
            UIColor(coHereTeamHex: 0x6C63FF),
            UIColor(coHereTeamHex: 0xFF6584),
            UIColor(coHereTeamHex: 0x43C6AC)
        ]
        let iconNames = [
            "cohere_team_summary_calendar",
            "cohere_team_summary_trend",
            "cohere_team_summary_people"
        ]
        for index in 0..<3 {
            let column = UIStackView()
            column.axis = .vertical
            column.alignment = .center
            column.spacing = 6
            let iconContainer = UIView()
            iconContainer.backgroundColor = colors[index].withAlphaComponent(0.09)
            iconContainer.layer.cornerRadius = 8
            iconContainer.widthAnchor.constraint(equalToConstant: 36).isActive = true
            iconContainer.heightAnchor.constraint(equalToConstant: 36).isActive = true
            let icon = UIImageView(image: UIImage(named: iconNames[index]))
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            iconContainer.addSubview(icon)
            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 16),
                icon.heightAnchor.constraint(equalToConstant: 16)
            ])
            let value = valueLabels[index]
            value.text = "0"
            value.font = .systemFont(ofSize: 26, weight: .semibold)
            value.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
            let caption = UILabel()
            caption.text = localized(labels[index])
            caption.font = .systemFont(ofSize: 12, weight: .medium)
            caption.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
                .withAlphaComponent(0.5)
            column.addArrangedSubview(iconContainer)
            column.addArrangedSubview(value)
            column.addArrangedSubview(caption)
            stack.addArrangedSubview(column)
        }

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 21),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 21),
            title.heightAnchor.constraint(equalToConstant: 22),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 59),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 21),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -21)
        ])
    }

    /// 获取当前 App 语言文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Figma 团队列表卡片。
final class CoHereTeamListCell: UITableViewCell {

    /// 复用标识。
    static let reuseIdentifier = "CoHereTeamListCell"

    /// 点击复制邀请码后的回调。
    var onCopyTap: (() -> Void)?

    /// 团队名称。
    private let nameLabel = UILabel()

    /// 团队人数。
    private let countLabel = UILabel()

    /// 默认团队的置顶状态胶囊。
    private let pinnedBadge = UIButton(type: .custom)

    /// 邀请码按钮。
    private let codeButton = UIButton(type: .custom)

    /// 邀请码胶囊中显示接口邀请码的文本。
    private let codeValueLabel = UILabel()

    /// 创建卡片。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 更新团队名称、人数、邀请码和置顶状态。
    /// - Parameter model: 团队模型。
    func configure(model: NoaTeamModel) {
        nameLabel.text = model.teamName
        countLabel.text = "\(model.totalInviteNum)\(localized("人"))"
        codeValueLabel.text = model.inviteCode
        pinnedBadge.isHidden = model.isDefaultTeam != 1
    }

    /// 构建 76pt 半透明团队卡片。
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(
            coHereTeamHex: 0xF7F7F7
        ).withAlphaComponent(0.8).cgColor
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.05
        contentView.layer.shadowRadius = 1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)

        let avatar = UIImageView(image: UIImage(named: "cohere_team_avatar"))
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = 8
        avatar.clipsToBounds = true
        avatar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatar)

        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        countLabel.font = .systemFont(ofSize: 12, weight: .medium)
        countLabel.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
            .withAlphaComponent(0.4)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countLabel)

        pinnedBadge.setTitle(localized("置顶"), for: .normal)
        pinnedBadge.setTitleColor(UIColor(coHereTeamHex: 0xFF9500), for: .normal)
        pinnedBadge.setImage(UIImage(named: "cohere_team_pin"), for: .normal)
        pinnedBadge.titleLabel?.font = .systemFont(ofSize: 10)
        pinnedBadge.backgroundColor = UIColor(coHereTeamHex: 0xFF9500)
            .withAlphaComponent(0.12)
        pinnedBadge.semanticContentAttribute = .forceLeftToRight
        pinnedBadge.imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -1,
            bottom: 0,
            right: 1
        )
        pinnedBadge.layer.cornerRadius = 10
        pinnedBadge.isUserInteractionEnabled = false
        pinnedBadge.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pinnedBadge)

        let codeTitle = UILabel()
        codeTitle.text = localized("邀请码")
        codeTitle.font = .systemFont(ofSize: 12, weight: .medium)
        codeTitle.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
            .withAlphaComponent(0.4)
        codeTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(codeTitle)

        codeButton.backgroundColor = UIColor(coHereTeamHex: 0x6C63FF)
            .withAlphaComponent(0.1)
        codeButton.layer.cornerRadius = 11
        codeButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        codeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(codeButton)

        let codeIcon = UIImageView(
            image: UIImage(named: "cohere_team_copy")?.withRenderingMode(.alwaysOriginal)
        )
        codeIcon.contentMode = .scaleAspectFit
        codeIcon.isUserInteractionEnabled = false
        codeIcon.translatesAutoresizingMaskIntoConstraints = false
        codeButton.addSubview(codeIcon)

        codeValueLabel.font = .systemFont(ofSize: 12, weight: .medium)
        codeValueLabel.textColor = UIColor(coHereTeamHex: 0x6C63FF)
        codeValueLabel.textAlignment = .center
        codeValueLabel.isUserInteractionEnabled = false
        codeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        codeButton.addSubview(codeValueLabel)

        let chevron = UIImageView(image: UIImage(named: "cohere_team_arrow"))
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chevron)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            avatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 44),
            avatar.heightAnchor.constraint(equalToConstant: 44),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 6),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

            countLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 6),
            countLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            pinnedBadge.leadingAnchor.constraint(equalTo: countLabel.trailingAnchor, constant: 6),
            pinnedBadge.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            pinnedBadge.widthAnchor.constraint(equalToConstant: 51),
            pinnedBadge.heightAnchor.constraint(equalToConstant: 20),
            pinnedBadge.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),

            codeTitle.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            codeTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            codeTitle.heightAnchor.constraint(equalToConstant: 20),

            codeButton.leadingAnchor.constraint(equalTo: codeTitle.trailingAnchor, constant: 6),
            codeButton.centerYAnchor.constraint(equalTo: codeTitle.centerYAnchor),
            codeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 58),
            codeButton.heightAnchor.constraint(equalToConstant: 22),

            codeIcon.leadingAnchor.constraint(equalTo: codeButton.leadingAnchor, constant: 11),
            codeIcon.centerYAnchor.constraint(equalTo: codeButton.centerYAnchor),
            codeIcon.widthAnchor.constraint(equalToConstant: 11),
            codeIcon.heightAnchor.constraint(equalToConstant: 11),

            codeValueLabel.leadingAnchor.constraint(equalTo: codeIcon.trailingAnchor, constant: 4),
            codeValueLabel.trailingAnchor.constraint(equalTo: codeButton.trailingAnchor, constant: -8),
            codeValueLabel.centerYAnchor.constraint(equalTo: codeButton.centerYAnchor),
            codeValueLabel.heightAnchor.constraint(equalToConstant: 20),

            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 16),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])

        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        pinnedBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    /// 转发邀请码复制点击。
    @objc private func copyTapped() {
        onCopyTap?()
    }

    /// 获取当前 App 语言文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Figma 团队详情页面。
final class CoHereTeamDetailPageView: UIView {

    /// 点击返回后的回调。
    var onBackTap: (() -> Void)?
    /// 点击设为置顶后的回调。
    var onTopTap: (() -> Void)?
    /// 点击编辑名称后的回调。
    var onEditNameTap: (() -> Void)?
    /// 点击复制值后的回调。
    var onCopyTap: ((String) -> Void)?
    /// 点击保存二维码后的回调。
    var onSaveQRCodeTap: (() -> Void)?
    /// 点击查看成员后的回调。
    var onMembersTap: (() -> Void)?

    /// 当前二维码图片。
    private(set) var qrCodeImage: UIImage?

    /// 团队名称。
    private let nameLabel = UILabel()
    /// 邀请码摘要。
    private let codeSummaryLabel = UILabel()
    /// 四个统计值。
    private let metricLabels = [UILabel(), UILabel(), UILabel(), UILabel()]
    /// 二维码视图。
    private let qrCodeImageView = UIImageView()
    /// 邀请码展示文本，复制时仍使用完整原始值。
    private let inviteCodeValueLabel = UILabel()
    /// 下载链接展示文本，视觉截断但复制时仍使用完整原始值。
    private let linkValueLabel = UILabel()
    /// 当前完整邀请码。
    private var inviteCodeValue = ""
    /// 当前完整下载链接。
    private var linkValue = ""

    /// 初始化并构建详情页。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 更新团队详情和二维码。
    /// - Parameter model: 最新团队详情模型。
    func configure(model: NoaTeamModel) {
        nameLabel.text = model.teamName
        codeSummaryLabel.text = "\(localized("邀请码")) ： \(model.inviteCode)"
        metricLabels[0].text = "\(model.totalInviteNum)"
        metricLabels[1].text = "\(model.yesterdayInviteNum)"
        metricLabels[2].text = "\(model.todayInviteNum)"
        metricLabels[3].text = "\(model.mouthInviteCount)"
        inviteCodeValue = model.inviteCode
        inviteCodeValueLabel.text = inviteCodeValue
        let shareLink = (model as? NoaTeamDetailModel)?.shareLink
            ?? model.registerHtml
        linkValue = shareLink
        linkValueLabel.text = linkValue
        qrCodeImage = UIImage.getQRCodeImage(
            with: shareLink,
            qrCodeColor: UIColor(coHereTeamHex: 0x1A1D2E),
            inputCorrectionLevel: .M
        )
        qrCodeImageView.image = qrCodeImage
    }

    /// 构建固定导航栏和完整可滚动详情内容。
    private func setupUI() {
        backgroundColor = UIColor(coHereTeamHex: 0xF9F9FF)
        coHereAddGradient()

        let navigationBar = CoHereTeamNavigationBar(
            title: "团队详情",
            trailingTitle: "设为置顶",
            backImageName: "cohere_team_back",
            contentBottomInset: 10
        )
        navigationBar.onBackTap = { [weak self] in self?.onBackTap?() }
        navigationBar.onTrailingTap = { [weak self] in self?.onTopTap?() }
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationBar)

        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        content.addArrangedSubview(makeProfileCard())
        content.addArrangedSubview(makeMetricsGrid())
        let qrCodeCard = makeQRCodeCard()
        content.addArrangedSubview(qrCodeCard)

        let bottomBar = UIStackView()
        bottomBar.axis = .horizontal
        bottomBar.spacing = 16
        bottomBar.distribution = .fill

        let saveButton = makeBottomButton(
            title: "保存二维码",
            filled: false,
            action: #selector(saveTapped)
        )
        let membersButton = makeBottomButton(
            title: "查看成员",
            filled: true,
            action: #selector(membersTapped)
        )
        bottomBar.addArrangedSubview(saveButton)
        bottomBar.addArrangedSubview(membersButton)
        content.addArrangedSubview(bottomBar)
        content.setCustomSpacing(32, after: qrCodeCard)

        let bottomSpacer = UIView()
        bottomSpacer.heightAnchor.constraint(equalToConstant: 75).isActive = true
        content.addArrangedSubview(bottomSpacer)
        content.setCustomSpacing(0, after: bottomBar)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 6),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            bottomBar.heightAnchor.constraint(equalToConstant: 48),
            saveButton.widthAnchor.constraint(equalToConstant: 149)
        ])
    }

    /// 创建团队头像、名称和邀请码卡片。
    private func makeProfileCard() -> UIView {
        let card = makeDetailCard()
        card.heightAnchor.constraint(equalToConstant: 92).isActive = true

        let avatar = UIImageView(image: UIImage(named: "cohere_team_avatar"))
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = 8
        avatar.clipsToBounds = true
        avatar.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(avatar)

        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)

        let editButton = UIButton(type: .system)
        let editImage = UIImage(
            systemName: "pencil",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        editButton.setImage(editImage, for: .normal)
        editButton.tintColor = UIColor(coHereTeamHex: 0x6C63FF)
        editButton.backgroundColor = UIColor(coHereTeamHex: 0x6C63FF)
            .withAlphaComponent(0.10)
        editButton.layer.cornerRadius = 14
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(editButton)

        codeSummaryLabel.font = .systemFont(ofSize: 12)
        codeSummaryLabel.textColor = UIColor(coHereTeamHex: 0x999BA5)
        codeSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(codeSummaryLabel)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 60),
            avatar.heightAnchor.constraint(equalToConstant: 60),
            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            editButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            editButton.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 28),
            editButton.heightAnchor.constraint(equalToConstant: 28),
            codeSummaryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            codeSummaryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6)
        ])
        return card
    }

    /// 创建 2×2 团队统计卡片。
    private func makeMetricsGrid() -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 12
        let captions = ["团队成员", "昨日邀请", "今日邀请", "本月邀请"]
        let iconNames = [
            "cohere_team_summary_people",
            "cohere_team_summary_calendar",
            "cohere_team_summary_trend",
            "star"
        ]
        let iconColors = [
            UIColor(coHereTeamHex: 0x6C63FF),
            UIColor(coHereTeamHex: 0x6C63FF),
            UIColor(coHereTeamHex: 0xFF6584),
            UIColor(coHereTeamHex: 0x43C6AC)
        ]
        for row in 0..<2 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 9
            rowStack.distribution = .fillEqually
            for column in 0..<2 {
                let index = row * 2 + column
                let card = makeDetailCard()
                card.heightAnchor.constraint(equalToConstant: 78).isActive = true

                let iconContainer = UIView()
                iconContainer.backgroundColor = iconColors[index].withAlphaComponent(0.094)
                iconContainer.layer.cornerRadius = 8
                iconContainer.translatesAutoresizingMaskIntoConstraints = false
                card.addSubview(iconContainer)

                let sourceImage = index == 3
                    ? UIImage(systemName: iconNames[index])
                    : UIImage(named: iconNames[index])
                let iconView = UIImageView(
                    image: sourceImage?.withRenderingMode(.alwaysTemplate)
                )
                iconView.tintColor = iconColors[index]
                iconView.contentMode = .scaleAspectFit
                iconView.translatesAutoresizingMaskIntoConstraints = false
                iconContainer.addSubview(iconView)

                let value = metricLabels[index]
                value.text = "0"
                value.font = .systemFont(ofSize: 16, weight: .semibold)
                value.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
                value.translatesAutoresizingMaskIntoConstraints = false
                card.addSubview(value)
                let caption = UILabel()
                caption.text = localized(captions[index])
                caption.font = .systemFont(ofSize: 12)
                caption.textColor = UIColor(coHereTeamHex: 0x999BA5)
                caption.translatesAutoresizingMaskIntoConstraints = false
                card.addSubview(caption)
                NSLayoutConstraint.activate([
                    iconContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                    iconContainer.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                    iconContainer.widthAnchor.constraint(equalToConstant: 40),
                    iconContainer.heightAnchor.constraint(equalToConstant: 40),
                    iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                    iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                    iconView.widthAnchor.constraint(equalToConstant: 18),
                    iconView.heightAnchor.constraint(equalToConstant: 18),
                    value.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 68),
                    value.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                    caption.leadingAnchor.constraint(equalTo: value.leadingAnchor),
                    caption.topAnchor.constraint(equalTo: card.topAnchor, constant: 40)
                ])
                rowStack.addArrangedSubview(card)
            }
            grid.addArrangedSubview(rowStack)
        }
        return grid
    }

    /// 创建扫码卡片、二维码和可复制文本行。
    private func makeQRCodeCard() -> UIView {
        let card = makeDetailCard(showsShadow: true)
        card.heightAnchor.constraint(equalToConstant: 424).isActive = true

        let titleIconContainer = UIView()
        titleIconContainer.backgroundColor = UIColor(coHereTeamHex: 0x6C63FF)
            .withAlphaComponent(0.094)
        titleIconContainer.layer.cornerRadius = 14
        titleIconContainer.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleIconContainer)

        let titleIcon = UIImageView(
            image: UIImage(systemName: "qrcode.viewfinder")
        )
        titleIcon.tintColor = UIColor(coHereTeamHex: 0x6C63FF)
        titleIcon.contentMode = .scaleAspectFit
        titleIcon.translatesAutoresizingMaskIntoConstraints = false
        titleIconContainer.addSubview(titleIcon)

        let title = UILabel()
        title.text = localized("扫码加入团队")
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        title.textColor = UIColor(coHereTeamHex: 0x1A1D2E).withAlphaComponent(0.70)
        title.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(title)

        let qrCodeOuterView = UIView()
        qrCodeOuterView.backgroundColor = UIColor(coHereTeamHex: 0x6C63FF)
        qrCodeOuterView.layer.cornerRadius = 24
        qrCodeOuterView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(qrCodeOuterView)

        let qrCodeInnerView = UIView()
        qrCodeInnerView.backgroundColor = .white
        qrCodeInnerView.layer.cornerRadius = 16
        qrCodeInnerView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeOuterView.addSubview(qrCodeInnerView)

        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.clipsToBounds = true
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeInnerView.addSubview(qrCodeImageView)

        let inviteField = makeCopyField(
            titleKey: "团队邀请码",
            valueLabel: inviteCodeValueLabel,
            action: #selector(copyCodeTapped)
        )
        card.addSubview(inviteField)
        let linkField = makeCopyField(
            titleKey: "下载链接",
            valueLabel: linkValueLabel,
            action: #selector(copyLinkTapped)
        )
        card.addSubview(linkField)

        NSLayoutConstraint.activate([
            titleIconContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleIconContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 21),
            titleIconContainer.widthAnchor.constraint(equalToConstant: 28),
            titleIconContainer.heightAnchor.constraint(equalToConstant: 28),
            titleIcon.centerXAnchor.constraint(equalTo: titleIconContainer.centerXAnchor),
            titleIcon.centerYAnchor.constraint(equalTo: titleIconContainer.centerYAnchor),
            titleIcon.widthAnchor.constraint(equalToConstant: 14),
            titleIcon.heightAnchor.constraint(equalToConstant: 14),
            title.leadingAnchor.constraint(equalTo: titleIconContainer.trailingAnchor, constant: 8),
            title.centerYAnchor.constraint(equalTo: titleIconContainer.centerYAnchor),

            qrCodeOuterView.topAnchor.constraint(equalTo: card.topAnchor, constant: 63),
            qrCodeOuterView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            qrCodeOuterView.widthAnchor.constraint(equalToConstant: 160),
            qrCodeOuterView.heightAnchor.constraint(equalToConstant: 160),
            qrCodeInnerView.centerXAnchor.constraint(equalTo: qrCodeOuterView.centerXAnchor),
            qrCodeInnerView.centerYAnchor.constraint(equalTo: qrCodeOuterView.centerYAnchor),
            qrCodeInnerView.widthAnchor.constraint(equalToConstant: 152),
            qrCodeInnerView.heightAnchor.constraint(equalToConstant: 152),
            qrCodeImageView.centerXAnchor.constraint(equalTo: qrCodeInnerView.centerXAnchor),
            qrCodeImageView.centerYAnchor.constraint(equalTo: qrCodeInnerView.centerYAnchor),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 140),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 140),

            inviteField.topAnchor.constraint(equalTo: card.topAnchor, constant: 233),
            inviteField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 21),
            inviteField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            inviteField.heightAnchor.constraint(equalToConstant: 78),
            linkField.topAnchor.constraint(equalTo: inviteField.bottomAnchor, constant: 12),
            linkField.leadingAnchor.constraint(equalTo: inviteField.leadingAnchor),
            linkField.trailingAnchor.constraint(equalTo: inviteField.trailingAnchor),
            linkField.heightAnchor.constraint(equalToConstant: 77)
        ])
        return card
    }

    /// 创建底部操作按钮。
    private func makeBottomButton(
        title: String,
        filled: Bool,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(localized(title), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.75
        button.setTitleColor(
            filled ? .white : UIColor(coHereTeamHex: 0x6C63FF),
            for: .normal
        )
        button.backgroundColor = filled
            ? UIColor(coHereTeamHex: 0x6C63FF)
            : .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    /// 创建 Figma 团队详情专用半透明卡片，避免影响其他团队页面。
    /// - Parameter showsShadow: 是否展示二维码主卡片的轻阴影。
    /// - Returns: 已配置圆角、描边和可选阴影的卡片。
    private func makeDetailCard(showsShadow: Bool = false) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.70)
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.80).cgColor
        if showsShadow {
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.05
            card.layer.shadowRadius = 6
            card.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        return card
    }

    /// 创建带完整值文本和尾部复制图标的 Figma 字段。
    /// - Parameters:
    ///   - titleKey: 字段标题的本地化键。
    ///   - valueLabel: 用于显示值的标签；长内容只在视觉上截断。
    ///   - action: 点击整行或复制图标时执行的复制方法。
    /// - Returns: 高度由调用方约束的复制字段。
    private func makeCopyField(
        titleKey: String,
        valueLabel: UILabel,
        action: Selector
    ) -> UIView {
        let field = UIView()
        field.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = localized(titleKey)
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
            .withAlphaComponent(0.45)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        field.addSubview(titleLabel)

        let valueContainer = UIView()
        valueContainer.backgroundColor = UIColor(coHereTeamHex: 0xFAFAFE)
        valueContainer.layer.cornerRadius = 8
        valueContainer.layer.borderWidth = 1
        valueContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.80).cgColor
        valueContainer.translatesAutoresizingMaskIntoConstraints = false
        field.addSubview(valueContainer)

        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
        valueLabel.lineBreakMode = .byTruncatingMiddle
        valueLabel.numberOfLines = 1
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueContainer.addSubview(valueLabel)

        let copyButton = UIButton(type: .system)
        copyButton.setImage(
            UIImage(named: "cohere_team_copy")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        copyButton.tintColor = UIColor(coHereTeamHex: 0x6C63FF)
        copyButton.addTarget(self, action: action, for: .touchUpInside)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        valueContainer.addSubview(copyButton)

        let rowButton = UIButton(type: .custom)
        rowButton.addTarget(self, action: action, for: .touchUpInside)
        rowButton.translatesAutoresizingMaskIntoConstraints = false
        valueContainer.insertSubview(rowButton, at: 0)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: field.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: field.leadingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            valueContainer.topAnchor.constraint(equalTo: field.topAnchor, constant: 26),
            valueContainer.leadingAnchor.constraint(equalTo: field.leadingAnchor),
            valueContainer.trailingAnchor.constraint(equalTo: field.trailingAnchor),
            valueContainer.bottomAnchor.constraint(equalTo: field.bottomAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: valueContainer.leadingAnchor, constant: 16),
            valueLabel.centerYAnchor.constraint(equalTo: valueContainer.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -8),
            copyButton.trailingAnchor.constraint(equalTo: valueContainer.trailingAnchor, constant: -17),
            copyButton.centerYAnchor.constraint(equalTo: valueContainer.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 32),
            copyButton.heightAnchor.constraint(equalToConstant: 32),
            rowButton.topAnchor.constraint(equalTo: valueContainer.topAnchor),
            rowButton.leadingAnchor.constraint(equalTo: valueContainer.leadingAnchor),
            rowButton.trailingAnchor.constraint(equalTo: valueContainer.trailingAnchor),
            rowButton.bottomAnchor.constraint(equalTo: valueContainer.bottomAnchor)
        ])
        return field
    }

    /// 转发编辑名称点击。
    @objc private func editTapped() { onEditNameTap?() }
    /// 转发保存二维码点击。
    @objc private func saveTapped() { onSaveQRCodeTap?() }
    /// 转发查看成员点击。
    @objc private func membersTapped() { onMembersTap?() }
    /// 复制邀请码。
    @objc private func copyCodeTapped() {
        onCopyTap?(inviteCodeValue)
    }
    /// 复制下载链接。
    @objc private func copyLinkTapped() {
        onCopyTap?(linkValue)
    }

    /// 获取当前 App 语言文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Figma 团队成员页面。
final class CoHereTeamMembersPageView: UIView, UITableViewDataSource,
    UITableViewDelegate {

    /// 点击返回后的回调。
    var onBackTap: (() -> Void)?
    /// 下拉刷新回调。
    var onRefresh: (() -> Void)?
    /// 分页回调。
    var onLoadMore: (() -> Void)?
    /// 点击踢出团队后的回调。
    var onKickTap: ((NoaTeamMemberModel) -> Void)?

    /// 全量成员。
    private var members: [NoaTeamMemberModel] = []
    /// 搜索过滤后的成员。
    private var filteredMembers: [NoaTeamMemberModel] = []
    /// Figma 32pt 搜索输入框。
    private let searchField = UITextField()
    /// 成员列表。
    private let tableView = UITableView(frame: .zero, style: .plain)
    /// 暂无数据状态。
    private let emptyView = CoHereTeamEmptyView()

    /// 初始化并构建成员页面。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 更新成员列表并应用当前搜索条件。
    /// - Parameter members: 当前已加载成员。
    func configure(members: [NoaTeamMemberModel]) {
        self.members = members
        applySearch(searchField.text ?? "")
    }

    /// 停止下拉刷新动画。
    func endRefreshing() {
        tableView.refreshControl?.endRefreshing()
    }

    /// 构建渐变背景、搜索框和卡片列表。
    private func setupUI() {
        backgroundColor = UIColor(coHereTeamHex: 0xF9F9FF)
        coHereAddGradient()

        let navigationBar = CoHereTeamNavigationBar(
            title: "团队成员",
            trailingTitle: nil,
            backImageName: "cohere_team_back"
        )
        navigationBar.onBackTap = { [weak self] in self?.onBackTap?() }
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationBar)

        searchField.backgroundColor = UIColor.white.withAlphaComponent(0.78)
        searchField.layer.cornerRadius = 8
        searchField.font = .systemFont(ofSize: 12)
        searchField.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
        searchField.attributedPlaceholder = NSAttributedString(
            string: localized("请搜索"),
            attributes: [.foregroundColor: UIColor(coHereTeamHex: 0xB3B5BF)]
        )
        searchField.clearButtonMode = .whileEditing
        searchField.returnKeyType = .search
        searchField.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )
        let searchIcon = UIImageView(
            image: UIImage(systemName: "magnifyingglass")
        )
        searchIcon.tintColor = UIColor(coHereTeamHex: 0xB3B5BF)
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.frame = CGRect(x: 10, y: 9, width: 14, height: 14)
        let searchLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 32))
        searchLeftView.addSubview(searchIcon)
        searchField.leftView = searchLeftView
        searchField.leftViewMode = .always
        searchField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchField)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            CoHereTeamMemberCell.self,
            forCellReuseIdentifier: CoHereTeamMemberCell.reuseIdentifier
        )
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        tableView.refreshControl = refresh
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)

        emptyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyView)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),

            searchField.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -2),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 40),

            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            emptyView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 36)
        ])
    }

    /// 返回过滤后的成员数量。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredMembers.count
    }

    /// 创建成员卡片。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereTeamMemberCell.reuseIdentifier,
            for: indexPath
        ) as? CoHereTeamMemberCell else {
            return UITableViewCell()
        }
        let model = filteredMembers[indexPath.row]
        cell.configure(model: model)
        cell.onKickTap = { [weak self] in self?.onKickTap?(model) }
        return cell
    }

    /// 返回 Figma 94pt 卡片加 13pt 间距的列表步进高度。
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        107
    }

    /// 列表接近底部时请求下一页。
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y + scrollView.bounds.height
                > scrollView.contentSize.height - 120 else {
            return
        }
        onLoadMore?()
    }

    /// 按昵称执行大小写不敏感本地过滤。
    /// - Parameter query: 搜索关键词。
    private func applySearch(_ query: String) {
        filteredMembers = query.isEmpty
            ? members
            : members.filter { $0.nickname.localizedCaseInsensitiveContains(query) }
        emptyView.isHidden = !filteredMembers.isEmpty
        tableView.reloadData()
    }

    /// 搜索内容变化时过滤当前已加载成员的昵称。
    @objc private func searchTextChanged() {
        applySearch(searchField.text ?? "")
    }

    /// 转发下拉刷新。
    @objc private func refreshTriggered() {
        onRefresh?()
    }

    /// 获取当前 App 语言文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Figma 团队成员卡片。
final class CoHereTeamMemberCell: UITableViewCell {

    /// 复用标识。
    static let reuseIdentifier = "CoHereTeamMemberCell"

    /// 点击踢出按钮后的回调。
    var onKickTap: (() -> Void)?

    /// 独立卡片容器，用于在 107pt 行高中保留 13pt 卡片间距。
    private let cardView = UIView()
    /// 成员头像。
    private let avatarView = UIImageView()
    /// 成员昵称。
    private let nameLabel = UILabel()
    /// 在线状态。
    private let onlineLabel = UILabel()
    /// 在线状态图标。
    private let onlineIconView = UIImageView()
    /// 加入时间。
    private let joinTimeLabel = UILabel()
    /// 加入时间图标。
    private let joinTimeIconView = UIImageView()
    /// 头像右下角在线状态圆点。
    private let statusDotView = UIView()

    /// 创建成员卡片。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 更新头像、昵称、在线状态和加入时间。
    /// - Parameter model: 成员模型。
    func configure(model: NoaTeamMemberModel) {
        avatarView.sd_setImage(
            with: model.avatar.getImageFullUrl(),
            placeholderImage: UIImage(named: "c_avatar_icon"),
            options: [.allowInvalidSSLCertificates]
        )
        nameLabel.text = model.nickname
        let presentation = onlinePresentation(timestamp: model.latestOfflineTime)
        onlineLabel.text = presentation.text
        onlineLabel.textColor = presentation.color
        onlineIconView.tintColor = presentation.color
        statusDotView.backgroundColor = presentation.isOnline
            ? UIColor(coHereTeamHex: 0x4CCF70)
            : UIColor(coHereTeamHex: 0xD7DCE6)
        joinTimeLabel.text = model.joinTime
    }

    /// 构建 Figma 成员卡片和踢出按钮。
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.78)
        cardView.layer.cornerRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 8
        avatarView.clipsToBounds = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(avatarView)

        statusDotView.backgroundColor = UIColor(coHereTeamHex: 0xD7DCE6)
        statusDotView.layer.cornerRadius = 5
        statusDotView.layer.borderColor = UIColor.white.cgColor
        statusDotView.layer.borderWidth = 2
        statusDotView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(statusDotView)

        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)

        onlineIconView.image = UIImage(systemName: "wifi")
        onlineIconView.contentMode = .scaleAspectFit
        onlineIconView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(onlineIconView)

        onlineLabel.font = .systemFont(ofSize: 12)
        onlineLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(onlineLabel)

        joinTimeIconView.image = UIImage(systemName: "arrow.turn.down.right")
        joinTimeIconView.tintColor = UIColor(coHereTeamHex: 0xB3B5BF)
        joinTimeIconView.contentMode = .scaleAspectFit
        joinTimeIconView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(joinTimeIconView)

        joinTimeLabel.font = .systemFont(ofSize: 12)
        joinTimeLabel.textColor = UIColor(coHereTeamHex: 0xB3B5BF)
        joinTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(joinTimeLabel)

        let kickButton = UIButton(type: .system)
        kickButton.setTitle(localized("踢出团队"), for: .normal)
        kickButton.setTitleColor(UIColor(coHereTeamHex: 0xFF6584), for: .normal)
        kickButton.titleLabel?.font = .systemFont(ofSize: 12)
        kickButton.titleLabel?.adjustsFontSizeToFitWidth = true
        kickButton.titleLabel?.minimumScaleFactor = 0.75
        kickButton.backgroundColor = UIColor(coHereTeamHex: 0xFFF4F6)
        kickButton.layer.borderColor = UIColor(coHereTeamHex: 0xFFB9C7).cgColor
        kickButton.layer.borderWidth = 1
        kickButton.layer.cornerRadius = 16
        kickButton.addTarget(self, action: #selector(kickTapped), for: .touchUpInside)
        kickButton.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(kickButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),

            avatarView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 44),
            avatarView.heightAnchor.constraint(equalToConstant: 44),
            statusDotView.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 2),
            statusDotView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 2),
            statusDotView.widthAnchor.constraint(equalToConstant: 10),
            statusDotView.heightAnchor.constraint(equalToConstant: 10),

            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: kickButton.leadingAnchor, constant: -12),
            onlineIconView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            onlineIconView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            onlineIconView.widthAnchor.constraint(equalToConstant: 14),
            onlineIconView.heightAnchor.constraint(equalToConstant: 14),
            onlineLabel.leadingAnchor.constraint(equalTo: onlineIconView.trailingAnchor, constant: 6),
            onlineLabel.centerYAnchor.constraint(equalTo: onlineIconView.centerYAnchor),
            onlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: kickButton.leadingAnchor, constant: -12),
            joinTimeIconView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            joinTimeIconView.topAnchor.constraint(equalTo: onlineIconView.bottomAnchor, constant: 3),
            joinTimeIconView.widthAnchor.constraint(equalToConstant: 14),
            joinTimeIconView.heightAnchor.constraint(equalToConstant: 14),
            joinTimeLabel.leadingAnchor.constraint(equalTo: joinTimeIconView.trailingAnchor, constant: 6),
            joinTimeLabel.centerYAnchor.constraint(equalTo: joinTimeIconView.centerYAnchor),
            joinTimeLabel.trailingAnchor.constraint(lessThanOrEqualTo: kickButton.leadingAnchor, constant: -12),

            kickButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            kickButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            kickButton.widthAnchor.constraint(equalToConstant: 70),
            kickButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    /// 根据最后离线时间生成 Figma 对应的文字、颜色和在线圆点状态。
    /// - Parameter timestamp: 服务端返回的秒或毫秒时间戳；0 表示在线，负数表示未知。
    /// - Returns: 状态文案、颜色及是否在线。
    private func onlinePresentation(timestamp: Int) -> (
        text: String,
        color: UIColor,
        isOnline: Bool
    ) {
        if timestamp == 0 {
            return (localized("在线"), UIColor(coHereTeamHex: 0x35C66C), true)
        }
        guard timestamp > 0 else {
            return ("-", UIColor(coHereTeamHex: 0x96A1BA), false)
        }
        let rawTimestamp = TimeInterval(timestamp)
        let now = Date().timeIntervalSince1970
        let normalizedTimestamp = rawTimestamp > now * 100
            ? rawTimestamp / 1000
            : rawTimestamp
        let isRecent = now - normalizedTimestamp <= 7 * 24 * 60 * 60
        let color = UIColor(coHereTeamHex: isRecent ? 0xF4C542 : 0x96A1BA)
        return (
            relativeOnlineText(timestamp: normalizedTimestamp, now: now),
            color,
            false
        )
    }

    /// 使用旧日期分类相同的区间和现有本地化键生成相对在线时间。
    /// - Parameters:
    ///   - timestamp: 已转换为秒的最后离线时间。
    ///   - now: 当前秒级时间戳。
    /// - Returns: “1分钟前在线”“5小时前在线”等本地化文案。
    private func relativeOnlineText(timestamp: TimeInterval, now: TimeInterval) -> String {
        let difference = max(0, now - timestamp)
        if difference < 60 {
            return String(format: localized("%@分钟前在线"), "1")
        }
        if difference < 60 * 60 {
            return String(
                format: localized("%@分钟前在线"),
                String(Int(floor(difference / 60)))
            )
        }
        if difference < 60 * 60 * 24 {
            return String(
                format: localized("%@小时前在线"),
                String(Int(floor(difference / (60 * 60))))
            )
        }
        if difference < 60 * 60 * 24 * 30 {
            return String(
                format: localized("%@天前在线"),
                String(Int(floor(difference / (60 * 60 * 24))))
            )
        }
        return localized("1月前在线")
    }

    /// 转发踢出点击。
    @objc private func kickTapped() {
        onKickTap?()
    }

    /// 获取当前 App 语言文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// Figma 新建团队页面。
final class CoHereTeamCreatePageView: UIView, UITextFieldDelegate {

    /// 点击返回后的回调。
    var onBackTap: (() -> Void)?
    /// 点击随机生成后的回调。
    var onRandomTap: (() -> Void)?
    /// 点击保存后的回调，依次传团队名、邀请码和置顶状态。
    var onSaveTap: ((String, String, Bool) -> Void)?

    /// 当前邀请码。
    var inviteCode: String {
        get { codeField.text ?? "" }
        set {
            codeField.text = newValue
            setInviteCodeErrorVisible(false)
            refreshSaveState()
        }
    }

    /// 团队名称输入。
    private let nameField = UITextField()
    /// 邀请码输入。
    private let codeField = UITextField()
    /// 邀请码错误提示。
    private let errorLabel = UILabel()
    /// 是否置顶。
    private let topSwitch = UISwitch()
    /// 保存按钮。
    private let saveButton = UIButton(type: .custom)
    /// 置顶区域相对邀请码输入框的顶部约束，用于避让邀请码错误提示。
    private var switchCardTopConstraint: NSLayoutConstraint?

    /// 初始化并构建表单。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// 展示服务端邀请码冲突提示。
    func showInviteCodeError() {
        errorLabel.text = localized("邀请码已存在")
        setInviteCodeErrorVisible(true)
    }

    /// 构建导航栏、两个输入区、置顶开关和保存按钮。
    private func setupUI() {
        backgroundColor = .white
        coHereAddGradient()
        let navigationBar = CoHereTeamNavigationBar(
            title: "新建团队",
            trailingTitle: nil,
            backImageName: "cohere_team_back",
            contentBottomInset: 10
        )
        navigationBar.onBackTap = { [weak self] in self?.onBackTap?() }
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationBar)

        let nameTitle = makeTitle("团队名称")
        addSubview(nameTitle)
        configureField(nameField, placeholder: "请输入团队名称")
        nameField.clearButtonMode = .whileEditing
        nameField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        addSubview(nameField)

        let codeTitle = makeTitle("邀请码")
        addSubview(codeTitle)
        configureField(codeField, placeholder: "请输入邀请码")
        codeField.clearButtonMode = .whileEditing
        codeField.keyboardType = .numberPad
        codeField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        addSubview(codeField)

        let randomButton = UIButton(type: .system)
        randomButton.setTitle(localized("随机生成"), for: .normal)
        randomButton.setTitleColor(UIColor(coHereTeamHex: 0x6C63FF), for: .normal)
        randomButton.titleLabel?.font = .systemFont(ofSize: 14)
        randomButton.addTarget(self, action: #selector(randomTapped), for: .touchUpInside)
        randomButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(randomButton)

        errorLabel.font = .systemFont(ofSize: 12)
        errorLabel.textColor = UIColor(coHereTeamHex: 0xFF3333)
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorLabel)

        let switchCard = UIView()
        switchCard.backgroundColor = UIColor(coHereTeamHex: 0xF8F8FF)
        switchCard.layer.cornerRadius = 8
        switchCard.translatesAutoresizingMaskIntoConstraints = false
        addSubview(switchCard)

        let switchTitle = UILabel()
        switchTitle.text = localized("是否设为置顶")
        switchTitle.font = .systemFont(ofSize: 16)
        switchTitle.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
        switchTitle.translatesAutoresizingMaskIntoConstraints = false
        switchCard.addSubview(switchTitle)

        topSwitch.onTintColor = UIColor(coHereTeamHex: 0x6C63FF)
        topSwitch.translatesAutoresizingMaskIntoConstraints = false
        switchCard.addSubview(topSwitch)

        saveButton.setTitle(localized("保存"), for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16)
        saveButton.backgroundColor = UIColor(coHereTeamHex: 0x6C63FF)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(saveButton)

        let switchCardTopConstraint = switchCard.topAnchor.constraint(
            equalTo: codeField.bottomAnchor,
            constant: 16
        )
        self.switchCardTopConstraint = switchCardTopConstraint

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),

            nameTitle.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 16),
            nameTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameField.topAnchor.constraint(equalTo: nameTitle.bottomAnchor, constant: 12),
            nameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameField.heightAnchor.constraint(equalToConstant: 52),

            codeTitle.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16),
            codeTitle.leadingAnchor.constraint(equalTo: nameTitle.leadingAnchor),
            codeField.topAnchor.constraint(equalTo: codeTitle.bottomAnchor, constant: 12),
            codeField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            codeField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            codeField.heightAnchor.constraint(equalToConstant: 52),
            randomButton.trailingAnchor.constraint(equalTo: codeField.trailingAnchor, constant: -16),
            randomButton.centerYAnchor.constraint(equalTo: codeField.centerYAnchor),
            errorLabel.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 3),
            errorLabel.leadingAnchor.constraint(equalTo: codeField.leadingAnchor),

            switchCardTopConstraint,
            switchCard.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            switchCard.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            switchCard.heightAnchor.constraint(equalToConstant: 52),
            switchTitle.leadingAnchor.constraint(equalTo: switchCard.leadingAnchor, constant: 16),
            switchTitle.centerYAnchor.constraint(equalTo: switchCard.centerYAnchor),
            topSwitch.trailingAnchor.constraint(equalTo: switchCard.trailingAnchor, constant: -16),
            topSwitch.centerYAnchor.constraint(equalTo: switchCard.centerYAnchor),

            saveButton.topAnchor.constraint(equalTo: switchCard.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        refreshSaveState()
    }

    /// 创建字段标题。
    private func makeTitle(_ key: String) -> UILabel {
        let label = UILabel()
        label.text = localized(key)
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// 配置 Figma 52pt 圆角输入框。
    private func configureField(_ field: UITextField, placeholder: String) {
        field.backgroundColor = UIColor(coHereTeamHex: 0xF8F8FF)
        field.layer.cornerRadius = 8
        field.font = .systemFont(ofSize: 14)
        field.textColor = UIColor(coHereTeamHex: 0x1A1D2E)
        field.attributedPlaceholder = NSAttributedString(
            string: localized(placeholder),
            attributes: [.foregroundColor: UIColor(coHereTeamHex: 0xAAB3CC)]
        )
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
    }

    /// 输入变化时限制团队名称和邀请码长度，并更新错误及保存状态。
    @objc private func textChanged() {
        if let text = nameField.text, text.count > 50 {
            nameField.text = String(text.prefix(50))
        }
        if let text = codeField.text, text.count > 4 {
            codeField.text = String(text.prefix(4))
        }
        setInviteCodeErrorVisible(false)
        refreshSaveState()
    }

    /// 根据团队名和邀请码是否为空更新保存按钮，格式校验仍在保存动作中执行。
    private func refreshSaveState() {
        let enabled = !(nameField.text ?? "").isEmpty
            && !(codeField.text ?? "").isEmpty
        saveButton.isEnabled = enabled
        saveButton.alpha = 1
    }

    /// 切换邀请码冲突提示，并调整下方置顶区域避免内容重叠。
    /// - Parameter visible: 是否展示服务端邀请码冲突提示。
    private func setInviteCodeErrorVisible(_ visible: Bool) {
        errorLabel.isHidden = !visible
        switchCardTopConstraint?.constant = visible ? 49 : 16
    }

    /// 转发随机生成点击。
    @objc private func randomTapped() { onRandomTap?() }

    /// 转发保存点击。
    @objc private func saveTapped() {
        onSaveTap?(
            nameField.text ?? "",
            codeField.text ?? "",
            topSwitch.isOn
        )
    }

    /// 获取当前 App 语言文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// 团队页面共用导航栏。
final class CoHereTeamNavigationBar: UIView {

    /// 点击返回后的回调。
    var onBackTap: (() -> Void)?
    /// 点击右侧文字后的回调。
    var onTrailingTap: (() -> Void)?

    /// 使用标题、可选右侧文字和页面专用返回图标创建导航栏。
    /// - Parameters:
    ///   - title: 页面标题本地化键。
    ///   - trailingTitle: 可选右侧操作本地化键。
    ///   - backImageName: 页面专用返回图标；nil 时沿用系统返回图标。
    ///   - contentBottomInset: 导航内容距离导航栏底部的间距。
    init(
        title: String,
        trailingTitle: String?,
        backImageName: String? = nil,
        contentBottomInset: CGFloat = 8
    ) {
        super.init(frame: .zero)
        setupUI(
            title: title,
            trailingTitle: trailingTitle,
            backImageName: backImageName,
            contentBottomInset: contentBottomInset
        )
    }

    /// Interface Builder 不支持动态标题。
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 向父页面提供包含状态栏和内容区的固定设计高度。
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 102)
    }

    /// 构建 Safe Area 导航栏，并保留未传配置页面的原布局。
    /// - Parameters:
    ///   - title: 页面标题本地化键。
    ///   - trailingTitle: 可选右侧操作本地化键。
    ///   - backImageName: 页面专用返回图标；nil 时使用系统图标。
    ///   - contentBottomInset: 导航内容距离导航栏底部的间距。
    private func setupUI(
        title: String,
        trailingTitle: String?,
        backImageName: String?,
        contentBottomInset: CGFloat
    ) {
        let backButton = UIButton(type: .system)
        let backImage = backImageName.flatMap(UIImage.init(named:))
            ?? UIImage(systemName: "chevron.left")
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = UIColor(coHereTeamHex: 0x555555)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.text = localized(title)
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(coHereTeamHex: 0x333333)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backButton.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -contentBottomInset
            ),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])

        if let trailingTitle {
            let button = UIButton(type: .system)
            button.setTitle(localized(trailingTitle), for: .normal)
            button.setTitleColor(UIColor(coHereTeamHex: 0x555555), for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.addTarget(self, action: #selector(trailingTapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                button.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
                button.heightAnchor.constraint(equalToConstant: 36)
            ])
        }
    }

    /// 转发返回点击。
    @objc private func backTapped() { onBackTap?() }
    /// 转发右侧操作点击。
    @objc private func trailingTapped() { onTrailingTap?() }

    /// 获取当前 App 语言文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

/// 团队页面共用半透明圆角卡片。
final class CoHereTeamCardView: UIView {

    /// 初始化卡片样式。
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.82)
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    /// Storyboard 初始化入口。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.white.withAlphaComponent(0.82)
        layer.cornerRadius = 8
    }
}

/// 团队成员页面继续使用的旧空状态，避免本次列表样式修改影响其他页面。
final class CoHereTeamEmptyView: UIStackView {

    /// 初始化成员页既有空态图文。
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        alignment = .center
        spacing = 10
        let imageView = UIImageView(image: UIImage(named: "c_no_history_chat"))
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        let label = UILabel()
        label.text = NoaLanguageManager.share().matchLocalLanguage("暂无数据")
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(coHereTeamHex: 0x999999)
        addArrangedSubview(imageView)
        addArrangedSubview(label)
    }

    /// Storyboard 初始化入口。
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}

private extension UIView {
    /// 添加 Figma 团队页面浅紫到白色的背景渐变。
    func coHereAddGradient() {
        let gradient = CAGradientLayer()
        gradient.name = "CoHereTeamGradient"
        gradient.colors = [
            UIColor(coHereTeamHex: 0xF2F1FF).cgColor,
            UIColor.white.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.7)
        gradient.frame = UIScreen.main.bounds
        layer.insertSublayer(gradient, at: 0)
    }
}

private extension UIColor {
    /// 使用 24 位十六进制值创建不透明颜色。
    /// - Parameter value: 0xRRGGBB 格式颜色值。
    convenience init(coHereTeamHex value: UInt32) {
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
