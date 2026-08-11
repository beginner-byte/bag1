//
//  NoaChatSetGroupNoteCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/5.
//

// 群设置 - 群公告Cell

#import "NoaBaseCell.h"
#import "LingIMGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatSetGroupNoteCell : NoaBaseCell
@property (nonatomic, strong) LingIMGroup *groupModel;

@property (nonatomic, assign) BOOL isShowLine;
@end

NS_ASSUME_NONNULL_END
