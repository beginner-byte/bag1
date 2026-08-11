//
//  NoaMediaCallMoreContentView.m
//  NoaKit
//
//  Created by Candy on 2023/2/15.
//

#import "NoaMediaCallMoreContentView.h"
#import "NoaToolManager.h"
#import "NoaCallManager.h"//即构

@interface NoaMediaCallMoreContentView () <ParticipantDelegate>


@end

@implementation NoaMediaCallMoreContentView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        
        //监听摄像头静默状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRoomCameraMute:) name:ZGCALLROOMCAMERAMUTE object:nil];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    
    //视频渲染view
    _sampleViewVideo = [NoaMediaCallSampleVideoView new];
    [self addSubview:_sampleViewVideo];
    [_sampleViewVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    //头像
    _ivHeader = [[UIImageView alloc] initWithImage:DefaultAvatar];
    [self addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    _viewAlpha = [UIView new];
    _viewAlpha.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.6], [COLOR_00_DARK colorWithAlphaComponent:0.6]];
    [self addSubview:_viewAlpha];
    [_viewAlpha mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    _lblNickname = [UILabel new];
    _lblNickname.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblNickname.font = FONTR(16);
    _lblNickname.textAlignment = NSTextAlignmentCenter;
    [_viewAlpha addSubview:_lblNickname];
    [_lblNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_viewAlpha);
        make.bottom.equalTo(_viewAlpha.mas_centerY).offset(-DWScale(2));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _lblTip = [UILabel new];
    _lblTip.hidden = YES;
    _lblTip.textAlignment = NSTextAlignmentCenter;
    [_viewAlpha addSubview:_lblTip];
    [_lblTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_viewAlpha);
        make.top.equalTo(_viewAlpha.mas_centerY).offset(DWScale(2));
        make.height.mas_equalTo(DWScale(17));
    }];
    
    //加载动画
    _viewShimmer = [UIView new];
    [_viewAlpha addSubview:_viewShimmer];
    [_viewShimmer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_lblTip);
        make.height.mas_equalTo(DWScale(6));
        make.width.mas_equalTo(DWScale(44));
    }];
    [_viewShimmer layoutIfNeeded];
    // 1.创建一个复制图层对象，设置复制层的属性
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    // 1.1.设置复制图层中子层总数：这里包含原始层
    replicatorLayer.instanceCount = 4;
    // 1.2.设置复制子层偏移量，不包含原始层，这里是相对于原始层的x轴的偏移量
    replicatorLayer.instanceTransform = CATransform3DMakeTranslation(DWScale(10), 0, 0);
    // 1.3.设置复制层的动画延迟事件
    replicatorLayer.instanceDelay = 0.1;
    // 1.4.设置复制层的背景色，如果原始层设置了背景色，这里设置就失去效果
    replicatorLayer.instanceColor = [UIColor whiteColor].CGColor;
    // 2.创建一个图层对象  单条柱形 (原始层)
    CALayer *layer = [CALayer layer];
    // 2.1.设置layer对象的位置
    layer.position = CGPointMake(DWScale(4), 0);
    // 2.2.设置layer对象的锚点
    layer.anchorPoint = CGPointMake(0, 0);
    // 2.3.设置layer对象的位置大小
    layer.bounds = CGRectMake(0, 0, DWScale(6), DWScale(6));
    // 2.5.设置layer对象的颜色
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    layer.cornerRadius = DWScale(3);
    layer.masksToBounds = YES;
    // 3.创建一个基本动画
    CABasicAnimation *basicAnimation = [CABasicAnimation animation];
    // 3.1.设置动画的属性
    basicAnimation.keyPath = @"opacity";
    // 3.2.设置动画的属性值
    basicAnimation.toValue = @0.2;
    // 3.3.设置动画的重复次数
    basicAnimation.repeatCount = MAXFLOAT;
    // 3.4.设置动画的执行时间
    basicAnimation.duration = 0.5;
    // 3.5.设置动画反转
    basicAnimation.autoreverses = YES;
    // 4.将动画添加到layer层上
    [layer addAnimation:basicAnimation forKey:nil];
    // 5.将layer层添加到复制层上
    [replicatorLayer addSublayer:layer];
    // 6.将复制层添加到view视图层上
    [_viewShimmer.layer addSublayer:replicatorLayer];
    
}

