//
//  NoaEncryptManager.h
//  NoaKit
//
//  Created by Apple on 2023/9/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaEncryptManager : NSObject
@property (nonatomic, assign) EncryptType encryptType;
#pragma mark - 单例的实现
+ (instancetype)shareEncryManager;

// 解密
-(NSData*)decrypt:(NSData*)data;

#pragma mark - 当对大文件进行加密时，会导致内存快速飙升，除非iOS系统内存告警并可能出现闪退，所以加密采用下面的方法
- (NSData *)encryptFileToData:(NSData *)plainData
                                error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
