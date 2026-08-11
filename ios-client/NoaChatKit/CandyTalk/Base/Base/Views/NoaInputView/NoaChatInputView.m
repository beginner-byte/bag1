//
//  NoaChatInputView.m
//  NoaKit
//
//  Created by Candy on 2026/9/27.
//

#import "NoaChatInputView.h"
//#import "NoaChatInputCommonEmojiView.h"//常用表情
#import "NoaChatInputReferenceView.h"//引用
#import "NoaChatInputFunctionView.h"//输入框
#import "NoaChatInputMoreView.h"//更多菜单
#import "NoaChatImageEmojiView.h"//自定义表情
#import "NoaChatInputVoiceView.h"//声音
#import "NoaChatInputVoiceStateView.h"

#import "NoaMessageModel.h"
#import "NoaDraftStore.h"

#import "RecordManager.h"
#import "NoaToolManager.h"

@interface NoaChatInputView () <FunctionViewDelegate,MoreViewDelegate,ZChatInputReferenceViewDelegate,ZChatImageEmojiViewDelegate,ZChatInputVoiceViewDelegate>

//常用表情
//@property (nonatomic, strong) ZChatInputCommonEmojiView *viewCommonEmoji;
//@property (nonatomic, assign) CGFloat commonEmojiH;

//引用控件
@property (nonatomic, strong) NoaChatInputReferenceView *viewReference;
@property (nonatomic, assign) CGFloat referenceH;

//主功能控件(输入框)
@property (nonatomic, strong) NoaChatInputFunctionView *viewFunction;
@property (nonatomic, assign) CGFloat functionH;

//表情控件
@property (nonatomic, strong) NoaChatImageEmojiView *viewImageEmoji;
@property (nonatomic, assign) CGFloat emojiH;

//录音控件
@property (nonatomic, strong) NoaChatInputVoiceView *viewVoice;
@property (nonatomic, assign) CGFloat voiceH;

/** 录音工具*/
@property (nonatomic, strong) RecordManager *recordTool;

//录音状态视图控件
@property (nonatomic, strong) NoaChatInputVoiceStateView *viewVoiceStateView;


@property (nonatomic, strong) NoaChatInputMoreView *viewMore;

//键盘高度
@property (nonatomic, assign) CGFloat keyboardH;

@end

@implementation NoaChatInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        //键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        //默认值
        //_commonEmojiH = DWScale(48);
        _referenceH = 0;
        _functionH = DWScale(56 + 50);
        _emojiH = 0;
        _keyboardH = 0;
        _voiceH = 0;
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        
        
        [self setupUI];
        
        
    }
    return self;
}

// 公开获取当前输入文本与 @ 列表，便于外部保存草稿
- (NSString * _Nullable)currentInputText {
    return self.viewFunction.inputContentStr;
}

- (NSArray * _Nullable)currentAtUserDictList {
    return [self.viewFunction.atUsersDictList copy];
}

- (NSArray * _Nullable)currentAtSegmentsList {
    return [self.viewFunction.atSegments copy];
}

#pragma mark - 界面布局
- (void)setupUI {
//    _viewCommonEmoji = [[ZChatInputCommonEmojiView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(48))];
//    _viewCommonEmoji.delegate = self;
//    [self addSubview:_viewCommonEmoji];
    
    _viewReference = [[NoaChatInputReferenceView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(62))];
    _viewReference.delegate = self;
    _viewReference.alpha = 0;
    [self addSubview:_viewReference];
    
    _viewFunction = [[NoaChatInputFunctionView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(56 + 50))];
    _viewFunction.sessionID = self.sessionID;
    _viewFunction.delegate = self;
    [self addSubview:_viewFunction];
    
    _viewImageEmoji = [[NoaChatImageEmojiView alloc] initWithFrame:CGRectMake(0, _functionH, DScreenWidth, DWScale(300) + DHomeBarH)];
    _viewImageEmoji.alpha = 0;
    _viewImageEmoji.delegate = self;
    [self addSubview:_viewImageEmoji];
    
    _viewVoice = [[NoaChatInputVoiceView alloc] initWithFrame:CGRectMake(0, _functionH, DScreenWidth, DWScale(192) + DHomeBarH)];
    _viewVoice.alpha = 0;
    _viewVoice.delegate = self;
    [self addSubview:_viewVoice];
    
    _viewVoiceStateView = [[NoaChatInputVoiceStateView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(56 + 50 + 48) + DWScale(34))];
    _viewVoiceStateView.hidden = YES;
    [self addSubview:_viewVoiceStateView];

}
#pragma makr - 输入框类型
- (void)setMoreType:(ZChatInputViewType)moreType {
    _moreType = moreType;
    _viewFunction.viewType = moreType;
}

