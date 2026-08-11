//
//  NoaChatInputFunctionView.m
//  NoaKit
//
//  Created by Candy on 2026/9/27.
//

#import "NoaChatInputFunctionView.h"
//#import "UITextView+Addition.h"
#import "NoaChatInputEmojiManager.h"
#import "NoaToolManager.h"
#import "NoaChatInputActionCell.h"
#import "NoaDraftStore.h"

#define ZATFormat  @"@%@ "
#define ZATRegular @"@[\\u4e00-\\u9fa5\\w\\-\\_\，]+ "

#define ZViewContentW DWScale(303)
#define ZTVContentW (ZViewContentW - DWScale(40))

#define Input_Text_Length       2000 //输入框最大输入字数

@interface NoaChatInputFunctionView () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ZChatInputActionCellDelegate>

@property (nonatomic, strong) NSDictionary *typingAttributes;
@property (nonatomic, strong) UICollectionViewFlowLayout *actionCollectionLayout;
@property (nonatomic, strong) UICollectionView *actionCollectionView;
@property (nonatomic, strong) NSMutableArray *actionList;
/// 是否处于消息编辑模式。
@property (nonatomic, assign) BOOL isEditMode;
/// 编辑模式右侧确认按钮。
@property (nonatomic, strong) UIButton *btnEditConfirm;
/// 编辑模式右侧取消按钮。
@property (nonatomic, strong) UIButton *btnEditCancel;
/// 进入编辑模式前的底部功能列表，用于退出时恢复。
@property (nonatomic, strong) NSMutableArray *originalActionList;
@property (nonatomic, assign) NSInteger lastSelectionLocation; // 记录上一次光标位置，用于判断左右移动
@property (nonatomic, assign) NSInteger lastTextChangeDelta; // 记录最后一次文本变化的delta值
@property (nonatomic, assign) NSUInteger lastTextChangeLocation; // 记录最后一次文本变化的位置
@property (nonatomic, assign) NSRange lastCursorRange; // 记录最后一次光标位置，用于在configAtInfo后恢复
@property (nonatomic, assign) BOOL isTextChanging; // 标记是否正在进行文本变化，避免误判光标移动
@end

@implementation NoaChatInputFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _actionList = [NSMutableArray array];
        _lastSelectionLocation = 0;
        _lastTextChangeDelta = 0;
        _lastTextChangeLocation = 0;
        _lastCursorRange = NSMakeRange(0, 0);
        
        NSDictionary *videoCall = @{
            @"actionTitle" : LanguageToolMatch(@"视频通话"),
            @"actionImage" : @"c_input_video",
            @"actionImage_dark" : @"c_input_video_dark",
            @"actionType"  : @(ZChatInputActionTypeVideoCall)
        };
        NSDictionary *audioCall =                 @{
            @"actionTitle" : LanguageToolMatch(@"语音通话"),
            @"actionImage" : @"c_input_audio",
            @"actionImage_dark" : @"c_input_audio_dark",
            @"actionType"  : @(ZChatInputActionTypeAudioCall)
        };
        NSDictionary *photoAlbum = @{
            @"actionTitle" : LanguageToolMatch(@"相册"),
            @"actionImage" : @"c_input_image",
            @"actionImage_dark" : @"c_input_image_dark",
            @"actionType"  : @(ZChatInputActionTypePhotoAlbum)
        };
        NSDictionary *filePicker = @{
            @"actionTitle" : LanguageToolMatch(@"文件"),
            @"actionImage" : @"c_input_file",
            @"actionImage_dark" : @"c_input_file_dark",
            @"actionType"  : @(ZChatInputActionTypeFile)
        };
        NSDictionary *collection = @{
            @"actionTitle" : LanguageToolMatch(@"收藏"),
            @"actionImage" : @"c_input_collection",
            @"actionImage_dark" : @"c_input_collection_dark",
            @"actionType"  : @(ZChatInputActionTypeCollection)
        };
        NSDictionary *translate = @{
            @"actionTitle" : LanguageToolMatch(@"翻译"),
            @"actionImage" : @"c_input_translate_n",
            @"actionImage_dark" : @"c_input_translate_n_dark",
            @"actionType"  : @(ZChatInputActionTypeTranslate)
        };
        
        if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
            LingIMGroupModel *groupModel = [IMSDKManager toolCheckMyGroupWith:self.sessionID];
            if (groupModel) {
                if (groupModel.isNetCall) {
                    if (groupModel.userGroupRole == 1 || groupModel.userGroupRole == 2) {
                        [_actionList addObject:videoCall];
                        [_actionList addObject:audioCall];
                    }
                } else {
                    [_actionList addObject:videoCall];
                    [_actionList addObject:audioCall];
                }
            } else {
                [_actionList addObject:videoCall];
                [_actionList addObject:audioCall];
            }
        }
        if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"]) {
            [_actionList addObject:photoAlbum];
        }
        if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"true"]) {
            [_actionList addObject:filePicker];
        }
        [_actionList addObject:collection];
        // 根据翻译开关控制是否展示翻译按钮（默认开启）
        BOOL translateEnabled = YES;
        if (UserManager.userRoleAuthInfo && UserManager.userRoleAuthInfo.translationSwitch && ![NSString isNil:UserManager.userRoleAuthInfo.translationSwitch.configValue]) {
            translateEnabled = [UserManager.userRoleAuthInfo.translationSwitch.configValue isEqualToString:@"true"];
        }
        if (translateEnabled) {
            [_actionList addObject:translate];
        }
            
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        
        WeakSelf
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            if (themeIndex == 1) {
                weakSelf.typingAttributes = @{
                    NSFontAttributeName:FONTR(16),
                    NSForegroundColorAttributeName:COLORWHITE
                };
            }else {
                weakSelf.typingAttributes = @{
                    NSFontAttributeName:FONTR(16),
                    NSForegroundColorAttributeName:COLOR_11
                };
            }
        };
        
        //键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        // 翻译开关变化监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTranslateFlagDidChange:) name:UserRoleAuthorityTranslateFlagDidChange object:nil];
        
        [self setupUI];
    }
    return self;
}

