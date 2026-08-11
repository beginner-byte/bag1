//
//  NoaSensitiveManager.m
//  NoaKit
//
//  Created by Candy on 2023/7/6.
//

#import "NoaSensitiveManager.h"

#define EXIST @"isExists"

@interface NoaSensitiveManager()

@property (nonatomic, strong) NSMutableDictionary *root;
//@property (nonatomic, strong) NSMutableArray *sensitiveList;
@property (nonatomic, assign) BOOL isFilterClose;
@property (nonatomic, strong) NSMutableArray *emojiTextArr;

@end

static dispatch_once_t onceToken;

@implementation NoaSensitiveManager

#pragma mark - 单例的实现
+ (instancetype)shareManager{
    static NoaSensitiveManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _manager = [[super allocWithZone:NULL] init];
        //初始化单例时加载本地敏感词库
        [_manager setupLocalSensitiveFilter];
    });
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaSensitiveManager shareManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaSensitiveManager shareManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaSensitiveManager shareManager];
}
#pragma mark - 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    onceToken = 0;
}


#pragma mark - 加载本地缓存的敏感词库
- (void)setupLocalSensitiveFilter {
    NSArray *wordList = [IMSDKManager toolGetSensitiveList];
    if (wordList == nil || wordList.count <= 0) {
        return;
    }
    
    // 直接重新创建root，避免removeAllObjects的崩溃风险
    self.root = [NSMutableDictionary dictionary];
    
    NSMutableArray<NSString *> *keyWordList = [NSMutableArray array];
    [wordList enumerateObjectsUsingBlock:^(LingIMSensitiveRecordsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = obj.decodeWordText;
        //插入字符，构造节点
        [keyWordList addObject:str];
    }];
    self.root = [self getSensitiveKeyWord:keyWordList];
}

/**
 * 构建敏感词库
 *
 * @param keyWordSet 敏感词集合
 * @return 返回构建好的词库（NSMutableDictionary）
 */
- (NSMutableDictionary *)getSensitiveKeyWord:(NSMutableArray<NSString *> *)keyWordSet {
    // 初始化词库字典，并指定容器大小（iOS 中没法直接指定 size，就使用可变字典）
    NSMutableDictionary *sensitiveWordMap = [NSMutableDictionary dictionaryWithCapacity:keyWordSet.count];
    
    // 用来保存当前处理的子字典
    NSMutableDictionary *nowMap = nil;
    // 用来辅助构建敏感词库
    NSMutableDictionary *newWordMap = nil;
    
    // 使用 NSEnumerator 遍历敏感词集合
    for (NSString *key in keyWordSet) {
        // 重新赋值，nowMap 可能会变
        nowMap = sensitiveWordMap;
        
        for (NSUInteger i = 0; i < key.length; i++) {
            unichar keyChar = [key characterAtIndex:i];
            NSString *charStr = [NSString stringWithCharacters:&keyChar length:1];
            
            // 判断该字是否已经在当前 Map 中
            NSMutableDictionary *wordMap = nowMap[charStr];
            if (wordMap != nil) {
                // 存在则指向该字典
                nowMap = wordMap;
            } else {
                // 不存在则新建一个字典
                newWordMap = [NSMutableDictionary dictionary];
                newWordMap[EXIST] = @(NO);
                nowMap[charStr] = newWordMap;
                nowMap = newWordMap;
            }
            
            // 如果是当前敏感词的最后一个字，标记为结尾
            if (i == key.length - 1) {
                nowMap[EXIST] = @(YES);
            }
        }
    }
    
    return sensitiveWordMap;
}

/**
 * 将输入文本中所有敏感词替换成 *
 * @param content 输入文本
 * @return 替换后的字符串
 */
