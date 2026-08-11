//
//  NoaImagePickerVC.m
//  NoaKit
//
//  Created by Candy on 2026/10/9.
//

#import "NoaImagePickerVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NoaImagePickerCell.h"//图片展示
#import "NoaToolManager.h"//工具类
#import "NoaClipImageVC.h"//图片裁剪
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

//下载iCloud资源
typedef void(^ZDownloadAsset) (PHAsset *);

@interface NoaImagePickerVC () <UICollectionViewDataSource,UICollectionViewDelegate,ZImagePickerCellDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, ZClipImageVCDelegate>
{
    BOOL _isPhotoOk;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <PHAsset *> *imageList;
@property (nonatomic, strong) UIButton *btnOriginal;//原图
@property (nonatomic, strong) UILabel *lblTotalMB;
@property (nonatomic, assign) BOOL isCalculatingSize;//是否正在计算大小

@end

@implementation NoaImagePickerVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //全局隐藏导系统的航栏，使用自定义的navbar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.view bringSubviewToFront:self.navView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _imageList = [NSMutableArray array];
    
    [self checkAuthority];
    
    [self setupNavUI];
    
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChanged) name:ALBUMUPDATE object:nil];
    
    //默认可选择图片和视频
    IMAGEPICKER.pickerType = ZImagePickerTypeAll;
}
#pragma mark - 获取相册全部资源
- (void)requestAlbumAll {
    //获取手机相册图片
    __weak typeof(self) weakSelf = self;
    [ZTOOL doAsync:^{
        [weakSelf.imageList removeAllObjects];
        [HUD showActivityMessage:LanguageToolMatch(@"加载中...")];
        [IMAGEPICKER getAllPhotoList];
        
    } completion:^{
        weakSelf.imageList = [weakSelf fetchLocalCoverListWithAssets:IMAGEPICKER.allPhotoList];
        [HUD hideHUD];
        [weakSelf.collectionView reloadData];
        [weakSelf calculateSelectImageSize];
        
    }];
}

- (void)requestAlbumlimt {
    //获取手机相册图片
    __weak typeof(self) weakSelf = self;
    [ZTOOL doAsync:^{
        [weakSelf.imageList removeAllObjects];
        [HUD showActivityMessage:LanguageToolMatch(@"加载中...")];
        [IMAGEPICKER getLimtPhotoList];
        
    } completion:^{
        weakSelf.imageList = [weakSelf fetchLocalCoverListWithAssets:IMAGEPICKER.allPhotoList];
        [HUD hideHUD];
        [weakSelf.collectionView reloadData];
        [weakSelf calculateSelectImageSize];
        
    }];
}


