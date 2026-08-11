//
//  NoaQRcodeScanViewController.m
//  NoaKit
//
//  Created by Candy on 2023/4/3.
//

#import "NoaQRcodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NoaImagePickerVC.h"      //相册
#import "NoaToolManager.h"

#import "NoaUserHomePageVC.h" //用户个人资料页
#import "NoaAuthPCloginViewController.h"  //授权登录
#import "NoaMessageAlertView.h"   //跳转到safari提醒弹窗
#import "NoaQrcodeTextContentViewController.h"    //纯文本展示
#import "NoaApplyJoinGroupViewController.h"   //扫码进群申请页
#import "NoaChatViewController.h"
#import "NoaJoinGroupModel.h" //邀请进群信息model
#import "NoaMessageAlertView.h"
#import "LXChatEncrypt.h"
#import "AesEncryptUtils.h"
@interface NoaQRcodeScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, ZImagePickerVCDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@end

@implementation NoaQRcodeScanViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //检查权限并开启扫描
    [self checkAVAuthorizationStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //停止扫描
    [self stopScanning];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR_00;
    [self setupUI];
    [self setupNavUI];
}

#pragma mark - UI
- (void)setupNavUI {
    self.navView.hidden = YES;
    
    UIButton *navBtnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    navBtnBack.frame = CGRectMake(16, DStatusBarH, 24, 44);
    navBtnBack.adjustsImageWhenHighlighted = NO;
    navBtnBack.exclusiveTouch = YES;
    [navBtnBack setImage:[UIImage imageNamed:@"nav_back_white"] forState:UIControlStateNormal];
    [navBtnBack addTarget:self action:@selector(navBtnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navBtnBack];
    [navBtnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(16);
        make.top.equalTo(self.view).offset(DStatusBarH);
        make.size.mas_equalTo(CGSizeMake(24, 44));
    }];
    [navBtnBack setEnlargeEdge:DWScale(10)];
    
}

- (void)checkAVAuthorizationStatus
{
    WeakSelf
    [ZTOOL getCameraAuth:^(BOOL granted) {
        DLog(@"相机权限:%d",granted);
        if (granted) {
            [weakSelf setupCameraUI];
        } else {
            [HUD showMessage:LanguageToolMatch(@"您没有权限访问相机")];
        }
    }];
}

- (void)setupUI {
    CGFloat scanWH = DWScale(297);
    CGFloat marginX = (DScreenWidth - scanWH) / 2;
    CGFloat marginY = (DScreenHeight - scanWH) / 2;
    CGFloat cornerWH = 26;
    
    //这盖层视图
    for (int i = 0; i < 4; i++) {
        UIView *coverView = [[UIView alloc] init];
        if (i == 0) {
            coverView.frame = CGRectMake(0, 0, DScreenWidth, marginY);
        }
        if (i == 1) {
            coverView.frame = CGRectMake(0, marginY + scanWH, DScreenWidth, DScreenHeight - scanWH - marginY);
        }
        if (i == 2 || i == 3) {
            coverView.frame = CGRectMake((marginX + scanWH) * (i - 2), marginY, marginX, scanWH);
        }
       
        coverView.userInteractionEnabled = YES;
        coverView.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3], [COLOR_00 colorWithAlphaComponent:0.3]];
        [self.view addSubview:coverView];
    }
    
    //扫描窗口视图
    UIView *scanView = [[UIView alloc] initWithFrame:CGRectMake(marginX, marginY, scanWH, scanWH)];
    [self.view addSubview:scanView];
    
    //边框
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scanWH, scanWH)];
    borderView.layer.borderColor = COLORWHITE.CGColor;
    borderView.layer.borderWidth = 1.0f;
    [scanView addSubview:borderView];
    
    //扫描窗口4个边角
    for (int i = 0; i < 4; i++) {
        CGFloat imgViewX = (scanWH - cornerWH) * (i % 2);
        CGFloat imgViewY = (scanWH - cornerWH) * (i / 2);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, cornerWH, cornerWH)];
        if (i == 0 || i == 1) {
            imgView.transform = CGAffineTransformRotate(imgView.transform, M_PI_2 * i);
        }else {
            imgView.transform = CGAffineTransformRotate(imgView.transform, - M_PI_2 * (i - 1));
        }
        [self drawImageForImageView:imgView];
        [scanView addSubview:imgView];
    }
    
    CGFloat btnSpaceW = (DScreenWidth - DWScale(65) * 2) / 3;
    //轻触开灯
    UIButton *lightBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [lightBtn setImage:ImgNamed(@"icon_qrcode_light") forState:UIControlStateNormal];
    [lightBtn setImage:ImgNamed(@"icon_qrcode_light") forState:UIControlStateSelected];
    [lightBtn addTarget:self action:@selector(lightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightBtn];
    [lightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).offset(btnSpaceW);
        make.top.equalTo(self.view.mas_top).offset(marginY + scanWH + DWScale(90));
        make.size.mas_equalTo(CGSizeMake(DWScale(65), DWScale(65)));
    }];
    UILabel * label1 = [UILabel new];
    label1.textColor = [UIColor whiteColor];
    label1.font = FONTR(12);
    label1.numberOfLines = 2;
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = LanguageToolMatch(@"轻触开灯");
    [self.view addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(lightBtn);
        make.top.equalTo(lightBtn.mas_bottom);
    }];
    
    //从相册选择
    UIButton *albumBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [albumBtn setImage:ImgNamed(@"icon_qrcode_album") forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(albumBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:albumBtn];
    [albumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view.mas_trailing).offset(-btnSpaceW);
        make.top.equalTo(self.view.mas_top).offset(marginY + scanWH + DWScale(90));
        make.size.mas_equalTo(CGSizeMake(DWScale(65), DWScale(65)));
    }];
    UILabel * label2 = [UILabel new];
    label2.textColor = [UIColor whiteColor];
    label2.font = FONTR(12);
    label2.numberOfLines = 2;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = LanguageToolMatch(@"从相册选择");
    [self.view addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(albumBtn);
        make.top.equalTo(albumBtn.mas_bottom);
    }];
}

