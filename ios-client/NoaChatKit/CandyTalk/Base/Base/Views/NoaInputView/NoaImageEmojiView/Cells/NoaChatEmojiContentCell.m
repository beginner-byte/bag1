//
//  NoaChatEmojiContentCell.m
//  NoaKit
//
//  Created by Candy on 2024/3/25.
//

#import "NoaChatEmojiContentCell.h"
#import "NoaChatInputEmojiView.h"
#import "NoaChatGitImgCollectionView.h"
#import "NoaChatPackageInEmojiView.h"

@interface NoaChatEmojiContentCell() <ZChatInputEmojiViewDelegate, ZChatGitImgCollectionViewDelegate, ZChatPackageInEmojiViewDelegate>

@property (nonatomic, strong) NoaChatInputEmojiView *emojiView;
@property (nonatomic, strong) NoaChatGitImgCollectionView *collectionGifImgView;
@property (nonatomic, strong) NoaChatPackageInEmojiView *packageItemEmojiView;

@end

@implementation NoaChatEmojiContentCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.emojiView.frame = CGRectMake(0, 0, DScreenWidth, DWScale(258));
    self.emojiView.hidden = YES;
    [self addSubview:self.emojiView];
    
    self.packageItemEmojiView.frame = CGRectMake(0, 0, DScreenWidth, DWScale(258));
    self.packageItemEmojiView.hidden = YES;
    [self addSubview:self.packageItemEmojiView];
    
    self.collectionGifImgView.frame = CGRectMake(0, 0, DScreenWidth, DWScale(258));
    self.collectionGifImgView.hidden = YES;
    [self addSubview:self.collectionGifImgView];
}

- (void)reloadMyCollectionStickers {
    [self.collectionGifImgView reloadMyCollectionStickers];
}

#pragma mark - 数据赋值
- (void)setCellIndexRow:(NSInteger)cellIndexRow {
    _cellIndexRow = cellIndexRow;
    if (_cellIndexRow == 0) {
        //emoji
        self.emojiView.hidden = NO;
        self.collectionGifImgView.hidden = YES;
        self.packageItemEmojiView.hidden = YES;
    } else if (_cellIndexRow == 1) {
        //收藏的表情
        self.emojiView.hidden = YES;
        self.collectionGifImgView.hidden = NO;
        self.packageItemEmojiView.hidden = YES;
    } else {
        //表情包表情
        self.emojiView.hidden = YES;
        self.collectionGifImgView.hidden = YES;
        self.packageItemEmojiView.hidden = NO;
    }
}

- (void)setStickersPackageModel:(NoaIMStickersPackageModel *)stickersPackageModel {
    _stickersPackageModel = stickersPackageModel;
    
    if (_stickersPackageModel) {
        self.packageItemEmojiView.stickersId = _stickersPackageModel.packageId;
        self.packageItemEmojiView.packageNameStr = _stickersPackageModel.name;
        self.packageItemEmojiView.stickersList = [_stickersPackageModel.stickersList copy];
    }
}

- (void)collectionStickerFromSearchResult {
    //请求收藏的表情
    //[self.collectionGifImgView reloadMyCollectionStickers];
}

#pragma mark - ZChatInputEmojiViewDelegate
//选中表情Emoji
- (void)inputEmojiViewSelected:(NSString *)emojiName {
    if (_delegate && [_delegate respondsToSelector:@selector(inputEmojiViewSelected:)]) {
        [_delegate inputEmojiViewSelected:emojiName];
    }
}
//删除Emoji
- (void)inputEmojiViewDelete {
    if (_delegate && [_delegate respondsToSelector:@selector(inputEmojiViewDelete)]) {
        [_delegate inputEmojiViewDelete];
    }
}

#pragma mark - ZChatGitImgCollectionViewDelegate
//打开相册(添加相册图片到收藏的表情里)
- (void)addCollectionGifImgAction {
    if (_delegate && [_delegate respondsToSelector:@selector(addCollectionGifImgAction)]) {
        [_delegate addCollectionGifImgAction];
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
    if (_delegate && [_delegate respondsToSelector:@selector(inputCollectGifImgSelected:)]) {
        [_delegate inputCollectGifImgSelected:sendStickersModel];
    }
}

#pragma mark - ZChatPackageInEmojiViewDelegate
//点击表情包表情发送
- (void)stickerPackageItemSelected:(NoaIMStickersModel *)sendStickersModel {
    if (_delegate && [_delegate respondsToSelector:@selector(stickerPackageItemSelected:)]) {
        [_delegate stickerPackageItemSelected:sendStickersModel];
    }
}

//删除当前表情包
- (void)deleteStickersPackageWithStickersSetId:(NSString *)stickersSetId {
    if (_delegate && [_delegate respondsToSelector:@selector(deleteStickersPackageWithStickersSetId:)]) {
        [_delegate deleteStickersPackageWithStickersSetId:stickersSetId];
    }
}


#pragma Lazy
//表情符号
- (NoaChatInputEmojiView *)emojiView {
    if (!_emojiView) {
        _emojiView = [[NoaChatInputEmojiView alloc] init];
        _emojiView.hidden = NO;
        _emojiView.delegate = self;
    }
    return _emojiView;
}


- (NoaChatGitImgCollectionView *)collectionGifImgView {
    if (!_collectionGifImgView) {
        _collectionGifImgView = [[NoaChatGitImgCollectionView alloc] init];
        _collectionGifImgView.hidden = YES;
        _collectionGifImgView.delegate = self;
    }
    return _collectionGifImgView;
}

- (NoaChatPackageInEmojiView *)packageItemEmojiView {
    if (!_packageItemEmojiView) {
        _packageItemEmojiView = [[NoaChatPackageInEmojiView  alloc] init];
        _packageItemEmojiView.hidden = YES;
        _packageItemEmojiView.delegate = self;
    }
    return _packageItemEmojiView;
}


@end
