import UIKit

/// 按照 Figma “签到记录”节点实现的 Swift 视觉层；月份选择和记录请求由 Swift 控制器负责。
@objc(CoHereSignInRecordsPageView)
final class CoHereSignInRecordsPageView: UIView {

    // MARK: - Controller callbacks

    /// 点击返回按钮后的业务回调。
    @objc var onBackTap: (() -> Void)?

    /// 点击月份按钮后的业务回调。
    @objc var onMonthTap: (() -> Void)?

    // MARK: - Navigation

    /// 页面导航区域，覆盖系统安全区和 56pt 导航内容。
    private let coHereNavigationView = UIView()

    /// 返回按钮，图标来自 Figma，点击区域为 44pt。
    private let coHereBackButton = UIButton(type: .custom)

    /// 页面居中的导航标题。
    private let coHereTitleLabel = UILabel()

    /// 当前年月选择按钮，点击后复用原日期选择器。
    private let coHereMonthButton = UIButton(type: .custom)

    // MARK: - Records

    /// 承载月份汇总、明细标题和记录卡片的列表。
    private let coHereTableView = UITableView(frame: .zero, style: .plain)

    /// 列表头部，包含渐变汇总区和“签到明细”标题。
    private let coHereHeaderView = UIView()

    /// 月份汇总的紫色渐变背景。
    private let coHereSummaryView = CoHereSignRecordsGradientView()

    /// 汇总标题前的 Figma 奖杯图标。
    private let coHereSummaryIconView = UIImageView(
        image: UIImage(named: "cohere_records_trophy")
    )

    /// “年月 + 签到汇总”标题。
    private let coHereSummaryTitleLabel = UILabel()

    /// 月度积分前的 Figma 星形图标。
    private let coHerePointsIconView = UIImageView(
        image: UIImage(named: "cohere_records_star")
    )

    /// 当前月份累计积分。
    private let coHerePointsLabel = UILabel()

    /// “积分已到账”说明文字。
    private let coHerePointsCaptionLabel = UILabel()

    /// 当前月份签到天数统计卡。
    private let coHereSignDaysStatView = CoHereSignRecordsStatView(
        iconName: "cohere_records_sign_days",
        caption: "签到天数"
    )

    /// 当前月份获得连签奖励次数统计卡。
    private let coHereRewardCountStatView = CoHereSignRecordsStatView(
        iconName: "cohere_records_reward_count",
        caption: "获奖励次数"
    )

    /// 当前月份日均积分统计卡。
    private let coHereAverageStatView = CoHereSignRecordsStatView(
        iconName: "cohere_records_average",
        caption: "日均积分"
    )

    /// “签到明细”列表标题。
    private let coHereDetailsTitleLabel = UILabel()

    /// 明细标题后的装饰分隔线。
    private let coHereDetailsLineView = UIView()

    /// 当前记录总数说明。
    private let coHereDetailsCountLabel = UILabel()

    // MARK: - Display state

    /// 当前接口返回的记录转换结果，顺序与接口数组保持一致。
    private var coHereRecords: [CoHereSignRecordDisplayModel] = []

    /// 当前展示年份。
    private var coHereYear = Calendar.current.component(.year, from: Date())

    /// 当前展示月份，取值为 1...12。
    private var coHereMonth = Calendar.current.component(.month, from: Date())

