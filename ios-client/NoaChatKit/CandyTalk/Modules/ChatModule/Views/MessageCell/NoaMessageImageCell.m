//
//  NoaMessageImageCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#define k_radius 18
#define k_arrow_radius 3

#import "NoaMessageImageCell.h"
#import "MImageBrowserVC.h"
#import "NoaToolManager.h"
#import "NoaFileUploadManager.h"
#import <SDWebImage/SDAnimatedImageView.h>
#import <SDWebImage/SDAnimatedImageView+WebCache.h>
#import <SDWebImage/SDWebImage.h>

@interface NoaMessageImageCell () <MImageBrowserVCDelegate>

@end

@implementation NoaMessageImageCell
{
    SDAnimatedImageView *_contentImageView;
}

#pragma mark - GIF Playback Control
- (void)startGifPlayback {
    if (_contentImageView.image.sd_isAnimated) {
        [_contentImageView startAnimating];
    }
}

- (void)stopGifPlayback {
    if ([_contentImageView isAnimating]) {
        [_contentImageView stopAnimating];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupImageUI];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // TODO: 优化cell复用导致图片展示错乱问题
    // 取消之前的图片加载操作
    [_contentImageView sd_cancelCurrentImageLoad];
    // 停止动图播放并重置，避免复用残留
    [_contentImageView stopAnimating];
    _contentImageView.image = nil;
}

#pragma mark - UI布局
- (void)setupImageUI {
    _contentImageView = [[SDAnimatedImageView alloc] init];
    _contentImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_contentImageView];
    
    UITapGestureRecognizer *contentImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgContentTapClick)];
    [_contentImageView addGestureRecognizer:contentImgTap];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    WeakSelf
    _contentImageView.frame = _contentRect;
    
    // 取消之前的图片加载操作
    [_contentImageView sd_cancelCurrentImageLoad];
    // 停止动图播放并重置
    [_contentImageView stopAnimating];
    _contentImageView.image = nil;
    
    if (model.message.localImg != nil) {
        _contentImageView.image = model.message.localImg;
    } else if (![NSString isNil:model.message.localImgName]) {
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionId];
        
        NSString *localThumbImgPath = [NSString getPathWithImageName:model.message.localImgName CustomPath:customPath];
        //缩略图
        NSData *localImgData = [NSData dataWithContentsOfFile:localThumbImgPath];
        if (localImgData) {
            NSString *fmt = [[NSString getImageFileFormat:localImgData] lowercaseString];
            if ([fmt isEqualToString:@"gif"]) {
                // 本地 GIF：使用 SDAnimatedImage 支持动图
                SDAnimatedImage *animated = [SDAnimatedImage imageWithData:localImgData];
                _contentImageView.image = animated; // SDAnimatedImageView 自动播放
            } else {
                _contentImageView.image = [UIImage imageWithData:localImgData];
            }
        } else {
            NSString *thumbnailImg;
            if ([[model.message.imgName lowercaseString] containsString:@".gif"]) {
                thumbnailImg = model.message.imgName;
            } else {
                if ([NSString isNil:model.message.thumbnailImg]) {
                    thumbnailImg = model.message.imgName;
                } else {
                    thumbnailImg = model.message.thumbnailImg;
                }
            }
            // 远端缩略/原图
            BOOL isGIF = [[thumbnailImg lowercaseString] containsString:@".gif"];
            SDWebImageOptions options = (SDWebImageRetryFailed | SDWebImageContinueInBackground | SDWebImageHighPriority | SDWebImageAllowInvalidSSLCertificates);
            if (!isGIF) {
                options |= SDWebImageScaleDownLargeImages;
            }
            SDWebImageContext *context = @{
                SDImageCoderDecodeFirstFrameOnly: @(NO)
            };
            [_contentImageView sd_setImageWithURL:[thumbnailImg getImageFullUrl]
                                 placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:_contentRect.size]
                                          options:options
                                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                StrongSelf;
                [strongSelf loadWithImage:image URL:[model.message.thumbnailImg getImageFullString] error:error];
            }];
        }
    } else {
        WeakSelf;
        NSString *thumbnailImg;
        if ([[model.message.imgName lowercaseString] containsString:@".gif"]) {
            thumbnailImg = model.message.imgName;
        } else {
            if ([NSString isNil:model.message.thumbnailImg]) {
                thumbnailImg = model.message.imgName;
            } else {
                thumbnailImg = model.message.thumbnailImg;
            }
        }
        BOOL isGIF = [[thumbnailImg lowercaseString] containsString:@".gif"];
        SDWebImageOptions options = (SDWebImageRetryFailed | SDWebImageContinueInBackground | SDWebImageHighPriority | SDWebImageAllowInvalidSSLCertificates);
        if (!isGIF) {
            options |= SDWebImageScaleDownLargeImages;
        }
        SDWebImageContext *context = @{
            SDImageCoderDecodeFirstFrameOnly: @(NO)
        };
        [_contentImageView sd_setImageWithURL:[thumbnailImg getImageFullUrl]
                             placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:_contentRect.size]
                                      options:options
                                    completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            StrongSelf;
            [strongSelf loadWithImage:image URL:[model.message.thumbnailImg getImageFullString] error:error];
        }];
    }
    
    //上传回调
    [model setUploadFileFail:^{
        NoaFileUploadTask *imgTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:weakSelf.messageModel.message.msgID];
        NoaFileUploadTask *thumbImgTaskTask = [[NoaFileUploadManager sharedInstance] getTaskWithId:[NSString stringWithFormat:@"%@_thumb", weakSelf.messageModel.message.msgID]];
        [ZTOOL doInMain:^{
            if (imgTask.status == FileUploadTaskStatus_Failed || thumbImgTaskTask.status == FileUploadTaskStatus_Failed) {
                [super configMsgSendStatus:CIMChatMessageSendTypeFail];
            }
        }];
    }];
    
    //将图片绘制成气泡的形状
    [self customDrawShapeIsSend:model.isSelf];
    
    if (model.isShowSelectBox) {
        _contentImageView.userInteractionEnabled = NO;
    } else {
        _contentImageView.userInteractionEnabled = YES;
    }
}

