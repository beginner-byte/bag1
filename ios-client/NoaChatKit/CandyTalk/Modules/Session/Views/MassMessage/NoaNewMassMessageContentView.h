//
//  NoaNewMassMessageContentView.h
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZNewMassMessageContentViewDelegate <NSObject>
- (void)newMassMessageSelect:(NSInteger)selectType;
- (void)newMassMessageAttachmentType:(NSInteger)attachmentType attachment:(id)attachment;
@end

@interface NoaNewMassMessageContentView : UIView
@property (nonatomic, strong) UIButton *btnText;//文本
@property (nonatomic, strong) UIView *viewMessage;
@property (nonatomic, strong) UILabel *lblMessageTip;
@property (nonatomic, strong) UITextView *tvMessage;

@property (nonatomic, strong) UIButton *btnAttachment;//附件
@property (nonatomic, strong) UIView *viewAttachment;
@property (nonatomic, strong) UIButton *btnSelectAttachment;
@property (nonatomic, strong) UIImageView *ivAttachment;
@property (nonatomic, strong) UIImageView *ivPlay;
@property (nonatomic, strong) UILabel *lblFileType;
@property (nonatomic, strong) UILabel *lblFileName;
@property (nonatomic, strong) UILabel *lblFileSize;
@property (nonatomic, strong) UIButton *btnReselect;//重选

@property (nonatomic, strong) UIButton *btnSelected;//被选中的按钮

@property (nonatomic, weak) id <ZNewMassMessageContentViewDelegate> delegate;

//手机里的文件信息
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, copy) NSString *fileSaxboxPath;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, assign) CGFloat fileSize;

@end

NS_ASSUME_NONNULL_END
