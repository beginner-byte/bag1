//
//  NSString+Addition.h
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Addition)
#pragma mark - 删除字符串开头与结尾的空白符与换行
- (NSString *)trimString;
#pragma mark - 图片地址中文处理
- (NSURL *)imageUrlEncode;
#pragma mark - url地址中文处理
- (NSString *)requrestUrlEncode;
#pragma mark - 数字和字母组合
- (BOOL)isNumberAndLetter;
#pragma mark - 手机号判断
- (BOOL)isPhoneNumber;
#pragma mark - 身份证判断
- (BOOL)isIDCardNumber;
#pragma mark - 小数点处理
- (NSString *)decimalFloat:(float)floatValue mode:(NSRoundingMode)mode scale:(NSInteger)scale;
#pragma mark - 含有emoji表情的字符串处理
- (NSInteger)emojiLength;
#pragma mark - 字符串转时间戳(毫秒)
- (NSTimeInterval)timeIntervalFromTimeStr;
#pragma mark - 加密
- (NSString *)MD5Encryption;
#pragma mark - 移除字符串中的特殊字符
+ (NSString *)stringReplaceSpecialCharacterWith:(NSString *)oldStr;

#pragma mark - 获取表情富文本
//- (NSMutableAttributedString *)getEmotionString;

#pragma mark - 2-20个字 中英文、数字
- (BOOL)checkNickname;

#pragma mark - 正则获取指定内容
- (NSString* )getRegExpressResultWithRegExp:(NSString*)regExp;

#pragma mark - 禁言时长，分钟 -> 小时、天、永久禁言
+ (NSString *)convertBannedSendMsgTime:(int64_t)minit;

#pragma mark - 获得其他功能图片路径
+ (NSString *)getSaveImagePath:(UIImage *)image ImgName:(NSString *)imgName;

#pragma mark - 存储图片相关
+ (void)saveImageToSaxboxWithData:(NSData *)imgData CustomPath:(NSString *)customPath ImgName:(NSString *)imgName;
+ (UIImage *)getImageWithImgName:(NSString *)imgName CustomPath:(NSString *)customPath;
+ (NSString *)getPathWithImageName:(NSString *)imgName CustomPath:(NSString *)customPath;

#pragma mark - 存储视频相关
+ (void)saveVideoToSaxboxWithData:(NSData *)videoData CustomPath:(NSString *)customPath VideoName:(NSString *)videoName;
+ (NSString *)getPathWithVideoName:(NSString *)videoName CustomPath:(NSString *)customPath;
//获取本地视频data
+ (NSData *)getVideoDataWithVideoName:(NSString *)videoName CustomPath:(NSString *)customPath;

#pragma mark - 存储音频相关
//获取保存语音路径
+ (NSString *)getVoiceDiectoryWithCustomPath:(NSString *)customPath;

#pragma mark - 存储文件相关
//发送文件消息时，将相册的视频文件copy到本地沙盒一份
+ (void)saveFileToSaxboxWithData:(NSData *)fileData CustomPath:(NSString *)customPath fileName:(NSString *)fileName;
//获取保存文件路径
+ (NSString *)getFileDiectoryWithCustomPath:(NSString *)customPath;

//获取本地文件地址
+ (NSString *)getPathWithFileName:(NSString *)fileName CustomPath:(NSString *)customPath;

#pragma mark - 获得存储https请求自签证书的密码
+ (NSString *)getHttpsCerPassword;

+ (NSString *)createSavedFileName;
+ (BOOL)createTempOpenIMFieldWithType:(NSString *)fieldType;

#pragma mark - 上传图片名称
+ (NSString *)uploadImageName:(UIImage *)image;

#pragma mark - 将数组转换成json格式字符串
+ (NSString *)jsonStringFromArray:(NSArray *)array;

#pragma mark - 将字典转换成json字符串
+ (NSString *)jsonStringFromDic:(NSDictionary *)dict;

#pragma mark - 将json字符串转换成字典
+ (NSDictionary *)jsonStringToDic:(NSString *)jsonString;

#pragma mark - 获取时间格式(单位:毫秒)
+ (NSString *)timeStringForPastTimeDate:(long long)timeValue;

#pragma mark - 获取指定时间间隔格式(单位:秒)(24小时，一年，一年以上)
+ (NSString *)timeIntervalStringWith:(long long)startTimeValue;

#pragma mark - 时间戳转字符串
+ (NSString *)dateStringFromTimeValue:(long long)timeValue formatter:(nonnull NSString *)formatter;

#pragma mark - 时间字符串 转 时间戳(毫秒)
+ (long long)dateFromTimeDate:(NSString *)formatTime formatter:(NSString *)format;

#pragma mark - 获取字符串宽度
- (CGFloat)widthForFont:(UIFont *)font;

