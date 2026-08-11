//
//  NoaNetRacingModel.m
//  NoaKit
//
//  Created by Candy on 2023/5/16.
//

#import "NoaNetRacingModel.h"

@implementation NoaNetRacingItemModel
@end

@implementation NoaNetRacingHttpModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
                @"dnsList":[NoaNetRacingItemModel class],
                @"ipList":[NoaNetRacingItemModel class]
            };
}

@end

@implementation NoaNetRacingTcpModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
                @"dnsList":[NoaNetRacingItemModel class],
                @"ipList":[NoaNetRacingItemModel class]
            };
}

@end

@implementation NoaNetRacingEndpointsModel
@end

@implementation NoaNetRacingModel

- (NSArray *)httpArr {
    if (_httpArr == nil) {
        NSMutableArray *allHttpArr = [NSMutableArray array];
        [allHttpArr addObjectsFromArray:self.endpoints.http.ipList];
        [allHttpArr addObjectsFromArray:self.endpoints.http.dnsList];
        
        NSMutableDictionary<NSNumber *, NSMutableArray<NoaNetRacingItemModel *> *> *allItemDict = [NSMutableDictionary dictionary];
        // 遍历原始数组，将模型按照sort值分组
        for (NoaNetRacingItemModel *tempItem in allHttpArr) {
            NSNumber *sortValue = @(tempItem.sort);
            NSMutableArray<NoaNetRacingItemModel *> *array = allItemDict[sortValue];
            if (!array) {
                array = [NSMutableArray array];
                allItemDict[sortValue] = array;
            }
            [array addObjectIfNotNil:tempItem];
        }
        
        NSArray<NSNumber *> *sortedKeys = [[allItemDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray<NSArray<NoaNetRacingItemModel *> *> *sortedArrays = [NSMutableArray array];
        for (NSNumber *key in sortedKeys) {
            NSArray<NoaNetRacingItemModel *> *array = allItemDict[key];
            [sortedArrays addObjectIfNotNil:array];
        }
        
        _httpArr = [sortedArrays copy];
    }
    return _httpArr;
}

- (NSArray *)tcpArr {
    if (_tcpArr == nil) {
        NSMutableArray *allTcpArr = [NSMutableArray array];
        [allTcpArr addObjectsFromArray:self.endpoints.tcp.ipList];
        [allTcpArr addObjectsFromArray:self.endpoints.tcp.dnsList];
        
        NSMutableDictionary<NSNumber *, NSMutableArray<NoaNetRacingItemModel *> *> *allItemDict = [NSMutableDictionary dictionary];
        // 遍历原始数组，将模型按照sort值分组
        for (NoaNetRacingItemModel *tempItem in allTcpArr) {
            NSNumber *sortValue = @(tempItem.sort);
            NSMutableArray<NoaNetRacingItemModel *> *array = allItemDict[sortValue];
            if (!array) {
                array = [NSMutableArray array];
                allItemDict[sortValue] = array;
            }
            [array addObjectIfNotNil:tempItem];
        }
        
        NSArray<NSNumber *> *sortedKeys = [[allItemDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray<NSArray<NoaNetRacingItemModel *> *> *sortedArrays = [NSMutableArray array];
        for (NSNumber *key in sortedKeys) {
            NSArray<NoaNetRacingItemModel *> *array = allItemDict[key];
            [sortedArrays addObjectIfNotNil:array];
        }
        
        _tcpArr = [sortedArrays copy];
      
    }
    return _tcpArr;
}

- (NSArray *)httpNodeArr {
    if (_httpNodeArr == nil) {
        NSMutableArray *allHttpNodeArr = [NSMutableArray array];
        for (NoaNetRacingItemModel *itemModel in self.endpoints.http.dnsList) {
            [allHttpNodeArr addObject:itemModel.ip];
        }
        for (NoaNetRacingItemModel *itemModel in self.endpoints.http.ipList) {
            [allHttpNodeArr addObject:itemModel.ip];

        }
        _httpNodeArr = [allHttpNodeArr copy];
    }
    return _httpNodeArr;
}

@end



@implementation NoaHttpDNSLocalModel
@end

