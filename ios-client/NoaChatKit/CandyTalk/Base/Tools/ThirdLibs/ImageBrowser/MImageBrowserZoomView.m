//
//  MImageBrowserZoomView.m
//  MiMaoApp
//
//  Created by Candy on 2020/10/13.
//  Copyright © 2020 MiMao. All rights reserved.
//

#import "MImageBrowserZoomView.h"
#import "MImageBrowserMacro.h"
#import "MImageBrowserManager.h"
#import <SDWebImage/SDAnimatedImageView.h>
#import <SDWebImage/SDAnimatedImageView+WebCache.h>
#import <SDWebImage/SDWebImage.h>

@interface MImageBrowserZoomView ()
@property (nonatomic, strong) MImageBrowserModel  *model;
@property (nonatomic, strong) SDAnimatedImageView  *imageView;
@property (nonatomic, strong) UIButton  *btnOrigin;

@property (nonatomic, strong) UIActivityIndicatorView  *activityIndicator;

@end

@implementation MImageBrowserZoomView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageState = ShowImageStateSmall;
        
        [self setupView];
        [self addGestures];
    }
    return self;
}

#pragma mark - 界面布局
- (void)setupView{
    self.directionalLockEnabled = YES;
    self.minimumZoomScale = 1.f;
    self.maximumZoomScale = 3.f;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.delegate = self;
    
    CGFloat imageViewW = [UIScreen mainScreen].bounds.size.width - 2 * 60;
    _imageView = [[SDAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewW, imageViewW)];
    _imageView.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    _imageView.userInteractionEnabled = YES;
    [self addSubview:_imageView];
    
    _btnOrigin = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnOrigin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnOrigin.titleLabel.font = [UIFont boldSystemFontOfSize:12.f];
    _btnOrigin.layer.masksToBounds = YES;
    _btnOrigin.layer.borderWidth = 1.f;
    _btnOrigin.layer.cornerRadius = 4.f;
    _btnOrigin.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _btnOrigin.hidden = YES;
    [self addSubview:_btnOrigin];
    [_btnOrigin addTarget:self action:@selector(downloadOriginImage) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)addGestures{
    //添加双击手势
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDoubleClick:)];
    tapDouble.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapDouble];
    
    //添加单击手势
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSingleClick:)];
    tapSingle.numberOfTapsRequired = 1;
    tapSingle.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapSingle];
    
    [tapSingle requireGestureRecognizerToFail:tapDouble];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

// 缩放小于1的时候，始终让其在中心点位置进行缩放
- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - API方法
- (void)resetScale{
    [self setZoomScale:1.f animated:NO];
}

- (void)showImageWithModel:(MImageBrowserModel *)model{
    if (model) {
        __weak typeof(self) weakSelf = self;
        
        _model = model;
        
        [self setupDownloadButton];
        
        UIImage *placeholderImage = nil;
        if ([_zoomDelegate respondsToSelector:@selector(zoomViewPlaceholderImage)]) {
            placeholderImage = [_zoomDelegate zoomViewPlaceholderImage];
        }
        
        //是否有原图缓存
        BOOL hasOriginImageCache = [[SDImageCache sharedImageCache] cachePathForKey:model.originURLString].length > 0;
        if (model.originURLString && hasOriginImageCache) {
            //有原图地址 + 缓存
            [_imageView sd_setImageWithURL:[NSURL URLWithString:model.originURLString]
                          placeholderImage:placeholderImage
                                   options:(SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates | SDWebImageHighPriority)
                                 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    [weakSelf becomeBigStateImage:weakSelf.imageView.image animation:YES];
                    self->_imageState = ShowImageStateOrigin;
                    weakSelf.btnOrigin.hidden = YES;
                }
            }];
            
        }else if (model.thumbURLString) {
            //加载普通图片
            BOOL hasThumbImageCache = [[SDImageCache sharedImageCache] cachePathForKey:model.thumbURLString].length > 0;
            if (!hasThumbImageCache) {
                [_activityIndicator startAnimating];
            }
            [_imageView sd_setImageWithURL:[NSURL URLWithString:model.thumbURLString]
                          placeholderImage:placeholderImage
                                   options:(SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates | SDWebImageHighPriority)
                                 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                [weakSelf.activityIndicator stopAnimating];
                if (image) {
                    self -> _imageState = ShowImageStateBig;
                    [weakSelf becomeBigStateImage:weakSelf.imageView.image animation:YES];
                }
            }];
            
        }else if (model.image || model.imageData) {
            //加载图片数据
            if (model.imageData) {
                SDAnimatedImage *animated = [SDAnimatedImage imageWithData:model.imageData];
                _imageView.image = animated ?: [UIImage imageWithData:model.imageData];
            } else {
                _imageView.image = model.image;
            }
            [self becomeBigStateImage:_imageView.image animation:YES];
            _imageState = ShowImageStateBig;
            
        }else{
            _imageView.image = placeholderImage;
            [self becomeBigStateImage:_imageView.image animation:YES];
            _imageState = ShowImageStateBig;
        }
        
    }else{
        if ([_zoomDelegate respondsToSelector:@selector(zoomViewPlaceholderImage)]) {
            _imageView.image = [_zoomDelegate zoomViewPlaceholderImage];
        }
    }
    
}

