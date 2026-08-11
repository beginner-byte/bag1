//
//  NoaChatGroupCallTipView.m
//  NoaKit
//
//  Created by Candy on 2023/2/8.
//

#import "NoaChatGroupCallTipView.h"
#import "NoaToolManager.h"

#import "NoaNavigationController.h"
//LiveKit
#import "NoaMediaCallManager.h"
#import "NoaMediaCallMoreVC.h"
//即构
#import "NoaCallManager.h"
#import "NoaCallGroupVC.h"
#import "NoaCallInfoModel.h"

@interface NoaChatGroupCallTipView () <UICollectionViewDataSource, UICollectionViewDelegate, NoaIMMediaCallDelegate>
{
    //多人音视频聊天群成员变化队列
    dispatch_queue_t _groupCallMemberActionQueue;
}

@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UIImageView *ivLogo;
@property (nonatomic, strong) UILabel *lblTip;
@property (nonatomic, strong) UIImageView *ivArrow;
@property (nonatomic, strong) UIButton *btnOpen;
@property (nonatomic, strong) UIView *viewMemberBg;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *btnAdd;

@property (nonatomic, strong) LIMMediaCallGroupParticipantAction *groupCallInfoModel;//LiveKit当前多人音视频通话信息
@property (nonatomic, strong) NoaCallInfoModel *zgCallInfoModel;//即构 音视频通话信息
@property (nonatomic, strong) NSMutableArray *zgCallMemberIdList;

@end

