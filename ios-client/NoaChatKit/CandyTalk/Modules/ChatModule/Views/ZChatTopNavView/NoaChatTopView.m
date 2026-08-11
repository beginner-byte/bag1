//
//  NoaChatTopView.m
//  NoaKit
//
//  Created by Candy on 2026/9/29.
//

#import "NoaChatTopView.h"
#import "NoaChatLinkCollectCell.h"
#import "NoaChatNavLinkAddView.h" //群链接addView
#import "NoaChatNavLinkSettingView.h" //群链接SettingView
#import "NoaMessageAlertView.h"
#import "LingIMGroup.h"

// 页签切换
#import <JXCategoryView/JXCategoryView.h>

@interface NoaChatTopView() <ZChatNavLinkSettingDelegate, JXCategoryViewDelegate>

@property (nonatomic, strong) UIButton *backBtn;        //返回按钮
@property (nonatomic, strong) UIButton *rightBtn;       //右侧按钮
@property (nonatomic, strong) UIButton *btnCancel;      //多选-取消按钮

@property (nonatomic, strong) UIView *chatLinkBackView;

@property (nonatomic, strong) NoaChatNavLinkSettingView *linkSettingView;

/// 底部切换(1.只有消息的时候展示消息 2.有公告、有链接的时候消息不展示)
@property (nonatomic, strong) JXCategoryTitleImageView *linkCategoryView;

/// 设置
@property (nonatomic, strong) UIButton *settingBtn;

/// 添加连接
@property (nonatomic, strong) UIButton *addBtn;

/// 网络检测
@property (nonatomic, strong) UIButton *netDetectionBtn;

/// linkCategoryView标题-数据源
@property (nonatomic, strong) NSMutableArray *titleArr;


@end

@implementation NoaChatTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStateChange:) name:@"IMConnectStateChange" object:nil];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    [self addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(7);
        make.leading.equalTo(self).offset(10);
        make.height.width.mas_equalTo(30);
    }];
    
    [self addSubview:self.rightBtn];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backBtn);
        make.trailing.equalTo(self).offset(-15);
        make.height.mas_equalTo(30);
    }];
    
    [self addSubview:self.tipExplainLbl];
    if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"]) {
        [self.tipExplainLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-(6 + DWScale(40)));
            make.leading.equalTo(self.backBtn.mas_trailing).offset(8);
            make.height.mas_equalTo(14);
        }];
    } else {
        [self.tipExplainLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-(6 + DWScale(40)));
            make.leading.equalTo(self.backBtn.mas_trailing).offset(8);
            make.height.mas_equalTo(14);
        }];
    }
    
    /**
     * UI变更注释
     [self addSubview:self.tipLockImgView];
     [self.tipLockImgView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.trailing.equalTo(self.tipExplainLbl.mas_leading).offset(-5);
     make.centerY.equalTo(self.tipExplainLbl);
     make.width.mas_equalTo(10);
     make.height.mas_equalTo(12);
     }];
     */
      
    [self addSubview:self.chatNameLbl];
    [self.chatNameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.tipExplainLbl.mas_top).offset(-5);
        make.leading.equalTo(self.backBtn.mas_trailing).offset(8);
        make.width.mas_lessThanOrEqualTo(DWScale(180));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    [self addSubview:self.btnTime];
    [self.btnTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rightBtn);
        make.trailing.equalTo(self.rightBtn.mas_leading).offset(-10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self addSubview:self.btnCancel];
    [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backBtn);
        make.trailing.equalTo(self).offset(-15);
        make.height.mas_equalTo(30);
    }];
    
    _viewOnline = [UIView new];
    _viewOnline.tkThemebackgroundColors = @[HEXCOLOR(@"01BC46"), HEXCOLOR(@"01BC46")];
    _viewOnline.layer.cornerRadius = DWScale(3);
    _viewOnline.layer.masksToBounds = YES;
    _viewOnline.hidden = YES;
    [self addSubview:_viewOnline];
    [_viewOnline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_chatNameLbl);
        make.leading.equalTo(_chatNameLbl.mas_trailing).offset(DWScale(2));
        make.size.mas_equalTo(CGSizeMake(DWScale(6), DWScale(6)));
    }];
    
    [self addSubview:self.chatLinkBackView];
    [self.chatLinkBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self);
        make.height.mas_equalTo(DWScale(40));
    }];
        
    // 网络检测
    _netDetectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_netDetectionBtn setImage:ImgNamed(@"icon_chat_nav_network_detection") forState:UIControlStateNormal];
    _netDetectionBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_netDetectionBtn addTarget:self action:@selector(btnChatLinkNetworkDetectClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.chatLinkBackView addSubview:_netDetectionBtn];
    [_netDetectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.chatLinkBackView).offset(-16);
        make.centerY.equalTo(self.chatLinkBackView);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    //设置
    _settingBtn = [[UIButton alloc] init];
    [_settingBtn setImage:ImgNamed(@"icon_chat_seetting") forState:UIControlStateNormal];
    _settingBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_settingBtn addTarget:self action:@selector(btnChatLinkSettingClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.chatLinkBackView addSubview:_settingBtn];
    [_settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_netDetectionBtn.mas_leading).offset(-12);
        make.centerY.equalTo(self.chatLinkBackView);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    //添加
    _addBtn = [[UIButton alloc] init];
    [_addBtn setImage:ImgNamed(@"icon_chat_link_add") forState:UIControlStateNormal];
    _addBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_addBtn addTarget:self action:@selector(btnChatLinkAddClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.chatLinkBackView addSubview:_addBtn];
    [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_settingBtn.mas_leading).offset(-12);
        make.centerY.equalTo(self.chatLinkBackView);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    // 连接展示
    [self.chatLinkBackView addSubview:self.linkCategoryView];
    [self.linkCategoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.chatLinkBackView);
        make.trailing.equalTo(_addBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.chatLinkBackView);
        make.height.mas_equalTo(24);
    }];
    
    [self reloadTopChatLinkView];

}