#pragma mark - 检测相册权限
- (void)checkAuthority {
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:level];
            switch (status) {
                case PHAuthorizationStatusLimited:
                {
                    NSLog(@"limited");
                    [weakSelf requestAlbumlimt];
                    //权限处理逻辑看下方
                    //这里可以直接调取从新选择图片，也可以直接调取 [self limtShow];
                    //建议每次启动后做一次选择图片处理 在调用[self limtShow]展示
                }
                    break;
                case PHAuthorizationStatusDenied:
                {
                    //未授权
                    _isPhotoOk = NO;
                }
                    break;
                case PHAuthorizationStatusAuthorized:
                {
                    //授权
                    _isPhotoOk = YES;
                    [weakSelf requestAlbumAll];
                }
                    break;
                case PHAuthorizationStatusNotDetermined:
                {
                    //没有询问是否开启相册
                    //请求访问相册权限
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                        if (status == PHAuthorizationStatusAuthorized) {
                            //权限正常
                            self->_isPhotoOk = YES;
                            [weakSelf requestAlbumAll];
                        } else {
                            //此处要在主线程操作UI
                            //相册权限未设置,请开启相册权限
                            self->_isPhotoOk = NO;
                        }
                    }];
                }
                    break;
                default:
                    break;
        }
    } else {
        //判断相册权限
        PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
        switch (photoAuthorStatus) {
            case PHAuthorizationStatusAuthorized:
            {
                //授权
                _isPhotoOk = YES;
                [weakSelf requestAlbumAll];
            }
                break;
            case PHAuthorizationStatusNotDetermined:
            {
                //没有询问是否开启相册
                //请求访问相册权限
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        //权限正常
                        self->_isPhotoOk = YES;
                        [weakSelf requestAlbumAll];
                    } else {
                        //此处要在主线程操作UI
                        //相册权限未设置,请开启相册权限
                        self->_isPhotoOk = NO;
                    }
                }];
            }
                break;
            case PHAuthorizationStatusDenied:
            {
                //未授权
                _isPhotoOk = NO;
            }
                break;
            case PHAuthorizationStatusRestricted:
            {
                //未授权，家长限制
                _isPhotoOk = NO;
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - 界面布局
- (void)setupNavUI {
    _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DNavStatusBarH)];
    _navView.tkThemebackgroundColors = @[COLOR_11, COLOR_11];
    [self.view addSubview:_navView];
    
    _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DWScale(60), DStatusBarH, DScreenWidth - DWScale(120), DNavBarH)];
    _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    _navTitleLabel.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _navTitleLabel.font = [UIFont systemFontOfSize:18];
    _navTitleLabel.numberOfLines = 1;
    _navTitleLabel.text = _isSignlePhoto ? LanguageToolMatch(@"选择") : LanguageToolMatch(@"选择图片");
    [_navView addSubview:_navTitleLabel];
    
    _navLineView = [[UIView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH - 0.5, DScreenWidth, 0.8)];
    _navLineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    _navLineView.hidden = YES;
    [_navView addSubview:_navLineView];
    
    _navBtnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    _navBtnBack.adjustsImageWhenHighlighted = NO;
    _navBtnBack.exclusiveTouch = YES;
    [_navBtnBack setImage:[UIImage imageNamed:@"image_picker_back"] forState:UIControlStateNormal];
    [_navBtnBack addTarget:self action:@selector(navBtnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navBtnBack];
    [_navBtnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_navTitleLabel);
        make.leading.equalTo(_navView).offset(DWScale(10));
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(44);
    }];
    [_navBtnBack setEnlargeEdge:DWScale(10)];

    _navBtnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    _navBtnRight.layer.cornerRadius = 10;
    _navBtnRight.layer.masksToBounds = YES;
    _navBtnRight.backgroundColor = COLOR_99;
    [_navBtnRight setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _navBtnRight.titleLabel.font = [UIFont systemFontOfSize:12];
    _navBtnRight.hidden = _isSignlePhoto;
    [_navBtnRight addTarget:self action:@selector(navBtnRightClicked) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navBtnRight];
    [_navBtnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_navTitleLabel);
        make.trailing.equalTo(_navView).offset(-16);
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(63);
    }];
    [_navBtnRight setEnlargeEdge:DWScale(10)];

    //默认9张
//    _maxSelectNum = 9;
    
}

//导航栏标题赋值
- (void)setNavTitleStr:(NSString *)navTitleStr {
    _navTitleStr = navTitleStr;
    _navTitleLabel.text = navTitleStr;
}
//最大选中图片
- (void)setMaxSelectNum:(NSInteger)maxSelectNum {
    _maxSelectNum = maxSelectNum;
    [self calculateSelectImageSize];
}
- (void)setPickerType:(ZImagePickerType)pickerType {
    _pickerType = pickerType;
    IMAGEPICKER.pickerType = pickerType;
    [self requestAlbumAll];
}

#pragma mark - 界面布局
- (void)setupUI {
    if (_isSignlePhoto) {
        self.view.tkThemebackgroundColors = @[COLOR_11, COLOR_11];
    } else {
        self.view.tkThemebackgroundColors = @[COLOR_22, COLOR_22];
    }

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(DScreenWidth / 4.0, DScreenWidth / 4.0);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH, DScreenWidth, DScreenHeight - DWScale(46) - DHomeBarH - DNavStatusBarH) collectionViewLayout:layout];
    _collectionView.tkThemebackgroundColors = @[COLOR_11, COLOR_11];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[NoaImagePickerCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaImagePickerCell class])];
    [self.view addSubview:_collectionView];
    
    if (!_isSignlePhoto) {
        _lblTotalMB = [UILabel new];
        _lblTotalMB.tkThemetextColors = @[COLORWHITE, COLORWHITE];
        _lblTotalMB.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_lblTotalMB];
        [_lblTotalMB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(DWScale(46));
            make.bottom.equalTo(self.view).offset(-DHomeBarH);
        }];
    }
    