@implementation NoaChatGroupCallTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        
        [self setupUI];
        
        //队列初始化
        _groupCallMemberActionQueue = dispatch_queue_create("com.CIMKit.groupCallMemberActionQueue", DISPATCH_QUEUE_SERIAL);
        
        if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
            //LiveKit
            [IMSDKManager addMediaCallDelegate:self];
            
        }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
            //即构
            //监听群聊音视频成员变化
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zgCallGroupMemberChange:) name:ZGCALLROOMOTHERCHANGE object:nil];
        }
        
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    self.layer.cornerRadius = DWScale(16);
    self.layer.masksToBounds = YES;
    
    UIView *viewLayerBg = [UIView new];
    viewLayerBg.backgroundColor = [UIColor clearColor];
    viewLayerBg.layer.shadowColor = [UIColor blackColor].CGColor;
    viewLayerBg.layer.shadowOffset = CGSizeMake(0, 0); // 阴影偏移量，默认（0,0）
    viewLayerBg.layer.shadowOpacity = 0.1; // 不透明度
    viewLayerBg.layer.shadowRadius = 5;
    [self addSubview:viewLayerBg];
    [viewLayerBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).offset(DWScale(3));
        make.trailing.bottom.equalTo(self).offset(-DWScale(3));
    }];
    
    _viewContent = [UIView new];
    _viewContent.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewContent.layer.cornerRadius = DWScale(16);
    _viewContent.layer.masksToBounds = YES;
    [viewLayerBg addSubview:_viewContent];
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(viewLayerBg);
    }];
    
    _ivLogo = [[UIImageView alloc] initWithFrame:CGRectMake(DWScale(10), DWScale(13), DWScale(20), DWScale(20))];
    [_viewContent addSubview:_ivLogo];
    
    _lblTip = [UILabel new];
    _lblTip.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblTip.font = FONTR(16);
    [_viewContent addSubview:_lblTip];
    [_lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivLogo);
        make.leading.equalTo(_ivLogo.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(_viewContent).offset(-DWScale(34));
    }];
    
    _ivArrow = [[UIImageView alloc] initWithImage:ImgNamed(@"c_arrow_right_gray")];
    [_viewContent addSubview:_ivArrow];
    [_ivArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ivLogo);
        make.trailing.equalTo(_viewContent).offset(-DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(8), DWScale(16)));
    }];
    
    _btnOpen = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnOpen addTarget:self action:@selector(btnOpenClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewContent addSubview:_btnOpen];
    [_btnOpen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(_viewContent);
        make.height.mas_equalTo(DWScale(46));
    }];

    _viewMemberBg = [UIView new];
    _viewMemberBg.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    _viewMemberBg.layer.cornerRadius = DWScale(12);
    _viewMemberBg.layer.masksToBounds = YES;
    [_viewContent addSubview:_viewMemberBg];
    [_viewMemberBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewContent).offset(DWScale(46));
        make.leading.equalTo(_viewContent).offset(DWScale(10));
        make.trailing.equalTo(_viewContent).offset(-DWScale(10));
        make.bottom.equalTo(_viewContent).offset(-DWScale(10));
    }];
    
    CGFloat itemW = (DScreenWidth - DWScale(120)) / 6.0;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(itemW, itemW);
    layout.minimumLineSpacing = DWScale(4);
    layout.minimumInteritemSpacing = DWScale(4);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = UIColor.clearColor;
    [_collectionView registerClass:[NoaChatGroupMemberItem class] forCellWithReuseIdentifier:NSStringFromClass([NoaChatGroupMemberItem class])];
    [_viewMemberBg addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(_viewMemberBg);
        make.bottom.equalTo(_viewMemberBg).offset(-DWScale(46));
    }];
    
    UIView *viewLine = [UIView new];
    viewLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [_viewMemberBg addSubview:viewLine];
    [viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewMemberBg).offset(DWScale(10));
        make.trailing.equalTo(_viewMemberBg).offset(-DWScale(10));
        make.bottom.equalTo(_viewMemberBg).offset(-DWScale(46));
        make.height.mas_equalTo(1);
    }];
    
    _btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnAdd setTitle:LanguageToolMatch(@"加入") forState:UIControlStateNormal];
    [_btnAdd setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    _btnAdd.titleLabel.font = FONTR(16);
    [_btnAdd addTarget:self action:@selector(btnAddClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewMemberBg addSubview:_btnAdd];
    [_btnAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(_viewMemberBg);
        make.height.mas_equalTo(DWScale(46));
    }];
    
}
- (void)updateUI {
    WeakSelf
    [ZTOOL doInMain:^{
        if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"0"]) {
            weakSelf.hidden = YES;
            return;
        } else {
            LingIMGroupModel *groupModel = [IMSDKManager toolCheckMyGroupWith:weakSelf.groupID];
            if (groupModel) {
                if (groupModel.isNetCall && groupModel.userGroupRole == 0) {
                    weakSelf.hidden = YES;
                    return;
                }
            } else {
                weakSelf.hidden = YES;
                return;
            }
        }
    
        //LiveKit
        if (weakSelf.groupCallInfoModel.participants.count > 0) {
            if ([weakSelf.groupCallInfoModel.participants containsObject:UserManager.userInfo.userUID]) {
                //我在当前的通话中
                weakSelf.hidden = YES;
            }else {
                weakSelf.hidden = NO;
                if (weakSelf.groupCallInfoModel.mode == 1) {
                    //语音通话1
                    weakSelf.ivLogo.image = ImgNamed(@"ms_btn_accept_s");
                    weakSelf.lblTip.text = [NSString stringWithFormat:LanguageToolMatch(@"%ld人正在进行语音通话"),weakSelf.groupCallInfoModel.participants.count];
                }else {
                    //视频通话0
                    weakSelf.ivLogo.image = ImgNamed(@"ms_btn_video_accept_s");
                    weakSelf.lblTip.text = [NSString stringWithFormat:LanguageToolMatch(@"%ld人正在进行视频通话"),weakSelf.groupCallInfoModel.participants.count];
                }
            }
            [weakSelf.collectionView reloadData];
            return;
        }
        
        //即构
        if (weakSelf.zgCallMemberIdList.count > 0) {
            NSString *mineUserUid = [NSString stringWithFormat:@"%@", UserManager.userInfo.userUID];
            if ([weakSelf.zgCallMemberIdList containsObject:mineUserUid]) {
                //我 已在 当前的通话中
                weakSelf.hidden = YES;
            }else {
                weakSelf.hidden = NO;
                if (weakSelf.zgCallInfoModel.callType == LingIMCallTypeAudio) {
                    //音频通话
                    weakSelf.ivLogo.image = ImgNamed(@"ms_btn_accept_s");
                    weakSelf.lblTip.text = [NSString stringWithFormat:LanguageToolMatch(@"%ld人正在进行语音通话"), weakSelf.zgCallMemberIdList.count];
                }else {
                    //视频通话
                    weakSelf.ivLogo.image = ImgNamed(@"ms_btn_video_accept_s");
                    weakSelf.lblTip.text = [NSString stringWithFormat:LanguageToolMatch(@"%ld人正在进行视频通话"),weakSelf.zgCallMemberIdList.count];
                }
            }
            
            [weakSelf.collectionView reloadData];
            
            return;
        }
        //默认隐藏
        weakSelf.hidden = YES;
    }];
    
}

