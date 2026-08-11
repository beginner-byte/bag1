//
//  NoaSafeSettingTools.h
//  NoaKit
//
//  Created by Candy on 2025/1/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaSafeSettingTools : NSObject

#pragma mark - 校验安全码 输入完成失去焦点时校验是否为6位，同时包含字母、数字
+ (BOOL)checkInputDeviceSafeCodeEndWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
