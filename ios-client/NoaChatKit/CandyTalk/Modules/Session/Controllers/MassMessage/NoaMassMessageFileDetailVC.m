//
//  NoaMassMessageFileDetailVC.m
//  NoaKit
//
//  Created by Candy on 2023/4/21.
//

#import "NoaMassMessageFileDetailVC.h"
#import "NoaProgressButton.h"
#import "NoaFileDownloadManager.h"
//#import "ZFileNetProgressManager.h"

@interface NoaMassMessageFileDetailVC () <ZFileDownloadTaskDelegate>

@property (nonatomic, strong)UIImageView *fileTypeImgView;
@property (nonatomic, strong)UILabel *fileTypeLbl;
@property (nonatomic, strong)UILabel *fileNameLbl;
@property (nonatomic, strong)UILabel *fileSizeLbl;
@property (nonatomic, strong)UILabel *fileProgressLbl;
@property (nonatomic, strong)UILabel *fileUnknowTipLbl;
@property (nonatomic, strong)NoaProgressButton *fileHandleBtn;
//@property (nonatomic, strong)ZFileNetProgressManager * fileDownloadManager;//下载类
@property (nonatomic, assign)float testProgress;

@end

@implementation NoaMassMessageFileDetailVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitleStr = self.messageModel.bodyModel.name;
    
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_EEEEEE_DARK];
//    self.fileDownloadManager = [[ZFileNetProgressManager alloc] init];
    [self setupUI];
    [self updateUIWithModel];
    
    NSString *foldPath = [NSString getFileDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-Temp",UserManager.userInfo.userUID]];
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", foldPath, self.messageModel.bodyModel.name];
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    
    if (existed) {
        self.fileProgressLbl.hidden = YES;
        self.fileHandleBtn.stopTitle = LanguageToolMatch(@"用其他应用打开");
    } else {
        self.fileProgressLbl.hidden = NO;
        [self.fileHandleBtn setTitle:LanguageToolMatch(@"下载") forState:UIControlStateNormal];
    }
    
    _testProgress = 0;
}

- (void)setupUI {
    [self.view addSubview:self.fileTypeImgView];
    [self.fileTypeImgView addSubview:self.fileTypeLbl];
    [self.view addSubview:self.fileNameLbl];
    [self.view addSubview:self.fileSizeLbl];
    [self.view addSubview:self.fileProgressLbl];
    [self.view addSubview:self.fileUnknowTipLbl];
    [self.view addSubview:self.fileHandleBtn];
    
    [self.fileTypeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(78));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(DWScale(73), DWScale(91)));
    }];
    
    [self.fileTypeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.fileTypeImgView.mas_bottom).offset(DWScale(-10));
        make.leading.equalTo(self.fileTypeImgView).offset(5);
        make.trailing.equalTo(self.fileTypeImgView).offset(-5);
        make.height.mas_equalTo(DWScale(22));
    }];
    
    [self.fileNameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileTypeImgView.mas_bottom).offset(DWScale(30));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(DWScale(210), DWScale(24)));
    }];
    
    [self.fileSizeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileNameLbl.mas_bottom).offset(DWScale(5));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(DWScale(210), DWScale(20)));
    }];
    
    [self.fileProgressLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileSizeLbl.mas_bottom).offset(DWScale(5));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(DWScale(210), DWScale(20)));
    }];
    
    [self.fileUnknowTipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileProgressLbl.mas_bottom).offset(DWScale(15));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(DWScale(210), DWScale(40)));
    }];
    
    [self.fileHandleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileUnknowTipLbl.mas_bottom).offset(DWScale(165));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(DWScale(220), DWScale(48)));
    }];
}
#pragma mark - 界面赋值
- (void)updateUIWithModel {
    //文件类型icon
    self.fileTypeImgView.image = [UIImage getFileMessageIconWithFileType:_messageModel.bodyModel.type fileName:_messageModel.bodyModel.name];
    self.fileTypeLbl.text = [NSString getFileTypeContentWithFileType:_messageModel.bodyModel.type fileName:_messageModel.bodyModel.name];
    
    //文件名称
    NSRange range = [_messageModel.bodyModel.name rangeOfString:@"-"];
    if (range.length == 0) {
        self.fileNameLbl.text = _messageModel.bodyModel.name;
    } else {
        self.fileNameLbl.text = [_messageModel.bodyModel.name safeSubstringWithRange:NSMakeRange(range.location+1, _messageModel.bodyModel.name.length - (range.location+1))];
    }
    //文件大小
    self.fileSizeLbl.text = [NSString stringWithFormat:LanguageToolMatch(@"文件大小：%@"),[NSString fileTranslateToSize:_messageModel.bodyModel.size]];
}

