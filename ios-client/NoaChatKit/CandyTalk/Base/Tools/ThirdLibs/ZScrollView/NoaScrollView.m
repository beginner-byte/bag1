//
//  NoaScrollView.m
//  NoaKit
//
//  Created by Candy on 2026/11/11.
//

#import "NoaScrollView.h"

@interface NoaScrollView () <UIGestureRecognizerDelegate>

@end

@implementation NoaScrollView
{
    BOOL _isMoveLeft;//是否滑动到左侧
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    //滑动速度
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    //x方向速度>0为右滑动，反之为左滑动
    if (translation.x <= 0) {
        _isMoveLeft = NO;
    }else{
        _isMoveLeft = YES;
        
    }
    return YES;
}

//此方法返回YES时，手势事件会一直往下传递(允许多手势触发)，不论当前层次是否对该事件进行响应。
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIPanGestureRecognizer *)otherGestureRecognizer {
    //根据contentOffset.x 与 滑动方向 来判断手势是否向下传递
    if (self.contentOffset.x == 0 && _isMoveLeft == YES){
        return YES;
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
