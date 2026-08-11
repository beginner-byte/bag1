//
//  NoaChatMessageMoreItemView.m
//  NoaKit
//
//  Created by Candy on 2026/9/29.
//

#import "NoaChatMessageMoreItemView.h"
#import "NoaChatMessageMoreItem.h"

@interface NoaChatMessageMoreItemView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation NoaChatMessageMoreItemView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
        [self setupUI];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(DWScale(59), DWScale(56));
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(DWScale(6), 0, DWScale(6), 0);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, self.width, self.height - 10) collectionViewLayout:layout];
    _collectionView.tkThemebackgroundColors = @[COLOR_00, COLOR_00];
    _collectionView.layer.cornerRadius = DWScale(14);
    _collectionView.layer.masksToBounds = YES;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[NoaChatMessageMoreItem class] forCellWithReuseIdentifier:NSStringFromClass([NoaChatMessageMoreItem class])];
    [self addSubview:_collectionView];
}

#pragma mark - 数据赋值
- (void)setMenuArr:(NSArray *)menuArr {
    _menuArr = menuArr;
    
    // 计算实际需要的行数（每行5个，向上取整）
    NSInteger rowCount = (NSInteger)ceil(menuArr.count / 5.0);
    // 根据行数动态计算高度：每行高度56，上下内边距各6，总共12
    CGFloat collectionViewHeight = DWScale(56) * rowCount + DWScale(12);
    // 更新整个 view 的高度（collectionView 高度 + 箭头区域10）
    self.height = collectionViewHeight + 10;
    // 更新 collectionView 的 frame（确保宽度和高度都正确）
    _collectionView.frame = CGRectMake(0, 10, self.width, collectionViewHeight);
    // 禁用滚动，让所有内容都能显示
    _collectionView.scrollEnabled = NO;

    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _menuArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatMessageMoreItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatMessageMoreItem class]) forIndexPath:indexPath];
    NSDictionary *dict = [self getMsgMenuItemDataWithType:[[_menuArr objectAtIndexSafe:indexPath.row] integerValue]];
    cell.ivImage.image = ImgNamed([dict objectForKeySafe:@"imageName"]);
    cell.lblTitle.text = [dict objectForKeySafe:@"titleName"];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MessageMenuItemActionType clickMenuType = [[_menuArr objectAtIndexSafe:indexPath.row] integerValue];
    if (_delegate && [_delegate respondsToSelector:@selector(menuItemViewSelectedAction:)]) {
        [_delegate menuItemViewSelectedAction:clickMenuType];
    }
}

#pragma mark - 根据类型 获取对应菜单的图标和标题
- (NSDictionary *)getMsgMenuItemDataWithType:(MessageMenuItemActionType)menuType {
    switch (menuType) {
        case MessageMenuItemActionTypeCopy:
            return @{
                @"titleName" : LanguageToolMatch(@"复制"),
                @"imageName" : @"c_more_copy"
            };
            break;
        case MessageMenuItemActionTypeCopyContent:
            return @{
                @"titleName" : LanguageToolMatch(@"复制原文"),
                @"imageName" : @"c_more_copy"
            };
            break;
        case MessageMenuItemActionTypeCopyTranslate:
            return @{
                @"titleName" : LanguageToolMatch(@"复制译文"),
                @"imageName" : @"c_more_copy_translate"
            };
            break;
        case MessageMenuItemActionTypeForward:
            return @{
                @"titleName" : LanguageToolMatch(@"转发"),
                @"imageName" : @"c_more_forward"
            };
            break;
        case MessageMenuItemActionTypeDelete:
            return @{
                @"titleName" : LanguageToolMatch(@"删除"),
                @"imageName" : @"c_more_delete"
            };
            break;
        case MessageMenuItemActionTypeRevoke:
            return @{
                @"titleName" : LanguageToolMatch(@"撤回"),
                @"imageName" : @"c_more_revoke"
            };
            break;
        case MessageMenuItemActionTypeReference:
            return @{
                @"titleName" : LanguageToolMatch(@"引用"),
                @"imageName" : @"c_more_reference"
            };
            break;
        case MessageMenuItemActionTypeCollection:
            return @{
                @"titleName" : LanguageToolMatch(@"收藏"),
                @"imageName" : @"c_more_collection"
            };
            break;
        case MessageMenuItemActionTypeMultiSelect:
            return @{
                @"titleName" : LanguageToolMatch(@"多选"),
                @"imageName" : @"c_more_multi_select"
            };
            break;
        case MessageMenuItemActionTypeAddTag:
            return @{
                @"titleName" : LanguageToolMatch(@"存为"),
                @"imageName" : @"c_more_url_tag"
            };
            break;
        case MessageMenuItemActionTypeShowTranslate:
            return @{
                @"titleName" : LanguageToolMatch(@"翻译"),
                @"imageName" : @"c_more_translate"
            };
            break;
        case MessageMenuItemActionTypeHiddenTranslate:
            return @{
                @"titleName" : LanguageToolMatch(@"隐藏译文"),
                @"imageName" : @"c_more_hidden_translate"
            };
            break;
        case MessageMenuItemActionTypeStickersAdd:
            return @{
                @"titleName" : LanguageToolMatch(@"添加"),
                @"imageName" : @"c_more_stickers_add"
            };
            break;
        case MessageMenuItemActionTypeStickersPackage:
            return @{
                @"titleName" : LanguageToolMatch(@"表情包"),
                @"imageName" : @"c_more_stickers_package"
            };
            break;
        case MessageMenuItemActionTypeMutePlayback:
            return @{
                @"titleName" : LanguageToolMatch(@"听筒播放"),
                @"imageName" : @"c_more_mute_playback"
            };
            break;
        case MessageMenuItemActionTypeGroupTop:
            return @{
                @"titleName" : LanguageToolMatch(@"置顶"),
                @"imageName" : @"c_more_group_top"
            };
            break;
        case MessageMenuItemActionTypeGroupTopCancel:
            return @{
                @"titleName" : LanguageToolMatch(@"取消置顶"),
                @"imageName" : @"c_more_group_cancel_top"
            };
            break;
        case MessageMenuItemActionTypeSingleTop:
            return @{
                @"titleName" : LanguageToolMatch(@"置顶"),
                @"imageName" : @"c_more_group_top"
            };
            break;
        case MessageMenuItemActionTypeSingleTopCancel:
            return @{
                @"titleName" : LanguageToolMatch(@"取消置顶"),
                @"imageName" : @"c_more_group_cancel_top"
            };
            break;
        case MessageMenuItemActionTypeEdit:
            return @{
                @"titleName" : LanguageToolMatch(@"编辑"),
                @"imageName" : @"c_more_message_edit"
            };
            break;
        default:
            return @{
                @"titleName" : @"",
                @"imageName" : @""
            };

            break;
    }
}

@end
