//
//  NoaMediaCallMoreVC.m
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

#import "NoaMediaCallMoreVC.h"
#import "SyncMutableArray.h"
#import "NoaMediaCallShimmerView.h"
#import "NoaMediaCallMoreVideoItem.h"
#import "NoaMediaCallMoreInviteVC.h"
#import "NoaMediaCallGroupMemberModel.h"
#import "NoaMediaCallMoreLayout.h"
#import "NoaMediaCallMoreContentView.h"
#import "UIButton+Gradient.h"

@interface NoaMediaCallMoreVC () <UICollectionViewDataSource, UICollectionViewDelegate, ZMediaCallMoreVideoItemDelegate>
{
    //多人音视频通话，成员发生变化队列
    dispatch_queue_t _mediaCallMoreMemberChangeQueue;
}
@property (nonatomic, strong) UIView *viewBaseBg;//被邀请者UI
@property (nonatomic, strong) NoaUserModel *userModel;//邀请我的用户信息
@property (nonatomic, strong) NoaBaseImageView *ivHeaderBg;//对方头像模糊背景
@property (nonatomic, strong) NoaBaseImageView *ivHeader;//对方头像
@property (nonatomic, strong) UILabel *lblNickname;//对方昵称
@property (nonatomic, strong) UILabel *lblCallTip;//会话提示
@property (nonatomic, strong) NoaMediaCallShimmerView *viewShimmer;//闪光效果

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

@end