- (void)reloadSetupDataWithTranslateBtnStatus:(BOOL)translateStatus {
    NSDictionary *videoCall = @{
        @"actionTitle" : LanguageToolMatch(@"视频通话"),
        @"actionImage" : @"c_input_video",
        @"actionImage_dark" : @"c_input_video_dark",
        @"actionType"  : @(ZChatInputActionTypeVideoCall)
    };
    NSDictionary *audioCall =                 @{
        @"actionTitle" : LanguageToolMatch(@"语音通话"),
        @"actionImage" : @"c_input_audio",
        @"actionImage_dark" : @"c_input_audio_dark",
        @"actionType"  : @(ZChatInputActionTypeAudioCall)
    };
    NSDictionary *photoAlbum = @{
        @"actionTitle" : LanguageToolMatch(@"相册"),
        @"actionImage" : @"c_input_image",
        @"actionImage_dark" : @"c_input_image_dark",
        @"actionType"  : @(ZChatInputActionTypePhotoAlbum)
    };
    NSDictionary *filePicker = @{
        @"actionTitle" : LanguageToolMatch(@"文件"),
        @"actionImage" : @"c_input_file",
        @"actionImage_dark" : @"c_input_file_dark",
        @"actionType"  : @(ZChatInputActionTypeFile)
    };
    NSDictionary *collection = @{
        @"actionTitle" : LanguageToolMatch(@"收藏"),
        @"actionImage" : @"c_input_collection",
        @"actionImage_dark" : @"c_input_collection_dark",
        @"actionType"  : @(ZChatInputActionTypeCollection)
    };
    NSDictionary *translate = @{
        @"actionTitle" : LanguageToolMatch(@"翻译"),
        @"actionImage" : @"c_input_translate_n",
        @"actionImage_dark" : @"c_input_translate_n_dark",
        @"actionType"  : @(ZChatInputActionTypeTranslate)
    };
    
    if (_viewType == ZChatInputViewTypeFileHelper) {
        //文件助手
        if (_actionList) {
            [_actionList removeAllObjects];
        } else {
            _actionList = [NSMutableArray array];
        }
        if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"]) {
            [_actionList addObject:photoAlbum];
        }
        if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"true"]) {
            [_actionList addObject:filePicker];
        }
        [_actionList addObject:collection];
    } else {
        if (_actionList) {
            [_actionList removeAllObjects];
        } else {
            _actionList = [NSMutableArray array];
        }
        if ([ZHostTool.appSysSetModel.enableAudioAndVideoCalls isEqualToString:@"1"]) {
            LingIMGroupModel *groupModel = [IMSDKManager toolCheckMyGroupWith:self.sessionID];
            if (groupModel) {
                if (groupModel.isNetCall) {
                    if (groupModel.userGroupRole == 1 || groupModel.userGroupRole == 2) {
                        [_actionList addObject:videoCall];
                        [_actionList addObject:audioCall];
                    }
                } else {
                    [_actionList addObject:videoCall];
                    [_actionList addObject:audioCall];
                }
            } else {
                [_actionList addObject:videoCall];
                [_actionList addObject:audioCall];
            }
        }
        if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"]) {
            [_actionList addObject:photoAlbum];
        }
        if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"true"]) {
            [_actionList addObject:filePicker];
        }
        [_actionList addObject:collection];
        BOOL translateEnabled2 = YES;
        if (UserManager.userRoleAuthInfo && UserManager.userRoleAuthInfo.translationSwitch && ![NSString isNil:UserManager.userRoleAuthInfo.translationSwitch.configValue]) {
            translateEnabled2 = [UserManager.userRoleAuthInfo.translationSwitch.configValue isEqualToString:@"true"];
        }
        if (translateEnabled2) {
            [_actionList addObject:translate];
        }
    }

    _actionCollectionLayout.itemSize = CGSizeMake(DScreenWidth * 1.0 / (_actionList.count), DWScale(44));
    [_actionCollectionView reloadData];
    [self configTranslateBtnStatus:translateStatus];
}

#pragma mark - 翻译开关变化通知
- (void)userTranslateFlagDidChange:(NSNotification *)note {
    if (_viewType == ZChatInputViewTypeFileHelper) {
        // 文件助手不展示翻译入口，忽略
        return;
    }
    BOOL enabled = YES;
    id val = note.userInfo[@"enabled"];
    if ([val isKindOfClass:[NSNumber class]]) {
        enabled = [((NSNumber *)val) boolValue];
    } else {
        // 便捷读取（默认开启）
        enabled = [UserManager isTranslateEnabled];
    }
    // 查找是否已有“翻译”入口
    __block NSInteger translateIndex = NSNotFound;
    [_actionList enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *type = obj[@"actionType"];
        if ([type isKindOfClass:[NSNumber class]] && type.integerValue == ZChatInputActionTypeTranslate) {
            translateIndex = (NSInteger)idx;
            *stop = YES;
        }
    }];
    if (enabled) {
        if (translateIndex == NSNotFound) {
            NSDictionary *translate = @{ @"actionTitle" : LanguageToolMatch(@"翻译"),
                                          @"actionImage" : @"c_input_translate_n",
                                          @"actionImage_dark" : @"c_input_translate_n_dark",
                                          @"actionType"  : @(ZChatInputActionTypeTranslate) };
            [_actionList addObject:translate];
        }
        // 同步当前会话的高亮状态
        NSInteger highlight = 0;
        if (self.sessionID && self.sessionID.length > 0) {
            LingIMSessionModel *sessionModel = [IMSDKManager toolCheckMySessionWith:self.sessionID];
            highlight = sessionModel.isSendAutoTranslate;
        }
        [self configTranslateBtnStatus:highlight];
    } else {
        if (translateIndex != NSNotFound) {
            [_actionList removeObjectAtIndex:translateIndex];
        }
    }
    _actionCollectionLayout.itemSize = CGSizeMake(DScreenWidth * 1.0 / (_actionList.count), DWScale(44));
    [_actionCollectionView reloadData];
}

