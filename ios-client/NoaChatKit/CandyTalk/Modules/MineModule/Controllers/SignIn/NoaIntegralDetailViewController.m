//
//  NoaIntegralDetailViewController.m
//  NoaKit
//
//  Created by Candy on 2024/1/9.
//

#import "NoaIntegralDetailViewController.h"
#import "NoaIntergralDetailCell.h"
#import "NoaFDatePickerView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface NoaIntegralDetailViewController ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property(nonatomic, strong)UILabel *usedIntergralLbl;
@property(nonatomic, strong)UILabel *obtainIntergralLbl;
@property(nonatomic, strong)NSMutableArray *dataList;
@property(nonatomic, strong)UIButton *downButtonMenu;

@end

@implementation NoaIntegralDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.navTitleStr = LanguageToolMatch(@"积分明细");
    [self setupUI];
    
    NSString *currentYear = [NSString stringWithFormat:@"%ld", [NSDate getYearWithCurrentDate]];
    NSString *currentMonth = [NSString stringWithFormat:@"%ld", [NSDate getMonthWithCurrentDate]];
    [self requestIntergralDetailRecordWithSelectYear:currentYear selectMonth:currentMonth];
}

- (void)setupUI {
    //选择日期
    [self.view addSubview:self.downButtonMenu];
    [self.downButtonMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(DNavStatusBarH + DWScale(8));
        make.leading.mas_equalTo(self.view.mas_leading).offset(DWScale(16));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    //获得
    [self.view addSubview:self.obtainIntergralLbl];
    [self.obtainIntergralLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-DWScale(16));
        make.centerY.mas_equalTo(self.downButtonMenu);
        make.height.mas_equalTo(DWScale(18));
    }];
    
    //使用
    [self.view addSubview:self.usedIntergralLbl];
    [self.usedIntergralLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.obtainIntergralLbl.mas_leading).offset(-DWScale(20));
        make.centerY.mas_equalTo(self.downButtonMenu);
        make.height.mas_equalTo(DWScale(18));
    }];
   
    //操作时间
    UILabel *handleTimeLabel = [[UILabel alloc] init];
    handleTimeLabel.text = LanguageToolMatch(@"操作时间");
    handleTimeLabel.tkThemetextColors = @[COLOR_66, COLOR_99];
    handleTimeLabel.font = FONTR(12);
    [self.view addSubview:handleTimeLabel];
    [handleTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading).offset(DWScale(16));
        make.top.mas_equalTo(self.downButtonMenu.mas_bottom).offset(DWScale(12));
        make.width.mas_equalTo((DScreenWidth - DWScale(16 + 30 + 8)) / 3 + DWScale(30 + 8));
        make.height.mas_equalTo(DWScale(18));
    }];
        
    //操作类型
    UILabel * handleTypeLabel = [[UILabel alloc] init];
    handleTypeLabel.text = LanguageToolMatch(@"操作类型");
    handleTypeLabel.tkThemetextColors = @[COLOR_66, COLOR_99];
    handleTypeLabel.font = FONTR(12);
    handleTypeLabel.textAlignment = NSTextAlignmentCenter;
    handleTypeLabel.numberOfLines = 2;
    [self.view addSubview:handleTypeLabel];
    [handleTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(handleTimeLabel.mas_trailing);
        make.centerY.mas_equalTo(handleTimeLabel);
        make.width.mas_equalTo((DScreenWidth - DWScale(16 + 30 + 8)) / 3);
    }];
    
    //积分
    UILabel *intergralLabel = [[UILabel alloc] init];
    intergralLabel.text = LanguageToolMatch(@"积分");
    intergralLabel.tkThemetextColors = @[COLOR_66, COLOR_99];
    intergralLabel.font = FONTR(12);
    intergralLabel.textAlignment = NSTextAlignmentCenter;
    intergralLabel.numberOfLines = 2;
    [self.view addSubview:intergralLabel];
    [intergralLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(handleTypeLabel.mas_trailing);
        make.centerY.mas_equalTo(handleTypeLabel);
        make.width.mas_equalTo((DScreenWidth - DWScale(16 + 30 + 8)) / 3);
    }];
    
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.bounces = YES;
    self.baseTableView.separatorColor = COLOR_CLEAR;
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.emptyDataSetSource = self;
    self.baseTableView.emptyDataSetDelegate = self;
    self.baseTableView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(handleTimeLabel.mas_bottom).offset(8);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    [self.baseTableView registerClass:[NoaIntergralDetailCell class] forCellReuseIdentifier:NSStringFromClass([NoaIntergralDetailCell class])];
}

