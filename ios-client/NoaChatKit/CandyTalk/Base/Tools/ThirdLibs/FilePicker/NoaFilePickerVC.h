//
//  NoaFilePickerVC.h
//  NoaKit
//
//  Created by Candy on 2023/1/4.
//

#import <UIKit/UIKit.h>
#import "NoaFilePickModel.h"//文件model

NS_ASSUME_NONNULL_BEGIN

@interface NoaFilePickerVC : UIViewController

//自定义导航栏
@property (nonatomic, strong) UIView  *navView;//自定义导航栏
@property (nonatomic, strong) UIButton  *navBtnBack;//返回按钮
@property (nonatomic, strong) UIButton *navBtnRight;//右侧按钮
@property (nonatomic, strong) UIButton  *navTitleBtn;//标题按钮
@property (nonatomic, strong) UIView  *navLineView;//线条
@property (nonatomic, copy) NSString *navTitleStr;//导航栏标题

@property (nonatomic, copy) NSString *sessionFoldPath;  //对应会话的本地文件类型数据保存目录
//直接选择的 手机储存的文件
@property (nonatomic, copy) void(^savePhoneFileSuccess)(NoaFilePickModel *selectFileModel);
//直接选择的 App中的文件或者相册视频
@property (nonatomic, copy) void(^saveLingXinFileSuccess)(NSArray *selectFileArr);

@end

NS_ASSUME_NONNULL_END
