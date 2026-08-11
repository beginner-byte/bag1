//
//  NoaPresentItem.m
//  NoaKit
//
//  Created by Candy on 2026/9/3.
//

#import "NoaPresentItem.h"

@interface NoaPresentItem ()

@end

@implementation NoaPresentItem

+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor {
    NoaPresentItem *item = [NoaPresentItem creatPresentViewItemWithText:text textColor:textColor font:nil itemHeight:0 backgroundColor:nil];
    return item;
}

+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font {
    NoaPresentItem *item = [NoaPresentItem creatPresentViewItemWithText:text textColor:textColor font:font itemHeight:0 backgroundColor:nil];
    return item;
}

+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font itemHeight:(CGFloat)itemHeight backgroundColor:(UIColor *)backgroundColor {
    NoaPresentItem *item = [[NoaPresentItem alloc] init];
    if (![NSString isNil:text]) {
        item.text = text;
    } else {
        item.text = @"";
    }
    if (textColor) {
        item.textColor = textColor;
    } else {
        item.textColor = COLOR_11;
    }
    if (font) {
        item.font = font;
    } else {
        item.font = FONTN(16);
    }
    if (itemHeight > 0) {
        item.itemHeight = itemHeight;
    } else {
        item.itemHeight = DWScale(54);
    }
    if (backgroundColor) {
        item.backgroundColor = backgroundColor;
    } else {
        item.backgroundColor = [UIColor clearColor];
    }
    return item;
}

+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor imageName:(NSString *)imageName {
    NoaPresentItem *item = [NoaPresentItem creatPresentViewItemWithText:text textColor:textColor font:nil imageName:imageName imageTitleSpace:DWScale(10) contentAlignment:ButtonImageAlignmentTypeLeft itemHeight:0 backgroundColor:[UIColor clearColor]];
    return item;
}

+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font imageName:(NSString *)imageName imageTitleSpace:(CGFloat)imageTitleSpace contentAlignment:(ButtonImageAlignmentType)imgageAlignment {
    NoaPresentItem *item = [NoaPresentItem creatPresentViewItemWithText:text textColor:textColor font:font imageName:imageName imageTitleSpace:imageTitleSpace contentAlignment:imgageAlignment itemHeight:0 backgroundColor:[UIColor clearColor]];
    return item;
}

+ (instancetype)creatPresentViewItemWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font imageName:(NSString *)imageName imageTitleSpace:(CGFloat)imageTitleSpace contentAlignment:(ButtonImageAlignmentType)imgageAlignment itemHeight:(CGFloat)itemHeight backgroundColor:(UIColor *)backgroundColor {
    NoaPresentItem *item = [[NoaPresentItem alloc] init];
    if (![NSString isNil:text]) {
        item.text = text;
    } else {
        item.text = @"";
    }
    if (textColor) {
        item.textColor = textColor;
    } else {
        item.textColor = COLOR_323233;
    }
    if (font) {
        item.font = font;
    } else {
        item.font = FONTN(17);
    }
    if (imageName) {
        item.imageName = imageName;
    } else {
        item.imageName = @"";
    }
    if (imageTitleSpace > 0) {
        item.imageTitleSpace = imageTitleSpace;
    } else {
        item.imageTitleSpace = 0;
    }
    item.imgageAlignment = imgageAlignment;
    if (itemHeight > 0) {
        item.itemHeight = itemHeight;
    } else {
        item.itemHeight = DWScale(50);
    }
    if (backgroundColor) {
        item.backgroundColor = backgroundColor;
    } else {
        item.backgroundColor = [UIColor clearColor];
    }
    return item;
}

@end
