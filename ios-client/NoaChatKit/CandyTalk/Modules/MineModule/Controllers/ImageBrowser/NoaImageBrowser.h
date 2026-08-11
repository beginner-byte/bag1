//
//  NoaImageBrowser.h
//  NoaKit
//
//  Created by Candy on 2024/9/14.
//

#import <Foundation/Foundation.h>
#import "KNPhotoBrowser.h"//图片视频浏览

typedef void(^ZDoneActionBlock)(NSInteger index, KNPhotoItems * _Nullable photoItems);
typedef void(^ZCancleActionBlock)(void);

@interface NoaImageBrowser : NSObject

- (void)imageBrowserWithImageItems:(NSArray<KNPhotoItems *> *_Nonnull)itemsArr
                      currentIndex:(NSInteger)currentIndex
                       selectItems:(NSArray <NoaPresentItem *>* _Nullable)selectItems
                        cancleItem:(NoaPresentItem * _Nullable)cancleItem
                         doneClick:(ZDoneActionBlock _Nullable)doneClick
                       cancleClick:(ZCancleActionBlock _Nullable)cancleClick;

- (void)dismiss;

@end