#pragma mark - 界面布局
- (void)setupUI {
    //默认UI
    _btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMore.hidden = YES;
    [_btnMore addTarget:self action:@selector(btnMoreClick) forControlEvents:UIControlEventTouchUpInside];
    [_btnMore setTkThemeImage:@[ImgNamed(@"c_input_more"), ImgNamed(@"c_input_more_dark")] forState:UIControlStateNormal];
    [self addSubview:_btnMore];
    [_btnMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.bottom.mas_equalTo(self.mas_bottom).offset(DWScale(-67));
        make.size.mas_equalTo(CGSizeMake(DWScale(22), DWScale(22)));
    }];
    
    _viewContent = [UIView new];
    _viewContent.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    _viewContent.layer.cornerRadius = DWScale(14);
    _viewContent.layer.masksToBounds = YES;
    [self addSubview:_viewContent];
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));//DWScale(48)
        make.top.equalTo(self).offset(DWScale(6));
        make.size.mas_equalTo(CGSizeMake(ZViewContentW, DWScale(44)));
    }];
    
    [_viewContent addSubview:self.tvContent];
    [self.tvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContent).offset(DWScale(12));
        make.trailing.equalTo(_viewContent).offset(-DWScale(32));
        make.top.equalTo(_viewContent).offset(DWScale(10));
        make.bottom.equalTo(_viewContent).offset(-DWScale(10));
    }];
    
    _btnEmoji = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnEmoji addTarget:self action:@selector(btnEmojiClick) forControlEvents:UIControlEventTouchUpInside];
    [_btnEmoji setImage:ImgNamed(@"c_input_emoji") forState:UIControlStateNormal];
    [_btnEmoji setTkThemeImage:@[ImgNamed(@"c_input_emoji_s"), ImgNamed(@"c_input_emoji_s_dark")] forState:UIControlStateSelected];
    [_viewContent addSubview:_btnEmoji];
    [_btnEmoji mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_viewContent.mas_bottom).offset(DWScale(-11));
        make.trailing.equalTo(_viewContent.mas_leading).offset(-DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(22), DWScale(22)));
    }];
    
    _btnVoice = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnVoice setImage:ImgNamed(@"c_input_voice") forState:UIControlStateNormal];
    [_btnVoice setImage:ImgNamed(@"c_input_send") forState:UIControlStateSelected];
    [_btnVoice setImage:ImgNamed(@"c_input_send") forState:UIControlStateSelected | UIControlStateHighlighted];
    [_btnVoice addTarget:self action:@selector(btnVoiceClick) forControlEvents:UIControlEventTouchUpInside];
    _btnVoice.selected = NO;
    _btnVoice.layer.cornerRadius = DWScale(12);
    _btnVoice.layer.masksToBounds = YES;
    [_btnVoice setEnlargeEdge:DWScale(10)];
    [self addSubview:_btnVoice];
    [_btnVoice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_btnMore);
        make.trailing.equalTo(self).offset(-DWScale(14));
        make.size.mas_equalTo(CGSizeMake(DWScale(36), DWScale(36)));
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewContentChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    _actionCollectionLayout = [UICollectionViewFlowLayout new];
    _actionCollectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _actionCollectionLayout.itemSize = CGSizeMake(DScreenWidth * 1.0 / (_actionList.count), DWScale(44));
    _actionCollectionLayout.minimumLineSpacing = 0;
    _actionCollectionLayout.minimumInteritemSpacing = 0;
    _actionCollectionLayout.sectionInset = UIEdgeInsetsZero;
    _actionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_actionCollectionLayout];
    [_actionCollectionView registerClass:[NoaChatInputActionCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaChatInputActionCell class])];
    _actionCollectionView.delegate = self;
    _actionCollectionView.dataSource = self;
    _actionCollectionView.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
    [self addSubview:_actionCollectionView];
    [_actionCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(DWScale(44));
        make.bottom.equalTo(self.mas_bottom).offset(-DWScale(6));
    }];
    
}


- (void)setInputContentStr:(NSString *)inputContentStr {
    if (![NSString isNil:inputContentStr]) {
        // 直接覆盖为新草稿，避免在现有文本后追加导致重复
        self.tvContent.text = @"";
        [self.tvContent configTextContent:inputContentStr];
        [self calculateFunctionFrame];
        //滚动到底部
        [self.tvContent scrollRangeToVisible:NSMakeRange(0, 0)];
        
    } else {
        
        self.tvContent.text = @"";
        
    }
}

- (NSString *)inputContentStr {
    //return _tvContent.text;
    NSString *inputStr = [EMOJI stringWithAttributedString:self.tvContent.attributedText];
    return inputStr;
}
- (void)inputAtUserInfo:(NSDictionary *)atUserDict {
    if (atUserDict) {
        
        // 此处不判断重复，因为用户可能多次 @ 某个用户
        [self.atUsersDictList addObject:atUserDict];
        
        NSArray *keyArr = atUserDict.allKeys;
        NSString *key = (NSString *)[keyArr firstObject];
    
        NSString *value;
        if ([key isEqualToString:UserManager.userInfo.userUID]) {
            value = LanguageToolMatch(@"我自己");
        } else {
            // 群聊优先展示 showName 已在上层控制，这里直接使用传入的显示名
            value = [NSString stringWithFormat:@"%@",atUserDict[key]];
        }
        
        //获取当前textview光标的位置
        NSInteger index = self.tvContent.selectedRange.location;
        NSString *insertText = [NSString stringWithFormat:ZATFormat,value];
        NSInteger insertLength = insertText.length;
            
        // 先更新已存在的段位置（在插入位置之后的段需要向后偏移）
        [self shiftAtSegmentsFromIndex:index delta:insertLength];
        
        NSMutableAttributedString* mutAtt = [[NSMutableAttributedString alloc]
            initWithAttributedString:self.tvContent.attributedText];
        // 构建带有自定义属性的 @ 片段，标记 uid，便于删除/提交
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:insertText];
        [mutAtt insertAttributedString:att atIndex:index];
        
        // 记录本次插入的 @ 段范围（用于后续删除 @ 数据时的整体删除）
        NSRange segRange = NSMakeRange(index, insertLength);
        
        // 存储 uid 和 range 字符串，避免属性值歧义
        NSDictionary *segInfo = @{
            @"uid": key ?: @"",
            @"range": NSStringFromRange(segRange)
        };

        [self.atSegments addObject:segInfo];
            
        self.tvContent.attributedText = mutAtt;
        [self configAtInfo];
        [self calculateFunctionFrame];

        [self.tvContent becomeFirstResponder];
        self.tvContent.selectedRange = NSMakeRange(index + insertLength, 0);
        
    }else{
        //获取当前textview光标的位置
        NSInteger index = self.tvContent.selectedRange.location;
        
        NSMutableAttributedString* mutAtt = [[NSMutableAttributedString alloc]
            initWithAttributedString:self.tvContent.attributedText];
        NSAttributedString* att =
            [[NSAttributedString alloc] initWithString:@"@"];
        [mutAtt insertAttributedString:att atIndex:index];
        
        self.tvContent.attributedText = mutAtt;
        [self configAtInfo];
        [self calculateFunctionFrame];

    
        [self.tvContent becomeFirstResponder];
        self.tvContent.selectedRange = NSMakeRange(index + @"@".length, 0);
    }
    //配置一下当前输入款的基本字体大小
    self.tvContent.font = FONTR(16);
}

- (void)configAtUserInfoList:(NSArray *)atUserDictList {
    if (!atUserDictList) {
        self.atUsersDictList = [NSMutableArray new];
        return;
    }
    
    self.atUsersDictList = [atUserDictList mutableCopy];
}

