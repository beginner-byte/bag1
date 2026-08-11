//
//  NoaChatInputEmojiView.m
//  NoaKit
//
//  Created by Candy on 2026/10/12.
//

#import "NoaChatInputEmojiView.h"
#import "NoaChatInputEmojiHeaderView.h"

@interface NoaChatInputEmojiView () <UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *emojiCollection;
@property (nonatomic, strong) NSMutableArray *emojiList;

@property (nonatomic, strong) UIButton *btnDelete;
@property (nonatomic, strong) UIButton *btnSend;

@end

@implementation NoaChatInputEmojiView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tkThemebackgroundColors = @[COLOR_F2F3F5, COLOR_11];
        //self.emojiList = [EMOJI.emojiList mutableCopy];
        
        NSArray *allEmojiList = [EMOJI.emojiList mutableCopy];
        NSArray *lastUseEmojiList = [DBTOOL getMyRecentsEmojiList];
        
        BOOL matchVersion = [EMOJI.version isEqualToString:[[MMKV defaultMMKV] getStringForKey:@"emojiVersion"]];
        
        if (lastUseEmojiList.count <= 0 || !matchVersion) {
            lastUseEmojiList = [[allEmojiList subarrayWithRange:NSMakeRange(0, 7)] mutableCopy];
            [DBTOOL batchInsertRecentsEmojiModelWith:lastUseEmojiList];
            [[MMKV defaultMMKV] setString:EMOJI.version forKey:@"emojiVersion"];
        }
        
        NSDictionary *lastUseDic = @{@"title":LanguageToolMatch(@"最近使用"),@"emojiArr":lastUseEmojiList};
        NSDictionary *allEmojiDic = @{@"title":LanguageToolMatch(@"全部表情"), @"emojiArr":allEmojiList};
        
        [self.emojiList addObject:lastUseDic];
        [self.emojiList addObject:allEmojiDic];
        
        [self setupUI];
        
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupUI {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat itemW = DScreenWidth / 7.0;
    layout.itemSize = CGSizeMake(itemW, itemW);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    //layout.headerReferenceSize = CGSizeMake(DScreenWidth, DWScale(30));
    //layout.footerReferenceSize = CGSizeMake(DScreenWidth, DWScale(50));
    
    _emojiCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(258)) collectionViewLayout:layout];
    _emojiCollection.delegate = self;
    _emojiCollection.dataSource = self;
    _emojiCollection.backgroundColor = [UIColor clearColor];
    _emojiCollection.pagingEnabled = NO;
    _emojiCollection.showsVerticalScrollIndicator = NO;
    [_emojiCollection registerClass:[NoaChatInputEmojiCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaChatInputEmojiCell class])];
    [_emojiCollection registerClass:[NoaChatInputEmojiHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier"];
    [_emojiCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerIdentifier"];
    [self addSubview:_emojiCollection];
    
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnDelete setImage:[UIImage imageNamed:@"input_emoji_delete"] forState:UIControlStateNormal];
    _btnDelete.frame = CGRectMake(DScreenWidth - DWScale(76), DWScale(258) - DWScale(8) - DWScale(44), DWScale(60), DWScale(44));
    [_btnDelete addTarget:self action:@selector(btnDeleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnDelete];
    
    
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.emojiList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *emojiDic = (NSDictionary *)[self.emojiList objectAtIndex:section];
    NSArray *emojiContetnList = (NSArray *)[emojiDic objectForKey:@"emojiArr"];
    return  emojiContetnList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatInputEmojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatInputEmojiCell class]) forIndexPath:indexPath];
    NSDictionary *emojiDic = (NSDictionary *)[self.emojiList objectAtIndex:indexPath.section];
    NSArray *emojiContetnList = (NSArray *)[emojiDic objectForKey:@"emojiArr"];
    RecentsEmojiModel *emoji = (RecentsEmojiModel *)[emojiContetnList objectAtIndex:indexPath.row];
    cell.ivEmoji.image = [UIImage imageNamed:emoji.emojiName];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(DScreenWidth, DWScale(30));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if (section == (self.emojiList.count - 1)) {
        return CGSizeMake(DScreenWidth, DWScale(50));
    } else {
        return CGSizeMake(DScreenWidth, 0);
    }
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *emojiDic = (NSDictionary *)[self.emojiList objectAtIndex:indexPath.section];
    NSArray *emojiContetnList = (NSArray *)[emojiDic objectForKey:@"emojiArr"];
    RecentsEmojiModel *emoji = (RecentsEmojiModel *)[emojiContetnList objectAtIndex:indexPath.row];
    DLog(@"点击的表情:%@",emoji);
    if (_delegate && [_delegate respondsToSelector:@selector(inputEmojiViewSelected:)]) {
        [_delegate inputEmojiViewSelected:emoji.zhCN];
    }
    
    BOOL result = [DBTOOL insertOrUpdateRecentsEmojiModelWith:emoji];
    if (result) {
        NSArray *lastUseEmojiList = [DBTOOL getMyRecentsEmojiList];
        NSDictionary *lastUseDic = @{@"title":LanguageToolMatch(@"最近使用"),@"emojiArr":lastUseEmojiList};
        [self.emojiList replaceObjectAtIndex:0 withObject:lastUseDic];
        [_emojiCollection reloadSections:[[NSIndexSet alloc] initWithIndex:0]];
    }
    
    /*
     @{
         "emojiName" = "e-05_laughing",
         "en" = "[laughing]",
         "type" = 0,
         "zhCN" = "[大笑]",
         "zhTW" = "[大笑]",
     }
     */
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NoaChatInputEmojiHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier" forIndexPath:indexPath];
        
        NSDictionary *emojiDic = (NSDictionary *)[self.emojiList objectAtIndex:indexPath.section];
        NSString *titleString = (NSString *)[emojiDic objectForKey:@"title"];
        headerView.titleStr = titleString;
        
        return headerView;
    }
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        //if (indexPath.section == (self.emojiList.count - 1)) {
            UICollectionReusableView *viewFooter = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerIdentifier" forIndexPath:indexPath];
            viewFooter.backgroundColor = UIColor.clearColor;
            return viewFooter;
//        } else {
//            return nil;
//        }
    }
    return nil;
}

#pragma mark - 交互事件
- (void)btnDeleteClick {
    if (_delegate && [_delegate respondsToSelector:@selector(inputEmojiViewDelete)]) {
        [_delegate inputEmojiViewDelete];
    }
}


#pragma mark - Lazy
- (NSMutableArray *)emojiList {
    if (!_emojiList) {
        _emojiList = [[NSMutableArray alloc] init];
    }
    return _emojiList;
}

@end

@implementation NoaChatInputEmojiCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivEmoji = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    _ivEmoji.center = self.contentView.center;
    [self.contentView addSubview:_ivEmoji];
}
@end
