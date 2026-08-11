//
//  NoaChatGitImgCollectionCell.h
//  NoaKit
//
//  Created by Candy on 2023/8/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatGitImgCollectionCellDelegate <NSObject>

- (void)collectionStickersLongTapAction:(NSIndexPath *)indexPath;

@end

@interface NoaChatGitImgCollectionCell : UICollectionViewCell

@property (nonatomic, strong) NSIndexPath *cellIndexPath;
@property (nonatomic, assign) NSInteger cellTotalIndex;
@property (nonatomic, strong) NoaIMStickersModel *collectModel;
@property (nonatomic, weak) id <ZChatGitImgCollectionCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
