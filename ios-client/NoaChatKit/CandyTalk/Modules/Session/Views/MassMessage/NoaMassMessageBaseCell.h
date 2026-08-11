//
//  NoaMassMessageBaseCell.h
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

// 群发助手列表基准Cell

#import "MGSwipeTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZMassMessageBaseCellDelegate <NSObject>
//查看全部接受者列表
- (void)cellCheckAllReceiverWith:(LIMMassMessageModel *)messageModel;
//查看发送失败用户列表
- (void)cellCheckErrorReceiverWith:(LIMMassMessageModel *)messageModel;
//再发一条
- (void)cellSendAgainWith:(LIMMassMessageModel *)messageModel;
//查看图片、视频、文件详情
- (void)cellCheckDetailWith:(LIMMassMessageModel *)messageModel;

@end

@interface NoaMassMessageBaseCell : MGSwipeTableCell
@property (nonatomic, strong) UIView *viewContent;//控件容器

@property (nonatomic, strong) UILabel *lblTarget;//标签
@property (nonatomic, strong) UILabel *lblNumber;//收件人个数
@property (nonatomic, strong) UILabel *lblReceiver;//收件人信息

@property (nonatomic, strong) UIButton *btnReceiver;//查看收件人列表

@property (nonatomic, strong) UILabel *lblSending;//发送中

@property (nonatomic, strong) UILabel *lblSendEnd;//发送完毕
@property (nonatomic, strong) UILabel *lblSendFail;//发送失败信息
@property (nonatomic, strong) UIButton *btnFail;//查看发送失败列表

@property (nonatomic, strong) UIButton *btnSendAgain;//再发一条

@property (nonatomic, strong) LIMMassMessageModel *messageModel;

@property (nonatomic, weak) id <ZMassMessageBaseCellDelegate> massMessageDelegate;
@end

NS_ASSUME_NONNULL_END
