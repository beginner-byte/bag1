//
//  NoaBaseTableView.m
//  NoaKit
//
//  Created by Candy on 2026/9/7.
//

#import "NoaBaseTableView.h"

@implementation NoaBaseTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

//- (instancetype)init{
//    self = [super init];
//    if (self) {
//        [self defaultConfig];
//    }
//    return self;
//}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self defaultConfig];
    }
    return self;
}
#pragma mark - 基本配置
- (void)defaultConfig{
    
    self.backgroundColor = UIColor.clearColor;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    if (@available(iOS 13.0, *)) {
        self.automaticallyAdjustsScrollIndicatorInsets = NO;
    }
    
    //当使用 UITableViewStylePlain 初始化UITableView 的时候，此属性会给每一个 section header 增加一个默认高度
    if (@available(iOS 15.0, *)) {
        self.sectionHeaderTopPadding = 0;
    }
    
    //暂时不用
//    for (id view in self.subviews) {
//        //找到UITableViewWrapperView
//        if ([view isKindOfClass:[UIScrollView class]]) {
//            //turn OFF delaysContentTouches in the hidden subview
//            UIScrollView *scrol = (UIScrollView *)view;
//            scrol.delaysContentTouches = NO;
//        }
//        break;
//    }
    
}

//可解决tableview.delaysContentTouches = NO影响滑动问题
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
