//
//  NoaMediaCallShimmerView.m
//  NoaKit
//
//  Created by Candy on 2023/2/7.
//

#import "NoaMediaCallShimmerView.h"
#import "FBShimmeringView.h"


@implementation NoaMediaCallShimmerView
{
    FBShimmeringView *_viewShimmer;
    UILabel *_lblPoint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _viewShimmer = [[FBShimmeringView alloc] init];
    _viewShimmer.shimmering = YES;
    _viewShimmer.shimmeringBeginFadeDuration = 0.3;
    _viewShimmer.shimmeringOpacity = 0.3;
    _viewShimmer.shimmeringSpeed = 330;
    [self addSubview:_viewShimmer];
    [_viewShimmer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    _lblPoint = [UILabel new];
    _lblPoint.text = @"● ● ● ●";
    _lblPoint.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblPoint.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
    _lblPoint.font = FONTB(10);
    _lblPoint.textAlignment = NSTextAlignmentCenter;
    [_lblPoint sizeToFit];
    _viewShimmer.contentView = _lblPoint;
    [_lblPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_viewShimmer);
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
