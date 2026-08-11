#import "ErrorCodeBuilder.h"

static NSString *const DEFAULT_EXTENSION = @"";

@interface ErrorCodeBuilder ()
@property (nonatomic, copy) NSString *moduleCode;
@property (nonatomic, copy) NSString *subModuleCode;
@property (nonatomic, copy) NSString *errorTypeCode;
@property (nonatomic, copy) NSString *extension;
@end

@implementation ErrorCodeBuilder

+ (instancetype)create {
    ErrorCodeBuilder *builder = [[self alloc] init];
    builder.moduleCode = [ErrorModules UNKNOWN];
    builder.subModuleCode = [InitializationSubModules UNKNOWN];
    builder.errorTypeCode = [InitializationErrorTypes UNKNOWN];
    builder.extension = DEFAULT_EXTENSION;
    return builder;
}

- (ErrorCodeBuilder *)withModule:(NSString *)moduleCode {
    @synchronized (self) {
        if ([ErrorModules isValidModule:moduleCode]) {
            self.moduleCode = moduleCode;
        }
    }
    return self;
}

- (ErrorCodeBuilder *)withInitializationSubModule:(NSString *)subModuleCode {
    @synchronized (self) {
        if ([InitializationSubModules isValidSubModule:subModuleCode]) {
            self.subModuleCode = subModuleCode;
        }
    }
    return self;
}

- (instancetype)withInitializationErrorType:(NSString *)errorTypeCode {
    @synchronized (self) {
        if ([InitializationErrorTypes isValidErrorType:errorTypeCode] &&
            [InitializationErrorTypes isErrorCodeGreater:errorTypeCode than:self.errorTypeCode]) {
            self.errorTypeCode = errorTypeCode;
        }
    }
    return self;
}

- (instancetype)clearInitializationErrorType {
    @synchronized (self) {
        self.errorTypeCode = [InitializationErrorTypes UNKNOWN];
        self.subModuleCode = @"";
    }
    return self;
}

- (instancetype)withExtension:(NSString *)extension {
    @synchronized (self) {
        if (extension && extension.length == 1) {
            self.extension = extension;
        }
    }
    return self;
}

- (NSString *)build {
    return [NSString stringWithFormat:@"%@%@%@%@", self.moduleCode, self.subModuleCode, self.errorTypeCode, self.extension];
}


- (ErrorCodeInfo *)buildInfo {
    return [[ErrorCodeInfo alloc] initWithModuleCode:self.moduleCode
                                           subModuleCode:self.subModuleCode
                                           errorTypeCode:self.errorTypeCode
                                                fullCode:[self build]];
}

@end

