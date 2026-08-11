//
//  NoaLanguageInfo.h
//  NoaKit
//
//  Created by Candy on 2023/9/14.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaLanguageInfo : NoaBaseModel

@property (nonatomic, copy) NSString * languageName;    //语言名称

@property (nonatomic, copy) NSString * languageName_zn; //语音中文

@property (nonatomic, copy) NSString * languageAbbr;    //语音缩写

@property (nonatomic, copy) NSString * languageCode;    //隐私政策/用户协议对应的语言类型参数

@property (nonatomic, copy) NSString * languageMapCode; //翻译语种映射表里的语言code


@end

NS_ASSUME_NONNULL_END
