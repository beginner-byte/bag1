//
//  NoaImagePickerVC.h
//  NoaKit
//
//  Created by Candy on 2026/10/9.
//

// 图片选择 VC

#import <UIKit/UIKit.h>
#import "NoaImagePickerManager.h"//相册管理类


NS_ASSUME_NONNULL_BEGIN
@protocol ZImagePickerVCDelegate <NSObject>
@optional
//直接去这个值即可IMAGEPICKER.zSelectedAssets
- (void)imagePickerVCSelected;
- (void)imagePickerClipImage:(UIImage *)resultImg localIdenti:(NSString *)localIdenti;
- (void)imagePickerVCCancel;//取消
@end

@interface NoaImagePickerVC : UIViewController

//自定义导航栏
@property (nonatomic, strong) UIView  *navView;//自定义导航栏
@property (nonatomic, strong) UIButton  *navBtnBack;//返回按钮
@property (nonatomic, strong) UIButton *navBtnRight;//右侧按钮
@property (nonatomic, strong) UILabel  *navTitleLabel;//标题
@property (nonatomic, strong) UIView  *navLineView;//线条
@property (nonatomic, copy) NSString *navTitleStr;//导航栏标题

@property (nonatomic, assign) NSInteger maxSelectNum;//最大选择图片
@property (nonatomic, assign) ZImagePickerType pickerType;//相册类型
@property (nonatomic, assign)BOOL hasCamera;//显示摄像头
@property (nonatomic, assign)BOOL isSignlePhoto;//是否是选择单张
@property (nonatomic, assign)BOOL isNeedEdit;//是否需要编辑图片(裁剪)

@property (nonatomic, weak) id <ZImagePickerVCDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
