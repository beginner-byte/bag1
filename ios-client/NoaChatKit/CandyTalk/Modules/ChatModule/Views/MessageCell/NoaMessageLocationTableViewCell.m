//
//  ZMessageLocatiohnTableViewCell.m
//  CIMKit
//
//  Created by Apple on 2023/4/12.
//

#import "NoaMessageLocationTableViewCell.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapLocationKit/AMapLocationManager.h>

#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3
#define k_radius 18
#define k_arrow_radius 3
@interface NoaMessageLocationTableViewCell ()<MAMapViewDelegate, AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;
@property (nonatomic, strong) MAMapView *mapView;
@property(nonatomic,strong) UILabel * addressLabel;
@end

@implementation NoaMessageLocationTableViewCell
{
    UIImageView *_contentImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLocationUI];
    }
    return self;
}
- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];

    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
   // [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
}
#pragma mark - Initialization

- (void)initCompleteBlock
{
    __weak NoaMessageLocationTableViewCell *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        if (location)
        {
            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
            [annotation setCoordinate:location.coordinate];
            
            if (regeocode)
            {
                [annotation setTitle:[NSString stringWithFormat:@"%@", regeocode.formattedAddress]];
                [annotation setSubtitle:[NSString stringWithFormat:@"%@-%@-%.2fm", regeocode.citycode, regeocode.adcode, location.horizontalAccuracy]];
                regeocode.POIName;
            }
            else
            {
                [annotation setTitle:[NSString stringWithFormat:@"lat:%f;lon:%f;", location.coordinate.latitude, location.coordinate.longitude]];
                [annotation setSubtitle:[NSString stringWithFormat:@"accuracy:%.2fm", location.horizontalAccuracy]];
            }
            
            NSLog(@"我的个人位置:%@||%@-%@-%.2fm||%@-%@||%@||%@",regeocode.formattedAddress,regeocode.citycode, regeocode.adcode, location.horizontalAccuracy,regeocode.street,regeocode.number,regeocode.POIName,regeocode.AOIName);
            NoaMessageLocationTableViewCell *strongSelf = weakSelf;
            [strongSelf addAnnotationToMapView:annotation];
        }
    };
}
- (void)addAnnotationToMapView:(id<MAAnnotation>)annotation
{
    
    self.addressLabel.text = annotation.title;
    
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    [self.mapView setZoomLevel:11.1 animated:NO];
    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
}
-(void)setupLocationUI{
    _contentImageView = [[UIImageView alloc] init];
    _contentImageView.userInteractionEnabled = YES;
    _contentImageView.clipsToBounds = YES;
    [self.contentView addSubview:_contentImageView];

    UITapGestureRecognizer *contentImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgContentTapClick)];
    [_contentImageView addGestureRecognizer:contentImgTap];
    
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [_contentImageView addSubview:self.mapView];
    [self initCompleteBlock];
    [self configLocationManager];
    
    UIView * addressView = [[UIView alloc] init];
    addressView.backgroundColor = UIColor.whiteColor;
    [_contentImageView addSubview:addressView];
    
    [addressView addSubview:self.addressLabel];
    
    [addressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentImageView);
        make.right.mas_equalTo(_contentImageView);
        make.top.mas_equalTo(_contentImageView);
        make.height.mas_equalTo(66);
    }];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(addressView.mas_left).offset(16);
        make.right.mas_equalTo(addressView.mas_right).offset(-14);
        make.top.mas_equalTo(addressView.mas_top).offset(16);
        make.height.mas_equalTo(22);
    }];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentImageView);
        make.right.mas_equalTo(_contentImageView);
        make.top.mas_equalTo(addressView.mas_bottom);
        make.bottom.mas_equalTo(_contentImageView);
    }];
}
-(MAMapView*)mapView{
    if(_mapView == nil){
        _mapView = [[MAMapView alloc] init];
    }
    return _mapView;
}
-(UILabel*)addressLabel{
    if(_addressLabel == nil){
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = FONTN(16);
    }
    return _addressLabel;
}
-(void)showFLocation{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}
#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";

        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }

        annotationView.canShowCallout   = YES;
        annotationView.animatesDrop     = YES;
        annotationView.draggable        = NO;
        annotationView.pinColor         = MAPinAnnotationColorPurple;

        return annotationView;
    }

    return nil;
}
- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager
{
    [locationManager requestAlwaysAuthorization];
}
- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    _contentImageView.frame = _contentRect;
    
    if (model.isSelf) {
        self.addressLabel.tkThemetextColors = @[COLOR_33, COLOR_33_DARK];
    } else {
        self.addressLabel.tkThemetextColors = @[COLOR_33, COLOR_33_DARK];
    }
    
    [self showFLocation];
    //将图片绘制成气泡的形状
    [self customDrawShapeIsSend:model.isSelf];
}

//重新绘制图片的形状
- (void)customDrawShapeIsSend:(BOOL)isSend {
    CGFloat width = _contentImageView.width;
    CGFloat height = _contentImageView.height;
   
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    maskPath.lineWidth = 1.0;
    maskPath.lineCapStyle = kCGLineCapRound;
    maskPath.lineJoinStyle = kCGLineJoinRound;
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
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = CGRectMake(0, 0, _contentImageView.width, _contentImageView.height);
    maskLayer.path = maskPath.CGPath;
    _contentImageView.layer.mask = maskLayer;
}
@end