#pragma mark - 输入框被激活，弹出键盘 等待输入的状态
- (void)inputViewBecomeFirstResponder {
    //弹出键盘
    [self.viewFunction.tvContent becomeFirstResponder];
}

#pragma mark - 输入框恢复初始状态
- (void)inputViewResignFirstResponder {
    if (self.viewFunction.tvContent.attributedText.length>0 || ![NSString isNil:self.viewFunction.tvContent.text]) {
        
//        self.viewFunction.tvContent.placeHolderLabel.hidden = YES;
        self.viewFunction.btnVoice.selected = YES;
        
    }else{
        
//        self.viewFunction.tvContent.placeHolderLabel.hidden = NO;
        self.viewFunction.btnVoice.selected = NO;
        
    }
    //1取消键盘响应
    [self.viewFunction.tvContent resignFirstResponder];
    //2隐藏表情
    self.viewFunction.btnEmoji.selected = NO;
    [self.viewFunction.btnEmoji mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.viewFunction.viewContent.mas_bottom).offset(-DWScale(8));
        make.trailing.equalTo(self.viewFunction.viewContent).offset(-DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(22), DWScale(22)));
    }];
    [self hiddenInputEmojiView];
    //3隐藏语音输入视图
    [self hiddenInputVoiceView];
    //345...
}
#pragma mark - @用户输入
- (void)inputViewInsertAtUserInfo:(NSDictionary *)userDic {
    [self.viewFunction inputAtUserInfo:userDic];
}
// 赋值 @ 信息
- (void)configAtUserInfoList:(NSArray *)atUserDictList {
    [self.viewFunction configAtUserInfoList:atUserDictList];
}

- (void)configAtSegmentsInfoList:(NSArray *)atSegmentsInfoList {
    [self.viewFunction configAtSegmentsInfoList:atSegmentsInfoList];
}

// 设置发送按钮高亮（当有草稿时应高亮）
- (void)setSendButtonHighlighted:(BOOL)highlighted {
    self.viewFunction.btnVoice.selected = highlighted;
}

// 将待编辑 @ 消息的成员信息交给内部输入控件重建高亮区间。
- (void)editAtMessageWithAtUserInfoList:(NSArray *)atUserDictList {
    [self.viewFunction editAtMessageWithAtUserInfoList:atUserDictList];
}
#pragma mark - 界面赋值
- (void)setInputContentStr:(NSString *)inputContentStr {
    _inputContentStr = inputContentStr;
    
    self.viewFunction.inputContentStr = inputContentStr;
    //更新高度
    [self.viewFunction calculateFunctionFrame];
}

// 同步输入框编辑状态与底层功能栏布局。
- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    [self.viewFunction setEditMode:isEditMode];
}
- (void)setMessageModelReference:(NoaMessageModel *)messageModelReference {
    if (messageModelReference) {
        _messageModelReference = messageModelReference;
        //展示引用控件
        self.viewReference.referenceMsgModel = _messageModelReference;
        [self showReferenceView];
    }else {
        //隐藏引用控件
        [self hiddenReferenceView];
        //恢复初始状态
        //[self inputViewResignFirstResponder];
    }
}

//配置翻译按钮状态
- (void)configTranslateBtnStatus:(NSInteger)status {
    [_viewFunction configTranslateBtnStatus:status];
}

//用户角色权限 uploadFile 、uploadImageVideo 发生变化
- (void)reloadSetupDataWithTranslateBtnStatus:(BOOL)translateStatus {
    _viewFunction.sessionID = self.sessionID;
    [_viewFunction reloadSetupDataWithTranslateBtnStatus:translateStatus];
}

//配置输入 @ 字符时，是否弹出选择 @用户的列表
- (void)configShowAtUserListStatus:(BOOL)status {
    _viewFunction.isShowAtList = status;
}

