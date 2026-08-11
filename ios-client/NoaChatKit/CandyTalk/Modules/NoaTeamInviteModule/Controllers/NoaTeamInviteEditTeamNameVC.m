//
//  NoaTeamInviteEditTeamNameVC.m
//  NoaKit
//
//  Created by phl on 2025/7/25.
//

#import "NoaTeamInviteEditTeamNameVC.h"
#import "NoaTeamInviteEditTeamNameView.h"
#import "NoaTeamInviteEditTeamNameDataHandle.h"

@interface NoaTeamInviteEditTeamNameVC ()

@property (nonatomic, strong) NoaTeamInviteEditTeamNameDataHandle *dataHandle;

@property (nonatomic, strong) NoaTeamInviteEditTeamNameView *contentView;

@end

@implementation NoaTeamInviteEditTeamNameVC

- (void)dealloc {
    CIMLog(@"%@ dealloc", [self class]);
}

- (NoaTeamInviteEditTeamNameView *)contentView {
    if (!_contentView) {
        _contentView = [[NoaTeamInviteEditTeamNameView alloc]initWithFrame:CGRectZero
                                                  editTeamNameDataHandle:self.dataHandle];
    }
    return _contentView;
}

- (NoaTeamInviteEditTeamNameDataHandle *)dataHandle {
    if (!_dataHandle) {
        _dataHandle = [[NoaTeamInviteEditTeamNameDataHandle alloc] initWithTeamModel:self.currentTeamModel];
    }
    return _dataHandle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self processData];
    // Do any additional setup after loading the view.
}

- (void)setUpUI {
    self.navView.hidden = YES;
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = HEXACOLOR(@"000000", 0.6);
    [self.view addSubview:maskView];
    // 点击遮盖关闭当前页面
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
    [maskView addGestureRecognizer:tap];
    
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(67);
        make.leading.bottom.trailing.equalTo(self.view);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 切圆角
        CAShapeLayer *contentViewLayer = [self configCornerRect:UIRectCornerAllCorners radius:12.0 rect:self.contentView.bounds];
        self.contentView.layer.mask = contentViewLayer;
    });
}

/// 将控件画圆角
/// - Parameters:
///   - corners: 哪个角绘制圆角
///   - cornerRadius: 半径
///   - rect: 控件的frame
- (CAShapeLayer *)configCornerRect:(UIRectCorner)corners
                            radius:(CGFloat)cornerRadius
                              rect:(CGRect)rect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}

/// 退出模态页面
- (void)dismissPopup {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)processData {
    @weakify(self)
    [self.dataHandle.backSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSString *newName = x;
        if ([NSString isNil:newName]) {
            [self dismissPopup];
        }else {
            if (self.changeTeamNameHandle) {
                self.changeTeamNameHandle(newName);
            }
            [self dismissPopup];
        }
        
    }];
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
