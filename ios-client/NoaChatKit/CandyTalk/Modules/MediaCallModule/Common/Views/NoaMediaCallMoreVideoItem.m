//
//  NoaMediaCallMoreVideoItem.m
//  NoaKit
//
//  Created by Candy on 2023/2/6.
//

#import "NoaMediaCallMoreVideoItem.h"
#import "NoaToolManager.h"

@interface NoaMediaCallMoreVideoItem ()

@end

@implementation NoaMediaCallMoreVideoItem
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    WeakSelf
    
    self.contentView.tkThemebackgroundColors = @[COLOR_00, COLOR_00_DARK];
    _viewContent = [NoaMediaCallMoreContentView new];
    [self.contentView addSubview:_viewContent];
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self.contentView).offset(DWScale(2));
        make.bottom.trailing.equalTo(self.contentView).offset(-DWScale(2));
    }];
    
    _viewContent.deleteMemberBlock = ^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mediaCallMoreVideoItemDelete:)]) {
            [weakSelf.delegate mediaCallMoreVideoItemDelete:weakSelf.model];
        }
    };
    
}
#pragma mark - 数据赋值
- (void)setModel:(NoaMediaCallGroupMemberModel *)model {
    if (model) {
        _model = model;
        _viewContent.hidden = NO;
        _viewContent.model = model;
    }else {
        _viewContent.hidden = YES;
    }
}
@end
