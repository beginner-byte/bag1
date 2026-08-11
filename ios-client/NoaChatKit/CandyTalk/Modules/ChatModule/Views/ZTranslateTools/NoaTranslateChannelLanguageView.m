//
//  NoaTranslateChannelLanguageView.m
//  NoaKit
//
//  Created by Candy on 2023/12/27.
//

#import "NoaTranslateChannelLanguageView.h"
#import "NoaSearchView.h"
#import "NoaChannelLanguageCell.h"

@interface NoaTranslateChannelLanguageView()<UITableViewDelegate, UITableViewDataSource, ZSearchViewDelegate>

@property (nonatomic, strong)LingIMSessionModel *sessionModel;
@property (nonatomic, assign)ZMsgTranslateType translateType;

@property (nonatomic, strong) NSMutableArray *defaultDataList;
@property (nonatomic, strong) NSMutableArray *showDataList;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) NoaSearchView *searchView;
@property (nonatomic, strong) UITableView *baseTableView;
@property (nonatomic, copy) NSString *searchContent;
@property (nonatomic, copy) NSString *selectOption;
@property (nonatomic, copy) NSString *selectOptionName;

@end

@implementation NoaTranslateChannelLanguageView

- (instancetype)initWithTranslateType:(ZMsgTranslateType)translateType sessionModel:(LingIMSessionModel *)sessionModel {
    self = [super init];
    if (self) {
        _translateType = translateType;
        _sessionModel = sessionModel;
        self.selectOption = @"";
        self.selectOptionName = @"";
        [self setupUI];
        [self requestNetworkData];
    }
    return self;
}

- (void)setupUI {
    self.searchContent = @"";
    
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.backgroundColor = [COLOR_00 colorWithAlphaComponent:0.3];
    [CurrentVC.view addSubview:self];

    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, DScreenHeight, DScreenWidth, DScreenHeight - DWScale(196))];
    _backView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [_backView round:DWScale(20) RectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    [self addSubview:_backView];
    
   
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setTkThemeImage:@[ImgNamed(@"icon_chat_refresh_close"), ImgNamed(@"icon_chat_refresh_close_dark")] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(colseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backView).offset(DWScale(18));
        make.leading.equalTo(_backView).offset(DWScale(16));
        make.width.height.mas_equalTo(DWScale(25));
    }];
    
    
    NSString *sureTitleStr = LanguageToolMatch(@"确定");
    CGRect btnSetRect = [sureTitleStr boundingRectWithSize:CGSizeMake(MAXFLOAT, DWScale(25)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: FONTR(16)} context:nil];
    CGFloat sureTitleWidth = btnSetRect.size.width > DWScale(120) ? DWScale(120) : btnSetRect.size.width;
    UIButton *sureBtn = [[UIButton alloc] init];
    [sureBtn setTitle:sureTitleStr forState:UIControlStateNormal];
    [sureBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2] forState:UIControlStateNormal];
    sureBtn.titleLabel.font = FONTN(16);
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_backView).offset(DWScale(18));
        make.trailing.mas_equalTo(_backView).offset(-DWScale(16));
        make.width.mas_equalTo(DWScale(sureTitleWidth + 20));
        make.height.mas_equalTo(DWScale(25));
    }];


    UILabel *titleLbl = [[UILabel alloc] init];
    if (_translateType == ZSendMsgTranslateTypeChannel || _translateType == ZReceiveMsgTranslateTypeChannel) {
        titleLbl.text = LanguageToolMatch(@"翻译通道");
    } else {
        titleLbl.text = LanguageToolMatch(@"翻译语种");
    }
    titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    titleLbl.font = FONTB(18);
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [_backView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_backView).offset(DWScale(18));
        make.leading.mas_equalTo(closeBtn.mas_trailing).offset(DWScale(16));
        make.trailing.mas_equalTo(sureBtn.mas_leading).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(25));
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.tkThemebackgroundColors = @[COLOR_D0D0D0, COLOR_D0D0D0_DARK];
    [_backView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLbl.mas_bottom).offset(DWScale(16));
        make.leading.mas_equalTo(_backView).offset(DWScale(16));
        make.trailing.mas_equalTo(_backView).offset(-DWScale(16));
        make.width.mas_equalTo(0.8);
    }];
    
    _searchView = [[NoaSearchView alloc] initWithPlaceholder:LanguageToolMatch(@"搜索")];
    _searchView.frame = CGRectMake(0, DWScale(10) + DNavStatusBarH, DScreenWidth, DWScale(40));
    _searchView.showClearBtn = YES;
    _searchView.returnKeyType = UIReturnKeyDefault;
    _searchView.delegate = self;
    [_backView addSubview:_searchView];
    [_searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_backView.mas_left);
        make.right.mas_equalTo(_backView.mas_right);
        make.top.mas_equalTo(titleLbl.mas_bottom).offset(DWScale(9));
        make.height.mas_equalTo(DWScale(38));
    }];
    
    _baseTableView = [[UITableView alloc] init];
    _baseTableView.delegate = self;
    _baseTableView.dataSource = self;
    _baseTableView.bounces = NO;
    _baseTableView.delaysContentTouches = NO;
    _baseTableView.separatorColor = COLOR_CLEAR;
    _baseTableView.tkThemebackgroundColors =  @[COLORWHITE, COLORWHITE_DARK];
    [_backView addSubview:_baseTableView];
    [_baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchView.mas_bottom).offset(DWScale(10));
        make.leading.trailing.equalTo(_backView);
        make.bottom.equalTo(_backView).offset(-DHomeBarH);
    }];
    [self.baseTableView registerClass:[NoaChannelLanguageCell class] forCellReuseIdentifier:NSStringFromClass([NoaChannelLanguageCell class])];
}

