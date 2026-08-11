//
//  NoaMessageMultiBottomView.h
//  NoaKit
//
//  Created by Candy on 2023/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZMsgMultiSelectDelegate <NSObject>

- (void)mergeForwardMessageAction;
- (void)singleForwardMessageAction;
- (void)deleteSelectedMessageAction;

@end

@interface NoaMessageMultiBottomView : UIView

@property (nonatomic, assign)NSInteger selectNum;
@property (nonatomic, weak) id <ZMsgMultiSelectDelegate> delegate;

- (void)reloadShowMultiBottom;

@end

NS_ASSUME_NONNULL_END
