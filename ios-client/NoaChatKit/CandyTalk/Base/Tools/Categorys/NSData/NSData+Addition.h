//
//  NSData+Addition.h
//  NoaKit
//
//  Created by Candy on 2025/1/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Addition)

//将字符串base64加密成data
+ (NSData *)base64DataFromString:(NSString *)string;

//Hex解密
+ (NSData *)hexDescodeWithStr:(NSString *)hexStr;

//获取随机长度数据
+ (NSData *)randomDataWithLength:(NSUInteger)length;

//MD5
- (NSString *)dataGetMD5Encry;

@end

NS_ASSUME_NONNULL_END
