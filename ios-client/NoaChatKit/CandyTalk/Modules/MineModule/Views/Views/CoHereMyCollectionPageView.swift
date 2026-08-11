//
//  CoHereMyCollectionPageView.swift
//  CandyTalk
//
//  Created by Codex on 2026/7/29.
//

import SDWebImage
import UIKit

/// “我的收藏”Swift 页面，负责导航、收藏列表、空状态和滑动删除视觉。
final class CoHereMyCollectionPageView: UIView {

    /// 返回按钮点击回调。
    var onBackTap: (() -> Void)?

    /// 收藏项点击回调，参数为当前列表下标。
    var onItemTap: ((Int) -> Void)?

    /// 收藏项删除回调，参数为当前列表下标。
    var onDeleteTap: ((Int) -> Void)?

    /// 列表滚动到底部时的加载更多回调。
    var onLoadMore: (() -> Void)?

    /// 当前展示的收藏业务模型。
    private var collectionModels: [NoaMyCollectionModel] = []

    /// 是否已经为当前列表触发加载更多，防止同一页重复请求。
    private var didRequestMore = false

    /// 顶部导航背景。
    private let navigationView = UIView()

    /// 返回按钮。
    private let backButton = UIButton(type: .custom)

    /// 页面标题。
    private let titleLabel = UILabel()

    /// 收藏列表。
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 无收藏数据时展示的统一空状态。
    private let emptyStateView = CoHereEmptyStateView()

    /// 创建并布局 Swift 页面。
    /// - Parameter frame: 初始区域，最终尺寸由 Auto Layout 更新。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    /// Storyboard 初始化入口。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    /// 使用业务模型刷新收藏列表。
    /// - Parameter models: 当前已加载的收藏模型。
    func configure(models: [NoaMyCollectionModel]) {
        collectionModels = models
        didRequestMore = false
        emptyStateView.isHidden = !models.isEmpty
        tableView.isHidden = models.isEmpty
        tableView.reloadData()
    }

    /// 创建导航、列表和空状态布局。
    private func setupView() {
        backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)

        navigationView.translatesAutoresizingMaskIntoConstraints = false
        navigationView.backgroundColor = .white
        addSubview(navigationView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "cohere_blacklist_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        navigationView.addSubview(backButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = localized("收藏")
        titleLabel.textColor = UIColor(red: 17 / 255, green: 17 / 255, blue: 17 / 255, alpha: 1)
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationView.addSubview(titleLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = backgroundColor
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            CoHereCollectionTableViewCell.self,
            forCellReuseIdentifier: CoHereCollectionTableViewCell.reuseIdentifier
        )
        addSubview(tableView)

        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 88),

            backButton.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 12),
            backButton.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20),
            emptyStateView.widthAnchor.constraint(equalToConstant: 220),
            emptyStateView.heightAnchor.constraint(equalToConstant: 220)
        ])
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }

    /// 转发返回点击。
    @objc private func backTapped() {
        onBackTap?()
    }

    /// 获取当前 App 语言下的页面文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前语言对应文本。
    private func localized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }
}

extension CoHereMyCollectionPageView: UITableViewDataSource, UITableViewDelegate {

    /// 返回当前收藏条数。
    /// - Parameters:
    ///   - tableView: 收藏列表。
    ///   - section: 固定为 0 的列表分组。
    /// - Returns: 已加载收藏模型数量。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collectionModels.count
    }

    /// 创建并配置对应消息类型的 Swift 收藏 Cell。
    /// - Parameters:
    ///   - tableView: 收藏列表。
    ///   - indexPath: 当前收藏坐标。
    /// - Returns: 已配置的 Swift Cell。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereCollectionTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CoHereCollectionTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(model: collectionModels[indexPath.row])
        return cell
    }

    /// 使用原业务模型计算的高度保持收藏卡片尺寸。
    /// - Parameters:
    ///   - tableView: 收藏列表。
    ///   - indexPath: 当前收藏坐标。
    /// - Returns: 原模型 cellHeight，最小为 100pt。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        max(collectionModels[indexPath.row].cellHeight, 100)
    }

    /// 转发收藏项点击。
    /// - Parameters:
    ///   - tableView: 收藏列表。
    ///   - indexPath: 点击坐标。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onItemTap?(indexPath.row)
    }

    /// 接近列表尾部时触发一次加载更多。
    /// - Parameters:
    ///   - tableView: 收藏列表。
    ///   - cell: 即将显示的 Cell。
    ///   - indexPath: 即将显示坐标。
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard !didRequestMore,
              !collectionModels.isEmpty,
              indexPath.row >= collectionModels.count - 2 else {
            return
        }
        didRequestMore = true
        onLoadMore?()
    }

    /// 提供右滑删除操作并把下标转发给控制器。
    /// - Parameters:
    ///   - tableView: 收藏列表。
    ///   - indexPath: 当前收藏坐标。
    /// - Returns: 仅包含删除动作的配置。
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: localized("删除")) {
            [weak self] _, _, completion in
            self?.onDeleteTap?(indexPath.row)
            completion(true)
        }
        delete.image = UIImage(named: "icon_collection_delete")
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

/// 统一承载文本、图片、视频、文件和位置收藏的 Swift Cell。
private final class CoHereCollectionTableViewCell: UITableViewCell {

    /// UITableView 复用标识。
    static let reuseIdentifier = "CoHereCollectionTableViewCell"

