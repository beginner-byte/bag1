//
//  NoaChatInputEmojiManager.h
//  NoaKit
//
//  Created by Candy on 2026/10/12.
//

#import <Foundation/Foundation.h>

#define EMOJI [NoaChatInputEmojiManager sharedManager]

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatInputEmojiManager : NSObject
//表情列表
@property (nonatomic, strong, readonly) NSArray *emojiList;
@property (nonatomic, strong, readonly) NSDictionary *emojiDict;

// 单例
+ (instancetype)sharedManager;
// 单例一般不需要清空，但是在执行某些功能的时候，防止数据清空不及时可以清空一下
- (void)clearManager;

//匹配文本中的所有表情
- (NSArray *)matchEmoticons:(NSString *)aString;
//匹配输入框将要删除的表情
- (NSString *)willDeleteEmoticon:(NSString *)aString;
//文本转富文本
- (NSMutableAttributedString *)attributedString:(NSString *)aString;
- (NSMutableAttributedString *)yy_emojiAttributedString:(NSString *)aString;

//文本转富文本，置顶富文本图片大小
- (NSMutableAttributedString *)attributedString:(NSString *)aString imageRect:(CGRect)imageRect;
//富文本转文本
- (NSString *)stringWithAttributedString:(NSAttributedString *)attributedStr;

- (NSString *)version;

@end

NS_ASSUME_NONNULL_END
