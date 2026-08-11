//
//  NoaGroupQRCodeVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/7.
//

#import "NoaGroupQRCodeVC.h"
#import "NoaBaseImageView.h"
#import "UIImage+YYImageHelper.h"
#import "NoaChatKit-Swift.h"

@interface NoaGroupQRCodeVC ()

@property (nonatomic,strong)UIImageView *qrCodeBgView;
@property (nonatomic,strong)NoaBaseImageView * ivQrcode;
@property (nonatomic, strong) UILabel * tipLabel1;
@end

@implementation NoaGroupQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self setupNavUI];
    [self setupUI];
}

#pragma mark - 界面布局
- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"群二维码");
    self.navBtnRight.hidden = YES;
}

- (void)setupUI {
    self.qrCodeBgView = [[UIImageView alloc] initWithImage:ImgNamed(@"g_qrcode_bgiew")];
    [self.view addSubview:self.qrCodeBgView];
    [self.qrCodeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(30));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(DWScale(300), DWScale(400)));
    }];
    
    NoaBaseImageView * groupAvatar = [NoaBaseImageView new] ;
    [groupAvatar rounded:DWScale(25) width:2 color:COLORWHITE];
    [groupAvatar sd_setImageWithURL:[self.groupInfoModel.groupAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
    [self.qrCodeBgView addSubview:groupAvatar];
    [groupAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(DWScale(22));
        make.leading.mas_equalTo(DWScale(25));
        make.size.mas_equalTo(CGSizeMake(DWScale(50), DWScale(50)));
    }];
    
    UILabel * groupNameLabel = [UILabel new];
    groupNameLabel.font = FONTR(16);
    groupNameLabel.text = [NSString stringWithFormat:@"%@",self.groupInfoModel.groupName];
    groupNameLabel.textColor = [UIColor whiteColor];
    [self.qrCodeBgView addSubview:groupNameLabel];
    [groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(groupAvatar.mas_trailing).offset(DWScale(10));
        make.trailing.mas_equalTo(self.qrCodeBgView.mas_trailing).offset(-DWScale(10));
        make.centerY.mas_equalTo(groupAvatar);
        make.height.mas_equalTo(DWScale(22));
    }];
    
    UIImageView * codeBgview =[UIImageView new];
    //codeBgview.image =ImgNamed(@"g_qrcode_bg");
    [self.qrCodeBgView addSubview:codeBgview];
    [codeBgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.qrCodeBgView);
        make.bottom.mas_equalTo(self.qrCodeBgView).offset(-DWScale(26));
        make.size.mas_equalTo(CGSizeMake(DWScale(250), DWScale(250)));
    }];
    
    _ivQrcode = [NoaBaseImageView new] ;
    UIImage *qrcodeImage = [UIImage getQRCodeImageWithString:self.qrcoceContent  qrCodeColor:COLOR_00 inputCorrectionLevel:QRCodeInputCorrectionLevel_M];
    _ivQrcode.image = qrcodeImage;
    [codeBgview addSubview:_ivQrcode];
    [_ivQrcode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(codeBgview);
        make.size.mas_equalTo(CGSizeMake(DWScale(230), DWScale(230)));
    }];
    
    [self.qrCodeBgView addSubview:self.tipLabel1];
    [self.tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qrCodeBgView.mas_bottom).offset(DWScale(16));
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.qrCodeBgView);
        make.height.mas_equalTo(DWScale(42));
    }];
    
    CGFloat btn_space = (DScreenWidth - DWScale(48)*2) / 3;
    //保存相册
    UIButton * savePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [savePhotoBtn setBackgroundColor:[UIColor whiteColor]];
    savePhotoBtn.layer.cornerRadius = DWScale(48/2);
    savePhotoBtn.clipsToBounds = YES;
    [savePhotoBtn setImage:ImgNamed(@"g_savephoto_logo") forState:UIControlStateNormal];
    [savePhotoBtn addTarget:self action:@selector(savePhotoBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:savePhotoBtn];
    [savePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLabel1.mas_bottom).offset(DWScale(40));
        make.leading.equalTo(self.view).offset(btn_space);
        make.size.mas_equalTo(CGSizeMake(DWScale(48), DWScale(48)));
    }];
    
    UILabel * savetipLabel = [UILabel new];
    savetipLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    savetipLabel.font = FONTR(13);
    savetipLabel.text = LanguageToolMatch(@"保存相册");
    [self.view addSubview:savetipLabel];
    [savetipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(savePhotoBtn.mas_bottom).offset(DWScale(10));
        make.centerX.equalTo(savePhotoBtn);
        make.height.mas_equalTo(DWScale(18));
    }];
    
    //分享二维码
    UIButton * shanerQRBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shanerQRBtn setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
    shanerQRBtn.layer.cornerRadius = DWScale(48/2);
    shanerQRBtn.clipsToBounds = YES;
    [shanerQRBtn setImage:ImgNamed(@"g_share_logo") forState:UIControlStateNormal];
    [shanerQRBtn addTarget:self action:@selector(shareQRcodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shanerQRBtn];
    [shanerQRBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLabel1.mas_bottom).offset(DWScale(40));
        make.centerX.equalTo(savePhotoBtn.mas_trailing).offset(btn_space);
        make.size.mas_equalTo(CGSizeMake(DWScale(48), DWScale(48)));
    }];
    
    UILabel * sharetipLabel = [UILabel new];
    sharetipLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    sharetipLabel.font = FONTR(13);
    sharetipLabel.text = LanguageToolMatch(@"分享");
    [self.view addSubview:sharetipLabel];
    [sharetipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shanerQRBtn.mas_bottom).offset(DWScale(10));
        make.centerX.equalTo(shanerQRBtn);
        make.height.mas_equalTo(DWScale(18));
    }];
}

