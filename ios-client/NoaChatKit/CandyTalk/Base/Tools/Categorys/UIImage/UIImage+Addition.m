//
//  UIImage+Addition.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import "UIImage+Addition.h"
#import <Accelerate/Accelerate.h>
#import <ImageIO/ImageIO.h>

@implementation UIImage (Addition)

#pragma mark - 图片质量压缩到某一范围内
+ (NSData *)compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength{
    //首先判断原图大小是否在要求内，如果满足要求则不进行压缩
    CGFloat compression = 1;
    
    NSData *data = UIImageJPEGRepresentation(image, compression);
    
    if (data.length < maxLength) return data;
    
    //原图大小超过范围，先进行“压处理”，这里 压缩比 采用二分法进行处理，6次二分后的最小压缩比是0.015625，已经够小了
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    
    //判断“压处理”的结果是否符合要求，符合要求就over
    if (data.length < maxLength) return data;
    
    UIImage *resultImage = [UIImage imageWithData:data];
    
    //缩处理，直接用大小的比例作为缩处理的比例进行处理，因为有取整处理，所以一般是需要两次处理
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        //获取处理后的尺寸
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
        //通过图片上下文进行处理图片
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //获取处理后图片的大小
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    //[UIImage imageWithData:data];
    return data;
}

#pragma mark - 图片压缩到指定尺寸
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - ++++++++++分割线

#pragma mark - 渐变色图片
+ (UIImage *)gradientColorImageFromColors:(NSArray *)colors gradientType:(GradientColorType)gradientType imageSize:(CGSize)imageSize{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case GradientColorTypeTopToBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, imageSize.height);
            break;
        case GradientColorTypeLeftToRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(imageSize.width, 0.0);
            break;
        case GradientColorTypeUpleftToLowright:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(imageSize.width, imageSize.height);
            break;
        case GradientColorTypeUprightToLowleft:
            start = CGPointMake(imageSize.width, 0.0);
            end = CGPointMake(0.0, imageSize.height);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 图片的模糊处理
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (!image) {
        return nil;
    }
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 200);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        DLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

#pragma mark -  将base64字符串转为图片
+ (UIImage *)base64ToImage:(NSString *)imgBase64 {
    /*
     正常情况先，将base64转成data的方式：
     NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
      UIImage *image = [UIImage imageWithData:imageData];
     */
    //后台将图片转为Base64编码，是利用canvas.toDataURL()函数转换的
    //解码也应该先把Base64字符串当做dataURL解码成URL，再转换为图片
    NSURL *URL = [NSURL URLWithString:imgBase64];
    NSData *imageData = [NSData dataWithContentsOfURL:URL];
    UIImage *img = [UIImage imageWithData:imageData];
    return img;
}

+ (UIImage *)blurryCoreImage:(UIImage *)image withBlurLevel:(CGFloat)blur{
    CIContext *context = [CIContext contextWithOptions:nil];
    
    //获取一张图片(本地或网络图片)
    CIImage * inputImg = [[CIImage alloc] initWithImage:image];
    //创建滤镜
    CIFilter * filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    //设置滤镜输入图片
    [filter setValue:inputImg forKey:kCIInputImageKey];
    //设置模糊效果大小
    [filter setValue:@10 forKey:@"inputRadius"];
    //获取滤镜输出图片
    CIImage * outputImg = [filter valueForKey:kCIOutputImageKey];
    //通过CIImage创建CGImage  大小如果使用 outputImg.extent结果会有白边
    CGImageRef cgImage = [context createCGImage:outputImg fromRect:inputImg.extent];
    //通过CGImage创建UIImage
    UIImage * resultImg = [UIImage imageWithCGImage:cgImage];
    //手动释放，否则会创建很大的内存空间
    CGImageRelease(cgImage);
    return resultImg;
}