    /// 创建签到记录视觉层并完成控件、约束和交互初始化。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupView()
        coHereSetupConstraints()
        coHereBindActions()
        coHereApplyInitialContent()
    }

    /// Storyboard/XIB 初始化入口，保持与代码初始化一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView()
        coHereSetupConstraints()
        coHereBindActions()
        coHereApplyInitialContent()
    }

    /// 根据当前视图宽度更新 UITableView 的固定头部尺寸。
    override func layoutSubviews() {
        super.layoutSubviews()
        let targetFrame = CGRect(x: 0, y: 0, width: bounds.width, height: 263)
        if coHereHeaderView.frame != targetFrame {
            coHereHeaderView.frame = targetFrame
            coHereTableView.tableHeaderView = coHereHeaderView
        }
    }

    /// 使用现有签到记录字段刷新月份汇总和明细卡片，不发起新请求。
    /// - Parameters:
    ///   - records: 原接口 `signInRecords` 数组，每项包含创建时间及三类积分字段。
    ///   - totalPoints: 原接口 `totalLoyalty`，作为当前月份汇总积分展示。
    ///   - year: 日期选择器当前年份。
    ///   - month: 日期选择器当前月份，取值为 1...12。
    @objc(configureWithRecords:totalPoints:year:month:)
    func coHereConfigure(
        records: [[String: Any]],
        totalPoints: String,
        year: Int,
        month: Int
    ) {
        coHereYear = year
        coHereMonth = month
        coHereRecords = coHereBuildDisplayModels(records: records, year: year, month: month)

        let rewardCount = coHereRecords.filter { $0.rewardPoints > 0 }.count
        let totalValue = coHereIntegerValue(totalPoints)
        let averageValue = coHereRecords.isEmpty ? 0 : totalValue / coHereRecords.count

        coHereMonthButton.setTitle("\(year)-\(month)", for: .normal)
        coHereSummaryTitleLabel.text = "\(year)-\(month) \(coHereLocalized("签到汇总"))"
        coHerePointsLabel.text = coHereFormattedNumber(totalPoints)
        coHereSignDaysStatView.coHereSetValue("\(coHereRecords.count)\(coHereLocalized("天"))")
        coHereRewardCountStatView.coHereSetValue("\(rewardCount)\(coHereLocalized("次"))")
        coHereAverageStatView.coHereSetValue("\(averageValue)")
        coHereDetailsCountLabel.text = String(
            format: coHereLocalized("共%@条"),
            "\(coHereRecords.count)"
        )
        coHereTableView.reloadData()
    }

    /// 创建页面全部 UIKit 控件并应用 Figma 的字体、颜色和圆角。
    private func coHereSetupView() {
        backgroundColor = UIColor(coHereRecordsHex: 0xF8F8FF)

        coHereNavigationView.translatesAutoresizingMaskIntoConstraints = false
        coHereNavigationView.backgroundColor = UIColor(coHereRecordsHex: 0xFAF9FF)
        addSubview(coHereNavigationView)

        coHereBackButton.translatesAutoresizingMaskIntoConstraints = false
        coHereBackButton.setImage(UIImage(named: "cohere_records_back"), for: .normal)
        coHereBackButton.accessibilityLabel = coHereLocalized("返回")
        coHereNavigationView.addSubview(coHereBackButton)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.textColor = UIColor(coHereRecordsHex: 0x333333)
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coHereTitleLabel.textAlignment = .center
        coHereNavigationView.addSubview(coHereTitleLabel)

        coHereMonthButton.translatesAutoresizingMaskIntoConstraints = false
        coHereMonthButton.backgroundColor = UIColor(coHereRecordsHex: 0xEEF2FF)
        coHereMonthButton.setTitleColor(UIColor(coHereRecordsHex: 0x6C63FF), for: .normal)
        coHereMonthButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .heavy)
        coHereMonthButton.setImage(UIImage(named: "cohere_records_dropdown"), for: .normal)
        coHereMonthButton.semanticContentAttribute = .forceRightToLeft
        coHereMonthButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        coHereMonthButton.layer.cornerRadius = 16
        coHereNavigationView.addSubview(coHereMonthButton)

        coHereTableView.translatesAutoresizingMaskIntoConstraints = false
        coHereTableView.backgroundColor = UIColor(coHereRecordsHex: 0xF8F8FF)
        coHereTableView.separatorStyle = .none
        coHereTableView.showsVerticalScrollIndicator = false
        coHereTableView.contentInsetAdjustmentBehavior = .never
        coHereTableView.dataSource = self
        coHereTableView.delegate = self
        coHereTableView.register(
            CoHereSignRecordTableViewCell.self,
            forCellReuseIdentifier: CoHereSignRecordTableViewCell.coHereReuseIdentifier
        )
        addSubview(coHereTableView)

        coHereConfigureHeaderView()
    }

    /// 配置列表头部的渐变汇总区和明细标题区。
    private func coHereConfigureHeaderView() {
        coHereHeaderView.backgroundColor = UIColor(coHereRecordsHex: 0xF8F8FF)

        coHereSummaryView.translatesAutoresizingMaskIntoConstraints = false
        coHereHeaderView.addSubview(coHereSummaryView)

        let summaryViews: [UIView] = [
            coHereSummaryIconView,
            coHereSummaryTitleLabel,
            coHerePointsIconView,
            coHerePointsLabel,
            coHerePointsCaptionLabel,
            coHereSignDaysStatView,
            coHereRewardCountStatView,
            coHereAverageStatView
        ]
        summaryViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            coHereSummaryView.addSubview($0)
        }

        coHereSummaryIconView.contentMode = .scaleAspectFit
        coHerePointsIconView.contentMode = .scaleAspectFit

        coHereSummaryTitleLabel.textColor = UIColor.white.withAlphaComponent(0.80)
        coHereSummaryTitleLabel.font = .systemFont(ofSize: 14, weight: .heavy)

        coHerePointsLabel.textColor = .white
        coHerePointsLabel.font = .systemFont(ofSize: 44, weight: .semibold)
        coHerePointsLabel.adjustsFontSizeToFitWidth = true
        coHerePointsLabel.minimumScaleFactor = 0.65

        coHerePointsCaptionLabel.textColor = UIColor.white.withAlphaComponent(0.55)
        coHerePointsCaptionLabel.font = .systemFont(ofSize: 14, weight: .regular)

        coHereDetailsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereDetailsTitleLabel.textColor = UIColor(coHereRecordsHex: 0x1E1B4B)
        coHereDetailsTitleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        coHereHeaderView.addSubview(coHereDetailsTitleLabel)

        coHereDetailsLineView.translatesAutoresizingMaskIntoConstraints = false
        coHereDetailsLineView.backgroundColor = UIColor(coHereRecordsHex: 0xE7E8F4)
        coHereHeaderView.addSubview(coHereDetailsLineView)

        coHereDetailsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereDetailsCountLabel.textColor = UIColor(coHereRecordsHex: 0x94A3B8)
        coHereDetailsCountLabel.font = .systemFont(ofSize: 11, weight: .regular)
        coHereHeaderView.addSubview(coHereDetailsCountLabel)
    }

    /// 建立页面、导航和汇总区域的 Auto Layout 约束。
    private func coHereSetupConstraints() {
        NSLayoutConstraint.activate([
            coHereNavigationView.topAnchor.constraint(equalTo: topAnchor),
            coHereNavigationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereNavigationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereNavigationView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 56),

            coHereBackButton.leadingAnchor.constraint(equalTo: coHereNavigationView.leadingAnchor, constant: 12),
            coHereBackButton.bottomAnchor.constraint(equalTo: coHereNavigationView.bottomAnchor, constant: -8),
            coHereBackButton.widthAnchor.constraint(equalToConstant: 44),
            coHereBackButton.heightAnchor.constraint(equalToConstant: 44),

            coHereTitleLabel.centerXAnchor.constraint(equalTo: coHereNavigationView.centerXAnchor),
            coHereTitleLabel.centerYAnchor.constraint(equalTo: coHereBackButton.centerYAnchor),

            coHereMonthButton.trailingAnchor.constraint(equalTo: coHereNavigationView.trailingAnchor, constant: -16),
            coHereMonthButton.centerYAnchor.constraint(equalTo: coHereBackButton.centerYAnchor),
            coHereMonthButton.widthAnchor.constraint(equalToConstant: 92),
            coHereMonthButton.heightAnchor.constraint(equalToConstant: 32),

            coHereTableView.topAnchor.constraint(equalTo: coHereNavigationView.bottomAnchor, constant: 9),
            coHereTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        coHereSetupHeaderConstraints()
    }

    /// 建立 Figma 汇总区及明细标题区内部约束。
    private func coHereSetupHeaderConstraints() {
        let statStackView = UIStackView(arrangedSubviews: [
            coHereSignDaysStatView,
            coHereRewardCountStatView,
            coHereAverageStatView
        ])
        statStackView.translatesAutoresizingMaskIntoConstraints = false
        statStackView.axis = .horizontal
        statStackView.spacing = 16
        statStackView.distribution = .fillEqually
        coHereSummaryView.addSubview(statStackView)

        NSLayoutConstraint.activate([
            coHereSummaryView.topAnchor.constraint(equalTo: coHereHeaderView.topAnchor),
            coHereSummaryView.leadingAnchor.constraint(equalTo: coHereHeaderView.leadingAnchor),
            coHereSummaryView.trailingAnchor.constraint(equalTo: coHereHeaderView.trailingAnchor),
            coHereSummaryView.heightAnchor.constraint(equalToConstant: 208),

            coHereSummaryIconView.leadingAnchor.constraint(equalTo: coHereSummaryView.leadingAnchor, constant: 20),
            coHereSummaryIconView.centerYAnchor.constraint(equalTo: coHereSummaryTitleLabel.centerYAnchor),
            coHereSummaryIconView.widthAnchor.constraint(equalToConstant: 15),
            coHereSummaryIconView.heightAnchor.constraint(equalToConstant: 15),

            coHereSummaryTitleLabel.leadingAnchor.constraint(equalTo: coHereSummaryIconView.trailingAnchor, constant: 8),
            coHereSummaryTitleLabel.topAnchor.constraint(equalTo: coHereSummaryView.topAnchor, constant: 20),
            coHereSummaryTitleLabel.heightAnchor.constraint(equalToConstant: 22),

            coHerePointsIconView.leadingAnchor.constraint(equalTo: coHereSummaryView.leadingAnchor, constant: 20),
            coHerePointsIconView.centerYAnchor.constraint(equalTo: coHerePointsLabel.centerYAnchor, constant: 5),
            coHerePointsIconView.widthAnchor.constraint(equalToConstant: 20),
            coHerePointsIconView.heightAnchor.constraint(equalToConstant: 20),

            coHerePointsLabel.leadingAnchor.constraint(equalTo: coHerePointsIconView.trailingAnchor, constant: 8),
            coHerePointsLabel.topAnchor.constraint(equalTo: coHereSummaryTitleLabel.bottomAnchor, constant: 12),
            coHerePointsLabel.heightAnchor.constraint(equalToConstant: 49),
            coHerePointsLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 160),

            coHerePointsCaptionLabel.leadingAnchor.constraint(equalTo: coHerePointsLabel.trailingAnchor, constant: 12),
            coHerePointsCaptionLabel.bottomAnchor.constraint(equalTo: coHerePointsLabel.bottomAnchor, constant: -4),

            statStackView.leadingAnchor.constraint(equalTo: coHereSummaryView.leadingAnchor, constant: 20),
            statStackView.trailingAnchor.constraint(equalTo: coHereSummaryView.trailingAnchor, constant: -20),
            statStackView.bottomAnchor.constraint(equalTo: coHereSummaryView.bottomAnchor, constant: -16),
            statStackView.heightAnchor.constraint(equalToConstant: 73),

            coHereDetailsTitleLabel.leadingAnchor.constraint(equalTo: coHereHeaderView.leadingAnchor, constant: 16),
            coHereDetailsTitleLabel.topAnchor.constraint(equalTo: coHereSummaryView.bottomAnchor, constant: 25),

            coHereDetailsLineView.leadingAnchor.constraint(equalTo: coHereDetailsTitleLabel.trailingAnchor, constant: 12),
            coHereDetailsLineView.centerYAnchor.constraint(equalTo: coHereDetailsTitleLabel.centerYAnchor),
            coHereDetailsLineView.heightAnchor.constraint(equalToConstant: 1),

            coHereDetailsCountLabel.leadingAnchor.constraint(equalTo: coHereDetailsLineView.trailingAnchor, constant: 12),
            coHereDetailsCountLabel.trailingAnchor.constraint(equalTo: coHereHeaderView.trailingAnchor, constant: -16),
            coHereDetailsCountLabel.centerYAnchor.constraint(equalTo: coHereDetailsTitleLabel.centerYAnchor),

            coHereDetailsLineView.widthAnchor.constraint(greaterThanOrEqualToConstant: 32)
        ])
    }

    /// 绑定返回和月份按钮事件，业务行为通过回调交给 Swift 控制器。
    private func coHereBindActions() {
        coHereBackButton.addTarget(self, action: #selector(coHereHandleBackTap), for: .touchUpInside)
        coHereMonthButton.addTarget(self, action: #selector(coHereHandleMonthTap), for: .touchUpInside)
    }

    /// 写入页面初始文案，接口数据到达后由 `coHereConfigure` 覆盖数值。
    private func coHereApplyInitialContent() {
        coHereTitleLabel.text = coHereLocalized("签到记录")
        coHerePointsCaptionLabel.text = coHereLocalized("积分已到账")
        coHereDetailsTitleLabel.text = coHereLocalized("签到明细")
        coHereConfigure(records: [], totalPoints: "0", year: coHereYear, month: coHereMonth)
    }

    /// 将控制器传入的字典数组转换为仅用于展示的 Swift 模型。
    /// - Parameters:
    ///   - records: 原接口记录数组。
    ///   - year: 当前选择年份，用于判断连续签到边界。
    ///   - month: 当前选择月份，用于判断连续签到边界。
    /// - Returns: 与输入顺序一致的展示模型数组。
    private func coHereBuildDisplayModels(
        records: [[String: Any]],
        year: Int,
        month: Int
    ) -> [CoHereSignRecordDisplayModel] {
        let calendar = Calendar.current
        let signedDates = Set(records.compactMap { record -> String? in
            guard let date = coHereDate(from: record["createTime"]) else { return nil }
            return coHereDateKey(date, calendar: calendar)
        })

        return records.map { record in
            let date = coHereDate(from: record["createTime"]) ?? Date(timeIntervalSince1970: 0)
            let dailyPoints = coHereIntegerValue(record["signMoneyDay"])
            let rewardPoints = coHereIntegerValue(record["signMoneyAway"])
            let rawTotal = coHereIntegerValue(record["money"])
            let totalPoints = rawTotal == 0 ? dailyPoints + rewardPoints : rawTotal
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let isSelectedMonth = dateComponents.year == year && dateComponents.month == month
            let streakDays = rewardPoints > 0 && isSelectedMonth
                ? coHereStreakDays(endingAt: date, signedDates: signedDates, calendar: calendar)
                : 0

            return CoHereSignRecordDisplayModel(
                dateText: coHereDateText(date),
                timeText: coHereTimeText(date),
                dailyPoints: dailyPoints,
                rewardPoints: rewardPoints,
                totalPoints: totalPoints,
                streakDays: streakDays
            )
        }
    }

    /// 计算同一月份内、截止指定日期的连续签到天数，避免跨月数据不完整时展示错误连签数。
    /// - Parameters:
    ///   - date: 当前奖励记录的签到日期。
    ///   - signedDates: 当前接口记录生成的日期键集合。
    ///   - calendar: 用于按自然日回溯的日历。
    /// - Returns: 当前月内可确认的连续天数。
    private func coHereStreakDays(
        endingAt date: Date,
        signedDates: Set<String>,
        calendar: Calendar
    ) -> Int {
        let targetMonth = calendar.component(.month, from: date)
        let targetYear = calendar.component(.year, from: date)
        var count = 0
        var cursor = date

        while calendar.component(.year, from: cursor) == targetYear,
              calendar.component(.month, from: cursor) == targetMonth,
              signedDates.contains(coHereDateKey(cursor, calendar: calendar)) {
            count += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previousDay
        }
        return count
    }

    /// 将毫秒或秒级时间戳转换为日期。
    /// - Parameter value: 接口 `createTime` 字段，可为数字或数字字符串。
    /// - Returns: 合法时间戳对应日期；无法解析时返回 nil。
    private func coHereDate(from value: Any?) -> Date? {
        let timestamp = Double(coHereStringValue(value)) ?? 0
        guard timestamp > 0 else { return nil }
        let seconds = timestamp > 10_000_000_000 ? timestamp / 1_000 : timestamp
        return Date(timeIntervalSince1970: seconds)
    }

    /// 生成用于连续签到集合匹配的本地自然日键。
    /// - Parameters:
    ///   - date: 待转换日期。
    ///   - calendar: 使用的本地日历。
    /// - Returns: `yyyy-MM-dd` 格式日期键。
    private func coHereDateKey(_ date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    /// 格式化记录卡片的月日文字。
    /// - Parameter date: 签到日期。
    /// - Returns: `MM-dd` 格式字符串。
    private func coHereDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }

    /// 格式化记录卡片的签到时间。
    /// - Parameter date: 签到日期。
    /// - Returns: `HH:mm` 格式字符串。
    private func coHereTimeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// 将接口中的数字或字符串字段统一转换为整数。
    /// - Parameter value: NSNumber、NSString、String 或 nil。
    /// - Returns: 可解析整数；无法解析时返回 0。
    private func coHereIntegerValue(_ value: Any?) -> Int {
        if let number = value as? NSNumber {
            return number.intValue
        }
        return Int(coHereStringValue(value)) ?? 0
    }

    /// 将接口中的可选字段转换为字符串。
    /// - Parameter value: 任意接口字段。
    /// - Returns: 字符串值；nil 返回空字符串。
    private func coHereStringValue(_ value: Any?) -> String {
        if let string = value as? String {
            return string
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return ""
    }

    /// 去除积分字符串无意义的小数尾零，保留接口的有效数值。
    /// - Parameter value: 原始积分字符串。
    /// - Returns: 适合页面展示的积分文字。
    private func coHereFormattedNumber(_ value: String) -> String {
        guard let decimal = Decimal(string: value) else {
            return value.isEmpty ? "0" : value
        }
        return NSDecimalNumber(decimal: decimal).stringValue
    }

    /// 获取项目本地化字符串。
    /// - Parameter key: Localizable.strings 中使用的中文键。
    /// - Returns: 当前语言对应文案。
    private func coHereLocalized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    /// 响应返回按钮点击并转发给控制器。
    @objc private func coHereHandleBackTap() {
        onBackTap?()
    }

    /// 响应月份按钮点击并转发给控制器。
    @objc private func coHereHandleMonthTap() {
        onMonthTap?()
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate

extension CoHereSignInRecordsPageView: UITableViewDataSource, UITableViewDelegate {

    /// 返回当前月份接口记录数量。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coHereRecords.count
    }

    /// 创建并配置普通或奖励样式的签到记录卡片。
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CoHereSignRecordTableViewCell.coHereReuseIdentifier,
            for: indexPath
        ) as? CoHereSignRecordTableViewCell else {
            return UITableViewCell()
        }
        cell.coHereConfigure(
            model: coHereRecords[indexPath.row],
            isFirst: indexPath.row == 0,
            isLast: indexPath.row == coHereRecords.count - 1
        )
        return cell
    }

    /// 根据是否包含奖励展示 Figma 的 154pt 或 199pt 卡片。
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        coHereRecords[indexPath.row].rewardPoints > 0 ? 203 : 158
    }

    /// 保持记录列表静态展示，不响应选中态。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

/// 签到记录接口字段转换后的页面展示模型。
private struct CoHereSignRecordDisplayModel {
    /// `MM-dd` 格式签到日期。
    let dateText: String

    /// `HH:mm` 格式签到时间。
    let timeText: String

    /// 当日日签积分。
    let dailyPoints: Int

    /// 当日奖励积分，大于 0 时使用奖励卡样式。
    let rewardPoints: Int

    /// 当日积分合计。
    let totalPoints: Int

    /// 当前月份内可确认的连续签到天数。
    let streakDays: Int
}

/// Figma 签到记录明细卡片，普通和奖励状态复用同一 UIKit Cell。
private final class CoHereSignRecordTableViewCell: UITableViewCell {

    /// UITableView 复用标识。
    static let coHereReuseIdentifier = "CoHereSignRecordTableViewCell"

    /// 时间轴竖线。
    private let coHereTimelineView = UIView()

    /// 时间轴外圈圆点。
    private let coHereTimelineRingView = UIView()

    /// 时间轴内部实心圆点。
    private let coHereTimelineDotView = UIView()

    /// 白色圆角记录卡片。
    private let coHereCardView = UIView()

    /// 日期图标的淡紫色底座。
    private let coHereCalendarBackgroundView = UIView()

    /// 来自 Figma 的日期图标。
    private let coHereCalendarIconView = UIImageView()

    /// 签到日期。
    private let coHereDateLabel = UILabel()

    /// 连签奖励标签。
    private let coHereStreakLabel = UILabel()

    /// 签到时间及状态。
    private let coHereTimeLabel = UILabel()

    /// 当日积分合计。
    private let coHereTotalPointsLabel = UILabel()

    /// 积分单位。
    private let coHerePointsUnitLabel = UILabel()

    /// 日签积分数值。
    private let coHereDailyValueLabel = UILabel()

    /// 奖励积分数值。
    private let coHereRewardValueLabel = UILabel()

    /// 当日合计数值。
    private let coHereTotalValueLabel = UILabel()

    /// 日签积分说明。
    private let coHereDailyCaptionLabel = UILabel()

    /// 奖励积分说明。
    private let coHereRewardCaptionLabel = UILabel()

    /// 当日合计说明。
    private let coHereTotalCaptionLabel = UILabel()

    /// 日签积分底座。
    private let coHereDailyTileView = UIView()

    /// 奖励积分底座。
    private let coHereRewardTileView = UIView()

    /// 当日合计底座。
    private let coHereTotalTileView = UIView()

    /// 奖励到账横幅，仅奖励记录显示。
    private let coHereRewardBannerView = UIView()

    /// 奖励横幅中的 Figma 皇冠图标。
    private let coHereRewardBannerIconView = UIImageView(
        image: UIImage(named: "cohere_records_crown")
    )

    /// 奖励到账说明。
    private let coHereRewardBannerLabel = UILabel()

    /// 卡片高度约束，根据普通或奖励状态在 154/199pt 间切换。
    private var coHereCardHeightConstraint: NSLayoutConstraint?

    /// 创建 Cell 并完成固定控件和约束初始化。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        coHereSetupView()
        coHereSetupConstraints()
    }

    /// Storyboard/XIB 初始化入口，保持与代码初始化一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView()
        coHereSetupConstraints()
    }

    /// 使用单条签到记录刷新普通或奖励卡片。
    /// - Parameters:
    ///   - model: 已转换的签到展示模型。
    ///   - isFirst: 是否为列表第一条，用于时间轴收口。
    ///   - isLast: 是否为列表最后一条，用于时间轴收口。
    func coHereConfigure(
        model: CoHereSignRecordDisplayModel,
        isFirst: Bool,
        isLast: Bool
    ) {
        let hasReward = model.rewardPoints > 0
        coHereCardHeightConstraint?.constant = hasReward ? 199 : 154
        coHereCalendarIconView.image = UIImage(
            named: hasReward ? "cohere_records_calendar_reward" : "cohere_records_calendar"
        )
        coHereDateLabel.text = model.dateText
        coHereTimeLabel.text = "\(model.timeText) \(coHereLocalized("已签到"))"
        coHereTotalPointsLabel.text = "+\(model.totalPoints)"
        coHereDailyValueLabel.text = "+\(model.dailyPoints)"
        coHereRewardValueLabel.text = hasReward ? "+\(model.rewardPoints)" : "—"
        coHereRewardValueLabel.textColor = UIColor(
            coHereRecordsHex: hasReward ? 0x7C3AED : 0xCBD5E1
        )
        coHereTotalValueLabel.text = "+\(model.totalPoints)"

        coHereStreakLabel.isHidden = !hasReward
        coHereStreakLabel.text = model.streakDays > 1
            ? "🎁 \(String(format: coHereLocalized("连签%@天"), "\(model.streakDays)"))"
            : "🎁 \(coHereLocalized("签到奖励"))"

        coHereRewardBannerView.isHidden = !hasReward
        coHereRewardTileView.layer.borderWidth = hasReward ? 1 : 0
        coHereRewardTileView.layer.borderColor = UIColor(coHereRecordsHex: 0xEDE9FE).cgColor
        coHereRewardBannerLabel.text = model.streakDays > 1
            ? "\(String(format: coHereLocalized("连签%@天"), "\(model.streakDays)")) \(String(format: coHereLocalized("奖励 +%@ 积分已到账！"), "\(model.rewardPoints)"))"
            : String(format: coHereLocalized("奖励 +%@ 积分已到账！"), "\(model.rewardPoints)")

        coHereTimelineRingView.layer.borderColor = UIColor(
            coHereRecordsHex: hasReward ? 0x5C5FF5 : 0xC7D2FE
        ).cgColor
        coHereTimelineRingView.backgroundColor = hasReward
            ? .white
            : UIColor(coHereRecordsHex: 0xEEF2FF)
        coHereTimelineDotView.backgroundColor = UIColor(
            coHereRecordsHex: hasReward ? 0x5C5FF5 : 0xC7D2FE
        )
        coHereTimelineView.isHidden = isFirst && isLast
    }

    /// 创建卡片、时间轴、积分宫格及奖励横幅。
    private func coHereSetupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        coHereTimelineView.translatesAutoresizingMaskIntoConstraints = false
        coHereTimelineView.backgroundColor = UIColor(coHereRecordsHex: 0xE0E7FF)
        contentView.addSubview(coHereTimelineView)

        coHereTimelineRingView.translatesAutoresizingMaskIntoConstraints = false
        coHereTimelineRingView.layer.cornerRadius = 10
        coHereTimelineRingView.layer.borderWidth = 2
        contentView.addSubview(coHereTimelineRingView)

        coHereTimelineDotView.translatesAutoresizingMaskIntoConstraints = false
        coHereTimelineDotView.layer.cornerRadius = 5
        coHereTimelineRingView.addSubview(coHereTimelineDotView)

        coHereCardView.translatesAutoresizingMaskIntoConstraints = false
        coHereCardView.backgroundColor = .white
        coHereCardView.layer.cornerRadius = 16
        coHereCardView.layer.shadowColor = UIColor(coHereRecordsHex: 0x5C5FF5).cgColor
        coHereCardView.layer.shadowOpacity = 0.06
        coHereCardView.layer.shadowRadius = 8
        coHereCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.addSubview(coHereCardView)

        coHereConfigureCardHeader()
        coHereConfigurePointTiles()
        coHereConfigureRewardBanner()
    }

    /// 配置记录卡片顶部日期、状态和总积分区域。
    private func coHereConfigureCardHeader() {
        coHereCalendarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        coHereCalendarBackgroundView.backgroundColor = UIColor(coHereRecordsHex: 0xEEF2FF)
        coHereCalendarBackgroundView.layer.cornerRadius = 14
        coHereCardView.addSubview(coHereCalendarBackgroundView)

        coHereCalendarIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereCalendarIconView.contentMode = .scaleAspectFit
        coHereCalendarBackgroundView.addSubview(coHereCalendarIconView)

        coHereDateLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereDateLabel.textColor = UIColor(coHereRecordsHex: 0x1E1B4B)
        coHereDateLabel.font = .systemFont(ofSize: 14, weight: .bold)
        coHereCardView.addSubview(coHereDateLabel)

        coHereStreakLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereStreakLabel.backgroundColor = UIColor(coHereRecordsHex: 0xEDE9FE)
        coHereStreakLabel.textColor = UIColor(coHereRecordsHex: 0x7C3AED)
        coHereStreakLabel.font = .systemFont(ofSize: 10, weight: .bold)
        coHereStreakLabel.textAlignment = .center
        coHereStreakLabel.layer.cornerRadius = 9.5
        coHereStreakLabel.clipsToBounds = true
        coHereCardView.addSubview(coHereStreakLabel)

        coHereTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTimeLabel.textColor = UIColor(coHereRecordsHex: 0x94A3B8)
        coHereTimeLabel.font = .systemFont(ofSize: 11, weight: .regular)
        coHereCardView.addSubview(coHereTimeLabel)

        coHereTotalPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTotalPointsLabel.textColor = UIColor(coHereRecordsHex: 0x5C5FF5)
        coHereTotalPointsLabel.font = .systemFont(ofSize: 20, weight: .heavy)
        coHereTotalPointsLabel.textAlignment = .right
        coHereCardView.addSubview(coHereTotalPointsLabel)

        coHerePointsUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        coHerePointsUnitLabel.textColor = UIColor(coHereRecordsHex: 0x94A3B8)
        coHerePointsUnitLabel.font = .systemFont(ofSize: 10, weight: .regular)
        coHerePointsUnitLabel.textAlignment = .right
        coHerePointsUnitLabel.text = coHereLocalized("积分")
        coHereCardView.addSubview(coHerePointsUnitLabel)
    }

    /// 配置三列积分明细宫格及文字样式。
    private func coHereConfigurePointTiles() {
        let tileViews = [coHereDailyTileView, coHereRewardTileView, coHereTotalTileView]
        tileViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = 14
            coHereCardView.addSubview($0)
        }
        coHereDailyTileView.backgroundColor = UIColor(coHereRecordsHex: 0xFAFAFE)
        coHereRewardTileView.backgroundColor = UIColor(coHereRecordsHex: 0xFAFAFE)
        coHereTotalTileView.backgroundColor = UIColor(coHereRecordsHex: 0xEEF2FF)

        let valueLabels = [coHereDailyValueLabel, coHereRewardValueLabel, coHereTotalValueLabel]
        valueLabels.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 14, weight: .heavy)
            $0.textAlignment = .center
        }
        coHereDailyValueLabel.textColor = UIColor(coHereRecordsHex: 0x5C5FF5)
        coHereRewardValueLabel.textColor = UIColor(coHereRecordsHex: 0x7C3AED)
        coHereTotalValueLabel.textColor = UIColor(coHereRecordsHex: 0x5C5FF5)

        let captionLabels = [
            coHereDailyCaptionLabel,
            coHereRewardCaptionLabel,
            coHereTotalCaptionLabel
        ]
        captionLabels.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = UIColor(coHereRecordsHex: 0x94A3B8)
            $0.font = .systemFont(ofSize: 10, weight: .regular)
            $0.textAlignment = .center
        }
        coHereDailyCaptionLabel.text = coHereLocalized("日签积分")
        coHereRewardCaptionLabel.text = coHereLocalized("奖励积分")
        coHereTotalCaptionLabel.text = coHereLocalized("当日合计")

        coHereAttachTileLabels(
            valueLabel: coHereDailyValueLabel,
            captionLabel: coHereDailyCaptionLabel,
            to: coHereDailyTileView
        )
        coHereAttachTileLabels(
            valueLabel: coHereRewardValueLabel,
            captionLabel: coHereRewardCaptionLabel,
            to: coHereRewardTileView
        )
        coHereAttachTileLabels(
            valueLabel: coHereTotalValueLabel,
            captionLabel: coHereTotalCaptionLabel,
            to: coHereTotalTileView
        )
    }

    /// 将数值和说明标签安装到指定积分宫格。
    /// - Parameters:
    ///   - valueLabel: 宫格顶部积分数值标签。
    ///   - captionLabel: 宫格底部字段说明标签。
    ///   - tileView: 标签所属宫格。
    private func coHereAttachTileLabels(
        valueLabel: UILabel,
        captionLabel: UILabel,
        to tileView: UIView
    ) {
        tileView.addSubview(valueLabel)
        tileView.addSubview(captionLabel)
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 9),
            valueLabel.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 1),
            valueLabel.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -1),
            valueLabel.heightAnchor.constraint(equalToConstant: 21),
            captionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            captionLabel.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 1),
            captionLabel.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -1),
            captionLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }

    /// 配置奖励记录底部的到账提示横幅。
    private func coHereConfigureRewardBanner() {
        coHereRewardBannerView.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardBannerView.backgroundColor = UIColor(coHereRecordsHex: 0xEDE9FE)
        coHereRewardBannerView.layer.cornerRadius = 14
        coHereCardView.addSubview(coHereRewardBannerView)

        coHereRewardBannerIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardBannerIconView.contentMode = .scaleAspectFit
        coHereRewardBannerView.addSubview(coHereRewardBannerIconView)

        coHereRewardBannerLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardBannerLabel.textColor = UIColor(coHereRecordsHex: 0x7C3AED)
        coHereRewardBannerLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        coHereRewardBannerLabel.adjustsFontSizeToFitWidth = true
        coHereRewardBannerLabel.minimumScaleFactor = 0.8
        coHereRewardBannerView.addSubview(coHereRewardBannerLabel)
    }

    /// 建立时间轴、卡片头部、积分宫格和奖励横幅约束。
    private func coHereSetupConstraints() {
        coHereCardHeightConstraint = coHereCardView.heightAnchor.constraint(equalToConstant: 154)
        coHereCardHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            coHereTimelineView.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            coHereTimelineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coHereTimelineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            coHereTimelineView.widthAnchor.constraint(equalToConstant: 2),

            coHereTimelineRingView.centerXAnchor.constraint(equalTo: coHereTimelineView.centerXAnchor),
            coHereTimelineRingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            coHereTimelineRingView.widthAnchor.constraint(equalToConstant: 20),
            coHereTimelineRingView.heightAnchor.constraint(equalToConstant: 20),

            coHereTimelineDotView.centerXAnchor.constraint(equalTo: coHereTimelineRingView.centerXAnchor),
            coHereTimelineDotView.centerYAnchor.constraint(equalTo: coHereTimelineRingView.centerYAnchor),
            coHereTimelineDotView.widthAnchor.constraint(equalToConstant: 10),
            coHereTimelineDotView.heightAnchor.constraint(equalToConstant: 10),

            coHereCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coHereCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 64),
            coHereCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -9),

            coHereCalendarBackgroundView.leadingAnchor.constraint(equalTo: coHereCardView.leadingAnchor, constant: 16),
            coHereCalendarBackgroundView.topAnchor.constraint(equalTo: coHereCardView.topAnchor, constant: 16),
            coHereCalendarBackgroundView.widthAnchor.constraint(equalToConstant: 36),
            coHereCalendarBackgroundView.heightAnchor.constraint(equalToConstant: 36),

            coHereCalendarIconView.centerXAnchor.constraint(equalTo: coHereCalendarBackgroundView.centerXAnchor),
            coHereCalendarIconView.centerYAnchor.constraint(equalTo: coHereCalendarBackgroundView.centerYAnchor),
            coHereCalendarIconView.widthAnchor.constraint(equalToConstant: 16),
            coHereCalendarIconView.heightAnchor.constraint(equalToConstant: 16),

            coHereDateLabel.leadingAnchor.constraint(equalTo: coHereCalendarBackgroundView.trailingAnchor, constant: 12),
            coHereDateLabel.topAnchor.constraint(equalTo: coHereCardView.topAnchor, constant: 15),
            coHereDateLabel.heightAnchor.constraint(equalToConstant: 21),

            coHereStreakLabel.leadingAnchor.constraint(equalTo: coHereDateLabel.trailingAnchor, constant: 8),
            coHereStreakLabel.centerYAnchor.constraint(equalTo: coHereDateLabel.centerYAnchor),
            coHereStreakLabel.heightAnchor.constraint(equalToConstant: 19),
            coHereStreakLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),

            coHereTimeLabel.leadingAnchor.constraint(equalTo: coHereDateLabel.leadingAnchor),
            coHereTimeLabel.topAnchor.constraint(equalTo: coHereDateLabel.bottomAnchor, constant: 4),
            coHereTimeLabel.heightAnchor.constraint(equalToConstant: 17),

            coHereTotalPointsLabel.trailingAnchor.constraint(equalTo: coHereCardView.trailingAnchor, constant: -16),
            coHereTotalPointsLabel.topAnchor.constraint(equalTo: coHereCardView.topAnchor, constant: 14),
            coHereTotalPointsLabel.heightAnchor.constraint(equalToConstant: 24),

            coHerePointsUnitLabel.trailingAnchor.constraint(equalTo: coHereTotalPointsLabel.trailingAnchor),
            coHerePointsUnitLabel.topAnchor.constraint(equalTo: coHereTotalPointsLabel.bottomAnchor),
            coHerePointsUnitLabel.heightAnchor.constraint(equalToConstant: 15),

            coHereDailyTileView.leadingAnchor.constraint(equalTo: coHereCardView.leadingAnchor, constant: 16),
            coHereDailyTileView.topAnchor.constraint(equalTo: coHereCardView.topAnchor, constant: 76),
            coHereDailyTileView.heightAnchor.constraint(equalToConstant: 58),

            coHereRewardTileView.leadingAnchor.constraint(equalTo: coHereDailyTileView.trailingAnchor, constant: 8),
            coHereRewardTileView.topAnchor.constraint(equalTo: coHereDailyTileView.topAnchor),
            coHereRewardTileView.widthAnchor.constraint(equalTo: coHereDailyTileView.widthAnchor),
            coHereRewardTileView.heightAnchor.constraint(equalTo: coHereDailyTileView.heightAnchor),

            coHereTotalTileView.leadingAnchor.constraint(equalTo: coHereRewardTileView.trailingAnchor, constant: 8),
            coHereTotalTileView.trailingAnchor.constraint(equalTo: coHereCardView.trailingAnchor, constant: -16),
            coHereTotalTileView.topAnchor.constraint(equalTo: coHereDailyTileView.topAnchor),
            coHereTotalTileView.widthAnchor.constraint(equalTo: coHereDailyTileView.widthAnchor),
            coHereTotalTileView.heightAnchor.constraint(equalTo: coHereDailyTileView.heightAnchor),

            coHereRewardBannerView.leadingAnchor.constraint(equalTo: coHereCardView.leadingAnchor, constant: 16),
            coHereRewardBannerView.trailingAnchor.constraint(equalTo: coHereCardView.trailingAnchor, constant: -16),
            coHereRewardBannerView.topAnchor.constraint(equalTo: coHereDailyTileView.bottomAnchor, constant: 8),
            coHereRewardBannerView.heightAnchor.constraint(equalToConstant: 33),

            coHereRewardBannerIconView.leadingAnchor.constraint(equalTo: coHereRewardBannerView.leadingAnchor, constant: 12),
            coHereRewardBannerIconView.centerYAnchor.constraint(equalTo: coHereRewardBannerView.centerYAnchor),
            coHereRewardBannerIconView.widthAnchor.constraint(equalToConstant: 13),
            coHereRewardBannerIconView.heightAnchor.constraint(equalToConstant: 13),

            coHereRewardBannerLabel.leadingAnchor.constraint(equalTo: coHereRewardBannerIconView.trailingAnchor, constant: 8),
            coHereRewardBannerLabel.trailingAnchor.constraint(equalTo: coHereRewardBannerView.trailingAnchor, constant: -8),
            coHereRewardBannerLabel.centerYAnchor.constraint(equalTo: coHereRewardBannerView.centerYAnchor)
        ])
    }

    /// 获取项目本地化字符串。
    /// - Parameter key: Localizable.strings 中使用的中文键。
    /// - Returns: 当前语言对应文案。
    private func coHereLocalized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}

