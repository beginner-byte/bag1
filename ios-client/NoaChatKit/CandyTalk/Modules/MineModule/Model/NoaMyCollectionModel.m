//
//  NoaMyCollectionModel.m
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaMyCollectionModel.h"
#import "NoaChatInputEmojiManager.h"

@implementation NoaMyCollectionModel

- (instancetype)initWithCollectionModel:(NoaMyCollectionItemModel *)itemModel {
    self = [super init];
    if (self) {
        _itemModel = itemModel;
        _isSelf = [_itemModel.fromUid isEqualToString:UserManager.userInfo.userUID];
    
        //默认高度
        _itemWidth = CGFLOAT_MIN;
        _itemHeight = CGFLOAT_MIN;
        _cellHeight = CGFLOAT_MIN;
        //计算高度
        [self calculateModelInfoSize];
    }
    return self;
}

//计算内容宽高和cell高度
- (void)calculateModelInfoSize {
    if (_itemModel) {
        if (_itemModel.mtype == CIMChatMessageType_TextMessage || _itemModel.mtype == CIMChatMessageType_AtMessage) {
            //文本消息
            [self calculateTextMessage];
        } else if (_itemModel.mtype == CIMChatMessageType_ImageMessage) {
            //图片消息
            [self calculateImageMessage];
        } else if (_itemModel.mtype == CIMChatMessageType_VideoMessage) {
            //视频消息
            [self calculateVideoMessage];
        } else if (_itemModel.mtype == CIMChatMessageType_FileMessage) {
            //文件消息
            [self calculateFileMessage];
        }  else if (_itemModel.mtype == CIMChatMessageType_GeoMessage) {
            //地理位置消息
            [self calculateGeoLocationMessage];
        } else {
            //忽略未解析的消息
            _itemWidth = DScreenWidth;
            _itemHeight = CGFLOAT_MIN;
            _cellHeight = CGFLOAT_MIN;
        }
    }
}

#pragma mark - 计算文本消息
- (void)calculateTextMessage {
    NSString *textContent = @"";
    if (![NSString isNil:_itemModel.body.translate]) {
        if (self.isSelf) {
            if (_itemModel.mtype == CIMChatMessageType_TextMessage) {
                textContent = _itemModel.body.content;
            }
            if (_itemModel.mtype == CIMChatMessageType_AtMessage) {
                textContent = [self atContenTranslateToShowContent:_itemModel.body.content atUsersDictList:_itemModel.body.atInfo];
            }
        } else {
            if (_itemModel.mtype == CIMChatMessageType_TextMessage) {
                textContent = _itemModel.body.translate;
            }
            if (_itemModel.mtype == CIMChatMessageType_AtMessage) {
                textContent = [self atContenTranslateToShowContent:_itemModel.body.translate atUsersDictList:_itemModel.body.atInfo];
            }
        }
    } else {
        if (_itemModel.mtype == CIMChatMessageType_TextMessage) {
            textContent = _itemModel.body.content;
        }
        if (_itemModel.mtype == CIMChatMessageType_AtMessage) {
            textContent = [self atContenTranslateToShowContent:_itemModel.body.content atUsersDictList:_itemModel.body.atInfo];
        }
    }
    
    _itemModel.body.content = textContent;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:[style copy]};
    //此处需要将表情内容"[表情]"替换为表情图片的富文本
    self.attStr = [[NoaChatInputEmojiManager sharedManager] attributedString:_itemModel.body.content];
    [self.attStr addAttributes:dict range:NSMakeRange(0, self.attStr.length)];
    
    CGSize size = [self.attStr boundingRectWithSize:CGSizeMake(DScreenWidth - (16*2)*2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    _itemWidth = DScreenWidth - (16*2)*2;
    _itemHeight = MAX(ceil(size.height), 22);
    
    _cellHeight = DWScale(16)+DWScale(16)+_itemHeight+DWScale(10)+DWScale(18)+DWScale(16);
}

#pragma mark - 计算图片消息
- (void)calculateImageMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    //图片
    _itemWidth = DWScale(80);
    _itemHeight = DWScale(80);
    
    _cellHeight = DWScale(16)+DWScale(16)+_itemHeight+DWScale(16)+DWScale(18)+DWScale(16);
}

#pragma mark - 计算视频消息
- (void)calculateVideoMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:@""];
    //视频封面图片
    _itemWidth = DWScale(80);
    _itemHeight = DWScale(80);
    
    _cellHeight = DWScale(16)+DWScale(16)+_itemHeight+DWScale(16)+DWScale(18)+DWScale(16);
}

#pragma mark - 计算文件消息
- (void)calculateFileMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    //文件类型图标图片
    _itemWidth = DWScale(54);
    _itemHeight = DWScale(66);
    
    _cellHeight = DWScale(16)+DWScale(16)+_itemHeight+DWScale(22)+DWScale(18)+DWScale(16);
}

#pragma mark - 计算地理位置消息
- (void)calculateGeoLocationMessage {
    self.attStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    //地理位置类型消息地图图片
    _itemWidth = DWScale(66);
    _itemHeight = DWScale(66);
    
    _cellHeight = DWScale(16)+DWScale(16)+_itemHeight+DWScale(22)+DWScale(18)+DWScale(16);
}

//将 at消息里的 \vuid\v 转换成 @nickName
- (NSString *)atContenTranslateToShowContent:(NSString *)atContentStr atUsersDictList:(NSArray *)atUsersDictList {
    if (![NSString isNil:atContentStr]) {
        NSString *showContent = [NSString stringWithString:atContentStr];
        for (NSDictionary *atUsersDict in atUsersDictList) {
            NSString *uidKey = (NSString *)[atUsersDict objectForKey:@"uId"];
            if ([uidKey isEqualToString:@"-1"]) {
                showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", uidKey] withString:LanguageToolMatch(@"@所有人")];
            } else {
                showContent = [showContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\v%@\v", uidKey] withString:[NSString stringWithFormat:@"@%@", (NSString *)[atUsersDict objectForKey:@"uNick"]]];
            }
        }
        return showContent;
    } else {
        return @"";
    }
}

#pragma mark - Lazy
- (NSMutableAttributedString *)attStr {
    if (!_attStr) {
        _attStr = [NSMutableAttributedString new];
    }
    return _attStr;
}



@end
