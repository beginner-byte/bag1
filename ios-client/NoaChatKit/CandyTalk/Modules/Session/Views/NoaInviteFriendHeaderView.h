//
//  NoaInviteFriendHeaderView.h
//  NoaKit
//
//  Created by Candy on 2024/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaInviteFriendHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) void (^selectAllCallback)(bool);
@property (nonatomic, copy) void (^openCallback)(bool);
@property (nonatomic, copy)NSString *contentStr;
@property (nonatomic, assign)BOOL isSelected;
@property (nonatomic, assign) bool isOpen;
@end

NS_ASSUME_NONNULL_END