/// Figma 月份汇总区域的紫色渐变背景。
private final class CoHereSignRecordsGradientView: UIView {

    /// 负责绘制渐变色的图层。
    private let coHereGradientLayer = CAGradientLayer()

    /// 创建渐变视图并写入 Figma 色值。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereSetupGradient()
    }

    /// Storyboard/XIB 初始化入口，保持与代码初始化一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupGradient()
    }

    /// 同步渐变图层尺寸以适配旋转和不同屏幕宽度。
    override func layoutSubviews() {
        super.layoutSubviews()
        coHereGradientLayer.frame = bounds
    }

    /// 按照 Figma 的 #5966F2 至 #7835E7 配置纵向渐变。
    private func coHereSetupGradient() {
        coHereGradientLayer.colors = [
            UIColor(coHereRecordsHex: 0x5966F2).cgColor,
            UIColor(coHereRecordsHex: 0x7835E7).cgColor
        ]
        coHereGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        coHereGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(coHereGradientLayer, at: 0)
    }
}

/// 月份汇总区域中单个 101×73pt 统计卡。
private final class CoHereSignRecordsStatView: UIView {

    /// 统计项图标。
    private let coHereIconView = UIImageView()

    /// 统计项数值。
    private let coHereValueLabel = UILabel()

    /// 统计项说明。
    private let coHereCaptionLabel = UILabel()

