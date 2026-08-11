//
//  NoaGroupNoteLocalUserNameModel.m
//  NoaKit
//
//  Created by phl on 2025/8/12.
//  继承于ZGroupNoteModel类，增加字段，主要是用于根据noticeCreateUid字段，从本地缓存中查询出用户名称，并展示

#import "NoaGroupNoteLocalUserNameModel.h"

@implementation NoaGroupNoteLocalUserNameModel

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)mj_didConvertToObjectWithKeyValues:(NSDictionary *)keyValues {
    // 根据noticeCreateUid字段，从本地缓存中查询出用户名称
    if ([self.noticeCreateUid isEqualToString:UserManager.userInfo.userUID]) {
        // 当前用户为自己
        self.localCacheUserName = UserManager.userInfo.nickname;
    }else {
        // 非自己，判断是否是好友，如果不是，默认展示创建用户的昵称
        LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:self.noticeCreateUid];
        if (friendModel && friendModel.nickname) {
            self.localCacheUserName = friendModel.nickname;
        } else {
            self.localCacheUserName = self.noticeCreateNickname;
        }
    }
    
    //处理公告文字内容（优先展示翻译）
    if (![NSString isNil:self.translateContent]) {
        NSString *currentLanguageMapCode = [ZLanguageTOOL languageCodeFromDevieInfo];
        NSDictionary *noticeDict = [NSString jsonStringToDic:self.translateContent];
        if (![[noticeDict allKeys] containsObject:currentLanguageMapCode]) {
            if ([currentLanguageMapCode isEqualToString:@"lb"]) {
                self.showContent = (NSString *)[noticeDict objectForKeySafe:@"lbb"];
            } else if ([currentLanguageMapCode isEqualToString:@"no"]) {
                self.showContent = (NSString *)[noticeDict objectForKeySafe:@"nor"];
            } else {
                NSString *notice_en = (NSString *)[noticeDict objectForKeySafe:@"en"];
                self.showContent = notice_en;
            }
        } else {
            NSString *notice_current = (NSString *)[noticeDict objectForKeySafe:currentLanguageMapCode];
            self.showContent = notice_current;
        }
    } else {
        self.showContent = [NSString isNil:self.content] ? @"" : self.content;
    }
}

- (CGFloat)getTextViewHeightWithText:(NSString *)text {
    CGFloat width = DScreenWidth - 32 - 32;
    // 计算文本高度
    CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{
        NSFontAttributeName: FONTR(14)
                                                     }
                                             context:nil];
    CGFloat textHeight = ceil(boundingRect.size.height);
    
    // 限制在20-80范围内（1-4行）
    CGFloat cellHeight = MIN(textHeight, 80);
    return cellHeight;
}

- (CGFloat)getTextViewHeight {
    CGFloat textViewHeight = [self getTextViewHeightWithText:self.showContent];
    return textViewHeight;
}

- (CGFloat)getCellHeight {
    CGFloat textViewHeight = [self getTextViewHeightWithText:self.showContent];
    CGFloat height = 0.0;
    if ([self isTop]) {
        // 置顶
        // 上下左右间距5，置顶高度20，文本高度为textViewHeight，用户名称距离文本5，高度12，距离底部16
        height = 5 * 2 + 20 + 2 + textViewHeight + 5 + 12 + 16;
    }else {
        // 上下左右间距5，文本距离bgView高度为16，文本高度为textViewHeight，用户名称距离文本5，高度12，距离底部16
        height = 5 * 2 + 16 + textViewHeight + 5 + 12 + 16;
    }
    return height;
}

- (BOOL)isTop {
    return [self.topStatus isEqualToString:@"1"];
}

@end