- (void)configTipAttributedString {
    //富文本
    NSMutableAttributedString *tipAttStr;
    if (_model.memberState == ZCallUserStateTimeOut) {
        tipAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"对方正忙")];
    }else if (_model.memberState == ZCallUserStateRefuse) {
        tipAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"对方拒绝")];
    }else if (_model.memberState == ZCallUserStateHangup) {
        tipAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"对方离开")];
    }else if (_model.memberState == ZCallUserStateCancel) {
        tipAttStr = [[NSMutableAttributedString alloc] initWithString:LanguageToolMatch(@"对方离开")];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;//NSLineBreakByCharWrapping;
    NSDictionary *dict = @{
        NSFontAttributeName:FONTR(12),
        NSForegroundColorAttributeName:COLOR_99,
        NSParagraphStyleAttributeName:paragraphStyle,
    };
    [tipAttStr addAttributes:dict range:NSMakeRange(0, tipAttStr.length)];
    
    NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
    attchImage.image = ImgNamed(@"ms_btn_cancel_s");
    attchImage.bounds = CGRectMake(0, roundf(FONTR(12).capHeight - DWScale(8))/2.f, DWScale(21), DWScale(8));
    NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    [tipAttStr appendAttributedString:stringImage];
    _lblTip.attributedText = tipAttStr;
    
    //延迟1.0秒后，界面移除相关成员
    if (self.deleteMemberBlock) {
        self.deleteMemberBlock();
    }
}

//获取用户信息
- (void)requestUserInfo {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_model.userUid forKey:@"userUid"];
    [IMSDKManager getUserInfoWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userDict = (NSDictionary *)data;
            NoaUserModel *userModel = [NoaUserModel mj_objectWithKeyValues:userDict];
            userModel.userUID = [NSString stringWithFormat:@"%@",[userDict objectForKeySafe:@"userUid"]];
            weakSelf.lblNickname.text = userModel.userName;
            [weakSelf.ivHeader sd_setImageWithURL:[userModel.avatar getImageFullUrl] placeholderImage:DefaultAvatar options:
             SDWebImageAllowInvalidSSLCertificates];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
    
}

