//
//  NoaChatImageEmojiView.m
//  NoaKit
//
//  Created by Candy on 2023/8/10.
//

#import "NoaChatImageEmojiView.h"
#import "NoaChatImgEmojiToolsView.h"
#import "NoaChatEmojiSearchView.h"
#import "NoaChatImgEmojiContentView.h"

@interface NoaChatImageEmojiView() <ZChatImgEmojiToolsViewDelegate, ZChatImgEmojiContentViewDelegate, ZChatEmojiSearchViewDelegate>

@property (nonatomic, strong) NSMutableArray *packageItemList;
@property (nonatomic, strong) NoaChatImgEmojiToolsView *toolsView;
@property (nonatomic, strong) NoaChatImgEmojiContentView *contentView;

@end

@implementation NoaChatImageEmojiView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
        
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self);
        make.height.mas_equalTo(DWScale(258));
    }];
    
    [self addSubview:self.toolsView];
    [self.toolsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(DWScale(46) + DHomeBarH);
    }];
}

//请求 收藏的表情和已使用的表情包
- (void)reloadStickersData {
    //请求收藏的表情
    [self.contentView reloadMyCollectionStickers];
    //请求已使用的表情包及表情包里的表情
    [self requestGetUsedStickerPackageList];
}

//单独刷新收藏的表情
- (void)relaodCollectionData {
    //请求收藏的表情
   // [self.contentView reloadMyCollectionStickers];
}

#pragma mark - NetWorking
//请求所有添加过的表情包数据
- (void)requestGetUsedStickerPackageList {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:@(0) forKey:@"lastUpdateTime"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    WeakSelf
    [IMSDKManager imSdkUserFindUsedStickersPackageList:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSArray class]]) {
            //数据处理
            NSArray *dataList = (NSArray *)data;
    
            [weakSelf.packageItemList removeAllObjects];
            //清空缓存的表情包
            [DBTOOL deleteAllStickersPackageModels];
            [weakSelf addDefaultItem];
            
            NSArray *tempPackageList = [NoaIMStickersPackageModel mj_objectArrayWithKeyValuesArray:dataList];
            [weakSelf.packageItemList addObjectsFromArray:tempPackageList];
            NSMutableArray *saveStickersList = [NSMutableArray array];
            for (int i = 0; i < dataList.count; i++) {
                NoaIMStickersPackageModel *tempPackageModel = (NoaIMStickersPackageModel *)[tempPackageList objectAtIndexSafe:i];
                NSDictionary *tempPackageDict = (NSDictionary *)[dataList objectAtIndexSafe:i];
                NSArray *tempStickersList = (NSArray *)[tempPackageDict objectForKeySafe:@"stickersList"];
                NSString *jsonArr = [NSString jsonStringFromArray:tempStickersList];
                tempPackageModel.stickersListJsonStr = jsonArr;
                tempPackageModel.stickersList = @[];
                [saveStickersList addObject:tempPackageModel];
            }
            //保存接口返回的表情包到本地数据库
            [DBTOOL batchInsertStickersPackageModelWith:saveStickersList];
            //刷新UI
            NSInteger toolsPage = (weakSelf.toolsView.pageIndex == 0 ? 1 : weakSelf.toolsView.pageIndex);
            weakSelf.toolsView.toolsItemList = [weakSelf.packageItemList mutableCopy];
            if (toolsPage > weakSelf.packageItemList.count - 1) {
                toolsPage = weakSelf.packageItemList.count - 1;
            } else {
                weakSelf.toolsView.pageIndex = toolsPage;
            }
            
            weakSelf.contentView.contentItemList = [weakSelf.packageItemList mutableCopy];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        NSArray *dbPackageList = [DBTOOL getMyStickersPackageList];
        if (dbPackageList.count > 0) {
            [weakSelf.packageItemList removeAllObjects];
            [weakSelf addDefaultItem];
           
            [weakSelf.packageItemList addObjectsFromArray:dbPackageList];
            weakSelf.toolsView.toolsItemList = weakSelf.packageItemList;
            weakSelf.contentView.contentItemList = weakSelf.packageItemList;
        }
    }];
}