- (void)setSessionID:(NSString *)sessionID {
    if ([_sessionID isEqualToString:sessionID]) {
        return;
    }
    _sessionID = sessionID;
}

//重新请求我收藏的表情
- (void)reloadGetMyCollectionStickers {
    [_viewImageEmoji relaodCollectionData];
}

#pragma mark - ZChatInputCommonEmojiViewDelegate
//- (void)commonEmojiSelected:(NSString *)emojiName {
//    [self.viewFunction.tvContent appendWithEmojiName:emojiName];
//    [self.viewFunction calculateFunctionFrame];
//    self.viewFunction.btnVoice.selected = YES;
//}

#pragma mark - FunctionViewDelegate
- (void)functionViewActionWith:(NSInteger)actionTag atUserList:(NSArray *)atUsersDictList atSegmentsList:(NSArray *)atSegmentsList {
    if (actionTag == 1) {
        //更多
        [self showInputMoreView];
    }else if (actionTag == 2) {
        //表情
        [self hiddenInputVoiceView];
        [self showInputEmojiView];
        [_viewImageEmoji reloadStickersData];
    }else if (actionTag == 3) {
        //显示语音输入视图
        [self hiddenInputEmojiView];
        [self showInputVoiceView];
    }else if (actionTag == 4) {
        
    }else if (actionTag == 5) {
        
        //发送
        if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewSend:atUserList:atUserSegmentList:)]) {
            [_delegate chatInputViewSend:self.viewFunction.inputContentStr
                              atUserList:atUsersDictList
            atUserSegmentList:atSegmentsList];
        }
        
        if (_keyboardH > 0 || _emojiH > 0) {
            
//            self.viewFunction.tvContent.placeHolderLabel.hidden = YES;
            self.viewFunction.btnVoice.selected = YES;
            
        }else{
            
            if (self.viewFunction.tvContent.attributedText.length>0 || ![NSString isNil:self.viewFunction.tvContent.text]) {
                
//                self.viewFunction.tvContent.placeHolderLabel.hidden = NO;
                self.viewFunction.btnVoice.selected = NO;
                
            }
            
        }
    }else if (actionTag == 6) {
        //键盘响应
        //隐藏表情控件
        [self hiddenInputEmojiView];
        //隐藏语音输入控件
        [self hiddenInputVoiceView];
    }else if (actionTag == 7) {
        //键盘取消响应
    }else if (actionTag == 8) {
        //@用户
        if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewAtUser)]) {
            [_delegate chatInputViewAtUser];
        }
    }
}
- (void)functionViewHeightChanged:(CGFloat)height {
    if (height != _functionH) {
        self.viewFunction.y = _referenceH;
        self.viewFunction.height = height;
        _functionH = height;
        
        if (_emojiH > 0) {
            //更新表情控件布局
            [self showInputEmojiView];
        }
        
        //总高度变化
        [self chatInputViewTotalHeightChange];
        
    }
}

// 将编辑确认事件上抛给聊天控制器执行接口调用。
- (void)functionViewEditConfirm {
    if ([_delegate respondsToSelector:@selector(chatInputViewEditConfirm)]) {
        [_delegate chatInputViewEditConfirm];
    }
}

// 将编辑取消事件上抛给聊天控制器恢复普通输入状态。
- (void)functionViewEditCancel {
    if ([_delegate respondsToSelector:@selector(chatInputViewEditCancel)]) {
        [_delegate chatInputViewEditCancel];
    }
}
- (void)functionViewBottomActionWith:(ZChatInputActionType)actionType {
    if (actionType == ZChatInputActionTypeAudioCall) {
        //语音通话
        [self performSelector:@selector(showAudioCallView) withObject:nil afterDelay:0.3];
    } else if (actionType == ZChatInputActionTypeVideoCall) {
        //视频通话
        [self performSelector:@selector(showVideoCallView) withObject:nil afterDelay:0.3];
    }else if (actionType == ZChatInputActionTypePhotoAlbum) {
        //相册
        [self performSelector:@selector(showImageSelectView) withObject:nil afterDelay:0.3];
    } else if (actionType == ZChatInputActionTypeFile) {
        //文件
        [self performSelector:@selector(showFileSelectView) withObject:nil afterDelay:0.3];
    } else if (actionType == ZChatInputActionTypeLocation) {
        //位置
        [self performSelector:@selector(showLocationSelectView) withObject:nil afterDelay:0.3];
    } else if (actionType == ZChatInputActionTypeCollection) {
        //收藏
        [self performSelector:@selector(showCollectionSelectView) withObject:nil afterDelay:0.3];
    } else if (actionType == ZChatInputActionTypeTranslate) {
        //翻译
        [self performSelector:@selector(showTranslateSelectView) withObject:nil afterDelay:0.3];
    }
}

