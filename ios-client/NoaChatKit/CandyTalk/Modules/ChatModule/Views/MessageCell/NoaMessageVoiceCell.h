//
//  NoaMessageVoiceCell.h
//  NoaKit
//
//  Created by Candy on 2023/1/5.
//

#import "NoaMessageContentBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMessageVoiceCell : NoaMessageContentBaseCell

@property(nonatomic, assign, readonly) BOOL isAnimation;

- (void)startAnimation;
- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
