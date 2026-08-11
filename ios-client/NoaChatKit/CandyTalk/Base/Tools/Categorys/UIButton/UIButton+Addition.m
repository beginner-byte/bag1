//
//  UIButton+Addition.m
//  NoaIMChatService
//
//  Created by Candy on 2026/7/8.
//

#import "UIButton+Addition.h"
#import <objc/runtime.h>

static char topNameKey;
static char rightNameKey;
static char bottomNameKey;
static char leftNameKey;


@implementation UIButton (Addition)
- (void)setBtnImageAlignmentType:(ButtonImageAlignmentType)type imageSpace:(CGFloat)space{
    /**
      UIButton中titleLabel和imageView的位置依赖:
      如果只有文字(或者图片)时,titleEdgeInsets(或imageEdgeInsets)是button中titleLabel(或imageView)相对于button的上下左右的内边距;
      如果同时有titleLabel和imageView，那么imageView的上下左是相对于button，右边是相对于titleLabel的;
      titleLabel的上下右是相对于button，左边是相对于imageView的。
      */

      // 获取imageView的宽、高
      CGFloat imageWith = self.currentImage.size.width;
      CGFloat imageHeight = self.currentImage.size.height;

      // 获取titleLabel的宽、高
      //intrinsicContentSize:也就是控件的内置大小,比如UILabel,UIButton等控件,
      //他们都有自己的内置大小,控件的内置大小往往是由控件本身的内容所决定的
      CGFloat labelWidth = self.titleLabel.intrinsicContentSize.width;
      CGFloat labelHeight = self.titleLabel.intrinsicContentSize.height;

      // 初始化imageEdgeInsets和labelEdgeInsets
      UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
      UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;

      // 根据参数style和space设置imageEdgeInsets和labelEdgeInsets的值
      switch (type) {
          case ButtonImageAlignmentTypeTop:
          {
              imageEdgeInsets = UIEdgeInsetsMake(-labelHeight - space / 2.0, 0, 0, -labelWidth);
              labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight - space / 2.0, 0);
          }
              break;
          case ButtonImageAlignmentTypeLeft:
          {
              imageEdgeInsets = UIEdgeInsetsMake(0, -space / 2.0, 0, space / 2.0);
              labelEdgeInsets = UIEdgeInsetsMake(0, space / 2.0, 0, -space / 2.0);
          }
              break;
          case ButtonImageAlignmentTypeBottom:
          {
              imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space / 2.0, -labelWidth);
              labelEdgeInsets = UIEdgeInsetsMake(-imageHeight - space / 2.0, -imageWith, 0, 0);
          }
              break;
          case ButtonImageAlignmentTypeRight:
          {
              imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + space / 2.0, 0, -labelWidth-space/2.0);
              labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith - space / 2.0, 0, imageWith + space / 2.0);
          }
              break;
          default:
              break;
      }
      // 重新设置titleEdgeInsets和imageEdgeInsets
      self.titleEdgeInsets = labelEdgeInsets;
      self.imageEdgeInsets = imageEdgeInsets;
}

#pragma mark - 扩大按钮的响应范围
- (void)setEnlargeEdge:(CGFloat) size{
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left{
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)enlargedRect
{
    NSNumber* topEdge = objc_getAssociatedObject(self, &topNameKey);
    NSNumber* rightEdge = objc_getAssociatedObject(self, &rightNameKey);
    NSNumber* bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber* leftEdge = objc_getAssociatedObject(self, &leftNameKey);
    if (topEdge && rightEdge && bottomEdge && leftEdge)
    {
        return CGRectMake(self.bounds.origin.x - leftEdge.floatValue,
                          self.bounds.origin.y - topEdge.floatValue,
                          self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue,
                          self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
    }
    else
    {
        return self.bounds;
    }
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = [self enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds))
    {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? YES : NO;
}


//
- (void)startCountDownTime:(int)time styleIndex:(NSInteger)styleIndex withCountDownBlock:(void(^)(void))countDownBlock{
    __block int timeout = time;
    UIFont *font = self.titleLabel.font;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        //倒计时结束
        if(timeout <= 1){
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userInteractionEnabled = YES;
                self.titleLabel.font = font;
                //倒计时结束回调
                if (countDownBlock) {
                    countDownBlock();
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *text;
                if (styleIndex == 1) {
                    text = [NSString stringWithFormat:LanguageToolMatch(@"%ds后重新获取"),timeout];
                } else if (styleIndex == 2) {
                    text = [NSString stringWithFormat:LanguageToolMatch(@"重新获取(%d)"),timeout];
                } else {
                    text = [NSString stringWithFormat:LanguageToolMatch(@"%ds后重新获取"),timeout];
                }
                [self setTitle:text forState:UIControlStateNormal];
                self.userInteractionEnabled = NO;
                self.titleLabel.font = [UIFont systemFontOfSize:15];
            });
            timeout --;
        }
    });
    dispatch_resume(_timer);
}

- (void)startCountDownTime:(int)time
                     title:(NSString *)title
            CountDownBlock:(void(^)(int count))countDownBlock
                    Finish:(void(^)(void))finishDownBlock {
    __block int timeout = time;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        //倒计时结束
        if(timeout <= 1){
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //倒计时结束回调
                if (finishDownBlock) {
                    finishDownBlock();
                }
            });
        }else{
            timeout -=1;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (countDownBlock) {
                    countDownBlock(timeout);
                }
            });
        }
    });
    dispatch_resume(_timer);
}


@end
