#import "NoaLoginBaseBlurView.h"

// MARK: - 圆角设置
#define BLUR_VIEW_CORNER_RADIUS 30.0f           // blurView 圆角半径
#define INNER_SHADOW_CORNER_RADIUS 30.0f        // 内阴影圆角半径（通常与blurView相同）

// MARK: - 内阴影设置
#define INNER_SHADOW_HEIGHT 2.0f                // 内阴影高度 (Y=2)

@interface NoaLoginBaseBlurView ()

/// 高斯模糊
@property (nonatomic, strong) UIVisualEffectView *blurView;

/// 渐变背景层
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

/// 视图上方切线圆角
@property (nonatomic, strong) CAShapeLayer *innerShadowLayer;

/// 是否是悬浮弹窗
@property (nonatomic, assign, readwrite) BOOL isPopWindows;

@end

@implementation NoaLoginBaseBlurView

- (instancetype)initWithFrame:(CGRect)frame
                 IsPopWindows:(BOOL)isPopWindows {
    self = [super initWithFrame:frame];
    if (self) {
        self.isPopWindows = isPopWindows;
        [self setupBaseView];
    }
    return self;
}

- (void)setupBaseView {
    // 确保视图背景透明，让父视图的背景图片（箭头）能够透过来
    self.backgroundColor = UIColor.clearColor;
    self.clipsToBounds = NO;  // 不裁剪内容，允许父视图背景显示
    
    // 使用模糊效果（根据当前主题选择）
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[self blurEffectStyleForCurrentTheme]];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = self.bounds;
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // 根据主题设置透明度：暗黑模式保持高透明度以确保毛玻璃效果明显，浅色模式可以稍低
    self.blurView.alpha = [self blurViewAlphaForCurrentTheme];
    
    // 设置圆角
    if (self.isPopWindows) {
        self.blurView.layer.cornerRadius = BLUR_VIEW_CORNER_RADIUS;
        self.blurView.layer.masksToBounds = YES;
    }else {
        self.blurView.layer.cornerRadius = BLUR_VIEW_CORNER_RADIUS;
        self.blurView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        self.blurView.layer.masksToBounds = YES;
    }
    
    [self addSubview:self.blurView];
    
    // 添加渐变背景层
    [self setupGradientLayer];
    
    // 添加内阴影
    [self addInnerShadow];
    
    // 注册主题变化监听
    [self styleChange];
}

/// 添加渐变背景层
- (void)setupGradientLayer {
    // 创建渐变层
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    
    // 根据当前主题设置渐变颜色和位置
    [self updateGradientForCurrentTheme];
    
    // 设置渐变方向（垂直方向，从上到下）
    self.gradientLayer.startPoint = CGPointMake(0.5, 0.0);  // 从上开始
    self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);    // 到下结束
    
    // 设置圆角遮罩（只有上边两个圆角）
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(BLUR_VIEW_CORNER_RADIUS, BLUR_VIEW_CORNER_RADIUS)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.gradientLayer.mask = maskLayer;
    
    // 将渐变层添加到 blurView.contentView 内部，作为 tint 层
    // 这样渐变层会与模糊效果混合，背景会透过模糊视图显示
    [self.blurView.contentView.layer insertSublayer:self.gradientLayer atIndex:0];
    // 确保渐变层在底层
    self.gradientLayer.zPosition = 0;
}