@implementation NoaMediaCallMoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _callUserList = [SyncMutableArray new];
    //队列初始化
    _mediaCallMoreMemberChangeQueue = dispatch_queue_create("com.CIMKit.mediaCallMoreMemberChangeQueue", DISPATCH_QUEUE_SERIAL);
    
    [self setupMoreCallUI];
    
    [self setupMoreUIWithCallState];
    
    [self updateUIWithUserModel];
    
    [self notificationObserver];
    
    [self mediaCallRoomGroupMemberUpdate];
    
    
}
#pragma mark - 界面布局
- (void)setupMoreCallUI {
    
    //基本UI相关实现
    self.view.tkThemebackgroundColors = @[COLOR_00, COLOR_00_DARK];
    
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
    }];
    
    //会话提示信息
    _lblCallTip = [UILabel new];
    _lblCallTip.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblCallTip.font = FONTR(14);
    [_viewBaseBg addSubview:_lblCallTip];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_ivHeader.mas_bottom).offset(DWScale(24));
        make.leading.equalTo(self.view.mas_leading).offset(16);
    }];
    _lblNickname.numberOfLines = 2;
    _lblNickname.textAlignment = NSTextAlignmentCenter;

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
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    if (currentCallOptions.callType == LingIMCallTypeAudio) {
        //音频
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
        //视频
        [self.view addSubview:self.btnMutedAudio];//静音
        [self.view addSubview:self.btnMutedVideo];//摄像头
        [self.view addSubview:self.btnCameraSwitch];//切换摄像头
        [self.view addSubview:self.btnEnd];//挂断(不含文字)
        [self.view addSubview:self.btnRefuse];//拒绝(不含文字)
        [self.view addSubview:self.btnAccept];//接受(不含文字)
        
        [self.btnEnd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.btnMutedAudio);
            make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(60)));
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
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(85)));
        }];
        
        [self.btnMutedVideo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.btnEnd.mas_top).offset(-DWScale(30));
            make.leading.equalTo(self.view).offset(DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(85)));
        }];
        
        [self.btnCameraSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.btnEnd.mas_top).offset(-DWScale(30));
            make.trailing.equalTo(self.view).offset(-DWScale(40));
            make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(85)));
        }];
    }
    [self layoutBtn];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutBtn];
}
//根据通话状态创建UI
- (void)setupMoreUIWithCallState {
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    if ([NoaMediaCallManager sharedManager].currentRoomCalling) {
        //当前通话已连接成功
        
        _viewCallBg.hidden = NO;
        _viewBaseBg.hidden = YES;
        
        if (currentCallOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            if (currentCallOptions.callRoleType == LingIMCallRoleTypeResponse) {
                //被邀请者
                [self btnHiddenAnimationWith:self.btnRefuse];//隐藏拒绝按钮
                [self btnHiddenAnimationWith:self.btnAccept];//隐藏接受按钮
            }
            [self btnShowAnimationWith:self.btnMutedAudio];
            [self btnShowAnimationWith:self.btnEnd];
            [self btnShowAnimationWith:self.btnExternal];
        }else {
            //视频通话
            if (currentCallOptions.callRoleType == LingIMCallRoleTypeResponse) {
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
            [[NoaMediaCallManager sharedManager] mediaCallAudioSpeaker:YES];
        }
        
        
    }else {
        //当前通话未连接成功
        
        if (currentCallOptions.callType == LingIMCallTypeAudio) {
            //音频通话
            if (currentCallOptions.callRoleType == LingIMCallRoleTypeResponse) {
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
            if (currentCallOptions.callRoleType == LingIMCallRoleTypeResponse) {
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

//更新对方的用户信息UI
- (void)updateUIWithUserModel {
    //获取对方用户信息
    _userModel = [NoaMediaCallManager sharedManager].userModel;
    if (_userModel) {
        //对方头像
        [_ivHeaderBg sd_setImageWithURL:[_userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        [_ivHeader sd_setImageWithURL:[_userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        
        //对方昵称
        _lblNickname.text = self.userModel.nickname;
    }
}
#pragma mark - 通知监听
- (void)notificationObserver {
    //监听多人音视频通话 是否需要更新成员信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCallRoomGroupMemberUpdate) name:CALLROOMGROUPMEMBERUPDATE object:nil];
    //监听多人音视频通话 是否有成员离开房间
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCallRoomGroupMemberLeave:) name:CALLROOMGROUPMEMBERLEAVE object:nil];
}
#pragma mark - 通知处理
//房间成员更新
- (void)mediaCallRoomGroupMemberUpdate {
    WeakSelf
    dispatch_async(self->_mediaCallMoreMemberChangeQueue, ^{
        
        //先清空数据
        [weakSelf.callUserList removeAllObjects];
        
        //当前通话信息
        NoaMediaCallOptions *currentOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
        //当前通话参与者信息
        NSMutableArray *currentParticipantList = currentOptions.callMediaGroupMemberList;
        //获得当前通话 远端参与者信息
        NSArray *remoteParticipantList = [[NoaMediaCallManager sharedManager] mediaCallRoomRemotePaticipants];
        
        [currentParticipantList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [remoteParticipantList enumerateObjectsUsingBlock:^(RemoteParticipant * _Nonnull remoteParticipant, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj.userUid isEqualToString:remoteParticipant.identity]) {
                    obj.memberState = ZCallUserStateAccept;
                    obj.participantMember = remoteParticipant;
                    *stop = YES;
                }
                
            }];
            
            [weakSelf.callUserList addObject:obj];
            
        }];
        
        
        [ZTOOL doInMain:^{
            [weakSelf.collectionViewCall reloadData];
        }];
        
    });
    
    
    
}
//房间成员离开
- (void)mediaCallRoomGroupMemberLeave:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    NoaMediaCallGroupMemberModel *leaveModel = [NoaMediaCallGroupMemberModel mj_objectWithKeyValues:dict];
    if (![leaveModel.groupID isEqualToString:[NoaMediaCallManager sharedManager].currentCallOptions.groupId]) return;
    
    WeakSelf
    dispatch_async(self->_mediaCallMoreMemberChangeQueue, ^{
        
        //该群的多人音视频通话，有成员离开
        if ([weakSelf.modelBig.userUid isEqualToString:leaveModel.userUid]) {
            
            //放大的成员离开了房间
            weakSelf.modelBig.memberState = leaveModel.memberState;
            weakSelf.viewBig.model = weakSelf.modelBig;
            weakSelf.modelBig = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf btnBigClick];
            });
            
        }else {
            
            [weakSelf.callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([leaveModel.userUid isEqualToString:obj.userUid]) {
                    obj.memberState = leaveModel.memberState;
                    [ZTOOL doInMain:^{
                        //更新离开成员的UI状态(1.0秒后移除相关UI)
                        [weakSelf.collectionViewCall reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                    }];
                    *stop = YES;
                }
            }];
            
        }
        
    });
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
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
        
        dispatch_async(self->_mediaCallMoreMemberChangeQueue, ^{
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
    dispatch_async(self->_mediaCallMoreMemberChangeQueue, ^{
        
        [weakSelf.callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([selectModel.userUid isEqualToString:obj.userUid]) {
                
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
        dispatch_async(self->_mediaCallMoreMemberChangeQueue, ^{
            
            NSString *userUid = model.userUid;
            [weakSelf.callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([userUid isEqualToString:obj.userUid]) {
                    //已包含该用户，删除，更新
                    [weakSelf.callUserList removeObjectAtIndex:idx];
                    *stop = YES;
                }
            }];
            
            //延迟1.0秒后移除相关成员UI
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.collectionViewCall reloadData];
            });
            
        });
    }
}
#pragma mark - 音视频房间加入
- (void)mediaCallRoomJoin {
    if ([NoaMediaCallManager sharedManager].currentRoomCalling) return;
    
    NoaIMCallOptions *callOptions = [NoaIMCallOptions new];
    callOptions.callRoomUrl = [NoaMediaCallManager sharedManager].currentCallOptions.callRoomUrl;
    callOptions.callRoomToken = [NoaMediaCallManager sharedManager].currentCallOptions.callRoomToken;
    callOptions.callType = [NoaMediaCallManager sharedManager].currentCallOptions.callType;
    callOptions.callRoleType = [NoaMediaCallManager sharedManager].currentCallOptions.callRoleType;
    callOptions.callMicState = [NoaMediaCallManager sharedManager].currentCallOptions.callMicState;
    callOptions.callCameraState = [NoaMediaCallManager sharedManager].currentCallOptions.callCameraState;
    
    [[NoaMediaCallManager sharedManager] mediaCallConnectRoomWith:callOptions delegate:self];
    
}
#pragma mark - 交互事件
//最小化
- (void)btnMiniClick {
    NoaWindowFloatView *viewMediaCall = [[NoaWindowFloatView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH, DWScale(86), DWScale(101))];
    viewMediaCall.isKeepBounds = YES;
    [CurrentWindow addSubview:viewMediaCall];
    
    NoaMediaCallMoreFloatView *viewFloat = [[NoaMediaCallMoreFloatView alloc] initWithFrame:CGRectMake(0, 0, DWScale(86), DWScale(101))];
    [viewMediaCall addSubview:viewFloat];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    viewMediaCall.delegate = appDelegate;
    appDelegate.viewFloatWindow = viewMediaCall;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
//邀请群成员加入通话
- (void)btnInviteClick {
    __block NSMutableArray *currentCallUser = [NSMutableArray array];
    [_callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [currentCallUser addObjectIfNotNil:obj.userUid];
    }];
    
    NoaMediaCallOptions *currentOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    NoaMediaCallMoreInviteVC *vc = [NoaMediaCallMoreInviteVC new];
    vc.groupID = currentOptions.callMediaGroupModel.chat_id;
    vc.callType = currentOptions.callType;
    vc.requestMore = 2;
    vc.currentRoomUser = currentCallUser;
    [self.navigationController pushViewController:vc animated:YES];
}
//通话结束
- (void)btnEndClick {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    [dict setValue:currentCallOptions.callHashKey forKey:@"hash"];
    
    //配置挂断原因参数
    if (currentCallOptions.callRoleType == LingIMCallRoleTypeRequest) {
        //邀请者
        if (![NoaMediaCallManager sharedManager].currentRoomCalling) {
            //取消通话
            [dict setValue:@"cancel" forKey:@"reason"];//主叫方取消通话
        }else {
            //挂断通话
            [dict setValue:@"" forKey:@"reason"];//通话建立之后正常挂断
        }
    }else {
        //被邀请者
        if (![NoaMediaCallManager sharedManager].currentRoomCalling) {
            //拒绝通话
            [dict setValue:@"refused" forKey:@"reason"];//拒绝
        }else {
            //挂断电话
            [dict setValue:@"" forKey:@"reason"];//通话建立之后正常挂断
        }
    }
    
    //调用接口
    [[NoaMediaCallManager sharedManager] mediaCallGroupDiscardWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
        if ([NoaMediaCallManager sharedManager].currentRoomCalling) {
            //断开连接
            [[NoaMediaCallManager sharedManager] mediaCallDisconnect];
        }
        
        [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateEnd;
        
        NSString *discardReason = [NSString stringWithFormat:@"%@", [dict objectForKeySafe:@"reason"]];
        if ([NSString isNil:discardReason]) {
            //销毁一下定时器，挂断操作
            [[NoaMediaCallManager sharedManager] deallocCurrentCallDurationTimer];
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
    
}
//同意接听
- (void)btnAcceptClick {
    
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    
    if (!currentCallOptions) return;
    
    WeakSelf
    if (currentCallOptions.callType == LingIMCallTypeAudio) {
        //音频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            [weakSelf callGroupAccept];
        }];
        
    }else {
        //视频
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            [ZTOOL getCameraAuth:^(BOOL granted) {
                DLog(@"相机权限:%d",granted);
                [weakSelf callGroupAccept];
            }];
        }];
    }
}
//音频静默
- (void)btnMutedAudioClick {
    WeakSelf
    if (self.btnMutedAudio.isSelected) {
        //执行关闭静音
        [[NoaMediaCallManager sharedManager] mediaCallAudioMute:NO complete:^(BOOL isMuted) {
            if (!isMuted) {
                weakSelf.btnMutedAudio.selected = NO;
                [HUD showMessage:LanguageToolMatch(@"静音关闭")];
            }
        }];
    } else {
        //执行开启静音
        [[NoaMediaCallManager sharedManager] mediaCallAudioMute:YES complete:^(BOOL isMuted) {
            if (isMuted) {
                weakSelf.btnMutedAudio.selected = YES;
                [HUD showMessage:LanguageToolMatch(@"静音开启")];
            }
        }];
    }
}
//视频静默
- (void)btnMutedVideoClick {
    WeakSelf
    if (self.btnMutedVideo.isSelected) {
        //执行关闭静默
        [[NoaMediaCallManager sharedManager] mediaCallVideoMute:NO complete:^(BOOL isMuted) {
            if (!isMuted) {
                weakSelf.btnMutedVideo.selected = NO;
                [HUD showMessage:LanguageToolMatch(@"摄像头开启")];
            }
        }];
        
    } else {
        //执行开启静默
        [[NoaMediaCallManager sharedManager] mediaCallVideoMute:YES complete:^(BOOL isMuted) {
            if (isMuted) {
                weakSelf.btnMutedVideo.selected = YES;
                [HUD showMessage:LanguageToolMatch(@"摄像头关闭")];
            }
        }];
        
    }
}
//扬声器
- (void)btnExternalClick {
    
    if (self.btnExternal.isSelected) {
        //关闭免提扬声器
        [[NoaMediaCallManager sharedManager] mediaCallAudioSpeaker:NO];
        self.btnExternal.selected = NO;
        [HUD showMessage:LanguageToolMatch(@"免提关闭")];
    }else {
        //开启免提扬声器
        [[NoaMediaCallManager sharedManager] mediaCallAudioSpeaker:YES];
        self.btnExternal.selected = YES;
        [HUD showMessage:LanguageToolMatch(@"免提开启")];
    }
    
}

//切换摄像头
- (void)btnCameraSwitchClick {
    [[NoaMediaCallManager sharedManager] mediaCallVideoCameraSwitch:^(BOOL success) {
        DLog(@"切换摄像头");
    }];
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

#pragma mark - 接受通话
- (void)callGroupAccept {
    WeakSelf
    NoaMediaCallOptions *currentCallOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
    [[NoaMediaCallManager sharedManager] mediaCallGroupAcceptWith:currentCallOptions onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            
            LIMMediaCallGroupModel *mediaCallModel = [LIMMediaCallGroupModel mj_objectWithKeyValues:dataDict];
            
            NoaMediaCallOptions *callOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
            
            callOptions.callMediaGroupModel = mediaCallModel;
            
            [weakSelf mediaCallRoomJoin];
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - RoomDelegateObjC
//房间状态更新
- (void)room:(Room *)room didUpdateConnectionState:(enum ConnectionState)connectionState oldConnectionState:(enum ConnectionState)oldConnectionState {
    switch (connectionState) {
        case ConnectionStateDisconnected:
        {
            DLog(@"当前房间-断开连接-0");
        }
            break;
        case ConnectionStateConnecting:
        {
            DLog(@"当前房间-正在连接-1");
        }
            break;
        case ConnectionStateReconnecting:
        {
            DLog(@"当前房间-重新连接-2");
        }
            break;
        case ConnectionStateConnected:
        {
            DLog(@"当前房间-连接成功-3");
            if ([NoaMediaCallManager sharedManager].mediaCallState != ZMediaCallStateCall) {
                
                [NoaMediaCallManager sharedManager].mediaCallState = ZMediaCallStateCall;
                //更新UI 主线程
                WeakSelf
                [ZTOOL doInMain:^{
                    [weakSelf setupMoreUIWithCallState];
                    [[NoaMediaCallManager sharedManager] createCurrentCallDurationTimer];
                    [weakSelf mediaCallRoomGroupMemberUpdate];
                    [HUD showMessage:LanguageToolMatch(@"连接成功")];
                }];
                
            }
        }
            
        default:
            break;
    }
    
    DLog(@"房间代理---0--房间连接状态:%ld",connectionState);
}

//房间连接成功
- (void)room:(Room *)room didConnectIsReconnect:(BOOL)isReconnect {
    DLog(@"当前房间-连接成功");
    DLog(@"房间代理---1");
    
}

//房间连接失败
- (void)room:(Room *)room didFailToConnectWithError:(NSError *)error {
    DLog(@"当前房间-连接失败");
    DLog(@"房间代理---2");
}

//房间断开连接
- (void)room:(Room *)room didDisconnectWithError:(NSError *)error {
    DLog(@"当前房间-断开连接");
    DLog(@"房间代理---3");
}
//房间有参与者加入
- (void)room:(Room *)room participantDidJoin:(RemoteParticipant *)participant {
    DLog(@"房间代理---4有参与者加入");//此时只有远端参与者信息，没有远端音视频轨道信息
}

//房间有参与者离开
- (void)room:(Room *)room participantDidLeave:(RemoteParticipant *)participant {
    DLog(@"房间代理---5有参与者离开");
    WeakSelf
    dispatch_async(self->_mediaCallMoreMemberChangeQueue, ^{
        
        //离开者ID
        NSString *userUid = participant.identity;
        
        if ([weakSelf.modelBig.userUid isEqualToString:userUid]) {
            //放大的成员离开了房间
            weakSelf.modelBig.memberState = ZCallUserStateHangup;
            weakSelf.viewBig.model = weakSelf.modelBig;
            weakSelf.modelBig = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf btnBigClick];
            });
        }else {
            
            [weakSelf.callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([userUid isEqualToString:obj.userUid]) {
                    //已包含该用户，删除，更新
                    [weakSelf.callUserList removeObjectAtIndex:idx];
                    *stop = YES;
                }
            }];
            
            [ZTOOL doInMain:^{
                [weakSelf.collectionViewCall reloadData];
            }];
            
        }
        
        
    });
}

