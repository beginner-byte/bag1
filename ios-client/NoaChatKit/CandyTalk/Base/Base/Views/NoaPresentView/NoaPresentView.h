//
//  NoaPresentView.h
//  NoaKit
//
//  Created by Candy on 2026/9/3.
//

#import <UIKit/UIKit.h>
#import "NoaPresentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaPresentView : UIView

typedef void(^DoneActionBlock)(NSInteger index);
typedef void(^CancleActionBlock)(void);

//灰色半透明背景
@property (nonatomic, strong) UIControl *control;
//弹窗白色背景
@property (nonatomic, strong) UIView *presentView;
//点击回调
@property (nonatomic, copy) DoneActionBlock doneActionBlock;
@property (nonatomic, copy) CancleActionBlock cancleActionBlock;
@property (nonatomic, strong) NoaPresentItem *titleItem;
@property (nonatomic, strong) NSArray <NoaPresentItem *>*selectItems;
@property (nonatomic, strong) NoaPresentItem *cancleItem;

- (instancetype)initWithFrame:(CGRect)frame titleItem:(NoaPresentItem * _Nullable)titleItem selectItems:(NSArray <NoaPresentItem *>* _Nullable)selectItems cancleItem:(NoaPresentItem * _Nonnull)cancleItem doneClick:(DoneActionBlock _Nullable)doneClick cancleClick:(CancleActionBlock _Nullable)cancleClick;

- (instancetype)initWithFrame:(CGRect)frame custom:(UIView*)customView  doneClick:(DoneActionBlock _Nullable)doneClick cancleClick:(CancleActionBlock _Nullable)cancleClick;

//显示面板
- (void)showPresentView;

//关闭面板
- (void)dismissPresentView;

@end

NS_ASSUME_NONNULL_END
