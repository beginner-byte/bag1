//
//  UIImage+Addition.h
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import <UIKit/UIKit.h>

//上传图片配置
#define MAX_IMAGE_NUM      (9)//最多选择张数
#define MAX_IMAGE_SIZE      (1024.0 * 1024) //图片最大大小(200 * 1024)
#define MAX_LONG_IMAGE_SIZE      (5 * 1024.0 * 1024)//长图最大大小

typedef NS_ENUM(NSUInteger, GradientColorType) {
    GradientColorTypeTopToBottom = 0,//从上到小
    GradientColorTypeLeftToRight = 1,//从左到右
    GradientColorTypeUpleftToLowright = 2,//左上到右下
    GradientColorTypeUprightToLowleft = 3,//右上到左下
};

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Addition)

#pragma mark - 图片质量压缩到某一范围内
+ (NSData *)compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength;

#pragma mark - 图片压缩到指定尺寸
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

#pragma mark - 渐变色图片
+ (UIImage *)gradientColorImageFromColors:(NSArray *)colors gradientType:(GradientColorType)gradientType imageSize:(CGSize)imageSize;

#pragma mark -  将base64字符串转为图片
+ (UIImage *)base64ToImage:(NSString *)imgBase64;

/**
 *  对图片进行模糊
 *
 *  @param image 要处理图片
 *  @param blur  模糊系数 (0.0-1.0)
 *
 *  @return 处理后的图片
 */
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

+ (UIImage *)blurryCoreImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

#pragma mark - 图片拉伸
//设置中心点为拉伸区域
- (UIImage *)resizableImageCenterMode;
//根据偏移量来设置拉伸区域
- (UIImage *)resizableImageCenterWithInset:(UIEdgeInsets)inset;

#pragma mark - 得到合适大小的上传图片
- (NSData *)getUploadImage;

//获取网络图片的Size
+ (CGSize)getImageSizeWithURL:(id)URL;

//保存图片到相册
- (void)saveToAlbumWithCompletionBlock:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completionBlock;

#pragma mark - 获取视频指定时间点的帧图片
//videoURL:本地视频路径    time：用来控制视频播放的时间点图片截取
+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

//裁剪图片
- (UIImage *)beginClip;

//按比例缩放,size 是你要把图显示到 多大区域
+ (UIImage *)imageCompressFitSizeScale:(UIImage *)sourceImage targetSize:(CGSize)size;

//解决拍照后照片旋转90度的问题
- (UIImage *)fixOrientation;

#pragma mark - 通过返回数据里文件消息的文件类型，展示不同的图标
+ (UIImage *)getFileMessageIconWithFileType:(NSString *)fileType fileName:(NSString *)fileName;


+ (BOOL)isImageEncryptTypeL:(NSString*)imgType;
@end

NS_ASSUME_NONNULL_END
