//
//  NoaProxySettings.h
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/16.
//

#import <Foundation/Foundation.h>
#import "NoaBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaProxySettings : NoaBaseModel
@property (nonatomic, assign) ProxyType type;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *port;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@end

NS_ASSUME_NONNULL_END
