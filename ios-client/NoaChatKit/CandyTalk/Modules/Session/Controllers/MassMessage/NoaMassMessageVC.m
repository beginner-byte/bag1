//
//  NoaMassMessageVC.m
//  NoaKit
//
//  Created by Candy on 2023/4/17.
//

#import "NoaMassMessageVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "NoaMassMessageTextCell.h"
#import "NoaMassMessageAttachmentCell.h"

#import "NoaNewMassMessageVC.h"//新建群发
#import "NoaMassMessageUserVC.h"//查看接收消息用户列表
#import "NoaMassMessageFileDetailVC.h"//文件详情
#import "KNPhotoBrowser.h"//图片视频浏览
#import "NoaToolManager.h"//工具类

@interface NoaMassMessageVC () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MGSwipeTableCellDelegate, ZMassMessageBaseCellDelegate, KNPhotoBrowserDelegate>
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, strong) NSMutableArray *messageList;
@property (nonatomic, strong) LIMMassMessageModel *currentDetailMessageModel;//当前查看详情的消息model
@end

@implementation NoaMassMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavUI];
    [self setupUI];
    
    _pageNumber = 1;
    _messageList = [NSMutableArray array];
    
    [self requestHairGroupMessageList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageList) name:@"MassMessageSendSuccess" object:nil];
}

- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"群发助手");

    if ([UserManager.userRoleAuthInfo.groupHairAssistant.configValue isEqualToString:@"true"]) {
        self.navBtnRight.hidden = NO;
        [self.navBtnRight setTitle:LanguageToolMatch(@"新建") forState:UIControlStateNormal];
        [self.navBtnRight setTitleColor:COLORWHITE forState:UIControlStateNormal];
        self.navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        self.navBtnRight.layer.cornerRadius = DWScale(12);
        self.navBtnRight.layer.masksToBounds = YES;
    } else {
        self.navBtnRight.hidden = YES;
    }
    
    CGRect btnTextRect = [self.navBtnRight.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, DWScale(32)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: FONTR(14)} context:nil];
    [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(32));
        make.width.mas_equalTo(MIN(btnTextRect.size.width + DWScale(28), 60));
    }];
    
}

