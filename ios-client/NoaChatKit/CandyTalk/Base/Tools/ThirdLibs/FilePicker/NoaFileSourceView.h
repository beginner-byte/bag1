//
//  NoaFileSourceView.h
//  NoaKit
//
//  Created by Candy on 2023/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaFileSourceView : UIView

@property (nonatomic, copy)void(^selectClick)(NSInteger index);
@property (nonatomic, copy)void(^dismissClick)(void);

- (void)showSourceView;

@end

NS_ASSUME_NONNULL_END
