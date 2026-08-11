//
//  LoginTypeMenuView.h
//  NoaKit
//
//  Created by Candy on 2023/3/25.
//

#import <UIKit/UIKit.h>
#import "NoaInputTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginTypeMenuView : UIView

@property (nonatomic, strong)NSArray *menuTypeArr;
@property (nonatomic, strong)NoaInputTextView *currentInputView;
@property (nonatomic, assign)int typeWay;
//切换登录方式
@property (nonatomic, copy) void(^switchLoginTypeBlock)(void);
//菜单栏输入框是否有内容
@property (nonatomic, copy) void(^menuInputStatus)(void);
//textField结束输入(失去焦点)，通过block通知外部
@property (nonatomic, copy) void(^menuTextEndInput)(void);
//phone类型时，选择国家区号
@property (nonatomic, copy) void(^getCountryCodeAction)(void);


@end

NS_ASSUME_NONNULL_END