#pragma mark - Setter
- (void)setChatName:(NSString *)chatName {
    _chatName = chatName;
    _chatNameLbl.text = _chatName;
}

- (void)setShowCancel:(BOOL)showCancel {
    _showCancel = showCancel;
    if (_showCancel) {
        self.btnCancel.hidden = NO;
        self.rightBtn.hidden = YES;
    } else {
        self.btnCancel.hidden = YES;
        self.rightBtn.hidden = NO;
    }
}

- (void)setChatLinkArr:(NSMutableArray *)chatLinkArr {
    _chatLinkArr = chatLinkArr;
    // 修改了连接数据，刷新展示
    [self reloadTopChatLinkView];
}


- (void)setIsShowGroupNotice:(BOOL)isShowGroupNotice {
    _isShowGroupNotice = isShowGroupNotice;
    // 修改了群公告状态，刷新展示
    [self reloadTopChatLinkView];
}

- (void)setIsShowTagTool:(BOOL)isShowTagTool {
    _isShowTagTool = isShowTagTool;
    if (_isShowTagTool) {
        // 展示连接
        self.chatLinkBackView.hidden = NO;
        // 展示网络检测
        self.netDetectionBtn.hidden = NO;
        //
        if (_chatType == CIMChatType_GroupChat) {
            // 群聊需要判断是否是管理员、群主，如果不是管理员、群主，则不显示添加链接、设置链接按钮(先隐藏，通过groupInfo属性传入后，再判断是否有权限，再放开展示)
            _addBtn.hidden = YES;
            _settingBtn.hidden = YES;
        }else {
            _settingBtn.hidden = NO;
            _addBtn.hidden = NO;
        }
        
    } else {
        // 隐藏连接
        self.chatLinkBackView.hidden = YES;
        // 隐藏网络检测
        self.netDetectionBtn.hidden = YES;
        // 隐藏设置按钮
        self.settingBtn.hidden = YES;
        // 隐藏添加链接按钮
        self.addBtn.hidden = YES;
    }
}

- (void)setGroupInfo:(LingIMGroup *)groupInfo {
    if (!groupInfo) {
        return;
    }
    _groupInfo = groupInfo;
    if (!self.isShowTagTool) {
        // 本身就不展示的，不再修改隐藏、显示状态
        return;
    }
    
    if (groupInfo.userGroupRole == 1 || groupInfo.userGroupRole == 2) {
        // 只有管理员跟群主能添加、设置
        _settingBtn.hidden = NO;
        _addBtn.hidden = NO;
    }else {
        // 普通用户无添加、设置
        _addBtn.hidden = YES;
        _settingBtn.hidden = YES;
    }
}

