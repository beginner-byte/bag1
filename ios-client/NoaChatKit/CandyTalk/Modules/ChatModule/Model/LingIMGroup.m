//
//  ZGroupInfoModel.m
//  NoaKit
//
//  Created by Candy on 2026/11/4.
//

#import "LingIMGroup.h"

@implementation LingIMGroup

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"groupMemberList":@"LingIMGroupMemberModel"};
}
@end
