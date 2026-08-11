//
//  MessageTimeTool.m
//  NoaKit
//
//  Created by Candy on 2026/10/12.
//

#import "NoaMessageTimeTool.h"

@implementation NoaMessageTimeTool

//显示一个人性化的时间字串
+ (NSString*)getTimeStringAutoShort2:(NSDate *)dt mustIncludeTime:(BOOL)includeTime{
    NSString *ret = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 当前时间
    NSDate *currentDate = [NSDate date];
    NSDateComponents *curComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:currentDate];
    NSInteger currentYear = [curComponents year];
    //NSInteger currentMonth = [curComponents month];
    //NSInteger currentDay = [curComponents day];
    // 目标判断时间
    NSDateComponents *srcComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:dt];
    NSInteger srcYear = [srcComponents year];
    //NSInteger srcMonth = [srcComponents month];
    //NSInteger srcDay = [srcComponents day];
    // 要额外显示的时间分钟
    NSString *timeExtraStr = (includeTime ? [NoaMessageTimeTool getTimeString:dt format:@"HH:mm"] : @"");
//    // 当年
//    if(currentYear == srcYear) {
//        //long currentTimestamp = [ZMessageTimeTool getIOSTimeStamp_l:currentDate];
//        //long srcTimestamp = [ZMessageTimeTool getIOSTimeStamp_l:dt];
//        // 相差时间（单位：秒）
//        //long delta = currentTimestamp - srcTimestamp;
//        // 当天（月份和日期一致才是）
//        if(currentMonth == srcMonth && currentDay == srcDay) {
//            /*
//            // 时间相差60秒以内
//            if(delta < 60)
//                ret = @"刚刚";
//            // 否则当天其它时间段的，直接显示“时:分”的形式
//            else
//                ret = [ZMessageTimeTool getTimeString:dt format:@"HH:mm"];
//            */
//            ret = [ZMessageTimeTool getTimeString:dt format:@"HH:mm"];
//        }
//        // 当年 && 当天之外的时间（即昨天及以前的时间）
//        else{
//            /*
//            // 昨天（以“现在”的时候为基准-1天）
//            NSDate *yesterdayDate = [NSDate date];
//            yesterdayDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:yesterdayDate];
//            NSDateComponents *yesterdayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:yesterdayDate];
//            NSInteger yesterdayMonth = [yesterdayComponents month];
//            NSInteger yesterdayDay = [yesterdayComponents day];
//            // 前天（以“现在”的时候为基准-2天）
//            NSDate *beforeYesterdayDate = [NSDate date];
//            beforeYesterdayDate = [NSDate dateWithTimeInterval:-48*60*60 sinceDate:beforeYesterdayDate];
//            NSDateComponents *beforeYesterdayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:beforeYesterdayDate];
//            NSInteger beforeYesterdayMonth = [beforeYesterdayComponents month];
//            NSInteger beforeYesterdayDay = [beforeYesterdayComponents day];
//            // 用目标日期的“月”和“天”跟上方计算出来的“昨天”进行比较，是最为准确的（如果用时间戳差值
//            // 的形式，是不准确的，比如：现在时刻是2019年02月22日1:00、而srcDate是2019年02月21日23:00，
//            // 这两者间只相差2小时，直接用“delta/3600” > 24小时来判断是否昨天，就完全是扯蛋的逻辑了）
//            if(srcMonth == yesterdayMonth && srcDay == yesterdayDay) {
//                ret = [NSString stringWithFormat:@"昨天%@", timeExtraStr];// -1d
//            } else if(srcMonth == beforeYesterdayMonth && srcDay == beforeYesterdayDay) {
//                // “前天”判断逻辑同上
//                ret = [NSString stringWithFormat:@"前天%@", timeExtraStr];// -2d
//            } else{
//                // 跟当前时间相差的小时数
//                long deltaHour = (delta/3600);
//
//                // 如果小于或等 7*24小时就显示星期几
//                if(deltaHour <= 7*24){
//                    NSArray<NSString*> *weekdayAry = [NSArray arrayWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
//                    // 取出的星期数：1表示星期天，2表示星期一，3表示星期二。。。。 6表示星期五，7表示星期六
//                    NSInteger srcWeekday=[srcComponents weekday];
//                    // 取出当前是星期几
//                    NSString *weedayDesc = [weekdayAry objectAtIndex:(srcWeekday-1)];
//                    ret = [NSString stringWithFormat:@"%@%@", weedayDesc, timeExtraStr];
//                }
//                // 否则直接显示完整日期时间
//                else
//                    ret = [NSString stringWithFormat:@"%@%@", [ZMessageTimeTool getTimeString:dt format:@"yyyy/M/d"], timeExtraStr];
//            }
//            */
//            ret = [NSString stringWithFormat:@"%@", [ZMessageTimeTool getTimeString:dt format:@"M/d HH:mm"]];
//        }
//    } else{    // 往年
//        ret = [NSString stringWithFormat:@"%@%@", [ZMessageTimeTool getTimeString:dt format:@"yyyy/M/d"], timeExtraStr];
//    }
    
    if(currentYear == srcYear) {
        // 当年
        ret = [NSString stringWithFormat:@"%@", [NoaMessageTimeTool getTimeString:dt format:@"M-d"]];
    } else {
        // 往年
        ret = [NSString stringWithFormat:@"%@", [NoaMessageTimeTool getTimeString:dt format:@"yyyy-M-d"]];
    }
    return ret;
}

