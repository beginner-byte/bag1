//
//  NoaFriendGroupManagerCell.m
//  NoaKit
//
//  Created by Candy on 2023/7/4.
//

#import "NoaFriendGroupManagerCell.h"

@interface NoaFriendGroupManagerCell () <UITextFieldDelegate>
@property (nonatomic, assign) BOOL friendGroupCanEdit;
@property (nonatomic, strong) LingIMFriendGroupModel *friendGroupModel;
@end

@implementation NoaFriendGroupManagerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    
    [self.contentView addSubview:self.baseContentButton];
    [self.baseContentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnDelete setImage:ImgNamed(@"c_fg_delete") forState:UIControlStateNormal];
    [_btnDelete addTarget:self action:@selector(btnDeleteClick) forControlEvents:UIControlEventTouchUpInside];
    _btnDelete.hidden = YES;
    [self.contentView addSubview:_btnDelete];
    [_btnDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(DWScale(16));
    }];
    
    _tfTitle = [UITextField new];
    _tfTitle.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _tfTitle.font = FONTR(16);
    _tfTitle.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfTitle.returnKeyType = UIReturnKeyDone;
    _tfTitle.delegate = self;
    [self.contentView addSubview:_tfTitle];
    
    _ivSelect = [[UIImageView alloc] initWithImage:ImgNamed(@"icon_selected_blue")];
    _ivSelect.hidden = YES;
    [self.contentView addSubview:_ivSelect];
    [_ivSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(16), DWScale(16)));
    }];
    
}

#pragma mark - 配置Cell
- (void)configCellWith:(LingIMFriendGroupModel *)friendGroupModel canEdit:(BOOL)canEdit {
    _friendGroupModel = friendGroupModel;
    _friendGroupCanEdit = canEdit;
    
    //可编辑
    _tfTitle.userInteractionEnabled = _friendGroupCanEdit;
    
    _tfTitle.text = ![NSString isNil:friendGroupModel.ugName] ? friendGroupModel.ugName : LanguageToolMatch(@"默认分组");
    
    if (friendGroupModel.ugType == -1) {
        //默认分组，不可删除
        _btnDelete.hidden = YES;
    }else {
        _btnDelete.hidden = !canEdit;
    }
    
    if (canEdit) {
        
        [_tfTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(DWScale(50));
            make.trailing.equalTo(self.contentView).offset(-DWScale(50));
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(DWScale(40));
        }];
        
        _ivSelect.image = ImgNamed(@"c_fg_move");
        _ivSelect.hidden = NO;
        self.baseContentButton.userInteractionEnabled = NO;
        
    }else {
        
        [_tfTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(DWScale(16));
            make.trailing.equalTo(self.contentView).offset(-DWScale(50));
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(DWScale(40));
        }];
        
        //根据选中情况展示
        _ivSelect.image = ImgNamed(@"icon_selected_blue");
        self.baseContentButton.userInteractionEnabled = YES;
        
    }
}

+ (CGFloat)defaultCellHeight {
    return DWScale(54);
}

#pragma mark - 交互事件
- (void)btnDeleteClick {
    if (_delegate && [_delegate respondsToSelector:@selector(friendGroupManagerDelete:)] && _friendGroupCanEdit) {
        [_delegate friendGroupManagerDelete:_friendGroupModel];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        //回车
        [self updateFriendGroupName];
        
        return NO;
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateFriendGroupName];
}

#pragma mark - 修改分组名称的方法
- (void)updateFriendGroupName {
    NSString *modelFriendGroupName = ![NSString isNil:_friendGroupModel.ugName] ? _friendGroupModel.ugName : LanguageToolMatch(@"默认分组");
    NSString *friendGroupName = _tfTitle.text;
    if (![friendGroupName isEqualToString:modelFriendGroupName]) {
        //修改了好友分组名称
        if (_delegate && [_delegate respondsToSelector:@selector(friendGroupManagerChangeName:newFriendGroupName:)] && _friendGroupCanEdit) {
            [_delegate friendGroupManagerChangeName:_friendGroupModel newFriendGroupName:friendGroupName];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
