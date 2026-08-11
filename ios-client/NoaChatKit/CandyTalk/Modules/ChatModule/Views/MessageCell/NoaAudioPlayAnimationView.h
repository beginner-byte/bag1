//
//  NoaAudioPlayAnimationView.h
//  NoaKit
//
//  Created by Candy on 2023/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaAudioPlayAnimationView : UIView

@property (nonatomic, assign) BOOL isSelfMsg;

@property (nonatomic, assign) int duringTime;
//无动画设置 进度
@property (assign, nonatomic) CGFloat persentage;
//有动画设置 进度 0~1
-(void)setAnimationPersentage:(CGFloat)persentage;
/**
 初始化layer 在完成frame赋值后调用一下
 */
-(void)initLayers;

- (void)startAnimation;
- (void)stopAnimation;


@end

NS_ASSUME_NONNULL_END
