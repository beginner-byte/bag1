//
//  NoaConfigMiniAppView.m
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaConfigMiniAppView.h"
#import "NoaToolManager.h"
#import "NoaImagePickerVC.h"
#import "NoaFileUploadManager.h"
//#import "ZFileNetProgressManager.h"

@interface NoaConfigMiniAppView () <UIGestureRecognizerDelegate, ZImagePickerVCDelegate>

/// 配置类型
@property (nonatomic, assign) ZConfigMiniAppType configType;

/// 视图容器
@property (nonatomic, strong) UIView *contentContainer;

/// 标题
@property (nonatomic, strong) UILabel *titleLabel;

/// 子标题
@property (nonatomic, strong) UILabel *subTitleLabel;

/// 设置图片按钮
@property (nonatomic, strong) UIButton *imageChangeBtn;

/// 编辑图片
@property (nonatomic, strong) UIImageView *editImgView;

/// 名称、连接输入容器
@property (nonatomic, strong) UIView *nameAndLinkContainer;

/// 名称
@property (nonatomic, strong) UITextField *nameTF;

/// 连接
@property (nonatomic, strong) UITextField *urlTF;

/// 开启密码
@property (nonatomic, strong) UIButton *changePasswordStateBtn;

/// 密码
@property (nonatomic, strong) UIView *passwordContainer;

/// 密码输入
@property (nonatomic, strong) UITextField *passwordTF;

/// 取消按钮
@property (nonatomic, strong) UIButton *btnCancel;

/// 保存按钮
@property (nonatomic, strong) UIButton *btnSave;

/// 是否使用本地图片
@property (nonatomic, assign) BOOL localImage;

@end

@implementation NoaConfigMiniAppView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)contentContainer {
    if (!_contentContainer) {
        _contentContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _contentContainer.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        _contentContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    }
    return _contentContainer;
}

