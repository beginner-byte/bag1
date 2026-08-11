//
//  NoaChatHistoryMediaVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/11.
//

#import "NoaChatHistoryMediaVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaChatHistoryMediaCell.h"
#import "NoaToolManager.h"
#import "KNPhotoBrowser.h"//图片+视频的浏览器
#import "NoaChatHistoryHeaderView.h"
#import "NoaChatHistoryChoiceUserVC.h"

@interface NoaChatHistoryMediaVC () <UICollectionViewDataSource,UICollectionViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,KNPhotoBrowserDelegate, ZChatHistoryHeaderViewDelegate, ZChatHistoryChoiceUserDelegate>

@property (nonatomic, strong) NSMutableArray *historyList;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NoaChatHistoryHeaderView *selectHeadView;

@end

@implementation NoaChatHistoryMediaVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navView.hidden = YES;
    _historyList = [NSMutableArray array];
    [self setupUI];
    [self searchChatHistoryMedia];
    [self refreshHeaderView];
}

#pragma mark - 界面布局
- (void)setupUI {
    self.selectHeadView = [[NoaChatHistoryHeaderView alloc] init];
    self.selectHeadView.delegate = self;
    [self.view addSubview:self.selectHeadView];
    [self.selectHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(DWScale(38));
    }];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(DScreenWidth / 4.0, DScreenWidth / 4.0);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.tkThemebackgroundColors = @[COLORWHITE, COLOR_11];;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.emptyDataSetSource = self;
    _collectionView.emptyDataSetDelegate = self;
    [_collectionView registerClass:[NoaChatHistoryMediaCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaChatHistoryMediaCell class])];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.selectHeadView.mas_bottom).offset(DWScale(6));
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
}

- (void)searchChatHistoryMedia {
    if ([NSString isNil:_sessionID]) return;
    NSMutableArray *userIdList = [NSMutableArray array];
    for (NoaBaseUserModel *userModel in self.selectHeadView.userInfoList) {
        [userIdList addObject:userModel.userId];
    }
    _historyList = [IMSDKManager toolGetChatMessageHistoryWith:_sessionID offset:0 messageType:@[@(CIMChatMessageType_VideoMessage), @(CIMChatMessageType_ImageMessage)] textMessageLike:nil userIdList:userIdList].mutableCopy;
    [_collectionView reloadData];
}

- (void)refreshHeaderView{
    if (self.chatType == CIMChatType_GroupChat) {
        self.selectHeadView.hidden = self.groupInfo.closeSearchUser;
        [self.selectHeadView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.groupInfo.closeSearchUser ? DWScale(0) : DWScale(38));
        }];
    }
}

#pragma mark - ZChatHistoryHeaderViewDelegate
- (void)headerClickAction {
    NoaChatHistoryChoiceUserVC *vc = [[NoaChatHistoryChoiceUserVC alloc] init];
    vc.choicedList = self.selectHeadView.userInfoList;
    vc.chatType = self.chatType;
    vc.sessionID = self.sessionID;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)headerResetAction {
    [self searchChatHistoryMedia];
}

#pragma mark - ZChatHistoryChoiceUserDelegate
- (void)chatHistoryChoicedUserList:(NSArray<NoaBaseUserModel *> *)selectedUserList {
    self.selectHeadView.userInfoList = [selectedUserList mutableCopy];
    [self searchChatHistoryMedia];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _historyList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaChatHistoryMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaChatHistoryMediaCell class]) forIndexPath:indexPath];
    cell.sessionID = self.sessionID;
    NoaIMChatMessageModel *model = [_historyList objectAtIndexSafe:indexPath.row];
    cell.chatMessageModel = model;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self imageVideoBrowserWith:indexPath];
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(-150);
}

//空态图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return ImgNamed(@"c_no_history_chat");
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *string = LanguageToolMatch(@"快去发送图片吧");
    NSMutableAttributedString *accessAttributeString  = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:FONTR(16),NSForegroundColorAttributeName:COLOR_5966F2}];
    return accessAttributeString;
}

