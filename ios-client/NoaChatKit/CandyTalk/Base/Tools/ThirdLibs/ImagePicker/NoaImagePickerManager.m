//
//  NoaImagePickerManager.m
//  NoaKit
//
//  Created by Candy on 2026/9/30.
//

#import "NoaImagePickerManager.h"

#define LIMITED_SIZE 4000

@interface NoaImagePickerManager () <PHPhotoLibraryChangeObserver>
{
    UIImage *img;
}
@end


@implementation NoaImagePickerManager

#pragma mark - 单例
+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static NoaImagePickerManager *_manager;
    dispatch_once(&once, ^{
        _manager = [[NoaImagePickerManager alloc] init];
        
    });
    return _manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

#pragma mark - PHPhotoLibraryChangeObserver 相册监听
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 监听相册发生变化
        PHFetchResultChangeDetails *imageChange = [changeInstance changeDetailsForFetchResult:self.imageFetchResults];
        
        if (imageChange) {
            if ([imageChange hasIncrementalChanges]) {
                //监听相册的增删
                if (imageChange.insertedObjects.count > 0 || imageChange.removedObjects.count > 0) {
                    
                    [self updatePhoto];
                    DLog(@"图片更新---------------------------------------------------");
                    
                    if (imageChange.removedObjects.count >0) {
                        //判断删除中的图片是否包含已经选择的图片
                        NSMutableArray *listDelete = [NSMutableArray array];
                        [imageChange.removedObjects enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj isKindOfClass:[PHAsset class]]) {
                                [self.zSelectedAssets enumerateObjectsUsingBlock:^(PHAsset *objSelect, NSUInteger idxSelect, BOOL * _Nonnull stop) {
                                    if ([obj.localIdentifier isEqualToString:objSelect.localIdentifier]) {
                                        [listDelete addObjectIfNotNil:objSelect];
                                    }
                                }];
                            }
                        }];
                        //要做优化 如果对象属性相同 可能删除对象不正确
                        [listDelete enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [self.zSelectedAssets removeObject:obj];
                        }];
                    }
                }
                /**监听完一次更新一下监听对象*/
                self.imageFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.onlyOptions];
            }
        }
        
        // 监听相册发生变化
        PHFetchResultChangeDetails *videoChange = [changeInstance changeDetailsForFetchResult:self.videoFetchResults];
        if (videoChange) {
            //监听相册的增删
            if (videoChange.insertedObjects.count > 0 || videoChange.removedObjects.count > 0) {
                
                [self updatePhoto];
                DLog(@"视频更新---------------------------------------------------");
                
                if (videoChange.removedObjects.count > 0) {
                    //判断删除的视频是否包含已经选择的视频
                    NSMutableArray *listDelete = [NSMutableArray array];
                    [videoChange.removedObjects enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[PHAsset class]]) {
                            [self.zSelectedAssets enumerateObjectsUsingBlock:^(PHAsset *objSelect, NSUInteger idxSelect, BOOL * _Nonnull stop) {
                                if ([obj.localIdentifier isEqualToString:objSelect.localIdentifier]) {
                                    [listDelete addObjectIfNotNil:objSelect];
                                }
                            }];
                        }
                    }];
                    //要做优化 如果对象属性相同 可能删除对象不正确
                    [listDelete enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [self.zSelectedAssets removeObject:obj];
                    }];
                }
            }
            /**监听完一次更新一下监听对象*/
            self.videoFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:self.onlyOptions];
        }
    });
    
}
#pragma mark - 更新相册
- (void)updatePhoto{
    
    if (self.pickerType == 0) {
        return;
    }
    
    [self.zAssetGroups removeAllObjects];
    
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    [albums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        
        DLog(@"相册名称 %@", collection.localizedTitle);

        NSMutableDictionary *albumDic = [NSMutableDictionary new];
        
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:self.onlyOptions];
        
        if (assetsFetchResult.count > 0 ) {
            
            [albumDic setObjectSafe:collection.localizedTitle forKey:@"name"];
            [albumDic setObjectSafe:@(assetsFetchResult.count) forKey:@"num"];
            [albumDic setObjectSafe:assetsFetchResult forKey:@"result"];
            
            [assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                if (asset != nil && [asset isKindOfClass:[PHAsset class]]) {
                    [self getImageFromAsset:asset type:ASSET_PHOTO_ASPECT_THUMBNAIL];
                    
                    // 安全地获取 img，避免访问已释放的内存
                    UIImage *currentImg = self->img;
                    if (currentImg) {
                        [albumDic setObjectSafe:currentImg forKey:@"image"];
                    }
                    *stop = YES;
                }
            }];
            [self.zAssetGroups addObject:albumDic];
            if ([albumDic[@"name"] isEqualToString:@"最近添加"]) {
                self.showCameraDict = albumDic;
                self.isCameraRoll = YES;
            }
        }
    }];
    
    PHFetchResult *userAlbums  = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        
        DLog(@"相册名称 %@", collection.localizedTitle);
        
        NSMutableDictionary *albumDic = [NSMutableDictionary new];
        
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:self.onlyOptions];
        
        if (assetsFetchResult.count > 0 ) {
            [albumDic setObjectSafe:collection.localizedTitle forKey:@"name"];
            [albumDic setObjectSafe:@(assetsFetchResult.count) forKey:@"num"];
            [albumDic setObjectSafe:assetsFetchResult forKey:@"result"];
            [assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                if (asset != nil && [asset isKindOfClass:[PHAsset class]]) {
                    [self getImageFromAsset:asset type:ASSET_PHOTO_ASPECT_THUMBNAIL];
                    
                    // 安全地获取 img，避免访问已释放的内存
                    UIImage *currentImg = self->img;
                    if (currentImg) {
                        [albumDic setObjectSafe:currentImg forKey:@"image"];
                    }
                    *stop = YES;
                }
            }];
            [self.zAssetGroups addObject:albumDic];
        }
    }];
    if (!self.showCameraDict) {
        self.showCameraDict = self.zAssetGroups.firstObject;
        self.isCameraRoll = YES;
    }
    [self.zAssetGroups enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.currentDict[@"name"] isEqualToString:obj[@"name"]]) {
            self.currentDict = obj;
            *stop = YES;
        }
    }];
    
    PHFetchResult *assetResult = self.currentDict[@"result"];
    if (assetResult.count == 0) {
        //可能之前的相册都删光了
        self.currentDict = self.showCameraDict;
    }
    [self.zCurrentAssets removeAllObjects];
    [self getPhotoListFromCollection:self.currentDict];
    
    if (self.isCamera && self.zCurrentAssets.count > 0) {
        //        [self.zSelectedAssets addObjectIfNotNil:self.zCurrentAssets.firstObject];
        [self selectAsset:self.zCurrentAssets.firstObject completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ALBUMUPDATE object:nil];
        }];
        //通知更新相册
        self.isCamera = NO;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ALBUMUPDATE object:nil];
    }
}
- (void)selectAsset:(PHAsset *)phAsset completion:(void(^)(void))completion {
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
                [self.zSelectedAssets addObject:phAsset];
            }
            if (completion) {
                completion();
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
                if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"] && ((videoSize / (1024 * 1024.0)) > ([UserManager.userRoleAuthInfo.upImageVideoFile.configData integerValue]))) {
                    [HUD showMessage:LanguageToolMatch(@"所选资源超过限制")];
                    return;
                } else {
                    //添加选中
                    [self.zSelectedAssets addObject:phAsset];
                }
                if (completion) {
                    completion();
                }
            }
        }];
    }
}


