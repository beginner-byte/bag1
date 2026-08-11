//
//  NoaRobotListViewController.m
//  NoaKit
//
//  Created by Apple on 2023/9/25.
//

#import "NoaRobotListViewController.h"
#import "NoaRobotListTableViewCell.h"
#import "NoaRobotModel.h"
@interface NoaRobotListViewController ()<UITableViewDataSource,UITableViewDelegate,ZBaseCellDelegate>
@property (nonatomic, strong) NSMutableArray *robotListArray;//展示机器人列表
@end

@implementation NoaRobotListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavUI];
    [self setupUI];
    [self getRobotList];
    // Do any additional setup after loading the view.
}
-(void)getRobotList{
    WeakSelf
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.groupInfoModel.groupId forKey:@"groupId"];
    [[NoaIMSDKManager sharedTool] groupGetRobotListWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *robotArray = (NSArray *)data;
            for(NSDictionary * dic in robotArray){
                NoaRobotModel * robotModel = [NoaRobotModel mj_objectWithKeyValues:dic];
                [weakSelf.robotListArray addObject:robotModel];
            }
            [weakSelf.baseTableView reloadData];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}
-(NSMutableArray*)robotListArray{
    if(nil == _robotListArray){
        _robotListArray = @[].mutableCopy;
    }
    return _robotListArray;
}
#pragma mark - 界面布局
- (void)setupNavUI {
    self.navTitleStr = LanguageToolMatch(@"群机器人");
    self.navBtnRight.hidden = YES;
}
-(void)setupUI{
    [self.view addSubview:self.baseTableView];
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    ///self.baseTableView.mj_header = self.refreshHeader;
    self.baseTableView.delaysContentTouches = NO;
    [self.baseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-DHomeBarH);
        make.top.equalTo(self.view.mas_top).offset(DNavStatusBarH + DWScale(6));
    }];
    [self.baseTableView registerClass:[NoaRobotListTableViewCell class] forCellReuseIdentifier:[NoaRobotListTableViewCell cellIdentifier]];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.robotListArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaRobotModel * model = [self.robotListArray objectAtIndex:indexPath.row];
    NoaRobotListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaRobotListTableViewCell cellIdentifier] forIndexPath:indexPath];
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    [cell cellConfigWithModel:model];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NoaRobotListTableViewCell defaultCellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
