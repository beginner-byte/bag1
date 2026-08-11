//
//  ErrorCodeManager.m
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

// ErrorCodeManager.m
// ErrorCodeManager.m
#import "ErrorCodeManager.h"
#import "ErrorModules.h"
#import "InitializationSubModules.h"
#import "InitializationErrorTypes.h"

static NSString * const kExtensionDigit = @"0";
static NSString * const kInvalidErrorCode = @"000000";

@implementation ErrorCodeManager

+ (instancetype)sharedManager {
    static ErrorCodeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSString *)generateErrorCodeWithModuleCode:(NSString *)moduleCode
                              subModuleCode:(NSString *)subModuleCode
                            errorTypeCode:(NSString *)errorTypeCode {
    if (![ErrorModules isValidModule:moduleCode] ||
        ![InitializationSubModules isValidSubModule:subModuleCode] ||
        ![InitializationErrorTypes isValidErrorType:errorTypeCode]) {
        return kInvalidErrorCode;
    }
    return [NSString stringWithFormat:@"%@%@%@%@", moduleCode, subModuleCode, errorTypeCode, kExtensionDigit];
}

- (ErrorCodeInfo *)parseErrorCode:(NSString *)errorCode {
    if (errorCode == nil || errorCode.length != 6) {
        return [[ErrorCodeInfo alloc] initWithModuleCode:[ErrorModules UNKNOWN]
                                           subModuleCode:[InitializationSubModules UNKNOWN]
                                           errorTypeCode:[InitializationErrorTypes UNKNOWN]
                                                 fullCode:kInvalidErrorCode];
    }

    NSString *moduleCode = [errorCode safeSubstringWithRange:NSMakeRange(0, 2)];
    NSString *subModuleCode = [errorCode safeSubstringWithRange:NSMakeRange(2, 2)];
    NSString *errorTypeCode = [errorCode safeSubstringWithRange:NSMakeRange(4, 2)];

    if (![ErrorModules isValidModule:moduleCode]) {
        moduleCode = [ErrorModules UNKNOWN];
    }
    if (![InitializationSubModules isValidSubModule:subModuleCode]) {
        subModuleCode = [InitializationSubModules UNKNOWN];
    }
    if (![InitializationErrorTypes isValidErrorType:errorTypeCode]) {
        errorTypeCode = [InitializationErrorTypes UNKNOWN];
    }

    return [[ErrorCodeInfo alloc] initWithModuleCode:moduleCode
                                       subModuleCode:subModuleCode
                                       errorTypeCode:errorTypeCode
                                             fullCode:errorCode];
}

- (NSString *)getErrorDescription:(NSString *)errorCode {
    ErrorCodeInfo *info = [self parseErrorCode:errorCode];
    return [NSString stringWithFormat:@"%@ - %@ - %@",
            [ErrorModules getModuleDescription:info.moduleCode],
            [InitializationSubModules getSubModuleDescription:info.subModuleCode],
            [InitializationErrorTypes getErrorTypeDescription:info.errorTypeCode]];
}

- (BOOL)isValidErrorCode:(NSString *)errorCode {
    if (errorCode == nil || errorCode.length != 6) {
        return NO;
    }
    NSString *moduleCode = [errorCode safeSubstringWithRange:NSMakeRange(0, 2)];
    NSString *subModuleCode = [errorCode safeSubstringWithRange:NSMakeRange(2, 2)];
    NSString *errorTypeCode = [errorCode safeSubstringWithRange:NSMakeRange(4, 2)];
    return [ErrorModules isValidModule:moduleCode] &&
           [InitializationSubModules isValidSubModule:subModuleCode] &&
           [InitializationErrorTypes isValidErrorType:errorTypeCode];
}

@end
