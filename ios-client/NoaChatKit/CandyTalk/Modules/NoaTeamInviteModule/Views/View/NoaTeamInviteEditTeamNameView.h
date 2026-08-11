//
//  NoaTeamInviteEditTeamNameView.h
//  NoaKit
//
//  Created by phl on 2025/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NoaTeamInviteEditTeamNameDataHandle;
@interface NoaTeamInviteEditTeamNameView : UIView

/// 初始化ZTeamInviteEditTeamNameView
/// - Parameters:
///   - frame: frame
///   - dataHandle: 数据处理类
- (instancetype)initWithFrame:(CGRect)frame
       editTeamNameDataHandle:(NoaTeamInviteEditTeamNameDataHandle *)dataHandle;

@end

NS_ASSUME_NONNULL_END
