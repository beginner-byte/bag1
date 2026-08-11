//
//  NoaMiniAppWebVC.h
//  NoaKit
//
//  Created by Candy on 2023/7/18.
//

typedef NS_ENUM(NSUInteger, ZMiniAppWebVCType) {
    ZMiniAppWebVCTypeDefault = 0,      //通用占位
    ZMiniAppWebVCTypeMiniApp = 1,      //小程序
};

#import "NoaBaseWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMiniAppWebVC : NoaBaseWebViewController
@property (nonatomic, assign) ZMiniAppWebVCType webType;//类型
//小程序专用
@property (nonatomic, strong) NoaFloatMiniAppModel * floatMiniAppModel;
@end

NS_ASSUME_NONNULL_END
