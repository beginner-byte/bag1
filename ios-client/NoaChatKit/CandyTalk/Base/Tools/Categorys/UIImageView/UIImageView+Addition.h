//
//  UIImageView+Addition.h
//  NoaKit
//
//  Created by Candy on 2023/4/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Addition)

#pragma mark - 加载用户头像:判断是否为注销头像，如果为注销头像就加载本地注销头像，如果不为注销头像就加载网络图片
- (void)loadAvatarWithUserImgContent:(NSString *)imgContent defaultImg:(UIImage *)defaultImg;

@end

NS_ASSUME_NONNULL_END
