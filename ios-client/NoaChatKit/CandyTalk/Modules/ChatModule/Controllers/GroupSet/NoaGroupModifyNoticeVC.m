//
//  NoaGroupModifyNoticeVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/11.
//

#import "NoaGroupModifyNoticeVC.h"
#import "noticeTranslateItemView.h"
#import "groupSetDorpView.h"
#import "NoaGroupNoticeTranslateVC.h"
#import "NoaMessageAlertView.h"
//#import "NoaCharacterBindViewController.h"
#import "NoaTranslateChannelLanguageModel.h"
#import "NoaChatViewController.h"
#import "NoaGroupNoticeListVC.h"

#define Notice_Content_Num_Max       1000

@interface NoaGroupModifyNoticeVC ()
@property (nonatomic,strong)UITextView *textView;
@property (nonatomic,strong)UILabel *numberLabel;
@property (nonatomic,strong)UILabel *placeHoderLabel;
@property (nonatomic,strong)UIButton *releaseButton;
@property (nonatomic,strong)UIButton *translateButton;
@property (nonatomic,strong)noticeTranslateItemView *channelInputView;
@property (nonatomic,strong)noticeTranslateItemView *languageInputView;
@property (nonatomic,strong)groupSetDorpView *channelDropView;
@property (nonatomic,strong)groupSetDorpView *languageDropView;
@property (nonatomic,strong)UIView *translateBgView; // 翻译父容器
@property (nonatomic,copy)NSString *channelCode;
@property (nonatomic,copy)NSString *channelName;
@property (nonatomic,strong)NSMutableArray *languageCodeList;
@property (nonatomic,strong)NSMutableArray *languageNameList;

// 声明内部方法，避免编译器可见性告警
- (void)applyTranslateFlag:(BOOL)enabled;

@end

@implementation NoaGroupModifyNoticeVC

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    NSLog(@"Block 是否存在: %@", self.groupNoticeSuccessBlock ? @"YES" : @"NO");
    self.channelCode = @"";
    self.channelName = @"";
    self.languageCodeList = [NSMutableArray arrayWithObject:@"en"];
    self.languageNameList = [NSMutableArray arrayWithObject:LanguageToolMatch(@"英文")];
    
    self.navTitleStr = LanguageToolMatch(@"群公告");
    [self setupUI];
    
    //监听键盘，当键盘将要出现时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //当键盘将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //监听textView输入内容发生变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange) name:UITextViewTextDidChangeNotification object:nil];
    // 翻译开关变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTranslateFlagChanged:) name:UserRoleAuthorityTranslateFlagDidChange object:nil];
    // 首屏按开关控制
    [self applyTranslateFlag:[UserManager isTranslateEnabled]];
}

- (void)onTranslateFlagChanged:(NSNotification *)note {
    BOOL enabled = [UserManager isTranslateEnabled];
    id val = note.userInfo[@"enabled"];
    if ([val isKindOfClass:[NSNumber class]]) {
        enabled = [((NSNumber *)val) boolValue];
    }
    [self applyTranslateFlag:enabled];
}

- (void)applyTranslateFlag:(BOOL)enabled {
    // 仅群主/管理员存在这些控件
    if (!(self.groupInfoModel.userGroupRole == 1 || self.groupInfoModel.userGroupRole == 2)) {
        return;
    }
    self.translateButton.hidden = !enabled;
    self.releaseButton.hidden = NO; // 原文发布不受开关影响
    self.channelInputView.hidden = !enabled;
    self.languageInputView.hidden = !enabled;
    // 下拉也一起隐藏
    self.channelDropView.hidden = !enabled;
    self.languageDropView.hidden = !enabled;
    // 父容器整体隐藏（含标题提示/注释）
    self.translateBgView.hidden = !enabled;
}