//    UIView *viewBottomCenter = [UIView new];
//    viewBottomCenter.backgroundColor = UIColor.clearColor;
//    [self.view addSubview:viewBottomCenter];
//
//    _btnOriginal = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_btnOriginal setImage:ImgNamed(@"image_picker_select_no") forState:UIControlStateNormal];
//    [_btnOriginal setImage:ImgNamed(@"image_picker_select_yes") forState:UIControlStateSelected];
//    [_btnOriginal setTitle:@" 原图" forState:UIControlStateNormal];
//    [_btnOriginal setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//    _btnOriginal.titleLabel.font = [UIFont systemFontOfSize:16];
//    [_btnOriginal addTarget:self action:@selector(btnOriginalClick) forControlEvents:UIControlEventTouchUpInside];
//    [viewBottomCenter addSubview:_btnOriginal];
//
//    _lblTotalMB = [UILabel new];
//    _lblTotalMB.textColor = [UIColor colorWithWhite:1 alpha:0.8];
//    _lblTotalMB.font = [UIFont systemFontOfSize:12];
//    _lblTotalMB.text = @"";
//    _lblTotalMB.hidden = YES;
//    [viewBottomCenter addSubview:_lblTotalMB];
//
//    [_btnOriginal mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(viewBottomCenter);
//        make.centerY.equalTo(viewBottomCenter);
//        make.height.mas_equalTo(DWScale(20));
//        make.trailing.equalTo(_lblTotalMB.mas_leading);
//    }];
//
//    [_lblTotalMB mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(_btnOriginal);
//        make.leading.equalTo(_btnOriginal.mas_trailing);
//        make.trailing.equalTo(viewBottomCenter);
//    }];
//
//    [viewBottomCenter mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.height.mas_equalTo(DWScale(46));
//        make.bottom.equalTo(self.view).offset(-DHomeBarH);
//        make.leading.equalTo(_btnOriginal);
//        make.trailing.equalTo(_lblTotalMB);
//    }];
    
}
- (NSMutableArray <PHAsset *> *)fetchLocalCoverListWithAssets:(NSMutableSet *)assetSet {
    // 排序
    NSMutableArray *array = [NSMutableArray arrayWithArray:assetSet.allObjects];
    [self quickSortArray:array withLeftIndex:0 andRightIndex:array.count - 1];
    return array;
}

// 快速排序
- (void)quickSortArray:(NSMutableArray *)array withLeftIndex:(NSInteger)leftIndex andRightIndex:(NSInteger)rightIndex {
    if (leftIndex >= rightIndex) {  // 如果数组长度为0或1时返回
        return;
    }

    NSInteger i = leftIndex;
    NSInteger j = rightIndex;
    // 记录比较基准数
    PHAsset *key = array[i];

    while (i < j) {
        // 首先从右边j开始查找比基准数大的值
        while (i < j && [self compareAssetCreationDate:array[j] targetAsset:key] <= 0) {  // 如果比基准数小，继续查找
            j--;
        }
        // 如果比基准数大，则将查找到的值调换到i的位置
        array[i] = array[j];

        // 当在右边查找到一个比基准数大的值时，就从i开始往后找比基准数小的值
        while (i < j && [self compareAssetCreationDate:array[i] targetAsset:key] >= 0) {  // 如果比基准数大，继续查找
            i++;
        }
        // 如果比基准数小，则将查找到的值调换到j的位置
        array[j] = array[i];
    }

    // 将基准数放到正确位置
    array[i] = key;

    /**** 递归排序 ***/
    // 排序基准数左边的
    [self quickSortArray:array withLeftIndex:leftIndex andRightIndex:i - 1];
    // 排序基准数右边的
    [self quickSortArray:array withLeftIndex:i + 1 andRightIndex:rightIndex];
}

