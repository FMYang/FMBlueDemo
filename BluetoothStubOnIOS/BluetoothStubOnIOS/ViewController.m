//
//  ViewController.m
//  BluetoothStubOnIOS
//
//  Created by 刘彦玮 on 15/12/11.
//  Copyright © 2015年 刘彦玮. All rights reserved.
//

#import "ViewController.h"
#import "BabyBluetooth.h"

NSString* const WRITE_CHARACTERISTIC_UUID   = @"D44BC439-ABFD-45A2-B575-925416129600";
NSString* const NOTIFY_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129601";
NSString* const RESEND_CHARACTERISTIC_UUID  = @"D44BC439-ABFD-45A2-B575-925416129610";

@interface ViewController (){
    BabyBluetooth *baby;
}

@property (nonatomic) CBCentral *central;
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) CBMutableCharacteristic *characteristic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // "D44BC439-ABFD-45A2-B575-925416129601"
    
    //配置第一个服务s1
    CBMutableService *s1 = makeCBService(@"FFF0");
    //配置s1的3个characteristic
    makeCharacteristicToService(s1, @"FFF1", @"r", @"hello1");//读
    makeCharacteristicToService(s1, WRITE_CHARACTERISTIC_UUID, @"rw", @"hello2");//写
    makeCharacteristicToService(s1, @"D44BC439-ABFD-45A2-B575-925416129622", @"rw", @"hello3");//读写,自动生成uuid
    makeCharacteristicToService(s1, @"FFF4", nil, @"hello4");//默认读写字段
    makeCharacteristicToService(s1, NOTIFY_CHARACTERISTIC_UUID, @"n", @"hello5");//notify字段
    //配置第一个服务s2
    CBMutableService *s2 = makeCBService(@"FFE0");
    makeStaticCharacteristicToService(s2, genUUID(), @"hello6", [@"a" dataUsingEncoding:NSUTF8StringEncoding]);//一个含初值的字段，该字段权限只能是只读
    //实例化baby
    baby = [BabyBluetooth shareBabyBluetooth];
    //配置委托
    [self babyDelegate];
    //添加服务和启动外设
    baby.bePeripheralWithName(@"FMSmoothX").addServices(@[s1,s2]).startAdvertising();
    
    UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [startBtn setTitle:@"start" forState:UIControlStateNormal];
    [startBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    UIButton *stopBtn = [[UIButton alloc] initWithFrame:CGRectMake(220, 100, 100, 40)];
    [stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    [stopBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(stopAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopBtn];
    
}

//配置委托
- (void)babyDelegate{
    [baby peripheralModelBlockOnPeripheralManagerDidUpdateState:^(CBPeripheralManager *peripheral) {
        NSLog(@"PeripheralManager trun status code: %ld",(long)peripheral.state);
    }];
    
    [baby peripheralModelBlockOnDidStartAdvertising:^(CBPeripheralManager *peripheral, NSError *error) {
        NSLog(@"didStartAdvertising !!!");
        
    }];
    
    [baby peripheralModelBlockOnDidAddService:^(CBPeripheralManager *peripheral, CBService *service, NSError *error) {
        NSLog(@"Did Add Service uuid: %@ ",service.UUID);
//        0x0905260201ffff4d2407050002
//        Byte bytes[13] = {0x09, 0x05, 0x26, 0x02, 0x01, 0xff, 0xff, 0x4d, 0x24, 0x07, 0x05, 0x00, 0x11};
//        NSData *data = [NSData dataWithBytes:bytes length:13];
        // The advertisement key 'Manufacturer Data' is not allowed
        [peripheral startAdvertising:@{CBAdvertisementDataLocalNameKey: @"FMSmoothX"}];
    }];
    
    [baby peripheralModelBlockOnDidReceiveReadRequest:^(CBPeripheralManager *peripheral,CBATTRequest *request) {
        NSLog(@"request characteristic uuid:%@ %@",request.characteristic.UUID, request);
        //判断是否有读数据的权限
        if (request.characteristic.properties & CBCharacteristicPropertyRead) {
            NSData *data = request.characteristic.value;
            [request setValue:data];
            //对请求作出成功响应
            [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
        }else{
            //错误的响应
            [peripheral respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
        }
    }];
    
    [baby peripheralModelBlockOnDidReceiveWriteRequests:^(CBPeripheralManager *peripheral,NSArray *requests) {
        CBATTRequest *request = requests[0];
        NSLog(@"didReceiveWriteRequests %@", request);
        //判断是否有写数据的权限
        if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
            //需要转换成CBMutableCharacteristic对象才能进行写值
            CBMutableCharacteristic *c =(CBMutableCharacteristic *)request.characteristic;
            c.value = request.value;
            [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
            
            // 响应
            [peripheral updateValue:request.value forCharacteristic:request.characteristic onSubscribedCentrals:@[request.central]];
        }else{
            [peripheral respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
        }
    }];
    
    __block NSTimer *timer;
    [baby peripheralModelBlockOnDidSubscribeToCharacteristic:^(CBPeripheralManager *peripheral, CBCentral *central, CBCharacteristic *characteristic) {
        NSLog(@"订阅了 %@的数据",characteristic.UUID);
        if([characteristic.UUID.UUIDString isEqualToString:NOTIFY_CHARACTERISTIC_UUID]) {
            self.characteristic = (CBMutableCharacteristic *)characteristic;
            self.peripheralManager = peripheral;
            self.central = central;
        }
        //每秒执行一次给主设备发送一个当前时间的秒数
//        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendData:) userInfo:characteristic  repeats:YES];
        // 0x243c08001812f3017c000000bc8c
        Byte bytes[14] = {0x24, 0x3c, 0x08, 0x00, 0x18, 0x12, 0xf3, 0x01, 0x7c, 0x00, 0x00, 0x00, 0xbc, 0x8c};
        NSData *data = [NSData dataWithBytes:bytes length:14];
        
        [peripheral updateValue:data forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:@[central]];
    }];
    
    [baby peripheralModelBlockOnDidUnSubscribeToCharacteristic:^(CBPeripheralManager *peripheral, CBCentral *central, CBCharacteristic *characteristic) {
        NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
        [timer fireDate];
    }];
    
}

//发送数据，发送当前时间的秒数
-(BOOL)sendData:(NSTimer *)t {
    CBMutableCharacteristic *characteristic = t.userInfo;
    NSDateFormatter *dft = [[NSDateFormatter alloc]init];
    [dft setDateFormat:@"ss"];
    NSLog(@"%@",[dft stringFromDate:[NSDate date]]);
//    执行回应Central通知数据
    return  [baby.peripheralManager updateValue:[[dft stringFromDate:[NSDate date]] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:nil];
}

- (void)startAction {
    // 0x243c08001812071620c03f007a71 录像
    NSData *data = [self convertHexStrToData:@"243c08001812071620c03f007a71"];
    [self.peripheralManager updateValue:data forCharacteristic:self.characteristic onSubscribedCentrals:@[self.central]];
}

- (void)stopAction {
    // 0x243c08001812081620c03f0079b4 停止录像
    NSData *data = [self convertHexStrToData:@"243c08001812081620c03f0079b4"];
    [self.peripheralManager updateValue:data forCharacteristic:self.characteristic onSubscribedCentrals:@[self.central]];
}

/**
 M键
 1.循环切换拍摄模式 0x243c080018122e1620c03300fd49
 2.前后置切换 0x243c08001812301620c03300dad3
 */

#pragma mark - tool
// 16进制转NSData
- (NSData *)convertHexStrToData:(NSString *)str
{
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

@end