#pragma mark - 设置相册选择类型
- (void)setPickerType:(ZImagePickerType)pickerType {
    _pickerType = pickerType;
    
    if (pickerType == 0) {
        return;
    }
    
    [self.zCurrentAssets removeAllObjects];
    
    if (pickerType == ZImagePickerTypeImage) {
        self.onlyOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    }else if (pickerType == ZImagePickerTypeVideo){
        self.onlyOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeVideo];
    }else{
       _onlyOptions = nil;
    }
    
    self.onlyOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    [self getAllGroupList];
    
    [self getPhotoListFromCollection:self.showCameraDict];
    //监听相册图片变化
    self.imageFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:self.onlyOptions];
    //监听相册视频变化
    self.videoFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:self.onlyOptions];
}
#pragma mark - 获取所有相册列表，顺序为 系统->自建相册
- (void)getAllGroupList {
    [self.zAssetGroups removeAllObjects];
    
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny  options:nil];
    [self addPhotoGroup:albums];
    
    PHFetchResult *userAlbums  = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [self addPhotoGroup:userAlbums];
}

#pragma mark - 遍历相册列表获取每个相册信息存入dictionary
-(void)addPhotoGroup:(PHFetchResult *)album{
    
    [album enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *albumDic = [NSMutableDictionary new];
//        DLog(@"相册名称 %@", collection.localizedTitle);
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:self.onlyOptions];
        if (assetsFetchResult.count > 0 ) {
            [albumDic setObjectSafe:collection.localizedTitle forKey:@"name"];
            [albumDic setObjectSafe:@(assetsFetchResult.count) forKey:@"num"];
            [albumDic setObjectSafe:assetsFetchResult forKey:@"result"];
            [assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                if (asset != nil && [asset isKindOfClass:[PHAsset class]]) {
                    [self getImageFromAsset:asset type:ASSET_PHOTO_ASPECT_THUMBNAIL];
                    
                    // 安全地获取 img，避免访问已释放的内存
                    UIImage *currentImg = self->img;
                    if (currentImg) {
                        [albumDic setObjectSafe:currentImg forKey:@"image"];
                    }
                    *stop = YES;
                }
            }];
            [self.zAssetGroups addObject:albumDic];
            if ([albumDic[@"name"] isEqualToString:@"最近添加"]) {
                [albumDic setObjectSafe:@(YES) forKey:@"select"];
                self.showCameraDict = albumDic;
                self.isCameraRoll = YES;
                self.currentDict = self.showCameraDict;
            }
        }
    }];
    
    if (!self.showCameraDict) {
        self.showCameraDict = self.zAssetGroups.firstObject;
        [self.showCameraDict  setObjectSafe:@(YES) forKey:@"select"];
        self.isCameraRoll = YES;
        self.currentDict = self.showCameraDict;
    }
}