#pragma mark - MoreViewDelegate
- (void)moreViewActionWith:(ZChatInputActionType)actionType {
    _viewMore = nil;
    
    if (actionType == ZChatInputActionTypeAudioCall) {
        //语音通话
        [self performSelector:@selector(showAudioCallView) withObject:nil afterDelay:0.3];
    } else if (actionType == ZChatInputActionTypeVideoCall) {
        //视频通话
        [self performSelector:@selector(showVideoCallView) withObject:nil afterDelay:0.3];
    }else if (actionType == ZChatInputActionTypePhotoAlbum) {
        //相册
        [self performSelector:@selector(showImageSelectView) withObject:nil afterDelay:0.3];
    } else if (actionType == ZChatInputActionTypeFile) {
        //文件
        [self performSelector:@selector(showFileSelectView) withObject:nil afterDelay:0.3];
    } else if (actionType == ZChatInputActionTypeLocation) {
        //位置
        [self performSelector:@selector(showLocationSelectView) withObject:nil afterDelay:0.3];
    } else if (actionType == ZChatInputActionTypeCollection) {
        //收藏
        [self performSelector:@selector(showCollectionSelectView) withObject:nil afterDelay:0.3];
    }
    
}

#pragma mark - ZChatInputReferenceViewDelegate
- (void)referenceViewClose {
    [self hiddenReferenceView];
    
    //总高度变化
    [self chatInputViewTotalHeightChange];
    
    //恢复初始状态
    [self inputViewResignFirstResponder];
    
}
#pragma mark - ZChatInputEmojiViewDelegate
- (void)imageEmojiViewSelected:(NSString *)emojiName {
    [self.viewFunction.tvContent appendWithEmojiName:emojiName];
    [self.viewFunction calculateFunctionFrame];
}
- (void)imageEmojiViewDelete {
    if (self.viewFunction.tvContent.text.length > 0) {
        
        NSRange range = self.viewFunction.tvContent.selectedRange;
        NSUInteger location = range.location;
        NSUInteger length = range.length;
        if (location == 0 && length == 0) return;
        
        //直接调用textview的代理方法进行删除
        if ([self.viewFunction textView:self.viewFunction.tvContent shouldChangeTextInRange:NSMakeRange(self.viewFunction.tvContent.text.length-1, 1) replacementText:@""]) {
            [self.viewFunction.tvContent deleteBackward];
        }
        
        //更新输入框控件高度，此处删除表情，不触发文本变化的回调，手动调用一下计算
        [self.viewFunction calculateFunctionFrame];
    }
}

//表情包表情或者动图表情或搜索到的表情发送
- (void)imageGifPackageSelected:(NoaIMStickersModel *)stickersModel  {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewStickersSend:)]) {
        [_delegate chatInputViewStickersSend:stickersModel];
    }
}

//打开相册(添加相册图片到收藏的表情里)
- (void)openAlumAddCollectGifImg {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewOpenAlumAddCollectGifImg)]) {
        [_delegate chatInputViewOpenAlumAddCollectGifImg];
    }
}

//剪刀石头布
- (void)chatGameStickerAction:(ZChatGameStickerType)gameType {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewPlayGameStickerAction:)]) {
        [_delegate chatInputViewPlayGameStickerAction:gameType];
    }
}

- (void)searchEmojiMoreAction {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewSearchMoreEmojiAction)]) {
        [_delegate chatInputViewSearchMoreEmojiAction];
    }
}

#pragma mark - ZChatInputVoiceViewDelegate
- (void)dragMoving{
    DLog(@"----------dragMoving");
}

