//
//  NoaCountryCodeViewController.m
//  NoaKit
//
//  Created by Candy on 2023/3/28.
//

#import "NoaCountryCodeViewController.h"
#import "NoaSearchView.h"
#import "NoaCountryCodeCell.h"
#import "FMDB.h"

@interface NoaCountryCodeViewController () <UITableViewDataSource, UITableViewDelegate, ZSearchViewDelegate>

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSMutableArray *countryList;
@property (nonatomic, strong) NSMutableArray *oriArray;

@end

@implementation NoaCountryCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    [self setupUI];
    [self setupLocalDB];
}

- (void)setupNavBar {
    self.navLineView.hidden = YES;
    self.navBtnBack.hidden = NO;
    self.navBtnRight.hidden = YES;
    self.navTitleLabel.text = LanguageToolMatch(@"选择国家/地区");
}

- (void)setupUI {
    NoaSearchView *searchView = [[NoaSearchView alloc] initWithPlaceholder:LanguageToolMatch(@"搜索")];
    searchView.currentViewSearch = YES;
    searchView.delegate = self;
    searchView.returnKeyType = UIReturnKeyDefault;
    [self.view addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(0));
        make.height.mas_equalTo(DWScale(38));
    }];
    
    [self.view addSubview:self.baseTableView];
    self.baseTableView.delaysContentTouches = NO;
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.backgroundColor = UIColor.clearColor;
    [self.baseTableView registerClass:[NoaCountryCodeCell class] forCellReuseIdentifier:[NoaCountryCodeCell cellIdentifier]];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.equalTo(searchView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
}

- (void)setupLocalDB {
    self.oriArray = @[].mutableCopy;
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"noa_constant" ofType:@"db"];
        weakSelf.db = [[FMDatabase alloc] initWithPath:dbPath];
        if ([weakSelf.db open]) {
            //根据当前的语言，选择不同的国家名称展示            
            NSString *sql;
            if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"]) {
                //简体中文
                sql = [NSString stringWithFormat:@"select * from SMS_country order by countryPinyin asc"];
            } else if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁体中文"]) {
                //繁体中文
                sql = [NSString stringWithFormat:@"select * from SMS_country order by big5 asc"];
            } else if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"英语"]) {
                //英文
                sql = [NSString stringWithFormat:@"select * from SMS_country order by en asc"];
            } else{
                sql = [NSString stringWithFormat:@"select * from SMS_country order by en asc"];
            }
            FMResultSet *rs = [weakSelf.db executeQuery:sql];//查询数据库
            while ([rs next]) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObjectSafe:[rs objectForColumn:@"id"] forKey:@"id"];
                [dict setObjectSafe:[rs objectForColumn:@"countryPinyin"] forKey:@"pinyin"];//中文拼音
                [dict setObjectSafe:[rs objectForColumn:@"prefix"] forKey:@"prefix"];
                [dict setObjectSafe:[rs objectForColumn:@"price"] forKey:@"price"];
                [dict setObjectSafe:[rs objectForColumn:@"emojiLogo"] forKey:@"emojiLogo"];
                [dict setObjectSafe:[rs objectForColumn:@"zh"] forKey:@"zh-Hans"];
                [dict setObjectSafe:[rs objectForColumn:@"big5"] forKey:@"zh-Hant"];
                [dict setObjectSafe:[rs objectForColumn:@"en"] forKey:@"en"];
                [dict setObjectSafe:[rs objectForColumn:@"es"] forKey:@"es"];
                [dict setObjectSafe:[rs objectForColumn:@"ar"] forKey:@"ar"];
                [dict setObjectSafe:[rs objectForColumn:@"bn"] forKey:@"bn"];
                [dict setObjectSafe:[rs objectForColumn:@"fa"] forKey:@"fa"];
                [dict setObjectSafe:[rs objectForColumn:@"fr"] forKey:@"fr"];
                [dict setObjectSafe:[rs objectForColumn:@"hi"] forKey:@"hi"];
                [dict setObjectSafe:[rs objectForColumn:@"ky"] forKey:@"ky"];
                [dict setObjectSafe:[rs objectForColumn:@"ru"] forKey:@"ru"];
                [dict setObjectSafe:[rs objectForColumn:@"tr"] forKey:@"tr"];
                [dict setObjectSafe:[rs objectForColumn:@"uz"] forKey:@"uz"];
                //数据库字段不能有- 用_替换 拿到数据后 字典 key 为 pt-BR
                [dict setObjectSafe:[rs objectForColumn:@"pt_BR"] forKey:@"pt-BR"];
                [dict setObjectSafe:[rs objectForColumn:@"in_id"] forKey:@"in_id"];
                [dict setObjectSafe:[rs objectForColumn:@"vi"] forKey:@"vi"];
                [dict setObjectSafe:[rs objectForColumn:@"ko"] forKey:@"ko"];

                [self.oriArray addObject:dict];
            }
        }
        weakSelf.countryList = self.oriArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            //在主线程刷新tableView
            [weakSelf.baseTableView reloadData];
        });
    });
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString {
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

#pragma mark - ZSearchViewDelegate
- (void)searchViewReturnKeySearch:(NSString *)searchStr {
    if (![NSString isNil:[searchStr trimString]]) {
        NSString *resultSearchStr = [searchStr trimString];
        //搜索数据库
        if (resultSearchStr.length > 0) {
            WeakSelf
            NSArray *arr = [[NSMutableArray searchCountryArea:resultSearchStr] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary*  _Nonnull obj1, NSDictionary*  _Nonnull obj2) {
                if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"]||
                    [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁体中文"]||
                    [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"英语"]) {
                    return [[weakSelf firstCharactor:obj1[ZLanguageTOOL.currentLanguage.languageAbbr]] compare:[weakSelf firstCharactor:obj2[ZLanguageTOOL.currentLanguage.languageAbbr]]];

                }else{
                    return [obj1[ZLanguageTOOL.currentLanguage.languageAbbr] compare:obj2[ZLanguageTOOL.currentLanguage.languageAbbr]];

                }
            }];
            self.countryList = arr.mutableCopy;
        } else {
            self.countryList = self.oriArray;
        }
    } else {
        self.countryList = self.oriArray;
    }
    [self.baseTableView reloadData];
    [self.view endEditing:YES];

}