- (UIButton *)imageChangeBtn {
    if (!_imageChangeBtn) {
        _imageChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imageChangeBtn setImage:ImgNamed(@"mini_app_add_gray") forState:UIControlStateNormal];
        [_imageChangeBtn addTarget:self action:@selector(btnHeaderClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageChangeBtn;
}

- (UIImageView *)editImgView {
    if (!_editImgView) {
        _editImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _editImgView.image = ImgNamed(@"mini_app_change_img_edit");
    }
    return _editImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = LanguageToolMatch(@"设置头像");
        _titleLabel.font = FONTSB(16);
        _titleLabel.tkThemetextColors = @[COLOR_00, COLOR_00_DARK];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.text = LanguageToolMatch(@"不设置头像自动生成");
        _subTitleLabel.font = FONTR(12);
        _subTitleLabel.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    }
    return _subTitleLabel;
}

- (UIView *)nameAndLinkContainer {
    if (!_nameAndLinkContainer) {
        _nameAndLinkContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _nameAndLinkContainer.tkThemebackgroundColors = @[HEXCOLOR(@"F5F6F8"), HEXCOLOR(@"373737")];
        _nameAndLinkContainer.layer.cornerRadius = 16;
        _nameAndLinkContainer.layer.masksToBounds = YES;
    }
    return _nameAndLinkContainer;
}

- (UITextField *)nameTF {
    if (!_nameTF) {
        _nameTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _nameTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置左边文字距离左边框间隔
        _nameTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        _nameTF.leftViewMode = UITextFieldViewModeAlways;
        _nameTF.font = FONTR(14);
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _nameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入应用名称") attributes:attributes];
    }
    return _nameTF;
}

- (UITextField *)urlTF {
    if (!_urlTF) {
        _urlTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _urlTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置左边文字距离左边框间隔
        _urlTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        _urlTF.leftViewMode = UITextFieldViewModeAlways;
        _urlTF.font = FONTR(14);
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _urlTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入链接") attributes:attributes];
    }
    return _urlTF;
}

- (UIButton *)changePasswordStateBtn {
    if (!_changePasswordStateBtn) {
        _changePasswordStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changePasswordStateBtn setImage:ImgNamed(@"mini_app_switch_off") forState:UIControlStateNormal];
        [_changePasswordStateBtn setImage:ImgNamed(@"mini_app_switch_on") forState:UIControlStateSelected];
        [_changePasswordStateBtn addTarget:self action:@selector(btnPasswordClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changePasswordStateBtn;
}

- (UIView *)passwordContainer {
    if (!_passwordContainer) {
        _passwordContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _passwordContainer.tkThemebackgroundColors = @[HEXCOLOR(@"F5F6F8"), HEXCOLOR(@"373737")];
        _passwordContainer.layer.cornerRadius = DWScale(8);
        _passwordContainer.layer.masksToBounds = YES;
        _passwordContainer.hidden = YES;
    }
    return _passwordContainer;
}

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _passwordTF.font = FONTR(14);
        _passwordTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置左边文字距离左边框间隔
        _passwordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _passwordTF.leftViewMode = UITextFieldViewModeAlways;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _passwordTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入访问密码") attributes:attributes];
    }
    return _passwordTF;
}

- (UIButton *)btnCancel {
    if (!_btnCancel) {
        _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
        [_btnCancel setTkThemeTitleColor:@[COLOR_66, COLORWHITE] forState:UIControlStateNormal];
        [_btnCancel setTkThemebackgroundColors:@[HEXCOLOR(@"F5F6F8"), HEXCOLOR(@"373737")]];
        _btnCancel.titleLabel.font = FONTM(14);
        [_btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCancel;
}

- (UIButton *)btnSave {
    if (!_btnSave) {
        _btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSave setTitle:LanguageToolMatch(@"保存") forState:UIControlStateNormal];
        [_btnSave setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        [_btnSave setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
        _btnSave.titleLabel.font = FONTM(14);
        _btnSave.layer.cornerRadius = 12;
        _btnSave.layer.masksToBounds = YES;
        [_btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSave;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (instancetype)initMiniAppWith:(ZConfigMiniAppType)configType {
    self = [super init];
    if (self) {
        _configType = configType;
        
        self.tkThemebackgroundColors = @[HEXACOLOR(@"000000", 0.3), HEXACOLOR(@"000000", 0.3)];
        self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
        [CurrentWindow addSubview:self];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(configMiniAppDismiss)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        [self setupUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configMiniAppViewShow:) name:@"MiniAppSelectImage" object:nil];
    
    }
    return self;
}

#pragma mark - 通知监听
- (void)configMiniAppViewShow:(NSNotification *)notification {
    NSDictionary *userInfoDict = notification.userInfo;
    BOOL showMiniView = [[userInfoDict objectForKeySafe:@"OpenImagePicker"] boolValue];
    
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        self.hidden = showMiniView;
    });
}

#pragma mark - 界面布局
- (void)setupUI {
    @weakify(self)
    self.contentContainer.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        @strongify(self)
        if (themeIndex == 1) {
            [self.contentContainer rounded:24 width:0.5 color:[COLORWHITE colorWithAlphaComponent:0.4]];
        }else {
            [self.contentContainer rounded:24 width:0.5 color:COLORWHITE];
        }
    };
    
    [self addSubview:self.contentContainer];
    [self.contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@70);
        make.centerX.equalTo(self);
        make.width.equalTo(@300);
        make.height.equalTo(@382);
    }];
    
    self.imageChangeBtn.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        @strongify(self)
        if (themeIndex == 1) {
            [self.imageChangeBtn rounded:26 width:1 color:COLORWHITE];
        }else {
            [self.imageChangeBtn rounded:26 width:1 color:COLORWHITE];
        }
    };
    
    [self.contentContainer addSubview:self.imageChangeBtn];
    [self.imageChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@16);
        make.leading.equalTo(@16);
        make.width.height.equalTo(@52);
    }];
    
    [self.contentContainer addSubview:self.editImgView];
    [self.editImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.imageChangeBtn).offset(3);
        make.centerX.equalTo(self.imageChangeBtn);
        make.width.height.equalTo(@11);
    }];
    
    [self.contentContainer addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@21);
        make.leading.equalTo(self.imageChangeBtn.mas_trailing).offset(8);
        make.trailing.equalTo(self.contentContainer).offset(-16);
        make.height.equalTo(@19);
    }];
    
    [self.contentContainer addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.leading.equalTo(self.titleLabel);
        make.trailing.equalTo(self.titleLabel);
        make.height.equalTo(@14);
    }];
    
    [self.contentContainer addSubview:self.nameAndLinkContainer];
    [self.nameAndLinkContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.editImgView.mas_bottom).offset(20);
        make.leading.equalTo(@16);
        make.trailing.equalTo(self.contentContainer).offset(-16);
        make.height.equalTo(@88);
    }];
    
    [self.nameAndLinkContainer addSubview:self.nameTF];

    UIView *divideLineView = [[UIView alloc] initWithFrame:CGRectZero];
    divideLineView.tkThemebackgroundColors = @[HEXCOLOR(@"E8E9EB"), [HEXCOLOR(@"E8E9EB") colorWithAlphaComponent:0.4]];
    [self.nameAndLinkContainer addSubview:divideLineView];
    
    [self.nameAndLinkContainer addSubview:self.urlTF];
    
    [self.nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@0);
        make.trailing.equalTo(self.nameAndLinkContainer).offset(-10);
        make.height.equalTo(@43.5);
    }];
    
    [divideLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameTF.mas_bottom);
        make.leading.equalTo(@10);
        make.trailing.equalTo(self.nameAndLinkContainer).offset(-10);
        make.height.equalTo(@1);
    }];
    
    [self.urlTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(divideLineView.mas_bottom);
        make.leading.equalTo(@0);
        make.trailing.equalTo(self.nameAndLinkContainer).offset(-10);
        make.height.equalTo(@43.5);
    }];
    
    UILabel *openPasswordLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    openPasswordLabel.text = LanguageToolMatch(@"开启密码");
    openPasswordLabel.tkThemetextColors = @[COLOR_00, COLOR_00_DARK];
    openPasswordLabel.font = FONTSB(16);
    [self.contentContainer addSubview:openPasswordLabel];
    [openPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameAndLinkContainer.mas_bottom).offset(20);
        make.leading.equalTo(@16);
        make.height.equalTo(@19);
    }];
    
    [self.contentContainer addSubview:self.changePasswordStateBtn];
    [self.changePasswordStateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(openPasswordLabel);
        make.leading.equalTo(openPasswordLabel.mas_trailing).offset(8);
        make.width.equalTo(@36);
        make.height.equalTo(@18);
    }];
    
    [self.contentContainer addSubview:self.passwordContainer];
    [self.passwordContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.changePasswordStateBtn.mas_bottom).offset(20);
        make.leading.equalTo(@16);
        make.trailing.equalTo(self.contentContainer).offset(-16);
        make.height.equalTo(@56);
    }];
    
    self.passwordContainer.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        @strongify(self)
        if (themeIndex == 1) {
            [self.passwordContainer rounded:16 width:1 color:[COLORWHITE colorWithAlphaComponent:0.4]];
        }else {
            [self.passwordContainer rounded:16 width:1 color:COLORWHITE];
        }
    };
    [self.passwordContainer addSubview:self.passwordTF];
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.passwordContainer);
    }];
    
    self.btnCancel.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        @strongify(self)
        if (themeIndex == 1) {
            [self.btnCancel rounded:12 width:0.5 color:[COLORWHITE colorWithAlphaComponent:0.4]];
        }else {
            [self.btnCancel rounded:12 width:0.5 color:COLORWHITE];
        }
    };
    [self.contentContainer addSubview:self.btnCancel];
    [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordContainer.mas_bottom).offset(20);
        make.leading.equalTo(@12);
        make.height.equalTo(@36);
    }];
    
    [self.contentContainer addSubview:self.btnSave];
    [self.btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.btnCancel);
        make.leading.equalTo(self.btnCancel.mas_trailing).offset(15);
        make.trailing.equalTo(self.contentContainer).offset(-12);
        make.width.equalTo(self.btnCancel.mas_width);
        make.height.equalTo(@36);
    }];
    
}

