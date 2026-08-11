//
//  NoaTeamDetailModel.m
//  NoaKit
//
//  Created by phl on 2025/7/31.
//

#import "NoaTeamDetailModel.h"
#import "NSObject+MJKeyValue.h"

@implementation NoaTeamDetailModel

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues {
    self.shareLink = [self handleShareQrcodeUrl];
}

/// 根据registerHtml组装生成二维码的url
/**
 邀请码示例：xxx/xxx.html?code=123&server=123456&type=1&userId=12313123123123123123213&userName=小小张
 直连示例：xxx/xxx.html?code=3q24&server=http%3A%2F%2Fwww.baidu.com&type=2&userId=12313123123123123123213&userName=小小张 */
- (NSString *)handleShareQrcodeUrl {
    // 下载链接
    NSString *html = [NSString isNil:self.registerHtml] ? @"" : self.registerHtml;
    
    // 邀请码
    NSString *inviteCode = [NSString isNil:self.inviteCode] ? @"" : self.inviteCode;
    if (html.length > 0) {
        //code
        NSMutableString *qrcodeUrl = [NSMutableString stringWithString:html];
        [qrcodeUrl appendString:@"?code="];
        [qrcodeUrl appendString:inviteCode];
        //server
        NSString *netUrlStr = @"--";
        NoaSsoInfoModel *ssoModel = [NoaSsoInfoModel getSSOInfo];
        if (ssoModel) {
            if (![NSString isNil:ssoModel.liceseId]) {
                netUrlStr = ssoModel.liceseId;
            }
            if (![NSString isNil:ssoModel.ipDomainPortStr]) {
                netUrlStr = ssoModel.ipDomainPortStr;
            }
        }
        //最后四位用****做脱敏处理
        netUrlStr = [netUrlStr stringByReplacingCharactersInRange:NSMakeRange(netUrlStr.length - 4, 4) withString:@"****"];
        [qrcodeUrl appendString:@"&server="];
        [qrcodeUrl appendString:netUrlStr];
        //userName
        [qrcodeUrl appendString:@"&userName="];
        [qrcodeUrl appendString:UserManager.userInfo.nickname ? UserManager.userInfo.nickname : @""];
        
        return qrcodeUrl;
    } else {
        return @"";
    }
}

@end
