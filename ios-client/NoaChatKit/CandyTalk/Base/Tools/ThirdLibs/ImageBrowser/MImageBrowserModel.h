//
//  MImageBrowserModel.h
//  MiMaoApp
//
//  Created by Candy on 2020/10/13.
//  Copyright © 2020 MiMao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MImageBrowserModel : NSObject
@property (nonatomic, strong) NSData  *imageData;//图片数据
@property (nonatomic, strong) UIImage  *image;//图片
@property (nonatomic, copy) NSString *thumbURLString;//普通图下载链接
@property (nonatomic, copy) NSString *originURLString;//原图下载链接
@property (nonatomic, assign) CGFloat originImageSize;//原图大小，单位为B

@property (nonatomic, assign) NSInteger sourceMode;//资源类型(1图片2视频)

@property (nonatomic, copy) NSString *videoCoverUrl;//视频封面链接
@property (nonatomic, copy) NSString *videoUrl;//视频链接
@end

NS_ASSUME_NONNULL_END
