//
//  NoaChatTopView.h
//  NoaKit
//
//  Created by Candy on 2026/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define Chat_Top_Nav_Link_Message       -1
#define Chat_Top_Nav_Link_Notice        -2
#define Chat_Top_Nav_Link_Add           -3
#define Chat_Top_Nav_Link_Setting       -4

typedef void (^ZChatTopNavBackBlock) (void);
typedef void (^ZChatTopNavRightBlock) (void);
typedef void (^ZChatTopNavTimeBlock) (void);//定时按钮点击回调
typedef void (^ZChatTopNavCacelBlock) (void);//多选-取消blokc回调
typedef void (^ZChatTopNavLinkBlock) (NSInteger linkIndex);//群链接-点击block
typedef void (^ZChatTopNavNetworkDetectBlock)(void); // 网络检测

@class LingIMGroup;
@interface NoaChatTopView : UIView

@property (nonatomic, copy) ZChatTopNavBackBlock navBackBlock;
@property (nonatomic, copy) ZChatTopNavBackBlock navRightBlock;
@property (nonatomic, copy) ZChatTopNavBackBlock navTimeBlock;
@property (nonatomic, copy) ZChatTopNavCacelBlock navCancelBlock;
@property (nonatomic, copy) ZChatTopNavLinkBlock navLinkBlock;
@property (nonatomic, copy) ZChatTopNavNetworkDetectBlock navNetworkDetectBlock;
@property (nonatomic, copy) NSString *chatName;//聊天名称
@property (nonatomic, strong) UILabel *chatNameLbl;//用户昵称或者群名
@property (nonatomic, strong) UILabel *tipExplainLbl;//提示：当前消息已被加密
@property (nonatomic, strong) UIImageView *tipLockImgView;//提示：锁的图片
@property (nonatomic, strong) UIButton *btnTime;//定时删除消息功能按钮
@property (nonatomic, assign) BOOL showCancel;//多选-取消按钮
@property (nonatomic, strong) UIView *viewOnline;//用户在线
@property (nonatomic, assign) BOOL isShowTagTool;
@property (nonatomic, strong) NSMutableArray *chatLinkArr;
@property (nonatomic, assign) BOOL isShowGroupNotice;//会话类型
@property (nonatomic, copy) NSString *sessionId;//sessionId
@property (nonatomic, assign) CIMChatType chatType;//聊天名称

/// 群聊信息(用于在群聊消息中判断权限)
@property (nonatomic, strong) LingIMGroup *groupInfo;

- (void)chatRoomAddNewTagActionWithTagName:(NSString *)tagName tagUrl:(NSString *)tagUrl;


@end

NS_ASSUME_NONNULL_END
