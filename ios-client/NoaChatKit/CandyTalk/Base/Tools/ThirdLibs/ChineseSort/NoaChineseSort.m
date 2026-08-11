//
//  NoaChineseSort.m
//
//  Created by Baymax on 16/2/11.
//  Copyright (c) 2016年 Baymax. All rights reserved.
//  version: 0.2.4

#import "NoaChineseSort.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NoaChineseSortSetting

+(NoaChineseSortSetting*)share{
    static NoaChineseSortSetting * singleton = nil ;
    if (singleton == nil) {
        singleton = [[NoaChineseSortSetting alloc] init];
        [singleton defaultValue];
    }
    return singleton;
}

-(void)defaultValue{
    _sortMode = 1;
    _logEable = YES;
    _needStable = false;
    _specialCharSectionTitle = @"#";
    _specialCharPositionIsFront = YES;
    _ignoreModelWithPrefix = @"";
    _polyphoneMapping = [NSMutableDictionary dictionaryWithDictionary:
                         @{@"重庆":@"CQ",
                           @"厦门":@"XM",
                           @"长":@"C",
                           @"沈":@"S",
                           }];
}

-(void)setPolyphoneMapping:(NSMutableDictionary *)polyphoneMapping{
    [_polyphoneMapping addEntriesFromDictionary:polyphoneMapping];
}

@end


#pragma mark ============== 封装用于排序的 单位 模型 ==================
@interface NoaChineseSortModel : NSObject
//用将需要排序的对象封装在BMChineseSort对象中，包含排序的字符串，对象，首字母三个属性
//进行比较的字符串，
@property(strong,nonatomic)NSString *string;
//字符串对应的拼音 首字母
@property(strong,nonatomic)NSString *pinYin;
//需要比较的对象
@property (strong , nonatomic) id object;
@end


@implementation NoaChineseSortModel
@end

#pragma mark ============== 自定义排序扩展 ==================
// NSString + mySort.h
@interface NSString (mySort)
- (NSComparisonResult)mySort:(NSString *)str;
@end

@implementation NSString (mySort)

- (NSComparisonResult)mySort:(NSString *)str {
    
    NSString*s = [NoaChineseSortSetting share].specialCharSectionTitle;
    BOOL b = [NoaChineseSortSetting share].specialCharPositionIsFront;
    
    NSComparisonResult res = NSOrderedDescending;
    if ([self isEqualToString:s]){
        //相同
        if ([str isEqualToString:s]) {
            res = NSOrderedSame;
        }
        res = b ? NSOrderedAscending : NSOrderedDescending;
    }else if ([str isEqualToString:s]){
        res = b ? NSOrderedDescending : NSOrderedAscending;
    }else{
        res = [self localizedStandardCompare:str];
    }
    //如过相等就返回
    if (res == NSOrderedSame) {
        res = NSOrderedAscending;
    }
    return res;
}
@end







//数组操作信号量
dispatch_semaphore_t semaphore;