#pragma mark - DZNEmptyDataSetDelegate
//允许滑动
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - 图片和视频的浏览
- (void)imageVideoBrowserWith:(NSIndexPath *)indexPath {
    WeakSelf
    __block NSMutableArray *browserMessages = [NSMutableArray array];
    [_historyList enumerateObjectsUsingBlock:^(NoaIMChatMessageModel * _Nonnull chatMessage, NSUInteger idx, BOOL * _Nonnull stop) {
        NoaChatHistoryMediaCell *indexCell = (NoaChatHistoryMediaCell *)[weakSelf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
        if (chatMessage.messageType == CIMChatMessageType_ImageMessage) {
            KNPhotoItems *item = [[KNPhotoItems alloc] init];
            //图片
            item.sourceView = indexCell.ivMedia;
            item.isVideo = false;
            if (chatMessage.localImgName) {
                //本地有图片
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, weakSelf.sessionID];
                item.url = [NSString getPathWithImageName:chatMessage.localImgName CustomPath:customPath];
            }else {
                //网络图片
                item.url = [chatMessage.imgName getImageFullString];
            }
            [browserMessages addObjectIfNotNil:item];
        }else if (chatMessage.messageType == CIMChatMessageType_VideoMessage) {
            //视频
            KNPhotoItems *item = [[KNPhotoItems alloc] init];
            item.sourceView = indexCell.ivMedia;
            item.isVideo = true;
            if (chatMessage.localVideoCover) {
                //本地视频封面
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, weakSelf.sessionID];
                NSString *pathStr = [NSString getPathWithImageName:chatMessage.localVideoCover CustomPath:customPath];
                item.videoPlaceHolderImageUrl = pathStr;
            }else {
                //网络视频封面
                item.videoPlaceHolderImageUrl = [chatMessage.videoCover getImageFullString];
            }
            if (chatMessage.localVideoName) {
                //本地视频地址
                NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionID];
                NSString *videoUrl = [NSString getPathWithVideoName:chatMessage.localVideoName CustomPath:customPath];
                item.url = videoUrl;
            }else {
                //网络视频地址
                item.url = [chatMessage.videoName getImageFullString];
            }
            [browserMessages addObjectIfNotNil:item];
        }
    }];
    
    KNPhotoBrowser *photoBrowser = [[KNPhotoBrowser alloc] init];
    [KNPhotoBrowserConfig share].isNeedCustomActionBar = false;
    photoBrowser.delegate = self;
    photoBrowser.itemsArr = browserMessages;
    photoBrowser.placeHolderColor = UIColor.lightTextColor;
    photoBrowser.currentIndex = indexPath.row;
    photoBrowser.isSoloAmbient = true;//音频模式
    photoBrowser.isNeedPageNumView = false;//分页
    photoBrowser.isNeedRightTopBtn = true;//更多按钮
    photoBrowser.isNeedLongPress = false;//长按
    photoBrowser.isNeedPanGesture = true;//拖拽
    photoBrowser.isNeedPrefetch = true;//预取图像(最大8)
    photoBrowser.isNeedAutoPlay = true;//自动播放
    photoBrowser.isNeedOnlinePlay = false;//在线播放(先自动下载视频)
    [photoBrowser present];
}

#pragma mark - KNPhotoBrowserDelegate
//图片浏览右侧按钮点击事件
- (void)photoBrowser:(KNPhotoBrowser *)photoBrowser rightBtnOperationActionWithIndex:(NSInteger)index {
    NoaIMChatMessageModel *currentModel = [_historyList objectAtIndexSafe:index];
    NSString *imageUrl;
    NSString *videoUrl;
    if (currentModel.messageType == CIMChatMessageType_ImageMessage) {
        //图片
        if (![NSString isNil:currentModel.localImgName]) {
            imageUrl = currentModel.localImgName;
        } else {
            imageUrl = [currentModel.imgName getImageFullString];
        }
    }else if (currentModel.messageType == CIMChatMessageType_VideoMessage) {
        //视频
        if (currentModel.localVideoName) {
            //本地视频地址
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.sessionID];
            videoUrl = [NSString getPathWithVideoName:currentModel.localVideoName CustomPath:customPath];
        }else {
            //网络视频地址
            videoUrl = [currentModel.videoName getImageFullString];
        }
    }
    
    WeakSelf
    NoaPresentItem *saveItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"保存到手机") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            saveItem.textColor = COLOR_11;
            saveItem.backgroundColor = COLORWHITE;
        }else {
            saveItem.textColor = COLORWHITE;
            saveItem.backgroundColor = COLOR_11;
        }
    };
    NoaPresentItem *cancelItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"取消") textColor:COLOR_99 font:FONTR(17) itemHeight:DWScale(54) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLORWHITE;
        }else {
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLOR_11;
        }
    };
    NoaPresentView *viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[saveItem] cancleItem:cancelItem doneClick:^(NSInteger index) {
        if (![NSString isNil:imageUrl]) {
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, weakSelf.sessionID];
            [ZTOOL saveImageToAlbumWith:imageUrl Cusotm:customPath];
        }
        if (![NSString isNil:videoUrl]) {
            [weakSelf saveVideoToAlbumWithUrl:videoUrl];
        }
        
    } cancleClick:^{
    }];
    [CurrentVC.view addSubview:viewAlert];
    [viewAlert showPresentView];
}

//保存视频到相册
- (void)saveVideoToAlbumWithUrl:(NSString *)videoUrl {
    [HUD showActivityMessage:LanguageToolMatch(@"正在保存...")];
    //此处的逻辑应该是，先查询本地缓存有没有该视频
    //有的话，直接保存，没有的话先缓存到本地，再保存
    NSString *videoPath = [ZTOOL videoExistsWith:videoUrl];
    if (![NSString isNil:videoPath]) {
        //已有缓存，直接保存
        [ZTOOL saveVideoToAlbumWith:videoPath];
    }else {
        //先下载缓存，再保存
        [ZTOOL downloadVideoWith:videoUrl completion:^(BOOL success, NSString * _Nonnull videoPath) {
            if (success) {
                [ZTOOL saveVideoToAlbumWith:videoPath];
            }
        }];
    }
}

@end