#pragma mark - 根据相册获得所有照片列表存入数组
- (void)getPhotoListFromCollection:(NSMutableDictionary *)dict{
    self.currentDict = dict;
    [self.currentDict setObjectSafe:@(YES) forKey:@"select"];
    PHFetchResult *assetsFetchResult = [dict objectForKey:@"result"];
    if (!assetsFetchResult) {
        return;
    }
    if ([self.showCameraDict[@"name"] isEqualToString:dict[@"name"]]) {
        self.isCameraRoll = YES;
    }else{
        self.isCameraRoll = NO;
    }
//    DLog(@"image number = %ld",(unsigned long)assetsFetchResult.count);
    [assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        if (asset != nil) {
            [self.zCurrentAssets addObject:asset];
        }
    }];
    
    // 排序
//    [self.tCurrentAssets sortUsingComparator:^NSComparisonResult(PHAsset *asset1, PHAsset *asset2) {
//        return [asset2.creationDate compare:asset1.creationDate];
//    }];
}

#pragma mark - 根据phasset获得对应uiimage
- (void)getImageFromAsset:(PHAsset *)asset type:(NSInteger)nType{
    if(nType == ASSET_PHOTO_ASPECT_THUMBNAIL){
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        if (asset.pixelHeight > LIMITED_SIZE || asset.pixelWidth > LIMITED_SIZE) {
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
        }
        
        // 使用 @autoreleasepool 确保内存及时释放
        @autoreleasepool {
            [self.imageManager requestImageForAsset:asset
                                         targetSize:CGSizeMake(90, 90)
                                        contentMode:PHImageContentModeAspectFill
                                            options:options
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                if (result) {
                    self->img = result;
                }
            }];
        }
    }
}

