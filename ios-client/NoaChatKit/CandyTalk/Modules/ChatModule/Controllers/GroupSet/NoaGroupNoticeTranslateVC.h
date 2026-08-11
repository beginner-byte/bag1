//
//  NoaGroupNoticeTranslateVC.h
//  NoaKit
//
//  Created by Candy on 2024/2/19.
//

#import "CandyBaseViewController.h"
#import "LingIMGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaGroupNoticeTranslateVC : CandyBaseViewController

@property (nonatomic,strong)LingIMGroup *groupInfoModel;
@property (nonatomic, copy)NSString *originNoticeContent;//群公告原文
@property (nonatomic, copy)NSString *channelCode;//翻译通道id
@property (nonatomic, copy)NSString *channelName;//翻译通道Name
@property (nonatomic, strong)NSArray *languageCodeArr;//翻译语种
@property (nonatomic, strong)NSArray *languageNameArr;//翻译语种名称

@end

NS_ASSUME_NONNULL_END
