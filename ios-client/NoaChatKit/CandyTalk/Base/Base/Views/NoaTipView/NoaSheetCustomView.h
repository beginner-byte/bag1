//
//  NoaSheetCustomView.h
//  NoaKit
//
//  Created by Candy on 2026/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaSheetCustomView : UIView
- (instancetype)initWithFrame:(CGRect)frame titleStr:(NSString *)titleStr itemArr:(NSArray *)itemArr;
@property (nonatomic, copy) void(^sureBtnBlock)(NSInteger index);   //确定按钮Block
@property (nonatomic, copy) void(^cancelBtnBlock)(void);   //取消按钮Block

- (void)customViewSHow;
- (void)customViewDismiss;
@end

NS_ASSUME_NONNULL_END
