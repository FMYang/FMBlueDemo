//
//  ViewController.m
//  BlueTest
//
//  Created by yfm on 2020/10/30.
//

/**
 步骤：
 1、初始化中央管理器对象
 2、扫描外围设备
 3、连接感兴趣的外围设备后读取数据
 4、停止扫描
 5、发送读写请求到外围设备的特征值
 6、订阅特征值，当特征值改变的时候收到通知
 */

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BlueListCell.h"
#import <Masonry/Masonry.h>
#import "ZYCrcCheck.h"
#import "ZYDeviceInfoModel.h"

NSString* const sendServiceUUID128          = @"0000FEE9-0000-1000-8000-00805F9B34FB";
NSString* const sendServiceUUID16           = @"FEE9";
NSString* const connectedUUID               = @"0000180A-0000-1000-8000-00805F9B34FB";
NSString* const WRITE_CHARACTERISTIC_UUID   = @"D44BC439-ABFD-45A2-B575-925416129600";
NSString* const NOTIFY_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129601";
NSString* const RESEND_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129610";

#pragma pack(1)
typedef struct DeviceInfo {
    UInt32 deviceId;
    UInt16 pagesize;
    UInt16 pagenum;
    UInt16 bl_version;
    UInt16 mechanic;
    UInt16 hw_version;
    UInt16 fw_version;
    UInt32 SN;
} DeviceInfo;
#pragma pack()

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate, UITableViewDelegate, UITableViewDataSource, BlueListCellDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripheralList;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *readBtn;
@property (nonatomic, strong) UIButton *refreshBtn;
@property (nonatomic, strong) UIButton *notifyBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self step];
}

- (void)step {
    // 1、创建中央设备管理器
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
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

#pragma mark - CBCentralManagerDelegate 中央管理代理
// 中央管理器状态更新
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState %ld", central.state);
    if(central.state == CBManagerStatePoweredOn) {
        // 2、扫描外设（前提是蓝牙是打开的）
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        
        CBUUID *uuid = [CBUUID UUIDWithString:sendServiceUUID16];//智云设备的服务id
        CBUUID *uuid1 = [CBUUID UUIDWithString:sendServiceUUID128];
        NSArray<CBPeripheral *> *array = [self.centralManager retrieveConnectedPeripheralsWithServices:@[uuid,uuid1]];
        self.peripheralList = [array mutableCopy];
        [self.tableView reloadData];
    }
}

// 中央管理器每次发现外围设备，都会调用这个代理方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"发现外设: %@", peripheral.name);

    if(peripheral.name.length > 0) {
        if(![self existPeripheral:peripheral]) {
            [self.peripheralList addObject:peripheral];
            [self.tableView reloadData];
        }
    }
}

// 外设已连接
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"连接外设成功 %@", peripheral);
    [peripheral readRSSI];
    
    // 4、停止扫描
    [self.centralManager stopScan];
    
    // 5、发现感兴趣的服务，下一步就是发现服务的特征
    [peripheral discoverServices:nil];
    
    [self.tableView reloadData];
}

// 连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接外设失败 %@", error);
    [self.tableView reloadData];
}

