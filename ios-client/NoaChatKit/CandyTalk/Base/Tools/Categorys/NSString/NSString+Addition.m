//
//  NSString+Addition.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import "NSString+Addition.h"
#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <MobileCoreServices/MobileCoreServices.h>

//无网络
static NSString * notReachable = @"notReachable";

@implementation NSString (Addition)

#pragma mark ------<判断字符串是否为空>
+ (BOOL)isNil:(NSString *)str {
    if (![str isKindOfClass:[NSString class]]) {
        return YES;
    }
    if (str == nil || str == NULL) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    if ([str isEqualToString:@"<null>"]) {
        return YES;
    }
    if ([str isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([[str lowercaseString] isEqualToString:@"null"]) {
        return YES;
    }
    return (str.length == 0);
}

#pragma mark - 删除字符串开头与结尾的空白符与换行
- (NSString *)trimString{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - 图片地址中文处理
- (NSURL *)imageUrlEncode{
    //NSString *imageUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *imageUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    return [NSURL URLWithString:imageUrl];
}

#pragma mark - url地址中文处理
- (NSString *)requrestUrlEncode {
    NSString *requrstUrlStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    return requrstUrlStr;
}

#pragma mark - 数字和字母组合
- (BOOL)isNumberAndLetter{
    NSString *pattern = @"^[A-Za-z0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",pattern];
    return [pred evaluateWithObject:self];
}

#pragma mark - 手机号判断
- (BOOL)isPhoneNumber{
    //NSString *pattern = @"^((13[0-9])|(14[5,7])|(15[^4,\\D])|(18[0-9])|(17[0-9])|(199)|(166)|(198))\\d{8}$";
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",pattern];
    //return [predicate evaluateWithObject:self];
    
    NSString *MOBILE = @"^1(3[0-9]|4[579]|5[0-35-9]|6[6]|7[0-35-9]|8[0-9]|9[89])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:self];
}

#pragma mark - 身份证判断
- (BOOL)isIDCardNumber{
    NSString *idCardNumber = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger length =0;
    if (!idCardNumber) {
        return NO;
    }else {
        length = idCardNumber.length;
        //不满足15位和18位，即身份证错误
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray = @[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    // 检测省份身份行政区代码
    NSString *valueStart2 = [idCardNumber substringToIndex:2];
    BOOL areaFlag =NO; //标识省份代码是否正确
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return NO;
    }
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    //分为15位、18位身份证进行校验
    switch (length) {
        case 15:
            //获取年份对应的数字
            year = [idCardNumber safeSubstringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                //创建正则表达式 NSRegularExpressionCaseInsensitive：不区分字母大小写的模式
                //测试出生日期的合法性
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$" options:NSRegularExpressionCaseInsensitive error:nil];
            }else {
                //测试出生日期的合法性
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$" options:NSRegularExpressionCaseInsensitive error:nil];
            }
            //使用正则表达式匹配字符串 NSMatchingReportProgress:找到最长的匹配字符串后调用block回调
            numberofMatch = [regularExpression numberOfMatchesInString:idCardNumber options:NSMatchingReportProgress range:NSMakeRange(0, idCardNumber.length)];
            
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            year = [idCardNumber safeSubstringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:idCardNumber options:NSMatchingReportProgress range:NSMakeRange(0, idCardNumber.length)];
            
            
            if(numberofMatch >0) {
                //1：校验码的计算方法 身份证号码17位数分别乘以不同的系数。从第一位到第十七位的系数分别为：7－9－10－5－8－4－2－1－6－3－7－9－10－5－8－4－2。将这17位数字和系数相乘的结果相加。
                
                int S = [idCardNumber safeSubstringWithRange:NSMakeRange(0,1)].intValue*7 + [idCardNumber safeSubstringWithRange:NSMakeRange(10,1)].intValue *7 + [idCardNumber safeSubstringWithRange:NSMakeRange(1,1)].intValue*9 + [idCardNumber safeSubstringWithRange:NSMakeRange(11,1)].intValue *9 + [idCardNumber safeSubstringWithRange:NSMakeRange(2,1)].intValue*10 + [idCardNumber safeSubstringWithRange:NSMakeRange(12,1)].intValue *10 + [idCardNumber safeSubstringWithRange:NSMakeRange(3,1)].intValue*5 + [idCardNumber safeSubstringWithRange:NSMakeRange(13,1)].intValue *5 + [idCardNumber safeSubstringWithRange:NSMakeRange(4,1)].intValue*8 + [idCardNumber safeSubstringWithRange:NSMakeRange(14,1)].intValue *8 + [idCardNumber safeSubstringWithRange:NSMakeRange(5,1)].intValue*4 + [idCardNumber safeSubstringWithRange:NSMakeRange(15,1)].intValue *4 + [idCardNumber safeSubstringWithRange:NSMakeRange(6,1)].intValue*2 + [idCardNumber safeSubstringWithRange:NSMakeRange(16,1)].intValue *2 + [idCardNumber safeSubstringWithRange:NSMakeRange(7,1)].intValue *1 + [idCardNumber safeSubstringWithRange:NSMakeRange(8,1)].intValue *6 + [idCardNumber safeSubstringWithRange:NSMakeRange(9,1)].intValue *3;
                
                //2：用加出来和除以11，看余数是多少？余数只可能有0－1－2－3－4－5－6－7－8－9－10这11个数字
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM safeSubstringWithRange:NSMakeRange(Y,1)];// 3：获取校验位
                
                NSString *lastStr = [idCardNumber safeSubstringWithRange:NSMakeRange(17,1)];
                
                DLog(@"%@",M);
                DLog(@"%@",[idCardNumber safeSubstringWithRange:NSMakeRange(17,1)]);
                //4：检测ID的校验位
                if ([lastStr isEqualToString:@"x"]) {
                    if ([M isEqualToString:@"X"]) {
                        return YES;
                    }else{
                        
                        return NO;
                    }
                }else{
                    
                    if ([M isEqualToString:[idCardNumber safeSubstringWithRange:NSMakeRange(17,1)]]) {
                        return YES;
                    }else {
                        return NO;
                    }
                    
                }
                
            }else {
                return NO;
            }
        default:
            return NO;
    }
}

#pragma mark - 小数点处理
- (NSString *)decimalFloat:(float)floatValue mode:(NSRoundingMode)mode scale:(NSInteger)scale{
    //NSRoundPlain,   四舍五入
        //NSRoundDown,    只舍不入
        //NSRoundUp,      只入不舍
        //NSRoundBankers  四舍六入, 中间值时, 取最近的,保持保留最后一位为偶数
        NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:mode scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        NSDecimalNumber *a;
        if (floatValue > 0) {
            a = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",floatValue]];
            NSDecimalNumber *b = [a decimalNumberByRoundingAccordingToBehavior:handler];
            return [NSString stringWithFormat:@"%@",b];
        }else{
            return @"0";
    //        switch (scale) {
    //            case 0:
    //                return @"0";
    //                break;
    //            case 1:
    //                return @"0.0";
    //                break;
    //            case 2:
    //                return @"0.00";
    //                break;
    //            case 3:
    //                return @"0.000";
    //                break;
    //            case 4:
    //                return @"0.0000";
    //                break;
    //            case 5:
    //                return @"0.00000";
    //                break;
    //
    //            default:
    //                return @"0.000000";
    //                break;
    //        }
        }
}

#pragma mark - 含有emoji表情的字符串处理
- (NSInteger)emojiLength{
    __block NSInteger length = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        length++;
    }];
    return length;
}