- (void)connectStateChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger connectType = [[userInfo objectForKeySafe:@"connectType"] integerValue];
    if (connectType == 0) {
        //正在连接...
        self.tipExplainLbl.text = LanguageToolMatch(@"正在连接...");
    } else if (connectType == 1) {
        //连接成功
        self.tipExplainLbl.text = LanguageToolMatch(@"当前消息已被加密");
    } else if (connectType == 2) {
        //连接失败
        self.tipExplainLbl.text = LanguageToolMatch(@"当前无法连接网络，请检查网络设置是否正常");
    } else {
        self.tipExplainLbl.text = LanguageToolMatch(@"当前消息已被加密");
    }
}


#pragma mark - Medth
- (void)chatRoomAddNewTagActionWithTagName:(NSString *)tagName tagUrl:(NSString *)tagUrl {
    //新增
    [self requestAddChatTagWithTagName:tagName tagUrl:tagUrl];
}

#pragma mark - Request
//新增tag
- (void)requestAddChatTagWithTagName:(NSString *)tagName tagUrl:(NSString *)tagUrl {
    NSInteger tagType = (self.chatType == 0 ? 1 : 2);
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.sessionId forKey:@"dialog"];
    [dict setObjectSafe:tagName forKey:@"tagName"];
    [dict setObjectSafe:[NSNumber numberWithInteger:tagType] forKey:@"tagType"];
    [dict setObjectSafe:tagUrl forKey:@"tagUrl"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
          [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager MessageChatTagAddWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            if (data) {
                [HUD showMessage:LanguageToolMatch(@"添加成功")];
                NSDictionary *dataDict = (NSDictionary *)data;
                NoaChatTagModel *newTagModel = [NoaChatTagModel mj_objectWithKeyValues:dataDict];
                [weakSelf.chatLinkArr addObject:newTagModel];
                [weakSelf reloadTopChatLinkView];
            }
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//更新tag
- (void)requestUpdateChatTagWithTagName:(NSString *)tagName tagUrl:(NSString *)tagUrl tagId:(NSInteger)tagId handleIndex:(NSInteger)handleIndex {
    NSInteger tagType = (self.chatType == 0 ? 1 : 2);
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.sessionId forKey:@"dialog"];
    [dict setObjectSafe:[NSNumber numberWithInteger:tagId] forKey:@"tagId"];
    [dict setObjectSafe:tagName forKey:@"tagName"];
    [dict setObjectSafe:[NSNumber numberWithInteger:tagType] forKey:@"tagType"];
    [dict setObjectSafe:tagUrl forKey:@"tagUrl"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
          [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager MessageChatTagUpdateWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (data) {
            BOOL isSuccess = [data boolValue];
            if (isSuccess) {
                [HUD showMessage:LanguageToolMatch(@"编辑成功")];
                NoaChatTagModel *updateTagModel = (NoaChatTagModel *)[weakSelf.chatLinkArr objectAtIndex:handleIndex];
                updateTagModel.tagName = tagName;
                updateTagModel.tagUrl = tagUrl;
                [weakSelf.chatLinkArr replaceObjectAtIndex:handleIndex withObject:updateTagModel];
                // 刷新链接
                [weakSelf reloadTopChatLinkView];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}


//删除tag
- (void)requestChatTagRemoveWithModel:(NSInteger)tagId withIndex:(NSInteger)index {
    NSInteger tagType = (self.chatType == 0 ? 1 : 2);
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.sessionId forKey:@"dialog"];
    [dict setObjectSafe:[NSNumber numberWithInteger:tagId] forKey:@"tagId"];
    [dict setObjectSafe:[NSNumber numberWithInteger:tagType] forKey:@"tagType"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
          [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager MessageChatTagRemoveWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if (data) {
            [weakSelf.chatLinkArr removeObjectAtIndex:weakSelf.isShowGroupNotice ? index - 2 : index - 1];
            // 刷新链接
            [weakSelf reloadTopChatLinkView];
            // toast提示
            [HUD showMessage:LanguageToolMatch(@"删除成功")];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _chatLinkArr.count;
}

- (CGSize)collectionView: (UICollectionView *)collectionView layout: (UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath: (NSIndexPath *)indexPath {
    NoaChatTagModel *tempTagModel = (NoaChatTagModel *)[_chatLinkArr objectAtIndex:indexPath.row];
    NSString *titleStr = tempTagModel.tagName;
    CGFloat itemTitleWidth = [titleStr widthForFont:FONTN(14)];
    CGSize size = CGSizeMake(DWScale(6+18+3+itemTitleWidth+3), DWScale(30));//每个cell的宽度自适应
    return size;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatLinkCollectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatLinkCollectCell class]) forIndexPath:indexPath];
    NoaChatTagModel *tempTagModel = (NoaChatTagModel *)[_chatLinkArr objectAtIndex:indexPath.row];
    cell.tagModel = tempTagModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.navLinkBlock) {
        self.navLinkBlock(indexPath.row);
    }
}

#pragma mark - ZChatNavLinkSettingDelegate
//删除
- (void)deleteAction:(NSInteger)index {
    WeakSelf
    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    msgAlertView.lblTitle.text = LanguageToolMatch(@"删除链接");
    msgAlertView.lblTitle.font = FONTB(18);
    msgAlertView.lblTitle.textAlignment = NSTextAlignmentLeft;
    msgAlertView.lblContent.text = LanguageToolMatch(@"确定要删除此链接吗？");
    msgAlertView.lblContent.font = FONTN(14);
    msgAlertView.lblContent.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"删除") forState:UIControlStateNormal];
    [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    [msgAlertView alertShow];
    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
        [weakSelf.linkSettingView linkSettingViewDismiss];
        weakSelf.linkSettingView.delegate = nil;
        weakSelf.linkSettingView = nil;
        NoaChatTagModel *removeTagModel = (NoaChatTagModel *)[weakSelf.chatLinkArr objectAtIndex:(weakSelf.isShowGroupNotice ? index - 2 : index - 1)];
        [weakSelf requestChatTagRemoveWithModel:removeTagModel.tagId withIndex:index];
    };
}

//编辑
- (void)editAction:(NSInteger)index {
    NoaChatNavLinkAddView *addView = [[NoaChatNavLinkAddView alloc] init];
    addView.updateIndex = index;
    addView.viewType = ChatLinkAddViewTypeEdit;
    addView.editTagModel = (NoaChatTagModel *)[self.chatLinkArr objectAtIndex:self.isShowGroupNotice ? index - 2 : index - 1];
    [addView linkAddViewShow];
    WeakSelf
    [addView setNewTagFinsihBlock:^(NSInteger tagId, NSString * _Nonnull tagName, NSString * _Nonnull tagUrl, NSInteger updateIndex) {
        [weakSelf.linkSettingView linkSettingViewDismiss];
        weakSelf.linkSettingView.delegate = nil;
        weakSelf.linkSettingView = nil;
        //更新
        NSInteger handleIndex = (weakSelf.isShowGroupNotice ? updateIndex - 2 : updateIndex - 1);
        [weakSelf requestUpdateChatTagWithTagName:tagName tagUrl:tagUrl tagId:tagId handleIndex:handleIndex];
    }];
    
}

#pragma mark - Action
- (void)navBtnBackClicked {
    if (self.navBackBlock) {
        self.navBackBlock();
    }
}

- (void)navBtnRightClicked {
    if (self.navRightBlock) {
        self.navRightBlock();
    }
}

- (void)btnTimeClicked {
    if (self.navTimeBlock) {
        self.navTimeBlock();
    }
}

- (void)btnCancelClicked {
    self.showCancel = NO;
    if (self.navCancelBlock) {
        self.navCancelBlock();
    }
}

- (void)btnChatLinkNoticeClicked {
    if (self.navLinkBlock) {
        self.navLinkBlock(Chat_Top_Nav_Link_Notice);
    }
}

- (void)btnChatLinkSettingClicked {
    NSMutableArray *allTagArr = [NSMutableArray arrayWithArray:self.chatLinkArr];
    NoaChatTagModel *messageTagModel = [[NoaChatTagModel alloc] init];
    messageTagModel.tagIcon = @"icon_chat_link_message";
    messageTagModel.tagName = LanguageToolMatch(@"消息");
    messageTagModel.tagUrl = @"";
    messageTagModel.localType = 1;
    [allTagArr insertObject:messageTagModel atIndex:0];
    if (_isShowGroupNotice) {
        //群公告
        NoaChatTagModel *noticeTagModel = [[NoaChatTagModel alloc] init];
        noticeTagModel.tagIcon = @"icon_chat_link_notice";
        noticeTagModel.tagName = LanguageToolMatch(@"群公告");
        noticeTagModel.tagUrl = @"";
        noticeTagModel.localType = 1;
        [allTagArr insertObject:noticeTagModel atIndex:1];
    }
    
    [self.linkSettingView configLinkListData:allTagArr];
    [self.linkSettingView linkSettingViewShow];
}

- (void)btnChatLinkAddClicked {
    NoaChatNavLinkAddView *addView = [[NoaChatNavLinkAddView alloc] init];
    addView.viewType = ChatLinkAddViewTypeAdd;
    [addView linkAddViewShow];
    WeakSelf
    [addView setNewTagFinsihBlock:^(NSInteger tagId, NSString * _Nonnull tagName, NSString * _Nonnull tagUrl, NSInteger updateIndex) {
        //新增
        [weakSelf requestAddChatTagWithTagName:tagName tagUrl:tagUrl];
    }];
}

- (void)btnChatLinkNetworkDetectClicked {
    if (self.navNetworkDetectBlock) {
        self.navNetworkDetectBlock();
    }
}

/// MARK: 更新连接
- (void)reloadTopChatLinkView {
 
    [self.titleArr removeAllObjects];
    if (self.chatLinkArr && self.chatLinkArr.count > 0) {
        // 多个链接，展示群公告(是否展示根据self.isShowGroupNotice状态)+连接内容
       
        // 先判断是否展示群公告
        if (self.isShowGroupNotice) {
            [self.titleArr addObject:LanguageToolMatch(@"群公告")];
        }
        
        for (NoaChatTagModel *tagModel in self.chatLinkArr) {
            [self.titleArr addObject:tagModel.tagName];
        }
    }else {
        // 无链接，展示群消息+群公告(是否展示根据self.isShowGroupNotice状态)
        [self.titleArr addObject:LanguageToolMatch(@"消息")];
        // 先判断是否展示群公告
        if (self.isShowGroupNotice) {
            [self.titleArr addObject:LanguageToolMatch(@"群公告")];
        }
    }
    
    // 每个Item的图片
    NSMutableArray *imgArr = [NSMutableArray new];
    // 每个Item的图文排版方式
    NSMutableArray *imageTypes = [NSMutableArray array];
    for (int i = 0; i < self.titleArr.count; i++) {
        [imgArr addObject:@"icon_chat_nav_top_link_show"];
        // 左边图片右边文字
        [imageTypes addObject:@(JXCategoryTitleImageType_LeftImage)];
    }
    
    // 因为图片是否选中、选中都一致，故直接设置
    self.linkCategoryView.imageNames = imgArr;
    self.linkCategoryView.selectedImageNames = imgArr;
    self.linkCategoryView.imageTypes = imageTypes;
    
    // 设置图片尺寸
    self.linkCategoryView.imageSize = CGSizeMake(12, 12);
    
    // 设置图片和文字的间距
    self.linkCategoryView.titleImageSpacing = 2;
    
    self.linkCategoryView.titles = self.titleArr;
    [self.linkCategoryView reloadDataWithoutListContainer];
}

/// MARK: JXCategoryViewDelegate Methods
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    if (self.chatLinkArr && self.chatLinkArr.count == 0) {
        if (index == 1) {
            // 点击的是群公告，跳转到对应页面
            [self btnChatLinkNoticeClicked];
        }else {
            // 点击的是消息，不处理
        }
        return;
    }
    
    // 有连接数据
    NSInteger selectIndex = index;
    if (self.isShowGroupNotice) {
        if (selectIndex == 0) {
            // 点击的是群公告，跳转到对应页面
            [self btnChatLinkNoticeClicked];
            return;
        }
        
        // 展示的有群公告,判断位置的时候需要移除
        selectIndex = index - 1;
    }
    
    // 点击的是连接地址
    if (self.navLinkBlock) {
        self.navLinkBlock(selectIndex);
    }
}

#pragma mark - Lazy
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        _backBtn.adjustsImageWhenHighlighted = NO;
        [_backBtn setTkThemeImage:@[ImgNamed(@"icon_nav_back"),ImgNamed(@"nav_back_white")] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(navBtnBackClicked) forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setEnlargeEdge:DWScale(10)];
    }
    return _backBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc] init];
        _rightBtn.adjustsImageWhenHighlighted = NO;
        [_rightBtn setImage:ImgNamed(@"icon_chat_seetting") forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(navBtnRightClicked) forControlEvents:UIControlEventTouchUpInside];
        [_rightBtn setEnlargeEdge:DWScale(10)];
    }
    return _rightBtn;
}

