//
//  NoaInviteFriendHeaderView.m
//  NoaKit
//
//  Created by Candy on 2024/1/11.
//

#import "NoaInviteFriendHeaderView.h"

@interface NoaInviteFriendHeaderView()

@property (nonatomic, strong)UILabel *contentLabel;
@property (nonatomic, strong)UIButton *selectedBtn;
@property (nonatomic, strong)UIImageView *openStatusImgView;

@end

@implementation NoaInviteFriendHeaderView

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
    self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    
    self.selectedBtn = [[UIButton alloc] init];
    [self.selectedBtn setImage:ImgNamed(@"c_select_no") forState:UIControlStateNormal];
    [self.selectedBtn setImage:ImgNamed(@"c_select_yes") forState:UIControlStateSelected];
    [self.selectedBtn addTarget:self action:@selector(allSelectGroupFriendAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.selectedBtn];
    [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(DWScale(18));
    }];
    [self.selectedBtn setEnlargeEdge:16];
    
    self.openStatusImgView = [[UIImageView alloc] init];
    self.openStatusImgView.image = ImgNamed(@"icon_section_status_close");
    [self.contentView addSubview:self.openStatusImgView];
    [self.openStatusImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.selectedBtn.mas_trailing).offset(DWScale(16));
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(DWScale(14));
    }];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    self.contentLabel.font = FONTR(16);
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.openStatusImgView.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(DWScale(-16));
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCloseEvent)]];
}

- (void)setContentStr:(NSString *)contentStr {
    _contentStr = contentStr;
    
    self.contentLabel.text = _contentStr;
}

- (void)openCloseEvent {
    self.isOpen = !self.isOpen;
    self.openStatusImgView.image = ImgNamed(self.isOpen ? @"icon_section_status_open" : @"icon_section_status_close");
    if (self.openCallback) {
        self.openCallback(self.isOpen);
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.selectedBtn.selected = _isSelected;
}

- (void)setIsOpen:(bool)isOpen {
    _isOpen = isOpen;
    self.openStatusImgView.image = ImgNamed(self.isOpen ? @"icon_section_status_open" : @"icon_section_status_close");
}

#pragma mark - Action
- (void)allSelectGroupFriendAction {
    NSLog(@"该分组全选/取消全选");
    self.selectedBtn.selected = !self.selectedBtn.selected;
    if (self.selectAllCallback) {
        self.selectAllCallback(self.selectedBtn.selected);
    }
    
}
@end
