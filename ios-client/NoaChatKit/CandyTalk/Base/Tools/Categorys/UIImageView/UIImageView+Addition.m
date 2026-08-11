//
//  UIImageView+Addition.m
//  NoaKit
//
//  Created by Candy on 2023/4/23.
//

#import "UIImageView+Addition.h"
#import <UIImageView+WebCache.h>
#import <objc/runtime.h>

@implementation UIImageView (Addition)

#pragma mark - 加载用户头像:判断是否为注销头像，如果为注销头像就加载本地注销头像，如果不为注销头像就加载网络图片
- (void)loadAvatarWithUserImgContent:(NSString *)imgContent defaultImg:(UIImage *)defaultImg {
    if ([imgContent isEqual:@"user_accout_delete_avatar"] || [imgContent isEqual:@"user_accout_delete_avatar.png"]) {
        //注销状态
        self.image = DefaultAccountDelete;
    } else {
        NSString *avatarUrl = imgContent;
        //xor解密数据
        [self sd_setImageWithURL:[avatarUrl getImageFullUrl] placeholderImage:defaultImg options:SDWebImageAllowInvalidSSLCertificates];
    }
}

+ (void)load {
    Class myClass = [self class];
    // 获取SEL
    SEL originSetImageSel = @selector(sd_setImageWithURL:placeholderImage:options:progress:completed:);
    SEL newSetImageSel = @selector(sd_setHttpsImageWithURL:placeholderImage:options:progress:completed:);
    // 生成Method
    Method originMethod = class_getInstanceMethod(myClass, originSetImageSel);
    Method newMethod = class_getInstanceMethod(myClass, newSetImageSel);
    // 交换方法实现
    method_exchangeImplementations(originMethod, newMethod);
}

//全局修改SDWebImage加载图片策略方法
- (void)sd_setHttpsImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDExternalCompletionBlock)completedBlock {
    
    [self sd_setHttpsImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates  progress:progressBlock completed:completedBlock];
}
/*
 
 
 */
@end
