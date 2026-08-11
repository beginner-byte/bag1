//
//  NoaMassMessageSelectModel.h
//  NoaKit
//
//  Created by Candy on 2024/1/12.
//

#import "NoaBaseModel.h"
#import "NoaBaseUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMassMessageSelectModel : NoaBaseModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<NoaBaseUserModel *> *list;
@property (nonatomic, assign) bool isOpen;
@property (nonatomic, assign) bool isAllSelect;
@end

NS_ASSUME_NONNULL_END