#pragma mark - 界面布局
- (void)setupUI {
    UILabel * tipLabel = [UILabel new];
    tipLabel.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    tipLabel.font = FONTR(12);
    tipLabel.numberOfLines = 0;
    tipLabel.text = LanguageToolMatch(@"群公告（仅群主和管理员可编辑）");
    [self.view addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navView.mas_bottom).offset(DWScale(16));
        make.leading.equalTo(self.view.mas_leading).offset(DWScale(16));
        make.trailing.equalTo(self.view.mas_trailing).offset(DWScale(-16));
    }];
    
    //群公告输入背景
    UIView * textBgView = [[UIView alloc] init];
    textBgView.layer.cornerRadius = 14;
    textBgView.clipsToBounds = YES;
    textBgView.tkThemebackgroundColors = @[COLORWHITE,COLOR_EEEEEE_DARK];
    [self.view addSubview:textBgView];
    
    //群公告输入框
    self.textView = [UITextView new];
    self.textView.layer.cornerRadius = 14;
    self.textView.clipsToBounds = YES;
    self.textView.font = FONTR(16);
    self.textView.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    self.textView.tkThemebackgroundColors = @[COLORWHITE,COLOR_EEEEEE_DARK];
    [textBgView addSubview:self.textView];
    
    //字数
    self.numberLabel = [UILabel new];
    self.numberLabel.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    self.numberLabel.font = FONTR(12);
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%d",self.textView.text.length, Notice_Content_Num_Max];
    self.numberLabel.textAlignment = NSTextAlignmentRight;
    [textBgView addSubview:self.numberLabel];
    
    //群公告输入框默认占位
    self.placeHoderLabel = [UILabel new];
    self.placeHoderLabel.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    self.placeHoderLabel.font = FONTR(16);
    self.placeHoderLabel.text = LanguageToolMatch(@"编辑群公告");
    self.placeHoderLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.placeHoderLabel];

    //群组/管理员
    if (self.groupInfoModel.userGroupRole == 1 ||self.groupInfoModel.userGroupRole == 2) {
        self.textView.editable = YES;
        
        //提交翻译
        self.translateButton = [[UIButton alloc] init];
        [self.translateButton setTitle:LanguageToolMatch(@"提交翻译") forState:UIControlStateNormal];
        [self.translateButton setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        [self.translateButton setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2]];
        self.translateButton.titleLabel.font = FONTN(14);
        [self.translateButton rounded:DWScale(8)];
        [self.translateButton addTarget:self action:@selector(confirmTranslateNoticeAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.translateButton];
        [self.translateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(-(DWScale(21) + DHomeBarH));
            make.leading.mas_equalTo(DWScale(16));
            make.trailing.mas_equalTo(-DWScale(16));
            make.height.mas_equalTo(DWScale(44));
        }];
    
        //直接发布
        self.releaseButton = [[UIButton alloc] init];
        [self.releaseButton setTitle:LanguageToolMatch(@"发布原文") forState:UIControlStateNormal];
        [self.releaseButton setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2] forState:UIControlStateNormal];
        [self.releaseButton setTkThemebackgroundColors:@[COLORWHITE, COLOR_11]];
        self.releaseButton.titleLabel.font = FONTN(14);
        [self.releaseButton rounded:DWScale(8) width:0.8 color:COLOR_5966F2];
        [self.releaseButton addTarget:self action:@selector(releaseOriginalNoticeAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.releaseButton];
        [self.releaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.translateButton.mas_top).offset(-DWScale(16));
            make.leading.mas_equalTo(DWScale(16));
            make.trailing.mas_equalTo(-DWScale(16));
            make.height.mas_equalTo(DWScale(44));
        }];
        
        //翻译选择通道和语种
        self.translateBgView = [[UIView alloc] init];
        self.translateBgView.layer.cornerRadius = 14;
        self.translateBgView.clipsToBounds = YES;
        self.translateBgView.tkThemebackgroundColors = @[COLORWHITE,COLOR_EEEEEE_DARK];
        [self.view addSubview:self.translateBgView];
        [self.translateBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.releaseButton.mas_top).offset(-DWScale(50));
            make.leading.mas_equalTo(DWScale(16));
            make.trailing.mas_equalTo(-DWScale(16));
        }];
        
        //顶部提示语
        UILabel *translateTopTipLabel = [UILabel new];
        translateTopTipLabel.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
        translateTopTipLabel.font = FONTR(12);
        translateTopTipLabel.numberOfLines = 0;
        translateTopTipLabel.text = LanguageToolMatch(@"选择群公告翻译通道和语种");
        [self.translateBgView addSubview:translateTopTipLabel];
        [translateTopTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.mas_equalTo(self.translateBgView).offset(DWScale(16));
            make.trailing.equalTo(self.translateBgView).offset(-DWScale(16));
        }];
        
        //通道
        UILabel *channelLbl = [UILabel new];
        channelLbl.tkThemetextColors = @[COLOR_11, COLORWHITE];
        channelLbl.font = FONTR(14);
        channelLbl.text = LanguageToolMatch(@"通道");
        [self.translateBgView addSubview:channelLbl];
        [channelLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(translateTopTipLabel.mas_bottom).offset(DWScale(27));
            make.leading.equalTo(self.translateBgView).offset(DWScale(16));
            make.width.mas_equalTo(DWScale(32));
            make.height.mas_equalTo(DWScale(18));
        }];
        
        self.channelInputView = [[noticeTranslateItemView alloc] init];
        self.channelInputView.contentStr = self.channelName;
        [self.translateBgView addSubview:self.channelInputView];
        [self.channelInputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(channelLbl);
            make.leading.equalTo(channelLbl.mas_trailing).offset(DWScale(10));
            make.trailing.equalTo(self.translateBgView).offset(-DWScale(16));
            make.height.mas_equalTo(DWScale(38));
        }];
        WeakSelf
        [self.channelInputView setTextInputClick:^{
            if (weakSelf.languageDropView) {
                [weakSelf.languageDropView dropViewDismiss];
            }
            if (!weakSelf.channelDropView) {
                weakSelf.channelDropView = [[groupSetDorpView alloc] initWithTranslateType:ZGroupNoticeTranslateTypeChannel channelCode:@"" selectedItemsCode:@[] selectedItemsName:@[]];
                CGRect targetFrame = [weakSelf.translateBgView convertRect:weakSelf.channelInputView.frame toView:weakSelf.view];
                weakSelf.channelDropView.frame = CGRectMake(targetFrame.origin.x, targetFrame.origin.y+DWScale(38), targetFrame.size.width, DWScale(150));
                [weakSelf.view addSubview:weakSelf.channelDropView];
            } else {
                if (weakSelf.channelDropView.isShow) {
                    [weakSelf.channelDropView dropViewDismiss];
                } else {
                    weakSelf.channelDropView.currentChannelCode = weakSelf.channelCode;
                    weakSelf.channelDropView.isShow = YES;
                    [weakSelf.view addSubview:weakSelf.channelDropView];
                    if (weakSelf.channelDropView.dataList == nil || weakSelf.channelDropView.dataList.count <= 0) {
                        [weakSelf.channelDropView setupData];
                    }
                }
            }
            [weakSelf.channelDropView setChannelSelectedBlock:^(NSString * _Nonnull itemId, NSString * _Nonnull itemName) {
                weakSelf.channelInputView.contentStr = itemName;
                weakSelf.channelCode = itemId;
                weakSelf.channelName = itemName;
                [weakSelf.languageCodeList removeAllObjects];
                [weakSelf.languageCodeList addObject:@"en"];
                [weakSelf.languageNameList removeAllObjects];
                [weakSelf.languageNameList addObject:LanguageToolMatch(@"英文")];
                weakSelf.languageInputView.contentStr = [weakSelf.languageNameList componentsJoinedByString:@"、"];
            }];
        }];
        
        //语种
        UILabel *languageLbl = [UILabel new];
        languageLbl.tkThemetextColors = @[COLOR_11, COLORWHITE];
        languageLbl.font = FONTR(14);
        languageLbl.text = LanguageToolMatch(@"语种");
        [self.translateBgView addSubview:languageLbl];
        [languageLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(channelLbl.mas_bottom).offset(DWScale(38));
            make.leading.mas_equalTo(self.translateBgView).offset(DWScale(16));
            make.width.mas_equalTo(DWScale(32));
            make.height.mas_equalTo(DWScale(18));
        }];
        
        self.languageInputView = [[noticeTranslateItemView alloc] init];
        if (![NSString isNil:self.channelCode]) {
            self.languageInputView.contentStr = [self.languageNameList componentsJoinedByString:@"、"];
        }
        [self.translateBgView addSubview:self.languageInputView];
        [self.languageInputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(languageLbl);
            make.leading.equalTo(languageLbl.mas_trailing).offset(DWScale(10));
            make.trailing.equalTo(self.translateBgView).offset(-DWScale(16));
            make.height.mas_equalTo(DWScale(38));
        }];
        [self.languageInputView setTextInputClick:^{
            if (weakSelf.channelDropView) {
                [weakSelf.channelDropView dropViewDismiss];
            }
            if (weakSelf.channelCode.length <= 0) {
                [HUD showMessage:LanguageToolMatch(@"请先选择翻译通道")];
                return;
            }
            if (!weakSelf.languageDropView) {
                weakSelf.languageDropView = [[groupSetDorpView alloc] initWithTranslateType:ZGroupNoticeTranslateTypeLanguage channelCode:weakSelf.channelCode selectedItemsCode:weakSelf.languageCodeList selectedItemsName:weakSelf.languageNameList];
                CGRect targetFrame = [weakSelf.translateBgView convertRect:weakSelf.languageInputView.frame toView:weakSelf.view];
                weakSelf.languageDropView.frame = CGRectMake(targetFrame.origin.x, targetFrame.origin.y+DWScale(38), targetFrame.size.width, DWScale(150));
                [weakSelf.view addSubview:weakSelf.languageDropView];
            } else {
                if (weakSelf.languageDropView.isShow) {
                    [weakSelf.languageDropView dropViewDismiss];
                } else {
                    weakSelf.languageDropView.currentLanguageCodeList = [weakSelf.languageCodeList copy];
                    weakSelf.languageDropView.currentLanguageNameList = [weakSelf.languageInputView.contentStr componentsSeparatedByString:@"、"];
                    weakSelf.languageDropView.isShow = YES;
                    [weakSelf.view addSubview:weakSelf.languageDropView];
                    if (weakSelf.languageDropView.dataList == nil || weakSelf.languageDropView.dataList.count <= 0) {
                        [weakSelf.languageDropView setupData];
                    }
                }
            }
            [weakSelf.languageDropView setLanguageSelectedBlock:^(NSArray * _Nonnull languageCodeList, NSArray * _Nonnull languageNameList) {
                [weakSelf.languageCodeList removeAllObjects];
                [weakSelf.languageCodeList addObjectsFromArray:languageCodeList];
                [weakSelf.languageNameList removeAllObjects];
                [weakSelf.languageNameList addObjectsFromArray:languageNameList];
                weakSelf.languageInputView.contentStr = [languageNameList componentsJoinedByString:@"、"];
            }];
        }];
        
        //底部提示语
        UILabel *translateBottomTipLabel = [UILabel new];
        translateBottomTipLabel.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
        translateBottomTipLabel.font = FONTR(12);
        translateBottomTipLabel.numberOfLines = 0;
        translateBottomTipLabel.text = LanguageToolMatch(@"注：未选择语种默认展示英文");
        [self.translateBgView addSubview:translateBottomTipLabel];
        [translateBottomTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(languageLbl.mas_bottom).offset(DWScale(21));
            make.leading.mas_equalTo(self.translateBgView).offset(DWScale(16));
            make.trailing.equalTo(self.translateBgView).offset(-DWScale(16));
            make.bottom.mas_equalTo(self.translateBgView.mas_bottom).offset(-DWScale(16));
        }];
        
        [textBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(tipLabel.mas_bottom).offset(DWScale(4));
            make.leading.mas_equalTo(DWScale(16));
            make.trailing.mas_equalTo(-DWScale(16));
            make.bottom.equalTo(self.translateBgView.mas_top).offset(-16);
        }];
    } else {
        self.textView.editable = NO;
        
        [textBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(tipLabel.mas_bottom).offset(DWScale(4));
            make.leading.mas_equalTo(DWScale(16));
            make.trailing.mas_equalTo(-DWScale(16));
            make.height.mas_equalTo(DWScale(268));
        }];
    }
   
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(textBgView).offset(DWScale(10));
        make.trailing.mas_equalTo(textBgView).offset(-DWScale(10));
        make.bottom.mas_equalTo(textBgView).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(textBgView).offset(DWScale(10));
        make.trailing.mas_equalTo(textBgView).offset(-DWScale(10));
        make.top.mas_equalTo(textBgView).offset(DWScale(10));
        make.bottom.mas_equalTo(self.numberLabel.mas_top).offset(-DWScale(6));
    }];
    
    [self.placeHoderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.textView.mas_leading).offset(DWScale(10));
        make.top.mas_equalTo(self.textView.mas_top).offset(DWScale(10));
        make.height.mas_equalTo(DWScale(17));
    }];
    
    if ([NSString isNil:self.groupInfoModel.groupNotice.groupId]) {
        self.placeHoderLabel.hidden = NO;
        self.textView.text = @"";
    }else{
        self.placeHoderLabel.hidden = YES;
        //群组/管理员
        if (self.groupInfoModel.userGroupRole == 1 ||self.groupInfoModel.userGroupRole == 2) {
            self.textView.text = [NSString stringWithFormat:@"%@",self.groupInfoModel.groupNotice.content];
        } else {
            //处理公告文字内容
            if (![NSString isNil:self.groupInfoModel.groupNotice.translateContent]) {
                NSString *currentLanguageMapCode = [ZLanguageTOOL languageCodeFromDevieInfo];
                NSDictionary *noticeDict = [NSString  jsonStringToDic:self.groupInfoModel.groupNotice.translateContent];
                if (![[noticeDict allKeys] containsObject:currentLanguageMapCode]) {
                    if ([currentLanguageMapCode isEqualToString:@"lb"]) {
                        self.textView.text = (NSString *)[noticeDict objectForKeySafe:@"lbb"];
                    } else if ([currentLanguageMapCode isEqualToString:@"no"]) {
                        self.textView.text = (NSString *)[noticeDict objectForKeySafe:@"nor"];
                    } else {
                        NSString *notice_en = (NSString *)[noticeDict objectForKeySafe:@"en"];
                        self.textView.text = notice_en;
                    }
                } else {
                    NSString *notice_current = (NSString *)[noticeDict objectForKeySafe:currentLanguageMapCode];
                    self.textView.text = notice_current;
                }
            } else {
                self.textView.text = self.groupInfoModel.groupNotice.content;
            }
        }
        self.numberLabel.text = [NSString stringWithFormat:@"%ld/%d",self.textView.text.length, Notice_Content_Num_Max];
    }
}