#pragma mark - Action
- (void)fileHandleClick {
    NSString *foldPath = [NSString getFileDiectoryWithCustomPath:[NSString stringWithFormat:@"%@-Temp",UserManager.userInfo.userUID]];
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", foldPath, self.messageModel.bodyModel.name];
    
    //判断本地文件存在不要加1
    if ([fileFullPath hasSuffix:@".ipa1"] || [fileFullPath hasSuffix:@".apk1"]) {
        fileFullPath = [fileFullPath substringToIndex:fileFullPath.length - 1];
    }
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    if (existed) {
        NSURL *fileUrl = [NSURL fileURLWithPath:fileFullPath];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileUrl] applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint];
        // 该控制器不能push，只能使用模态视图弹出
        [self presentViewController:activityVC animated:YES completion:nil];
    } else {
        self.fileProgressLbl.hidden = NO;
        NSString *fileUrl = [_messageModel.bodyModel.path getImageFullString];
   
        NoaFileDownloadTask *task = [[NoaFileDownloadTask alloc] initWithTaskId:fileUrl fileUrl:fileUrl saveName:[fileFullPath lastPathComponent] savePath:fileFullPath delegate:self];
        [[NoaFileDownloadManager sharedInstance] addDownloadTask:task];
    }
}

#pragma mark - ZFileDownloadTaskDelegate
//任务状态改变回调
-(void)fileDownloadTask:(NoaFileDownloadTask *)task didChangTaskStatus:(FileDownloadTaskStatus)status error:(NSError *)error {
    if (task.status == FileDownloadTaskStatus_Completed) {
        self.fileHandleBtn.stopTitle = LanguageToolMatch(@"用其他应用打开");
        self.fileProgressLbl.hidden = YES;
    }
    if (task.status == FileDownloadTaskStatus_Failed) {
        self.fileProgressLbl.hidden = YES;
        [HUD showMessage:LanguageToolMatch(@"下载失败")];
    }
}

//任务上传进度回调
-(void)fileDownloadTask:(NoaFileDownloadTask *)task didChangTaskProgress:(float)progress {
    self.fileHandleBtn.progress = progress;
    self.fileProgressLbl.text = [NSString stringWithFormat:@"%@/%@", [NSString fileTranslateToSize:_messageModel.bodyModel.size * progress], [NSString fileTranslateToSize:_messageModel.bodyModel.size]];
}
    
#pragma mark - Lazy
- (UIImageView *)fileTypeImgView {
    if (!_fileTypeImgView) {
        _fileTypeImgView = [[UIImageView alloc] init];
    }
    return _fileTypeImgView;
}

- (UILabel *)fileTypeLbl {
    if (!_fileTypeLbl) {
        _fileTypeLbl = [[UILabel alloc] init];
        _fileTypeLbl.text = @"";
        _fileTypeLbl.tkThemetextColors = @[COLORWHITE, COLORWHITE];
        _fileTypeLbl.font = FONTN(22);
        _fileTypeLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _fileTypeLbl;
}

- (UILabel *)fileNameLbl {
    if (!_fileNameLbl) {
        _fileNameLbl = [[UILabel alloc] init];
        _fileNameLbl.text = @"文件名称";
        _fileNameLbl.tkThemetextColors = @[COLOR_11, COLORWHITE];
        _fileNameLbl.font = FONTN(16);
        _fileNameLbl.textAlignment = NSTextAlignmentCenter;
        _fileNameLbl.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _fileNameLbl;
}

- (UILabel *)fileSizeLbl {
    if (!_fileSizeLbl) {
        _fileSizeLbl = [[UILabel alloc] init];
        _fileSizeLbl.text = @"文件大小：";
        _fileSizeLbl.tkThemetextColors = @[COLOR_11, COLORWHITE];
        _fileSizeLbl.font = FONTN(14);
        _fileSizeLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _fileSizeLbl;
}

- (UILabel *)fileProgressLbl {
    if (!_fileProgressLbl) {
        _fileProgressLbl = [[UILabel alloc] init];
        _fileProgressLbl.text = @"0KB/0KB";
        _fileProgressLbl.hidden = YES;
        _fileProgressLbl.tkThemetextColors = @[COLOR_99, COLOR_99];
        _fileProgressLbl.font = FONTN(14);
        _fileProgressLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _fileProgressLbl;
}

- (UILabel *)fileUnknowTipLbl {
    if (!_fileUnknowTipLbl) {
        _fileUnknowTipLbl = [[UILabel alloc] init];
        _fileUnknowTipLbl.text = LanguageToolMatch(@"暂不支持打开此类型文件，你可以使用其他应用打开");
        _fileUnknowTipLbl.tkThemetextColors = @[COLOR_99, COLOR_99];
        _fileUnknowTipLbl.font = FONTN(14);
        _fileUnknowTipLbl.numberOfLines = 2;
        _fileUnknowTipLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _fileUnknowTipLbl;
}

- (NoaProgressButton *)fileHandleBtn {
    if (!_fileHandleBtn) {
        _fileHandleBtn = [NoaProgressButton crearProgressButtonWithFrame:CGRectMake(0, 0, DWScale(220), DWScale(48)) title:@"" lineWidth:DWScale(48) lineColor:COLOR_5966F2 textColor:COLORWHITE backColor:COLOR_5966F2 isRound:NO];
        _fileHandleBtn.titleLabel.font = FONTN(17);
        [_fileHandleBtn addTarget:self action:@selector(fileHandleClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fileHandleBtn;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
