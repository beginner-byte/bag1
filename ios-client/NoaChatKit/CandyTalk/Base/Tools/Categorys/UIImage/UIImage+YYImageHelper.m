//
//  UIImage+YYImageHelper.m
//  testDemo
//
//  Created by apple on 2018/1/16.
//  Copyright © 2018年 com.ruanmeng. All rights reserved.
//

#import "UIImage+YYImageHelper.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
@implementation UIImage (YYImageHelper)
/*
 *颜色这转为图片
 */
+(UIImage *)ImageForColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 10, 10);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/*
 *模糊图片
 */
+(UIImage *)blurryImage:(UIImage *)image
          withBlurLevel:(CGFloat)blur {
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur),
                        nil];
    
    CIImage *outputImage = filter.outputImage;
    CGImageRef outImage = [context createCGImage:outputImage
                                        fromRect:[outputImage extent]];
    
    return [UIImage imageWithCGImage:outImage];
}
/* blur the current image with a box blur algoritm */
- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        DLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    /*void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
     vImage_Buffer outBuffer2;
     outBuffer2.data = pixelBuffer2;
     outBuffer2.width = CGImageGetWidth(img);
     outBuffer2.height = CGImageGetHeight(img);
     outBuffer2.rowBytes = CGImageGetBytesPerRow(img);*/
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        DLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    //free(pixelBuffer2);
    
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    
    
    return returnImage;
}

- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur withTintColor:(UIColor *)tintColor
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        DLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    /*void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
     vImage_Buffer outBuffer2;
     outBuffer2.data = pixelBuffer2;
     outBuffer2.width = CGImageGetWidth(img);
     outBuffer2.height = CGImageGetHeight(img);
     outBuffer2.rowBytes = CGImageGetBytesPerRow(img);*/
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        DLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    CGRect imageRect = {CGPointZero, self.size};
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(ctx);
        CGContextSetFillColorWithColor(ctx, tintColor.CGColor);
        CGContextFillRect(ctx, imageRect);
        CGContextRestoreGState(ctx);
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    //free(pixelBuffer2);
    
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}
+ (UIImage *)setImgNameBianShen:(NSString *)Img{
    
    UIImage * img = [UIImage imageNamed:Img];
    return  [img stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}
- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor < heightFactor) {
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        DLog(@"could not scale image");
    return newImage ;
}
/*
 *获取图片某个点的RGBA值
 */
+(NSMutableArray *)getImagePixel:(UIImage *)image point:(CGPoint)apoint{
    NSMutableArray *byteArray=[[NSMutableArray alloc]init];
    CGImageRef cgimage=image.CGImage;
    size_t scale=CGImageGetWidth(cgimage)/image.size.width;
    
    size_t bpr=CGImageGetBytesPerRow(cgimage);//每行的字节数
    size_t bpp=CGImageGetBitsPerPixel(cgimage);//每个像素的位数
    size_t bpc=CGImageGetBitsPerComponent(cgimage);//每个字节的组成部分
    size_t bytes_per_pixel=bpp/bpc;
    
    CGDataProviderRef provider=CGImageGetDataProvider(cgimage);
    
    @autoreleasepool {
        NSData *data=(__bridge_transfer NSData *)CGDataProviderCopyData(provider);
        const UInt8 *bytes =(Byte *)[data bytes];
        size_t row = apoint.y*scale;
        size_t col = apoint.x*scale;
        
        const UInt8 *pixel = &bytes[row*bpr + col*bytes_per_pixel];
        for (unsigned short i=0; i<4; i+=4) {
            unsigned short red = pixel[i];
            unsigned short green = pixel[i+1];
            unsigned short blue = pixel[i+2];
            unsigned short alpha = pixel[i+3];
            
            [byteArray addObject:@(red)];
            [byteArray addObject:@(green)];
            [byteArray addObject:@(blue)];
            [byteArray addObject:@(alpha)];
        }
        data=nil;
    }
    return byteArray;
}

