//
//  NoaJoinGroupModel.m
//  NoaKit
//
//  Created by Candy on 2023/4/7.
//

#import "NoaJoinGroupModel.h"

@implementation NoaJoinGroupMemberModel

@end

@implementation NoaJoinGroupInfoModel

@end


@implementation NoaJoinGroupModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"groupMemberList":@"NoaJoinGroupMemberModel"};
}



@end
