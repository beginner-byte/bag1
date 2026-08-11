//
//  NoaPlaceHolderTextView.h
//  NoaKit
//
//  Created by Candy on 2023/5/4.
//

#import <UIKit/UIKit.h>
#import "UITextView+Addition.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ZPlaceHolderTextViewDelegate <NSObject>

@optional
/**
 在显示文字限制的时候，需要实现的代理方法，可以不用操作什么
 */
- (void)refreshTextLimit;

@end

@interface NoaPlaceHolderTextView : UITextView

/**
 自定义带提示语和文本字数限制的textView(默认文本左对齐,字体边距（10，8，10，8）)--在显示文本字数限制的时候，需要实现代理方法
 
 @param frame frame大小
 @param hiddenMaxText 是否隐藏文本字数限制(显示的时候，需要实现代理方法)
 @return NoaPlaceHolderTextView
 */
- (instancetype)initWithFrame:(CGRect)frame hiddenMaxText:(BOOL)hiddenMaxText;

@property (nonatomic, weak) id<ZPlaceHolderTextViewDelegate> textViewDelegate;

/**
 提示用户输入的提示语(默认：请输入文本)
 */
@property (nonatomic, copy) NSString *placeHolder;

/**
 提示语文本的颜色（默认lightGrayColor）
 */
@property (nonatomic, strong) UIColor *placeHolderTextColor;

/**
 文本最大输入长度(默认100)
 */
@property (nonatomic, assign) NSInteger maxTextLength;

/**
 是否隐藏文本字数限制
 */
@property (nonatomic, assign) BOOL hiddenMaxText;


@end

NS_ASSUME_NONNULL_END
