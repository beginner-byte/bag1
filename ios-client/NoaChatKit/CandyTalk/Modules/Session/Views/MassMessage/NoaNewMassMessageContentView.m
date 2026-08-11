//
//  NoaNewMassMessageContentView.m
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaNewMassMessageContentView.h"
#import "NoaToolManager.h"
#import "NoaImagePickerVC.h"              //相册
#import "NoaFilePickerVC.h"               //文件

@interface NoaNewMassMessageContentView () <ZImagePickerVCDelegate>
@end

@implementation NoaNewMassMessageContentView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    UIView *viewLineV = [UIView new];
    viewLineV.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    [self addSubview:viewLineV];
    [viewLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(DWScale(12));
        make.size.mas_equalTo(CGSizeMake(0.5, DWScale(15)));
    }];
    
    UIView *viewLineH = [UIView new];
    viewLineH.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_CCCCCC_DARK];
    [self addSubview:viewLineH];
    [viewLineH mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(DWScale(39));
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    _btnText = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnText setTitle:LanguageToolMatch(@"文本") forState:UIControlStateNormal];
    [_btnText setTkThemeTitleColor:@[COLOR_99, COLOR_99_DARK] forState:UIControlStateNormal];
    [_btnText setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateSelected];
    _btnText.titleLabel.font = FONTR(12);
    _btnText.tag = 200;
    [_btnText addTarget:self action:@selector(btnSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    _btnText.selected = YES;//默认选择文本
    _btnSelected = _btnText;
    [self addSubview:_btnText];
    [_btnText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self);
        make.trailing.equalTo(viewLineV.mas_leading);
        make.bottom.equalTo(viewLineH.mas_top);
    }];
    
    _btnAttachment = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnAttachment setTitle:LanguageToolMatch(@"附件") forState:UIControlStateNormal];
    [_btnAttachment setTkThemeTitleColor:@[COLOR_99, COLOR_99_DARK] forState:UIControlStateNormal];
    [_btnAttachment setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateSelected];
    _btnAttachment.titleLabel.font = FONTR(12);
    _btnAttachment.tag = 201;
    [_btnAttachment addTarget:self action:@selector(btnSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnAttachment];
    [_btnAttachment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.equalTo(self);
        make.leading.equalTo(viewLineV.mas_trailing);
        make.bottom.equalTo(viewLineH.mas_top);
    }];
    
    _viewMessage = [UIView new];
    _viewMessage.hidden = NO;
    [self addSubview:_viewMessage];
    [_viewMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewLineH.mas_bottom);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    _lblMessageTip = [UILabel new];
    _lblMessageTip.text = LanguageToolMatch(@"粘贴或输入需要发送的内容");
    _lblMessageTip.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblMessageTip.font = FONTR(12);
    [_viewMessage addSubview:_lblMessageTip];
    [_lblMessageTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewMessage).offset(DWScale(16));
        make.leading.equalTo(_viewMessage).offset(DWScale(20));
        make.trailing.equalTo(_viewMessage.mas_trailing).offset(DWScale(-20));
    }];
    _lblMessageTip.numberOfLines = 2;
    
    _tvMessage = [UITextView new];
    _tvMessage.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR_DARK];
    _tvMessage.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _tvMessage.font = FONTR(12);
    [_viewMessage addSubview:_tvMessage];
    [_tvMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewMessage).offset(DWScale(16));
        make.leading.equalTo(_viewMessage).offset(DWScale(16));
        make.trailing.equalTo(_viewMessage).offset(-DWScale(16));
        make.bottom.equalTo(_viewMessage).offset(-DWScale(19));
    }];
    
    _viewAttachment = [UIView new];
    _viewAttachment.hidden = YES;
    [self addSubview:_viewAttachment];
    [_viewAttachment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewLineH.mas_bottom);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    _btnSelectAttachment = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSelectAttachment setImage:ImgNamed(@"c_square_add") forState:UIControlStateNormal];
    [_btnSelectAttachment setTitle:LanguageToolMatch(@"选择需要发送的图片、视频、文件") forState:UIControlStateNormal];
    _btnSelectAttachment.titleLabel.font = FONTR(12);
    [_btnSelectAttachment setTkThemeTitleColor:@[COLOR_99, COLOR_99_DARK] forState:UIControlStateNormal];
    [_btnSelectAttachment setBtnImageAlignmentType:ButtonImageAlignmentTypeLeft imageSpace:DWScale(7)];
    [_btnSelectAttachment addTarget:self action:@selector(btnSelectAttachmentClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewAttachment addSubview:_btnSelectAttachment];
    [_btnSelectAttachment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewAttachment).offset(DWScale(16));
        make.top.equalTo(_viewAttachment).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(240), DWScale(44)));
    }];
    
    _ivAttachment = [UIImageView new];
    _ivAttachment.layer.cornerRadius = DWScale(8);
    _ivAttachment.layer.masksToBounds = YES;
    _ivAttachment.hidden = YES;
    [_viewAttachment addSubview:_ivAttachment];
    [_ivAttachment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewAttachment).offset(DWScale(16));
        make.top.equalTo(_viewAttachment).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(88), DWScale(88)));
    }];
    
    _ivPlay = [[UIImageView alloc] initWithImage:ImgNamed(@"icon_video_msg_play")];
    _ivPlay.hidden = YES;
    [_viewAttachment addSubview:_ivPlay];
    [_ivPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_ivAttachment);
        make.size.mas_equalTo(CGSizeMake(DWScale(26), DWScale(26)));
    }];
    
    _btnReselect = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnReselect.layer.cornerRadius = DWScale(12);
    _btnReselect.layer.masksToBounds = YES;
    _btnReselect.layer.tkThemeborderColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    _btnReselect.layer.borderWidth = 1;
    [_btnReselect setTitle:LanguageToolMatch(@"重新选择") forState:UIControlStateNormal];
    _btnReselect.titleLabel.font = FONTR(12);
    [_btnReselect setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
    _btnReselect.hidden = YES;
    [_btnReselect addTarget:self action:@selector(btnSelectAttachmentClick) forControlEvents:UIControlEventTouchUpInside];
    [_viewAttachment addSubview:_btnReselect];
    [_btnReselect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_ivAttachment);
        make.top.equalTo(_ivAttachment.mas_bottom).offset(DWScale(10));
        make.size.mas_equalTo(CGSizeMake(DWScale(60), DWScale(24)));
    }];
    
    _lblFileType = [UILabel new];
    _lblFileType.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblFileType.font = FONTR(22);
    _lblFileType.hidden = YES;
    _lblFileType.textAlignment = NSTextAlignmentCenter;
    [_viewAttachment addSubview:_lblFileType];
    [_lblFileType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_ivAttachment);
        make.bottom.equalTo(_ivAttachment).offset(-DWScale(7));
    }];
    
    _lblFileName = [UILabel new];
    _lblFileName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblFileName.font = FONTR(12);
    _lblFileName.hidden = YES;
    [_viewAttachment addSubview:_lblFileName];
    [_lblFileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_ivAttachment.mas_trailing).offset(DWScale(10));
        make.top.equalTo(_ivAttachment);
        make.trailing.equalTo(_viewAttachment).offset(-DWScale(10));
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _lblFileSize = [UILabel new];
    _lblFileSize.font = FONTR(12);
    _lblFileSize.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblFileSize.hidden = YES;
    [_viewAttachment addSubview:_lblFileSize];
    [_lblFileSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_lblFileName);
        make.bottom.equalTo(_ivAttachment);
    }];
    
    //监听文本变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewContentChanged) name:UITextViewTextDidChangeNotification object:_tvMessage];
}

