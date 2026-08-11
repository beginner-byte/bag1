//
//  NoaImagePickerCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/29.
//

#import "NoaImagePickerCell.h"
#import "NoaImagePickerManager.h"

#define  LIMITED_SIZE 4000

@interface NoaImagePickerCell ()
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) PHAuthorizationStatus status;

@property (nonatomic, strong) UIView *viewVideoBg;
@property (nonatomic, strong) UIImageView *ivVideo;
@property (nonatomic, strong) UILabel *lblTime;

@property (nonatomic, strong) UIButton *btnCamera;
//资源大小
@property (nonatomic, assign) CGFloat assetSize;
@end

@implementation NoaImagePickerCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageManager = [[PHCachingImageManager alloc] init];
        if (@available(iOS 14, *)) {
            _status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        } else {
            _status = [PHPhotoLibrary authorizationStatus];
        }
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    _ivPhoto = [UIImageView new];
    _ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
    _ivPhoto.clipsToBounds = YES;
    [self.contentView addSubview:_ivPhoto];
    [_ivPhoto mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSelect setImage:ImgNamed(@"image_picker_select_no") forState:UIControlStateNormal];
    [_btnSelect setImage:ImgNamed(@"image_picker_select_yes") forState:UIControlStateSelected];
    [_btnSelect addTarget:self action:@selector(btnSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_btnSelect];
    [_btnSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(20), DWScale(20)));
    }];
    
    _viewVideoBg = [UIView new];
    _viewVideoBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self.contentView addSubview:_viewVideoBg];
    [_viewVideoBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(DWScale(40));
    }];
    _ivVideo = [[UIImageView alloc] initWithImage:ImgNamed(@"image_picker_video_logo")];
    [_viewVideoBg addSubview:_ivVideo];
    [_ivVideo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewVideoBg);
        make.leading.equalTo(_viewVideoBg).offset(DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(18), DWScale(14)));
    }];
    _lblTime = [UILabel new];
    _lblTime.textColor = COLORWHITE;
    _lblTime.font = FONTR(13);
    _lblTime.text = @"00:00";
    [_viewVideoBg addSubview:_lblTime];
    [_lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewVideoBg);
        make.trailing.equalTo(_viewVideoBg).offset(-DWScale(5));
        make.leading.equalTo(_ivVideo.mas_trailing).offset(DWScale(5));
    }];
    _viewVideoBg.hidden = YES;
    
    _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCamera setImage:[UIImage imageNamed:@"image_picker_camera"] forState:UIControlStateNormal];
    [_btnCamera setBackgroundColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1]];
    [_btnCamera addTarget:self action:@selector(btnCameraClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_btnCamera];
    [_btnCamera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}
#pragma mark - 数据赋值
- (void)setAsset:(PHAsset *)asset {
    if (asset) {
        _btnCamera.hidden = YES;
        
        _asset = asset;
        
        [self getImageFromAsset:asset];
        
        [self calculateAssetSize];
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            _viewVideoBg.hidden = YES;
        }else {
            _viewVideoBg.hidden = NO;
            _lblTime.text = [self stringFromTime:asset.duration];
        }
        
        __block BOOL containSelected = NO;
        [IMAGEPICKER.zSelectedAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.localIdentifier isEqualToString:asset.localIdentifier]) {
                containSelected = YES;
                *stop = YES;
            }
        }];
        _btnSelect.selected = containSelected;
        
    }else {
        _btnCamera.hidden = NO;
    }
}

- (void)setIsHiddenSelect:(BOOL)isHiddenSelect {
    _isHiddenSelect = isHiddenSelect;
    _btnSelect.hidden =  isHiddenSelect;
}

#pragma mark - 获取图片或视频封面
- (void)getImageFromAsset:(PHAsset *)asset{
    WeakSelf
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    //options里的synchronous不能置为yes，会导致卡顿
    options.synchronous = YES;//同步，如果有卡顿的情况，可设置为NO异步
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    
    if (asset.pixelHeight > LIMITED_SIZE || asset.pixelWidth > LIMITED_SIZE) {
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
    } else{
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
    }
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(DScreenWidth / 4.0, DScreenWidth / 4.0)
                                contentMode:PHImageContentModeAspectFill
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            weakSelf.ivPhoto.image = result;
        }
        
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            //options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [weakSelf.imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *resultImage = [UIImage imageWithData:imageData];
                if (!resultImage) {
                    weakSelf.ivPhoto.image = resultImage;
                }
            }];
        }
    }];
}

- (NSString *)stringFromTime:(NSTimeInterval)timeInterval {
    NSString *duration;
    NSInteger second = 0;
    NSInteger minute = 0;
    NSInteger hour = 0;
    second = (NSInteger)timeInterval;
    minute = floor(second / 60);
    hour = floor(minute / 60);
    minute = minute - hour * 60;
    second = second - minute * 60;
    
    NSString *secondStr = second > 10 ? [NSString stringWithFormat:@"%ld",second] : [NSString stringWithFormat:@"0%ld",second];
    NSString *minuteStr = minute > 10 ? [NSString stringWithFormat:@"%ld",minute] : [NSString stringWithFormat:@"0%ld",minute];
    NSString *hourStr = hour > 10 ? [NSString stringWithFormat:@"%ld",hour] : [NSString stringWithFormat:@"0%ld",hour];
    
    if (hour > 0) {
        duration = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minuteStr,secondStr];
    }else if (minute > 0){
        duration = [NSString stringWithFormat:@"%@:%@",minuteStr,secondStr];
    }else {
        duration = secondStr;
    }
    
    return duration;
}
//计算资源大小
- (void)calculateAssetSize {
    __weak typeof(self) weakSelf = self;
    
    //图片
    if (_asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.networkAccessAllowed = YES;
        options.version = PHImageRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestImageDataForAsset:_asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            weakSelf.assetSize = imageData.length;
        }];
    }
    
    //视频
    if (_asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
        options.networkAccessAllowed = YES;
        options.version = PHVideoRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                NSNumber *size;
                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                weakSelf.assetSize = [size floatValue];
         }
        }];
    }
    
}
#pragma mark - 交互事件
- (void)btnSelectClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    //防连续点击事件
    button.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.userInteractionEnabled = YES;
    });
    
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerCellSelected:)]) {
        [_delegate imagePickerCellSelected:_asset];
    }
}
- (void)btnCameraClick {
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerCellCamera)]) {
        [_delegate imagePickerCellCamera];
    }
}
@end
