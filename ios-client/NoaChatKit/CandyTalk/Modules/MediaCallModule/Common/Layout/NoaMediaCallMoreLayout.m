//
//  NoaMediaCallMoreLayout.m
//  NoaKit
//
//  Created by Candy on 2023/2/13.
//

#import "NoaMediaCallMoreLayout.h"

@interface NoaMediaCallMoreLayout ()
@property (nonatomic, strong) NSMutableArray *attributesArray;//cell布局属性数组
@property (nonatomic, assign) NSInteger itemCount;
@end

@implementation NoaMediaCallMoreLayout
#pragma mark - 1.准备布局
- (void)prepareLayout {
    
    //cell个数
    _itemCount = [self.collectionView numberOfItemsInSection:0];
    //cell属性数组
    [self configAttributesArray];
}
#pragma mark - 2.计算滚动范围
- (CGSize)collectionViewContentSize {
    CGFloat H;
   if (_itemCount <= 9) {
        H = DScreenWidth;
   } else {
       NSInteger hang = _itemCount / 3;
       H = (hang + 1) * (DScreenWidth / 3.0);
   }
    return CGSizeMake(DScreenWidth, H);
}
#pragma mark - 3.cell布局赋值给UI
- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributesArray;
}
#pragma mark - 4.计算每个cell的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *itemAttr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger columnCount = 2;//列数
    CGFloat itemW = (DScreenWidth - DWScale(4)) / 2.0;//item宽度
    if (_itemCount > 4) {
        columnCount = 3;
        itemW = (DScreenWidth - DWScale(4)) / 3.0;
    }
    
    CGFloat itemCenterX;
    CGFloat itemCenterY;
    NSInteger itemColumn = indexPath.row % columnCount;//item位于第几列
    NSInteger itemRow = indexPath.row / columnCount;//item位于第几行
    if (indexPath.row == 2 && _itemCount == 3) {
        itemCenterX = (DScreenWidth - DWScale(4)) / 2.0;
        itemCenterY = itemW * 1.5;
    }else {
        itemCenterX = (itemColumn + 0.5) * itemW + DWScale(2);
        itemCenterY = (itemRow + 0.5) * itemW;
    }
    itemAttr.size = CGSizeMake(itemW, itemW);
    itemAttr.center = CGPointMake(itemCenterX, itemCenterY);
    
    return itemAttr;
}

#pragma mark - 配置cell布局属性数组数据
- (void)configAttributesArray {
    [self.attributesArray removeAllObjects];
    
    for (NSInteger i = 0; i < _itemCount; i++) {
        //如果item数目过大，容易造成内存峰值提高
        @autoreleasepool {
            NSIndexPath *itemIndex = [NSIndexPath indexPathForItem:i inSection:0];
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:itemIndex];
            [self.attributesArray addObject:attrs];
        }
    }
}
#pragma mark - 懒加载
- (NSMutableArray *)attributesArray {
    if (!_attributesArray) {
        _attributesArray = [NSMutableArray array];
    }
    return _attributesArray;
}
@end