- (void)configMiniAppShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.contentContainer.transform = CGAffineTransformIdentity;
    }];
}

- (void)configMiniAppDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.contentContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    } completion:^(BOOL finished) {
        [weakSelf.contentContainer removeFromSuperview];
        weakSelf.contentContainer = nil;
        
        [weakSelf removeFromSuperview];
    }];
}
#pragma mark - 界面赋值
- (void)setMiniAppModel:(LingIMMiniAppModel *)miniAppModel {
    if (miniAppModel) {
        _miniAppModel = miniAppModel;
        
        if (![NSString isNil:miniAppModel.qaAppPic]) {
            [_imageChangeBtn sd_setImageWithURL:[miniAppModel.qaAppPic getImageFullUrl] forState:UIControlStateNormal placeholderImage:ImgNamed(@"mini_app_icon") options:SDWebImageAllowInvalidSSLCertificates];
        }else {
            [_imageChangeBtn setImage:ImgNamed(@"mini_app_add_gray") forState:UIControlStateNormal];
        }
        
        _nameTF.text = miniAppModel.qaName;
        
        _urlTF.text = miniAppModel.qaAppUrl;
        
        if (miniAppModel.qaPwdOpen == 1) {
            //开启密码
            _passwordContainer.hidden = NO;
            _passwordTF.text = miniAppModel.qaPwd;
            _changePasswordStateBtn.selected = YES;
        }else {
            //关闭密码
            _passwordContainer.hidden = YES;
            _passwordTF.text = @"";
            _changePasswordStateBtn.selected = NO;
        }
        
    }
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:_contentContainer]) {
        return NO;
    }
    return YES;
}

