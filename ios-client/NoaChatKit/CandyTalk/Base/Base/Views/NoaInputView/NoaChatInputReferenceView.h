//
//  NoaChatInputReferenceView.h
//  NoaKit
//
//  Created by Candy on 2026/9/27.
//

// 聊天输入内容 引用 View 62固定高度

#import <UIKit/UIKit.h>
#import "NoaMessageModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ZChatInputReferenceViewDelegate <NSObject>
- (void)referenceViewClose;
@end

@interface NoaChatInputReferenceView : UIView

@property (nonatomic, strong)NoaMessageModel *referenceMsgModel;
@property (nonatomic, weak) id <ZChatInputReferenceViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