#pragma mark - 获得所有的图片PHAsset 1方法
- (void)getAllPhotoList {
    [self.allPhotoList removeAllObjects];

    // 权限判断
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (@available(iOS 14, *)) {
        if (status != PHAuthorizationStatusAuthorized &&
            status != PHAuthorizationStatusLimited) {
            NSLog(@"相册权限未授权");
            return;
        }
    } else {
        // Fallback on earlier versions
    }

    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    if (_pickerType == ZImagePickerTypeImage) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    } else if (_pickerType == ZImagePickerTypeVideo) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeVideo];
    }

    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    if (albums.count > 0) {
        NSLock *arrayLock = [NSLock new];
        for (int i = 0; i < albums.count; i++) {
            PHAssetCollection *collection = (PHAssetCollection *)[albums objectAtIndex:i];
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;

            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            if (assetsFetchResult.count > 0 ) {
                for (int j = 0; j < assetsFetchResult.count; j++) {
                    PHAsset *asset = (PHAsset *)[assetsFetchResult objectAtIndex:j];
                    if (asset && [asset isKindOfClass:[PHAsset class]]) {
                        [arrayLock lock];
                        [self.allPhotoList addObject:asset];
                        [arrayLock unlock];
                    }
                }
            }
        }
    }
}


- (void)getLimtPhotoList {
    
    [self.allPhotoList removeAllObjects];
    
    WeakSelf
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    if (_pickerType == ZImagePickerTypeImage) {
        //只展示图片
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    } else if (_pickerType == ZImagePickerTypeVideo) {
        //只展示视频
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeVideo];
    }
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    if (albums.count > 0) {
        NSLock *arrayLock = [NSLock new];
        [albums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
            StrongSelf
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            if (assetsFetchResult.count > 0 ) {
                [assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                    if (asset != nil && [asset isKindOfClass:[PHAsset class]]) {
                        [arrayLock lock];
                        [strongSelf.allPhotoList addObject:asset];
                        [arrayLock unlock];
                    }
                }];
            }
        }];
    }
}

#pragma mark - 获得所有的图片PHAsset 2方法
- (void)getAllPhotosCompletion:(ZImagePickerAllPhotosCallBack)allPhoto {
    
    [self.allPhotoList removeAllObjects];
    
    WeakSelf
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    if (_pickerType == ZImagePickerTypeImage) {
        //只展示图片
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    }else if (_pickerType == ZImagePickerTypeVideo) {
        //只展示视频
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeVideo];
    }
    
        //总相册
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny  options:nil];
    NSLock *arrayLock = [NSLock new];
    [albums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        StrongSelf
        //某个文件夹
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        if (assetsFetchResult.count > 0 ) {
            [assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idxAsset, BOOL *stop) {
                if (asset != nil && [asset isKindOfClass:[PHAsset class]]) {
                    //照片
                    [arrayLock lock];
                    [strongSelf.allPhotoList addObject:asset];
                    [arrayLock unlock];
                }
                
                if (idxAsset == assetsFetchResult.count - 1) {
                    //本次遍历结束
                    if (allPhoto) {
                        allPhoto(weakSelf.allPhotoList);
                    }
                }
                
            }];
        }
    }];
}

#pragma mark - 懒加载
- (NSMutableArray<NSMutableDictionary *> *)zAssetGroups {
    if (!_zAssetGroups) {
        _zAssetGroups = [NSMutableArray array];
    }
    return _zAssetGroups;
}
- (NSMutableArray<PHAsset *> *)zSelectedAssets {
    if (!_zSelectedAssets) {
        _zSelectedAssets = [NSMutableArray array];
    }
    return _zSelectedAssets;
}
- (NSMutableArray<PHAsset *> *)zCurrentAssets {
    if (!_zCurrentAssets) {
        _zCurrentAssets = [NSMutableArray array];
    }
    return _zCurrentAssets;
}
- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}
- (PHFetchOptions *)onlyOptions {
    if (!_onlyOptions) {
        _onlyOptions = [PHFetchOptions new];
    }
    return _onlyOptions;
}
- (NSMutableSet *)allPhotoList {
    if (!_allPhotoList) {
        _allPhotoList = [NSMutableSet set];
    }
    return _allPhotoList;
}


- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    img = nil;
}

@end