#pragma mark - 交互事件
- (void)btnSelectClick:(UIButton *)sender {
    NSInteger senderTag = sender.tag;
    NSInteger selectedTag = _btnSelected.tag;
    if (senderTag != selectedTag) {
        //点击不同的按钮
        _btnSelected.selected = NO;
        sender.selected = YES;
        _btnSelected = sender;
        if (senderTag == 200) {
            _viewMessage.hidden = NO;
            _viewAttachment.hidden = YES;
        }else {
            _viewMessage.hidden = YES;
            _viewAttachment.hidden = NO;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(newMassMessageSelect:)]) {
            [_delegate newMassMessageSelect:_btnSelected.tag - 200];
        }
    }
}
- (void)btnSelectAttachmentClick {
    [self showAttachmentTypeView];
}

- (void)showAttachmentTypeView {
    WeakSelf
    NoaPresentItem *imageItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"图片/视频") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(56) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            imageItem.textColor = COLOR_11;
            imageItem.backgroundColor = COLORWHITE;
        }else {
            imageItem.textColor = COLORWHITE;
            imageItem.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentItem *fileItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"文件") textColor:COLOR_11 font:FONTR(17) itemHeight:DWScale(56) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            fileItem.textColor = COLOR_11;
            fileItem.backgroundColor = COLORWHITE;
        }else {
            fileItem.textColor = COLORWHITE;
            fileItem.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentItem *cancelItem = [NoaPresentItem creatPresentViewItemWithText:LanguageToolMatch(@"取消") textColor:COLOR_99 font:FONTR(17) itemHeight:DWScale(52) backgroundColor:COLORWHITE];
    self.tkThemeChangeBlock = ^(id  _Nullable itself, NSUInteger themeIndex) {
        if (themeIndex == 0) {
            cancelItem.textColor = COLOR_B3B3B3;
            cancelItem.backgroundColor = COLORWHITE;
        }else {
            cancelItem.textColor = COLOR_99;
            cancelItem.backgroundColor = COLOR_11;
        }
    };
    
    NoaPresentView *viewAlert;
    if ([UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"] && [UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"false"]) {
        viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[imageItem] cancleItem:cancelItem doneClick:^(NSInteger index) {
            if (index == 0) {
                //图片/视频
                [weakSelf selectPhotoLibrary];
            }
        } cancleClick:^{
        }];
        [CurrentWindow addSubview:viewAlert];
        [viewAlert showPresentView];
    } else if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"true"] && [UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"false"]) {
        viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[fileItem] cancleItem:cancelItem doneClick:^(NSInteger index) {
            if (index == 0) {
                //文件
                [weakSelf selectFileLibrary];
            }
        } cancleClick:^{
        }];
        [CurrentWindow addSubview:viewAlert];
        [viewAlert showPresentView];
    } else if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"true"] && [UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"true"]) {
        viewAlert = [[NoaPresentView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DScreenHeight) titleItem:nil selectItems:@[imageItem, fileItem] cancleItem:cancelItem doneClick:^(NSInteger index) {
            if (index == 0) {
                //图片/视频
                [weakSelf selectPhotoLibrary];
            }else {
                //文件
                [weakSelf selectFileLibrary];
            }
        } cancleClick:^{
        }];
        [CurrentWindow addSubview:viewAlert];
        [viewAlert showPresentView];
    } else if ([UserManager.userRoleAuthInfo.upFile.configValue isEqualToString:@"false"] && [UserManager.userRoleAuthInfo.upImageVideoFile.configValue isEqualToString:@"false"]) {
        [HUD showMessage:LanguageToolMatch(@"无操作权限")];
        return;
    }
}
    
