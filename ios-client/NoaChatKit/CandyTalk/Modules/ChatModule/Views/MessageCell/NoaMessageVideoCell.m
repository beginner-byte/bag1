//
//  NoaMessageVideoCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#define k_radius 18
#define k_arrow_radius 3

#import "NoaMessageVideoCell.h"
#import "NoaFileUploadManager.h"

@implementation NoaMessageVideoCell
{
    UIImageView *_snapshotImageView;
    UIImageView *_playImgView;
    UIImageView *_videoSignImgView;
    UILabel *_videoDuringLbl;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSnapshotUI];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // TODO: 优化cell复用导致图片展示错乱问题
    // 取消之前的图片加载操作
    [_snapshotImageView sd_cancelCurrentImageLoad];
    // 重置头像为nil，避免显示上一个cell的内容
    _snapshotImageView.image = nil;
}

#pragma mark - UI布局
- (void)setupSnapshotUI {
    _snapshotImageView = [[UIImageView alloc] init];
    _snapshotImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_snapshotImageView];
    
    UITapGestureRecognizer *contentSnapshotTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoContentTapClick)];
    [_snapshotImageView addGestureRecognizer:contentSnapshotTap];
    
    _playImgView = [[UIImageView alloc] init];
    _playImgView.image = ImgNamed(@"icon_video_msg_play");
    [self.contentView addSubview:_playImgView];
    [_playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_snapshotImageView);
    }];
    
    _videoSignImgView = [[UIImageView alloc] init];
    _videoSignImgView.image = ImgNamed(@"img_video_msg_sign");
    [self.contentView addSubview:_videoSignImgView];
    [_videoSignImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_snapshotImageView).offset(10);
        make.bottom.equalTo(_snapshotImageView).offset(-10);
        make.width.mas_equalTo(DWScale(18));
        make.height.mas_equalTo(DWScale(14));
    }];
    
    _videoDuringLbl = [[UILabel alloc] init];
    _videoDuringLbl.text = @"";
    _videoDuringLbl.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _videoDuringLbl.font = FONTN(13);
    [self.contentView addSubview:_videoDuringLbl];
    [_videoDuringLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_videoSignImgView.mas_trailing).offset(6);
        make.centerY.equalTo(_videoSignImgView);
        make.width.mas_equalTo(DWScale(45));
        make.height.mas_equalTo(DWScale(18));
    }];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    
    // 取消之前的图片加载操作
    [_snapshotImageView sd_cancelCurrentImageLoad];
    
    // 立即清空图片，避免显示旧数据
    _snapshotImageView.image = nil;
    
    WeakSelf
    [model setUploadFileFail:^{
        NoaFileUploadTask *videoTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:weakSelf.messageModel.message.msgID];
        NoaFileUploadTask *coverTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:[NSString stringWithFormat:@"%@_cover",weakSelf.messageModel.message.msgID]];
        [ZTOOL doInMain:^{
            if (videoTask.status == FileUploadTaskStatus_Failed || coverTask.status == FileUploadTaskStatus_Failed) {
                [super configMsgSendStatus:CIMChatMessageSendTypeFail];
            }
        }];
    }];
    
    _snapshotImageView.frame = _contentRect;
    _videoDuringLbl.text = [NSDate transSecondToTimeMethod2:model.message.videoLength];
    
    if (![NSString isNil:model.message.localVideoCover]) {
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionId];
        UIImage *localVideoCover = [NSString getImageWithImgName:model.message.localVideoCover CustomPath:customPath];
        if (localVideoCover) {
            //[_snapshotImageView sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:_contentRect.size]];
            _snapshotImageView.image = localVideoCover;
        } else {
            WeakSelf;
            [_snapshotImageView sd_setImageWithURL:[model.message.videoCover getImageFullUrl] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:_contentRect.size] options: SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                StrongSelf;
                [strongSelf loadWithImage:image URL:[model.message.thumbnailImg getImageFullString] error:error];
            }];
        }
    } else {
        [_snapshotImageView sd_setImageWithURL:[model.message.videoCover getImageFullUrl] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:_contentRect.size] options: SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            StrongSelf;
            [strongSelf loadWithImage:image URL:[model.message.thumbnailImg getImageFullString] error:error];
        }];
    }
    
    //将图片绘制成气泡的形状
    [self customDrawShapeIsSend:model.isSelf];
    
    if (model.isShowSelectBox) {
        _snapshotImageView.userInteractionEnabled = NO;
    } else {
        _snapshotImageView.userInteractionEnabled = YES;
    }
}