- (void)setupCameraUI
{
    WeakSelf
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化相机设备
        weakSelf.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //初始化输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:weakSelf.device error:nil];
        //初始化输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //设置代理，主线程刷新
        [output setMetadataObjectsDelegate:weakSelf queue:dispatch_get_main_queue()];
        //初始化链接对象
        weakSelf.session = [[AVCaptureSession alloc] init];
        //高质量采集率
        [weakSelf.session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([weakSelf.session canAddInput:input]) {
            [weakSelf.session addInput:input];
        }
        if ([weakSelf.session canAddOutput:output]) {
            [weakSelf.session addOutput:output];
        }
        //条码类型（二维码/条形码）
        output.metadataObjectTypes = output.availableMetadataObjectTypes;
        //更新界面
        [ZTOOL doInMain:^{
            weakSelf.preview = [AVCaptureVideoPreviewLayer layerWithSession:weakSelf.session];
            weakSelf.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            weakSelf.preview.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
            [weakSelf.view.layer insertSublayer:weakSelf.preview atIndex:0];
        }];
        [weakSelf.session startRunning];
    });
}

#pragma mark - Action
- (void)navBtnBackClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)lightBtnClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    //判断是否有闪光灯
   if (![self.device hasTorch]) {
       [HUD showMessage:LanguageToolMatch(@"当前设备没有闪光灯，无法开启照明功能")];
       return;
   }
   
   btn.selected = !btn.selected;
   [self.device lockForConfiguration:nil];
   if (btn.selected) {
       [self.device setTorchMode:AVCaptureTorchModeOn];
   }else {
       [self.device setTorchMode:AVCaptureTorchModeOff];
   }
   [self.device unlockForConfiguration];
}

- (void)albumBtnClick:(id)sender {
    WeakSelf
    [ZTOOL getPhotoLibraryAuth:^(BOOL granted) {
        if (granted) {
            [ZTOOL doInMain:^{
                NoaImagePickerVC *vc = [NoaImagePickerVC new];
                vc.isSignlePhoto = YES;
                vc.isNeedEdit = NO;
                vc.hasCamera = YES;
                vc.delegate = self;
                [vc setPickerType:ZImagePickerTypeImage];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }];
        }else {
            [HUD showWarningMessage:LanguageToolMatch(@"相册权限未开启，请在设置中选择当前应用，开启相册权限")];
        }
    }];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描完成
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            //扫码结果
            [self requestTransformDataWithQrcdoeContent:[[metadataObjects firstObject] stringValue]];
        }
    }
}

#pragma mark - ZImagePickerVCDelegate
- (void)imagePickerClipImage:(UIImage *)resultImg localIdenti:(NSString *)localIdenti {
    //识别图片
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:resultImg.CGImage]];
    
    //识别结果
    if (features.count > 0) {
        //扫码结果
        [self requestTransformDataWithQrcdoeContent:[[features firstObject] messageString]];
    } else {
        [HUD showMessage:LanguageToolMatch(@"没有识别到二维码")];
    }
}
 
