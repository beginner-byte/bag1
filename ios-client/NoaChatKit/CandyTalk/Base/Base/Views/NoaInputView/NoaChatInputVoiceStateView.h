//
//  NoaChatInputVoiceStateView.h
//  NoaKit
//
//  Created by Candy on 2023/1/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, InputVoiceStateType) {
    InputVoiceStateSend = 1,        //发送状态
    InputVoiceStateCancel = 2,        //取消状态
};

@interface NoaChatInputVoiceStateView : UIView
@property (nonatomic, strong) UILabel *timeLabel;//声音时间

- (void)updateViewState:(InputVoiceStateType)stateType;
@end

NS_ASSUME_NONNULL_END