- (void)configAtSegmentsInfoList:(NSArray *)atSegmentsInfoList {
    if (!atSegmentsInfoList || atSegmentsInfoList.count == 0) {
        self.atSegments = [NSMutableArray new];
        return;
    }
    self.atSegments = [atSegmentsInfoList mutableCopy];
    // 4) 回显：按 atSegments 高亮，刷新高度
    [self configAtInfo];
}

// 根据当前显示文本重新定位每个 @ 片段，避免沿用原消息中的转义坐标。
- (void)editAtMessageWithAtUserInfoList:(NSArray *)atUserDictList {
    self.atUsersDictList = [atUserDictList mutableCopy] ?: NSMutableArray.array;
    self.atSegments = NSMutableArray.array;
    NSString *displayText = self.inputContentStr ?: @"";
    NSUInteger searchLocation = 0;
    for (NSDictionary *atUser in self.atUsersDictList) {
        NSString *userID = atUser.allKeys.firstObject;
        NSString *nickname = [atUser objectForKey:userID];
        if ([userID isEqualToString:UserManager.userInfo.userUID]) {
            nickname = LanguageToolMatch(@"我自己");
        }
        NSString *mentionText = [NSString stringWithFormat:ZATFormat, nickname ?: @""];
        if (mentionText.length == 0 || searchLocation >= displayText.length) {
            continue;
        }
        NSRange searchRange = NSMakeRange(searchLocation, displayText.length - searchLocation);
        NSRange mentionRange = [displayText rangeOfString:mentionText options:0 range:searchRange];
        if (mentionRange.location == NSNotFound) {
            continue;
        }
        [self.atSegments addObject:@{@"uid" : userID ?: @"", @"range" : NSStringFromRange(mentionRange)}];
        searchLocation = NSMaxRange(mentionRange);
    }
    [self configAtInfo];
    [self calculateFunctionFrame];
}

- (void)setViewType:(ZChatInputViewType)viewType {
    _viewType = viewType;
    if (viewType == ZChatInputViewTypeFileHelper) {
        //文件助手
        NSDictionary *photoAlbum = @{
            @"actionTitle" : LanguageToolMatch(@"相册"),
            @"actionImage" : @"c_input_image",
            @"actionImage_dark" : @"c_input_image_dark",
            @"actionType"  : @(ZChatInputActionTypePhotoAlbum)
        };
        NSDictionary *filePicker = @{
            @"actionTitle" : LanguageToolMatch(@"文件"),
            @"actionImage" : @"c_input_file",
            @"actionImage_dark" : @"c_input_file_dark",
            @"actionType"  : @(ZChatInputActionTypeFile)
        };
        NSDictionary *collection = @{
            @"actionTitle" : LanguageToolMatch(@"收藏"),
            @"actionImage" : @"c_input_collection",
            @"actionImage_dark" : @"c_input_collection_dark",
            @"actionType"  : @(ZChatInputActionTypeCollection)
        };
        if (_actionList) {
            [_actionList removeAllObjects];
        } else {
            _actionList = [NSMutableArray array];
        }
        if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"]) {
            [_actionList addObject:photoAlbum];
        }
        if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"true"]) {
            [_actionList addObject:filePicker];
        }
        [_actionList addObject:collection];
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(DScreenWidth * 1.0 / (_actionList.count), DWScale(44));
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        [_actionCollectionView setCollectionViewLayout:layout];
        
        [_actionCollectionView reloadData];
    }
}

//配置翻译按钮状态
- (void)configTranslateBtnStatus:(NSInteger)status {
    NSArray *tempActionList = [NSArray arrayWithArray:_actionList];
    for (int i = 0; i<tempActionList.count; i++) {
        NSDictionary *tempDict = (NSDictionary *)[tempActionList objectAtIndex:i];
        NSInteger actionType = [[tempDict objectForKeySafe:@"actionType"] integerValue];
        if (actionType == ZChatInputActionTypeTranslate) {//翻译
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
            if (status == 1) {
                [dict setObjectSafe:@"c_input_translate_s" forKey:@"actionImage"];
                [dict setObjectSafe:@"c_input_translate_s" forKey:@"actionImage_dark"];

            } else {
                [dict setObjectSafe:@"c_input_translate_n" forKey:@"actionImage"];
                [dict setObjectSafe:@"c_input_translate_n_dark" forKey:@"actionImage_dark"];
            }
            [_actionList replaceObjectAtIndex:i withObject:dict];
            [self.actionCollectionView reloadData];
        }
    }
}


