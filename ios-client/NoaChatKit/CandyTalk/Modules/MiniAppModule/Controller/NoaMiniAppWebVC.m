//
//  NoaMiniAppWebVC.m
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaMiniAppWebVC.h"
#import "AppDelegate.h"
#import "NoaMiniAppFloatView.h"
#import "NoaToolManager.h"

@interface NoaMiniAppWebVC ()
@property (nonatomic, strong) UIButton *btnClose;
@property (nonatomic, strong) UIButton *btnMore;
@end

@implementation NoaMiniAppWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavRightUI];
    //小程序加载，只有一个VC的处理
    [self checkNavControllers];
}

#pragma mark - 右侧导航栏布局
- (void)setupNavRightUI {
    
    UIView *viewRight = [UIView new];
    viewRight.layer.cornerRadius = DWScale(15);
    viewRight.layer.masksToBounds = YES;
    viewRight.layer.borderWidth = 1;
    viewRight.layer.tkThemeborderColors = @[HEXCOLOR(@"F0F0F0"), HEXCOLOR(@"F0F0F0")];
    [self.navView addSubview:viewRight];
    [viewRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(80), DWScale(30)));
    }];
    
    _btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMore.frame = CGRectMake(0, 0, DWScale(40), DWScale(30));
    [_btnMore setImage:ImgNamed(@"mini_app_more") forState:UIControlStateNormal];
    [_btnMore addTarget:self action:@selector(btnMoreClick) forControlEvents:UIControlEventTouchUpInside];
    [_btnMore round:DWScale(15) RectCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft];
    [viewRight addSubview:_btnMore];
    
    _btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnClose.frame = CGRectMake(DWScale(40), 0, DWScale(40), DWScale(30));
    [_btnClose setImage:ImgNamed(@"mini_app_close") forState:UIControlStateNormal];
    [_btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [_btnClose round:DWScale(15) RectCorners:UIRectCornerTopRight | UIRectCornerBottomRight];
    [viewRight addSubview:_btnClose];
    
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(DWScale(39.5), DWScale(8), DWScale(1), DWScale(14))];
    viewLine.tkThemebackgroundColors = @[HEXCOLOR(@"F0F0F0"), HEXCOLOR(@"F0F0F0")];
    [viewRight addSubview:viewLine];
    
    self.navTitleLabel.x = DWScale(96);
    self.navTitleLabel.width = DScreenWidth - DWScale(192);
}

#pragma mark - 交互事件
- (void)btnMoreClick {
    [self showMoreView];
}

- (void)btnCloseClick {
    if(self.floatMiniAppModel){
        self.floatMiniAppModel.title = self.navTitleStr;
        self.floatMiniAppModel.url = self.currentUrlStr;
    }
    //更新浮窗的url和标题
    [IMSDKManager imSdkInsertFloatMiniAppWith:self.floatMiniAppModel];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navBtnBackClicked {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        if(self.floatMiniAppModel){
            self.floatMiniAppModel.title = self.navTitleStr;
            self.floatMiniAppModel.url = self.currentUrlStr;
        }
        //更新浮窗的url和标题
        [IMSDKManager imSdkInsertFloatMiniAppWith:self.floatMiniAppModel];
        
        [super navBtnBackClicked];
    }
}

