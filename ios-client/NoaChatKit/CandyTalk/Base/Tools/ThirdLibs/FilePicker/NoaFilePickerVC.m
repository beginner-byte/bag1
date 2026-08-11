//
//  NoaFilePickerVC.m
//  NoaKit
//
//  Created by Candy on 2023/1/4.
//

#import "NoaFilePickerVC.h"
#import "NoaFileSourceView.h"
#import "NoaFilePickerHeaderView.h"
#import "NoaFilePickerCell.h"
#import "NoaToolManager.h"//工具类

@interface NoaFilePickerVC () <UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate>
{
    BOOL _isPhotoOk;
}

@property (nonatomic, strong) UITableView *fileTableView;
@property (nonatomic, strong) NSMutableArray *fileList;
//相册中所有视频文件
@property (nonatomic, strong) NSMutableSet *albumVideoList;
//接收到的其他文件
@property (nonatomic, strong) NSMutableArray *reviceFileList;
//选定的文件
@property (nonatomic, strong) NSMutableArray *selectFileList;

@end

@implementation NoaFilePickerVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //全局隐藏导系统的航栏，使用自定义的navbar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.view bringSubviewToFront:self.navView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    _fileList = [[NSMutableArray alloc] init];
    //相册视频
    NSMutableDictionary *videoFileDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"相册视频",@"title",
                                   [NSNumber numberWithBool:NO],@"unfold",
                                   @[],@"itemArr",nil];
    [_fileList addObject:videoFileDic];
    
    if (![NSString isNil:self.sessionFoldPath]) {
        //接收到的其他文
        NSMutableDictionary *receivedFileDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                LanguageToolMatch(@"接收到的其他文件"),@"title",
                                                [NSNumber numberWithBool:NO],@"unfold",
                                                @[],@"itemArr",nil];
        
        [_fileList addObject:receivedFileDic];        
    }
    
    [self setupNavUI];
    [self setupUI];
    [self requestAlbumAll];
}

