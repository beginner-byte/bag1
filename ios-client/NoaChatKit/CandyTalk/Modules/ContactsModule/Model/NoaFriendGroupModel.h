//
//  NoaFriendGroupModel.h
//  NoaKit
//
//  Created by Candy on 2023/7/5.
//

#import "NoaBaseModel.h"
#import "NoaFriendModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaFriendGroupModel : NoaBaseModel
//好友分组信息
@property (nonatomic, strong) LingIMFriendGroupModel *friendGroupModel;
//好友分组下的 好友列表
@property (nonatomic, strong) NSMutableArray <NoaFriendModel *> *friendList;
@property (nonatomic, strong) NSMutableArray <NoaFriendModel *> *friendOnLineList;//在线
@property (nonatomic, strong) NSMutableArray <NoaFriendModel *> *friendOffLineList;//离线
@property (nonatomic, strong) NSMutableArray <NoaFriendModel *> *friendSignOutList;//注销
//好友分组 是否展开
@property (nonatomic, assign) BOOL openedSection;
@end

NS_ASSUME_NONNULL_END
