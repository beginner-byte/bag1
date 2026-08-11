//
//  NoaFilePickModel.h
//  NoaKit
//
//  Created by Candy on 2023/1/31.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaFilePickModel : NoaBaseModel

/* 文件来源 */
@property (nonatomic, assign) ZMsgFileSourceType fileSource;

/* 相册视频 */
@property (nonatomic, strong) PHAsset *videoAsset;

/* App中的文件*/
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, assign) float fileSize;
@property (nonatomic, copy) NSString *filePath;

/* 手机中的文件*/
@property (nonatomic, strong) NSURL *phoneFileUrl;

/* 是否为选中状态*/
@property (nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
