//
//  NoaEmojiPackageDetailViewController.h
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "CandyBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaEmojiPackageDetailViewController : CandyBaseViewController

@property (nonatomic, assign) NSInteger supIndex;
@property (nonatomic, copy) NSString *stickersId;
@property (nonatomic, copy) NSString *stickersSetId;//表情包Id
@property (nonatomic, copy) void(^packageAddClick)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