#pragma mark - Request
//请求翻译通道数据
- (void)requestGetTranslateChannel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:ZLanguageTOOL.currentLanguage.languageAbbr forKey:@"currentLang"];
    
    WeakSelf
    [IMSDKManager imSdkTranslateGetChannelLanguage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *dataArr = (NSArray *)data;
            NSArray *chanelModelList = [NoaTranslateChannelLanguageModel mj_objectArrayWithKeyValuesArray:dataArr];
            for (NoaTranslateChannelLanguageModel *tempChannelModel in chanelModelList) {
                if ([tempChannelModel.channelId isEqualToString:weakSelf.channelCode]) {
                    weakSelf.channelName = tempChannelModel.name;
                }
            }
            weakSelf.channelInputView.contentStr = weakSelf.channelName;
            if (weakSelf.channelDropView) {
                weakSelf.channelDropView.currentChannelCode = weakSelf.channelCode;
            }
            [weakSelf requestGetTranslateLanguage];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//请求支持的语种数据
- (void)requestGetTranslateLanguage {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_channelCode forKey:@"channelCode"];
    [dict setValue:ZLanguageTOOL.currentLanguage.languageAbbr forKey:@"currentLang"];
    
    WeakSelf
    [IMSDKManager imSdkTranslateGetChannelLanguage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *dataArr = (NSArray *)data;
            NSArray *languageModelList;
            NSArray *dataList = [NoaTranslateChannelLanguageModel mj_objectArrayWithKeyValuesArray:dataArr];
            for (NoaTranslateChannelLanguageModel *model in dataList) {
                if ([model.channelId isEqualToString:weakSelf.channelCode]) {
                    languageModelList = model.lang_table;
                }
            }
            for (NSString *languageCode in weakSelf.languageCodeList) {
                for (NoaTranslateLanguageModel *tempLanguageModel in languageModelList) {
                    if ([languageCode isEqualToString:tempLanguageModel.slug]) {
                        [weakSelf.languageNameList addObject:tempLanguageModel.name];
                    }
                }
            }
            if (![NSString isNil:weakSelf.channelCode]) {
                weakSelf.languageInputView.contentStr = [self.languageNameList componentsJoinedByString:@"、"];
                if (weakSelf.languageDropView)  {
                    weakSelf.languageDropView.currentLanguageCodeList = weakSelf.languageCodeList;
                    weakSelf.languageDropView.currentLanguageNameList = weakSelf.languageNameList;
                }
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];

    }];
}

