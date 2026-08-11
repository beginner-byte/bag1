//
//  NoaGestureLockView.m
//  NoaKit
//
//  Created by Candy on 2023/4/23.
//

#import "NoaGestureLockView.h"

#define SaveGesturesPassword @"SaveGesturesPassword"

@interface NoaGestureLockView ()
@property (nonatomic, strong) NSMutableArray *selectBtnList;//选中的按钮
@property (nonatomic, assign) BOOL finished;//是否完成
@property (nonatomic, assign) CGPoint currentPoint;//当前触摸点
@end

@implementation NoaGestureLockView
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
    
}

#pragma mark - 界面布局
- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    //手势
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
    [self addGestureRecognizer:panGes];
    
    //创建九宫格
    for (NSInteger i = 0; i < 9; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        [btn setImage:[UIImage imageNamed:@"gl_gray_round"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"gl_blue_round"] forState:UIControlStateSelected];
        [self addSubview:btn];
        btn.tag = 200 + i;
    }
}

//子控件布局约束
- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSUInteger count = self.subviews.count;
    
    NSInteger cols = 3;//总列数
    
    CGFloat x = 0, y = 0, w = DWScale(60), h = DWScale(60);
    
    //间距
    CGFloat margin = (self.bounds.size.width - cols * w) / (cols + 1);
    
    CGFloat col = 0;
    CGFloat row = 0;
    
    for (NSInteger i = 0; i < count; i++) {
        
        col = i % cols;
        
        row = i / cols;
        
        x = margin + (w + margin) * col;
        
        y = margin + (w + margin) * row;
        
        UIButton *btn = [self.subviews objectAtIndex:i];
        btn.frame = CGRectMake(x, y, w, h);
        
    }
    
}
//只要调用这个方法，就会把之前绘制的东西清空，重新绘制
- (void)drawRect:(CGRect)rect {
    if (_selectBtnList.count == 0) return;
    
    //把所有选中按钮 中心点 连线
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = DWScale(2);
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineCapStyle = kCGLineCapRound;
    
    for (NSInteger i = 0; i < self.selectBtnList.count; i++) {
        UIButton *btn = self.selectBtnList[i];
        if (i == 0) {
            //设置起点
            [path moveToPoint:btn.center];
        }else {
            [path addLineToPoint:btn.center];
        }
    }
    
    //判断是否松开手指
    if (!self.finished) {
        //手指未松开，设置路径
        [path addLineToPoint:self.currentPoint];
        
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            if (themeIndex == 0) {
                [COLOR_5966F2 set];
            }else {
                [COLOR_5966F2_DARK set];
            }
        };
        
    }else {
        //手指已松开
    }
    
    //渲染
    [path stroke];
}

#pragma mark - 手势方法
- (void)panGes:(UIPanGestureRecognizer *)panGes {
    
    //手势开始
    if (panGes.state == UIGestureRecognizerStateBegan) {
    }
    
    //当前触摸点位置
    _currentPoint = [panGes locationInView:self];
    
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, _currentPoint)) {
            if (btn.selected == NO) {
                //点在按钮上，设置为选中
                btn.selected = YES;
                [self.selectBtnList addObject:btn];
            }
        }
    }
    
    //重绘
    [self setNeedsDisplay];
    [self layoutIfNeeded];
    
    
    if (panGes.state == UIGestureRecognizerStateEnded) {
        
        for (UIButton *btn in self.selectBtnList) {
            btn.selected = NO;
        }
        
        if (self.selectBtnList.count < 3){
            [HUD showMessage:LanguageToolMatch(@"至少选择3个点")];
            [self.selectBtnList removeAllObjects];
            return;
        }
        
        //获取手势密码
        NSMutableString *gesturePassword = [self readGesturePassword];
        [self.selectBtnList removeAllObjects];
        
        //手势密码绘制完成后回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockViewFinishWith:)]) {
            [self.delegate gestureLockViewFinishWith:gesturePassword];
        }
    }
    
}
#pragma mark - 获取设置的手势密码
- (NSMutableString *)readGesturePassword {
    //创建可变字符串
    NSMutableString *result = [NSMutableString string];
    for (UIButton *btn in self.selectBtnList) {
        [result appendFormat:@"%ld", btn.tag - 200];
    }
    return result;
}

#pragma mark - 懒加载
- (NSMutableArray *)selectBtnList {
    if (!_selectBtnList) {
        _selectBtnList = [NSMutableArray array];
    }
    return _selectBtnList;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
