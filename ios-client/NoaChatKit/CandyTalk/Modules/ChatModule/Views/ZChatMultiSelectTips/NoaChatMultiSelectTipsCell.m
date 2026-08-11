//
//  NoaChatMultiSelectTipsCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/18.
//

#import "NoaChatMultiSelectTipsCell.h"
#import "NoaBaseImageView.h"

@interface NoaChatMultiSelectTipsCell ()

@property (nonatomic, strong) NoaBaseImageView *ivHeader;

@end


@implementation NoaChatMultiSelectTipsCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivHeader = [NoaBaseImageView new];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
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
