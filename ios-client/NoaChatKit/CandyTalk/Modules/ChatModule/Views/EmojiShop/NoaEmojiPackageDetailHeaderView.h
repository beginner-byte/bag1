//
//  NoaEmojiPackageDetailHeaderView.h
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZEmojiPackageDetailHeaderViewDelegate <NSObject>

- (void)addStrickersPackageAction;

@end

@interface NoaEmojiPackageDetailHeaderView : UICollectionReusableView

@property (nonatomic, strong) NoaIMStickersPackageModel *model;
@property (nonatomic, weak) id <ZEmojiPackageDetailHeaderViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
