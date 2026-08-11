//
//  NoaMessageContentBaseCell.h
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#import "NoaMessageBaseCell.h"
#import "NoaBubbleSendView.h"
#import "NoaBubbleReceiveView.h"
#import "NoaMsgReadProgressView.h"
#import "NoaBaseMsgAvatarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMessageContentBaseCell : NoaMessageBaseCell
{
    CGRect _contentRect;
}

//消息UI
@property (nonatomic, strong) NoaBaseMsgAvatarView *msgAvatarBackView;//头像Back
@property (nonatomic, strong) UIImageView *msgAvatarImgView;//头像
@property (nonatomic, strong) UILabel *msgUserRoleName;//用户角色名称
@property (nonatomic, strong) UILabel *userNickLbl; //昵称
@property (nonatomic, strong) UIButton *groupRoleView;//群主或群管理标识
@property (nonatomic, strong) UILabel *groupRoleLabel;//群主或管理标识文本
@property (nonatomic, strong) NoaBubbleSendView *viewSendBubble;//发送消息气泡
@property (nonatomic, strong) NoaBubbleReceiveView *viewReceiveBubble;//接收消息气泡
@property (nonatomic, strong) UILabel *msgDateLbl;//日期时间
@property (nonatomic, strong) NoaMsgReadProgressView *readedView; //是否已读状态或已读进度
@property (nonatomic, strong) UIButton *reSendBtn; //发送失败红色感叹号，点击可重发
@property (nonatomic, strong) UIImageView *sendLoadingView; //发送中的loading小菊花
@property (nonatomic, strong) UIButton *selectedStatusBtn;  //是否选中状态View
@property (nonatomic, strong) UITapGestureRecognizer *cellTouchTap;
@property (nonatomic, strong) UILabel *msgTimeLbl;//消息的发送时间

//头像点击事件
- (void)avatarClick;
- (void)configMsgSendStatus:(CIMChatMessageSendType)sendStatus;
- (void)loadImageFailWithURL:(NSString *)url error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
