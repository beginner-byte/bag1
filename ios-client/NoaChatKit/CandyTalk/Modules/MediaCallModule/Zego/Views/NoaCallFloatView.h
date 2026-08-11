//
//  NoaCallFloatView.h
//  NoaKit
//
//  Created by Candy on 2023/5/24.
//

// 即构 单人 音视频通话 最小化控件

#import <UIKit/UIKit.h>
#import "NoaCallUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaCallFloatView : UIView
@property (nonatomic, strong) NoaCallUserModel *userModel;
@end

NS_ASSUME_NONNULL_END
