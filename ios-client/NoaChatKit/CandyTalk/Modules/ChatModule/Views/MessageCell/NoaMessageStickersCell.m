//
//  NoaMessageStickersCell.m
//  NoaKit
//
//  Created by Candy on 2023/10/26.
//

#define k_radius 18
#define k_arrow_radius 3

#import "NoaMessageStickersCell.h"
#import "NoaToolManager.h"

@interface NoaMessageStickersCell ()

@end

@implementation NoaMessageStickersCell

{
    UIImageView *_contentImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupStickersUI];
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
- (void)setupStickersUI {
    _contentImageView = [[UIImageView alloc] init];
    _contentImageView.userInteractionEnabled = YES;
    [_contentImageView rounded:DWScale(6)];
    [self.contentView addSubview:_contentImageView];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    _contentImageView.frame = _contentRect;
   
    WeakSelf;
    [_contentImageView sd_setImageWithURL:[model.message.stickersImg getImageFullUrl] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:_contentRect.size] options:SDWebImageAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        StrongSelf;
        [strongSelf loadWithImage:image URL:[model.message.stickersImg getImageFullString] error:error];
    }];
    //将图片绘制成气泡的形状
    //[self customDrawShapeIsSend:model.isSelf];
    
    if (model.isShowSelectBox) {
        _contentImageView.userInteractionEnabled = NO;
    } else {
        _contentImageView.userInteractionEnabled = YES;
    }
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
