//
//  NoaTranslateChannelLanguageModel.h
//  NoaKit
//
//  Created by Candy on 2024/8/7.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaTranslateLanguageModel : NoaBaseModel

@property(nonatomic, copy)NSString *slug;//语种类型
@property(nonatomic, copy)NSString *name;//语种名称
@property(nonatomic, copy)NSString *inner;
@property(nonatomic, assign)BOOL target;
@property(nonatomic, assign)BOOL popular;

@end


@interface NoaTranslateChannelLanguageModel : NoaBaseModel

@property(nonatomic, copy)NSString *channelId;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, assign)NSInteger qps;
@property(nonatomic, strong)NSArray *lang_table;

@end

NS_ASSUME_NONNULL_END