#pragma mark - 字符串转时间戳(毫秒)
- (NSTimeInterval)timeIntervalFromTimeStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *tempDate = [dateFormatter dateFromString:self];
    return [tempDate timeIntervalSince1970] * 1000;//毫秒级
}
#pragma mark - 判断是否是同一天
+ (BOOL)compareIsSameDayDate:(NSDate *)date{

    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    
    NSDate *today = [[NSDate alloc] init];
    
    NSDate *tomorrow, *yesterday;

    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];

    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];

    NSString * dateString = [[date description] substringToIndex:10];

    if ([dateString isEqualToString:todayString]) {
        //今天
        return YES;
    } else if ([dateString isEqualToString:yesterdayString]) {
        //昨天
        return NO;
    }else if ([dateString isEqualToString:tomorrowString]) {
        //明天
        return NO;
    }else {
        //别的天
        return NO;
    }
}

#pragma mark - 加密 32位小写
- (NSString *)MD5Encryption {    
    const char *input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);

    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}

#pragma mark - 移除字符串中的特殊字符
+ (NSString *)stringReplaceSpecialCharacterWith:(NSString *)oldStr {
    if (oldStr.length > 0) {
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
        //由于NSString中有全角符号和半角符号, 因此有些符号要包括全角和半角的
        NSString *newStr = [oldStr stringByTrimmingCharactersInSet:set];
        return newStr;
    }else {
        return oldStr;
    }
}

#pragma mark - 禁言时长，分钟 -> 小时、天、永久禁言
+ (NSString *)convertBannedSendMsgTime:(int64_t)minit {
    NSString *resultStr = @"";
    switch (minit) {
        case 10:
            resultStr = LanguageToolMatch(@"禁言10分钟");
            break;
        case 60:
            resultStr = LanguageToolMatch(@"禁言1小时");
            break;
        case 720:
            resultStr = LanguageToolMatch(@"禁言12小时");
            break;
        case 1440:
            resultStr = LanguageToolMatch(@"禁言24小时");
            break;
        case 10080:
            resultStr = LanguageToolMatch(@"禁言7天");
            break;
        case 43200:
            resultStr = LanguageToolMatch(@"禁言30天");
            break;
        case -1:
            resultStr = LanguageToolMatch(@"禁言");
            break;
            
        default:
            break;
    }
    
    return resultStr;
}

#pragma mark - 获取表情富文本
/*
- (NSMutableAttributedString *)getEmotionString {
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSDictionary *a = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
    //表情
    NSMutableAttributedString *att = [[WZMEmoticonManager manager] attributedString:self.length > 0 ? self : @"未知内容"];
    [att addAttributes:a range:NSMakeRange(0, att.length)];
    return att;
}
*/

#pragma mark - 获得其他功能图片路径
+ (NSString *)getSaveImagePath:(UIImage *)image ImgName:(NSString *)imgName {
    NSString *imagePath;
    NSString *imageName = imgName;
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        imageData = UIImageJPEGRepresentation(image, 1);
        imagePath = [NSString stringWithFormat:@"OpenIM/Image/%@.jpg", imageName];
    }else {
        imagePath = [NSString stringWithFormat:@"OpenIM/Image/%@.png", imageName];
    }
    
    //图片存储到沙盒 Temp/OpenIM/Image/xxx/000.png
    BOOL fieldOK = [self createTempOpenIMFieldWithType:[NSString stringWithFormat:@"Image"]];
    if (fieldOK) {
        //存储
        NSString *pathStr = [NSTemporaryDirectory() stringByAppendingPathComponent:imagePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isSaved = [fileManager createFileAtPath:pathStr contents:imageData attributes:nil];
        if (isSaved) {
            return imagePath;
        }else {
            return nil;
        }
    }else {
        return nil;
    }
}

#pragma mark - 图片/视频/语音/文件 存储到沙盒Temp/OpenIM文件下
// 将图片存储到本地沙盒
+ (void)saveImageToSaxboxWithData:(NSData *)imgData CustomPath:(NSString *)customPath ImgName:(NSString *)imgName {
    NSString *imagePath = [NSString stringWithFormat:@"OpenIM/Image/%@/%@", customPath, imgName];
    //图片存储到沙盒 Temp/OpenIM/Image/xxx/xxx
    BOOL fieldOK = [self createTempOpenIMFieldWithType:[NSString stringWithFormat:@"Image/%@",customPath]];
    if (fieldOK) {
        //存储
        NSString *pathStr = [NSTemporaryDirectory() stringByAppendingPathComponent:imagePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isSaved = [fileManager createFileAtPath:pathStr contents:imgData attributes:nil];
        if (isSaved) {
            NSLog(@"图片保存到沙盒成功");
        } else {
            NSLog(@"图片保存到沙盒失败");
        }
    } else {
        NSLog(@"创建沙盒图片目录失败");
    }
}

//获取本地图片
+ (UIImage *)getImageWithImgName:(NSString *)imgName CustomPath:(NSString *)customPath {
    NSString *imagePath = [NSString stringWithFormat:@"OpenIM/Image/%@/%@", customPath, imgName];
    NSString *pathStr = [NSTemporaryDirectory() stringByAppendingPathComponent:imagePath];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathStr];
    return image;
}

//获取本地图片沙盒路径
+ (NSString *)getPathWithImageName:(NSString *)imgName CustomPath:(NSString *)customPath {
    NSString *imagePath;
    imagePath = [NSString stringWithFormat:@"OpenIM/Image/%@/%@", customPath, imgName];
    NSString *pathStr = [NSTemporaryDirectory() stringByAppendingPathComponent:imagePath];
    return pathStr;
}

