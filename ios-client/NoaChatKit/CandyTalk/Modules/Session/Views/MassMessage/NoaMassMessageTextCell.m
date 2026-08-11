//
//  NoaMassMessageTextCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaMassMessageTextCell.h"

@implementation NoaMassMessageTextCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    _lblMessage = [UILabel new];
    _lblMessage.font = FONTR(12);
    _lblMessage.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblMessage.numberOfLines = 0;
    _lblMessage.preferredMaxLayoutWidth = DScreenWidth - DWScale(64);
    [self.viewContent addSubview:_lblMessage];
    [_lblMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.viewContent).offset(DWScale(16));
        make.trailing.equalTo(self.viewContent).offset(-DWScale(16));
        make.top.equalTo(self.viewContent).offset(DWScale(77));
        make.bottom.equalTo(self.viewContent).offset(-DWScale(88));
    }];
}
- (void)setMessageModel:(LIMMassMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    
    _lblMessage.text = messageModel.bodyModel.content;
    
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
