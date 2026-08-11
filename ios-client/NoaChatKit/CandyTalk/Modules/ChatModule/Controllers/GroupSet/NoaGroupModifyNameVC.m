//
//  NoaGroupModifyNameVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/7.
//

#import "NoaGroupModifyNameVC.h"
#import "NoaGroupSetBasicInfoVC.h"

@interface NoaGroupModifyNameVC ()

@property (nonatomic,strong)UITextView * textView;
@property (nonatomic,strong)UILabel * numberLabel;

@end

@implementation NoaGroupModifyNameVC

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    [self setupNavUI];
    [self setupUI];
    
    //监听键盘，当键盘将要出现时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //当键盘将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange) name:UITextViewTextDidChangeNotification object:nil];
}

#pragma mark - 界面布局
- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"修改群名称");
    self.navTitleLabel.font = FONTB(18);
    self.navBtnRight.hidden = YES;
    [self.navBtnRight setTitle:LanguageToolMatch(@"保存") forState:UIControlStateNormal];
    [self.navBtnRight setTitleColor:COLORWHITE forState:UIControlStateNormal];
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [self.navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [self.navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
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
    UILabel * tipLabel = [UILabel new];
    tipLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    tipLabel.font = FONTR(12);
    tipLabel.text = LanguageToolMatch(@"群名称");
    [self.view addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navView.mas_bottom).offset(DWScale(16));
        make.leading.mas_equalTo(DWScale(16));
        make.height.mas_equalTo(DWScale(17));
    }];
    
    self.textView = [UITextView new];
    self.textView.layer.cornerRadius = 14;
    self.textView.clipsToBounds = YES;
    self.textView.font = FONTR(16);
    self.textView.text = self.groupInfoModel.groupName;
//    [self.textView addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.textView.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    self.textView.tkThemebackgroundColors = @[COLORWHITE,COLOR_EEEEEE_DARK];
    self.textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipLabel.mas_bottom).offset(DWScale(4));
        make.leading.mas_equalTo(DWScale(16));
        make.trailing.mas_equalTo(-DWScale(16));
        make.height.mas_equalTo(DWScale(70));
    }];
    
    self.numberLabel = [UILabel new];
    self.numberLabel.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    self.numberLabel.font = FONTR(12);
    self.numberLabel.text = @"0/30";
    self.numberLabel.textAlignment = NSTextAlignmentRight;
    self.numberLabel.hidden = YES;
    [self.view addSubview:self.numberLabel];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.textView.mas_trailing).offset(-DWScale(10));
        make.bottom.mas_equalTo(self.textView.mas_bottom).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(17));
    }];
}

- (void)navBtnRightClicked {
    [self requestChangeGroupName];
}

- (void)requestChangeGroupName{
    if ([NSString isNil:self.textView.text]) {
        [HUD showMessage:LanguageToolMatch(@"群名称不能为空")];
        return;
    }
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
    [dict setValue:[NSString stringWithFormat:@"%@",self.textView.text] forKey:@"groupName"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    
    [IMSDKManager changeGroupNameWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        BOOL dataResult = [data boolValue];
        if (dataResult) {
            [HUD showMessage:LanguageToolMatch(@"保存成功")];
            
            for (UIViewController * vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[NoaGroupSetBasicInfoVC class]]) {
                    NoaGroupSetBasicInfoVC * infoVc = (NoaGroupSetBasicInfoVC *)vc;
                    infoVc.groupInfoModel.groupName = [NSString stringWithFormat:@"%@",self.textView.text];
                    [infoVc reloadCurData];
                    [weakSelf.navigationController popToViewController:infoVc animated:YES];
                    break;
                }
            }
            
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//当键盘出现
-(void)keyboardWillShow:(NSNotification *)notification{
    self.numberLabel.hidden = NO;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/30",self.textView.text.length];
}
 
//当键盘退出
-(void)keyboardWillHide:(NSNotification *)notification{
    self.numberLabel.hidden = YES;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/30",self.textView.text.length];
}

- (void)textViewDidChange {
     // 判断是否存在高亮字符，如果有，则不进行字数统计和字符串截断
     UITextRange *selectedRange = self.textView.markedTextRange;
     UITextPosition *position = [self.textView positionFromPosition:selectedRange.start offset:0];
     if (position) {
         return;
     }

     // 判断是否超过最大字数限制，如果超过就截断
     if (self.textView.text.length > 30) {
         self.textView.text = [self.textView.text substringToIndex:30];
     }
    if ([self.textView.text isEqualToString:self.groupInfoModel.groupName] || [NSString isNil:self.textView.text]) {
        self.navBtnRight.hidden = YES;
    }else{
        self.navBtnRight.hidden = NO;
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/30",self.textView.text.length];
     // 剩余字数显示 UI 更新
}


@end
