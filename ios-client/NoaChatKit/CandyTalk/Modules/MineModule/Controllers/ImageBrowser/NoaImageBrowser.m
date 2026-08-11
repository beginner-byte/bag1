//
//  NoaImageBrowser.m
//  NoaKit
//
//  Created by Candy on 2024/9/14.
//

#import "NoaImageBrowser.h"
#import "NoaPresentView.h"

@interface NoaImageBrowser ()<KNPhotoBrowserDelegate>

@property (nonatomic, strong) KNPhotoBrowser *photoBrowser;
@property (nonatomic, strong) NSArray<KNPhotoItems *> *itemsArr;

@property (nonatomic, strong) NSArray <NoaPresentItem *> *selectItems;
@property (nonatomic, strong) NoaPresentItem *cancleItem;
@property (nonatomic, copy) ZDoneActionBlock doneClick;
@property (nonatomic, copy) ZCancleActionBlock cancleClick;

@end

@implementation NoaImageBrowser

- (void)imageBrowserWithImageItems:(NSArray<KNPhotoItems *> *_Nonnull)itemsArr
                      currentIndex:(NSInteger)currentIndex
                       selectItems:(NSArray <NoaPresentItem *>* _Nullable)selectItems
                        cancleItem:(NoaPresentItem * _Nullable)cancleItem
                         doneClick:(ZDoneActionBlock _Nullable)doneClick
                       cancleClick:(ZCancleActionBlock _Nullable)cancleClick {
    
    KNPhotoBrowser *photoBrowser = [[KNPhotoBrowser alloc] init];
    [KNPhotoBrowserConfig share].isNeedCustomActionBar = false;
    photoBrowser.delegate = self;
    photoBrowser.itemsArr = itemsArr;
    photoBrowser.placeHolderColor = UIColor.lightTextColor;
    photoBrowser.currentIndex = currentIndex;
    photoBrowser.isSoloAmbient = true;//音频模式
    photoBrowser.isNeedPageNumView = false;//分页
    photoBrowser.isNeedRightTopBtn = true;//更多按钮
    photoBrowser.isNeedLongPress = false;//长按
    photoBrowser.isNeedPanGesture = true;//拖拽
    photoBrowser.isNeedPrefetch = true;//预取图像(最大8)
    photoBrowser.isNeedAutoPlay = true;//自动播放
    photoBrowser.isNeedOnlinePlay = true;//在线播放(先自动下载视频)
    [photoBrowser present];
    
    self.photoBrowser = photoBrowser;
    self.itemsArr = itemsArr;
    self.selectItems = selectItems;
    self.cancleItem = cancleItem;
    self.doneClick = doneClick;
    self.cancleClick = cancleClick;
    
    
}

- (void)dismiss {
    
    [self.photoBrowser dismiss];
}

#pragma mark - KNPhotoBrowserDelegate
//图片浏览右侧按钮点击事件
- (void)photoBrowser:(KNPhotoBrowser *)photoBrowser rightBtnOperationActionWithIndex:(NSInteger)index {

    KNPhotoItems *item = nil;
    if (index < self.itemsArr.count) {
        item = self.itemsArr[index];
    }
    
    WeakSelf;
    NoaPresentView *viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:self.selectItems cancleItem:self.cancleItem doneClick:^(NSInteger index) {
        
        if (weakSelf.doneClick) {
            weakSelf.doneClick(index, item);
        }
        
    } cancleClick:^{
        
        if (weakSelf.cancleClick) {
            weakSelf.cancleClick();
        }
    }];
    [CurrentVC.view addSubview:viewAlert];
    [viewAlert showPresentView];
}

@end
