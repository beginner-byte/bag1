//
//  NoaChatInputEmojiHeaderView.m
//  NoaKit
//
//  Created by Candy on 2023/8/11.
//

#import "NoaChatInputEmojiHeaderView.h"

@interface NoaChatInputEmojiHeaderView ()

@property (nonatomic, strong) UILabel *titleLbl;
  
@end


@implementation NoaChatInputEmojiHeaderView

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

#pragma mark - Setter
- (void)setTitleStr:(NSString *)titleStr {
    _titleStr = titleStr;
    self.titleLbl.text = _titleStr;
}

#pragma mark - Lazy
- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.tkThemetextColors = @[COLOR_99, COLOR_99];
        _titleLbl.font = FONTR(12);
    }
    return _titleLbl;
}

@end