#pragma mark - 图片拉伸
//设置中心点为拉伸区域
- (UIImage *)resizableImageCenterMode {
    //return [self resizableImageWithCapInsets:UIEdgeInsetsMake(self.size.height / 2, self.size.width / 2, self.size.height / 2, self.size.width / 2)];
    
    //UIImageResizingModeTile平铺
    //UIImageResizingModeStretch拉伸
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(self.size.height / 2, self.size.width / 2, self.size.height / 2, self.size.width / 2) resizingMode:UIImageResizingModeTile];
}
//根据偏移量来设置拉伸区域
- (UIImage *)resizableImageCenterWithInset:(UIEdgeInsets)inset {
    CGFloat x = (self.size.width - inset.left - inset.right) / 2;
    CGFloat y = (self.size.height - inset.top - inset.bottom) / 2;
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(y + inset.top, x + inset.left, y + inset.bottom, x + inset.right)];
}

#pragma mark - 得到合适大小的上传图片
- (NSData *)getUploadImage{
    if (self) {
        NSData *fileContent;
        if (self.size.height > 3 * self.size.width) {
            fileContent = [UIImage compressImageSize:self toByte:MAX_LONG_IMAGE_SIZE];
        }else{
            fileContent = [UIImage compressImageSize:self toByte:MAX_IMAGE_SIZE];
        }
        return fileContent;
    }
    return nil;
}


/**
*  根据图片url获取网络图片尺寸
*/
+ (CGSize)getImageSizeWithURL:(id)URL{
    NSURL * url = nil;
    if ([URL isKindOfClass:[NSURL class]]) {
        url = URL;
    }
    if ([URL isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:URL];
    }
    if (!URL) {
        return CGSizeZero;
    }
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    CGFloat width = 0, height = 0;
    
    if (imageSourceRef) {
        // 获取图像属性
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
        //以下是对手机32位、64位的处理
        if (imageProperties != NULL) {
            CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
#if defined(__LP64__) && __LP64__
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
            }
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
            }
#else
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat32Type, &width);
            }
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat32Type, &height);
            }
#endif
            /***************** 此处解决返回图片宽高相反问题 *****************/
            // 图像旋转的方向属性
            NSInteger orientation = [(__bridge NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyOrientation) integerValue];
            CGFloat temp = 0;
            switch (orientation) {  // 如果图像的方向不是正的，则宽高互换
                case UIImageOrientationLeft: // 向左逆时针旋转90度
                case UIImageOrientationRight: // 向右顺时针旋转90度
                case UIImageOrientationLeftMirrored: // 在水平翻转之后向左逆时针旋转90度
                case UIImageOrientationRightMirrored: { // 在水平翻转之后向右顺时针旋转90度
                    temp = width;
                    width = height;
                    height = temp;
                }
                    break;
                default:
                    break;
            }
            /***************** 此处解决返回图片宽高相反问题 *****************/
            CFRelease(imageProperties);
        }
        CFRelease(imageSourceRef);
    }
    return CGSizeMake(width, height);
}

//保存图片到相册
- (void)saveToAlbumWithCompletionBlock:(void (^)(BOOL success, NSError * _Nullable error))completionBlock {
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:self];
    } completionHandler:completionBlock];
}

/** 获取视频指定时间点的帧图片*/
//videoURL:本地视频路径    time：用来控制视频播放的时间点图片截取
+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
  
  AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
  NSParameterAssert(asset);
  AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
  assetImageGenerator.appliesPreferredTrackTransform = YES;
  assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
  
  CGImageRef thumbnailImageRef = NULL;
  CFTimeInterval thumbnailImageTime = time;
  NSError *thumbnailImageGenerationError = nil;
  thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
  
  if(!thumbnailImageRef)
      DLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
  
  UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
  
  return thumbnailImage;
}

