//
//  NoaGestureLockIndicatorView.m
//  NoaKit
//
//  Created by Candy on 2023/4/23.
//

#import "NoaGestureLockIndicatorView.h"

@interface NoaGestureLockIndicatorView ()
@property (nonatomic, strong) NSMutableArray *btnList;
@end

@implementation NoaGestureLockIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    //创建9个按钮
    for (NSInteger i = 0; i < 9; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        [btn setImage:[UIImage imageNamed:@"gl_gray_round"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"gl_orange_round"] forState:UIControlStateSelected];
        [self addSubview:btn];
        [self.btnList addObject:btn];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSUInteger count = self.subviews.count;
    
    int cols = 3;//总列数
    
    CGFloat x = 0,y = 0,w = 9,h = 9;//bounds
    CGFloat margin = (self.bounds.size.width - cols * w) / (cols + 1);//间距
    
    CGFloat col = 0;
    CGFloat row = 0;
    for (int i = 0; i < count; i++) {
        
        col = i % cols;
        row = i / cols;
        
        x = margin + (w+margin)*col;
        y = margin + (w+margin)*row;
        
        UIButton *btn = self.subviews[i];
        btn.frame = CGRectMake(x, y, w, h);
    }
    
}
#pragma mark - 设置手势密码
- (void)setGesturePassword:(NSString *)gesturePassword {
    if (gesturePassword.length == 0) {
        for (UIButton *btn in self.btnList) {
            btn.selected = NO;
        }
        return;
    }
    
    for (NSInteger i = 0; i < gesturePassword.length; i++) {
        NSString *pwd = [gesturePassword safeSubstringWithRange:NSMakeRange(i, 1)];
        UIButton *btn = [self.btnList objectAtIndex:[pwd integerValue]];
        btn.selected = YES;
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)btnList {
    if (!_btnList) {
        _btnList = [NSMutableArray array];
    }
    return _btnList;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
