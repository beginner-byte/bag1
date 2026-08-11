//
//  NoaGroupManageCommonCell.h
//  NoaKit
//
//  Created by Candy on 2026/11/14.
//

#import "NoaBaseCell.h"
#import "LingIMGroup.h"
NS_ASSUME_NONNULL_BEGIN

//网络请求 上传图片、视频类型 表单提交

typedef NS_ENUM(NSUInteger, GroupManageCellType) {
    GroupManageCellCommon = 1,        //普通类型
    GroupManageCellSelect = 2,        //选择按钮
    GroupManageCellButton = 3,  //单独按钮
};
//背景试图圆角的分布位置
typedef NS_ENUM(NSUInteger, CornerRadiusLocationType) {
    CornerRadiusLocationAll = 1,        //四个角全部都是
    CornerRadiusLocationTop = 2,        //上边两个角是
    CornerRadiusLocationBottom = 3,  //下边两个角是
};


@interface NoaGroupManageCommonCell : NoaBaseCell
@property (nonatomic, strong) UIButton *viewBg;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIImageView *ivArrow;
@property (nonatomic, strong) UIButton *btnAction;
@property (nonatomic, strong) UIButton *btnCenter;
@property (nonatomic, strong) UIView *viewLine;
@property (nonatomic, strong) UIView *viewLineCenter;//邀请进群申请 前的横线

- (void)setCornerRadiusWithIsShow:(BOOL)isShow location:(CornerRadiusLocationType)locationType;

- (void)cellConfigWith:(GroupManageCellType)cellType itemStr:(NSString *)itemStr  model:(LingIMGroup *)model;


@end

NS_ASSUME_NONNULL_END