#pragma mark - 查询本群是否有多人音视频通话
- (void)setGroupID:(NSString *)groupID {
    _groupID = groupID;
    //查询当前群组是否有正在进行的音视频通话
    if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
        //LiveKit
        [self requestCallGroupState];
    }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
        //即构
        [self requestZegoCallGroupState];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
        //LiveKit
        return self.groupCallInfoModel.participants.count;
    }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
        //即构
        return self.zgCallMemberIdList.count;
    }else {
        return 0;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatGroupMemberItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatGroupMemberItem class]) forIndexPath:indexPath];
    if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
        //LiveKit
        cell.userUid = [self.groupCallInfoModel.participants objectAtIndexSafe:indexPath.row];
    }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
        //即构
        NSString *userUid = [NSString stringWithFormat:@"%@", [self.zgCallMemberIdList objectAtIndexSafe:indexPath.row]];
        cell.userUid = userUid;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - 交互事件
- (void)btnOpenClick {
    
    if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
        //LiveKit
        if (self.groupCallInfoModel.participants.count < 1) return;
    }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
        //即构
        if (self.zgCallMemberIdList.count < 1) return;
    }
    
    _btnOpen.selected = !_btnOpen.selected;
    
    WeakSelf
    [ZTOOL doInMain:^{
        
        if (weakSelf.btnOpen.selected) {
            //展开
            NSInteger rowNum = 0;
            if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                //LiveKit
                rowNum = weakSelf.groupCallInfoModel.participants.count / 6;
            }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                //即构
                rowNum = weakSelf.zgCallMemberIdList.count / 6;
            }

            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.ivArrow.transform = CGAffineTransformMakeRotation(M_PI_2);
                weakSelf.height = (DScreenWidth - DWScale(120)) / 6.0 * (rowNum + 1) + DWScale(118) + DWScale(8) * rowNum;
            } completion:^(BOOL finished) {}];
        }else {
            //收起
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.ivArrow.transform = CGAffineTransformMakeRotation(0);
                weakSelf.height = DWScale(52);
            } completion:^(BOOL finished) {}];
        }
        
    }];
}

