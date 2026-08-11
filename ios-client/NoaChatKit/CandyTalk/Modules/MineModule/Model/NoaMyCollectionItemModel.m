//
//  NoaMyCollectionItemModel.m
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaMyCollectionItemModel.h"

@implementation NoaMyCollectionBodyModel

@end


@implementation NoaMyCollectionItemModel

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    if ([property.name isEqualToString:@"body"]) {
        if (oldValue) {
            NoaMyCollectionBodyModel *body = [NoaMyCollectionBodyModel mj_objectWithKeyValues:oldValue];
            return body;
        }
    }
    return oldValue;
}

@end
