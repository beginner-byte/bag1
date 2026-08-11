//
//  UIImage+YYImageHelper.h
//  testDemo
//
//  Created by apple on 2018/1/16.
//  Copyright © 2018年 com.ruanmeng. All rights reserved.
//

#import <UIKit/UIKit.h>

//设置二维码的纠错水平,越高纠错水平越高,可以污损的范围越大
//L:7% M:15% Q:25% H:30%
typedef NS_OPTIONS(NSInteger, QRCodeInputCorrectionLevel) {
    QRCodeInputCorrectionLevel_L = 0,
    QRCodeInputCorrectionLevel_M = 1,
    QRCodeInputCorrectionLevel_Q = 1 << 1,
    QRCodeInputCorrectionLevel_H = 1 << 2,
};

/// UIImage 分类
@interface UIImage (YYImageHelper)
/*
 *颜色这转为图片
 */
+(UIImage *)ImageForColor:(UIColor *)color;
/*
 *模糊图片
 */
+(UIImage *)blurryImage:(UIImage *)image
          withBlurLevel:(CGFloat)blur;
/* blur the current image with a box blur algoritm */
- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur;

/* blur the current image with a box blur algoritm and tint with a color */
- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur withTintColor:(UIColor*)tintColor;
/*
*转换成马赛克,level代表一个点转为多少level*level的正方形
*/
+ (UIImage *)transToMosaicImage:(UIImage*)orginImage blockLevel:(NSUInteger)level;

+(UIImage *)setImgNameBianShen:(NSString *)Img;

/* 图片大小 */
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
/*
 *获取图片某个点的RGBA值
 */
+(NSMutableArray *)getImagePixel:(UIImage *)image point:(CGPoint)apoint;


/// [编号10-10] 生成二维码
/// @param string 二维码包含的字符串
/// @param qrCodeColor 二维码的颜色
+ (UIImage *)getQRCodeImageWithString:(NSString *)string qrCodeColor:(UIColor *)qrCodeColor;

/// [编号10-11] 生成二维码 清晰度
/// @param string 二维码包含的字符串
/// @param qrCodeColor 二维码的颜色
/// @param inputCorrectionLevel 二维码清晰度
+ (UIImage *)getQRCodeImageWithString:(NSString *)string qrCodeColor:(UIColor *)qrCodeColor inputCorrectionLevel:(QRCodeInputCorrectionLevel)inputCorrectionLevel;

/// [编号 10-11] 生成二维码 大小,清晰度
/// @param string 二维码包含的字符串
/// @param qrCodeColor 二维码的颜色
/// @param size 二维码的大小
/// @param inputCorrectionLevel 二维码清晰度
+ (UIImage *)getQRCodeImageWithString:(NSString *)string qrCodeColor:(UIColor *)qrCodeColor size:(CGSize)size inputCorrectionLevel:(QRCodeInputCorrectionLevel)inputCorrectionLevel;

/// [编号 11-10] 小image添加到大image上
/// @param smallImage 小图
/// @param bigImage 大图
/// @param origin 小图的要添加的位置
/// @param newSmallImageSize 小图要添加的大小
+ (UIImage *)spliceSmallImage:(UIImage *)smallImage toBigImage:(UIImage *)bigImage OnOrigin:(CGPoint)origin withNewSmallImageSize:(CGSize)newSmallImageSize;


/// [编号 12-10] image上添加文字
/// @param image 图片
/// @param text 文字(水印)
/// @param point 要添加的位置
/// @param font 文字大小
/// @param color 文字颜色
+ (UIImage *)waterImageWithImage:(UIImage *)image text:(NSString *)text textPoint:(CGPoint)point attributedStringFont:(UIFont * )font attributedStringColor:(UIColor *)color;

/// [编号 13-10] 裁剪图片
/// @param rect 裁剪大小
- (UIImage *)qmui_imageWithClippedRect:(CGRect)rect;

/// [编号 13-11] 裁剪图片
/// @param rect 裁剪大小
- (UIImage *)clipImageWithRect:(CGRect)rect;

/// [编号 14-10] 截图功能
/// @param view 截图的view
+ (UIImage *)captureImageFromView:(UIView *)view;

/// [编号 15-10] 保存图片
/// @param completionBlock 保存回调
- (void)saveToAlbumWithCompletionBlock:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completionBlock;
@end