#pragma mark - 界面布局
- (void)setupNavUI {
    _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DNavStatusBarH)];
    _navView.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [self.view addSubview:_navView];
    
    _navTitleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navTitleBtn.frame = CGRectMake(DScreenWidth/2 - DWScale(160)/2, DStatusBarH, DWScale(160), DWScale(34));
    _navTitleBtn.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    _navTitleBtn.adjustsImageWhenHighlighted = NO;
    _navTitleBtn.exclusiveTouch = YES;
    if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"英语"] ||
        [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"阿拉伯语"] ||
        [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"法语"] ||
        [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"吉尔吉斯语"] ||
        [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"乌兹别克语"] ||
        [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"西班牙语"]){
        _navTitleBtn.titleLabel.font = FONTB(10);
    } else if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"俄语"]) {
        _navTitleBtn.titleLabel.font = FONTB(8);
    } else if ([ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"土耳其语"] ||
               [ZLanguageTOOL.currentLanguage.languageName_zn isEqualToString:@"波斯语"]) {
        _navTitleBtn.titleLabel.font = FONTB(14);
    }  else {
        _navTitleBtn.titleLabel.font = FONTB(16);
    }
    NSString * st = [NSString stringWithFormat:LanguageToolMatch(@"%@中的文件"), [ZTOOL getAppName]];
    [_navTitleBtn setTitle:st forState:UIControlStateNormal];
    [_navTitleBtn setTkThemeTitleColor:@[COLOR_11, COLOR_11_DARK] forState:UIControlStateNormal];
    [_navTitleBtn setImage:ImgNamed(@"c_circle_arrow") forState:UIControlStateNormal];
    [_navTitleBtn setBtnImageAlignmentType:ButtonImageAlignmentTypeRight imageSpace:DWScale(8)];
    [_navTitleBtn rounded:DWScale(34)/2];
    [_navTitleBtn addTarget:self action:@selector(navTitleBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navTitleBtn];
    
    _navLineView = [[UIView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH - 0.5, DScreenWidth, 0.8)];
    _navLineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    _navLineView.hidden = YES;
    [_navView addSubview:_navLineView];
    
    _navBtnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    _navBtnBack.frame = CGRectMake(DWScale(10), DWScale(DStatusBarH + 4), 30, 30);
    _navBtnBack.adjustsImageWhenHighlighted = NO;
    _navBtnBack.exclusiveTouch = YES;
    [_navBtnBack setTkThemeImage:@[ImgNamed(@"icon_nav_back"), ImgNamed(@"icon_nav_back_dark")] forState:UIControlStateNormal];
    [_navBtnBack addTarget:self action:@selector(navBtnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navBtnBack];
    [_navBtnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_navView.mas_leading).offset(DWScale(10));
        make.centerY.equalTo(_navTitleBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_navBtnBack setEnlargeEdge:DWScale(10)];

    _navBtnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [_navBtnRight setTitle:LanguageToolMatch(@"发送") forState:UIControlStateNormal];
    [_navBtnRight setTkThemeTitleColor:@[COLORWHITE, COLOR_CCCCCC_DARK] forState:UIControlStateNormal];
    _navBtnRight.hidden = YES;
    _navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    [_navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [_navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    _navBtnRight.titleLabel.font = FONTN(12);
    [_navBtnRight rounded:DWScale(12)];
    [_navBtnRight addTarget:self action:@selector(navBtnRightClicked) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navBtnRight];
    [_navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_navBtnBack);
        make.trailing.equalTo(_navView).offset(-16);
        make.height.mas_equalTo(28);
        make.width.mas_greaterThanOrEqualTo(63);
    }];
}

- (void)setupUI {
    [self.view addSubview:self.fileTableView];
    [self.fileTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(_navView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
}

#pragma mark - 获取相册全部视频资源
- (void)requestAlbumAll {
    //获取手机相册图片
    __weak typeof(self) weakSelf = self;
    [ZTOOL doAsync:^{
        [HUD showActivityMessage:LanguageToolMatch(@"加载中...")];
        [weakSelf getAllPhotoList];
    } completion:^{
        NSArray <PHAsset *> *albumVideoArr = [self fetchLocalCoverListWithAssets:weakSelf.albumVideoList];
        __block NSMutableArray *resultAlbumArr = [NSMutableArray array];
        for (PHAsset *tempAsset in albumVideoArr) {
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.synchronous = YES;//同步，如果有卡顿的情况，可设置为NO异步
            [[PHImageManager defaultManager] requestImageDataForAsset:tempAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] == NO) {
                    NoaFilePickModel *albumVideoModel = [[NoaFilePickModel alloc] init];
                    albumVideoModel.fileSource = ZMsgFileSourceTypeAlbumVideo;
                    albumVideoModel.videoAsset = tempAsset;
                    albumVideoModel.isSelected = NO;
                    [resultAlbumArr addObject:albumVideoModel];
                }
            }];
        }
        
        [HUD hideHUD];
        
        NSMutableDictionary *albumDic = (NSMutableDictionary *)[weakSelf.fileList objectAtIndex:0];
        [albumDic setObjectSafe:resultAlbumArr forKey:@"itemArr"];
        [albumDic setObjectSafe:[NSString stringWithFormat:@"%@（%lu）",LanguageToolMatch(@"相册视频"), (unsigned long)albumVideoArr.count] forKey:@"title"];
        [weakSelf.fileList replaceObjectAtIndex:0 withObject:albumDic];
        [weakSelf.fileTableView reloadData];
        
        //获取当前会话，本地存储的所有文件
        if (![NSString isNil:weakSelf.sessionFoldPath]) {
            [weakSelf getSessionLocalFile];
        }
    }];
}

#pragma mark - 获得所有的视频PHAsset方法
- (void)getAllPhotoList {
    [self.albumVideoList removeAllObjects];
    __weak typeof (self) weakSelf = self;
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    //只展示视频
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeVideo];
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny  options:nil];
    [albums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        if (assetsFetchResult.count > 0 ) {
            [assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                if (asset != nil) {
                    [weakSelf.albumVideoList addObject:asset];
                }
            }];
        }
    }];
}

#pragma mark - 获取当前会话，本地存储的所有文件
- (void)getSessionLocalFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    //该文件夹下所有文件的文件名及文件夹名的数组
    NSArray *allFileList = [fileManager contentsOfDirectoryAtPath:self.sessionFoldPath error:&error];
    NSMutableArray *resultFileArr = [NSMutableArray array];
    for (NSString *tempFileName in allFileList) {
        //筛选掉隐藏文件：隐藏文件，其实是利用unix文件系统的特性，在文件命名的时候加了一个点“.”实现了隐藏文件的效果
        if (![[tempFileName substringToIndex:1] isEqualToString:@"."]) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.sessionFoldPath, tempFileName];
            float fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
            NoaFilePickModel *singleFileModel = [[NoaFilePickModel alloc] init];
            singleFileModel.fileName = tempFileName;
            singleFileModel.filePath = filePath;
            singleFileModel.fileSource = ZMsgFileSourceTypeLingxin;
            singleFileModel.fileSize = fileSize;
            singleFileModel.fileType = [NSString fileTranslateToFileType:filePath];
            singleFileModel.isSelected = NO;
            [resultFileArr addObject:singleFileModel];
        }
    }
    
    NSMutableDictionary *localFileDic = (NSMutableDictionary *)[self.fileList objectAtIndex:1];
    [localFileDic setObjectSafe:resultFileArr forKey:@"itemArr"];
    [self.fileList replaceObjectAtIndex:1 withObject:localFileDic];
    [self.fileTableView reloadData];
}

