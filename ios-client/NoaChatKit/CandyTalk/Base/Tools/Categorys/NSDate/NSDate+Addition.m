//
//  NSDate+Addition.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/13.
//

#import "NSDate+Addition.h"

@implementation NSDate (Addition)
#pragma mark - 当前时间戳（以秒为单位）
+ (long long)currentTimeIntervalWithSecond {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    long long time = [date timeIntervalSince1970];
    return time;
}

//当前时间戳（以毫秒为单位）
+ (long long)currentTimeIntervalWithMillisecond {
    NSDate *date = [NSDate date];
    long long time = [date timeIntervalSince1970] * 1000;
    return time;
}


- (NSString *)dateForFileName {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
    NSString *selfStr = [fmt stringFromDate:self];
    return selfStr;
}

+ (NSString *)dateForBucketName {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *selfStr = [fmt stringFromDate:[NSDate date]];
    return selfStr;
}


// 07-15 10:45:23
+ (NSString *)transTimeStrToDateMethod1:(long long)time {
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time / 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}
// 2022-07-15
+ (NSString *)transTimeStrToDateMethod2:(long long)time {
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time / 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}
// 07-15 10:45
+ (NSString *)transTimeStrToDateMethod3:(long long)time {
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time / 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}
//10:45
+ (NSString *)transTimeStrToDateMethod4:(long long)time {
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time / 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}

+ (NSString *)transTimeStrToDateMethod5:(long long)time {
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time / 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}

+ (NSString *)transTimeStrToDateMethod6:(long long)time {
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time / 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}


//毫秒转换成： 03:23
+ (NSString *)transSecondToTimeMethod1:(NSInteger)millisecond {
    NSInteger seconds = millisecond / 1000;
    //时
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //分
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //秒
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];

    //NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    NSString *format_time = @"";
    if (![str_hour isEqualToString:@"00"]) {
        format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    } else {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    
    return format_time;
}

//秒转换成： 03:23
+ (NSString *)transSecondToTimeMethod2:(NSInteger)millisecond {
    NSInteger seconds = millisecond;
    //时
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //分
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //秒
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];

    //NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    NSString *format_time = @"";
    if (![str_hour isEqualToString:@"00"]) {
        format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    } else {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    
    return format_time;
}

//获取两个时间点的时间差，精确到秒
//@"yyyy-MM-dd HH:mm:ss"
+ (NSInteger )getTimeDifferenceWithStartTime:(NSString * )startTime andEndTime:(NSString *)endTime timeFormatter:(NSString *)timeFormatter{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:timeFormatter];

//    NSDate* startTimeData = [dateFormatter dateFromString:startTime];

    NSTimeInterval startTimeSp=[[NSDate date] timeIntervalSince1970];// *1000 是精确到毫秒，不乘就是精确到秒

    NSDate* endTimeData = [dateFormatter dateFromString:endTime];

    NSTimeInterval endTimeSp=[endTimeData timeIntervalSince1970];

    NSInteger difference = (endTimeSp - startTimeSp);

    //NSLog(@"开始时间：%@,结束时间：%@,两个时间差为%ld秒",startTime,endTime, difference);

    return difference;
}

//将时间数据（秒）转换为@"%ld天%小时%@分%@秒"
+ (NSString*)getOvertime:(NSString*)mStr isShowSecondStr:(BOOL)isShowSecond{
    long msec = [mStr longLongValue];
      
    if (msec <= 0)
    {
        return @"";
    }
      
    NSInteger d = msec/60/60/24;
    NSInteger h = msec/60/60%24;
    NSInteger  m = msec/60%60;
    NSInteger  s = msec%60;
      
    NSString *_tStr = @"";
    NSString *_dStr = @"";
    NSString *_hStr = @"";
    NSString *_mStr = @"";
    NSString *_sStr = @"";
      
    if (d > 0)
    {
        _dStr = [NSString stringWithFormat:LanguageToolMatch(@"%ld天"),d];
    }
      
    if (h > 0)
    {
        _hStr = [NSString stringWithFormat:LanguageToolMatch(@"%ld小时"),h];
    }
    if (m > 0)
    {
        _mStr = [NSString stringWithFormat:LanguageToolMatch(@"%ld分钟"),m];
    }
    if (isShowSecond) {
        if (s > 0)
        {
            _sStr = [NSString stringWithFormat:LanguageToolMatch(@"%ld秒"),s];
        }
    }
    if (d>30) {
        _tStr = LanguageToolMatch(@"禁言");
    }else{
        _tStr = [NSString stringWithFormat:@"%@%@%@%@",_dStr,_hStr,_mStr,_sStr];
    }
      
    return _tStr;
}