#pragma mark - 辅助函数
// 根据双击位置计算放大范围
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGFloat height = self.frame.size.height / scale;
    CGFloat width  = self.frame.size.width / scale;
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    return CGRectMake(x, y, width, height);
}

// 设置 下载原图 按钮
- (void)setupDownloadButton{
    if (_model.originURLString) {
        _btnOrigin.hidden = NO;
        NSString *title = [NSString stringWithFormat:LanguageToolMatch(@" 查看原图(%.1fM) "),_model.originImageSize / 1024.0 / 1024.0];
        [_btnOrigin setTitle:title forState:UIControlStateNormal];
        [_btnOrigin sizeToFit];
        CGPoint center = _btnOrigin.center;
        center.x = [UIScreen mainScreen].bounds.size.width * 0.5;
        _btnOrigin.center = center;
        CGRect frame = _btnOrigin.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - 10 - frame.size.height;
        _btnOrigin.frame = frame;
    }
    
    BOOL hasOriginImageCache = [[SDImageCache sharedImageCache] cachePathForKey:_model.originURLString].length > 0;
    if (_model.originURLString && hasOriginImageCache) {
        //图片有原图地址 + 原图有缓存
        _btnOrigin.hidden = NO;
    }else if (_model.originURLString) {
        //图片有原图地址 + 无缓存
        _btnOrigin.hidden = NO;
    }else{
        _btnOrigin.hidden = YES;
    }
}

//大图状态动画
- (void)becomeBigStateImage:(UIImage *)image animation:(BOOL)animation{
    if (animation) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:MImageBrowserShowImageAnimationDuration delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:0 animations:^{
            [weakSelf setupImageView:image];
        } completion:^(BOOL finished) {
        }];
    }else{
        [self setupImageView:image];
    }
}

//图片展示
- (void)setupImageView:(UIImage *)image{
    if (!image) return;
    
    CGFloat scrW = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = scrW / image.size.width;
    CGSize size = CGSizeMake(scrW, image.size.height * scale);
    CGFloat y = MAX(0., (self.frame.size.height - size.height) / 2.f);
    CGFloat x = MAX(0., (self.frame.size.width - size.width) / 2.f);
    [self.imageView setFrame:CGRectMake(x, y, size.width, size.height)];
    [self.imageView setImage:image];
    self.contentSize = CGSizeMake(self.bounds.size.width, size.height);
}

//消失动画
- (void)dismissAnimation:(BOOL)animation{
    __block CGRect toFrame;
    if ([self.zoomDelegate respondsToSelector:@selector(dismissRect)]) {
        toFrame = [self.zoomDelegate dismissRect];
        if (CGRectEqualToRect(toFrame, CGRectZero) || CGRectEqualToRect(toFrame, CGRectNull)) {
            animation = NO;
        }
    }
    
    if (animation) {
        if (_imageView.image) {
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            [UIView animateWithDuration:MImageBrowserShowImageAnimationDuration delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:0 animations:^{
                self->_imageView.frame = CGRectMake(toFrame.origin.x+self.contentOffset.x, toFrame.origin.y+self.contentOffset.y, toFrame.size.width, toFrame.size.height);
            } completion:^(BOOL finished) {
            }];
        }
    }
    
    [ImageBrowserManager dismissWindow:YES];
}

#pragma mark - 交互事件
//原图下载
- (void)downloadOriginImage{
    
    UIImage *placeholderImage = nil;
    if ([self.zoomDelegate respondsToSelector:@selector(zoomViewPlaceholderImage)]) {
        placeholderImage = [self.zoomDelegate zoomViewPlaceholderImage];
    }
    
    [self.activityIndicator startAnimating];
    __weak typeof(self) weakSelf = self;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_model.originURLString] placeholderImage:placeholderImage options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [weakSelf.activityIndicator stopAnimating];
        weakSelf.btnOrigin.hidden = YES;
    }];
}

//双击手势
- (void)tapDoubleClick:(UITapGestureRecognizer *)gesture{
    if (_imageState > ShowImageStateSmall) {
        if (self.zoomScale != 1.0) {
            //还原
            [self setZoomScale:1.f animated:YES];
        }else{
            //放大
            CGPoint point = [gesture locationInView:gesture.view];
            CGFloat touchX = point.x;
            CGFloat touchY = point.y;
            touchX *= 1 / self.zoomScale;
            touchY *= 1 / self.zoomScale;
            touchX += self.contentOffset.x;
            touchY += self.contentOffset.y;
            CGRect zoomRect = [self zoomRectForScale:2.f withCenter:CGPointMake(touchX, touchY)];
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}

//单击手势
- (void)tapSingleClick:(UIPanGestureRecognizer *)gesture{
    [self dismissAnimation:YES];
}

#pragma mark - 懒加载
- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.center = CGPointMake(self.frame.size.width*0.5, self.frame.size.height*0.5);
        [self addSubview:_activityIndicator];
        _activityIndicator.tintColor = [UIColor grayColor];
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