#pragma mark - ZImagePickerVCDelegate

/// 退出相册回调
- (void)imagePickerVCCancel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:@(NO) forKey:@"OpenImagePicker"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MiniAppSelectImage" object:nil userInfo:dict];
}

/// 选择图片并保存回调
/// - Parameters:
///   - resultImg: 选中的图片
///   - localIdenti: ？？？
- (void)imagePickerClipImage:(UIImage *)resultImg localIdenti:(NSString *)localIdenti {
    [_imageChangeBtn setImage:resultImg forState:UIControlStateNormal];
    _localImage = YES;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:@(NO) forKey:@"OpenImagePicker"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MiniAppSelectImage" object:nil userInfo:dict];
}

#pragma mark - 交互事件
- (void)btnHeaderClick {
    //先检测权限，再进入相册，解决某些系统第一次不能获取照片，杀死进程后可以获取照片的问题
    [ZTOOL getPhotoLibraryAuth:^(BOOL granted) {
        if (granted) {
            [ZTOOL doInMain:^{
                NoaImagePickerVC *vc = [NoaImagePickerVC new];
                vc.isSignlePhoto = YES;
                vc.isNeedEdit = YES;
                vc.hasCamera = YES;
                vc.delegate = self;
                [vc setPickerType:ZImagePickerTypeImage];
                [CurrentVC.navigationController pushViewController:vc animated:YES];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObjectSafe:@(YES) forKey:@"OpenImagePicker"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MiniAppSelectImage" object:nil userInfo:dict];
            }];
        }else {
            [HUD showWarningMessage:LanguageToolMatch(@"相册权限未开启，请在设置中选择当前应用，开启相册权限")];
        }
    }];
}

- (void)btnPasswordClick {
    _changePasswordStateBtn.selected = !_changePasswordStateBtn.selected;
    _passwordContainer.hidden = !_changePasswordStateBtn.selected;
    _passwordTF.text = @"";
    [_passwordTF resignFirstResponder];
}

