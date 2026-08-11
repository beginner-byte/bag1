//
//  NoaTranslateDefaultModel.h
//  NoaKit
//
//  Created by Candy on 2024/2/18.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaTranslateDefaultModel : NoaBaseModel
@property(nonatomic, copy)NSString *sendChannel;
@property(nonatomic, copy)NSString *sendChannelName;
@property(nonatomic, copy)NSString *sendTargetLang;
@property(nonatomic, copy)NSString *sendTargetLangName;
@property(nonatomic, copy)NSString *receiveChannel;
@property(nonatomic, copy)NSString *receiveChannelName;
@property(nonatomic, copy)NSString *receiveTargetLang;
@property(nonatomic, copy)NSString *receiveTargetLangName;
@end

NS_ASSUME_NONNULL_END
