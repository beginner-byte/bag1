//
//  NoaMessageCallCell.m
//  NoaKit
//
//  Created by Candy on 2023/2/24.
//

#import "NoaMessageCallCell.h"

@implementation NoaMessageCallCell
{
    UILabel *_contentLabel;
    UIImageView *_callTypeImgView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupMediaCallUI];
    }
    return self;
}
#pragma mark - 界面布局
- (void)setupMediaCallUI {
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = FONTN(16);
    _contentLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:_contentLabel];
    
    _callTypeImgView = [[UIImageView alloc] init];
    _callTypeImgView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_callTypeImgView];
    [_callTypeImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(10);
        make.centerY.equalTo(_contentLabel);
        make.width.height.mas_equalTo(DWScale(18));
    }];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    
    _contentLabel.frame = _contentRect;
    _contentLabel.attributedText = [model attStr];
    
    if (model.isSelf) {
        //自己发的消息
        _contentLabel.tkThemetextColors = @[COLORWHITE, COLORWHITE];
        if (model.message.messageType == CIMChatMessageType_NetCallMessage) {
            //即构音视频
            
            if (model.message.netCallType == 2) {
                //视频通话
                _callTypeImgView.image = ImgNamed(@"icon_call_video_self");
            } else {
                //语音通话
                _callTypeImgView.image = ImgNamed(@"icon_call_phone_self");
            }
            
        }else if (model.message.messageType == CIMChatMessageType_ServerMessage) {
            //LiveKit音视频
            IMServerMessage *serverMessage = model.message.serverMessage;
            CustomEvent *customEvent = serverMessage.customEvent;
            NSString *jsonContent = customEvent.content;
            NSInteger liveKitCallType = 0;
            if (customEvent.type == 101) {
                //单人音视频
                LIMMediaCallSingleModel *singleCallModel = [LIMMediaCallSingleModel mj_objectWithKeyValues:jsonContent];
                liveKitCallType = singleCallModel.mode;
            }else if (customEvent.type == 103){
                //多人音视频
                LIMMediaCallGroupParticipantAction *groupCallModel = [LIMMediaCallGroupParticipantAction mj_objectWithKeyValues:jsonContent];
                liveKitCallType = groupCallModel.mode;
            }
                
            
            if (liveKitCallType == 0) {
                //视频通话
                _callTypeImgView.image = ImgNamed(@"icon_call_video_self");
            } else {
                //语音通话
                _callTypeImgView.image = ImgNamed(@"icon_call_phone_self");
            }
            
        }
        [_callTypeImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self->_contentLabel.mas_leading).offset(-6);
            make.centerY.equalTo(self->_contentLabel);
            make.width.height.mas_equalTo(DWScale(18));
        }];
    } else {
        //别人发的消息
        _contentLabel.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        if (model.message.messageType == CIMChatMessageType_NetCallMessage) {
            //即构音视频
            
            if (model.message.netCallType == 2) {
                //视频通话
                _callTypeImgView.image = ImgNamed(@"icon_call_video_other");
            } else {
                //语音通话
                _callTypeImgView.image = ImgNamed(@"icon_call_phone_other");
            }
            
        }else if (model.message.messageType == CIMChatMessageType_ServerMessage) {
            //LiveKit音视频
            IMServerMessage *serverMessage = model.message.serverMessage;
            CustomEvent *customEvent = serverMessage.customEvent;
            NSString *jsonContent = customEvent.content;
            NSInteger liveKitCallType = 0;
            if (customEvent.type == 101) {
                //单人音视频
                LIMMediaCallSingleModel *singleCallModel = [LIMMediaCallSingleModel mj_objectWithKeyValues:jsonContent];
                liveKitCallType = singleCallModel.mode;
            }else if (customEvent.type == 103){
                //多人音视频
                LIMMediaCallGroupParticipantAction *groupCallModel = [LIMMediaCallGroupParticipantAction mj_objectWithKeyValues:jsonContent];
                liveKitCallType = groupCallModel.mode;
            }
            
            if (liveKitCallType == 0) {
                //视频通话
                _callTypeImgView.image = ImgNamed(@"icon_call_video_other");
            } else {
                //语音通话
                _callTypeImgView.image = ImgNamed(@"icon_call_phone_other");
            }
            
        }
        
        [_callTypeImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self->_contentLabel.mas_trailing).offset(6);
            make.centerY.equalTo(self->_contentLabel);
            make.width.height.mas_equalTo(DWScale(18));
        }];
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
