//
//  NoaChatMessageMoreView.m
//  NoaKit
//
//  Created by Candy on 2026/9/28.
//

#import "NoaChatMessageMoreView.h"
#import "NoaToolManager.h"

@interface NoaChatMessageMoreView () <ZChatMessageMoreItemViewDelegate>

@property (nonatomic, assign) CGRect targetRect;
@property (nonatomic, assign) BOOL isFromMy;
@property (nonatomic, assign) BOOL isBottom;
@property (nonatomic, assign) CGSize msgContentSize;
@property (nonatomic, strong) NSArray *menuArr;
@property (nonatomic, strong) NoaChatMessageMoreItemView *viewMoreItem;
@property (nonatomic, strong) UIImageView *arrowImgView;

@end

@implementation NoaChatMessageMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (instancetype)initWithMenu:(NSArray *)menuArr targetRect:(CGRect)targetRect isFromMy:(BOOL)isFromMy isBottom:(BOOL)isBottom msgContentSize:(CGSize)msgContentSize; {
    self = [super init];
    if (self) {
        _targetRect = targetRect;
        _isFromMy = isFromMy;
        _menuArr = menuArr;
        _isBottom = isBottom;
        _msgContentSize = msgContentSize;
        
        self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
        self.backgroundColor = COLOR_CLEAR;
        [CurrentVC.view addSubview:self];
        
        //背景点击关闭事件
        UIControl *backAction = [[UIControl alloc] initWithFrame:self.bounds];
        [backAction addTarget:self action:@selector(hiddenMenuView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backAction];
        
        //显示菜单
        [self showMoreItemView];
    }
    return self;
}

#pragma mark - 界面布局
- (void)showMoreItemView {
    BOOL arrowIsTop = YES;
    //根据转换后cell在View的坐标，确定menu弹窗的frame
    CGFloat menuViewWidth = _menuArr.count > 5 ? DWScale(300) : DWScale(60) * _menuArr.count;
    // 计算实际需要的行数（每行5个，向上取整）
    NSInteger rowCount = (NSInteger)ceil(_menuArr.count / 5.0);
    // 根据行数动态计算高度：每行高度56，上下内边距各6，总共12，加上箭头区域10
    CGFloat menuViewHeight = DWScale(56) * rowCount + DWScale(12);

    CGFloat menuViewX = _isFromMy ? (_targetRect.origin.x + _msgContentSize.width + 20 - menuViewWidth) : _targetRect.origin.x;
    CGFloat menuViewY;
    if (_isBottom) {
        arrowIsTop = NO;
        menuViewY = _targetRect.origin.y - (menuViewHeight - (_targetRect.size.height - _msgContentSize.height - 18 - 10)) - 3;
    } else {
        menuViewY = _targetRect.origin.y + _targetRect.size.height;
        arrowIsTop = YES;
        if ((menuViewY + menuViewHeight) > DScreenHeight) {
            arrowIsTop = NO;
            menuViewY = _targetRect.origin.y - (menuViewHeight - (_targetRect.size.height - _msgContentSize.height - 18 - 10)) - 3;
        }
    }
   
    //菜单View
    _viewMoreItem = [[NoaChatMessageMoreItemView alloc] initWithFrame:CGRectMake(menuViewX, menuViewY, menuViewWidth, menuViewHeight + 10)];
    _viewMoreItem.menuArr = _menuArr;
    _viewMoreItem.delegate = self;
    [self addSubview:_viewMoreItem];
    [_viewMoreItem resetFrameToFitRTL];

    CGFloat arrowImgX = _isFromMy ? (menuViewWidth - (_msgContentSize.width+18)/2 - 18/2) : (_msgContentSize.width+18)/2 - 18/2;
    //防止三角形箭头超出弹窗范围
    if (arrowImgX < 30 || arrowImgX > menuViewWidth - 30) {
        if (_isFromMy) {
            arrowImgX = menuViewWidth - 30;
        } else {
            arrowImgX = 30;
        }
    }
    
    CGFloat arrowImgY = arrowIsTop ? 0.5 : (menuViewHeight - 3);
    _arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(arrowImgX, arrowImgY, 18, 10)];
    _arrowImgView.image = arrowIsTop ? ImgNamed(@"c_more_arrow_up.png") : ImgNamed(@"c_more_arrow_down.png");
    [_viewMoreItem addSubview:_arrowImgView];
    [_arrowImgView resetFrameToFitRTL];

}

#pragma mark - ZChatMessageMoreItemViewDelegate
- (void)menuItemViewSelectedAction:(MessageMenuItemActionType)actionType {
    if (self.menuClick) {
        self.menuClick(actionType);
    }
    [self hiddenMenuView];
}

//关闭菜单弹窗
- (void)hiddenMenuView {
    [self removeFromSuperview];
}
/// 动态更新菜单项
- (void)updateMenuItems:(NSArray *)menuArr {
    _menuArr = menuArr;
    if (_viewMoreItem) {
        // 先更新菜单项数组，这会触发 setMenuArr: 方法，自动更新内部高度
        _viewMoreItem.menuArr = _menuArr;
        
        // 重新计算菜单尺寸（基于更新后的实际高度）
        CGFloat menuViewWidth = _menuArr.count > 5 ? DWScale(300) : DWScale(60) * _menuArr.count;
        // 计算实际需要的行数（每行5个，向上取整）
        NSInteger rowCount = (NSInteger)ceil(_menuArr.count / 5.0);
        // 根据行数动态计算高度：每行高度56，上下内边距各6，总共12，加上箭头区域10
        CGFloat menuViewHeight = DWScale(56) * rowCount + DWScale(12);
        CGFloat menuViewX = _isFromMy ? (_targetRect.origin.x + _msgContentSize.width + 20 - menuViewWidth) : _targetRect.origin.x;
        CGFloat menuViewY;
        BOOL arrowIsTop = YES;
        if (_isBottom) {
            arrowIsTop = NO;
            menuViewY = _targetRect.origin.y - (menuViewHeight - (_targetRect.size.height - _msgContentSize.height - 18 - 10)) - 3;
        } else {
            menuViewY = _targetRect.origin.y + _targetRect.size.height;
            arrowIsTop = YES;
            if ((menuViewY + menuViewHeight) > DScreenHeight) {
                arrowIsTop = NO;
                menuViewY = _targetRect.origin.y - (menuViewHeight - (_targetRect.size.height - _msgContentSize.height - 18 - 10)) - 3;
            }
        }
        
        // 更新菜单视图的frame（使用更新后的高度）
        _viewMoreItem.frame = CGRectMake(menuViewX, menuViewY, menuViewWidth, menuViewHeight + 10);
        
        // 更新箭头位置
        CGFloat arrowImgX = _isFromMy ? (menuViewWidth - (_msgContentSize.width+18)/2 - 18/2) : (_msgContentSize.width+18)/2 - 18/2;
        if (arrowImgX < 30 || arrowImgX > menuViewWidth - 30) {
            if (_isFromMy) {
                arrowImgX = menuViewWidth - 30;
            } else {
                arrowImgX = 30;
            }
        }
        CGFloat arrowImgY = arrowIsTop ? 0.5 : (menuViewHeight - 3);
        _arrowImgView.frame = CGRectMake(arrowImgX, arrowImgY, 18, 10);
        _arrowImgView.image = arrowIsTop ? ImgNamed(@"c_more_arrow_up.png") : ImgNamed(@"c_more_arrow_down.png");
    }
}

@end
