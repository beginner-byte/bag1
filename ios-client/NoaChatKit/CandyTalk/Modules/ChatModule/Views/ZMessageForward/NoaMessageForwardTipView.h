//
//  NoaMessageForwardTipView.h
//  NoaKit
//
//  Created by Candy on 2026/12/7.
//

#import <UIKit/UIKit.h>
#import "NoaMessageModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface NoaMessageForwardTipView : UIView
// content可以是被转发消息的文本内容，也可以是被转发的图片、视频消息的图片name或者视频封面图片name
- (instancetype)initWithForwardMsg:(NSArray *)forwardMsgList toAvatarList:(NSArray *)toAvatarList mergeMsgCount:(NSInteger)mergeMsgCount fromSessionId:(NSString *)fromSessionId multiSelectType:(ZMultiSelectType)multiSelectType;

@property (nonatomic, copy)void(^sureClick)(void);

- (void)viewShow;
- (void)viewDismiss;

@end

NS_ASSUME_NONNULL_END