#pragma mark - 数据赋值
- (void)setModel:(NoaMediaCallGroupMemberModel *)model {
    if (model) {
        _model = model;
        
        WeakSelf
        [ZTOOL doInMain:^{
            
            LingIMGroupMemberModel *groupMemberModel = [IMSDKManager imSdkCheckGroupMemberWith:model.userUid groupID:model.groupID];
            if (groupMemberModel) {
                weakSelf.lblNickname.text = groupMemberModel.showName;
                [weakSelf.ivHeader sd_setImageWithURL:[groupMemberModel.userAvatar getImageFullUrl] placeholderImage:DefaultAvatar options:SDWebImageAllowInvalidSSLCertificates];
            }else {
                [weakSelf requestUserInfo];
            }
            
            //状态(0呼叫中 1已加入 2超时 3已离开)
            switch (model.memberState) {
                case ZCallUserStateCalling://正在呼叫中
                {
                    weakSelf.viewAlpha.hidden = NO;
                    weakSelf.viewShimmer.hidden = NO;
                    weakSelf.lblTip.hidden = YES;
                }
                    break;
                case ZCallUserStateAccept://接通多人音视频
                {
                    weakSelf.viewAlpha.hidden = YES;
                    weakSelf.viewShimmer.hidden = YES;
                    weakSelf.lblTip.hidden = YES;
                }
                    break;
                case ZCallUserStateTimeOut://呼叫超时
                case ZCallUserStateRefuse://已拒绝多人音视频
                case ZCallUserStateHangup://已离开多人音视频
                case ZCallUserStateCancel://取消
                {
                    weakSelf.viewAlpha.hidden = NO;
                    weakSelf.viewShimmer.hidden = YES;
                    weakSelf.lblTip.hidden = NO;
                    [weakSelf configTipAttributedString];
                }
                    break;
                    
                    
                default:
                    break;
            }
            
            if (model.callType == LingIMCallTypeAudio) {
                
                //音频聊天
                weakSelf.ivHeader.hidden = NO;
                weakSelf.sampleViewVideo.hidden = YES;
                
                if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                    //LiveKit
                }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                    //即构
                    if (model.callUserModel) {
                        NSString *modelUserUid = [NSString stringWithFormat:@"%@", model.callUserModel.userUid];
                        NSString *mineUserUid = [NSString stringWithFormat:@"%@", UserManager.userInfo.userUID];
                        if ([modelUserUid isEqualToString:mineUserUid]) {
                            //本地音频
                        }else {
                            //拉流 远端音频
                            NSString *streamIDStr = [NSString stringWithFormat:@"%@", model.callUserModel.streamID];
                            [[NoaCallManager sharedManager] callRoomStartPlayingStream:streamIDStr with:weakSelf.sampleViewVideo.viewVideoZG];
                        }
                    }
                }
                
            }else {
                
                //视频聊天
                weakSelf.ivHeader.hidden = NO;
                weakSelf.sampleViewVideo.hidden = NO;
                
                if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"0"]) {
                    
                    //LiveKit
                    if (model.participantMember) {
                        //有视频流参与者
                        if ([model.participantMember isKindOfClass:[LocalParticipant class]]) {
                            //本地
                            LocalParticipant *localP = (LocalParticipant *)model.participantMember;
                            [localP addDelegate:weakSelf];
                            LocalTrackPublication *localTP = (LocalTrackPublication *)localP.localVideoTracks.firstObject;
                            if (localTP) {
                                weakSelf.sampleViewVideo.viewVideo.track = (id)localTP.track;
                                weakSelf.ivHeader.hidden = localTP.track.muted ? NO : YES;
                                weakSelf.sampleViewVideo.hidden = localTP.track.muted ? YES : NO;
                            }else {
                                weakSelf.ivHeader.hidden = NO;
                                weakSelf.sampleViewVideo.hidden = YES;
                            }
                            
                        }else {
                            //远端
                            RemoteParticipant *remoteP = (RemoteParticipant *)model.participantMember;
                            [remoteP addDelegate:weakSelf];
                            TrackPublication *remoteTP = remoteP.videoTracks.firstObject;
                            if (remoteTP) {
                                weakSelf.sampleViewVideo.viewVideo.track = (RemoteVideoTrack *)remoteTP.track;
                                weakSelf.ivHeader.hidden = remoteTP.track.muted ? NO : YES;
                                weakSelf.sampleViewVideo.hidden = remoteTP.track.muted ? YES : NO;
                            }else {
                                weakSelf.ivHeader.hidden = NO;
                                weakSelf.sampleViewVideo.hidden = YES;
                            }
                        }
                    }
                    
                }else if ([ZHostTool.appSysSetModel.video_source_config isEqualToString:@"1"]) {
                    
                    //即构
                    if (model.callUserModel) {
                        NSString *modelUserUid = [NSString stringWithFormat:@"%@", model.callUserModel.userUid];
                        NSString *mineUserUid = [NSString stringWithFormat:@"%@", UserManager.userInfo.userUID];
                        if ([modelUserUid isEqualToString:mineUserUid]) {
                            //本地 渲染 视频
                            [[NoaCallManager sharedManager] callRoomStartPreviewWith:weakSelf.sampleViewVideo.viewVideoZG];
                        }else {
                            //拉流 渲染远端 视频
                            NSString *streamIDStr = [NSString stringWithFormat:@"%@", model.callUserModel.streamID];
                            [[NoaCallManager sharedManager] callRoomStartPlayingStream:streamIDStr with:weakSelf.sampleViewVideo.viewVideoZG];
                        }
                        weakSelf.ivHeader.hidden = model.callUserModel.cameraState == LingIMCallCameraMuteStateOn ? NO : YES;
                        weakSelf.sampleViewVideo.hidden = model.callUserModel.cameraState == LingIMCallCameraMuteStateOn ? YES : NO;
                    }
                    
                }
                
            }
            
        }];
        
    }
    
}



