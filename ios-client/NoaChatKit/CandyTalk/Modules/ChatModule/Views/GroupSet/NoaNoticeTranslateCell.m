//
//  NoaNoticeTranslateCell.m
//  NoaKit
//
//  Created by Candy on 2024/2/19.
//

#import "NoaNoticeTranslateCell.h"
#import "UIButton+Gradient.h"
#import "NoaNoticeTranslateEditView.h"

@interface NoaNoticeTranslateCell () <ZNoticeTranslateEditViewDelegate>

@property (nonatomic, strong) UILabel *translateTitleLbl;
@property (nonatomic, strong) UILabel *translateContentLbl;
@property (nonatomic, strong) UIButton *translateEditBtn;
@property (nonatomic, strong) UILabel *translateFailLbl;//字符不足，翻译失败！
@property (nonatomic, strong) UIButton *retryTranslateBtn;//翻译失败，请重试！
@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation NoaNoticeTranslateCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
    
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    _translateTitleLbl = [[UILabel alloc] init];
    _translateTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _translateTitleLbl.font = FONTN(16);
    [self.contentView addSubview:_translateTitleLbl];
    [_translateTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(self.contentView);
        make.width.mas_equalTo(DWScale(32));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _translateEditBtn = [[UIButton alloc] init];
    [_translateEditBtn setImage:ImgNamed(@"notice_translate_edit") forState:UIControlStateNormal];
    [_translateEditBtn addTarget:self action:@selector(editClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_translateEditBtn];
    [_translateEditBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_translateTitleLbl.mas_trailing).offset(DWScale(6));
        make.centerY.equalTo(_translateTitleLbl);
        make.width.height.mas_equalTo(DWScale(20));
    }];

    _translateContentLbl = [[UILabel alloc] init];
    _translateContentLbl.text = LanguageToolMatch(@"翻译中...");
    _translateContentLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _translateContentLbl.font = FONTN(14);
    _translateContentLbl.numberOfLines = 3;
    [self.contentView addSubview:_translateContentLbl];
    [_translateContentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(_translateTitleLbl.mas_bottom).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.bottom.equalTo(self.contentView).offset(-DWScale(16));
    }];
    
    _translateFailLbl = [[UILabel alloc] init];
    _translateFailLbl.text = LanguageToolMatch(@"字符不足，翻译失败！");
    _translateFailLbl.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2];
    _translateFailLbl.font = FONTN(14);
    _translateFailLbl.textAlignment = NSTextAlignmentLeft;
    _translateFailLbl.hidden = YES;
    [self.contentView addSubview:_translateFailLbl];
    [_translateFailLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(_translateTitleLbl.mas_bottom).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(20));
    }];

    _retryTranslateBtn = [[UIButton alloc] init];
    _retryTranslateBtn = [[UIButton alloc] init];
    [_retryTranslateBtn setTitle:LanguageToolMatch(@"翻译失败，请重试！") forState:UIControlStateNormal];
    [_retryTranslateBtn setImage:ImgNamed(@"icon_msg_translate_fail") forState:UIControlStateNormal];
    [_retryTranslateBtn setIconInLeftWithSpacing:DWScale(2)];
    [_retryTranslateBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2] forState:UIControlStateNormal];
    _retryTranslateBtn.titleLabel.font = FONTN(14);
    _retryTranslateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_retryTranslateBtn addTarget:self action:@selector(retryClick) forControlEvents:UIControlEventTouchUpInside];
    _retryTranslateBtn.hidden = YES;
    [self.contentView addSubview:_retryTranslateBtn];
    [_retryTranslateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.top.equalTo(_translateTitleLbl.mas_bottom).offset(DWScale(10));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.tkThemebackgroundColors = @[COLOR_E6E6E6, COLOR_99];
    [self.contentView addSubview:_bottomLineView];
    [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(16));
        make.trailing.equalTo(self.contentView).offset(-DWScale(16));
        make.top.equalTo(_translateContentLbl.mas_bottom).offset(DWScale(15));
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Data
- (void)setModel:(NoaNoticeTranslateModel *)model {
    _model = model;
    if (_model) {
        _translateTitleLbl.text = _model.languageName;
        CGFloat titleWidth = [_model.languageName widthForFont:FONTN(16)];
        if (titleWidth > (DScreenWidth - DWScale(16)*2 - DWScale(6) - DWScale(20))) {
            titleWidth = DScreenWidth - DWScale(16)*2 - DWScale(6) - DWScale(20);
        } else {
            if (titleWidth < DWScale(32)) {
                titleWidth = DWScale(32);
            }
        }
        [_translateTitleLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(titleWidth);
        }];
        
        if (_model.isOrigin) {
            _translateEditBtn.hidden = YES;
            _bottomLineView.hidden = NO;
            _translateContentLbl.text = _model.originNotice;
        } else {
            _translateEditBtn.hidden = NO;
            _bottomLineView.hidden = YES;
            switch (model.translateStatus) {
                case 1://翻译中
                    _translateEditBtn.enabled = NO;
                    _translateFailLbl.hidden = YES;
                    _retryTranslateBtn.hidden = YES;
                    _translateContentLbl.hidden = NO;
                    _translateContentLbl.text = LanguageToolMatch(@"翻译中...");
                    [self requestTranslateContent];
                    break;
                case 2://翻译成功显示译文
                    _translateEditBtn.enabled = YES;
                    _translateFailLbl.hidden = YES;
                    _retryTranslateBtn.hidden = YES;
                    _translateContentLbl.hidden = NO;
                    _translateContentLbl.text = _model.translateNotice;
                    break;
                case 3://字符不足，翻译失败
                    _translateEditBtn.enabled = YES;
                    _translateFailLbl.hidden = NO;
                    _retryTranslateBtn.hidden = YES;
                    _translateContentLbl.hidden = YES;
                    break;
                case 4://翻译失败，请重试
                    _translateEditBtn.enabled = YES;
                    _translateFailLbl.hidden = YES;
                    _retryTranslateBtn.hidden = NO;
                    _translateContentLbl.hidden = YES;
                    break;
                    
                default:
                    break;
            }
        }
    }
}