#pragma mark - Draw
//绘制扫码窗口4个角的图片
- (void)drawImageForImageView:(UIImageView *)imageView {
    UIGraphicsBeginImageContext(imageView.bounds.size);
    
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条宽度
    CGContextSetLineWidth(context, 6.0f);
    //设置线条颜色
    CGContextSetStrokeColorWithColor(context, COLOR_5966F2.CGColor);
    //路径
    CGContextBeginPath(context);
    //设置起点坐标
    CGContextMoveToPoint(context, 0, imageView.bounds.size.height);
    //设置下一个点坐标
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, imageView.bounds.size.width, 0);
    //渲染
    CGContextStrokePath(context);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


#pragma mark - Medth
- (void)stopScanning {
    [self.session stopRunning];
    self.session = nil;
    [self.preview removeFromSuperlayer];
}

- (BOOL)checkSacnResultForNav:(NSString *)content {
    BOOL result = NO;
    NSDictionary *contentDic = [NSString jsonStringToDic:content];
    if (contentDic && [[contentDic allKeys] containsObject:@"type"]) {
        NSInteger type = [[contentDic objectForKey:@"type"] integerValue];
        NSString *appId = (NSString *)[contentDic objectForKey:@"appId"];
        if (type == 5 ) {
            result = YES;
            //未解密的License信息（先Base64解码，再传入method8）
            NSString *content = (NSString *)[contentDic objectForKey:@"content"];
            NSData *b64Data = [[NSData alloc] initWithBase64EncodedString:content options:0];
            NSData *responseData = [AesEncryptUtils decryptBytes:b64Data secret:[appId MD5Encryption]];
            NSError *err = nil;
            IMServerListResponseBody *body = [IMServerListResponseBody parseFromData:responseData error:&err];
            if (!body) {
                NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeSingleBtn supView:nil];
                msgAlertView.lblTitle.text = LanguageToolMatch(@"无效二维码");
                msgAlertView.lblContent.text = LanguageToolMatch(@"当前二维码无效，确认是否有误");
                msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
                [msgAlertView.btnSure setTitle:LanguageToolMatch(@"我知道了") forState:UIControlStateNormal];
                [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
                msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
                [msgAlertView alertShow];
                WeakSelf
                msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                    [weakSelf setupCameraUI];
                };
            } else {
                NSLog(@"✅ 解密成功，数据长度: %lu", (unsigned long)responseData.length);
                WeakSelf
                NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
                msgAlertView.lblTitle.text = LanguageToolMatch(@"加入服务器");
                msgAlertView.lblContent.text = LanguageToolMatch(@"您正在加入服务器，是否确认？");
                msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
                [msgAlertView.btnSure setTitle:LanguageToolMatch(@"是") forState:UIControlStateNormal];
                [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
                msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
                [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"否") forState:UIControlStateNormal];
                [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
                msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
                [msgAlertView alertShow];
                msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                    if (weakSelf.QRcodeSacnNavBlock) {
                        weakSelf.QRcodeSacnNavBlock(body, appId);
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                };
                msgAlertView.cancelBtnBlock = ^{
                    [weakSelf setupCameraUI];
                };
            }
            
        }
    }
    return result;
}

