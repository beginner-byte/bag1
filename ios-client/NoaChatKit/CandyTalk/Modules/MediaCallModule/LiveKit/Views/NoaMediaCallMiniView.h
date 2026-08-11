//
//  NoaMediaCallMiniView.h
//  NoaKit
//
//  Created by Candy on 2023/1/9.
//

#import <UIKit/UIKit.h>
#import "NoaMediaCallManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMediaCallMiniView : UIView
@property (nonatomic, strong) NoaMediaCallOptions *mediaCallOptions;//多媒体会话配置信息

//展示动画
- (void)mediaCallMiniViewShow;
//消失动画
- (void)mediaCallMiniViewDismiss;
@end

NS_ASSUME_NONNULL_END
