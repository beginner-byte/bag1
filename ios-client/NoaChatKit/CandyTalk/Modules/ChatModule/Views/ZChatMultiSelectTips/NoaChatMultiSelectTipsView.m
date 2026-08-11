//
//  NoaChatMultiSelectTipsView.m
//  NoaKit
//
//  Created by Candy on 2023/4/18.
//

#import "NoaChatMultiSelectTipsView.h"
#import "NoaToolManager.h"
#import "NoaChatMultiSelectTipsCell.h"

@interface NoaChatMultiSelectTipsView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UIView *viewBg;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *lblContent;

@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray *toAvatarList;

@end

@implementation NoaChatMultiSelectTipsView

- (instancetype)initWithContent:(NSString *)content toAvatarList:(NSArray *)toAvatarList {
    self = [super init];
    if (self) {
        _content = content;
        _toAvatarList = toAvatarList;
        
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.tkThemebackgroundColors = @[[COLOR_00 colorWithAlphaComponent:0.3],[COLOR_00 colorWithAlphaComponent:0.6]];
    [CurrentWindow addSubview:self];
    
    _viewBg = [UIView new];
    _viewBg.alpha = 0;
    _viewBg.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _viewBg.layer.cornerRadius = DWScale(14);
    _viewBg.layer.masksToBounds = YES;
    [self addSubview:_viewBg];
    
    UILabel *lblSendTip = [UILabel new];
    lblSendTip.text = LanguageToolMatch(@"发送给");
    lblSendTip.tkThemetextColors = @[COLOR_11, COLORWHITE];
    lblSendTip.font = FONTB(18);
    [_viewBg addSubview:lblSendTip];
    [lblSendTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewBg).offset(DWScale(40));
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.height.mas_equalTo(DWScale(28));
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(DWScale(54), DWScale(44));
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    [_collectionView registerClass:[NoaChatMultiSelectTipsCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaChatMultiSelectTipsCell class])];
    [_viewBg addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lblSendTip.mas_bottom).offset(DWScale(16));
        make.leading.equalTo(lblSendTip);
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(44));
    }];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [btnCancel setTkThemeTitleColor:@[COLOR_66, COLORWHITE] forState:UIControlStateNormal];
    btnCancel.titleLabel.font = FONTR(17);
    btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F5F6F9_DARK];
    [btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateSelected];
    [btnCancel setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_EEEEEE],[UIImage ImageForColor:COLOR_EEEEEE_DARK]] forState:UIControlStateHighlighted];
    btnCancel.layer.cornerRadius = DWScale(22);
    btnCancel.layer.masksToBounds = YES;
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:btnCancel];
    
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSend setTitle:LanguageToolMatch(@"发送") forState:UIControlStateNormal];
    [btnSend setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    btnSend.titleLabel.font = FONTR(17);
    btnSend.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [btnSend setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [btnSend setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    btnSend.layer.cornerRadius = DWScale(22);
    btnSend.layer.masksToBounds = YES;
    [btnSend addTarget:self action:@selector(btnSendClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewBg addSubview:btnSend];
    
    _lblContent = [UILabel new];
    _lblContent.text = _content;
    _lblContent.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblContent.font = FONTR(14);
    _lblContent.preferredMaxLayoutWidth = DWScale(244);
    [_viewBg addSubview:_lblContent];
    [_lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.top.equalTo(_collectionView.mas_bottom).offset(DWScale(26));
        make.height.mas_equalTo(DWScale(22));
    }];
        
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewBg).offset(DWScale(20));
        make.top.equalTo(_lblContent.mas_bottom).offset(DWScale(26));
        make.size.mas_equalTo(CGSizeMake(DWScale(99), DWScale(44)));
        make.bottom.equalTo(_viewBg.mas_bottom).offset(-DWScale(40));
    }];
    
    [btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewBg).offset(-DWScale(20));
        make.centerY.equalTo(btnCancel);
        make.size.mas_equalTo(CGSizeMake(DWScale(146), DWScale(44)));
    }];
    
    [_viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(DWScale(295));
        make.top.equalTo(lblSendTip.mas_top).offset(-DWScale(30));
        make.bottom.equalTo(btnCancel.mas_bottom).offset(DWScale(30));
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _toAvatarList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatMultiSelectTipsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatMultiSelectTipsCell class]) forIndexPath:indexPath];
    cell.toUserDic = (NSDictionary *)[_toAvatarList objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - 交互事件
- (void)btnCancelClick {
    [self viewDismiss];
}

- (void)btnSendClick {
    if (self.sureClick) {
        self.sureClick();
    }
    [self viewDismiss];
}
- (void)viewShow {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.alpha = 1;
    }];
}
- (void)viewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewBg.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf.viewBg removeFromSuperview];
        weakSelf.viewBg = nil;
        [weakSelf removeFromSuperview];
    }];
}

@end
