//
//  NoaChatInputEmojiManager.m
//  NoaKit
//
//  Created by Candy on 2026/10/12.
//

#import "NoaChatInputEmojiManager.h"
#import <objc/runtime.h>
static dispatch_once_t onceToken;

#define EmojiVersion  @"1.0.0"

@interface NoaChatInputEmojiManager ()
// 所有表情
@property (nonatomic, strong) NSArray *emojiList;
@property (nonatomic, strong) NSDictionary *emojiDict;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation NoaChatInputEmojiManager

#pragma mark - 单例
+ (instancetype)sharedManager {
    static NoaChatInputEmojiManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 不再使用 alloc/init，而是调用 super allocWithZone:NULL
        _manager = [[super allocWithZone:NULL] init];
        _manager.lock = [NSLock new];
        [_manager loadAllEmoji];
    });
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaChatInputEmojiManager sharedManager];
}

// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaChatInputEmojiManager sharedManager];
}

// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaChatInputEmojiManager sharedManager];
}

#pragma mark - 运行时重新加载（线程安全）
- (void)reloadEmojis {
    [self.lock lock];
    [self loadAllEmoji];
    [self.lock unlock];
}
#pragma mark - 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager{
    onceToken = 0;
}
#pragma mark - 所有表情
- (void)loadAllEmoji {
    NSString *emojiPath = [[NSBundle mainBundle] pathForResource:@"NoaChatInputEmoji" ofType:@"plist"];
    NSArray *array = nil;
    if (emojiPath) {
        array = [[NSArray alloc] initWithContentsOfFile:emojiPath];
    }
    if (!array) {
        NSLog(@"[Emoji] plist not found at path: %@", emojiPath);
        self.emojiList = @[];
        self.emojiDict = @{};
        return;
    }
    
    
    // 解析模型数组（如果你使用 MJExtension 或类似库）
    @try {
        self.emojiList = [RecentsEmojiModel mj_objectArrayWithKeyValuesArray:[array copy]];
    } @catch (NSException *ex) {
        // 保护兼容性：如果解析失败，仍然保留原始 array
        NSLog(@"[Emoji] mj parse exception: %@", ex);
        self.emojiList = [array copy];
    }
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:array.count * 2];
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *zh_cn = obj[@"zhCN"]; // 可能是 "色眯眯" 或 "[色眯眯]"
        NSString *emojiName = obj[@"emojiName"]; // 图片名
        if (!zh_cn || !emojiName) return;
        
        
        // 标准化 rawKey（不带括号）
        NSString *rawKey = zh_cn;
        if (rawKey.length >= 2 && [rawKey hasPrefix:@"["] && [rawKey hasSuffix:@"]"]) {
            rawKey = [rawKey substringWithRange:NSMakeRange(1, rawKey.length - 2)];
        }
        
        
        NSString *bracketedKey = [NSString stringWithFormat:@"[%@]", rawKey];
        
        
        // 同时存 rawKey 和 [rawKey]，保证查找兼容
        if (rawKey.length > 0) dict[rawKey] = emojiName;
        dict[bracketedKey] = emojiName;
    }];
    
    
    self.emojiDict = [dict copy];
    NSLog(@"[Emoji] loaded %lu emoji keys", (unsigned long)self.emojiDict.count);
}

#pragma mark - 匹配文本中的所有表情
- (NSArray *)matchEmoticons:(NSString *)aString {
    if (!aString || aString.length == 0) return @[];
    NSMutableArray *emoticons = [[NSMutableArray alloc] initWithCapacity:0];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]"
                                  options:0
                                  error:&error];
    if (!error) {
        NSArray *matchs = [regex matchesInString:aString
                                         options:0
                                           range:NSMakeRange(0, [aString length])];
        for (NSTextCheckingResult *match in matchs) {
            NSString *result = [aString safeSubstringWithRange:match.range];
            if (!result || result.length == 0) continue;
            NSDictionary *dic = @{@"emoticon":result, @"range":NSStringFromRange(match.range)};
            [emoticons addObject:dic];
        }
    } else {
        NSLog(@"[Emoji] regex create error: %@", error);
    }
    return [emoticons copy];
}

#pragma mark - 匹配输入框将要删除的表情
- (NSString *)willDeleteEmoticon:(NSString *)aString {
    if (![aString isKindOfClass:[NSString class]] || aString.length == 0) return nil;
    if ([aString hasSuffix:@"]"]) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]"
                                      options:0
                                      error:&error];
        if (!error) {
            NSArray *matchs = [regex matchesInString:aString
                                             options:0
                                               range:NSMakeRange(0, [aString length])];
            NSTextCheckingResult *match = matchs.lastObject;
            if (match) {
                if (match.range.location + match.range.length == aString.length) {
                    NSString *result = [aString safeSubstringWithRange:match.range];
                    if (!result || result.length == 0) {
                        NSLog(@"[Emoji] willDeleteEmoticon: safeSubstring returned nil/empty for range %@ (len=%lu)", NSStringFromRange(match.range), (unsigned long)aString.length);
                        return nil;
                    }
                    return result;
                }
            }
        } else {
            NSLog(@"[Emoji] regex error in willDeleteEmoticon: %@", error);
        }
    }
    return nil;
}

#pragma mark - 富文本（默认图片 rect）
- (NSMutableAttributedString *)attributedString:(NSString *)aString {
    return [self attributedString:aString imageRect:CGRectMake(0, -4, 22, 22)];
}


