//
//  NoaImagePickerManager.h
//  NoaKit
//
//  Created by Candy on 2026/9/30.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <Photos/Photos.h>

#define IMAGEPICKER  [NoaImagePickerManager sharedManager]

//需要监听 相册分组的完成 和 在系统相册中增加或者删除照片的更新
#define ALBUMUPDATE @"AlbumUpdate"

#define ASSET_PHOTO_THUMBNAIL           0      //缩略图
#define ASSET_PHOTO_ASPECT_THUMBNAIL    1      //方形缩略图
#define ASSET_PHOTO_SCREEN_SIZE         2      //屏幕尺寸
#define ASSET_PHOTO_FULL_RESOLUTION     3      //分辨率

//选择相册类型
typedef NS_ENUM(NSUInteger, ZImagePickerType) {
    ZImagePickerTypeImage = 1,      //只选择图片
    ZImagePickerTypeVideo = 2,      //只选择视频
    ZImagePickerTypeAll = 3,        //可选择图片和视频
};

//全部照片的回调
typedef void (^ZImagePickerAllPhotosCallBack)(NSMutableSet * _Nullable allPhotos);

NS_ASSUME_NONNULL_BEGIN

@interface NoaImagePickerManager : NSObject
#pragma mark - 单例
+ (instancetype)sharedManager;

//相册选择器类型
@property (nonatomic, assign) ZImagePickerType pickerType;
//存储所有的相册分组
@property (nonatomic, strong) NSMutableArray <NSMutableDictionary *> *zAssetGroups;
//选中的图片phasset的集合
@property (nonatomic, strong) NSMutableArray <PHAsset *> *zSelectedAssets;
//当前相册里面的phasset的集合
@property (nonatomic, strong) NSMutableArray <PHAsset *> *zCurrentAssets;
//显示摄像头的字典
@property (nonatomic, strong) NSMutableDictionary *showCameraDict;
//显示
@property (nonatomic, strong) NSMutableDictionary *currentDict;
//相册取的类型(筛选条件)
@property (nonatomic, strong) PHFetchOptions *onlyOptions;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
//用于监听相册变化 图片
@property (nonatomic, strong) PHFetchResult *imageFetchResults;
//用于监听相册变化 视频
@property (nonatomic, strong) PHFetchResult *videoFetchResults;
//标示是拍摄更新的相册
@property (nonatomic,assign)  BOOL isCamera;
//是否是相机胶卷
@property (nonatomic,assign)  BOOL isCameraRoll;
//相册中的全部图片PHAsset
@property (nonatomic, strong) NSMutableSet *allPhotoList;

//根据相册获得所有照片列表
- (void)getPhotoListFromCollection:(NSMutableDictionary *)dict;
//获取相册中的所有图片PHAsset(根据picketType获取数据) 1方法
- (void)getAllPhotoList;
- (void)getLimtPhotoList;

//获取相册中的所有图片PHAsset(根据picketType获取数据) 2方法
- (void)getAllPhotosCompletion:(ZImagePickerAllPhotosCallBack)allPhoto;

@end

NS_ASSUME_NONNULL_END
