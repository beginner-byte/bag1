//
//  NoaChatMultiSelectCell.h
//  NoaKit
//
//  Created by Candy on 2023/4/12.
//

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatMultiSelectCell : NoaBaseCell

- (void)configModelWith:(id)model indexPath:(NSIndexPath *)cellIndex searchStr:(NSString * _Nullable)searchStr;

@end

NS_ASSUME_NONNULL_END
