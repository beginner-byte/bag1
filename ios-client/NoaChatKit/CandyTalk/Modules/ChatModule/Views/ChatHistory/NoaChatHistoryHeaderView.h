//
//  NoaChatHistoryHeaderView.h
//  NoaKit
//
//  Created by Candy on 2024/8/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatHistoryHeaderViewDelegate <NSObject>
//点击
- (void)headerClickAction;
//重置
- (void)headerResetAction;

@end

@interface NoaChatHistoryHeaderView : UIView

@property (nonatomic, strong) NSMutableArray *userInfoList;
@property (nonatomic, weak) id <ZChatHistoryHeaderViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
