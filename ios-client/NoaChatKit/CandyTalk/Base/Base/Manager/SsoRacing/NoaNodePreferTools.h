//
//  NoaNodePreferTools.h
//  NoaKit
//
//  Created by Candy on 2024/10/24.
//

#import <Foundation/Foundation.h>
#import "NoaNetRacingModel.h"

NS_ASSUME_NONNULL_BEGIN

//节点竞速接口
#define App_Http_Node_Prefer_Url      @"/zlcpig"

@interface NoaNodePreferTools : NSObject

@property (nonatomic, copy)NSString *liceseId;
@property (nonatomic, assign)NSInteger preferDuring;
@property (nonatomic, strong)NSArray<NoaNetRacingItemModel *> *httpArr;

- (void)startNodePrefer;

@end

NS_ASSUME_NONNULL_END
