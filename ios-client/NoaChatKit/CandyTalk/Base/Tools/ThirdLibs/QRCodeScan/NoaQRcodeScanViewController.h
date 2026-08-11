//
//  NoaQRcodeScanViewController.h
//  NoaKit
//
//  Created by Candy on 2023/4/3.
//

#import "CandyBaseViewController.h"
#import "Nav.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaQRcodeScanViewController : CandyBaseViewController

//是否是竞速扫码
@property (nonatomic, assign)BOOL isRacing;
//如果扫码结果为license类型，需要将扫码结果传递给SSO界面
@property (nonatomic, copy) void(^QRcodeSacnLicenseBlock)(NSString * _Nonnull liceseId, NSString * _Nonnull ipDomainPort);
@property (nonatomic, copy) void(^QRcodeSacnNavBlock)(IMServerListResponseBody *model, NSString * appKey);
@end

NS_ASSUME_NONNULL_END