#pragma mark - Setter
//导航栏标题赋值
- (void)setNavTitleStr:(NSString *)navTitleStr {
    _navTitleStr = navTitleStr;
    [_navTitleBtn setTitle:_navTitleStr forState:UIControlStateNormal];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fileList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableDictionary *sectionDic = (NSMutableDictionary *)[self.fileList objectAtIndex:section];
    BOOL unfold = (BOOL)[[sectionDic objectForKey:@"unfold"] boolValue];
    if (unfold) {
        //展开
        NSArray *itemArr = (NSArray *)[sectionDic objectForKey:@"itemArr"];
        return itemArr.count;
    } else {
        //未展开
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(68);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DWScale(54);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSMutableDictionary *sectionDic = (NSMutableDictionary *)[self.fileList objectAtIndex:section];
    NoaFilePickerHeaderView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([NoaFilePickerHeaderView class])];
    viewHeader.contentStr = (NSString *)[sectionDic objectForKey:@"title"];
    BOOL unfold = (BOOL)[[sectionDic objectForKey:@"unfold"] boolValue];
    viewHeader.unFlod = unfold;
    WeakSelf
    viewHeader.ZFileHeaderClick = ^{
        [sectionDic setObjectSafe:[NSNumber numberWithBool:!unfold] forKey:@"unfold"];
        [weakSelf.fileList replaceObjectAtIndex:section withObject:sectionDic];
        [weakSelf.fileTableView reloadData];
    };
    return viewHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaFilePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaFilePickerCell class]) forIndexPath:indexPath];
    NSMutableDictionary *sectionDic = (NSMutableDictionary *)[self.fileList objectAtIndex:indexPath.section];
    if (indexPath.section == 0) {
        NSArray *itemArr = (NSArray *)[sectionDic objectForKey:@"itemArr"];
        NoaFilePickModel *tempAssetModel = (NoaFilePickModel *)[itemArr objectAtIndex:indexPath.row];
        cell.videoAsset = tempAssetModel.videoAsset;
        cell.isSelected = tempAssetModel.isSelected;
    } else {
        NSArray *itemArr = (NSArray *)[sectionDic objectForKey:@"itemArr"];
        NoaFilePickModel *tempFileModel = (NoaFilePickModel *)[itemArr objectAtIndex:indexPath.row];
        cell.showName = tempFileModel.fileName;
        cell.localFileType = tempFileModel.fileType;
        cell.localFileSize = tempFileModel.fileSize;
        cell.isSelected = tempFileModel.isSelected;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NoaFilePickerCell *cell = [self.fileTableView cellForRowAtIndexPath:indexPath];
    
    if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"true"] && ((cell.currentFileSize / (1024 * 1024)) > [UserManager.userRoleAuthInfo.upFile.configData integerValue])) {
        [HUD showMessage:LanguageToolMatch(@"所选资源超过限制")];
        return;
    } else {
        cell.isSelected = !cell.isSelected;
        NSMutableDictionary *sectionDic = (NSMutableDictionary *)[self.fileList objectAtIndex:indexPath.section];
        
        //相册中的视频
        if (indexPath.section == 0) {
            NSMutableArray *itemArr = (NSMutableArray *)[sectionDic objectForKey:@"itemArr"];
            NoaFilePickModel *tempAssetModel = (NoaFilePickModel *)[itemArr objectAtIndex:indexPath.row];
            if (cell.isSelected && ![NSString isValiableWithFileName:[cell showName]]) {
                // 当前选中状态，并包含特殊字符:\/:*?\"<>|
                [HUD showMessage:LanguageToolMatch(@"文件名不能包含下列任何字符:\\/:*?\"<>|")];
                cell.isSelected = !cell.isSelected;
                return;
            }
            //选择状态改变后，更新tableView数据源数组里的数据
            tempAssetModel.isSelected = cell.isSelected;
            [itemArr replaceObjectAtIndex:indexPath.row withObject:tempAssetModel];
            [sectionDic setObjectSafe:itemArr forKey:@"itemArr"];
            [self.fileList replaceObjectAtIndex:indexPath.section withObject:sectionDic];
        
            //将点击的元素加入或者移除 已选择数组
            if (cell.isSelected) {
                [self.selectFileList addObject:tempAssetModel];
            } else {
                [self.selectFileList removeObject:tempAssetModel];
            }
        } else {
            //App中接收到的文件
            NSMutableArray *itemArr = (NSMutableArray *)[sectionDic objectForKey:@"itemArr"];
            NoaFilePickModel *tempFileModel = (NoaFilePickModel *)[itemArr objectAtIndex:indexPath.row];
            if (cell.isSelected && ![NSString isValiableWithFileName:tempFileModel.fileName]) {
                [HUD showMessage:LanguageToolMatch(@"文件名不能包含下列任何字符:\\/:*?\"<>|")];
                cell.isSelected = !cell.isSelected;
                return;
            }
            //选择状态改变后，更新tableView数据源数组里的数据
            tempFileModel.isSelected = cell.isSelected;
            [itemArr replaceObjectAtIndex:indexPath.row withObject:tempFileModel];
            [sectionDic setObjectSafe:itemArr forKey:@"itemArr"];
            [self.fileList replaceObjectAtIndex:indexPath.section withObject:sectionDic];
        
            //将点击的元素加入或者移除 已选择数组
            if (cell.isSelected) {
                [self.selectFileList addObject:tempFileModel];
            } else {
                [self.selectFileList removeObject:tempFileModel];
            }
        }
        
        _navBtnRight.hidden = self.selectFileList.count > 0 ? NO : YES;
        [_navBtnRight setTitle:[NSString stringWithFormat:LanguageToolMatch(@"发送(%d)"), self.selectFileList.count] forState:UIControlStateNormal];
        
        if (![NSString isNil:_sessionFoldPath]) {
            //聊天界面发送文件 选中
        }else {
            //群发助手发送文件 选中
            if (self.selectFileList.count == 1) {
                [self navBtnRightClicked];
            }
        }
    }

}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    // 获取授权
    WeakSelf
    BOOL fileAut = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAut) {
        //通过文件协调工具来得到新的文件地址
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        __block NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            //获取文件大小
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                [HUD showMessage:LanguageToolMatch(@"未能打开文件")];
                return;
            }
            DLog(@"文件大小:%lu", (unsigned long)fileData.length);
            float fileSize = (float)fileData.length / (1024 * 1024.0);
            if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"true"] && (fileSize > [UserManager.userRoleAuthInfo.upFile.configData integerValue])) {
                [HUD showMessage:LanguageToolMatch(@"所选资源超过限制")];
                return;
            } else {
                NSString *fileName = [newURL lastPathComponent];
                if (![NSString isValiableWithFileName:fileName]) {
                    [HUD showMessage:LanguageToolMatch(@"文件名不能包含下列任何字符:\\/:*?\"<>|")];
                    return;
                }
                NoaFilePickModel *phoneFileModel = [[NoaFilePickModel alloc] init];
                phoneFileModel.fileSource = ZMsgFileSourceTypePhone;
                phoneFileModel.fileType = [NSString fileTranslateToFileType:[newURL absoluteString]];
                phoneFileModel.phoneFileUrl = newURL;
                if (weakSelf.savePhoneFileSuccess) {
                    weakSelf.savePhoneFileSuccess(phoneFileModel);
                }
                [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
         }];
        
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        //授权失败
     }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSString * st = [NSString stringWithFormat:LanguageToolMatch(@"%@中的文件"), [ZTOOL getAppName]];
    [self.navTitleBtn setTitle:st forState:UIControlStateNormal];
}