@implementation NoaChineseSort
#pragma mark ============== tools ==================
//中文转拼音 ABC苹果 -> @"ABC ping guo" 英文不变 拼音小写
+(NSString *)transformChinese:(NSString *)word{
    NSMutableString *pinyin = [word mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return pinyin;
}

#pragma mark ==============  排序  ==================

+(void)sortAndGroup:(NSArray*)objectArray
                key:(NSString *)key
             finish:(void (^)(bool isSuccess,
                              NSMutableArray *unGroupedArr,
                              NSMutableArray *sectionTitleArr,
                              NSMutableArray<NSMutableArray*>* sortedObjArr))finish{

    if (!objectArray || objectArray.count == 0) {
        finish(YES,@[].mutableCopy,@[].mutableCopy,@[].mutableCopy);
        return;
    }
    //非法 属性名 检测
    BOOL containKey = NO;
    NSObject *obj = objectArray.firstObject;
    if (key == nil) {
        
        if (![obj isKindOfClass:NSString.class]) {
            [NoaChineseSort logMsg:@"数组内元素不是字符串类型,如果是对象类型，请传key"];
            finish(NO,nil,nil,nil);
            return;
        }
        containKey = YES;
        
    }else{
        
        Class cla = ((NSObject*)objectArray.firstObject).class;
        
        while (cla != Nil){
            unsigned int outCount, i;
            Ivar *ivars = class_copyIvarList(cla, &outCount);
            for (i = 0; i < outCount; i++) {
                Ivar property = ivars[i];
                NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
                NSString *tempKey = [NSString stringWithFormat:@"_%@",key];
                if ([keyName isEqualToString:tempKey]) {
                    containKey = YES;
                    break;
                }
            }
            if (containKey == YES) {
                break;
            }
            cla = class_getSuperclass(cla.class);
        }
    }
    
    if (!containKey) {
        [NoaChineseSort logMsg:@"数组内元素未包含指定属性"];
        finish(NO,nil,nil,nil);
        return;
    }
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();

    semaphore = dispatch_semaphore_create(1);

    __weak typeof(self) weakSelf = self;
    
    //异步执行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //将数据 转换为 BMChineseSortModel
        NSMutableArray *sortModelArray = [NSMutableArray arrayWithCapacity:0];
        
        if (NoaChineseSortSetting.share.needStable){
            NSMutableArray *tempArray = [NSMutableArray array];

            [objectArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NoaChineseSortModel *model = [weakSelf getModelWithObj:obj key:key];
                [tempArray addObject:model];
                
            }];
            
            // 一次性将收集好的数据添加到sortModelArray
            [sortModelArray addObjectsFromArray:tempArray];
            
        }else{
            // 先创建一个并发安全的临时容器收集数据
            NSMutableArray *tempArray = [NSMutableArray array];
            NSLock *lock = [NSLock new];
            
            // 由于enumerateObjectsWithOptions是多线程导致 转拼音后顺序打乱 造成排序的不稳定
            [objectArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NoaChineseSortModel *model = [weakSelf getModelWithObj:obj key:key];
                if (model) {
                    //对 数组的插入操作 上锁
                    [lock lock];
                    [tempArray addObject:model];
                    [lock unlock];
                }
            }];
            
            // 再将临时容器中的数据添加到sortModelArray
            [sortModelArray addObjectsFromArray:tempArray];
        }
        
        CFAbsoluteTime state1 = CFAbsoluteTimeGetCurrent();
        [NoaChineseSort logMsg:@""];
        [NoaChineseSort logMsg:[NSString stringWithFormat:@"转拼音用时：\t %f s", (state1-start)]];

        //根据BMChineseSortModel的pinYin字段 升序 排列
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES selector:@selector(mySort:)];
        [sortModelArray sortUsingDescriptors:@[sortDescriptor]];

        //打印 排序用时
        CFAbsoluteTime state2 = CFAbsoluteTimeGetCurrent();
        [NoaChineseSort logMsg:[NSString stringWithFormat:@"排序用时：\t %f s", (state2-state1)]];


        //不分组
        NSMutableArray *unSortedArr = [NSMutableArray array];

        //分组
        NSMutableArray<NSString *> *sectionTitleArr = [NSMutableArray array];
        NSMutableArray<NSMutableArray *> *sortedObjArr = [NSMutableArray array];
        NSMutableArray *newSection = [NSMutableArray array];
        NSString *lastTitle;
        
        //拼音分组 稳定的分组排序 所以组内不需要再排
        for (NoaChineseSortModel* object in sortModelArray) {
            
            NSString *firstLetter = [object.pinYin substringToIndex:1];
            
            //防止nil程序崩溃
            firstLetter = firstLetter.length > 0 ? firstLetter : @"";
            
            id obj = object.object;
            
            [unSortedArr addObject:obj];
            
            //不同
            if(![lastTitle isEqualToString:firstLetter]){
                [sectionTitleArr addObject:firstLetter];
                //分组
                newSection = [NSMutableArray array];
                [sortedObjArr addObject:newSection];
                [newSection  addObject:obj];
                //用于下一次比较
                lastTitle = firstLetter;
            }else{//相同
                [newSection  addObject:obj];
            }
        }
        //

        //打印 总用时
        //CFAbsoluteTime state3 = CFAbsoluteTimeGetCurrent();
        //[ZChineseSort logMsg:[NSString stringWithFormat:@"分组用时：\t %f s", (state3-state2)]];
        //[ZChineseSort logMsg:[NSString stringWithFormat:@"BMChineseSort 排序总计用时：\t %f s", (state3-start)]];

        //回主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            finish(YES,unSortedArr,sectionTitleArr,sortedObjArr);
        });
    });
}

