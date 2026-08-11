//
//  NoaTeamInviteDetailDataHandle.m
//  NoaKit
//
//  Created by phl on 2025/7/24.
//

#import "NoaTeamInviteDetailDataHandle.h"

@interface NoaTeamInviteDetailDataHandle()

/// 从上个页面传入的团队信息
@property (nonatomic, strong, readwrite) NoaTeamModel *currentTeamModel;

/// 获取到的团队详情信息
@property (nonatomic, strong, readwrite) NoaTeamDetailModel *teamDetailModel;

@end

@implementation NoaTeamInviteDetailDataHandle

- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

- (RACCommand *)requestTeamDetailDataCommand {
    if (!_requestTeamDetailDataCommand) {
        @weakify(self)
        _requestTeamDetailDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObjectSafe:self.currentTeamModel.teamId forKey:@"teamId"];
                [IMSDKManager imTeamDetailWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dataDict = (NSDictionary *)data;
                        self.teamDetailModel = [NoaTeamDetailModel mj_objectWithKeyValues:dataDict];
                        if([self.teamDetailModel.teamName isEqualToString:@"默认团队"]){
                            self.teamDetailModel.teamName = LanguageToolMatch(@"默认团队");
                        }
                    }
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
    return _requestTeamDetailDataCommand;
}

- (RACCommand *)editTeamDetailInfoCommand {
    if (!_editTeamDetailInfoCommand) {
        @weakify(self)
        _editTeamDetailInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObjectSafe:self.currentTeamModel.teamId forKey:@"teamId"];
                [dict setObjectSafe:@1 forKey:@"isDefaultTeam"];
                [IMSDKManager imTeamEditWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    [HUD showMessage:LanguageToolMatch(@"置顶成功")];
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
    return _editTeamDetailInfoCommand;
}

- (RACSubject *)changeNewTeamSubject {
    if (!_changeNewTeamSubject) {
        _changeNewTeamSubject = [RACSubject subject];
    }
    return _changeNewTeamSubject;
}

- (RACSubject *)jumpAllGroupPeoplePageSubject {
    if (!_jumpAllGroupPeoplePageSubject) {
        _jumpAllGroupPeoplePageSubject = [RACSubject subject];
    }
    return _jumpAllGroupPeoplePageSubject;
}

- (instancetype)initWithTeamModel:(NoaTeamModel *)teamModel {
    self = [super init];
    if (self) {
        self.currentTeamModel = teamModel;
    }
    return self;
}

- (void)changeNewTeamName:(NSString *)newTeamName {
    if (_currentTeamModel) {
        _currentTeamModel.teamName = newTeamName;
    }
    
    if (_teamDetailModel) {
        _teamDetailModel.teamName = newTeamName;
    }
}

@end