// 断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开连接 %@", error);
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
        // WRITE_CHARACTERISTIC_UUID
        if([characteristic.UUID.UUIDString isEqualToString:WRITE_CHARACTERISTIC_UUID]) {
            self.characteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
//        if([characteristic.UUID.UUIDString isEqualToString:NOTIFY_CHARACTERISTIC_UUID]) {
//            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
//        }
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
    // 配件值更新
//    if([characteristic.UUID.UUIDString isEqualToString:WRITE_CHARACTERISTIC_UUID]) {
        
    if(characteristic.value.length == 28) {
        NSData *rcvData = characteristic.value;
        NSLog(@"yfm - %@", rcvData);
        const void *bytes = rcvData.bytes; // receiveData
        
        // infoData
        Byte *infoBytes = malloc(20);
        memset(infoBytes, 0, 20);
        memcpy(infoBytes, bytes + 6, 20);
        NSData *infoData = [NSData dataWithBytes:infoBytes length:20]; // infoData
        NSLog(@"infoData = %@", infoData);
        
//        DeviceInfo *info = malloc(sizeof(DeviceInfo));
//        info = (DeviceInfo *)infoBytes;
//        NSInteger _device_id = info->deviceId;
//        NSInteger _page_size = info->pagesize;
//        NSInteger _page_nums = info->pagenum;
//        NSInteger _bl_version = info->bl_version;
//        NSInteger _mechanic = info->mechanic;
//        NSInteger _hw_version = info->hw_version;
//        NSInteger _fw_version = info->fw_version;
//        NSInteger _sn = info->SN;
//        NSLog(@"%ld, %ld, %ld, %ld, %ld, %ld, %ld, %ld", (long)_device_id, (long)_page_size, _page_nums, _bl_version, _mechanic, _hw_version, _fw_version, _sn);
        
        Byte *deviceIdBytes = malloc(4);
        memset(deviceIdBytes, 0, 4);
        memcpy(deviceIdBytes, infoBytes, 4);
        UInt32 deviceId = 0;
        memcpy(&deviceId, deviceIdBytes, 4);
//        deviceId = ntohl(deviceId); // 大端转小端
        NSLog(@"deviceId = %u", deviceId);

        Byte *pageSizeBytes = malloc(2);
        memset(pageSizeBytes, 0, 2);
        memcpy(pageSizeBytes, infoBytes + 4, 2);
        UInt16 pageSize = 0;
        memcpy(&pageSize, pageSizeBytes, 2);
//        pageSize = ntohs(pageSize); // 大端转小端
        NSLog(@"pageSize = %hu", pageSize);
        
        Byte *pageNumBytes = malloc(2);
        memset(pageNumBytes, 0, 2);
        memcpy(pageNumBytes, infoBytes + 6, 2);
        UInt16 pageNum = 0;
        memcpy(&pageNum, pageNumBytes, 2);
//        pageNum = ntohs(pageNum); // 大端转小端
        NSLog(@"pageNum = %hu", pageNum);

        Byte *blVersionBytes = malloc(2);
        memset(blVersionBytes, 0, 2);
        memcpy(blVersionBytes, infoBytes + 8, 2);
        UInt16 blVersion = 0;
        memcpy(&blVersion, blVersionBytes, 2);
//        blVersion = ntohs(blVersion); // 大端转小端
        NSLog(@"blVersion = %hu", blVersion);
        
        Byte *mecBytes = malloc(2);
        memset(mecBytes, 0, 2);
        memcpy(mecBytes, infoBytes + 10, 2);
        UInt16 mec = 0;
        memcpy(&mec, mecBytes, 2);
//        mec = ntohs(mec); // 大端转小端
        NSLog(@"Mechanic = %hu", mec);

        Byte *hwVersionBytes = malloc(2);
        memset(hwVersionBytes, 0, 2);
        memcpy(hwVersionBytes, infoBytes + 12, 2);
        UInt16 hwVersion = 0;
        memcpy(&hwVersion, hwVersionBytes, 2);
//        hwVersion = ntohs(hwVersion); // 大端转小端
        NSLog(@"HW_Version = %hu", hwVersion);

        Byte *fwVersionBytes = malloc(2);
        memset(fwVersionBytes, 0, 2);
        memcpy(fwVersionBytes, infoBytes + 14, 2);
        UInt16 fwVersion = 0;
        memcpy(&fwVersion, fwVersionBytes, 2);
//        fwVersion = ntohs(fwVersion); // 大端转小端
        NSLog(@"FW_Version = %hu", fwVersion);
        
        Byte *snBytes = malloc(4);
        memset(snBytes, 0, 4);
        memcpy(snBytes, infoBytes + 16, 4);
        UInt32 sn = 0;
        memcpy(&sn, snBytes, 4);
//        sn = ntohs(sn); // 大端转小端
        NSLog(@"SN = %u", sn);
        
        
        free(infoBytes);
        free(deviceIdBytes);
        free(pageSizeBytes);
        free(pageNumBytes);
        free(blVersionBytes);
        free(mecBytes);
        
        ZYDeviceInfoModel *model = [[ZYDeviceInfoModel alloc] init];
        model.deviceId = deviceId;
        model.pageSize = pageSize;
        model.pageNum = pageNum;
        model.bl_version = blVersion;
        model.mechanic = mec;
        model.fw_version = fwVersion;
        model.hw_version = hwVersion;
        model.sn = sn;
        NSLog(@"%@", model.description);
        // 设备信息
        
        /**
         2021-02-07 11:05:58.957539+0800 BlueDemo[12684:1943706] 收到:status = 0 device_id = 4998216 page_size = 256 page_num = 2816 bl_version = 3 mechanic = 1792 hw_version = 1856 fw_version = 186 sn = 4294967293 ZYBLStatueCMD_SYNCData
         */
    }
//    }
    
    // 读特征值
//    [self.peripheral readValueForCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    
}

