import UIKit

/// 按照 Figma “每日签到”节点实现的 Swift 视觉层；签到接口和页面跳转由 Swift 控制器负责。
@objc(CoHereDailySignInPageView)
final class CoHereDailySignInPageView: UIView {

    // MARK: - Controller callbacks

    /// 点击返回按钮后的业务回调。
    @objc var onBackTap: (() -> Void)?

    /// 点击签到记录按钮后的业务回调。
    @objc var onRecordTap: (() -> Void)?

    /// 点击总积分区域后的业务回调。
    @objc var onPointsTap: (() -> Void)?

    /// 点击立即签到按钮后的业务回调。
    @objc var onSignInTap: (() -> Void)?

    // MARK: - Page containers

    /// 页面滚动容器，小屏设备可完整查看月历和底部提示。
    private let coHereScrollView = UIScrollView()

    /// 承载完整 375pt 设计稿内容的容器。
    private let coHereContentView = UIView()

    /// 顶部 406pt 紫色渐变区域。
    private let coHereHeroView = CoHereSignInGradientView(
        colors: [
            UIColor(coHereSignInHex: 0x5966F2),
            UIColor(coHereSignInHex: 0x7835E7)
        ],
        startPoint: CGPoint(x: 0.5, y: 0),
        endPoint: CGPoint(x: 0.5, y: 1)
    )

    /// Figma 顶部曲线和光点装饰。
    private let coHereHeroDecorationView = UIImageView(
        image: UIImage(named: "cohere_signin_hero")
    )

    /// 页面内容高度约束，会根据月历行数和设备高度更新。
    private var coHereContentHeightConstraint: NSLayoutConstraint?

    // MARK: - Navigation

    /// 返回按钮，图标来自 Figma，点击区域扩展为 44pt。
    private let coHereBackButton = UIButton(type: .custom)

    /// 页面导航标题。
    private let coHereTitleLabel = UILabel()

    /// 签到记录入口。
    private let coHereRecordButton = UIButton(type: .custom)

    // MARK: - Hero statistics

    /// 连续签到圆环。
    private let coHereStreakRingView = UIImageView(
        image: UIImage(named: "cohere_signin_ring")
    )

    /// 连续签到天数。
    private let coHereStreakCountLabel = UILabel()

    /// “天连签”说明。
    private let coHereStreakTitleLabel = UILabel()

    /// 累计签到图标。
    private let coHereTotalDaysIconView = UIImageView(
        image: UIImage(named: "cohere_signin_flame")
    )

    /// 累计签到次数。
    private let coHereTotalDaysValueLabel = UILabel()

    /// 累计签到说明。
    private let coHereTotalDaysTitleLabel = UILabel()

    /// 总积分图标。
    private let coHereTotalPointsIconView = UIImageView(
        image: UIImage(named: "cohere_signin_star")
    )

    /// 用户当前总积分。
    private let coHereTotalPointsValueLabel = UILabel()

    /// 总积分说明。
    private let coHereTotalPointsTitleLabel = UILabel()

    /// 两个统计区域之间的半透明分隔线。
    private let coHereFirstDivider = UIView()

    /// 总积分区域左侧的半透明分隔线。
    private let coHereSecondDivider = UIView()

    /// 覆盖总积分统计区域的点击按钮。
    private let coHerePointsButton = UIButton(type: .custom)

    // MARK: - Reward card

    /// Figma 半透明签到奖励卡片。
    private let coHereRewardCardView = UIView()

    /// 签到卡片的主标题。
    private let coHereRewardTitleLabel = UILabel()

    /// 今日签到状态说明。
    private let coHereRewardStatusLabel = UILabel()

    /// 今日积分前的闪电图标。
    private let coHereRewardBoltView = UIImageView(
        image: UIImage(named: "cohere_signin_bolt")
    )

    /// 今日签到可得或已得积分。
    private let coHereRewardValueLabel = UILabel()

    /// 积分单位说明。
    private let coHereRewardUnitLabel = UILabel()

    /// 立即签到按钮。
    private let coHereSignButton = UIButton(type: .custom)

    /// 奖励卡底部深色摘要区域。
    private let coHereRewardSummaryView = UIView()

    /// 奖励卡底部连签火焰图标。
    private let coHereRewardSummaryIconView = UIImageView(
        image: UIImage(named: "cohere_signin_flame_summary")
    )

    /// 本月累计签到和连续签到摘要。
    private let coHereRewardSummaryLabel = UILabel()

    // MARK: - Calendar

