//
//  NoaGroupNoticeListView.h
//  NoaKit
//
//  Created by phl on 2025/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NoaGroupNoticeListDataHandle;
@interface NoaGroupNoticeListView : UIView

/// 初始化群公告列表
/// - Parameters:
///   - frame: frame布局
///   - dataHandle: 处理群公告列表数据
- (instancetype)initWithFrame:(CGRect)frame
    GroupNoticeListDataHandle:(NoaGroupNoticeListDataHandle *)dataHandle;

/// 刷新公告列表
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
