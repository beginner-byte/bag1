//
//  NoaContactSectionHeaderView.m
//  NoaKit
//
//  Created by Candy on 2023/7/3.
//

#import "NoaContactSectionHeaderView.h"

@implementation NoaContactSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
