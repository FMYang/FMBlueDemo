//
//  ZYBLOtherEventObject.h
//  FMBlueCentralDemo
//
//  Created by yfm on 2022/5/18.
//

#import "ZYBLHeadObject.h"

NS_ASSUME_NONNULL_BEGIN

#pragma pack(push)
#pragma pack(1)
typedef struct {
    UInt16 pack_id;
    UInt8 cmd;
    UInt8 flag;
    UInt16 data;
} ZYBLCMDFuncEvent;
#pragma pack(pop)


typedef NS_ENUM(NSUInteger, ZYBLOhterEvent) {
    ZYBLOhterEvent_CMD_CHECKMD5               = 0x01,    // MD5值校验
    ZYBLOhterEvent_CMD_FILE_ASYN              = 0x02,    // 是否开机异步传输
    ZYBLOhterEvent_CMD_UPDATA_STATE           = 0x03,    // 图传板的升级状态
    ZYBLOhterEvent_CMD_DEVICE_INFO            = 0x04,    // 检查当前设备能否控制图传设备
    ZYBLOhterEvent_CMD_SYSTEM_TIME            = 0x05,    // 同步手机，稳定器系统时间
    ZYBLOhterEvent_CMD_JSON_FILE              = 0x06,    // 传输文件
    ZYBLOhterEvent_CMD_SYNC_DATA              = 0x07,    // 同步数据
    ZYBLOhterEvent_CMD_PATH_DATA              = 0x08,    // 查询轨迹拍摄信息
    ZYBLOhterEvent_CMD_DEVICE_TYPE            = 0x09,    // 稳定器搭载的设备类型
    ZYBLOhterEvent_CMD_MVOELINE_STATUS        = 0x0a,   // 移动延时摄影状态指示 1：结束 2：暂停 3：开始 4.移动中
    ZYBLOhterEvent_CMD_OTA_WAIT               = 0x0b,    // 传输数据包完成之后是否需要等待设备进度，等待设备烧录固件完毕之后再进行下一步操作。烧录进度使用HDL_CMD_SHOW_INFO命令
    ZYBLOhterEvent_BLE_CMD_HEART              = 0x10,    // 蓝牙HID设备连接心跳指令(支持蓝牙hid的设备使用)
    ZYBLOhterEvent_CMD_KEYFUNC_DEFINE_SET     = 0x11,    // 重新定义按键映射功能
    ZYBLOhterEvent_CMD_KEYFUNC_DEFINE_READ    = 0x12,   //  重新定义按键映射功能
    ZYBLOhterEvent_CMD_CHECK_ACTIVEINFO       = 0x13,    // 查询激活状态信息
    ZYBLOhterEvent_CMD_SET_ACTIVEINFO         = 0x14,    // 发送激活密钥
    ZYBLOhterEvent_CMD_LOG_READ               = 0x15,    // 读LOG数据
    ZYBLOhterEvent_CMD_TRACKING_MODE          = 0x16,   // 设置自动跟踪模式
    ZYBLOhterEvent_CMD_TRACKING_ANCHOR        = 0x17,  // 设置跟踪时的锚点
    ZYBLOhterEvent_CMD_DATA_TEST              = 0x18,    // 用于测试吞吐性能
    ZYBLOhterEvent_CMD_TIMELAPSE              = 0x19,    // 配置延时摄影参数
    ZYBLOhterEvent_CMD_TRACKING_SELECT        = 0x20,    // 选择、返回跟踪目标坐标
    ZYBLOhterEvent_CMD_TRANSFER_INFO          = 0x21,    // 手柄获取图传相关信息
    ZYBLOhterEvent_CMD_FUNC_EVENT             = 0x1A,    // 执行功能事件
    ZYBLOhterEvent_CMD_BALANCE_CHECK          = 0x1B,    // 查询平衡度信息
};

@interface ZYBLOtherEventObject : ZYBLHeadObject

@property (nonatomic) ZYBLOhterEvent cmdEvent;

@end

NS_ASSUME_NONNULL_END
