//
//  NoaCollectionMenuView.h
//  NoaKit
//
//  Created by Candy on 2024/8/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaCollectionMenuView : UIView

@property (nonatomic, copy) void(^menuClickBlock)(void);

- (instancetype)initWithMenuTitle:(NSString *)menuTitle rect:(CGRect)rect;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
