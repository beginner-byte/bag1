//
//  NoaIntergralDetailCell.m
//  NoaKit
//
//  Created by Candy on 2024/1/9.
//

#import "NoaIntergralDetailCell.h"

@interface NoaIntergralDetailCell()

@property (nonatomic, strong) UILabel *handleDateLbl;//操作时间
@property (nonatomic, strong) UILabel *handleTypeLbl;//操作类型
@property(nonatomic,strong) UILabel *IntergralLbl;//积分

@end

@implementation NoaIntergralDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}

#pragma mark - UI
-(void)setupUI{
    
    UIImageView * tipImgView = [[UIImageView alloc] init];
    tipImgView.image = ImgNamed(@"signLogoicon");
    [self.contentView addSubview:tipImgView];
    [tipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(DWScale(16));
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(DWScale(30), DWScale(30)));
    }];
    
    [self.contentView addSubview:self.handleDateLbl];
    [self.handleDateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(tipImgView.mas_trailing).offset(DWScale(8));
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo((DScreenWidth - DWScale(16 + 30 + 8)) / 3);
        make.height.mas_equalTo(DWScale(18));
    }];
    
    
    [self.contentView addSubview:self.handleTypeLbl];
    [self.handleTypeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.handleDateLbl.mas_trailing);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo((DScreenWidth - DWScale(16 + 30 + 8)) / 3);
        make.height.mas_equalTo(DWScale(18));
    }];
    
   
    [self.contentView addSubview:self.IntergralLbl];
    [self.IntergralLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.handleTypeLbl.mas_trailing);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo((DScreenWidth - DWScale(16 + 30 + 8)) / 3);
        make.height.mas_equalTo(DWScale(18));
    }];
}

- (void)setIntergralDetailDict:(NSDictionary *)intergralDetailDict {
    if (intergralDetailDict) {
        _intergralDetailDict = intergralDetailDict;
        
        long long handleTime = [[_intergralDetailDict objectForKeySafe:@"createTime"] longLongValue];
        long long intergralNum = [[_intergralDetailDict objectForKeySafe:@"money"] longLongValue];
        NSInteger handleType = [[_intergralDetailDict objectForKeySafe:@"opeType"] integerValue];
        
        self.handleDateLbl.text = [NSDate transTimeStrToDateMethod3:handleTime];
        //操作类型 9: 签到 18: 系统扣减
        if (handleType == 9) {
            //签到
            self.handleTypeLbl.text = LanguageToolMatch(@"签到");
            self.IntergralLbl.tkThemetextColors = @[COLOR_5966F2, COLOR_5966F2];
            self.IntergralLbl.text = [NSString stringWithFormat:@"+%lld", intergralNum];
        } else if (handleType == 18) {
            //系统扣减
            self.handleTypeLbl.text = LanguageToolMatch(@"系统扣减");
            self.IntergralLbl.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333];
            self.IntergralLbl.text = [NSString stringWithFormat:@"-%lld", intergralNum];
        } else if (handleType == 19) {
            //系统清除
            self.handleTypeLbl.text = LanguageToolMatch(@"系统清除");
            self.IntergralLbl.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333];
            self.IntergralLbl.text = [NSString stringWithFormat:@"-%lld", intergralNum];
        }  else {
            //其他
            self.handleTypeLbl.text = LanguageToolMatch(@"其他");
            self.IntergralLbl.tkThemetextColors = @[COLOR_66, COLOR_99];
            self.IntergralLbl.text = [NSString stringWithFormat:@"%lld", intergralNum];
        }
    }
}

#pragma mark - Lazy
- (UILabel *)handleDateLbl {
    if (!_handleDateLbl) {
        _handleDateLbl = [[UILabel alloc] init];
        _handleDateLbl.tkThemetextColors = @[COLOR_66, COLOR_99];
        _handleDateLbl.font = FONTR(12);
    }
    return _handleDateLbl;
}

- (UILabel *)handleTypeLbl {
    if (!_handleTypeLbl) {
        _handleTypeLbl = [[UILabel alloc] init];
        _handleTypeLbl.text = @"";
        _handleTypeLbl.textAlignment = NSTextAlignmentCenter;
        _handleTypeLbl.tkThemetextColors = @[COLOR_66, COLOR_99];
        _handleTypeLbl.font = FONTR(12);
    }
    return _handleTypeLbl;
}

- (UILabel *)IntergralLbl {
    if (!_IntergralLbl) {
        _IntergralLbl = [[UILabel alloc] init];
        _IntergralLbl.text = @"";
        _IntergralLbl.textAlignment = NSTextAlignmentCenter;
        _IntergralLbl.textColor = HEXCOLOR(@"4791FF");
        _IntergralLbl.font = FONTR(12);
    }
    return _IntergralLbl;
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
