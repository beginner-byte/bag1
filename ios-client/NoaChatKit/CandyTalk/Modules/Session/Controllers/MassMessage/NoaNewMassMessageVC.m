//
//  NoaNewMassMessageVC.m
//  NoaKit
//
//  Created by Candy on 2023/4/17.
//

#import "NoaNewMassMessageVC.h"
#import "NoaNewMassMessageContentView.h"
#import "NoaMassMessageUserHeaderCell.h"
#import "NoaMassMessageSelectUserVC.h"
//#import "ZFileNetProgressManager.h"
#import "NoaFilePickModel.h"
#import "NoaFileUploadManager.h"

typedef NS_ENUM(NSUInteger, MassMessageSelectType) {
    MassMessageSelectTypeText = 0,        //当前选择是文本
    MassMessageSelectTypeAttachment = 1,  //当前选择是附件
};

typedef NS_ENUM(NSUInteger, MassMessageType) {
    MassMessageTypeText = 0,   //群发文本类型消息
    MassMessageTypeImage = 1,  //群发图片类型消息
    MassMessageTypeVideo = 2,  //群发视频类型消息
    MassMessageTypeFile = 5,   //群发文件类型消息
};

#define Mass_Tag_Max_Num        16

@interface NoaNewMassMessageVC () <UICollectionViewDataSource, UICollectionViewDelegate, ZMassMessageSelectUserDelegate, ZNewMassMessageContentViewDelegate>
@property (nonatomic, strong) UIView *viewUser;//接受消息人
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NoaNewMassMessageContentView *viewMessage;//消息内容

@property (nonatomic, strong) UIView *viewTarget;//标签
@property (nonatomic, strong) UITextField *tfTarget;
@property (nonatomic, strong) UILabel *lblTarget;

@property (nonatomic, strong) UIButton *btnSend;//立即发送

@property (nonatomic, strong) NSArray<NoaBaseUserModel *> *selectedUserList;//选中的用户信息

@property (nonatomic, strong) NSMutableArray *selectedFriendIdList;//选中的好友id
@property (nonatomic, strong) NSMutableArray *selectedGroupIdList;//选中的群组id

@property (nonatomic, assign) MassMessageSelectType massMessageSelectType;//当前选择发送消息类型
@property (nonatomic, assign) MassMessageType massMessageType;//群发消息类型
@property (nonatomic, strong) id attachment;//附件内容

@property (nonatomic, copy) NSString *labelID;//群发组ID
@property (nonatomic, strong) NSMutableDictionary *bodyDict;

//@property (nonatomic, strong) ZFileNetProgressManager *fileUploader;

@end

