//
//  NoaAppPermissionTipView.h
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

// 系统权限获取提示 View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaAppPermissionTipView : UIView
@property (nonatomic, strong) UILabel *lblTitle;//提示标题
@property (nonatomic, strong) UILabel *lblTip;//提示内容
@property (nonatomic, strong) UIButton *btnCancel;//取消
@property (nonatomic, strong) UIButton *btnOpen;//打开

//权限获取提示 展示
- (void)permissionTipViewSHow;
//权限获取提示 关闭
- (void)permissionTipViewDismiss;

@end

NS_ASSUME_NONNULL_END
