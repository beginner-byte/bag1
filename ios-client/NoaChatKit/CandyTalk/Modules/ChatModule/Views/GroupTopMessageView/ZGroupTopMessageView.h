//
//  ZGroupTopMessageView.h
//  NoaChatKit
//
//  Created by Auto on 2025/1/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZGroupTopMessageView;

@protocol ZGroupTopMessageViewDelegate <NSObject>

/// 点击消息列表按钮
- (void)groupTopMessageViewDidClickListButton:(ZGroupTopMessageView *)view;

/// 点击定位按钮（在列表页面中）
- (void)groupTopMessageViewDidClickLocationButtonWithSmsgId:(NSString *)smsgId;

/// 点击整个 view 定位当前显示的消息
- (void)groupTopMessageViewDidClickView:(ZGroupTopMessageView *)view;

@end

@interface ZGroupTopMessageView : UIView

@property (nonatomic, weak) id<ZGroupTopMessageViewDelegate> delegate;

/// 更新置顶消息数据
/// @param dataArray 置顶消息数据数组，元素为字典，包含 smsgId、body、topType 等字段
/// @param sessionID 会话ID，用于查询本地数据库
- (void)updateWithTopMessages:(NSArray<NSDictionary *> *)dataArray sessionID:(NSString *)sessionID;

/// 隐藏/显示 View
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

/// 获取当前显示的消息的 smsgId
- (NSString *)currentSmsgId;

@end

NS_ASSUME_NONNULL_END