/// [编号10-10] 生成二维码
+ (UIImage *)getQRCodeImageWithString:(NSString *)string qrCodeColor:(UIColor *)qrCodeColor {
    UIImage *qrCodeImage = [UIImage getQRCodeImageWithString:string qrCodeColor:qrCodeColor inputCorrectionLevel:QRCodeInputCorrectionLevel_M];
    return qrCodeImage;
}

/// [编号10-11] 生成二维码 清晰度
+ (UIImage *)getQRCodeImageWithString:(NSString *)string qrCodeColor:(UIColor *)qrCodeColor inputCorrectionLevel:(QRCodeInputCorrectionLevel)inputCorrectionLevel {
    UIImage *qrCodeImage = [UIImage getQRCodeImageWithString:string qrCodeColor:qrCodeColor size:CGSizeMake(500, 500) inputCorrectionLevel:inputCorrectionLevel];
    return qrCodeImage;
}

/// [编号10-12] 生成二维码 大小,清晰度
+ (UIImage *)getQRCodeImageWithString:(NSString *)string qrCodeColor:(UIColor *)qrCodeColor size:(CGSize)size inputCorrectionLevel:(QRCodeInputCorrectionLevel)inputCorrectionLevel {
    //创建CIFilter
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //将filter所有属性设置为默认值
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    //设置二维码的纠错水平,越高纠错水平越高,可以污损的范围越大
    //L:7% M:15% Q:25% H:30%
    NSString *levelString = @"";
    switch (inputCorrectionLevel) {
        case QRCodeInputCorrectionLevel_L:
            levelString = @"L";
            break;
        case QRCodeInputCorrectionLevel_M:
            levelString = @"M";
            break;
        case QRCodeInputCorrectionLevel_Q:
            levelString = @"Q";
            break;
        case QRCodeInputCorrectionLevel_H:
            levelString = @"H";
            break;
        default:
            break;
    }
    [filter setValue:levelString forKey:@"inputCorrectionLevel"];
    //拿到二维码图片,此时的图片不是很清晰,需要二次加工
    CIImage *outPutImage = [filter outputImage];
    UIImage *qrCodeImage = [UIImage getHDImageWithCIImage:outPutImage size:size color:qrCodeColor];
    return qrCodeImage;
}

+ (UIImage *)getHDImageWithCIImage:(CIImage *)image size:(CGSize)size color:(UIColor *)color {
    //二维码的颜色
    UIColor *pointColor = color;
    //背景颜色
    UIColor *backgroundColor = [UIColor whiteColor];
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputImage" ,image, @"inputColor0", [CIColor colorWithCGColor:pointColor.CGColor], @"inputColor1", [CIColor colorWithCGColor:backgroundColor.CGColor], nil];
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *QRCodeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    //UIImage *spliceImage = [UIImage spliceSmallImage:kLogoDefaultImage toBigImage:QRCodeImage OnOrigin:CGPointMake(IMM_ScaleNumber(190), IMM_ScaleNumber(190)) withNewSmallImageSize:CGSizeMake(IMM_ScaleNumber(120), IMM_ScaleNumber(120))];
    return QRCodeImage;
}

