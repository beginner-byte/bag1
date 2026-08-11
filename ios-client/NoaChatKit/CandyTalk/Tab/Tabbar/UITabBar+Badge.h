//
//  UITabBar+Badge.h
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (Badge)
/// tabbar的红点显示
/// @param index 下标
/// @param textStr 显示的内容(如果只想显示红点@"")
/// @param badgeSize 显示内容的宽高
- (void)showBadgeAtItemIndex:(NSInteger)index textStr:(NSString *)textStr size:(CGSize)badgeSize tapBlock:(void(^)(void))tapBlock;


/// tabbar红点隐藏
/// @param index 下标
- (void)hideBadgeAtItemIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
