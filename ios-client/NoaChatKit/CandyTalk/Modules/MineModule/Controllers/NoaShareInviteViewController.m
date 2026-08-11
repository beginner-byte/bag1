//
//  NoaShareInviteViewController.m
//  NoaKit
//
//  Created by Candy on 2023/6/30.
//

#import "NoaShareInviteViewController.h"
#import "NoaToolManager.h"
#import "UIImage+YYImageHelper.h"

@interface NoaShareInviteViewController ()

@property(nonatomic, strong)UIImageView *showBackView;
@property(nonatomic, strong)UILabel *invitedNumLbl;
@property(nonatomic, strong)UILabel *inviteCodeLbl;
@property(nonatomic, strong)UIImageView *qrcodeImgView;
@property(nonatomic, strong)UIButton *shareBtn;

@property (nonatomic, copy) NSString *shareLink;//分享链接地址
@end

@implementation NoaShareInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    self.navTitleStr = LanguageToolMatch(@"分享邀请");
    [self setupNavUI];
    [self setupUI];
    
    //[self requestGetShareInviteData];
    //新的分享 团队分享
    if (![NSString isNil:_teamID]) {
        [self requestTeamShareData];
    }else {
        [self requestTeamDefaultShareData];
    }
}
- (void)setupNavUI {
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setTitle:LanguageToolMatch(@"复制链接") forState:UIControlStateNormal];
    [self.navBtnRight setTkThemeTitleColor:@[HEXCOLOR(@"6E79FF"), HEXCOLOR(@"6E79FF")] forState:UIControlStateNormal];
}
- (void)setupUI {
    [self.view addSubview:self.showBackView];
    [self.showBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom);
        make.leading.bottom.trailing.equalTo(self.view);
    }];
        
    //来自 xx App
    UILabel *fromAppLbl = [[UILabel alloc] init];
    fromAppLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"来%@"), [ZTOOL getAppName]];
    fromAppLbl.tkThemetextColors = @[COLOR_5031B8, COLOR_5031B8_DARK];
    fromAppLbl.font = FONTB(24);
    fromAppLbl.textAlignment = NSTextAlignmentCenter;
    [self.showBackView addSubview:fromAppLbl];
    [fromAppLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(21));
        make.leading.equalTo(self.showBackView).offset(DWScale(54));
        make.trailing.equalTo(self.showBackView).offset(-DWScale(54));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    //tips:体验新的聊天乐趣
    UILabel *fromTipsLbl = [[UILabel alloc] init];
    fromTipsLbl.text = LanguageToolMatch(@"体验新的聊天乐趣");
    fromTipsLbl.tkThemetextColors = @[COLOR_5031B8, COLOR_5031B8_DARK];
    fromTipsLbl.font = FONTN(16);
    fromTipsLbl.numberOfLines = 2;
    fromTipsLbl.textAlignment = NSTextAlignmentCenter;
    [self.showBackView addSubview:fromTipsLbl];
    [fromTipsLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fromAppLbl.mas_bottom).offset(DWScale(30));
        make.leading.trailing.equalTo(fromAppLbl);
    }];
    
    //userName
    UILabel *userNameLbl = [[UILabel alloc] init];
    userNameLbl.text = UserManager.userInfo.nickname;
    userNameLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    userNameLbl.font = FONTB(16);
    userNameLbl.textAlignment = NSTextAlignmentCenter;
    [self.showBackView addSubview:userNameLbl];
    [userNameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fromTipsLbl.mas_bottom).offset(DWScale(73));
        make.leading.trailing.equalTo(fromAppLbl);
        make.height.mas_equalTo(DWScale(16));
    }];
    
    //已经邀请背景
    UIView *invitedBgView = [[UIView alloc] init];
    invitedBgView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [invitedBgView rounded:DWScale(12)];
    [invitedBgView shadow:COLOR_D4E6F2 opacity:1 radius:5 offset:CGSizeMake(0, 0)];
    [self.showBackView addSubview:invitedBgView];
    [invitedBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userNameLbl.mas_bottom).offset(DWScale(12));
        make.centerX.equalTo(userNameLbl);
        make.width.mas_equalTo(DWScale(245));
        make.height.mas_equalTo(DWScale(40));
    }];
    
    //已经邀请
    UILabel *invitedTitleLbl = [[UILabel alloc] init];
    invitedTitleLbl.text = LanguageToolMatch(@"已经邀请");
    invitedTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    invitedTitleLbl.font = FONTN(14);
    invitedTitleLbl.textAlignment = NSTextAlignmentLeft;
    [invitedBgView addSubview:invitedTitleLbl];
    [invitedTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(invitedBgView);
        make.leading.equalTo(invitedBgView).offset(DWScale(10));
        make.width.mas_equalTo(DWScale(75));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    //x位用户
    _invitedNumLbl = [[UILabel alloc] init];
    _invitedNumLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"%d位用户"), 0];
    _invitedNumLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _invitedNumLbl.font = FONTN(14);
    _invitedNumLbl.textAlignment = NSTextAlignmentRight;
    [invitedBgView addSubview:_invitedNumLbl];
    [_invitedNumLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(invitedBgView);
        make.trailing.equalTo(invitedBgView).offset(-DWScale(15));
        make.width.mas_equalTo(DWScale(90));
        make.height.mas_equalTo(DWScale(16));
    }];

    //邀请码
    UIView *inviteCodeBgView = [[UIView alloc] init];
    inviteCodeBgView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [inviteCodeBgView rounded:DWScale(12)];
    [inviteCodeBgView shadow:COLOR_D4E6F2 opacity:0.6 radius:3 offset:CGSizeMake(0, 0)];
    [self.showBackView addSubview:inviteCodeBgView];
    [inviteCodeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(invitedBgView.mas_bottom).offset(DWScale(10));
        make.centerX.equalTo(userNameLbl);
        make.width.mas_equalTo(DWScale(245));
        make.height.mas_equalTo(DWScale(40));
    }];
    
    // 邀请码
    UILabel *inviteCodeTitleLbl = [[UILabel alloc] init];
    inviteCodeTitleLbl.text = LanguageToolMatch(@"邀请码");
    inviteCodeTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    inviteCodeTitleLbl.font = FONTN(14);
    inviteCodeTitleLbl.textAlignment = NSTextAlignmentLeft;
    [inviteCodeBgView addSubview:inviteCodeTitleLbl];
    [inviteCodeTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(inviteCodeBgView);
        make.leading.equalTo(inviteCodeBgView).offset(DWScale(10));
        make.width.mas_equalTo(DWScale(60));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    // 邀请码内容:XXXXXX
    _inviteCodeLbl = [[UILabel alloc] init];
    _inviteCodeLbl.text = @"--";
    _inviteCodeLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _inviteCodeLbl.font = FONTN(14);
    _inviteCodeLbl.textAlignment = NSTextAlignmentRight;
    [inviteCodeBgView addSubview:_inviteCodeLbl];
    [_inviteCodeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(inviteCodeBgView);
        make.trailing.equalTo(inviteCodeBgView).offset(-DWScale(15));
        make.width.mas_equalTo(DWScale(90));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    //长按二维码手势
    UITapGestureRecognizer *inviteCodeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteCodeTapClick)];
    [inviteCodeBgView addGestureRecognizer:inviteCodeTap];
    
    // 网络地址
    NSString *netUrlStr = @"--";
    NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
    if (ssoModel) {
        if (![NSString isNil:ssoModel.liceseId]) {
            netUrlStr = ssoModel.liceseId;
        }
        if (![NSString isNil:ssoModel.ipDomainPortStr]) {
            netUrlStr = ssoModel.ipDomainPortStr;
        }
    }
    //最后四位用****做脱敏处理
    netUrlStr = [netUrlStr stringByReplacingCharactersInRange:NSMakeRange(netUrlStr.length - 4, 4) withString:@"****"];
    UILabel *netUrlContentLbl = [[UILabel alloc] init];
    netUrlContentLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"网络地址：%@"), netUrlStr];
    netUrlContentLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    netUrlContentLbl.font = FONTN(14);
    netUrlContentLbl.textAlignment = NSTextAlignmentCenter;
    [self.showBackView addSubview:netUrlContentLbl];
    [netUrlContentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inviteCodeBgView.mas_bottom).offset(DWScale(110));
        make.leading.equalTo(self.showBackView).offset(DWScale(44));
        make.trailing.equalTo(self.showBackView).offset(-DWScale(44));
        make.height.mas_equalTo(DWScale(16));
    }];
    
    //二维码背景
    UIView *qrcodeBgView = [[UIView alloc] init];
    qrcodeBgView.userInteractionEnabled = YES;
    [qrcodeBgView rounded:DWScale(15) width:0.8 color:COLOR_698CFE];
    [self.showBackView addSubview:qrcodeBgView];
    [qrcodeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(netUrlContentLbl.mas_bottom).offset(DWScale(11));
        make.centerX.equalTo(netUrlContentLbl);
        make.width.height.mas_equalTo(DWScale(135));
    }];

    //二维码边框
    _qrcodeImgView = [[UIImageView alloc] init];
    _qrcodeImgView.image = ImgNamed(@"");
    [self.showBackView addSubview:_qrcodeImgView];
    [_qrcodeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(qrcodeBgView);
        make.size.mas_equalTo(CGSizeMake(DWScale(105), DWScale(105)));
    }];
    //长按二维码手势
    UILongPressGestureRecognizer *qrcodeLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(qrcodeLongTapClick:)];
    [qrcodeBgView addGestureRecognizer:qrcodeLongTap];
    
    //分享按钮
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareBtn setTitle:LanguageToolMatch(@"分享") forState:UIControlStateNormal];
    [_shareBtn setTkThemeTitleColor:@[COLOR_6E79FF, COLOR_6E79FF_DARK] forState:UIControlStateNormal];
    _shareBtn.titleLabel.font = FONTN(14);
    [_shareBtn rounded:DWScale(6)];
    [_shareBtn setTkThemebackgroundColors:@[COLOR_DDE0FF, COLOR_DDE0FF_DARK]];
    [_shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.showBackView addSubview:_shareBtn];
    [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(qrcodeBgView.mas_bottom).offset(-DWScale(8));
        make.centerX.equalTo(qrcodeBgView);
        make.size.mas_equalTo(CGSizeMake(DWScale(103), DWScale(30)));
    }];
    
    //邀请更多好友来体验
    UILabel *inviteTipsLbl = [[UILabel alloc] init];
    inviteTipsLbl.text = LanguageToolMatch(@"邀请更多好友来体验");
    inviteTipsLbl.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    inviteTipsLbl.font = FONTN(14);
    inviteTipsLbl.textAlignment = NSTextAlignmentCenter;
    [self.showBackView addSubview:inviteTipsLbl];
    [inviteTipsLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_shareBtn.mas_bottom).offset(DWScale(68));
        make.leading.equalTo(self.showBackView).offset(DWScale(44));
        make.trailing.equalTo(self.showBackView).offset(-DWScale(44));
        make.height.mas_equalTo(DWScale(20));
    }];
}

