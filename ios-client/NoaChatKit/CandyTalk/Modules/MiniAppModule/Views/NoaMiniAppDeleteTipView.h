//
//  NoaMiniAppDeleteTipView.h
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaMiniAppDeleteTipView : UIView

@property (nonatomic, copy) void(^sureBtnBlock)(void);   //确定按钮Block
@property (nonatomic, copy) void(^cancelBtnBlock)(void);   //取消按钮Block

- (void)tipViewSHow;
- (void)tipViewDismiss;

@end

NS_ASSUME_NONNULL_END
