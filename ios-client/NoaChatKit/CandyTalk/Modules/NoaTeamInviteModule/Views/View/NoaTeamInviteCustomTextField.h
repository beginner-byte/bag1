//
//  NoaTeamInviteCustomTextField.h
//  NoaKit
//
//  Created by phl on 2025/8/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaTeamInviteCustomTextField : UIView

/// 输入框
@property (nonatomic, strong, readonly) UITextField *textField;

/// 是否展示清楚按钮
@property (nonatomic, assign) BOOL isShowClearButton;

@end

NS_ASSUME_NONNULL_END