#pragma mark - Action
//返回
- (void)navBtnBackClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

//标题按钮-选择文件来源
- (void)navTitleBtnClicked {
    NoaFileSourceView *sourceView = [[NoaFileSourceView alloc] init];
    [sourceView showSourceView];
    self.navTitleBtn.userInteractionEnabled = NO;
    WeakSelf
    [sourceView setSelectClick:^(NSInteger index) {
        if (index == 1) {
            //App中的文件
            NSString * st = [NSString stringWithFormat:LanguageToolMatch(@"%@中的文件"), [ZTOOL getAppName]];
            [weakSelf.navTitleBtn setTitle:st forState:UIControlStateNormal];
        }
        if (index == 2) {
            //手机储存
            [weakSelf.navTitleBtn setTitle:LanguageToolMatch(@"手机储存") forState:UIControlStateNormal];
            NSArray*types = @[@"public.data", @"com.microsoft.powerpoint.ppt", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.pptx", @"com.microsoft.word.docx", @"com.microsoft.excel.xlsx", @"public.avi", @"public.3gpp", @"public.mpeg-4", @"com.compuserve.gif", @"public.jpeg", @"public.png", @"public.plain-text", @"com.adobe.pdf"];
            
            UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeOpen];
            documentPicker.delegate = weakSelf;
            documentPicker.modalPresentationStyle = UIModalPresentationPageSheet;
            [weakSelf presentViewController:documentPicker animated:YES completion:nil];
        }
        weakSelf.navTitleBtn.userInteractionEnabled = YES;
    }];
    [sourceView setDismissClick:^{
        weakSelf.navTitleBtn.userInteractionEnabled = YES;
    }];
}

