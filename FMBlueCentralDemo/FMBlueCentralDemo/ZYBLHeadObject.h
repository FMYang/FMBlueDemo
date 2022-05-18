//
//  ZYBLHeadObject.h
//  FMBlueCentralDemo
//
//  Created by yfm on 2022/5/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZYBLCMD) {
    ZYBLCMD_SYNC       = 0x01, // 同步及获取设备信息
    ZYBLCMD_WRITE      = 0x02, // 向设备写入固件
    ZYBLCMD_CHECK      = 0x03, // 校验设备固件
    ZYBLCMD_BYPASS     = 0x04, // 旁路设备，使其向下转发所接收的命令(注：仅对1号设备有效)
    ZYBLCMD_RESET      = 0x05, // 重启设备
    ZYBLCMD_APPGO      = 0x06, // 运行设备
    ZYBLCMD_BOOT_RESET = 0x07, // 重启设备并进入升级模式
    ZYBLCMD_EVENT      = 0x08  // 其他控制指令
};

typedef NS_ENUM(NSUInteger, ZYBLCMDEvent) {
    ZYBLCMDEvent_USRBUS_EVENT           = 0x10, // USRBUS事件
    ZYBLCMDEvent_BLE_EVENT              = 0x11, // 蓝牙控制事件
    ZYBLCMDEvent_ASYN_EVENT             = 0x12, // 异步传输事件
    ZYBLCMDEvent_JOYSTICK_WHEEL_EVENT   = 0x13, // 摇杆/拨轮事件
    ZYBLCMDEvent_ANGLE_EVENT            = 0x14, // 角度/拨轮事件
    ZYBLCMDEvent_RDIS_EVENT             = 0x15, // RDIS控制数据事件
    ZYBLCMDEvent_HDL_EVENT_Handle       = 0x16, // 手柄事件
    ZYBLCMDEvent_WIFI_EVENT             = 0x17, // wifi控制事件
    ZYBLCMDEvent_OTHER_EVENT            = 0x18, // 其他事件
    ZYBLCMDEvent_CCS_EVENT              = 0x19, // 相机控制系统事件
    ZYBLCMDEvent_HDL_EVENT              = 0x1A, // 手柄事件
    ZYBLCMDEvent_ACC_EVENT              = 0x1B, // 配件事件
    ZYBLCMDEvent_STORY_EVENT            = 0x1C, // STORY事件
    ZYBLCMDEvent_MULTI_RDIS_EVENT       = 0x1D  // 扩展RDIS数据事件
};

// 包头
#pragma pack(push)
#pragma pack(1)
typedef struct {
    unsigned short head;     // 包头
    unsigned short length;   // 长度
    unsigned char cmd: 4;    // 命令（低4位）
    unsigned char addrs: 4;  // 设备地址（高4位）
    unsigned char cmd_event; // 当cmd为0x08的时候，为此刻为CMD_EVENT
} ZYBLHead;
#pragma pack(pop)

@interface ZYBLHeadObject : NSObject

@property (nonatomic) NSInteger head;
@property (nonatomic) NSInteger length;
@property (nonatomic) NSInteger cmd;
@property (nonatomic) NSInteger addrs;
@property (nonatomic) NSInteger cmd_event;

@end

NS_ASSUME_NONNULL_END
