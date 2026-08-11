//
//  NoaCallGroupVC.m
//  NoaKit
//
//  Created by Candy on 2023/5/30.
//

#import "NoaCallGroupVC.h"
#import "SyncMutableArray.h"
#import "NoaMediaCallShimmerView.h"
#import "NoaMediaCallMoreVideoItem.h"
#import "NoaMediaCallMoreInviteVC.h"
#import "NoaMediaCallGroupMemberModel.h"
#import "NoaMediaCallMoreLayout.h"
#import "NoaMediaCallMoreContentView.h"
#import "NoaCallGroupFloatView.h"
#import "UIButton+Gradient.h"

@interface NoaCallGroupVC () <UICollectionViewDataSource, UICollectionViewDelegate, ZMediaCallMoreVideoItemDelegate>
{
    dispatch_queue_t _callMemberQueue;
}
//我是 群聊 被邀请者 显示邀请者信息 UI
@property (nonatomic, strong) UIView *viewBaseBg;//被邀请者UI
@property (nonatomic, strong) NoaCallUserModel *inviterUserModel;//邀请者用户信息
@property (nonatomic, strong) NoaBaseImageView *ivHeaderBg;//对方头像模糊背景
@property (nonatomic, strong) NoaBaseImageView *ivHeader;//对方头像
@property (nonatomic, strong) UILabel *lblNickname;//对方昵称
@property (nonatomic, strong) UILabel *lblCallTip;//会话提示
@property (nonatomic, strong) NoaMediaCallShimmerView *viewShimmer;//闪光效果

//群聊 接通后 / 我是 群聊 发起者 UI
@property (nonatomic, strong) UIView *viewCallBg;//通话UI
@property (nonatomic, strong) UIButton *btnInvite;//邀请按钮
@property (nonatomic, strong) UIView *viewCollectionBg;//通话界面背景

@property (nonatomic, strong) UICollectionView *collectionViewCall;//通话界面
@property (nonatomic, strong) SyncMutableArray *callUserList;//通话参与者列表
@property (nonatomic, strong) NoaMediaCallMoreLayout *layoutV;//垂直方向布局
@property (nonatomic, strong) UICollectionViewFlowLayout *layoutH;//水平方向布局

@property (nonatomic, strong) UIButton *btnBig;//放大成员点击按钮
@property (nonatomic, strong) NoaMediaCallGroupMemberModel *modelBig;//放大的model
@property (nonatomic, strong) NoaMediaCallMoreContentView *viewBig;

@property (nonatomic, strong) UILabel *lblTime;//会话进行的时间

@property (nonatomic, strong) NoaCallUserModel *localUserModel;//本地用户信息(我)
@end

