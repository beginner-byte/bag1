//
//  NoaSureCancelTipView.h
//  NoaKit
//
//  Created by Candy on 2026/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaSureCancelTipView : UIView
@property (nonatomic, strong) UILabel *lblTitle;    //标题
@property (nonatomic, strong) UILabel *lblContent;  //内容
@property (nonatomic, strong) UIButton *btnCancel;  //取消按钮
@property (nonatomic, strong) UIButton *btnSure;    //确定按钮
@property (nonatomic, copy) void(^sureBtnBlock)(void);   //确定按钮Block
@property (nonatomic, copy) void(^cancelBtnBlock)(void);   //取消按钮Block

- (void)tipViewSHow;
- (void)tipViewDismiss;
@end

NS_ASSUME_NONNULL_END
