//
//  NoaSearchView.h
//  NoaKit
//
//  Created by Apple on 2026/9/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZSearchViewDelegate <NSObject>
@optional
//输入框文本变化
- (void)searchViewTextValueChanged:(NSString *)searchStr;
//当currentViewSearch == NO的时候，触发跳转搜索
- (void)searchViewGoSearch;
//回车
- (void)searchViewReturnKeySearch:(NSString *)searchStr;
@end

@interface NoaSearchView : UIView

- (instancetype)initWithPlaceholder:(NSString*)placeholder;

@property (nonatomic, weak) id <ZSearchViewDelegate> delegate;
//显示清空按钮
@property (nonatomic, assign) BOOL showClearBtn;
//输入框文本内容
@property (nonatomic, copy) NSString *searchStr;
//当前界面搜索
@property (nonatomic, assign) BOOL currentViewSearch;
//回车类型
@property (nonatomic, assign) UIReturnKeyType returnKeyType;
//是否激活键盘
@property (nonatomic, assign) BOOL showKeyboard;
@property (nonatomic, strong) UITextField *tfSearch;

@end

NS_ASSUME_NONNULL_END