- (void)dragEnded{
    DLog(@"----------dragEnded");
}
// 点击被取消，例如进入后台
- (void)voiceEventTouchCancel{
    DLog(@"----------voiceEventTouchCancel");
    self.viewVoiceStateView.hidden = YES;
    [self.viewVoiceStateView updateViewState:InputVoiceStateSend];
    
    [self.recordTool cancelRecord];
}

// 按下去
- (void)voiceEventTouchDown{
    DLog(@"----------voiceEventTouchDown");
    self.viewVoiceStateView.hidden = NO;
    [self.recordTool startRecord];
}

// 从外到内
- (void)voiceEventTouchDragEnter{
    DLog(@"----------voiceEventTouchDragEnter");
    [self.viewVoiceStateView updateViewState:InputVoiceStateSend];
}

// 从内到外
- (void)voiceEventTouchDragExit{
    DLog(@"----------voiceEventTouchDragExit");
    [self.viewVoiceStateView updateViewState:InputVoiceStateCancel];
}

// 在button感应区域之外结束点击，取消点击
- (void)voiceEventTouchUpOutside{
    DLog(@"----------voiceEventTouchUpOutside");
    self.viewVoiceStateView.hidden = YES;
    [self.viewVoiceStateView updateViewState:InputVoiceStateSend];
    
    [self.recordTool cancelRecord];
}

// 在button感应区域之内结束点击，成功点击
- (void)voiceEventTouchUpInside{
    DLog(@"----------voiceEventTouchUpInside");
    self.viewVoiceStateView.hidden = YES;
    [self.viewVoiceStateView updateViewState:InputVoiceStateSend];
    
    [self.recordTool finishRecord];
    
    if (self.recordTool.recordTime < 1) {
        [HUD showMessage:LanguageToolMatch(@"说话时间太短")];
    }else {
        WeakSelf
        self.recordTool.conventFinish = ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatInputViewVoicePath:voiceName:voiceDuration:)]) {
                [weakSelf.delegate chatInputViewVoicePath:weakSelf.recordTool.voiceFilePath voiceName:weakSelf.recordTool.voiceName voiceDuration:weakSelf.recordTool.recordTime];
            }
        };
    }
}
#pragma mark - 交互事件
//展示引用控件
- (void)showReferenceView {
    _referenceH = DWScale(62);
    WeakSelf
    
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewFunction.y = weakSelf.viewReference.height;
        weakSelf.viewReference.alpha = 1;
    }];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewImageEmoji.y = weakSelf.referenceH + weakSelf.functionH;
        weakSelf.viewImageEmoji.alpha = 0;
    }];
    
    //总高度变化
    [self chatInputViewTotalHeightChange];
    
}
//隐藏引用控件
- (void)hiddenReferenceView {
    _messageModelReference = nil;
    _referenceH = 0;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewFunction.y = weakSelf.referenceH;
        weakSelf.viewReference.alpha = 0;
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewImageEmoji.y = weakSelf.referenceH + weakSelf.functionH;
        weakSelf.viewImageEmoji.alpha = weakSelf.emojiH > 0 ? 1 : 0;
    }];

    
    //总高度变化
    [self chatInputViewTotalHeightChange];
    
}

//展示更多控件
- (void)showInputMoreView {
    
    self.viewMore.bottomH = self.height;
    [self.viewMore viewShow];
}

//展示语音通话VC
- (void)showAudioCallView {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewAudioCall)]) {
        [_delegate chatInputViewAudioCall];
    }
}

//展示位置信息选择
-(void)showLocationSelectView{
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewShowLoction)]) {
        [_delegate chatInputViewShowLoction];
    }
}

//展示收藏列表
- (void)showCollectionSelectView {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewCollection)]) {
        [_delegate chatInputViewCollection];
    }
}

//展示视频通话VC
- (void)showVideoCallView {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewVideoCall)]) {
        [_delegate chatInputViewVideoCall];
    }
}

//展示图片选择VC
- (void)showImageSelectView {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewShowImage)]) {
        [_delegate chatInputViewShowImage];
    }
}

//展示文件选择VC
- (void)showFileSelectView {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewShowFile)]) {
        [_delegate chatInputViewShowFile];
    }
}

//展示翻译选项View
- (void)showTranslateSelectView {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewTranslate)]) {
        [_delegate chatInputViewTranslate];
    }
}

