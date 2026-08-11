//
//  NoaChatLinkSetViewCell.m
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaChatLinkSetViewCell.h"

@interface NoaChatLinkSetViewCell()

@property (nonatomic, strong)UIButton *deleteBtn;
@property (nonatomic, strong)UIImageView *iconImgView;
@property (nonatomic, strong)UILabel *titleLbl;
@property (nonatomic, strong)UIButton *editBtn;
@property (nonatomic, strong)UIView *bottomLine;

@end


@implementation NoaChatLinkSetViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    [self.contentView addSubview:self.deleteBtn];
    [self.contentView addSubview:self.iconImgView];
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.editBtn];
    [self.contentView addSubview:self.bottomLine];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@16);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.deleteBtn.mas_trailing).offset(5);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-16);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.iconImgView.mas_trailing).offset(3);
        make.trailing.equalTo(self.editBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(20);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(6);
        make.trailing.equalTo(self.contentView).offset(-6);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Setter
- (void)setTagModel:(NoaChatTagModel *)tagModel {
    _tagModel = tagModel;
    
    if (_tagModel.localType == 1) {
        [self.deleteBtn setImage:ImgNamed(@"icon_link_delete_unused") forState:UIControlStateNormal];
        self.deleteBtn.userInteractionEnabled = NO;
        self.editBtn.hidden = YES;
        [_iconImgView rounded:0];
        [self.iconImgView setImage:ImgNamed(_tagModel.tagIcon)];
    } else {
        [self.deleteBtn setImage:ImgNamed(@"icon_link_delete_used") forState:UIControlStateNormal];
        self.deleteBtn.userInteractionEnabled = YES;
        self.editBtn.hidden = NO;
        [_iconImgView rounded:8];
        [self.iconImgView sd_setImageWithURL:[_tagModel.tagIcon getImageFullUrl] placeholderImage:ImgNamed(@"mini_app_icon") options:SDWebImageAllowInvalidSSLCertificates];
    }
    
    self.titleLbl.text = LanguageToolMatch(_tagModel.tagName);
}

#pragma mark - Action
- (void)deleteBtnClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteChatLinkAction:)]) {
        [self.delegate deleteChatLinkAction:self.cellaPath.row];
    }
}

- (void)editBtnClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editChatLinkAction:)]) {
        [self.delegate editChatLinkAction:self.cellaPath.row];
    }
}

#pragma mark - Lazy
- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setImage:ImgNamed(@"icon_link_delete_unused") forState:UIControlStateNormal];
        _deleteBtn.userInteractionEnabled = NO;
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.image = ImgNamed(@"mini_app_icon");
        // 设置内容模式：保持宽高比，填充整个视图（超出部分会被裁剪）
        _iconImgView.contentMode = UIViewContentModeScaleAspectFill;
        // 裁剪超出边界的部分
        _iconImgView.clipsToBounds = YES;
    }
    return _iconImgView;
}

- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = FONTR(14);
        _titleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    }
    return _titleLbl;
}

- (UIButton *)editBtn {
    if (!_editBtn) {
        _editBtn = [[UIButton alloc] init];
        [_editBtn setImage:ImgNamed(@"icon_link_edit") forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    }
    return _bottomLine;
}


#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
