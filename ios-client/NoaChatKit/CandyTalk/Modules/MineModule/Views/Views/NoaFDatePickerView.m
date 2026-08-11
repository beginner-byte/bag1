//
//  NoaFDatePickerView.m
//  NoaKit
//
//  Created by Candy on 2026/11/17.
//
#import "NoaFDatePickerView.h"
#import "AppDelegate.h"

@interface NoaFDatePickerView () <UIPickerViewDataSource,UIPickerViewDelegate>{
    UIView *contentView;
    void(^backBlock)(NSString *,NSString*,NSString*);
    
    NSMutableArray *yearArray;
    NSMutableArray *monthArray;
    NSInteger currentYear;
    NSInteger currentMonth;
    NSString *restr;
    
    NSString *selectedYear;
    NSString *selectecMonth;
    
    BOOL onlySelectYear;
    
    UIView *superView;
}


@end

@implementation NoaFDatePickerView

#pragma mark - initDatePickerView
/**
 初始化方法，只带年月的日期选择
 
 @param block 返回选中的日期
 @return QFDatePickerView对象
 */
- (instancetype)initDatePackerWithResponse:(void (^)(NSString *,NSString *,NSString *))block{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    [self setViewInterface];
    if (block) {
        backBlock = block;
    }
    onlySelectYear = NO;
    return self;
}

/**
 初始化方法，只带年月的日期选择
 
 @param superView picker的载体View
 @param block 返回选中的日期
 @return QFDatePickerView对象
 */
- (instancetype)initDatePackerWithSUperView:(UIView *)superView response:(void(^)(NSString*,NSString *,NSString *))block {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    [self setViewInterface];
    if (block) {
        backBlock = block;
    }
    superView = superView;
    onlySelectYear = NO;
    return self;
}

/**
 初始化方法，只带年份的日期选择
 
 @param block 返回选中的年份
 @return QFDatePickerView对象
 */
- (instancetype)initYearPickerViewWithResponse:(void(^)(NSString*,NSString *,NSString *))block {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    [self setViewInterface];
    if (block) {
        backBlock = block;
    }
    onlySelectYear = YES;
    return self;
}

/**
 初始化方法，只带年份的日期选择
 
 @param block 返回选中的年份
 @return QFDatePickerView对象
 */
- (instancetype)initYearPickerWithView:(UIView *)superView response:(void(^)(NSString*,NSString *,NSString *))block {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    [self setViewInterface];
    if (block) {
        backBlock = block;
    }
    superView = superView;
    onlySelectYear = YES;
    return self;
}

#pragma mark - Configuration
- (void)setViewInterface {
    
    [self getCurrentDate];
    
    [self setYearArray];
    
    [self setMonthArray];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, DScreenWidth, DWScale(300))];
    [self addSubview:contentView];

    //设置背景颜色为黑色，并有0.4的透明度
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    //添加白色view
    UIView *whiteView = [[UIView alloc] init];
    whiteView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:whiteView];
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.height.mas_equalTo(DWScale(40));
    }];
    //添加确定和取消按钮
    for (int i = 0; i < 2; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 80) * i, 0, 80, 40)];
        [button setTitle:i == 0 ? LanguageToolMatch(@"取消") : LanguageToolMatch(@"确定") forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:HEXCOLOR(@"666666") forState:UIControlStateNormal];
        } else {
            [button setTitleColor:HEXCOLOR(@"333333") forState:UIControlStateNormal];
        }
        [whiteView addSubview:button];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10 + i;
    }
    
    
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor whiteColor];
    
    //设置pickerView默认选中当前时间
    [pickerView selectRow:[selectedYear integerValue] - 1970 inComponent:0 animated:YES];
    if (!onlySelectYear) {
        [pickerView selectRow:[selectecMonth integerValue] - 1 inComponent:1 animated:YES];
    }
    
    [contentView addSubview:pickerView];
    [pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(contentView);
        make.top.equalTo(contentView).offset(DWScale(40));
        make.height.mas_equalTo(260);
    }];
}

