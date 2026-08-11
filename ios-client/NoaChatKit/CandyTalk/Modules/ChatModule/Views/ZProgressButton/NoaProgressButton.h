//
//  NoaProgressButton.h
//  NoaKit
//
//  Created by Candy on 2023/2/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaProgressButton : UIButton

//进度值，范围 0 ～ 1
@property (nonatomic, assign) CGFloat progress;
//进度终止状态标题，一旦设置了此标题进度条就会停止
@property (nonatomic, strong) NSString *stopTitle;
    
/**
 *  创建带进度条的按钮
 *
 *  @param frame        按钮的 frame 值
 *  @param title        进按钮的标题
 *  @param lineWidth    进度条的线宽，默认 2
 *  @param lineColor    进度条线的颜色，默认 greenColor
 *  @param textColor    进度值的颜色，默认 blackColor
 *  @param backColor    按钮的背景颜色，默认 clearColor
 *  @param isRound      按钮是否显示为圆形，默认 YES
 *
 *  @return 带进度条的按钮
 */
+ (instancetype)crearProgressButtonWithFrame:(CGRect)frame
                                    title:(NSString *)title
                                lineWidth:(CGFloat)lineWidth
                                lineColor:(nullable UIColor *)lineColor
                                textColor:(nullable UIColor *)textColor
                                backColor:(nullable UIColor *)backColor
                                  isRound:(BOOL)isRound;


@end

NS_ASSUME_NONNULL_END
