//
//  FMEventObject.h
//  BluetoothStubOnIOS
//
//  Created by yfm on 2022/4/21.
//  Copyright © 2022 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 0x243e0b0018181a0800110005020100e235 录像/停止
 0x243e0b0018181ae9041100040201007ab5 前后置切换
 0x243e0b0018181af5041100120205008369 打开/关闭分辨率
 0x243e0b0018181afd041100070202002c49 打开/关闭相册
 0x243e0b0018181a060511001802000044c3 右转
 0x243e0b0018181a07051100170200007950 左转
 0x243e0b0018181a480511000f0200000fe1 OK
 0x243e05001818100457a63d back
 */
typedef NS_ENUM(NSUInteger, EventType) {
    EventTypeRecord,
    EventTypeSwitchPosition,
    EventTypeMenu,
    EventTypeAlbum,
    EventTypeRight,
    EventTypeLeft,
    EventTypeOK,
    EventTypeBack
};

@interface FMEventObject : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) EventType eventType;
@property (nonatomic) NSString *eventDataHexStr;

+ (NSArray<FMEventObject *> *)allObjects;

@end

NS_ASSUME_NONNULL_END
