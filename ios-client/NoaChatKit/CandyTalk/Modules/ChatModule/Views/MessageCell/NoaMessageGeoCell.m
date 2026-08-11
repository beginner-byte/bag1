//
//  NoaMessageGeoCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/13.
//

#import "NoaMessageGeoCell.h"

#define k_radius 18
#define k_arrow_radius 3

@implementation NoaMessageGeoCell
{
    UILabel *_geoTitleLbl;
    UILabel *_geoSubTitleLbl;
    UIImageView *_geoImgView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupGeoUI];
    }
    return self;
}

#pragma mark - UI布局
- (void)setupGeoUI {
    _geoTitleLbl = [[UILabel alloc] init];
    _geoTitleLbl.text = @"";
    _geoTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _geoTitleLbl.font = FONTN(16);
    _geoTitleLbl.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_geoTitleLbl];
    
    _geoSubTitleLbl = [[UILabel alloc] init];
    _geoSubTitleLbl.text = @"";
    _geoSubTitleLbl.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _geoSubTitleLbl.font = FONTN(10);
    _geoSubTitleLbl.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_geoSubTitleLbl];
    [_geoSubTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_geoTitleLbl.mas_bottom).offset(DWScale(4));
        make.leading.trailing.equalTo(_geoTitleLbl);
        make.height.mas_equalTo(DWScale(16));
    }];
    
    _geoImgView = [[UIImageView alloc] init];
    _geoImgView.image = DefaultImage;
    _geoImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_geoImgView];
    [_geoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_geoSubTitleLbl.mas_bottom).offset(DWScale(10));
        make.leading.trailing.bottom.equalTo(self.viewSendBubble);
    }];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    //标题
    _geoTitleLbl.frame = _contentRect;
    _geoTitleLbl.text = model.message.geoName;
    //副标题
    _geoSubTitleLbl.text = model.message.geoDetails;
    //位置图片
    if (![NSString isNil:model.message.localGeoImgName]) {
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionId];
        NSString * path = [NSString getPathWithImageName:model.message.localGeoImgName CustomPath:customPath];
        [_geoImgView sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DWScale(250), DWScale(94))] options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
    } else {
        [_geoImgView sd_setImageWithURL:[model.message.geoImg getImageFullUrl] placeholderImage:[UIImage imageCompressFitSizeScale:DefaultImage targetSize:CGSizeMake(DWScale(250), DWScale(94))] options:SDWebImageAllowInvalidSSLCertificates];        
    }
    
    //UI
    if (model.isSelf) {
        [_geoImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_geoSubTitleLbl.mas_bottom).offset(DWScale(10));
            make.leading.trailing.bottom.equalTo(self.viewSendBubble);
        }];
    } else {
        [_geoImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_geoSubTitleLbl.mas_bottom).offset(DWScale(10));
            make.leading.trailing.bottom.equalTo(self.viewReceiveBubble);
        }];
    }
    
    //上传回调
    /*
    [model setUploadFileSuccess:^{
        [ZTOOL doInMain:^{
            [super configMsgSendStatus:CIMChatMessageSendTypeSuccess];
        }];
    }];
    */
    [model setUploadFileFail:^{
        [ZTOOL doInMain:^{
            [super configMsgSendStatus:CIMChatMessageSendTypeFail];
        }];
    }];
    
    
    //将位置图片绘制成气泡的形状
    [self customDrawShapeIsSend:model.isSelf];
}

//重新绘制图片的形状
- (void)customDrawShapeIsSend:(BOOL)isSend {
    CGFloat width = DWScale(250);
    CGFloat height = DWScale(94);
   
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    maskPath.lineWidth = 1.0;
    maskPath.lineCapStyle = kCGLineCapRound;
    maskPath.lineJoinStyle = kCGLineJoinRound;
    if(ZLanguageTOOL.isRTL){
        if (!isSend) {
            [maskPath moveToPoint:CGPointMake(k_radius, height)]; //左下角
            [maskPath addLineToPoint:CGPointMake(width - k_radius, height)];
            [maskPath addQuadCurveToPoint:CGPointMake(width, height- k_radius) controlPoint:CGPointMake(width, height)]; //右下角的圆弧
            [maskPath addLineToPoint:CGPointMake(width, 0)]; //右边直线
            [maskPath addLineToPoint:CGPointMake(0, 0)]; //顶部直线
            [maskPath addLineToPoint:CGPointMake(0, height - k_radius)]; //左边直线
            [maskPath addQuadCurveToPoint:CGPointMake(k_radius, height) controlPoint:CGPointMake(0, height)]; //左下角圆弧
        } else {
            [maskPath moveToPoint:CGPointMake(k_radius, height)]; //左下角
            [maskPath addLineToPoint:CGPointMake(width - k_radius, height)];
            [maskPath addQuadCurveToPoint:CGPointMake(width, height- k_radius) controlPoint:CGPointMake(width, height)]; //右下角的圆弧
            [maskPath addLineToPoint:CGPointMake(width, 0)]; //右边直线
            [maskPath addLineToPoint:CGPointMake(0, 0)]; //顶部直线
            [maskPath addLineToPoint:CGPointMake(0, height - k_radius)]; //左边直线
            [maskPath addQuadCurveToPoint:CGPointMake(k_radius, height) controlPoint:CGPointMake(0, height)]; //左下角圆弧
        }
    }else{
        if (isSend) {
            [maskPath moveToPoint:CGPointMake(k_radius, height)]; //左下角
            [maskPath addLineToPoint:CGPointMake(width - k_radius, height)];
            [maskPath addQuadCurveToPoint:CGPointMake(width, height- k_radius) controlPoint:CGPointMake(width, height)]; //右下角的圆弧
            [maskPath addLineToPoint:CGPointMake(width, 0)]; //右边直线
            [maskPath addLineToPoint:CGPointMake(0, 0)]; //顶部直线
            [maskPath addLineToPoint:CGPointMake(0, height - k_radius)]; //左边直线
            [maskPath addQuadCurveToPoint:CGPointMake(k_radius, height) controlPoint:CGPointMake(0, height)]; //左下角圆弧
        } else {
            [maskPath moveToPoint:CGPointMake(k_radius, height)]; //左下角
            [maskPath addLineToPoint:CGPointMake(width - k_radius, height)];
            [maskPath addQuadCurveToPoint:CGPointMake(width, height- k_radius) controlPoint:CGPointMake(width, height)]; //右下角的圆弧
            [maskPath addLineToPoint:CGPointMake(width, 0)]; //右边直线
            [maskPath addLineToPoint:CGPointMake(0, 0)]; //顶部直线
            [maskPath addLineToPoint:CGPointMake(0, height - k_radius)]; //左边直线
            [maskPath addQuadCurveToPoint:CGPointMake(k_radius, height) controlPoint:CGPointMake(0, height)]; //左下角圆弧
        }
    }
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = CGRectMake(0, 0, width, height);
    maskLayer.path = maskPath.CGPath;
    _geoImgView.layer.mask = maskLayer;
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
