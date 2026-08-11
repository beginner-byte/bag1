//
//  CandyBaseViewController.h
//  NoaKit
//
//  Created by Candy on 2026/8/30.
//

#import <UIKit/UIKit.h>

#import <MJRefresh/MJRefresh.h>

#import "NoaBaseTableView.h"  

NS_ASSUME_NONNULL_BEGIN

@interface CandyBaseViewController : UIViewController

//自定义导航栏
@property (nonatomic, strong) UIView  *navView;//自定义导航栏
@property (nonatomic, strong) UIButton  *navBtnBack;//返回按钮
@property (nonatomic, strong) UIButton *navBtnRight;//右侧按钮
@property (nonatomic, strong) UILabel  *navTitleLabel;//标题
@property (nonatomic, strong) UIView  *navLineView;//线条
@property (nonatomic, copy) NSString *navTitleStr;//导航栏标题

@property (nonatomic, strong) NoaBaseTableView *baseTableView;
@property (nonatomic, assign) UITableViewStyle baseTableViewStyle;
@property (nonatomic, strong) MJRefreshNormalHeader  *refreshHeader;//下拉刷新
@property (nonatomic, strong) MJRefreshBackNormalFooter  *refreshFooter;//上拉加载

//只显示返回按钮
- (void)onlyShowNavBackBtn;
//left按钮点击事件
- (void)navBtnBackClicked;
//right按钮点击事件
- (void)navBtnRightClicked;

//刷新数据
- (void)headerRefreshData;
- (void)footerRefreshData;

//默认列表布局约束
- (void)defaultTableViewUI;
//展示版本号
-(void)showAppVersion;
@end

NS_ASSUME_NONNULL_END
