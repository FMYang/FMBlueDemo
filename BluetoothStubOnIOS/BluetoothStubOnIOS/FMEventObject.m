//
//  FMEventObject.m
//  BluetoothStubOnIOS
//
//  Created by yfm on 2022/4/21.
//  Copyright © 2022 刘彦玮. All rights reserved.
//

#import "FMEventObject.h"

@implementation FMEventObject

+ (NSArray<FMEventObject *> *)allObjects {
    NSArray *arr = @[@(EventTypeRecord),
                     @(EventTypeSwitchPosition),
                     @(EventTypeMenu),
                     @(EventTypeAlbum),
                     @(EventTypeRight),
                     @(EventTypeLeft),
                     @(EventTypeOK),
                     @(EventTypeBack)
    ];
    NSArray *titles = @[@"录像",
                        @"切换前后置",
                        @"分辨率菜单",
                        @"相册",
                        @"右",
                        @"左",
                        @"OK",
                        @"Back"];
    NSArray *commands = @[@"243e0b0018181a0800110005020100e235",
                          @"243e0b0018181ae9041100040201007ab5",
                          @"243e0b0018181af5041100120205008369",
                          @"243e0b0018181afd041100070202002c49",
                          @"243e0b0018181a060511001802000044c3",
                          @"243e0b0018181a07051100170200007950",
                          @"243e0b0018181a480511000f0200000fe1",
                          @"243e0f0018181a0e00110006020100150201000567"];
    NSMutableArray *result = @[].mutableCopy;
    for(int i = 0; i<arr.count; i++) {
        NSNumber *num = arr[i];
        FMEventObject *obj = [[FMEventObject alloc] init];
        obj.eventType = [num integerValue];
        obj.title = titles[i];
        obj.eventDataHexStr = commands[i];
        [result addObject:obj];
    }
    return result;
}

/** smoothx
 243c08001812071620c03f007a71 录像/停止
 */

/** smooth5
 0x243e0b0018181a0800110005020100e235 录像/停止
 0x243e0b0018181ae9041100040201007ab5 前后置切换
 0x243e0b0018181af5041100120205008369 打开/关闭分辨率
 0x243e0b0018181afd041100070202002c49 打开/关闭相册
 0x243e0b0018181a060511001802000044c3 右转
 0x243e0b0018181a07051100170200007950 左转
 0x243e0b0018181a480511000f0200000fe1 OK
 0x243e0f0018181a0e00110006020100150201000567 back
 */

@end
