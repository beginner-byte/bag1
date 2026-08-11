//
//  NoaChatTextUrlListView.h
//  NoaKit
//
//  Created by Candy on 2023/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatTextUrlListView : UIView

@property (nonatomic, copy) void(^textUrlClickBlock)(NSInteger clickIndex);

- (instancetype)initWithDataList:(NSArray *)dataList;
//界面显示/关闭操作
- (void)viewShow;
- (void)viewDismiss;

@end

NS_ASSUME_NONNULL_END