@implementation NoaNewMassMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitleStr = LanguageToolMatch(@"群发");
    
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    _selectedUserList = [NSArray array];
    _selectedFriendIdList = [NSMutableArray array];
    _selectedGroupIdList = [NSMutableArray array];
    
    //默认进来是文本类型
    _massMessageSelectType = MassMessageSelectTypeText;
    _massMessageType = MassMessageTypeText;
    if (_messageModel) {
        _selectedUserList = [_messageModel.userUidList mutableCopy];
        _labelID = _messageModel.labelId;
    }
    
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setupUI {
    [self.view addSubview:self.baseTableView];
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(500))];
    viewHeader.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.baseTableView.tableHeaderView = viewHeader;
    [self defaultTableViewUI];
    
    //DWScale(77)  DWScale(137)
    CGFloat viewUserH = DWScale(77);
    if (_selectedUserList.count > 6) viewUserH = DWScale(137);
    
    _viewUser = [[UIView alloc] initWithFrame:CGRectMake(DWScale(16), DWScale(16), DScreenWidth - DWScale(32), viewUserH)];
    _viewUser.layer.cornerRadius = DWScale(12);
    _viewUser.layer.masksToBounds = YES;
    _viewUser.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [viewHeader addSubview:_viewUser];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(DWScale(44), DWScale(44));
    layout.minimumInteritemSpacing = DWScale(4.5);
    layout.minimumLineSpacing = DWScale(8);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(DWScale(17), DWScale(17), DWScale(16), DWScale(17));
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.tkThemebackgroundColors = @[[UIColor clearColor],[UIColor clearColor]];
    [_collectionView registerClass:[NoaMassMessageUserHeaderCell class] forCellWithReuseIdentifier:NSStringFromClass([NoaMassMessageUserHeaderCell class])];
    [_viewUser addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_viewUser);
    }];
    
    
    _viewMessage = [[NoaNewMassMessageContentView alloc] initWithFrame:CGRectMake(DWScale(16), DWScale(32) + viewUserH, DScreenWidth - DWScale(32), DWScale(200))];
    _viewMessage.layer.cornerRadius = DWScale(12);
    _viewMessage.layer.masksToBounds = YES;
    _viewMessage.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    _viewMessage.delegate = self;
    [viewHeader addSubview:_viewMessage];
    
    _viewTarget = [[UIView alloc] initWithFrame:CGRectMake(DWScale(16), DWScale(48) + viewUserH + DWScale(200), DScreenWidth - DWScale(32), DWScale(54))];
    _viewTarget.layer.cornerRadius = DWScale(12);
    _viewTarget.layer.masksToBounds = YES;
    _viewTarget.tkThemebackgroundColors = @[COLORWHITE, COLORWHITE_DARK];
    [viewHeader addSubview:_viewTarget];
    
    _lblTarget = [[UILabel alloc] init];
    _lblTarget.text = [NSString stringWithFormat:@"%@/%d", @"0", Mass_Tag_Max_Num];
    _lblTarget.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblTarget.textAlignment = NSTextAlignmentRight;
    _lblTarget.font = FONTR(12);
    [_viewTarget addSubview:_lblTarget];
    [_lblTarget mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewTarget);
        make.trailing.equalTo(_viewTarget).offset(DWScale(-16));
        make.width.mas_equalTo(DWScale(30));
        make.height.mas_equalTo(DWScale(30));
    }];
    
    _tfTarget = [UITextField new];
    _tfTarget.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _tfTarget.font = FONTR(12);
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"设置群发标签（非必填）") attributes:
        @{NSForegroundColorAttributeName:COLOR_99,
          NSFontAttributeName:_tfTarget.font
        }];
    _tfTarget.attributedPlaceholder = attrString;
    [_viewTarget addSubview:_tfTarget];
    [_tfTarget mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_viewTarget);
        make.leading.equalTo(_viewTarget).offset(DWScale(16));
        make.trailing.equalTo(_lblTarget.mas_leading).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(30));
    }];
    
    _btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSend.layer.cornerRadius = DWScale(14);
    _btnSend.layer.masksToBounds = YES;
    [_btnSend setTitle:LanguageToolMatch(@"立即发送") forState:UIControlStateNormal];
    _btnSend.titleLabel.font = FONTR(16);
    [_btnSend setTkThemeTitleColor:@[COLORWHITE, COLORWHITE_DARK] forState:UIControlStateNormal];
    [_btnSend setTkThemebackgroundColors:@[COLOR_5966F2, COLOR_5966F2_DARK]];
    [_btnSend addTarget:self action:@selector(btnSendClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnSend];
    [_btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DWScale(26) - DHomeBarH);
        make.size.mas_equalTo(CGSizeMake(DWScale(343), DWScale(50)));
    }];
}

- (void)textFieldDidChange{
    // 判断是否存在高亮字符，如果有，则不进行字数统计和字符串截断
    UITextRange *selectedRange = _tfTarget.markedTextRange;
    UITextPosition *position = [_tfTarget positionFromPosition:selectedRange.start offset:0];
    if (position) {
        return;
    }

    // 判断是否超过最大字数限制，如果超过就截断
    if (_tfTarget.text.length > Mass_Tag_Max_Num) {
        _tfTarget.text = [_tfTarget.text substringToIndex:Mass_Tag_Max_Num];
    }
    // 剩余字数显示 UI 更新
   _lblTarget.text = [NSString stringWithFormat:@"%ld/%d",_tfTarget.text.length, Mass_Tag_Max_Num];
}

