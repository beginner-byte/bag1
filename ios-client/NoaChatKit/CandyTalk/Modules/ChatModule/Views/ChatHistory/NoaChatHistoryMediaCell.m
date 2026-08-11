//
//  NoaChatHistoryMediaCell.m
//  NoaKit
//
//  Created by Candy on 2026/11/14.
//

#import "NoaChatHistoryMediaCell.h"


@interface NoaChatHistoryMediaCell ()
@end

@implementation NoaChatHistoryMediaCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivMedia = [NoaBaseImageView new];
    [self.contentView addSubview:_ivMedia];
    [_ivMedia mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _viewVideo = [UIView new];
    _viewVideo.hidden = YES;
    _viewVideo.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.contentView addSubview:_viewVideo];
    [_viewVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _ivVideo = [[UIImageView alloc] initWithImage:ImgNamed(@"img_video_msg_sign")];
    [_viewVideo addSubview:_ivVideo];
    [_ivVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewVideo);
        make.leading.equalTo(_viewVideo).offset(DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(14)));
    }];
    
    _lblVideoTime = [UILabel new];
    _lblVideoTime.font = FONTR(13);
    _lblVideoTime.textColor = COLORWHITE;
    [_viewVideo addSubview:_lblVideoTime];
    [_lblVideoTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewVideo);
        make.leading.equalTo(_ivVideo.mas_trailing).offset(DWScale(5));
        make.trailing.equalTo(_viewVideo).offset(-DWScale(5));
    }];
    
}
#pragma mark - 界面赋值
- (void)setChatMessageModel:(NoaIMChatMessageModel *)chatMessageModel {
    if (chatMessageModel) {
        _chatMessageModel = chatMessageModel;
        
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionID];
        if (chatMessageModel.messageType == CIMChatMessageType_ImageMessage) {
            _viewVideo.hidden = YES;
            if (![NSString isNil:chatMessageModel.localImgName]) {
                //本地图片
                NSString * path = [NSString getPathWithImageName:chatMessageModel.localImgName CustomPath:customPath];
                [_ivMedia sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DScreenWidth / 4.0, DScreenWidth / 4.0)] options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
            } else {
                [_ivMedia sd_setImageWithURL:[chatMessageModel.imgName getImageFullUrl] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DScreenWidth / 4.0, DScreenWidth / 4.0)] options:SDWebImageAllowInvalidSSLCertificates];
            }
        }else {
            _viewVideo.hidden = NO;
            
            if (![NSString isNil:chatMessageModel.localVideoCover]) {
                //本地视频封面
                NSString * path = [NSString getPathWithImageName:chatMessageModel.localVideoCover CustomPath:customPath];
                [_ivMedia sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DScreenWidth / 4.0, DScreenWidth / 4.0)] options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
            } else {
                [_ivMedia sd_setImageWithURL:[chatMessageModel.videoCover getImageFullUrl] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DScreenWidth / 4.0, DScreenWidth / 4.0)] options:SDWebImageAllowInvalidSSLCertificates];
            }
            _lblVideoTime.text = [NSDate transSecondToTimeMethod2:chatMessageModel.videoLength];
        }
    }
}

@end
