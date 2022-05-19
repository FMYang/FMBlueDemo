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
    UInt8 otherEvent;
    UInt16 pack_id;
    UInt8 cmd;
    UInt8 flag;
    UInt16 data;
    UInt16 param;
} ZYBLCMDFuncEvent;
#pragma pack(pop)

//typedef struct {
//    UInt16 data;
//    UInt16 param;
//} ZYBLFuncRequest;


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

typedef NS_ENUM(NSUInteger, BLFuncEventData) {
    BLFuncEventData_KEY_TAKE_PHOTO    = 0x0100, //   -    设备拍照
    BLFuncEventData_KEY_CAPTURE_VIDEO  = 0x0101, //   -    设备录像
    BLFuncEventData_KEY_ZOOM_IN    = 0x0200,   // 0:结束变焦 1:开始变焦 2:焦距增大固定值    变焦+
    BLFuncEventData_KEY_ZOOM_OUT   = 0x0201,   // 0:结束变焦 1:开始变焦 2:焦距减少固定值    变焦-
    BLFuncEventData_KEY_FOCUS_MAX   = 0x0202,    // 0:结束手动对焦 1:开始手动对焦 2:自动对焦 3:对焦值增加 对焦+
    BLFuncEventData_KEY_FOCUS_MIN    = 0x0203,   // 0:结束手动对焦 1:开始手动对焦 2:自动对焦 3:对焦值减少 对焦-
    BLFuncEventData_KEY_SELECT_LENS    = 0x0204,   // 0:切换至上一个可用摄像头 1:切换至下一个可用摄像头 2:切换至可用前置摄像头 3:切换至可用后置摄像头    切换摄像头
    BLFuncEventData_KEY_SHOT    = 0x0205,    // 0:录制开始/结束循环 1:拍照    拍摄
    BLFuncEventData_KEY_SMART    = 0x0206,   // 0:退出 1:呼出 2:开/关    SMART菜单
    BLFuncEventData_KEY_ALBUM    = 0x0207,   // 0:退出 1:呼出 2:开/关    相册
    BLFuncEventData_KEY_SCENE    = 0x0208,    // 0:上一模式 1:下一模式 2:拍照 3:录像 4:全景 5:慢动作 6:希区柯克 7:延时摄影 8:AI Live    拍摄模式
    BLFuncEventData_KEY_SHORTCUT_MENU   = 0x0209,   // 0:退出 1:呼出 2:开/关    快捷菜单
    BLFuncEventData_KEY_MENUITEM_UP    = 0x020A,    // 上一选项
    BLFuncEventData_KEY_MENUITEM_DOWN    = 0x020B,    // 下一选项
    BLFuncEventData_KEY_MENUITEM_LEFT    = 0x020C,    // 上一选项
    BLFuncEventData_KEY_MENUITEM_RIGHT    = 0x020D,    // 下一选项
    BLFuncEventData_KEY_TRACKING    = 0x020E,    // 0:退出 1:呼出 2:开/关    智能跟踪
    BLFuncEventData_KEY_CONFIRM    = 0x020F,    // 确认
    BLFuncEventData_KEY_CLEAR    = 0x0210,    // 0:默认状态 1:保留预览页面 2:保留预览页面+安全线 3:保留预览页面+图像分析 4:保留预览页面+安全线+图像分析 16:上一状态 17:下一状态    确认
    BLFuncEventData_KEY_ANALYSIS   = 0x0211,    // 0:退出 1:呼出 2:开/关    图像分析
    BLFuncEventData_KEY_CAP_PARAMS   = 0x0212,   // 0:上一参数 1:下一参数 2:iso 3:快门 4:白平衡 5:视频设置 拍摄参数
    BLFuncEventData_KEY_CONTINUOUS_ZOOM   = 0x0213,   // 虚拟位置(0-65535, 其中0继续减少1个单位等于65535)    连续变焦,需要定频率发送。按50hz发送,每收到一条指令将在20ms内完成变焦,变焦值的变动为与前一指令虚拟位置的差值, 如整个变焦过程仅发送一条指令则变焦值无变化
    BLFuncEventData_KEY_CONTINUOUS_FOCUS   = 0x0214,  // 连续对焦,使用方式同连续变焦
    BLFuncEventData_KEY_RETURN    = 0x0215,   // 0:返回至ROOT 1:返回至上一级菜单    返回上一级菜单
    BLFuncEventData_KEY_CUSTOM_EVENT   = 0x0216,   // 定义参考2.8.8.13中映射表 0xB0后的值执行自定义菜单中的预设功能
    BLFuncEventData_KEY_MENUITEM_PREVIOUS   = 0x0217, // 上一选项
    BLFuncEventData_KEY_MENUITEM_NEXT    = 0x0218,    // 下一选项
    BLFuncEventData_KEY_CAPTURE_MODE    = 0x0219,   // 0:设置快门，ISO 自动 1:设置快门，ISO 手动 2:设置快门，ISO 自动手动切换 3:设置白平衡参数模式自动 4:设置白平衡参数模式手动 5:设置白平衡参数模式自动手动切换 6:设置所有参数模式自动(快门，ISO ，WB) 7:设置所有参数模式手动(快门，ISO ，WB) 8:设置所有参数模式自动手动切换(快门，ISO ，WB)    设置参数模式
    BLFuncEventData_KEY_AUTOFOCUS    = 0x0220,  // 设置成自动对焦
    BLFuncEventData_KEY_CAP_PARAMS_SET   = 0x0221,   // 0:设置激活参数上一档 1:设置激活参数下一档 2:设置ISO上一档 3:设置ISO下一档 4:设置快门上一档 5:设置快门下一档 6:设置白平衡上一档 7:设置白平衡下一档    设置拍摄参数*/
};

@interface ZYBLOtherEventObject : ZYBLHeadObject

@property (nonatomic) ZYBLOhterEvent otherEvent;
@property (nonatomic) NSInteger packId;
@property (nonatomic) NSInteger func_cmd;
@property (nonatomic) NSInteger flag;
@property (nonatomic) BLFuncEventData data;
@property (nonatomic) BLFuncEventData param;

@end

NS_ASSUME_NONNULL_END
