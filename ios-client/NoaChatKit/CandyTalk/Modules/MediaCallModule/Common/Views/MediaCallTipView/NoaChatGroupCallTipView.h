//
//  NoaChatGroupCallTipView.h
//  NoaKit
//
//  Created by Candy on 2023/2/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatGroupCallTipView : UIView
@property (nonatomic, copy) NSString *groupID;//群组ID

- (void)updateUI;

@end

@interface NoaChatGroupMemberItem : UICollectionViewCell
@property (nonatomic, copy) NSString *userUid;
@property (nonatomic, strong) UIImageView *ivHeader;



@end
NS_ASSUME_NONNULL_END