@implementation NoaCallGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _callUserList = [SyncMutableArray new];
    
    //队列初始化
    _callMemberQueue = dispatch_queue_create("com.CIMKit.callMemberQueue", DISPATCH_QUEUE_SERIAL);
    
    //获取本地和远端用户信息
    WeakSelf
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    [currentCallOptions.callMemberList enumerateObjectsUsingBlock:^(NoaCallUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userUid isEqualToString:UserManager.userInfo.userUID]) {
            weakSelf.localUserModel = obj;
            *stop = YES;
        }
            
    }];
    
    
    [self notificationObserver];
    
    [self setupGroupCallUI];
    
    [self updateGroupCallUIWithCallState];
    
    [self updateGroupCallUIWithUserModel];
    
    [self updateGroupCallUIWithMembers];
    
    //根据推流功能状态，设置按钮状态
    [self updateBtnStateWithLoacalUserModel];
}
#pragma mark - 界面布局
- (void)setupGroupCallUI {
    
    //基本UI相关实现
    self.view.tkThemebackgroundColors = @[COLOR_66,COLOR_66_DARK];
    
    _viewBaseBg = [[UIView alloc] initWithFrame:self.view.bounds];
    _viewBaseBg.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
    [self.view addSubview:_viewBaseBg];
    
    _viewCallBg = [[UIView alloc] initWithFrame:self.view.bounds];
    _viewCallBg.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
    [self.view addSubview:_viewCallBg];
    
    //具体的UI相关实现
    //模糊头像背景
    _ivHeaderBg = [[NoaBaseImageView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight)];
    toolbar.barStyle = UIBarStyleBlack;
    [_ivHeaderBg addSubview:toolbar];
    [_viewBaseBg addSubview:_ivHeaderBg];
    
    //对方头像
    _ivHeader = [[NoaBaseImageView alloc] initWithImage:DefaultAvatar];
    _ivHeader.layer.cornerRadius = DWScale(44);
    _ivHeader.layer.masksToBounds = YES;
    [_viewBaseBg addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(DWScale(246));
        make.size.mas_equalTo(CGSizeMake(DWScale(88), DWScale(88)));
    }];
    
    //对方昵称
    _lblNickname = [UILabel new];
    _lblNickname.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblNickname.font = FONTM(24);
    [_viewBaseBg addSubview:_lblNickname];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_ivHeader.mas_bottom).offset(DWScale(24));
        make.leading.equalTo(self.view.mas_leading).offset(16);
    }];
    _lblNickname.numberOfLines = 2;
    _lblNickname.textAlignment = NSTextAlignmentCenter;

    //会话提示信息
    _lblCallTip = [UILabel new];
    _lblCallTip.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblCallTip.font = FONTR(14);
    [_viewBaseBg addSubview:_lblCallTip];
    [_lblCallTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_lblNickname.mas_bottom).offset(DWScale(16));
    }];
    
    //闪光效果
    _viewShimmer = [NoaMediaCallShimmerView new];
    [_viewBaseBg addSubview:_viewShimmer];
    [_viewShimmer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_viewBaseBg);
        make.top.equalTo(_lblCallTip.mas_bottom).offset(DWScale(15));
        make.height.mas_equalTo(DWScale(10));
    }];
    
    _lblTime = [[UILabel alloc] initWithFrame:CGRectMake(DWScale(60), DStatusBarH, DScreenWidth - DWScale(120), DWScale(24))];
    _lblTime.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblTime.font = FONTR(17);
    _lblTime.textAlignment = NSTextAlignmentCenter;
    [_viewCallBg addSubview:_lblTime];
    
    _btnInvite = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnInvite.frame = CGRectMake(DScreenWidth - DWScale(42), DStatusBarH, DWScale(24), DWScale(24));
    [_btnInvite setImage:ImgNamed(@"ms_btn_invite") forState:UIControlStateNormal];
    [_btnInvite addTarget:self action:@selector(btnInviteClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewCallBg addSubview:_btnInvite];
    
    _viewCollectionBg = [[UIView alloc] initWithFrame:CGRectMake(0, DStatusBarH + DWScale(40), DScreenWidth, DScreenWidth + (DScreenWidth - DWScale(20)) / 4.0)];
    _viewCollectionBg.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
    [_viewCallBg addSubview:_viewCollectionBg];
    
    _btnBig = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnBig.hidden = YES;
    _btnBig.frame = CGRectMake(DWScale(2), DWScale(2), DScreenWidth - DWScale(4), DScreenWidth - DWScale(4));
    [_btnBig addTarget:self action:@selector(btnBigClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewCollectionBg addSubview:_btnBig];
    
    
    _collectionViewCall = [[UICollectionView alloc] initWithFrame:CGRectMake(DWScale(2), 0, DScreenWidth - DWScale(4), DScreenWidth - DWScale(4)) collectionViewLayout:self.layoutV];
    _collectionViewCall.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
    _collectionViewCall.dataSource = self;
    _collectionViewCall.delegate = self;
    [_collectionViewCall registerClass:[NoaMediaCallMoreVideoItem class] forCellWithReuseIdentifier:NSStringFromClass([NoaMediaCallMoreVideoItem class])];
    [_viewCollectionBg addSubview:_collectionViewCall];
    
    self.btnMini.frame = CGRectMake(DWScale(18), DStatusBarH, DWScale(24), DWScale(24));
    [self.view addSubview:self.btnMini];
    
    //当前通话信息
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
        
        //音频通话
        [self.view addSubview:self.btnMutedAudio];//音频静默
        [self.view addSubview:self.btnExternal];//免提
        [self.view addSubview:self.btnEnd];//挂断(包含文字)
        [self.view addSubview:self.btnRefuse];//拒绝(包含文字)
        [self.view addSubview:self.btnAccept];//接受(包含文字)
        
        [self.btnEnd setTitle:LanguageToolMatch(@"挂断") forState:UIControlStateNormal];
        [self.btnEnd setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [self.btnEnd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        
        [self.btnMutedAudio mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.btnEnd);
            make.leading.equalTo(self.view).offset(DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        
        [self.btnExternal mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.btnEnd);
            make.trailing.equalTo(self.view).offset(-DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        
        [self.btnRefuse setTitle:LanguageToolMatch(@"拒绝") forState:UIControlStateNormal];
        [self.btnRefuse setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [self.btnRefuse mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(DWScale(70));
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        
        [self.btnAccept setTitle:LanguageToolMatch(@"接听") forState:UIControlStateNormal];
        [self.btnAccept setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(10)];
        [self.btnAccept mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.view).offset(-DWScale(70));
            make.bottom.equalTo(self.view).offset(-DHomeBarH - DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(85)));
        }];
        
    }else {
        
        //视频通话
        [self.view addSubview:self.btnMutedAudio];//静音
        [self.view addSubview:self.btnMutedVideo];//摄像头
        [self.view addSubview:self.btnCameraSwitch];//切换摄像头
        [self.view addSubview:self.btnEnd];//挂断(包含文字)
        [self.view addSubview:self.btnRefuse];//拒绝(不含文字)
        [self.view addSubview:self.btnAccept];//接受(不含文字)
        
        [self.btnEnd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.btnMutedAudio);
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(90)));
            make.bottom.equalTo(self.view).offset(-DWScale(20) - DHomeBarH);
        }];
        
        [self.btnRefuse mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(DWScale(67));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(60)));
            make.bottom.equalTo(self.view).offset(-DWScale(20) - DHomeBarH);
        }];
        
        [self.btnAccept mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.view).offset(-DWScale(67));
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(60)));
            make.bottom.equalTo(self.view).offset(-DWScale(20) - DHomeBarH);
        }];
        
        [self.btnMutedAudio mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.btnEnd.mas_top).offset(-DWScale(30));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(105)));
        }];
        
        [self.btnMutedVideo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.btnEnd.mas_top).offset(-DWScale(30));
            make.leading.equalTo(self.view).offset(DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(105)));
        }];
        
        [self.btnCameraSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.btnEnd.mas_top).offset(-DWScale(30));
            make.trailing.equalTo(self.view).offset(-DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(105)));
        }];
    }
    [self layoutBtn];

}

