//
//  ViewController.m
//  FMBlueCentralDemo
//
//  Created by yfm on 2021/10/29.
//  蓝牙客户端（central中心模式）

#import "ViewController.h"
#import "FMListCell.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <Masonry/Masonry.h>
#import "math.h"
#import "ZYBLOtherEventObject.h"
#import "FMLogVC.h"

//NSString* const sendServiceUUID16           = @"FEE9";
NSString * const service1UUID = @"FEE9";
NSString * const service2UUID = @"0000FEE9-0000-1000-8000-00805F9B34FB";

NSString* const WRITE_CHARACTERISTIC_UUID   = @"D44BC439-ABFD-45A2-B575-925416129600";
NSString* const NOTIFY_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129601";
NSString* const RESEND_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129610";

#pragma pack(push)
#pragma pack(1)
typedef struct Date {
    uint8_t second;
} Date;
#pragma pack(pop)

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripheralList;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, strong) CBCharacteristic *notiCharacteristic;
@property (nonatomic, strong) CBCharacteristic *resendCharacteristic;

@property (nonatomic) NSMutableArray *logs;
@property (nonatomic) FMLogVC *logVC;
// 过滤心跳
@property (nonatomic) BOOL filter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    _logs = @[].mutableCopy;
    _filter = YES;
}

- (BOOL)existPeripheral:(CBPeripheral *)peripheral {
    BOOL exist = NO;
    for(CBPeripheral *p in self.peripheralList) {
        if([p.name isEqualToString:peripheral.name]) {
            exist = YES;
        }
    }
    
    return exist;
}

#pragma mark - 中央管理代理
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if(central.state == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        
        CBUUID *uuid1 = [CBUUID UUIDWithString:service1UUID];
        CBUUID *uuid2 = [CBUUID UUIDWithString:service2UUID];
        NSArray<CBPeripheral *> *array = [self.centralManager retrieveConnectedPeripheralsWithServices:@[uuid1,uuid2]];
        self.peripheralList = [array mutableCopy];
        [self.tableView reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if(peripheral.name.length > 0) {
        NSLog(@"%@ %@", peripheral.name, advertisementData);
        if(![self existPeripheral:peripheral]) {
            [self.peripheralList addObject:peripheral];
            [self.tableView reloadData];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 连接成功
    NSLog(@"fm 连接成功");
    [self.centralManager stopScan];
    [peripheral discoverServices:nil];
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"fm 连接设备失败");
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"fm 断开连接");
    [self.tableView reloadData];
}

#pragma mark - CBPeripheralDelegate 配件代理
// 发现服务了
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for(CBService *service in peripheral.services) {
        NSLog(@"发现服务 %@", service);
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}

// 发现特征了
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for(CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"发现特征 %@", characteristic);
        // 6、发现特征了
        if([characteristic.UUID.UUIDString isEqualToString:WRITE_CHARACTERISTIC_UUID]) {
            self.writeCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else if([characteristic.UUID.UUIDString isEqualToString:NOTIFY_CHARACTERISTIC_UUID]) {
            self.notiCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:RESEND_CHARACTERISTIC_UUID]) {
            self.resendCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        // 订阅通知
        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        [self.peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic characteristic = %@ error = %@", characteristic, error);
}

// 读信号强度
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"RSSI = %@", RSSI);
}

// 更新了配件的特征值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSData *data = characteristic.value;
    NSString *cmdStr = [self convertDataToHexStr:data];
    if(data.length > 7) {
        if(self.filter) {
            if(data.length != 18 && data.length != 11) {
                [self.logs insertObject:cmdStr atIndex:0];
            }
        } else {
            [self.logs insertObject:cmdStr atIndex:0];
        }
    }
    self.logVC.datasource = self.logs;
    if(data.length > 7 && data.length != 18) {
        [self parseData:data];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 发送心跳查询设备状态
    [self sendHeart];
}

- (void)sendHeart {
    /**<243c0400 18181000 d577>*/
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    Byte bytes[14] = {0x24, 0x3c, 0x04, 0x00, 0x18, 0x18, 0x10, 0x00, 0xd5, 0x77};
//    NSData *data = [NSData dataWithBytes:bytes length:10];
    NSData *data = [self convertHexStrToData:@"243c040018181000d577"];
    [self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
    [self performSelector:@selector(sendHeart) withObject:nil afterDelay:0.6];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    CBPeripheral *peripheral = self.peripheralList[indexPath.row];
    [cell configCell:peripheral];
    __weak ViewController *weakSelf = self;
    cell.connectBlock = ^(NSIndexPath * _Nonnull aIndexPath) {
        [weakSelf connect:aIndexPath];
    };
    return cell;
}

- (void)connect:(NSIndexPath *)indexPath {
    self.peripheral = self.peripheralList[indexPath.row];
    self.peripheral.delegate = self;

    if(self.peripheral.state == CBPeripheralStateConnected) {
        // 3、断开连接外设
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    } else {
        // 3、连接外设
        [self.centralManager connectPeripheral:self.peripheral options:nil];
    }
}

#pragma mark -
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    Byte bytes[4] = {0x01, 0x02, 0x03, 0x04};
//    NSData *data = [NSData dataWithBytes:bytes length:4];
//    [self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    
    _logVC = [[FMLogVC alloc] init];
    [self presentViewController:_logVC animated:YES completion:nil];
}

