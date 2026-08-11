//
//  NoaGroupMyNicknameVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/11.
//

#import "NoaGroupMyNicknameVC.h"
#import "NoaToolManager.h"
@interface NoaGroupMyNicknameVC () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *tvNickname;
@property (nonatomic, strong) UILabel *lblNumber;

@end

@implementation NoaGroupMyNicknameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitleStr = LanguageToolMatch(@"我的群昵称");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    [self setupNavUI];
    [self setupUI];
}

#pragma mark - 界面布局
- (void)setupNavUI {
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setTitle:LanguageToolMatch(@"保存") forState:UIControlStateNormal];
    [self.navBtnRight setTitleColor:COLORWHITE forState:UIControlStateNormal];
    [self.navBtnRight setBackgroundColor:COLOR_5966F2];
    self.navBtnRight.layer.cornerRadius = DWScale(12);
    self.navBtnRight.layer.masksToBounds = YES;
    [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(32));
        CGSize textSize = [self.navBtnRight.titleLabel.text sizeWithFont:FONTR(14) constrainedToSize:CGSizeMake(10000, DWScale(32))];
        make.width.mas_equalTo(MIN(textSize.width+DWScale(28), 60));

    }];
}

- (void)setupUI {
    UILabel *lblTip = [UILabel new];
    lblTip.text = LanguageToolMatch(@"我的群昵称");
    lblTip.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    lblTip.font = FONTR(12);
    [self.view addSubview:lblTip];
    [lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(16));
        make.leading.equalTo(self.view).offset(DWScale(16));
    }];
    
    UIView *viewNickname = [[UIView alloc] initWithFrame:CGRectMake(DWScale(16), DNavStatusBarH + DWScale(37), DScreenWidth - DWScale(32), DWScale(70))];
    viewNickname.layer.cornerRadius = DWScale(14);
    viewNickname.layer.masksToBounds = YES;
    viewNickname.tkThemebackgroundColors = @[COLORWHITE, COLOR_EEEEEE_DARK];
    [self.view addSubview:viewNickname];
    
    _tvNickname = [[UITextView alloc] initWithFrame:CGRectMake(DWScale(13), DWScale(0), DScreenWidth - DWScale(64), DWScale(44))];
//    _tvNickname.backgroundColor = UIColor.clearColor;
    _tvNickname.tkThemebackgroundColors = @[COLORWHITE, COLOR_EEEEEE_DARK];
    _tvNickname.font = FONTR(16);
    _tvNickname.delegate = self;
    _tvNickname.text = _groupInfoModel.nicknameInGroup;
    [viewNickname addSubview:_tvNickname];
    
    _lblNumber = [UILabel new];
    _lblNumber.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblNumber.font = FONTR(12);
    _lblNumber.text = [NSString stringWithFormat:@"%ld/30",_groupInfoModel.nicknameInGroup.length];
    [viewNickname addSubview:_lblNumber];
    [_lblNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(viewNickname).offset(-DWScale(10));
        make.bottom.equalTo(viewNickname).offset(-DWScale(10));
    }];
    
    if (_tvNickname.text.length <= 30 && ![_tvNickname.text isEqualToString:_groupInfoModel.nicknameInGroup]) {
        self.navBtnRight.enabled = YES;
        [self.navBtnRight setBackgroundColor:COLOR_5966F2];
    } else {
        self.navBtnRight.enabled = NO;
        [self.navBtnRight setBackgroundColor:COLOR_99];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSInteger maxFontNum = 30;//最大输入限制
    NSString *toBeString = textView.text;

    // 获取键盘输入模式
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { // zh-Hans代表简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [self.tvNickname markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self.tvNickname positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > maxFontNum) {
                self.tvNickname.text = [toBeString substringToIndex:maxFontNum];//超出限制则截取最大限制的文本
                _lblNumber.text = [NSString stringWithFormat:@"%ld/30",maxFontNum];
            } else {
                _lblNumber.text = [NSString stringWithFormat:@"%ld/30",toBeString.length];
            }
        }
    } else {// 中文输入法以外的直接统计
        if (toBeString.length > maxFontNum) {
            textView.text = [toBeString substringToIndex:maxFontNum];
            _lblNumber.text = [NSString stringWithFormat:@"%ld/30",maxFontNum];
        } else {
            _lblNumber.text = [NSString stringWithFormat:@"%ld/30",toBeString.length];
        }
    }
    if (toBeString.length > maxFontNum) {
        textView.text = [toBeString substringToIndex:maxFontNum];
        _lblNumber.text = [NSString stringWithFormat:@"%ld/30",maxFontNum];
    } else {
        _lblNumber.text = [NSString stringWithFormat:@"%ld/30",toBeString.length];
    }
    if (toBeString.length <= 30 && ![toBeString isEqualToString:_groupInfoModel.nicknameInGroup]) {
        self.navBtnRight.enabled = YES;
        [self.navBtnRight setBackgroundColor:COLOR_5966F2];
    } else {
        self.navBtnRight.enabled = NO;
        [self.navBtnRight setBackgroundColor:COLOR_99];
    }
}

// 用户输入时调用的方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.tvNickname) {
        if ([text isEqualToString:@"'"] || [text isEqualToString:@"’"]) {
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}

#pragma mark - 交互事件
- (void)navBtnRightClicked {
    NSString *nicknameStr = [_tvNickname.text trimString];
    
    if (nicknameStr.length <= 30 && ![nicknameStr isEqualToString:_groupInfoModel.nicknameInGroup]) {
        //修改我在本群的昵称
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:_groupInfoModel.groupId forKey:@"groupId"];
        [dict setValue:(![NSString isNil:nicknameStr] ? nicknameStr : UserManager.userInfo.nickname) forKey:@"groupNickname"];
        if (![NSString isNil:UserManager.userInfo.userUID]) {
            [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
        }
        WeakSelf
        [IMSDKManager groupMyNicknameWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            [HUD showMessage:LanguageToolMatch(@"修改成功")];
            weakSelf.groupInfoModel.nicknameInGroup = nicknameStr;
            if (weakSelf.myGroupNicknameChange) {
                weakSelf.myGroupNicknameChange();
            }
            //更新群成员信息
            [IMSDKManager imSdkCreatSaveGroupMemberTableWith:weakSelf.groupInfoModel.groupId syncGroupMemberSuccess:^{
            } syncGroupMemberFaiule:^{
            }];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }
}

@end