//根据通话状态创建UI
- (void)updateGroupCallUIWithCallState {
    //当前通话信息
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    if ([NoaCallManager sharedManager].callState == ZCallStateCalling) {
        //当前通话已连接成功
        
        _viewCallBg.hidden = NO;
        _viewBaseBg.hidden = YES;
        
        if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            if (![currentCallOptions.inviterUserModel.userUid isEqualToString:UserManager.userInfo.userUID]) {
                //被邀请者
                [self btnHiddenAnimationWith:self.btnRefuse];//隐藏拒绝按钮
                [self btnHiddenAnimationWith:self.btnAccept];//隐藏接受按钮
            }
            [self btnShowAnimationWith:self.btnMutedAudio];
            [self btnShowAnimationWith:self.btnEnd];
            [self btnShowAnimationWith:self.btnExternal];
        }else {
            //视频通话
            if (![currentCallOptions.inviterUserModel.userUid isEqualToString:UserManager.userInfo.userUID]) {
                //被邀请者
                [self btnHiddenAnimationWith:self.btnRefuse];//隐藏拒绝按钮
                [self btnHiddenAnimationWith:self.btnAccept];//隐藏接受按钮
            }
            self.btnCameraSwitch.enabled = YES;
            [self btnShowAnimationWith:self.btnMutedVideo];
            [self btnShowAnimationWith:self.btnMutedAudio];
            [self btnShowAnimationWith:self.btnCameraSwitch];
            [self btnShowAnimationWith:self.btnEnd];
            
            //开启扬声器
            [[NoaCallManager sharedManager] callRoomSpeakerMute:NO];
        }
        
        
    }else {
        //当前通话未连接成功
        
        if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            if (![currentCallOptions.inviterUserModel.userUid isEqualToString:UserManager.userInfo.userUID]) {
                //被邀请方
                _lblCallTip.text = LanguageToolMatch(@"邀请你进行语音通话");
                [self btnShowAnimationWith:self.btnRefuse];
                [self btnShowAnimationWith:self.btnAccept];
                _viewCallBg.hidden = YES;
                _viewBaseBg.hidden = NO;
            }else {
                //邀请方
                [self btnShowAnimationWith:self.btnMutedAudio];
                [self btnShowAnimationWith:self.btnEnd];
                [self btnShowAnimationWith:self.btnExternal];
                _viewCallBg.hidden = NO;
                _viewBaseBg.hidden = YES;
            }
        }else {
            //视频通话
            if (![currentCallOptions.inviterUserModel.userUid isEqualToString:UserManager.userInfo.userUID]) {
                //被邀请方
                _lblCallTip.text = LanguageToolMatch(@"邀请你进行视频通话");
                [self btnShowAnimationWith:self.btnRefuse];
                [self btnShowAnimationWith:self.btnAccept];
                _viewCallBg.hidden = YES;
                _viewBaseBg.hidden = NO;
            }else {
                //邀请方
                [self btnShowAnimationWith:self.btnEnd];
                _viewCallBg.hidden = NO;
                _viewBaseBg.hidden = YES;
            }
            self.btnCameraSwitch.enabled = NO;
            [self btnShowAnimationWith:self.btnMutedVideo];
            [self btnShowAnimationWith:self.btnMutedAudio];
            [self btnShowAnimationWith:self.btnCameraSwitch];
        }
    }
}

