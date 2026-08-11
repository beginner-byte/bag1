//
//  NoaMessageForwardUserCell.m
//  NoaKit
//
//  Created by Candy on 2026/12/7.
//

#import "NoaMessageForwardUserCell.h"
#import "NoaBaseImageView.h"

@interface NoaMessageForwardUserCell ()

@property (nonatomic, strong) NoaBaseImageView *ivHeader;

@end


@implementation NoaMessageForwardUserCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView setTransform:CGAffineTransformMakeScale(-1, 1)];//水平方向翻
        
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivHeader = [NoaBaseImageView new];
    _ivHeader.layer.cornerRadius = DWScale(12);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(DWScale(24), DWScale(24)));
    }];
}

#pragma mark - 数据赋值
- (void)setToUserDic:(NSDictionary *)toUserDic {
    _toUserDic = toUserDic;
    
    NSInteger chatType = [[_toUserDic objectForKey:@"dialogType"] integerValue];
    
    NSString *avatarUri = (NSString *)[_toUserDic objectForKey:@"avatar"];
    NSString *avatarUrl = [avatarUri getImageFullString];
    
    if (chatType == CIMChatType_SingleChat) {
        [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultAvatar];
    }
    
    if (chatType == CIMChatType_GroupChat) {
        [_ivHeader loadAvatarWithUserImgContent:avatarUrl defaultImg:DefaultGroup];
    }
}

@end
