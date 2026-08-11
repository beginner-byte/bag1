//
//  NoaForwardMsgPrecheckModel.h
//  NoaKit
//
//  Created by Candy on 2024/3/19.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaForwardDialogModel : NoaBaseModel

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) NSInteger dialogId;
@property (nonatomic, assign) NSInteger dialogType;
@property (nonatomic, copy) NSString *nickname;

@end



@interface NoaForwardExceptionModel : NoaBaseModel

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *codeMsg;
@property (nonatomic, copy) NSString *message;

@end


@interface NoaForwardMsgPrecheckModel : NoaBaseModel

@property (nonatomic, strong) NoaForwardDialogModel *dialogInfo;
@property (nonatomic, strong) NoaForwardExceptionModel *exceptionInfo;

@end

NS_ASSUME_NONNULL_END