#pragma mark - 日期转字符串
- (NSString *)dateForStringWith:(NSString *)timeFormatter {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = timeFormatter;
    NSString *selfStr = [fmt stringFromDate:self];
    return selfStr;
}


#pragma mark - 拿到当前日期时间，判断某个日期时间(零时区)是否过期，用于检查文件存储的token是否已过期
+ (BOOL)checkCloudStoreageDataTimeExpireWith:(NSString *)ExpirationTime {
    BOOL isExpire = NO;
    /** 将失效时间字符串转换成时间戳 */
    //去掉 UTC时间字符串中的 T 和 Z
    NSString *expireTime = [ExpirationTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    expireTime = [expireTime stringByReplacingOccurrencesOfString:@"Z" withString:@" "];
    //将UTC时间字符串转换成当前时区的时间字符串
    NSDateFormatter *expireFormat = [[NSDateFormatter alloc] init];
    expireFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    expireFormat.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDate *expireDate = [expireFormat dateFromString:expireTime];
    //失效时间转成时间戳
    long long expireTiemStamp = (long long)[expireDate timeIntervalSince1970];
    
    /** 获取当前设备的时间的时间戳 */
    NSDate *nowDate = [NSDate date];
    long long nowTimeStamp = (long long)[nowDate timeIntervalSince1970];

    //判断是否已经失效
    if ((nowTimeStamp + 5) >= expireTiemStamp) {
        //已失效
        isExpire = YES;
    } else {
        //未失效
        isExpire = NO;
    }
    //NSLog(@"======= isExpire：%@ =======", isExpire ? @"已失效":@"未失效");
    return isExpire;
}
+ (NSInteger)getYearWithCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger year = [dateComponent year];
    return year;
}
+ (NSInteger)getMonthWithCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger month = [dateComponent month];
    return month;
}
+ (NSInteger)getDayWithCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger day = [dateComponent day];
    return day;
}
+ (NSInteger)getHourWithCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger hour = [dateComponent hour];
    return hour;
}
+ (NSInteger)getMinuteWithCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger minute = [dateComponent minute];
    return minute;
}

/// 根据时间戳输出与当前时间差的描述字符串
/// @param timestamp 时间戳（秒或毫秒）
/// @return 描述字符串，例如 "20秒"、"5分"、"3小时"、"10天"、"2月"
+ (NSString *)timeDescriptionFromTimestamp:(NSTimeInterval)timestamp {
    // 判断时间戳是否是毫秒级（大于当前时间的100倍，大概率是毫秒）
    if (timestamp > [[NSDate date] timeIntervalSince1970] * 100) {
        timestamp = timestamp / 1000.0;
    }

    // 当前时间
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval diff = currentTime - timestamp;

    if (diff < 60) {
        return [NSString stringWithFormat:LanguageToolMatch(@"%@分钟前在线"), @"1"];
    } else if (diff < 60 * 60) {
        return [NSString stringWithFormat:LanguageToolMatch(@"%@分钟前在线"), [NSString stringWithFormat:@"%ld",(NSInteger)floor(diff / 60)]];
    } else if (diff < 60 * 60 * 24) {
        return [NSString stringWithFormat:LanguageToolMatch(@"%@小时前在线"), [NSString stringWithFormat:@"%ld",(NSInteger)floor(diff / (60 * 60))]];
    } else if (diff < 60 * 60 * 24 * 30) {
        return [NSString stringWithFormat:LanguageToolMatch(@"%@天前在线"), [NSString stringWithFormat:@"%ld",(NSInteger)floor(diff / (60 * 60 * 24))]];
    } else {
        return LanguageToolMatch(@"1月前在线");
    }
}

@end