#pragma mark - 交互事件
- (void)btnSendClick {
    if (_selectedUserList.count < 1) return;
    
    //防连续点击事件
    self.btnSend.enabled = NO;
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.btnSend.enabled = YES;
    });
    
    if (_massMessageSelectType == MassMessageSelectTypeText) {
        //发送文本
        if ([NSString isNil:[_viewMessage.tvMessage.text trimString]]) return;
        [HUD showActivityMessage:LanguageToolMatch(@"发送中...")];

        _bodyDict = [NSMutableDictionary dictionary];
        [_bodyDict setValue:[_viewMessage.tvMessage.text trimString] forKey:@"content"];
        [_bodyDict setValue:@"" forKey:@"ext"];
        [self groupHairCreateHairGroupWith:[_bodyDict mj_JSONString]];
        
    }else {
        
        //发送附件
        if (!_viewMessage.ivAttachment.image) return;
        [HUD showActivityMessage:LanguageToolMatch(@"发送中...")];
        
        //先上传图片，视频，文件
        if (_massMessageType == MassMessageTypeImage) {
            //上传图片
            [self uploadImage];
        }else if (_massMessageType == MassMessageTypeVideo) {
            //上传视频
            [self uploadVideo];
        }else if (_massMessageType == MassMessageTypeFile) {
            //上传文件
            [self uploadFile];
        }
    }
}
#pragma mark - 创建群发组
- (void)groupHairCreateHairGroupWith:(NSString *)bodyJsonStr {
    if (_messageModel) {
        //再发一次，不生成新的群发组ID
        _labelID = _messageModel.labelId;
        [self groupHairSendHairGroupMessageWithJsonStr:bodyJsonStr];
    }else {
        //生成新的群发组ID
        WeakSelf
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:[_tfTarget.text trimString] forKey:@"label"];
        [dict setValue:_selectedFriendIdList forKey:@"userUidList"];
        [dict setValue:_selectedGroupIdList forKey:@"groupUidList"];
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
        [IMSDKManager GroupHairCreateHairGroupWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
            [HUD hideHUD];
            NSString *hairGroupId = (NSString *)data;
            weakSelf.labelID = hairGroupId;
            [weakSelf groupHairSendHairGroupMessageWithJsonStr:bodyJsonStr];
        } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
            [HUD hideHUD];
            [HUD showMessageWithCode:code errorMsg:msg];
        }];
    }
}

#pragma mark - 发送群发消息
- (void)groupHairSendHairGroupMessageWithJsonStr:(NSString *)jsonStr {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_labelID forKey:@"labelId"];
    [dict setValue:jsonStr forKey:@"body"];
    [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    [dict setValue:@(_massMessageType) forKey:@"mtype"];
    
    WeakSelf
    [IMSDKManager GroupHairSendHairMessageWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD showMessage:LanguageToolMatch(@"发送成功")];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MassMessageSendSuccess" object:nil];
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selectedUserList.count <= 11) {
        return _selectedUserList.count + 1;
    }else {
        return 12;
    }
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaMassMessageUserHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaMassMessageUserHeaderCell class]) forIndexPath:indexPath];
    
    id model;
    if (indexPath.row < 11) {
        model = [_selectedUserList objectAtIndexSafe:indexPath.row];
    }
    cell.model = model;
    
    if (model != nil) {
        cell.ivHeader.hidden = NO;
    }else {
        if (_messageModel) {
            cell.ivHeader.hidden = YES;
        }else {
            cell.ivHeader.hidden = NO;
        }
    }
    
    if (_selectedUserList.count > 11 && indexPath.row == 0) {
        cell.viewMask.hidden = NO;
        cell.lblNumber.text = [NSString stringWithFormat:LanguageToolMatch(@"%ld人"), _selectedUserList.count];
    }else {
        cell.viewMask.hidden = YES;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedUserList.count > 0) {
        if (_selectedUserList.count <= 11) {
            if (indexPath.row == _selectedUserList.count) {
                //点击 +
                [self goSelectReceiveMessageUser];
            }
        }else {
            if (indexPath.row == 11) {
                //点击 +
                [self goSelectReceiveMessageUser];
            }
        }
    }else {
        //点击 +
        [self goSelectReceiveMessageUser];
    }
}
//去选择接收消息的人
- (void)goSelectReceiveMessageUser {
    
    //再发一次，不能修改成员
    if (_messageModel) return;
    
    NoaMassMessageSelectUserVC *vc = [NoaMassMessageSelectUserVC new];
    vc.selectedList = [_selectedUserList mutableCopy];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - ZMassMessageSelectUserDelegate
- (void)massMessageSelectedUserList:(NSArray<NoaBaseUserModel *> *)selectedUserList {
    _selectedUserList = selectedUserList;
    CGFloat viewUserH = DWScale(77);
    if (_selectedUserList.count > 6) viewUserH = DWScale(137);
    
    _viewUser.height = viewUserH;
    _viewMessage.y = DWScale(32) + viewUserH;
    _viewTarget.y = DWScale(48) + viewUserH + DWScale(200);
    
    WeakSelf
    [_selectedUserList enumerateObjectsUsingBlock:^(NoaBaseUserModel* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isGroup) {
            [weakSelf.selectedGroupIdList addObject:obj.userId];
        } else {
            [weakSelf.selectedFriendIdList addObject:obj.userId];
        }
    }];
    
    [_collectionView reloadData];
}

