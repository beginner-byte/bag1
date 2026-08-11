//
//  NoaChatHistoryMediaCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/14.
//

// 聊天历史 多媒体Cell

#import <UIKit/UIKit.h>
#import "NoaBaseImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatHistoryMediaCell : UICollectionViewCell
@property (nonatomic, copy)NSString *sessionID;
@property (nonatomic, strong) NoaIMChatMessageModel *chatMessageModel;

@property (nonatomic, strong) NoaBaseImageView *ivMedia;
@property (nonatomic, strong) UIView *viewVideo;
@property (nonatomic, strong) UIImageView *ivVideo;
@property (nonatomic, strong) UILabel *lblVideoTime;
@end

NS_ASSUME_NONNULL_END
