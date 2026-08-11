//
//  NoaAppStartErrorDefaultViewController.m
//  NoaKit
//
//  Created by Candy on 2023/5/18.
//

#import "NoaAppStartErrorDefaultViewController.h"
#import "NoaChatKit-Swift.h"

@interface NoaAppStartErrorDefaultViewController ()

@property (nonatomic, strong)UILabel *errorMsgLbl;

@end

@implementation NoaAppStartErrorDefaultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [self setupNavUI];
    [self setupUI];
}

- (void)setupNavUI {
    self.navBtnBack.hidden = YES;
    self.navBtnRight.hidden = NO;
    self.navTitleLabel.hidden = YES;
    self.navLineView.hidden = YES;
    
    self.navView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    
    [self.navBtnRight setTitle:LanguageToolMatch(@"更换") forState:UIControlStateNormal];
    [self.navBtnRight setTkThemeTitleColor:@[COLOR_99, COLOR_99_DARK] forState:UIControlStateNormal];
    [self.navBtnRight setImage:ImgNamed(@"c_arrow_right_gray") forState:UIControlStateNormal];
    [self.navBtnRight setBtnImageAlignmentType:ButtonImageAlignmentTypeRight imageSpace:5];
}

- (void)setupUI {
    UIImageView *defaultErrorImgView = [[UIImageView alloc] init];
    defaultErrorImgView.image = ImgNamed(@"img_start_error_default");
    [self.view addSubview:defaultErrorImgView];
    [defaultErrorImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-(DWScale(30)+DNavStatusBarH));
        make.width.mas_equalTo(DWScale(251));
        make.height.mas_equalTo(DWScale(251));
    }];
    
    [self.view addSubview:self.errorMsgLbl];
    [self.errorMsgLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(defaultErrorImgView.mas_bottom).offset(DWScale(5));
        make.leading.trailing.equalTo(defaultErrorImgView);
        make.height.mas_equalTo(DWScale(25));
    }];
    
   UIButton *relaodButton = [[UIButton alloc] init];
    [relaodButton setTitle:LanguageToolMatch(@"重新加载") forState:UIControlStateNormal];
    [relaodButton setTitleColor:COLORWHITE forState:UIControlStateNormal];
    [relaodButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [relaodButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    relaodButton.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2];
    relaodButton.titleLabel.font = FONTN(16);
    [relaodButton rounded:DWScale(14)];
    [relaodButton addTarget:self action:@selector(reloadInstallNodeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:relaodButton];
    [relaodButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-DWScale(120));
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(DWScale(343));
        make.height.mas_equalTo(DWScale(48));
    }];
    
    [self setupData];
}

- (void)setupData {
    //竞速失败
    switch (self.step) {
        case ZNetRacingStepOss:
        {
            //OSS
            if (self.code == 100000) {
                self.errorMsgLbl.text = LanguageToolMatch(@"服务器连接失败 ，请联系管理员");
            } else {
                if (self.code == 404 || self.code == 403) {
                    self.errorMsgLbl.text = LanguageToolMatch(@"邀请码不存在");
                } else {
                    self.errorMsgLbl.text = LanguageToolMatch(@"服务器连接失败");
                }
            }
        }
            break;
        case ZNetRacingStepHttp:
        {
            //Http
            self.errorMsgLbl.text = LanguageToolMatch(@"获取配置失败");
        }
            break;
        case ZNetRacingStepTcp:
        {
            //Tcp
            self.errorMsgLbl.text = LanguageToolMatch(@"IM连接失败");
        }
            break;
        case ZNetIpDomainStepHttp:
        {
            //IP/Domain Http
            self.errorMsgLbl.text = LanguageToolMatch(@"获取配置失败");
        }
            break;
        case ZNetIpDomainStepTcp:
        {
            //IP/Domain Tcp
            self.errorMsgLbl.text = LanguageToolMatch(@"IM连接失败");
        }
            break;
        default:
            break;
    }
}

#pragma mark - Action
//更换
- (void)navBtnRightClicked {
    NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
    [[MMKV defaultMMKV] removeValueForKey:[NSString stringWithFormat:@"%@%@",CONNECT_LOCAL_CACHE,ssoModel.liceseId]];
    [NoaSsoInfoModel clearSSOInfoWithLiceseId:ssoModel.liceseId];
    CoHereSsoSetViewController *ssoSetVC = [[CoHereSsoSetViewController alloc] init];
    ssoSetVC.isRoot = NO;
    ssoSetVC.isReset = YES;
    [self.navigationController pushViewController:ssoSetVC animated:YES];
}

//重新加载(重新进行竞速)
- (void)reloadInstallNodeAction {
    [HUD showActivityMessage:@""];
    dispatch_async(dispatch_queue_create("com.nodeRacing", DISPATCH_QUEUE_CONCURRENT), ^{
        ZHostTool.isReloadRacing = YES;
        [ZHostTool startHostNodeRace];
    });


}

#pragma mark -  Lazy
- (UILabel *)errorMsgLbl {
    if (!_errorMsgLbl) {
        _errorMsgLbl = [[UILabel alloc] init];
        _errorMsgLbl.text = @"";
        _errorMsgLbl.font = FONTN(16);
        _errorMsgLbl.tkThemetextColors = @[COLOR_00, COLOR_00_DARK];
        _errorMsgLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _errorMsgLbl;
}

@end