#pragma mark - 监听UITextView内容变化
- (void)textViewContentChanged:(NSNotification *)notification {
    
    self.tvContent.typingAttributes = _typingAttributes;
    [self calculateFunctionFrame];
    
    [self configAtInfo];
    
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction  API_AVAILABLE(ios(10.0)){
    return NO;
}

//输入框中的文字要随着文字改变实时将 @ 词高亮
- (void)textViewDidChange:(UITextView *)textView {
    //DLog(@"输入内容:%@",textView.text);
    //[self calculateFunctionFrame];
    //直接赋值的时候不触发该回调，采用通知监听内容变化
    
    self.tvContent.typingAttributes = _typingAttributes;
    
    // 先根据上次文本变化调整 atSegments 位置，再高亮
    if (self.lastTextChangeDelta != 0) {
        NSLog(@"🔄 调整 atSegments 位置: location=%lu, delta=%ld, 段数量=%lu", 
              (unsigned long)self.lastTextChangeLocation, 
              (long)self.lastTextChangeDelta,
              (unsigned long)self.atSegments.count);
        
        [self shiftAtSegmentsFromIndex:self.lastTextChangeLocation delta:self.lastTextChangeDelta];
        self.lastTextChangeDelta = 0; // 重置
        
        NSLog(@"✅ 调整后 atSegments: %@", self.atSegments);
    }
    
    // 保存当前光标位置，避免 configAtInfo 后光标跳动
    NSRange currentCursorRange = textView.selectedRange;
    
    [self configAtInfo];
    
    // 恢复光标位置（如果 configAtInfo 改变了光标位置）
    if (!NSEqualRanges(currentCursorRange, textView.selectedRange)) {
        // 确保光标位置不越界
        NSUInteger maxLocation = textView.text.length;
        NSUInteger safeLocation = MIN(currentCursorRange.location, maxLocation);
        textView.selectedRange = NSMakeRange(safeLocation, 0);
    }
    
    // 实时本地草稿落库（MMKV），不更新DB
    NSString *tvContent = self.inputContentStr;
    NSArray *atList = self.atUsersDictList ?: @[];
    NSArray *atSegments = self.atSegments ?: @[];
    BOOL hasText = ![NSString isNil:tvContent];
    BOOL hasAt = atList.count > 0;
    NSMutableDictionary *draft = [NSMutableDictionary dictionary];
    if (hasText) {
        [draft setValue:tvContent forKey:@"draftContent"];
        if (hasAt) {
            [draft setValue:atList forKey:@"atUser"];
            [draft setValue:atSegments forKey:@"atSegments"];
        }
    }
   
    if (draft.count > 0) {
        [NoaDraftStore saveDraft:draft forSession:self.sessionID];
    } else {
        [NoaDraftStore deleteDraftForSession:self.sessionID];
    }
}

//删除时 @ 词要整体删除
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    textView.typingAttributes = _typingAttributes;
    
    //回车
    /*
    if ([text isEqualToString:@"\n"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(functionViewActionWith:withAtUserList:)]) {
            [_delegate functionViewActionWith:5 withAtUserList:[self.atUsersDictList copy]];
            self.atUsersDictList = nil;
        }
        
        return NO;
    }
    */
    
    
    if ([text isEqualToString:@""]) {
        //删除
        NSRange selectRange = textView.selectedRange;
        if (selectRange.length > 0) {
            //用户长按 选择文本时不处理
            return YES;
        }
        
        // 使用 _atSegments：若删除范围命中某个 @ 段（交叉/紧邻末尾/段内退格），只删除命中的单个段
        NSMutableAttributedString *mttStr = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
        // 计算退格将要删除的字符（length==0 时）
        NSRange backspaceRange = (range.length > 0)
            ? range
            : (range.location > 0 ? NSMakeRange(range.location - 1, 1) : NSMakeRange(NSNotFound, 0));

        for (NSInteger i = self.atSegments.count - 1; i >= 0; i--) {
            NSDictionary *seg = self.atSegments[i];
            // segRange：某个已记录的“ @ 用户名+空格”片段的整体范围。
            NSRange segRange = NSRangeFromString((NSString *)seg[@"range"]);
            // 至少包含 @ 与空格，故判断长度<2的直接舍弃
            if (segRange.length < 2) {
                continue;
            }

            // 判断当前代理返回的range是否与 @ 用户信息有交集(示例: “@Jack”中，我拖拽选择了“@Jack”中的任意一部分,然后点击删除键，只要选择的对象与 @ 段有交集，就返回YES)
            BOOL hitBySelectionOverlap = (range.length > 0) && (NSIntersectionRange(range, segRange).length > 0);
            // 判断当前range是否在 @ 消息的内部(示例: 光标停在“@Jack”中间，比如“@Ja|ck ”，此时按退格（将删除‘a’）。如果被删的字符在segRange内，就返回YES)
            BOOL hitByBackspaceInside  = (backspaceRange.location != NSNotFound) && (NSIntersectionRange(backspaceRange, segRange).length > 0);
            // 判断当前当前是否紧邻最后一个字符(示例:光标位于“@Jack”之后，形如“@Jack |欢迎”，若此时删除，就返回YES)
            BOOL hitByTrailingBackspace = (range.length == 0 && range.location == NSMaxRange(segRange));

            if (hitBySelectionOverlap || hitByBackspaceInside || hitByTrailingBackspace) {
                // 边界检查：确保 segRange 不越界
                if (NSMaxRange(segRange) > mttStr.length || segRange.length == 0) {
                    // 越界或无效范围，跳过此段
                    continue;
                }
                
                // 从 atUsersDictList 移除对应 uid
                NSString *uid = (NSString *)seg[@"uid"];
                if (uid.length > 0) {
                    NSArray *tempAtUsetDictList = [NSMutableArray arrayWithArray:self.atUsersDictList];
                    for (int j = 0; j < tempAtUsetDictList.count; j++) {
                        NSDictionary *atUserDict = (NSDictionary *)[tempAtUsetDictList objectAtIndexSafe:j];
                        NSString *key = (NSString *)[[atUserDict allKeys] firstObject];
                        if ([key isEqualToString:uid]) {
                            [self.atUsersDictList removeObjectAtIndex:j];
                            break;
                        }
                    }
                }
                // 删除文本与记录，位移其后段
                [mttStr deleteCharactersInRange:segRange];
                textView.attributedText = mttStr;
                
                // 设置光标位置，确保不越界
                NSUInteger cursorLocation = MIN(segRange.location, mttStr.length);
                [textView setSelectedRange:NSMakeRange(cursorLocation, 0)];
                
                [self.atSegments removeObjectAtIndex:i];
                [self shiftAtSegmentsFromIndex:segRange.location delta:-(NSInteger)segRange.length];
                [self calculateFunctionFrame];
                
                // 标记正在进行文本变化，避免 textViewDidChangeSelection: 误判
                self.isTextChanging = YES;
                
                // 重置 lastTextChangeDelta，避免 textViewDidChange: 中再次调整
                self.lastTextChangeDelta = 0;
                
                return NO; // 只删除一个段
            }
        }
        // 未命中任何 @ 段：普通删除
        // 不在这里调用 shiftAtSegmentsFromIndex，让 textViewDidChange: 来统一处理
        
        // 标记正在进行文本变化，避免 textViewDidChangeSelection: 误判
        self.isTextChanging = YES;
        
        // 记录文本变化信息，供 textViewDidChange: 使用
        // 删除操作：如果 range.length > 0，说明选择了文本删除；否则是退格删除1个字符
        NSInteger deleteLength = (range.length > 0) ? range.length : 1;
        NSInteger delta = -(NSInteger)deleteLength;
        self.lastTextChangeDelta = delta;
        // 删除位置：如果 range.length > 0，位置就是 range.location；否则是 range.location - 1
        self.lastTextChangeLocation = (range.length > 0) ? range.location : (range.location > 0 ? range.location - 1 : 0);
        
        NSLog(@"📝 普通删除: range=%@, delta=%ld, location=%lu, atSegments=%@", 
              NSStringFromRange(range), 
              (long)delta,
              (unsigned long)self.lastTextChangeLocation,
              self.atSegments);
        
        return YES;
    }
    
    // 添加输入文字
    
    //限制输入框输入字数
    if (self.tvContent.text.length > Input_Text_Length) {
        return NO;
//        self.tvContent.text = [self.tvContent.text substringToIndex:Input_Text_Length];
    }
    
    if ([text isEqualToString:@"@"]) {
        // 输入 @ 让选择需要 @ 的人
        if (_isShowAtList) {
            //输入 @
            [textView unmarkText];
            NSInteger index = self.tvContent.text.length;
            if (self.tvContent.isFirstResponder) {
                index = self.tvContent.selectedRange.location + self.tvContent.selectedRange.length;
                [self.tvContent resignFirstResponder];
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(functionViewActionWith:atUserList:atSegmentsList:)]) {
                [_delegate functionViewActionWith:8 atUserList:nil atSegmentsList:nil];
            }
            
            return YES;
        } else {
            return YES;
        }
    }

    // 检查是否在 @ 段内部插入文字（不允许）
    for (NSDictionary *seg in self.atSegments) {
        NSRange segRange = NSRangeFromString((NSString *)seg[@"range"]);
        if (segRange.length < 2) { continue; }
        
        // @ 段的内部范围（不包括开头的 @ 和结尾的空格）
        NSRange inner = NSMakeRange(segRange.location + 1, segRange.length - 2);
        
        // 如果要插入的位置在 @ 段内部，拒绝插入
        if (inner.length > 0 && range.location > segRange.location && range.location < NSMaxRange(segRange)) {
            NSLog(@"🚫 拒绝在 @ 段内插入文字: range=%@, segRange=%@", NSStringFromRange(range), NSStringFromRange(segRange));
            return NO;
        }
    }
    
    // 记录文本变化信息，供 textViewDidChange: 使用
    NSInteger delta = (NSInteger)text.length - (NSInteger)range.length;
    self.lastTextChangeDelta = delta;
    self.lastTextChangeLocation = range.location;
    
    // 保存光标位置（输入后光标会在 range.location + text.length）
    self.lastCursorRange = NSMakeRange(range.location + text.length, 0);
    
    // 标记正在进行文本变化，避免 textViewDidChangeSelection: 误判
    self.isTextChanging = YES;

    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}