- (void)navBtnRightClicked {
    if (![NSString isNil:_shareLink]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _shareLink;
        [HUD showMessage:LanguageToolMatch(@"复制成功")];
    }
}

#pragma mark - request
- (void)requestGetShareInviteData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    
    WeakSelf
    [IMSDKManager getFriendShareInviteInfo:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            NSInteger friendNum = [[dataDict objectForKeySafe:@"friendNum"] integerValue];
            NSString *invitationCode = (NSString *)[dataDict objectForKeySafe:@"invitationCode"];
            NSString *registerHtml = (NSString *)[dataDict objectForKeySafe:@"registerHtml"];
            //已经邀请人数
            weakSelf.invitedNumLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"%d位用户"), friendNum];
            //邀请码
            weakSelf.inviteCodeLbl.text = invitationCode;
            //生成二维码
            UIImage *qrcodeImage = [UIImage getQRCodeImageWithString:[self handleShareQrcodeUrlWithBaseUrl:registerHtml] qrCodeColor:COLOR_00 inputCorrectionLevel:QRCodeInputCorrectionLevel_M];
            weakSelf.qrcodeImgView.image = qrcodeImage;
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        return;
    }];
}

#pragma mark - Action & Tap
//NavBack
- (void)navToBackAction {
    [super navBtnBackClicked];
}