    /// 月份标题前的渐变奖杯底座。
    private let coHereMonthIconBackgroundView = CoHereSignInGradientView(
        colors: [
            UIColor(coHereSignInHex: 0x6366F1),
            UIColor(coHereSignInHex: 0x8B5CF6)
        ],
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 1, y: 1)
    )

    /// 月份标题奖杯图标。
    private let coHereMonthIconView = UIImageView(
        image: UIImage(named: "cohere_signin_trophy")
    )

    /// 当前年月标题。
    private let coHereMonthTitleLabel = UILabel()

    /// “已签”图例圆点。
    private let coHereSignedLegendDot = UIView()

    /// “已签”图例文字。
    private let coHereSignedLegendLabel = UILabel()

    /// “未签”图例圆点。
    private let coHereUnsignedLegendDot = UIView()

    /// “未签”图例文字。
    private let coHereUnsignedLegendLabel = UILabel()

    /// 星期标题行。
    private let coHereWeekStackView = UIStackView()

    /// 根据当前月份动态渲染签到状态的月历。
    private let coHereCalendarView = CoHereSignInCalendarView()

    /// 月历高度约束，五行和六行月份会自动调整。
    private var coHereCalendarHeightConstraint: NSLayoutConstraint?

    /// 底部次日奖励提示容器。
    private let coHereTomorrowTipView = UIView()

    /// 底部次日奖励闪电图标。
    private let coHereTomorrowTipIconView = UIImageView(
        image: UIImage(named: "cohere_signin_tip")
    )

    /// 底部次日奖励说明。
    private let coHereTomorrowTipLabel = UILabel()

    // MARK: - Display state

    /// 当前用户是否已经完成今日签到。
    private var coHereIsSignedIn = false

    /// 当前月份接口返回的已签到日期集合，元素取值为 1...31。
    private var coHereSignedDays = Set<Int>()

    /// 当前展示年份。
    private var coHereYear = Calendar.current.component(.year, from: Date())

    /// 当前展示月份，取值为 1...12。
    private var coHereMonth = Calendar.current.component(.month, from: Date())

    /// 当前月累计签到天数，用于摘要文案。
    private var coHereMonthSignedCount = "0"

    /// 创建每日签到视觉层并完成控件、约束与交互初始化。
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

    /// 根据设备高度和动态月历行数更新滚动内容高度。
    override func layoutSubviews() {
        super.layoutSubviews()
        let calendarRows = coHereCalendarView.coHereRowCount
        let calendarHeight = CGFloat(calendarRows) * 54
        coHereCalendarHeightConstraint?.constant = calendarHeight
        coHereContentHeightConstraint?.constant = max(
            bounds.height,
            514 + calendarHeight + 68
        )
    }

    /// 使用签到详情接口已有字段刷新 Figma 顶部统计和签到卡片。
    /// - Parameters:
    ///   - isSignedIn: 今日是否已签到。
    ///   - todayPoints: 今日可领取或已领取积分。
    ///   - totalSignDays: 用户累计签到天数。
    ///   - totalPoints: 用户当前总积分。
    ///   - monthSignDays: 当前月累计签到天数。
    @objc(configureWithIsSignedIn:todayPoints:totalSignDays:totalPoints:monthSignDays:)
    func coHereConfigure(
        isSignedIn: Bool,
        todayPoints: String,
        totalSignDays: String,
        totalPoints: String,
        monthSignDays: String
    ) {
        coHereIsSignedIn = isSignedIn
        coHereMonthSignedCount = monthSignDays
        coHereTotalDaysValueLabel.text = totalSignDays
        coHereTotalPointsValueLabel.text = coHereFormattedPoints(totalPoints)
        coHereRewardValueLabel.text = "+\(todayPoints)"
        coHereRewardStatusLabel.text = coHereLocalized(
            isSignedIn ? "今日签到奖励已到账" : "今日可领积分"
        )
        coHereSignButton.setTitle(
            coHereLocalized(isSignedIn ? "今日已签到" : "立即签到"),
            for: .normal
        )
        coHereSignButton.isEnabled = !isSignedIn
        coHereSignButton.alpha = isSignedIn ? 0.72 : 1
        coHereRefreshDerivedContent()
    }

    /// 使用现有签到记录生成当前月份日历，不请求新接口。
    /// - Parameters:
    ///   - signedDays: 已签到日期数组，元素取值为 1...31。
    ///   - year: 当前展示年份。
    ///   - month: 当前展示月份，取值为 1...12。
    @objc(updateCalendarWithSignedDays:year:month:)
    func coHereUpdateCalendar(
        signedDays: [NSNumber],
        year: Int,
        month: Int
    ) {
        coHereSignedDays = Set(signedDays.map(\.intValue))
        coHereYear = year
        coHereMonth = month
        coHereCalendarView.coHereConfigure(
            year: year,
            month: month,
            signedDays: coHereSignedDays
        )
        coHereMonthTitleLabel.text = String(
            format: coHereLocalized("%@年%@月"),
            "\(year)",
            "\(month)"
        )
        coHereRefreshDerivedContent()
        setNeedsLayout()
    }

    /// 创建页面全部 UIKit 控件并应用 Figma 的字体、颜色和圆角。
    private func coHereSetupView() {
        backgroundColor = .white
        clipsToBounds = true

        coHereScrollView.translatesAutoresizingMaskIntoConstraints = false
        coHereScrollView.showsVerticalScrollIndicator = false
        coHereScrollView.alwaysBounceVertical = false
        coHereScrollView.contentInsetAdjustmentBehavior = .never
        addSubview(coHereScrollView)

        coHereContentView.translatesAutoresizingMaskIntoConstraints = false
        coHereContentView.backgroundColor = .white
        coHereScrollView.addSubview(coHereContentView)

        coHereHeroView.translatesAutoresizingMaskIntoConstraints = false
        coHereContentView.addSubview(coHereHeroView)

        coHereHeroDecorationView.translatesAutoresizingMaskIntoConstraints = false
        coHereHeroDecorationView.contentMode = .scaleToFill
        coHereHeroView.addSubview(coHereHeroDecorationView)

        coHereConfigureNavigation()
        coHereConfigureStatistics()
        coHereConfigureRewardCard()
        coHereConfigureCalendar()
        coHereConfigureTomorrowTip()
    }

    /// 配置返回、标题和签到记录入口。
    private func coHereConfigureNavigation() {
        coHereBackButton.translatesAutoresizingMaskIntoConstraints = false
        coHereBackButton.setImage(
            UIImage(named: "cohere_signin_back"),
            for: .normal
        )
        coHereHeroView.addSubview(coHereBackButton)

        coHereTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTitleLabel.text = coHereLocalized("每日签到")
        coHereTitleLabel.textColor = .white
        coHereTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coHereTitleLabel.textAlignment = .center
        coHereHeroView.addSubview(coHereTitleLabel)

        coHereRecordButton.translatesAutoresizingMaskIntoConstraints = false
        coHereRecordButton.setImage(
            UIImage(named: "cohere_signin_record"),
            for: .normal
        )
        coHereRecordButton.setTitle(
            coHereLocalized("签到记录"),
            for: .normal
        )
        coHereRecordButton.setTitleColor(
            UIColor.white.withAlphaComponent(0.8),
            for: .normal
        )
        coHereRecordButton.titleLabel?.font = .systemFont(
            ofSize: 12,
            weight: .regular
        )
        coHereRecordButton.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        coHereRecordButton.layer.cornerRadius = 16
        coHereRecordButton.layer.borderWidth = 1
        coHereRecordButton.layer.borderColor = UIColor.white
            .withAlphaComponent(0.18).cgColor
        coHereRecordButton.imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -3,
            bottom: 0,
            right: 3
        )
        coHereHeroView.addSubview(coHereRecordButton)
    }

    /// 配置连签、累计签到和总积分三组顶部统计。
    private func coHereConfigureStatistics() {
        [
            coHereStreakRingView,
            coHereTotalDaysIconView,
            coHereTotalPointsIconView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFit
            coHereHeroView.addSubview($0)
        }

        coHereConfigureHeroValueLabel(coHereStreakCountLabel)
        coHereConfigureHeroValueLabel(coHereTotalDaysValueLabel)
        coHereConfigureHeroValueLabel(coHereTotalPointsValueLabel)

        coHereConfigureHeroCaptionLabel(coHereStreakTitleLabel)
        coHereConfigureHeroCaptionLabel(coHereTotalDaysTitleLabel)
        coHereConfigureHeroCaptionLabel(coHereTotalPointsTitleLabel)

        coHereStreakTitleLabel.text = coHereLocalized("天连签")
        coHereTotalDaysTitleLabel.text = coHereLocalized("累计签到")
        coHereTotalPointsTitleLabel.text = coHereLocalized("总积分")

        [
            coHereStreakCountLabel,
            coHereTotalDaysValueLabel,
            coHereTotalPointsValueLabel,
            coHereStreakTitleLabel,
            coHereTotalDaysTitleLabel,
            coHereTotalPointsTitleLabel
        ].forEach(coHereHeroView.addSubview)

        [coHereFirstDivider, coHereSecondDivider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            coHereHeroView.addSubview($0)
        }

        coHerePointsButton.translatesAutoresizingMaskIntoConstraints = false
        coHereHeroView.addSubview(coHerePointsButton)
    }

    /// 为顶部数值标签应用统一样式。
    /// - Parameter label: 需要配置的顶部数值标签。
    private func coHereConfigureHeroValueLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-"
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
    }

    /// 为顶部统计说明应用统一样式。
    /// - Parameter label: 需要配置的统计说明标签。
    private func coHereConfigureHeroCaptionLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white.withAlphaComponent(0.55)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
    }

    /// 配置 Figma 半透明签到奖励卡及其按钮。
    private func coHereConfigureRewardCard() {
        coHereRewardCardView.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardCardView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        coHereRewardCardView.layer.cornerRadius = 24
        coHereRewardCardView.layer.borderWidth = 1
        coHereRewardCardView.layer.borderColor = UIColor.white
            .withAlphaComponent(0.22).cgColor
        coHereRewardCardView.clipsToBounds = true
        coHereHeroView.addSubview(coHereRewardCardView)

        coHereRewardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardTitleLabel.text = coHereLocalized("签到领积分")
        coHereRewardTitleLabel.textColor = .white
        coHereRewardTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coHereRewardCardView.addSubview(coHereRewardTitleLabel)

        coHereRewardStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardStatusLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        coHereRewardStatusLabel.font = .systemFont(ofSize: 12, weight: .regular)
        coHereRewardCardView.addSubview(coHereRewardStatusLabel)

        coHereRewardBoltView.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardBoltView.contentMode = .scaleAspectFit
        coHereRewardCardView.addSubview(coHereRewardBoltView)

        coHereRewardValueLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardValueLabel.textColor = .white
        coHereRewardValueLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        coHereRewardCardView.addSubview(coHereRewardValueLabel)

        coHereRewardUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardUnitLabel.text = coHereLocalized("积分")
        coHereRewardUnitLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        coHereRewardUnitLabel.font = .systemFont(ofSize: 12, weight: .regular)
        coHereRewardCardView.addSubview(coHereRewardUnitLabel)

        coHereSignButton.translatesAutoresizingMaskIntoConstraints = false
        coHereSignButton.backgroundColor = .white
        coHereSignButton.setTitleColor(
            UIColor(coHereSignInHex: 0x6C63FF),
            for: .normal
        )
        coHereSignButton.titleLabel?.font = .systemFont(
            ofSize: 12,
            weight: .medium
        )
        coHereSignButton.layer.cornerRadius = 13
        coHereRewardCardView.addSubview(coHereSignButton)

        coHereRewardSummaryView.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardSummaryView.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        coHereRewardCardView.addSubview(coHereRewardSummaryView)

        coHereRewardSummaryIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardSummaryIconView.contentMode = .scaleAspectFit
        coHereRewardSummaryView.addSubview(coHereRewardSummaryIconView)

        coHereRewardSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereRewardSummaryLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        coHereRewardSummaryLabel.font = .systemFont(ofSize: 12, weight: .heavy)
        coHereRewardSummaryLabel.textAlignment = .center
        coHereRewardSummaryView.addSubview(coHereRewardSummaryLabel)
    }

    /// 配置月份标题、状态图例、星期标题和动态日历。
    private func coHereConfigureCalendar() {
        coHereMonthIconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        coHereMonthIconBackgroundView.layer.cornerRadius = 10
        coHereContentView.addSubview(coHereMonthIconBackgroundView)

        coHereMonthIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereMonthIconView.contentMode = .scaleAspectFit
        coHereMonthIconBackgroundView.addSubview(coHereMonthIconView)

        coHereMonthTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereMonthTitleLabel.textColor = UIColor(coHereSignInHex: 0x0D0E1C)
        coHereMonthTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        coHereContentView.addSubview(coHereMonthTitleLabel)

        coHereSignedLegendDot.translatesAutoresizingMaskIntoConstraints = false
        coHereSignedLegendDot.backgroundColor = UIColor(coHereSignInHex: 0x6366F1)
        coHereSignedLegendDot.layer.cornerRadius = 6
        coHereContentView.addSubview(coHereSignedLegendDot)

        coHereUnsignedLegendDot.translatesAutoresizingMaskIntoConstraints = false
        coHereUnsignedLegendDot.backgroundColor = .clear
        coHereUnsignedLegendDot.layer.cornerRadius = 6
        coHereUnsignedLegendDot.layer.borderWidth = 1
        coHereUnsignedLegendDot.layer.borderColor = UIColor(
            coHereSignInHex: 0xE5E7EB
        ).cgColor
        coHereContentView.addSubview(coHereUnsignedLegendDot)

        [coHereSignedLegendLabel, coHereUnsignedLegendLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = UIColor(coHereSignInHex: 0x9CA3AF)
            $0.font = .systemFont(ofSize: 12, weight: .regular)
            coHereContentView.addSubview($0)
        }
        coHereSignedLegendLabel.text = coHereLocalized("已签")
        coHereUnsignedLegendLabel.text = coHereLocalized("未签")

        coHereWeekStackView.translatesAutoresizingMaskIntoConstraints = false
        coHereWeekStackView.axis = .horizontal
        coHereWeekStackView.distribution = .fillEqually
        ["日", "一", "二", "三", "四", "五", "六"].enumerated().forEach {
            index,
            title in
            let label = UILabel()
            label.text = coHereLocalized(title)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = index == 0 || index == 6
                ? UIColor(coHereSignInHex: 0xF87171)
                : UIColor(coHereSignInHex: 0x9CA3AF)
            coHereWeekStackView.addArrangedSubview(label)
        }
        coHereContentView.addSubview(coHereWeekStackView)

        coHereCalendarView.translatesAutoresizingMaskIntoConstraints = false
        coHereContentView.addSubview(coHereCalendarView)
    }

    /// 配置页面底部的次日连签奖励提示。
    private func coHereConfigureTomorrowTip() {
        coHereTomorrowTipView.translatesAutoresizingMaskIntoConstraints = false
        coHereTomorrowTipView.backgroundColor = UIColor(
            coHereSignInHex: 0x6366F1,
            alpha: 0.06
        )
        coHereTomorrowTipView.layer.cornerRadius = 14
        coHereContentView.addSubview(coHereTomorrowTipView)

        coHereTomorrowTipIconView.translatesAutoresizingMaskIntoConstraints = false
        coHereTomorrowTipIconView.contentMode = .scaleAspectFit
        coHereTomorrowTipView.addSubview(coHereTomorrowTipIconView)

        coHereTomorrowTipLabel.translatesAutoresizingMaskIntoConstraints = false
        coHereTomorrowTipLabel.text = coHereLocalized(
            "明天签到，您将会获得连签奖励"
        )
        coHereTomorrowTipLabel.textColor = UIColor(coHereSignInHex: 0x6366F1)
        coHereTomorrowTipLabel.font = .systemFont(ofSize: 12, weight: .medium)
        coHereTomorrowTipLabel.adjustsFontSizeToFitWidth = true
        coHereTomorrowTipLabel.minimumScaleFactor = 0.8
        coHereTomorrowTipView.addSubview(coHereTomorrowTipLabel)
    }

    /// 按 Figma 375×812 坐标建立页面约束，并保留窄屏可滚动能力。
    private func coHereSetupConstraints() {
        coHereContentHeightConstraint = coHereContentView.heightAnchor.constraint(
            equalToConstant: 812
        )
        coHereCalendarHeightConstraint = coHereCalendarView.heightAnchor.constraint(
            equalToConstant: 270
        )

        NSLayoutConstraint.activate([
            coHereScrollView.topAnchor.constraint(equalTo: topAnchor),
            coHereScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coHereScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coHereScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            coHereContentView.topAnchor.constraint(
                equalTo: coHereScrollView.contentLayoutGuide.topAnchor
            ),
            coHereContentView.leadingAnchor.constraint(
                equalTo: coHereScrollView.contentLayoutGuide.leadingAnchor
            ),
            coHereContentView.trailingAnchor.constraint(
                equalTo: coHereScrollView.contentLayoutGuide.trailingAnchor
            ),
            coHereContentView.bottomAnchor.constraint(
                equalTo: coHereScrollView.contentLayoutGuide.bottomAnchor
            ),
            coHereContentView.widthAnchor.constraint(
                equalTo: coHereScrollView.frameLayoutGuide.widthAnchor
            ),
            coHereContentHeightConstraint!,

            coHereHeroView.topAnchor.constraint(equalTo: coHereContentView.topAnchor),
            coHereHeroView.leadingAnchor.constraint(
                equalTo: coHereContentView.leadingAnchor
            ),
            coHereHeroView.trailingAnchor.constraint(
                equalTo: coHereContentView.trailingAnchor
            ),
            coHereHeroView.heightAnchor.constraint(equalToConstant: 406),

            coHereHeroDecorationView.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor
            ),
            coHereHeroDecorationView.leadingAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor
            ),
            coHereHeroDecorationView.trailingAnchor.constraint(
                equalTo: coHereHeroView.trailingAnchor
            ),
            coHereHeroDecorationView.bottomAnchor.constraint(
                equalTo: coHereHeroView.bottomAnchor
            ),

            coHereBackButton.leadingAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor,
                constant: 8
            ),
            coHereBackButton.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 54
            ),
            coHereBackButton.widthAnchor.constraint(equalToConstant: 44),
            coHereBackButton.heightAnchor.constraint(equalToConstant: 44),

            coHereTitleLabel.centerXAnchor.constraint(
                equalTo: coHereHeroView.centerXAnchor
            ),
            coHereTitleLabel.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 64
            ),
            coHereTitleLabel.heightAnchor.constraint(equalToConstant: 24),

            coHereRecordButton.trailingAnchor.constraint(
                equalTo: coHereHeroView.trailingAnchor,
                constant: -20
            ),
            coHereRecordButton.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 60
            ),
            coHereRecordButton.widthAnchor.constraint(equalToConstant: 93),
            coHereRecordButton.heightAnchor.constraint(equalToConstant: 32),

            coHereStreakRingView.leadingAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor,
                constant: 20
            ),
            coHereStreakRingView.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 100
            ),
            coHereStreakRingView.widthAnchor.constraint(equalToConstant: 96),
            coHereStreakRingView.heightAnchor.constraint(equalToConstant: 96),

            coHereStreakCountLabel.centerXAnchor.constraint(
                equalTo: coHereStreakRingView.centerXAnchor
            ),
            coHereStreakCountLabel.topAnchor.constraint(
                equalTo: coHereStreakRingView.topAnchor,
                constant: 24
            ),
            coHereStreakTitleLabel.centerXAnchor.constraint(
                equalTo: coHereStreakRingView.centerXAnchor
            ),
            coHereStreakTitleLabel.topAnchor.constraint(
                equalTo: coHereStreakCountLabel.bottomAnchor,
                constant: 1
            ),

            coHereFirstDivider.leadingAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor,
                constant: 140
            ),
            coHereFirstDivider.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 116
            ),
            coHereFirstDivider.widthAnchor.constraint(equalToConstant: 1),
            coHereFirstDivider.heightAnchor.constraint(equalToConstant: 64),

            coHereTotalDaysIconView.leadingAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor,
                constant: 165
            ),
            coHereTotalDaysIconView.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 129
            ),
            coHereTotalDaysIconView.widthAnchor.constraint(equalToConstant: 16),
            coHereTotalDaysIconView.heightAnchor.constraint(equalToConstant: 16),
            coHereTotalDaysValueLabel.leadingAnchor.constraint(
                equalTo: coHereTotalDaysIconView.trailingAnchor,
                constant: 6
            ),
            coHereTotalDaysValueLabel.centerYAnchor.constraint(
                equalTo: coHereTotalDaysIconView.centerYAnchor
            ),
            coHereTotalDaysTitleLabel.centerXAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor,
                constant: 198
            ),
            coHereTotalDaysTitleLabel.topAnchor.constraint(
                equalTo: coHereTotalDaysIconView.bottomAnchor,
                constant: 6
            ),

            coHereSecondDivider.leadingAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor,
                constant: 233
            ),
            coHereSecondDivider.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 116
            ),
            coHereSecondDivider.widthAnchor.constraint(equalToConstant: 1),
            coHereSecondDivider.heightAnchor.constraint(equalToConstant: 64),

            coHereTotalPointsIconView.leadingAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor,
                constant: 258
            ),
            coHereTotalPointsIconView.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 129
            ),
            coHereTotalPointsIconView.widthAnchor.constraint(equalToConstant: 15),
            coHereTotalPointsIconView.heightAnchor.constraint(equalToConstant: 15),
            coHereTotalPointsValueLabel.leadingAnchor.constraint(
                equalTo: coHereTotalPointsIconView.trailingAnchor,
                constant: 6
            ),
            coHereTotalPointsValueLabel.centerYAnchor.constraint(
                equalTo: coHereTotalPointsIconView.centerYAnchor
            ),
            coHereTotalPointsTitleLabel.centerXAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor,
                constant: 303
            ),
            coHereTotalPointsTitleLabel.topAnchor.constraint(
                equalTo: coHereTotalPointsIconView.bottomAnchor,
                constant: 6
            ),
            coHerePointsButton.leadingAnchor.constraint(
                equalTo: coHereSecondDivider.trailingAnchor
            ),
            coHerePointsButton.trailingAnchor.constraint(
                equalTo: coHereHeroView.trailingAnchor
            ),
            coHerePointsButton.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 108
            ),
            coHerePointsButton.heightAnchor.constraint(equalToConstant: 88),

            coHereRewardCardView.leadingAnchor.constraint(
                equalTo: coHereHeroView.leadingAnchor,
                constant: 20
            ),
            coHereRewardCardView.trailingAnchor.constraint(
                equalTo: coHereHeroView.trailingAnchor,
                constant: -5
            ),
            coHereRewardCardView.topAnchor.constraint(
                equalTo: coHereHeroView.topAnchor,
                constant: 220
            ),
            coHereRewardCardView.heightAnchor.constraint(equalToConstant: 151),

            coHereRewardTitleLabel.leadingAnchor.constraint(
                equalTo: coHereRewardCardView.leadingAnchor,
                constant: 16
            ),
            coHereRewardTitleLabel.topAnchor.constraint(
                equalTo: coHereRewardCardView.topAnchor,
                constant: 16
            ),
            coHereRewardStatusLabel.leadingAnchor.constraint(
                equalTo: coHereRewardTitleLabel.leadingAnchor
            ),
            coHereRewardStatusLabel.topAnchor.constraint(
                equalTo: coHereRewardTitleLabel.bottomAnchor,
                constant: 1
            ),

            coHereRewardBoltView.leadingAnchor.constraint(
                equalTo: coHereRewardTitleLabel.leadingAnchor
            ),
            coHereRewardBoltView.topAnchor.constraint(
                equalTo: coHereRewardCardView.topAnchor,
                constant: 75
            ),
            coHereRewardBoltView.widthAnchor.constraint(equalToConstant: 14),
            coHereRewardBoltView.heightAnchor.constraint(equalToConstant: 14),
            coHereRewardValueLabel.leadingAnchor.constraint(
                equalTo: coHereRewardBoltView.trailingAnchor,
                constant: 6
            ),
            coHereRewardValueLabel.centerYAnchor.constraint(
                equalTo: coHereRewardBoltView.centerYAnchor
            ),
            coHereRewardUnitLabel.leadingAnchor.constraint(
                equalTo: coHereRewardValueLabel.trailingAnchor,
                constant: 6
            ),
            coHereRewardUnitLabel.centerYAnchor.constraint(
                equalTo: coHereRewardBoltView.centerYAnchor
            ),

            coHereSignButton.trailingAnchor.constraint(
                equalTo: coHereRewardCardView.trailingAnchor,
                constant: -16
            ),
            coHereSignButton.topAnchor.constraint(
                equalTo: coHereRewardCardView.topAnchor,
                constant: 45
            ),
            coHereSignButton.widthAnchor.constraint(equalToConstant: 78),
            coHereSignButton.heightAnchor.constraint(equalToConstant: 26),

            coHereRewardSummaryView.leadingAnchor.constraint(
                equalTo: coHereRewardCardView.leadingAnchor
            ),
            coHereRewardSummaryView.trailingAnchor.constraint(
                equalTo: coHereRewardCardView.trailingAnchor
            ),
            coHereRewardSummaryView.bottomAnchor.constraint(
                equalTo: coHereRewardCardView.bottomAnchor
            ),
            coHereRewardSummaryView.heightAnchor.constraint(equalToConstant: 36),
            coHereRewardSummaryIconView.leadingAnchor.constraint(
                greaterThanOrEqualTo: coHereRewardSummaryView.leadingAnchor,
                constant: 16
            ),
            coHereRewardSummaryIconView.centerYAnchor.constraint(
                equalTo: coHereRewardSummaryView.centerYAnchor
            ),
            coHereRewardSummaryIconView.widthAnchor.constraint(equalToConstant: 13),
            coHereRewardSummaryIconView.heightAnchor.constraint(equalToConstant: 13),
            coHereRewardSummaryLabel.leadingAnchor.constraint(
                equalTo: coHereRewardSummaryIconView.trailingAnchor,
                constant: 8
            ),
            coHereRewardSummaryLabel.centerYAnchor.constraint(
                equalTo: coHereRewardSummaryView.centerYAnchor
            ),
            coHereRewardSummaryLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: coHereRewardSummaryView.trailingAnchor,
                constant: -16
            ),
            coHereRewardSummaryLabel.centerXAnchor.constraint(
                equalTo: coHereRewardSummaryView.centerXAnchor,
                constant: 10
            ),

            coHereMonthIconBackgroundView.leadingAnchor.constraint(
                equalTo: coHereContentView.leadingAnchor,
                constant: 28
            ),
            coHereMonthIconBackgroundView.topAnchor.constraint(
                equalTo: coHereContentView.topAnchor,
                constant: 420
            ),
            coHereMonthIconBackgroundView.widthAnchor.constraint(equalToConstant: 28),
            coHereMonthIconBackgroundView.heightAnchor.constraint(equalToConstant: 28),
            coHereMonthIconView.centerXAnchor.constraint(
                equalTo: coHereMonthIconBackgroundView.centerXAnchor
            ),
            coHereMonthIconView.centerYAnchor.constraint(
                equalTo: coHereMonthIconBackgroundView.centerYAnchor
            ),
            coHereMonthIconView.widthAnchor.constraint(equalToConstant: 14),
            coHereMonthIconView.heightAnchor.constraint(equalToConstant: 14),
            coHereMonthTitleLabel.leadingAnchor.constraint(
                equalTo: coHereMonthIconBackgroundView.trailingAnchor,
                constant: 8
            ),
            coHereMonthTitleLabel.centerYAnchor.constraint(
                equalTo: coHereMonthIconBackgroundView.centerYAnchor
            ),

            coHereUnsignedLegendLabel.trailingAnchor.constraint(
                equalTo: coHereContentView.trailingAnchor,
                constant: -28
            ),
            coHereUnsignedLegendLabel.centerYAnchor.constraint(
                equalTo: coHereMonthIconBackgroundView.centerYAnchor
            ),
            coHereUnsignedLegendDot.trailingAnchor.constraint(
                equalTo: coHereUnsignedLegendLabel.leadingAnchor,
                constant: -4
            ),
            coHereUnsignedLegendDot.centerYAnchor.constraint(
                equalTo: coHereUnsignedLegendLabel.centerYAnchor
            ),
            coHereUnsignedLegendDot.widthAnchor.constraint(equalToConstant: 12),
            coHereUnsignedLegendDot.heightAnchor.constraint(equalToConstant: 12),
            coHereSignedLegendLabel.trailingAnchor.constraint(
                equalTo: coHereUnsignedLegendDot.leadingAnchor,
                constant: -8
            ),
            coHereSignedLegendLabel.centerYAnchor.constraint(
                equalTo: coHereUnsignedLegendLabel.centerYAnchor
            ),
            coHereSignedLegendDot.trailingAnchor.constraint(
                equalTo: coHereSignedLegendLabel.leadingAnchor,
                constant: -4
            ),
            coHereSignedLegendDot.centerYAnchor.constraint(
                equalTo: coHereSignedLegendLabel.centerYAnchor
            ),
            coHereSignedLegendDot.widthAnchor.constraint(equalToConstant: 12),
            coHereSignedLegendDot.heightAnchor.constraint(equalToConstant: 12),

            coHereWeekStackView.leadingAnchor.constraint(
                equalTo: coHereContentView.leadingAnchor,
                constant: 28
            ),
            coHereWeekStackView.trailingAnchor.constraint(
                equalTo: coHereContentView.trailingAnchor,
                constant: -29
            ),
            coHereWeekStackView.topAnchor.constraint(
                equalTo: coHereContentView.topAnchor,
                constant: 456
            ),
            coHereWeekStackView.heightAnchor.constraint(equalToConstant: 25),

            coHereCalendarView.leadingAnchor.constraint(
                equalTo: coHereWeekStackView.leadingAnchor
            ),
            coHereCalendarView.trailingAnchor.constraint(
                equalTo: coHereWeekStackView.trailingAnchor
            ),
            coHereCalendarView.topAnchor.constraint(
                equalTo: coHereWeekStackView.bottomAnchor,
                constant: 3
            ),
            coHereCalendarHeightConstraint!,

            coHereTomorrowTipView.leadingAnchor.constraint(
                equalTo: coHereContentView.leadingAnchor,
                constant: 28
            ),
            coHereTomorrowTipView.trailingAnchor.constraint(
                equalTo: coHereContentView.trailingAnchor,
                constant: -29
            ),
            coHereTomorrowTipView.topAnchor.constraint(
                equalTo: coHereCalendarView.bottomAnchor,
                constant: 16
            ),
            coHereTomorrowTipView.heightAnchor.constraint(equalToConstant: 42),
            coHereTomorrowTipIconView.leadingAnchor.constraint(
                equalTo: coHereTomorrowTipView.leadingAnchor,
                constant: 12
            ),
            coHereTomorrowTipIconView.centerYAnchor.constraint(
                equalTo: coHereTomorrowTipView.centerYAnchor
            ),
            coHereTomorrowTipIconView.widthAnchor.constraint(equalToConstant: 14),
            coHereTomorrowTipIconView.heightAnchor.constraint(equalToConstant: 14),
            coHereTomorrowTipLabel.leadingAnchor.constraint(
                equalTo: coHereTomorrowTipIconView.trailingAnchor,
                constant: 8
            ),
            coHereTomorrowTipLabel.trailingAnchor.constraint(
                equalTo: coHereTomorrowTipView.trailingAnchor,
                constant: -12
            ),
            coHereTomorrowTipLabel.centerYAnchor.constraint(
                equalTo: coHereTomorrowTipView.centerYAnchor
            )
        ])
    }

    /// 绑定纯视觉按钮到 Swift 控制器提供的原业务回调。
    private func coHereBindActions() {
        coHereBackButton.addTarget(
            self,
            action: #selector(coHereBackButtonTapped),
            for: .touchUpInside
        )
        coHereRecordButton.addTarget(
            self,
            action: #selector(coHereRecordButtonTapped),
            for: .touchUpInside
        )
        coHerePointsButton.addTarget(
            self,
            action: #selector(coHerePointsButtonTapped),
            for: .touchUpInside
        )
        coHereSignButton.addTarget(
            self,
            action: #selector(coHereSignButtonTapped),
            for: .touchUpInside
        )
    }

    /// 设置接口返回前的安全占位内容和当前月份。
    private func coHereApplyInitialContent() {
        coHereConfigure(
            isSignedIn: false,
            todayPoints: "--",
            totalSignDays: "-",
            totalPoints: "-",
            monthSignDays: "0"
        )
        let components = Calendar.current.dateComponents(
            [.year, .month],
            from: Date()
        )
        coHereUpdateCalendar(
            signedDays: [],
            year: components.year ?? coHereYear,
            month: components.month ?? coHereMonth
        )
    }

    /// 根据已签到日期计算当前月连续签到天数并刷新摘要。
    private func coHereRefreshDerivedContent() {
        let continuousDays = coHereContinuousSignInDays()
        coHereStreakCountLabel.text = "\(continuousDays)"
        coHereRewardSummaryLabel.text = String(
            format: coHereLocalized("本月已累计签到%@天 · 连续签到%@天"),
            coHereMonthSignedCount,
            "\(continuousDays)"
        )
    }

    /// 仅根据当前月已有签到记录计算连续天数，不推测跨月数据。
    /// - Returns: 从今天或昨天开始向前连续出现的签到天数。
    private func coHereContinuousSignInDays() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        guard coHereYear == currentYear, coHereMonth == currentMonth else {
            return 0
        }

        let today = calendar.component(.day, from: now)
        var cursor = coHereSignedDays.contains(today) ? today : today - 1
        var count = 0
        while cursor > 0, coHereSignedDays.contains(cursor) {
            count += 1
            cursor -= 1
        }
        return count
    }

    /// 为积分数值添加千位分隔符，无法解析时保留接口原值。
    /// - Parameter value: 接口返回的积分文本。
    /// - Returns: 本地化千位分隔后的积分文本。
    private func coHereFormattedPoints(_ value: String) -> String {
        guard let number = Int64(value) else {
            return value
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? value
    }

    /// 使用项目现有语言管理器匹配文案。
    /// - Parameter key: 简体中文本地化键。
    /// - Returns: 当前应用语言对应的文案。
    private func coHereLocalized(_ key: String) -> String {
        NoaLanguageManager.share().matchLocalLanguage(key)
    }

    /// 转发返回点击事件。
    @objc private func coHereBackButtonTapped() {
        onBackTap?()
    }

    /// 转发签到记录点击事件。
    @objc private func coHereRecordButtonTapped() {
        onRecordTap?()
    }

    /// 转发总积分点击事件。
    @objc private func coHerePointsButtonTapped() {
        onPointsTap?()
    }

    /// 转发签到点击事件；已签到状态下按钮本身不可用。
    @objc private func coHereSignButtonTapped() {
        onSignInTap?()
    }
}

