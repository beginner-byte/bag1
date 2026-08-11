//
//  NoaChatImgEmojiToolsView.h
//  NoaKit
//
//  Created by Candy on 2023/8/10.
//

#import <UIKit/UIKit.h>
#import "SyncMutableArray.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZChatImgEmojiToolsViewDelegate <NSObject>
//选中
- (void)toolsViewSelectedIndex:(NSInteger)toolsIndex;

@end


@interface NoaChatImgEmojiToolsView : UIView

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSMutableArray *toolsItemList;
@property (nonatomic, weak) id <ZChatImgEmojiToolsViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