// 通过此方法限制，禁止光标落在 @ 段中间（使用 atSegments，保证与高亮/删除规则一致）
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSRange sel = textView.selectedRange;
    if (sel.length > 0) { return; } // 选区时不干预
    
    // 如果正在进行文本变化（插入/删除），不干预光标位置
    // 因为 shouldChangeTextInRange: 已经正确处理了光标位置
    if (self.isTextChanging) {
        self.isTextChanging = NO; // 重置标志
        self.lastSelectionLocation = sel.location; // 更新记录
        return;
    }

    // 判断用户移动方向：<0 向左，>0 向右
    NSInteger delta = sel.location - self.lastSelectionLocation;

    for (NSDictionary *seg in self.atSegments) {
        NSRange segRange = NSRangeFromString((NSString *)seg[@"range"]);
        if (segRange.length < 2) { continue; }
        NSRange inner = NSMakeRange(segRange.location + 1, segRange.length - 2);
        if (inner.length > 0 && NSLocationInRange(sel.location, inner)) {
            if (delta < 0) {
                // 向左 → 放到段前
                textView.selectedRange = NSMakeRange(segRange.location, 0);
            } else {
                // 向右或未知 → 放到段后（空格之后）
                textView.selectedRange = NSMakeRange(NSMaxRange(segRange), 0);
            }
            self.lastSelectionLocation = textView.selectedRange.location;
            return;
        }
    }
    // 未命中任何段，更新记录
    self.lastSelectionLocation = sel.location;
}
- (void)calculateFunctionFrame {
    
    CGFloat tvH = [self getHeightWith:self.tvContent width:ZTVContentW];
    
    [self updateBtnEmojiConstraints];
    
    if (tvH != self.tvContent.height) {
        
        //高度发生变化
        if (_delegate && [_delegate respondsToSelector:@selector(functionViewHeightChanged:)]) {
            [_delegate functionViewHeightChanged:(tvH + DWScale(84))];
        }
        
        [_viewContent mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(DWScale(16));//DWScale(48)
            make.top.equalTo(self).offset(DWScale(6));
            make.size.mas_equalTo(CGSizeMake(ZViewContentW, tvH + DWScale(22)));
        }];
        
    }
};
//计算输入框高度
- (CGFloat)getHeightWith:(UITextView *)textView width:(CGFloat)tvWidth {
    
    CGSize size = [textView sizeThatFits:CGSizeMake(tvWidth, MAXFLOAT)];
    
    if (size.height <= DWScale(24)) {
        return DWScale(24);
    }
    
    if (size.height > DWScale(100)) {
        return DWScale(100);
    }
    
    return size.height + DWScale(5);
}
#pragma mark - 交互事件
//更多功能
- (void)btnMoreClick {
    
    //隐藏表情
    if (_btnEmoji.selected) {
        if (_delegate && [_delegate respondsToSelector:@selector(functionViewActionWith:atUserList:atSegmentsList:)]) {
            [_delegate functionViewActionWith:6 atUserList:nil atSegmentsList:nil];
        }
    }
    
    //键盘消失
    [_tvContent resignFirstResponder];
    if (_delegate && [_delegate respondsToSelector:@selector(functionViewActionWith:atUserList:atSegmentsList:)]) {
        [_delegate functionViewActionWith:1 atUserList:nil atSegmentsList:nil];
    }
    
}
//表情
- (void)btnEmojiClick {
    if (_btnEmoji.selected) {
        _btnEmoji.selected = NO;
        //隐藏表情，显示键盘
        [self.tvContent becomeFirstResponder];
        [self updateBtnEmojiConstraints];
    }else {
        //显示表情
        [self.tvContent resignFirstResponder];
        _btnEmoji.selected = YES;
        _btnVoice.selected = YES;
        [self updateBtnEmojiConstraints];
        
        if (_delegate && [_delegate respondsToSelector:@selector(functionViewActionWith:atUserList:atSegmentsList:)]) {
            [_delegate functionViewActionWith:2 atUserList:nil atSegmentsList:nil];
        }
    }
}
//发送
- (void)btnVoiceClick {
    if (_btnVoice.selected) {
        //发送
        //[_tvContent resignFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(functionViewActionWith:atUserList:atSegmentsList:)]) {
            [_delegate functionViewActionWith:5 atUserList:[self.atUsersDictList copy] atSegmentsList:[self.atSegments copy]];
            self.atUsersDictList = nil;
            self.atSegments = nil;
        }
    }else{
        //显示语音输入视图
        WeakSelf
        [ZTOOL getMicrophoneAuth:^(BOOL granted) {
            DLog(@"麦克风权限:%d",granted);
            if (granted) {
                [ZTOOL doInMain:^{
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(functionViewActionWith:atUserList:atSegmentsList:)]) {
                        [weakSelf.delegate functionViewActionWith:3 atUserList:nil atSegmentsList:nil];
                    }
                }];
            }else {
                [HUD showMessage:LanguageToolMatch(@"需要获取麦克风权限")];
            }
        }];
    }
}
//更新表情试图的布局
- (void)updateBtnEmojiConstraints{
    
    CGFloat tvH = [self getHeightWith:self.tvContent width:ZTVContentW];
    
    if (_btnEmoji.selected) {
        
        [_btnEmoji mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (tvH > DWScale(24)) {
                make.bottom.mas_equalTo(_viewContent.mas_bottom).offset(-DWScale(5));
            }else{
                make.centerY.mas_equalTo(_tvContent);
            }
            make.trailing.mas_equalTo(_viewContent).offset(-DWScale(4));
            make.size.mas_equalTo(CGSizeMake(DWScale(34), DWScale(34)));
        }];
        
    }else{
        
        [_btnEmoji mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (tvH > DWScale(24)) {
                make.bottom.mas_equalTo(_viewContent.mas_bottom).offset(-DWScale(11));
            }else{
                make.centerY.mas_equalTo(self.tvContent);
            }
            make.trailing.equalTo(_viewContent).offset(-DWScale(10));
            make.size.mas_equalTo(CGSizeMake(DWScale(22), DWScale(22)));
        }];
        
    }
}

