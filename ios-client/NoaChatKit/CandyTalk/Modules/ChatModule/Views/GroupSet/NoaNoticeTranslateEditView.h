//
//  NoaNoticeTranslateEditView.h
//  NoaKit
//
//  Created by Candy on 2024/2/21.
//

#import <UIKit/UIKit.h>
#import "NoaNoticeTranslateModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZNoticeTranslateEditViewDelegate <NSObject>

- (void)editContentFinish:(NSString *)contentStr;

@end

@interface NoaNoticeTranslateEditView : UIView

@property (nonatomic, assign) NSInteger maxContentNum;
@property (nonatomic, copy) NSString *editTitelStr;
@property (nonatomic, copy) NSString *editContentStr;
@property (nonatomic, weak) id<ZNoticeTranslateEditViewDelegate>delegate;

- (void)editViewShow;

@end

NS_ASSUME_NONNULL_END
