//
//  NoaGroupNoticeDetailVC.m
//  NoaKit
//
//  Created by Candy on 2025/8/11.
//

#import "NoaGroupNoticeDetailVC.h"
#import "NoaGroupNoteModel.h"
#import "NoaGroupModifyNoticeVC.h"

@interface NoaGroupNoticeDetailVC()
@property (nonatomic, strong) UIImageView *headPortrait;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *leadingView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIScrollView *displayView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *editButton;
@end

@implementation NoaGroupNoticeDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavUI];
    [self setupUI];
    [self requestNotifyDetail];
}

- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"群公告");
    self.navBtnRight.hidden = YES;
}

- (void)setupUI {
    
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    
    [self.view addSubview:self.headPortrait];
    [self.headPortrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(16));
        make.top.mas_equalTo(self.navView.mas_bottom).offset(DWScale(18));
        make.width.height.mas_equalTo(48);
    }];
    [self.view addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.headPortrait.mas_trailing).offset(DWScale(8));
        make.top.mas_equalTo(self.headPortrait).offset(DWScale(7));
        make.height.mas_equalTo(DWScale(14));
    }];
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(DWScale(8));
        make.height.mas_equalTo(DWScale(12));
    }];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.deleteButton setTitle:LanguageToolMatch(@"删除公告") forState:UIControlStateNormal];
    
    self.deleteButton.titleLabel.font = FONTM(16);
    
    [self.deleteButton setTkThemeTitleColor:@[COLOR_F93A2F, COLOR_F93A2F_DARK] forState:UIControlStateNormal];
    [self.deleteButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLORWHITE],[UIImage ImageForColor:COLORWHITE_DARK]] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteNotifyEvent) forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteButton.layer.cornerRadius = DWScale(8);
    self.deleteButton.layer.masksToBounds = YES;
    self.deleteButton.layer.borderWidth = DWScale(1);
    self.deleteButton.layer.tkThemeborderColors = @[COLOR_F93A2F, COLOR_F93A2F_DARK];
    
    [self.view addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(20));
        make.trailing.mas_equalTo(-DWScale(20));
        make.height.mas_equalTo(DWScale(44));
        make.bottom.mas_equalTo(- (DHomeBarH + 16));
    }];
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.editButton setTitle:LanguageToolMatch(@"编辑公告") forState:UIControlStateNormal];
    
    self.editButton.titleLabel.font = FONTM(16);
    
    [self.editButton setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    [self.editButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLORWHITE],[UIImage ImageForColor:COLORWHITE_DARK]] forState:UIControlStateNormal];
    
    [self.editButton addTarget:self action:@selector(editNotifyEvent) forControlEvents:UIControlEventTouchUpInside];
    
    self.editButton.layer.cornerRadius = DWScale(8);
    self.editButton.layer.masksToBounds = YES;
    self.editButton.layer.borderWidth = DWScale(1);
    self.editButton.layer.tkThemeborderColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    
    [self.view addSubview:self.editButton];
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(DWScale(20));
        make.trailing.mas_equalTo(-DWScale(20));
        make.height.mas_equalTo(DWScale(44));
        make.bottom.mas_equalTo(self.deleteButton.mas_top).offset(-DWScale(16));
    }];
    
    
    self.containerView = [[UIView alloc] init];
    self.containerView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    self.containerView.layer.cornerRadius = 8.0;
    self.containerView.layer.masksToBounds = YES;
    [self.view addSubview:self.containerView];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headPortrait.mas_bottom).offset(DWScale(12));
        make.leading.mas_equalTo(DWScale(16));
        make.trailing.mas_equalTo(-DWScale(16));
        make.bottom.mas_equalTo(-(DWScale(DHomeBarH + 144)));
    }];
    
    self.leadingView = [[UIView alloc] init];
    self.leadingView.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.2],[COLOR_5966F2_DARK colorWithAlphaComponent:0.2]];
    [self.containerView addSubview:self.leadingView];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = LanguageToolMatch(@"置顶");
    label.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    label.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [self.leadingView addSubview:label];
    
    [self.leadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(self.containerView);
        make.height.mas_equalTo(DWScale(20));
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.leadingView);
        make.leading.mas_equalTo(self.leadingView).offset(16);
        make.trailing.mas_equalTo(self.leadingView).offset(-16);
        make.height.mas_equalTo(15);
    }];
    
    [self.leadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(label.mas_trailing).offset(16);
    }];
    
    self.displayView = [[UIScrollView alloc] init];
    [self.containerView addSubview:self.displayView];
    
    [self.displayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leadingView.mas_bottom).offset(2);
        make.leading.mas_equalTo(self.containerView).offset(16);
        make.trailing.mas_equalTo(self.containerView).offset(-16);
        make.bottom.mas_equalTo(self.containerView).offset(-16);
    }];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    [self.displayView addSubview:self.contentLabel];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.displayView);
        make.width.mas_equalTo(self.displayView);
    }];
    
    if (self.groupInfoModel.userGroupRole == 0) {
        self.editButton.hidden = YES;
        self.deleteButton.hidden = YES;
    }
}