- (void)setGiftImage:(UIImageView *)imageView url:(NSString *)url {
    WeakSelf
    SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageContinueInBackground | SDWebImageScaleDownLargeImages | SDWebImageHighPriority | SDWebImageAllowInvalidSSLCertificates;
    
    
    SDWebImageContext *context = @{
        SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(60, 60)),
        SDWebImageContextImageScaleDownLimitBytes: @(1024 * 1024 * 2)
    };
    [imageView sd_setImageWithURL:[url getImageFullUrl]
                 placeholderImage:nil
                          options:options
                          context:context
                         progress:nil
                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        StrongSelf;
        [strongSelf loadWithImage:image URL:[url getImageFullString] error:error];
    }];
}

//重新绘制图片的形状
- (void)customDrawShapeIsSend:(BOOL)isSend {
    CGFloat width = _contentImageView.width;
    CGFloat height = _contentImageView.height;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    maskPath.lineWidth = 1.0;
    maskPath.lineCapStyle = kCGLineCapRound;
    maskPath.lineJoinStyle = kCGLineJoinRound;
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
    maskLayer.frame = CGRectMake(0, 0, _contentImageView.width, _contentImageView.height);
    maskLayer.path = maskPath.CGPath;
    _contentImageView.layer.mask = maskLayer;
}

- (void)loadWithImage:(UIImage *)image URL:(NSString *)url error:(NSError *)error {
    
    if (!image) {
        _contentImageView.image = [UIImage imageCompressFitSizeScale:DefaultNoImage targetSize:_contentRect.size];
        [self loadImageFailWithURL:url error:error];
    }
}

#pragma mark - Tap Click
- (void)imgContentTapClick {
    // 点击查看大图
    if (!self.messageModel) return;
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellBrowserImageAndVideo:)]) {
        [self.delegate messageCellBrowserImageAndVideo:self.messageModel.message];
    }
}

#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
