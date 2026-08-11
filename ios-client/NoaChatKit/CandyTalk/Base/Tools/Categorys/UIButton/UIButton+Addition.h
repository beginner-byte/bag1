//
//  UIButton+Addition.h
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ButtonImageAlignmentType) {
    ButtonImageAlignmentTypeTop,           //图片在上，文字在下
    ButtonImageAlignmentTypeLeft,          //图片在左，文字在右
    ButtonImageAlignmentTypeBottom,        //图片在下，文字在上
    ButtonImageAlignmentTypeRight          //图片在右，文字在左
};

@interface UIButton (Addition)
/// 设置按钮图片对齐类型
/// @param type 对齐类型
/// @param space 图片与文字的间距
- (void)setBtnImageAlignmentType:(ButtonImageAlignmentType)type imageSpace:(CGFloat)space;

#pragma mark - 扩大按钮的响应范围
- (void)setEnlargeEdge:(CGFloat) size;
- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

/** 实现倒计时 用于 短信验证码 按钮  当倒计时结束时，执行countDownBlock */
- (void)startCountDownTime:(int)time styleIndex:(NSInteger)styleIndex withCountDownBlock:(void(^)(void))countDownBlock;

/// 倒计时
/// - Parameters:
///   - time: 倒计时事件
///   - title: button倒计时文案
///   - countDownBlock: 时间变化事件
///   - finishDownBlock: 计时器结束事件
- (void)startCountDownTime:(int)time
                     title:(NSString *)title
            CountDownBlock:(void(^)(int count))countDownBlock
                    Finish:(void(^)(void))finishDownBlock;

@end

NS_ASSUME_NONNULL_END