- (NSString *)sensitiveFilter:(NSString *)content {
    if (self.isFilterClose || !self.root) {
        return content;
    }
    // 先过滤掉表情
    NSMutableString *result = [[self matchEmojiTextWithContent:content] mutableCopy];
    
    // 保存所有敏感词 range
    NSMutableArray<NSValue *> *ranges = [NSMutableArray array];
    NSUInteger contentLength = result.length;
    
    for (NSUInteger i = 0; i < contentLength; i++) {
        NSDictionary *nowMap = self.root;
        NSUInteger longestMatchLength = 0;
        
        for (NSUInteger j = i; j < contentLength; j++) {
            unichar c = [result characterAtIndex:j];
            NSString *charStr = [NSString stringWithCharacters:&c length:1];
            
            NSDictionary *nextMap = nowMap[charStr];
            if (nextMap == nil) {
                // 后续没匹配到，退出
                break;
            } else {
                nowMap = nextMap;
                
                if ([nowMap[EXIST] boolValue]) {
                    // 记录当前匹配到的最长长度
                    longestMatchLength = j - i + 1;
                }
            }
        }
        
        if (longestMatchLength > 0) {
            // 只记录最长匹配
            NSRange range = NSMakeRange(i, longestMatchLength);
            [ranges addObject:[NSValue valueWithRange:range]];
            // 跳过已匹配部分，防止重复
            i += (longestMatchLength - 1);
        }
    }
    
    // 替换内容。注意从后往前替换，防止 range 变化
    for (NSInteger i = ranges.count - 1; i >= 0; i--) {
        NSRange range = [ranges[i] rangeValue];
        NSMutableString *stars = [NSMutableString string];
        for (NSUInteger j = 0; j < range.length; j++) {
            [stars appendString:@"*"];
        }
        [result replaceCharactersInRange:range withString:stars];
    }
    
    return [self restoreEmojiTextWithFilerContent:result];
}

/// 匹配文本中的所有[表情]并记录其位置
- (NSString *)matchEmojiTextWithContent:(NSString *)aString {
    NSString *filterEmojiStr = [aString mutableCopy];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]"
                                  options:0
                                  error:&error];
    if (!error) {
        NSArray *matchs = [regex matchesInString:aString
                                         options:0
                                           range:NSMakeRange(0, [aString length])];
        [self.emojiTextArr removeAllObjects];
        for (NSTextCheckingResult *match in matchs) {
            NSString *result = [aString safeSubstringWithRange:match.range];
       
            NSDictionary *emojiTextDic = [NSDictionary dictionaryWithObject:result forKey:match];
            [self.emojiTextArr addObject:emojiTextDic];
            filterEmojiStr = [filterEmojiStr stringByReplacingOccurrencesOfString:result withString:@""];
        }
    }
    return filterEmojiStr;
}

- (NSString *)restoreEmojiTextWithFilerContent:(NSString *)aString {
    NSMutableString *restoreStr = [aString mutableCopy];
    for (NSDictionary *emojiTextDic in self.emojiTextArr) {
        NSTextCheckingResult *match = [emojiTextDic.allKeys firstObject];
        NSInteger localIndex = match.range.location;
        NSString *emojiStr = [emojiTextDic objectForKeySafe:match];
        [restoreStr insertString:emojiStr atIndex:localIndex];
    }
    [self.emojiTextArr removeAllObjects];
    return restoreStr;
}

- (void)freeFilter {
    self.root = nil;
}

- (void)stopFilter:(BOOL)b {
    self.isFilterClose = b;
}

#pragma mark - Lazy
//- (NSMutableArray *)sensitiveList {
//    if (!_sensitiveList) {
//        _sensitiveList = [NSMutableArray array];
//    }
//    return _sensitiveList;
//}

- (NSMutableDictionary *)root {
    if (!_root) {
        _root = [NSMutableDictionary dictionary];
    }
    return _root;
}

- (NSMutableArray *)emojiTextArr {
    if (!_emojiTextArr) {
        _emojiTextArr = [NSMutableArray array];
    }
    return _emojiTextArr;
}

@end