- (void)btnAddClick {
    WeakSelf
    if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
        //LiveKit
        if ([NoaMediaCallManager sharedManager].mediaCallState != ZMediaCallStateEnd) {
            [HUD showWarningMessage:LanguageToolMatch(@"当前正在通话中")];
        }else {
            
            //加入多人通话
            if (self.groupCallInfoModel.mode == 0) {
                //视频通话
                [ZTOOL getMicrophoneAuth:^(BOOL granted) {
                    DLog(@"麦克风权限:%d",granted);
                    [ZTOOL getCameraAuth:^(BOOL granted) {
                        DLog(@"相机权限:%d",granted);
                        [weakSelf groupCallJoin];
                    }];
                }];
            }else {
                //语音通话
                [ZTOOL getMicrophoneAuth:^(BOOL granted) {
                    DLog(@"麦克风权限:%d",granted);
                    [weakSelf groupCallJoin];
                }];
            }
            
        }
    }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
        //即构
        if ([NoaCallManager sharedManager].callState != ZCallStateEnd) {
            [HUD showWarningMessage:LanguageToolMatch(@"当前正在通话中")];
        }else {
            
            //加入多人通话
            [ZTOOL getMicrophoneAuth:^(BOOL granted) {
                if (weakSelf.zgCallInfoModel.callType == LingIMCallTypeAudio) {
                    [weakSelf groupCallZGJoin];
                }else {
                    [ZTOOL getCameraAuth:^(BOOL granted) {
                        [weakSelf groupCallZGJoin];
                    }];
                }
            }];
            
        }
    }
}
#pragma mark - <<<<<<LiveKit音视频SDK>>>>>>
#pragma mark - LiveKit 获取当前群组是否有正在进行的音视频通话
- (void)requestCallGroupState {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_groupID forKey:@"chat_id"];
    [[NoaMediaCallManager sharedManager] mediaCallGroupState:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            weakSelf.groupCallInfoModel = [LIMMediaCallGroupParticipantAction mj_objectWithKeyValues:dataDict];
            //说明当前群有多人通话
            [weakSelf updateUI];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}

#pragma mark - LiveKit 加入 群聊 音视频通话
- (void)groupCallJoin {
    if (!self.groupCallInfoModel) return;
    
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.groupCallInfoModel.hashKey forKey:@"hash"];
    
    [[NoaMediaCallManager sharedManager] mediaCallGroupJoinWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            //房间信息配置
            LIMMediaCallGroupModel *groupModel = [LIMMediaCallGroupModel mj_objectWithKeyValues:dataDict];
            
            NoaMediaCallOptions *callOptions = [NoaMediaCallOptions new];
            callOptions.callRoleType = LingIMCallRoleTypeRequest;//主动加入，相当于我自己是发起者
            callOptions.inviterUid = UserManager.userInfo.userUID;//主动加入，相当于我自己是发起者
            callOptions.inviteeUid = @"";//被邀请者
            callOptions.callRoomType = ZIMCallRoomTypeGroup;//多人音视频
            callOptions.callMediaGroupModel = groupModel;//音视频信息
            callOptions.callType = groupModel.mode;//通话类型类型
            callOptions.groupId = groupModel.chat_id;//多人音视频群ID
            callOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//音频打开
            callOptions.callCameraState = LingIMCallCameraMuteStateOff;//视频打开
            __block NSMutableArray *participantList = [NSMutableArray array];
            [groupModel.participants enumerateObjectsUsingBlock:^(LIMMediaCallGroupParticipant * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NoaMediaCallGroupMemberModel *model = [NoaMediaCallGroupMemberModel new];
                model.memberState = obj.status == 0 ? ZCallUserStateCalling : ZCallUserStateAccept;//用户状态
                model.callType = groupModel.mode;//通话类型
                model.userUid = obj.userUid;
                model.groupID = groupModel.chat_id;
                [participantList addObjectIfNotNil:model];
            }];
            callOptions.callMediaGroupMemberList = participantList;//当前房间参与者列表
            
            [NoaMediaCallManager sharedManager].currentCallOptions = callOptions;
            
            NoaMediaCallMoreVC *vc = [NoaMediaCallMoreVC new];
            [vc mediaCallRoomJoin];
            NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [CurrentVC presentViewController:nav animated:YES completion:nil];
            
            weakSelf.hidden = YES;
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - LingIMMediaCallDelegate （LiveKit音视频的 socket代理）
- (void)imSdkMediaCallGroupParticipantActionWith:(LIMMediaCallModel *)mediaCallModel {
    if (mediaCallModel) {
        WeakSelf
        LIMMediaCallGroupParticipantAction *actionModel = mediaCallModel.callGroupParticipantActionModel;
        
        NSString *actionGroupID = actionModel.chat_id;
        
        if ([actionGroupID isEqualToString:_groupID]) {
            //发生变化的是，当前群
            if ([actionModel.action isEqualToString:@"discard"]) {
                //当前群的多人音视频结束
                self.groupCallInfoModel = nil;
                self.hidden = YES;
            }else if ([actionModel.action isEqualToString:@"join"]) {
                //某人加入了当前多人音视频
                dispatch_async(self->_groupCallMemberActionQueue, ^{
                    if (![weakSelf.groupCallInfoModel.participants containsObject:actionModel.user_id]) {
                        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:weakSelf.groupCallInfoModel.participants];
                        [tempArray addObjectIfNotNil:actionModel.user_id];
                        weakSelf.groupCallInfoModel.participants = tempArray;
                        [weakSelf updateUI];
                    }
                });
            }else if ([actionModel.action isEqualToString:@"leave"]) {
                //某人离开了当前多人音视频
                dispatch_async(self->_groupCallMemberActionQueue, ^{
                    if ([weakSelf.groupCallInfoModel.participants containsObject:actionModel.user_id]) {
                        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:weakSelf.groupCallInfoModel.participants];
                        [tempArray removeObject:actionModel.user_id];
                        weakSelf.groupCallInfoModel.participants = tempArray;
                        [weakSelf updateUI];
                    }
                });
                
            }else {//""
                //某人发起了多人音视频
                _groupCallInfoModel = actionModel;
                [self updateUI];
            }
        }
        
    }
}

