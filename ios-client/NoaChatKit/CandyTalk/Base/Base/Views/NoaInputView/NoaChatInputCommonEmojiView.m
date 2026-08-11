//
//  NoaChatInputCommonEmojiView.m
//  NoaKit
//
//  Created by Candy on 2023/6/28.
//

#import "NoaChatInputCommonEmojiView.h"
#import "NoaChatInputActionCell.h"
#import "NoaChatInputEmojiManager.h"

@interface NoaChatInputCommonEmojiView () <UICollectionViewDataSource, UICollectionViewDelegate, ZChatInputActionCellDelegate>
@property (nonatomic, strong) UICollectionView *emojiCollectionView;
@property (nonatomic, strong) NSMutableArray *emojiList;
@end

@implementation NoaChatInputCommonEmojiView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configCommonEmojiList];
        
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    
    self.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake((DScreenWidth - DWScale(32) - DWScale(176)) / 7.0, DWScale(40));
    layout.minimumLineSpacing = DWScale(20);//列间距
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, DWScale(28), DWScale(0), DWScale(28));
    
    _emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_emojiCollectionView registerClass:[NoaChatInputActionCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaChatInputActionCell class])];
    _emojiCollectionView.delegate = self;
    _emojiCollectionView.dataSource = self;
    _emojiCollectionView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
    _emojiCollectionView.layer.cornerRadius = DWScale(8);
    _emojiCollectionView.layer.masksToBounds = YES;
    [self addSubview:_emojiCollectionView];
    [_emojiCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(DScreenWidth - DWScale(32), DWScale(40)));
    }];
    
}
//配置常用表情列表
- (void)configCommonEmojiList {
    /*
     @{
         @"emojiName" : @"e-02_joy",
         @"en" : @"[laughing]",
         @"type" : @"0",
         @"zhCN" : @"[大笑]",
         @"zhTW" : @"[大笑]",
     }
     */
    _emojiList = [NSMutableArray array];
    
    NSArray *totalEmojiList = EMOJI.emojiList;
    //NSArray *commonEmojiList = @[@"e-02_joy", @"e-04_sweat_smile", @"e-23_sob", @"e-03_heart_eyes", @"e-07_yum", @"e-12_scream", @"e-14_smirk"];
    WeakSelf
    [totalEmojiList enumerateObjectsUsingBlock:^(RecentsEmojiModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.emojiName isEqualToString:@"e-02_joy"]) {
            [weakSelf.emojiList addObjectIfNotNil:obj];
        }else if ([obj.emojiName isEqualToString:@"e-04_sweat_smile"]) {
            [weakSelf.emojiList addObjectIfNotNil:obj];
        }else if ([obj.emojiName isEqualToString:@"e-23_sob"]) {
            [weakSelf.emojiList addObjectIfNotNil:obj];
        }else if ([obj.emojiName isEqualToString:@"e-03_heart_eyes"]) {
            [weakSelf.emojiList addObjectIfNotNil:obj];
        }else if ([obj.emojiName isEqualToString:@"e-07_yum"]) {
            [weakSelf.emojiList addObjectIfNotNil:obj];
        }else if ([obj.emojiName isEqualToString:@"e-12_scream"]) {
            [weakSelf.emojiList addObjectIfNotNil:obj];
        }else if ([obj.emojiName isEqualToString:@"e-14_smirk"]) {
            [weakSelf.emojiList addObjectIfNotNil:obj];
        }
        
        if (weakSelf.emojiList.count > 6) {
            *stop = YES;
        }
        
    }];

}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _emojiList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatInputActionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatInputActionCell class]) forIndexPath:indexPath];
    RecentsEmojiModel *emojiModel = (RecentsEmojiModel *)[_emojiList objectAtIndexSafe:indexPath.row];
    cell.ivAction.image = [UIImage imageNamed:emojiModel.emojiName];
    cell.cellIndex = indexPath;
    cell.delegate = self;
    [cell.ivAction mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(DWScale(24), DWScale(24)));
    }];
    return cell;
}

//#pragma mark - UICollectionViewDelegate
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//}

#pragma mark - ZChatInputActionCellDelegate
- (void)actionCellSelected:(NSIndexPath *)cellIndex {
    RecentsEmojiModel *emojiModel = (RecentsEmojiModel *)[_emojiList objectAtIndexSafe:cellIndex.row];
    //DLog(@"点击的表情:%@",emojiModel.emojiName);
    
    if (_delegate && [_delegate respondsToSelector:@selector(commonEmojiSelected:)]) {
        [_delegate commonEmojiSelected:emojiModel.zhCN];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
