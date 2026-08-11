//
//  NoaSessionHeaderView.m
//  NoaKit
//
//  Created by Candy on 2026/11/2.
//

#import "NoaSessionHeaderView.h"
#import "NoaBaseCollectionView.h"
#import "NoaToolManager.h"
#import "NoaChatKit-Swift.h"
#import "NoaChatViewController.h"

@interface NoaSessionHeaderView () <UICollectionViewDataSource,UICollectionViewDelegate,ZBaseCollectionCellDelegate>
@property (nonatomic, strong) UICollectionView *collection;
@end

@implementation NoaSessionHeaderView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.tkThemebackgroundColors = @[HEXCOLOR(@"F9F9F9"), HEXCOLOR(@"393939")];
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(DScreenWidth / 5.0, DWScale(73));
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(DWScale(5), 0, DWScale(5), 0);
    _collection = [[NoaBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collection.dataSource = self;
    _collection.delegate = self;
    _collection.tkThemebackgroundColors = @[HEXCOLOR(@"F9F9F9"), HEXCOLOR(@"393939")];
    [_collection registerClass:[NoaSessionHeaderItem class] forCellWithReuseIdentifier:NSStringFromClass([NoaSessionHeaderItem class])];
    [self.contentView addSubview:_collection];
    [_collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    _collection.delaysContentTouches = NO;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sessionTopList.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoaSessionHeaderItem *cell = [_collection dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NoaSessionHeaderItem class]) forIndexPath:indexPath];
    LingIMSessionModel *sessionModel = [_sessionTopList objectAtIndexSafe:indexPath.row];
    cell.sessionModel = sessionModel;
    
    cell.baseCellDelegate = self;
    cell.baseCellIndexPath = indexPath;
    return cell;
}

#pragma mark - UICollectionViewDelegate
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    LingIMSessionModel *sessionModel = [_sessionTopList objectAtIndexSafe:indexPath.row];
//    ZChatViewController *vc = [ZChatViewController new];
//    vc.chatName = sessionModel.sessionName;
//    vc.sessionID = sessionModel.sessionID;
//    if (sessionModel.sessionType == CIMSessionTypeSingle) {
//        //单聊
//        vc.chatType = CIMChatType_SingleChat;
//    } else if (sessionModel.sessionType == CIMSessionTypeGroup) {
//        //群聊
//        vc.chatType = CIMChatType_GroupChat;
//    }
//    [CurrentVC.navigationController pushViewController:vc animated:YES];
//
//}
#pragma mark - ZBaseCollectionCellDelegate
- (void)baseCellDidSelectedRowAtIndexPath:(NSIndexPath *)indexPath {
    LingIMSessionModel *sessionModel = [_sessionTopList objectAtIndexSafe:indexPath.row];
    if ([sessionModel.sessionID isEqualToString:@"100002"]) {
        //单聊 文件助手
        CoHereFileHelperViewController *vc = [CoHereFileHelperViewController new];
        vc.sessionID = sessionModel.sessionID;
        [CurrentVC.navigationController pushViewController:vc animated:YES];
    } else {
        NoaChatViewController *vc = [NoaChatViewController new];
        vc.chatName = sessionModel.sessionName;
        vc.sessionID = sessionModel.sessionID;
        if (sessionModel.sessionType == CIMSessionTypeSingle) {
            //单聊
            vc.chatType = CIMChatType_SingleChat;
        } else if (sessionModel.sessionType == CIMSessionTypeGroup) {
            //群聊
            vc.chatType = CIMChatType_GroupChat;
        }
        [CurrentVC.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 数据更新
- (void)setSessionTopList:(NSMutableArray *)sessionTopList {
    _sessionTopList = sessionTopList;
    [_collection reloadData];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation NoaSessionHeaderItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    [self.contentView addSubview:self.baseContentButton];
    self.baseContentButton.frame = CGRectMake(0, 0, DScreenWidth / 5.0, DWScale(73));
    
    _ivHeader = [NoaBaseImageView new];
    _ivHeader.layer.cornerRadius = DWScale(22);
    _ivHeader.layer.masksToBounds = YES;
    [self.contentView addSubview:_ivHeader];
    [_ivHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(DWScale(5));
        make.size.mas_equalTo(CGSizeMake(DWScale(44), DWScale(44)));
    }];
    
    _lblName = [UILabel new];
    _lblName.tkThemetextColors = @[COLOR_66, COLOR_66_DARK];
    _lblName.font = FONTR(12);
    _lblName.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_lblName];
    [_lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-DWScale(5));
        make.width.mas_equalTo(DScreenWidth / 5.0 - DWScale(10));
    }];
}
#pragma mark - 数据赋值
- (void)setSessionModel:(LingIMSessionModel *)sessionModel {
    if (sessionModel) {
        _sessionModel = sessionModel;
        if ([_sessionModel.sessionID isEqualToString:@"100002"]) {
            //文件助手
            _ivHeader.image = ImgNamed(@"session_file_helper_logo");
            _lblName.text = LanguageToolMatch(@"文件助手");
        } else {
            if (sessionModel.sessionType == CIMSessionTypeSingle) {
                //单聊
                LingIMFriendModel *friendModel = [IMSDKManager toolCheckMyFriendWith:_sessionModel.sessionID];
                NSString *imgUrl = [NSString loadAvatarWithUserStatus:friendModel.disableStatus avatarUri:_sessionModel.sessionAvatar];
                
                [_ivHeader loadAvatarWithUserImgContent:imgUrl defaultImg:DefaultAvatar];
                _lblName.text = [NSString loadNickNameWithUserStatus:friendModel.disableStatus realNickName:_sessionModel.sessionName];
            } else {
                //群聊
                NSString *imgUrl = [NSString loadAvatarWithUserStatus:0 avatarUri:_sessionModel.sessionAvatar];
                [_ivHeader loadAvatarWithUserImgContent:imgUrl defaultImg:DefaultGroup];
                _lblName.text = sessionModel.sessionName;
            }
        }
    }
}
@end
