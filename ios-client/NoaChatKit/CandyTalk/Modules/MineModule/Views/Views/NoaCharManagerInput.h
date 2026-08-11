//
//  NoaCharManagerInput.h
//  NoaKit
//
//  Created by Candy on 2023/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZCharManagerInputType) {
    ZCharManagerInputTypeNomal,       //常规类型(左边标题，中间textField，右边清除按钮)
    ZCharManagerInputTypeVercode,     //验证码类型(左边标题，中间textField，右边清除按钮、获取验证码按钮)
};

@interface NoaCharManagerInput : UIView

//输入框的类型
@property (nonatomic, assign) ZCharManagerInputType inputType;
//左边标题
@property (nonatomic, copy) NSString *leftTitleStr;
//输入框
@property (nonatomic, strong, readonly) UITextField *inputText;
//输入框默认占位提示语
@property (nonatomic, copy) NSString *placeholderText;
//判断textField是否为空
@property (nonatomic, assign)BOOL isEmpty;
//textField内容发生改变时，通过block通知外部
@property (nonatomic, copy) void(^inputStatus)(void);
//textField结束输入(失去焦点)，通过block通知外部
@property (nonatomic, copy) void(^textFieldEndInput)(void);
//获取验证码点击事件
@property (nonatomic, copy) void(^getVerCodeBlock)(void);
//实时获取当前输入框的内容字符串长度
@property (nonatomic, assign)NSUInteger textLength;
//textField键盘类型
@property (nonatomic, assign)UIKeyboardType inputKeyBoardType;

- (void)configVercodeBtnCountdown;

@end

NS_ASSUME_NONNULL_END
