//
//  NoaGestureLockIndicatorView.h
//  NoaKit
//
//  Created by Candy on 2023/4/23.
//

// 手势锁 指示器 小图提示

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaGestureLockIndicatorView : UIView
//设置手势密码
- (void)setGesturePassword:(NSString *)gesturePassword;
@end

NS_ASSUME_NONNULL_END