//保存视频文件到本地沙盒
+ (void)saveVideoToSaxboxWithData:(NSData *)videoData CustomPath:(NSString *)customPath VideoName:(NSString *)videoName{
    NSString *videoPath = [NSString stringWithFormat:@"OpenIM/Video/%@/%@", customPath, videoName];
    //视频存储到沙盒 Temp/OpenIM/Video/xxx/xxx
    BOOL fieldOK = [self createTempOpenIMFieldWithType:[NSString stringWithFormat:@"Video/%@",customPath]];
    if (fieldOK) {
        //存储
        NSString *pathStr = [NSTemporaryDirectory() stringByAppendingPathComponent:videoPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isSaved = [fileManager createFileAtPath:pathStr contents:videoData attributes:nil];
        if (isSaved) {
            NSLog(@"视频保存到沙盒成功");
        }else {
            NSLog(@"视频保存到沙盒失败");
        }
    }else {
        NSLog(@"创建沙盒视频目录失败");
    }
}

//获取本地视频沙盒路径
+ (NSString *)getPathWithVideoName:(NSString *)videoName CustomPath:(NSString *)customPath {
    NSString *videoPath;
    videoPath = [NSString stringWithFormat:@"OpenIM/Video/%@/%@", customPath, videoName];
    NSString *pathStr = [NSTemporaryDirectory() stringByAppendingPathComponent:videoPath];
    return pathStr;
}

//获取本地视频data
+ (NSData *)getVideoDataWithVideoName:(NSString *)videoName CustomPath:(NSString *)customPath {
    NSString *imagePath;
    imagePath = [NSString stringWithFormat:@"OpenIM/Video/%@/%@", customPath, videoName];
    NSString *pathStr = [NSTemporaryDirectory() stringByAppendingPathComponent:imagePath];
    NSData *data = [NSData dataWithContentsOfFile:pathStr options:NSDataReadingMappedIfSafe error:nil];
    return data;
}

//获取保存语音路径
+ (NSString *)getVoiceDiectoryWithCustomPath:(NSString *)customPath {
    NSString *videoPath = [NSString stringWithFormat:@"OpenIM/Voice/%@", customPath];
    NSString *diectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoPath];
    BOOL fieldOK = [self createTempOpenIMFieldWithType:[NSString stringWithFormat:@"Voice/%@",customPath]];
    if (fieldOK) {
        return diectoryPath;
    } else {
        return nil;
    }
}

//保存file文件到本地沙盒
+ (void)saveFileToSaxboxWithData:(NSData *)fileData CustomPath:(NSString *)customPath fileName:(NSString *)fileName {
    NSString *filePath = [NSString stringWithFormat:@"OpenIM/File/%@/%@", customPath, fileName];
    //存储到沙盒 Temp/OpenIM/File/xxx/xxx
    BOOL fieldOK = [self createTempOpenIMFieldWithType:[NSString stringWithFormat:@"File/%@",customPath]];
    if (fieldOK) {
        //存储
        NSString *pathStr = [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isSaved = [fileManager createFileAtPath:pathStr contents:fileData attributes:nil];
        if (isSaved) {
            NSLog(@"文件保存到沙盒成功");
        } else {
            NSLog(@"文件保存到沙盒失败");
        }
    }else {
        NSLog(@"创建沙盒文件目录失败");
    }
}

//获取本地文件地址
+ (NSString *)getPathWithFileName:(NSString *)fileName CustomPath:(NSString *)customPath {
    NSString *filePath = [NSString stringWithFormat:@"OpenIM/File/%@/%@", customPath, fileName];
    NSString *pathStr = [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
    return pathStr;
}

//获取已保存文件的目录路径
+ (NSString *)getFileDiectoryWithCustomPath:(NSString *)customPath {
    NSString *filePath = [NSString stringWithFormat:@"OpenIM/File/%@", customPath];
    NSString *diectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
    BOOL fieldOK = [self createTempOpenIMFieldWithType:[NSString stringWithFormat:@"File/%@",customPath]];
    if (fieldOK) {
        return diectoryPath;
    } else {
        return nil;
    }
}

//获取收藏消息中保存文件路径
+ (NSString *)getCollcetionMessageFileDiectoryPath {
    NSString *filePath = @"OpenIM/File/Collection";
    NSString *diectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
    BOOL fieldOK = [self createTempOpenIMFieldWithType:@"File/Collection"];
    if (fieldOK) {
        return diectoryPath;
    } else {
        return nil;
    }
}

+ (BOOL)createTempOpenIMFieldWithType:(NSString *)fieldType {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"OpenIM/%@",fieldType]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    //fileExistsAtPath 判断一个文件或目录是否有效，isDirectory 判断是否一个目录
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir)) {
        //创建目录
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            //失败
            return NO;
        }else {
            DLog(@"创建文件夹成功，文件路径%@",path);
            //成功
            return YES;
        }
    }
    return YES;
}

+ (NSString *)createSavedFileName {
    //根据时间戳和随机内容创建上传文件名称
    NSDate *currentDate = [NSDate date];
    NSString *dateStr = [NSString stringWithFormat:@"%@_",[currentDate dateForFileName]];
    NSMutableString *scopeString = [[NSMutableString alloc] initWithString:dateStr];
    
    NSString *scope = @"0123456789abcdefghijklmnopqrstuvwxyz";
    
    for (NSInteger i = 0; i < 20; i++) {
        NSInteger index = arc4random() % scope.length;
        [scopeString appendString:[NSString stringWithFormat:@"%@",[scope safeSubstringWithRange:NSMakeRange(index, 1)]]];
    }
    //000-00-00-00-00-00_0123
    return scopeString;
}

#pragma mark - 获得存储https请求自签证书的密码
+ (NSString *)getHttpsCerPassword {
    NSString *cerPassword;
    if (ZHostTool.racingType == ZReacingTypeCompanyId) {
        cerPassword = [NSString stringWithFormat:@"%@%@", Z_COMPANY_ID_IP_CER_PASSWORD, ZHostTool.ossInfoAppKey];
    }
    if (ZHostTool.racingType == ZReacingTypeIpDomain) {
        cerPassword = [NSString stringWithFormat:@"%@", Z_HTTPS_IP_CER_PASSWORD];
    }
    return cerPassword;
}

#pragma mark - 上传图片名称
+ (NSString *)uploadImageName:(UIImage *)image {
    NSString *imageName = [NSString createSavedFileName];
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        imageName = [imageName stringByAppendingString:@".jpg"];
    }else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return imageName;
}