#pragma mark - ZNewMassMessageContentViewDelegate
- (void)newMassMessageSelect:(NSInteger)selectType {
    _massMessageSelectType = selectType;
}
- (void)newMassMessageAttachmentType:(NSInteger)attachmentType attachment:(id)attachment {
    _massMessageType = attachmentType;
    _attachment = attachment;
}

#pragma mark - 图片上传方法
- (void)uploadImage {
    WeakSelf
    PHAsset *mediaAsset = (PHAsset *)_attachment;
    //发送图片
    //发送图片
    CGSize targetSize = CGSizeMake(mediaAsset.pixelWidth, mediaAsset.pixelHeight);
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;//同步，如果有卡顿的情况，可设置为NO异步
    [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:mediaAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
        //中间目录
        NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, @"chat_mass_message"];
        
        if ([[info valueForKey:@"PHImageResultIsDegradedKey"] integerValue] == 0){
            NSMutableArray *taskArr = [NSMutableArray array];
            //目录路径
            //缩略图
            NSData *thumbImageData;
            if ([[[NSString getImageFileFormat:imageData] lowercaseString] isEqualToString:@"gif"]) {
                //GIF图片
                thumbImageData = imageData;
            } else {
                //静态图片
                thumbImageData = [UIImage compressImageSize:[UIImage imageWithData:imageData] toByte:50*1024];//压缩到50KB
            }
            //原图名称
            NSString *originImageName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:imageData]];
            //缩略图名称
            NSString *thumbImgFileName = [[NSString alloc] initWithFormat:@"thumbil_%@", originImageName];
            
            NSInteger imgSize = imageData.length;
            NSInteger imgWidth = targetSize.width;
            NSInteger imgHeight = targetSize.height;
            
            __block NSString *thumbnailImagePath = @"";
            __block NSString *imagePath = @"";
            weakSelf.bodyDict = [NSMutableDictionary dictionary];
            [ZTOOL doAsync:^{
                //保存缩略图到本地沙盒
                [NSString saveImageToSaxboxWithData:thumbImageData CustomPath:customPath ImgName:thumbImgFileName];
                thumbnailImagePath = [NSString getPathWithImageName:thumbImgFileName CustomPath:customPath];
                //保存原图到本地沙盒
                [NSString saveImageToSaxboxWithData:imageData CustomPath:customPath ImgName:originImageName];
                imagePath = [NSString getPathWithImageName:originImageName CustomPath:customPath];
            } completion:^{
                
                //上传缩略图task
                NoaFileUploadTask *thumbTask = [[NoaFileUploadTask alloc] initWithTaskId:thumbImgFileName filePath:thumbnailImagePath originFilePath:imagePath fileName:thumbImgFileName fileType:@"" isEncrypt:YES dataLength:thumbImageData.length uploadType:ZHttpUploadTypeImageThumbnail beSendMessage:nil delegate:nil];
                thumbTask.messageTaskType = FileUploadMessageTaskTypeNoamlImgThumb;
                [taskArr addObject:thumbTask];
                
                //上传原图
                NoaFileUploadTask *task = [[NoaFileUploadTask alloc] initWithTaskId:originImageName filePath:imagePath originFilePath:@"" fileName:originImageName fileType:@"" isEncrypt:YES dataLength:imageData.length uploadType:ZHttpUploadTypeImage beSendMessage:nil delegate:nil];
                task.messageTaskType = FileUploadMessageTaskTypeNoamlImg;
                [taskArr addObject:task];
                
                __block NSInteger taskNum = 0;
                NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                    for (NoaFileUploadTask *task in taskArr) {
                        if (task.status == FileUploadTaskStatus_Completed) {
                            if (task.messageTaskType == FileUploadMessageTaskTypeNoamlImgThumb) {
                                [weakSelf.bodyDict setValue:task.originUrl forKey:@"iImg"];//缩略图地址
                                taskNum++;
                            }
                            if (task.messageTaskType == FileUploadMessageTaskTypeNoamlImg) {
                                [weakSelf.bodyDict setValue:task.originUrl forKey:@"name"];//图片完整Url
                                taskNum++;
                            }
                            if (taskNum == 2) {
                                if (weakSelf.massMessageType == MassMessageTypeImage) {
                                    if (weakSelf.massMessageType == MassMessageTypeImage) {
                                        [weakSelf.bodyDict setValue:@(imgSize) forKey:@"size"];
                                        [weakSelf.bodyDict setValue:@(imgWidth) forKey:@"width"];
                                        [weakSelf.bodyDict setValue:@(imgHeight) forKey:@"height"];
                                        [weakSelf.bodyDict setValue:@"" forKey:@"ext"];
                                        //调用接口
                                        [ZTOOL doInMain:^{
                                            [weakSelf groupHairCreateHairGroupWith:[weakSelf.bodyDict mj_JSONString]];
                                        }];
                                    }
                                }
                            }
                        } else {
                            [ZTOOL doInMain:^{
                                [HUD showMessage:LanguageToolMatch(@"上传图片失败")];
                            }];
                        }
                    }
                }];
                NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
                getSTSTask.uploadTask = taskArr;
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];

                for (NoaFileUploadTask *task in taskArr) {
                    [[NoaFileUploadManager sharedInstance] addUploadTask:task];
                    [blockOperation addDependency:task];
                }
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
            }];
        }
    }];
}

