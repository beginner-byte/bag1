//
//  NoaMediaCallOptions.m
//  NoaKit
//
//  Created by Candy on 2023/1/6.
//

#import "NoaMediaCallOptions.h"

@implementation NoaMediaCallOptions

#pragma mark - 房间信息
- (NSString *)callRoomUrl {
    if (self.callRoomType == ZIMCallRoomTypeSingle) {
        //单人
        return self.callMediaModel.connection.endpoint;
    }else if (self.callRoomType == ZIMCallRoomTypeGroup) {
        //多人
        return self.callMediaGroupModel.connection.endpoint;
    }else if (self.callRoomType == ZIMCallRoomTypeMeeting) {
        //会议
        return nil;
    }else {
        return nil;
    }
}

- (NSString *)callRoomToken {
    if (self.callRoomType == ZIMCallRoomTypeSingle) {
        //单人
        return self.callMediaModel.connection.token;
    }else if (self.callRoomType == ZIMCallRoomTypeGroup) {
        //多人
        return self.callMediaGroupModel.connection.token;
    }else if (self.callRoomType == ZIMCallRoomTypeMeeting) {
        //会议
        return nil;
    }else {
        return nil;
    }
}

- (NSString *)callRoomId {
    if (self.callRoomType == ZIMCallRoomTypeSingle) {
        //单人
        return self.callMediaModel.connection.room;
    }else if (self.callRoomType == ZIMCallRoomTypeGroup) {
        //多人
        return self.callMediaGroupModel.connection.room;
    }else if (self.callRoomType == ZIMCallRoomTypeMeeting) {
        //会议
        return nil;
    }else {
        return nil;
    }
}

- (NSInteger)callMode {
    if (self.callRoomType == ZIMCallRoomTypeSingle) {
        //单人
        return self.callMediaModel.mode;
    }else if (self.callRoomType == ZIMCallRoomTypeGroup) {
        //多人
        return self.callMediaGroupModel.mode;
    }else if (self.callRoomType == ZIMCallRoomTypeMeeting) {
        //会议
        return 2;
    }else {
        return 2;
    }
}

- (NSString *)callState {
    if (self.callRoomType == ZIMCallRoomTypeSingle) {
        //单人
        return self.callMediaModel.state;
    }else if (self.callRoomType == ZIMCallRoomTypeGroup) {
        //多人
        return self.callMediaGroupModel.action;
    }else if (self.callRoomType == ZIMCallRoomTypeMeeting) {
        //会议
        return nil;
    }else {
        return nil;
    }
}

- (NSString *)callHashKey {
    if (self.callRoomType == ZIMCallRoomTypeSingle) {
        //单人
        return self.callMediaModel.hashKey;
    }else if (self.callRoomType == ZIMCallRoomTypeGroup) {
        //多人
        return self.callMediaGroupModel.hashKey;
    }else if (self.callRoomType == ZIMCallRoomTypeMeeting) {
        //会议
        return nil;
    }else {
        return nil;
    }
}

- (NSString *)callFrom {
    if (self.callRoomType == ZIMCallRoomTypeSingle) {
        //单人
        return self.callMediaModel.from_id;
    }else if (self.callRoomType == ZIMCallRoomTypeGroup) {
        //多人
        if ([self.callMediaGroupModel.action isEqualToString:@"request"]) {
            return self.callMediaGroupModel.args.firstObject;
        }
        return nil;
    }else if (self.callRoomType == ZIMCallRoomTypeMeeting) {
        //会议
        return nil;
    }else {
        return nil;
    }
}

- (NSString *)callTo {
    if (self.callRoomType == ZIMCallRoomTypeSingle) {
        //单人
        return self.callMediaModel.to_id;
    }else if (self.callRoomType == ZIMCallRoomTypeGroup) {
        //多人
        return self.callMediaGroupModel.chat_id;
    }else if (self.callRoomType == ZIMCallRoomTypeMeeting) {
        //会议
        return nil;
    }else {
        return nil;
    }
}

- (NSString *)callDiscardReason {
    if (self.callRoomType == ZIMCallRoomTypeSingle) {
        //单人
        return self.callMediaModel.discard_reason;
    }else if (self.callRoomType == ZIMCallRoomTypeGroup) {
        //多人
        return self.callMediaGroupModel.reason;
    }else if (self.callRoomType == ZIMCallRoomTypeMeeting) {
        //会议
        return nil;
    }else {
        return nil;
    }
}

@end