#pragma mark - 将数组转换成json格式字符串
+ (NSString *)jsonStringFromArray:(NSArray *)array {

    if (![array isKindOfClass:[NSArray class]] || ![NSJSONSerialization isValidJSONObject:array]) {
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return strJson;

}

#pragma mark - 将字典转换成json字符串
+ (NSString *)jsonStringFromDic:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString*jsonString;
    if(!jsonData) {
        DLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //去掉字符串中的换行符
    NSRange range = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    
    return mutStr;
}

#pragma mark - 将json字符串转换成字典
+ (NSDictionary *)jsonStringToDic:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    if ([jsonString isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)jsonString;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                            error:&err];
    if(err)
    {
        DLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - 获取时间格式
+ (NSString *)timeStringForPastTimeDate:(long long)timeValue {
    
    //当前时间戳
    NSDate *dateNow = [NSDate date];
    long long timeInterval = [dateNow timeIntervalSince1970] * 1000;//毫秒
    
    //时间差(秒)
    long long second = (timeInterval - timeValue) / 1000;

    if (second <= 60 * 15) {
        return LanguageToolMatch(@"刚刚");
    }else{
        NSInteger minute = second / 60;
        if (minute < 60) {
            return [NSString stringWithFormat:LanguageToolMatch(@"%ld分钟以前"),minute];
        }else{
            NSInteger hour = second / 3600;
            if (hour < 24) {
                return [NSString stringWithFormat:LanguageToolMatch(@"%ld小时以前"),hour];
            }else{
                NSInteger day = second / (3600 * 24);
                if (day < 2) {
                    return [NSString stringWithFormat:LanguageToolMatch(@"昨天%@"),[self dateStringFromTimeValue:timeValue formatter:@"HH:mm"]];
                }else{
                    NSInteger month = second / (3600 * 24 * 30);
                    if (month < 12) {
                        return [self dateStringFromTimeValue:timeValue formatter:@"MM-dd"];
                    }else{
                        return [self dateStringFromTimeValue:timeValue formatter:@"yyyy-MM-dd"];
                    }
                }
            }
            
        }
    }
    return @"";
}

#pragma mark - 获取指定时间间隔格式(单位:秒)(24小时，一年，一年以上)
+ (NSString *)timeIntervalStringWith:(long long)startTimeValue {
    //开始时间
    NSDate *dateStart = [NSDate dateWithTimeIntervalSince1970:startTimeValue];
    //当前时间
    NSDate *dateNow = [NSDate date];
    
    //利用NSCalendar比较日期的差异
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    /**
     * 要比较的时间单位,常用如下,可以同时传：
     *
     *    NSCalendarUnitDay : 天
     *    NSCalendarUnitYear : 年
     *    NSCalendarUnitMonth : 月
     *    NSCalendarUnitHour : 时
     *    NSCalendarUnitMinute : 分
     *    NSCalendarUnitSecond : 秒
     *    NSCalendarUnitWeekdayOrdinal : 星期
     */

    //按天计算
    NSCalendarUnit unitDay = NSCalendarUnitDay;
    //比较的结果是NSDateComponents类对象
    NSDateComponents *dateDay = [calendar components:unitDay fromDate:dateStart toDate:dateNow options:0];
    
    if (dateDay.day < 1) {
        //24小时内
        BOOL sameToday = [NSString compareIsSameDayDate:dateStart];
        if (sameToday) {
            return [NSString dateStringFromTimeValue:startTimeValue * 1000 formatter:@"HH:mm"];
        }else {
            return [NSString dateStringFromTimeValue:startTimeValue * 1000 formatter:@"MM/dd"];
        }
    }else {
        //按年计算
        NSCalendarUnit unitYear = NSCalendarUnitYear;//只比较天数差异
        NSDateComponents *dateYear = [calendar components:unitYear fromDate:dateStart toDate:dateNow options:0];
        if (dateYear.year <= 1) {
            //一年之内
            return [NSString dateStringFromTimeValue:startTimeValue * 1000 formatter:@"MM/dd"];
        }else {
            return [NSString dateStringFromTimeValue:startTimeValue * 1000 formatter:@"yyyy/MM/dd"];
        }
    }
//    //打印
//    NSLog(@"%@",dateDay);
//    //获取其中的"天"
//    NSLog(@"day: %ld",dateDay.day);
//    NSLog(@"era: %ld",dateDay.era);
//    NSLog(@"year: %ld",dateDay.year);
//    NSLog(@"month: %ld",dateDay.month);
//    NSLog(@"hour: %ld",dateDay.hour);
//    NSLog(@"minute: %ld",dateDay.minute);
//    NSLog(@"second: %ld",dateDay.second);
//    NSLog(@"weekday: %ld",dateDay.weekday);
//    NSLog(@"weekdayOrdinal: %ld",dateDay.weekdayOrdinal);
    return @"";
}


#pragma mark - 时间戳转字符串
+ (NSString *)dateStringFromTimeValue:(long long)timeValue formatter:(nonnull NSString *)formatter{
    //将时间戳转换为日期对象
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeValue / 1000];
    
    //设置要转换的日期格式
    //NSString *dateFormatter = @"yyyy-MM-dd HH:mm";
    //HH:mm:ss：表示24小时制
    //hh:mm:ss：表示12小时制
    
    //初始化NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置时区
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    //设置日期格式
    [dateFormatter setDateFormat:formatter];
    //获取转换后的结果
    NSString *rest = [dateFormatter stringFromDate:date];
    return rest;
}

#pragma mark - 时间字符串 转 时间戳
+(long long)dateFromTimeDate:(NSString *)formatTime formatter:(NSString *)format {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];//当前时区
    //[NSTimeZone timeZoneWithName:@"Asia/Beijing"];//北京时区
    [formatter setTimeZone:timeZone];
    NSDate *date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    long long timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] longLongValue] * 1000;
    return timeSp;
}

#pragma mark - 2-20个字 中英文、数字
- (BOOL)checkNickname {
    NSString *nicknameStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //2-20 汉字字母数字
    NSString *regex = @"^[a-zA-Z0-9\u4e00-\u9fa5]{2,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:nicknameStr];
    //YES符合
}

#pragma mark - 正则获取指定内容
- (NSString* )getRegExpressResultWithRegExp:(NSString*)regExp {
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExp options: NSRegularExpressionCaseInsensitive error:nil];
    if(regex != nil){
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:self options:0 range: NSMakeRange(0, [self length])];
        if(firstMatch){
            NSRange resultRange = [firstMatch rangeAtIndex: 0];
            // 截取数据
            NSString *result = [self safeSubstringWithRange:resultRange];
            return result;
        }
    }
    return @"";
}

#pragma mark - 计算字节长度 视中文为2个字节，英文为1个字节
- (NSInteger)calculateStringLenght {
    NSInteger strLength = 0;
    
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
      char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    
      for (int i=0 ; i<[self lengthOfBytesUsingEncoding:encoding] ;i++) {
          
          if (*p) {
              p++;
              strLength++;
          } else {
              p++;
          }
           
      }
      return strLength;
}
#pragma mark - 截取指定长度字节
- (NSString *)subStringWith:(NSInteger)length {
    if (self.length < length) {
        return self;
    }
    
    NSInteger count = 0;
    NSMutableString *str = [NSMutableString string];
    for (NSInteger i = 0; i < self.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *aStr = [str safeSubstringWithRange:range];
        count += [aStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 1 ? 2 : 1;
        [str appendString:aStr];
        if (count >= length * 2) {
            return (i == self.length - 1) ? [str copy] : [NSString stringWithFormat:@"%@...",[str copy]];
        }
    }
    return self;
}

//计算字符串Size
- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
    NSMutableDictionary *attr = [NSMutableDictionary new];
    attr[NSFontAttributeName] = font;
    if (lineBreakMode != NSLineBreakByWordWrapping) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = lineBreakMode;
        attr[NSParagraphStyleAttributeName] = paragraphStyle;
    }
    CGRect rect = [self boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attr context:nil];
    result = rect.size;
    } else {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
    #pragma clang diagnostic pop
    }
    return result;
}

