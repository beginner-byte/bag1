//
//  MImageBrowserVC.m
//  MiMaoApp
//
//  Created by Candy on 2020/10/13.
//  Copyright © 2020 MiMao. All rights reserved.
//

#import "MImageBrowserVC.h"
#import "MImageBrowserMacro.h"
#import "MImageBrowserManager.h"
#import "MImageBrowserZoomView.h"
#import "MImageBrowserGestureHandle.h"

//方向
typedef NS_ENUM(NSUInteger, ZoomViewScrollDirection) {
    ZoomViewScrollDirectionDefault,
    ZoomViewScrollDirectionLeft,
    ZoomViewScrollDirectionRight
};

@interface MImageBrowserVC () <UIScrollViewDelegate, MImageBrowserZoomViewDelegate, MImageBrowserGestureHandleDelegate>

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIView  *coverView;
@property (nonatomic, strong) UILabel  *lblPage;
@property (nonatomic, strong) UIButton *btnMore;//更多按钮
@property (nonatomic, assign) CGFloat lastScrollX;
@property (nonatomic, strong) NSMutableDictionary  *viewZoomCache;
@property (nonatomic, assign) ZoomViewScrollDirection direction;
@property (nonatomic, strong) MImageBrowserGestureHandle  *gestureHandle;

@end

@implementation MImageBrowserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configImageArr];
    [self setupView];
    [self setupGestureHandle];
    [self setupScrollView];
    [self loadImageAtIndex:_currentImageIndex];
    [self loadFirstImage];
    
    if (_customUIBlock) {
        _customUIBlock(self);
    }
}
#pragma mark - 处理imageArr内数据，统一成MImageBrowserModel
- (void)configImageArr{
    NSMutableArray *imagesArr = [NSMutableArray array];
    [_imageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MImageBrowserModel class]]) {
            [imagesArr addObject:obj];
            
        }else if ([obj isKindOfClass:[NSString class]]) {
            MImageBrowserModel *model = [MImageBrowserModel new];
            model.thumbURLString = (NSString *)obj;
            [imagesArr addObject:model];
            
        }else if ([obj isKindOfClass:[UIImage class]]) {
            MImageBrowserModel *model = [MImageBrowserModel new];
            model.image = (UIImage *)obj;
            [imagesArr addObject:model];
            
        }else if ([obj isKindOfClass:[NSDate class]]) {
            MImageBrowserModel *model = [MImageBrowserModel new];
            //model.imageData = (NSData *)obj;
            model.image = [UIImage imageWithData:obj];
            [imagesArr addObject:model];
        }
    }];
    
    _imageArr = [imagesArr copy];
}

#pragma mark - 界面布局
- (void)setupView{
    _coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    _coverView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_coverView];
    _coverView.alpha = 0;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat statusH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    _lblPage = [[UILabel alloc] initWithFrame:CGRectMake((screenW - 60) / 2.0, statusH, 60, 26)];
    _lblPage.textColor = [UIColor whiteColor];
    _lblPage.textAlignment = NSTextAlignmentCenter;
    _lblPage.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _lblPage.layer.cornerRadius = 13;
    _lblPage.layer.masksToBounds = YES;
    [self.view addSubview:_lblPage];
    
    //更多按钮
    _btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMore.frame = CGRectMake(screenW - 45, statusH - 5, 30, 30);
    [_btnMore setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
    _btnMore.layer.cornerRadius = 15;
    _btnMore.clipsToBounds = YES;
    [_btnMore setImage:[UIImage imageNamed:@"image_browser_more"] forState:UIControlStateNormal];
    [_btnMore addTarget:self action:@selector(btnMoreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnMore];
    _btnMore.hidden = !_showMoreBtn;
    
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGes:)];
    longPress.minimumPressDuration = 0.6;
    [_scrollView addGestureRecognizer:longPress];
}
#pragma mark - 更多按钮点击事件
- (void)btnMoreClick {
    if (_delegate && [_delegate respondsToSelector:@selector(imageBrowserMoreForIndex:)]) {
        [_delegate imageBrowserMoreForIndex:_currentImageIndex];
    }
}
- (void)longPressGes:(UILongPressGestureRecognizer *)gesture {
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        [self btnMoreClick];
    }
}
#pragma mark - 创建手势
- (void)setupGestureHandle{
    _gestureHandle = [[MImageBrowserGestureHandle alloc] initWithScrollView:_scrollView coverView:_coverView];
    _gestureHandle.delegate = self;
}

