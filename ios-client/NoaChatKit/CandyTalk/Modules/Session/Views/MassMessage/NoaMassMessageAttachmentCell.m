//
//  NoaMassMessageAttachmentCell.m
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaMassMessageAttachmentCell.h"

@implementation NoaMassMessageAttachmentCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupUI {
    _ivAttachment = [UIImageView new];
    _ivAttachment.layer.cornerRadius = DWScale(8);
    _ivAttachment.layer.masksToBounds = YES;
    [self.viewContent addSubview:_ivAttachment];
    [_ivAttachment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.viewContent).offset(DWScale(16));
        make.top.equalTo(self.viewContent).offset(DWScale(77));
        make.bottom.equalTo(self.viewContent).offset(-DWScale(88));
        make.size.mas_equalTo(CGSizeMake(DWScale(88), DWScale(88)));
    }];
    
    _ivPlay = [[UIImageView alloc] initWithImage:ImgNamed(@"icon_video_msg_play")];
    _ivPlay.hidden = YES;
    [self.viewContent addSubview:_ivPlay];
    [_ivPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_ivAttachment);
        make.size.mas_equalTo(CGSizeMake(DWScale(26), DWScale(26)));
    }];
    
    _lblFileType = [UILabel new];
    _lblFileType.font = FONTR(22);
    _lblFileType.tkThemetextColors = @[COLORWHITE, COLORWHITE_DARK];
    _lblFileType.textAlignment = NSTextAlignmentCenter;
    _lblFileType.hidden = YES;
    [self.viewContent addSubview:_lblFileType];
    [_lblFileType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_ivAttachment);
        make.bottom.equalTo(_ivAttachment).offset(-DWScale(7));
    }];
    
    _lblFileName = [UILabel new];
    _lblFileName.font = FONTR(12);
    _lblFileName.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _lblFileName.hidden = YES;
    [self.viewContent addSubview:_lblFileName];
    [_lblFileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_ivAttachment);
        make.leading.equalTo(_ivAttachment.mas_trailing).offset(DWScale(10));
        make.trailing.equalTo(self.viewContent).offset(-DWScale(10));
    }];
    
    _lblFileSize = [UILabel new];
    _lblFileSize.font = FONTR(12);
    _lblFileSize.tkThemetextColors = @[COLOR_99, COLOR_99_DARK];
    _lblFileSize.hidden = YES;
    [self.viewContent addSubview:_lblFileSize];
    [_lblFileSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(_lblFileName);
        make.bottom.equalTo(_ivAttachment);
    }];
    
    UIButton *btnCheck = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCheck addTarget:self action:@selector(btnCheckClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewContent addSubview:btnCheck];
    [btnCheck mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(_ivAttachment);
        make.trailing.equalTo(self.viewContent).offset(-DWScale(16));
    }];
}

- (void)setMessageModel:(LIMMassMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    
    CGFloat ivAttachmentW = DWScale(88);
    
    if (messageModel.mtype == 1) {
        //图片
        [_ivAttachment sd_setImageWithURL:[messageModel.bodyModel.name getImageFullUrl] placeholderImage:DefaultImage options:SDWebImageAllowInvalidSSLCertificates];
        _ivPlay.hidden = YES;
        _lblFileType.hidden = YES;
        _lblFileName.hidden = YES;
        _lblFileSize.hidden = YES;
    }else if (messageModel.mtype == 2) {
        //视频
        [_ivAttachment sd_setImageWithURL:[messageModel.bodyModel.cImg getImageFullUrl] placeholderImage:DefaultImage options:SDWebImageAllowInvalidSSLCertificates];
        _ivPlay.hidden = NO;
        _lblFileType.hidden = YES;
        _lblFileName.hidden = YES;
        _lblFileSize.hidden = YES;
    }else if (messageModel.mtype == 5) {
        //文件
        _ivAttachment.image = [UIImage getFileMessageIconWithFileType:messageModel.bodyModel.type fileName:messageModel.bodyModel.name];
        ivAttachmentW = DWScale(70);
        _ivPlay.hidden = YES;
        _lblFileType.hidden = NO;
        _lblFileName.hidden = NO;
        _lblFileSize.hidden = NO;
        _lblFileType.text = [NSString getFileTypeContentWithFileType:messageModel.bodyModel.type fileName:messageModel.bodyModel.name];
        NSRange range1 = [messageModel.bodyModel.name rangeOfString:@"-"];
        if (range1.length == 0) {
            _lblFileName.text = messageModel.bodyModel.name;
        } else {
            _lblFileName.text = [messageModel.bodyModel.name safeSubstringWithRange:NSMakeRange(range1.location+1, messageModel.bodyModel.name.length - (range1.location+1))];
        }
        _lblFileSize.text = [NSString stringWithFormat:@"%@ %@", [NSString getFileTypeContentWithFileType:messageModel.bodyModel.type fileName:messageModel.bodyModel.name], [NSString fileTranslateToSize:messageModel.bodyModel.size]];
    }
    
    [_ivAttachment mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.viewContent).offset(DWScale(16));
        make.top.equalTo(self.viewContent).offset(DWScale(77));
        make.bottom.equalTo(self.viewContent).offset(-DWScale(88));
        make.size.mas_equalTo(CGSizeMake(ivAttachmentW, DWScale(88)));
    }];
}

#pragma mark - 交互事件
//查看附件信息
- (void)btnCheckClick {
    if (self.massMessageDelegate && [self.massMessageDelegate respondsToSelector:@selector(cellCheckDetailWith:)] && self.messageModel) {
        [self.massMessageDelegate cellCheckDetailWith:self.messageModel];
    }
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
