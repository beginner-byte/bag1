//
//  groupSetDorpView.m
//  NoaKit
//
//  Created by Candy on 2024/2/17.
//

#import "groupSetDorpView.h"
#import "NoaTranslateChannelLanguageModel.h"

@interface groupSetDorpView()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property(nonatomic, assign)ZGroupNoticeTranslateType translateType;
@property(nonatomic, copy)NSString *channelCode;
@property(nonatomic, strong)NSMutableArray *selectedItemsCode;
@property(nonatomic, strong)NSMutableArray *selectedItemsName;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic ,strong)UIActivityIndicatorView *activityView;

@end


@implementation groupSetDorpView

- (instancetype)initWithTranslateType:(ZGroupNoticeTranslateType)translateType channelCode:(NSString *)channelCode selectedItemsCode:(NSArray *)selectedItemsCode selectedItemsName:(NSArray *)selectedItemsName {
    self = [super init];
    if (self) {
        _translateType = translateType;
        _channelCode = channelCode;
        _selectedItemsCode = [NSMutableArray arrayWithArray:selectedItemsCode];
        _selectedItemsName = [NSMutableArray arrayWithArray:selectedItemsName];
        _isShow = YES;
        [self setupUI];
        [self setupData];
    }
    return self;
}

- (void)dropViewDismiss {
    [self removeFromSuperview];
    self.isShow = NO;
}

- (void)setupData {
    if (_translateType == ZGroupNoticeTranslateTypeChannel) {
        //请求通道
        [self requestGetTranslateChannel];
    }
    if (_translateType == ZGroupNoticeTranslateTypeLanguage) {
        //请求语种
        [self requestGetTranslateLanguage];
    }
}

- (void)setupUI {
    self.backgroundColor = COLOR_CLEAR;
    [self shadow:COLOR_11 opacity:0.15 radius:5 offset:CGSizeMake(0, 0)];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self addSubview:self.activityView];
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.mas_equalTo(DWScale(25));
    }];
}

- (void)setCurrentChannelCode:(NSString *)currentChannelCode {
    _currentChannelCode = currentChannelCode;
    _channelCode = _currentChannelCode;
    [self.tableView reloadData];
}

- (void)setCurrentLanguageCodeList:(NSArray *)currentLanguageCodeList {
    _currentLanguageCodeList = currentLanguageCodeList;
    [_selectedItemsCode removeAllObjects];
    [_selectedItemsCode addObjectsFromArray:_currentLanguageCodeList];
}

- (void)setCurrentLanguageNameList:(NSArray *)currentLanguageNameList {
    _currentLanguageNameList = currentLanguageNameList;
    [_selectedItemsName removeAllObjects];
    [_selectedItemsName addObjectsFromArray:_currentLanguageNameList];
    [self.tableView reloadData];
}

