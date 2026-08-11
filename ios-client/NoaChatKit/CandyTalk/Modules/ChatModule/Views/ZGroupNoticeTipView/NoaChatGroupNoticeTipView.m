//
//  NoaChatGroupNoticeTipView.m
//  NoaKit
//
//  Created by Candy on 2023/3/8.
//

#import "NoaChatGroupNoticeTipView.h"

@implementation NoaChatGroupNoticeTipView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGroupNoticeTipUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupGroupNoticeTipUI {
    
    self.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    self.layer.cornerRadius = DWScale(12);
    self.layer.masksToBounds = YES;
    
    UIView *viewLayerBg = [UIView new];
    viewLayerBg.backgroundColor = [UIColor clearColor];
    viewLayerBg.layer.shadowColor = [UIColor blackColor].CGColor;
    viewLayerBg.layer.shadowOffset = CGSizeMake(0, 0); // 阴影偏移量，默认（0,0）
    viewLayerBg.layer.shadowOpacity = 0.1; // 不透明度
    viewLayerBg.layer.shadowRadius = DWScale(2);
    [self addSubview:viewLayerBg];
    [viewLayerBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).offset(DWScale(3));
        make.trailing.bottom.equalTo(self).offset(-DWScale(3));
    }];
    
    UIImageView *ivLogo = [[UIImageView alloc] initWithImage:ImgNamed(@"g_notice_logo")];
    ivLogo.frame = CGRectMake(DWScale(13), DWScale(13), DWScale(16), DWScale(16));
    [self addSubview:ivLogo];
    
    _lblGroupNotice = [[UILabel alloc] initWithFrame:CGRectMake(DWScale(36), DWScale(10), DWScale(269), DWScale(22))];
    _lblGroupNotice.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblGroupNotice.font = FONTR(16);
    _lblGroupNotice.numberOfLines = 1;
    _lblGroupNotice.preferredMaxLayoutWidth = DWScale(269);
    [self addSubview:_lblGroupNotice];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:ImgNamed(@"g_noticeclose_logo") forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnClose];
    [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-DWScale(13));
        make.size.mas_equalTo(CGSizeMake(DWScale(16), DWScale(16)));
    }];
    
    UIButton *btnGroupNotice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGroupNotice.frame = CGRectMake(DWScale(36), DWScale(5), DWScale(269), DWScale(32));
    [btnGroupNotice addTarget:self action:@selector(btnGroupNoticeClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnGroupNotice];
}

#pragma mark - 交互事件
- (void)btnCloseClick {
    if (_delegate && [_delegate respondsToSelector:@selector(groupNoticeTipAction:)]) {
        [_delegate groupNoticeTipAction:0];
    }
}
- (void)btnGroupNoticeClick {
    if (_delegate && [_delegate respondsToSelector:@selector(groupNoticeTipAction:)]) {
        [_delegate groupNoticeTipAction:1];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