#pragma mark - 获取字符串宽度
- (CGFloat)widthForFont:(UIFont *)font {
    CGSize size = [self sizeForFont:font size:CGSizeMake(MAXFLOAT, MAXFLOAT) mode:NSLineBreakByWordWrapping];
    return size.width;
}

#pragma mark - 获取指定宽度字符串的高度
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self sizeForFont:font size:CGSizeMake(width, MAXFLOAT) mode:NSLineBreakByWordWrapping];
    return size.height;
}

#pragma mark - 获得时长00:00
+ (NSString *)getTimeLength:(NSInteger)time{
    NSInteger minute = time / 60;
    NSInteger second = (time - minute * 60);
    return [NSString stringWithFormat:@"%02ld:%02ld",minute,second];
}

#pragma mark - 获得时长00:00:00
+ (NSString *)getTimeLengthHMS:(NSInteger)second{
    NSInteger aSecond = second;
    
    NSInteger aMinute = 0;
    NSInteger aHour = 0;
    
    NSString *secondStr = @"";
    NSString *minuteStr = @"";
    NSString *hourStr = @"";
    
    aHour = second/3600;
    aMinute = (second - aHour * 3600)/60;
    aSecond = second - aHour * 3600 - aMinute * 60;
    
    if (aHour < 10) {
        hourStr = [NSString stringWithFormat:@"0%ld",(long)aHour];
    }else{
        hourStr = [NSString stringWithFormat:@"%ld",(long)aHour];
    }
    
    if (aMinute < 10) {
        minuteStr = [NSString stringWithFormat:@"0%ld",(long)aMinute];
    }else{
        minuteStr = [NSString stringWithFormat:@"%ld",(long)aMinute];
    }
    
    if (aSecond < 10) {
        secondStr = [NSString stringWithFormat:@"0%ld",(long)aSecond];
    }else{
        secondStr = [NSString stringWithFormat:@"%ld",(long)aSecond];
    }
    
    if (aHour > 0) {
        return [NSString stringWithFormat:@"%@:%@:%@",hourStr,minuteStr,secondStr];
    }else {
        return [NSString stringWithFormat:@"%@:%@",minuteStr,secondStr];
    }
    
}

#pragma mark - 按照指定要求展示群名称/昵称
+ (NSString *)showAppointWidith:(CGFloat)maxWidth sessionName:(NSString *)sessionName peopleNum:(NSString *)peopleNum {
    NSString *sessonTitleStr;
    //人数
    NSString *peopleNumStr = @"";
    CGFloat peopleNumWidth = 0;
    if (![NSString isNil:peopleNum]) {
        peopleNumStr = [NSString stringWithFormat:@"(%@)", peopleNum];
        peopleNumWidth = [peopleNumStr widthForFont:FONTB(16)];
    }
    
    CGFloat nameWidth = maxWidth - peopleNumWidth - 10;
    //名称
    NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
    p.lineBreakMode = NSLineBreakByCharWrapping;
   
    NSAttributedString *namesAtt = [[NSAttributedString alloc] initWithString:sessionName.length > 0 ? sessionName : @"" attributes:@{NSFontAttributeName:FONTB(16), NSParagraphStyleAttributeName:p}];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)namesAtt);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, nameWidth, FONTB(16).lineHeight + 1.0)];
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, sessionName.length), path.CGPath, NULL);
   
    CFRange range = CTFrameGetVisibleStringRange(frame);
    CFRelease(framesetter);
    CFRelease(frame);
    NSString *resultStr = [sessionName safeSubstringWithRange:NSMakeRange(range.location, range.length)];
    if (resultStr.length < sessionName.length && resultStr.length > 0) {
        resultStr = [resultStr stringByReplacingCharactersInRange:NSMakeRange(resultStr.length - 1, 1) withString:@"..."];
    }
    

    sessonTitleStr = [NSString stringWithFormat:@"%@%@", resultStr, peopleNumStr];
    return sessonTitleStr;
}

#pragma mark -- 自己添加
+ (NSString *)sizeFormattedWithSize:(NSInteger)size {
    NSString *sizeString = @"";
    if (size == 0) {
        sizeString = LanguageToolMatch(@"文件过小");
    }else if (size < 1024.0 && size > 0) {
        sizeString = [NSString stringWithFormat:@"%.1fB",(float)size];
    }else if (size < 1024.0 * 1024 && size >= 1024.0){
        sizeString = [NSString stringWithFormat:@"%.1fKB",(float)size/1024.0];
    }else if(size < 1024.0 * 1024 * 1024 && size >= 1024.0 * 1024){
        sizeString = [NSString stringWithFormat:@"%.1fMB",(float)size/1024/1024.0];
    }else{
        sizeString = LanguageToolMatch(@"文件过大");
    }
    return sizeString;
}

#pragma mark - 转换文件大小的单位
+ (NSString *)fileTranslateToSize:(float)size {
    NSString *resultSize;
    if (size < 1024) { //小于1k
        resultSize = [NSString stringWithFormat:@"%ldB",(long)size];
    } else if (size < 1024.0 * 1024) { //小于1M
        CGFloat cFloat = size / 1024.0;
        resultSize = [NSString stringWithFormat:@"%.1fKB",cFloat];
    } else if (size < 1024.0 * 1024 * 1024) { //小于1G
        CGFloat cFloat = size / (1024.0 * 1024);
        resultSize = [NSString stringWithFormat:@"%.1fMB",cFloat];
    } else { //大于1G
        CGFloat cFloat = size / (1024.0 * 1024 * 1024);
        resultSize = [NSString stringWithFormat:@"%.1fGB",cFloat];
    }
    return resultSize;
}

