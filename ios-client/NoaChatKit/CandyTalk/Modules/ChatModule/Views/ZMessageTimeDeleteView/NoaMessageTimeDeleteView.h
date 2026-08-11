//
//  NoaMessageTimeDeleteView.h
//  NoaKit
//
//  Created by Candy on 2023/4/18.
//

// 消息定时删除View

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZMessageTimeDeleteViewDelegate <NSObject>
- (void)messageTimeDeleteType:(NSInteger)deleteType;
@end

@interface NoaMessageTimeDeleteView : UIView
//界面是否显示关闭操作
- (instancetype)initWithShowCloseView:(BOOL)showClose;
- (void)viewShow;
- (void)viewDismiss;

@property (nonatomic, weak) id <ZMessageTimeDeleteViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