- (void)setupUI {
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    self.baseTableViewStyle = UITableViewStyleGrouped;
    [self.view addSubview:self.baseTableView];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.emptyDataSetSource = self;
    self.baseTableView.emptyDataSetDelegate = self;
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self.baseTableView registerClass:[NoaMassMessageTextCell class] forCellReuseIdentifier:NSStringFromClass([NoaMassMessageTextCell class])];
    [self.baseTableView registerClass:[NoaMassMessageAttachmentCell class] forCellReuseIdentifier:NSStringFromClass([NoaMassMessageAttachmentCell class])];
    self.baseTableView.mj_header = self.refreshHeader;
    self.baseTableView.rowHeight = UITableViewAutomaticDimension;
    self.baseTableView.estimatedRowHeight = DWScale(300);
    [self defaultTableViewUI];
    
}
#pragma mark - 下拉刷新
- (void)headerRefreshData {
    _pageNumber++;
    [self requestHairGroupMessageList];
}
- (void)requestHairGroupMessageList {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@((_pageNumber - 1) * 15) forKey:@"pageStart"];
    [dict setValue:@(15) forKey:@"pageSize"];
    [dict setValue:@(_pageNumber) forKey:@"pageNumber"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [IMSDKManager GroupHairGetMessageListWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            if (weakSelf.pageNumber == 1) {
                [weakSelf.messageList removeAllObjects];
            }
            
            NSDictionary *dataDict = (NSDictionary *)data;
            
            __block NSMutableArray *tempList = [NSMutableArray array];
            NSArray *recordMessageList = [dataDict objectForKeySafe:@"records"];
            [recordMessageList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LIMMassMessageModel *messageModel = [LIMMassMessageModel mj_objectWithKeyValues:obj];
                [tempList addObjectIfNotNil:messageModel];
            }];
            
            if (weakSelf.pageNumber == 1) {
                [weakSelf.messageList addObjectsFromArray:tempList];
            }else{
                NSRange range = NSMakeRange(0, tempList.count);
                NSIndexSet *nsindex = [NSIndexSet indexSetWithIndexesInRange:range];
                [weakSelf.messageList insertObjects:tempList atIndexes:nsindex];
            }
            
            [weakSelf.baseTableView reloadData];
            [weakSelf.baseTableView.mj_header endRefreshing];
            
            if (weakSelf.pageNumber == 1) {
                
                if (weakSelf.messageList.count > 0) {
                    //首次加载，自动滚动到底部
                    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:weakSelf.messageList.count - 1];
                    //加载滚动到底部
                    [weakSelf.baseTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    
                    //更新本地存储的最新的一条群发消息
                    [weakSelf updateMassMessageLatestModel];
                    
                }else {
                    //列表为空的时候，不再进行下拉刷新
                    weakSelf.baseTableView.mj_header = nil;
                }
                
            }else {
                //下拉加载，将新加载数据的最后一条，滚动到顶部
                if (tempList.count > 0) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:tempList.count];
                    [weakSelf.baseTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }
        }
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
        [weakSelf.baseTableView.mj_header endRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _messageList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LIMMassMessageModel *messageModel = [_messageList objectAtIndexSafe:indexPath.section];
    if (messageModel.mtype == 0) {
        //文本
        NoaMassMessageTextCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaMassMessageTextCell class]) forIndexPath:indexPath];
        cell.messageModel = messageModel;
        cell.delegate = self;
        cell.massMessageDelegate = self;
        return cell;
    }else {
        //1图片2视频5文件
        NoaMassMessageAttachmentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaMassMessageAttachmentCell class]) forIndexPath:indexPath];
        cell.messageModel = messageModel;
        cell.delegate = self;
        cell.massMessageDelegate = self;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(16))];
    viewHeader.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    return viewHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DWScale(16);
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point {
    return YES;
}
- (NSArray<UIView *> *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings {
    
    swipeSettings.transition = MGSwipeTransitionBorder;//动画效果
    swipeSettings.enableSwipeBounces = NO;
    swipeSettings.allowsButtonsWithDifferentWidth = YES;
    
    expansionSettings.buttonIndex = -1;//可展开按钮索引，即滑动自动触发按钮下标
    expansionSettings.fillOnTrigger = NO;//是否填充
    expansionSettings.threshold = 1.0;//触发阈值
    
    NSIndexPath *cellIndex = [self.baseTableView indexPathForCell:cell];
    LIMMassMessageModel *model = [_messageList objectAtIndexSafe:cellIndex.section];
    
    WeakSelf
    if (direction == MGSwipeDirectionLeftToRight) {
        //从左到右滑动
        return nil;
    }else {
        //从右到左滑动
        
        MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:@"" icon:ImgNamed(@"icon_collection_delete") backgroundColor:COLOR_F5F6F9 callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            //执行删除群发消息逻辑
            [weakSelf deleteMassMessageWith: model];
            return NO;
        }];
        btnDelete.titleLabel.font = FONTR(12);
        btnDelete.buttonWidth = DWScale(86);
        [btnDelete setBtnImageAlignmentType:ButtonImageAlignmentTypeTop imageSpace:DWScale(6)];
        [btnDelete setBackgroundImage:[UIImage ImageForColor:[HEXCOLOR(@"FF504E") colorWithAlphaComponent:0.2]] forState:UIControlStateHighlighted];
        
        return @[btnDelete];
    }
    
}
- (void)swipeTableCell:(MGSwipeTableCell *)cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive {
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"右滑"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"左滑"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"右滑展开"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"左滑展开"; break;
    }
    DLog(@"手势状态:%@------%@",str, gestureIsActive ? @"开始" : @"结束");
}

#pragma mark - DZNEmptyDataSetSource
//图片距离中心偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return DWScale(-120);
}
//空态图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return ImgNamed(@"c_no_history_chat");
}

