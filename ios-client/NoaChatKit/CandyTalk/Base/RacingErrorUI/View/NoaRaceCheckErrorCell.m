//
//  NoaRaceCheckErrorCell.m
//  NoaKit
//
//  Created by Candy on 2024/5/11.
//

#import "NoaRaceCheckErrorCell.h"

@interface NoaRaceCheckErrorCell()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *seriaNumLbl;
@property (nonatomic, strong) UILabel *urlContentLbl;
@property (nonatomic, strong) UILabel *httpCodeLbl;
@property (nonatomic, strong) UILabel *serverMsgLbl;
@property (nonatomic, strong) UILabel *traceIdLbl;

@end

@implementation NoaRaceCheckErrorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI {
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(DWScale(12));
        make.leading.equalTo(self.contentView).offset(DWScale(24));
        make.trailing.equalTo(self.contentView).offset(DWScale(-24));
        make.bottom.equalTo(self.contentView).offset(DWScale(-12));
    }];
    
    [self.backView addSubview:self.seriaNumLbl];
    [self.seriaNumLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self.backView);
        make.width.mas_equalTo(DWScale(20));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.backView addSubview:self.httpCodeLbl];
    [self.httpCodeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.equalTo(self.backView);
        make.width.mas_equalTo(DWScale(60));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.backView addSubview:self.urlContentLbl];
    [self.urlContentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView);
        make.leading.equalTo(self.seriaNumLbl.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.httpCodeLbl.mas_leading).offset(DWScale(-10));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.backView addSubview:self.serverMsgLbl];
    [self.serverMsgLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.urlContentLbl.mas_bottom).offset(DWScale(6));
        make.leading.equalTo(self.urlContentLbl);
        make.trailing.equalTo(self.backView);
    }];
    
    [self.backView addSubview:self.traceIdLbl];
    [self.traceIdLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.serverMsgLbl.mas_bottom).offset(DWScale(4));
        make.leading.equalTo(self.urlContentLbl);
        make.trailing.equalTo(self.backView);
        make.bottom.equalTo(self.backView);
    }];
}

#pragma mark - setter
- (void)setCellIndex:(NSInteger)cellIndex {
    _cellIndex = cellIndex;
    
    self.seriaNumLbl.text = [NSString stringWithFormat:@"%ld", _cellIndex + 1];
}

- (void)setModel:(NoaRaceCheckErrorModel *)model {
    _model = model;
    
    if ([NSString isNil:_model.host]) {
        self.urlContentLbl.text = _model.url;
    } else {
        self.urlContentLbl.text = [NSString stringWithFormat:@"(%@)%@", _model.host, [_model.url desensitizeIPAddress]];
    }
   
    self.httpCodeLbl.text = _model.httpCode;
    if ([_model.httpCode isEqualToString:@"200"] || [_model.httpCode isEqualToString:@"10000"]) {
        self.httpCodeLbl.tkThemetextColors = @[COLOR_00D971, COLOR_00D971_DARK];
    } else {
        self.httpCodeLbl.tkThemetextColors = @[COLOR_F93A2F, COLOR_F93A2F_DARK];
    }
    self.serverMsgLbl.text = [NSString stringWithFormat:@"serverMsg:%@", _model.serverMsg];
    if ([NSString isNil:_model.traceId]) {
        self.traceIdLbl.text = @"";
    } else {
        self.traceIdLbl.text = [NSString stringWithFormat:@"traceld:%@", _model.traceId];
    }
}

#pragma mark - Lazy
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    }
    return _backView;
}

- (UILabel *)seriaNumLbl {
    if (!_seriaNumLbl) {
        _seriaNumLbl = [[UILabel alloc] init];
        _seriaNumLbl.text = @"";
        _seriaNumLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _seriaNumLbl.font = FONTN(16);
        _seriaNumLbl.textAlignment = NSTextAlignmentRight;
    }
    return _seriaNumLbl;
}

- (UILabel *)urlContentLbl {
    if (!_urlContentLbl) {
        _urlContentLbl = [[UILabel alloc] init];
        _urlContentLbl.text = @"";
        _urlContentLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _urlContentLbl.font = FONTN(16);
    }
    return _urlContentLbl;
}

- (UILabel *)httpCodeLbl {
    if (!_httpCodeLbl) {
        _httpCodeLbl = [[UILabel alloc] init];
        _httpCodeLbl.text = @"";
        _httpCodeLbl.tkThemetextColors = @[COLOR_00D971, COLOR_00D971_DARK];
        _httpCodeLbl.font = FONTN(16);
        _httpCodeLbl.textAlignment = NSTextAlignmentRight;
    }
    return _httpCodeLbl;
}

- (UILabel *)serverMsgLbl {
    if (!_serverMsgLbl) {
        _serverMsgLbl = [[UILabel alloc] init];
        _serverMsgLbl.text = @"";
        _serverMsgLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
        _serverMsgLbl.font = FONTN(12);
        _serverMsgLbl.numberOfLines = 0;
    }
    return _serverMsgLbl;
}

- (UILabel *)traceIdLbl {
    if (!_traceIdLbl) {
        _traceIdLbl = [[UILabel alloc] init];
        _traceIdLbl.text = @"";
        _traceIdLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
        _traceIdLbl.font = FONTN(12);
        _traceIdLbl.numberOfLines = 0;
    }
    return _traceIdLbl;
}

#pragma mark - other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
