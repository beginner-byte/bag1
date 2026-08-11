//
//  NoaMyCollectionModel.h
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaBaseModel.h"
#import "NoaMyCollectionItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMyCollectionModel : NoaBaseModel

//收藏内容的model
@property (nonatomic, strong) NoaMyCollectionItemModel *itemModel;
//富文本(消息内容)
@property (nonatomic, strong) NSMutableAttributedString * _Nullable attStr;
//内容的高度
@property (nonatomic, assign) CGFloat cellHeight;
//内容宽度
@property (nonatomic, assign) CGFloat itemWidth;
//内容高度
@property (nonatomic, assign) CGFloat itemHeight;
//消息是否是自己发送的
@property (nonatomic, assign) BOOL isSelf;

- (instancetype)initWithCollectionModel:(NoaMyCollectionItemModel *)itemModel;

@end

NS_ASSUME_NONNULL_END
