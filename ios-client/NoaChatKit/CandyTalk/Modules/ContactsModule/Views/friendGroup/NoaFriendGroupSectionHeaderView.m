//
//  NoaFriendGroupSectionHeaderView.m
//  NoaKit
//
//  Created by Candy on 2023/7/3.
//

#import "NoaFriendGroupSectionHeaderView.h"

@interface NoaFriendGroupSectionHeaderView () <UIGestureRecognizerDelegate>

@end

@implementation NoaFriendGroupSectionHeaderView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
     
    //点击手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    tapGes.delegate = self;
    [self.contentView addGestureRecognizer:tapGes];
    
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.3;
    longPress.delegate = self;
    [self.contentView addGestureRecognizer:longPress];
    
    //如果长按确定侦测失败才会触发单击
    [tapGes requireGestureRecognizerToFail:longPress];
    
    _ivArrow = [[UIImageView alloc] initWithImage:ImgNamed(@"c_triangle_right")];
    [self addSubview:_ivArrow];
    [_ivArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self.mas_leading).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(14), DWScale(14)));
    }];
    
    _lblTitle = [UILabel new];
    _lblTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblTitle.font = FONTR(16);
    _lblTitle.preferredMaxLayoutWidth = DWScale(200);
    [self addSubview:_lblTitle];
    [_lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(_ivArrow.mas_trailing).offset(DWScale(12));
    }];
    
    
    _lblNumber = [UILabel new];
    _lblNumber.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblNumber.font = FONTR(12);
    [self addSubview:_lblNumber];
    [_lblNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self.mas_trailing).offset(-DWScale(16));
    }];
}
#pragma mark - 数据赋值
- (void)setFriendGroupModel:(NoaFriendGroupModel *)friendGroupModel {
    _friendGroupModel = friendGroupModel;
    
    _lblTitle.text = ![NSString isNil:friendGroupModel.friendGroupModel.ugName] ? friendGroupModel.friendGroupModel.ugName : LanguageToolMatch(@"默认分组");
    _lblNumber.text = [NSString stringWithFormat:@"%ld/%ld", friendGroupModel.friendOnLineList.count, friendGroupModel.friendList.count];
    WeakSelf
    if (friendGroupModel.openedSection) {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.ivArrow.transform = CGAffineTransformMakeRotation(M_PI_2);
        } completion:^(BOOL finished) {}];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.ivArrow.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {}];
    }
    
    self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
}


#pragma mark - UIGestureRecognizerDelegate
//允许多个手势并发
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - 交互事件
//点击事件
- (void)tapGes:(UITapGestureRecognizer *)tapGes {
    self.contentView.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
    _friendGroupModel.openedSection = !_friendGroupModel.openedSection;
    
    if (_delegate && [_delegate respondsToSelector:@selector(friendGroupSectionOpenWith:)]) {
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.delegate friendGroupSectionOpenWith:weakSelf.friendGroupModel];
        });
    }
    
}

//长按事件
- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    
    self.contentView.tkThemebackgroundColors = @[COLOR_EEEEEE, COLOR_EEEEEE_DARK];
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        //开始长按手势
        if (_delegate && [_delegate respondsToSelector:@selector(friendGroupSectionLongPress)]) {
            [_delegate friendGroupSectionLongPress];
        }
    }else if (longPress.state == UIGestureRecognizerStateEnded) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
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
