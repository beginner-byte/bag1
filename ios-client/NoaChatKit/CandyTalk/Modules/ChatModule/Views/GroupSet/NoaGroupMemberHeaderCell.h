//
//  NoaGroupMemberHeaderCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/5.
//

// 群成员头像Cell

#import <UIKit/UIKit.h>
#import <NoaChatCore/LingIMGroupMemberModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupMemberHeaderCell : UICollectionViewCell
/// 配置群成员信息
/// @param memberModel 群成员
/// @param addMember 添加或删除群成员
- (void)configCellWith:(LingIMGroupMemberModel * _Nullable)memberModel action:(BOOL)addMember;
@property (nonatomic, assign) BOOL addMember;
@end

NS_ASSUME_NONNULL_END
