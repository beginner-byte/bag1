//
//  NoaCallUserModel.h
//  NoaKit
//
//  Created by Candy on 2023/5/26.
//

// 即构 参与音视频通话的用户信息

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaCallUserModel : NSObject
//用户ID
@property (nonatomic, copy) NSString *userUid;
//用户的昵称或备注
@property (nonatomic, copy) NSString *userShowName;
//用户头像
@property (nonatomic, copy) NSString *userAvatar;
//音视频通话该用户的音视频流ID
@property (nonatomic, copy) NSString *streamID;

//摄像头静默
@property (nonatomic, assign) LingIMCallCameraMuteState cameraState;
//摄像头方向
@property (nonatomic, assign) LingIMCallCameraDirection cameraDirection;
//麦克风静默
@property (nonatomic, assign) LingIMCallMicrophoneMuteState micState;
//扬声器静默
@property (nonatomic, assign) LingIMCallSpeakerMuteState speakerState;

//用户的通话状态
@property (nonatomic, assign) ZCallUserState callState;

@end

NS_ASSUME_NONNULL_END