- (void)btnCancelClick {
    [self configMiniAppDismiss];
}

- (void)btnSaveClick {
    
    __block NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *miniAppName = [_nameTF.text trimString];
    NSString *miniAppUrl = [_urlTF.text trimString];
    NSString *passwordStr = [_passwordTF.text trimString];
    
    if ([NSString isNil:miniAppName]) {
        [HUD showMessage:LanguageToolMatch(@"应用名称不能为空")];
        return;
    }
    
    if ([NSString isNil:miniAppUrl]) {
        [HUD showMessage:LanguageToolMatch(@"链接不能为空")];
        return;
    }
    if (![miniAppUrl checkStringIsUrl]) {
        [HUD showMessage:LanguageToolMatch(@"链接地址无效")];
        return;
    }
    
    if (_changePasswordStateBtn.selected) {
        if ([NSString isNil:passwordStr]) {
            [HUD showMessage:LanguageToolMatch(@"访问密码不能为空")];
            return;
        }
    }
    
    if (_configType == ZConfigMiniAppTypeAdd) {
        //创建小程序
        [dict setObjectSafe:miniAppName forKey:@"qaName"];
        [dict setObjectSafe:miniAppUrl forKey:@"qaAppUrl"];
        if (_changePasswordStateBtn.selected) {
            [dict setObjectSafe:passwordStr forKey:@"qaPwd"];
            [dict setObjectSafe:@(1) forKey:@"qaPwdOpen"];
        }else {
            [dict setObjectSafe:@(0) forKey:@"qaPwdOpen"];
        }
        
        if (_localImage) {
            //先上传图片
            [HUD showActivityMessage:@""];
            WeakSelf
            NSData *imageData = UIImageJPEGRepresentation(_imageChangeBtn.imageView.image, 1.0);//转成jpeg
            NSData *comMassImageData = [UIImage compressImageSize:[UIImage imageWithData:imageData] toByte:50*1024];//压缩到50KB
            NSString *fileName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:comMassImageData]];
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, @"mini_app"];
                        
            __block NSString *imagePath = @"";
            [ZTOOL doAsync:^{
                [NSString saveImageToSaxboxWithData:comMassImageData CustomPath:customPath ImgName:fileName];
                imagePath = [NSString getPathWithImageName:fileName CustomPath:customPath];
            } completion:^{
                NoaFileUploadTask *task = [[NoaFileUploadTask alloc] initWithTaskId:fileName filePath:imagePath originFilePath:@"" fileName:fileName fileType:@"" isEncrypt:YES dataLength:comMassImageData.length uploadType:ZHttpUploadTypeMiniApp beSendMessage:nil delegate:nil];
               NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                   if (task.status == FileUploadTaskStatus_Completed) {
                       [dict setObjectSafe:task.originUrl forKey:@"qaAppPic"];
                       [weakSelf createMiniAppWith:dict];
                   } else {
                       [ZTOOL doInMain:^{
                           [HUD showMessage:LanguageToolMatch(@"上传头像失败")];
                       }];
                   }
                }];
               
                NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
                [task addDependency:getSTSTask];
                [blockOperation addDependency:task];
                
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:task];
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
            }];
            
           
        }else {
            [self createMiniAppWith:dict];
        }
        
    }else {
        //编辑小程序
        if (!_miniAppModel) return;;
        
        [dict setObjectSafe:miniAppName forKey:@"qaName"];
        [dict setObjectSafe:miniAppUrl forKey:@"qaAppUrl"];
        //图片地址
        if (![NSString isNil:_miniAppModel.qaAppPic]) {
            [dict setObjectSafe:_miniAppModel.qaAppPic forKey:@"qaAppPic"];
        }
        //密码开启
        if (_changePasswordStateBtn.selected) {
            [dict setObjectSafe:passwordStr forKey:@"qaPwd"];
            [dict setObjectSafe:@(1) forKey:@"qaPwdOpen"];
        }else {
            [dict setObjectSafe:@(0) forKey:@"qaPwdOpen"];
        }
        
        if (_localImage) {
            //先上传图片
            WeakSelf
            [HUD showActivityMessage:@""];
            NSData *imageData = UIImageJPEGRepresentation(_imageChangeBtn.imageView.image, 1.0);//转成jpeg
            NSData *comMassImageData = [UIImage compressImageSize:[UIImage imageWithData:imageData] toByte:50*1024];//压缩到50KB
            NSString *fileName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:comMassImageData]];
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, @"mini_app"];
            
            __block NSString *imagePath = @"";
            [ZTOOL doAsync:^{
                [NSString saveImageToSaxboxWithData:comMassImageData CustomPath:customPath ImgName:fileName];
                imagePath = [NSString getPathWithImageName:fileName CustomPath:customPath];
            } completion:^{
                NoaFileUploadTask *task = [[NoaFileUploadTask alloc] initWithTaskId:fileName filePath:imagePath originFilePath:@"" fileName:fileName fileType:@"" isEncrypt:YES dataLength:comMassImageData.length uploadType:ZHttpUploadTypeMiniApp beSendMessage:nil delegate:nil];
               NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                   if (task.status == FileUploadTaskStatus_Completed) {
                       [dict setObjectSafe:task.originUrl forKey:@"qaAppPic"];
                       [weakSelf editMiniAppWith:dict];
                   } else {
                       [ZTOOL doInMain:^{
                           [HUD showMessage:LanguageToolMatch(@"上传头像失败")];
                       }];
                   }
               }];
                
                NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
                [task addDependency:getSTSTask];
                [blockOperation addDependency:task];
                
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:task];
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
            }];
        } else {
            [self editMiniAppWith:dict];
        }
    }
}