- (void)requestNetworkData {
    if (_translateType == ZReceiveMsgTranslateTypeChannel || _translateType == ZSendMsgTranslateTypeChannel) {
        //通道
        [self requestGetTranslateChannel];
    }
    if (_translateType == ZReceiveMsgTranslateTypeLanguage || _translateType == ZSendMsgTranslateTypeLanguage) {
        //语种
        [self requestGetTranslateLanguage];
    }
}

- (void)channelLanguageViewShow {
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.backView.frame = CGRectMake(0, DWScale(196), DScreenWidth, DScreenHeight - DWScale(196));
    }];
}

- (void)channelLanguageViewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.backView.frame = CGRectMake(0, DScreenHeight, DScreenWidth, DScreenHeight - DWScale(196));
    } completion:^(BOOL finished) {
        NSArray *subViews = [weakSelf.backView subviews];
        if([subViews count] != 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        [weakSelf.backView removeFromSuperview];
        weakSelf.backView = nil;
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - Request
//请求翻译通道数据
- (void)requestGetTranslateChannel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:ZLanguageTOOL.currentLanguage.languageAbbr forKey:@"currentLang"];
    
    WeakSelf
    [HUD showActivityMessage:@""];
    [IMSDKManager imSdkTranslateGetChannelLanguage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *dataArr = (NSArray *)data;
            [weakSelf.showDataList removeAllObjects];
            [weakSelf.defaultDataList removeAllObjects];
            weakSelf.showDataList = [NoaTranslateChannelLanguageModel mj_objectArrayWithKeyValuesArray:dataArr];
            [weakSelf.defaultDataList addObjectsFromArray:weakSelf.showDataList];
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//请求支持的语种数据
- (void)requestGetTranslateLanguage {
    NSString *selectedChannel = @"";
    if (_translateType == ZReceiveMsgTranslateTypeLanguage) {
        selectedChannel = _sessionModel.receiveTranslateChannel;
    }
    if (_translateType == ZSendMsgTranslateTypeLanguage) {
        selectedChannel = _sessionModel.sendTranslateChannel;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:ZLanguageTOOL.currentLanguage.languageAbbr forKey:@"currentLang"];
    
    WeakSelf
    [HUD showActivityMessage:@""];
    [IMSDKManager imSdkTranslateGetChannelLanguage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *dataArr = (NSArray *)data;
            [weakSelf.showDataList removeAllObjects];
            [weakSelf.defaultDataList removeAllObjects];
            NSArray *dataList = [NoaTranslateChannelLanguageModel mj_objectArrayWithKeyValuesArray:dataArr];
            for (NoaTranslateChannelLanguageModel *model in dataList) {
                if ([model.channelId isEqualToString:selectedChannel]) {
                    weakSelf.showDataList = [model.lang_table mutableCopy];
                    [weakSelf.defaultDataList addObjectsFromArray:weakSelf.showDataList];
                    [weakSelf.baseTableView reloadData];
                }
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - Action
- (void)colseBtnClick {
    //关闭
    [self channelLanguageViewDismiss];
}

- (void)sureBtnClick {
    //确定
    if (_translateType == ZReceiveMsgTranslateTypeChannel) {
        //通道-收到消息
        _sessionModel.receiveTranslateChannel = self.selectOption;
        _sessionModel.receiveTranslateChannelName = self.selectOptionName;
    }
    if (_translateType == ZReceiveMsgTranslateTypeLanguage) {
        //语种-收到消息
        _sessionModel.receiveTranslateLanguage = self.selectOption;
        _sessionModel.receiveTranslateLanguageName = self.selectOptionName;
    }
    if (_translateType == ZSendMsgTranslateTypeChannel) {
        //通道-发送消息
        _sessionModel.sendTranslateChannel = self.selectOption;
        _sessionModel.sendTranslateChannelName = self.selectOptionName;
       
    }
    if (_translateType == ZSendMsgTranslateTypeLanguage) {
        //语种-发送消息
        _sessionModel.sendTranslateLanguage = self.selectOption;
        _sessionModel.sendTranslateLanguageName = self.selectOptionName;
    }
   
    //缓存到本地并传递给上个页面
    [DBTOOL insertOrUpdateSessionModelWith:_sessionModel];
    if (_delegate && [_delegate respondsToSelector:@selector(selectActionFinishWithSessionModel:translateType:)]) {
        [_delegate selectActionFinishWithSessionModel:_sessionModel translateType:_translateType];
    }
    [self channelLanguageViewDismiss];
}

#pragma mark - ZSearchViewDelegate
- (void)searchViewTextValueChanged:(NSString *)searchStr {
    self.searchContent = [searchStr trimString];
    
    [self.showDataList removeAllObjects];
    if (self.searchContent.length > 0) {
        //通道
        if (_translateType == ZSendMsgTranslateTypeChannel || _translateType == ZReceiveMsgTranslateTypeChannel) {
            for (NoaTranslateChannelLanguageModel *tempChannelModel in self.defaultDataList) {
                if ([tempChannelModel.name containsString:searchStr]) {
                    [self.showDataList addObject:tempChannelModel];
                }
            }
        }
        //语种
        if (_translateType == ZSendMsgTranslateTypeLanguage || _translateType == ZReceiveMsgTranslateTypeLanguage) {
            for (NoaTranslateLanguageModel *tempLangueModel in self.defaultDataList) {
                if ([tempLangueModel.name containsString:searchStr]) {
                    [self.showDataList addObject:tempLangueModel];
                }
            }
        }
    } else {
        [self.showDataList removeAllObjects];
        [self.showDataList addObjectsFromArray:self.defaultDataList];
    }
    [self.baseTableView reloadData];
}

- (void)searchViewReturnKeySearch:(NSString *)searchStr {
    [_searchView.tfSearch resignFirstResponder];
    self.searchContent = [searchStr trimString];
    if (self.searchContent.length > 0) {
        //通道
        if (_translateType == ZSendMsgTranslateTypeChannel || _translateType == ZReceiveMsgTranslateTypeChannel) {
            for (NoaTranslateChannelLanguageModel *tempChannelModel in self.defaultDataList) {
                if ([tempChannelModel.name containsString:searchStr]) {
                    [self.showDataList addObject:tempChannelModel];
                }
            }
        }
        //语种
        if (_translateType == ZSendMsgTranslateTypeLanguage || _translateType == ZReceiveMsgTranslateTypeLanguage) {
            for (NoaTranslateLanguageModel *tempLangueModel in self.defaultDataList) {
                if ([tempLangueModel.name containsString:searchStr]) {
                    [self.showDataList addObject:tempLangueModel];
                }
            }
        }
    } else {
        [self.showDataList removeAllObjects];
        [self.showDataList addObjectsFromArray:self.defaultDataList];
    }
    [self.baseTableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showDataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(56);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaChannelLanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaChannelLanguageCell class]) forIndexPath:indexPath];
    if (_translateType == ZSendMsgTranslateTypeChannel || _translateType == ZReceiveMsgTranslateTypeChannel) {
        //通道
        NoaTranslateChannelLanguageModel *channelModel = (NoaTranslateChannelLanguageModel *)[self.showDataList objectAtIndexSafe:indexPath.row];
        cell.channelModel = channelModel;
        if (_translateType == ZReceiveMsgTranslateTypeChannel) {
            if ([self.selectOption isEqualToString:channelModel.channelId]) {
                cell.isSelected = YES;
            } else {
                cell.isSelected = NO;
            }
        }
        if (_translateType == ZSendMsgTranslateTypeChannel) {
            if ([self.selectOption isEqualToString:channelModel.channelId]) {
                cell.isSelected = YES;
            } else {
                cell.isSelected = NO;
            }
        }
    }
    if (_translateType == ZSendMsgTranslateTypeLanguage || _translateType == ZReceiveMsgTranslateTypeLanguage) {
        //语种
        NoaTranslateLanguageModel *languageModel = (NoaTranslateLanguageModel *)[self.showDataList objectAtIndexSafe:indexPath.row];
        cell.languageModel = languageModel;
        if (_translateType == ZReceiveMsgTranslateTypeLanguage) {
            if ([self.selectOption isEqualToString:languageModel.slug]) {
                cell.isSelected = YES;
            } else {
                cell.isSelected = NO;
            }
        }
        if (_translateType == ZSendMsgTranslateTypeLanguage) {
            if ([self.selectOption isEqualToString:languageModel.slug]) {
                cell.isSelected = YES;
            } else {
                cell.isSelected = NO;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_translateType == ZReceiveMsgTranslateTypeChannel) {
        //通道-收到消息
        NoaTranslateChannelLanguageModel *clickChannelModel = (NoaTranslateChannelLanguageModel *)[self.showDataList objectAtIndexSafe:indexPath.row];
        self.selectOption = clickChannelModel.channelId;
        self.selectOptionName = clickChannelModel.name;
    }
    if (_translateType == ZReceiveMsgTranslateTypeLanguage) {
        //语种-收到消息
        NoaTranslateLanguageModel *clickLanguageModel = (NoaTranslateLanguageModel *)[self.showDataList objectAtIndexSafe:indexPath.row];
        self.selectOption = clickLanguageModel.slug;
        self.selectOptionName = clickLanguageModel.name;
    }
    if (_translateType == ZSendMsgTranslateTypeChannel) {
        //通道-发送消息
        NoaTranslateChannelLanguageModel *clickChannelModel = (NoaTranslateChannelLanguageModel *)[self.showDataList objectAtIndexSafe:indexPath.row];
        self.selectOption = clickChannelModel.channelId;
        self.selectOptionName = clickChannelModel.name;
    }
    if (_translateType == ZSendMsgTranslateTypeLanguage) {
        //语种-发送消息
        NoaTranslateLanguageModel *clickLanguageModel = (NoaTranslateLanguageModel *)[self.showDataList objectAtIndexSafe:indexPath.row];
        self.selectOption = clickLanguageModel.slug;
        self.selectOptionName = clickLanguageModel.name;
    }
    
    [self.baseTableView reloadData];
}

#pragma mark - Lazy
- (NSMutableArray *)showDataList {
    if (!_showDataList) {
        _showDataList = [[NSMutableArray alloc] init];
    }
    return _showDataList;
}

- (NSMutableArray *)defaultDataList {
    if (!_defaultDataList) {
        _defaultDataList = [[NSMutableArray alloc] init];
    }
    return _defaultDataList;
}

@end
