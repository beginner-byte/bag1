//
//  NoaMessageModel.h
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

//Cell上、下留白
#define CellTop       10
#define CellBottom    10

#import "NoaBaseModel.h"
#import <NoaChatCore/NoaIMChatMessageModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaMessageModel : NoaBaseModel <NSCopying, NSMutableCopying>

//消息Model
@property (nonatomic, strong) NoaIMChatMessageModel *message;
//被引用的消息Model
@property (nonatomic, strong) NoaIMChatMessageModel *referenceMsg;
//富文本(消息内容)
@property (nonatomic, strong) NSMutableAttributedString * _Nullable attStr;
//富文本(消息内容)译文
@property (nonatomic, strong) NSMutableAttributedString * _Nullable translateAttStr;
//富文本(被引用的消息内容)
@property (nonatomic, strong) NSMutableAttributedString *referenceAttStr;
//message内容宽度
@property (nonatomic, assign) CGFloat messageWidth;
//message内容高度
@property (nonatomic, assign) CGFloat messageHeight;
//message内容宽度-译文
@property (nonatomic, assign) CGFloat translateMessageWidth;
//message内容高度-译文
@property (nonatomic, assign) CGFloat translateMessageHeight;
//引用message内容高度
@property (nonatomic, assign) CGFloat referenceMsgHeight;
//cell高度
@property (nonatomic, assign) CGFloat cellHeight;
//消息是否是自己发送的
@property (nonatomic, assign) BOOL isSelf;
//引用消息是否是自己发送的
@property (nonatomic, assign) BOOL isReferenceSelf;
//是否要显示消息的发送时间
@property(nonatomic, assign) BOOL isShowSendTime;
//将消息的时间戳转换成日期时间
@property (nonatomic, copy) NSString *dataTime;

//已经下载的大小
@property (nonatomic, assign)long long byteSent;
//总大小
@property (nonatomic, assign)long long totalByte;
//请求任务状态
@property (nonatomic, assign)NSInteger taskState;//任务状态
//是否是多选状态(是否显示左边的选中按钮)
@property (nonatomic, assign)BOOL isShowSelectBox;
//多选-选中的状态(是否选中)
@property (nonatomic, assign)BOOL multiSelected;
//是否启用群活跃功能（0：关闭，1：开启）
@property (nonatomic, assign)NSInteger isActivityLevel;
//我在本群的角色(0普通成员;1管理员;2群主)
@property (nonatomic, assign)NSInteger userGroupRole;

@property (nonatomic, copy) void(^uploadFileSuccess)(void);
@property (nonatomic, copy) void(^uploadFileFail)(void);
@property (nonatomic, copy) void(^uploadFileLoading)(float progress, NSString *taskId);

//获取attstr,每次获取都更新一下
- (NSMutableAttributedString *)getCurAttStr;

//初始化赋值
- (instancetype)initWithMessageModel:(NoaIMChatMessageModel *)message;
/// 使用编辑后的消息初始化展示模型，并保留正确的翻译展示状态。
/// @param message 已合并编辑内容的数据库消息。
- (instancetype)initWithEditMessageModel:(NoaIMChatMessageModel *)message;
//初始化赋值(会话记录)
- (instancetype)initWithMessageModel:(NoaIMChatMessageModel *)message isSelf:(BOOL)isSelf;

//计算cell的宽高
- (void)calculateModelInfoSize;

@end

NS_ASSUME_NONNULL_END