//复制 邀请码
- (void)inviteCodeTapClick {
    [HUD showMessage:LanguageToolMatch(@"复制成功")];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _inviteCodeLbl.text;
}

//长按二维码保存相册
- (void)qrcodeLongTapClick:(UILongPressGestureRecognizer *)longPressGesture {
    //长按手势会分别在UIGestureRecognizerStateBegan和UIGestureRecognizerStateEnded状态时调用响应函数，
    //此处需做判断
    if (longPressGesture.state == UIGestureRecognizerStateBegan){
        WeakSelf
        NoaPresentItem *saveAlbumItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"保存相册") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            if (themeIndex == 0) {
                saveAlbumItem.textColor = COLOR_11;
                saveAlbumItem.backgroundColor = COLORWHITE;
            }else {
                saveAlbumItem.textColor = COLORWHITE;
                saveAlbumItem.backgroundColor = COLOR_11;
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
        NoaPresentView *viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[saveAlbumItem] cancleItem:cancelItem doneClick:^(NSInteger index) {
            if (index == 0) {
                [ZTOOL doInMain:^{
                    [weakSelf performSelector:@selector(saveShareScreenshotToAlbum) withObject:nil afterDelay:0.5];
                }];
            }
        } cancleClick:^{
        }];
        [self.view addSubview:viewAlert];
        [viewAlert showPresentView];
   }
}

//分享
- (void)shareBtnClick {
    self.navView.hidden = YES;
    self.shareBtn.hidden = YES;
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.navView.hidden = NO;
    self.shareBtn.hidden = NO;

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint];
    // 该控制器不能push，只能使用模态视图弹出
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Other
//保存到相册
- (void)saveShareScreenshotToAlbum {
    self.navView.hidden = YES;
    self.shareBtn.hidden = YES;
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.navView.hidden = NO;
    self.shareBtn.hidden = NO;

    //保存到相册
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = nil;
    if (!error) {
        message = LanguageToolMatch(@"已保存至相册");
    } else {
        message = [error description];
    }
    [HUD showMessage:message];
}

