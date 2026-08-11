//
//  noticeTranslateItemView.h
//  NoaKit
//
//  Created by Candy on 2024/2/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface noticeTranslateItemView : UIView

@property (nonatomic, copy) NSString *contentStr;
@property (nonatomic, copy) void(^textInputClick)(void);

@end

NS_ASSUME_NONNULL_END
