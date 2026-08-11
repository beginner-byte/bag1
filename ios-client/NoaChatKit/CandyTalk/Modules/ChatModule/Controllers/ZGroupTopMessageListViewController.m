//
//  ZGroupTopMessageListViewController.m
//  NoaChatKit
//
//  Created by Auto on 2025/1/15.
//

#import "ZGroupTopMessageListViewController.h"
#import "NoaMessageBaseCell.h"
#import "NoaMessageTextCell.h"
#import "NoaMessageReferenceCell.h"
#import "NoaMessageImageCell.h"
#import "NoaMessageVideoCell.h"
#import "NoaMessageAtUserCell.h"
#import "NoaMessageFileCell.h"
#import "NoaMessageVoiceCell.h"
#import "NoaMessageGeoCell.h"
#import "NoaMergeMessageRecordCell.h"
#import "NoaMessageStickersCell.h"
#import "NoaMessageGameStickersCell.h"
#import "NoaMessageCardCell.h"
#import "NoaMessageModel.h"
#import "NoaMessageTimeTool.h"
#import "NoaToolManager.h"
#import "NoaChatViewController.h"
#import "NoaMessageContentBaseCell.h"
#import <objc/runtime.h>
#import <MJRefresh/MJRefresh.h>
#import "NoaMessageAlertView.h"
#import "NoaUserRoleAuthorityModel.h"
#import "NoaMessageTools.h"
#import "NoaChatInputEmojiManager.h"
@interface ZGroupTopMessageListViewController () <UITableViewDelegate, UITableViewDataSource, ZMessageBaseCellDelegate>

@property (nonatomic, strong) NSMutableArray<NoaMessageModel *> *messageList;

@end

@implementation ZGroupTopMessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitleStr = LanguageToolMatch(@"置顶消息");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
    
    self.messageList = [NSMutableArray array];
    
    [self setupUI];
    // 根据会话类型调用不同的请求方法
    if (self.chatType == CIMChatType_SingleChat) {
        [self requestSingleTopMessageList];
    } else {
        [self requestGroupTopMessageList];
    }
}

#pragma mark - UI
- (void)setupUI {
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
    self.baseTableView.estimatedRowHeight = 0;
    self.baseTableView.estimatedSectionHeaderHeight = 0;
    self.baseTableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    
    // 添加下拉刷新
    WeakSelf;
    self.baseTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.chatType == CIMChatType_SingleChat) {
            [weakSelf requestSingleTopMessageList];
        } else {
            [weakSelf requestGroupTopMessageList];
        }
    }];
}

