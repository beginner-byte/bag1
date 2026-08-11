//
//  NoaLanguageManager.h
//  NoaKit
//
//  Created by Candy on 2026/12/28.
//

#define ZLanguageTOOL                   [NoaLanguageManager shareManager]
#define LanguageToolMatch(str)          [[NoaLanguageManager shareManager] matchLocalLanguage:str]
#define LanguageToolCodeMatch(code, msg)     [[NoaLanguageManager shareManager] matchTranslateMessageFromCode:code errorMsg:msg]

#import <Foundation/Foundation.h>
#import "NoaLanguageInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaLanguageManager : NSObject

#pragma mark - 单例的实现
+ (instancetype)shareManager;

// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager;

//是否需要多语言翻译(使用该属性可以控制是否显示多语言选项)
@property(nonatomic, assign) BOOL isLanguageSetting;

//是否需要RTL布局
@property (nonatomic, assign, readonly) BOOL isRTL;

//当前语言
@property(nonatomic, strong) NoaLanguageInfo * currentLanguage;

//支持的语言列表
@property (nonatomic, copy) NSArray<NoaLanguageInfo *> * languageList;

//初始化
- (void)initLanguageSetting;

//获取App本地化语言设置信息
- (NSString *)matchLocalLanguage:(NSString *)originalStr;
//根据当前语言类型返回隐私政策/用户协议对应的语言类型参数
- (NSString *)matchAgreementAndPolicyWithLocalLanguage;
//根据后台返回的code码，返回对应翻译后的提示文字
- (NSString *)matchTranslateMessageFromCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg;
//通过获取当前设备的语种code匹配群公告翻译后的译文里的语种code
- (NSString *)languageCodeFromDevieInfo;

@end

NS_ASSUME_NONNULL_END
