//
//  NoaAppUpdateTools.h
//  NoaKit
//
//  Created by Candy on 2023/4/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaAppUpdateTools : NSObject

+ (void)getAppUpdateInfoWithShowDefaultTips:(BOOL)isShow completion:(void (^)(BOOL))completion;


@end

NS_ASSUME_NONNULL_END
