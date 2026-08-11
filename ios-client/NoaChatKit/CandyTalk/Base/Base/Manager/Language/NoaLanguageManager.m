//
//  NoaLanguageManager.m
//  NoaKit
//
//  Created by Candy on 2026/12/28.
//

#import "NoaLanguageManager.h"
#import "NoaToolManager.h"
#import "FMDB.h"

static dispatch_once_t onceToken;

@interface NoaLanguageManager()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation NoaLanguageManager

#pragma mark - 单例的实现
+ (instancetype)shareManager{
    static NoaLanguageManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaLanguageManager shareManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaLanguageManager shareManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaLanguageManager shareManager];
}
#pragma mark - 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    onceToken = 0;
}
//是否需要RTL布局
-(BOOL)isRTL{
    if([self.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"] ||
       [self.currentLanguage.languageName_zn isEqualToString:@"波斯语"]){
        return YES;
    }else{
        return NO;
    }
}
//初始化
- (void)initLanguageSetting {
    //默认展示多语言
    _isLanguageSetting = YES;
    _languageList = nil;
    _currentLanguage = nil;
    [self currentLanguage];
    
    [ZTOOL RTLConfig];
}

//获取App本地化语言设置信息(以App设置里为第一判断条件，以系统语音为第二判断条件)
- (NSString *)matchLocalLanguage:(NSString *)originalStr {
    NSString * languageAbbr;
    
    //印尼语 缩写 id 为关键字，改为 in_id, 只在读取 本地 语音文件时 使用 id 其余地方 均使用 in_id
    if([self.currentLanguage.languageAbbr isEqualToString:@"in_id"]){
        languageAbbr = @"id";
    }else{
        languageAbbr = self.currentLanguage.languageAbbr;
    }
    return [self matchLocalLanguage:originalStr languageAbbr:languageAbbr];
}

- (NSString *)matchLocalLanguage:(NSString *)originalStr languageAbbr:(NSString *)languageAbbr {
    NSString *path = [[NSBundle mainBundle] pathForResource:languageAbbr ofType:@"lproj"];
    NSString * word = [[NSBundle bundleWithPath:path] localizedStringForKey:originalStr value:nil table:nil];
    if(word){
        return word;
    }else{
        return originalStr;
    }
}


//根据当前语言类型返回隐私政策/用户协议对应的语言类型参数
- (NSString *)matchAgreementAndPolicyWithLocalLanguage {
    return self.currentLanguage.languageCode;
}

//根据后台返回的code码，返回对应翻译后的提示文字内容
- (NSString *)matchTranslateMessageFromCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg  {
    //获取errorCode和errorMsg对应的plist表内容
    NSString *netResultCodePath = [[NSBundle mainBundle] pathForResource:@"NoaNetResultCode" ofType:@"plist"];
    NSDictionary *NetResultCodeDic = [NSDictionary dictionaryWithContentsOfFile:netResultCodePath];
    
    NSString *keyStr = [NSString stringWithFormat:@"%ld", (long)errorCode];
    NSString *vauleStr;
    if ([NetResultCodeDic.allKeys containsObject:keyStr]) {
        vauleStr = [NetResultCodeDic objectForKeySafe:keyStr];
    } else {
        vauleStr = @"操作失败";
    }
    
    return LanguageToolMatch(vauleStr);
}

//通过获取当前设备的语种code匹配群公告翻译后的译文里的语种code
- (NSString *)languageCodeFromDevieInfo {
    if([self.currentLanguage.languageName_zn isEqualToString:@"系统语言"]) {
        NSString *languageCode = @"";
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSArray  *array = [language componentsSeparatedByString:@"-"];
        if (array.count == 1) {
            languageCode = language;
        } else if (array.count == 2) {
            languageCode = [NSString stringWithFormat:@"%@", array[0]];
        } else if (array.count == 3) {
            languageCode = [NSString stringWithFormat:@"%@-%@", array[0], array[1]];
        } else {
            languageCode = language;
        }
        //从本地数据库里查找对应的MapLanguageCode
        NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"noa_constant" ofType:@"db"];
        self.db = [[FMDatabase alloc] initWithPath:dbPath];
        if ([self.db open]) {
            //根据当前的语言，选择不同的国家名称展示
            NSString *sql =  [NSString stringWithFormat:@"SELECT mapCode FROM language WHERE languageTag = '%@'", languageCode];
            FMResultSet *rs = [self.db executeQuery:sql];//查询数据库
            // 处理查询结果
            while ([rs next]) {
                NSString *mapCode = [rs stringForColumn:@"mapCode"];
                if (mapCode.length <= 0) {
                    return @"en";
                } else {
                    return mapCode;
                }
            }
        }
        return @"en";
    } else {
        return self.currentLanguage.languageMapCode;
    }
}