#pragma mark - yy 富文本生成（使用 YYText 附件）
- (NSMutableAttributedString *)yy_emojiAttributedString:(NSString *)aString {
    if (aString.length == 0) return nil;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:aString];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]"
                                  options:0
                                  error:&error];
    if (error) {
        NSLog(@"[Emoji] regex error: %@", error);
        return attStr;
    }
    
    
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:aString options:0 range:NSMakeRange(0, aString.length)];
    // 逆序替换，避免索引偏移问题
    for (NSInteger i = matches.count - 1; i >= 0; --i) {
        NSTextCheckingResult *match = matches[i];
        NSRange r = match.range;
        NSString *result = [aString safeSubstringWithRange:r];
        if (!result || result.length == 0) {
            NSLog(@"[Emoji] safeSubstring returned nil/empty for range %@ (len=%lu)", NSStringFromRange(r), (unsigned long)aString.length);
            continue;
        }
        
        
        NSString *lookupKey = result;
        if (lookupKey.length >= 2 && [lookupKey hasPrefix:@"["] && [lookupKey hasSuffix:@"]"]) {
            lookupKey = [lookupKey substringWithRange:NSMakeRange(1, lookupKey.length - 2)];
        }
        
        
        NSString *imageName = self.emojiDict[lookupKey];
        if (!imageName) imageName = self.emojiDict[result];
        if (!imageName) {
            NSLog(@"[Emoji] no mapping for %@ (lookupKey=%@)", result, lookupKey);
            continue;
        }
        
        
        UIImage *image = [UIImage imageNamed:imageName];
        if (!image) {
            NSBundle *b = [NSBundle bundleForClass:[self class]];
            image = [UIImage imageNamed:imageName inBundle:b compatibleWithTraitCollection:nil];
        }
        if (!image) {
            NSLog(@"[Emoji] image not found for name: %@ (mapped from %@)", imageName, result);
            continue;
        }
        
        
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithEmojiImage:image fontSize:24];
        [attStr replaceCharactersInRange:r withAttributedString:attachText];
    }
    return attStr;
}

#pragma mark - 文本转富文本，置顶富文本图片大小
- (NSMutableAttributedString *)attributedString:(NSString *)aString imageRect:(CGRect)imageRect {
    if (aString.length == 0) return nil;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:aString];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]"
                                  options:0
                                  error:&error];
    if (error) {
        NSLog(@"[Emoji] regex error: %@", error);
        return attStr;
    }
    
    
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:aString options:0 range:NSMakeRange(0, aString.length)];
    for (NSInteger i = matches.count - 1; i >= 0; --i) {
        NSTextCheckingResult *match = matches[i];
        NSRange r = match.range;
        NSString *result = [aString safeSubstringWithRange:r];
        if (!result || result.length == 0) {
            NSLog(@"[Emoji] safeSubstring returned nil/empty for range %@ (len=%lu)", NSStringFromRange(r), (unsigned long)aString.length);
            continue;
        }
        
        
        NSString *lookupKey = result;
        if (lookupKey.length >= 2 && [lookupKey hasPrefix:@"["] && [lookupKey hasSuffix:@"]"]) {
            lookupKey = [lookupKey substringWithRange:NSMakeRange(1, lookupKey.length - 2)];
        }
        
        
        NSString *imageName = self.emojiDict[lookupKey];
        if (!imageName) imageName = self.emojiDict[result];
        
        
        if (!imageName) {
            NSLog(@"[Emoji] no mapping for %@ (lookupKey=%@)", result, lookupKey);
            continue;
        }
        
        
        UIImage *image = [UIImage imageNamed:imageName];
        if (!image) {
            NSBundle *b = [NSBundle bundleForClass:[self class]];
            image = [UIImage imageNamed:imageName inBundle:b compatibleWithTraitCollection:nil];
        }
        if (!image) {
            NSLog(@"[Emoji] image not found for name: %@ (mapped from %@)", imageName, result);
            continue;
        }
        
        
        [self setAttributedString:attStr image:image imageName:result rect:imageRect range:r];
    }
    return attStr;
}


#pragma mark - 富文本转文本
- (NSString *)stringWithAttributedString:(NSAttributedString *)attributedStr {
    if (!attributedStr) return @"";
    NSMutableString *newString = [NSMutableString new];
    
    
    [attributedStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedStr.length) options:0 usingBlock:^(id _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value) {
            NSTextAttachment *ment = value;
            NSString *emojiStr = [NSString stringWithFormat:@"%@", ment.accessibilityValue ?: @""];
            [newString appendString:emojiStr];
        } else {
            NSAttributedString *attStr = [attributedStr attributedSubstringFromRange:range];
            [newString appendString:[attStr string]];
        }
    }];
    
    
    return newString;
}


#pragma mark - private
- (void)setAttributedString:(NSMutableAttributedString *)attributedString image:(UIImage *)image imageName:(NSString *)imageName rect:(CGRect)rect range:(NSRange)range{
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = rect;
    // 存储原始文本（如 "[色眯眯]"）到 accessibilityValue，便于转回文本
    attachment.accessibilityValue = imageName ? imageName : @""; // 这里按原逻辑可以考虑存 imageName 或原文本
    NSAttributedString *attStr = [NSAttributedString attributedStringWithAttachment:attachment];
    [attributedString replaceCharactersInRange:range withAttributedString:attStr];
}


- (NSString *)version {
    return EmojiVersion;
}

@end
