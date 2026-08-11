//
//  NoaGetImgVerCodeBlurDataHandle.m
//  NoaChatKit
//
//  Created by phl on 2025/11/14.
//

#import "NoaGetImgVerCodeBlurDataHandle.h"

@interface NoaGetImgVerCodeBlurDataHandle ()

@end

@implementation NoaGetImgVerCodeBlurDataHandle

- (RACSubject *)showToastSubject {
    if (!_showToastSubject) {
        _showToastSubject = [RACSubject subject];
    }
    return _showToastSubject;
}

- (RACSubject *)dismissSubject {
    if (!_dismissSubject) {
        _dismissSubject = [RACSubject subject];
    }
    return _dismissSubject;
}

- (RACSubject *)configureFinishSubject {
    if (!_configureFinishSubject) {
        _configureFinishSubject = [RACSubject subject];
    }
    return _configureFinishSubject;
}

- (RACCommand *)getImgVerCommand {
    if (!_getImgVerCommand) {
        _getImgVerCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
                NSString *account = self.account;
                
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setValue:account forKey:@"loginName"];
                // 手机号注册类型为1
                [params setValue:@(self.verCodeType) forKey:@"type"];
                
                [IMSDKManager authGetImgVerCodeWith:params
                                          onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    if (![data isKindOfClass:[NSString class]]) {
                        [subscriber sendNext:@{
                            @"res": @NO,
                            @"code": @"",
                        }];
                        [subscriber sendCompleted];
                        return;
                    }
                    
                    NSString *codeStr = data;
                    if ([NSString isNil:codeStr]) {
                        // 为空异常
                        [subscriber sendNext:@{
                            @"res": @NO,
                            @"code": @"",
                        }];
                    }else {
                        [subscriber sendNext:@{
                            @"res": @YES,
                            @"code": codeStr,
                        }];
                    }
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    [subscriber sendNext:@{
                        @"res": @NO,
                        @"code": msg,
                        @"error": @{
                            @"code" : @(code),
                            @"msg" : [NSString isNil:msg] ? @"" : msg,
                        }
                    }];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _getImgVerCommand;
}

@end
