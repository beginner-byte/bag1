//
//  NoaSystemMessageVC.m
//  NoaKit
//
//  Created by Candy on 2023/5/9.
//

#import "NoaSystemMessageVC.h"
#import <JXCategoryView/JXCategoryView.h>
#import "NoaScrollView.h"
#import "NoaSystemMessageAllVC.h"//全部
#import "NoaSystemMessagePendReviewVC.h"//待审核

@interface NoaSystemMessageVC () <JXCategoryViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) JXCategoryTitleView *viewCategory;
@property (nonatomic, strong) NoaScrollView *scrollView;
@property (nonatomic, strong) NoaSystemMessageAllVC *vcAllReview;
@property (nonatomic, strong) NoaSystemMessagePendReviewVC *vcPendReview;

@end

@implementation NoaSystemMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.groupHelperType == ZGroupHelperFormTypeGroupManager) {
        self.navTitleStr = LanguageToolMatch(@"进群申请");
    }
    if (self.groupHelperType == ZGroupHelperFormTypeSessionList) {
        self.navTitleStr = LanguageToolMatch(@"群通知");
    }
    [self setupUI];

    [self sendSystemMessageRead];
}

#pragma mark - 界面布局
- (void)setupUI {
    _viewCategory = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH, DScreenWidth, DWScale(40))];
    _viewCategory.delegate = self;
    _viewCategory.titles = @[LanguageToolMatch(@"全部"),LanguageToolMatch(@"待审核")];
    _viewCategory.titleColorGradientEnabled = YES;
    _viewCategory.titleLabelZoomScale = YES;
    _viewCategory.titleFont = FONTB(16);
    _viewCategory.titleLabelZoomScale = 1.0;
    WeakSelf
    self.view.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        switch (themeIndex) {
            case 1:
            {
                //暗黑
                weakSelf.viewCategory.titleColor = COLOR_66_DARK;
                weakSelf.viewCategory.titleSelectedColor = COLOR_11_DARK;
            }
                break;
                
            default:
            {
                weakSelf.viewCategory.titleColor = COLOR_66;
                weakSelf.viewCategory.titleSelectedColor = COLOR_11;
            }
                break;
        }
    };
    //指示器
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorColor = COLOR_5966F2;
    lineView.componentPosition = JXCategoryComponentPosition_Bottom;
    lineView.verticalMargin = 5;
    _viewCategory.indicators = @[lineView];
    
    _scrollView = [[NoaScrollView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH + DWScale(40), DScreenWidth, DScreenHeight - DNavStatusBarH - DWScale(40) - DHomeBarH)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delaysContentTouches = NO;
    _scrollView.contentSize = CGSizeMake(DScreenWidth * 2, 0);
    _scrollView.bounces = NO;
    
    [self.view addSubview:self.viewCategory];
    [self.view addSubview:self.scrollView];
    self.viewCategory.contentScrollView = self.scrollView;
    
    _vcAllReview = [NoaSystemMessageAllVC new];
    _vcAllReview.groupHelperType = self.groupHelperType;
    _vcAllReview.groupId = self.groupId;
    _vcAllReview.view.frame = CGRectMake(0, 0, DScreenWidth, _scrollView.height);
    [self addChildViewController:_vcAllReview];
    [self.scrollView addSubview:_vcAllReview.view];
    
    _vcPendReview = [NoaSystemMessagePendReviewVC new];
    _vcPendReview.groupHelperType = self.groupHelperType;
    _vcPendReview.groupId = self.groupId;
    _vcPendReview.view.frame = CGRectMake(DScreenWidth, 0, DScreenWidth, _scrollView.height);
    [self addChildViewController:_vcPendReview];
    [self.scrollView addSubview:_vcPendReview.view];
}

#pragma mark - 系统消息(群助手)消息已读
- (void)sendSystemMessageRead {
    if (_sessionModel) {
        //发送消息已读
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
        [dict setObjectSafe:@(5) forKey:@"chatType"];
        [dict setObjectSafe:_sessionModel.sessionLatestMessage.serviceMsgID forKey:@"smsgId"];
        [dict setObjectSafe:_sessionModel.sessionID forKey:@"sendMsgUserUid"];
        
        [[NoaIMSDKManager sharedTool] readedMessage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            
        }];
    }
}
@end