+ (NSString*)getTimeStringForSignMessage:(NSDate*)dt mustIncludeTime:(BOOL)includeTime {
    NSString *ret = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 当前时间
    NSDate *currentDate = [NSDate date];
    NSDateComponents *curComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:currentDate];
    NSInteger currentYear = [curComponents year];
    NSInteger currentMonth = [curComponents month];
    NSInteger currentDay = [curComponents day];
    // 目标判断时间
    NSDateComponents *srcComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:dt];
    NSInteger srcYear = [srcComponents year];
    NSInteger srcMonth = [srcComponents month];
    NSInteger srcDay = [srcComponents day];
    // 要额外显示的时间分钟
    NSString *timeExtraStr = (includeTime ? [NoaMessageTimeTool getTimeString:dt format:@"HH:mm"] : @"");
    // 当年
    if(currentYear == srcYear) {
        //long currentTimestamp = [ZMessageTimeTool getIOSTimeStamp_l:currentDate];
        //long srcTimestamp = [ZMessageTimeTool getIOSTimeStamp_l:dt];
        // 相差时间（单位：秒）
        //long delta = currentTimestamp - srcTimestamp;
        // 当天（月份和日期一致才是）
        if(currentMonth == srcMonth && currentDay == srcDay) {
            /*
            // 时间相差60秒以内
            if(delta < 60)
                ret = @"刚刚";
            // 否则当天其它时间段的，直接显示“时:分”的形式
            else
                ret = [NoaMessageTimeTool getTimeString:dt format:@"HH:mm"];
            */
            ret = [NoaMessageTimeTool getTimeString:dt format:@"HH:mm"];
        }
        // 当年 && 当天之外的时间（即昨天及以前的时间）
        else{
            /*
            // 昨天（以“现在”的时候为基准-1天）
            NSDate *yesterdayDate = [NSDate date];
            yesterdayDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:yesterdayDate];
            NSDateComponents *yesterdayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:yesterdayDate];
            NSInteger yesterdayMonth = [yesterdayComponents month];
            NSInteger yesterdayDay = [yesterdayComponents day];
            // 前天（以“现在”的时候为基准-2天）
            NSDate *beforeYesterdayDate = [NSDate date];
            beforeYesterdayDate = [NSDate dateWithTimeInterval:-48*60*60 sinceDate:beforeYesterdayDate];
            NSDateComponents *beforeYesterdayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:beforeYesterdayDate];
            NSInteger beforeYesterdayMonth = [beforeYesterdayComponents month];
            NSInteger beforeYesterdayDay = [beforeYesterdayComponents day];
            // 用目标日期的“月”和“天”跟上方计算出来的“昨天”进行比较，是最为准确的（如果用时间戳差值
            // 的形式，是不准确的，比如：现在时刻是2019年02月22日1:00、而srcDate是2019年02月21日23:00，
            // 这两者间只相差2小时，直接用“delta/3600” > 24小时来判断是否昨天，就完全是扯蛋的逻辑了）
            if(srcMonth == yesterdayMonth && srcDay == yesterdayDay) {
                ret = [NSString stringWithFormat:@"昨天%@", timeExtraStr];// -1d
            } else if(srcMonth == beforeYesterdayMonth && srcDay == beforeYesterdayDay) {
                // “前天”判断逻辑同上
                ret = [NSString stringWithFormat:@"前天%@", timeExtraStr];// -2d
            } else{
                // 跟当前时间相差的小时数
                long deltaHour = (delta/3600);

                // 如果小于或等 7*24小时就显示星期几
                if(deltaHour <= 7*24){
                    NSArray<NSString*> *weekdayAry = [NSArray arrayWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
                    // 取出的星期数：1表示星期天，2表示星期一，3表示星期二。。。。 6表示星期五，7表示星期六
                    NSInteger srcWeekday=[srcComponents weekday];
                    // 取出当前是星期几
                    NSString *weedayDesc = [weekdayAry objectAtIndex:(srcWeekday-1)];
                    ret = [NSString stringWithFormat:@"%@%@", weedayDesc, timeExtraStr];
                }
                // 否则直接显示完整日期时间
                else
                    ret = [NSString stringWithFormat:@"%@%@", [NoaMessageTimeTool getTimeString:dt format:@"yyyy/M/d"], timeExtraStr];
            }
            */
            ret = [NSString stringWithFormat:@"%@", [NoaMessageTimeTool getTimeString:dt format:@"M/d HH:mm"]];
        }
    } else{    // 往年
        ret = [NSString stringWithFormat:@"%@%@", [NoaMessageTimeTool getTimeString:dt format:@"yyyy/M/d"], timeExtraStr];
    }
    
    return ret;
}

+ (NSString*)getTimeString:(NSDate*)dt format:(NSString*)fmt{
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:fmt];
    return [format stringFromDate:(dt == nil ? [NoaMessageTimeTool getIOSDefaultDate] : dt)];
}

+ (NSTimeInterval)getIOSTimeStamp:(NSDate*)dat {
    NSTimeInterval a = [dat timeIntervalSince1970];
    return a;
}

+ (long)getIOSTimeStamp_l:(NSDate*)dat {
    return [[NSNumber numberWithDouble:[NoaMessageTimeTool getIOSTimeStamp:dat]] longValue];
}

+(NSDate *)getIOSDefaultDate {
    return [NSDate date];
}

//判断两个时间戳是不是在同一天内
+(BOOL)isSameDay:(long)iTime1 Time2:(long)iTime2 {
    //传入时间毫秒数
    NSDate *pDate1 = [NSDate dateWithTimeIntervalSince1970:iTime1/1000];
    NSDate *pDate2 = [NSDate dateWithTimeIntervalSince1970:iTime2/1000];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:pDate1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:pDate2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

@end
