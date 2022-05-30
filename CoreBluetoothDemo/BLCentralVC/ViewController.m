//
//  ViewController.m
//  BLCentralVC
//
//  Created by yfm on 2022/5/30.
//
//  中心模式
/**
 1.启动中央管理器
 2.发现并连接正在广播的外围设备
 3.连接到外围设备后探索外围设备上的数据
 4.向外围服务的特征值发送读写请求
 5.订阅特征值以在更新时得到通知
 */

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString *const SERVICE_UUID = @"C477CBCA-BBA8-42EF-A5F9-782BF2E09822";
NSString *const WRITE_UUID = @"CDB49AF3-6B35-4102-AEE7-7398D1C46210";
NSString *const NOTIFY_UUID = @"CDB49AF3-6B35-4102-AEE7-7398D1C46211";

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic) CBCentralManager *centralManager;
@property (nonatomic) NSMutableArray<CBPeripheral *> *discoverPeripherals;
@property (nonatomic) CBPeripheral *connectedPeripheral;
@property (nonatomic) CBService *service;
@property (nonatomic) CBCharacteristic *writeCharacteristic;
@property (nonatomic) CBCharacteristic *notifyCharacteristic;

@property (nonatomic) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// 1.启动中央管理器
- (void)startUpCentralManager {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

// 2.发现并连接正在广播的外围设备
- (void)discoverDevice {
    [self.centralManager scanForPeripheralsWithServices:@[SERVICE_UUID] options:nil];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 3.连接到外围设备后探索外围设备上的数据
    if(peripheral.name.length > 0) {
        [self.discoverPeripherals addObject:peripheral];
        [self.tableView reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.connectedPeripheral = peripheral;
    self.connectedPeripheral.delegate = self;
    
    // 探索外围设备上的数据
    [self.connectedPeripheral discoverServices:@[SERVICE_UUID]];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for(CBService *service in peripheral.services) {
        if([service.UUID.UUIDString isEqualToString:SERVICE_UUID]) {
            self.service = service;
            
            [peripheral discoverCharacteristics:@[WRITE_UUID, NOTIFY_UUID] forService:self.service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for(CBCharacteristic *characteristic in service.characteristics) {
        if([characteristic.UUID.UUIDString isEqualToString:WRITE_UUID]) {
            self.writeCharacteristic = characteristic;
        } else if([characteristic.UUID.UUIDString isEqualToString:NOTIFY_UUID]) {
            self.notifyCharacteristic = characteristic;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

@end
