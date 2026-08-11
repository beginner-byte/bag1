//
//  NoaChatTagModel.h
//  NoaKit
//
//  Created by Candy on 2023/7/21.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaChatTagModel : NoaBaseModel

@property (nonatomic, copy) NSString *dialog;
@property (nonatomic, copy) NSString *tagIcon;
@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, assign) NSInteger tagType;
@property (nonatomic, copy) NSString *tagUrl;
@property (nonatomic, assign) NSInteger localType;
@property (nonatomic, copy) NSString *ownerUId;


@end

NS_ASSUME_NONNULL_END
