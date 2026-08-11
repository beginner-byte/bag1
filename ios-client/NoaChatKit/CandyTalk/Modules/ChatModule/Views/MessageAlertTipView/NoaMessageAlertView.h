//
//  NoaMessageAlertView.h
//  NoaKit
//
//  Created by Candy on 2026/10/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZMessageAlertType) {
    ZMessageAlertTypeNomal = 1,         //常规提示框(不带标题、不带复选框)
    ZMessageAlertTypeCheckBox = 2,      //消息提示框(带复选框、不带标题)
    ZMessageAlertTypeTitle = 3,         //消息提示框(带标题)
    ZMessageAlertTypeSingleBtn = 4,     //消息提示框(带标题，只有一个“我知道了的弹窗”)
    ZMessageAlertTypeTitleCheckBox = 5,      //消息提示框(带复选框、待标题)
    ZMessageAlertTypeTitleCheckBoxAboveButton = 6,      //消息提示框(带标题、带复选框，复选框在按钮上方)
};

@interface NoaMessageAlertView : UIView

@property (nonatomic, strong) UILabel *lblTitle;        //提示标题
@property (nonatomic, strong) UILabel *lblContent;      //提示内容
@property (nonatomic, strong) UIButton *btnCancel;      //取消按钮
@property (nonatomic, strong) UIButton *btnSure;        //确定按钮
@property (nonatomic, copy) void(^sureBtnBlock)(BOOL isCheckBox);   //确定按钮Block
@property (nonatomic, copy) void(^cancelBtnBlock)(void);            //取消按钮Block
@property (nonatomic, strong) UILabel *checkboxLblContent;    //复选框后面的文本内容
@property (nonatomic, assign)BOOL isSelectCheckBox;           //复选框的选中状态
@property (nonatomic, assign)BOOL isShow;           //是否已经显示在屏幕上了
@property (nonatomic, assign)BOOL showClose;           //是否显示右上角关闭按钮
@property (nonatomic, assign) BOOL isSizeDivide;

- (instancetype)initWithMsgAlertType:(ZMessageAlertType)alertType supView:(UIView * _Nullable)supView;
- (void)alertShow;
- (void)alertDismiss;

@end

NS_ASSUME_NONNULL_END
