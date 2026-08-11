//
//  NoaProxyInputView.h
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/16.
//

#import "NoaProxySettings.h"
NS_ASSUME_NONNULL_BEGIN

@interface NoaProxyInputView : UIView
@property (nonatomic, assign) ProxyType currentType;
@property (nonatomic, copy) void (^cancleCallback)(void);
- (void)show;
@end

NS_ASSUME_NONNULL_END
