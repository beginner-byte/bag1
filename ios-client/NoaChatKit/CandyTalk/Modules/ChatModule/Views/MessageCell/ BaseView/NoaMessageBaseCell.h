//
//  NoaMessageBaseCell.h
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#import "NoaBaseCell.h"
#import "NoaMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZMessageBaseCellDelegate <NSObject>

@optional
//点击了用户头像
- (void)userAvatarClick:(NSString *)userId role:(NSInteger)role;
//长按头像 At 用户
- (void)userAvatarLongTapClick:(NSString *)userId nickname:(NSString *)nickname role:(NSInteger)role;
//长按头像 At或禁言 用户
- (void)userAvatarLongTapClickAtAndBanned:(NSString *)userId nickname:(NSString *)nickname role:(NSInteger)role cellIndex:(NSIndexPath *)cellIndex;
//视频消息点击，播放视频
//- (void)videoPlayWithVideoUrl:(NSString *)videoUrl;
//长按消息，显示菜单弹窗
- (void)messageCellLongTapWithIndex:(NSIndexPath *)cellIndex;
//消息发送失败，重发消息
- (void)messageReSendClick:(NSIndexPath *)cellIndex;
//系统通知：非好友弹窗
- (void)systemMessageNotFriendAlert:(NSIndexPath *)cellIndex;
//点击语音消息 播放
- (void)voiceMessageClick:(NSIndexPath *)cellIndex;
//点击消息气泡
- (void)messageBubbleClick:(NSIndexPath *)cellIndex;
//点击了cell
- (void)messageCellClick:(NSIndexPath *)cellIndex;
//文本消息/引用消息/At消息 的消息文字内容中有URL，点击了URL后进行跳转web
- (void)messageTextContainUrlClick:(NSString *)urlStr messageModel:(NoaMessageModel *)messageModel;
//文本消息/引用消息/At消息 的消息文字内容中有URL，点击了URL后进行跳转web
- (void)messageTextReTranslateClick:(NSIndexPath *)cellIndex;
//石头剪刀布、摇骰子 动画执行完成
- (void)gameMessageAnimationComplete:(NSIndexPath *)cellIndex;
//活跃等级标签点击
- (void)groupMemberActivityLevelTagClick:(NSIndexPath *)cellIndex;

//点击图片或视频进行浏览
- (void)messageCellBrowserImageAndVideo:(NoaIMChatMessageModel *)messageModel;

/// 点击了群公告
- (void)messageCellClickGroupNotice:(NSIndexPath *)cellIndex;

@end

@interface NoaMessageBaseCell : NoaBaseCell

@property (nonatomic, strong) NoaMessageModel *messageModel;
@property (nonatomic, strong) NSIndexPath *cellIndex;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, weak) id<ZMessageBaseCellDelegate>delegate;

- (void)setConfigMessage:(NoaMessageModel *)model;
//- (void)msgAddGlitterAction;

- (void)mesaagePositionAnimation;

//发送消息 的 已读 状态 控件 显示/隐藏
- (void)showSendMessageReadProgressView:(BOOL)showProgress;
@end

NS_ASSUME_NONNULL_END
