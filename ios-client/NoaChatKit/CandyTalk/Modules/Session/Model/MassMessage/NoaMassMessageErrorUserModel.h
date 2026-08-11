//
//  NoaMassMessageErrorUserModel.h
//  NoaKit
//
//  Created by Candy on 2023/4/21.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMassMessageErrorUserModel : NoaBaseModel
@property (nonatomic, copy) NSString *ID;//
@property (nonatomic, copy) NSString *taskId;//任务ID，该群发组ID下发送的第几条消息
@property (nonatomic, copy) NSString *errorUserUid;//用户ID
@property (nonatomic, copy) NSString *errorMsg;//失败原因
@property (nonatomic, copy) NSString *sendTime;//发送时间
@property (nonatomic, assign) NSInteger chatType;//区分单人/群，0：单人   1：群
@end

NS_ASSUME_NONNULL_END