/// 展示 Figma 线性渐变背景的轻量 UIView。
private final class CoHereSignInGradientView: UIView {

    /// 渐变图层，颜色和方向在初始化时固定。
    private let coHereGradientLayer = CAGradientLayer()

    /// 创建指定颜色和方向的渐变视图。
    /// - Parameters:
    ///   - colors: 渐变颜色数组。
    ///   - startPoint: 渐变起点。
    ///   - endPoint: 渐变终点。
    init(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        super.init(frame: .zero)
        coHereGradientLayer.colors = colors.map(\.cgColor)
        coHereGradientLayer.startPoint = startPoint
        coHereGradientLayer.endPoint = endPoint
        layer.insertSublayer(coHereGradientLayer, at: 0)
    }

    /// Storyboard 初始化不适用于需要显式渐变参数的内部视图。
    required init?(coder: NSCoder) {
        nil
    }

    /// 让渐变图层始终覆盖当前视图边界。
    override func layoutSubviews() {
        super.layoutSubviews()
        coHereGradientLayer.frame = bounds
        coHereGradientLayer.cornerRadius = layer.cornerRadius
    }

    /// 更新渐变颜色，用于月历日期格在普通、已签和今日状态间复用。
    /// - Parameter colors: 新的渐变颜色数组。
    func coHereUpdateColors(_ colors: [UIColor]) {
        coHereGradientLayer.colors = colors.map(\.cgColor)
    }
}