- (UILabel *)chatNameLbl {
    if (!_chatNameLbl) {
        _chatNameLbl = [[UILabel alloc] init];
        _chatNameLbl.text = @"";
        _chatNameLbl.font = FONTB(16);
        _chatNameLbl.textAlignment = NSTextAlignmentCenter;
        _chatNameLbl.preferredMaxLayoutWidth = DWScale(220);
        _chatNameLbl.tkThemetextColors = @[COLOR_11, COLORWHITE];
    }
    return _chatNameLbl;
}

- (UILabel *)tipExplainLbl {
    if (!_tipExplainLbl) {
        _tipExplainLbl = [[UILabel alloc] init];
        if ([[NetWorkStatusManager shared] getConnectStatus]) {
            _tipExplainLbl.text = LanguageToolMatch(@"当前消息已被加密");
        }else {
            _tipExplainLbl.text = LanguageToolMatch(@"当前无法连接网络，请检查网络设置是否正常");
        }
        _tipExplainLbl.font = FONTN(12);
        _tipExplainLbl.textAlignment = NSTextAlignmentCenter;
        _tipExplainLbl.tkThemetextColors = @[COLOR_99, COLOR_99];
        [_tipExplainLbl sizeToFit];
    }
    return _tipExplainLbl;
}

- (UIImageView *)tipLockImgView {
    if (!_tipLockImgView) {
        _tipLockImgView = [[UIImageView alloc] init];
        _tipLockImgView.image = ImgNamed(@"img_chat_lock");
    }
    return _tipLockImgView;
}