#pragma mark - Request
//请求翻译通道数据
- (void)requestGetTranslateChannel {
    self.activityView.hidden = NO;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:ZLanguageTOOL.currentLanguage.languageAbbr forKey:@"currentLang"];
    
    WeakSelf
    [IMSDKManager imSdkTranslateGetChannelLanguage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        weakSelf.activityView.hidden = YES;
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *dataArr = (NSArray *)data;
            weakSelf.dataList = [NoaTranslateChannelLanguageModel mj_objectArrayWithKeyValuesArray:dataArr];
            [weakSelf.tableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        weakSelf.activityView.hidden = YES;
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//请求支持的语种数据
- (void)requestGetTranslateLanguage {
    self.activityView.hidden = NO;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_channelCode forKey:@"channelCode"];
    [dict setValue:ZLanguageTOOL.currentLanguage.languageAbbr forKey:@"currentLang"];
    
    WeakSelf
    [IMSDKManager imSdkTranslateGetChannelLanguage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        weakSelf.activityView.hidden = YES;
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *dataArr = (NSArray *)data;
            NSArray *dataList = [NoaTranslateChannelLanguageModel mj_objectArrayWithKeyValuesArray:dataArr];
            for (NoaTranslateChannelLanguageModel *model in dataList) {
                if ([model.channelId isEqualToString:weakSelf.channelCode]) {
                    weakSelf.dataList = [model.lang_table mutableCopy];
                    [weakSelf.tableView reloadData];
                }
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        weakSelf.activityView.hidden = YES;
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(38);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    groupSetDorpCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([groupSetDorpCell class]) forIndexPath:indexPath];
    if (_translateType == ZGroupNoticeTranslateTypeChannel) {
        NoaTranslateChannelLanguageModel *model = (NoaTranslateChannelLanguageModel *)[self.dataList objectAtIndexSafe:indexPath.row];
        cell.itemTitleStr = model.name;
        cell.statusImgView.image = ImgNamed(@"icon_selected_blue");
        if ([_channelCode isEqual:model.channelId]) {
            cell.statusImgView.hidden = NO;
        } else {
            cell.statusImgView.hidden = YES;
        }
    }
    if (_translateType == ZGroupNoticeTranslateTypeLanguage) {
        NoaTranslateLanguageModel *model = (NoaTranslateLanguageModel *)[self.dataList objectAtIndexSafe:indexPath.row];
        cell.itemTitleStr = model.name;
        cell.statusImgView.hidden = NO;
        if ([_selectedItemsCode containsObject:model.slug]) {
            cell.statusImgView.image = ImgNamed(@"c_select_yes");
        } else {
            cell.statusImgView.image = ImgNamed(@"c_select_no");
        }
    }
    cell.baseCellIndexPath = indexPath;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_translateType == ZGroupNoticeTranslateTypeChannel) {
        NoaTranslateChannelLanguageModel *model = (NoaTranslateChannelLanguageModel *)[self.dataList objectAtIndexSafe:indexPath.row];
        if (self.channelSelectedBlock) {
            self.channelSelectedBlock(model.channelId, model.name);
        }
        [self dropViewDismiss];
    }
    if (_translateType == ZGroupNoticeTranslateTypeLanguage) {
        NoaTranslateLanguageModel *model = (NoaTranslateLanguageModel *)[self.dataList objectAtIndexSafe:indexPath.row];
        if ([_selectedItemsCode containsObject:model.slug]) {
            if ([model.slug isEqualToString:@"en"]) {
                return;
            } else {
                [_selectedItemsCode removeObject:model.slug];
                [_selectedItemsName removeObject:model.name];
            }
        } else {
            if (_selectedItemsCode.count >= 15) {
                [HUD showMessage:LanguageToolMatch(@"最多可选15个语种")];
                return;
            }
            [_selectedItemsCode addObject:model.slug];
            [_selectedItemsName addObject:model.name];
        }
        if (self.languageSelectedBlock) {
            self.languageSelectedBlock(_selectedItemsCode, _selectedItemsName);
        }
        [self.tableView reloadData];
    }
}

#pragma mark - Lazy
- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = COLOR_CLEAR;
        _tableView.delaysContentTouches = NO;
        [_tableView rounded:DWScale(4)];
        _tableView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        
        [_tableView registerClass:[groupSetDorpCell class] forCellReuseIdentifier:NSStringFromClass([groupSetDorpCell class])];
    }
    return _tableView;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _activityView.hidden = YES;
    }
    return _activityView;
}

@end



@implementation groupSetDorpCell

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
    [self.contentView addSubview:self.contentLbl];
    [self.contentView addSubview:self.statusImgView];
    
    [self.statusImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView).offset(-DWScale(12));
        make.width.height.mas_equalTo(DWScale(16));
    }];
    
    [self.contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(DWScale(12));
        make.centerY.equalTo(self.contentView);
        make.trailing.mas_equalTo(self.statusImgView.mas_leading).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(28));
    }];
}

- (void)setItemTitleStr:(NSString *)itemTitleStr {
    _itemTitleStr = itemTitleStr;
    
    self.contentLbl.text = _itemTitleStr;
}

-(UILabel * )contentLbl{
    if(!_contentLbl){
        _contentLbl = [[UILabel alloc] init];
        _contentLbl.font = FONTR(14);
        _contentLbl.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    }
    return _contentLbl;
}

-(UIImageView *)statusImgView {
    if(!_statusImgView){
        _statusImgView = [[UIImageView alloc] init];
    }
    return _statusImgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
