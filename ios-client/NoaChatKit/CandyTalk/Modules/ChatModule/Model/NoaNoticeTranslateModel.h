//
//  NoaNoticeTranslateModel.h
//  NoaKit
//
//  Created by Candy on 2024/2/22.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaNoticeTranslateModel : NoaBaseModel

@property (nonatomic, copy) NSString *originNotice;//群公告原文
@property (nonatomic, copy) NSString *translateNotice;//群公告译文
@property (nonatomic, assign) BOOL isOrigin;//是原文还是译文
@property (nonatomic, copy) NSString *channelCode;
@property (nonatomic, copy) NSString *languageCode;
@property (nonatomic, copy) NSString *languageName;
@property (nonatomic, assign) NSInteger translateStatus;//翻译的状态：1：未翻译，2：翻译成功，3：字符不足，4：翻译失败
@property (nonatomic, assign) BOOL isTranslate;//是否已经调用过翻译接口

@end

NS_ASSUME_NONNULL_END