- (UIButton *)btnTime {
    if (!_btnTime) {
        _btnTime = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnTime setImage:ImgNamed(@"icon_time") forState:UIControlStateNormal];
        [_btnTime addTarget:self action:@selector(btnTimeClicked) forControlEvents:UIControlEventTouchUpInside];
        [_btnTime setEnlargeEdge:DWScale(10)];
        _btnTime.hidden = YES;
    }
    return _btnTime;
}

- (UIButton *)btnCancel {
    if (!_btnCancel) {
        _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        [_btnCancel setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
        _btnCancel.titleLabel.font = FONTN(16);
        [_btnCancel addTarget:self action:@selector(btnCancelClicked) forControlEvents:UIControlEventTouchUpInside];
        [_btnCancel setEnlargeEdge:DWScale(10)];
        _btnCancel.hidden = YES;
    }
    return _btnCancel;
}

- (UIView *)chatLinkBackView {
    if (!_chatLinkBackView) {
        _chatLinkBackView = [[UIView alloc] init];
        _chatLinkBackView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    }
    return _chatLinkBackView;
}

- (NoaChatNavLinkSettingView *)linkSettingView {
    if (!_linkSettingView) {
        _linkSettingView = [[NoaChatNavLinkSettingView alloc] init];
        _linkSettingView.delegate = self;
    }
    return _linkSettingView;
}

#pragma mark - Lazy Loading
- (JXCategoryTitleImageView *)linkCategoryView {
    if (!_linkCategoryView) {
        _linkCategoryView = [JXCategoryTitleImageView  new];
        _linkCategoryView.delegate = self;
        _linkCategoryView.titleColor = COLOR_99;
        _linkCategoryView.titleSelectedColor = COLOR_99;
        // 设置 title 字体大小（影响 title 高度）
        _linkCategoryView.titleFont = FONTM(14);
        _linkCategoryView.titleSelectedFont = FONTM(14);
        // 设置 title 垂直偏移量（正值向下，负值向上）
        // _ssoTypeCategoryView.titleLabelVerticalOffset = 0;
        _linkCategoryView.titleColorGradientEnabled = YES;
        _linkCategoryView.averageCellSpacingEnabled = NO;
        _linkCategoryView.contentEdgeInsetLeft = 16;
        _linkCategoryView.contentEdgeInsetRight = 16;
        _linkCategoryView.cellSpacing = 36;
        // 默认第一个
        _linkCategoryView.defaultSelectedIndex = 0;
    }
    return _linkCategoryView;
}

- (NSMutableArray *)titleArr {
    if (!_titleArr) {
        _titleArr = [NSMutableArray new];
    }
    return _titleArr;
}

@end