- (void)createMiniAppWith:(NSMutableDictionary *)dict {
    WeakSelf
    [IMSDKManager imMiniAppCreateWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            LingIMMiniAppModel *miniAppNew = [LingIMMiniAppModel mj_objectWithKeyValues:dataDict];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(configMiniAppCreateWith:)]) {
                [weakSelf.delegate configMiniAppCreateWith:miniAppNew];
            }
        }
        
        [HUD showMessage:LanguageToolMatch(@"操作成功")];
        [weakSelf configMiniAppDismiss];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

- (void)editMiniAppWith:(NSMutableDictionary *)dict {
    if (_miniAppModel) {
        WeakSelf
        [dict setObjectSafe:_miniAppModel.qaUuid forKey:@"qaUuid"];
        
        [IMSDKManager imMiniAppEditWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDict = (NSDictionary *)data;
                LingIMMiniAppModel *tempMiniApp = [LingIMMiniAppModel mj_objectWithKeyValues:dataDict];
                //更新数据
                weakSelf.miniAppModel.qaName = tempMiniApp.qaName;
                weakSelf.miniAppModel.qaAppPic = tempMiniApp.qaAppPic;
                weakSelf.miniAppModel.qaAppUrl = tempMiniApp.qaAppUrl;
                weakSelf.miniAppModel.qaPwd = tempMiniApp.qaPwd;
                weakSelf.miniAppModel.qaPwdOpen = tempMiniApp.qaPwdOpen;
                weakSelf.miniAppModel.qaUuid = tempMiniApp.qaUuid;
                
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(configMiniAppEditWith:)]) {
                    [weakSelf.delegate configMiniAppEditWith:weakSelf.miniAppModel];
                }
            }
            
            [HUD showMessage:LanguageToolMatch(@"操作成功")];
            [weakSelf configMiniAppDismiss];
            
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
    }
}

#pragma mark - 懒加载
//- (ZFileNetProgressManager *)fileUploader {
//    if (!_fileUploader) {
//        _fileUploader = [[ZFileNetProgressManager alloc] init];
//    }
//    return _fileUploader;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
