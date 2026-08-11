//
//  NoaFilePickerCell.h
//  NoaKit
//
//  Created by Candy on 2023/1/4.
//

#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaFilePickerCell : NoaBaseCell

@property (nonatomic, strong)PHAsset *videoAsset;

@property (nonatomic, copy)NSString *showName;
@property (nonatomic, copy)NSString *localFileType;
@property (nonatomic, assign)float localFileSize;

@property (nonatomic, assign)BOOL isSelected;

@property (nonatomic, assign)float currentFileSize;

@end

NS_ASSUME_NONNULL_END