//展示更多弹窗
- (void)showMoreView {
    WeakSelf
    NoaPresentItem *browserItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"在浏览器打开") textColor:COLOR_11 font:FONTR(16) itemHeight:DWScale(56) backgroundColor:COLORWHITE];
    NoaPresentItem *floatItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"浮窗") textColor:COLOR_11 font:FONTR(16) itemHeight:DWScale(56) backgroundColor:COLORWHITE];
    NoaPresentItem *copyItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"复制链接") textColor:COLOR_11 font:FONTR(16) itemHeight:DWScale(56) backgroundColor:COLORWHITE];
    NoaPresentItem *cancelItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"取消") textColor:COLOR_99 font:FONTR(16) itemHeight:DWScale(56) backgroundColor:COLORWHITE];
    
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            browserItem.textColor = COLOR_11;
            browserItem.backgroundColor = COLORWHITE;
            floatItem.textColor = COLOR_11;
            floatItem.backgroundColor = COLORWHITE;
            copyItem.textColor = COLOR_11;
            copyItem.backgroundColor = COLORWHITE;
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLORWHITE;
            
        }else {
            
            browserItem.textColor = COLORWHITE;
            browserItem.backgroundColor = COLOR_11;
            floatItem.textColor = COLORWHITE;
            floatItem.backgroundColor = COLOR_11;
            copyItem.textColor = COLORWHITE;
            copyItem.backgroundColor = COLOR_11;
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLOR_11;
        }
    };
    NSArray *moreItemArray;
    if (self.webType == ZMiniAppWebVCTypeMiniApp) {
        //小程序
        moreItemArray = @[browserItem, floatItem, copyItem];
    }else {
        //通用占位
        moreItemArray = @[browserItem, copyItem];
    }
    NoaPresentView *viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:moreItemArray cancleItem:cancelItem doneClick:^(NSInteger index) {
        //具体的功能实现
        [weakSelf webMoreItemWith:index];
    } cancleClick:^{
        //点击了取消
    }];
    [self.view addSubview:viewAlert];
    [viewAlert showPresentView];
}
- (void)webMoreItemWith:(NSInteger)index {
    switch (self.webType) {
        case ZMiniAppWebVCTypeMiniApp:
        {
            if (index == 0) {
                //在浏览器打开
                [self goWebBrowser];
            }else if (index == 1) {
                //浮窗
                [self goFloatView];
            }else {
                //复制链接
                [self goCopyWebUrl];
            }
        }
            break;
            
        default:
        {
            if (index == 0) {
                //在浏览器打开
                [self goWebBrowser];
            }else {
                //复制链接
                [self goCopyWebUrl];
            }
        }
            break;
    }
}
- (void)goWebBrowser {
    if (![NSString isNil:self.webViewUrl]) {
        BOOL isExsit = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.webViewUrl]];
        if(isExsit) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webViewUrl] options:@{} completionHandler:nil];
        }
    }
}
- (void)goFloatView {
    if (![NSString isNil:self.webViewUrl]) {
        
        if(self.floatMiniAppModel){
            self.floatMiniAppModel.title = self.navTitleStr;
            self.floatMiniAppModel.url = self.currentUrlStr;
        }
        //将小程序加入浮窗
        [IMSDKManager imSdkInsertFloatMiniAppWith:self.floatMiniAppModel];
        [ZWebCachesTOOL.caches setObject:self forKey:self.floatMiniAppModel.floladId];
        
        //判断当前是否已有小程序浮窗
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (!appDelegate.viewFloatMiniApp) {
            //当前没有小程序浮窗，创建
            NoaMiniAppFloatView *viewFloat = [[NoaMiniAppFloatView alloc] initWithFrame:CGRectMake(0, DWScale(100), DWScale(50), DWScale(50))];
            viewFloat.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];;
            viewFloat.freeRect = CGRectMake(0, DNavStatusBarH, DScreenWidth, DScreenHeight - DNavStatusBarH - DHomeBarH);
            viewFloat.delegate = appDelegate;
            viewFloat.imageView.image = ImgNamed(@"mini_app_float");
            viewFloat.isKeepBounds = YES;
            [viewFloat round:DWScale(10) RectCorners:UIRectCornerTopRight | UIRectCornerBottomRight];
            appDelegate.viewFloatMiniApp = viewFloat;
            [CurrentWindow addSubview:viewFloat];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)goCopyWebUrl {
    if (![NSString isNil:self.webViewUrl]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.webViewUrl;
        [HUD showMessage:LanguageToolMatch(@"复制成功")];
    }
}

#pragma mark - 多个小程序跳转的处理
- (void)checkNavControllers {
    __block NSMutableArray *newList = [NSMutableArray array];
    
    NSArray *vcList = self.navigationController.viewControllers;
    [vcList enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == vcList.count - 1) {
            [newList addObjectIfNotNil:obj];
        }else{
            if (![obj isKindOfClass:[NoaMiniAppWebVC class]]) {
                [newList addObjectIfNotNil:obj];
            }
        }
    }];
    
    self.navigationController.viewControllers = newList;

}

- (void)dealloc {
    NSLog(@" ======= NoaMiniAppWebVC dealloc =========");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