/// 添加内阴影
- (void)addInnerShadow {
    // 移除旧的阴影层
    if (self.innerShadowLayer) {
        [self.innerShadowLayer removeFromSuperlayer];
    }
    
    // 创建内阴影层
    self.innerShadowLayer = [CAShapeLayer layer];
    self.innerShadowLayer.frame = self.bounds;
    
    // 创建内阴影路径
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    
    // 创建一个完整的圆角矩形路径（与blurView相同）
    UIBezierPath *fullPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(INNER_SHADOW_CORNER_RADIUS, INNER_SHADOW_CORNER_RADIUS)];
    
    // 创建一个稍小的内部路径，用于创建内阴影效果
    CGRect innerRect = CGRectMake(0, INNER_SHADOW_HEIGHT, viewWidth, viewHeight - INNER_SHADOW_HEIGHT);
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRoundedRect:innerRect
                                                    byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                          cornerRadii:CGSizeMake(INNER_SHADOW_CORNER_RADIUS, INNER_SHADOW_CORNER_RADIUS)];
    
    // 将两个路径组合
    [fullPath appendPath:innerPath];
    
    self.innerShadowLayer.path = fullPath.CGPath;
    self.innerShadowLayer.fillRule = kCAFillRuleEvenOdd;
    
    // 设置纯色填充
    BOOL isDarkMode = ([TKThemeManager config].themeIndex != 0);
    if (isDarkMode) {
        self.innerShadowLayer.fillColor = [COLORWHITE colorWithAlphaComponent:0.2].CGColor;
    }else {
        self.innerShadowLayer.fillColor = [COLORWHITE colorWithAlphaComponent:1.0].CGColor;
    }
    
    // 将阴影层添加到self.layer上，不受blurView透明度影响
    [self.layer addSublayer:self.innerShadowLayer];
    // 设置zPosition确保内阴影层在最上层（高于模糊视图）
    self.innerShadowLayer.zPosition = 1000;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 更新blurView的frame
    self.blurView.frame = self.bounds;
    
    // 更新渐变层的frame和遮罩
    if (self.gradientLayer) {
        self.gradientLayer.frame = self.bounds;
        // 更新圆角遮罩
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(BLUR_VIEW_CORNER_RADIUS, BLUR_VIEW_CORNER_RADIUS)];
        CAShapeLayer *maskLayer = (CAShapeLayer *)self.gradientLayer.mask;
        if (!maskLayer) {
            maskLayer = [CAShapeLayer layer];
            self.gradientLayer.mask = maskLayer;
        }
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
    }
    
    // 更新阴影层
    [self updateInnerShadowLayer];
}

- (void)updateInnerShadowLayer {
    if (!self.innerShadowLayer) {
        return;
    }
    
    self.innerShadowLayer.frame = self.bounds;
    
    // 重新创建路径
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    
    UIBezierPath *fullPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(INNER_SHADOW_CORNER_RADIUS, INNER_SHADOW_CORNER_RADIUS)];
    
    CGRect innerRect = CGRectMake(0, INNER_SHADOW_HEIGHT, viewWidth, viewHeight - INNER_SHADOW_HEIGHT);
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRoundedRect:innerRect
                                                    byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                          cornerRadii:CGSizeMake(INNER_SHADOW_CORNER_RADIUS, INNER_SHADOW_CORNER_RADIUS)];
    
    [fullPath appendPath:innerPath];
    self.innerShadowLayer.path = fullPath.CGPath;
}

