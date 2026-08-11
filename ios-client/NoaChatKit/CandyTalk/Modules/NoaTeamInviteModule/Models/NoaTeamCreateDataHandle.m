//
//  NoaTeamCreateDataHandle.m
//  NoaKit
//
//  Created by phl on 2025/7/21.
//

#import "NoaTeamCreateDataHandle.h"

@interface NoaTeamCreateDataHandle()

/// 当前的随机验证码
@property (nonatomic, copy, readwrite) NSString *randomCode;

@end

@implementation NoaTeamCreateDataHandle

- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

- (RACCommand *)createTeamCommand {
    if (!_createTeamCommand) {
        @weakify(self)
        _createTeamCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSDictionary *param = input;
                NSString *teamName = [param objectForKey:@"teamName"];
                NSString *code = [param objectForKey:@"code"];
                NSNumber *isTop = [param objectForKey:@"isTop"];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObjectSafe:teamName forKey:@"teamName"];
                [dict setObjectSafe:code forKey:@"inviteCode"];
                [dict setObjectSafe:isTop forKey:@"isDefaultTeam"];
                [IMSDKManager imTeamCreateWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    [HUD showMessage:LanguageToolMatch(@"操作成功")];
                    [subscriber sendNext:@(YES)];
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    if (code == 42016) {
                        // 输入界面提示，不进行toast提示
                        [self.showCodeErrorSubject sendNext:@1];
                    }else {
                        [HUD showMessageWithCode:code errorMsg:msg];
                    }
                    [subscriber sendNext:@(NO)];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _createTeamCommand;
}

- (RACCommand *)requestRandomCodeCommand {
    if (!_requestRandomCodeCommand) {
        @weakify(self)
        _requestRandomCodeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [IMSDKManager imTeamGetRandomCodeWith:[@{} mutableCopy] onSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
                    [HUD showMessage:LanguageToolMatch(@"操作成功")];
                    self.randomCode = data;
                    [subscriber sendNext:@(YES)];
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    [HUD showMessageWithCode:code errorMsg:msg];
                    [subscriber sendNext:@(NO)];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _requestRandomCodeCommand;
}

- (RACSubject *)backSubject {
    if (!_backSubject) {
        _backSubject = [RACSubject subject];
    }
    return _backSubject;
}

- (RACSubject *)showCodeErrorSubject {
    if (!_showCodeErrorSubject) {
        _showCodeErrorSubject = [RACSubject subject];
    }
    return _showCodeErrorSubject;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)validateInviteCode:(NSString *)code {
    // 检查长度是否为4位
       if (code.length != 4) {
           [HUD showMessage:LanguageToolMatch(@"请输入4位数字邀请码")];
           return NO;
       }
       
       // 检查是否为纯数字
       NSCharacterSet *nonDigitSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
       if ([code rangeOfCharacterFromSet:nonDigitSet].location != NSNotFound) {
           [HUD showMessage:LanguageToolMatch(@"请输入4位数字邀请码")];
           return NO;
       }
       return YES;
}

@end
