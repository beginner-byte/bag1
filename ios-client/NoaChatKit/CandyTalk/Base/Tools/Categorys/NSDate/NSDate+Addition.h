//
//  NSDate+Addition.h
//  NoaIMChatService
//
//  Created by Candy on 2026/7/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Addition)
//当前时间戳（以秒为单位）
+ (long long)currentTimeIntervalWithSecond;

//当前时间戳（以毫秒为单位）
+ (long long)currentTimeIntervalWithMillisecond;

//根据时间获得唯一名称
- (NSString *)dateForFileName;

//上传文件的bucketName相关
+ (NSString *)dateForBucketName;

//时间戳转换成： 07-15 10:45:23
+ (NSString *)transTimeStrToDateMethod1:(long long)time;
+ (NSString *)transTimeStrToDateMethod2:(long long)time;
+ (NSString *)transTimeStrToDateMethod3:(long long)time;
+ (NSString *)transTimeStrToDateMethod4:(long long)time;
+ (NSString *)transTimeStrToDateMethod5:(long long)time;
+ (NSString *)transTimeStrToDateMethod6:(long long)time;
//毫秒转换成： 03:23
+ (NSString *)transSecondToTimeMethod1:(NSInteger)millisecond;

//秒转换成： 03:23
+ (NSString *)transSecondToTimeMethod2:(NSInteger)millisecond;

//获取两个时间点的时间差，精确到秒
//@"yyyy-MM-dd HH:mm:ss"
+ (NSInteger )getTimeDifferenceWithStartTime:(NSString * )startTime andEndTime:(NSString *)endTime timeFormatter:(NSString *)timeFormatter;

//将时间数据（秒）转换为@"%ld天%小时%@分%@秒"
+ (NSString*)getOvertime:(NSString*)mStr isShowSecondStr:(BOOL)isShowSecond;

//日期转字符串
- (NSString *)dateForStringWith:(NSString *)timeFormatter;

//拿到当前日期时间，判断某个日期时间(零时区)是否过期，用于检查文件存储的token是否已过期
+ (BOOL)checkCloudStoreageDataTimeExpireWith:(NSString *)ExpirationTime;
//获取当前日期的年 例如2023
+ (NSInteger)getYearWithCurrentDate;
//获取当前日期的月份 例如7月
+ (NSInteger)getMonthWithCurrentDate;
+ (NSString *)timeDescriptionFromTimestamp:(NSTimeInterval)timestamp;
@end

NS_ASSUME_NONNULL_END