/// [编号11-10] 小image添加到大image上
+ (UIImage *)spliceSmallImage:(UIImage *)smallImage toBigImage:(UIImage *)bigImage OnOrigin:(CGPoint)origin withNewSmallImageSize:(CGSize)newSmallImageSize {
    UIGraphicsBeginImageContextWithOptions(bigImage.size, NO, [[UIScreen mainScreen] scale]);
    [bigImage drawInRect:CGRectMake(0, 0, bigImage.size.width, bigImage.size.height)];
    [smallImage drawInRect:CGRectMake(origin.x, origin.y, newSmallImageSize.width, newSmallImageSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//image添加文字
+ (UIImage *)waterImageWithImage:(UIImage *)image text:(NSString *)text textPoint:(CGPoint)point attributedStringFont:(UIFont * )font attributedStringColor:(UIColor *)color {
    //1.开启上下文 CGSize size 尺寸, BOOL opaque 透明度, CGFloat scale 比例
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    //2.绘制图片
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    // 文字属性
    NSDictionary *attributed = @{NSFontAttributeName:font, NSForegroundColorAttributeName:color};
    //添加水印文字
    [text drawAtPoint:point withAttributes:attributed];
    //3.从上下文中获取新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //4.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

/// [编号 13-10] 裁剪图片
/// @param rect 裁剪大小
- (UIImage *)qmui_imageWithClippedRect:(CGRect)rect {
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    if (CGRectContainsRect(rect, imageRect)) {
        // 要裁剪的区域比自身大，所以不用裁剪直接返回自身即可
        return self;
    }
    // 由于CGImage是以pixel为单位来计算的，而UIImage是以point为单位，所以这里需要将传进来的point转换为pixel
    CGRect scaledRect = CGRectApplyScale(rect, self.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, scaledRect);
    UIImage *imageOut = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return imageOut;
}

/// 为一个CGRect叠加scale计算
CG_INLINE CGRect
CGRectApplyScale(CGRect rect, CGFloat scale) {
    return CGRectFlatted(CGRectMake(CGRectGetMinX(rect) * scale, CGRectGetMinY(rect) * scale, CGRectGetWidth(rect) * scale, CGRectGetHeight(rect) * scale));
}

CG_INLINE CGRect
CGRectFlatted(CGRect rect) {
    return CGRectMake(flat(rect.origin.x), flat(rect.origin.y), flat(rect.size.width), flat(rect.size.height));
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
CG_INLINE CGFloat
flat(CGFloat floatValue) {
    return flatSpecificScale(floatValue, 0);
}

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
CG_INLINE CGFloat
flatSpecificScale(CGFloat floatValue, CGFloat scale) {
    floatValue = removeFloatMinUI(floatValue);
    scale = scale ?: [[UIScreen mainScreen] scale];
    CGFloat flattedValue = ceil(floatValue * scale) / scale;
    return flattedValue;
}

/**
 *  某些地方可能会将 CGFLOAT_MIN 作为一个数值参与计算（但其实 CGFLOAT_MIN 更应该被视为一个标志位而不是数值），可能导致一些精度问题，所以提供这个方法快速将 CGFLOAT_MIN 转换为 0
 *  issue: https://github.com/Tencent/QMUI_iOS/issues/203
 */
CG_INLINE CGFloat
removeFloatMinUI(CGFloat floatValue) {
    return floatValue == CGFLOAT_MIN ? 0 : floatValue;
}

/// [编号 13-11] 裁剪图片
/// @param rect 裁剪大小
- (UIImage *)clipImageWithRect:(CGRect)rect {
    
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    UIImage *img = nil;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    [self drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/// [编号 14-10] 截图功能
/// @param view 截图的view
+ (UIImage *)captureImageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.size,YES, 0.0);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

- (void)saveToAlbumWithCompletionBlock:(void (^)(BOOL success, NSError * _Nullable error))completionBlock {
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:self];
    } completionHandler:completionBlock];
}

#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

+ (UIImage *)transToMosaicImage:(UIImage*)orginImage blockLevel:(NSUInteger)level
{
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = orginImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }

    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                        kBitsPerComponent,
                                        kBitsPerPixel,
                                        width*kPixelChannelCount ,
                                        colorSpace,
                                        (CGBitmapInfo)kCGImageAlphaPremultipliedLast,
                                        provider,
                                        NULL, NO,
                                        kCGRenderingIntentDefault);
     CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                 width,
                                                 height,
                                                 kBitsPerComponent,
                                                 width*kPixelChannelCount,
                                                 colorSpace,
                                                kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    return resultImage;

}

@end
