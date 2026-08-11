//
//  NoaGroupNoticeListDataHandle.m
//  NoaKit
//
//  Created by phl on 2025/8/11.
//

#import "NoaGroupNoticeListDataHandle.h"
#import "NoaGroupNoteLocalUserNameModel.h"

@interface NoaGroupNoticeListDataHandle()

/// 当前群信息
@property (nonatomic, strong, readwrite) LingIMGroup *groupInfoModel;

/// 页数
@property (nonatomic, assign) NSInteger pageNumber;

@end

@implementation NoaGroupNoticeListDataHandle

- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

- (NSMutableArray<NoaGroupNoteLocalUserNameModel *> *)topGroupNoteModelList {
    if (!_topGroupNoteModelList) {
        _topGroupNoteModelList = [NSMutableArray new];
    }
    return _topGroupNoteModelList;
}

- (NSMutableArray<NoaGroupNoteLocalUserNameModel *> *)normalGroupNoteModelList {
    if (!_normalGroupNoteModelList) {
        _normalGroupNoteModelList = [NSMutableArray new];
    }
    return _normalGroupNoteModelList;
}

- (RACCommand *)requestListDataCommand {
    if (!_requestListDataCommand) {
        @weakify(self)
        _requestListDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
                NSInteger pageSize = 20;
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObjectSafe:@(self.pageNumber) forKey:@"pageNumber"];
                [dict setObjectSafe:@(pageSize) forKey:@"pageSize"];
                [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
                [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
                [IMSDKManager groupCheckGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        //数据处理
                        NSMutableArray <NoaGroupNoteLocalUserNameModel *>*normalGroupNoteModelList = [NSMutableArray new];
                        NSMutableArray <NoaGroupNoteLocalUserNameModel *>*topGroupNoteModelList = [NSMutableArray new];
                        NSArray *groupListTemp = (NSArray *)[data objectForKeySafe:@"rows"];
                        [groupListTemp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NoaGroupNoteLocalUserNameModel *groupNoticeModel = [NoaGroupNoteLocalUserNameModel mj_objectWithKeyValues:obj];
                            if ([groupNoticeModel.topStatus isEqualToString:@"1"]) {
                                [topGroupNoteModelList addObjectIfNotNil:groupNoticeModel];
                            }else {
                                [normalGroupNoteModelList addObjectIfNotNil:groupNoticeModel];
                            }
                            
                        }];
                        
                        if (self.pageNumber == 1) {
                            self.normalGroupNoteModelList = normalGroupNoteModelList;
                            self.topGroupNoteModelList = topGroupNoteModelList;
                        }else {
                            [self.normalGroupNoteModelList addObjectsFromArray:normalGroupNoteModelList];
                            [self.topGroupNoteModelList addObjectsFromArray:topGroupNoteModelList];
                        }
                        
                        // 对数组进行排序
                        [self sortGroupNoteModelListsByCreateTime:self.topGroupNoteModelList];
                        [self sortGroupNoteModelListsByCreateTime:self.normalGroupNoteModelList];

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
    return _requestListDataCommand;
}

- (RACCommand *)requestNoticeDetailCommand {
    if (!_requestNoticeDetailCommand) {
        @weakify(self)
        _requestNoticeDetailCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSIndexPath *selectIndexPath = input;
                NoaGroupNoteLocalUserNameModel *groupNoticeModel = [self obtainGroupModelWithIndexPath:selectIndexPath];
                if (!groupNoticeModel) {
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                    return [RACDisposable disposableWithBlock:^{
                        
                    }];
                }
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
                [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
                [dict setObjectSafe:groupNoticeModel.noticeId forKey:@"noticeId"];
                [IMSDKManager groupCheckOneGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    NoaGroupNoteModel *groupNoticeModel = nil;
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dataDict = (NSDictionary *)data;
                        groupNoticeModel = [NoaGroupNoteModel mj_objectWithKeyValues:dataDict];
                    }
                    [subscriber sendNext:groupNoticeModel];
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    if (code == 41034) {
                        [HUD showMessage:LanguageToolMatch(@"公告已删除")];
                    }else {
                        [HUD showMessageWithCode:code errorMsg:msg];
                    }
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _requestNoticeDetailCommand;
}

- (RACCommand *)deleteDataCommand {
    if (!_deleteDataCommand) {
        @weakify(self)
        _deleteDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSIndexPath *indexPath = (NSIndexPath *)input;
                NoaGroupNoteLocalUserNameModel *groupNoticeModel = [self obtainGroupModelWithIndexPath:indexPath];
                if (!groupNoticeModel) {
                    [subscriber sendNext:@(false)];
                    [subscriber sendCompleted];
                    return [RACDisposable disposableWithBlock:^{
                        
                    }];
                }
                
                NSMutableDictionary *dict = [NSMutableDictionary new];
                //删除群公告
                [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
                [dict setValue:[NSString stringWithFormat:@"%@", groupNoticeModel.noticeId] forKey:@"noticeId"];
                [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
                [IMSDKManager groupDeleteGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    [HUD showMessage:LanguageToolMatch(@"删除成功")];
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
    return _deleteDataCommand;
}

- (RACSubject *)jumpGroupInfoDetailSubject {
    if (!_jumpGroupInfoDetailSubject) {
        _jumpGroupInfoDetailSubject = [RACSubject subject];
    }
    return _jumpGroupInfoDetailSubject;
}

- (RACSubject *)jumpEditSubject {
    if (!_jumpEditSubject) {
        _jumpEditSubject = [RACSubject subject];
    }
    return _jumpEditSubject;
}

- (instancetype)initWithGroupInfo:(LingIMGroup *)groupInfoModel {
    self = [super init];
    if (self) {
        self.groupInfoModel = groupInfoModel;
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

- (NoaGroupNoteLocalUserNameModel *)obtainGroupModelWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSInteger row = indexPath.row;
        if (self.topGroupNoteModelList.count > row) {
            return self.topGroupNoteModelList[row];
        }
    }else {
        NSInteger row = indexPath.row;
        if (self.normalGroupNoteModelList.count > row) {
            return self.normalGroupNoteModelList[row];
        }
    }
    return nil;
}

- (void)sortGroupNoteModelListsByCreateTime:(NSMutableArray<NoaGroupNoteLocalUserNameModel *> *)list {
    // 使用NSSortDescriptor对createTime进行降序排序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createTime" ascending:NO];
    [list sortUsingDescriptors:@[sortDescriptor]];
}

@end