#pragma mark - DZNEmptyDataSetDelegate
//允许滑动
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - ZMassMessageBaseCellDelegate
//查看全部成员列表
- (void)cellCheckAllReceiverWith:(LIMMassMessageModel *)messageModel {
    NoaMassMessageUserVC *vc = [NoaMassMessageUserVC new];
    vc.allUsers = YES;
    vc.messageModel = messageModel;
    [self.navigationController pushViewController:vc animated:YES];
}
//查看发送失败成员列表
- (void)cellCheckErrorReceiverWith:(LIMMassMessageModel *)messageModel {
    NoaMassMessageUserVC *vc = [NoaMassMessageUserVC new];
    vc.allUsers = NO;
    vc.messageModel = messageModel;
    [self.navigationController pushViewController:vc animated:YES];
}
//图片、视频、文件查看详情
- (void)cellCheckDetailWith:(LIMMassMessageModel *)messageModel {
    if (messageModel.mtype == 5) {
        //文件
        NoaMassMessageFileDetailVC *vc = [[NoaMassMessageFileDetailVC alloc] init];
        vc.messageModel = messageModel;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else {
        //图片/视频
        [self imageVideoBrowserWith:messageModel];
    }
}
- (void)cellSendAgainWith:(LIMMassMessageModel *)messageModel {
    NoaNewMassMessageVC *vc = [NoaNewMassMessageVC new];
    vc.messageModel = messageModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 删除消息
- (void)deleteMassMessageWith:(LIMMassMessageModel *)messageModel {
    WeakSelf
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:messageModel.taskId forKey:@"taskId"];
    
    [IMSDKManager GroupHairDeleteHairMessageWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        
        [weakSelf.messageList enumerateObjectsUsingBlock:^(LIMMassMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj.taskId isEqualToString:messageModel.taskId]) {
                [weakSelf.messageList removeObjectAtIndexSafe:idx];
                *stop = YES;
            }
            
        }];
        
        [weakSelf.baseTableView reloadData];
        [weakSelf updateMassMessageLatestModel];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - 右侧按钮点击事件
- (void)navBtnRightClicked {
    NoaNewMassMessageVC *vc = [[NoaNewMassMessageVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ******图片和视频的浏览******
- (void)imageVideoBrowserWith:(LIMMassMessageModel *)messageModel {
    _currentDetailMessageModel = messageModel;
    
    __block NSMutableArray *browserMessages = [NSMutableArray array];
    __block NSInteger messageModelIndex = 0;//点击的cell在图片视频列表中的位置
    if (messageModel.mtype == 1) {
        //图片
        KNPhotoItems *item = [[KNPhotoItems alloc] init];
        //图片
        item.isVideo = false;
        item.url = [messageModel.bodyModel.name getImageFullString];//原图地址
        item.thumbnailUrl = [messageModel.bodyModel.iImg getImageFullString];//缩略图地址
        
        [browserMessages addObjectIfNotNil:item];
    }else {
        //视频
        KNPhotoItems *item = [[KNPhotoItems alloc] init];
        item.isVideo = true;
        //网络视频封面
        item.videoPlaceHolderImageUrl = [messageModel.bodyModel.cImg getImageFullString];
        //网络视频地址
        item.url = [messageModel.bodyModel.name getImageFullString];
        
        [browserMessages addObjectIfNotNil:item];
    }
    
    KNPhotoBrowser *photoBrowser = [[KNPhotoBrowser alloc] init];
    
    [KNPhotoBrowserConfig share].isNeedCustomActionBar = false;
    
    photoBrowser.delegate = self;
    photoBrowser.itemsArr = browserMessages;
    photoBrowser.placeHolderColor = UIColor.lightTextColor;
    photoBrowser.currentIndex = messageModelIndex;
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
    
    NSString *imageUrl;
    NSString *videoUrl;
    if (_currentDetailMessageModel.mtype == 1) {
        //图片
        imageUrl = [_currentDetailMessageModel.bodyModel.name getImageFullString];
    }else if (_currentDetailMessageModel.mtype == 2) {
        //视频
        //网络视频地址
        videoUrl = [_currentDetailMessageModel.bodyModel.name getImageFullString];
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
            [ZTOOL saveImageToAlbumWith:imageUrl Cusotm:@""];
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
#pragma mark - 更新本地存储的最新群发消息
- (void)updateMassMessageLatestModel {

    //当前最新的群发消息
    LIMMassMessageModel *latestMassMessage = _messageList.lastObject;
    
    //获取原先存储的最新群发消息
    NSString *userKey = [NSString stringWithFormat:@"%@-MassMessage", UserManager.userInfo.userUID];
    NSString *jsonStr = [[MMKV defaultMMKV] getStringForKey:userKey];
    
    if (![NSString isNil:jsonStr]) {
        
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            //转换得到原先存储的最新的群发消息
            LIMMassMessageModel *massMessageModel = [LIMMassMessageModel mj_objectWithKeyValues:dict];
            
            if (![latestMassMessage.sendTime isEqualToString:massMessageModel.sendTime]) {
                //最新群发消息发生改变
                if (latestMassMessage) {
                    [[MMKV defaultMMKV] setString:[latestMassMessage mj_JSONString] forKey:userKey];
                }else {
                    [[MMKV defaultMMKV] removeValueForKey:userKey];
                }
            }
        }
        
    }else {
        //更新最新的群发消息
        if (latestMassMessage) {
            [[MMKV defaultMMKV] setString:[latestMassMessage mj_JSONString] forKey:userKey];
        }else {
            [[MMKV defaultMMKV] removeValueForKey:userKey];
        }
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LatestMassMessageChange" object:nil];
    
    
}
#pragma mark - 通知监听
- (void)updateMessageList {
    _pageNumber = 1;
    [self requestHairGroupMessageList];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
