//
//  NoaImageUploadModel.h
//  NoaKit
//
//  Created by Candy on 2026/10/24.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaFileUploadModel : NoaBaseModel

@property (nonatomic, copy) NSString *buckerName;       //桶名称
@property (nonatomic, copy) NSString *fileName;         //文件名称
@property (nonatomic, copy) NSString *name;             //文件原始名称
@property (nonatomic, assign)long long size;            //文件大小
@property (nonatomic, copy) NSString *thumbnailUri;     //缩略图uri
@property (nonatomic, copy) NSString *thumbnailUrl;     //缩略图url
@property (nonatomic, copy) NSString *type;             //文件类型
@property (nonatomic, copy) NSString *uri;              //uri
@property (nonatomic, copy) NSString *url;              //url


@end

NS_ASSUME_NONNULL_END