//更新对方的用户信息UI(邀请者的信息)
- (void)updateGroupCallUIWithUserModel {
    NoaCallUserModel *inviterUserModel = [NoaCallManager sharedManager].currentCallOptions.inviterUserModel;
    if (![inviterUserModel.userUid isEqualToString:UserManager.userInfo.userUID]) {
        //我是被邀请者，此处，展示邀请者的信息
        //头像
        [_ivHeaderBg sd_setImageWithURL:[inviterUserModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        [_ivHeader sd_setImageWithURL:[inviterUserModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        
        //昵称
        _lblNickname.text = inviterUserModel.userShowName;
        
    }
}

//更新群聊成员状态信息
- (void)updateGroupCallUIWithMembers {
    WeakSelf
    dispatch_async(self->_callMemberQueue, ^{
        
        //先清空数据
        [weakSelf.callUserList removeAllObjects];
        
        //当前音视频通话房间成员
        NSArray *currentCallMemberList = [NoaCallManager sharedManager].currentCallOptions.callMemberList;
        
        [currentCallMemberList enumerateObjectsUsingBlock:^(NoaCallUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NoaMediaCallGroupMemberModel *model = [NoaMediaCallGroupMemberModel new];
            model.memberState = obj.callState;//用户通话状态
            model.callType = [NoaCallManager sharedManager].currentCallOptions.zgCallOptions.callType;//通话类型
            model.userUid = obj.userUid;//用户ID
            model.groupID = [NoaCallManager sharedManager].currentCallOptions.groupID;//群组ID
            model.callUserModel = obj;//即构 用户信息
            if ([weakSelf.modelBig.userUid isEqualToString:obj.userUid]) {
                //如果此时有放大用户，更新放大用户的信息
                weakSelf.modelBig = model;
            }else {
                [weakSelf.callUserList addObject:model];
            }
        }];
        
        [ZTOOL doInMain:^{
            
            [weakSelf.collectionViewCall reloadData];
            
            if (weakSelf.modelBig) {
                //更新大图UI
                weakSelf.viewBig.model = weakSelf.modelBig;
                switch (weakSelf.modelBig.memberState) {
                    case ZCallUserStateTimeOut:
                    case ZCallUserStateRefuse:
                    case ZCallUserStateHangup:
                    case ZCallUserStateCancel:
                    {
                        //被放大的用户离开了房间
                        weakSelf.modelBig = nil;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf btnBigClick];
                        });
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
        }];
        
        
    });
    
}

//根据推流功能状态，设置按钮状态
- (void)updateBtnStateWithLoacalUserModel {
    if ([NoaCallManager sharedManager].callState == ZCallStateCalling) {
        //当前正在通话中
        //麦克风
        LingIMCallMicrophoneMuteState micState = _localUserModel.micState;
        self.btnMutedAudio.selected = micState == LingIMCallMicrophoneMuteStateOn ? YES : NO;
        
        if ([NoaCallManager sharedManager].currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
            //扬声器
            LingIMCallSpeakerMuteState speakerState = _localUserModel.speakerState;
            self.btnExternal.selected = speakerState == LingIMCallSpeakerMuteStateOn ? NO : YES;
            [[NoaCallManager sharedManager] callRoomSpeakerMute:speakerState == LingIMCallSpeakerMuteStateOn ? YES : NO];
        }else {
            //摄像头
            LingIMCallCameraMuteState cameraState = _localUserModel.cameraState;
            self.btnMutedVideo.selected = cameraState == LingIMCallCameraMuteStateOn ? YES : NO;
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"******当前个数%ld",_callUserList.count);
    return _callUserList.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaMediaCallMoreVideoItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaMediaCallMoreVideoItem class]) forIndexPath:indexPath];
    NoaMediaCallGroupMemberModel *model = [_callUserList objectAtIndex:indexPath.row];
    item.model = model;
    item.delegate = self;
    return item;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaMediaCallGroupMemberModel *selectModel = [_callUserList objectAtIndex:indexPath.row];
    
    //将要离开的用户，不进行放大的效果了，因为可能还没放大呢，就需要UI上移除了，如果需要修改，就需要在移除离开成员的位置，做一下判断，当前需要离开的人是否是放大状态
    if (selectModel.memberState > 1) return;
    
    WeakSelf
    CGFloat itemW = (DScreenWidth - DWScale(20)) / 4.0;
    
    if (_modelBig) {
        //需要先缩放动画，在执行放大动画
        
        dispatch_async(self->_callMemberQueue, ^{
            [ZTOOL doInMain:^{
                
                //将放大控件加入列表展示
                [weakSelf.callUserList addObject:weakSelf.modelBig];
                [weakSelf.collectionViewCall reloadData];
                //移除放大
                [UIView animateWithDuration:0.3 animations:^{
                    weakSelf.viewBig.frame = CGRectMake(0, DScreenWidth - DWScale(4), itemW, itemW);
                } completion:^(BOOL finished) {
                    [weakSelf.viewBig removeFromSuperview];
                    weakSelf.viewBig = nil;
                    //展示新的放大效果
                    [weakSelf showBigMemberWith:selectModel];
                }];
                
            }];
            
        });
        
    } else {
        
        
        if ([_collectionViewCall.collectionViewLayout isEqual:self.layoutV]) {
            
            //修改为横向滚动
            [_collectionViewCall setCollectionViewLayout:self.layoutH animated:YES];
            
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.collectionViewCall.frame = CGRectMake(DWScale(2), DScreenWidth - DWScale(4), DScreenWidth - DWScale(4), itemW);
            } completion:^(BOOL finished) {
                //执行放大动画
                [weakSelf showBigMemberWith:selectModel];
            }];
        }
        
    }
    
}
- (void)showBigMemberWith:(NoaMediaCallGroupMemberModel *)selectModel {
    WeakSelf
    dispatch_async(self->_callMemberQueue, ^{
        
        [weakSelf.callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *selectUid = [NSString stringWithFormat:@"%@", selectModel.userUid];
            NSString *objUid = [NSString stringWithFormat:@"%@", obj.userUid];
            if ([selectUid isEqualToString:objUid]) {
                
                [ZTOOL doInMain:^{
                    NoaMediaCallMoreVideoItem *cell = (NoaMediaCallMoreVideoItem *)[weakSelf.collectionViewCall cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    CGRect selectRect = [cell convertRect:cell.viewContent.frame toView:weakSelf.viewCollectionBg];
                    weakSelf.viewBig = [NoaMediaCallMoreContentView new];
                    weakSelf.viewBig.model = obj;
                    weakSelf.viewBig.frame = selectRect;
                    [weakSelf.viewCollectionBg addSubview:weakSelf.viewBig];
                    [weakSelf.viewCollectionBg bringSubviewToFront:weakSelf.btnBig];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        weakSelf.viewBig.frame = CGRectMake(DWScale(2), 0, DScreenWidth - DWScale(4), DScreenWidth - DWScale(4));
                    } completion:^(BOOL finished) {
                        weakSelf.modelBig = obj;
                        [weakSelf.callUserList removeObjectAtIndex:idx];
                        weakSelf.btnBig.hidden = NO;
                        [weakSelf.collectionViewCall reloadData];
                        
                    }];
                    
                }];
                
                
                *stop = YES;
            }
        }];
        
    });
    
}
#pragma mark - ZMediaCallMoreVideoItemDelegate
- (void)mediaCallMoreVideoItemDelete:(NoaMediaCallGroupMemberModel *)model {
    if (model) {
        
        WeakSelf
        dispatch_async(self->_callMemberQueue, ^{
            
            NSString *userUid = [NSString stringWithFormat:@"%@", model.userUid];
            
            //界面数据列表删除
            [weakSelf.callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *objUserUid = [NSString stringWithFormat:@"%@", obj.userUid];
                if ([userUid isEqualToString:objUserUid]) {
                    //已包含该用户，删除，更新
                    if (idx < weakSelf.callUserList.count) {
                        [weakSelf.callUserList removeObjectAtIndex:idx];
                        //******
                    }
                    *stop = YES;
                }
            }];
            
            //通话单例维护的列表删除
            NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
            __block NSMutableArray *tempCallMemberList = [NSMutableArray arrayWithArray:currentCallOptions.callMemberList];
            [tempCallMemberList enumerateObjectsUsingBlock:^(NoaCallUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *objUserUid = [NSString stringWithFormat:@"%@", obj.userUid];
                if ([userUid isEqualToString:objUserUid]) {
                    //删除该用户
                    [tempCallMemberList removeObjectAtIndexSafe:idx];
                    *stop = YES;
                }
            }];
            currentCallOptions.callMemberList = tempCallMemberList;
            
            //延迟1.0秒后移除相关成员UI
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.collectionViewCall reloadData];
            });
            
        });
    }
}

