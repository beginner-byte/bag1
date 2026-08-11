//
//  NoaBaseCollectionView.m
//  NoaKit
//
//  Created by Candy on 2023/1/10.
//

#import "NoaBaseCollectionView.h"

@implementation NoaBaseCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self defaultConfig];
    }
    return self;
}
#pragma mark - 基础配置
- (void)defaultConfig {
    
}

//可解决collectionView.delaysContentTouches = NO影响滑动问题
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