/// 更新渐变色
- (void)updateGradientForCurrentTheme {
    if (!self.gradientLayer) {
        return;
    }
    
    BOOL isDarkMode = ([TKThemeManager config].themeIndex != 0);
    
    if (isDarkMode) {
        // 暗黑模式渐变：linear-gradient(180deg, rgba(39, 41, 46, 0.7) 4.88%, #27292E 17.03%, rgba(39, 41, 46, 0.6) 100%)
        // RGB(39, 41, 46) = #27292E
        // 严格按照设计稿的颜色值，通过 gradientLayer.opacity 控制整体透明度让背景透过来
        NSArray *colors = @[
            (id)[UIColor colorWithRed:39.0/255.0 green:41.0/255.0 blue:46.0/255.0 alpha:0.7].CGColor,  // rgba(39,41,46,0.7) 4.88%
            (id)[UIColor colorWithRed:39.0/255.0 green:41.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor,  // #27292E 17.03%
            (id)[UIColor colorWithRed:39.0/255.0 green:41.0/255.0 blue:46.0/255.0 alpha:0.6].CGColor   // rgba(39,41,46,0.6) 100%
        ];
        self.gradientLayer.colors = colors;
        self.gradientLayer.locations = @[@0.0488, @0.1703, @1.0];
        // 通过降低渐变层整体透明度，让背景能透过显示，同时保持设计图的颜色
        self.gradientLayer.opacity = 0.3;
    } else {
        if (self.isPopWindows) {
            // 悬浮弹窗正常模式不使用渐变色
            NSArray *colors = @[
                (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor,  // rgba(255,255,255,1) 0%
                (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor   // rgba(255,255,255,0) 100%
            ];
            self.gradientLayer.colors = colors;
            self.gradientLayer.locations = @[@0.0, @1.0];
            self.gradientLayer.opacity = 1.0;
        }else {
            // 浅色模式渐变：linear-gradient(180deg, rgba(255,255,255,0.4) 0%, #FFFFFF 7.82%, #FFFFFF 22.7%, rgba(255,255,255,0.4) 56.21%, rgba(255,255,255,0) 100%)
            // 严格按照设计稿的颜色值
            // 由于渐变层现在在 blurView 外部作为 overlay，背景会透过模糊视图显示
            NSArray *colors = @[
                (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4].CGColor,  // rgba(255,255,255,0.4) 0%
                (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor,  // #FFFFFF 7.82%
                (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor,  // #FFFFFF 22.7%
                (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4].CGColor,  // rgba(255,255,255,0.4) 56.21%
                (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0].CGColor   // rgba(255,255,255,0) 100%
            ];
            self.gradientLayer.colors = colors;
            self.gradientLayer.locations = @[@0.0, @0.0782, @0.227, @0.5621, @1.0];
            // 提高渐变层透明度，保持设计图的颜色明显
            // 背景会通过降低 blurView.alpha 来透过显示
            self.gradientLayer.opacity = 0.8;
        }
    }
}

#pragma mark - 暗黑模式支持
- (void)styleChange {
    @weakify(self)
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        @strongify(self)
        // 主题变化，更新模糊高斯效果
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[self blurEffectStyleForCurrentTheme]];
        self.blurView.effect = blurEffect;
        
        // 更新模糊视图透明度（暗黑模式需要更高的透明度以确保毛玻璃效果明显）
        self.blurView.alpha = [self blurViewAlphaForCurrentTheme];
        
        if (themeIndex == 1) {
            self.innerShadowLayer.fillColor = [COLORWHITE colorWithAlphaComponent:0.2].CGColor;
        }else {
            self.innerShadowLayer.fillColor = [COLORWHITE colorWithAlphaComponent:1.0].CGColor;
        }
        
        // 更新渐变色效果
        [self updateGradientForCurrentTheme];
    };
}

/// 根据暗黑模式获取当前高斯模糊样式
- (UIBlurEffectStyle)blurEffectStyleForCurrentTheme {
    BOOL isDarkMode = ([TKThemeManager config].themeIndex != 0);
    if (isDarkMode) {
        // 暗黑模式：使用更强的模糊样式以确保毛玻璃效果明显（模拟模糊度17）
        // UIBlurEffectStyleDark 或 UIBlurEffectStyleProminent 都可以，但 Dark 更重
        return UIBlurEffectStyleDark;
    } else {
        // 浅色模式：使用最薄的浅色模糊样式（模拟模糊度2）
        return UIBlurEffectStyleSystemUltraThinMaterialLight;
    }
}

/// 根据主题获取模糊视图的透明度
- (CGFloat)blurViewAlphaForCurrentTheme {
    BOOL isDarkMode = ([TKThemeManager config].themeIndex != 0);
    if (isDarkMode) {
        // 暗黑模式：保持高透明度（0.95）以确保模糊效果明显，背景通过渐变层的极低透明度来显示
        return 0.9;
    } else {
        if (self.isPopWindows) {
            // 悬浮弹窗，在正常模式，无需透视
            return 1.0;
        }
        // 浅色模式：适度降低透明度，让背景能透过显示，同时保持足够的模糊效果
        // 配合渐变层 opacity = 0.8，可以在保持颜色明显的同时让背景透过来
        return 0.7;
    }
}

/// MARK: 根据文本计算长度
- (CGFloat)calculateButtonWidthForText:(NSString *)text font:(UIFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize size = [text sizeWithAttributes:attributes];
    CGFloat textWidth = size.width + 35; // 左右各16的内边距,多余出来一点
    return textWidth;
}


@end
