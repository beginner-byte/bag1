//
//  NoaImagePickerCell.h
//  NoaKit
//
//  Created by Candy on 2026/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZImagePickerCellDelegate <NSObject>
- (void)imagePickerCellSelected:(PHAsset *)asset;
- (void)imagePickerCellCamera;
@end

@interface NoaImagePickerCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *ivPhoto;
@property (nonatomic, strong) UIButton *btnSelect;
@property (nonatomic, assign)BOOL isHiddenSelect;//是否隐藏选中小圆圈
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, weak) id <ZImagePickerCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