#pragma mark - <<<<<<即构音视频SDK>>>>>>

#pragma mark - 即构 获取当前群组是否有正在进行的音视频通话
- (void)requestZegoCallGroupState {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_groupID forKey:@"groupId"];
    
    [[NoaCallManager sharedManager] callGetGroupCallInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDic = (NSDictionary *)data;
            if (dataDic.allKeys.count > 0) {
                //当前群聊 有 正在进行的音视频通话
                weakSelf.zgCallInfoModel = [NoaCallInfoModel mj_objectWithKeyValues:dataDic];
                
                [weakSelf.zgCallMemberIdList removeAllObjects];
                [weakSelf.zgCallInfoModel.receiveUserInfo enumerateObjectsUsingBlock:^(NoaCallMemberInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [weakSelf.zgCallMemberIdList addObjectIfNotNil:obj.userUid];
                }];
                
                [weakSelf updateUI];
            }else {
                //当前群聊 没有 正在进行的音视频通话
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        
    }];
}

#pragma mark - 即构群聊音视频成员列表变化通知
- (void)zgCallGroupMemberChange:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *callAction = [NSString stringWithFormat:@"%@", [dict objectForKeySafe:@"callAction"]];
    WeakSelf
    dispatch_async(self->_groupCallMemberActionQueue, ^{
        
        [ZTOOL doInMain:^{
            
            if ([callAction isEqualToString:@"callEnd"]) {
                [weakSelf.zgCallMemberIdList removeAllObjects];
                weakSelf.zgCallInfoModel = nil;
            }else if ([callAction isEqualToString:@"callBegin"]) {
                //更新音视频通话信息
                [weakSelf requestZegoCallGroupState];
            }else {
                //callMemberChange
                NSInteger callMemberChangeState = [[dict objectForKeySafe:@"callMemberChangeState"] integerValue];
                switch (callMemberChangeState) {
                    case 3://超时未接听 音视频成员离开
                    case 4://拒绝 音视频成员离开
                    case 5://挂断 音视频成员离开
                    case 7://通话中断 音视频成员离开
                    {
                        NSArray *callOperationMemberList = (NSArray *)[dict objectForKeySafe:@"callOperationMemberList"];
                        [callOperationMemberList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSString *memberUid = [NSString stringWithFormat:@"%@", obj];
                            if ([weakSelf.zgCallMemberIdList containsObject:memberUid]) {
                                [weakSelf.zgCallMemberIdList removeObject:memberUid];
                            }
                        }];
                        
                    }
                        break;
                    case 9://邀请加入 音视频成员总个数增加
                    case 10://主动加入 音视频成员总个数增加
                    {
                        NSArray *callOperationMemberList = (NSArray *)[dict objectForKeySafe:@"callOperationMemberList"];
                        [weakSelf.zgCallMemberIdList addObjectsFromArray:callOperationMemberList];
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }
            
            [weakSelf updateUI];
            
        }];
    });
}
#pragma mark - 即构 加入 群聊 音视频通话
- (void)groupCallZGJoin {
    
    if (!self.zgCallInfoModel) return;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.zgCallInfoModel.callId forKey:@"callId"];
    WeakSelf
    [[NoaCallManager sharedManager] callGroupJoinWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            NoaCallInfoModel *joinedCallInfo = [NoaCallInfoModel mj_objectWithKeyValues:dataDict];
            //此处仅仅返回了，我当前加入的时候 receiveUserInfo roomId token三个参数
            [ZTOOL doInMain:^{
                [weakSelf zgCallJoinForGroupWith:joinedCallInfo];                            
            }];
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
    
}
#pragma mark - 加入 群聊 音视频通话的配置方法(后面如果再添加新的SDK，可将此方法也放到单例中配置)
- (void)zgCallJoinForGroupWith:(NoaCallInfoModel *)callInfoModel{
    
    //此时，我是主动加入的群聊音视频
    LingIMCallType callType = self.zgCallInfoModel.callType;//音视频类型
    NSString *callID = self.zgCallInfoModel.callId;//通话唯一标识
    NSString *roomID = callInfoModel.roomId;//房间ID
    NSString *token = callInfoModel.token;//用户进入房间鉴权token
    NSArray *receiveUserInfoArray = callInfoModel.receiveUserInfo;//当前通话的全部成员信息
    
    
    //1.配置 单聊 音视频通话 参数
    NoaIMZGCallOptions *zgCallOptions = [NoaIMZGCallOptions new];
    //zgCallOptions.callRoomCreateUserID;//房间创建者
    zgCallOptions.callRoomType = LingIMCallRoomTypeGroup;// 此处为2群聊
    zgCallOptions.callType = callType;//1语音通话2视频通话
    zgCallOptions.callID = callID;//通话标识
    zgCallOptions.callRoomID = roomID;//房间ID
    zgCallOptions.callRoomToken = token;//房间token令牌，群聊的需要在用户点击同意成功后，获取该用户的有效token
    //zgCallOptions.callTimeout;//呼叫超时市场
    //zgCallOptions.callStatus;//通话状态
    //zgCallOptions.callDuration;//通话时长
    zgCallOptions.callRoomUserID = UserManager.userInfo.userUID;//音视频房间推流的用户ID
    zgCallOptions.callRoomUserNickname = UserManager.userInfo.nickname;//音视频房间推流的用户昵称
    zgCallOptions.callRoomUserStreamID = UserManager.userInfo.userUID;//音视频房间推流的音视频流ID
    zgCallOptions.callMicState = LingIMCallMicrophoneMuteStateOff;//房间推流默认开启麦克风(本地 我的 推流设置)
    zgCallOptions.callSpeakerState = LingIMCallSpeakerMuteStateOff;//房间推流默认开启扬声器(本地 我的 推流设置) 群聊 默认开启扬声器
    zgCallOptions.callCameraState = LingIMCallCameraMuteStateOff;//房间推流默认开启摄像头(本地 我的 推流设置)
    zgCallOptions.callCameraDirection = LingIMCallCameraDirectionFront;//房间推流默认前置摄像头(本地 我的 推流设置)
    
    //2.本地维护的房间成员信息
    __block NSMutableArray *callMemberList = [NSMutableArray array];
    [receiveUserInfoArray enumerateObjectsUsingBlock:^(NoaCallMemberInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NoaCallUserModel *model = [NoaCallUserModel new];
        model.userUid = obj.userUid;//用户ID
        model.userAvatar = obj.avatar;//用户头像
        model.userShowName = obj.nickname;//用户昵称
        model.streamID = obj.userUid;//音视频轨道流ID
        model.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
        model.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头
        model.speakerState = LingIMCallSpeakerMuteStateOff;//默认开启扬声器
        model.cameraState = LingIMCallCameraMuteStateOn;//默认关闭摄像头
        model.callState = ZCallUserStateCalling;//默认正在呼叫中
        NSString *mineUserUid = [NSString stringWithFormat:@"%@", UserManager.userInfo.userUID];
        if ([obj.userUid isEqualToString:mineUserUid]) {
            //我的 推流相关配置
            model.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头
            model.callState = ZCallUserStateAccept;//默认接通
        }
        
        [callMemberList addObjectIfNotNil:model];
    }];
    
    //我在本房间的信息，主动加入，自己是自己的邀请者
    NoaCallUserModel *userModelMineInviter = [NoaCallUserModel new];
    userModelMineInviter.userUid = UserManager.userInfo.userUID;//用户ID
    userModelMineInviter.userShowName = UserManager.userInfo.userName;//用户昵称
    userModelMineInviter.userAvatar = UserManager.userInfo.avatar;//用户头像
    userModelMineInviter.streamID = UserManager.userInfo.userUID;//音视频轨道流ID
    userModelMineInviter.micState = LingIMCallMicrophoneMuteStateOff;//默认开启麦克风
    userModelMineInviter.speakerState = LingIMCallSpeakerMuteStateOff;//默认开启扬声器
    userModelMineInviter.cameraState = LingIMCallCameraMuteStateOff;//默认开启摄像头
    userModelMineInviter.cameraDirection = LingIMCallCameraDirectionFront;//默认前置摄像头
    userModelMineInviter.callState = ZCallUserStateAccept;//默认接通
    
    
    //3.业务层 配置 单聊 音视频通话 参数
    __block NoaCallOptions *callOptions = [NoaCallOptions new];
    callOptions.zgCallOptions = zgCallOptions;
    callOptions.groupID = self.groupID;
    callOptions.callMemberList = callMemberList;//本地维护的群聊成员列表
    callOptions.inviterUserModel = userModelMineInviter;//主动加入 自己当做自己的邀请者
    //callOptions.inviteeUserList;//发起群聊邀请时有效
    
    NoaCallManager *callManager = [NoaCallManager sharedManager];
    callManager.currentCallOptions = callOptions;
    callManager.callState = ZCallStateBegin;//开始一个音视频通话的进程
    
    //4.跳转到群聊VC
    NoaCallGroupVC *vc = [NoaCallGroupVC new];
    [vc callRoomJoin];
    NoaNavigationController *nav = [[NoaNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [CurrentVC presentViewController:nav animated:YES completion:nil];
    
    [self btnOpenClick];
    self.hidden = YES;
}

#pragma mark - 即构 懒加载
- (NSMutableArray *)zgCallMemberIdList {
    if (!_zgCallMemberIdList) {
        _zgCallMemberIdList = [NSMutableArray array];
    }
    return _zgCallMemberIdList;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation NoaChatGroupMemberItem
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat itemW = (DScreenWidth - DWScale(120)) / 6.0;
        _ivHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemW, itemW)];
        _ivHeader.layer.cornerRadius = itemW / 2.0;
        _ivHeader.layer.masksToBounds = YES;
        [self.contentView addSubview:_ivHeader];
    }
    return self;
}
#pragma mark - 界面赋值
- (void)setUserUid:(NSString *)userUid {
    _userUid = userUid;
    
    //临时使用接口获取用户信息
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:userUid forKey:@"userUid"];
    [IMSDKManager getUserInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userDict = (NSDictionary *)data;
            NoaUserModel *userModel = [NoaUserModel mj_objectWithKeyValues:userDict];
            userModel.userUID = [NSString stringWithFormat:@"%@",[userDict objectForKeySafe:@"userUid"]];
            [weakSelf.ivHeader sd_setImageWithURL:[userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
    }];
}


@end
