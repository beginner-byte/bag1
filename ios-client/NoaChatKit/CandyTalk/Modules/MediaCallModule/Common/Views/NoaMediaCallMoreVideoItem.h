//
//  NoaMediaCallMoreVideoItem.h
//  NoaKit
//
//  Created by Candy on 2023/2/6.
//

#import <UIKit/UIKit.h>
#import "NoaMediaCallGroupMemberModel.h"
#import "NoaMediaCallMoreContentView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ZMediaCallMoreVideoItemDelegate <NSObject>
- (void)mediaCallMoreVideoItemDelete:(NoaMediaCallGroupMemberModel *)model;
@end

@interface NoaMediaCallMoreVideoItem : UICollectionViewCell
@property (nonatomic, strong) NoaMediaCallGroupMemberModel *model;
@property (nonatomic, strong) NoaMediaCallMoreContentView *viewContent;
@property (nonatomic, weak) id <ZMediaCallMoreVideoItemDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