#pragma mark - 监听键盘
- (void)systemKeyboardWillShow:(NSNotification *)notification {
    
    _btnVoice.selected = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(functionViewActionWith:atUserList:atSegmentsList:)]) {
        [_delegate functionViewActionWith:6 atUserList:nil atSegmentsList:nil];
    }
    
    if (_btnEmoji.selected) _btnEmoji.selected = NO;
    
//    self.tvContent.placeHolderLabel.hidden = YES;
}
- (void)systemKeyboardWillHide:(NSNotification *)notification {
    
//    _btnVoice.selected = NO;
    if (self.tvContent.attributedText.length>0 || ![NSString isNil:self.tvContent.text]) {
        _btnVoice.selected = YES;
    }else{
        _btnVoice.selected = NO;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(functionViewActionWith:atUserList:atSegmentsList:)]) {
        [_delegate functionViewActionWith:7 atUserList:nil atSegmentsList:nil];
    }
}

#pragma mark - 私有方法
// 在文本发生插入/删除后，批量平移后续的 @ 段起始位置
- (void)shiftAtSegmentsFromIndex:(NSUInteger)editLocation delta:(NSInteger)delta {
    if (delta == 0 || self.atSegments.count == 0) {
        return;
    }
    
    for (NSInteger i = 0; i < self.atSegments.count; i++) {
        NSMutableDictionary *seg = [self.atSegments[i] mutableCopy];
        NSRange segRange = NSRangeFromString((NSString *)seg[@"range"]);
        if (segRange.location >= editLocation) {
            NSInteger newLoc = (NSInteger)segRange.location + delta;
            if (newLoc < 0) {
                newLoc = 0;
            }
            segRange.location = (NSUInteger)newLoc;
            seg[@"range"] = NSStringFromRange(segRange);
            self.atSegments[i] = seg;
        }
    }
}

//@用户信息配置(颜色)
- (void)configAtInfo {
    UITextRange *selectedRange = self.tvContent.markedTextRange;
    NSString *newText = [self.tvContent textInRange:selectedRange];

    if (newText.length < 1) {
        // 高亮输入框中的@
        UITextView *textView = _tvContent;
        NSRange range = textView.selectedRange;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
        
        // 保存原始长度，避免在异步回调中访问可能已释放的对象
        NSUInteger originalLength = string.length;
        
        self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
            // 使用保存的原始长度，避免访问可能已释放的对象
            NSUInteger safeLength = originalLength;
            if (safeLength > 0) {
                if (themeIndex == 1) {
                    [string addAttribute:NSForegroundColorAttributeName value:COLORWHITE range:NSMakeRange(0, safeLength)];
                }else {
                    [string addAttribute:NSForegroundColorAttributeName value:COLOR_11 range:NSMakeRange(0, safeLength)];
                }
            }
        };
        [string addAttribute:NSFontAttributeName value:FONTR(16) range:NSMakeRange(0, string.string.length)];
        
        // 基于 atSegments 进行高亮，保证与删除/光标规则一致（高亮到末尾空格前）
        if (self.atSegments && self.atSegments.count > 0) {
            for (NSDictionary *seg in self.atSegments) {
                NSRange segRange = NSRangeFromString((NSString *)seg[@"range"]);
                if (segRange.length < 2) { continue; } // 至少包含 '@' 与末尾空格
                if (NSMaxRange(segRange) > string.length) { continue; } // 越界保护
                NSRange highlightRange = NSMakeRange(segRange.location, segRange.length - 1);
                [string addAttribute:NSForegroundColorAttributeName value:COLOR_5966F2 range:highlightRange];
            }
        }
        
        textView.attributedText = string;
        textView.selectedRange = range;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _actionList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatInputActionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatInputActionCell class]) forIndexPath:indexPath];
    NSDictionary *dict = (NSDictionary *)[_actionList objectAtIndexSafe:indexPath.row];
    NSString *actionImageName = [NSString stringWithFormat:@"%@", [dict objectForKeySafe:@"actionImage"]];
    NSString *actionImageDarkName = [NSString stringWithFormat:@"%@", [dict objectForKeySafe:@"actionImage_dark"]];
    [cell.ivAction setTkThemeimages:@[[UIImage imageNamed:actionImageName], [UIImage imageNamed:actionImageDarkName]]];
    cell.cellIndex = indexPath;
    cell.delegate = self;
    return cell;
}

