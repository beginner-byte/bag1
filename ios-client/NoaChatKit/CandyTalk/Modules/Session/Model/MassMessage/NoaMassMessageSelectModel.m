//
//  NoaMassMessageSelectModel.m
//  NoaKit
//
//  Created by Candy on 2024/1/12.
//

#import "NoaMassMessageSelectModel.h"

@implementation NoaMassMessageSelectModel

-(void)setIsAllSelect:(bool)isAllSelect{
    if(self.list.count == 0){
        _isAllSelect = NO;
    }else{
        _isAllSelect = isAllSelect;
    }
}

@end
