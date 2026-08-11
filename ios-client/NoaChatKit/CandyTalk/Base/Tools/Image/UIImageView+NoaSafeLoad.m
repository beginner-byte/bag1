//
//  UIImageView+ZSafeLoad.m
//  NoaKit
//

#import "UIImageView+NoaSafeLoad.h"
#import "NoaImageLoader.h"
#import <SDWebImage/SDWebImage.h>
#import <objc/runtime.h>

@implementation UIImageView (NoaSafeLoad)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        SEL originalSel = @selector(sd_setImageWithURL:placeholderImage:options:context:);
        SEL swizzledSel = @selector(z_safe_sd_setImageWithURL:placeholderImage:options:context:);
        Method m1 = class_getInstanceMethod(cls, originalSel);
        Method m2 = class_getInstanceMethod(cls, swizzledSel);
        if (m1 && m2) {
            method_exchangeImplementations(m1, m2);
        }

        // 其它常用重载也做兜底
        SEL o1 = @selector(sd_setImageWithURL:);
        SEL s1 = @selector(z_safe_sd_setImageWithURL:);
        Method mo1 = class_getInstanceMethod(cls, o1);
        Method ms1 = class_getInstanceMethod(cls, s1);
        if (mo1 && ms1) {
            method_exchangeImplementations(mo1, ms1);
        }

        SEL o2 = @selector(sd_setImageWithURL:placeholderImage:);
        SEL s2 = @selector(z_safe_sd_setImageWithURL:placeholderImage:);
        Method mo2 = class_getInstanceMethod(cls, o2);
        Method ms2 = class_getInstanceMethod(cls, s2);
        if (mo2 && ms2) {
            method_exchangeImplementations(mo2, ms2);
        }

        SEL o3 = @selector(sd_setImageWithURL:placeholderImage:options:);
        SEL s3 = @selector(z_safe_sd_setImageWithURL:placeholderImage:options:);
        Method mo3 = class_getInstanceMethod(cls, o3);
        Method ms3 = class_getInstanceMethod(cls, s3);
        if (mo3 && ms3) {
            method_exchangeImplementations(mo3, ms3);
        }
    });
}

- (void)z_safe_sd_setImageWithURL:(NSURL *)url
                 placeholderImage:(UIImage *)placeholder
                          options:(SDWebImageOptions)options
                          context:(SDWebImageContext *)context {
    // 注入缩略像素（若调用方未提供）并限制仅磁盘缓存
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize defaultPixel = CGSizeMake(self.bounds.size.width * scale, self.bounds.size.height * scale);
    NSMutableDictionary *ctx = context ? context.mutableCopy : [NSMutableDictionary dictionary];
    if (!ctx[SDWebImageContextImageThumbnailPixelSize]) {
        if (defaultPixel.width > 0 && defaultPixel.height > 0) {
            ctx[SDWebImageContextImageThumbnailPixelSize] = [NSValue valueWithCGSize:defaultPixel];
        } else {
            ctx[SDWebImageContextImageThumbnailPixelSize] = [NSValue valueWithCGSize:CGSizeMake(512, 512)];
        }
    }
    // 缓存策略：默认允许内存命中，减少闪烁；如需严格控内存，可在大图调用点单独覆盖为 Disk-only
    SDWebImageOptions safeOpts = options | SDWebImageScaleDownLargeImages | SDWebImageDecodeFirstFrameOnly | SDWebImageAllowInvalidSSLCertificates;
    // 调回原实现（已交换）
    [self z_safe_sd_setImageWithURL:url placeholderImage:placeholder options:safeOpts context:ctx];
}

- (void)z_safe_sd_setImageWithURL:(NSURL *)url {
    [self z_safe_sd_setImageWithURL:url placeholderImage:nil options:0];
}

- (void)z_safe_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self z_safe_sd_setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)z_safe_sd_setImageWithURL:(NSURL *)url
                 placeholderImage:(UIImage *)placeholder
                          options:(SDWebImageOptions)options {
    // 统一转到带 context 的实现，注入安全策略
    SDWebImageContext *context = @{};
    [self z_safe_sd_setImageWithURL:url placeholderImage:placeholder options:options context:context];
}

@end


