//
//  NoaSessionNetStateView.m
//  NoaKit
//
//  Created by Candy on 2024/3/11.
//

#import "NoaSessionNetStateView.h"

@implementation NoaSessionNetStateView

#pragma mark ------<默认配置>
/**
 *  默认配置
 */
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self defaultConfig];
        
    }
    return self;
}

- (void)defaultConfig {
     self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
     
     UIImageView *networkTipsImgView = [[UIImageView alloc] init];
     networkTipsImgView.image = ImgNamed(@"icon_msg_resend");
     [self addSubview:networkTipsImgView];
     [networkTipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerY.equalTo(self);
         make.leading.equalTo(self).offset(DWScale(24));
         make.size.mas_equalTo(CGSizeMake(DWScale(16), DWScale(16)));
     }];
     
     UILabel *networkTipsLbl = [[UILabel alloc] init];
     networkTipsLbl.text = LanguageToolMatch(@"当前无法连接网络，请检查网络设置是否正常");
     networkTipsLbl.font = FONTN(14);
     networkTipsLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
     [self addSubview:networkTipsLbl];
     [networkTipsLbl mas_makeConstraints:^(MASConstraintMaker *make) {
         make.leading.equalTo(networkTipsImgView.mas_trailing).offset(DWScale(8));
         make.trailing.equalTo(self).offset(-DWScale(10));
         make.top.bottom.equalTo(self);
     }];

}

@end
