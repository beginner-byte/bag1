//
//  NoaFriendReqModel.h
//  NoaKit
//
//  Created by Candy on 2024/6/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaFriendReqModel : NoaBaseModel
@property (nonatomic, strong) NSString *hashKey;
@property (nonatomic, assign) NSInteger beStatus;
@property (nonatomic, strong) NSString *latestUpdateTime;
@end

NS_ASSUME_NONNULL_END
