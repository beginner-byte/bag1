//
//  NoaImgVerCodeView.h
//  NoaKit
//
//  Created by Candy on 2026/9/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaImgVerCodeView : UIView

@property (nonatomic, copy)NSString *imgCodeStr;

@property (nonatomic, copy) NSString *loginName;

@property (nonatomic, assign) NSInteger verCodeType;

@property (nonatomic, copy) void(^sureBtnBlock)(NSString *imgCode);

@property (nonatomic, copy) void(^cancelBtnBlock)(void);

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
