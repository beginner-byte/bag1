//
//  NoaMessageBaseCell.m
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#import "NoaMessageBaseCell.h"
#import "NoaToolManager.h"

@interface NoaMessageBaseCell ()
@property (nonatomic, assign) NSInteger animationNum;
@end

@implementation NoaMessageBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
        self.contentView.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    }
    return self;
}

#pragma mark - 数据赋值
- (void)setCellIndex:(NSIndexPath *)cellIndex {
    if (cellIndex) {
        _cellIndex = cellIndex;
    }
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    _messageModel = model;
}

- (void)showSendMessageReadProgressView:(BOOL)showProgress {
    
}
#pragma mark - 搜索定位消息，闪烁动画
- (void)mesaagePositionAnimation {
    _animationNum = 1;
    [self viewSetColorAnimation];
}
- (void)viewSetColorAnimation {
    WeakSelf
    [ZTOOL doInMain:^{
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.contentView.tkThemebackgroundColors = @[HEXACOLOR(@"4791FF", 0.2),COLOR_00];
        } completion:^(BOOL finished) {
            [weakSelf viewClearColorAnimation];
        }];
    }];
}
- (void)viewClearColorAnimation {
    WeakSelf
    [ZTOOL doInMain:^{
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.contentView.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
            weakSelf.animationNum++;
        } completion:^(BOOL finished) {
            if (weakSelf.animationNum < 3) {
                [weakSelf viewSetColorAnimation];
            }
        }];
    }];
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
