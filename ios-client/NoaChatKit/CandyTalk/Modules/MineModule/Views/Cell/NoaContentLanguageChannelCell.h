//
//  NoaContentLanguageChannelCell.h
//  NoaKit
//
//  Created by Candy on 2023/9/14.
//

#import "NoaBaseCell.h"
#import "NoaTranslateChannelLanguageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaContentLanguageChannelCell : NoaBaseCell

@property (nonatomic, strong) NoaTranslateChannelLanguageModel *channelModel;
@property (nonatomic, strong) NoaTranslateLanguageModel *languageModel;
@property (nonatomic, assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