- (void)savePhotoBtnAction{
    UIGraphicsBeginImageContextWithOptions(self.qrCodeBgView.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.qrCodeBgView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //保存到相册
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)shareQRcodeBtnClick {
    UIGraphicsBeginImageContextWithOptions(self.qrCodeBgView.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.qrCodeBgView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //分享二维码
    CoHereChatMultiSelectViewController *vc = [CoHereChatMultiSelectViewController new];
    vc.multiSelectType = ZMultiSelectTypeShareQRImg;
    vc.fromSessionId = self.groupInfoModel.groupId;
    vc.qrCodeImg = image;
    [self.navigationController pushViewController:vc animated:YES];
    [vc setShareQrCodeMsgSendSuccess:^(NoaIMChatMessageModel * _Nonnull sendForwardMsg) {
        //发送通知通知:群二维分享成功，并且分享到当前群聊，需要本地在会话界面添加一条二维码图片消息
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageShareQRCodeToSelfGroupNotification" object:sendForwardMsg userInfo:nil];
    }];
}
 
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = nil;
    if (!error) {
        message = LanguageToolMatch(@"已保存至相册");
        [HUD showMessage:message];
    } else {
        message = [error description];
    }
}

- (void)setExpireTime:(NSInteger)expireTime {
    _expireTime = expireTime;
    // 获取月和日并拼接到字符串
    NSString *timeString = [NSDate transTimeStrToDateMethod1:expireTime];
    NSArray *timeComponents = [timeString componentsSeparatedByString:@"-"]; // 将字符串按“-”拆分
    NSString *month = timeComponents[0];
    NSString *day = [timeComponents[1] componentsSeparatedByString:@" "][0]; // 取日部分
    if ([month hasPrefix:@"0"]) {
        month = [month substringFromIndex:1];
    }
    self.tipLabel1.text = [NSString stringWithFormat:LanguageToolMatch(@"该二维码7天内（%@月%@日前）有效，重新进入将更新"), month, day];
}

- (UILabel *)tipLabel1 {
    if (_tipLabel1 == nil) {
        _tipLabel1 = [[UILabel alloc] init];
        _tipLabel1.font = FONTR(14);
        _tipLabel1.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
        _tipLabel1.textAlignment = NSTextAlignmentCenter;
        _tipLabel1.numberOfLines = 2;
    }
    return _tipLabel1;
}

@end