//发送
- (void)navBtnRightClicked {
    if (self.saveLingXinFileSuccess) {
        self.saveLingXinFileSuccess(self.selectFileList);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Othetr
//排序
- (NSMutableArray <PHAsset *> *)fetchLocalCoverListWithAssets:(NSMutableSet *)assetSet {
    // 排序
    NSMutableArray *array = [NSMutableArray arrayWithArray:assetSet.allObjects];
    [self quickSortArray:array withLeftIndex:0 andRightIndex:array.count - 1];
    return array;
}

// 快速排序
- (void)quickSortArray:(NSMutableArray *)array withLeftIndex:(NSInteger)leftIndex andRightIndex:(NSInteger)rightIndex {
    if (leftIndex >= rightIndex) {  // 如果数组长度为0或1时返回
        return;
    }

    NSInteger i = leftIndex;
    NSInteger j = rightIndex;
    // 记录比较基准数
    PHAsset *key = array[i];
    while (i < j) {
        // 首先从右边j开始查找比基准数大的值
        while (i < j && [self compareAssetCreationDate:array[j] targetAsset:key] <= 0) {  // 如果比基准数小，继续查找
            j--;
        }
        // 如果比基准数大，则将查找到的值调换到i的位置
        array[i] = array[j];
        // 当在右边查找到一个比基准数大的值时，就从i开始往后找比基准数小的值
        while (i < j && [self compareAssetCreationDate:array[i] targetAsset:key] >= 0) {  // 如果比基准数大，继续查找
            i++;
        }
        // 如果比基准数小，则将查找到的值调换到j的位置
        array[j] = array[i];
    }
    // 将基准数放到正确位置
    array[i] = key;

    /**** 递归排序 ***/
    // 排序基准数左边的
    [self quickSortArray:array withLeftIndex:leftIndex andRightIndex:i - 1];
    // 排序基准数右边的
    [self quickSortArray:array withLeftIndex:i + 1 andRightIndex:rightIndex];
}

// 比较大小(asset == targetAsset -> 0，asset > targetAsset -> 1，asset < targetAsset -> -1)
- (NSInteger)compareAssetCreationDate:(PHAsset *)asset targetAsset:(PHAsset *)targetAsset {
    NSInteger result = 0;
    switch ([asset.creationDate compare:targetAsset.creationDate]) {
        case NSOrderedSame:
            result = 0;
            break;
        case NSOrderedDescending:
            result = 1;
            break;
        case NSOrderedAscending:
            result = -1;
            break;
        default:
            break;
    }
    return result;
}


#pragma mark - Lazy
- (UITableView *)fileTableView {
    if (!_fileTableView) {
        _fileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, DNavStatusBarH, DScreenWidth, DScreenHeight - DNavStatusBarH - DHomeBarH) style:UITableViewStylePlain];
        _fileTableView.delegate = self;
        _fileTableView.dataSource = self;
        _fileTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
        _fileTableView.bounces = NO;
        _fileTableView.separatorColor = COLOR_CLEAR;
        
        [_fileTableView registerClass:[NoaFilePickerHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([NoaFilePickerHeaderView class])];
        [_fileTableView registerClass:[NoaFilePickerCell class] forCellReuseIdentifier:NSStringFromClass([NoaFilePickerCell class])];
    }
    return _fileTableView;
}

- (NSMutableSet *)albumVideoList {
    if (!_albumVideoList) {
        _albumVideoList = [[NSMutableSet alloc] init];
    }
    return _albumVideoList;
}

- (NSMutableArray *)reviceFileList {
    if (!_reviceFileList) {
        _reviceFileList = [[NSMutableArray alloc] init];
    }
    return _reviceFileList;
}


- (NSMutableArray *)selectFileList {
    if (!_selectFileList) {
        _selectFileList = [[NSMutableArray alloc] init];
    }
    return _selectFileList;
}

@end
