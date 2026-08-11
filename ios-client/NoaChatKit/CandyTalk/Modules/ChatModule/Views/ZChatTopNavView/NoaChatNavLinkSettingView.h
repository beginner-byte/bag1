//
//  NoaChatNavLinkSettingView.h
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import <UIKit/UIKit.h>
#import "SyncMutableArray.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatNavLinkSettingDelegate <NSObject>

- (void)deleteAction:(NSInteger)index;
- (void)editAction:(NSInteger)index;

@end

@interface NoaChatNavLinkSettingView : UIView

@property (nonatomic, weak) id<ZChatNavLinkSettingDelegate>delegate;

- (void)linkSettingViewShow;
- (void)linkSettingViewDismiss;
- (void)configLinkListData:(NSMutableArray *)dataList;

@end

NS_ASSUME_NONNULL_END
