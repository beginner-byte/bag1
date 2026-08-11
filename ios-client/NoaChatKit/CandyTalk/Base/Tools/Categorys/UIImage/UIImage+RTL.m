//
//  UIImage+RTL.m
//  NoaKit
//
//  Created by Candy on 2023/9/16.
//

#import "UIImage+RTL.h"

@implementation UIImage (RTL)

+(void)load{
    Method oldSetTextAlignment = class_getClassMethod([self class],@selector(imageNamed:));
    Method newSetTextAlignment = class_getClassMethod([self class], @selector(rtl_imageNamed:));
    method_exchangeImplementations(oldSetTextAlignment, newSetTextAlignment);
}

+(UIImage *)rtl_imageNamed:(NSString *)name{
    UIImage * image = [UIImage rtl_imageNamed:name];
    if(ZLanguageTOOL.isRTL &&
       [[UIImage rtl_ImageNameList] containsObject:name]){
        //改变该图片的方向
        //UIImageOrientationUp, // 默认方向
        //UIImageOrientationDown, // 让默认方向旋转180度
        //UIImageOrientationLeft, // 让默认方向逆时针旋转90度
        //UIImageOrientationRight, // 让默认方向顺时针旋转90度
        //UIImageOrientationUpMirrored, // 默认方向的竖线镜像
        //（即以原图的左(或右)边的竖线为对称轴，对原图进行对称投影得到的镜像）
        //UIImageOrientationDownMirrored, // 让镜像旋转180度
        //UIImageOrientationLeftMirrored, // 让镜像逆时针旋转90度
        //UIImageOrientationRightMirrored, // 让镜像顺时针旋转90度
        UIImage * rtl_image = [UIImage imageWithCGImage:image.CGImage
                                                  scale:image.scale
                                            orientation:UIImageOrientationUpMirrored];
        return rtl_image;
    }else{
        return image;
    }
}

//需要RTL 适配的 image 图片
+ (NSArray *)rtl_ImageNameList{
    static NSArray *rtl_ImageNameList;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rtl_ImageNameList = @[@"icon_geo_nav_back",
                              @"icon_nav_back",
                              @"nav_back_white",
                              @"c_arrow_right_gray",
                              @"c_arrow_right_darkgray",
                              @"team_arrow_gray",
                              @"c_right_blue_arrow",
                              @"image_picker_back",
                              @"input_emoji_delete"];
    });
    return rtl_ImageNameList;
}
@end