#pragma mark - 数据请求
- (void)requestGroupTopMessageList {
    if (!self.groupId.length) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:self.groupId forKey:@"groupId"];
    
    WeakSelf;
    [HUD showActivityMessage:@"" inView:self.view];
    [IMSDKManager MessageQueryGroupTopMsgListWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [weakSelf.baseTableView.mj_header endRefreshing];
        // data 直接就是数组
        NSArray *dataArray = nil;
        if ([data isKindOfClass:[NSArray class]]) {
            dataArray = (NSArray *)data;
        }
        
        if ([dataArray isKindOfClass:[NSArray class]] && dataArray.count > 0) {
            NSMutableArray<NoaMessageModel *> *newMessages = [NSMutableArray array];
            
            for (NSDictionary *dict in dataArray) {
                // 优先从数据库查询消息（如果数据库有，使用数据库的数据，确保 showContent 和 showTranslateContent 正确）
                NSString *smsgId = [dict objectForKeySafe:@"smsgId"];
                NoaIMChatMessageModel *chatMessageModel = nil;
                
                if (weakSelf.groupId.length > 0 && smsgId.length > 0) {
                    // 尝试从数据库查询消息
                    chatMessageModel = [IMSDKManager toolGetOneChatMessageWithServiceMessageID:smsgId sessionID:weakSelf.groupId];
                }
                
                // 如果数据库没有找到，从字典创建
                if (!chatMessageModel) {
                    chatMessageModel = [weakSelf createChatMessageModelFromDict:dict];
                }
                
                if (chatMessageModel) {
                    // 设置 translateStatus（确保有译文时能正确显示）
                    if (chatMessageModel.messageType == CIMChatMessageType_TextMessage || chatMessageModel.messageType == CIMChatMessageType_AtMessage) {
                        if (chatMessageModel.translateStatus == CIMTranslateStatusNone) {
                            if (![NSString isNil:chatMessageModel.translateContent] || ![NSString isNil:chatMessageModel.atTranslateContent] || ![NSString isNil:chatMessageModel.againTranslateContent] || ![NSString isNil:chatMessageModel.againAtTranslateContent]) {
                                chatMessageModel.translateStatus = CIMTranslateStatusSuccess;
                            }
                        } else {
                            if (![NSString isNil:chatMessageModel.translateContent] || ![NSString isNil:chatMessageModel.atTranslateContent] || ![NSString isNil:chatMessageModel.againTranslateContent] || ![NSString isNil:chatMessageModel.againAtTranslateContent]) {
                                chatMessageModel.translateStatus = CIMTranslateStatusSuccess;
                            }
                        }
                    }
                    
                    // 创建 ZMessageModel（会自动计算 showContent 和 showTranslateContent）
                    BOOL isSelf = [chatMessageModel.fromID isEqualToString:UserManager.userInfo.userUID];
                    NoaMessageModel *messageModel = [[NoaMessageModel alloc] initWithMessageModel:chatMessageModel isSelf:isSelf];
                    messageModel.message.messageSendType = CIMChatMessageSendTypeSuccess;
                    
                    // 调试：检查 @消息的关键属性
                    if (chatMessageModel.messageType == CIMChatMessageType_AtMessage) {
                        if ([NSString isNil:messageModel.message.showContent] && messageModel.message.atContent.length > 0) {
                            // 如果 showContent 为空但 atContent 不为空，重新计算
                            if (isSelf) {
                                messageModel.message.showContent = [NoaMessageTools atContenTranslateToShowContent:messageModel.message.atContent atUsersDictList:messageModel.message.atUsersInfoList withMessage:messageModel.message isGetShowName:YES];
                            } else {
                                NSString *translateContent = ![NSString isNil:messageModel.message.atTranslateContent] ? messageModel.message.atTranslateContent : messageModel.message.atContent;
                                messageModel.message.showContent = [NoaMessageTools atContenTranslateToShowContent:translateContent atUsersDictList:messageModel.message.atUsersInfoList withMessage:messageModel.message isGetShowName:YES];
                            }
                            // 重新计算 attStr
                            if (messageModel.message.showContent.length > 0) {
                                messageModel.attStr = [[NoaChatInputEmojiManager sharedManager] attributedString:messageModel.message.showContent];
                                if (messageModel.attStr) {
                                    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                                    style.lineSpacing = 2;
                                    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
                                    [messageModel.attStr addAttributes:dict range:NSMakeRange(0, messageModel.attStr.length)];
                                }
                            }
                        }
                    }
                    
                    // 读取 topType 并保存到关联对象
                    NSInteger topType = [[dict objectForKeySafe:@"topType"] integerValue];
                    objc_setAssociatedObject(messageModel, @"topType", @(topType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                    [newMessages addObject:messageModel];
                }
            }
            
            // 替换数据
            [weakSelf.messageList removeAllObjects];
            [weakSelf.messageList addObjectsFromArray:newMessages];
            
            // 处理消息时间显示
            [weakSelf computeVisibleTime];
            
            [weakSelf.baseTableView reloadData];
        } else {
            [weakSelf.messageList removeAllObjects];
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [weakSelf.baseTableView.mj_header endRefreshing];
        [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
    }];
}

//请求单聊置顶消息列表
- (void)requestSingleTopMessageList {
    if (!self.friendUid.length) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:@(1) forKey:@"type"]; // type=1 查询全部的个人当前会话的所有置顶消息列表
    [params setObjectSafe:self.friendUid forKey:@"friendUid"];
    
    WeakSelf;
    [HUD showActivityMessage:@"" inView:self.view];
    [IMSDKManager MessageQueryUserTopMsgsWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [weakSelf.baseTableView.mj_header endRefreshing];
        // data 直接就是数组
        NSArray *dataArray = nil;
        if ([data isKindOfClass:[NSArray class]]) {
            dataArray = (NSArray *)data;
        }
        
        if ([dataArray isKindOfClass:[NSArray class]] && dataArray.count > 0) {
            NSMutableArray<NoaMessageModel *> *newMessages = [NSMutableArray array];
            
            for (NSDictionary *dict in dataArray) {
                // 优先从数据库查询消息（如果数据库有，使用数据库的数据，确保 showContent 和 showTranslateContent 正确）
                NSString *smsgId = [dict objectForKeySafe:@"smsgId"];
                NoaIMChatMessageModel *chatMessageModel = nil;
                
                if (weakSelf.friendUid.length > 0 && smsgId.length > 0) {
                    // 尝试从数据库查询消息
                    chatMessageModel = [IMSDKManager toolGetOneChatMessageWithServiceMessageID:smsgId sessionID:weakSelf.friendUid];
                }
                
                // 如果数据库没有找到，从字典创建
                if (!chatMessageModel) {
                    chatMessageModel = [weakSelf createChatMessageModelFromDict:dict];
                }
                
                if (chatMessageModel) {
                    // 设置 translateStatus（确保有译文时能正确显示）
                    if (chatMessageModel.messageType == CIMChatMessageType_TextMessage || chatMessageModel.messageType == CIMChatMessageType_AtMessage) {
                        if (chatMessageModel.translateStatus == CIMTranslateStatusNone) {
                            if (![NSString isNil:chatMessageModel.translateContent] || ![NSString isNil:chatMessageModel.atTranslateContent] || ![NSString isNil:chatMessageModel.againTranslateContent] || ![NSString isNil:chatMessageModel.againAtTranslateContent]) {
                                chatMessageModel.translateStatus = CIMTranslateStatusSuccess;
                            }
                        } else {
                            if (![NSString isNil:chatMessageModel.translateContent] || ![NSString isNil:chatMessageModel.atTranslateContent] || ![NSString isNil:chatMessageModel.againTranslateContent] || ![NSString isNil:chatMessageModel.againAtTranslateContent]) {
                                chatMessageModel.translateStatus = CIMTranslateStatusSuccess;
                            }
                        }
                    }
                    
                    // 创建 ZMessageModel（会自动计算 showContent 和 showTranslateContent）
                    BOOL isSelf = [chatMessageModel.fromID isEqualToString:UserManager.userInfo.userUID];
                    NoaMessageModel *messageModel = [[NoaMessageModel alloc] initWithMessageModel:chatMessageModel isSelf:isSelf];
                    messageModel.message.messageSendType = CIMChatMessageSendTypeSuccess;
                    
                    // 调试：检查 @消息的关键属性
                    if (chatMessageModel.messageType == CIMChatMessageType_AtMessage) {
                        if ([NSString isNil:messageModel.message.showContent] && messageModel.message.atContent.length > 0) {
                            // 如果 showContent 为空但 atContent 不为空，重新计算
                            if (isSelf) {
                                messageModel.message.showContent = [NoaMessageTools atContenTranslateToShowContent:messageModel.message.atContent atUsersDictList:messageModel.message.atUsersInfoList withMessage:messageModel.message isGetShowName:YES];
                            } else {
                                NSString *translateContent = ![NSString isNil:messageModel.message.atTranslateContent] ? messageModel.message.atTranslateContent : messageModel.message.atContent;
                                messageModel.message.showContent = [NoaMessageTools atContenTranslateToShowContent:translateContent atUsersDictList:messageModel.message.atUsersInfoList withMessage:messageModel.message isGetShowName:YES];
                            }
                            // 重新计算 attStr
                            if (messageModel.message.showContent.length > 0) {
                                messageModel.attStr = [[NoaChatInputEmojiManager sharedManager] attributedString:messageModel.message.showContent];
                                if (messageModel.attStr) {
                                    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                                    style.lineSpacing = 2;
                                    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
                                    [messageModel.attStr addAttributes:dict range:NSMakeRange(0, messageModel.attStr.length)];
                                }
                            }
                        }
                    }
                    
                    // 读取 topType 并保存到关联对象（单聊使用 type 字段）
                    NSInteger topType = [[dict objectForKeySafe:@"topType"] integerValue];
                    objc_setAssociatedObject(messageModel, @"topType", @(topType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                    [newMessages addObject:messageModel];
                }
            }
            
            // 替换数据
            [weakSelf.messageList removeAllObjects];
            [weakSelf.messageList addObjectsFromArray:newMessages];
            
            // 处理消息时间显示
            [weakSelf computeVisibleTime];
            
            [weakSelf.baseTableView reloadData];
        } else {
            [weakSelf.messageList removeAllObjects];
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [weakSelf.baseTableView.mj_header endRefreshing];
        [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
    }];
}

// 从字典创建 LingIMChatMessageModel
- (NoaIMChatMessageModel *)createChatMessageModelFromDict:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NoaIMChatMessageModel *model = [NoaIMChatMessageModel new];
    
    // 基本字段
    model.msgID = [dict objectForKeySafe:@"msgId"] ?: @"";
    model.serviceMsgID = [dict objectForKeySafe:@"smsgId"] ?: @"";
    model.chatType = [[dict objectForKeySafe:@"ctype"] integerValue];
    model.messageType = [[dict objectForKeySafe:@"mtype"] integerValue];
    model.fromID = [dict objectForKeySafe:@"fromUid"] ?: @"";
    model.fromNickname = [dict objectForKeySafe:@"nick"] ?: @"";
    model.fromIcon = [dict objectForKeySafe:@"icon"] ?: @"";
    model.toID = [dict objectForKeySafe:@"toUid"] ?: @"";
    model.isAck = [[dict objectForKeySafe:@"isAck"] integerValue];
    model.isEncry = [[dict objectForKeySafe:@"isEncry"] boolValue];
    model.snapchat = [[dict objectForKeySafe:@"snapchat"] integerValue];
    model.sendTime = [[dict objectForKeySafe:@"sendTime"] longLongValue];
    model.messageSendType = CIMChatMessageSendTypeSuccess;
    model.referenceMsgId = [dict objectForKeySafe:@"referenceMsgId"] ?: @"";
    model.messageStatus = [[dict objectForKeySafe:@"status"] integerValue];
    
    // 已读状态
    BOOL isRead = [[dict objectForKeySafe:@"isRead"] boolValue];
    if (model.chatType == CIMChatType_SingleChat) {
        if ([model.fromID isEqualToString:UserManager.userInfo.userUID]) {
            model.chatMessageReaded = YES;
        } else {
            model.chatMessageReaded = isRead;
        }
        model.totalNeedReadCount = 1;
        model.haveReadCount = isRead ? 1 : 0;
    } else if (model.chatType == CIMChatType_GroupChat) {
        if ([model.fromID isEqualToString:UserManager.userInfo.userUID]) {
            model.chatMessageReaded = YES;
        } else {
            model.chatMessageReaded = isRead;
        }
        model.totalNeedReadCount = [[dict objectForKeySafe:@"totalNeedReadCount"] integerValue];
        model.haveReadCount = [[dict objectForKeySafe:@"haveReadCount"] integerValue];
    }
    
    model.currentVersionMessageOK = YES;
    
    // 解析 body 字段
    NSString *bodyStr = [dict objectForKeySafe:@"body"];
    if ([bodyStr isKindOfClass:[NSString class]] && bodyStr.length > 0) {
        NSDictionary *bodyDict = [bodyStr mj_JSONObject];
        if ([bodyDict isKindOfClass:[NSDictionary class]]) {
            // 根据消息类型解析 body
            switch (model.messageType) {
                case CIMChatMessageType_TextMessage:
                {
                    model.textContent = [bodyDict objectForKeySafe:@"content"] ?: @"";
                    model.textExt = [bodyDict objectForKeySafe:@"ext"] ?: @"";
                    model.translateContent = [bodyDict objectForKeySafe:@"translate"] ?: @"";
                }
                    break;
                case CIMChatMessageType_AtMessage:
                {
                    // @消息需要特殊处理
                    NSString *content = [bodyDict objectForKeySafe:@"content"] ?: @"";
                    NSString *translate = [bodyDict objectForKeySafe:@"translate"] ?: @"";
                    model.textExt = [bodyDict objectForKeySafe:@"ext"] ?: @"";
                    
                    // 解析 atInfo 数组，转换为 atUsersInfoList 格式
                    NSArray *atInfoArray = [bodyDict objectForKeySafe:@"atInfo"];
                    NSMutableArray *atUsersInfoList = [NSMutableArray array];
                    if ([atInfoArray isKindOfClass:[NSArray class]] && atInfoArray.count > 0) {
                        for (NSDictionary *atInfoDict in atInfoArray) {
                            if ([atInfoDict isKindOfClass:[NSDictionary class]]) {
                                NSString *uId = [atInfoDict objectForKeySafe:@"uId"] ?: @"";
                                NSString *uNick = [atInfoDict objectForKeySafe:@"uNick"] ?: @"";
                                if (uId.length > 0 && uNick.length > 0) {
                                    NSMutableDictionary *atUserDict = [NSMutableDictionary dictionary];
                                    [atUserDict setValue:uNick forKey:uId];
                                    [atUsersInfoList addObject:atUserDict];
                                }
                            }
                        }
                    }
                    model.atUsersInfoList = atUsersInfoList;
                    
                    // 将 content 中的 @昵称 替换为 \vUid\v 格式，生成 atContent
                    // 注意：content 可能是混合格式（同时包含 \vUid\v 和 @昵称），需要统一处理
                    NSMutableString *atContent = [NSMutableString stringWithString:content];
                    if (atUsersInfoList.count > 0) {
                        // 先清理所有 atInfo 中对应的 @昵称（避免重复显示）
                        // 倒序处理，避免索引偏移
                        for (NSInteger i = atUsersInfoList.count - 1; i >= 0; i--) {
                            NSDictionary *atUserDict = atUsersInfoList[i];
                            NSArray *keys = [atUserDict allKeys];
                            if (keys.count > 0) {
                                NSString *uid = keys[0];
                                NSString *nick = [atUserDict objectForKey:uid];
                                if (uid && nick) {
                                    // 检查是否已经存在 \vUid\v 格式
                                    NSString *existingPattern = [NSString stringWithFormat:@"\v%@\v", uid];
                                    if ([atContent containsString:existingPattern]) {
                                        // 已经存在 \vUid\v 格式，清理掉对应的 @昵称（避免重复）
                                        NSString *atPattern1 = [NSString stringWithFormat:@"@%@ ", nick];
                                        NSString *atPattern2 = [NSString stringWithFormat:@"@%@", nick];
                                        [atContent replaceOccurrencesOfString:atPattern1 withString:@"" options:NSLiteralSearch range:NSMakeRange(0, atContent.length)];
                                        [atContent replaceOccurrencesOfString:atPattern2 withString:@"" options:NSLiteralSearch range:NSMakeRange(0, atContent.length)];
                                    } else {
                                        // 不存在 \vUid\v 格式，需要将 @昵称 替换为 \vUid\v
                                        NSString *atPattern1 = [NSString stringWithFormat:@"@%@ ", nick];
                                        NSString *atPattern2 = [NSString stringWithFormat:@"@%@", nick];
                                        NSString *replaceStr = [NSString stringWithFormat:@"\v%@\v", uid];
                                        // 先替换带空格的，再替换不带空格的
                                        [atContent replaceOccurrencesOfString:atPattern1 withString:[replaceStr stringByAppendingString:@" "] options:NSLiteralSearch range:NSMakeRange(0, atContent.length)];
                                        [atContent replaceOccurrencesOfString:atPattern2 withString:replaceStr options:NSLiteralSearch range:NSMakeRange(0, atContent.length)];
                                    }
                                }
                            }
                        }
                    }
                    // 确保 atContent 不为空
                    if (atContent.length == 0) {
                        atContent = [NSMutableString stringWithString:content];
                    }
                    model.atContent = atContent;
                    
                    // 处理翻译内容，同样将 @昵称 替换为 \vUid\v 格式
                    if (translate.length > 0) {
                        NSMutableString *atTranslateContent = [NSMutableString stringWithString:translate];
                        // 注意：translate 可能是混合格式（同时包含 \vUid\v 和 @昵称），需要统一处理
                        if (atUsersInfoList.count > 0) {
                            // 先清理所有 atInfo 中对应的 @昵称（避免重复显示）
                            // 倒序处理，避免索引偏移
                            for (NSInteger i = atUsersInfoList.count - 1; i >= 0; i--) {
                                NSDictionary *atUserDict = atUsersInfoList[i];
                                NSArray *keys = [atUserDict allKeys];
                                if (keys.count > 0) {
                                    NSString *uid = keys[0];
                                    NSString *nick = [atUserDict objectForKey:uid];
                                    if (uid && nick) {
                                        // 检查是否已经存在 \vUid\v 格式
                                        NSString *existingPattern = [NSString stringWithFormat:@"\v%@\v", uid];
                                        if ([atTranslateContent containsString:existingPattern]) {
                                            // 已经存在 \vUid\v 格式，清理掉对应的 @昵称（避免重复）
                                            // 注意：翻译内容中的 @昵称 可能是英文或其他语言（如 @everyone），需要尝试匹配
                                            NSString *atPattern1 = [NSString stringWithFormat:@"@%@ ", nick];
                                            NSString *atPattern2 = [NSString stringWithFormat:@"@%@", nick];
                                            [atTranslateContent replaceOccurrencesOfString:atPattern1 withString:@"" options:NSLiteralSearch range:NSMakeRange(0, atTranslateContent.length)];
                                            [atTranslateContent replaceOccurrencesOfString:atPattern2 withString:@"" options:NSLiteralSearch range:NSMakeRange(0, atTranslateContent.length)];
                                        } else {
                                            // 不存在 \vUid\v 格式，需要将 @昵称 替换为 \vUid\v
                                            // 注意：翻译内容中的 @昵称 可能是英文或其他语言（如 @everyone），需要尝试匹配
                                            NSString *atPattern1 = [NSString stringWithFormat:@"@%@ ", nick];
                                            NSString *atPattern2 = [NSString stringWithFormat:@"@%@", nick];
                                            NSString *replaceStr = [NSString stringWithFormat:@"\v%@\v", uid];
                                            // 先替换带空格的，再替换不带空格的
                                            [atTranslateContent replaceOccurrencesOfString:atPattern1 withString:[replaceStr stringByAppendingString:@" "] options:NSLiteralSearch range:NSMakeRange(0, atTranslateContent.length)];
                                            [atTranslateContent replaceOccurrencesOfString:atPattern2 withString:replaceStr options:NSLiteralSearch range:NSMakeRange(0, atTranslateContent.length)];
                                        }
                                    }
                                }
                            }
                        }
                        // 确保 atTranslateContent 不为空
                        if (atTranslateContent.length == 0) {
                            atTranslateContent = [NSMutableString stringWithString:translate];
                        }
                        model.atTranslateContent = atTranslateContent;
                        model.translateContent = translate; // 同时设置 translateContent
                    } else {
                        model.atTranslateContent = @"";
                        model.translateContent = @"";
                    }
                }
                    break;
                case CIMChatMessageType_ImageMessage:
                {
                    model.imgHeight = [[bodyDict objectForKeySafe:@"height"] floatValue];
                    model.imgWidth = [[bodyDict objectForKeySafe:@"width"] floatValue];
                    model.imgSize = [[bodyDict objectForKeySafe:@"size"] floatValue];
                    model.imgName = [bodyDict objectForKeySafe:@"name"] ?: @"";
                    model.thumbnailImg = [bodyDict objectForKeySafe:@"iImg"] ?: @"";
                    model.imgExt = [bodyDict objectForKeySafe:@"ext"] ?: @"";
                }
                    break;
                default:
                    // 其他类型暂时只解析文本内容
                    model.textContent = [bodyDict objectForKeySafe:@"content"] ?: @"";
                    break;
            }
        }
    }
    
    return model;
}

// 处理消息时间显示
- (void)computeVisibleTime {
    if (self.messageList.count == 0) {
        return;
    }
    
    long long prevSendTime = 0;
    for (NSInteger i = 0; i < self.messageList.count; i++) {
        NoaMessageModel *currentModel = [self.messageList objectAtIndex:i];
        
        if (i == 0) {
            // 第一条消息显示时间
            prevSendTime = currentModel.message.sendTime;
            currentModel.isShowSendTime = YES;
        } else {
            // 如果聊天消息是同一天的，不显示间隔的日期
            BOOL sameDay = [NoaMessageTimeTool isSameDay:currentModel.message.sendTime Time2:prevSendTime];
            currentModel.isShowSendTime = sameDay ? NO : YES;
            prevSendTime = currentModel.message.sendTime;
        }
    }
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaMessageModel *model = [self.messageList objectAtIndex:indexPath.row];
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.messageList.count) {
        return [[UITableViewCell alloc] init];
    }
    
    NoaMessageBaseCell *cell = nil;
    NoaMessageModel *model = [self.messageList objectAtIndex:indexPath.row];
    
    // 去掉cell重用机制，每次都创建新的cell实例（数据源最多40条，性能影响可忽略）
    switch (model.message.messageType) {
        case CIMChatMessageType_TextMessage:    //文本消息
        {
            //文本消息
            if (![NSString isNil:model.message.referenceMsgId]) {
                //引用类文本消息
                cell = [[NoaMessageReferenceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            } else {
                //纯文本消息
                cell = [[NoaMessageTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            }
        }
            break;
        case CIMChatMessageType_AtMessage:       //@消息
        {
            //@消息
            if (![NSString isNil:model.message.referenceMsgId]) {
                //引用类@消息
                cell = [[NoaMessageReferenceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            } else {
                //纯@消息
                cell = [[NoaMessageAtUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            }
        }
            break;
        case CIMChatMessageType_ImageMessage:   //图片消息
        {
            cell = [[NoaMessageImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
            break;
        case CIMChatMessageType_VideoMessage:   //视频消息
        {
            cell = [[NoaMessageVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
            break;
        case CIMChatMessageType_VoiceMessage:   //语音消息
        {
            cell = [[NoaMessageVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
            break;
        case CIMChatMessageType_FileMessage:     //文件消息
        {
            cell = [[NoaMessageFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
            break;
        case CIMChatMessageType_GeoMessage:     //位置消息
        {
            cell = [[NoaMessageGeoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
            break;
        case CIMChatMessageType_CardMessage:    //名片消息
        {
            cell = [[NoaMessageCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
            break;
        case CIMChatMessageType_StickersMessage:   //表情消息
        {
            cell = [[NoaMessageStickersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
            break;
        case CIMChatMessageType_GameStickersMessage:   //游戏表情消息
        {
            cell = [[NoaMessageGameStickersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
            break;

        case CIMChatMessageType_ForwardMessage:   //转发消息
        {
            cell = [[NoaMergeMessageRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
            break;
        default:
            cell = [[NoaMessageTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            break;
    }
    
    cell.delegate = self;
    cell.sessionId = self.groupId;
    cell.cellIndex = indexPath; // 设置 cellIndex，确保长按手势能正确工作
    
    // 配置消息，并隐藏已读未读标识和头像上的标识
    [cell setConfigMessage:model];
    
    // 隐藏已读未读标识
    if ([cell isKindOfClass:[NoaMessageContentBaseCell class]]) {
        NoaMessageContentBaseCell *contentCell = (NoaMessageContentBaseCell *)cell;
        contentCell.readedView.hidden = YES;
        // 隐藏头像上的标识
        contentCell.msgUserRoleName.hidden = YES;
        contentCell.groupRoleView.hidden = YES;
        
        // 修复昵称位置：隐藏标识后，重新设置昵称约束，使其距离头像6
        if (model.message.chatType == CIMChatType_GroupChat) {
            contentCell.userNickLbl.hidden = NO; // 确保昵称可见
            
            // 计算 offset_Y（考虑时间显示）
            CGFloat offset_Y = CellTop;
            if (![NSString isNil:model.dataTime]) {
                offset_Y = offset_Y + 12 + 19;
            }
            
            // 重新设置昵称约束，距离头像6
            [contentCell.userNickLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (model.isSelf) {
                    // 自己发的消息：昵称在头像左边
                    make.trailing.equalTo(contentCell.msgAvatarImgView.mas_leading).offset(-6);
                } else {
                    // 接收的消息：昵称在头像右边
                    make.leading.equalTo(contentCell.msgAvatarImgView.mas_trailing).offset(6);
                }
                make.top.equalTo(contentCell.contentView).offset(offset_Y);
                make.width.mas_lessThanOrEqualTo(DScreenWidth - 140);
                make.height.mas_equalTo(16);
            }];
        }
        
        // 添加定位按钮（位置跟已读标识一样）
        UIButton *locationBtn = [contentCell.contentView viewWithTag:9999];
        if (!locationBtn) {
            locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            locationBtn.tag = 9999;
            [locationBtn setImage:ImgNamed(@"chat_message_location_btn") forState:UIControlStateNormal];
            [locationBtn addTarget:self action:@selector(locationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [contentCell.contentView addSubview:locationBtn];
        }
        
        // 使用与 readedView 相同的约束位置
        [locationBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(DWScale(28), DWScale(28)));
            // 位置与 readedView 相同：trailing 相对于 viewSendBubble.mas_leading 偏移 -6，bottom 对齐 viewSendBubble.mas_bottom
            if (model.isSelf) {
                // 自己发送的消息：使用 viewSendBubble 的约束
                make.trailing.equalTo(contentCell.viewSendBubble.mas_leading).offset(-6);
                make.bottom.equalTo(contentCell.viewSendBubble.mas_bottom);
            } else {
                // 接收的消息：使用 viewReceiveBubble 的约束（参考 readedView 的位置逻辑）
                make.leading.equalTo(contentCell.viewReceiveBubble.mas_trailing).offset(6);
                make.bottom.equalTo(contentCell.viewReceiveBubble.mas_bottom);
            }
        }];
        
        // 保存 smsgId 到按钮的关联对象
        objc_setAssociatedObject(locationBtn, @"smsgId", model.message.serviceMsgID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return cell;
}

- (void)locationButtonAction:(UIButton *)sender {
    NSString *smsgId = objc_getAssociatedObject(sender, @"smsgId");
    if (smsgId.length > 0) {
        NSString *sessionID = self.chatType == CIMChatType_SingleChat ? self.friendUid : self.groupId;
        // 排除删除和撤回的消息
        NoaIMChatMessageModel *targetMessage = [IMSDKManager toolGetOneChatMessageWithServiceMessageIDExcludeDeleted:smsgId sessionID:sessionID];
        if (!targetMessage) {
            [HUD showMessage:LanguageToolMatch(@"找不到本条消息") inView:self.view];
            return;
        }
        // 返回聊天页面并定位到该消息
        [self.navigationController popViewControllerAnimated:YES];
        
        // 发送通知，让聊天页面定位到该消息
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *sessionIdKey = self.chatType == CIMChatType_SingleChat ? @"friendUid" : @"groupId";
            NSString *sessionIdValue = self.chatType == CIMChatType_SingleChat ? (self.friendUid ?: @"") : (self.groupId ?: @"");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TopMessageLocationNotification" object:nil userInfo:@{@"smsgId": smsgId, sessionIdKey: sessionIdValue}];
        });
    }
}

#pragma mark - ZMessageBaseCellDelegate
- (void)messageCellLongTapWithIndex:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.messageList.count) {
        return;
    }
    
    NoaMessageModel *msgModel = [self.messageList objectAtIndex:indexPath.row];
    
    // 根据会话类型判断权限
    if (self.chatType == CIMChatType_SingleChat) {
        // 单聊：判断 userMsgPinning 是否为 "true"
        if (![UserManager.userRoleAuthInfo.userMsgPinning.configValue isEqualToString:@"true"]) {
            return;
        }
        
        // 获取 topType（单聊使用 type 字段）
        NSNumber *topTypeNum = objc_getAssociatedObject(msgModel, @"topType");
        NSInteger topType = topTypeNum ? [topTypeNum integerValue] : 0;
        
        // 根据 topType 判断显示哪个弹框
        if (topType == 1 || topType == 3) {
            // type == 1 或 type == 3：显示取消全局置顶弹框
            [self showCancelSingleGlobalTopAlertWithMsgModel:msgModel];
        } else if (topType == 2) {
            // type == 2：显示取消置顶弹框
            [self showCancelSingleTopAlertWithMsgModel:msgModel];
        }
    } else {
        // 群聊：判断 groupMsgPinning 是否为 "true"
        if (![UserManager.userRoleAuthInfo.groupMsgPinning.configValue isEqualToString:@"true"]) {
            return;
        }
        
        // 获取 topType
        NSNumber *topTypeNum = objc_getAssociatedObject(msgModel, @"topType");
        NSInteger topType = topTypeNum ? [topTypeNum integerValue] : 0;
        
        // 获取用户角色
        NSInteger userGroupRole = self.groupInfo ? self.groupInfo.userGroupRole : 0;
        
        // 根据 topType 和用户角色判断显示哪个弹框
        if (topType == 2) {
            // 仅个人置顶：弹出取消个人置顶弹框
            [self showCancelPersonalTopAlertWithMsgModel:msgModel];
        } else if (topType == 1) {
            // 全局置顶：只有群主或管理员才能取消
            if (userGroupRole == 1 || userGroupRole == 2) {
                [self showCancelGlobalTopAlertWithMsgModel:msgModel];
            }
            // 群成员不弹框
        } else if (topType == 3) {
            // 全局+个人置顶
            if (userGroupRole == 1 || userGroupRole == 2) {
                // 群主或管理员：弹出取消全局置顶弹框
                [self showCancelGlobalTopAlertWithMsgModel:msgModel];
            } else {
                // 群成员：弹出取消个人置顶弹框
                [self showCancelPersonalTopAlertWithMsgModel:msgModel];
            }
        }
    }
}

- (void)messageCellClickWithIndex:(NSIndexPath *)indexPath {
    // 列表页面不支持点击操作
}

#pragma mark - 取消置顶弹框
// 显示取消全局置顶提示框
- (void)showCancelGlobalTopAlertWithMsgModel:(NoaMessageModel *)msgModel {
    NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    alertView.lblTitle.text = LanguageToolMatch(@"取消全局置顶");
    alertView.lblContent.text = LanguageToolMatch(@"你确定取消本条消息的全局置顶吗?");
    [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    WeakSelf;
    alertView.sureBtnBlock = ^(BOOL isCheckBox) {
        // 取消全局置顶
        [weakSelf doSetMsgTopWithMsgModel:msgModel msgStatus:3];
    };
    alertView.cancelBtnBlock = ^{
    };
    [alertView alertShow];
}

// 显示取消置顶提示框（个人置顶）
- (void)showCancelPersonalTopAlertWithMsgModel:(NoaMessageModel *)msgModel {
    NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    alertView.lblTitle.text = LanguageToolMatch(@"取消置顶");
    alertView.lblContent.text = LanguageToolMatch(@"你确定取消本条置顶消息吗?");
    [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    WeakSelf;
    alertView.sureBtnBlock = ^(BOOL isCheckBox) {
        // 取消个人置顶
        [weakSelf doSetMsgTopWithMsgModel:msgModel msgStatus:4];
    };
    alertView.cancelBtnBlock = ^{
    };
    [alertView alertShow];
}

// 显示取消单聊全局置顶提示框
- (void)showCancelSingleGlobalTopAlertWithMsgModel:(NoaMessageModel *)msgModel {
    NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    alertView.lblTitle.text = LanguageToolMatch(@"取消全局置顶");
    alertView.lblContent.text = LanguageToolMatch(@"你确定取消本条消息的全局置顶吗?");
    [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    WeakSelf;
    alertView.sureBtnBlock = ^(BOOL isCheckBox) {
        // 取消全局置顶
        [weakSelf doSetSingleMsgTopWithMsgModel:msgModel msgStatus:3];
    };
    alertView.cancelBtnBlock = ^{
    };
    [alertView alertShow];
}

// 显示取消单聊置顶提示框（个人置顶）
- (void)showCancelSingleTopAlertWithMsgModel:(NoaMessageModel *)msgModel {
    NoaMessageAlertView *alertView = [[NoaMessageAlertView alloc] initWithMsgAlertType:ZMessageAlertTypeTitle supView:nil];
    alertView.lblTitle.text = LanguageToolMatch(@"取消置顶");
    alertView.lblContent.text = LanguageToolMatch(@"你确定取消本条置顶消息吗?");
    [alertView.btnSure setTitle:LanguageToolMatch(@"确认") forState:UIControlStateNormal];
    [alertView.btnSure setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
    alertView.btnSure.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [alertView.btnCancel setTitle:LanguageToolMatch(@"取消") forState:UIControlStateNormal];
    [alertView.btnCancel setTkThemeTitleColor:@[COLOR_66, COLOR_66_DARK] forState:UIControlStateNormal];
    alertView.btnCancel.tkThemebackgroundColors = @[COLOR_F6F6F6, COLOR_F6F6F6_DARK];
    WeakSelf;
    alertView.sureBtnBlock = ^(BOOL isCheckBox) {
        // 取消个人置顶
        [weakSelf doSetSingleMsgTopWithMsgModel:msgModel msgStatus:4];
    };
    alertView.cancelBtnBlock = ^{
    };
    [alertView alertShow];
}

//执行置顶/取消置顶操作
- (void)doSetMsgTopWithMsgModel:(NoaMessageModel *)msgModel msgStatus:(NSInteger)msgStatus {
    if (!msgModel || !msgModel.message.serviceMsgID.length) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:self.groupId forKey:@"groupId"];
    [params setObjectSafe:msgModel.message.serviceMsgID forKey:@"smsgId"];
    [params setObjectSafe:@(msgStatus) forKey:@"msgStatus"];
    
    WeakSelf;
    [IMSDKManager groupSetMsgTopWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        // 取消置顶成功，刷新列表数据
        [weakSelf requestGroupTopMessageList];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        // 取消置顶失败
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

//执行单聊置顶/取消置顶操作
- (void)doSetSingleMsgTopWithMsgModel:(NoaMessageModel *)msgModel msgStatus:(NSInteger)msgStatus {
    if (!msgModel || !msgModel.message.serviceMsgID.length) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:self.friendUid forKey:@"friendUid"];
    [params setObjectSafe:msgModel.message.serviceMsgID forKey:@"smsgId"];
    [params setObjectSafe:@(msgStatus) forKey:@"msgStatus"];
    
    WeakSelf;
    [IMSDKManager MessageSetMsgTopWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        // 取消置顶成功，刷新列表数据
        [weakSelf requestSingleTopMessageList];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        // 取消置顶失败
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

@end

