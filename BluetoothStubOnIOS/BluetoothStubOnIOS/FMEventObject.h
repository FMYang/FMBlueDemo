//
//  FMEventObject.h
//  BluetoothStubOnIOS
//
//  Created by yfm on 2022/4/21.
//  Copyright © 2022 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