#pragma mark - 上传视频
- (void)uploadVideo {
    //发送视频
    WeakSelf
    PHAsset *mediaAsset = (PHAsset *)_attachment;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;

    [[PHImageManager defaultManager] requestAVAssetForVideo:mediaAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)asset;
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            
            NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, @"chat_mass_message"];
            //视频
            NSData *videoData = [NSData dataWithContentsOfURL:urlAsset.URL options:NSDataReadingMappedIfSafe error:nil];
        
            NSString *videoName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getVideoFileFormat:urlAsset.URL]];
            
            //视频封面
            UIImage *coverImg =  [UIImage thumbnailImageForVideo:urlAsset.URL atTime:1];
            NSData *coverImgData = UIImageJPEGRepresentation(coverImg, 0.5);
            NSString *coverImgName = [[NSString alloc] initWithFormat:@"cover_%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:coverImgData]];
            
            //length视频时长
            CMTime time = [asset duration];
            int64_t seconds = time.value / time.timescale;
            //cWidth视频封面宽度   cHeight视频封面高度
            NSInteger cWidth = coverImg.size.width;
            NSInteger cHeight = coverImg.size.height;
            
            weakSelf.bodyDict = [NSMutableDictionary dictionary];
            [weakSelf.bodyDict setValue:@"" forKey:@"ext"];//拓展字段
            [weakSelf.bodyDict setValue:@(cWidth) forKey:@"cWidth"];//视频封面宽度
            [weakSelf.bodyDict setValue:@(cHeight) forKey:@"cHeight"];//视频封面高度
            [weakSelf.bodyDict setValue:@(seconds) forKey:@"length"];//视频大小
            
            __block NSString *coverImgPath = @"";
            __block NSString *videoPath  = @"";
            [ZTOOL doAsync:^{
                //保存封面图到本地沙盒
                [NSString saveImageToSaxboxWithData:coverImgData CustomPath:customPath ImgName:coverImgName];
                coverImgPath = [NSString getPathWithImageName:coverImgName CustomPath:customPath];
                //保存视频到本地沙盒
                [NSString saveVideoToSaxboxWithData:videoData CustomPath:customPath VideoName:videoName];
                videoPath = [NSString getPathWithVideoName:videoName CustomPath:customPath];
            } completion:^{
                NSMutableArray *taskArray = [NSMutableArray array];
                //封面
                NoaFileUploadTask *coverTask = [[NoaFileUploadTask alloc] initWithTaskId:coverImgName filePath:coverImgPath originFilePath:@"" fileName:coverImgName fileType:@"" isEncrypt:YES dataLength:coverImgData.length uploadType:ZHttpUploadTypeImage beSendMessage:nil delegate:nil];
                coverTask.messageTaskType = FileUploadMessageTaskTypeCover;
                [taskArray addObject:coverTask];
                
                //视频
                NoaFileUploadTask *videoTask = [[NoaFileUploadTask alloc] initWithTaskId:videoName filePath:videoPath originFilePath:@"" fileName:videoName fileType:@"" isEncrypt:YES dataLength:videoData.length uploadType:ZHttpUploadTypeVideo beSendMessage:nil delegate:nil];
                videoTask.messageTaskType = FileUploadMessageTaskTypeVideo;
                [taskArray addObject:videoTask];
                
                __block NSInteger taskNum = 0;
                NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                    for (NoaFileUploadTask *task in taskArray) {
                        if (task.status == FileUploadTaskStatus_Completed) {
                            if (task.messageTaskType == FileUploadMessageTaskTypeCover) {
                                [weakSelf.bodyDict setValue:task.originUrl forKey:@"cImg"];//封面地址
                                taskNum++;
                            }
                            if (task.messageTaskType == FileUploadMessageTaskTypeVideo) {
                                [weakSelf.bodyDict setValue:task.originUrl forKey:@"name"];//视频地址
                                taskNum++;
                            }
                            if (taskNum == 2) {
                                //调用接口
                                [ZTOOL doInMain:^{
                                    [weakSelf groupHairCreateHairGroupWith:[weakSelf.bodyDict mj_JSONString]];
                                }];
                            }
                        } else {
                            [ZTOOL doInMain:^{
                                [HUD hideHUD];
                                [HUD showMessage:LanguageToolMatch(@"上传失败")];
                            }];
                        }
                    }
                }];
                NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
                [coverTask addDependency:getSTSTask];
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
                
                [[NoaFileUploadManager sharedInstance] addUploadTask:coverTask];
                [videoTask addDependency:coverTask];
                [[NoaFileUploadManager sharedInstance] addUploadTask:videoTask];
                [blockOperation addDependency:videoTask];
                
                [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
            }];
        }
    }];
}

