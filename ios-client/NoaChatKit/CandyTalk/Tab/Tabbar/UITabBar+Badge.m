//
//  UITabBar+Badge.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import "UITabBar+Badge.h"
#import "MBadgeView.h"

#define TabbarItemNums 3.0    //tabbar的数量

@class UITabBarButton;

/// 不再使用 KVC 访问私有 `_imageView`（新系统会 `valueForUndefinedKey:` 崩溃），改为在子树中查找展示图标的 `UIImageView`。
static UIImageView *Noa_tabBarButtonIconImageView(UIView *tabBarButton) {
    if (!tabBarButton) {
        return nil;
    }
    UIImageView *bestWithoutImage = nil;
    CGFloat bestArea = 0;
    NSMutableArray<UIView *> *stack = [NSMutableArray arrayWithObject:tabBarButton];
    while (stack.count > 0) {
        UIView *v = stack.lastObject;
        [stack removeLastObject];
        for (UIView *child in v.subviews) {
            [stack addObject:child];
        }
        if (![v isKindOfClass:[UIImageView class]]) {
            continue;
        }
        UIImageView *iv = (UIImageView *)v;
        if (iv.hidden || iv.alpha < 0.01) {
            continue;
        }
        if (iv.image != nil || iv.highlightedImage != nil) {
            return iv;
        }
        CGFloat area = CGRectGetWidth(iv.bounds) * CGRectGetHeight(iv.bounds);
        if (area > bestArea) {
            bestArea = area;
            bestWithoutImage = iv;
        }
    }
    return bestWithoutImage;
}

@implementation UITabBar (Badge)

-(MBadgeView *)badgeViewAtIndex:(NSInteger)index{
    // 如果之前添加过，直接设置hidden为NO
    UIView *tabBarButton = [self __iconViewWithIndex:index];
    if (!tabBarButton) {
        return nil;
    }
    for (UIView *subView in tabBarButton.subviews) {
          if (subView.tag == 888 + index) {
              return (MBadgeView *)subView;
          }
    }
    //新建小红点
    MBadgeView *badgeView = [[MBadgeView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.backgroundColor = HEXCOLOR(@"F93A2F");//颜色：红色
    badgeView.textLb.textColor = [UIColor whiteColor];
    badgeView.textLb.font = [UIFont systemFontOfSize:12.f];
    WeakSelf
    if(index == 1){
        badgeView.clearBlock = nil;
    }else{
        badgeView.clearBlock = ^{
            [weakSelf MessageReadAllMessage];
        };
    }
    UIImageView *icon = Noa_tabBarButtonIconImageView(tabBarButton);
    UIView *anchorView = icon ?: tabBarButton;
    [tabBarButton addSubview:badgeView];
    [tabBarButton bringSubviewToFront:badgeView];
    badgeView.layer.zPosition = 1;
    [badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (icon) {
            make.centerY.mas_equalTo(icon.mas_top);
            make.centerX.mas_equalTo(icon.mas_trailing);
        } else {
            make.centerX.mas_equalTo(anchorView);
            make.centerY.mas_equalTo(anchorView.mas_top).offset(2);
        }
    }];
    return badgeView;
    
}

#pragma mark - 显示红点
- (void)showBadgeAtItemIndex:(NSInteger)index textStr:(NSString *)textStr size:(CGSize)badgeSize tapBlock:(nonnull void (^)(void))tapBlock{
    
    MBadgeView *badgeView = [self badgeViewAtIndex:index];
    if (!badgeView) {
        return;
    }
    [badgeView setBadgeText:textStr];
    [badgeView setTapBlock:^{
        tapBlock();
    }];
   
}

// 获取图标所在View
- (UIView *)__iconViewWithIndex:(NSInteger)index {
    UITabBarItem *item = self.items[index];
    UIView *tabBarButton = [item valueForKey:@"_view"];
    return tabBarButton;
}

#pragma mark - 隐藏红点
- (void)hideBadgeAtItemIndex:(NSInteger)index{
    //移除小红点
    [self removeBadgeOnItemIndex:index];
}

//移除小红点
- (void)removeBadgeOnItemIndex:(NSInteger)index{
    MBadgeView *badgeView = [self badgeViewAtIndex:index];
    if (!badgeView) {
        return;
    }
    badgeView.hidden = YES;
}

//全部已读接口
- (void)MessageReadAllMessage {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [IMSDKManager MessageReadAllMessageWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSString *lastSMsgId = (NSString *)data;
        [ZTOOL doInMain:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionListAllRead" object:lastSMsgId];
        }];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        
    }];
}

@end