#pragma mark - 判断扫码结果是不是邀请码相关操作
- (BOOL)checkSacnResultForLicense:(NSString *)content {
    BOOL result = NO;
    NSDictionary *contentDic = [NSString jsonStringToDic:content];
    if (contentDic && [[contentDic allKeys] containsObject:@"type"]) {
        NSInteger type = [[contentDic objectForKey:@"type"] integerValue];
        NSString *appId = (NSString *)[contentDic objectForKey:@"appId"];
        if (type == 4 && [appId isEqualToString:@"zim"]) {
            result = YES;
            //未解密的License信息
            NSString *rsaContent = (NSString *)[contentDic objectForKey:@"content"];
            NSString *liceseDicStr = [LXChatEncrypt method8:rsaContent];
            NSDictionary *liceseDic = [NSString jsonStringToDic:liceseDicStr];
            NSString *liceseId = (NSString *)[liceseDic objectForKey:@"appKey"];
            WeakSelf
            NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
            msgAlertView.lblTitle.text = LanguageToolMatch(@"加入服务器");
            msgAlertView.lblContent.text = [NSString stringWithFormat: LanguageToolMatch(@"您正在加入“%@”服务器，是否确认？"), liceseId];
            msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
            [msgAlertView.btnSure setTitle:LanguageToolMatch(@"是") forState:UIControlStateNormal];
            [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
            msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
            [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"否") forState:UIControlStateNormal];
            [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
            msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
            [msgAlertView alertShow];
            msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                if (weakSelf.QRcodeSacnLicenseBlock) {
                    weakSelf.QRcodeSacnLicenseBlock(liceseId, @"");
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            msgAlertView.cancelBtnBlock = ^{
                [weakSelf setupCameraUI];
            };
        }
    }
    return result;
}

#pragma mark - 判断扫码结果是不是IP/Domain直连
- (BOOL)checkSacnResultForIpDomainConnect:(NSString *)content {
    BOOL result = NO;
    NSDictionary *contentDic = [NSString jsonStringToDic:content];
    if (contentDic && [[contentDic allKeys] containsObject:@"type"]) {
        NSInteger type = [[contentDic objectForKey:@"type"] integerValue];
        NSString *appId = (NSString *)[contentDic objectForKey:@"appId"];
        if (type == 1 && [appId isEqualToString:@"zim"]) {
            result = YES;
            //IP/域名 + 端口号
            NSString *rsaContent = (NSString *)[contentDic objectForKey:@"content"];
            NSString *ipDomainPort = [LXChatEncrypt method8:rsaContent];
            WeakSelf
            NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
            msgAlertView.lblTitle.text = LanguageToolMatch(@"加入服务器");
            msgAlertView.lblContent.text = [NSString stringWithFormat: LanguageToolMatch(@"您正在加入“%@”服务器，是否确认？"), ipDomainPort];
            msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
            [msgAlertView.btnSure setTitle:LanguageToolMatch(@"是") forState:UIControlStateNormal];
            [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
            msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
            [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"否") forState:UIControlStateNormal];
            [msgAlertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
            msgAlertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
            [msgAlertView alertShow];
            msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                if (weakSelf.QRcodeSacnLicenseBlock) {
                    weakSelf.QRcodeSacnLicenseBlock(@"", ipDomainPort);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            msgAlertView.cancelBtnBlock = ^{
                [weakSelf setupCameraUI];
            };
        }
    }
    return result;
}

#pragma mark - Request
- (void)requestTransformDataWithQrcdoeContent:(NSString *)content {
    //先停止扫描
    [self stopScanning];
    
    //扫码出来的结果是License信息
    if (self.isRacing) {
        if ([self checkSacnResultForLicense:content] || [self checkSacnResultForIpDomainConnect:content] || [self checkSacnResultForNav:content]) {
            return;
        } else {
            NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeSingleBtn supView:nil];
            msgAlertView.lblTitle.text = LanguageToolMatch(@"无效二维码");
            msgAlertView.lblContent.text = LanguageToolMatch(@"当前二维码无效，确认是否有误");
            msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
            [msgAlertView.btnSure setTitle:LanguageToolMatch(@"我知道了") forState:UIControlStateNormal];
            [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
            msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
            [msgAlertView alertShow];
            WeakSelf
            msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                [weakSelf setupCameraUI];
            };
            return;
        }
    }
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:content forKey:@"content"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    WeakSelf
    [HUD showActivityMessage:LanguageToolMatch(@"加载中...")];
    [IMSDKManager UserGetTransformQrcodeContentWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        if([data isKindOfClass:[NSDictionary class]]){
            NSDictionary *dataDict = (NSDictionary *)data;
            NSInteger code = [[dataDict objectForKey:@"code"] integerValue];
            NSString *dataStr = (NSString *)[dataDict objectForKey:@"data"];
            [weakSelf navToResultWithCode:code dataStr:dataStr];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        
        if (code == 41055) {
            [HUD showMessage:LanguageToolMatch(@"当前群不支持二维码入群")];

            [weakSelf checkAVAuthorizationStatus];
        } else {
            NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeSingleBtn supView:nil];
            msgAlertView.lblTitle.text = LanguageToolMatch(@"无效二维码");
            msgAlertView.lblContent.text = code == 50005 ? LanguageToolMatch(@"二维码已过期") : LanguageToolMatch(@"当前二维码无效，确认是否有误");
            msgAlertView.lblContent.textAlignment = NSTextAlignmentLeft;
            [msgAlertView.btnSure setTitle:LanguageToolMatch(@"我知道了") forState:UIControlStateNormal];
            [msgAlertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
            msgAlertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
            [msgAlertView alertShow];
            WeakSelf
            msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                [weakSelf checkAVAuthorizationStatus];
            };
        }

    }];
}

#pragma mark - Action
- (void)navToResultWithCode:(ZQrCodeResult)code dataStr:(NSString *)dataStr {
    switch (code) {
        case ZQrCodeResultUser:
            {
                //用户二维码
                NSDictionary *dataDic = [NSString jsonStringToDic:dataStr];
                if (dataDic) {
                    NSDictionary *userInfoDic = (NSDictionary *)[dataDic objectForKey:@"userInfo"];
                    NSString *uidStr = (NSString *)[userInfoDic objectForKey:@"uid"];
                    NoaUserHomePageVC *vc = [NoaUserHomePageVC new];
                    vc.isFromQRCode = YES;
                    vc.userUID = uidStr;
                    vc.groupID = @"";
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            break;
        case ZQrCodeResultGroup:
            {
                //群二维码
                NSDictionary *dataDic = [NSString jsonStringToDic:dataStr];
                if (dataDic) {
                    NSDictionary *groupInfo = (NSDictionary *)[dataDic objectForKey:@"groupInfo"];
                    NSInteger groupStatus = [[groupInfo objectForKey:@"groupStatus"] integerValue];
        
                    if (groupStatus == 1) {
                        BOOL isOnGroup = [[dataDic objectForKey:@"isOnGroup"] boolValue];
                        if (isOnGroup) {
                            //已在当前群，进入群聊天
                            NoaChatViewController *chatVC = [[NoaChatViewController alloc] init];
                            chatVC.isFromQRCode = YES;
                            chatVC.chatName = (NSString *)[groupInfo objectForKey:@"gName"];
                            chatVC.sessionID = (NSString *)[groupInfo objectForKey:@"gid"];
                            chatVC.chatType = CIMChatType_GroupChat;
                            [self.navigationController pushViewController:chatVC animated:YES];
                        } else {
                            //不在当前群
                            NoaJoinGroupModel *applyModel = [NoaJoinGroupModel mj_objectWithKeyValues:dataDic];
                            //邀请进群页
                            NoaApplyJoinGroupViewController *applyJoinGroupVC = [[NoaApplyJoinGroupViewController alloc] init];
                            applyJoinGroupVC.applyGroupModel = applyModel;
                            [self.navigationController pushViewController:applyJoinGroupVC animated:YES];
                        }
                    }
                }
            }
            break;
        case ZQrCodeResultPCAuth:
            {
                //授权PC端登录
                NSDictionary *dataDic = [NSString jsonStringToDic:dataStr];
                if (dataDic) {
                    NSString *deviceUuid = (NSString *)[dataDic objectForKey:@"deviceUuid"];
                    NSString *ewmKey = (NSString *)[dataDic objectForKey:@"ewmKey"];
                    //授权PC登录页
                    NoaAuthPCloginViewController *pcAuthVC = [[NoaAuthPCloginViewController alloc] init];
                    pcAuthVC.deviceUuidStr = deviceUuid;
                    pcAuthVC.ewmKeyStr = ewmKey;
                    [self.navigationController pushViewController:pcAuthVC animated:YES];
                }
            }
            break;
        case ZQrCodeResultUrl:
            {
                //url,跳转到自带浏览器
                NSString *urlString = [NSString stringWithFormat:@"%@", dataStr];
                if (![NSString isNil:urlString]) {
                    WeakSelf
                    NoaMessageAlertView *msgAlertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeNomal supView:nil];
                    //msgAlertView.lblTitle.text = LanguageToolMatch(@"跳转到Safari浏览器");
                    msgAlertView.lblContent.text = LanguageToolMatch(@"扫码结果为网址，跳转到Safrai并打开");
                    [msgAlertView.btnSure setTitle:LanguageToolMatch(@"是") forState:UIControlStateNormal];
                    [msgAlertView.btnCancel setTitle:LanguageToolMatch(@"否") forState:UIControlStateNormal];
                    [msgAlertView alertShow];
                    msgAlertView.sureBtnBlock = ^(BOOL isCheckBox) {
                        //跳转到Safari浏览器
                        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
                            [weakSelf checkAVAuthorizationStatus];
                        }
                    };
                    msgAlertView.cancelBtnBlock = ^{
                        [weakSelf checkAVAuthorizationStatus];
                    };
                }
            }
            break;
        case ZQrCodeResultTxt:
            {
                //纯文本内容
                NSString *textContent = [NSString stringWithFormat:@"%@", dataStr];
                if (![NSString isNil:textContent]) {
                    NoaQrcodeTextContentViewController *textContentVC = [[NoaQrcodeTextContentViewController alloc] init];
                    textContentVC.textContent = textContent;
                    [self.navigationController pushViewController:textContentVC animated:YES];
                }
            }
            break;
            
        default:
            break;
    }
}

@end
