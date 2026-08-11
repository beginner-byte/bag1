//
//  NoaSessionTopView.h
//  NoaKit
//
//  Created by Candy on 2026/9/23.
//

// 会话列表VC 顶部View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZSessionTopAddBlock) (ZSessionMoreActionType actionType);
typedef void (^ZSessionTopSearchBlock) (void);
typedef void (^ZSessionTopAvatarTapBlock) (void);

@interface NoaSessionTopView : UIView
@property (nonatomic, copy) ZSessionTopSearchBlock searchBlock;
@property (nonatomic, copy) ZSessionTopAddBlock addBlock;
@property (nonatomic, copy) ZSessionTopAvatarTapBlock avatarTapBlock;
@property (nonatomic, assign) BOOL showLoading;

@property (nonatomic, assign, readonly) BOOL isHome;
/// 首页顶部区域高度变化（展开/收起我的应用）
@property (nonatomic, copy, nullable) void (^layoutHeightDidChangeBlock)(CGFloat height);

- (instancetype)initWithHome:(BOOL)isHome;
/// 第一行（状态栏下标题栏）高度
+ (CGFloat)preferredFirstRowHeightIsHome:(BOOL)isHome;
/// 联系人页：仅第一行
+ (CGFloat)preferredHeightForContact;
/// 首页：第一行 + 我的应用入口（展开时再加面板高度）
+ (CGFloat)preferredHeightForHome:(BOOL)miniAppExpanded;
- (void)viewAppearUpdateUI;
@end

NS_ASSUME_NONNULL_END
