//
//  NoaQRCodeModel.h
//  NoaKit
//
//  Created by Candy on 2025/8/8.
//

#import <Foundation/Foundation.h>
#import "NoaBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaQRCodeModel : NoaBaseModel
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) NSInteger expireTime;
@end

NS_ASSUME_NONNULL_END