//选择图片/视频
- (void)selectPhotoLibrary {
    //先检测权限，再进入相册，解决某些系统第一次不能获取照片，杀死进程后可以获取照片的问题
    [ZTOOL getPhotoLibraryAuth:^(BOOL granted) {
        if (granted) {
            [ZTOOL doInMain:^{
                
                [IMAGEPICKER.zSelectedAssets removeAllObjects];
                
                NoaImagePickerVC *vc = [NoaImagePickerVC new];
                vc.maxSelectNum = 1;
                vc.isNeedEdit = NO;
                vc.hasCamera = YES;
                vc.delegate = self;
                [vc setPickerType:ZImagePickerTypeAll];
                [CurrentVC.navigationController pushViewController:vc animated:YES];
            }];
        }else {
            [HUD showWarningMessage:LanguageToolMatch(@"相册权限未开启，请在设置中选择当前应用，开启相册权限")];
        }
    }];
}
//选择文件
- (void)selectFileLibrary {
    //先检测权限，再进入，解决某些系统第一次不能获取相册，杀死进程后可以获取相册的问题
    WeakSelf
    [ZTOOL getPhotoLibraryAuth:^(BOOL granted) {
        if (granted) {
            [ZTOOL doInMain:^{
                NoaFilePickerVC *vc = [NoaFilePickerVC new];
                [CurrentVC.navigationController pushViewController:vc animated:YES];
                
                //直接选择 手机储存的文件
                vc.savePhoneFileSuccess = ^(NoaFilePickModel *selectFileModel) {
                    //手机储存中的文件
                    [weakSelf showSelectedFile:selectFileModel];
                };
                
                //选择的 App中的文件或者相册视频 数组里可以是 PHAsset或者本地文件沙盒路径
                vc.saveLingXinFileSuccess = ^(NSArray * _Nonnull sendSelectFileArr) {
                    //App中的文件或者相册视频
                    NoaFilePickModel *selectFileModel = sendSelectFileArr.firstObject;
                    [weakSelf showSelectedFile:selectFileModel];
                };
            }];
        } else {
            [HUD showWarningMessage:LanguageToolMatch(@"相册权限未开启，请在设置中选择当前应用，开启相册权限")];
        }
    }];
}