#pragma mark - actions
- (void)didClickConnect:(NSIndexPath *)indexPath {
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

- (void)readDeviceId {
//    NSData *data = [self convertHexStrToData:@"243c0800181267017c000000b944"];
    Byte bytes[6];
    bytes[0] = 0x24;
    bytes[1] = 0x3c; // head
    bytes[2] = 0x02;
    bytes[3] = 0x00; // length
    bytes[4] = 0x11; // addrs | CMD_SYNC
    bytes[5] = 0x00; // status
    NSMutableData *data = [[NSData dataWithBytes:bytes length:6] mutableCopy];
    
    // crc校验
    Byte crcBytess[2];
    crcBytess[0] = 0x11;
    crcBytess[1] = 0x00;
    NSData *crcByteData = [NSData dataWithBytes:crcBytess length:2];
    NSInteger crc = [ZYCrcCheck calculate:crcByteData];
    NSData *crcData = [NSData dataWithBytes:&crc length:2];
    [data appendData:crcData];
    
    if(self.characteristic) {
        // 0x243c020011004230
        [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
//        [self.peripheral readValueForCharacteristic:self.characteristic];
        NSLog(@"写数据 %@ %@", data, self.characteristic);
    } else {
        NSLog(@"未发现特征");
    }
    
    // 2021-01-31 18:10:29.402035+0800 BlueTest[13910:8593257] didWriteValueForCharacteristic <CBCharacteristic: 0x28005bd80, UUID = D44BC439-ABFD-45A2-B575-925416129600, properties = 0x86, value = (null), notifying = NO> (null) error = Error Domain=CBATTErrorDomain Code=3 "Writing is not permitted." UserInfo={NSLocalizedDescription=Writing is not permitted.}
}

- (void)refreshAction {
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)notifyAction {
    [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlueListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.delegate = self;
    CBPeripheral *peripheral = self.peripheralList[indexPath.row];
    [cell configCell:peripheral];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - UI
- (void)setupUI {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.readBtn];
    [self.view addSubview:self.refreshBtn];
    [self.view addSubview:self.notifyBtn];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.safeAreaInsets.top);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(400);
    }];
    
    [self.readBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.tableView.mas_bottom).offset(10);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(44);
    }];
    
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.readBtn.mas_right).offset(20);
        make.centerY.equalTo(self.readBtn);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(44);
    }];
    
    [self.notifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.refreshBtn.mas_right).offset(20);
        make.centerY.equalTo(self.readBtn);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(44);
    }];
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:BlueListCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSMutableArray<CBPeripheral *> *)peripheralList {
    if(!_peripheralList) {
        _peripheralList = @[].mutableCopy;
    }
    return _peripheralList;
}

- (UIButton *)readBtn {
    if(!_readBtn) {
        _readBtn = [[UIButton alloc] init];
        [_readBtn setTitle:@"设备信息" forState:UIControlStateNormal];
        [_readBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_readBtn addTarget:self action:@selector(readDeviceId) forControlEvents:UIControlEventTouchUpInside];
    }
    return _readBtn;
}

- (UIButton *)refreshBtn {
    if(!_refreshBtn) {
        _refreshBtn = [[UIButton alloc] init];
        [_refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

- (UIButton *)notifyBtn {
    if(!_notifyBtn) {
        _notifyBtn = [[UIButton alloc] init];
        [_notifyBtn setTitle:@"Notify" forState:UIControlStateNormal];
        [_notifyBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_notifyBtn addTarget:self action:@selector(notifyAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _notifyBtn;
}

@end
