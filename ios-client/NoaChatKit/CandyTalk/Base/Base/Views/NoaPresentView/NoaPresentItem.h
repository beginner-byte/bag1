//
//  NoaPresentItem.h
//  NoaKit
//
//  Created by Candy on 2026/9/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaPresentItem : NSObject

@property (nonatomic, copy)NSString *text;
@property (nonatomic, strong)UIFont *font;
@property (nonatomic, assign)CGFloat itemHeight;
@property (nonatomic, strong)UIColor *textColor;
@property (nonatomic, strong)UIColor *backgroundColor;
@property (nonatomic, assign)CGFloat imageTitleSpace;
@property (nonatomic, copy)NSString *imageName;
@property (nonatomic, assign)ButtonImageAlignmentType imgageAlignment;

/// @param text 文字
/// @param textColor 文字颜色
+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor;

/// @param text 文字
/// @param textColor 文字颜色
/// @param font 文字字体

+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font;

/// @param text 文字
/// @param textColor 文字颜色
/// @param font 文字字体
/// @param itemHeight item高度
/// @param backgroundColor 背景颜色
+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(nullable UIColor *)textColor font:(nullable UIFont *)font itemHeight:(CGFloat)itemHeight backgroundColor:(nullable UIColor *)backgroundColor;

/// @param text 文字
/// @param textColor 文字颜色
/// @param imageName 图片
+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor imageName:(NSString *)imageName;

/// @param text 文字
/// @param textColor 文字颜色
/// @param font 文字字体
/// @param imageName 图片
/// @param imageTitleSpace 图文间距
/// @param imgageAlignment 图片、标题对其方式
+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font imageName:(NSString *)imageName imageTitleSpace:(CGFloat)imageTitleSpace contentAlignment:(ButtonImageAlignmentType)imgageAlignment;

/// @param text 文字
/// @param textColor 文字颜色
/// @param font 文字字体
/// @param imageName 图片
/// @param imageTitleSpace 图文间距
/// @param imgageAlignment 图片、标题对其方式
/// @param itemHeight item高度
/// @param backgroundColor 背景颜色
+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font imageName:(NSString *)imageName imageTitleSpace:(CGFloat)imageTitleSpace contentAlignment:(ButtonImageAlignmentType)imgageAlignment itemHeight:(CGFloat)itemHeight backgroundColor:(UIColor *)backgroundColor;

@end

NS_ASSUME_NONNULL_END
