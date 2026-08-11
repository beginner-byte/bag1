//
//  NoaFriendGroupAddView.h
//  NoaKit
//
//  Created by Candy on 2023/7/4.
//

// 添加 好友分组 View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZFriendGroupAddViewDelegate <NSObject>
- (void)friendGroupAdd;
@end

@interface NoaFriendGroupAddView : UIView

@property (nonatomic, weak) id <ZFriendGroupAddViewDelegate> delegate;

- (void)addViewShow;
- (void)addViewDismiss;

@end

NS_ASSUME_NONNULL_END
