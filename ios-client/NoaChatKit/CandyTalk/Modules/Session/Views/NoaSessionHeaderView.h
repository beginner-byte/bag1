//
//  NoaSessionHeaderView.h
//  NoaKit
//
//  Created by Candy on 2026/11/2.
//

#import <UIKit/UIKit.h>
#import "NoaBaseImageView.h"
#import "NoaBaseCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaSessionHeaderView : UITableViewHeaderFooterView
@property (nonatomic, strong) NSMutableArray *sessionTopList;
@end


//H73
@interface NoaSessionHeaderItem : NoaBaseCollectionCell
@property (nonatomic, strong) NoaBaseImageView *ivHeader;
@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) LingIMSessionModel *sessionModel;
@end
NS_ASSUME_NONNULL_END