//组装生成二维码的url
/**
 邀请码示例：xxx/xxx.html?code=123&server=123456&type=1&userId=12313123123123123123213&userName=小小张
 直连示例：xxx/xxx.html?code=3q24&server=http%3A%2F%2Fwww.baidu.com&type=2&userId=12313123123123123123213&userName=小小张 */
- (NSString *)handleShareQrcodeUrlWithBaseUrl:(NSString *)baseUrl {
    if (![NSString isNil:baseUrl]) {
        //code
        NSMutableString *qrcodeUrl = [NSMutableString stringWithString:baseUrl];
        [qrcodeUrl appendString:@"?code="];
        [qrcodeUrl appendString:_inviteCodeLbl.text];
        //server
        NSString *netUrlStr = @"--";
        NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
        if (ssoModel) {
            if (![NSString isNil:ssoModel.liceseId]) {
                netUrlStr = ssoModel.liceseId;
            }
            if (![NSString isNil:ssoModel.ipDomainPortStr]) {
                netUrlStr = ssoModel.ipDomainPortStr;
            }
        }
        //最后四位用****做脱敏处理
        netUrlStr = [netUrlStr stringByReplacingCharactersInRange:NSMakeRange(netUrlStr.length - 4, 4) withString:@"****"];
        [qrcodeUrl appendString:@"&server="];
        [qrcodeUrl appendString:netUrlStr];
        //userName
        [qrcodeUrl appendString:@"&userName="];
        [qrcodeUrl appendString:UserManager.userInfo.nickname ? UserManager.userInfo.nickname : @""];
        
        return qrcodeUrl;
    } else {
        return @"";
    }
}

#pragma mark - Lazy
- (UIImageView *)showBackView {
    if (!_showBackView) {
        _showBackView = [[UIImageView alloc] init];
        _showBackView.userInteractionEnabled = YES;
        _showBackView.contentMode = UIViewContentModeScaleAspectFit;
        _showBackView.image = ImgNamed(@"img_share_bg.png");
    }
    return _showBackView;
}

#pragma mark - 数据请求
//个人中心，请求默认团队分享
- (void)requestTeamDefaultShareData {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    [IMSDKManager imTeamDefaultShareWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dataDict = (NSDictionary *)data;
            
            NSInteger friendNum = [[dataDict objectForKeySafe:@"friendNum"] integerValue];
            
            NSString *invitationCode = (NSString *)[dataDict objectForKeySafe:@"invitationCode"];
            
            NSString *registerHtml = (NSString *)[dataDict objectForKeySafe:@"registerHtml"];
            
            //已经邀请人数
            weakSelf.invitedNumLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"%d位用户"), friendNum];
            //邀请码
            weakSelf.inviteCodeLbl.text = invitationCode;
            //生成二维码
            UIImage *qrcodeImage = [UIImage getQRCodeImageWithString:[self handleShareQrcodeUrlWithBaseUrl:registerHtml] qrCodeColor:COLOR_00 inputCorrectionLevel:QRCodeInputCorrectionLevel_M];
            weakSelf.qrcodeImgView.image = qrcodeImage;
            //分享的链接
            weakSelf.shareLink = [weakSelf handleShareQrcodeUrlWithBaseUrl:registerHtml];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//某个团队的分享
- (void)requestTeamShareData {
    if (![NSString isNil:_teamID]) {
        WeakSelf
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:_teamID forKey:@"teamId"];
        [IMSDKManager imTeamShareWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dataDict = (NSDictionary *)data;
                
                NSInteger friendNum = [[dataDict objectForKeySafe:@"friendNum"] integerValue];
                
                NSString *invitationCode = (NSString *)[dataDict objectForKeySafe:@"invitationCode"];
                
                NSString *registerHtml = (NSString *)[dataDict objectForKeySafe:@"registerHtml"];
                
                //已经邀请人数
                weakSelf.invitedNumLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"%d位用户"), friendNum];
                //邀请码
                weakSelf.inviteCodeLbl.text = invitationCode;
                //生成二维码
                UIImage *qrcodeImage = [UIImage getQRCodeImageWithString:[self handleShareQrcodeUrlWithBaseUrl:registerHtml] qrCodeColor:COLOR_00 inputCorrectionLevel:QRCodeInputCorrectionLevel_M];
                weakSelf.qrcodeImgView.image = qrcodeImage;
                //分享的链接
                weakSelf.shareLink = [weakSelf handleShareQrcodeUrlWithBaseUrl:registerHtml];
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }
}

@end
