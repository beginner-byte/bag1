//
//  NoaChatMultiSelectTipsView.h
//  NoaKit
//
//  Created by Candy on 2023/4/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatMultiSelectTipsView : UIView

- (instancetype)initWithContent:(NSString *)content toAvatarList:(NSArray *)toAvatarList;

@property (nonatomic, copy)void(^sureClick)(void);

- (void)viewShow;
- (void)viewDismiss;

@end

NS_ASSUME_NONNULL_END