- (NoaLanguageInfo *)currentLanguage{
    if (_currentLanguage == nil) {
        NSString * type = [[MMKV defaultMMKV] getStringForKey:Z_LANGUAGE_SELECTES_TYPE];
        if (type == nil) {
            //未设置语言情况下 默认 走跟随系统语音
            _currentLanguage = self.languageList.firstObject;
        }
        //从本地语音 列表中 获取语言信息
        for (NoaLanguageInfo * languageInfo in self.languageList) {
            if([languageInfo.languageName_zn isEqualToString:type]){
                _currentLanguage = languageInfo;
                break;
            }
        }
        if(_currentLanguage == nil){
            //如果找不到匹配的类型 默认显示英文
            _currentLanguage = self.languageList[3];
        }
        //配置第一个 跟跟随系统信息的配置
        NoaLanguageInfo * configInfo = self.languageList.firstObject;
        NoaLanguageInfo * languageInfo;
        if(_currentLanguage == configInfo){
            //如果用户 选择跟随系统配置 则 根据系统配置 获取 语音对象 配置 第一项
            NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
            NSArray  *array = [language componentsSeparatedByString:@"-"];
            NSString *systemLanguage = @"";
            if (array.count > 2) {
                systemLanguage = [NSString stringWithFormat:@"%@-%@", array[0], array[1]];
            } else {
                systemLanguage = [NSString stringWithFormat:@"%@", array[0]];
            }
            for (NoaLanguageInfo * info in self.languageList) {
                if([info.languageAbbr isEqualToString:systemLanguage]){
                    languageInfo = info;
                    break;
                }
            }
            if(languageInfo == nil){
                languageInfo = self.languageList[3];
            }
        }else{
            //如果用户 选择特定语言 则 特定语音对象 配置 第一项
            languageInfo = self.currentLanguage;
        }
        //config
        configInfo.languageAbbr = languageInfo.languageAbbr;
        configInfo.languageCode = languageInfo.languageCode;
        configInfo.languageName = [self matchLocalLanguage:configInfo.languageName_zn languageAbbr:languageInfo.languageAbbr];
        
    }
    return _currentLanguage;
}


-(NSArray<NoaLanguageInfo *> *)languageList{
    if (_languageList == nil) {
        
        NoaLanguageInfo * info0 = [NoaLanguageInfo new];
        info0.languageName_zn = @"系统语言";
        
        NoaLanguageInfo * info1 = [NoaLanguageInfo new];
        info1.languageName = @"简体中文";
        info1.languageAbbr = @"zh-Hans";
        info1.languageMapCode = @"zh";
        info1.languageName_zn = @"简体中文";
        info1.languageCode = @"1";
        
        NoaLanguageInfo * info2 = [NoaLanguageInfo new];
        info2.languageName = @"繁體中文";
        info2.languageAbbr = @"zh-Hant";
        info2.languageMapCode = @"cht";
        info2.languageName_zn = @"繁体中文";
        info2.languageCode = @"2";
        
        NoaLanguageInfo * info3 = [NoaLanguageInfo new];
        info3.languageName = @"English";
        info3.languageAbbr = @"en";
        info3.languageMapCode = @"en";
        info3.languageName_zn = @"英语";
        info3.languageCode = @"3";
        
       
        _languageList = @[info0,
                          info1,
                          info2,
                          info3];
    }
    return _languageList;
}

@end