#pragma mark - Action
//发布公告原文
- (void)releaseOriginalNoticeAction {
    if (self.channelDropView && self.channelDropView.isShow) {
        [self.channelDropView dropViewDismiss];
    }
    if (self.languageDropView && self.languageDropView.isShow) {
        [self.languageDropView dropViewDismiss];
    }
    [self.textView resignFirstResponder];
    
    if ([NSString isNil:self.textView.text]) {
        [HUD showMessage:LanguageToolMatch(@"公告不能为空")];
        return;
    }
    
    WeakSelf
    NoaPresentItem * sendToSessionItem= [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"发送至会话") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            sendToSessionItem.textColor = COLOR_11;
            sendToSessionItem.backgroundColor = COLORWHITE;
        }else {
            sendToSessionItem.textColor = COLORWHITE;
            sendToSessionItem.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentItem *displayTopSessionItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"在会话内置顶显示") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            displayTopSessionItem.textColor = COLOR_11;
            displayTopSessionItem.backgroundColor = COLORWHITE;
        }else {
            displayTopSessionItem.textColor = COLORWHITE;
            displayTopSessionItem.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentItem *sendTOSessionTop = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"发送至会话并置顶") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            sendTOSessionTop.textColor = COLOR_11;
            sendTOSessionTop.backgroundColor = COLORWHITE;
        }else {
            sendTOSessionTop.textColor = COLORWHITE;
            sendTOSessionTop.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentItem *cancelItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"取消") textColor:COLOR_99 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            cancelItem.textColor = COLOR_B3B3B3;
            cancelItem.backgroundColor = COLORWHITE;
        }else {
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLOR_11;
        }
    };
    NoaPresentView *viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[sendToSessionItem, displayTopSessionItem,sendTOSessionTop] cancleItem:cancelItem doneClick:^(NSInteger index) {
      
        if(index == 0){
            [weakSelf requestChangeGroupName:0 isSendMsg:1];
        }
        if(index == 1){
            [weakSelf requestChangeGroupName:1 isSendMsg:0];
        }
        if(index == 2){
            [weakSelf requestChangeGroupName:1 isSendMsg:1];
        }
    } cancleClick:^{
    }];
    [self.view addSubview:viewAlert];
    [viewAlert showPresentView];
}

