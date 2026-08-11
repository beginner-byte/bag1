//
//  NoaChatInputMoreView.h
//  NoaKit
//
//  Created by Candy on 2026/9/27.
//

// 聊天输入内容 更多 View 固定宽高128 * 176

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MoreViewDelegate <NSObject>
- (void)moreViewActionWith:(ZChatInputActionType)actionType;
@end

@interface NoaChatInputMoreView : UIView
@property (nonatomic, assign) ZChatInputViewType moreType;//控件类型
@property (nonatomic, strong) NSMutableArray *actionList;//功能列表
@property (nonatomic, weak) id <MoreViewDelegate> delegate;
@property (nonatomic, assign) CGFloat bottomH;//距离底部的高度

- (void)viewShow;
- (void)viewDismiss;
@end

NS_ASSUME_NONNULL_END
