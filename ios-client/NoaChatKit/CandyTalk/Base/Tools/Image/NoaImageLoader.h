//
//  NoaImageLoader.h
//  NoaKit
//
//  Global image loading policies and safe loaders to avoid memory spikes.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaImageLoader : NSObject

/// Configure global SDWebImage policies (should be called once at app launch)
+ (void)configureGlobalImagePolicies;

/// Load image safely with thumbnail decode and first-frame-only for animations.
/// If pixelSize is CGSizeZero, a default clamp (e.g., 512x512) will be used.
+ (void)loadImageIntoImageView:(UIImageView *)imageView
                        urlStr:(NSString *)urlStr
                   placeholder:(UIImage * _Nullable)placeholder
                     pixelSize:(CGSize)pixelSize
                      animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END