// 比较大小(asset == targetAsset -> 0，asset > targetAsset -> 1，asset < targetAsset -> -1)
- (NSInteger)compareAssetCreationDate:(PHAsset *)asset targetAsset:(PHAsset *)targetAsset {
    NSInteger result = 0;
    switch ([asset.creationDate compare:targetAsset.creationDate]) {
        case NSOrderedSame:
            result = 0;
            break;
        case NSOrderedDescending:
            result = 1;
            break;
        case NSOrderedAscending:
            result = -1;
            break;
        default:
            break;
    }
    return result;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _hasCamera ? _imageList.count + 1 : _imageList.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaImagePickerCell class]) forIndexPath:indexPath];
    PHAsset *asset;
    if (_hasCamera) {
        asset = [_imageList objectAtIndexSafe:indexPath.row - 1];
    }else {
        asset = [_imageList objectAtIndexSafe:indexPath.row];
    }
    cell.isHiddenSelect = self.isSignlePhoto;
    cell.asset = asset;
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [_imageList objectAtIndexSafe:indexPath.row - 1];
    if (asset.mediaType == PHAssetMediaTypeImage) {
        if (_isSignlePhoto) {
            WeakSelf
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *resultImage, NSDictionary *info) {
                if ([[info valueForKey:@"PHImageResultIsDegradedKey"] integerValue] == 0){
                    float imgSize = CGImageGetHeight(resultImage.CGImage) * CGImageGetBytesPerRow(resultImage.CGImage);
                    if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"] && ((imgSize / (1024 * 1024.0)) > [UserManager.userRoleAuthInfo.upImageVideoFile.configData integerValue])) {
                        [HUD showMessage:LanguageToolMatch(@"所选资源超过限制")];
                        return;
                    } else {
                        if (weakSelf.isNeedEdit) {
                            //图片编辑
                            [weakSelf clipImageAction:resultImage];
                        } else {
                            NSString *localIdentifier = asset.localIdentifier;
                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imagePickerClipImage:localIdenti:)]) {
                                [weakSelf.delegate imagePickerClipImage:resultImage localIdenti:localIdentifier];
                            }
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }
                    }
                }
            }];
        } else {
            //大图浏览
            //[self browserPhoto:asset];
        }
        
    }else {
        //视频浏览
        //[self browserVideo:asset];
    }
}

- (void)browserPhoto:(PHAsset *)selectedAsset {
    
}
- (void)browserVideo:(PHAsset *)selectedAsset {
    
}

#pragma mark - 图片裁剪
- (void)clipImageAction:(UIImage *)originImage {
    NoaClipImageVC *clipImgVC = [[NoaClipImageVC alloc] init];
    clipImgVC.delegate = self;
    clipImgVC.image = originImage;
    //设置自定义裁剪区域大小
    clipImgVC.cropSize = CGSizeMake(DWScale(343), DWScale(343));
    clipImgVC.isRound = NO;
    [self.navigationController pushViewController:clipImgVC animated:YES];
}

