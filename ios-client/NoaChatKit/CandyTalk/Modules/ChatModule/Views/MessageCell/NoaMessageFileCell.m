//
//  NoaMessageFileCell.m
//  NoaKit
//
//  Created by Candy on 2023/1/5.
//

#import "NoaMessageFileCell.h"
//#import "ZFileNetProgressManager.h"
//#import "NoaFileManager.h"

@interface NoaMessageFileCell()

@property(nonatomic, strong)UIImageView *fileIconImgView;
@property(nonatomic, strong)UILabel *fileTypeLbl;
@property(nonatomic, strong)UILabel *fileTitleLbl;
@property(nonatomic, strong)UILabel *fileSubTitleLbl;
@property(nonatomic, strong)UIButton *downUploadBtn;

@end

@implementation NoaMessageFileCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        [self setupFileUI];
    }
    return self;
}

#pragma mark - UI布局
- (void)setupFileUI {
    _fileIconImgView = [[UIImageView alloc] init];
    _fileIconImgView.image = ImgNamed(@"icon_file_unknow");
    [self.contentView addSubview:_fileIconImgView];

    _fileTypeLbl = [[UILabel alloc] init];
    _fileTypeLbl.text = @"";
    _fileTypeLbl.tkThemetextColors = @[COLORWHITE, COLORWHITE];
    _fileTypeLbl.font = FONTN(9);
    _fileTypeLbl.textAlignment = NSTextAlignmentCenter;
    [_fileIconImgView addSubview:_fileTypeLbl];
    [_fileTypeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_fileIconImgView);
        make.bottom.equalTo(_fileIconImgView).offset(-6);
        make.height.mas_equalTo(DWScale(10));
    }];
    
    _fileTitleLbl = [[UILabel alloc] init];
    _fileTitleLbl.text = @"";
    _fileTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _fileTitleLbl.font = FONTN(16);
    _fileTitleLbl.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:_fileTitleLbl];
    [_fileTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.viewSendBubble).offset(10);
        make.trailing.equalTo(_fileIconImgView.mas_leading).offset(-10);
        make.top.equalTo(_fileIconImgView).offset(2);
        make.height.mas_equalTo(DWScale(22));
    }];
    
    _fileSubTitleLbl = [[UILabel alloc] init];
    _fileSubTitleLbl.text = @"";
    _fileSubTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_99_DARK];
    _fileSubTitleLbl.font = FONTN(12);
    [self.contentView addSubview:_fileSubTitleLbl];
    [_fileSubTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_fileTitleLbl);
        make.bottom.equalTo(_fileIconImgView).offset(DWScale(2));
        make.height.mas_equalTo(DWScale(12));
    }];
    
    _downUploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _downUploadBtn.layer.cornerRadius = 10;
    _downUploadBtn.clipsToBounds = YES;
    _downUploadBtn.titleLabel.font = FONTR(12);
    [_downUploadBtn setTkThemeTitleColor:@[COLORWHITE,COLORWHITE] forState:UIControlStateNormal];
    [_downUploadBtn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.4]];
    [_downUploadBtn setImage:ImgNamed(@"c_file_goonBtn") forState:UIControlStateNormal];
    [_downUploadBtn setTitle:@"" forState:UIControlStateNormal];
    [_downUploadBtn addTarget:self action:@selector(downUploadBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_downUploadBtn];
    [_downUploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_fileIconImgView);
        make.width.height.mas_equalTo(DWScale(48));
    }];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    _fileIconImgView.frame = _contentRect;
    _fileIconImgView.image = [UIImage getFileMessageIconWithFileType:model.message.fileType fileName:model.message.fileName];
    _fileTypeLbl.text = [NSString getFileTypeContentWithFileType:model.message.fileType fileName:model.message.fileName];
    _fileTitleLbl.text = model.message.showFileName;
    if (model.isSelf) {
        [_fileTitleLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.viewSendBubble).offset(10);
            make.trailing.equalTo(_fileIconImgView.mas_leading).offset(-10);
            make.top.equalTo(_fileIconImgView).offset(2);
            make.height.mas_equalTo(DWScale(22));
        }];
    } else {
        [_fileTitleLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.viewReceiveBubble).offset(10);
            make.trailing.equalTo(_fileIconImgView.mas_leading).offset(-10);
            make.top.equalTo(_fileIconImgView).offset(2);
            make.height.mas_equalTo(DWScale(22));
        }];
    }
    
    if(model.isSelf) {
        WeakSelf
        /*
        [model setUploadFileSuccess:^{
            [ZTOOL doInMain:^{
                [super configMsgSendStatus:CIMChatMessageSendTypeSuccess];
                weakSelf.fileSubTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_99_DARK];
                weakSelf.fileSubTitleLbl.text = [NSString fileTranslateToSize:weakSelf.messageModel.message.fileSize];
                weakSelf.downUploadBtn.hidden = YES;
                [weakSelf.downUploadBtn setTitle:@"" forState:UIControlStateNormal];
            }];
        }];
        */
        [model setUploadFileFail:^{
            [ZTOOL doInMain:^{
                [super configMsgSendStatus:CIMChatMessageSendTypeFail];
                weakSelf.fileSubTitleLbl.textColor = HEXCOLOR(@"F93A2F");
                weakSelf.fileSubTitleLbl.text = LanguageToolMatch(@"上传失败");
                weakSelf.downUploadBtn.hidden = YES;
                [weakSelf.downUploadBtn setTitle:@"" forState:UIControlStateNormal];
            }];
        }];
        [model setUploadFileLoading:^(float progress, NSString *taskId) {
            if ([taskId isEqualToString:weakSelf.messageModel.message.msgID]) {
                //NSLog(@" =======Cell===== %@ 进度：%0.2f =============",  weakSelf.messageModel.message.showFileName, progress);
                [ZTOOL doInMain:^{
                    if (model.message.messageSendType != CIMChatMessageSendTypeSending) {
                        [super configMsgSendStatus:CIMChatMessageSendTypeSending];
                    }
                }];
                weakSelf.fileSubTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_99_DARK];
                weakSelf.fileSubTitleLbl.text = [NSString stringWithFormat:@"%@/%@",[NSString fileTranslateToSize:progress * weakSelf.messageModel.message.fileSize], [NSString fileTranslateToSize:weakSelf.messageModel.message.fileSize]];
                weakSelf.downUploadBtn.hidden = NO;
                [weakSelf.downUploadBtn setTitle:[NSString stringWithFormat:@"%0.f%%", progress * 100] forState:UIControlStateNormal];
                [weakSelf.downUploadBtn setImage:nil forState:UIControlStateNormal];
            }
        }];
        
        //UI
        if (model.message.messageSendType == CIMChatMessageSendTypeSuccess) {
            self.fileSubTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_99_DARK];
            self.fileSubTitleLbl.text = [NSString fileTranslateToSize:self.messageModel.message.fileSize];
            self.downUploadBtn.hidden = YES;
            [self.downUploadBtn setTitle:@"" forState:UIControlStateNormal];
        }
        if (model.message.messageSendType == CIMChatMessageSendTypeFail) {
            self.fileSubTitleLbl.textColor = HEXCOLOR(@"F93A2F");
            self.fileSubTitleLbl.text = LanguageToolMatch(@"上传失败");
            self.downUploadBtn.hidden = YES;
            [self.downUploadBtn setTitle:@"" forState:UIControlStateNormal];
        }
        if (model.message.messageSendType == CIMChatMessageSendTypeSending) {
            self.fileSubTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_99_DARK];
            self.fileSubTitleLbl.text = [NSString stringWithFormat:@"%@/%@", @"0", [NSString fileTranslateToSize:self.messageModel.message.fileSize]];
            self.downUploadBtn.hidden = NO;
            [self.downUploadBtn setTitle:@"0%" forState:UIControlStateNormal];
            [self.downUploadBtn setImage:nil forState:UIControlStateNormal];
        }
    } else {
        _fileSubTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_99_DARK];
        _fileSubTitleLbl.text = [NSString fileTranslateToSize:model.message.fileSize];
        _downUploadBtn.hidden = YES;
    }
//    [_model addObserver:self forKeyPath:@"byteSent" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld context:nil];
}


#pragma mark - Action
- (void)downUploadBtnAction {

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