//裁剪图片
- (UIImage *)beginClip {
    CGSize size = self.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [path addClip];
    [self drawAtPoint:CGPointZero];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//按比例缩放,size 是你要把图显示到 多大区域
+ (UIImage *)imageCompressFitSizeScale:(UIImage *)sourceImage targetSize:(CGSize)size{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
            
        }
        else{
            
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        DLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}
//解决拍照后照片旋转90度的问题
- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#pragma mark - 通过返回数据里文件消息的文件类型，展示不同的图标
+ (UIImage *)getFileMessageIconWithFileType:(NSString *)fileType fileName:(NSString *)fileName {
    NSString *currentType = @"";
    if (![NSString isNil:fileType]) {
        currentType = fileType;
        if ([fileType isEqualToString:@"unknow"]) {
            if ([fileName containsString:@"."]) {
                NSArray *fileNameArr = [fileName componentsSeparatedByString:@"."];
                currentType = (NSString *)[fileNameArr lastObject];
            }
        }
    } else {
        if ([fileName containsString:@"."]) {
            NSArray *fileNameArr = [fileName componentsSeparatedByString:@"."];
            currentType = (NSString *)[fileNameArr lastObject];
        }
    }
    UIImage *fileIconImage;
    if ([currentType isEqualToString:@"doc"] || [currentType isEqualToString:@"DOC"] || [currentType isEqualToString:@"docx"] || [currentType isEqualToString:@"DOCX"]) {
        //doc、docx
        fileIconImage = ImgNamed(@"c_file_type_doc");
    } else if ([currentType isEqualToString:@"xls"] || [currentType isEqualToString:@"XLS"] || [currentType isEqualToString:@"xlsx"] || [currentType isEqualToString:@"XLSX"]) {
        //xls、xlsx
        fileIconImage = ImgNamed(@"c_file_type_xls");
    } else if ([currentType isEqualToString:@"ppt"] || [currentType isEqualToString:@"PPT"] || [currentType isEqualToString:@"pptx"] || [currentType isEqualToString:@"PPTX"]) {
        //ppt、pptx
        fileIconImage = ImgNamed(@"c_file_type_ppt");
    } else if ([currentType isEqualToString:@"zip"] || [currentType isEqualToString:@"ZIP"] || [currentType isEqualToString:@"rar"] || [currentType isEqualToString:@"RAR"]) {
        //zip、rar
        fileIconImage = ImgNamed(@"c_file_type_zip");
    } else if ([currentType isEqualToString:@"txt"] || [currentType isEqualToString:@"TXT"]) {
        //txt
        fileIconImage = ImgNamed(@"c_file_type_txt");
    } else if ([currentType isEqualToString:@"pdf"] || [currentType isEqualToString:@"PDF"]) {
        //pdf
        fileIconImage = ImgNamed(@"c_file_type_pdf");
    } else if ([currentType isEqualToString:@"mp4"] || [currentType isEqualToString:@"MP4"] || [currentType isEqualToString:@"mov"] || [currentType isEqualToString:@"MOV"] || [currentType isEqualToString:@"avi"] || [currentType isEqualToString:@"AVI"] ||[currentType isEqualToString:@"flv"] || [currentType isEqualToString:@"FLV"] || [currentType isEqualToString:@"rm"] || [currentType isEqualToString:@"RM"] || [currentType isEqualToString:@"rmvb"] || [currentType isEqualToString:@"RMVB"] || [currentType isEqualToString:@"mkv"] || [currentType isEqualToString:@"MKV"] || [currentType isEqualToString:@"WMV"] || [currentType isEqualToString:@"wmv"]) {
        //mp4、mov、avi、flv、rm、rmvb、mkv、wmv
        fileIconImage = ImgNamed(@"c_file_type_mp4");
    } else if ([currentType isEqualToString:@"png"] || [currentType isEqualToString:@"PNG"] || [currentType isEqualToString:@"jpeg"] || [currentType isEqualToString:@"JPEG"]) {
        //png、jpeg
        fileIconImage = ImgNamed(@"c_file_type_png");
    } else {
        // unknow 未知
        fileIconImage = ImgNamed(@"c_file_type_unknow");
    }
    return fileIconImage;
}

+ (BOOL)isImageEncryptTypeL:(NSString*)imgType{
    if ([imgType isEqualToString:@"jpeg"]|| [imgType isEqualToString:@"JPEG"]||
         [imgType isEqualToString:@"png"] || [imgType isEqualToString:@"PNG"] ||
         [imgType isEqualToString:@"gif"] || [imgType isEqualToString:@"GIF"] ||
         [imgType isEqualToString:@"jpg"] || [imgType isEqualToString:@"JPG"] ||
         [imgType isEqualToString:@"jpe"] || [imgType isEqualToString:@"JPE"] ||
         [imgType isEqualToString:@"heic"]|| [imgType isEqualToString:@"HEIC"]||
         [imgType isEqualToString:@"webp"]|| [imgType isEqualToString:@"WEBP"]||
         [imgType isEqualToString:@"bmp"]  || [imgType isEqualToString:@"BMP"]){

        return YES;
    }
    return NO;
}
@end