//参与者扬声器改变
- (void)room:(Room *)room didUpdateSpeakers:(NSArray<Participant *> *)speakers {
    DLog(@"当前房间-参与者扬声器改变，是谁在说话");
    DLog(@"房间代理---6");
}

//房间的元数据发生改变
- (void)room:(Room *)room didUpdateMetadata:(NSString *)metadata {
    DLog(@"当前房间-元数据发生改变");
    DLog(@"房间代理---7");
}

//房间的参与者元数据发生改变 ParticipantDelegate有相同功能 participant:didUpdateMetadata:
- (void)room:(Room *)room participant:(Participant *)participant didUpdateMetadata:(NSString *)metadata {
    DLog(@"当前房间-参与者元数据发生改变");
    DLog(@"房间代理---8");
}
- (void)room:(Room *)room participant:(Participant *)participant didUpdateConnectionQuality:(enum ConnectionQuality)connectionQuality {
    DLog(@"房间代理---9");
    
}
//房间的参与者轨道静默状态发生改变 ParticipantDelegate有相同功能 participant:publication:didUpdateMuted:
- (void)room:(Room *)room participant:(Participant *)participant publication:(TrackPublication *)publication didUpdateMuted:(BOOL)muted {
    DLog(@"房间代理---10");
    
}

- (void)room:(Room *)room participant:(Participant *)participant didUpdatePermissions:(ParticipantPermissions *)permissions {
    DLog(@"房间代理---11");
}
- (void)room:(Room *)room participant:(RemoteParticipant *)participant publication:(RemoteTrackPublication *)publication didUpdateStreamState:(enum StreamState)streamState {
    DLog(@"房间代理---12");
}
- (void)room:(Room *)room participant:(RemoteParticipant *)participant didPublishPublication:(RemoteTrackPublication *)publication {
    DLog(@"房间代理---13");
}
- (void)room:(Room *)room participant:(RemoteParticipant *)participant didUnpublishPublication:(RemoteTrackPublication *)publication {
    DLog(@"房间代理---14");
}

