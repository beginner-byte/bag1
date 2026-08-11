//
//  NoaMediaCallVC.h
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

// 音视频通话 基类VC

#import "CandyBaseViewController.h"
#import "NoaMediaCallManager.h"
#import "NoaBaseImageView.h"
#import "NoaToolManager.h"//工具类
#import "NoaWindowFloatView.h"//浮窗控价
#import "NoaMediaCallFloatView.h"//单人音视频浮窗UI
#import "NoaMediaCallMoreFloatView.h"//多人音视频浮窗UI
#import "AppDelegate.h"
#import "NoaMediaCallVideoView.h"


NS_ASSUME_NONNULL_BEGIN

@interface NoaMediaCallVC : CandyBaseViewController
<
RoomDelegateObjC,
ZMediaCallManagerDelegate
>

//功能按钮
@property (nonatomic, strong) UIButton *btnMini;//最小化
@property (nonatomic, strong) UIButton *btnAccept;//被邀请者接听通话
@property (nonatomic, strong) UIButton *btnRefuse;//被邀请者拒绝通话
@property (nonatomic, strong) UIButton *btnEnd;//挂断通话(邀请者取消，邀请者挂断，被邀请者挂断)
@property (nonatomic, strong) UIButton *btnMutedAudio;//音频静默
@property (nonatomic, strong) UIButton *btnMutedVideo;//视频静默
@property (nonatomic, strong) UIButton *btnExternal;//免提
@property (nonatomic, strong) UIButton *btnCameraSwitch;//切换摄像头

//音视频房间加入
- (void)mediaCallRoomJoin;

//按钮显示动画
- (void)btnShowAnimationWith:(UIButton *)sender;
//按钮隐藏动画
- (void)btnHiddenAnimationWith:(UIButton *)sender;

//最小化
- (void)btnMiniClick;
//接听电话
- (void)btnAcceptClick;
//挂断电话
- (void)btnEndClick;
//音频静默
- (void)btnMutedAudioClick;
//视频静默
- (void)btnMutedVideoClick;
//免提
- (void)btnExternalClick;
//摄像头切换
- (void)btnCameraSwitchClick;

-(void)layoutBtn;
@end

NS_ASSUME_NONNULL_END
