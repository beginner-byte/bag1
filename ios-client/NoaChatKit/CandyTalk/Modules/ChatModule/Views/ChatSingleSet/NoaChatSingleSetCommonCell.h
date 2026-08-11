//
//  NoaChatSingleSetCommonCell.h
//  NoaKit
//
//  Created by Candy on 2026/12/29.
//

#import "NoaBaseCell.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ChatSingleSetCommonCellType) {
    ChatSingleSetCellTypeCommon = 1,        //普通类型
    ChatSingleSetCellTypeSelect = 2,        //选择按钮
    ChatSingleSetCellTypeText = 3,          //文本类型
};

//背景试图圆角的分布位置
typedef NS_ENUM(NSUInteger, CornerRadiusLocationType) {
    CornerRadiusLocationAll = 1,        //四个角全部都是
    CornerRadiusLocationTop = 2,        //上边两个角是
    CornerRadiusLocationBottom = 3,  //下边两个角是
};

@interface NoaChatSingleSetCommonCell : NoaBaseCell
@property (nonatomic, strong) UIButton *viewBg;
@property (nonatomic, strong) UILabel *lblTitle;//标题
@property (nonatomic, strong) UIImageView *ivArrow;
@property (nonatomic, strong) UIButton *btnAction;
@property (nonatomic, strong) UIButton *btnCenter;
@property (nonatomic, strong) UIView *viewLine;
@property (nonatomic, strong) UILabel *lblContent;//内容

- (void)setCornerRadiusWithIsShow:(BOOL)isShow location:(CornerRadiusLocationType)locationType;

- (void)cellConfigWith:(ChatSingleSetCommonCellType)cellType itemStr:(NSString *)itemStr  model:(LingIMFriendModel * _Nullable)model;
@end

NS_ASSUME_NONNULL_END