#pragma mark - 上传文件
- (void)uploadFile {
    
    NoaFilePickModel *fileModel = (NoaFilePickModel *)_attachment;
    
    WeakSelf
    //中间目录
    NSString *customPath = [NSString stringWithFormat:@"%@-Temp", UserManager.userInfo.userUID];
    
    //发送的是手机里的文件
    if (fileModel.fileSource == ZMsgFileSourceTypePhone) {
        //文件内容
        NSData *fileData = _viewMessage.fileData;
        //文件大小
        NSInteger fileSize = _viewMessage.fileSize;
        //文件类型
        NSString *fileType = _viewMessage.fileType;
        //文件名称
        NSString *fileName = _viewMessage.fileName;
        
        if ([fileName hasSuffix:@".ipa1"] || [fileName hasSuffix:@".apk1"]) {
            fileName = [fileName substringToIndex: fileName.length - 1];
        }

        __block NSString *fileSaxboxPath = @"";
        [ZTOOL doAsync:^{
            [NSString saveFileToSaxboxWithData:fileData CustomPath:customPath fileName:fileName];
            fileSaxboxPath = [NSString getPathWithFileName:fileName CustomPath:customPath];
        } completion:^{
            //上传
            NSString *extensionFileName = fileName;
            if ([fileName hasSuffix:@".ipa"] || [fileName hasSuffix:@".apk"]) {
                extensionFileName = [fileName stringByAppendingString:@"1"];
            }
            NoaFileUploadTask *fileTask = [[NoaFileUploadTask alloc] initWithTaskId:extensionFileName filePath:fileSaxboxPath originFilePath:@"" fileName:extensionFileName fileType:fileType isEncrypt:YES dataLength:fileData.length uploadType:ZHttpUploadTypeFile beSendMessage:nil delegate:nil];
            
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                if (fileTask.status == FileUploadTaskStatus_Completed) {
                    weakSelf.bodyDict = [NSMutableDictionary dictionary];
                    [weakSelf.bodyDict setValue:fileTask.originUrl forKey:@"path"];//文件路径
                    [weakSelf.bodyDict setValue:fileType forKey:@"type"];//文件类型
                    [weakSelf.bodyDict setValue:@(fileSize) forKey:@"size"];//文件大小
                    [weakSelf.bodyDict setValue:extensionFileName forKey:@"name"];//文件名称
                    [weakSelf.bodyDict setValue:@"" forKey:@"ext"];//文件拓展
                    [ZTOOL doInMain:^{
                        [weakSelf groupHairCreateHairGroupWith:[weakSelf.bodyDict mj_JSONString]];
                    }];
                }
                if (fileTask.status == FileUploadTaskStatus_Failed) {
                    [ZTOOL doInMain:^{
                        [HUD showMessage:LanguageToolMatch(@"上传失败")];
                    }];
                }
            }];
            NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
            [fileTask addDependency:getSTSTask];
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
            
            [[NoaFileUploadManager sharedInstance] addUploadTask:fileTask];
            [blockOperation addDependency:fileTask];
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
        }];
    }
    
    //发送的是App中的文件
    if (fileModel.fileSource == ZMsgFileSourceTypeLingxin) {
        //将文件转换成data，并保存到指定会话的沙盒目录下
        NSData *fileData = [NSData dataWithContentsOfFile:fileModel.filePath options:NSDataReadingMappedIfSafe error:nil];
        
        //真实的文件名
        NSRange range = [fileModel.fileName rangeOfString:@"-"];
        NSString *rawFileName;
        if(range.length == 0){
            rawFileName = fileModel.fileName;
        }else{
            rawFileName = [fileModel.fileName safeSubstringWithRange:NSMakeRange(range.location+1, fileModel.fileName.length - (range.location+1))];
        }

        NSString *saxboxFileName = [NSString stringWithFormat:@"%@%lld-%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], rawFileName];
        

        //文件大小
        CGFloat fileSize = fileModel.fileSize;
        //文件类型
        NSString *fileType = fileModel.fileType;
        //文件名称
        NSString *fileName = saxboxFileName;
        
        __block NSString *fileSaxboxPath = @"";
        [ZTOOL doAsync:^{
            [NSString saveFileToSaxboxWithData:fileData CustomPath:customPath fileName:saxboxFileName];
            fileSaxboxPath = [NSString getPathWithFileName:saxboxFileName CustomPath:customPath];
        } completion:^{
            //上传
            NSString *extensionFileName = fileName;
            if ([fileName hasSuffix:@".ipa"] || [fileName hasSuffix:@".apk"]) {
                extensionFileName = [fileName stringByAppendingString:@"1"];
            }
            NoaFileUploadTask *fileTask = [[NoaFileUploadTask alloc] initWithTaskId:extensionFileName filePath:fileSaxboxPath originFilePath:@"" fileName:extensionFileName fileType:fileType isEncrypt:YES dataLength:fileData.length uploadType:ZHttpUploadTypeFile beSendMessage:nil delegate:nil];
            
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                if (fileTask.status == FileUploadTaskStatus_Completed) {
                    weakSelf.bodyDict = [NSMutableDictionary dictionary];
                    [weakSelf.bodyDict setValue:fileTask.originUrl forKey:@"path"];//文件路径
                    [weakSelf.bodyDict setValue:fileType forKey:@"type"];//文件类型
                    [weakSelf.bodyDict setValue:@(fileSize) forKey:@"size"];//文件大小
                    [weakSelf.bodyDict setValue:extensionFileName forKey:@"name"];//文件名称
                    [weakSelf.bodyDict setValue:@"" forKey:@"ext"];//文件拓展
                    [ZTOOL doInMain:^{
                        [weakSelf groupHairCreateHairGroupWith:[weakSelf.bodyDict mj_JSONString]];
                    }];
                }
                if (fileTask.status == FileUploadTaskStatus_Failed) {
                    [ZTOOL doInMain:^{
                        [HUD showMessage:LanguageToolMatch(@"上传失败")];
                    }];
                }
            }];
            NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
            [fileTask addDependency:getSTSTask];
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
            
            [[NoaFileUploadManager sharedInstance] addUploadTask:fileTask];
            [blockOperation addDependency:fileTask];
            [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
        }];
    }
    
    //发送的是相册的视频文件
    if (fileModel.fileSource == ZMsgFileSourceTypeAlbumVideo) {
        WeakSelf
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestAVAssetForVideo:fileModel.videoAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                NSNumber *size;
                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                //视频data
                NSData *fileVideoData = [NSData dataWithContentsOfURL:urlAsset.URL options:NSDataReadingMappedIfSafe error:nil];
                //视频名称原始名称
                //视频文件文件名
                NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:fileModel.videoAsset];
                PHAssetResource *resource = nil;
                for (PHAssetResource *res in resources) {
                    if ([res.assetLocalIdentifier isEqualToString:fileModel.videoAsset.localIdentifier]) {
                        resource = res;
                        break;
                    }
                }
                //名称
                NSString *fileName = resource.originalFilename;
                //视频大小
                CGFloat fileSize = [size floatValue];

                __block NSString *fileSaxboxPath = @"";
                __block NSString *fileType = @"";
                [ZTOOL doAsync:^{
                    //文件沙盒路径
                    [NSString saveFileToSaxboxWithData:fileVideoData CustomPath:customPath fileName:fileName];
                    fileSaxboxPath = [NSString getPathWithFileName:fileName CustomPath:customPath];
                    //文件类型
                    fileType = [NSString fileTranslateToFileType:fileSaxboxPath];
                } completion:^{
                    //上传
                    NoaFileUploadTask *fileTask = [[NoaFileUploadTask alloc] initWithTaskId:fileName filePath:fileSaxboxPath originFilePath:@"" fileName:fileName fileType:fileType isEncrypt:YES dataLength:fileVideoData.length uploadType:ZHttpUploadTypeFile beSendMessage:nil delegate:nil];
                    
                    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                        if (fileTask.status == FileUploadTaskStatus_Completed) {
                            weakSelf.bodyDict = [NSMutableDictionary dictionary];
                            [weakSelf.bodyDict setValue:fileTask.originUrl forKey:@"path"];//文件路径
                            [weakSelf.bodyDict setValue:fileType forKey:@"type"];//文件类型
                            [weakSelf.bodyDict setValue:@(fileSize) forKey:@"size"];//文件大小
                            [weakSelf.bodyDict setValue:fileName forKey:@"name"];//文件名称
                            [weakSelf.bodyDict setValue:@"" forKey:@"ext"];//文件拓展
                            [ZTOOL doInMain:^{
                                [weakSelf groupHairCreateHairGroupWith:[weakSelf.bodyDict mj_JSONString]];
                            }];
                        }
                        if (fileTask.status == FileUploadTaskStatus_Failed) {
                            [HUD showMessage:LanguageToolMatch(@"上传失败")];
                        }
                    }];
                    NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
                    [fileTask addDependency:getSTSTask];
                    [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
                    
                    [[NoaFileUploadManager sharedInstance] addUploadTask:fileTask];
                    [blockOperation addDependency:fileTask];
                    [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
                }];
            }
        }];
    }
}

#pragma mark - Lazy
//- (ZFileNetProgressManager *)fileUploader {
//    if (!_fileUploader) {
//        _fileUploader = [[ZFileNetProgressManager alloc] init];
//    }
//    return _fileUploader;
//}

@end
