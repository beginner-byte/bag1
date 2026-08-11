//
//  NoaFDatePickerView.m
//  NoaKit
//
//  Created by Candy on 2026/11/17.
//

#import <UIKit/UIKit.h>

@interface NoaFDatePickerView : UIView


/**
 初始化方法，只带年月的日期选择

 @param block 返回选中的日期
 @return QFDatePickerView对象
 */
- (instancetype)initDatePackerWithResponse:(void(^)(NSString*,NSString* ,NSString*))block;


/**
 初始化方法，只带年月的日期选择
 
 @param superView picker的载体View
 @param block 返回选中的日期
 @return QFDatePickerView对象
 */
- (instancetype)initDatePackerWithSUperView:(UIView *)superView response:(void(^)(NSString*,NSString*,NSString*))block;


/**
 初始化方法，只带年份的日期选择

 @param block 返回选中的年份
 @return QFDatePickerView对象
 */
- (instancetype)initYearPickerViewWithResponse:(void(^)(NSString*,NSString*,NSString*))block;

/**
 初始化方法，只带年份的日期选择
 
 @param block 返回选中的年份
 @return QFDatePickerView对象
 */
- (instancetype)initYearPickerWithView:(UIView *)superView response:(void(^)(NSString*,NSString*,NSString*))block;

/**
 显示方法
 */
- (void)show;

@end
