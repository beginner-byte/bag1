//
//  NoaMyMiniAppItem.m
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

#import "NoaMyMiniAppItem.h"
#import "NoaBaseImageView.h"

@interface NoaMyMiniAppItem ()

@property (nonatomic, strong) UIView *imgViewContainer;

@property (nonatomic, strong) UIImageView *ivMiniApp;

@property (nonatomic, strong) UIButton *btnDelete;

@property (nonatomic, strong) UILabel *lblMiniApp;

@property (nonatomic, strong) LingIMMiniAppModel *miniAppModel;

@end

@implementation NoaMyMiniAppItem

- (UIView *)imgViewContainer {
    if (!_imgViewContainer) {
        _imgViewContainer = [UIView new];
        _imgViewContainer.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
    }
    return _imgViewContainer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    [self.contentView addSubview:self.imgViewContainer];
    [self.imgViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@5);
        make.leading.equalTo(@10);
        make.trailing.equalTo(self.contentView).offset(-10);
        make.height.equalTo(self.imgViewContainer.mas_width);
    }];
    
    _ivMiniApp = [[UIImageView alloc] initWithFrame:CGRectZero];
    _ivMiniApp.contentMode = UIViewContentModeScaleAspectFit;
    [self.imgViewContainer addSubview:_ivMiniApp];
    [self.ivMiniApp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.imgViewContainer);
        make.width.height.equalTo(self.imgViewContainer);
    }];
    
    [self.imgViewContainer rounded:14 width:0.9 color:COLOR_5966F2];
    
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDelete.hidden = YES;
    [_btnDelete setImage:ImgNamed(@"mini_app_delete") forState:UIControlStateNormal];
    [self.contentView addSubview:_btnDelete];
    
    [_btnDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgViewContainer.mas_top);
        make.trailing.equalTo(self.imgViewContainer);
        make.size.equalTo(@(CGSizeMake(12, 12)));
    }];
    
    _lblMiniApp = [UILabel new];
    _lblMiniApp.tkThemetextColors = @[COLOR_00, COLOR_00_DARK];
    _lblMiniApp.font = FONTM(14);
    _lblMiniApp.textAlignment = NSTextAlignmentCenter;
    _lblMiniApp.text = LanguageToolMatch(@"添加");
    [self.contentView addSubview:_lblMiniApp];
    
    [_lblMiniApp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgViewContainer.mas_bottom).offset(4);
        make.leading.equalTo(@3);
        make.trailing.equalTo(self.contentView).offset(-3);
    }];
    
    @weakify(self)
    [[self.btnDelete rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self btnDeleteClick];
    }];
}

#pragma mark - 交互事件
- (void)btnDeleteClick {
    if (_miniAppModel && _delegate && [_delegate respondsToSelector:@selector(myMiniAppDelete:)]) {
        [_delegate myMiniAppDelete:self.baseCellIndexPath];
    }
}

#pragma mark - 界面赋值
- (void)configItemWith:(LingIMMiniAppModel *)miniAppModel manage:(BOOL)manageItem {
    _miniAppModel = miniAppModel;
    if (miniAppModel) {
        [self.ivMiniApp mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.imgViewContainer);
            make.width.height.equalTo(self.imgViewContainer);
        }];
        [self.imgViewContainer rounded:14 width:0.9 color:HEXCOLOR(@"D8D9FF")];
        [self.ivMiniApp sd_setImageWithURL:[miniAppModel.qaAppPic getImageFullUrl] placeholderImage:ImgNamed(@"mini_app_icon") options:SDWebImageAllowInvalidSSLCertificates];
        _lblMiniApp.text = miniAppModel.qaName;
        if(manageItem){
            if(miniAppModel.allowUserDelete){
                _btnDelete.hidden = !manageItem;
            }else{
                _btnDelete.hidden = YES;
            }
        }else{
            _btnDelete.hidden = !manageItem;
        }
    }else {
        _ivMiniApp.image = ImgNamed(@"mini_app_add_blue");
        _lblMiniApp.text = LanguageToolMatch(@"添加");
        _btnDelete.hidden = YES;
        [self.imgViewContainer rounded:14 width:0.9 color:COLOR_5966F2];
        [self.ivMiniApp mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.imgViewContainer);
            make.width.height.equalTo(@12);
        }];
    }
}

@end
