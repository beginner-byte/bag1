//
//  ErrorCodeManager.h
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

// ErrorCodeManager.h
#import <Foundation/Foundation.h>
#import "ErrorCodeInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ErrorCodeManager : NSObject

/// 单例访问
+ (instancetype)sharedManager;

/**
 生成完整的6位错误码，如果参数无效返回默认错误码
 @param moduleCode 模块编码
 @param subModuleCode 子模块编码
 @param errorTypeCode 错误类型编码
 @return 6位错误码字符串
 */
- (NSString *)generateErrorCodeWithModuleCode:(NSString *)moduleCode
                              subModuleCode:(NSString *)subModuleCode
                            errorTypeCode:(NSString *)errorTypeCode;

/**
 解析错误码，如果错误码无效返回包含默认值的错误信息对象
 @param errorCode 6位错误码字符串
 @return ErrorCodeInfo 对象
 */
- (ErrorCodeInfo *)parseErrorCode:(nullable NSString *)errorCode;

/**
 获取错误描述，永远不会返回 nil
 @param errorCode 6位错误码字符串
 @return 格式化的描述字符串
 */
- (NSString *)getErrorDescription:(nullable NSString *)errorCode;

/**
 检查错误码是否有效
 @param errorCode 6位错误码字符串
 @return YES 表示有效，NO 表示无效
 */
- (BOOL)isValidErrorCode:(nullable NSString *)errorCode;

@end

NS_ASSUME_NONNULL_END