- (void)getCurrentDate {
    //获取当前时间 （时间格式支持自定义）
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM"];//自定义时间格式
    NSString *currentDateStr = [formatter stringFromDate:[NSDate date]];
    //拆分年月成数组
    NSArray *dateArray = [currentDateStr componentsSeparatedByString:@"-"];
    if (dateArray.count == 2) {//年 月
        currentYear = [[dateArray firstObject]integerValue];
        currentMonth =  [dateArray[1] integerValue];
    }
    selectedYear = [NSString stringWithFormat:@"%ld",(long)currentYear];
    selectecMonth = [NSString stringWithFormat:@"%ld",(long)currentMonth];
}

- (void)setYearArray {
    //初始化年数据源数组
    yearArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1970; i <= currentYear ; i++) {
        NSString *yearStr = [NSString stringWithFormat:@"%ld",(long)i];
        [yearArray addObject:yearStr];
    }
   // [yearArray addObject:@"至今"];
}

- (void)setMonthArray {
    //初始化月数据源数组
    monthArray = [[NSMutableArray alloc]init];
    
    if ([[selectedYear safeSubstringWithRange:NSMakeRange(0, 4)] isEqualToString:[NSString stringWithFormat:@"%ld",(long)currentYear]]) {
        for (NSInteger i = 1 ; i <= currentMonth; i++) {
            NSString *monthStr = [NSString stringWithFormat:@"%ld",(long)i];
            [monthArray addObject:monthStr];
        }
    } else {
        for (NSInteger i = 1 ; i <= 12; i++) {
            NSString *monthStr = [NSString stringWithFormat:@"%ld",(long)i];
            [monthArray addObject:monthStr];
        }
    }
}

#pragma mark - Actions
- (void)buttonTapped:(UIButton *)sender {
    if (sender.tag == 10) {
        [self dismiss];
    } else {
        if (onlySelectYear) {
            restr = [NSString stringWithFormat:@"%@",selectedYear];;
        } else {
//            selectedYear = [selectedYear stringByReplacingOccurrencesOfString:@"年" withString:@""];
//            selectecMonth = [selectecMonth stringByReplacingOccurrencesOfString:@"月" withString:@""];
            restr = [NSString stringWithFormat:@"%@-%@",selectedYear,selectecMonth];
        }
        backBlock(restr,selectedYear,selectecMonth);
        [self dismiss];
    }
}

#pragma mark - pickerView出现
- (void)show {
    if (superView) {
        [superView addSubview:self];
    } else {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    [UIView animateWithDuration:0.25 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y - contentView.frame.size.height);
    }];
}
#pragma mark - pickerView消失
- (void)dismiss{
    
    [UIView animateWithDuration:0.25 animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y + contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (onlySelectYear) {//只选择年
        return 1;
    } else {
        return 2;
    }
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (onlySelectYear) {//只选择年
        return yearArray.count;
    } else {
        if (component == 0) {
            return yearArray.count;
        } else {
            return monthArray.count;
        }
    }
    return 0;
}

/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (onlySelectYear) {//只选择年
        return yearArray[row];
    } else {
        if (component == 0) {
            return yearArray[row];
        } else {
            return monthArray[row];
        }
    }
    return @"";
}
*/

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary* titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         COLOR_11, NSForegroundColorAttributeName,
                                         FONTN(18), NSFontAttributeName,
                                         nil];
    NSString *rowTitleStr = [NSString string];
    if (onlySelectYear) {//只选择年
        rowTitleStr = yearArray[row];
    } else {
        if (component == 0) {
            rowTitleStr = yearArray[row];
        } else {
            rowTitleStr = monthArray[row];
        }
    }
    NSAttributedString *titleAttStr = [[NSAttributedString alloc] initWithString:rowTitleStr attributes:titleTextAttributes];
    
    return titleAttStr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (onlySelectYear) {//只选择年
        selectedYear = yearArray[row];
    } else {
        if (component == 0) {
            selectedYear = yearArray[row];
            if ([selectedYear isEqualToString:@"至今"]) {//至今的情况下,月份清空
                [monthArray removeAllObjects];
                selectecMonth = @"";
            } else {//非至今的情况下,显示月份
                [self setMonthArray];
                selectecMonth = [NSString stringWithFormat:@"%ld",(long)currentMonth];
            }
            [pickerView reloadComponent:1];
            
        } else {
            selectecMonth = monthArray[row];
        }
    }
}

@end
