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

NSString * const service1UUID = @"FFF0";
NSString * const service2UUID = @"FFE0";

NSString* const WRITE_CHARACTERISTIC_UUID   = @"D44BC439-ABFD-45A2-B575-925416129600";
NSString* const NOTIFY_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129601";
NSString* const RESEND_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129610";

#pragma pack(1)
typedef struct Date {
    uint8_t second;
} Date;
#pragma pack()

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *peripheralList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
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
    [self.centralManager stopScan];
    [peripheral discoverServices:nil];
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接设备失败");
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
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
    if(data.length > 0) {
        const char *bytes = data.bytes;
        NSString *sec = [NSString stringWithCString:bytes encoding:NSUTF8StringEncoding];
        NSLog(@"sec = %@", sec);
    }
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
//    NSData *data = [@"hahaha" dataUsingEncoding:NSUTF8StringEncoding];
    Byte bytes[4] = {0x01, 0x02, 0x03, 0x04};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
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

@end
