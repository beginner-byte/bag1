//
//  NSData+Addition.m
//  NoaKit
//
//  Created by Candy on 2025/1/13.
//

#import "NSData+Addition.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (Addition)

#pragma mark - 将字符串base64加密成data
+ (NSData *)base64DataFromString:(NSString *)string {
  unsigned long ixtext, lentext;
  unsigned char ch, inbuf[4], outbuf[3];
  short i, ixinbuf;
  Boolean flignore, flendtext = false;
  const unsigned char *tempcstring;
  NSMutableData *theData;
  
  if (string == nil) {
    return [NSData data];
  }
  
  ixtext = 0;
  
  tempcstring = (const unsigned char *)[string UTF8String];
  
  lentext = [string length];
  
  theData = [NSMutableData dataWithCapacity: lentext];
  
  ixinbuf = 0;
  
  while (true) {
    if (ixtext >= lentext) {
      break;
    }
    
    ch = tempcstring [ixtext++];
    
    flignore = false;
    
    if ((ch >= 'A') && (ch <= 'Z')) {
      ch = ch - 'A';
    }
    else if ((ch >= 'a') && (ch <= 'z')) {
      ch = ch - 'a' + 26;
    }
    else if ((ch >= '0') && (ch <= '9')) {
      ch = ch - '0' + 52;
    }
    else if (ch == '+') {
      ch = 62;
    }
    else if (ch == '=') {
      flendtext = true;
    }
    else if (ch == '/') {
      ch = 63;
    }
    else {
      flignore = true;
    }
    
    if (!flignore) {
      short ctcharsinbuf = 3;
      Boolean flbreak = false;
      
      if (flendtext) {
        if (ixinbuf == 0) {
          break;
        }
        
        if ((ixinbuf == 1) || (ixinbuf == 2)) {
          ctcharsinbuf = 1;
        }
        else {
          ctcharsinbuf = 2;
        }
        
        ixinbuf = 3;
        
        flbreak = true;
      }
      
      inbuf [ixinbuf++] = ch;
      
      if (ixinbuf == 4) {
        ixinbuf = 0;
        
        outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
        outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
        outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
        
        for (i = 0; i < ctcharsinbuf; i++) {
          [theData appendBytes: &outbuf[i] length: 1];
        }
      }
      
      if (flbreak) {
        break;
      }
    }
  }
  
  return theData;
}

#pragma mark - Hex解密
+ (NSData *)hexDescodeWithStr:(NSString *)hexStr {
    NSMutableData *data = [NSMutableData data];
    int length = (int)[hexStr length];
       
    // 处理字符串长度必须是偶数
    if (length % 2 != 0) {
        return nil; // 或者抛出错误
    }

    for (int i = 0; i < length; i += 2) {
        NSString *byteString = [hexStr safeSubstringWithRange:NSMakeRange(i, 2)];
        unsigned int byteValue;
        [[NSScanner scannerWithString:byteString] scanHexInt:&byteValue];
        uint8_t byte = (uint8_t)byteValue;
        [data appendBytes:&byte length:1];
    }

    return data;
}

#pragma mark - MD5
- (NSString *)dataGetMD5Encry {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
       CC_MD5(self.bytes, (CC_LONG)self.length, digest);
       NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
       for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
           [output appendFormat:@"%02x", digest[i]];
       }
       return output;
}

#pragma mark - 随机长度数据
+ (NSData *)generateRandomIV:(NSUInteger)length {
    NSMutableData *ivData = [NSMutableData dataWithLength:length];
    int result = SecRandomCopyBytes(kSecRandomDefault, length, ivData.mutableBytes);
    
    if (result != errSecSuccess) {
        NSLog(@"❌ 生成随机IV失败: %d", result);
        return nil;
    }
    
    NSLog(@"✅ 生成随机IV成功: %lu字节", (unsigned long)length);
    return [ivData copy];
}


@end
