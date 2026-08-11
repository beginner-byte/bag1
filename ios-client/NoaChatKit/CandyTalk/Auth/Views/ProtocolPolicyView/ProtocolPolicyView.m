//
//  ProtocolPolicyView.m
//  NoaKit
//
//  Created by Candy on 2026/9/20.
//

#import "ProtocolPolicyView.h"
//#import <YYText/NSAttributedString+YYText.h>
//#import <YYText/YYLabel.h>
#import "NoaToolManager.h"

@interface ProtocolPolicyView()

@end

@implementation ProtocolPolicyView

- (instancetype)init {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        [self setupUIAndConstraints];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self setupUIAndConstraints];
    }
    return self;
}

- (void)setupUIAndConstraints {
   //复选框
    self.checkBoxBtn = [[UIButton alloc] init];
    [self.checkBoxBtn setImage:ImgNamed(@"icon_checkbox_unselect") forState:UIControlStateNormal];
    [self.checkBoxBtn setImage:ImgNamed(@"icon_checkbox_selected") forState:UIControlStateSelected];
    self.checkBoxBtn.selected = NO;
    [self.checkBoxBtn addTarget:self action:@selector(checkBoxAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.checkBoxBtn];
    [self.checkBoxBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.top.equalTo(self);
        make.width.mas_equalTo(DWScale(15.5));
        make.height.mas_equalTo(DWScale(15.5));
    }];
    
    //内容
    NSString *serveText = LanguageToolMatch(@"《服务协议》");
    NSString *privateText = LanguageToolMatch(@"《隐私政策》");
    NSString *contentText = [NSString stringWithFormat:LanguageToolMatch(@"我已阅读并同意%@和%@"), serveText, privateText];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:contentText];
    [text configAttStrLightColor:COLOR_99 darkColor:COLOR_99_DARK range:NSMakeRange(0, contentText.length)];
    [text yy_setTextHighlightRange:[contentText rangeOfString:serveText] color:COLOR_5966F2 backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        //服务协议
        [ZTOOL setupServeAgreement];
    }];
    [text yy_setTextHighlightRange:[contentText rangeOfString:privateText] color:COLOR_5966F2 backgroundColor:COLOR_CLEAR tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        //隐私政策
        [ZTOOL setupPrivePolicy];
    }];
    [text addAttribute:NSFontAttributeName value:FONTN(13) range:NSMakeRange(0, contentText.length)];
    //Label
    YYLabel *contentLbl = [YYLabel new];
    contentLbl.attributedText = text;
    contentLbl.numberOfLines = 3;
    contentLbl.userInteractionEnabled = YES;
    contentLbl.backgroundColor = COLOR_CLEAR;
    contentLbl.preferredMaxLayoutWidth = DScreenWidth - 25 - DWScale(15.5) - DWScale(3) - 25;
    [self addSubview:contentLbl];
    [contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.checkBoxBtn.mas_trailing).offset(DWScale(3));
        make.top.bottom.trailing.equalTo(self);
    }];
}


#pragma mark -  Action
- (void)checkBoxAction {
    self.checkBoxBtn.selected = !self.checkBoxBtn.selected;
}

@end
