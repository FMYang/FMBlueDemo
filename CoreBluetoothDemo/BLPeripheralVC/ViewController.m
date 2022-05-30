//
//  ViewController.m
//  BLPeripheralVC
//
//  Created by yfm on 2022/5/30.
//
//  外设模式

/**
 1.启动外围设备管理器对象
 2.在本地外围设备上设置服务和特征
 3.将服务和特征发布到设备的本地数据库
 4.广播服务
 5.响应来自中心的读写请求
 6.将更新的特征值发送到订阅中心
 */

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString *const SERVICE_UUID = @"C477CBCA-BBA8-42EF-A5F9-782BF2E09822";
NSString *const WRITE_UUID = @"CDB49AF3-6B35-4102-AEE7-7398D1C46210";
NSString *const NOTIFY_UUID = @"CDB49AF3-6B35-4102-AEE7-7398D1C46211";

@interface ViewController () <CBPeripheralManagerDelegate>
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) CBMutableService *service;
@property (nonatomic) CBMutableCharacteristic *writeCharateristic;
@property (nonatomic) CBMutableCharacteristic *notifyCharateristic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startUpPeripheralManager];
    [self setupServiceAndCharateristic];
    [self publishServiceAndCharateristic];
    [self startAdvertise];
}

// 1.启动外围设备管理器对象
- (void)startUpPeripheralManager {
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

// 2.在本地外围设备上设置服务和特征
- (void)setupServiceAndCharateristic {
    self.writeCharateristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:WRITE_UUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsReadable];
    self.notifyCharateristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:WRITE_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsReadable];
    self.service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID] primary:YES];
    self.service.characteristics = @[self.writeCharateristic,
                                     self.notifyCharateristic];
}

// 3.将服务和特征发布到设备的本地数据库
- (void)publishServiceAndCharateristic {
    [self.peripheralManager addService:self.service];
}

// 4.广播服务
- (void)startAdvertise {
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey: @[self.service.UUID]}];
}

#pragma mark - delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    
}

// 5.响应来自中心的读写请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
}

// 6.将更新的特征值发送到订阅中心
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
}

@end