#pragma mark - Request
- (void)requestTranslateContent {
    if (_model.translateStatus == 1) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObjectSafe:_model.channelCode forKey:@"channelCode"];
        [dict setObjectSafe:_model.languageCode forKey:@"to"];
        [dict setObjectSafe:_model.originNotice forKey:@"content"];
        [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
        
        WeakSelf
        [IMSDKManager imSdkTranslateYuueeContent:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            NSString *translateContent = (NSString *)data;
            weakSelf.model.translateStatus = 2;
            weakSelf.model.translateNotice = translateContent;
            weakSelf.model.isTranslate = YES;
            //翻译成功
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(noticeTranslateSuccess:indexPath:)]) {
                [weakSelf.delegate noticeTranslateSuccess:weakSelf.model indexPath:weakSelf.baseCellIndexPath];
            }
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            weakSelf.model.translateNotice = @"";
            weakSelf.model.isTranslate = YES;
            if (code == Translate_yuuee_no_balance_code) {
                //字符不足，翻译失败！
                weakSelf.model.translateStatus = 3;
            } else {
                //翻译失败，请重试！
                weakSelf.model.translateStatus = 4;
            }
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(noticeTranslateFail:indexPath:)]) {
                [weakSelf.delegate noticeTranslateFail:weakSelf.model indexPath:weakSelf.baseCellIndexPath];
            }
        }];
    }
}

#pragma mark - Action
- (void)editClick {
    //手动编辑
    if (_model.translateStatus == 1) {
        return;
    }
    
    NoaNoticeTranslateEditView *editTranslateView = [[NoaNoticeTranslateEditView alloc] init];
    editTranslateView.delegate = self;
    editTranslateView.editTitelStr = _model.languageName;
    editTranslateView.editContentStr = _model.translateNotice;
    if (_model.translateStatus == 3 || _model.translateStatus == 4) {
        editTranslateView.maxContentNum = 1000;
    } else {
        if (_model.translateNotice.length <= 1000) {
            editTranslateView.maxContentNum = 1000;
        } else {
            editTranslateView.maxContentNum = _model.translateNotice.length;
        }
    }
    [editTranslateView editViewShow];
}

#pragma mark - ZNoticeTranslateEditViewDelegate
- (void)editContentFinish:(NSString *)contentStr {
    _model.translateStatus = 2;
    _model.translateNotice = contentStr;
    if (self.delegate && [self.delegate respondsToSelector:@selector(noticeTranslateEdit:indexPath:)]) {
        [self.delegate noticeTranslateEdit:_model indexPath:self.baseCellIndexPath];
    }
}

- (void)retryClick {
    //重新翻译
    _model.translateStatus = 1;
    [self requestTranslateContent];
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