- (void)requestDeleteStickerPackageWithId:(NSString *)stickerSetId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:stickerSetId forKey:@"stickersSetId"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    WeakSelf
    [IMSDKManager imSdkUserRemoveusedStickersPackage:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        //重新请求toolsView的数据
        [HUD showMessage:LanguageToolMatch(@"删除成功")];
        [DBTOOL deleteStickersPackageModelWith:stickerSetId];
        [weakSelf requestGetUsedStickerPackageList];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - ZChatImgEmojiToolsViewDelegate
- (void)toolsViewSelectedIndex:(NSInteger)toolsIndex {
    if (toolsIndex == 0) {
        //搜索表情包
        NoaChatEmojiSearchView *searchEmojiView = [[NoaChatEmojiSearchView alloc] init];
        searchEmojiView.delegate = self;
        [searchEmojiView emojiSearchViewShow];
    } else {
        self.contentView.index = toolsIndex - 1;
    }
}

#pragma mark - ZChatImgEmojiContentViewDelegate
- (void)scrollToPage:(int)page {
    self.toolsView.pageIndex = page + 1;
}

/** Emoji */
//选中表情Emoji
- (void)inputEmojiViewSelected:(NSString *)emojiName {
    if (_delegate && [_delegate respondsToSelector:@selector(imageEmojiViewSelected:)]) {
        [_delegate imageEmojiViewSelected:emojiName];
    }
}
//删除Emoji
- (void)inputEmojiViewDelete {
    if (_delegate && [_delegate respondsToSelector:@selector(imageEmojiViewDelete)]) {
        [_delegate imageEmojiViewDelete];
    }
}

/** 收藏的表情 */
//打开相册(添加相册图片到收藏的表情里)
- (void)addCollectionGifImgAction {
    if (_delegate && [_delegate respondsToSelector:@selector(openAlumAddCollectGifImg)]) {
        [_delegate openAlumAddCollectGifImg];
    }
}

//游戏表情：石头剪刀布、摇骰子
- (void)chatGameStickerAction:(ZChatGameStickerType)gameType {
    if (_delegate && [_delegate respondsToSelector:@selector(chatGameStickerAction:)]) {
        [_delegate chatGameStickerAction:gameType];
    }
}

//发送收藏的表情
- (void)inputCollectGifImgSelected:(NoaIMStickersModel *)sendStickersModel {
    if (_delegate && [_delegate respondsToSelector:@selector(imageGifPackageSelected:)]) {
        [_delegate imageGifPackageSelected:sendStickersModel];
    }
}

/** 表情包 */
//点击表情包表情发送
- (void)stickerPackageItemSelected:(NoaIMStickersModel *)sendStickersModel {
    if (_delegate && [_delegate respondsToSelector:@selector(imageGifPackageSelected:)]) {
        [_delegate imageGifPackageSelected:sendStickersModel];
    }
}

//删除当前表情包
- (void)deleteStickersPackageWithStickersSetId:(NSString *)stickersSetId {
    [self requestDeleteStickerPackageWithId:stickersSetId];
}

#pragma mark - ZChatEmojiSearchViewDelegate
- (void)sendSearchStickersForModel:(NoaIMStickersModel *)stickersModel {
    if (_delegate && [_delegate respondsToSelector:@selector(imageGifPackageSelected:)]) {
        [_delegate imageGifPackageSelected:stickersModel];
    }
}

//表情搜索页-更多表情
- (void)moreEmojiAction {
    if (_delegate && [_delegate respondsToSelector:@selector(searchEmojiMoreAction)]) {
        [_delegate searchEmojiMoreAction];
    }
}

- (void)collectionStickerFromSearchResult {
    //请求收藏的表情
    [self.contentView reloadMyCollectionStickers];
}

#pragma mark - Other
- (void)addDefaultItem {
    NoaIMStickersPackageModel *emojiSearchItemModel = [[NoaIMStickersPackageModel alloc] init];
    emojiSearchItemModel.itemAssetCoverName = @"stickers_search_icon";
    emojiSearchItemModel.isSelected = NO;
    
    NoaIMStickersPackageModel *packageItemModel = [[NoaIMStickersPackageModel alloc] init];
    packageItemModel.itemAssetCoverName = @"stickers_emoji_icon";
    packageItemModel.isSelected = YES;
    
    NoaIMStickersPackageModel *collectItemModel = [[NoaIMStickersPackageModel alloc] init];
    collectItemModel.itemAssetCoverName = @"stickers_collect_icon";
    collectItemModel.isSelected = NO;
    
    [self.packageItemList addObject:emojiSearchItemModel];
    [self.packageItemList addObject:packageItemModel];
    [self.packageItemList addObject:collectItemModel];
}

#pragma mark - Lazy
- (NSMutableArray *)packageItemList {
    if (!_packageItemList) {
        _packageItemList = [NSMutableArray array];
    }
    return _packageItemList;
}

- (NoaChatImgEmojiToolsView *)toolsView {
    if (!_toolsView) {
        _toolsView = [[NoaChatImgEmojiToolsView alloc] init];
        _toolsView.delegate = self;
    }
    return _toolsView;
}

- (NoaChatImgEmojiContentView *)contentView {
    if (!_contentView) {
        _contentView = [[NoaChatImgEmojiContentView alloc] init];
        _contentView.delegate = self;
    }
    return _contentView;
}


@end
