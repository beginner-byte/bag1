//
//  NoaMyCollectionItemModel.h
//  NoaKit
//
//  Created by Candy on 2023/4/19.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaMyCollectionBodyModel : NoaBaseModel

@property(nonatomic, copy)NSString *content;//文本消息-文本内容
@property(nonatomic, copy)NSString *translate;//文本消息-文本内容(译文)
@property(nonatomic, copy)NSString *name;   //图片消息、视频消息-图片/视频路径、文件消息-文件名字、位置消息-位置名称
@property(nonatomic, assign)float length;   //视频消息-时长
@property(nonatomic, assign)float cWidth;   //视频消息-封面图片宽度、位置消息-地图图片宽度
@property(nonatomic, assign)float cHeight;  //视频消息-封面图片高度、位置消息-地图图片宽度
@property(nonatomic, copy)NSString *cImg;   //视频消息-封面图片、位置消息-地图图片名字(路径)
@property(nonatomic, assign)float size;     //图片消息、文件消息-图片/文件大小
@property(nonatomic, assign)float width;    //图片消息-图片宽度
@property(nonatomic, assign)float height;   //图片消息-图片高度
@property(nonatomic, copy)NSString *iImg;   //图片消息-图片缩略图
@property(nonatomic, copy)NSString *path;   //文件消息-文件路径
@property(nonatomic, copy)NSString *type;   //文件消息-文件类型
@property(nonatomic, copy)NSString *lng;      //位置消息-经度
@property(nonatomic, copy)NSString *lat;      //位置消息-纬度
@property(nonatomic, copy)NSString *details;//位置消息-位置详细地址
@property(nonatomic, copy)NSString *ext;    //扩展字段
@property(nonatomic, strong)NSArray *atInfo;    //At信息

@end

@interface NoaMyCollectionItemModel : NoaBaseModel

@property(nonatomic, strong)NoaMyCollectionBodyModel *body;
@property(nonatomic, copy)NSString *collectId;
@property(nonatomic, copy)NSString *createTime;
@property(nonatomic, assign)CIMChatType ctype;
@property(nonatomic, copy)NSString *friendRemark;
@property(nonatomic, copy)NSString *fromUid;
@property(nonatomic, copy)NSString *icon;
@property(nonatomic, assign)CIMChatMessageType mtype;
@property(nonatomic, copy)NSString *nick;

@end

NS_ASSUME_NONNULL_END
