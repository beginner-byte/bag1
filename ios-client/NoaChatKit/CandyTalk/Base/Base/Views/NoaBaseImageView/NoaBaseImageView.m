//
//  NoaBaseImageView.m
//  NoaKit
//
//  Created by Candy on 2026/9/9.
//

#import "NoaBaseImageView.h"

@implementation NoaBaseImageView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
    }
    return self;
}
- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self defaultConfig];
    }
    return self;
}
- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self defaultConfig];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
#pragma mark - 基本配置
- (void)defaultConfig {
    self.backgroundColor = self.image ? UIColor.clearColor : HEXCOLOR(@"999999");
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    //监听image
    [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"image"]) {
        if (self.image) {
            self.backgroundColor = [UIColor clearColor];
        }else{
            self.backgroundColor = HEXCOLOR(@"999999");
        }
    }
}
- (void)dealloc{
    [self removeObserver:self forKeyPath:@"image"];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