    /// 使用指定 Figma 图标和本地化说明创建统计卡。
    /// - Parameters:
    ///   - iconName: Assets.xcassets 中的图标名称。
    ///   - caption: Localizable.strings 中的中文键。
    init(iconName: String, caption: String) {
        super.init(frame: .zero)
        coHereSetupView(iconName: iconName, caption: caption)
    }

    /// 统计卡只支持代码创建。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereSetupView(iconName: "", caption: "")
    }

    /// 更新统计项数值。
    /// - Parameter value: 已拼接单位的展示文字。
    func coHereSetValue(_ value: String) {
        coHereValueLabel.text = value
    }

    /// 配置半透明底座、图标、数值和说明约束。
    /// - Parameters:
    ///   - iconName: Assets.xcassets 中的图标名称。
    ///   - caption: Localizable.strings 中的中文键。
    private func coHereSetupView(iconName: String, caption: String) {
        backgroundColor = UIColor.white.withAlphaComponent(0.12)
        layer.cornerRadius = 8

        coHereIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereIconView.image = UIImage(named: iconName)
        coHereIconView.contentMode = .scaleAspectFit
        addSubview(coHereIconView)

        coHereValueLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereValueLabel.textColor = .white
        coHereValueLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        addSubview(coHereValueLabel)

        coHereCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereCaptionLabel.text = NSLocalizedString(caption, comment: "")
        coHereCaptionLabel.textColor = UIColor.white.withAlphaComponent(0.45)
        coHereCaptionLabel.font = .systemFont(ofSize: 10, weight: .regular)
        addSubview(coHereCaptionLabel)

        NSLayoutConstraint.activate([
            coHereIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            coHereIconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            coHereIconView.widthAnchor.constraint(equalToConstant: 15),
            coHereIconView.heightAnchor.constraint(equalToConstant: 15),

            coHereValueLabel.leadingAnchor.constraint(equalTo: coHereIconView.trailingAnchor, constant: 6),
            coHereValueLabel.centerYAnchor.constraint(equalTo: coHereIconView.centerYAnchor),

            coHereCaptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            coHereCaptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            coHereCaptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6)
        ])
    }
}

private extension UIColor {

    /// 将 Figma 的 0xRRGGBB 色值转换为 UIKit 颜色。
    /// - Parameter coHereRecordsHex: 六位 RGB 色值。
    convenience init(coHereRecordsHex: UInt32) {
        let red = CGFloat((coHereRecordsHex >> 16) & 0xFF) / 255
        let green = CGFloat((coHereRecordsHex >> 8) & 0xFF) / 255
        let blue = CGFloat(coHereRecordsHex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
