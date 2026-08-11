//
//  NoaSheetInputView.h
//  NoaKit
//
//  Created by Candy on 2023/1/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaSheetInputView : UIView
- (instancetype)initWithFrame:(CGRect)frame titleStr:(NSString *)titleStr remarkStr:(NSString *)remarkStr desStr:(NSString *)desStr ;
@property (nonatomic, copy) void(^saveBtnBlock)(NSString * remarkStr,NSString * desStr);   //确定按钮Block
@property (nonatomic, copy) void(^cancelBtnBlock)(void);   //取消按钮Block

- (void)inputViewSHow;
- (void)inputViewDismiss;
@end

NS_ASSUME_NONNULL_END
