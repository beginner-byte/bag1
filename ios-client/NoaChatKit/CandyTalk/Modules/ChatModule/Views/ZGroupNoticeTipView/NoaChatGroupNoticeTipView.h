//
//  NoaChatGroupNoticeTipView.h
//  NoaKit
//
//  Created by Candy on 2023/3/8.
//

// 聊天界面VC - 群公告提示 View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatGroupNoticeTipViewDelegate <NSObject>
//0 关闭 1 跳转公告页
- (void)groupNoticeTipAction:(NSInteger)actionTag;
@end

@interface NoaChatGroupNoticeTipView : UIView
@property (nonatomic, weak) id <ZChatGroupNoticeTipViewDelegate> delegate;
@property (nonatomic, strong) UILabel *lblGroupNotice;
@end

NS_ASSUME_NONNULL_END