#pragma mark - 获取指定宽度字符串的高度
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;

#pragma mark - 获得时长00:00
+ (NSString *)getTimeLength:(NSInteger)time;

#pragma mark - 获得时长00:00:00
+ (NSString *)getTimeLengthHMS:(NSInteger)second;

#pragma mark - 按照指定要求展示群名称/昵称
+ (NSString *)showAppointWidith:(CGFloat)maxWidth sessionName:(NSString *)sessionName peopleNum:(NSString *)peopleNum;

#pragma mark - 根据文件大小转换大小字符串
// <1KB，单位B，1MB<大小<=1KB，单位KB，50MB<=大小<=1MB，单位MB
+ (NSString *)sizeFormattedWithSize:(NSInteger)size;

#pragma mark - 转换文件大小的单位
+ (NSString *)fileTranslateToSize:(float)size;

#pragma mark - 通过目标路径的文件获取该文件上传时的mimeType类型
+ (NSString *)fileTranslateToMimeTypeWithPath:(NSString *)filePath;

#pragma mark - 通过目标路径的文件获取该文件的格式
+ (NSString *)fileTranslateToTypeWithPath:(NSString *)filePath;

#pragma mark - 通过目标路径下本地文件获取该文件的文件类型
+ (NSString *)fileTranslateToFileType:(NSString *)filePath;

#pragma mark - 通过返回数据里文件消息的文件类型，展示不同的图标里的文件类型
+ (NSString *)getFileTypeContentWithFileType:(NSString *)fileType fileName:(NSString *)fileName;

#pragma mark - 获得apiHost完整的加载地址
- (NSURL *)getApiHostFullUrl;

#pragma mark - 获得图片完整的加载地址
- (NSURL *)getImageFullUrl;
#pragma mark - 获得图片完整的加载地址
- (NSString *)getImageFullString;

#pragma mark - 获取收藏消息中保存文件路径
+ (NSString *)getCollcetionMessageFileDiectoryPath;

#pragma mark - 通过注册/登录的类型值返回类型的文本
+ (NSString *)getAuthContetnWithAuthType:(int)authType;

+ (NSString *)getAuthCodeWithAuthType:(int)authType;

#pragma mark - 加载用户头像逻辑：先判断用户是否注销，如果注销显示注销头像，如果未注销，显示真实头像、
+ (NSString *)loadAvatarWithUserStatus:(NSInteger)userStatus avatarUri:(NSString *)avatarUri;

 #pragma mark - 加载用户昵称逻辑：先判断用户是否注销，如果注销显示账号已注销，如果未注销，显示真实昵称、
+ (NSString *)loadNickNameWithUserStatus:(NSInteger)userStatus realNickName:(NSString *)realNickName;

#pragma mark -  汉字转拼音
+ (NSString *)chineseTransformPinYinWith:(NSString *)chineseCharacters;

#pragma mark - 获取字符串中的网址
- (NSArray *)getUrlFromString;

#pragma mark - 判断字符是否是URL
-(BOOL)checkStringIsUrl;

#pragma mark - 邀请码只能输入：纯小写字母 或 纯数字 或 小写字母+数字
- (BOOL)inputLiceseIdCheck;

#pragma mark - 检测url地址是否为IP地址
- (BOOL)checkUrlIsIPAddress;

#pragma mark - 账号格式检测(修改账号功能)
//只能是 6-16位 字母+数字组合，前两位必须为字母
- (BOOL)checkUserAccountFormat;

#pragma mark - 生成一个指定范围的随机整数
+ (NSString *)randomNumWithMin:(NSInteger)min max:(NSInteger)max;

#pragma mark - 获取当前设备的公网IP
+ (NSString *)getDevicePublicNetworkIP;

#pragma mark - 获取当前网络连接类型WiFi、5G、4G、3G、2G
+ (NSString *)getCurrentNetWorkType;

//#pragma mark - 去掉字符串中所有回车和空格
//+ (NSString *)handleStringSpecilFormat:(NSString *)originalStr;

#pragma mark ------<判断字符串是否为空>
+ (BOOL)isNil:(NSString *)str;

#pragma mark - 获取图片的格式
+ (NSString *)getImageFileFormat:(NSData *)imgData;

#pragma mark - 获取视频的格式
+ (NSString *)getVideoFileFormat:(NSURL *)videoUrl;

#pragma mark - 对IP地址进行脱敏处理
- (NSString *)desensitizeIPAddress;

/// 安全地截取指定范围的子字符串，避免越界崩溃。
/// 如果 range 无效，则返回 nil。
- (nullable NSString *)safeSubstringWithRange:(NSRange)range;

/// 判断文件名称是否包含:\/:*?"<> |
/// - Parameter fileName:文件名称
+ (BOOL)isValiableWithFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
