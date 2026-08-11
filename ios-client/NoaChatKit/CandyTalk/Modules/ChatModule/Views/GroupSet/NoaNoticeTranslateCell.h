//
//  NoaNoticeTranslateCell.h
//  NoaKit
//
//  Created by Candy on 2024/2/19.
//

#import "NoaBaseCell.h"
#import "NoaNoticeTranslateModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZNoticeTranslateCellDelegate <NSObject>

- (void)noticeTranslateSuccess:(NoaNoticeTranslateModel *)model indexPath:(NSIndexPath *)indexPath;
- (void)noticeTranslateFail:(NoaNoticeTranslateModel *)model indexPath:(NSIndexPath *)indexPath;
- (void)noticeTranslateEdit:(NoaNoticeTranslateModel *)model indexPath:(NSIndexPath *)indexPath;

@end

@interface NoaNoticeTranslateCell : NoaBaseCell

@property (nonatomic, strong) NoaNoticeTranslateModel *model;
@property (nonatomic, weak) id<ZNoticeTranslateCellDelegate>delegate;


@end

NS_ASSUME_NONNULL_END