//展示表情控件
- (void)showInputEmojiView {
    _emojiH = DWScale(300);
    
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewImageEmoji.y = weakSelf.referenceH + weakSelf.functionH;
        weakSelf.viewImageEmoji.alpha = 1;
    }];
    
    //总高度变化
    [self chatInputViewTotalHeightChange];
    
}
//隐藏表情控件
- (void)hiddenInputEmojiView {
    if (_emojiH > 0) {
        _emojiH = 0;
        WeakSelf
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.viewImageEmoji.y = weakSelf.referenceH + weakSelf.functionH;
            weakSelf.viewImageEmoji.alpha = 0;
        }];
        
        //总高度变化
        [self chatInputViewTotalHeightChange];
    }
}

//展示输入语音控件
- (void)showInputVoiceView {
    _voiceH = DWScale(192);
    
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.viewVoice.y = weakSelf.referenceH + weakSelf.functionH;
        weakSelf.viewVoice.alpha = 1;
    }];
    
    //总高度变化
    [self chatInputViewTotalHeightChange];
    
}
//隐藏输入语音控件
- (void)hiddenInputVoiceView {
    if (_voiceH > 0) {
        _voiceH = 0;
        WeakSelf
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.viewVoice.y = weakSelf.referenceH + weakSelf.functionH;
            weakSelf.viewVoice.alpha = 0;
        }];
        
        //总高度变化
        [self chatInputViewTotalHeightChange];
    }
}

//展示输入语音状态控件
- (void)showInputVoiceStateView{
    self.viewVoiceStateView.y = 0;
}
//隐藏输入语音状态控件
- (void)hiddelInputVoiceStateView{
    
}


#pragma mark - 监听键盘
- (void)systemKeyboardWillShow:(NSNotification *)notification {
    //显示系统键盘
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardH = keyboardRect.size.height;
    _keyboardH -= DHomeBarH;
    
    //总高度变化
    [self chatInputViewTotalHeightChange];
}
- (void)systemKeyboardWillHide:(NSNotification *)notification {
    //隐藏系统键盘
    _keyboardH = 0;
    
    //总高度变化
    [self chatInputViewTotalHeightChange];
}

//总高度发生变化回调
- (void)chatInputViewTotalHeightChange {
    if (_delegate && [_delegate respondsToSelector:@selector(chatInputViewHeightChanged:)]) {
        [_delegate chatInputViewHeightChanged:_functionH + _referenceH + _emojiH + _keyboardH +_voiceH + DHomeBarH];
    }
}

#pragma mark - 懒加载
- (NoaChatInputMoreView *)viewMore {
    if (!_viewMore) {
        _viewMore = [NoaChatInputMoreView new];
        _viewMore.delegate = self;
        _viewMore.moreType = self.moreType;
    }
    return _viewMore;
}

- (RecordManager *)recordTool {
    
    if (_recordTool == nil) {
        _recordTool = [[RecordManager alloc] initWithSessionID:self.sessionID];
        //配置
        _recordTool.soundMeterCount = 7;
        _recordTool.updateFequency = 0.1;
        _recordTool.maxSecond = 60;
        __weak typeof(self) weakSelf = self;

        _recordTool.returnTime = ^(NSTimer *timer,int second) {
            
            NSLog(@"returnTime %d",second);
            
            weakSelf.viewVoiceStateView.timeLabel.text = [NSString stringWithFormat:@"%ds", weakSelf.recordTool.maxSecond - second];
            
            if (second < 1) {
                //倒计时结束
                [weakSelf.recordTool finishRecord];
                
                weakSelf.viewVoice.recordVoiceFinish = YES;
                [weakSelf.viewVoice.voiceBtn setImage:ImgNamed(@"Img_chat_voice_input_normal") forState:UIControlStateNormal];
                weakSelf.viewVoiceStateView.hidden = YES;
                [weakSelf.viewVoiceStateView updateViewState:InputVoiceStateSend];
                
                weakSelf.recordTool.conventFinish = ^{
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatInputViewVoicePath:voiceName:voiceDuration:)]) {
                        [weakSelf.delegate chatInputViewVoicePath:weakSelf.recordTool.voiceFilePath voiceName:weakSelf.recordTool.voiceName voiceDuration:weakSelf.recordTool.recordTime];
                    }
                };
            }
        };
    }
    return _recordTool;
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
