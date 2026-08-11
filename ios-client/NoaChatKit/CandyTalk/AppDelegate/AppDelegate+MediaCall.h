//
//  AppDelegate+MediaCall.h
//  NoaKit
//
//  Created by Candy on 2023/5/29.
//

// 音视频通话 相关处理

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (MediaCall)
<NoaIMMediaCallDelegate>

- (void)configMediaCall;
@end

NS_ASSUME_NONNULL_END