#pragma mark - 设置scrollView
- (void)setupScrollView{
    if (_currentImageIndex < 0 || _currentImageIndex >= _imageCount) {
        return;
    }
    
    CGFloat scrollW = _scrollView.frame.size.width;
    _scrollView.contentSize = CGSizeMake(scrollW * _imageCount, _scrollView.frame.size.height);
    _scrollView.contentOffset = CGPointMake(scrollW * _currentImageIndex, 0);
}

#pragma mark - 加载图片
- (void)loadImageAtIndex:(NSInteger)index{
    if (index == _currentImageIndex) {
        //改变指示标记
        _lblPage.text = [NSString stringWithFormat:@"%ld / %ld",_currentImageIndex + 1, _imageCount];
    }
    
    if (index > -1 && index < _imageCount && _imageCount - index <= _imageArr.count) {
        CGFloat scrollW = _scrollView.frame.size.width;
        CGRect frame = CGRectMake(index * scrollW, 0, scrollW, _scrollView.frame.size.height);
        MImageBrowserModel *model = [_imageArr objectAtIndex:index];
        MImageBrowserZoomView *viewZoom = [self.viewZoomCache objectForKey:[NSNumber numberWithInteger:index]];
        if (!viewZoom) {
            viewZoom = [[MImageBrowserZoomView alloc] initWithFrame:frame];
            viewZoom.zoomDelegate = self;
            viewZoom.frame = frame;
            [_scrollView addSubview:viewZoom];
            [self.viewZoomCache setObject:viewZoom forKey:[NSNumber numberWithInteger:index]];
        }
        [viewZoom resetScale];
        [viewZoom showImageWithModel:model];
    }
}

