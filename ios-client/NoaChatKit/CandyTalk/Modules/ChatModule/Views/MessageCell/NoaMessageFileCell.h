//
//  NoaMessageFileCell.h
//  NoaKit
//
//  Created by Candy on 2023/1/5.
//

#import "NoaMessageContentBaseCell.h"
typedef void(^FailureBlock)(NoaIMChatMessageModel * _Nullable chatMsgModel);
NS_ASSUME_NONNULL_BEGIN

@interface NoaMessageFileCell : NoaMessageContentBaseCell
//点击群组信息视图回调Block
@property (nonatomic, copy) FailureBlock failureBlock;
@end

NS_ASSUME_NONNULL_END
