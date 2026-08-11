//
//   .h
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZMessageInputViewType) {
    ZMessageInputViewTypeSimple,       //简易类型(左边textField，右边清除按钮)
    ZMessageInputViewTypeNomal,        //常规类型(左边图标，中间textField，右边清除按钮)
    ZMessageInputViewTypePhone,        //手机号类型(左边图标+国家区号+分割线，中间textField，右边清除按钮)
    ZMessageInputViewTypePassword,     //密码类型(左边图标，中间textField显示为※，右边小眼睛按钮、清除按钮)
    ZMessageInputViewTypeVercode,      //验证码类型(左边图标，中间textField，右边清除按钮、获取验证码按钮)
    ZMessageInputViewTypeNoCancel,     //不带一键清空text功能(左边图标，右边textField)
};

@interface NoaInputTextView : UIView

//输入框的类型
@property (nonatomic, assign)ZMessageInputViewType inputType;
//输入框左边的图标图片
@property (nonatomic, copy)NSString *tipsImgName;
//phone类型的输入框，设置默认展示的CountryCode
@property (nonatomic, copy)NSString *countryCodeStr;
//输入框
@property (nonatomic, strong, readonly)UITextField *inputText;
//输入框默认提示语
@property (nonatomic, copy) NSString *placeholderText;
//预输入值，比如：本地存储的登录账号，这样可以处理是否显示clearButton和设置isEmpty的值
@property (nonatomic, copy) NSString *preInputText;
//判断textField是否为空
@property (nonatomic, assign)BOOL isEmpty;
//textField内容发生改变时，通过block通知外部
@property (nonatomic, copy) void(^inputStatus)(void);
//textField结束输入(失去焦点)，通过block通知外部
@property (nonatomic, copy) void(^textFieldEndInput)(void);
//获取验证码点击事件
@property (nonatomic, copy) void(^getVerCodeBlock)(void);
//phone类型时，选择国家区号
@property (nonatomic, copy) void(^getCountryCodeAction)(void);
//实时获取当前输入框的内容字符串长度
@property (nonatomic, assign)NSUInteger textLength;
//textField键盘类型
@property (nonatomic, assign)UIKeyboardType inputKeyBoardType;
//是否显示蓝色边框
@property (nonatomic, assign)BOOL isShowBoard;
//输入框背景色(浅色模式、暗黑模式)
@property (nonatomic, strong)NSArray *bgViewBackColor;
//是否是SSO输入框(只能输入或粘贴 数字或字母)
@property (nonatomic, assign)BOOL isSSO;
//是否是创建/修改密码的输入框(只能输入或粘贴 数字+字母+特殊字符)
@property (nonatomic, assign)BOOL isPassword;
//是否还可编辑
@property (nonatomic, assign)BOOL enableEdit;

//设置"获取验证码"按钮为倒计时状态
- (void)configVercodeBtnCountdown;
//获取当前选中的CountryCode
- (NSString *)getCurrentCountryCode;

@end

NS_ASSUME_NONNULL_END
