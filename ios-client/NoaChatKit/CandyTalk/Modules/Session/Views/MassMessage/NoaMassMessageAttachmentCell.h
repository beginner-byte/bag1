//
//  NoaMassMessageAttachmentCell.h
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

// 群发助手附件Cell

#import "NoaMassMessageBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMassMessageAttachmentCell : NoaMassMessageBaseCell
@property (nonatomic, strong) UIImageView *ivAttachment;//附件
@property (nonatomic, strong) UIImageView *ivPlay;//视频附件播放标志
@property (nonatomic, strong) UILabel *lblFileType;//文件附件 类型
@property (nonatomic, strong) UILabel *lblFileName;//文件附件 名字
@property (nonatomic, strong) UILabel *lblFileSize;//文件附件 大小
@end

NS_ASSUME_NONNULL_END