#pragma mark -
- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:FMListCell.class forCellReuseIdentifier:@"listCell"];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.height.mas_equalTo(0.5 * kScreenHeight);
        }];
    }
    return _tableView;
}

- (NSMutableArray<CBPeripheral *> *)peripheralList {
    if(!_peripheralList) {
        _peripheralList = @[].mutableCopy;
    }
    return _peripheralList;
}

#pragma mark - 数据解析
- (void)parseData:(NSData *)data {
    ZYBLHead *head = (ZYBLHead *)data.bytes;
    
    ZYBLHeadObject *object = [[ZYBLHeadObject alloc] init];
    object.head = head->head;
    object.length = head->length;
    object.cmd = head->cmd;
    object.addrs = head->addrs;
    object.cmd_event = head->cmd_event;
    
    if(object.cmd == ZYBLCMD_EVENT) {
        if(object.cmd_event == ZYBLCMDEvent_OTHER_EVENT) {
            // 其他事件指令
            NSData *subData = [data subdataWithRange:NSMakeRange(sizeof(ZYBLHead), object.length - 2)];
            Byte *bytes = (Byte *)subData.bytes;
            if(bytes[0] == ZYBLOhterEvent_CMD_FUNC_EVENT) {
                ZYBLCMDFuncEvent *event = (ZYBLCMDFuncEvent *)bytes;
                ZYBLOtherEventObject *funcObject = [[ZYBLOtherEventObject alloc] init];
                funcObject.otherEvent = event->otherEvent;
                funcObject.packId = event->pack_id;
                funcObject.func_cmd = event->cmd;
                funcObject.flag = event->flag;
                funcObject.data = event->data;
                funcObject.param = event->param;
                
                switch (funcObject.data) {
                    case BLFuncEventData_KEY_SHOT:
                        if(funcObject.param == 0) {
                            NSLog(@"录像");
                        } else if(funcObject.param == 1) {
                            NSLog(@"拍照");
                        }
                        break;

                    case BLFuncEventData_KEY_SELECT_LENS:
                        NSLog(@"切换摄像头");
                        break;

                    case BLFuncEventData_KEY_CAP_PARAMS:
                        // 0:设置激活参数上一档 1:设置激活参数下一档 2:设置ISO上一档 3:设置ISO下一档 4:设置快门上一档 5:设置快门下一档 6:设置白平衡上一档 7:设置白平衡下一档    设置拍摄参数
                        if(funcObject.param == 0) {
                            NSLog(@"设置激活参数上一档");
                        } else if(funcObject.param == 1) {
                            NSLog(@"设置激活参数下一档");
                        } else if(funcObject.param == 2) {
                            NSLog(@"设置ISO上一档");
                        } else if(funcObject.param == 3) {
                            NSLog(@"设置ISO下一档");
                        } else if(funcObject.param == 4) {
                            NSLog(@"设置快门上一档");
                        } else if(funcObject.param == 5) {
                            NSLog(@"设置快门下一档");
                        } else if(funcObject.param == 6) {
                            NSLog(@"设置白平衡上一档");
                        } else if(funcObject.param == 7) {
                            NSLog(@"设置白平衡下一档");
                        } else {
                            NSLog(@"设置拍摄参数");
                        }
                        break;

                    case BLFuncEventData_KEY_ALBUM:
                        NSLog(@"相册");
                        break;

                    case BLFuncEventData_KEY_MENUITEM_NEXT:
                        NSLog(@"下一选项");
                        break;

                    case BLFuncEventData_KEY_MENUITEM_PREVIOUS:
                        NSLog(@"上一选项");
                        break;

                    case BLFuncEventData_KEY_CONFIRM:
                        NSLog(@"OK");
                        break;

                    case BLFuncEventData_KEY_SMART:
                        if(funcObject.param == 0) {
                            NSLog(@"退出");
                        } else if(funcObject.param == 1) {
                            NSLog(@"呼出");
                        } else if(funcObject.param == 2) {
                            NSLog(@"开/关 SMART菜单");
                        }
                        break;

                    default:
                        break;
                }
            }
        }
    }
}

#pragma mark - tools
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

@end
