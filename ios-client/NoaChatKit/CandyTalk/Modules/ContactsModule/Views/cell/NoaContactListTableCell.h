//
//  NoaContactListTableCell.h
//  NoaKit
//
//  Created by Candy on 2026/9/9.
//

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN


@interface NoaContactListTableCell : NoaBaseCell

@property (nonatomic, strong) LingIMFriendModel *friendModel;
@property (nonatomic, strong) UIView *viewOnline;

@end

NS_ASSUME_NONNULL_END