//房间的本地参与者 订阅了一个新的远端音视频轨道；只要有新的轨道可以使用，这个事件就会触发
- (void)room:(Room *)room participant:(RemoteParticipant *)participant didSubscribePublication:(RemoteTrackPublication *)publication track:(Track *)track {
    DLog(@"房间代理---15本地参与者订阅了一个新的音视频轨道");
    //先走房间代理4，然后本地订阅成功后，15的代理回调
    WeakSelf
    dispatch_async(self->_mediaCallMoreMemberChangeQueue, ^{
        
        NSString *userUid = participant.identity;
        __block BOOL userInclude = NO;
        
        [weakSelf.callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([userUid isEqualToString:obj.userUid]) {
                //已包含该用户，更新信息
                obj.memberState = 1;
                obj.participantMember = participant;
                userInclude = YES;
                *stop = YES;
            }
            
        }];
        
        if (!userInclude) {
            //新用户主动加入多人音视频
            NoaMediaCallOptions *currentOptions = [NoaMediaCallManager sharedManager].currentCallOptions;
            
            NoaMediaCallGroupMemberModel *newModel = [NoaMediaCallGroupMemberModel new];
            newModel.userUid = userUid;
            newModel.memberState = 1;
            newModel.participantMember = participant;
            newModel.callType = currentOptions.callType;
            newModel.groupID = currentOptions.groupId;
            [weakSelf.callUserList addObject:newModel];
        }
        
        [ZTOOL doInMain:^{
            [weakSelf.collectionViewCall reloadData];
        }];
        
    });
    
}
- (void)room:(Room *)room participant:(RemoteParticipant *)participant didFailToSubscribe:(NSString *)trackSid error:(NSError *)error {
    DLog(@"房间代理---16");
}
- (void)room:(Room *)room publication:(RemoteParticipant *)participant didUnsubscribePublication:(RemoteTrackPublication *)publication track:(Track *)track {
    DLog(@"房间代理---17");
}
- (void)room:(Room *)room participant:(RemoteParticipant *)participant didReceiveData:(NSData *)data {
    DLog(@"房间代理---18");
}