#pragma mark - ZClipImageVCDelegate
- (void)clipImageDidFinishedWithImage:(UIImage *)image {
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerClipImage:localIdenti:)]) {
        [_delegate imagePickerClipImage:image localIdenti:@""];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ZImagePickerCellDelegate
//点击拍照
- (void)imagePickerCellCamera {
    if (!_isSignlePhoto) {
        if (IMAGEPICKER.zSelectedAssets.count >= _maxSelectNum) {
            [HUD showMessage:[NSString stringWithFormat:LanguageToolMatch(@"最多只能选择%ld张照片"),_maxSelectNum]];
            return;;
        }
    }
    [self openCamera];
    
}
//选中
- (void)imagePickerCellSelected:(PHAsset *)asset {
    //检测资源是否在iCloud上
    if ([self checkAssetInCloud:asset]) {
        __weak typeof(self) weakSelf = self;
        [self downloadAssetFromCloud:asset complate:^(PHAsset *phAsset) {
            if (phAsset) {
                [weakSelf selectedWithAsset:phAsset];
            }
        }];
    }else {
        [self selectedWithAsset:asset];
    }
    
}
//选中一个资源的处理
- (void)selectedWithAsset:(PHAsset * _Nullable)phAsset {
    __block BOOL containSelect = NO;
    __block NSInteger indexSelect;
    [IMAGEPICKER.zSelectedAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.localIdentifier isEqualToString:phAsset.localIdentifier]) {
            //存在则删除
            //不存在则添加
            containSelect = YES;
            indexSelect = idx;
            *stop = YES;
        }
    }];
    if (containSelect) {
        [IMAGEPICKER.zSelectedAssets removeObjectAtIndex:indexSelect];
        [_collectionView reloadData];
        [self calculateSelectImageSize];
    }else {
        
        if (IMAGEPICKER.zSelectedAssets.count >= _maxSelectNum) {
            [HUD showMessage:[NSString stringWithFormat:LanguageToolMatch(@"最多只能选择%ld张照片"),_maxSelectNum]];
            return;
        }else {
            WeakSelf
            if (phAsset.mediaType == PHAssetMediaTypeImage) {
                //图片
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.networkAccessAllowed = YES;
                options.version = PHImageRequestOptionsVersionOriginal;
                [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:phAsset options:options resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary *_Nullable info) {
                    
                    float imgSize = imageData.length;
                    if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"] && ((imgSize / (1024 * 1024.0)) > [UserManager.userRoleAuthInfo.upImageVideoFile.configData integerValue])) {
                        [HUD showMessage:LanguageToolMatch(@"所选资源超过限制")];
                        return;
                    } else {
                        //添加选中
                        [IMAGEPICKER.zSelectedAssets addObject:phAsset];
                        [ZTOOL doInMain:^{
                            [weakSelf.collectionView reloadData];
                        }];
                        [weakSelf calculateSelectImageSize];
                    }
                }];
            }
            if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                //视频
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
                options.networkAccessAllowed = YES;
                options.version = PHVideoRequestOptionsVersionOriginal;
                [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                    if ([asset isKindOfClass:[AVURLAsset class]]) {
                        AVURLAsset* urlAsset = (AVURLAsset*)asset;
                        NSNumber *size;
                        [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                        float videoSize = [size floatValue];
                        if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"] && ((videoSize / (1024 * 1024.0)) > [UserManager.userRoleAuthInfo.upImageVideoFile.configData integerValue])) {
                            [HUD showMessage:LanguageToolMatch(@"所选资源超过限制")];
                            return;
                        } else {
                            //添加选中
                            [IMAGEPICKER.zSelectedAssets addObject:phAsset];
                            [ZTOOL doInMain:^{
                                [weakSelf.collectionView reloadData];
                            }];
                            [weakSelf calculateSelectImageSize];
                        }
                    }
                }];
            }
        }
    }
}
//计算选中图片大小
- (void)calculateSelectImageSize {
    // 防重复计算 - 使用实例变量而不是静态变量
    if (_isCalculatingSize) {
        return;
    }
    
    _isCalculatingSize = YES;
    __weak typeof(self) weakSelf = self;
    
    // 先更新UI显示，避免用户看到"加载中"
    [ZTOOL doInMain:^{
        weakSelf.lblTotalMB.text = [NSString stringWithFormat:LanguageToolMatch(@"共%ld个文件"),IMAGEPICKER.zSelectedAssets.count];
        [weakSelf.navBtnRight setTitle:[NSString stringWithFormat:LanguageToolMatch(@"%ld/%ld发送"),IMAGEPICKER.zSelectedAssets.count,weakSelf.maxSelectNum] forState:UIControlStateNormal];
        if (IMAGEPICKER.zSelectedAssets.count > 0) {
            [weakSelf.navBtnRight setBackgroundColor:COLOR_5966F2];
        }else {
            [weakSelf.navBtnRight setBackgroundColor:COLOR_99];
        }
    }];
    
    [self getPhotoBytesWith:[IMAGEPICKER.zSelectedAssets copy] completion:^(NSString *totalBytes) {
        [ZTOOL doInMain:^{
            weakSelf.lblTotalMB.text = [NSString stringWithFormat:LanguageToolMatch(@"共%@"),totalBytes];
            weakSelf.isCalculatingSize = NO; // 重置标志
        }];
    }];
}

