//
//  NoaRobotModel.h
//  NoaKit
//
//  Created by Apple on 2023/9/25.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaRobotModel : NoaBaseModel
@property (nonatomic, copy) NSString *createTime ;
@property (nonatomic, copy) NSString *createUserId;
@property (nonatomic, assign) NSInteger deleteEditCondition;
@property (nonatomic, assign) NSInteger enable;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *headPhoto;
@property (nonatomic, copy) NSString *hookUuid;
@property (nonatomic, copy) NSString *ipWhitelist;
@property (nonatomic, copy) NSString *robotDesc;
@property (nonatomic, copy) NSString *robotName;
@property (nonatomic, copy) NSString *robotType;
@property (nonatomic, copy) NSString *signatureKey;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString *updateUserId;
@property (nonatomic, copy) NSString *userUid ;
@property (nonatomic, copy) NSString *webhook;
@end

NS_ASSUME_NONNULL_END
