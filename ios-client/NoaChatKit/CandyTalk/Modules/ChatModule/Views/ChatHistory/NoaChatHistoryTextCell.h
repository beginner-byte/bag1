//
//  NoaChatHistoryTextCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/14.
//

// 聊天历史 文本Cell

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatHistoryTextCell : NoaBaseCell
- (void)configCellWith:(NoaIMChatMessageModel *)chatMessageModel searchContent:(NSString *)searchStr;
@end

NS_ASSUME_NONNULL_END
