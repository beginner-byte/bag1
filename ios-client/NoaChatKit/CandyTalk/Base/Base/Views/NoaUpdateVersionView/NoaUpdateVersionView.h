//
//  NoaUpdateVersionView.h
//  NoaKit
//
//  Created by Candy on 2023/3/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaUpdateVersionView : UIView

//是否强制更新(只显示 "立即跟新" 按钮，并且点击后 更新弹窗不消失)
@property (nonatomic, assign)BOOL isCompelUpdate;
@property (nonatomic, copy)NSString *versionNumStr;
@property (nonatomic, copy)NSString *storeUrl;
@property (nonatomic, copy)NSString *updateDes;

- (void)updateVersionViewShow;
- (void)updateVersionViewDismiss;

@end

NS_ASSUME_NONNULL_END
