//
//  NoaClipImageVC.h
//  NoaKit
//
//  Created by Candy on 2026/11/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//@class ZClipImageVC;
@protocol ZClipImageVCDelegate <NSObject>

- (void)clipImageDidFinishedWithImage:(UIImage *)image;

@end

@interface NoaClipImageVC : UIViewController

//自定义导航栏
@property (nonatomic, strong) UIView  *navView;//自定义导航栏
@property (nonatomic, strong) UIButton  *navBtnBack;//返回按钮
@property (nonatomic, strong) UIButton *navBtnRight;//右侧按钮
@property (nonatomic, copy) NSString *navTitleStr;//导航栏标题
//裁剪的图片
@property(nonatomic,strong)UIImage *image;
//裁剪区域
@property(nonatomic,assign)CGSize cropSize;
//是否裁剪成圆形
@property(nonatomic,assign)BOOL isRound;

@property (nonatomic, weak) id <ZClipImageVCDelegate> delegate;

@end



NS_ASSUME_NONNULL_END
