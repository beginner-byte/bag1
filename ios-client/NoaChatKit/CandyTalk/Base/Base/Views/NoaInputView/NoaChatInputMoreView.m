//
//  NoaChatInputMoreView.m
//  NoaKit
//
//  Created by Candy on 2026/9/27.
//

#import "NoaChatInputMoreView.h"
#import "NoaToolManager.h"
#import "NoaBaseTableView.h"
#import "NoaImageTitleContentArrowCell.h"

@interface NoaChatInputMoreView () <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,ZBaseCellDelegate>
@property (nonatomic, strong) NoaBaseTableView *tableView;
@end

@implementation NoaChatInputMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _actionList = @[
            @{
                @"actionTitle" : LanguageToolMatch(@"语音通话"),
                @"actionImage" : @"c_input_audio",
                @"actionImage_dark" : @"c_input_audio_dark",
                @"actionType"  : @(ZChatInputActionTypeAudioCall)
            },
            @{
                @"actionTitle" : LanguageToolMatch(@"视频通话"),
                @"actionImage" : @"c_input_video",
                @"actionImage_dark" : @"c_input_video_dark",
                @"actionType"  : @(ZChatInputActionTypeVideoCall)
            },
            @{
                @"actionTitle" : LanguageToolMatch(@"相册"),
                @"actionImage" : @"c_input_image",
                @"actionImage_dark" : @"c_input_image_dark",
                @"actionType"  : @(ZChatInputActionTypePhotoAlbum)
            },
            @{
                @"actionTitle" : LanguageToolMatch(@"文件"),
                @"actionImage" : @"c_input_file",
                @"actionImage_dark" : @"c_input_file_dark",
                @"actionType"  : @(ZChatInputActionTypeFile)
            },
            @{
                @"actionTitle" : LanguageToolMatch(@"收藏"),
                @"actionImage" : @"c_input_collection",
                @"actionImage_dark" : @"c_input_collection_dark",
                @"actionType"  : @(ZChatInputActionTypeCollection)
            },
        ].mutableCopy;
        
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    self.frame = CGRectMake(0, 0, DScreenWidth, DScreenHeight);
    self.tkThemebackgroundColors = @[[UIColor clearColor],[UIColor clearColor]];
//    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.03];
    [CurrentWindow addSubview:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDismiss)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    
    _tableView = [[NoaBaseTableView alloc] initWithFrame:CGRectMake(DWScale(16), DScreenHeight, DWScale(127), 0) style:UITableViewStylePlain];
    _tableView.alpha = 0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.bounces = NO;
    [_tableView registerClass:[NoaImageTitleContentArrowCell class] forCellReuseIdentifier:[NoaImageTitleContentArrowCell cellIdentifier]];
    [self addSubview:_tableView];
    _tableView.layer.cornerRadius = DWScale(8);
    _tableView.layer.masksToBounds = YES;
}
#pragma mark - 界面赋值
- (void)setMoreType:(ZChatInputViewType)moreType {
    _moreType = moreType;
    
    if (moreType == ZChatInputViewTypeFileHelper) {
        //文件助手
        _actionList = @[
            @{
                @"actionTitle" : LanguageToolMatch(@"相册"),
                @"actionImage" : @"c_input_image",
                @"actionImage_dark" : @"c_input_image_dark",
                @"actionType"  : @(ZChatInputActionTypePhotoAlbum)
            },
            @{
                @"actionTitle" : LanguageToolMatch(@"文件"),
                @"actionImage" : @"c_input_file",
                @"actionImage_dark" : @"c_input_file_dark",
                @"actionType"  : @(ZChatInputActionTypeFile)
            },
            @{
                @"actionTitle" : LanguageToolMatch(@"收藏"),
                @"actionImage" : @"c_input_collection",
                @"actionImage_dark" : @"c_input_collection_dark",
                @"actionType"  : @(ZChatInputActionTypeCollection)
            },
        ].mutableCopy;
    }
    
    [_tableView reloadData];
    
    
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:_tableView]) {
        return NO;
    }
    return YES;
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _actionList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoaImageTitleContentArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:[NoaImageTitleContentArrowCell cellIdentifier] forIndexPath:indexPath];
    cell.lblContent.hidden = YES;
    cell.ivArrow.hidden = YES;
    NSDictionary *actionDict = [_actionList objectAtIndexSafe:indexPath.row];
    cell.ivLogo.image = ImgNamed(actionDict[@"actionImage"]);
    cell.lblTitle.text = actionDict[@"actionTitle"];
    cell.baseDelegate = self;
    cell.baseCellIndexPath = indexPath;
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DWScale(44);
}

#pragma mark - ZBaseCellDelegate
- (void)cellClickAction:(NSIndexPath *)indexPath {
    NSDictionary *actionDict = [_actionList objectAtIndexSafe:indexPath.row];
    ZChatInputActionType actionType = [[actionDict objectForKeySafe:@"actionType"] integerValue];
    
    switch (actionType) {
        case ZChatInputActionTypePhotoAlbum://相册
        {
            //需要检测用户角色信息，是否可以进行图片、视频
            WeakSelf
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            [dict setValue:@"UPIMAGEVIDEOFILE" forKey:@"authorityType"];
            [IMSDKManager userGetUserAuthorityWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                NSLog(@"!!!%@",data);
                BOOL resultData = [data boolValue];
                if (resultData) {
                    //有操作权限
                    [weakSelf moreViewSelectActionWith:actionType];
                }else {
                    //没有操作权限
                    [HUD showMessage:LanguageToolMatch(@"无操作权限")];
                }
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
        }
            break;
        case ZChatInputActionTypeFile://文件
        {
            //需要检测用户角色信息，是否可以进行文件，图片，视频的上传
            WeakSelf
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:UserManager.userInfo.userUID forKey:@"userUid"];
            [dict setValue:@"UPFILE" forKey:@"authorityType"];
            [IMSDKManager userGetUserAuthorityWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                NSLog(@"!!!%@",data);
                BOOL resultData = [data boolValue];
                if (resultData) {
                    //有操作权限
                    [weakSelf moreViewSelectActionWith:actionType];
                }else {
                    //没有操作权限
                    [HUD showMessage:LanguageToolMatch(@"无操作权限")];
                }
            } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                [HUD showMessageWithCode:code errorMsg:msg];
            }];
            
        }
            
            break;
            
        default:
        {
            [self moreViewSelectActionWith:actionType];
        }
            break;
    }
    
}

- (void)moreViewSelectActionWith:(ZChatInputActionType)actionType {
    [self viewDismiss];
    
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewActionWith:)]) {
        [_delegate moreViewActionWith:actionType];
    }
    
}

#pragma mark - 交互事件
- (void)viewShow {
    WeakSelf
    
    CGFloat viewH = _actionList.count > 6 ? DWScale(176+44) : _actionList.count * DWScale(44);
    
    [UIView animateWithDuration:0.1 animations:^{
        
        weakSelf.tableView.y = DScreenHeight - weakSelf.bottomH;
        
    } completion:^(BOOL finished) {
        weakSelf.tableView.alpha = 1;
        
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.tableView.y = DScreenHeight - viewH - weakSelf.bottomH;
            weakSelf.tableView.height = viewH;
        }];
        
    }];
}

- (void)viewDismiss {
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.tableView.height = 0;
        weakSelf.tableView.y = DScreenHeight - weakSelf.bottomH;
    } completion:^(BOOL finished) {
        [weakSelf.tableView removeFromSuperview];
        weakSelf.tableView = nil;
        [weakSelf removeFromSuperview];
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewActionWith:)]) {
        [_delegate moreViewActionWith:0];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
