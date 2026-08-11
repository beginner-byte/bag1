//
//  NoaMessageSendTask.h
//  NoaKit
//
//  Created by Candy on 2024/3/8.
//

#import <Foundation/Foundation.h>
#import "NoaFileUploadTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMessageSendTask : NSOperation

//要发送的消息
@property (nonatomic, strong) NSArray<NoaFileUploadTask *> * uploadTask;

@end

NS_ASSUME_NONNULL_END
