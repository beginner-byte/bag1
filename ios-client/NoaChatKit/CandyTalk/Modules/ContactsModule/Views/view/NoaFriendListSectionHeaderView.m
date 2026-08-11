//
//  NoaFriendListSectionHeaderView.m
//  NoaKit
//
//  Created by Candy on 2026/9/9.
//

#import "NoaFriendListSectionHeaderView.h"

@interface NoaFriendListSectionHeaderView()


@end


@implementation NoaFriendListSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.userInteractionEnabled = YES;
    self.contentView.tkThemebackgroundColors = @[COLOR_F8F9FB, COLORWHITE_DARK];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    self.contentLabel.font = FONTN(12);
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(16);
        make.trailing.equalTo(self.contentView).offset(-16);
        make.centerY.equalTo(self.contentView);
    }];
    
}



@end
