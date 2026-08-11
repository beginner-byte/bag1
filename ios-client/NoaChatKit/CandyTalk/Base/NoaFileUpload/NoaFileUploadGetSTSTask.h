//
//  NoaFileUploadGetSTSTask.h
//  NoaKit
//
//  Created by Candy on 2024/8/23.
//

#import <Foundation/Foundation.h>
#import "NoaFileUploadTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaFileUploadGetSTSTask : NSOperation

@property (nonatomic, strong) NSArray<NoaFileUploadTask *> * uploadTask;

@end

NS_ASSUME_NONNULL_END
