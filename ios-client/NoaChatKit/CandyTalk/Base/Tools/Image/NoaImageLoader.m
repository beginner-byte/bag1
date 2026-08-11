//
//  NoaImageLoader.m
//  NoaKit
//

#import "NoaImageLoader.h"
#import <SDWebImage/SDWebImage.h>

@implementation NoaImageLoader

+ (void)configureGlobalImagePolicies {
    SDImageCacheConfig *config = SDImageCache.sharedImageCache.config;
    // 动图全帧预解码在 5.x 由具体视图/解码器控制，这里不全局开启
    config.shouldCacheImagesInMemory = YES;           // 全局保持开启，细粒度按场景关闭
    config.maxMemoryCost = 60 * 1024 * 1024;          // 约 60MB，可按设备级别调整
    config.maxMemoryCount = 0;                        // 数量不限制，依成本控制

    // 可选：限制并发下载数（通过 Downloader.config）
    SDWebImageDownloaderConfig *downCfg = SDWebImageDownloader.sharedDownloader.config;
    downCfg.maxConcurrentDownloads = 4;

    // 全局 options 处理器：统一注入首帧解码与缩略兜底（不强制磁盘缓存，减少闪烁）
    SDWebImageManager.sharedManager.optionsProcessor = [SDWebImageOptionsProcessor optionsProcessorWithBlock:^SDWebImageOptionsResult * _Nullable(NSURL * _Nullable url, SDWebImageOptions options, SDWebImageContext * _Nullable context) {
        NSString *ext = url.pathExtension.lowercaseString ?: @"";
        BOOL isGIF = [ext isEqualToString:@"gif"];
        // 基础容错
        SDWebImageOptions safeOptions = options | SDWebImageAllowInvalidSSLCertificates;
        // 非 GIF：允许缩放与仅首帧；GIF：保留多帧（不加 DecodeFirstFrameOnly 与 ScaleDownLargeImages）
        if (!isGIF) {
            safeOptions |= SDWebImageScaleDownLargeImages | SDWebImageDecodeFirstFrameOnly;
        }
        NSMutableDictionary *ctx = context ? context.mutableCopy : [NSMutableDictionary dictionary];
        // 若未指定缩略像素，给个全局兜底（512x512），GIF 不强加缩略，避免丢帧
        if (!ctx[SDWebImageContextImageThumbnailPixelSize] && !isGIF) {
            ctx[SDWebImageContextImageThumbnailPixelSize] = [NSValue valueWithCGSize:CGSizeMake(512, 512)];
        }
        return [[SDWebImageOptionsResult alloc] initWithOptions:safeOptions context:ctx];
    }];
}

+ (void)loadImageIntoImageView:(UIImageView *)imageView
                        urlStr:(NSString *)urlStr
                   placeholder:(UIImage *)placeholder
                     pixelSize:(CGSize)pixelSize
                      animated:(BOOL)animated {
    if (urlStr.length <= 0) {
        imageView.image = placeholder;
        return;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    if (!url) {
        imageView.image = placeholder;
        return;
    }
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize px = pixelSize.width > 0 && pixelSize.height > 0 ? CGSizeMake(pixelSize.width * scale, pixelSize.height * scale) : CGSizeMake(512, 512);
    // 稳定像素，避免 Autolayout 中 43.999 导致 cache key 抖动
    CGSize clamp = CGSizeMake((CGFloat)lrintf(px.width), (CGFloat)lrintf(px.height));
    NSMutableDictionary *ctx = [@{ SDWebImageContextImageThumbnailPixelSize : [NSValue valueWithCGSize:clamp] } mutableCopy];
    NSString *ext = url.pathExtension.lowercaseString ?: @"";
    BOOL isGIF = [ext isEqualToString:@"gif"];
    SDWebImageOptions opts = SDWebImageAllowInvalidSSLCertificates;
    if (!isGIF) {
        opts |= SDWebImageScaleDownLargeImages | SDWebImageDecodeFirstFrameOnly;
    }

    __weak typeof(imageView) weakImageView = imageView;
    [imageView sd_setImageWithURL:url placeholderImage:placeholder options:opts context:ctx progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            NSLog(@"[NoaImageLoader] load fail: %@ error=%@", imageURL, error);
        } else {
            // 打印像素与是否动图（辅助排查）
            NSLog(@"[NoaImageLoader] loaded: %@ size=%@ animated=%@", imageURL, NSStringFromCGSize(image.size), image.sd_isAnimated ? @"YES" : @"NO");
        }
        if (animated && weakImageView && image && cacheType == SDImageCacheTypeNone) {
            weakImageView.alpha = 0;
            [UIView animateWithDuration:0.15 animations:^{ weakImageView.alpha = 1; }];
        }
    }];
}

@end