- (void)requestNotifyDetail {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:self.groupInfoModel.groupId forKey:@"groupId"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setObjectSafe:self.groupNoticeModel.noticeId forKey:@"noticeId"];
    WeakSelf
    [IMSDKManager groupCheckOneGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            NoaGroupNoteModel *groupNoticeModel = [NoaGroupNoteModel mj_objectWithKeyValues:dataDict];
            weakSelf.groupNoticeModel = groupNoticeModel;
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        if (code == 41034) {
            [HUD showMessage:LanguageToolMatch(@"公告已删除")];
            if (self.deleteNoticyCallback) {
                // 上一级页面刷新
                self.deleteNoticyCallback();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [HUD showMessageWithCode:code errorMsg:msg];
        }
    }];
}

- (void)editNotifyEvent {
    NoaGroupModifyNoticeVC * vc = [NoaGroupModifyNoticeVC new];
    self.groupInfoModel.groupNotice = self.groupNoticeModel;
    vc.groupInfoModel = self.groupInfoModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteNotifyEvent {
    //删除群公告
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.groupNoticeModel.groupId forKey:@"groupId"];
    [dict setValue:self.groupNoticeModel.noticeId forKey:@"noticeId"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    [IMSDKManager groupDeleteGroupNoticeWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"删除成功")];
        if (weakSelf.deleteNoticyCallback) {
            weakSelf.deleteNoticyCallback();
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}


- (void)setGroupNoticeModel:(NoaGroupNoteModel *)groupNoticeModel {
    _groupNoticeModel = groupNoticeModel;
    [self.headPortrait sd_setImageWithURL:[groupNoticeModel.userHeader getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
    self.nameLabel.text = groupNoticeModel.noticeCreateNickname;
    self.timeLabel.text = [NSDate transTimeStrToDateMethod5:[groupNoticeModel.createTime integerValue]];
    //处理公告文字内容
    NSString *tempGroupNoctice = @"";
    if (![NSString isNil:groupNoticeModel.translateContent]) {
        NSString *currentLanguageMapCode = [ZLanguageTOOL languageCodeFromDevieInfo];
        NSDictionary *noticeDict = [NSString  jsonStringToDic:groupNoticeModel.translateContent];
        if (![[noticeDict allKeys] containsObject:currentLanguageMapCode]) {
            if ([currentLanguageMapCode isEqualToString:@"lb"]) {
                tempGroupNoctice = (NSString *)[noticeDict objectForKeySafe:@"lbb"];
            } else if ([currentLanguageMapCode isEqualToString:@"no"]) {
                tempGroupNoctice = (NSString *)[noticeDict objectForKeySafe:@"nor"];
            } else {
                NSString *notice_en = (NSString *)[noticeDict objectForKeySafe:@"en"];
                tempGroupNoctice = notice_en;
            }
        } else {
            NSString *notice_current = (NSString *)[noticeDict objectForKeySafe:currentLanguageMapCode];
            tempGroupNoctice = notice_current;
        }
    } else {
        tempGroupNoctice = groupNoticeModel.content;
    }
    // 设置行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6; // 行间距 6

    NSDictionary *attributes = @{
        NSParagraphStyleAttributeName: paragraphStyle
    };

    self.contentLabel.attributedText = [[NSAttributedString alloc] initWithString:tempGroupNoctice attributes:attributes];
    
    self.leadingView.hidden = [groupNoticeModel.topStatus isEqualToString:@"0"];
    [self.displayView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([groupNoticeModel.topStatus isEqualToString:@"0"]) {
            make.top.mas_equalTo(self.containerView).offset(16);
        } else {
            make.top.mas_equalTo(self.leadingView.mas_bottom).offset(2);
        }
        make.leading.mas_equalTo(self.containerView).offset(16);
        make.trailing.mas_equalTo(self.containerView).offset(-16);
        make.bottom.mas_equalTo(self.containerView).offset(-16);
    }];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"] ||
        [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.leadingView.bounds
                                                   byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomLeft)
                                                         cornerRadii:CGSizeMake(8, 8)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.path = path.CGPath;
        self.leadingView.layer.mask = maskLayer;
    } else {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.leadingView.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(8, 8)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.path = path.CGPath;
        self.leadingView.layer.mask = maskLayer;
    }
    
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = FONTR(14);
        _nameLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = FONTR(12);
        _timeLabel.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    }
    return _timeLabel;
}

- (UIImageView *)headPortrait {
    if (_headPortrait == nil) {
        _headPortrait = [[UIImageView alloc] init];
        _headPortrait.layer.masksToBounds = YES;
        _headPortrait.layer.cornerRadius = DWScale(24);
    }
    return _headPortrait;
}
@end
