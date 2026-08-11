//
//  NoaFilePickerCell.m
//  NoaKit
//
//  Created by Candy on 2023/1/4.
//

#import "NoaFilePickerCell.h"
#import "NoaToolManager.h"//工具类

#define  LIMITED_SIZE 4000

@interface NoaFilePickerCell()

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)UIImageView *iconImgView;
@property (nonatomic, strong)UILabel *iconTypeLbl;
@property (nonatomic, strong)UILabel *titleLbl;
@property (nonatomic, strong)UILabel *subTitleLbl;
@property (nonatomic, strong)UIButton *selectedBtn;
@property (nonatomic, strong)UIView *lineView;

@end

@implementation NoaFilePickerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = COLOR_CLEAR;
        self.backgroundColor = COLOR_CLEAR;
        _imageManager = [[PHCachingImageManager alloc] init];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.iconImgView];
    [self.iconImgView addSubview:self.iconTypeLbl];
    [self.backView addSubview:self.titleLbl];
    [self.backView addSubview:self.subTitleLbl];
    [self.backView addSubview:self.selectedBtn];
    [self.backView addSubview:self.lineView];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.backView).offset(20);
        make.centerY.equalTo(self.backView);
        make.width.mas_equalTo(DWScale(28));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView);
        make.leading.equalTo(self.selectedBtn.mas_trailing).offset(18);
        make.width.mas_equalTo(DWScale(40));
        make.height.mas_equalTo(DWScale(40));
    }];
    
    [self.iconTypeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.iconImgView);
        make.bottom.equalTo(self.iconImgView).offset(-6);
        make.height.mas_equalTo(DWScale(10));
    }];
    
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView).offset(DWScale(12));
        make.leading.equalTo(self.iconImgView.mas_trailing).offset(12);
        make.trailing.equalTo(self.backView).offset(-16);
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.subTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLbl.mas_bottom).offset(DWScale(4));
        make.leading.equalTo(self.titleLbl);
        make.trailing.equalTo(self.backView).offset(-16);
        make.height.mas_equalTo(DWScale(18));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.backView);
        make.leading.equalTo(self.backView).offset(48);
        make.trailing.equalTo(self.backView);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - Data
- (void)setVideoAsset:(PHAsset *)videoAsset {
    _videoAsset = videoAsset;
    __weak typeof(self) weakSelf = self;
    
    PHImageRequestOptions *imgOptions = [PHImageRequestOptions new];
    imgOptions.synchronous = YES;//同步，如果有卡顿的情况，可设置为NO异步
    if (_videoAsset.pixelHeight > LIMITED_SIZE || _videoAsset.pixelWidth > LIMITED_SIZE) {
        imgOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    }else{
        imgOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
    }
    //设置视频封面
    [self.imageManager requestImageForAsset:_videoAsset
                                 targetSize:CGSizeMake(DScreenWidth / 4.0, DScreenWidth / 4.0)
                                contentMode:PHImageContentModeAspectFill
                                    options:imgOptions
                              resultHandler:^(UIImage *result, NSDictionary *info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            weakSelf.iconImgView.image = result;
        }
        
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            //options里的synchronous不能置为yes，会导致卡顿
            //options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [self.imageManager requestImageDataForAsset:_videoAsset options:imgOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *resultImage = [UIImage imageWithData:imageData];
                if (!resultImage) {
                    weakSelf.iconImgView.image = result;
                }
            }];
        }
    }];
    
    //设置视频名称和大小
    PHVideoRequestOptions *videoOptions = [[PHVideoRequestOptions alloc] init];
    videoOptions.version = PHVideoRequestOptionsVersionOriginal;
    [[PHImageManager defaultManager] requestAVAssetForVideo:_videoAsset options:videoOptions resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)asset;
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];

            //视频名称
            NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:weakSelf.videoAsset];
            PHAssetResource *resource = nil;
            for (PHAssetResource *res in resources) {
                if ([res.assetLocalIdentifier isEqualToString:weakSelf.videoAsset.localIdentifier]) {
                    resource = res;
                    break;
                }
            }
            NSString *videoName = resource.originalFilename;
            
            weakSelf.currentFileSize = [size floatValue];
            
            [ZTOOL doInMain:^{
                //视频大小
                weakSelf.subTitleLbl.text = [NSString fileTranslateToSize:[size floatValue]];
                //视频名称
                weakSelf.titleLbl.text = videoName;
            }];
        }
    }];
}

//文件名
- (void)setShowName:(NSString *)showName {
    _showName = showName;
    //文件名称
    //self.titleLbl.text = _showName;
    NSRange range = [_showName rangeOfString:@"-"];
    if(range.length == 0){
        self.titleLbl.text = _showName;
    }else{
        self.titleLbl.text = [_showName safeSubstringWithRange:NSMakeRange(range.location+1, _showName.length - (range.location+1))];
    }
}

//文件类型图标
- (void)setLocalFileType:(NSString *)localFileType {
    _localFileType = localFileType;
    //文件类型图标
    self.iconImgView.image = [UIImage getFileMessageIconWithFileType:_localFileType fileName:_showName];
    self.iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconTypeLbl.text = [NSString getFileTypeContentWithFileType:_localFileType fileName:_showName];
}

- (void)setLocalFileSize:(float)localFileSize {
    _localFileSize = localFileSize;
    //文件大小
    self.currentFileSize = _localFileSize;
    self.subTitleLbl.text = [NSString fileTranslateToSize:_localFileSize];
    
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.selectedBtn.selected = _isSelected;
}
        
#pragma mark - Lazy
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.tkThemebackgroundColors = @[COLORWHITE, COLOR_4E4E4E_DARK];
    }
    return _backView;
}

- (UIButton *)selectedBtn {
    if (!_selectedBtn) {
        _selectedBtn = [[UIButton alloc] init];
        [_selectedBtn setImage:ImgNamed(@"c_select_no") forState:UIControlStateNormal];
        [_selectedBtn setImage:ImgNamed(@"c_select_yes") forState:UIControlStateSelected];
        _selectedBtn.userInteractionEnabled = NO;
        _selectedBtn.selected = NO;
    }
    return _selectedBtn;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.backgroundColor = COLOR_CLEAR;
        [_iconImgView rounded:DWScale(2)];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _iconImgView;
}

- (UILabel *)iconTypeLbl {
    if (!_iconTypeLbl) {
        _iconTypeLbl = [[UILabel alloc] init];
        _iconTypeLbl.text = @"";
        _iconTypeLbl.tkThemetextColors = @[COLORWHITE, COLORWHITE];
        _iconTypeLbl.font = FONTN(10);
        _iconTypeLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _iconTypeLbl;
}

- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.text = @"";
        _titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _titleLbl.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLbl.font = FONTN(16);
    }
    return _titleLbl;
}

- (UILabel *)subTitleLbl {
    if (!_subTitleLbl) {
        _subTitleLbl = [[UILabel alloc] init];
        _subTitleLbl.text = @"";
        _subTitleLbl.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
        _subTitleLbl.font = FONTN(12);
    }
    return _subTitleLbl;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.1], [COLOR_00_DARK colorWithAlphaComponent:0.1]];
    }
    return _lineView;
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
