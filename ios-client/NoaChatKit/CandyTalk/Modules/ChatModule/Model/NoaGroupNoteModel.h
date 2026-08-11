//
//  NoaGroupNoteModel.h
//  NoaKit
//
//  Created by Candy on 2026/11/9.
//

// 群公告model

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupNoteModel : NoaBaseModel
@property (nonatomic, copy) NSString *groupId;//群ID
@property (nonatomic, copy) NSString *noticeCreateNickname;//群公告创建者
@property (nonatomic, copy) NSString *content;//群公告内容
@property (nonatomic, copy) NSString *translateContent;//群公告内容(译文)
@property (nonatomic, copy) NSString *createTime;//群公告创建时间
@property (nonatomic, copy) NSString *status;//状态 0删除 1正常
@property (nonatomic, copy) NSString *noticeId;//群公告Id
@property (nonatomic, copy) NSString *topStatus;//置顶状态 0未置顶 1置顶

@property (nonatomic, copy) NSString *noticeCreateUid;//群公告创建者ID
@property (nonatomic, copy) NSString *noticeUpdateName;//群公告更新者
@property (nonatomic, copy) NSString *noticeUpdateUid;//群公告更新者ID
@property (nonatomic, copy) NSString *noticeUuid;//公告uuid
@property (nonatomic, copy) NSString *modifyTime;//修改时间
@property (nonatomic, copy) NSString *readStatus;//已读状态 0未读 1已读
@property (nonatomic, copy) NSString *type;//1普通公告
@property (nonatomic, copy) NSString *userHeader;//创建/修改者头像


@end

NS_ASSUME_NONNULL_END
