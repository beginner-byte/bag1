//
//  NoaLameTool.h
//  NoaKit
//
//  Created by Candy on 2023/1/28.
//

/** 将录音生成的 .caf文件转换成 .mp3 文件*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaLameTool : NSObject

//cafFilePath为caf文件本地地址，mp3FilePath为要保存mp3文件的本地地址
//+ (BOOL)audioPCMtoMP3:(NSString *)cafFilePath mp3FilePath:(NSString *)mp3FilePath;

//录完再转码的方法, 如果录音时间比较长的话,会要等待几秒...
+ (void)conventToMp3WithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                           callback:(void(^)(BOOL result))callback;

@end

NS_ASSUME_NONNULL_END
