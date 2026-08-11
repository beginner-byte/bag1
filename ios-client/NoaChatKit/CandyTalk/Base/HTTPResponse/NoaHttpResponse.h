//
//  NoaHttpResponse.h
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//未绑定阅译账号
#define Translate_yuuee_unbind_error_code       40056
//阅译账号余额不足
#define Translate_yuuee_no_balance_code         40422
//绑定yuee账号时，如果账号绑定了，不可以再被绑定，一对一，必须解绑后重新绑定
#define Translate_yuuee_not_bind_code           40058   //此账号已被绑定

//消息转发失败
#define NetWork_Error_Friend_Delete             41032    //双方不是好友关系
#define NetWork_Error_Friend_Blacklist          900018   //用户已经被拉黑
#define NetWork_Error_Friend_BeBlacklist        900019   //你已经被拉黑

#define NetWork_Error_Group_Single_ShutDown     41051    //群组已封禁
#define NetWork_Error_Group_Nonentity           41052    //群组已解散
#define NetWork_Error_Group_Not_In              41003    //您已不在当前群组
#define NetWork_Error_Group_All_Silent          41045    //群组已开启全员禁言
#define NetWork_Error_Group_Single_Silent       41046    //用户已被禁言
#define NetWork_Error_Group_Interval            41000    //消息发送间隔
#define NetWork_Error_Group_Number_Limit        52001    //转发数量超过限制


@interface NoaHttpResponse : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) id data;
@property (nonatomic, copy) NSString *traceId;
@property (nonatomic, assign) BOOL isHttpSuccess;//是否成功

- (id)responseData;
- (void)setResponseData:(id)data;
- (id)responseDataDescryptWithDataString:(id)data url:(NSString *)url; //返回数据解密

@end

NS_ASSUME_NONNULL_END
