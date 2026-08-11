//
//  NoaGropuSetBasicInfoVC.m
//  NoaKit
//
//  Created by Candy on 2026/11/7.
//

#import "NoaGroupSetBasicInfoVC.h"
#import "NoaGroupSetBasicInfoCell.h"
#import "NoaGroupModifyNameVC.h"
#import "NoaFileUploadModel.h"
#import "NoaImagePickerVC.h"
#import "NoaFileUploadModel.h"
#import "NoaToolManager.h"
#import "NoaFileUploadManager.h"
//#import "ZFileNetProgressManager.h"

@interface NoaGroupSetBasicInfoVC () <UITableViewDataSource, UITableViewDelegate, ZImagePickerVCDelegate,ZBaseCellDelegate>

//@property (nonatomic, strong)ZFileNetProgressManager *fileUploader;

@end

@implementation NoaGroupSetBasicInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navTitleStr = LanguageToolMatch(@"群信息");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    
    [self setupUI];
}

#pragma mark - 界面布局
- (void)setupUI {
    [self defaultTableViewUI];
    self.baseTableView.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView registerClass:[NoaGroupSetBasicInfoCell class] forCellReuseIdentifier:[NoaGroupSetBasicInfoCell cellIdentifier]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //群资料
    NoaGroupSetBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaGroupSetBasicInfoCell cellIdentifier] forIndexPath:indexPath];
    cell.baseCellIndexPath = indexPath;
    cell.baseDelegate = self;
    if (indexPath.section == 0) {
        [cell cellConfigWithTitle:LanguageToolMatch(@"群头像") model:self.groupInfoModel];
    } else {
        [cell cellConfigWithTitle:LanguageToolMatch(@"群名称") model:self.groupInfoModel];
    }
    
    return cell;
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            //群头像
            //先检测权限，再进入相册，解决某些系统第一次不能获取照片，杀死进程后可以获取照片的问题
            WeakSelf
            [ZTOOL getPhotoLibraryAuth:^(BOOL granted) {
                if (granted) {
                    [ZTOOL doInMain:^{
                        NoaImagePickerVC *vc = [NoaImagePickerVC new];
                        vc.isSignlePhoto = YES;
                        vc.isNeedEdit = YES;
                        vc.hasCamera = YES;
                        vc.delegate = self;
                        [vc setPickerType:ZImagePickerTypeImage];
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    }];
                }else {
                    [HUD showWarningMessage:LanguageToolMatch(@"相册权限未开启，请在设置中选择当前应用，开启相册权限")];
                }
            }];
        }
            break;
        case 1:
        {
            //群名称
            NoaGroupModifyNameVC * vc = [NoaGroupModifyNameVC new];
            vc.groupInfoModel = self.groupInfoModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaGroupSetBasicInfoCell defaultCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DScreenWidth, DWScale(16))];
    viewHeader.backgroundColor = UIColor.clearColor;
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DWScale(16);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)reloadCurData{
    [self.baseTableView reloadData];
}

#pragma mark - 上传群头像
- (void)imagePickerClipImage:(UIImage *)resultImg localIdenti:(NSString *)localIdenti {
    [HUD showActivityMessage:@""];
    NSData *imageData = UIImageJPEGRepresentation(resultImg, 1.0);//转成jpeg
    //对选择的图片进行压缩：200x200，大小在50KB以下
    UIImage *comSizeImage = [UIImage imageWithImage:[UIImage imageWithData:imageData] scaledToSize:CGSizeMake(200, 200)];
    NSData *comMassImageData = [UIImage compressImageSize:comSizeImage toByte:50*1024];
    //fileName 文件名为：userid+当前时间戳
    NSString *imageName = [[NSString alloc] initWithFormat:@"%@_%lld.%@", UserManager.userInfo.userUID, [NSDate currentTimeIntervalWithMillisecond], [NSString getImageFileFormat:comMassImageData]];
    //将图片放入沙盒目录下
    NSString *customPath = [NSString stringWithFormat:@"%@-%@", UserManager.userInfo.userUID, self.groupInfoModel.groupId];
    __block NSString *imagePath = @"";
    [ZTOOL doAsync:^{
        [NSString saveImageToSaxboxWithData:comMassImageData CustomPath:customPath ImgName:imageName];
        imagePath = [NSString getPathWithImageName:imageName CustomPath:customPath];
    } completion:^{
        //上传群头像图片
        WeakSelf
        NoaFileUploadTask *task = [[NoaFileUploadTask alloc] initWithTaskId:imageName filePath:imagePath originFilePath:@"" fileName:imageName fileType:@"" isEncrypt:YES dataLength:comMassImageData.length uploadType:ZHttpUploadTypeGroupAvatar beSendMessage:nil delegate:nil];
        NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            if (task.status == FileUploadTaskStatus_Completed) {
                [weakSelf requestUpdateGroupAvatarWithUrl:task.originUrl];
            }
            if (task.status == FileUploadTaskStatus_Failed) {
                [ZTOOL doInMain:^{
                    [HUD hideHUD];
                    [HUD showMessage:LanguageToolMatch(@"上传图片失败")];
                }];
            }
        }];
        NoaFileUploadGetSTSTask *getSTSTask = [[NoaFileUploadGetSTSTask alloc] init];
        [task addDependency:getSTSTask];
        [[NoaFileUploadManager sharedInstance].operationQueue addOperation:getSTSTask];
        [blockOperation addDependency:task];
        [[NoaFileUploadManager sharedInstance] addUploadTask:task];
        [[NoaFileUploadManager sharedInstance].operationQueue addOperation:blockOperation];
    }];
}

- (void)requestUpdateGroupAvatarWithUrl:(NSString *)avatarUrl {
    //调用更新头像图片资源id的接口
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.groupInfoModel.groupId forKey:@"groupId"];
    [dict setValue:avatarUrl forKey:@"avatar"];
    if (![NSString isNil:UserManager.userInfo.userUID]) {
        [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
    }
    WeakSelf
    [IMSDKManager changeGroupAvatarWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessage:LanguageToolMatch(@"操作成功")];
        weakSelf.groupInfoModel.groupAvatar = [NSString stringWithFormat:@"%@",avatarUrl];
        [weakSelf reloadCurData];
        //更新会话的头像
        [IMSDKManager toolUpdateSessionAvatarWithSessionId:weakSelf.groupInfoModel.groupId withAvatar:avatarUrl];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//#pragma mark - Lazy
//- (ZFileNetProgressManager *)fileUploader {
//    if (!_fileUploader) {
//        _fileUploader = [[ZFileNetProgressManager alloc] init];
//    }
//    return _fileUploader;
//}

@end
