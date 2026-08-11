//
//  NoaFriendGroupDeleteView.h
//  NoaKit
//
//  Created by Candy on 2023/7/4.
//

// 删除 好友分组 View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZFriendGroupDeleteViewDelegate <NSObject>
- (void)friendGroupDelete:(LingIMFriendGroupModel *)friendGroupDelete;
@end

@interface NoaFriendGroupDeleteView : UIView

@property (nonatomic, weak) id <ZFriendGroupDeleteViewDelegate> delegate;
@property (nonatomic, strong) LingIMFriendGroupModel *friendGroupModel;

- (void)deleteViewShow;
- (void)deleteViewDismiss;
@end

NS_ASSUME_NONNULL_END
