//
//  NoaAlertTipView.h
//  NoaKit
//
//  Created by Candy on 2026/9/19.
//

#import <UIKit/UIKit.h>
//#import <YYText/YYLabel.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaAlertTipView : UIView

@property (nonatomic, strong) UILabel *lblTitle;    //标题
@property (nonatomic, strong) YYLabel *lblContent;  //内容
@property (nonatomic, strong) UIButton *btnCancel;  //取消按钮
@property (nonatomic, strong) UIButton *btnSure;    //确定按钮
@property (nonatomic, copy) void(^sureBtnBlock)(void);   //确定按钮Block
@property (nonatomic, copy) void(^cancelBtnBlock)(void);   //取消按钮Block

- (void)alertTipViewSHow;
- (void)alertTipViewDismiss;

@end

NS_ASSUME_NONNULL_END
