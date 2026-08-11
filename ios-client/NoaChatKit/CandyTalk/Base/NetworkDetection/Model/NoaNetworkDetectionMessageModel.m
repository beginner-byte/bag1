//
//  NoaNetworkDetectionMessageModel.m
//  NoaChatKit
//
//  Created by phl on 2025/10/15.
//  TODO: 网络检测 - 信息数据

#import "NoaNetworkDetectionMessageModel.h"

@implementation NoaNetworkDetectionSubResultModel

@end

@implementation NoaNetworkDetectionMessageModel

// MARK: set/get
- (NSMutableArray<NoaNetworkDetectionSubResultModel *> *)subFunctionResultArr {
    if (!_subFunctionResultArr) {
        _subFunctionResultArr = [NSMutableArray new];
    }
    return _subFunctionResultArr;
}

- (RACSubject *)changeStatusSubject {
    if (!_changeStatusSubject) {
        _changeStatusSubject = [RACSubject subject];
    }
    return _changeStatusSubject;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFinish = NO;
        self.isFold = YES;
    }
    return self;
}

- (BOOL)isAllSubFunctionPass {
    // 空数组情况处理
    if (self.subFunctionResultArr.count == 0) {
        return YES;
    }
    
    if (self.sectionType == ZNetworkDetectionNetworkConnectSectionType) {
        // 网络连接：要求全部通过
        for (NoaNetworkDetectionSubResultModel *subResult in self.subFunctionResultArr) {
            if (!subResult.isPass) {
                return NO;
            }
        }
        return YES;
    } else {
        // 其他类型：有一个通过即认为通过
        for (NoaNetworkDetectionSubResultModel *subResult in self.subFunctionResultArr) {
            if (subResult.isPass) {
                return YES;
            }
        }
        return NO; // 全部失败则返回 NO
    }
}

@end
