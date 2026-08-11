//
//  NoaTeamUpdateNameView.h
//  NoaKit
//
//  Created by Candy on 2023/11/7.
//

#import <UIKit/UIKit.h>
#import "NoaTeamModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ZTeamUpdateNameViewDelegate <NSObject>

- (void)teamUpdateNameAction:(NSString *)newName;

@end

@interface NoaTeamUpdateNameView : UIView

@property (nonatomic, strong) NoaTeamModel *model;
@property (nonatomic, weak) id <ZTeamUpdateNameViewDelegate> delegate;

- (void)updateViewShow;

@end

NS_ASSUME_NONNULL_END