#pragma mark - 图片选择 - ZImagePickerVCDelegate
- (void)imagePickerVCSelected {
    
    WeakSelf
    NSMutableArray *selectAssetArray = [IMAGEPICKER.zSelectedAssets mutableCopy];
    
    if (selectAssetArray.count > 0) {
        _btnSelectAttachment.hidden = YES;
        _ivAttachment.hidden = NO;
        _btnReselect.hidden = NO;
        _lblFileType.hidden = YES;
        _lblFileName.hidden = YES;
        _lblFileSize.hidden = YES;
        [_ivAttachment mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewAttachment).offset(DWScale(16));
            make.top.equalTo(_viewAttachment).offset(DWScale(16));
            make.size.mas_equalTo(CGSizeMake(DWScale(88), DWScale(88)));
        }];
        
        PHAsset *mediaAsset = selectAssetArray.firstObject;
        
        if (mediaAsset.mediaType == PHAssetMediaTypeImage) {
            //图片
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.synchronous = YES;//同步，如果有卡顿的情况，可设置为NO异步
            [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:mediaAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                
                if ([[[NSString getImageFileFormat:imageData] lowercaseString] isEqualToString:@"gif"]) {
                    //GIF图片
                    UIImage *gifImage = [UIImage sd_imageWithGIFData:imageData];
                    [weakSelf.ivAttachment sd_setImageWithURL:nil placeholderImage:gifImage options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
                } else {
                    //静态图片
                    [weakSelf.ivAttachment setImage:[UIImage imageWithData:imageData]];
                }
                weakSelf.ivPlay.hidden = YES;
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(newMassMessageAttachmentType:attachment:)]) {
                    [weakSelf.delegate newMassMessageAttachmentType:1 attachment:mediaAsset];
                }
            }];
        } else if (mediaAsset.mediaType == PHAssetMediaTypeVideo) {
            //视频
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            [[PHImageManager defaultManager] requestAVAssetForVideo:mediaAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset *urlAsset = (AVURLAsset*)asset;
                    NSNumber *size;
                    [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                    //视频data
                    NSData *videoData = [NSData dataWithContentsOfURL:urlAsset.URL options:NSDataReadingMappedIfSafe error:nil];
                    if (videoData.length > (200 * 1024 * 1024)) {
                        NoaFilePickModel *tempAssetModel = [[NoaFilePickModel alloc] init];
                        tempAssetModel.fileSource = ZMsgFileSourceTypeAlbumVideo;
                        tempAssetModel.videoAsset = mediaAsset;
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(newMassMessageAttachmentType:attachment:)]) {
                            [weakSelf.delegate newMassMessageAttachmentType:5 attachment:tempAssetModel];
                        }
                        [ZTOOL doInMain:^{
                            weakSelf.btnSelectAttachment.hidden = YES;
                            weakSelf.ivAttachment.hidden = NO;
                            weakSelf.btnReselect.hidden = NO;
                            weakSelf.ivPlay.hidden = YES;
                            weakSelf.lblFileType.hidden = NO;
                            weakSelf.lblFileName.hidden = NO;
                            weakSelf.lblFileSize.hidden = NO;
                            [weakSelf.ivAttachment mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.leading.equalTo(weakSelf.viewAttachment).offset(DWScale(16));
                                make.top.equalTo(weakSelf.viewAttachment).offset(DWScale(16));
                                make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(88)));
                            }];
                        }];
                        NSString *customPath = [NSString stringWithFormat:@"%@-Temp", UserManager.userInfo.userUID];
                        //以文件形式展示
                        //视频文件文件名
                        NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:mediaAsset];
                        PHAssetResource *resource = nil;
                        for (PHAssetResource *res in resources) {
                            if ([res.assetLocalIdentifier isEqualToString:mediaAsset.localIdentifier]) {
                                resource = res;
                                break;
                            }
                        }
                        NSString *videoName = resource.originalFilename;
                        //保存到沙盒
                        [NSString saveFileToSaxboxWithData:videoData CustomPath:customPath fileName:videoName];
                        //完整沙盒路径
                        NSString *saxboxFilePath = [NSString getPathWithFileName:videoName CustomPath:customPath];
                        //名称
                        NSString *fileName = videoName;
                        //视频大小
                        CGFloat fileSize = [size floatValue];
                        //文件类型
                        NSString *fileType = [NSString fileTranslateToFileType:saxboxFilePath];
                        //文件显示在UI上的名字
                        [ZTOOL doInMain:^{
                            NSRange range3 = [fileName rangeOfString:@"-"];
                            if (range3.length == 0) {
                                weakSelf.lblFileName.text = fileName;
                            } else {
                                weakSelf.lblFileName.text = [fileName safeSubstringWithRange:NSMakeRange(range3.location+1, fileName.length - (range3.location+1))];
                            }
                            
                            weakSelf.lblFileType.text = [NSString getFileTypeContentWithFileType:fileType fileName:fileName];
                            weakSelf.lblFileSize.text = [NSString stringWithFormat:@"%@ %@", [NSString getFileTypeContentWithFileType:fileType fileName:fileName], [NSString fileTranslateToSize:fileSize]];
                            weakSelf.ivAttachment.image = [UIImage getFileMessageIconWithFileType:fileType fileName:fileName];
                        }];
                    } else {
                        //视频封面
                        UIImage *coverImg =  [UIImage thumbnailImageForVideo:urlAsset.URL atTime:1];
                        [ZTOOL doInMain:^{
                            weakSelf.ivAttachment.image = coverImg;
                            weakSelf.ivPlay.hidden = NO;
                            
                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(newMassMessageAttachmentType:attachment:)]) {
                                [weakSelf.delegate newMassMessageAttachmentType:2 attachment:mediaAsset];
                            }
                        }];
                    }
                }
            }];
        }
        [IMAGEPICKER.zSelectedAssets removeAllObjects];
    }
}
#pragma mark - 文件选择
- (void)showSelectedFile:(NoaFilePickModel *)fileModel{
    
    if (_delegate && [_delegate respondsToSelector:@selector(newMassMessageAttachmentType:attachment:)]) {
        [_delegate newMassMessageAttachmentType:5 attachment:fileModel];
    }
    
    _btnSelectAttachment.hidden = YES;
    _ivPlay.hidden = YES;
    _ivAttachment.hidden = NO;
    _btnReselect.hidden = NO;
    _lblFileType.hidden = NO;
    _lblFileName.hidden = NO;
    _lblFileSize.hidden = NO;
    [_ivAttachment mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewAttachment).offset(DWScale(16));
        make.top.equalTo(_viewAttachment).offset(DWScale(16));
        make.size.mas_equalTo(CGSizeMake(DWScale(70), DWScale(88)));
    }];
    
    //中间目录
    NSString *customPath = [NSString stringWithFormat:@"%@-Temp", UserManager.userInfo.userUID];
    
    //发送的是手机里的文件
    if (fileModel.fileSource == ZMsgFileSourceTypePhone) {
        
        NSError *error;
        NSString *encodingNewURL = [fileModel.phoneFileUrl.absoluteString stringByRemovingPercentEncoding];
        NSArray  *encodingNewURLArr = [encodingNewURL componentsSeparatedByString:@"/"];
        NSString *rawFileName = [NSString stringWithFormat:@"%@",encodingNewURLArr.lastObject];
        
        //将文件转换成data，并保存到指定会话的沙盒目录下
        NSData *fileData = [NSData dataWithContentsOfURL:fileModel.phoneFileUrl options:NSDataReadingMappedIfSafe error:&error];
        
        NSString *saxboxFileName = [NSString stringWithFormat:@"%@%lld-%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], rawFileName];
        //保存到沙盒
        [NSString saveFileToSaxboxWithData:fileData CustomPath:customPath fileName:saxboxFileName];
        //完整沙盒路径
        NSString *fileSaxboxPath = [NSString getPathWithFileName:saxboxFileName CustomPath:customPath];
        //文件大小
        CGFloat fileSize = fileData.length;
        //文件类型
        NSString *fileType = [NSString fileTranslateToFileType:fileSaxboxPath];
        //文件名称
        NSString *fileName = saxboxFileName;
        
        //文件显示在UI上的名字
        NSRange range1 = [fileName rangeOfString:@"-"];
        if (range1.length == 0) {
            _lblFileName.text = fileName;
        } else {
            _lblFileName.text = [fileName safeSubstringWithRange:NSMakeRange(range1.location+1, fileName.length - (range1.location+1))];
        }
        _lblFileType.text = [NSString getFileTypeContentWithFileType:fileType fileName:fileName];
        _lblFileSize.text = [NSString stringWithFormat:@"%@ %@", [NSString getFileTypeContentWithFileType:fileType fileName:fileName], [NSString fileTranslateToSize:fileSize]];
        _ivAttachment.image = [UIImage getFileMessageIconWithFileType:fileType fileName:fileName];
        
        _fileData = fileData;
        _fileSaxboxPath = fileSaxboxPath;
        _fileName = fileName;
        _fileType = fileType;
        _fileSize = fileSize;
        
    }
    
    //发送的是App中的文件
    if (fileModel.fileSource == ZMsgFileSourceTypeLingxin) {
        
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
        //文件显示在UI上的名字
        NSRange range2 = [fileName rangeOfString:@"-"];
        if (range2.length == 0) {
            _lblFileName.text = fileName;
        } else {
            _lblFileName.text = [fileName safeSubstringWithRange:NSMakeRange(range2.location+1, fileName.length - (range2.location+1))];
        }
        
        _lblFileType.text = [NSString getFileTypeContentWithFileType:fileType fileName:fileName];
        _lblFileSize.text = [NSString stringWithFormat:@"%@ %@", [NSString getFileTypeContentWithFileType:fileType fileName:fileName], [NSString fileTranslateToSize:fileSize]];
        _ivAttachment.image = [UIImage getFileMessageIconWithFileType:fileType fileName:fileName];
        
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
                NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:fileModel.videoAsset];
                PHAssetResource *resource = nil;
                for (PHAssetResource *res in resources) {
                    if ([res.assetLocalIdentifier isEqualToString:fileModel.videoAsset.localIdentifier]) {
                        resource = res;
                        break;
                    }
                }
                NSString *videoName = resource.originalFilename;
                //保存到沙盒
                [NSString saveFileToSaxboxWithData:fileVideoData CustomPath:customPath fileName:videoName];
                //完整沙盒路径
                NSString *saxboxFilePath = [NSString getPathWithFileName:videoName CustomPath:customPath];
                //名称
                NSString *fileName = videoName;
                //视频大小
                CGFloat fileSize = [size floatValue];
                //文件类型
                NSString *fileType = [NSString fileTranslateToFileType:saxboxFilePath];
                
                //文件显示在UI上的名字
                [ZTOOL doInMain:^{
                    
                    NSRange range3 = [fileName rangeOfString:@"-"];
                    if (range3.length == 0) {
                        weakSelf.lblFileName.text = fileName;
                    } else {
                        weakSelf.lblFileName.text = [fileName safeSubstringWithRange:NSMakeRange(range3.location+1, fileName.length - (range3.location+1))];
                    }
                    
                    weakSelf.lblFileType.text = [NSString getFileTypeContentWithFileType:fileType fileName:fileName];
                    weakSelf.lblFileSize.text = [NSString stringWithFormat:@"%@ %@", [NSString getFileTypeContentWithFileType:fileType fileName:fileName], [NSString fileTranslateToSize:fileSize]];
                    weakSelf.ivAttachment.image = [UIImage getFileMessageIconWithFileType:fileType fileName:fileName];
                    
                }];
                
            }
        }];
    }
    
}
#pragma mark - 内容变化监听
- (void)textViewContentChanged {
    if (_tvMessage.text.length || _tvMessage.attributedText.length) {
        _lblMessageTip.hidden = YES;
    }else {
        _lblMessageTip.hidden = NO;
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
