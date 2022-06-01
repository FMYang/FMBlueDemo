//
//  ZYDeviceInfoModel.m
//  BlueTest
//
//  Created by yfm on 2021/2/5.
//

#import "ZYDeviceInfoModel.h"

@implementation ZYDeviceInfoModel

- (NSString *)description {
    return [NSString stringWithFormat:@"设备识别ID = %ld, 设备页可编程大小 = %ld, 设备可编程页数 = %ld, 设备BOOT版本 = %ld, 设备结构版本 = %ld, 设备硬件版本 = %ld, 设备固件版本 = %ld, 设备序列号 = %ld", self.deviceId, (unsigned long)self.pageSize, (unsigned long)self.pageNum, self.bl_version, self.mechanic, self.hw_version, self.fw_version, self.sn];
}

@end
