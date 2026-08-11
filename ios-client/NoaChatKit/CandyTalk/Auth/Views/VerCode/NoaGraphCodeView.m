//
//  NoaGraphCodeView.m
//  NoaKit
//
//  Created by Candy on 2026/10/18.
//

#import "NoaGraphCodeView.h"
@interface NoaGraphCodeView()

@property (nonatomic, strong) UIImageView *codeImgView;

@end

@implementation NoaGraphCodeView

- (instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    //设置背景颜色
    self.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
    
    [self addSubview:self.codeImgView];
    [self.codeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setCodeStr:(NSString *)codeStr {
    _codeStr = codeStr;
    if (![NSString isNil:_codeStr]) {
        UIImage *codeImage = [self createCaptchaImageWithText:_codeStr size:CGSizeMake(DWScale(120), DWScale(40))];
        [self.codeImgView setImage:codeImage];
    }
}

//根据服务器返回的或者自己设置的codeStr绘制图形验证码
- (UIImage *)createCaptchaImageWithText:(NSString *)text size:(CGSize)size {
    // 开始图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    // 设置背景颜色
    [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    // 设置字体和颜色
    NSArray *colors = @[
        [UIColor redColor],
        [UIColor greenColor],
        [UIColor blueColor],
        [UIColor orangeColor],
        [UIColor grayColor],
        [UIColor cyanColor],
        [UIColor purpleColor],
        [UIColor darkGrayColor],
        [UIColor magentaColor],
        [UIColor systemPinkColor],
        [UIColor systemBlueColor],
        [UIColor systemBrownColor]
    ];
    
    for (int i = 0; i < text.length; i++) {
        // 随机颜色
        UIColor *color = colors[i % colors.count];
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont boldSystemFontOfSize:26],
            NSForegroundColorAttributeName: color
        };
        
        // 计算字符的绘制区域
        NSString *character = [text safeSubstringWithRange:NSMakeRange(i, 1)];
        CGSize charSize = [character sizeWithAttributes:attributes];
        CGRect charRect = CGRectMake(10 + i * (size.width / text.length), (size.height - charSize.height) / 2, charSize.width, charSize.height);
        
        // 绘制字符
        [character drawInRect:charRect withAttributes:attributes];
    }
    
    // 添加干扰线
//    for (int i = 0; i < 1; i++) {
//        [self drawRandomLineInRect:CGRectMake(0, 0, size.width, size.height)];
//    }
    
    // 获取生成的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)drawRandomLineInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
   
    CGFloat startX = arc4random() % (int)rect.size.width;
    CGFloat startY = arc4random() % (int)rect.size.height;
    CGFloat length = rect.size.width;//arc4random() % 10 + 5; // 线段长度为5到15的随机值
    CGFloat endX = startX + (arc4random() % 2 ? length : -length);
    CGFloat endY = startY + (arc4random() % 2 ? length : -length);
   
    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, endX, endY);
    CGContextStrokePath(context);
}

#pragma mark - Lazy
- (UIImageView *)codeImgView {
    if (!_codeImgView) {
        _codeImgView = [[UIImageView alloc] init];
    }
    return _codeImgView;
}

@end