- (void)searchViewTextValueChanged:(NSString *)searchStr {
    if (![NSString isNil:searchStr]) {
        NSString *resultSearchStr = [searchStr trimString];
        //搜索数据库
        if (resultSearchStr.length > 0) {
            WeakSelf
            NSArray *arr = [[NSMutableArray searchCountryArea:resultSearchStr] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary*  _Nonnull obj1, NSDictionary*  _Nonnull obj2) {
                if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"简体中文"]||
                    [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"繁体中文"]||
                    [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"英语"]) {
                    return [[weakSelf firstCharactor:obj1[ZLanguageTOOL.currentLanguage.languageAbbr]] compare:[weakSelf firstCharactor:obj2[ZLanguageTOOL.currentLanguage.languageAbbr]]];

                }else{
                    return [obj1[ZLanguageTOOL.currentLanguage.languageAbbr] compare:obj2[ZLanguageTOOL.currentLanguage.languageAbbr]];

                }
            }];
            self.countryList = arr.mutableCopy;
        } else {
            self.countryList = self.oriArray;
        }
    } else {
        self.countryList = self.oriArray;
    }
    [self.baseTableView reloadData];
}

#pragma mark - Tableview delegate dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.countryList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(52);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NoaCountryCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaCountryCodeCell cellIdentifier] forIndexPath:indexPath];
    NSDictionary *dict = (NSDictionary *)[self.countryList objectAtIndex:indexPath.row];
    cell.countryDic = dict;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = (NSDictionary *)[self.countryList objectAtIndex:indexPath.row];
    if (self.selecgCountryCodeBlock) {
        self.selecgCountryCodeBlock(dict);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
