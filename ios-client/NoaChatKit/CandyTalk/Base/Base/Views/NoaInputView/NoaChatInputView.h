//
//  NoaChatInputView.h
//  NoaKit
//
//  Created by Candy on 2026/9/27.
//

// 聊天输入内容 总 View

#import <UIKit/UIKit.h>
#import "NoaChatInputMoreView.h"

@class NoaMessageModel;

NS_ASSUME_NONNULL_BEGIN
@protocol ZChatInputViewDelegate <NSObject>
@optional
- (void)chatInputViewHeightChanged:(CGFloat)heigh;//高度变化
- (void)chatInputViewSend:(NSString *)sendStr
               atUserList:(NSArray * _Nullable)atUsersDictList
        atUserSegmentList:(NSArray * _Nullable)atUserSegmentList;//发送
- (void)chatInputViewAudioCall;//音频通话
- (void)chatInputViewVideoCall;//视频通话
- (void)chatInputViewShowImage;//展示相册
- (void)chatInputViewShowFile;//展示文件选择
- (void)chatInputViewAtUser;//@用户
- (void)chatInputViewShowLoction;//展示定位
- (void)chatInputViewCollection;//展示收藏
- (void)chatInputViewTranslate;//展示翻译通道和语种选择View
- (void)chatInputViewVoicePath:(NSString *)vociePath voiceName:(NSString *)voiceName voiceDuration:(CGFloat)vocieDuration;//语音消息录制完成将语音地址返回出去
- (void)chatInputViewSearchMoreEmojiAction;//搜索更多表情
- (void)chatInputViewStickersSend:(NoaIMStickersModel *)sendStickersModel;//发送表情包表情或者动图表情或搜索到的表情
- (void)chatInputViewOpenAlumAddCollectGifImg;//打开相册(添加相册图片到收藏的表情里)
- (void)chatInputViewPlayGameStickerAction:(ZChatGameStickerType)gameType;//游戏表情：剪刀石头布、摇骰子
/// 确认编辑当前消息。
- (void)chatInputViewEditConfirm;
/// 取消编辑当前消息。
- (void)chatInputViewEditCancel;


@end

@interface NoaChatInputView : UIView
@property (nonatomic, copy) NSString * sessionID;//当前聊天ID
@property (nonatomic, assign) ZChatInputViewType moreType;//左侧 更多 按钮弹窗类型
@property (nonatomic, weak) id <ZChatInputViewDelegate> delegate;
@property (nonatomic, copy) NSString *inputContentStr;//输入框内容

/// 获取当前输入框纯文本（包含表情转义后的文本）。若无内容返回nil
- (NSString * _Nullable)currentInputText;
/// 获取当前输入中的 @ 用户列表（数组元素为 {uid:nick} 字典）。若无则返回nil
- (NSArray * _Nullable)currentAtUserDictList;

- (NSArray * _Nullable)currentAtSegmentsList;

@property (nonatomic, strong) NoaMessageModel * _Nullable messageModelReference;//引用消息
/// 当前正在编辑的消息。
@property (nonatomic, strong) NoaMessageModel * _Nullable messageModelEdit;
/// 输入框是否处于消息编辑模式。
@property (nonatomic, assign) BOOL isEditMode;

//输入框被激活，弹出键盘
- (void)inputViewBecomeFirstResponder;
//输入框恢复初始状态
- (void)inputViewResignFirstResponder;
//@用户输入
- (void)inputViewInsertAtUserInfo:(NSDictionary * _Nullable)userDic;
//配置输入 @ 字符时，是否弹出选择 @用户的列表
- (void)configShowAtUserListStatus:(BOOL)status;
//重新请求我收藏的表情
- (void)reloadGetMyCollectionStickers;
//用户角色权限 uploadFile 发生变化
- (void)reloadSetupDataWithTranslateBtnStatus:(BOOL)translateStatus;
//配置翻译按钮状态
- (void)configTranslateBtnStatus:(NSInteger)status;

// 赋值 @ 信息（转发至内部 FunctionView）
- (void)configAtUserInfoList:(NSArray *)atUserDictList;

/// 将 @ 信息高亮
- (void)configAtSegmentsInfoList:(NSArray *)atSegmentsInfoList;

/// 设置发送按钮高亮（当有草稿时应高亮，表现为发送态）
- (void)setSendButtonHighlighted:(BOOL)highlighted;

/// 回填待编辑 @ 消息的用户信息。
/// @param atUserDictList @ 用户字典列表。
- (void)editAtMessageWithAtUserInfoList:(NSArray *)atUserDictList;

@end

NS_ASSUME_NONNULL_END
