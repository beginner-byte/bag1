//
//  groupSetDorpView.h
//  NoaKit
//
//  Created by Candy on 2024/2/17.
//

#import <UIKit/UIKit.h>
#import "NoaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
//聊天接收、发送消息翻译选择通道或语种 类型
typedef NS_ENUM(NSUInteger, ZGroupNoticeTranslateType) {
    ZGroupNoticeTranslateTypeChannel = 1,   //通道
    ZGroupNoticeTranslateTypeLanguage = 2,  //语种-收到消息
};

@interface groupSetDorpView : UIView

@property (nonatomic, copy) void(^channelSelectedBlock)(NSString *channelCode, NSString *channelName);
@property (nonatomic, copy) void(^languageSelectedBlock)(NSArray *languageModelList, NSArray *languageNameList);

@property(nonatomic, strong)NSMutableArray *dataList;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, copy) NSString *currentChannelCode;
@property (nonatomic, strong) NSArray *currentLanguageCodeList;
@property (nonatomic, strong) NSArray *currentLanguageNameList;

- (instancetype)initWithTranslateType:(ZGroupNoticeTranslateType)translateType channelCode:(NSString *)channelCode selectedItemsCode:(NSArray *)selectedItemsCode selectedItemsName:(NSArray *)selectedItemsName;
- (void)setupData;
- (void)dropViewDismiss;

@end



@interface groupSetDorpCell : NoaBaseCell

@property (nonatomic, copy) NSString *itemTitleStr;
@property (nonatomic, strong) UILabel *contentLbl;
@property (nonatomic, strong) UIImageView *statusImgView;

@end

NS_ASSUME_NONNULL_END
