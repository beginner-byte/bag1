//
//  NoaMediaCallMoreContentView.h
//  NoaKit
//
//  Created by Candy on 2023/2/15.
//

// 多人音视频通话 展示 VideoView + 用户头像 的内容View

#import <UIKit/UIKit.h>
#import "NoaMediaCallSampleVideoView.h"
#import "NoaMediaCallGroupMemberModel.h"
#import "NoaToolManager.h"

//接口请求成功回调
typedef void (^MediaCallMoreContentBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface NoaMediaCallMoreContentView : UIView
@property (nonatomic, strong) NoaMediaCallSampleVideoView *sampleViewVideo;//视频通话 视频轨道渲染
@property (nonatomic, strong) UIView *viewAlpha;//透明背景
@property (nonatomic, strong) UIImageView *ivHeader;//头像
@property (nonatomic, strong) UILabel *lblNickname;//昵称
@property (nonatomic, strong) UILabel *lblTip;//提示
@property (nonatomic, strong) UIView *viewShimmer;//闪光动画

@property (nonatomic, strong) NoaMediaCallGroupMemberModel *model;
@property (nonatomic, copy) MediaCallMoreContentBlock deleteMemberBlock;//删除超时，离开的成员回调
@end

NS_ASSUME_NONNULL_END
