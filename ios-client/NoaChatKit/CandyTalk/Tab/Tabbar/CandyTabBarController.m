//
//  NoaTabBarController.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import "CandyTabBarController.h"


#import "UITabBar+Badge.h"
#import "NoaNavigationController.h"
#import "NoaChatKit-Swift.h"

#import "CandyTalkHomeViewController.h"
// 移除“我的”Tab及相关自定义转场依赖
#import "CandyTalkTeamViewController.h"//团队

@interface CandyTabBarController () <UITabBarControllerDelegate,UITabBarDelegate>
{
    NSInteger _currentSelectedIndex;//当前选中下标
}

@property (nonatomic, strong) CandyTalkHomeViewController  *vcSession;
@property (nonatomic, strong) CoHereContactViewController  *vcContact;
@property (nonatomic, strong) CoHereDailySignInViewController  *signvc;
@property (nonatomic, strong) CandyTalkTeamViewController  *teamvc;
@property (nonatomic, strong) CoHereMineViewController *mineVc;



@end

@implementation CandyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    self.tabBarController.tabBar.delegate = self;
    
    [self showInfo];
    [self setupTabbar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionListAllRead:) name:@"sessionListAllRead" object:nil];
}
-(void)showInfo{
//    [HUD showSuccessMessage:@"加载首页"];
}
- (void)viewWillLayoutSubviews{
    CGRect tabbarFrame = self.tabBar.frame;
    tabbarFrame.size.height = DTabBarH;
    tabbarFrame.size.width = DScreenWidth;
    tabbarFrame.origin.y = self.view.height - DTabBarH;
    self.tabBar.frame = tabbarFrame;
}

- (void)sessionListAllRead:(NSNotification *)notification {
    NSString *lastServerMsgId = (NSString *)[notification object];
    [self.vcSession sessionListAllRead:lastServerMsgId];
}

#pragma mark - 配置Tabbar
- (void)setupTabbar{
    

    if (@available(iOS 13.0, *)) {
        WeakSelf
        [self setTkThemeChangeBlock:^(id  _Nullable itself, NSUInteger themeIndex) {
            //0浅色 ， 暗黑
            [weakSelf tabbarConfigWithMode:themeIndex];
        }];
    }else {
        //tabbar背景颜色
        [[UITabBar appearance] setTkThemebackgroundColors:@[COLORWHITE, COLOR_11]];
        [[UITabBar appearance] setTkThemebarTintColors:@[COLORWHITE, COLOR_11]];
        //去掉tabbar上的横线
        [[UITabBar appearance] setShadowImage:[UIImage new]];
        [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
    }

    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -2)];

    _vcSession = [CandyTalkHomeViewController new];
    [self addChildViewController:_vcSession imageNormal:@"atab_l_d" imageSelected:@"atab_l_a" title:LanguageToolMatch(@"消息") tag:1000];

//    _signvc = [CoHereDailySignInViewController new];
//    [self addChildViewController:_signvc imageNormal:@"qiandaodef" imageSelected:@"qiandao" title:LanguageToolMatch(@"签到") tag:1001];

    _vcContact = [CoHereContactViewController new];
    [self addChildViewController:_vcContact imageNormal:@"atab_c_d" imageSelected:@"atab_c_a" title:LanguageToolMatch(@"通讯录") tag:1001];


//    _teamvc  = [CandyTalkTeamViewController new];
//    [self addChildViewController:_teamvc imageNormal:@"tuanduidef" imageSelected:@"tuandui" title:LanguageToolMatch(@"团队") tag:1001];

    _mineVc = [CoHereMineViewController new];
    [self addChildViewController:_mineVc imageNormal:@"atab_r_d" imageSelected:@"atab_r_a" title:LanguageToolMatch(@"我的") tag:1001];
    
    
    self.selectedIndex = 0;
    _currentSelectedIndex = 0;
    
}
//iOS13tabbar
- (void)tabbarConfigWithMode:(NSInteger)modeType {
    UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
    tabBarAppearance.backgroundColor = modeType == 0 ? COLORWHITE : COLOR_11;
    tabBarAppearance.backgroundImage = [UIImage new];
    tabBarAppearance.shadowColor = modeType == 0 ? COLOR_5966F2 : COLOR_11;
    tabBarAppearance.shadowImage = [UIImage new];
    self.tabBar.standardAppearance = tabBarAppearance;
}

#pragma mark - 添加自控制器方法
- (void)addChildViewController:(UIViewController *)childController imageNormal:(NSString *)imageNameNor imageSelected:(NSString *)imageNameSel title:(NSString *)title tag:(NSInteger)tag{
    
    NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:childController];
    
    nav.tabBarItem.image = [[UIImage imageNamed:imageNameNor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:imageNameSel] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    nav.tabBarItem.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        UIColor *color = nil;
        if (themeIndex == 0) {
            color = COLOR_99;
        } else {
            color = COLOR_99;
        }
        [(UITabBarItem *)itself setTitleTextAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName : FONTR(11)} forState:UIControlStateNormal];
    };
    
    nav.tabBarItem.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        UIColor *color = nil;
        if (themeIndex == 0) {
            color = COLOR_5966F2;
        } else {
            color = COLOR_5966F2_DARK;
        }
        [(UITabBarItem *)itself setTitleTextAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName : FONTR(11)} forState:UIControlStateSelected];
    };

    nav.tabBarItem.title = title;
    
    nav.tabBarItem.tag = tag;
    
    [self addChildViewController:nav];
}

//检查是单击还是双击
- (BOOL)checkIsDoubleClick:(UIViewController *)viewController
{
    static UIViewController *lastViewController = nil;
    static NSTimeInterval lastClickTime = 0;
    
    if (lastViewController != viewController) {
        lastViewController = viewController;
        lastClickTime = [NSDate timeIntervalSinceReferenceDate];
        
        return NO;
    }
    
    NSTimeInterval clickTime = [NSDate timeIntervalSinceReferenceDate];
    if (clickTime - lastClickTime > 0.6 ) {
        lastClickTime = clickTime;
        return NO;
    }
    
    lastClickTime = clickTime;
    return YES;
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (_currentSelectedIndex == item.tag - 1000) {
        //点击当前选中下标
    }else{
        //切换界面
    }
    _currentSelectedIndex = item.tag - 1000;
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([self checkIsDoubleClick:viewController]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Z_DoubleClickTabItemNotification object:nil];
    }
    return YES;
}

#pragma mark - UITabBarControllerDelegate

#pragma mark - 红点设置
- (void)setBadgeValue:(NSInteger)index number:(NSInteger)number {
    if (!self) return;
    __weak typeof(self) weakSelf = self;
    if (number > 0) {
        if (number > 99) {
            [self.tabBar showBadgeAtItemIndex:index textStr:@"99+" size:CGSizeMake(20, 20) tapBlock:^{
                weakSelf.selectedIndex = index;
            }];
        }else {
            [self.tabBar showBadgeAtItemIndex:index textStr:[NSString stringWithFormat:@"%ld",number] size:CGSizeMake(18, 18) tapBlock:^{
                weakSelf.selectedIndex = index;
            }];
        }
    }else {
        [self.tabBar hideBadgeAtItemIndex:index];
    }
    
}

//红点的显示与隐藏 参考
- (void)setTheBadge{
    [self.tabBar showBadgeAtItemIndex:0 textStr:@"" size:CGSizeMake(10, 10) tapBlock:^{
        
    }];
    [self.tabBar hideBadgeAtItemIndex:0];
}

- (void)dealloc{
    
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
