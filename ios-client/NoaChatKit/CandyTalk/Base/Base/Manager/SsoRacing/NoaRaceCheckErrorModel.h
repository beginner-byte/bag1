//
//  NoaRaceCheckErrorModel.h
//  NoaKit
//
//  Created by Candy on 2024/5/11.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaRaceCheckErrorModel : NoaBaseModel

@property (nonatomic, copy)NSString *host;
@property (nonatomic, copy)NSString *url;
@property (nonatomic, copy)NSString *serverMsg;
@property (nonatomic, copy)NSString *traceId;
@property (nonatomic, copy)NSString *httpCode;
@property (nonatomic, assign)NSInteger sort;

@end

NS_ASSUME_NONNULL_END
