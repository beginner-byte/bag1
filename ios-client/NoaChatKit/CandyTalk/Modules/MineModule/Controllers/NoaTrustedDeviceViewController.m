//
//  NoaTrustedDeviceViewController.m
//  CandyTalk
//
//  Created by Codex on 2026/8/9.
//

#import "NoaTrustedDeviceViewController.h"
#import "NoaTrustedDeviceCell.h"
#import "NoaTrustedDeviceModel.h"
#import "NoaAuthInputTools.h"
#import "LXChatEncrypt.h"

@interface NoaTrustedDeviceViewController () <UITableViewDataSource, UITableViewDelegate>

/// 服务端返回的信任设备列表。
@property (nonatomic, copy) NSArray<NoaTrustedDeviceModel *> *deviceList;

@end

@implementation NoaTrustedDeviceViewController

/// 初始化信任设备页面的导航标题和基础背景。
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitleStr = LanguageToolMatch(@"信任设备");
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    [self setupUI];
    [self requestTrustedDeviceList];
}

/// 创建信任设备列表并配置空列表提示。
- (void)setupUI {
    self.deviceList = @[];
    self.baseTableView.dataSource = self;
    self.baseTableView.delegate = self;
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.baseTableView.backgroundColor = UIColor.clearColor;
    [self.baseTableView registerClass:[NoaTrustedDeviceCell class] forCellReuseIdentifier:NSStringFromClass([NoaTrustedDeviceCell class])];
    [self.view addSubview:self.baseTableView];
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(DNavStatusBarH);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
    }];
    [self updateEmptyState];
}

/// 请求当前用户的信任设备列表，并将响应字典转换为页面模型。
- (void)requestTrustedDeviceList {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];

    WeakSelf
    [IMSDKManager authTrustedDeviceListWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        NSMutableArray<NoaTrustedDeviceModel *> *devices = [NSMutableArray array];
        if ([data isKindOfClass:[NSArray class]]) {
            for (id item in (NSArray *)data) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    NoaTrustedDeviceModel *model = [NoaTrustedDeviceModel mj_objectWithKeyValues:item];
                    NSString *localDeviceUuid = [FCUUID uuidForDevice];
                    model.current = model.isCurrent || (localDeviceUuid.length > 0 && [model.deviceUuid isEqualToString:localDeviceUuid]);
                    [devices addObject:model];
                }
            }
        }
        weakSelf.deviceList = [devices copy];
        [weakSelf.baseTableView reloadData];
        [weakSelf updateEmptyState];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

/// 根据设备数量显示或移除空列表提示。
- (void)updateEmptyState {
    if (self.deviceList.count > 0) {
        self.baseTableView.backgroundView = nil;
        return;
    }
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = LanguageToolMatch(@"暂无信任设备");
    emptyLabel.font = FONTR(15);
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    self.baseTableView.backgroundView = emptyLabel;
}

/// 返回信任设备列表行数。
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceList.count;
}

/// 返回信任设备卡片高度。
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaTrustedDeviceModel *device = [self.deviceList objectAtIndexSafe:indexPath.row];
    return DWScale(device.isCurrent ? 178 : 230);
}

/// 创建并配置指定位置的信任设备单元格。
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaTrustedDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NoaTrustedDeviceCell class]) forIndexPath:indexPath];
    cell.deviceModel = [self.deviceList objectAtIndexSafe:indexPath.row];
    WeakSelf
    cell.revokeDeviceBlock = ^(NoaTrustedDeviceModel *device) {
        [weakSelf presentRevokeConfirmationForDevice:device];
    };
    return cell;
}

#pragma mark - 剔除设备
/// 展示登录密码确认框；当前设备或缺少设备标识时不允许发起剔除。
/// @param device 用户选择剔除的目标设备
- (void)presentRevokeConfirmationForDevice:(NoaTrustedDeviceModel *)device {
    if (device.isCurrent || device.deviceUuid.length == 0 || device.deviceType.length == 0) {
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LanguageToolMatch(@"剔除设备")
                                                                   message:LanguageToolMatch(@"剔除后，该设备需要重新登录。")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = LanguageToolMatch(@"请输入当前账号登录密码");
        textField.secureTextEntry = YES;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    [alert addAction:[UIAlertAction actionWithTitle:LanguageToolMatch(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    WeakSelf
    [alert addAction:[UIAlertAction actionWithTitle:LanguageToolMatch(@"确认") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *password = alert.textFields.firstObject.text;
        if (![NoaAuthInputTools checkPasswordWithText:password IsShowToast:YES]) {
            return;
        }
        [weakSelf requestEncryptKeyForRevokeDevice:device password:password];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 获取一次性加密密钥，用于加密本次设备剔除请求中的登录密码。
/// @param device 用户选择剔除的目标设备
/// @param password 用户本次临时输入的登录密码，不进行持久化
- (void)requestEncryptKeyForRevokeDevice:(NoaTrustedDeviceModel *)device password:(NSString *)password {
    [HUD showActivityMessage:@"" inView:self.view];
    WeakSelf
    [IMSDKManager authGetEncryptKeySuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        if (![data isKindOfClass:[NSString class]] || [(NSString *)data length] == 0) {
            [HUD showMessage:LanguageToolMatch(@"操作失败") inView:weakSelf.view];
            return;
        }
        [weakSelf revokeDevice:device password:password encryptKey:(NSString *)data];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

/// 加密登录密码并调用服务端接口撤销目标设备会话。
/// @param device 用户选择剔除的目标设备
/// @param password 用户本次临时输入的登录密码
/// @param encryptKey 服务端下发的一次性加密密钥
- (void)revokeDevice:(NoaTrustedDeviceModel *)device password:(NSString *)password encryptKey:(NSString *)encryptKey {
    NSString *passwordKey = [NSString stringWithFormat:@"%@%@", encryptKey, password];
    NSString *encryptedPassword = [LXChatEncrypt method4:passwordKey];
    if (encryptedPassword.length == 0) {
        [HUD showMessage:LanguageToolMatch(@"操作失败") inView:self.view];
        return;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:device.deviceUuid forKey:@"deviceUuid"];
    [params setObjectSafe:device.deviceType forKey:@"deviceType"];
    [params setObjectSafe:encryptedPassword forKey:@"passwd"];
    [params setObjectSafe:encryptKey forKey:@"encryptKey"];

    [HUD showActivityMessage:@"" inView:self.view];
    WeakSelf
    [IMSDKManager authTrustedDeviceRevokeWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        NSMutableArray<NoaTrustedDeviceModel *> *remainingDevices = [weakSelf.deviceList mutableCopy];
        NSIndexSet *removedIndexes = [remainingDevices indexesOfObjectsPassingTest:^BOOL(NoaTrustedDeviceModel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            return [item.deviceUuid isEqualToString:device.deviceUuid];
        }];
        [remainingDevices removeObjectsAtIndexes:removedIndexes];
        weakSelf.deviceList = [remainingDevices copy];
        [weakSelf.baseTableView reloadData];
        [weakSelf updateEmptyState];
        [HUD showMessage:LanguageToolMatch(@"剔除成功") inView:weakSelf.view];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg inView:weakSelf.view];
    }];
}

@end