#pragma mark - 交互事件
//最小化
- (void)btnMiniClick {
    NoaWindowFloatView *viewMediaCall = [[NoaWindowFloatView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH, DWScale(86), DWScale(101))];
    viewMediaCall.isKeepBounds = YES;
    [CurrentWindow addSubview:viewMediaCall];

    NoaCallGroupFloatView *viewFloat = [[NoaCallGroupFloatView alloc] initWithFrame:CGRectMake(0, 0, DWScale(86), DWScale(101))];
    [viewMediaCall addSubview:viewFloat];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    viewMediaCall.delegate = appDelegate;
    appDelegate.viewFloatWindow = viewMediaCall;

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//邀请群成员加入通话
- (void)btnInviteClick {
    
    //当前已在通话进程的用户
    __block NSMutableArray *currentCallUser = [NSMutableArray array];
    [_callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [currentCallUser addObjectIfNotNil:[NSString stringWithFormat:@"%@", obj.userUid]];
    }];
    
    NoaCallOptions *currentOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    NoaMediaCallMoreInviteVC *vc = [NoaMediaCallMoreInviteVC new];
    vc.groupID = currentOptions.groupID;
    vc.callType = currentOptions.zgCallOptions.callType;
    vc.requestMore = 2;
    vc.currentRoomUser = currentCallUser;
    [self.navigationController pushViewController:vc animated:YES];
    
}
//通话结束
- (void)btnEndClick {
    
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    if (currentCallOptions) {
        //当前有通话
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if ([NoaCallManager sharedManager].callState == ZCallStateCalling) {
            //通话已接听--结束通话
            [dict setValue:@"hangup" forKey:@"discardType"];//挂断类型 结束
        }else {
            //通话未接听--拒绝通话
            [dict setValue:@"refuse" forKey:@"discardType"];//挂断类型 拒绝
        }
        
        [dict setValue:currentCallOptions.zgCallOptions.callID forKey:@"callId"];
        WeakSelf
        [[NoaCallManager sharedManager] callDiscardWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            //成功
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            //失败错误提示
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
        
        //调用接口后，已经清空了本次通话的信息，如果接口报错了，再次点击挂断，可以退出界面
        //这个体验，暂时先不改，和安卓的保持一致
        
    }else {
        
        //退出房间
        [[NoaCallManager sharedManager] callRoomLogout];
        //清空本次通话的配置
        [[NoaCallManager sharedManager] clearManagerConfig];
        
        //界面消失
        [self dismissViewControllerAnimated:YES completion:nil];
        
    };
    
    
}

//同意接听
- (void)btnAcceptClick {
    
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    if (!currentCallOptions) return;
    
    WeakSelf
    if (currentCallOptions.zgCallOptions.callType == LingIMCallTypeAudio) {
        //音频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            //单人音视频
            [weakSelf callGroupAccept];
        }];
    }else {
        //视频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            [ZTOOL getCameraAuth:^(BOOL granted) {
                DLog(@"相机权限:%d",granted);
                //单人音视频
                [weakSelf callGroupAccept];
            }];
        }];
    }
    
}
//音频静默
- (void)btnMutedAudioClick {
    if ([NoaCallManager sharedManager].callState != ZCallStateCalling) return;
    self.btnMutedAudio.selected = !self.btnMutedAudio.selected;
    [[NoaCallManager sharedManager] callRoomMicrophoneMute:self.btnMutedAudio.selected];
    _localUserModel.micState = [NoaCallManager sharedManager].callRoomMirophoneState;
    if (self.btnMutedAudio.selected) {
        [HUD showMessage:LanguageToolMatch(@"静音开启")];
    }else {
        [HUD showMessage:LanguageToolMatch(@"静音关闭")];
    }
}
//视频静默
- (void)btnMutedVideoClick {
    if ([NoaCallManager sharedManager].callState != ZCallStateCalling) return;
    self.btnMutedVideo.selected = !self.btnMutedVideo.selected;
    [[NoaCallManager sharedManager] callRoomCameraMute:self.btnMutedVideo.selected];
    _localUserModel.cameraState = [NoaCallManager sharedManager].callRoomCameraState;
    if (self.btnMutedVideo.selected) {
        [HUD showMessage:LanguageToolMatch(@"摄像头关闭")];
    }else {
        [HUD showMessage:LanguageToolMatch(@"摄像头开启")];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];//摄像头状态改变的用户
    if (_localUserModel.cameraState == LingIMCallCameraMuteStateOn) {
        //摄像头静默
        [dict setValue:@(YES) forKey:@"cameraMute"];
    }else {
        //摄像头打开
        [dict setValue:@(NO) forKey:@"cameraMute"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ZGCALLROOMCAMERAMUTE object:nil userInfo:dict];
}
//扬声器
- (void)btnExternalClick {
    if ([NoaCallManager sharedManager].callState != ZCallStateCalling) return;
    
    self.btnExternal.selected = !self.btnExternal.selected;
    
    [[NoaCallManager sharedManager] callRoomSpeakerMute:!self.btnExternal.selected];
    
    _localUserModel.speakerState = [NoaCallManager sharedManager].callRoomSpeakerState;
    
    if (self.btnExternal.selected) {
        [HUD showMessage:LanguageToolMatch(@"免提开启")];
    }else {
        [HUD showMessage:LanguageToolMatch(@"免提关闭")];
    }
}

//切换摄像头
- (void)btnCameraSwitchClick {
    if ([NoaCallManager sharedManager].callState != ZCallStateCalling) return;
    self.btnCameraSwitch.selected = !self.btnCameraSwitch.selected;
    [[NoaCallManager sharedManager] callRoomCameraUseFront:self.btnCameraSwitch.selected];
    _localUserModel.cameraDirection = [NoaCallManager sharedManager].callRoomCameraDirection;
}

//缩小放大的成员
- (void)btnBigClick {
    //取消放大
    if (_modelBig) {
        [_callUserList addObject:_modelBig];
    }
    
    //更换为垂直布局
    [_collectionViewCall setCollectionViewLayout:self.layoutV animated:YES];
    
    WeakSelf
    [ZTOOL doInMain:^{
        [weakSelf.collectionViewCall reloadData];
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBig.alpha = 0;
        weakSelf.collectionViewCall.frame = CGRectMake(DWScale(2), 0, DScreenWidth - DWScale(4), DScreenWidth - DWScale(4));
    } completion:^(BOOL finished) {
        [weakSelf.viewBig removeFromSuperview];
        weakSelf.viewBig = nil;
        weakSelf.modelBig = nil;
    }];
    
    _btnBig.hidden = YES;
}

//接受通话接口
- (void)callGroupAccept {
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    if (currentCallOptions) {
        WeakSelf
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:currentCallOptions.zgCallOptions.callID forKey:@"callId"];
        [[NoaCallManager sharedManager] callAcceptWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            //被邀请者，同意音视频通话请求后，进入房间
            [weakSelf callRoomJoin];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }else {
        [HUD showMessage:LanguageToolMatch(@"操作失败")];
    }
}

#pragma mark - ZCallManagerDelegate
- (void)currentCallDurationTime:(NSInteger)duration {
    if (duration > 0) {
        _lblTime.text = [NSString getTimeLengthHMS:duration];
    }else {
        _lblTime.text = @"";
    }
}

#pragma mark - 通知监听
- (void)notificationObserver {
    //监听多人音视频通话 是否需要更新成员信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRoomGroupMemberUpdate:) name:ZGCALLROOMGROUPMEMBERUPDATE object:nil];
}
#pragma mark - 通知处理
//加入群聊音视频房间
- (void)callRoomJoin {
    WeakSelf
    
    if ([NoaCallManager sharedManager].callState == ZCallStateCalling) return;
    
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    
    //第一步 初始化单例
    [[NoaCallManager sharedManager] callRoomCreateEngineWithOptions:currentCallOptions.zgCallOptions];
    //第二步 登录房间
    [[NoaCallManager sharedManager] callRoomLogin:^(int errorCode, NSDictionary * _Nullable extendedData) {
        if (errorCode == 0) {
            //第三步 开始推流
            [NoaCallManager sharedManager].callState = ZCallStateCalling;
            [[NoaCallManager sharedManager] callRoomStartPublish];
            //界面更新
            [weakSelf updateGroupCallUIWithCallState];
            [weakSelf updateBtnStateWithLoacalUserModel];
            [weakSelf updateGroupCallUIWithMembers];
            //通话计时器
            [[NoaCallManager sharedManager] createCurrentCallDurationTimer];
            [[NoaCallManager sharedManager] createCallHeartBeatTimer];

            [HUD showMessage:LanguageToolMatch(@"连接成功")];
        }else {
            [HUD showMessage:LanguageToolMatch(@"传入参数不合法")];
        }
    }];
}
//群聊成员状态变化
- (void)callRoomGroupMemberUpdate:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *groupID = [NSString stringWithFormat:@"%@", [dict objectForKeySafe:@"groupID"]];
    NoaCallOptions *currentCallOptions = [NoaCallManager sharedManager].currentCallOptions;
    if ([currentCallOptions.groupID isEqualToString:groupID]) {
        //我当前进行的 群聊 成员发生变化
        [self updateGroupCallUIWithMembers];
    }
}