- (void)getPhotoBytesWith:(NSArray *)photos completion:(void (^) (NSString *totalBytes))completion {
    
    if (!photos || !photos.count) {
        if (completion) completion(@"0MB");
        return;
    }
    
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    
    for (NSInteger i = 0; i < photos.count; i++) {
        
        PHAsset *model = photos[i];
        
        if (model.mediaType == PHAssetMediaTypeImage) {
            //图片
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.networkAccessAllowed = YES;
            options.version = PHImageRequestOptionsVersionOriginal;
            [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:model options:options resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary *_Nullable info) {
                
                //图片
                dataLength += imageData.length;
                assetCount ++;
                
                if (assetCount >= photos.count) {
                    NSString *bytes = [NSString stringWithFormat:@"%.2fMB",dataLength / (1024 * 1024.0)];
                    if (completion) completion(bytes);
                }
                
            }];
            
        }else if (model.mediaType == PHAssetMediaTypeVideo) {
            //视频 - 优化性能但不使用估算
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
            options.networkAccessAllowed = YES;
            options.version = PHVideoRequestOptionsVersionOriginal;
            
            // 添加进度监控，但不强制超时
            options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
                DLog(@"视频大小计算进度：%f", progress);
                // 如果进度太慢，记录日志但不强制停止
                if (progress < 0.1 && error == nil) {
                    DLog(@"视频大小计算较慢，可能是网络或设备性能问题");
                }
            };
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:model options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset* urlAsset = (AVURLAsset*)asset;
                    NSNumber *size;
                    [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                    
                    dataLength += [size floatValue];
                    assetCount ++;
                    
                    if (assetCount >= photos.count) {
                        NSString *bytes = [NSString stringWithFormat:@"%.2fMB",dataLength / (1024 * 1024.0)];
                        if (completion) completion(bytes);
                    }
                } else {
                    // 如果无法获取asset，跳过这个视频的大小计算
                    DLog(@"无法获取视频asset，跳过大小计算");
                    assetCount++;
                    
                    if (assetCount >= photos.count) {
                        NSString *bytes = [NSString stringWithFormat:@"%.2fMB",dataLength / (1024 * 1024.0)];
                        if (completion) completion(bytes);
                    }
                }
            }];
        }
        
    }
}

#pragma mark - 打开相机
- (void)openCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LanguageToolMatch(@"温馨提示") message:LanguageToolMatch(@"请在设置中开启相机权限使用此功能") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LanguageToolMatch(@"下次开启") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:LanguageToolMatch(@"立即开启") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]){
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    
    }else if (authStatus == AVAuthorizationStatusNotDetermined) {
        //没有询问是否开启相机
        WeakSelf
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [ZTOOL doInMain:^{
                if (granted) {
                    [weakSelf showImagePicker];
                }
            }];
        }];
        
    }else if (authStatus == AVAuthorizationStatusAuthorized) {
        //授权
        [self showImagePicker];
    }
}
- (void)showImagePicker{
    //打开相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.allowsEditing = NO;//此处若设为NO 下面代理方法需如此设置才能获取图(UIImage *image = info[UIImagePickerControllerOriginalImage];)
        controller.sourceType =   UIImagePickerControllerSourceTypeCamera;
        controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        controller.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*) kUTTypeImage, (NSString*) kUTTypeMovie, nil];
        controller.videoQuality = UIImagePickerControllerQualityTypeMedium;
        [self presentViewController:controller animated:YES completion:nil];
        
    }else {
        [HUD showMessage:LanguageToolMatch(@"相机权限未开启，请在设置中选择当前应用，开启相机权限")];
    }
}
#pragma mark - 相机拍照回调
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
    
    [HUD showActivityMessage:LanguageToolMatch(@"处理中...")];
    NSString *type = info[UIImagePickerControllerMediaType];
    
    WeakSelf
    if ([type isEqualToString:(NSString *)kUTTypeImage]) {
        NSString *localIdentifier;
        NSDictionary *metaDataDic = info[UIImagePickerControllerMediaMetadata];
        NSDictionary *exifDic = [metaDataDic objectForKeySafe:@"{Exif}"];
        if (exifDic) {
            NSString *dateTimeDigitized = [exifDic objectForKeySafe:@"DateTimeDigitized"];
            NSString *shutterSpeedValue = [NSString stringWithFormat:@"%f", [[exifDic objectForKeySafe:@"ShutterSpeedValue"] doubleValue]];
            if (![NSString isNil:dateTimeDigitized] && ![NSString isNil:shutterSpeedValue]) {
                localIdentifier = [NSString stringWithFormat:@"%@-%@", dateTimeDigitized, shutterSpeedValue];
            }
        } else {
            localIdentifier = [NSString stringWithFormat:@"%lld-%@", [NSDate currentTimeIntervalWithMillisecond], [NoaDeviceTool appUniqueIdentifier]];
        }
       
        //图片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            [ZTOOL doInMain:^{
                if (success) {
                    IMAGEPICKER.isCamera = YES;
                    if (weakSelf.isSignlePhoto) {
                        if (weakSelf.isNeedEdit) {
                            //图片编辑
                            [weakSelf clipImageAction:[image fixOrientation]];
                        } else {
                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imagePickerClipImage:localIdenti:)]) {
                                [weakSelf.delegate imagePickerClipImage:image localIdenti:localIdentifier];
                            }
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }
                    } else {
                        [weakSelf requestAlbumAll];
                    }
                }
                [HUD hideHUD];
            }];
        }];
    }else if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
        //视频
        NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:mediaURL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            [ZTOOL doInMain:^{
                if (success) {
                    IMAGEPICKER.isCamera = YES;
                    [weakSelf requestAlbumAll];
                } else {
                    [HUD showErrorMessage:LanguageToolMatch(@"操作失败，请重试")];
                }
                [HUD hideHUD];
            }];
        }];
    }
}

