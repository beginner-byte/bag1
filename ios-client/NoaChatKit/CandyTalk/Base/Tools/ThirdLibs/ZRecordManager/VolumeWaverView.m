//
//  VolumeWaverView.m
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/20.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "VolumeWaverView.h"

@interface VolumeWaverView()

@property (strong, nonatomic) NSOperationQueue *queue;


@end

@implementation VolumeWaverView

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 5;
    }
    return _queue;
}

- (instancetype)initWithFrame:(CGRect)frame andType:(VolumeWaverType)type {

    if (self = [self initWithFrame:frame]) {
        
        self.showType = type;
        if (type == VolumeWaverType_Bar) {
//            [self addSubview: self.gridsView];
        }

    }
    return self;
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
       
        //背景色
        self.backgroundColor = [UIColor clearColor];
        
        //监听声波改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:@"updateMeters" object:nil];

    }
    return self;
}
#pragma mark - Action
- (void)updateView:(NSNotification *)notice{
    
    self.soundMeters = notice.object;
}
//赋值后绘图
- (void)setSoundMeters:(NSArray *)soundMeters {
    
    if (self.showType == VolumeWaverType_Line || self.showType == VolumeWaverType_BarMove || !soundMeters.count) {
        
        _soundMeters = soundMeters;
        [self setNeedsDisplay];
        return;
    }
    [self.queue addOperationWithBlock:^{
    
        NSArray *objectArray = soundMeters;
        NSInteger count = objectArray.count;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:objectArray];
        NSMutableArray *valueArray = [NSMutableArray array];
        int index = 0;
        for (int i = 0; i < count; i ++) {
            if (!tempArray.count) {
                break;
            }
            index = arc4random() % tempArray.count;
            NSNumber *value = tempArray[index];
            if (![value isKindOfClass:[NSNumber class]]) {
                continue;
            }
            [valueArray addObject:value];
            [tempArray removeObjectAtIndex:index];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _soundMeters = valueArray;
            [self setNeedsDisplay];
        });
    }];
}
- (void)drawRect:(CGRect)rect {
    
    if (self.soundMeters && self.soundMeters.count) {
        // 上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        // 设置线的顶角样式
        CGContextSetLineCap(context, kCGLineCapRound);
//        CGContextSetLineCap(context, kCGLineCapRound);
        // 设置线的连接样式
        CGContextSetLineJoin(context, kCGLineJoinRound);
//        CGContextSetLineWidth(<#CGContextRef  _Nullable c#>, <#CGFloat width#>)
        // 颜色
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        
        CGFloat noVoice = -80.0;// 该值代表低于 x 的声音都认为无声音
        CGFloat maxVolume = 0; // 该值代表最高声音为 x
     
        CGFloat range = maxVolume - noVoice;//正常获取的分贝值在 -160 ~0 之间，通常说话声音在 - 50左右。
        
        switch (self.showType) {
            case VolumeWaverType_BarMove:
            case VolumeWaverType_Bar:{
                
                CGFloat lineWidth = 2;
                //线宽
                CGContextSetLineWidth(context, lineWidth);
                
                for (int i = 0; i < self.soundMeters.count; i ++) {
                    
                    CGFloat soundValue = [self.soundMeters[self.soundMeters.count - i - 1] floatValue];
                    CGFloat rate = (soundValue - noVoice)/range;
                    CGFloat barHeight = rect.size.height * rate;
                    
                    CGPoint point = CGPointMake(i * ( 6 + lineWidth)+ lineWidth *0.5, rect.size.height);
                  
                    
                    CGContextMoveToPoint(context, point.x, point.y);
                    CGContextAddLineToPoint(context, point.x,  point.y - barHeight);

                }
                
                
            }
                break;
                
            case VolumeWaverType_Line:{
                
                CGFloat lineWidth = 1.5;
                
                CGFloat lineSpace = rect.size.width / (Xcount - 1);

                CGContextSetLineWidth(context, lineWidth);
                CGContextMoveToPoint(context, 0, rect.size.height);

                for (int i = 0; i < self.soundMeters.count; i ++) {

                    CGFloat soundValue = [self.soundMeters[i] floatValue];
                    CGFloat rate = (soundValue - noVoice)/range;
                    CGFloat barHeight = rect.size.height * rate;
                    
                    CGPoint point = CGPointMake(i * lineSpace, rect.size.height);

                    CGContextAddLineToPoint(context, point.x,point.y - barHeight);
                    CGContextMoveToPoint(context, point.x,point.y - barHeight);

                }
                
            }
                
                break;
                
            default:
                break;
        }
        
        CGContextStrokePath(context);
        
    }else {//取消原先的绘制
        
        //背景色：自定义设置
//        self.backgroundColor = [UIColor cyanColor];
        
    }
    
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
