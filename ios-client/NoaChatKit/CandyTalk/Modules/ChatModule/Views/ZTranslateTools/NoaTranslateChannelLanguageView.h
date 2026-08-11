//
//  NoaTranslateChannelLanguageView.h
//  NoaKit
//
//  Created by Candy on 2023/12/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZTranslateChannelLanguageViewDelegate <NSObject>

- (void)selectActionFinishWithSessionModel:(LingIMSessionModel *)sessionModel translateType:(ZMsgTranslateType)translateType;

@end

@interface NoaTranslateChannelLanguageView : UIView

@property (nonatomic, weak) id <ZTranslateChannelLanguageViewDelegate> delegate;

//初始化
- (instancetype)initWithTranslateType:(ZMsgTranslateType)translateType sessionModel:(LingIMSessionModel *)sessionModel;
- (void)channelLanguageViewShow;
- (void)channelLanguageViewDismiss;

@end

NS_ASSUME_NONNULL_END
