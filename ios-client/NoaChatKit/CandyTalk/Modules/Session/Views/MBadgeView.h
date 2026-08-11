//
//  MBadgeView.m
//  MUIKit
//
//  Created by 郑开 on 2024/4/1.
//


#import <UIKit/UIKit.h>


@interface MBadgeView : UIView

//角标颜色，默认红色
@property (nonatomic, strong) UIColor *badgeCorlor;

//默认白字，字体14，角标大小自动适应字体大小
@property (nonatomic, strong) UILabel *textLb;

//是否需要消失特效，爆炸特效 默认YES
@property (nonatomic) BOOL needDisappearEffects;

//大圆脱离小圆的最大距离 默认100
@property (nonatomic, assign) CGFloat maxDistance;

//拖动清除回调（设置了这个才会有拖动效果）
@property (nonatomic, copy) void(^clearBlock)(void);

//点击回调
@property (nonatomic, copy) void(^tapBlock)(void);

-(void)setBadge:(NSInteger)badge;

-(void)setBadgeText:(NSString *)badge;


@end