#pragma mark - 通过目标路径的文件获取该文件上传时的mimeType类型
+ (NSString *)fileTranslateToMimeTypeWithPath:(NSString *)filePath {
    NSString *mimeType;
    if (![[[NSFileManager alloc] init] fileExistsAtPath:filePath]) {
        mimeType = @"";
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[filePath pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        mimeType = @"";
    } else {
        mimeType = (__bridge NSString *)(MIMEType);
    }
    return mimeType;
}

#pragma mark - 通过目标路径的文件获取该文件的格式
+ (NSString *)fileTranslateToTypeWithPath:(NSString *)filePath {
    NSString *mimeType;
    if (![[[NSFileManager alloc] init] fileExistsAtPath:filePath]) {
        mimeType = @"";
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[filePath pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        mimeType = @"";
    } else {
        mimeType = (__bridge NSString *)(MIMEType);
    }
    
    NSString *type;
    if (![NSString isNil:mimeType]) {
        NSArray *typeArr = [mimeType componentsSeparatedByString:@"/"];
        type = (NSString *)[typeArr lastObject];
    }
    return type;
}

#pragma mark - 通过目标路径下本地文件获取该文件的文件类型
+ (NSString *)fileTranslateToFileType:(NSString *)filePath {
    NSString *mimeType;
    if (![[[NSFileManager alloc] init] fileExistsAtPath:filePath]) {
        mimeType = @"";
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[filePath pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        mimeType = @"";
    } else {
        mimeType = (__bridge NSString *)(MIMEType);
    }
    
    NSString *fileType;
    if (![NSString isNil:mimeType]) {
        NSString *fileTypeDicPath = [[NSBundle mainBundle] pathForResource:@"NoaMineToFile" ofType:@"plist"];
        NSDictionary *fileTypeDic = [NSDictionary dictionaryWithContentsOfFile:fileTypeDicPath];
        if ([[fileTypeDic allKeys] containsObject:mimeType]) {
            fileType = [fileTypeDic objectForKey:mimeType];
        } else {
            fileType = @"unknow";
        }
    } else {
        fileType = @"unknow";
    }
    return fileType;
}

#pragma mark - 通过返回数据里文件消息的文件类型，展示不同的图标里的文件类型
+ (NSString *)getFileTypeContentWithFileType:(NSString *)fileType fileName:(NSString *)fileName {
    NSString *currentType = @"";
    if (![NSString isNil:fileType]) {
        currentType = fileType;
        if ([fileType isEqualToString:@"unknow"]) {
            if ([fileName containsString:@"."]) {
                NSArray *fileNameArr = [fileName componentsSeparatedByString:@"."];
                currentType = (NSString *)[fileNameArr lastObject];
            }
        }
    } else {
        if ([fileName containsString:@"."]) {
            NSArray *fileNameArr = [fileName componentsSeparatedByString:@"."];
            currentType = (NSString *)[fileNameArr lastObject];
        }
    }
    NSString *typeContent;
    if ([currentType isEqualToString:@"doc"] || [currentType isEqualToString:@"DOC"] ) {
        typeContent = @"DOC";
    } else if ([currentType isEqualToString:@"docx"] || [currentType isEqualToString:@"DOCX"]) {
        typeContent = @"DOCX";
    } else if ([currentType isEqualToString:@"xls"] || [currentType isEqualToString:@"XLS"]) {
        typeContent = @"XLS";
    } else if ([currentType isEqualToString:@"xlsx"] || [currentType isEqualToString:@"XLSX"]) {
        typeContent = @"XLSX";
    } else if ([currentType isEqualToString:@"ppt"] || [currentType isEqualToString:@"PPT"]) {
        typeContent = @"PPT";
    } else if ([currentType isEqualToString:@"pptx"] || [currentType isEqualToString:@"PPTX"]) {
        typeContent = @"PPTX";
    } else if ([currentType isEqualToString:@"zip"] || [currentType isEqualToString:@"ZIP"]) {
        typeContent = @"ZIP";
    } else if ([currentType isEqualToString:@"rar"] || [currentType isEqualToString:@"RAR"]) {
        typeContent = @"RAR";
    } else if ([currentType isEqualToString:@"txt"] || [currentType isEqualToString:@"TXT"]) {
        typeContent = @"TXT";
    } else if ([currentType isEqualToString:@"pdf"] || [currentType isEqualToString:@"PDF"]) {
        typeContent = @"PDF";
    } else if ([currentType isEqualToString:@"mp4"] || [currentType isEqualToString:@"MP4"]) {
        typeContent = @"MP4";
    } else if ([currentType isEqualToString:@"mov"] || [currentType isEqualToString:@"MOV"]) {
        typeContent = @"MOV";
    } else if ([currentType isEqualToString:@"avi"] || [currentType isEqualToString:@"AVI"]) {
        typeContent = @"AVI";
    } else if ([currentType isEqualToString:@"flv"] || [currentType isEqualToString:@"FLV"]) {
        typeContent = @"FLV";
    } else if ([currentType isEqualToString:@"RM"] || [currentType isEqualToString:@"rm"]) {
        typeContent = @"RM";
    } else if ([currentType isEqualToString:@"RMVB"] || [currentType isEqualToString:@"rmvb"]) {
        typeContent = @"RMVB";
    } else if ([currentType isEqualToString:@"MKV"] || [currentType isEqualToString:@"mkv"]) {
        typeContent = @"MKV";
    } else if ([currentType isEqualToString:@"WMV"] || [currentType isEqualToString:@"wmv"]) {
        typeContent = @"WMV";
    } else if ([currentType isEqualToString:@"png"] || [currentType isEqualToString:@"PNG"]) {
        typeContent = @"PNG";
    } else if ([currentType isEqualToString:@"jpeg"] || [currentType isEqualToString:@"JPEG"]) {
        typeContent = @"JPEG";
    } else {
        typeContent = @"?";
    }
    return typeContent;
}

#pragma mark - 获得apiHost完整的加载地址
- (NSURL *)getApiHostFullUrl {
    if ([self hasPrefix:@"http"]) {
        //http开头认为是完整的地址
        return [self imageUrlEncode];
    }else {
        //拼接出完整的地址
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",ZHostTool.apiHost, self];
        return [imageUrl imageUrlEncode];
    }
}

#pragma mark - 获得图片完整的加载地址
- (NSURL *)getImageFullUrl {
    if ([self hasPrefix:@"http"]) {
        //http开头认为是完整的地址
        return [self imageUrlEncode];
    }else {
        //拼接出完整的地址
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",ZHostTool.getFileHost, self];
        return [imageUrl imageUrlEncode];
    }
}

#pragma mark - 获得图片完整的加载地址
- (NSString *)getImageFullString {
    if ([self hasPrefix:@"http"]) {
        //http开头认为是完整的地址
        return self;
    }else {
        //拼接出完整的地址
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",ZHostTool.getFileHost, self];
        return imageUrl;
    }
}

#pragma mark - 通过注册/登录的类型值返回类型的文本
+ (NSString *)getAuthContetnWithAuthType:(int)authType {
    switch (authType) {
        case UserAuthTypePhone:
            return LanguageToolMatch(@"手机号");
            break;
        case UserAuthTypeEmail:
            return LanguageToolMatch(@"邮箱");
            break;
        case UserAuthTypeAccount:
            return LanguageToolMatch(@"账号");
            break;
            
        default:
            break;
    }
    return @"";
}

#pragma mark - 通过注册/登录的类型值返回类型的文本
+ (NSString *)getAuthCodeWithAuthType:(int)authType {
    switch (authType) {
        case UserAuthTypePhone:
            return LanguageToolMatch(@"50001");
            break;
        case UserAuthTypeEmail:
            return LanguageToolMatch(@"50000");
            break;
        case UserAuthTypeAccount:
            return LanguageToolMatch(@"2036");
            break;
            
        default:
            break;
    }
    return @"";
}



#pragma mark - 加载用户头像逻辑：先判断用户是否注销，如果注销显示注销头像，如果未注销，显示真实头像、
+ (NSString *)loadAvatarWithUserStatus:(NSInteger)userStatus avatarUri:(NSString *)avatarUri {
    if (userStatus == 4) {
        //账号已注销
        return @"user_accout_delete_avatar.png";
    } else {
        NSString *avatarUrl = [avatarUri getImageFullString];
        return avatarUrl;
    }
}


#pragma mark - 加载用户昵称逻辑：先判断用户是否注销，如果注销显示账号已注销，如果未注销，显示真实昵称、
+ (NSString *)loadNickNameWithUserStatus:(NSInteger)userStatus realNickName:(NSString *)realNickName {
    if (userStatus == 4) {
        //已注销
        return LanguageToolMatch(@"账号已注销");
    } else {
        return realNickName;
    }
}

#pragma mark -  汉字转拼音
+ (NSString *)chineseTransformPinYinWith:(NSString *)chineseCharacters {
    if (![NSString isNil:chineseCharacters]) {
//        CFStringRef hanzi = (__bridge CFStringRef)(chineseCharacters);
//
//        CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, hanzi);
//
//        // Boolean CFStringTransform(CFMutableStringRef string, CFRange *range, CFStringRef transform, Boolean reverse);
//        //string 为要转换的字符串
//        // range 要转换的范围，NULL 则为全部
//        //transform 要进行怎么样的转换    //kCFStringTransformMandarinLatin 将汉字转拼音
//        //reverse 是否支持逆向转换
//        CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);
//
//        //kCFStringTransformStripDiacritics去掉声调
//        CFStringTransform(string, NULL, kCFStringTransformStripDiacritics, NO);
//
//        NSString * pinyin = (NSString *) CFBridgingRelease(string);
//        //将中间分隔符号去掉
//        pinyin = [pinyin stringByReplacingOccurrencesOfString:@" " withString: @""];
//
//        return pinyin;
        
        //转成可变字符串
        NSMutableString *mutString = [NSMutableString stringWithString:chineseCharacters];
        //先转换为带声调的拼音
        CFStringTransform((CFMutableStringRef)mutString, NULL, kCFStringTransformToLatin, false);
        //再转换为不带声调的拼音
        CFStringTransform((CFMutableStringRef)mutString, NULL, kCFStringTransformStripDiacritics, false);
        
        //NSLog(@"汉字转拼音：tempStr1 == %@", mutString);  // ni hao
        //mutString = (NSMutableString *)mutString.uppercaseString;
        //NSLog(@"小写转大写：tempStr1 == %@", mutString);  // NI HAO
        //mutString = (NSMutableString *)mutString.lowercaseString;
        //NSLog(@"大写转小写：tempStr1 == %@", mutString);  // ni hao
        
        return (NSMutableString *)mutString.lowercaseString;//小写
        
    }else {
        return @"";
    }
}

#pragma mark - 获取字符串中的网址
- (NSArray *)getUrlFromString {
    NSError *error;
     //可以识别url的正则表达式
     NSString *regulaStr =  @"(?:(https?|ftps?|sftp|smtp|imap|pop3|ldaps?|telnet|ssh|git|rsync|wss?):\\/\\/)?((([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,}|localhost)|((\\d{1,3}\\.){3}\\d{1,3})|(\\[[0-9a-fA-F:]+\\]))(:\\d+)?(\\/[\\S]*)?";
     NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
     options:NSRegularExpressionCaseInsensitive
     error:&error];

     NSArray *arrayOfAllMatches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];

     NSMutableArray *arr = [[NSMutableArray alloc] init];

     for (NSTextCheckingResult *match in arrayOfAllMatches){
         NSString *substringForMatch;
         substringForMatch = [self safeSubstringWithRange:match.range];
         [arr addObject:substringForMatch];
     }
    
    return arr;
}

-(BOOL)checkStringIsUrl{
    NSString *regexPattern = @"(?:(https?|ftps?|sftp|smtp|imap|pop3|ldaps?|telnet|ssh|git|rsync|wss?):\\/\\/)?((([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,}|localhost)|((\\d{1,3}\\.){3}\\d{1,3})|(\\[[0-9a-fA-F:]+\\]))(:\\d+)?(\\/[\\S]*)?";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexPattern];
    BOOL isMatch = [predicate evaluateWithObject:self];
    return isMatch;
}

