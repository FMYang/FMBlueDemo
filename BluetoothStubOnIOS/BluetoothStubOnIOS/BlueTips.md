#  Tips

1、The advertisement key 'Manufacturer Data' is not allowed

https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager/1393252-startadvertising?language=objc

startAdvertising只支持广播CBAdvertisementDataLocalNameKey和CBAdvertisementDataServiceUUIDsKey

advertisementData
包含您要宣传的数据的可选字典。外围管理器仅支持两个键：和。CBAdvertisementDataLocalNameKeyCBAdvertisementDataServiceUUIDsKey

2、filter

//        if (self->_filterUnZYDevice && ![ZYScanTools isZYDevice:advertisementData]) {
//            return;
//        }


3、设备广播信息
2022-04-18 17:16:00.190410+0800 ZYFilmic[2452:799517] 搜索到了设备:SMOOTH-X_A1B5 = <CBPeripheral: 0x283be1e00, identifier = A28E1BF4-C21D-9585-3E35-B805BEC0F177, name = SMOOTH-X_A1B5, state = disconnected> advertisementData = {
    kCBAdvDataAppearance = 960;
    kCBAdvDataIsConnectable = 1;
    kCBAdvDataLocalName = "SMOOTH-X_A1B5";
    kCBAdvDataManufacturerData = {length = 5, bytes = 0x0905260201};
    kCBAdvDataRxPrimaryPHY = 1;
    kCBAdvDataRxSecondaryPHY = 0;
    kCBAdvDataTimestamp = "671966160.189232";
}

4、查询序列号这步走不通，序列号放在kCBAdvDataManufacturerData，外设设置不了

//设备连接上之后必须读取的数据
-(void)queryMustData;

qurySystemStatus

translateToModelNumberWithAdvertisementData

queryProductionSerialNo
