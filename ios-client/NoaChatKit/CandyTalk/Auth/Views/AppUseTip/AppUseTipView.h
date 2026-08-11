//
//  AppUseTipView.h
//  NoaKit
//
//  Created by Candy on 2023/6/19.
//

// App使用提示

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppUseTipView : UIView

//展示用户协议提示
- (void)showAppUserAgreement;

//关闭用户协议提示
- (void)dismissAppUserAgreement;

@end

NS_ASSUME_NONNULL_END