-(void)selectDataPicker{
    WeakSelf;
    NoaFDatePickerView *datePickerView = [[NoaFDatePickerView alloc]initDatePackerWithSUperView:self.view response:^(NSString *str,NSString* selectYear,NSString* selectMonth) {
        NSString *string = str;
        [weakSelf.downButtonMenu setTitle:string forState:UIControlStateNormal];
        [weakSelf.downButtonMenu setBtnImageAlignmentType:ButtonImageAlignmentTypeRight imageSpace:DWScale(6)];
        [weakSelf requestIntergralDetailRecordWithSelectYear:selectYear selectMonth:selectMonth];
    }];
    [datePickerView show];
}

#pragma mark - Network
- (void)requestIntergralDetailRecordWithSelectYear:(NSString*)year selectMonth:(NSString*)month
{
    WeakSelf;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:year forKey:@"year"];
    [dict setValue:month forKey:@"month"];
    [IMSDKManager imSignInWithIntergralDetail:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        DLog(@"积分明细======%@",data);
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            NSInteger userIntergralNum = [[dataDict objectForKeySafe:@"useIntegral"] integerValue];
            NSInteger obtainIntergralNum = [[dataDict objectForKeySafe:@"gainIntegral"] integerValue];
            weakSelf.usedIntergralLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"使用：%ld"), userIntergralNum];
            weakSelf.obtainIntergralLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"获得：%ld"), obtainIntergralNum];
            
            NSArray *intergralList = (NSArray *)[dataDict objectForKeySafe:@"integralRecordVos"];
            [weakSelf.dataList removeAllObjects];
            [weakSelf.dataList addObjectsFromArray:intergralList];
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
      
    }];
}
#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(50);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaIntergralDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaIntergralDetailCell class]) forIndexPath:indexPath];
    NSDictionary *dict = [self.dataList objectAtIndex:indexPath.row];
    cell.intergralDetailDict = dict;
    return cell;
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(-120);
}
//空态图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return ImgNamed(@"c_no_history_chat");
}

#pragma mark - DZNEmptyDataSetDelegate
//允许滑动
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - Lazy
- (UILabel *)usedIntergralLbl {
    if (!_usedIntergralLbl) {
        _usedIntergralLbl = [[UILabel alloc] init];
        _usedIntergralLbl.text = @"";
        _usedIntergralLbl.tkThemetextColors = @[COLOR_99, COLOR_99];
        _usedIntergralLbl.font = FONTR(12);
    }
    return _usedIntergralLbl;
}

- (UILabel *)obtainIntergralLbl {
    if (!_obtainIntergralLbl) {
        _obtainIntergralLbl = [[UILabel alloc] init];
        _obtainIntergralLbl.text = @"";
        _obtainIntergralLbl.tkThemetextColors = @[COLOR_99, COLOR_99];
        _obtainIntergralLbl.font = FONTR(12);
    }
    return _obtainIntergralLbl;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (UIButton *)downButtonMenu {
    if (!_downButtonMenu) {
        _downButtonMenu = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downButtonMenu setImage:ImgNamed(@"signDownBtn") forState:UIControlStateNormal];
        [_downButtonMenu setTitle:[NSString stringWithFormat:@"%ld-%ld", [NSDate getYearWithCurrentDate],[NSDate getMonthWithCurrentDate]] forState:UIControlStateNormal];
        [_downButtonMenu setTkThemeTitleColor:@[COLOR_11, COLOR_99] forState:UIControlStateNormal];
        _downButtonMenu.titleLabel.font = FONTR(12);
        [_downButtonMenu setBtnImageAlignmentType:ButtonImageAlignmentTypeRight imageSpace:DWScale(6)];
        [_downButtonMenu addTarget:self action:@selector(selectDataPicker) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downButtonMenu;
}


@end
