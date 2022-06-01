//
//  ZYDeviceInfoModel.h
//  BlueTest
//
//  Created by yfm on 2021/2/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYDeviceInfoModel : NSObject
// 设备识别ID
@property (nonatomic, assign) NSInteger deviceId;
// 设备页可编程大小
@property (nonatomic, assign) NSInteger pageSize;
// 设备可编程页数
@property (nonatomic, assign) NSInteger pageNum;
// 设备BOOT版本
@property (nonatomic, assign) NSInteger bl_version;
// 设备结构版本
@property (nonatomic, assign) NSInteger mechanic;
// 设备硬件版本
@property (nonatomic, assign) NSInteger hw_version;
// 设备固件版本
@property (nonatomic, assign) NSInteger fw_version;
// 设备序列号
@property (nonatomic, assign) NSInteger sn;

@end

NS_ASSUME_NONNULL_END
