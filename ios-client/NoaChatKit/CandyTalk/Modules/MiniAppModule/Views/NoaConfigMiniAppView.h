//
//  NoaConfigMiniAppView.h
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

//新增 / 编辑 小程序

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZConfigMiniAppType) {
    ZConfigMiniAppTypeAdd = 1,      //新增小程序
    ZConfigMiniAppTypeEdit = 2,     //编辑小程序
};

@protocol ZConfigMiniAppViewDelegate <NSObject>

//小程序创建成功回调
- (void)configMiniAppCreateWith:(LingIMMiniAppModel *)miniApp;

//小程序编辑成功回调
- (void)configMiniAppEditWith:(LingIMMiniAppModel *)miniApp;

@end

@interface NoaConfigMiniAppView : UIView

@property (nonatomic, weak) id <ZConfigMiniAppViewDelegate> delegate;

/// 小程序信息
@property (nonatomic, strong) LingIMMiniAppModel *miniAppModel;

/// 初始化
/// - Parameter configType: 配置类型
- (instancetype)initMiniAppWith:(ZConfigMiniAppType)configType;

/// 显示
- (void)configMiniAppShow;

/// 隐藏
- (void)configMiniAppDismiss;

@end

NS_ASSUME_NONNULL_END
