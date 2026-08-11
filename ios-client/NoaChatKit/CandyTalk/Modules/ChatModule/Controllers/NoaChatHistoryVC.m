//
//  NoaChatHistoryVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/11.
//

#import "NoaChatHistoryVC.h"

#import <JXCategoryView/JXCategoryView.h>
#import "NoaScrollView.h"
#import "NoaChatHistoryTextVC.h"//文本
#import "NoaChatHistoryMediaVC.h"//图片/视频
#import "NoaChatHistoryFileVC.h"//文件

@interface NoaChatHistoryVC () <JXCategoryViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) JXCategoryTitleView *viewCategory;
@property (nonatomic, strong) NoaScrollView *scrollView;
@property (nonatomic, strong) NoaChatHistoryTextVC *vcText;
@property (nonatomic, strong) NoaChatHistoryMediaVC *vcMedia;
@property (nonatomic, strong) NoaChatHistoryFileVC *vcFile;

@end

@implementation NoaChatHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitleStr = LanguageToolMatch(@"聊天记录");
    
    [self setupUI];
}

#pragma mark - 界面布局
- (void)setupUI {
    _viewCategory = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH, DScreenWidth * 0.66, DWScale(35))];
    _viewCategory.delegate = self;
    _viewCategory.titles = @[LanguageToolMatch(@"消息"),LanguageToolMatch(@"图片/视频"),LanguageToolMatch(@"文件")];
    _viewCategory.titleColorGradientEnabled = YES;
    _viewCategory.titleLabelZoomScale = YES;
    _viewCategory.titleFont = FONTR(15);
    _viewCategory.titleLabelZoomScale = 1.0;
    WeakSelf
    self.view.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        switch (themeIndex) {
            case 1:
            {
                //暗黑
                weakSelf.viewCategory.titleColor = COLOR_99_DARK;
                weakSelf.viewCategory.titleSelectedColor = COLOR_5966F2_DARK;
            }
                break;
                
            default:
            {
                weakSelf.viewCategory.titleColor = COLOR_99;
                weakSelf.viewCategory.titleSelectedColor = COLOR_5966F2;
            }
                break;
        }
    };
    //指示器
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorColor = COLOR_5966F2;
    lineView.componentPosition = JXCategoryComponentPosition_Bottom;
    lineView.verticalMargin = 4;
    _viewCategory.indicators = @[lineView];
    
    _scrollView = [[NoaScrollView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH + DWScale(35), DScreenWidth, DScreenHeight - DNavStatusBarH - DWScale(35) - DHomeBarH)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delaysContentTouches = NO;
    _scrollView.contentSize = CGSizeMake(DScreenWidth * 3, 0);
    _scrollView.bounces = NO;
    
    [self.view addSubview:self.viewCategory];
    [self.view addSubview:self.scrollView];
    self.viewCategory.contentScrollView = self.scrollView;
    
    _vcText = [NoaChatHistoryTextVC new];
    _vcText.chatType = _chatType;
    _vcText.sessionID = _sessionID;
    _vcText.groupInfo = self.groupInfoModel;
    _vcText.view.frame = CGRectMake(0, 0, DScreenWidth, _scrollView.height);
    [self addChildViewController:_vcText];
    [self.scrollView addSubview:_vcText.view];
    
    _vcMedia = [NoaChatHistoryMediaVC new];
    _vcMedia.chatType = _chatType;
    _vcMedia.sessionID = _sessionID;
    _vcMedia.groupInfo = self.groupInfoModel;
    _vcMedia.view.frame = CGRectMake(DScreenWidth, 0, DScreenWidth, _scrollView.height);
    [self addChildViewController:_vcMedia];
    [self.scrollView addSubview:_vcMedia.view];
    
    _vcFile = [NoaChatHistoryFileVC new];
    _vcFile.chatType = _chatType;
    _vcFile.sessionID = _sessionID;
    _vcFile.groupInfo = self.groupInfoModel;
    _vcFile.view.frame = CGRectMake(DScreenWidth*2, 0, DScreenWidth, _scrollView.height);
    [self addChildViewController:_vcFile];
    [self.scrollView addSubview:_vcFile.view];
}

@end
