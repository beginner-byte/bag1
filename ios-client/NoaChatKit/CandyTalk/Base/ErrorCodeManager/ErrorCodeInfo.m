//
//  ErrorCodeInfo.m
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

#import "ErrorCodeInfo.h"
#import "ErrorModules.h"
#import "InitializationSubModules.h"
#import "InitializationErrorTypes.h"

@implementation ErrorCodeInfo

- (instancetype)initWithModuleCode:(NSString *)moduleCode
                    subModuleCode:(NSString *)subModuleCode
                    errorTypeCode:(NSString *)errorTypeCode
                         fullCode:(NSString *)fullCode {
    self = [super init];
    if (self) {
        _moduleCode = [moduleCode copy];
        _subModuleCode = [subModuleCode copy];
        _errorTypeCode = [errorTypeCode copy];
        _fullCode = [fullCode copy];
    }
    return self;
}


- (BOOL)isValid {
    return [ErrorModules isValidModule:self.moduleCode] &&
           [InitializationSubModules isValidSubModule:self.subModuleCode] &&
           [InitializationErrorTypes isValidErrorType:self.errorTypeCode];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ - %@",
            [ErrorModules getModuleDescription:self.moduleCode],
            [InitializationSubModules getSubModuleDescription:self.subModuleCode],
            [InitializationErrorTypes getErrorTypeDescription:self.errorTypeCode]];
}

- (NSString *)simpleDescription:(NSString *)specialDesc {
    NSString *desc = (specialDesc != nil && specialDesc.length > 0)
        ? specialDesc
        : [InitializationErrorTypes getErrorTypeDescription:self.errorTypeCode];
    return [NSString stringWithFormat:@"%@, %@", desc, self.fullCode];
}

@end
