//
//  NoaMessageMultiBottomView.m
//  NoaKit
//
//  Created by Candy on 2023/4/21.
//

#import "NoaMessageMultiBottomView.h"

@interface NoaMessageMultiBottomView()

@property (nonatomic, strong)UIButton *mergeForwardBtn;
@property (nonatomic, strong)UIButton *singleForwardBtn;
@property (nonatomic, strong)UIButton *deleteMsgBtn;
@property (nonatomic, strong)UIView *line1;
@property (nonatomic, strong)UIView *line2;

@end

@implementation NoaMessageMultiBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.mergeForwardBtn];
    [self addSubview:self.singleForwardBtn];
    [self addSubview:self.deleteMsgBtn];
    [self addSubview:self.line1];
    [self addSubview:self.line2];
}

- (void)reloadShowMultiBottom {
    if ([UserManager.userRoleAuthInfo.deleteMessage.configValue isEqualToString:@"false"] && [UserManager.userRoleAuthInfo.remoteDeleteMessage.configValue isEqualToString:@"false"]) {
        self.mergeForwardBtn.hidden = NO;
        self.singleForwardBtn.hidden = NO;
        self.deleteMsgBtn.hidden = YES;
        self.line1.hidden = NO;
        self.line2.hidden = YES;
        
        self.mergeForwardBtn.frame = CGRectMake(0, 0, DScreenWidth/2, DWScale(56));
        self.singleForwardBtn.frame = CGRectMake(DScreenWidth/2, 0, DScreenWidth/2, DWScale(56));
        self.deleteMsgBtn.frame = CGRectZero;
        self.line1.frame = CGRectMake(DScreenWidth/2, DWScale(18), 1, DWScale(24));
        self.line2.frame = CGRectZero;
    } else {
        self.mergeForwardBtn.hidden = NO;
        self.singleForwardBtn.hidden = NO;
        self.deleteMsgBtn.hidden = NO;
        self.line1.hidden = NO;
        self.line2.hidden = NO;
        
        self.mergeForwardBtn.frame = CGRectMake(0, 0, DScreenWidth/3, DWScale(56));
        self.singleForwardBtn.frame = CGRectMake(DScreenWidth/3, 0, DScreenWidth/3, DWScale(56));
        self.deleteMsgBtn.frame = CGRectMake(DScreenWidth/3 * 2, 0, DScreenWidth/3, DWScale(56));
        self.line1.frame = CGRectMake(DScreenWidth/3, DWScale(18), 1, DWScale(24));
        self.line2.frame = CGRectMake(DScreenWidth/3 * 2, DWScale(18), 1, DWScale(24));
    }
}

- (void)setSelectNum:(NSInteger)selectNum {
    _selectNum = selectNum;
    
    if (_selectNum > 0) {
        //合并转发
        NSString *mergeTitleStr = [NSString stringWithFormat:@"%@(%ld%@)",LanguageToolMatch(@"合并转发"), (long)_selectNum, LanguageToolMatch(@"条")];
        [self.mergeForwardBtn setTitle:mergeTitleStr forState:UIControlStateNormal];
        [self.mergeForwardBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(8)];
        
        //逐条转发
        NSString *singelTitleStr = [NSString stringWithFormat:@"%@(%ld%@)",LanguageToolMatch(@"逐条转发"), (long)_selectNum, LanguageToolMatch(@"条")];
        [self.singleForwardBtn setTitle:singelTitleStr forState:UIControlStateNormal];
        [self.singleForwardBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(8)];
        
        //删除
        NSString *deleteTitleStr = [NSString stringWithFormat:@"%@(%ld%@)",LanguageToolMatch(@"删除"), (long)_selectNum, LanguageToolMatch(@"条")];
        [self.deleteMsgBtn setTitle:deleteTitleStr forState:UIControlStateNormal];
        [self.deleteMsgBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(8)];
        
    } else {
        //合并转发
        [self.mergeForwardBtn setTitle:LanguageToolMatch(@"合并转发") forState:UIControlStateNormal];
        [self.mergeForwardBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(8)];
        
        //逐条转发
        [self.singleForwardBtn setTitle:LanguageToolMatch(@"逐条转发") forState:UIControlStateNormal];
        [self.singleForwardBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(8)];
        
        //删除
        [self.deleteMsgBtn setTitle:LanguageToolMatch(@"删除") forState:UIControlStateNormal];
        [self.deleteMsgBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(8)];
    }
}