//重新绘制图片的形状
- (void)customDrawShapeIsSend:(BOOL)isSend {
    CGFloat width = _snapshotImageView.width;
    CGFloat height = _snapshotImageView.height;
   
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    maskPath.lineWidth = 1.0;
    maskPath.lineCapStyle = kCGLineCapRound;
    maskPath.lineJoinStyle = kCGLineJoinRound;
    //RTL 圆角要反过来
    if(ZLanguageTOOL.isRTL){
        if (!isSend) {
            [maskPath moveToPoint:CGPointMake(k_radius, height)]; //左下角
            [maskPath addLineToPoint:CGPointMake(width - k_radius, height)];
            [maskPath addQuadCurveToPoint:CGPointMake(width, height- k_radius) controlPoint:CGPointMake(width, height)]; //右下角的圆弧
            [maskPath addLineToPoint:CGPointMake(width, k_arrow_radius)]; //右边直线
          
            [maskPath addQuadCurveToPoint:CGPointMake(width - k_arrow_radius, 0) controlPoint:CGPointMake(width, 0)]; //右上角圆弧
            [maskPath addLineToPoint:CGPointMake(k_radius, 0)]; //顶部直线
          
            [maskPath addQuadCurveToPoint:CGPointMake(0, k_radius) controlPoint:CGPointMake(0, 0)]; //左上角圆弧
            [maskPath addLineToPoint:CGPointMake(0, height - k_radius)]; //左边直线
            [maskPath addQuadCurveToPoint:CGPointMake(k_radius, height) controlPoint:CGPointMake(0, height)]; //左下角圆弧
        } else {
            [maskPath moveToPoint:CGPointMake(k_radius, height)]; //左下角
            [maskPath addLineToPoint:CGPointMake(width - k_radius, height)];
            [maskPath addQuadCurveToPoint:CGPointMake(width, height- k_radius) controlPoint:CGPointMake(width, height)]; //右下角的圆弧
            [maskPath addLineToPoint:CGPointMake(width, k_radius)]; //右边直线
            [maskPath addQuadCurveToPoint:CGPointMake(width - k_radius, 0) controlPoint:CGPointMake(width, 0)]; //右上角圆弧
            [maskPath addLineToPoint:CGPointMake(k_arrow_radius, 0)]; //顶部直线
            [maskPath addQuadCurveToPoint:CGPointMake(0, k_arrow_radius) controlPoint:CGPointMake(0, 0)]; //左上角圆弧
            [maskPath addLineToPoint:CGPointMake(0, height - k_radius)]; //左边直线
            [maskPath addQuadCurveToPoint:CGPointMake(k_radius, height) controlPoint:CGPointMake(0, height)]; //左下角圆弧
        }
    }else{
        if (isSend) {
            [maskPath moveToPoint:CGPointMake(k_radius, height)]; //左下角
            [maskPath addLineToPoint:CGPointMake(width - k_radius, height)];
            [maskPath addQuadCurveToPoint:CGPointMake(width, height- k_radius) controlPoint:CGPointMake(width, height)]; //右下角的圆弧
            [maskPath addLineToPoint:CGPointMake(width, k_arrow_radius)]; //右边直线
          
            [maskPath addQuadCurveToPoint:CGPointMake(width - k_arrow_radius, 0) controlPoint:CGPointMake(width, 0)]; //右上角圆弧
            [maskPath addLineToPoint:CGPointMake(k_radius, 0)]; //顶部直线
          
            [maskPath addQuadCurveToPoint:CGPointMake(0, k_radius) controlPoint:CGPointMake(0, 0)]; //左上角圆弧
            [maskPath addLineToPoint:CGPointMake(0, height - k_radius)]; //左边直线
            [maskPath addQuadCurveToPoint:CGPointMake(k_radius, height) controlPoint:CGPointMake(0, height)]; //左下角圆弧
        } else {
            [maskPath moveToPoint:CGPointMake(k_radius, height)]; //左下角
            [maskPath addLineToPoint:CGPointMake(width - k_radius, height)];
            [maskPath addQuadCurveToPoint:CGPointMake(width, height- k_radius) controlPoint:CGPointMake(width, height)]; //右下角的圆弧
            [maskPath addLineToPoint:CGPointMake(width, k_radius)]; //右边直线
            [maskPath addQuadCurveToPoint:CGPointMake(width - k_radius, 0) controlPoint:CGPointMake(width, 0)]; //右上角圆弧
            [maskPath addLineToPoint:CGPointMake(k_arrow_radius, 0)]; //顶部直线
            [maskPath addQuadCurveToPoint:CGPointMake(0, k_arrow_radius) controlPoint:CGPointMake(0, 0)]; //左上角圆弧
            [maskPath addLineToPoint:CGPointMake(0, height - k_radius)]; //左边直线
            [maskPath addQuadCurveToPoint:CGPointMake(k_radius, height) controlPoint:CGPointMake(0, height)]; //左下角圆弧
        }
    }
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = CGRectMake(0, 0, _snapshotImageView.width, _snapshotImageView.height);
    maskLayer.path = maskPath.CGPath;
    _snapshotImageView.layer.mask = maskLayer;
}

#pragma mark - Tap Click
- (void)videoContentTapClick {
    // 点击播放视频
    if (!self.messageModel) return;
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellBrowserImageAndVideo:)]) {
        [self.delegate messageCellBrowserImageAndVideo:self.messageModel.message];
    }
}

- (void)loadWithImage:(UIImage *)image URL:(NSString *)url error:(NSError *)error {
    
    if (!image) {
        _snapshotImageView.image = [UIImage imageCompressFitSizeScale:DefaultNoImage targetSize:_contentRect.size];
        [self loadImageFailWithURL:url error:error];
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
