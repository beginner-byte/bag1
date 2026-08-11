//
//  NoaEmojiShopFeaturedHeaderView.m
//  NoaKit
//
//  Created by Candy on 2023/10/25.
//

#import "NoaEmojiShopFeaturedHeaderView.h"

@interface NoaEmojiShopFeaturedHeaderView ()

@property (nonatomic, strong) UILabel *titleLbl;
  
@end

@implementation NoaEmojiShopFeaturedHeaderView

-(id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
    [self addSubview:self.titleLbl];
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.trailing.equalTo(self).offset(DWScale(16));
        make.top.equalTo(self).offset(DWScale(10));
        make.height.mas_equalTo(DWScale(20));
    }];
}

#pragma mark - Lazy
- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.text = LanguageToolMatch(@"精选表情");
        _titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _titleLbl.font = FONTR(14);
    }
    return _titleLbl;
}


@end
