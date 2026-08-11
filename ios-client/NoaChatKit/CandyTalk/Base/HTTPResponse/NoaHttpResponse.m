//
//  NoaHttpResponse.m
//  NoaKit
//
//  Created by Candy on 2026/9/13.
//

#import "NoaHttpResponse.h"
#import "LXChatEncrypt.h"

@interface NoaHttpResponse ()
{
    id _responseData;
}
@end

@implementation NoaHttpResponse

- (BOOL)isHttpSuccess {
    return _code == ZHttpRequestCodeTypeSuccess;
}

- (id)responseData {
    return _responseData;
}

- (void)setResponseData:(id)data {
    _responseData = data;
}

#pragma mark - 接口返回的data解密处理
- (id)responseDataDescryptWithDataString:(id)data url:(NSString *)url {
    if ([data isKindOfClass:[NSString class]]) {
        NSString *dataString = (NSString *)data;
        BOOL dataStringIsJson = [self isValidJsonString:dataString];
        //如果 dataString 是一个有效Json
        if(dataStringIsJson) {
            id jsonObj = [self jsonObjectFromString:dataString];
            return jsonObj;
        }else{
            //对 dataString 尝试解密
            NSString *descryptDataStr;
            if ([url containsString:@"system/v2/getSystemConfig"]) {
                descryptDataStr = [LXChatEncrypt method6:dataString];
            } else {
                descryptDataStr = [LXChatEncrypt method7:[IMSDKManager tenantCode] encryptData:dataString];
            }
            if(descryptDataStr == nil){
                //解密失败
                return dataString;
            }else{
                //解密成功
                BOOL descryptDataStrIsJson = [self isValidJsonString:descryptDataStr];
                if(descryptDataStrIsJson){
                    id descryptObj = [self jsonObjectFromString:descryptDataStr];
                    return descryptObj;
                }else{
                    return descryptDataStr;
                }
            }
        }
    } else {
        return data;
    }
}

-(BOOL)isValidJsonString:(NSString *)str{
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return NO;
    }
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:&error];
    return (jsonObject != nil && error == nil);
}

-(id)jsonObjectFromString:(NSString *)jsonString{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        NSLog(@"Error: Unable to convert string to NSData");
        return nil;
    }
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return nil;
    }
    
    return jsonObject;
}


@end