//房间的 本地 参与者 发布了 音视频轨道
- (void)room:(Room *)room localParticipant:(LocalParticipant *)localParticipant didPublishPublication:(LocalTrackPublication *)publication {
    DLog(@"房间代理---19");
    WeakSelf
    dispatch_async(self->_mediaCallMoreMemberChangeQueue, ^{
        
        NSString *userUid = localParticipant.identity;
        [weakSelf.callUserList enumerateObjectsUsingBlock:^(NoaMediaCallGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userUid isEqualToString:userUid]) {
                obj.participantMember = localParticipant;
                obj.memberState = 1;//已加入
                *stop = YES;
            }
        }];
        [ZTOOL doInMain:^{
            [weakSelf.collectionViewCall reloadData];
        }];
        
    });
    
}

- (void)room:(Room *)room localParticipant:(LocalParticipant *)localParticipant didUnpublishPublication:(LocalTrackPublication *)publication {
    DLog(@"房间代理---20");
    //本地取消音视频轨道发布
}

- (void)room:(Room *)room participant:(RemoteParticipant *)participant didUpdate:(RemoteTrackPublication *)publication permission:(BOOL)allowed {
    DLog(@"房间代理---21");
}



#pragma mark - ZMediaCallManagerDelegate
- (void)mediaCallCurrentDuration:(NSInteger)duration {
    if (duration > 0) {
        _lblTime.text = [NSString getTimeLengthHMS:duration];
    }else {
        _lblTime.text = @"";
    }
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
