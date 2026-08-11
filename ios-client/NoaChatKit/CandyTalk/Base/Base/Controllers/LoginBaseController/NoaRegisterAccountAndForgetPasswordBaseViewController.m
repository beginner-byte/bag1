//
//  NoaRegisterAccountAndForgetPasswordBaseViewController.m
//  NoaChatKit
//
//  Created by phl on 2025/11/11.
//

#import "NoaRegisterAccountAndForgetPasswordBaseViewController.h"

@interface NoaRegisterAccountAndForgetPasswordBaseViewController ()

/// 背景图片
@property (nonatomic, strong) UIImageView *bgImgView;

@end

@implementation NoaRegisterAccountAndForgetPasswordBaseViewController

// MARK: set/get
- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [UIImageView new];
        _bgImgView.image = ImgNamed(@"icon_register_bg");
        // 设置内容模式：保持宽高比，填充整个视图（超出部分会被裁剪）
        _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        // 裁剪超出边界的部分
        _bgImgView.clipsToBounds = YES;
    }
    return _bgImgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 调用布局
    [self setupBaseNavBar];
    [self setupBaseUI];
}

- (void)setupBaseNavBar {
    self.navBtnBack.hidden = NO;
    self.navBtnRight.hidden = YES;
    self.navTitleLabel.hidden = NO;
    self.navLineView.hidden = YES;
    self.navView.tkThemebackgroundColors = @[UIColor.clearColor, UIColor.clearColor];
}

- (void)setupBaseUI {
    [self.view addSubview:self.bgImgView];
    [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.leading.trailing.equalTo(self.view);
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