//简单的列表刷新
- (void)sampleReloadTable {
    WeakSelf
    dispatch_async(self->_callMemberQueue, ^{
        [ZTOOL doInMain:^{
            [weakSelf.collectionViewCall reloadData];
        }];
    });
}

#pragma mark - 懒加载
- (NoaMediaCallMoreLayout *)layoutV {
    if (!_layoutV) {
        _layoutV = [NoaMediaCallMoreLayout new];
        _layoutV.minimumLineSpacing = 0;
        _layoutV.minimumInteritemSpacing = 0;
        _layoutV.scrollDirection = UICollectionViewScrollDirectionVertical;
        _layoutV.sectionInset = UIEdgeInsetsZero;
        _layoutV.itemSize = CGSizeMake(10, 10);
    }
    return _layoutV;
}
- (UICollectionViewFlowLayout *)layoutH {
    if (!_layoutH) {
        _layoutH = [UICollectionViewFlowLayout new];
        CGFloat itemW = (DScreenWidth - DWScale(20)) / 4.0;
        _layoutH.itemSize = CGSizeMake(itemW, itemW);
        _layoutH.minimumLineSpacing = 0;
        _layoutH.minimumInteritemSpacing = 0;
        _layoutH.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layoutH.sectionInset = UIEdgeInsetsZero;
    }
    return _layoutH;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
