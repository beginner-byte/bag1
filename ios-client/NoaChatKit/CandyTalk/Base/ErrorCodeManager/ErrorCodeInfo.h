//
//  ErrorCodeInfo.h
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ErrorCodeInfo : NSObject

/// 模块编码
@property (nonatomic, copy, readonly) NSString *moduleCode;
/// 子模块编码
@property (nonatomic, copy, readonly) NSString *subModuleCode;
/// 错误类型编码
@property (nonatomic, copy, readonly) NSString *errorTypeCode;
/// 原始完整错误码
@property (nonatomic, copy, readonly) NSString *fullCode;

/**
 初始化 ErrorCodeInfo
 @param moduleCode 模块编码
 @param subModuleCode 子模块编码
 @param errorTypeCode 错误类型编码
 @param fullCode 原始完整错误码
 @return 实例对象
 */
- (instancetype)initWithModuleCode:(NSString *)moduleCode
                   subModuleCode:(NSString *)subModuleCode
                   errorTypeCode:(NSString *)errorTypeCode
                         fullCode:(NSString *)fullCode;

- (BOOL)isValid;
- (NSString *)description;
- (NSString *)simpleDescription:(NSString *)specialDesc;
@end

NS_ASSUME_NONNULL_END
