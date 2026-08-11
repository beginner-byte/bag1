//
//  NoaMassMessageGroupEntranceView.h
//  NoaKit
//
//  Created by Candy on 2023/9/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GroupEntranceViewDelegate <NSObject>

- (void)GroupEntranceAction;

@end

@interface NoaMassMessageGroupEntranceView : UIView

@property (nonatomic, weak) id <GroupEntranceViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