//将对象 转为 BMChineseSortModel
+(NoaChineseSortModel*)getModelWithObj:(id)obj key:(NSString*)key{
    
    NoaChineseSortModel *model = [[NoaChineseSortModel alloc]init];
    
    model.object = obj;
    
    if (!key) {
        model.string = obj;
    }else{
        model.string = [obj valueForKeyPath:key];
    }
    
    //提出空白字符
    model.string = [model.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(model.string == nil || model.string.length == 0){
        model.string = NoaChineseSortSetting.share.specialCharSectionTitle;
    }else{
        //过滤 ignoreModelWithPrefix
        NSString *prefix = [model.string substringToIndex:1];
        
        if (![NoaChineseSortSetting.share.ignoreModelWithPrefix containsString:prefix]) {
            //是否将字母与汉字拼音一起排序？？？？ （暂不考虑）
            //获取拼音首字母
            model.pinYin = [self getFirstLetter:model.string];
        }else{
            return nil;
        }
    }
    return model;
}


// 开关控制打印
+(void)logMsg:(NSString*)msg{
    if (NoaChineseSortSetting.share.logEable == YES) {
        DLog(@"------------------");
        DLog(@"%@", msg);
        DLog(@"------------------");
    }
}

#pragma mark ===============获取汉字首字母====================
//获得 首字母组成的字符串保留非中文字符  电脑->DN  abc->ABC abc电脑->ABCDN
+ (NSString *)getFirstLetter:(NSString *)chinese{
    
    //把已知的英文转为大写
    __block NSString* newChinese = [chinese uppercaseString];
    
    //吧多音字先替换
    [NoaChineseSortSetting.share.polyphoneMapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        newChinese = [newChinese stringByReplacingOccurrencesOfString:key withString:obj];
    }];

    NSMutableString *result = [NSMutableString string];
    
    NSArray *wordArr = [[NoaChineseSort transformChinese:newChinese] componentsSeparatedByString:@" "];
    
    for (NSString* word in wordArr) {
        
        //如果word是小写 为汉字转的拼音 提取首字符 否则 保留全部
        if (word.length > 0) {
            char c = [word characterAtIndex:0];
            if ((c>96)&&(c<123)) {
                [result appendFormat:@"%c",c];
            }else{
                [result appendString:word];
            }
        }
        
    }
    
//    if (ZChineseSortSetting.share.sortMode == 1) {
//        //此处 对整个字符串转中文 而不单个字一次转 因为CFStringTransform太耗时 而这个时间又与字个数关系不大，所以尽量减少调用次数 以减少时间
//        NSArray *wordArr = [[ZChineseSort transformChinese:newChinese] componentsSeparatedByString:@" "];
//        for (NSString* word in wordArr) {
//            //如果word是小写 为汉字转的拼音 提取首字符 否则 保留全部
//            char c = [word characterAtIndex:0];
//            if ((c>96)&&(c<123)) {
//                [result appendFormat:@"%c",c];
//            }else{
//                [result appendString:word];
//            }
//        }
//    }else{
//        for(int j=0;j<newChinese.length;j++){
//            NSString *pinyin;
//            NSString *word = [newChinese substringWithRange:NSMakeRange(j, 1)];
//            pinyin = [NSString stringWithFormat:@"%c",pinyinFirstLetter([word characterAtIndex:0])];
//            if (pinyin.length>=1) {
//                [result appendString:[pinyin substringToIndex:1]];
//            }
//        }
//    }

    //全转为大写
    NSString *upperCaseStr = [result uppercaseString];
    //判断第一个字符是否为字母 英文或者中文转拼音后都是字母开头
    if ([upperCaseStr characterAtIndex:0] >= 'A' && [upperCaseStr characterAtIndex:0] <= 'Z') {
        return upperCaseStr;
    }else{//所有非字母的全分为 特殊字符分类中
        return NoaChineseSortSetting.share.specialCharSectionTitle;
    }
}
@end
