//
//  NoaWeakPwdCheckTool.m
//  NoaChatKit
//
//  Created by blackcat on 2025/10/13.
//

#import "NoaWeakPwdCheckTool.h"
#import "NoaMessageAlertView.h"
#import "NoaPwdWeakCheckModel.h"
#import "NoaChatKit-Swift.h"
#import "LXChatEncrypt.h"


static NSString *const ZPwdWeakCheckModelTypePasswordEqAccount = @"PASSWORD_EQ_ACCOUNT";
static NSString *const ZPwdWeakCheckModelTypeWeekPassword = @"WEAK_PASSWORD";

@interface NoaWeakPwdCheckTool ()
@property (nonatomic, strong) NoaPwdWeakCheckModel *pwdWeakCheckModel;
@end

@implementation NoaWeakPwdCheckTool

// 单例实现
+ (instancetype)sharedInstance {
    static NoaWeakPwdCheckTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NoaWeakPwdCheckTool alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _userPwd = nil;
    }
    return self;
}

- (void)getEncryptKeyWithCompletion: (void(^)(NSString *encryptKey))completion {
    [IMSDKManager authGetEncryptKeySuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            //调用注册接口，传入加密密钥
            if([data isKindOfClass:[NSString class]]){
                NSString *encryptKey = (NSString *)data;
                if (completion) {
                    completion(encryptKey);
                }
            }
        }];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            if (completion) {
                completion(nil);
            }
        }];
        
    }];
}

- (void)checkPwdStrengthWithCompletion: (void(^)(BOOL doNext))completion {
    [self getEncryptKeyWithCompletion:^(NSString *encryptKey) {
        if (![NSString isNil:encryptKey]) {
            [self alertCheckPwdStrengthWithEncryptKey:encryptKey completion:completion];
        } else {
            completion(false);
        }
    }];
}
  

- (void)alertCheckPwdStrengthWithEncryptKey: (NSString *)encryptKey completion: (void(^)(BOOL doNext))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    if (![NSString isNil:self.userPwd] && ![NSString isNil:encryptKey]) {
        // 在工具内部加密密码 - 先拼接encryptKey和密码，再加密
        NSString *passwordKey = [NSString stringWithFormat:@"%@%@", encryptKey, self.userPwd];
        NSString *encryptedPassword = [LXChatEncrypt method4:passwordKey];
        [params setObjectSafe:encryptedPassword forKey:@"password"];
        [params setObjectSafe:encryptKey forKey:@"encryptKey"];
        self.userPwd = nil;
    }
    WeakSelf
    [IMSDKManager authCheckPasswordStrengthWith:params onSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            weakSelf.pwdWeakCheckModel = [NoaPwdWeakCheckModel mj_objectWithKeyValues:data];
            BOOL forcedPasswordReset = weakSelf.pwdWeakCheckModel.roleConfigMap.forcedPasswordReset;
            BOOL showAlert = NO;
            if (weakSelf.pwdWeakCheckModel.isWeakPassword) {
                if (params[@"password"] && !forcedPasswordReset) {
                    showAlert = YES;
                } else if (forcedPasswordReset) {
                    showAlert = YES;
                } else {
                    showAlert = NO;
                }
            } else {
                showAlert = NO;
            }
            if (completion) {
                completion(showAlert);
            }
        }];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [ZTOOL doInMain:^{
            if (completion) {
                completion(NO);
            }
        }];
        
    }];
}

- (void)alertChangePwdTipView  {
    NSString *content = LanguageToolMatch(@"弱密码提示");

    if ([self.pwdWeakCheckModel.type isEqualToString:ZPwdWeakCheckModelTypePasswordEqAccount]) {
        content = LanguageToolMatch(@"密码与账户名一致提示");
    } else if ([self.pwdWeakCheckModel.type isEqualToString:ZPwdWeakCheckModelTypeWeekPassword]) {
        content = LanguageToolMatch(@"弱密码提示");
    } else {
        return;
    }
    BOOL isForcedReset = self.pwdWeakCheckModel.roleConfigMap.forcedPasswordReset;

    ZMessageAlertType alertType = isForcedReset ? ZMessageAlertTypeSingleBtn : ZMessageAlertTypeTitle;

    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:alertType supView:nil];
    msgAlertView.lblTitle.text = LanguageToolMatch(@"安全提醒");
    msgAlertView.lblContent.text = content;
    msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"去修改") forState:UIControlStateNormal];
    [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    [msgAlertView alertShow];
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
      [self requestCheckUserHasSetPwd];
    };
}

- (void)requestCheckUserHasSetPwd {
    CoHerePasswordSettingViewController *oldPasswordVC = [[CoHerePasswordSettingViewController alloc] init];
    // 传递强制重置标记以控制返回按钮与手势
    BOOL isForcedReset = self.pwdWeakCheckModel.roleConfigMap.forcedPasswordReset;
    oldPasswordVC.isForcedReset = isForcedReset;
    oldPasswordVC.requiresOldPassword = YES;
    [self.currentNavigationController pushViewController:oldPasswordVC animated:YES];
}
@end