//提交翻译
- (void)confirmTranslateNoticeAction {
    if (self.channelDropView && self.channelDropView.isShow) {
        [self.channelDropView dropViewDismiss];
    }
    if (self.languageDropView && self.languageDropView.isShow) {
        [self.languageDropView dropViewDismiss];
    }
    [self.textView resignFirstResponder];
    if (self.textView.text.length <= 0) {
        [HUD showMessage:LanguageToolMatch(@"请输入群公告内容！")];
        return;
    }
    if (self.channelCode.length <= 0 || self.languageCodeList.count <= 0) {
        [HUD showMessage:LanguageToolMatch(@"选择群公告翻译通道和语种")];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    NoaGroupNoticeTranslateVC *vc = [[NoaGroupNoticeTranslateVC alloc] init];
    vc.groupInfoModel = self.groupInfoModel;
    vc.originNoticeContent = [self.textView.text trimString];
    vc.channelCode = self.channelCode;
    vc.channelName = self.channelName;
    vc.languageCodeArr = self.languageCodeList;
    vc.languageNameArr = self.languageNameList;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
- (void)translateNoBindAccountTips {
    //弹出新的弹窗
    WeakSelf
    NoaMessageAlertView *translateAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
    translateAlertView.lblContent.text = LanguageToolMatch(@"您尚未绑定字符账号，无法使用翻译功能，请绑定后使用。");
    translateAlertView.lblContent.textAlignment = NSTextAlignmentCenter;
    [translateAlertView.btnSure setTitle:LanguageToolMatch(@"绑定账户") forState:UIControlStateNormal];
    [translateAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    translateAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    [translateAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [translateAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    translateAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    [translateAlertView alertShow];
    translateAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        //绑定账户-跳转到绑定账户VC
        NoaCharacterBindViewController *vc = [[NoaCharacterBindViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
}
*/

#pragma mark - Request
- (void)requestChangeGroupName:(NSInteger)topStatus isSendMsg:(NSInteger)isShowMsg{
    //判断如果没有群公告，先创建
    WeakSelf
    if (![NSString isNil:self.groupInfoModel.groupNotice.noticeId]) {
        if (![NSString isNil:self.textView.text]){
            //更新群公告
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
            [dict setValue:[NSString stringWithFormat:@"%@",self.textView.text] forKey:@"noticeContent"];
            [dict setValue:[NSString stringWithFormat:@"%ld",(long)topStatus] forKey:@"isTop"];
            [dict setValue:[NSString stringWithFormat:@"%ld",(long)isShowMsg] forKey:@"isSendMsg"];
            [dict setValue:[NSString stringWithFormat:@"%@",self.groupInfoModel.groupNotice.noticeId] forKey:@"noticeId"];
            [dict setValue:@"" forKey:@"translateContent"];
            if (![NSString isNil:UserManager.userInfo.userUID]) {
                [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            }
            [IMSDKManager groupChangeGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                if (weakSelf.groupNoticeSuccessBlock) {
                    weakSelf.groupNoticeSuccessBlock();
                }
                [weakSelf backAction];
                [HUD showMessage:LanguageToolMatch(@"编辑成功")];
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        } else {
            /**
             * TODO: 老版本代码如果没有输入内容，直接删除
             //删除群公告
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
             [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
             [dict setValue:[NSString stringWithFormat:@"%@",self.groupInfoModel.groupNotice.noticeId] forKey:@"noticeId"];
             if (![NSString isNil:UserManager.userInfo.userUID]) {
                 [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
             }
             [IMSDKManager groupDeleteGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                 [weakSelf.navigationController popViewControllerAnimated:YES];
                 [HUD showMessage:LanguageToolMatch(@"群公告移除成功")];
             } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                 [HUD showMessageWithCode:code errorMsg:msg];
             }];
             */
        }
    } else {
        if (![NSString isNil:self.textView.text]) {
            //创建群公告
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
            [dict setValue:[NSString stringWithFormat:@"%@",self.textView.text] forKey:@"noticeContent"];
            [dict setValue:[NSString stringWithFormat:@"%ld",(long)topStatus] forKey:@"isTop"];
            [dict setValue:[NSString stringWithFormat:@"%ld",(long)isShowMsg] forKey:@"isSendMsg"];
            [dict setValue:@"" forKey:@"translateContent"];
            if (![NSString isNil:UserManager.userInfo.userUID]) {
                [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            }
            [IMSDKManager groupCreateGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                if (weakSelf.groupNoticeSuccessBlock) {
                    weakSelf.groupNoticeSuccessBlock();
                }
                [weakSelf backAction];
                [HUD showMessage:LanguageToolMatch(@"发布成功")];
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        } else {
            /**
             * TODO: 老版本代码如果没有输入内容，直接删除
             //删除群公告
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
             [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
             [dict setValue:[NSString stringWithFormat:@"%@",self.groupInfoModel.groupNotice.noticeId] forKey:@"noticeId"];
             if (![NSString isNil:UserManager.userInfo.userUID]) {
                 [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
             }
             [IMSDKManager groupDeleteGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                 [weakSelf.navigationController popViewControllerAnimated:YES];
                 [HUD showMessage:LanguageToolMatch(@"群公告移除成功")];
             } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                 [HUD showMessageWithCode:code errorMsg:msg];
             }];
             */
        }
    }
}

/// 返回按钮事件，如果找到群公告列表页面，则返回列表页面；如果找到聊天界面，则返回聊天界面
- (void)backAction {
    NSArray *viewControllers = self.navigationController.viewControllers;
    [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[NoaChatViewController class]]){
            NoaChatViewController *chatCtrl = (NoaChatViewController *)obj;
            [self.navigationController popToViewController:chatCtrl animated:YES];
            *stop = YES;
        }else if ([obj isKindOfClass:[NoaGroupNoticeListVC class]]) {
            NoaGroupNoticeListVC *noticeList = (NoaGroupNoticeListVC *)obj;
            // 刷新
            [noticeList reloadData];
            [self.navigationController popToViewController:noticeList animated:YES];
            *stop = YES;
        }
    }];
}

//当键盘出现
-(void)keyboardWillShow:(NSNotification *)notification{
//    self.numberLabel.hidden = NO;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%d",self.textView.text.length, Notice_Content_Num_Max];
    self.placeHoderLabel.hidden = YES;
}
 
//当键盘退出
-(void)keyboardWillHide:(NSNotification *)notification{
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%d",self.textView.text.length, Notice_Content_Num_Max];
    if (![NSString isNil:self.textView.text]) {
        self.placeHoderLabel.hidden = YES;
    }else{
        self.placeHoderLabel.hidden = NO;
    }
}

- (void)textViewDidChange {
     // 判断是否存在高亮字符，如果有，则不进行字数统计和字符串截断
     UITextRange *selectedRange = self.textView.markedTextRange;
     UITextPosition *position = [self.textView positionFromPosition:selectedRange.start offset:0];
     if (position) {
         return;
     }

     // 判断是否超过最大字数限制，如果超过就截断
     if (self.textView.text.length > Notice_Content_Num_Max) {
         self.textView.text = [self.textView.text substringToIndex:Notice_Content_Num_Max];
     }
    
    //剩余字数显示UI更新
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%d",self.textView.text.length, Notice_Content_Num_Max];
}

@end