/// 按当前年月和签到日期渲染七列月历。
private final class CoHereSignInCalendarView: UIView {

    /// 最多 42 个日期格，覆盖所有可能的六行月份。
    private let coHereDayViews = (0..<42).map { _ in CoHereSignInDayView() }

    /// 当前实际需要展示的月历行数，取值为 4...6。
    private(set) var coHereRowCount = 5

    /// 创建日期格并加入月历容器。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereDayViews.forEach(addSubview)
    }

    /// Storyboard/XIB 初始化入口，与代码初始化保持一致。
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        coHereDayViews.forEach(addSubview)
    }

    /// 按七列、每行 54pt 布局日期格。
    override func layoutSubviews() {
        super.layoutSubviews()
        let itemWidth = bounds.width / 7
        for (index, dayView) in coHereDayViews.enumerated() {
            dayView.frame = CGRect(
                x: CGFloat(index % 7) * itemWidth,
                y: CGFloat(index / 7) * 54,
                width: itemWidth,
                height: 54
            )
        }
    }

    /// 生成指定年月的日期和签到视觉状态。
    /// - Parameters:
    ///   - year: 展示年份。
    ///   - month: 展示月份，取值为 1...12。
    ///   - signedDays: 已签到日期集合。
    func coHereConfigure(year: Int, month: Int, signedDays: Set<Int>) {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.year = year
        components.month = month
        components.day = 1
        guard
            let firstDate = components.date,
            let dayRange = Calendar.current.range(
                of: .day,
                in: .month,
                for: firstDate
            )
        else {
            return
        }

        let weekday = Calendar.current.component(.weekday, from: firstDate) - 1
        let occupiedCount = weekday + dayRange.count
        coHereRowCount = max(4, Int(ceil(Double(occupiedCount) / 7.0)))

        let now = Date()
        let currentYear = Calendar.current.component(.year, from: now)
        let currentMonth = Calendar.current.component(.month, from: now)
        let today = Calendar.current.component(.day, from: now)
        let isCurrentMonth = year == currentYear && month == currentMonth

        coHereDayViews.enumerated().forEach { index, dayView in
            let day = index - weekday + 1
            guard day > 0, day <= dayRange.count, index < coHereRowCount * 7 else {
                dayView.coHereConfigure(day: nil, state: .empty)
                return
            }

            let state: CoHereSignInDayState
            if isCurrentMonth, day == today {
                state = signedDays.contains(day) ? .todaySigned : .todayUnsigned
            } else if signedDays.contains(day) {
                state = .signed
            } else if isCurrentMonth, day > today {
                state = .future
            } else {
                state = .unsigned
            }
            dayView.coHereConfigure(day: day, state: state)
        }
    }
}