#pragma mark - 邀请码只能输入：纯小写字母 或 纯数字 或 小写字母+数字
- (BOOL)inputLiceseIdCheck {
    //校验是否为纯小写字母
    NSString *letterRegex = @"^[a-z]+$";//纯小写字母
    NSPredicate *letterPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", letterRegex];
    BOOL letterResult = [letterPredicate evaluateWithObject:self];
    
    NSString *figureRegex = @"^[0-9]*$";//纯数字
    NSPredicate *figurePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", figureRegex];
    BOOL figureResult = [figurePredicate evaluateWithObject:self];
    
    NSString *letterFigureRegex = @"^[a-z0-9]+$";//小写字母+数字
    NSPredicate *letterFigurePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", letterFigureRegex];
    BOOL letterFigureResult = [letterFigurePredicate evaluateWithObject:self];
   
    if (letterResult == NO &&  figureResult == NO && letterFigureResult == NO) {
        return NO;
    }
    return YES;
}

#pragma mark - 检测url地址是否为IP地址
- (BOOL)checkUrlIsIPAddress {
    BOOL isIPAddress = NO;
    
    NSString *urlStr = [NSMutableString stringWithString:self];
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    
    if ([urlStr containsString:@":"]) {
        NSRange portRang = [urlStr rangeOfString:@":"];
        urlStr = [urlStr safeSubstringWithRange:NSMakeRange(0, portRang.location)];
    }

    NSString *regex = @"^(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5]).(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5]).(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5]).(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    isIPAddress = [predicate evaluateWithObject:urlStr];
    
    return isIPAddress;
}

#pragma mark - 账号格式检测(修改账号功能)
//只能是 6-16位 字母+数字组合，前两位必须为字母
- (BOOL)checkUserAccountFormat {
    //校验是否为 6-16位
    if (self.length < 6 || self.length > 16) {
        return NO;
    }
    
    //校验是否为数字+字母组合
    NSString *formatRegex = @"^[a-zA-Z]+$|^[0-9]+$|^[a-zA-Z0-9]+$";//纯小写字母
    NSPredicate *formatPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", formatRegex];
    BOOL formatResult = [formatPredicate evaluateWithObject:self];
    
    //校验 前2位是否为字母
    NSString *topTwoStr = [self safeSubstringWithRange:NSMakeRange(0, 2)];
    NSString *topTwoRegex = @"^[A-Za-z]+$";//存字母
    NSPredicate *topTwoPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", topTwoRegex];
    BOOL topTwoResult = [topTwoPredicate evaluateWithObject:topTwoStr];

    if (formatResult == NO || topTwoResult == NO) {
        return NO;
    }
    return YES;
}

#pragma mark - 生成一个指定范围的随机整数
+ (NSString *)randomNumWithMin:(NSInteger)min max:(NSInteger)max {
    NSInteger randomNum = arc4random_uniform((uint32_t)(max - min + 1)) + min;
    return [NSString stringWithFormat:@"%ld", (long)randomNum];
}

