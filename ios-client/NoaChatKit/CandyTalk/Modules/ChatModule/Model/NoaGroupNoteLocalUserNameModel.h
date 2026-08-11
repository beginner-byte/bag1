//
//  NoaGroupNoteLocalUserNameModel.h
//  NoaKit
//
//  Created by phl on 2025/8/12.
//

#import "NoaGroupNoteModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupNoteLocalUserNameModel : NoaGroupNoteModel

@property (nonatomic, copy) NSString *localCacheUserName;

@property (nonatomic, copy) NSString *showContent;

/// 获取文本展示高度
- (CGFloat)getTextViewHeight;

/// 获取cell高度
- (CGFloat)getCellHeight;

/// 是否置顶
- (BOOL)isTop;

@end

NS_ASSUME_NONNULL_END