/// 单个日期格的展示状态。
private enum CoHereSignInDayState {
    case empty
    case unsigned
    case signed
    case todayUnsigned
    case todaySigned
    case future
}

/// 月历中的单个日期格，负责数字、签到勾选、圆点和今日渐变状态。
private final class CoHereSignInDayView: UIView {

    /// 日期或签到勾选的圆形背景。
    private let coHereCircleView = CoHereSignInGradientView(
        colors: [.clear, .clear],
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 1, y: 1)
    )

    /// 日期数字。
    private let coHereDayLabel = UILabel()

    /// 已签到日期使用的 Figma 勾选图标。
    private let coHereCheckView = UIImageView(
        image: UIImage(named: "cohere_signin_check")
    )

    /// 已签到日期圆形下方的紫色状态点。
    private let coHereDotView = UIView()

    /// 创建日期格并设置固定的内部控件。
    override init(frame: CGRect) {
        super.init(frame: frame)
        coHereCircleView.isUserInteractionEnabled = false
        addSubview(coHereCircleView)

        coHereDayLabel.textAlignment = .center
        coHereDayLabel.font = .systemFont(ofSize: 14, weight: .heavy)
        coHereCircleView.addSubview(coHereDayLabel)

        coHereCheckView.contentMode = .scaleAspectFit
        coHereCircleView.addSubview(coHereCheckView)

        coHereDotView.backgroundColor = UIColor(coHereSignInHex: 0xA5B4FC)
        coHereDotView.layer.cornerRadius = 2
        addSubview(coHereDotView)
    }

    /// Storyboard/XIB 不用于内部动态日期格。
    required init?(coder: NSCoder) {
        nil
    }

    /// 将圆形、数字、勾选和状态点放置在 Figma 对应位置。
    override func layoutSubviews() {
        super.layoutSubviews()
        coHereCircleView.frame = CGRect(
            x: (bounds.width - 36) / 2,
            y: 4,
            width: 36,
            height: 36
        )
        coHereCircleView.layer.cornerRadius = 18
        coHereDayLabel.frame = coHereCircleView.bounds
        coHereCheckView.frame = CGRect(x: 11, y: 11, width: 14, height: 14)
        coHereDotView.frame = CGRect(
            x: (bounds.width - 4) / 2,
            y: 44,
            width: 4,
            height: 4
        )
    }

    /// 根据日期状态应用 Figma 的颜色、勾选和今日高亮。
    /// - Parameters:
    ///   - day: 日期数字；为空时隐藏日期格。
    ///   - state: 当前日期视觉状态。
    func coHereConfigure(day: Int?, state: CoHereSignInDayState) {
        isHidden = state == .empty
        guard let day else {
            return
        }

        coHereDayLabel.text = "\(day)"
        coHereDayLabel.isHidden = false
        coHereCheckView.isHidden = true
        coHereDotView.isHidden = true
        coHereCircleView.backgroundColor = .clear
        coHereCircleView.coHereUpdateColors([.clear, .clear])
        coHereCircleView.layer.borderWidth = 0
        coHereCircleView.layer.shadowOpacity = 0
        coHereDayLabel.textColor = UIColor(coHereSignInHex: 0x374151)

        switch state {
        case .signed:
            coHereCircleView.backgroundColor = UIColor(
                coHereSignInHex: 0x6366F1,
                alpha: 0.1
            )
            coHereDayLabel.isHidden = true
            coHereCheckView.isHidden = false
            coHereDotView.isHidden = false
        case .todayUnsigned, .todaySigned:
            coHereCircleView.coHereUpdateColors([
                UIColor(coHereSignInHex: 0x6366F1),
                UIColor(coHereSignInHex: 0x8B5CF6)
            ])
            coHereCircleView.layer.shadowColor = UIColor(
                coHereSignInHex: 0x6366F1
            ).cgColor
            coHereCircleView.layer.shadowOpacity = 0.45
            coHereCircleView.layer.shadowRadius = 7
            coHereCircleView.layer.shadowOffset = CGSize(width: 0, height: 4)
            coHereDayLabel.textColor = .white
        case .future:
            coHereDayLabel.textColor = UIColor(coHereSignInHex: 0xD1D5DB)
        case .unsigned:
            coHereDayLabel.textColor = UIColor(coHereSignInHex: 0x374151)
        case .empty:
            break
        }
    }
}

private extension UIColor {

    /// 使用十六进制 RGB 和透明度创建签到页面颜色。
    /// - Parameters:
    ///   - hex: 0xRRGGBB 格式颜色。
    ///   - alpha: 透明度，默认完全不透明。
    convenience init(coHereSignInHex hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