#pragma mark - 获取当前设备的公网IP
+ (NSString *)getDevicePublicNetworkIP {
    // 当前公网ip
    NSArray *ipAPIs = @[
        //@"https://api.ipify.org",
        @"https://ipinfo.io/ip",
        @"https://checkip.amazonaws.com",
        @"http://checkip.amazonaws.com"
    ];

    // 使用锁来保证线程安全地访问共享变量ipStr
    NSLock *lock = [[NSLock alloc] init];
    __block NSString *ipStr = @"";
    __block NSInteger ipApiRequestNum = 0;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    for (NSString *apiUrlString in ipAPIs) {
        NSURL *url = [NSURL URLWithString:apiUrlString];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            ipApiRequestNum++;
            if (!error && data) {
                NSString *ipString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (ipString.length > 0) {
                    // 是合法IP格式，加锁后再赋值给ipStr，保证线程安全
                    [lock lock];
                    ipStr = ipString;
                    [lock unlock];
                }
                dispatch_semaphore_signal(semaphore);
            } else {
                if (ipApiRequestNum == ipAPIs.count) {
                    // 所有请求都失败时返回nil，让调用者决定如何处理
                    ipStr = @"";
                    dispatch_semaphore_signal(semaphore);
                }
            }
        }];
        [task resume];
    }
    // 设置超时时间，避免长时间阻塞导致类似死锁情况
    BOOL semaphoreWaitResult = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC))) == 0;
    if (!semaphoreWaitResult) {
        //获取公网IP超时
        return @"";
    }
    // 如果获取到了有效的ipStr，进行换行符替换并返回，否则返回nil
    if (ipStr.length > 0) {
        // 使用try-catch块来捕获可能在字符串替换操作中出现的异常
        @try {
            if (ipStr != nil && ipStr.length > 0) {
                return [ipStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            } else {
                return @"";
            }
        } @catch (NSException *exception) {
            //字符串替换操作出现异常
            return @"";
        }
    }
    return @"";
    /*
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURL *url = [NSURL URLWithString:@"https://ifconfig.me/ip"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            ipStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            // 在这里可以使用获取到的 IP 字符串 ipStr
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return ipStr;
    */
}

#pragma mark - 获取当前网络连接类型WiFi、5G、4G、3G、2G
+ (NSString *)getCurrentNetWorkType {
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_storage zeroAddress;
    
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags) {
        return notReachable;
    }
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    if (isReachable && !needsConnection) { }else{
        return notReachable;
    }

    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired ) {
        return notReachable;
    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        return [NSString cellularType];
    } else {
        return @"WiFi";
    }
}

//返回5G、4G、3G、2G
+ (NSString *)cellularType {
    CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
    
    NSString *currentRadioAccessTechnology;
    if (info && [info respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
        NSDictionary *radioDic = [info serviceCurrentRadioAccessTechnology];
        if (radioDic.allKeys.count) {
            currentRadioAccessTechnology = [radioDic objectForKey:radioDic.allKeys[0]];
        } else {
            return notReachable;
        }
    } else {
        
        return notReachable;
    }
    if (currentRadioAccessTechnology) {
        if (@available(iOS 14.1, *)) {
            if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyNRNSA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyNR]) {
                return @"5G";
            }
        }
        if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
            return @"4G";
        } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {

            return @"3G";
        } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
            return @"2G";
        } else {
            return @"Unknow";
        }
    } else {
        
        return notReachable;
    }
}

#pragma mark - 获取图片的格式
+ (NSString *)getImageFileFormat:(NSData *)imgData {
    // 创建 CGImageSourceRef 对象
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imgData, NULL);
    if (!source) {
        return @"png";
    }
    // 获取图片信息
    CFStringRef imageType = CGImageSourceGetType(source);
    // 释放 CGImageSourceRef 对象
    CFRelease(source);
    // 将 CFStringRef 转换为 NSString
    NSString *imageFormat = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(imageType, kUTTagClassFilenameExtension);
    return imageFormat;
}

#pragma mark - 获取视频的格式
+ (NSString *)getVideoFileFormat:(NSURL *)videoUrl {
    NSString *fileExtension = [[[videoUrl absoluteString] pathExtension] lowercaseString];
    if ([fileExtension containsString:@"mp4"]) {
        return @"mp4";
    } else if ([fileExtension containsString:@"mov"]) {
        return @"mov";
    } else if ([fileExtension containsString:@"avi"]) {
        return @"avi";
    } else if ([fileExtension containsString:@"flv"]) {
        return @"flv";
    } else if ([fileExtension containsString:@"rm"]) {
        return @"rm";
    } else if ([fileExtension containsString:@"rmvb"]) {
        return @"rmvb";
    } else if ([fileExtension containsString:@"mkv"]) {
        return @"mkv";
    } else if ([fileExtension containsString:@"wmv"]) {
        return @"wmv";
    } else {
        return @"mp4";
    }
}

#pragma mark - 对IP地址进行脱敏处理
- (NSString *)desensitizeIPAddress {
    if ([self checkUrlIsIPAddress]) {
        // 拆分IP地址
        NSArray *components = [self componentsSeparatedByString:@"."];
        
        // 确保IP地址格式正确，并且有足够的分段
        if (components.count == 4) {
            // 脱敏处理，将第2段和第3段替换成"xxx"
            NSString *desensitizedIP = [NSString stringWithFormat:@"%@.*.*.%@", components[0], components[3]];
            return desensitizedIP;
        } else {
            // 如果IP地址格式不正确，则对中间部分脱敏
            NSString *desensitizedIP = [NSString stringWithFormat:@"%@.*.*.%@", [components firstObject], [components lastObject]];
            return desensitizedIP;
        }
    } else {
        return self;
    }
}

- (nullable NSString *)safeSubstringWithRange:(NSRange)range {
    if (![self isKindOfClass:[NSString class]] || self.length == 0) {
        return nil;
    }
    if (range.location == NSNotFound || NSMaxRange(range) > self.length) {
        NSLog(@"[safeSubstring] invalid range %@ for string length %lu. string preview: %@", NSStringFromRange(range), (unsigned long)self.length, (self.length > 200 ? [self substringToIndex:200] : self));
        return nil;
    }
    @try {
        return [self substringWithRange:range];
    } @catch (NSException *ex) {
        NSLog(@"[safeSubstring] exception %@ for range %@, string preview: %@", ex, NSStringFromRange(range), (self.length > 200 ? [self substringToIndex:200] : self));
        return nil;
    }
}

+ (BOOL)isValiableWithFileName:(NSString *)fileName {
    if (![NSString isNil:fileName]) {
        // 定义文件名中不允许出现的非法字符：\ / : * ? " < > |
        NSCharacterSet *illegalCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\\/:*?\"<>|"];
        
        // 检查文件名中是否包含非法字符
        NSRange range = [fileName rangeOfCharacterFromSet:illegalCharacterSet];
        
        // 如果找到非法字符，返回 NO（不合法）；否则返回 YES（合法）
        return (range.location == NSNotFound);
    }
    
    // 文件名为空，直接保持原先逻辑，支持
    return YES;
}

@end