    /// 白色圆角卡片。
    private let cardView = UIView()

    /// 消息主图，供图片、视频和位置类型使用。
    private let previewImageView = UIImageView()

    /// 视频消息播放标记。
    private let playImageView = UIImageView()

    /// 主标题或文本内容。
    private let contentLabel = UILabel()

    /// 文件类型或位置详情等副标题。
    private let detailLabel = UILabel()

    /// 收藏来源昵称。
    private let nicknameLabel = UILabel()

    /// 收藏时间。
    private let timeLabel = UILabel()

    /// 创建 Cell 并搭建 Swift UI。
    /// - Parameters:
    ///   - style: UITableView Cell 样式。
    ///   - reuseIdentifier: 复用标识。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    /// Storyboard 初始化入口。
    /// - Parameter coder: Storyboard 解码器。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    /// 清理异步图片和类型视觉状态。
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.sd_cancelCurrentImageLoad()
        previewImageView.image = nil
        previewImageView.isHidden = true
        playImageView.isHidden = true
        detailLabel.isHidden = true
        contentLabel.attributedText = nil
        contentLabel.text = nil
    }

    /// 根据收藏消息类型配置视觉内容。
    /// - Parameter model: 现有收藏业务模型。
    func configure(model: NoaMyCollectionModel) {
        let item = model.itemModel
        nicknameLabel.text = item.nick
        timeLabel.text = item.createTime
        previewImageView.isHidden = true
        playImageView.isHidden = true
        detailLabel.isHidden = true

        switch item.mtype.rawValue {
        case 0, 10:
            contentLabel.attributedText = model.attStr
        case 1:
            configurePreview(urlText: item.body.iImg, contentMode: .scaleAspectFit)
        case 2:
            configurePreview(urlText: item.body.cImg, contentMode: .scaleAspectFit)
            playImageView.isHidden = false
        case 3:
            configurePreview(urlText: item.body.cImg, contentMode: .scaleAspectFill)
            contentLabel.text = item.body.name
            detailLabel.text = item.body.details
            detailLabel.isHidden = false
        case 5:
            previewImageView.isHidden = false
            previewImageView.image = UIImage.getFileMessageIcon(
                withFileType: item.body.type,
                fileName: item.body.name
            )
            contentLabel.text = normalizedFileName(item.body.name)
            let type = NSString.getFileTypeContent(
                withFileType: item.body.type,
                fileName: item.body.name
            )
            detailLabel.text = "\(type) \(NSString.fileTranslate(toSize: item.body.size))"
            detailLabel.isHidden = false
        default:
            contentLabel.text = ""
        }
    }

    /// 创建圆角卡片和内容布局。
    private func setupCell() {
        selectionStyle = .default
        backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)
        contentView.backgroundColor = backgroundColor

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        contentView.addSubview(cardView)

        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.layer.cornerRadius = 4
        previewImageView.clipsToBounds = true
        previewImageView.isHidden = true
        cardView.addSubview(previewImageView)

        playImageView.translatesAutoresizingMaskIntoConstraints = false
        playImageView.image = UIImage(named: "icon_video_msg_play")
        playImageView.isHidden = true
        previewImageView.addSubview(playImageView)

        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = UIColor(red: 17 / 255, green: 17 / 255, blue: 17 / 255, alpha: 1)
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        cardView.addSubview(contentLabel)

        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.textColor = .secondaryLabel
        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.numberOfLines = 2
        detailLabel.isHidden = true
        cardView.addSubview(detailLabel)

        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.textColor = .secondaryLabel
        nicknameLabel.font = .systemFont(ofSize: 12)
        cardView.addSubview(nicknameLabel)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = .secondaryLabel
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textAlignment = .right
        cardView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            previewImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            previewImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            previewImageView.widthAnchor.constraint(equalToConstant: 80),
            previewImageView.heightAnchor.constraint(equalToConstant: 80),

            playImageView.centerXAnchor.constraint(equalTo: previewImageView.centerXAnchor),
            playImageView.centerYAnchor.constraint(equalTo: previewImageView.centerYAnchor),
            playImageView.widthAnchor.constraint(equalToConstant: 30),
            playImageView.heightAnchor.constraint(equalToConstant: 30),

            contentLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: previewImageView.leadingAnchor,
                constant: -12
            ),

            detailLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: previewImageView.leadingAnchor, constant: -12),

            nicknameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nicknameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            nicknameLabel.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.45),

            timeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            timeLabel.centerYAnchor.constraint(equalTo: nicknameLabel.centerYAnchor),
            timeLabel.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.45)
        ])
    }

    /// 加载收藏图片预览。
    /// - Parameters:
    ///   - urlText: SDK 返回的相对或完整图片地址。
    ///   - contentMode: 图片展示模式。
    private func configurePreview(urlText: String, contentMode: UIView.ContentMode) {
        previewImageView.isHidden = false
        previewImageView.contentMode = contentMode
        previewImageView.sd_setImage(
            with: urlText.getImageFullUrl(),
            placeholderImage: UIImage(named: "default_image")
        )
    }

    /// 移除服务端文件名前置的唯一标识。
    /// - Parameter fileName: 原始文件名。
    /// - Returns: 首个连字符后的用户文件名；无连字符时返回原值。
    private func normalizedFileName(_ fileName: String) -> String {
        guard let separator = fileName.firstIndex(of: "-") else {
            return fileName
        }
        return String(fileName[fileName.index(after: separator)...])
    }
}