#pragma mark - ZChatInputActionCellDelegate
- (void)actionCellSelected:(NSIndexPath *)cellIndex {
    NSDictionary *dict = (NSDictionary *)[_actionList objectAtIndexSafe:cellIndex.row];
    
    ZChatInputActionType actionType = [[dict objectForKeySafe:@"actionType"] integerValue];
    
    switch (actionType) {
        case ZChatInputActionTypePhotoAlbum://相册
        {
            //需要检测用户角色信息，是否可以进行图片、视频
            WeakSelf
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            [dict setValue:@"UPIMAGEVIDEOFILE" forKey:@"authorityType"];
            [IMSDKManager userGetUserAuthorityWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                NSLog(@"!!!%@",data);
                BOOL resultData = [data boolValue];
                if (resultData) {
                    //有操作权限
                    [weakSelf functionViewBottomAction:actionType];
                }else {
                    //没有操作权限
                    [HUD showMessage:LanguageToolMatch(@"无操作权限")];
                }
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        }
            break;
        case ZChatInputActionTypeFile://文件
        {
            //需要检测用户角色信息，是否可以进行文件
            WeakSelf
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            [dict setValue:@"UPFILE" forKey:@"authorityType"];
            [IMSDKManager userGetUserAuthorityWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                NSLog(@"!!!%@",data);
                BOOL resultData = [data boolValue];
                if (resultData) {
                    //有操作权限
                    [weakSelf functionViewBottomAction:actionType];
                }else {
                    //没有操作权限
                    [HUD showMessage:LanguageToolMatch(@"无操作权限")];
                }
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        }
            break;
            
        default:
        {
            [self functionViewBottomAction:actionType];
        }
            break;
    }
}

- (void)functionViewBottomAction:(ZChatInputActionType)actionType {
    if (_delegate && [_delegate respondsToSelector:@selector(functionViewBottomActionWith:)]) {
        [_delegate functionViewBottomActionWith:actionType];
    }
}

#pragma mark - 消息编辑模式
// 切换编辑模式并保证重复赋值不会重复创建按钮或丢失功能列表。
- (void)setEditMode:(BOOL)isEditMode {
    if (_isEditMode == isEditMode) {
        return;
    }
    _isEditMode = isEditMode;
    if (isEditMode) {
        [self enterMessageEditMode];
        return;
    }
    [self exitMessageEditMode];
}

// 返回当前编辑模式状态，供外层控制器协调菜单和键盘行为。
- (BOOL)isEditMode {
    return _isEditMode;
}

// 进入编辑模式：保留翻译入口、扩展输入框并显示确认/取消按钮。
- (void)enterMessageEditMode {
    self.originalActionList = [self.actionList mutableCopy];
    NSMutableArray *editActions = NSMutableArray.array;
    for (NSDictionary *action in self.actionList) {
        if ([[action objectForKeySafe:@"actionType"] integerValue] == ZChatInputActionTypeTranslate) {
            [editActions addObject:action];
            break;
        }
    }
    self.actionList = editActions;
    self.actionCollectionLayout.itemSize = CGSizeMake(DWScale(44), DWScale(44));
    self.actionCollectionLayout.sectionInset = UIEdgeInsetsMake(0, DWScale(16), 0, 0);
    [self.actionCollectionView reloadData];

    [self.viewContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.trailing.equalTo(self).offset(-DWScale(16));
        make.top.equalTo(self).offset(DWScale(6));
        make.height.mas_equalTo(MAX(DWScale(44), self.viewContent.height));
    }];
    self.btnVoice.hidden = YES;
    [self createMessageEditButtons];
    [self layoutIfNeeded];
}

// 退出编辑模式：恢复原功能列表和普通输入框布局。
- (void)exitMessageEditMode {
    if (self.originalActionList) {
        self.actionList = [self.originalActionList mutableCopy];
        self.originalActionList = nil;
    }
    CGFloat itemWidth = self.actionList.count > 0 ? DScreenWidth / self.actionList.count : DScreenWidth;
    self.actionCollectionLayout.itemSize = CGSizeMake(itemWidth, DWScale(44));
    self.actionCollectionLayout.sectionInset = UIEdgeInsetsZero;
    [self.actionCollectionView reloadData];

    CGFloat currentHeight = MAX(DWScale(44), self.viewContent.height);
    [self.viewContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(DWScale(16));
        make.top.equalTo(self).offset(DWScale(6));
        make.width.mas_equalTo(ZViewContentW);
        make.height.mas_equalTo(currentHeight);
    }];
    self.btnVoice.hidden = NO;
    [self removeMessageEditButtons];
    [self layoutIfNeeded];
}

// 创建编辑确认和取消按钮；按钮位于底部功能栏右侧，不遮挡输入正文。
- (void)createMessageEditButtons {
    if (self.btnEditConfirm || self.btnEditCancel) {
        return;
    }
    self.btnEditConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnEditConfirm setImage:ImgNamed(@"function_edit_message_sure") forState:UIControlStateNormal];
    self.btnEditConfirm.layer.cornerRadius = DWScale(6);
    self.btnEditConfirm.layer.masksToBounds = YES;
    self.btnEditConfirm.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [self.btnEditConfirm addTarget:self action:@selector(messageEditConfirmClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnEditConfirm];
    [self.btnEditConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-DWScale(16));
        make.centerY.equalTo(self.actionCollectionView);
        make.size.mas_equalTo(CGSizeMake(DWScale(40), DWScale(24)));
    }];

    self.btnEditCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnEditCancel setImage:ImgNamed(@"function_edit_message_cancle") forState:UIControlStateNormal];
    self.btnEditCancel.layer.cornerRadius = DWScale(6);
    self.btnEditCancel.layer.masksToBounds = YES;
    self.btnEditCancel.layer.borderWidth = 1;
    self.btnEditCancel.layer.tkThemeborderColors = @[COLOR_99, COLOR_99_DARK];
    [self.btnEditCancel addTarget:self action:@selector(messageEditCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnEditCancel];
    [self.btnEditCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.btnEditConfirm.mas_leading).offset(-DWScale(24));
        make.centerY.equalTo(self.actionCollectionView);
        make.size.mas_equalTo(CGSizeMake(DWScale(40), DWScale(24)));
    }];
}

// 移除编辑态按钮，避免退出后继续拦截底部功能栏点击。
- (void)removeMessageEditButtons {
    [self.btnEditConfirm removeFromSuperview];
    [self.btnEditCancel removeFromSuperview];
    self.btnEditConfirm = nil;
    self.btnEditCancel = nil;
}

// 将确认事件交给总输入框，再由聊天控制器提交编辑请求。
- (void)messageEditConfirmClick {
    if ([self.delegate respondsToSelector:@selector(functionViewEditConfirm)]) {
        [self.delegate functionViewEditConfirm];
    }
}

// 将取消事件交给总输入框恢复普通输入状态。
- (void)messageEditCancelClick {
    if ([self.delegate respondsToSelector:@selector(functionViewEditCancel)]) {
        [self.delegate functionViewEditCancel];
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)atUsersDictList {
    if (!_atUsersDictList) {
        _atUsersDictList = [NSMutableArray array];
    }
    return _atUsersDictList;
}

- (NSMutableArray<NSDictionary *> *)atSegments {
    if (!_atSegments) {
        _atSegments = [NSMutableArray array];
    }
    return _atSegments;
}

- (NoaChatTextView *)tvContent {
    if (!_tvContent) {
        _tvContent = [NoaChatTextView new];
        _tvContent.isCanPerform = YES;
        _tvContent.backgroundColor = UIColor.clearColor;
        _tvContent.font = FONTR(16);
        _tvContent.tkThemetextColors = @[COLOR_11, COLORWHITE];
        _tvContent.typingAttributes = _typingAttributes;
        //_tvContent.returnKeyType = UIReturnKeySend;
        _tvContent.delegate = self;
        [_tvContent setAutocorrectionType:UITextAutocorrectionTypeNo];
    }
    return _tvContent;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
