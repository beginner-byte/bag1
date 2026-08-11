//
//  NoaChatInputVoiceView.h
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZChatInputVoiceViewDelegate <NSObject>
- (void)dragMoving;

- (void)dragEnded;
// 点击被取消，例如进入后台
- (void)voiceEventTouchCancel;

// 按下去
- (void)voiceEventTouchDown;

// 从外到内
- (void)voiceEventTouchDragEnter;

// 从内到外
- (void)voiceEventTouchDragExit;

// 在button感应区域之外结束点击，取消点击
- (void)voiceEventTouchUpOutside;

// 在button感应区域之内结束点击，成功点击
- (void)voiceEventTouchUpInside;
@end

@interface NoaChatInputVoiceView : UIView
@property (nonatomic, weak) id <ZChatInputVoiceViewDelegate> delegate;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, assign) BOOL recordVoiceFinish;//录音是否结束
@end

NS_ASSUME_NONNULL_END
