//
//  NoaTrustedDeviceCell.h
//  CandyTalk
//
//  Created by Codex on 2026/8/9.
//

#import <UIKit/UIKit.h>

@class NoaTrustedDeviceModel;

NS_ASSUME_NONNULL_BEGIN

/// 信任设备列表单元格，负责展示平台、IP、活跃时间、异常状态和剔除操作。
@interface NoaTrustedDeviceCell : UITableViewCell

/// 当前单元格展示的设备模型。
@property (nonatomic, strong, nullable) NoaTrustedDeviceModel *deviceModel;
/// 用户点击剔除按钮时回传当前设备；当前设备不会触发该回调。
@property (nonatomic, copy, nullable) void (^revokeDeviceBlock)(NoaTrustedDeviceModel *device);

@end

NS_ASSUME_NONNULL_END
