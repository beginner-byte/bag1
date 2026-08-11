//
//  NoaMessageGameStickersCell.m
//  NoaKit
//
//  Created by Candy on 2023/12/14.
//

#import "NoaMessageGameStickersCell.h"

@interface NoaMessageGameStickersCell ()

@property (nonatomic, strong)UIImageView *contentImageView;
@property (nonatomic, strong)NSString *msgIdStr;

@end

@implementation NoaMessageGameStickersCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupGameStickersUI];
    }
    return self;
}

#pragma mark - UI布局
- (void)setupGameStickersUI {
    self.contentImageView = [[UIImageView alloc] init];
    self.contentImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.contentImageView];
}

- (void)setConfigMessage:(NoaMessageModel *)model {
    [super setConfigMessage:model];
    self.msgIdStr = model.message.msgID;
    
    self.contentImageView.frame = _contentRect;
    
    //已经展示过动画
    BOOL isGameAnimationed = model.message.isGameAnimationed;
    if (isGameAnimationed) {
        //加载游戏表情
        NSString *contentImgName;
        if (model.message.gameSticekersType == ZChatGameStickerTypeFingerGuessing) {
            //石头剪刀布
            contentImgName = [NSString stringWithFormat:@"icon_chat_message_stoneScissorCloth%@", model.message.gameStickersResut];
        } else if (model.message.gameSticekersType == ZChatGameStickerTypePlayDice) {
            //摇骰子
            contentImgName = [NSString stringWithFormat:@"icon_chat_message_dice%@", model.message.gameStickersResut];
        } else {
            contentImgName = @"";
        }
        //设置图片
        [self.contentImageView setImage:ImgNamed(contentImgName)];
    } else {
        //未展示过动画，开始执行动画
        [self gameStickersStartAnimation];
    }
}

//开始执行动画
- (void)gameStickersStartAnimation {
    NSString *iconAnimationNamePrefix = @"";
    NSInteger imgNum = 0;
    NSTimeInterval duringTime = 0;
    if (self.messageModel.message.gameSticekersType == ZChatGameStickerTypeFingerGuessing) {
        iconAnimationNamePrefix = @"icon_chat_message_stoneScissorCloth";
        imgNum = 3;
        duringTime = 0.9;
    }
    if (self.messageModel.message.gameSticekersType == ZChatGameStickerTypePlayDice) {
        iconAnimationNamePrefix = @"icon_chat_message_dice_animation";
        imgNum = 4;
        duringTime = 0.4;
    }
    
    if ([self.messageModel.message.msgID isEqualToString:self.msgIdStr]) {
        NSMutableArray *imgArr = [NSMutableArray array];
        for (int i = 1; i <= imgNum; i++) {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", iconAnimationNamePrefix, i]];
            [imgArr addObject:img];
        }
        self.contentImageView.animationImages = imgArr;
        self.contentImageView.animationDuration = duringTime;
        self.contentImageView.animationRepeatCount = 0;
        [self.contentImageView startAnimating];
    }
    //3s后动画结束显示真正的结果
    [self performSelector:@selector(gameStickersStopAnimation) withObject:nil afterDelay:3.0];
}

//动画执行结束
- (void)gameStickersStopAnimation {
    if ([self.messageModel.message.msgID isEqualToString:self.msgIdStr]) {
        NSString *iconContentNamePrefix = @"";
        if (self.messageModel.message.gameSticekersType == ZChatGameStickerTypeFingerGuessing) {
            iconContentNamePrefix = @"icon_chat_message_stoneScissorCloth";
        }
        if (self.messageModel.message.gameSticekersType == ZChatGameStickerTypePlayDice) {
            iconContentNamePrefix = @"icon_chat_message_dice";
        }
        
        [self.contentImageView stopAnimating];
        [self messageAnimationComplete];
        NSString *contentImgName = [NSString stringWithFormat:@"%@%@", iconContentNamePrefix, self.messageModel.message.gameStickersResut];
        [self.contentImageView setImage:ImgNamed(contentImgName)];
    }
}

- (void)messageAnimationComplete {
    self.messageModel.message.isGameAnimationed = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(gameMessageAnimationComplete:)]) {
        [self.delegate gameMessageAnimationComplete:self.cellIndex];
    }
}

#pragma mark - Other
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