#pragma mark - 交互事件
//返回
- (void)navBtnBackClicked {
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerVCCancel)]) {
        [_delegate imagePickerVCCancel];
    }
    [IMAGEPICKER.zSelectedAssets removeAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
}
//发送
- (void)navBtnRightClicked {
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerVCSelected)]) {
        [_delegate imagePickerVCSelected];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//原图选择
- (void)btnOriginalClick {
    _btnOriginal.selected = !_btnOriginal.selected;
    if (_btnOriginal.selected) {
        _lblTotalMB.hidden = NO;
        //计算大小方法
        [self calculateSelectImageSize];
    }else {
        _lblTotalMB.hidden = YES;
        _lblTotalMB.text = @"";
    }
}
#pragma mark - 判断资源是否在iCloud上
- (BOOL)checkAssetInCloud:(PHAsset *)phAsset {
    if(!phAsset) return NO;
    
    __block BOOL isInCloud = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    @autoreleasepool {
        if (phAsset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
            option.version = PHVideoRequestOptionsVersionOriginal;
            option.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset
                                                            options:option
                                                      resultHandler:^(AVAsset * avAsset, AVAudioMix * audioMix, NSDictionary * info) {
                DLog(@"%d", [[info objectForKey:PHImageResultIsInCloudKey] boolValue]);
                                                          if (avAsset == nil) {
                                                              isInCloud = YES;
                                                          } else {
                                                              isInCloud = NO;
                                                          }
                                                          dispatch_semaphore_signal(semaphore);
                                                      }];
        } else {
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.version = PHImageRequestOptionsVersionOriginal;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.synchronous = YES;
            [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:phAsset options:options resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary *_Nullable info) {
                if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData) {
                    isInCloud = YES;
                }
                dispatch_semaphore_signal(semaphore);
            }];
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    return isInCloud;
}
#pragma mark - 从iCloud上下载资源
- (void)downloadAssetFromCloud:(PHAsset *)phAsset complate:(ZDownloadAsset)complate {
    [HUD showActivityMessage:LanguageToolMatch(@"从iCloud下载...")];
    
    if (phAsset.mediaType == PHAssetMediaTypeVideo) {
        //视频下载
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc]init];
        option.networkAccessAllowed = YES;
        option.version = PHVideoRequestOptionsVersionOriginal;
        option.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        option.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
            DLog(@"iCloud下载视频：%f", progress);
        };
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:option resultHandler:^(AVAsset * _Nullable asset1, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [HUD hideHUD];
                
                if (asset1) {
                    
                    // 下载完成
                    if (complate) {
                        complate(phAsset);
                    }
                    
                } else {
                    
                    // 下载失败
                    if (![info[PHImageCancelledKey] boolValue]) {
                        // 如果不是取消，弹窗提示
                        [HUD showMessage:LanguageToolMatch(@"资源下载失败")];
                    }
                    
                    if (complate) {
                        complate(nil);
                    }
                }
                
            });
        }];
    } else {
        //图片下载
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.version = PHImageRequestOptionsVersionOriginal;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
            DLog(@"iCloud下载图片：%f", progress);
        };
        
        [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:phAsset options:options resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary *_Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hideHUD];
                
                if (imageData) {
                    // 下载完成
                    if (complate) {
                        complate(phAsset);
                    }
                } else {
                    // 下载失败
                    if (![info[PHImageCancelledKey] boolValue]) {
                        // 如果不是取消，弹窗提示
                        [HUD showMessage:LanguageToolMatch(@"资源下载失败")];
                    }
                    
                    if (complate) {
                        complate(nil);
                    }
                }
                
            });
        }];
    }
}
#pragma mark - 通知监听处理
//相册更新了
- (void)albumChanged {
    [self requestAlbumAll];
    //如果此时在浏览大图，需要更新浏览大图界面的数据
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
