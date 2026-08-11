//
//  NoaTeamListDataHandle.m
//  NoaKit
//
//  Created by phl on 2025/7/21.
//

#import "NoaTeamListDataHandle.h"

@interface NoaTeamListDataHandle()

@property (nonatomic, assign) NSInteger pageNumber;

@end

@implementation NoaTeamListDataHandle

- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

- (RACCommand *)requestTeamHomeDataCommand {
    if (!_requestTeamHomeDataCommand) {
        @weakify(self)
        _requestTeamHomeDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
                [IMSDKManager imTeamHomeV2With:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dataDic = (NSDictionary *)data;
                        self.defaultTeamModel = [NoaTeamModel mj_objectWithKeyValues:dataDic];
                        self.defaultTeamModel.teamName = LanguageToolMatch(self.defaultTeamModel.teamName);
                    }
                    
                    [subscriber sendNext:@(YES)];
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    [HUD showMessageWithCode:code errorMsg:msg];
                    [subscriber sendNext:@(false)];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _requestTeamHomeDataCommand;
}

- (RACCommand *)requestTeamListCommand {
    if (!_requestTeamListCommand) {
        @weakify(self)
        _requestTeamListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
                NSInteger pageSize = self.pageNumber * 20;
                NSInteger pageStart = (self.pageNumber - 1) * 20;
                
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObjectSafe:@(self.pageNumber) forKey:@"pageNumber"];
                [dict setObjectSafe:@(pageSize) forKey:@"pageSize"];
                [dict setObjectSafe:@(pageStart) forKey:@"pageStart"];
                [IMSDKManager imTeamListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        //数据处理
                        NSMutableArray <NoaTeamModel *>*teamModelList = [NSMutableArray new];
                        NSArray *teamListTemp = (NSArray *)[data objectForKeySafe:@"records"];
                        [teamListTemp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NoaTeamModel *model = [NoaTeamModel mj_objectWithKeyValues:obj];
                            if([model.teamName isEqualToString:@"默认团队"]){
                                model.teamName = LanguageToolMatch(@"默认团队");
                            }
                            [teamModelList addObjectIfNotNil:model];
                        }];
                        
                        if (self.pageNumber == 1) {
                            self.teamListModelArr = teamModelList;
                        }else {
                            [self.teamListModelArr addObjectsFromArray:teamModelList];
                        }
                    }
                    [subscriber sendNext:@(YES)];
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    [HUD showMessageWithCode:code errorMsg:msg];
                    [subscriber sendNext:@(false)];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _requestTeamListCommand;
}

- (NSMutableArray<NoaTeamModel *> *)teamListModelArr {
    if (!_teamListModelArr) {
        _teamListModelArr = [NSMutableArray new];
    }
    return _teamListModelArr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resumeDefaultConfigure];
    }
    return self;
}

- (void)resumeDefaultConfigure {
    self.pageNumber = 1;
}

- (void)requestMoreDataConfigure {
    self.pageNumber += 1;
}

- (NoaTeamModel *)obtainTeamModelWithIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (self.teamListModelArr.count > row) {
        return self.teamListModelArr[row];
    }
    return nil;
}


@end