#pragma mark - 点击进入动画效果
- (void)loadFirstImage{
    CGRect startRect;
    UIImageView *imageView = nil;
    
    if (_delegate && [_delegate respondsToSelector:@selector(sourceImageViewForIndex:)]) {
        imageView = [_delegate sourceImageViewForIndex:_currentImageIndex];
    }else{
        [UIView animateWithDuration:MImageBrowserShowImageAnimationDuration delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:0 animations:^{
            self->_coverView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
        return;
    }
    
    startRect = [imageView.superview convertRect:imageView.frame toView:self.view];
    UIImage *image = imageView.image;
    if (!image) {
        return;
    }
    UIImageView *tempImageView = [UIImageView new];
    tempImageView.image = image;
    tempImageView.frame = startRect;
    [self.view addSubview:tempImageView];
    
    //目标frame
    CGRect targetRect;
    CGFloat imageWidthHeightRatio = image.size.width / (image.size.height * 1.0);
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat scrH = [UIScreen mainScreen].bounds.size.height;
    CGFloat height = width / imageWidthHeightRatio;
    CGFloat x = 0;
    CGFloat y;
    if (height > scrH) {
        y = 0;
    }else{
        y = (scrH - height) * 0.5;
    }
    targetRect = CGRectMake(x, y, width, height);
    
    _scrollView.hidden = YES;
    self.view.alpha = 1.f;
    
    [UIView animateKeyframesWithDuration:MImageBrowserShowImageAnimationDuration delay:0.f options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        tempImageView.frame = targetRect;
        self->_coverView.alpha = 1;
    } completion:^(BOOL finished) {
        [tempImageView removeFromSuperview];
        self.scrollView.hidden = NO;
    }];
    
}

#pragma mark - API方法
+ (instancetype)showImageBrowserWithImages:(NSArray *)imageArr currentImageIndex:(NSInteger)currentImageIndex{
    return [self showImageBrowserWithImages:imageArr currentImageIndex:currentImageIndex delegate:nil];
}

+ (instancetype)showImageBrowserWithImages:(NSArray *)imageArr currentImageIndex:(NSInteger)currentImageIndex delegate:(id<MImageBrowserVCDelegate> _Nullable)delegate{
    if (!imageArr || ![imageArr isKindOfClass:[NSArray class]] || imageArr.count < 1) {
        return nil;
    }
    
    if (currentImageIndex < 0) {
        currentImageIndex = 0;
    }
    
    MImageBrowserVC *vc = [MImageBrowserVC new];
    vc.imageArr = imageArr;
    vc.imageCount = imageArr.count;
    vc.currentImageIndex = currentImageIndex;
    vc.delegate = delegate;
    [ImageBrowserManager presentWindowWithController:vc];
    return vc;
}

- (void)dismissAnimation:(BOOL)animation{
    MImageBrowserZoomView *viewZoom = [_viewZoomCache objectForKey:[NSNumber numberWithInteger:_currentImageIndex]];
    [viewZoom dismissAnimation:animation];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _lastScrollX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    if (_lastScrollX < scrollView.contentOffset.x) {
        _direction = ZoomViewScrollDirectionRight;
    } else {
        _direction = ZoomViewScrollDirectionLeft;
    }
    NSUInteger page = (NSUInteger) (floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
    if (_currentImageIndex != page) {
        _currentImageIndex = page;
        [self loadImageAtIndex:_currentImageIndex];
    }
}

#pragma mark - MImageBrowserZoomViewDelegate
- (CGRect)dismissRect {
    CGRect dismissRect;
    UIImageView *imageView = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(sourceImageViewForIndex:)]) {
        imageView = [_delegate sourceImageViewForIndex:_currentImageIndex];
        if (!imageView) {
            return CGRectZero;
        }
    }else{
        return CGRectZero;
    }
    dismissRect = [imageView.superview convertRect:imageView.frame toView:self.view];
    return dismissRect;
}
- (UIImage *)zoomViewPlaceholderImage{
    if (_delegate && [_delegate respondsToSelector:@selector(imageBrowserPlaceholderImage)]) {
        UIImage *image = [_delegate imageBrowserPlaceholderImage];
        return image;
    }
    return nil;
}
#pragma mark - MImageBrowserGestureHandleDelegate
- (MImageBrowserZoomView *)currentDetailImageViewInImagePreview:(MImageBrowserGestureHandle *)handle {
    MImageBrowserZoomView *viewZoom = [_viewZoomCache objectForKey:[NSNumber numberWithInteger:_currentImageIndex]];
    return viewZoom;
}
- (void)detailImageViewDismiss {
    MImageBrowserZoomView *viewZoom = [_viewZoomCache objectForKey:[NSNumber numberWithInteger:_currentImageIndex]];
    [viewZoom dismissAnimation:YES];
}
- (void)imagePreviewComponmentHidden:(BOOL)hidden {
    _lblPage.hidden = hidden;
    _btnMore.hidden = hidden;
}

#pragma mark - 懒加载
- (NSMutableDictionary *)viewZoomCache{
    if (!_viewZoomCache) {
        _viewZoomCache = [NSMutableDictionary dictionary];
    }
    return _viewZoomCache;
}

#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
    // 停止当前可见动图播放，降低内存压力
    for (NSNumber *key in self.viewZoomCache) {
        MImageBrowserZoomView *zoom = [self.viewZoomCache objectForKey:key];
        if ([zoom respondsToSelector:@selector(imageView)]) {
            UIImageView *iv = [zoom valueForKey:@"imageView"];
            if ([iv isAnimating]) [iv stopAnimating];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
