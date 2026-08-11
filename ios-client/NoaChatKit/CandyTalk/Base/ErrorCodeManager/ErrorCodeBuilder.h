//
//  ErrorCodeBuilder.h
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

#import <Foundation/Foundation.h>
#import "ErrorCodeInfo.h"
#import "ErrorModules.h"
#import "InitializationSubModules.h"
#import "InitializationErrorTypes.h"

@interface ErrorCodeBuilder : NSObject
@property (nonatomic, copy, readonly) NSString *moduleCode;
@property (nonatomic, copy, readonly) NSString *subModuleCode;
@property (nonatomic, copy, readonly) NSString *errorTypeCode;

+ (instancetype)create;
- (ErrorCodeBuilder *)withModule:(NSString *)moduleCode;
- (ErrorCodeBuilder *)withInitializationSubModule:(NSString *)subModuleCode;
- (ErrorCodeBuilder *)withInitializationErrorType:(NSString *)errorTypeCode;
- (ErrorCodeBuilder *)withExtension:(NSString *)extension;
- (ErrorCodeBuilder *)clearInitializationErrorType;
- (NSString *)build;
- (ErrorCodeInfo *)buildInfo;
@end