#pragma mark - <<<<<<LiveKit SDK>>>>>>
#pragma mark - ParticipantDelegate
- (void)participant:(Participant *)participant publication:(TrackPublication *)publication didUpdateMuted:(BOOL)muted {
    NSString *userUid = participant.identity;
    
    if ([userUid isEqualToString: _model.userUid]) {
        //当前用户的轨道静默状态发生改变
        WeakSelf
        [ZTOOL doInMain:^{
            
            if ([participant isKindOfClass:[LocalParticipant class]]) {
                //本地参与者轨道发生变化
                
                LocalTrackPublication *localT = (LocalTrackPublication *)publication;
                if ([localT.track isKindOfClass:[LocalVideoTrack class]]) {
                    //本地参与者视频轨道发生变化
                    
                    if (muted) {
                        //本地参与者视频轨道静默
                        weakSelf.sampleViewVideo.hidden = YES;
                        weakSelf.ivHeader.hidden = NO;
                    }else {
                        //本地参与者视频轨道静默关闭
                        weakSelf.sampleViewVideo.viewVideo.track = (LocalVideoTrack *)localT.track;
                        weakSelf.sampleViewVideo.hidden = NO;
                        weakSelf.ivHeader.hidden = YES;
                    }
                }else {
                    DLog(@"本地参与者音频轨道发生变化");
                }
                
            }else {
                //远端参与者轨道发生变化
                RemoteTrackPublication *remoteT = (RemoteTrackPublication *)publication;
                
                if ([remoteT.track isKindOfClass:[RemoteVideoTrack class]]) {
                    
                    //远端参与者视频轨道发生变化
                    if (muted) {
                        //远端参与者视频轨道静默
                        weakSelf.sampleViewVideo.hidden = YES;
                        weakSelf.ivHeader.hidden = NO;
                    }else {
                        //远端参与者视频轨道静默关闭
                        weakSelf.sampleViewVideo.viewVideo.track = (RemoteVideoTrack *)remoteT.track;
                        weakSelf.sampleViewVideo.hidden = NO;
                        weakSelf.ivHeader.hidden = YES;
                    }
                    
                }else {
                    DLog(@"远端参与者音频轨道发生变化");
                }
                
            }
                    
        }];
    }
}

#pragma mark - <<<<<<即构 SDK>>>>>>
#pragma mark - 远端摄像头静默状态
- (void)callRoomCameraMute:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    //远端摄像头静默状态改变的用户
    NSString *userUid = [NSString stringWithFormat:@"%@", [userInfo objectForKeySafe:@"userUid"]];
    //远端摄像头静默状态
    BOOL cameraMute = [[userInfo objectForKeySafe:@"cameraMute"] boolValue];
    if ([userUid isEqualToString:_model.callUserModel.userUid]) {
        //当前用户的摄像头状态发生改变
        _ivHeader.hidden = cameraMute ? NO : YES;
        _model.callUserModel.cameraState = cameraMute ? LingIMCallCameraMuteStateOn : LingIMCallCameraMuteStateOff;
        _sampleViewVideo.hidden = cameraMute ? YES : NO;
    }
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