#pragma mark - Action
//合并转发
- (void)mergeForwardAcion {
    if ([self.delegate respondsToSelector:@selector(mergeForwardMessageAction)]) {
        [self.delegate mergeForwardMessageAction];
    }
}

//逐条转发
- (void)singleForwardAcion {
    if ([self.delegate respondsToSelector:@selector(singleForwardMessageAction)]) {
        [self.delegate singleForwardMessageAction];
    }
}

//删除消息
- (void)deleteMessageAcion {
    if ([self.delegate respondsToSelector:@selector(deleteSelectedMessageAction)]) {
        [self.delegate deleteSelectedMessageAction];
    }
}

#pragma mark - Lazy
- (UIButton *)mergeForwardBtn {
    if (!_mergeForwardBtn) {
        _mergeForwardBtn = [[UIButton alloc] init];
        [_mergeForwardBtn setTitle:LanguageToolMatch(@"合并转发") forState:UIControlStateNormal];
        [_mergeForwardBtn setTkThemeTitleColor:@[COLOR_002CB6, COLOR_002CB6_DARK] forState:UIControlStateNormal];
        [_mergeForwardBtn setImage:ImgNamed(@"m_multi_merge_forward") forState:UIControlStateNormal];
        _mergeForwardBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        _mergeForwardBtn.titleLabel.font = FONTN(12);
        [_mergeForwardBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(8)];
        [_mergeForwardBtn addTarget:self action:@selector(mergeForwardAcion) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mergeForwardBtn;
}

- (UIButton *)singleForwardBtn {
    if (!_singleForwardBtn) {
        _singleForwardBtn = [[UIButton alloc] init];
        [_singleForwardBtn setTitle:LanguageToolMatch(@"逐条转发") forState:UIControlStateNormal];
        [_singleForwardBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        [_singleForwardBtn setImage:ImgNamed(@"m_multi_item_forward") forState:UIControlStateNormal];
        _singleForwardBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        _singleForwardBtn.titleLabel.font = FONTN(12);
        [_singleForwardBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(8)];
        [_singleForwardBtn addTarget:self action:@selector(singleForwardAcion) forControlEvents:UIControlEventTouchUpInside];
    }
    return _singleForwardBtn;
}

- (UIButton *)deleteMsgBtn {
    if (!_deleteMsgBtn) {
        _deleteMsgBtn = [[UIButton alloc] init];
        [_deleteMsgBtn setTitle:LanguageToolMatch(@"删除") forState:UIControlStateNormal];
        [_deleteMsgBtn setTkThemeTitleColor:@[COLOR_ED6542, COLOR_ED6542_DARK] forState:UIControlStateNormal];
        [_deleteMsgBtn setImage:ImgNamed(@"m_multi_delete") forState:UIControlStateNormal];
        _deleteMsgBtn.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        _deleteMsgBtn.titleLabel.font = FONTN(12);
        [_deleteMsgBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(8)];
        [_deleteMsgBtn addTarget:self action:@selector(deleteMessageAcion) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteMsgBtn;
}

- (UIView *)line1 {
    if (!_line1) {
        _line1 = [[UIView alloc] init];
        _line1.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    }
    return _line1;
}

- (UIView *)line2 {
    if (!_line2) {
        _line2 = [[UIView alloc] init];
        _line2.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    }
    return _line2;
}

@end
