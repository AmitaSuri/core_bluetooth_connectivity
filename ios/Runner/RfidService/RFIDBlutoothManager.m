//
//  RFIDBlutoothManager.h
//  RFID_ios
//
//  Created by   on 2018/4/26.
//  Copyright © 2018年  . All rights reserved.
//


#import "RFIDBlutoothManager.h"
#import "AppHelper.h"

#define kFatscaleTimeOut 5.0
#define serviceUUID  @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define writeUUID  @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define receiveUUID  @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
//#define serviceUUID  @"6e400001-b5a3-f393-e0a9-e50e24dcca9e"
//#define writeUUID  @"6e400002-b5a3-f393-e0a9-e50e24dcca9e"
//#define receiveUUID  @"6e400003-b5a3-f393-e0a9-e50e24dcca9e"
#define BLE_NAME_UUID  @"00001800-0000-1000-8000-00805f9b34fb"
#define BLE_NAME_CHARACTE @"00002a00-0000-1000-8000-00805f9b34fb"
#define macAddressStr @"macAddress"
#define UUIDArray @"UUIDArray"
#define BLE_SEND_MAX_LEN 20
#define UpdateBLE_SEND_MAX_LEN 20

@interface RFIDBlutoothManager () <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSTimer *bleScanTimer;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSMutableArray *peripheralArray;
@property (nonatomic, weak) id<FatScaleBluetoothManager> managerDelegate;
@property (nonatomic, weak) id<PeripheralAddDelegate> addDelegate;

@property (nonatomic, copy) NSString *connectPeripheralCharUUID;

@property (nonatomic, strong) NSMutableArray *BLEServerDatasArray;

@property (nonatomic, strong) CBCharacteristic *myCharacteristic;
@property (nonatomic, strong) NSTimer *connectTime;//计算蓝牙连接是否超时的定时器
@property (nonatomic, strong) NSTimer *sendGetTagRequestTime;//定时发送获取标签命令
@property (nonatomic, strong) NSMutableString *dataStr;
@property (nonatomic, strong) NSMutableArray *uuidDataList;
@property (nonatomic, assign) BOOL isFirstSendGetTAGCmd;
/** isHeader */
@property (assign,nonatomic) BOOL isHeader;

@property (nonatomic,readwrite)BOOL isgetLab;//是否是获取标签

/** Barcode parsing type */
@property (assign,nonatomic) BarcodeParsingType barcodeParsingType;

@end

@implementation RFIDBlutoothManager

bool isDebug = true;
bool isUpgrade = false;


+ (instancetype)shareManager {
     static RFIDBlutoothManager *shareManager = nil;
     static dispatch_once_t once;
     dispatch_once(&once, ^{
          shareManager = [[self alloc] init];
     });
     return shareManager;
}
- (instancetype)init {
     self = [super init];
     if (self) {
          [self centralManager];
          self.isSupportRssi=YES;
          self.isBLE40=NO;
          self.isHeader = NO;
          self.isSetGen2Data = NO;
          self.isGetGen2Data = NO;
          
          self.isFirstSendGetTAGCmd=YES;
          self.isgetLab=NO;
          
          self.barcodeParsingType = BarcodeParsingOfASCII;
     }
     return self;
}

#pragma mark - Public methods
- (void)bleDoScan {
     self.bleScanTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startBleScan) userInfo:nil repeats:YES];
}
// connect Bluetooth device
- (void)connectPeripheral:(CBPeripheral *)peripheral macAddress:(NSString *)macAddress {
//     NSArray *aa=[macAddress componentsSeparatedByString:@":"];
//     NSMutableString *str=[[NSMutableString alloc]init];
//     for (NSInteger i=0; i<aa.count; i++) {
//          [str appendFormat:@"%@",aa[i]];
//     }
//     
//     NSString *strr=[NSString stringWithFormat:@"%@",str];
//     [[NSUserDefaults standardUserDefaults] setObject:strr forKey:macAddressStr];
//     [[NSUserDefaults standardUserDefaults] synchronize];
     
     self.peripheral = peripheral;
     [self.centralManager connectPeripheral:peripheral options:nil];
}
- (void)cancelConnectBLE {
     [self.centralManager cancelPeripheralConnection:self.peripheral];
}
- (void)setFatScaleBluetoothDelegate:(id<FatScaleBluetoothManager>)delegate {
     self.managerDelegate = delegate;
}

- (void)setPeripheralAddDelegate:(id<PeripheralAddDelegate>)delegate {
     self.addDelegate = delegate;
}


- (Byte )getBye8:(Byte[])data {
     Byte byte8 = data[2] + data[3] + data[4] + data[5] +data[6];
     byte8 = (unsigned char) ( byte8 & 0x00ff);
     return byte8;
}

//获取电池电量
-(void)getBatteryLevel {
     self.isGetBattery = YES;
     NSData *data=[BluetoothUtil getBatteryLevel];
     [self sendDataToBle:data];
}
//获取设备当前温度
-(void)getServiceTemperature {
     self.isTemperature = YES;
     NSData *data=[BluetoothUtil getServiceTemperature];
     [self sendDataToBle:data];
}
//开启2D扫描
-(void)start2DScan {
     self.isCodeLab = YES;
     NSData *data=[BluetoothUtil start2DScan];
     [self sendDataToBle:data];
}
// 开启连续2D扫描
-(void)startContinuity2DScan {
     self.isCodeLab = YES;
     NSData *data=[BluetoothUtil startContinuous2DScan];
     [self sendDataToBle:data];
}
// 关闭连续2D扫描
-(void)stopContinuity2DScan {
     self.isCodeLab = NO;
     NSData *data=[BluetoothUtil stopContinuous2DScan];
     [self sendDataToBle:data];
}

//获取硬件版本号
-(void)getHardwareVersion {
     self.isGetVerson = YES;
     NSData *data=[BluetoothUtil getHardwareVersion];
     [self sendDataToBle:data];
     
}
////获取固件版本号
//-(void)getFirmwareVersion2 {
//     NSData *data = [BluetoothUtil getFirmwareVersion];
//     [self sendDataToBle:data];
//}
//获取固件版本号
-(void)getFirmwareVersion {
     self.isGetVerson = YES;
     NSData *data = [BluetoothUtil getFirmwareVersion];
     [self sendDataToBle:data];
}
//获取主板版本号
-(void) getReaderMainboardVersion
{
     NSData *data = [BluetoothUtil makeSendDataWithCmd:nil  cmd:0xc8];
     [self sendDataToBle:data];
}
//获取设备ID
-(void)getServiceID {
     NSData *data = [BluetoothUtil getServiceID];
     [self sendDataToBle:data];
}
//软件复位
-(void)softwareReset {
     NSData *data = [BluetoothUtil softwareReset];
     [self sendDataToBle:data];
}
//开启蜂鸣器
-(void)setOpenBuzzer {
     self.isOpenBuzzer = YES;
     NSData *data = [BluetoothUtil openBuzzer];
     [self sendDataToBle:data];
}
//关闭蜂鸣器
-(void)setCloseBuzzer {
     self.isCloseBuzzer  = YES;
     NSData *data = [BluetoothUtil closeBuzzer];
     [self sendDataToBle:data];
}

//设置标签读取格式
-(void)setEpcTidUserWithAddressStr:(NSString *)addressStr length:(NSString *)lengthStr epcStr:(NSString *)epcStr {
     self.isSetTag = YES;
     NSData *data = [BluetoothUtil setEpcTidUserWithAddressStr:addressStr length:lengthStr EPCStr:epcStr];
     [self sendDataToBle:data];
}
//获取标签读取格式
-(void)getEpcTidUserWithAddressStr {
     self.isSetTag = YES;
     NSData *data = [BluetoothUtil getEpcTidUser];
     [self sendDataToBle:data];
}

//获取标签读取格式
-(void)getEpcTidUser {
     self.isGetTag = YES;
     NSData *data = [BluetoothUtil getEpcTidUser];
     [self sendDataToBle:data];
}


//设置发射功率
-(void)setLaunchPowerWithstatus:(NSString *)status antenna:(NSString *)antenna readStr:(NSString *)readStr writeStr:(NSString *)writeStr {
     self.isSetEmissionPower = YES;
     NSData *data = [BluetoothUtil setLaunchPowerWithstatus:status antenna:antenna readStr:readStr writeStr:writeStr];
     [self sendDataToBle:data];
     
}
//获取当前发射功率
-(void)getLaunchPower {
     self.isGetEmissionPower = YES;
     NSData *data = [BluetoothUtil getLaunchPower];
     [self sendDataToBle:data];
     
}
//跳频设置
-(void)detailChancelSettingWithstring:(NSString *)str {
     NSData *data = [BluetoothUtil detailChancelSettingWithstring:str];
     [self sendDataToBle:data];
}
//获取当前跳频设置状态
-(void)getdetailChancelStatus {
     NSData *data = [BluetoothUtil getdetailChancelStatus];
     [self sendDataToBle:data];
}

//区域设置
-(void)setRegionWithsaveStr:(NSString *)saveStr regionStr:(NSString *)regionStr {
     NSData *data = [BluetoothUtil setRegionWithsaveStr:saveStr regionStr:regionStr];
     [self sendDataToBle:data];
}
//获取区域设置
-(void)getRegion {
     NSData *data = [BluetoothUtil getRegion];
     [self sendDataToBle:data];
}


// 设置透传命令
-(BOOL) setBarcodeParmameter:(NSString *) parmameter{
     if (!self.connectDevice) {
          return NO;
     }
     if (![AppHelper isHexString:parmameter]) {
          return NO;
     }
     [self sendDataToBle: [BluetoothUtil setParameter:parmameter]];
     return YES;
}
// 设置超时时间
-(BOOL) setBarcodeTimeout: (NSString *) timeout {
     if (!self.connectDevice) {
          return NO;
     }
     float timeoutValue = [timeout floatValue];
     if (timeoutValue < 0.5 || timeoutValue > 9.9) {
         return NO;
     }
     NSData *data = [BluetoothUtil setBarcodeTimeOut: [NSString stringWithFormat:@"%d", (int)(timeoutValue * 10)]];
     [self sendDataToBle:data];
     return YES;
}
//设置CodeID
-(BOOL) setBarcodeCodeId:(BOOL) codeId {
     if (!self.connectDevice) {
          return NO;
     }
     NSData *data = [BluetoothUtil setBarcodeCodeId: codeId];
     [self sendDataToBle:data];
     self.isBarcodeCodeID = codeId;
     return YES;
}

//设置二维码解析方式
-(void) setBarcodeParsingType:(BarcodeParsingType)type {
     _barcodeParsingType = type;
     
}
//获取二维码解析方式
-(BarcodeParsingType) getBarcodeParsingType:(BarcodeParsingType)type {
     return _barcodeParsingType;
}

// 设置过滤
- (void)setFilterWithBank:(BANK)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data {
     NSLog(@"setFilter bank:%ld  ptr:%@  len:%@  data:%@", bank, ptr, len, data);
     NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
     NSNumber *ptrValue = [numberFormatter numberFromString:ptr];
     if (ptr.length == 0) {
          [self.managerDelegate rfidSetFilterCallback:@"Filter Ptr can't be empty" isSuccess:NO];
         return;
     } else if (ptrValue == nil) {
          [self.managerDelegate rfidSetFilterCallback:@"Filter Ptr must be a number" isSuccess:NO];
         return;
     }
     NSNumber *lenValue = [numberFormatter numberFromString:len];
     if (len.length == 0) {
          [self.managerDelegate rfidSetFilterCallback:@"Filter Len can't be empty" isSuccess:NO];
         return;
     } else if (lenValue == nil) {
          [self.managerDelegate rfidSetFilterCallback:@"Filter Len must be a number" isSuccess:NO];
         return;
     }
     if (lenValue.intValue != 0 && data.length == 0) {
          [self.managerDelegate rfidSetFilterCallback:@"Filter Data can't be empty" isSuccess:NO];
         return;
     }
     if (lenValue.intValue != 0 && ![AppHelper isHexString:data]) {
          [self.managerDelegate rfidSetFilterCallback:@"Filter Data must be Hexadecimal" isSuccess:NO];
         return;
     }
     if (lenValue.intValue != 0 && data.length * 4 < len.intValue) {
          [self.managerDelegate rfidSetFilterCallback:@"Filter Data does not match Len" isSuccess:NO];
         return;
     }
     if (bank < 1 || bank > 3) {
          [self.managerDelegate rfidSetFilterCallback:@"Filter Bank is invaild" isSuccess:NO];
          return;
     }
     
     NSData *sendData = [BluetoothUtil setFilterWithBank:bank Ptr:ptr Len:len Data:data];
     [self sendDataToBle:sendData];
}


//单次盘存标签
-(void)singleInventory {
     self.isSingleSaveLable  = YES;
     NSData *data = [BluetoothUtil singleInventory];
     [self sendDataToBle:data];
}
//********************************************
- (void)handleTimer {
     if(self.isFirstSendGetTAGCmd==YES){
          //NSLog(@"----------------------------++++++");
          //如果开始盘底后，马上停止。 那么直接退回定时器
          self.isFirstSendGetTAGCmd=NO;
          for(int k=0;k<300;k++){
               if(self.isgetLab == NO){
                    [self.sendGetTagRequestTime invalidate];
                    self.sendGetTagRequestTime=nil;
                    // NSLog(@"退出获取标签定时器!");
                    return;
               }
               usleep(1000);
          }
     }
     
     if (self.connectDevice ==YES && self.isgetLab==YES) {
          // NSLog(@"获取标签定时器!");
          [self getLabMessage];
     }else{
          [self.sendGetTagRequestTime invalidate];
          self.sendGetTagRequestTime=nil;
          //  NSLog(@"退出获取标签定时器!");
     }
}
//连续盘存标签
-(void)startInventory {
     //获取蓝牙版本
     //[self getFirmwareVersion];
     self.isgetLab = YES;
     
     NSData *data = [BluetoothUtil startInventory];
     [self sendDataToBle:data];
     
     if (self.sendGetTagRequestTime == nil){
          self.isFirstSendGetTAGCmd=YES;
          if (self.isBLE40 == YES) {
               self.sendGetTagRequestTime = [NSTimer scheduledTimerWithTimeInterval:0.08 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
          } else {
               self.sendGetTagRequestTime = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
          }
     }
     
}

//停止连续盘存标签
-(void)stopInventory {
     self.isgetLab = NO;
     NSData *data = [BluetoothUtil StopcontinuitySaveLabel];
     [self sendDataToBle:data];
}


////********************************************
////连续盘存标签
//-(void)startInventory {
//     Byte dateByte[2];
//     dateByte[0]=0x00;
//     dateByte[1]=0x00;
//     NSData *temp = [[NSData alloc] initWithBytes:dateByte length:2];
//     NSData *data = [BluetoothUtil makeSendDataWithCmd:temp  cmd:0x82];
//     //NSData *data = [BluetoothUtil continuitySaveLabelWithCount:0];
//     [self sendDataToBle:data];
//}
//
////停止连续盘存标签
//-(void)stopInventory {
//     self.isgetLab=NO;
//     NSData *data = [BluetoothUtil makeSendDataWithCmd:nil  cmd:0x8c];
//     // NSData *data = [BluetoothUtil StopcontinuitySaveLabel];
//     for(int k=0;k<3;k++){
//          usleep(1000*200);
//          [self sendDataToBle:data];
//     }
//}

//升级第一步：进入升级模式 1:表示rfid固件， 2:表示主板固件
-(void)enterUpgradeMode:(int) firmwareType {
     NSLog(@"进入升级模式 enterUpgradeMode firmwareType=%d",firmwareType);
     if (firmwareType!=1 && firmwareType!=2) {
          return;
     }
     Byte dateByte[1];
     if (firmwareType == 1) {
          dateByte[0] = 0xCC; //rfid固件0xcc
     } else {
          dateByte[0] = 0xEE; //主板固件0xee
     }
     
     NSData *temp = [[NSData alloc] initWithBytes:dateByte length:1];
     NSData *data = [BluetoothUtil makeSendDataWithCmd:temp  cmd:0xC0];
     //NSData *data = [BluetoothUtil continuitySaveLabelWithCount:0];
     [self sendDataToBle:data];
}
//升级第二步：开始升级
- (void)startUpgrade {
     NSLog(@"开始升级startUpgrade.");
     isUpgrade = true;
     NSData *data = [BluetoothUtil makeSendDataWithCmd:nil  cmd:0xC2];
     [self sendDataToBle:data];
}
//升级第三步：发送数据
- (void)sendUpgradeData:(NSString *)hexData {
     NSLog(@"发送数据sendUpgradeData.");
     NSData *data = [BluetoothUtil makeSendDataWithCmd:[AppHelper hexToNSData:hexData] cmd:0xC4];
     [self sendDataToBle:data];
}
//升级第四步：结束升级
- (void)stopUpgrade {
     NSLog(@"结束升级stopUpgrade");
     NSData *data = [BluetoothUtil makeSendDataWithCmd:nil  cmd:0xC6];
     [self sendDataToBle:data];
}



//读标签数据区
-(void)readLabelMessageWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata MBstr:(NSString *)MBstr SAstr:(NSString *)SAstr DLstr:(NSString *)DLstr isfilter:(BOOL)isfilter
{
     if([password isEqualToString:@""] || [MBstr isEqualToString:@""] || [SAstr isEqualToString:@""] || [DLstr isEqualToString:@""] || ( isfilter && ([MMBstr isEqualToString:@""] || [MSAstr isEqualToString:@""] || [MDLstr isEqualToString:@""] || [MDdata isEqualToString:@""]) )
     ) {
          [self.managerDelegate rfidReadLabelCallback:@"Existing input information is empty" isSuccess:NO];
          return;
     }
     if (isfilter && ( MDLstr.intValue == 0 || MDLstr.intValue / 4 != MDdata.length)) {
          [self.managerDelegate rfidReadLabelCallback:@"Filter data does not match length" isSuccess:NO];
          return;
     }
     if(isfilter && ![AppHelper isHexString:MDdata]){
          [self.managerDelegate rfidReadLabelCallback:@"Filter Data must be in hexadecimal" isSuccess:NO];
          return;
     }
     if (password.length < 8 || ![AppHelper isHexString:password]) {
          [self.managerDelegate rfidReadLabelCallback:@"Password must be 8 characters hexadecimal" isSuccess:NO];
          return;
     }
     
     NSData *data = [BluetoothUtil readLabelMessageWithPassword:password MMBstr:MMBstr MSAstr:MSAstr MDLstr:MDLstr MDdata:MDdata MBstr:MBstr SAstr:SAstr DLstr:DLstr isfilter:isfilter];
     if(data == NULL){
          [self.managerDelegate rfidReadLabelCallback:@"fail" isSuccess:NO];
          return;
     }
     [self sendDataToBle:data];
}

//写标签数据区
-(void)writeLabelMessageWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata MBstr:(NSString *)MBstr SAstr:(NSString *)SAstr DLstr:(NSString *)DLstr writeData:(NSString *)writeData isfilter:(BOOL)isfilter
{
     if([password isEqualToString:@""] || [MBstr isEqualToString:@""] || [SAstr isEqualToString:@""] || [DLstr isEqualToString:@""] || [writeData isEqualToString:@""] || ( isfilter && ([MMBstr isEqualToString:@""] || [MSAstr isEqualToString:@""] || [MDLstr isEqualToString:@""] || [MDdata isEqualToString:@""]) )
        ) {
          [self.managerDelegate rfidWriteLabelCallback:@"Existing input information is empty" isSuccess:NO];
          return;
     }
     if (isfilter && ( MDLstr.intValue == 0 || MDLstr.intValue / 4 != MDdata.length)) {
          [self.managerDelegate rfidWriteLabelCallback:@"Filter Data does not match length" isSuccess:NO];
          return;
     }
     if(isfilter && ![AppHelper isHexString:MDdata]){
          [self.managerDelegate rfidWriteLabelCallback:@"Filter Data must be in hexadecimal" isSuccess:NO];
          return;
     }
     if (password.length < 8 || ![AppHelper isHexString:password]) {
          [self.managerDelegate rfidWriteLabelCallback:@"Password must be 8 characters hexadecimal" isSuccess:NO];
          return;
     }
     if (DLstr.intValue * 4 != writeData.length) {
          [self.managerDelegate rfidWriteLabelCallback:@"Data does not match length" isSuccess:NO];
          return;
     }
     if(![AppHelper isHexString:writeData]){
          [self.managerDelegate rfidWriteLabelCallback:@"Data must be in hexadecimal" isSuccess:NO];
          return;
     }
     
//     NSData *data =[BluetoothUtil writeLabelWithPassword:password MMBstr:MMBstr MSAstr:MSAstr MDLstr:MDLstr MDdata:MDdata MBstr:MBstr SAstr:SAstr DLstr:DLstr writeData:writeData isfilter:isfilter];
     NSData *data = [BluetoothUtil writeLabelMessageWithPassword:password MMBstr:MMBstr MSAstr:MSAstr MDLstr:MDLstr MDdata:MDdata MBstr:MBstr SAstr:SAstr DLstr:DLstr writeData:writeData isfilter:isfilter];
//     NSLog(@"data =%@", [data subdataWithRange:NSMakeRange(0, 20)]);
//     NSLog(@"data =%@", [data subdataWithRange:NSMakeRange(20, data.length - 20)]);
//     NSLog(@"data0=%@", [data0 subdataWithRange:NSMakeRange(0, 20)]);
//     NSLog(@"data0=%@", [data0 subdataWithRange:NSMakeRange(20, data0.length - 20)]);

     
     if (data == nil) {
          [self.managerDelegate rfidWriteLabelCallback:@"fail" isSuccess:NO];
          return;
     }
     
     [self sendDataToBle:data];
}

//Lock标签
-(void)lockLabelWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata ldStr:(NSString *)ldStr isfilter:(BOOL)isfilter
{
     if ([password isEqualToString:@""] || [ldStr isEqualToString:@""] || ( isfilter && ([MMBstr isEqualToString:@""] || [MSAstr isEqualToString:@""] || [MDLstr isEqualToString:@""] || [MDdata isEqualToString:@""]))) {
          [self.managerDelegate rfidLockLabelCallback:@"Existing input information is empty" isSuccess:NO];
          return;
     }
     if (isfilter && ( MDLstr.intValue == 0 || MDLstr.intValue / 4 != MDdata.length)) {
          [self.managerDelegate rfidWriteLabelCallback:@"Filter Data does not match length" isSuccess:NO];
          return;
     }
     if(isfilter && ![AppHelper isHexString:MDdata]){
          [self.managerDelegate rfidLockLabelCallback:@"Filter Data must be in hexadecimal" isSuccess:NO];
          return;
     }
     if (password.length < 8 || ![AppHelper isHexString:password]) {
          [self.managerDelegate rfidLockLabelCallback:@"Password must be 8 characters hexadecimal" isSuccess:NO];
          return;
     }
     
     NSData *data=[BluetoothUtil lockLabelWithPassword:password MMBstr:MMBstr MSAstr:MSAstr MDLstr:MDLstr MDdata:MDdata ldStr:ldStr isfilter:isfilter];
     NSLog(@"data===%@",data);
     
     if (data == nil) {
          [self.managerDelegate rfidLockLabelCallback:@"fail" isSuccess:NO];
          return;
     }
     
     [self sendDataToBle:data];
}

//kill标签。
-(void)killLabelWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata isfilter:(BOOL)isfilter
{
     if ([password isEqualToString:@""] || ( isfilter && ([MMBstr isEqualToString:@""] || [MSAstr isEqualToString:@""] || [MDLstr isEqualToString:@""] || [MDdata isEqualToString:@""]))) {
          [self.managerDelegate rfidKillLabelCallback:@"Existing input information is empty" isSuccess:NO];
          return;
     }
     if (isfilter && ( MDLstr.intValue == 0 || MDLstr.intValue / 4 != MDdata.length)) {
          [self.managerDelegate rfidKillLabelCallback:@"Filter Data does not match length" isSuccess:NO];
          return;
     }
     if(isfilter && ![AppHelper isHexString:MDdata]){
          [self.managerDelegate rfidKillLabelCallback:@"Filter Data must be in hexadecimal" isSuccess:NO];
          return;
     }
     if (password.length < 8 || ![AppHelper isHexString:password]) {
          [self.managerDelegate rfidKillLabelCallback:@"Password must be 8 characters hexadecimal" isSuccess:NO];
          return;
     }
     
     NSData *data = [BluetoothUtil killLabelWithPassword:password MMBstr:MMBstr MSAstr:MSAstr MDLstr:MDLstr MDdata:MDdata isfilter:isfilter];
     NSLog(@"data===%@",data);
     
     if (data == nil) {
          [self.managerDelegate rfidKillLabelCallback:@"fail" isSuccess:NO];
          return;
     }
     
     [self sendDataToBle:data];
}
//获取标签数据
-(void)getLabMessage {
     dispatch_async(dispatch_get_main_queue(), ^{
          NSData *data = [BluetoothUtil getLabMessage];
          [self sendDataToBle:data];
     });
}



#pragma mark - Private Methods
- (void)startBleScan {
     if (self.centralManager.state == CBManagerStatePoweredOff) {
          self.connectDevice = NO;
          if ([self.managerDelegate respondsToSelector:@selector(connectBluetoothFailWithMessage:)]) {
               [self.managerDelegate connectBluetoothFailWithMessage:[self centralManagerStateDescribe:CBManagerStatePoweredOff]];
          }
          return;
     }
     if (_connectTime == nil) {
          //创建连接制定设备的定时器
          _connectTime = [NSTimer scheduledTimerWithTimeInterval:kFatscaleTimeOut target:self selector:@selector(connectTimeroutEvent) userInfo:nil repeats:NO];
     }
     self.uuidDataList=[[NSMutableArray alloc]init];
     [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @ YES}];
}

- (void)connectTimeroutEvent {
     [_connectTime invalidate];
     _connectTime = nil;
     [self stopBleScan];
     [self.centralManager stopScan];
     [self.managerDelegate receiveDataWithBLEmodel:nil result:@"1"];
}

- (void)stopBleScan {
     [self.bleScanTimer invalidate];
}

- (void)closeBleAndDisconnect {
     [self stopBleScan];
     [self.centralManager stopScan];
     if (self.peripheral) {
          [self.centralManager cancelPeripheralConnection:self.peripheral];
     }
}

//Nordic_UART_CW HotWaterBottle
- (void)sendDataToBle:(NSData *)data {
     // NSLog(@"sendData");
     if(data.length<=BLE_SEND_MAX_LEN){
          NSLog(@"sendData=%@",[AppHelper dataToHex:data]);
          dispatch_async(dispatch_get_main_queue(), ^{
               [self.peripheral writeValue:data forCharacteristic:self.myCharacteristic type:CBCharacteristicWriteWithoutResponse];
          });
          return;
     }
     int c = data.length%BLE_SEND_MAX_LEN==0?0:1;
     int count = data.length/BLE_SEND_MAX_LEN + c; 
     for(int k=0;k<count;k++){
          int sendSize=20;
          if(k==count-1 && c==1){
               //发送余数
               sendSize=data.length%BLE_SEND_MAX_LEN;
          }
          NSData *sendData= [data subdataWithRange:NSMakeRange(k*BLE_SEND_MAX_LEN, sendSize)];
          NSLog(@"sendData=%@",[AppHelper dataToHex:sendData]);
          dispatch_async(dispatch_get_main_queue(), ^{
               [self.peripheral writeValue:sendData forCharacteristic:self.myCharacteristic type:CBCharacteristicWriteWithoutResponse];
          });
          usleep(1000*30);
     }
}


#pragma maek - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
     if (central.state != CBManagerStatePoweredOn) {
          if ([self.managerDelegate respondsToSelector:@selector(connectBluetoothFailWithMessage:)]) {
               if (central.state == CBManagerStatePoweredOff) {
                    self.connectDevice = NO;
                    [self.managerDelegate connectBluetoothFailWithMessage:[self centralManagerStateDescribe:CBManagerStatePoweredOff]];
               }
          }
     }
     
     switch (central.state) {
          case CBManagerStatePoweredOn:
               NSLog(@"CBCentralManagerStatePoweredOn");
               break;
          case CBManagerStatePoweredOff:
               NSLog(@"蓝牙断开：CBCentralManagerStatePoweredOff");
               break;
          default:
               break;
     }
}

#pragma mark - 扫描到设备
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
     NSData *manufacturerData = [advertisementData valueForKeyPath:CBAdvertisementDataManufacturerDataKey];
     
     if (advertisementData.description.length > 0) {
          NSLog(@"/-------广播数据advertisementData:%@--------",advertisementData.description);
          NSLog(@"-------外设peripheral:%@--------/",peripheral.description);
          NSLog(@"peripheral.services==%@",peripheral.identifier.UUIDString);
          NSLog(@"RSSI==%@",RSSI);
     }
     
     NSString *bindString = @"";
     NSString *str = @"";
     if (manufacturerData.length>=8) {
          NSData *subData = [manufacturerData subdataWithRange:NSMakeRange(manufacturerData.length-8, 8)];
          bindString = subData.description;
          str = [self getVisiableIDUUID:bindString];
          NSLog(@" GG == %@ == GG",str);
     }
     
     NSString *typeStr=@"1";
     for (NSString *uuidStr in self.uuidDataList) {
          if ([peripheral.identifier.UUIDString isEqualToString:uuidStr]) {
               typeStr=@"2";
          }
     }
     if (peripheral.name!=nil && peripheral.name.length>0 && [typeStr isEqualToString:@"1"]) {
          [self.uuidDataList addObject:peripheral.identifier.UUIDString];
          BLEModel *model=[BLEModel new];
          model.nameStr=peripheral.name;
          model.rssStr=[NSString stringWithFormat:@"%@",RSSI];
          model.addressStr=str;
          model.peripheral=peripheral;
          [self.managerDelegate receiveDataWithBLEmodel:model result:@"0"];
     }
}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
     self.connectDevice = YES;
     NSLog(@"-- 成功连接外设 --：%@",peripheral.name);
     NSLog(@"Did connect to peripheral: %@",peripheral);
     peripheral.delegate = self;
     [peripheral discoverServices:nil];
     [self.centralManager stopScan];
     [self stopBleScan];
     
     // 保存已连接的设备UUID到NSUserDefaults中
     // 保存已连接的设备identifier到NSUserDefaults中
//     NSMutableArray *identifierArray = [[[NSUserDefaults standardUserDefaults] objectForKey:UUIDArray] mutableCopy];
//     if (!identifierArray) {
//        identifierArray = [NSMutableArray new];
//     }
//     if (![identifierArray containsObject:peripheral.identifier]) {
//        [identifierArray addObject:peripheral.identifier];
//     }
//     [[NSUserDefaults standardUserDefaults] setObject:identifierArray forKey:@"connectedIdentifiers"];
//     [[NSUserDefaults standardUserDefaults] synchronize];
     
     // 设置CodeID，保证isBarcodeCodeID与设备状态一致
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          NSData *data = [BluetoothUtil setBarcodeCodeId: self.isBarcodeCodeID];
          [self sendDataToBle:data];
          
          [self.managerDelegate connectPeripheralSuccess:peripheral.name];
     });
}

//断开外设连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
     self.connectDevice = NO;
     self.isgetLab = NO;
     //NSLog(@"蓝牙已断开");
     [self.managerDelegate disConnectPeripheral];
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
     //NSLog(@"-- 连接失败 --");
     self.connectDevice = NO;
}

#pragma mark - CBPeripheralDelegate
//发现服务时调用的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
     NSLog(@"%s", __func__);
     NSLog(@"error：%@", error);
     NSLog(@"-==----includeServices = %@",peripheral.services);
     for (CBService *service in peripheral.services) {
          [peripheral  discoverCharacteristics:nil forService:service];
     }
}

//发现服务的特征值后回调的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
     for (CBCharacteristic *c in service.characteristics) {
          [peripheral discoverDescriptorsForCharacteristic:c];
     }
     
     if ([service.UUID.UUIDString isEqualToString:serviceUUID]) {
          for (CBCharacteristic *characteristic in service.characteristics) {
               if ([characteristic.UUID.UUIDString isEqualToString:writeUUID]) {
                    if (characteristic) {
                         self.myCharacteristic  = characteristic;
                    }
               }
               if ([characteristic.UUID.UUIDString isEqualToString:receiveUUID]) {
                    if (characteristic) {
                         [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    }
               }
          }
     }
//     if ([service.UUID.UUIDString isEqualToString:BLE_NAME_UUID]) {
//          NSLog(@"-----=====find BLE NAME UUID Service");
//          for (CBCharacteristic *characteristic in service.characteristics) {
//               if ([characteristic.UUID.UUIDString isEqualToString:BLE_NAME_CHARACTE]) {
//                    if (characteristic) {
//                         //[peripheral setValue:@"" forKey:BLE_NAME_CHARACTE];
//                    }
//               }
//          }
//     }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
     // NSLog(@"didUpdateNotificationStateForCharacteristic: %@",characteristic.value);
}

//*******************解析按键*************************
const NSInteger dataKeyBuffLen=9;
Byte dataKey[9];
NSInteger dataIndex=0;
- (void) getKeyData:(Byte*) data {
     //A5 5A 00 09 E6 04 EB0D0A
     int flag = 0;
     int keyCode = 0;
     int checkCode = 0;//校验码
     for (int k = 0; k < dataKeyBuffLen; k++) {
          int temp = (data[k] & 0xff);
          switch (flag) {
               case 0:
                    if(temp == 0xC8){
                         flag = 1;
                    }else if(temp == 0xA5){
                         flag = 111;
                    }
                    break;
               case 111:
                    flag = (temp == 0x5A) ? 2 : 0;
                    break;
               case 1:
                    flag = (temp == 0x8C) ? 2 : 0;
                    break;
               case 2:
                    flag = (temp == 0x00) ? 3 : 0;
                    break;
               case 3:
                    flag = (temp == 0x09) ? 4 : 0;
                    break;
               case 4:
                    flag = (temp == 0xE6) ? 5 : 0;
                    break;
               case 5:
                    flag = (temp == 0x01 || temp == 0x02 || temp == 0x03 || temp == 0x04) ? 6 : 0;
                    keyCode = data[k];
                    break;
               case 6:
                    checkCode = checkCode ^ 0x00;
                    checkCode = checkCode ^ 0x09;
                    checkCode = checkCode ^ 0xE6;
                    checkCode = checkCode ^ keyCode;
                    flag = (temp == checkCode) ? 7 : 0;
                    break;
               case 7:
                    flag = (temp == 0x0D) ? 8 : 0;
                    break;
               case 8:
                    flag = (temp == 0x0A) ? 9 : 0;
                    break;
          }
          if (flag == 9)
               break;
     }
     if (flag == 9) {
          NSLog(@"按下扫描按键");
          [self.managerDelegate rfidConfigCallback:@"" function:0xe6];
     }
     
}


-(void) parseKeyDown:(NSData *) data {
     Byte *tempBytes = (Byte *)data.bytes;
     for (int k = 0; k < data.length; k++) {
          dataKey[dataIndex++]=tempBytes[k];
          if(dataIndex>=dataKeyBuffLen){
               dataIndex=dataKeyBuffLen-1;
               if(dataKey[0]== 0xC8 && dataKey[1]==0x8c && dataKey[4]==0xE6 && dataKey[dataKeyBuffLen-2]==0x0D  && dataKey[dataKeyBuffLen-1]==0x0A){
                    [self getKeyData:dataKey];
               }else if(dataKey[0]== 0xA5 && dataKey[1]==0x5A && dataKey[4]==0xE6 && dataKey[dataKeyBuffLen-2]==0x0D  && dataKey[dataKeyBuffLen-1]==0x0A){
                    [self getKeyData:dataKey];
               }
               for(int s=0;s<dataKeyBuffLen-1;s++){
                    dataKey[s]=dataKey[s+1];
               }
          }
     }
}


/**
 特征值更新时回调的方法
 */
#pragma mark - 接收数据
- (void)peripheral:(CBPeripheral *)peripheral
        didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
        error:(NSError *)error
{
     if (isDebug)  NSLog(@"==>characteristic.value=%@", characteristic.value);
     if (![AppHelper dataToHex:characteristic.value])  return;
     if (!self.uhfData) {
          self.uhfData = [[NSMutableData alloc]initWithData:characteristic.value];
     } else {
          [self.uhfData appendData:characteristic.value];
     }
     
     // a5 5a    数据长度（2字节）  cmd     数据       crc(1字节)      0d 0a
     // a5 5a    00 19           e1      数据       eb             0d 0a
     if(isDebug)    NSLog(@"==>>>self.uhfData=%@", self.uhfData);
     if (self.uhfData.length < 8) return;
     
     int cmd = -1, length = 0, headerIndex = 0;
     bool isHeader = NO;
     Byte *tagDataBytes = (Byte *)self.uhfData.bytes;
     Byte tempBytes[1024] = {0};
     for(int i = 0; i < self.uhfData.length; i++) {
          if (length == 0) {
               memset(tempBytes, 0, sizeof(tempBytes));  //数组所有元素赋0
          }
          tempBytes[length] = tagDataBytes[i];
          length++;
          
          //NSLog(@"tagDataBytes[i]=%d length=%d",tagDataBytes[i], length);
          
          if (!isHeader) {
               
               int t0 = (tempBytes[0] & 0xFF);
               int t1 = (tempBytes[1] & 0xFF);
               if(t0 == 0xA5) {
                    if(length == 2) {
                         if (t1==0x5A) {
                              isHeader = true;
                              headerIndex = i - 1;
                         } else {
                              length=0;
                         }
                    }
               } else {
                    length=0;
               }
               
          } else if ((tempBytes[length - 2] & 0xFF) == 0x0D && (tempBytes[length - 1] & 0xFF) == 0x0A) {
               NSInteger len = ((tempBytes[2]&0xFF) << 8) | (tempBytes[3]&0xFF); //数据帧h长度
               //NSLog(@"len=%ld  length=%d", len, length);
               if (len == length) {
                    cmd = (tempBytes[4]) & 0xff;  //功能
                    // NSLog(@"tempHexData=%@",dataStr);
                    NSData * completeNSData=[NSData dataWithBytes:tempBytes length:length];
                    // 开始解析数据   去掉头尾，返回uhf纯数据
                    NSData *onlyUhfData = [BluetoothUtil parseDataWithOriginalStr:completeNSData cmd:cmd];
                    if (onlyUhfData.length == 0) {
                         NSLog(@"解析失败...");
                         // 解析失败清除数据头
                         length = 0;
                         isHeader = NO;
                         i = headerIndex + 1;
                         headerIndex = 0;
                    } else {
                         // 处理数据
                         if(isDebug) NSLog(@"解析成功  %@", [AppHelper dataToHex:completeNSData]);
                         [self processData:onlyUhfData cmd:cmd];
                         // 解析完成，清空头，再开始下一个数据的读取
                         isHeader = NO;
                         length = 0;
                    }
               } else if(len > 1024) {
                    length = 0;
                    isHeader = NO;
                    i = headerIndex + 1;
                    headerIndex = 0;
                    if(isDebug)  NSLog(@"len > 1024");
               } else {
                    if(isDebug)  NSLog(@"len!=length  len=%ld  length=%d", len, length);
               }
          } else if (length > 500) {
               // 累计500个字节还没有正确数据，直接清空缓存buff
               NSData *tData = [NSData dataWithBytes:tempBytes length:length];
               NSLog(@"累计250个字节还没有正确数据，直接清空缓存buff=%@", [AppHelper dataToHex:tData]);
               length = 0;
               isHeader = NO;
          } else if(length > 4) {
               NSInteger len = ((tempBytes[2] & 0xFF)<<8) | (tempBytes[3] & 0xFF);  //数据帧h长度
               if (len == length) {
                    //NSData * tData = [NSData dataWithBytes:tempBytes length:length];
                    //NSLog(@"数据解析失败 len=%d s=%d headerIndex=%d buff=%@ ",length,s,headerIndex,[AppHelper dataToHex:tData]);
                    length = 0;
                    i = headerIndex + 1;  //重新找数据头
                    headerIndex = 0;
                    isHeader = NO;
               }
          }
     }
     if(!self.isgetLab && self.uhfData.length>5 ){
          Byte *uhfDataBytes = (Byte *)self.uhfData.bytes;
          if((uhfDataBytes[4] & 0xff)==0xe1) {
               self.uhfData = [NSMutableData data];
               return;
          }
     }
     
     if (length <= 0) {
          self.uhfData = [NSMutableData data];
     } else {
          // 将遍历结束后未解析的数据保存下来
          self.uhfData = [NSMutableData dataWithBytes:tempBytes length:length];
     }
    
}

/**
 根据命令字处理数据
 */
#pragma mark - 根据命令字处理数据
- (void)processData:(NSData *)uhfData cmd:(int)cmd{
     if(isDebug)    NSLog(@"processData uhfData=%@  cmd=%x", uhfData, cmd);
     
     // 获取硬件版本号
     if (cmd == 0x01) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSString *version = [NSString stringWithFormat:@"V%d.%d.%d",byteData[0],byteData[1],byteData[2]];
          NSLog(@"获取硬件版本号返回=%@", version);
          [self.managerDelegate rfidConfigCallback:version function:cmd];
     }
     // 获取固件版本号
     else if (cmd == 0x03) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSString *version = [NSString stringWithFormat:@"V%d.%d.%d",byteData[0],byteData[1],byteData[2]];
          NSLog(@"获取固件版本号返回=%@", version);
          [self.managerDelegate rfidConfigCallback:version function:cmd];
     }
     // 获取主板版本号
     else if (cmd == 0xc9){
          Byte *byteData = (Byte*)[uhfData bytes];
          NSString *version = [NSString stringWithFormat:@"V%d.%d.%d",byteData[0],byteData[1],byteData[2]];
          NSLog(@"获取主板版本号返回=%@", version);
          [self.managerDelegate rfidConfigCallback:version function:cmd];
     }
     // 获取设备ID
     else if (cmd == 0x05){
          //NSString *str=[dataStr substringWithRange:NSMakeRange(10, 8)];
          Byte *byteData = (Byte*)[uhfData bytes];
          NSLog(@"str==%s", byteData);
     }
     // 获取主板版本号
     else if (cmd == 0xc9) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSString *version = [NSString stringWithFormat:@"%d.%d.%d",byteData[0],byteData[1],byteData[2]];
          NSLog(@"获取主板版本号返回=%@",version);
           [self.managerDelegate rfidConfigCallback:version function:cmd];
     }
     // 设置发射功率
     else if (cmd == 0x11) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSString *setPower = [NSString stringWithFormat:@"%d",byteData[0]];
          NSLog(@"设置功率返回=%@", setPower);
          [self.managerDelegate rfidConfigCallback:setPower function:cmd];
     }
     // 获取发射功率  data: 1-30
     else if (cmd == 0x13) {
          Byte *byteData = (Byte*)[uhfData bytes];
          int power = ((byteData[2]&0xFF)*256 + (byteData[3]&0xFF))/100;
          NSLog(@"获取功率返回=%d", power);
          [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d",power] function:cmd];
     }
     // 设置跳频
     else if (cmd == 0x15) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSString *setHop = [NSString stringWithFormat:@"%d", byteData[0]];
          NSLog(@"定频设置返回=%@", setHop);
          [self.managerDelegate rfidConfigCallback:setHop function:cmd];
     }
     // 设置频段区域
     else if (cmd == 0x2d) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSString *setFrequency = [NSString stringWithFormat:@"%d", byteData[0]];
          NSLog(@"频段区域设置返回=%@", setFrequency);
          [self.managerDelegate rfidConfigCallback:setFrequency function:cmd];
     }
     // 获取频段区域
     else if (cmd == 0x2f) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSString *frequency = @"-1";
          if (byteData[0] == 1) {
               int valueStr = byteData[1];
               if (valueStr == 1) {
                    frequency = @"0";
               } else if (valueStr == 2){
                    frequency = @"1";
               } else if (valueStr == 4){
                    frequency = @"2";
               } else if (valueStr == 8){
                    frequency = @"3";
               } else if (valueStr == 16) {
                    frequency = @"4";
               } else if (valueStr == 32){
                    frequency = @"5";
               }
          }
          NSLog(@"获取区域返回=%d", byteData[0]);
          [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%@", frequency] function:cmd];
     }
     // 获取设备温度
     else if (cmd == 0x35) {
          Byte *byteData = (Byte*)[uhfData bytes];
          int t = -1;
          if(byteData[0] == 1){
               t = (byteData[1]<<8) | (byteData[2]);
               if (byteData[1] >= 0xF0)  t = -((0xFFFF-t) / 100);
               else   t = (t / 100);
          }
          NSLog(@"获取设备温度返回=%d", t);
          [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d", t] function:0x35];
     }
     // 设置过滤
     else if (cmd == 0x6F) {
          Byte *byteData = (Byte*)[uhfData bytes];
          BOOL res = byteData[0] == 1 ? YES : NO;
          NSLog(@"设置过滤返回=%d", res);
          [self.managerDelegate rfidSetFilterCallback:@"过滤" isSuccess:res];
     }
     // 设置盘点模式
     else if (cmd == 0x71) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSString *setScanModel = [NSString stringWithFormat:@"%d", byteData[0]];
          NSLog(@"盘点模式设置返回=%@", setScanModel);
          [self.managerDelegate rfidConfigCallback:setScanModel function:cmd];
     }
     // 获取盘点模式
     else if (cmd == 0x73) {
          Byte *byteData = (Byte*)[uhfData bytes];
          if (uhfData.length < 4 || byteData[0] != 1) {
               NSLog(@"获取盘点模式返回数据异常");
               [self.managerDelegate rfidConfigCallback:@"" function:cmd];
               return;
          }
          NSString *getScanModel = [NSString stringWithFormat:@"%d %d %d", byteData[1], byteData[2], byteData[3]];
          NSLog(@"盘点模式获取返回=%@", getScanModel);
          [self.managerDelegate rfidConfigCallback:getScanModel function:cmd];
     }
     // 单次盘点
     else if (cmd == 0x81) {
          NSLog(@"单次盘点返回=%@", uhfData);
          if (self.isSupportRssi) {
               [self parseUhfTagBuff_EPC_TID_USER:uhfData];
          } else {
               [self parseUhfTagBuff_EPC:uhfData];
          }
     }
     // 停止连续盘存标签
     else if (cmd == 0x8d) {
          NSLog(@"停止连续盘存标签成功");
          self.isgetLab = NO;
     }
     // 读标签
     else if (cmd == 0x85) {
          if (uhfData.length < 4) return;
          Byte *byteData = (Byte*)[uhfData bytes];
          NSMutableString *data = [NSMutableString stringWithString:@""];
          if (byteData[0] == 0 ) { // 读取失败
               if (byteData[1] == 1)      [data appendString: @"no tag"];
               else if (byteData[1] == 2) [data appendString: @"password error"];
               else if (byteData[1] == 3) [data appendString: @"read fail"];
               else                       [data appendString: @"fail"];
               [self.managerDelegate rfidReadLabelCallback:data isSuccess:NO];
          } else if(byteData[0] == 1) { // 读取成功
               NSInteger len = ((byteData[2] & 0xFF)<<8) | (byteData[3] & 0xFF);
               for (int i = 4; i < uhfData.length; i++) {
                    NSString *t = [NSString stringWithFormat:@"%02x", (byteData[i]) & 0xff];
                    [data appendString:t];
               }
               if (data.length == len*4) {
                    [self.managerDelegate rfidReadLabelCallback:data isSuccess:YES];
               } else {
                    [self.managerDelegate rfidReadLabelCallback:@"data error" isSuccess:NO];
               }
          }
     }
     // 写标签
     else if (cmd == 0x87) {
          if (uhfData.length < 2) return;
          Byte *byteData = (Byte*)[uhfData bytes];
          if (byteData[0] == 0 ) { // 写入失败
               NSString *data = @"";
               if (byteData[1] == 1)      data = @"no tag";
               else if (byteData[1] == 2) data = @"password error";
               else if (byteData[1] == 3) data = @"write fail";
               else                       data = @"fail";
               [self.managerDelegate rfidWriteLabelCallback:data isSuccess:NO];
          } else {
               [self.managerDelegate rfidWriteLabelCallback:@"success" isSuccess:YES];
          }
     }
     // 锁标签
     else if (cmd == 0x89) {
          if (uhfData.length < 2)  return;
          Byte *byteData = (Byte*)[uhfData bytes];
          if (byteData[0] == 0 ) { // 失败
               NSString *data = @"";
               if (byteData[1] == 1)      data = @"no tag";
               else if (byteData[1] == 2) data = @"password error";
               else if (byteData[1] == 3) data = @"lock fail";
               else                       data = @"fail";
               [self.managerDelegate rfidLockLabelCallback:data isSuccess:NO];
          } else {
               [self.managerDelegate rfidLockLabelCallback:@"success" isSuccess:YES];
          }
     }
     // 销毁标签
     else if (cmd == 0x8b) {
          if (uhfData.length < 2)  return;
          Byte *byteData = (Byte*)[uhfData bytes];
          if (byteData[0] == 0 ) { // 失败
               NSString *data = @"";
               if (byteData[1] == 1)      data = @"no tag";
               else if (byteData[1] == 2) data = @"password error";
               else if (byteData[1] == 3) data = @"kill fail";
               else                       data = @"fail";
               [self.managerDelegate rfidKillLabelCallback:data isSuccess:NO];
          } else {
               [self.managerDelegate rfidKillLabelCallback:@"success" isSuccess:YES];
          }
     }
     // 进入升级模式返回
     else if (cmd == 0xc1) {
          isUpgrade = true;
          Byte *byteData = (Byte*)[uhfData bytes];
          NSLog(@"进入升级模式返回=%d", byteData[0]);
          [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d", byteData[0]] function:cmd];
     }
     // 开始升级返回
     else if (cmd == 0xc3) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSLog(@"开始升级返回=%d",byteData[0]);
          [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d", byteData[0]] function:cmd];
     }
     // 发送升级数据返回
     else if (cmd == 0xc5) {
          Byte *byteData = (Byte*)[uhfData bytes];
          NSLog(@"发送升级数据返回=%d",byteData[0]);
          [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d",byteData[0]] function:cmd];
     }
     // 升级结束
     else if (cmd == 0xc7) {
          isUpgrade=false;
          Byte *byteData = (Byte*)malloc(uhfData.length);
          memcpy(byteData, [uhfData bytes], uhfData.length);
          NSLog(@"停止升级数据返回=%d",byteData[0]);
          [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d",byteData[0]] function:cmd];
     }
     //标签数据
     else if(cmd == 0xe3) {
          // [self parseReadTagDataData:uhfData];
     }
     // 连续盘点
     else if (cmd == 0xe1) {
          [self parseReadTagDataData:uhfData];
     }
     //
     else if (cmd == 0xe5) {
          Byte *byteData = (Byte*)[uhfData bytes];
          //获取电池电量
          if (self.isGetBattery && byteData[0]==0x01 && uhfData.length == 2) {
               [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d", byteData[1]] function:0xE5];
               self.isGetBattery = NO;
               NSLog(@"获取电池电量返回  %d",byteData[1]);
               return;
          }
          // 扫描二维码
          if (self.isCodeLab  && byteData[0] == 0x02) {
               NSLog(@"扫描二维码  %s", byteData);
               if(uhfData.length<2)     return;
               //[self.managerDelegate rfidConfigCallbank:[NSString stringWithFormat:@"%s",byteData] function:0xE502];
               NSData *barcodeData = [uhfData subdataWithRange:NSMakeRange(1, uhfData.length - 1)];
               
               NSLog(@"barcodeData = %@", barcodeData);
               NSString *barcodeString;
               if (self.barcodeParsingType == BarcodeParsingOfUTF8) {
                    barcodeString = [[NSString alloc]initWithData:barcodeData encoding:NSUTF8StringEncoding];
               } else  if (self.barcodeParsingType == BarcodeParsingOfGB2312) {
                    barcodeString = [[NSString alloc]initWithData:barcodeData encoding:kCFStringEncodingGB_2312_80];
               } else {
                    barcodeString = [[NSString alloc]initWithData:barcodeData encoding:NSASCIIStringEncoding];
               }
               //= [[NSString alloc]initWithData:barcodeData encoding:NSASCIIStringEncoding];
               if (self.isBarcodeCodeID) {
                    NSString *codeId;
                    if ([barcodeString hasPrefix:@"P"]) {
                         codeId = [barcodeString substringToIndex:3];
                         barcodeString = [NSString stringWithFormat:@"%@%@",
                                          [AppHelper getBarcodeTypeByCodeID:codeId],
                                          [barcodeString substringFromIndex:3]
                         ];
                    } else {
                         codeId = [barcodeString substringToIndex:1];
                         barcodeString = [NSString stringWithFormat:@"%@%@",
                                          [AppHelper getBarcodeTypeByCodeID:codeId],
                                          [barcodeString substringFromIndex:1]
                         ];
                    }
               }
               if (self.barcodeParsingType == BarcodeParsingOfASCII) {
                    [self.managerDelegate rfidBarcodeLabelCallBack: [barcodeString dataUsingEncoding:NSASCIIStringEncoding]];
               } else if (self.barcodeParsingType == BarcodeParsingOfUTF8) {
                    [self.managerDelegate rfidBarcodeLabelCallBack: [barcodeString dataUsingEncoding:NSUTF8StringEncoding]];
               } else if (self.barcodeParsingType == BarcodeParsingOfGB2312) {
                    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
                    [self.managerDelegate rfidBarcodeLabelCallBack: [barcodeString dataUsingEncoding:enc]];
               } else {
                    [self.managerDelegate rfidBarcodeLabelCallBack: barcodeData];
               }
               return;
          }
          //开启蜂鸣器
          if (self.isOpenBuzzer) {
               [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d",byteData[0]] function:0xE500];
               self.isOpenBuzzer = NO;
               NSLog(@"开启蜂鸣器返回=%d",byteData[0]);
          }
          //关闭蜂鸣器
          if (self.isCloseBuzzer) {
               [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d",byteData[0]] function:0xE501];
               self.isCloseBuzzer = NO;
               NSLog(@"关闭蜂鸣器返回=%d",byteData[0]);
          }
     }
     // 按键
     else if (cmd == 0xe6) {
          Byte *byteData = (Byte*)[uhfData bytes];
          [self.managerDelegate rfidConfigCallback:[NSString stringWithFormat:@"%d",byteData[0]] function:cmd];
     }
}

- (void)parseReadTagDataData:(NSData *)tempData {
     if (tempData.length < 5) {
          return;   //标签数据长度小于5则直接返回，此为无效数据。
     }
     // 00 01         01             0b          1c00160800000000fd9001
     // [0]-[1]:索引  [2]:表示标签个数  [3]:标签长度  [4]:标签数据开始
     if(isDebug)    NSLog(@"去除头尾后的EPCTIDUSERDataData = %@",[AppHelper dataToHex:tempData]);
     Byte *dataBytes = (Byte *)[tempData bytes];
     int count = dataBytes[2] & 0xFF;// 标签个数
     int epc_lenIndex = 3;// epc长度索引
     int epc_startIndex = 4; // 截取epc数据的起始索引
     int epc_endIndex = 0;// 截取epc数据的结束索引
     for (NSInteger k = 0; k < count; k ++) {
          epc_startIndex = epc_lenIndex + 1;
          epc_endIndex = epc_startIndex + (dataBytes[epc_lenIndex] & 0xFF); // epc的起始索引加长度得到结束索引
          if (epc_endIndex > tempData.length) {
               break;
          } else {
               Byte epcBuff[epc_endIndex - epc_startIndex];
               [tempData getBytes:epcBuff range:NSMakeRange(epc_startIndex, epc_endIndex - epc_startIndex)];
               NSData *epcDataBuff = [NSData dataWithBytes:epcBuff length:epc_endIndex - epc_startIndex];
               // NSLog(@"--- epcDataBuff = %@", epcDataBuff);
               if (self.isSupportRssi) {
                    [self parseUhfTagBuff_EPC_TID_USER:epcDataBuff];
               } else {
                    [self parseUhfTagBuff_EPC:epcDataBuff];
               }
          }
          epc_lenIndex = epc_endIndex;
          if (epc_endIndex >= tempData.length) {
               break;
          }
     }
}

- (void) parseUhfTagBuff_EPC:(NSData *) tagBuff {
     if (tagBuff.length < 3)  return;
     NSLog(@"tagBuff=%@", tagBuff);
     //获取EPC
     NSString *epcHex=[AppHelper dataToHex:tagBuff];
     UHFTagInfo *tag = [UHFTagInfo tagWithEpc:epcHex];
     [self.managerDelegate rfidTagInfoCallback: tag];
}

- (void)parseUhfTagBuff_EPC_TID_USER:(NSData *)tagsBuff {
     if (tagsBuff.length < 3) return;
     NSString *allData = [AppHelper dataToHex:tagsBuff];//整个数据
     NSInteger length = tagsBuff.length;
     NSString *pc = [allData substringWithRange:NSMakeRange(0, 4)];
     int epclen = (((int)[AppHelper getHexToDecimal:[pc substringToIndex:2]])>>3) * 2;
     int uiiLen = epclen + 2;
     int tidLen = 12;
     int rssiLen = 2;
     int antLen = 1;
     int endLen = allData.length % 4;   // 最后可能会多出两位字符为天线，去掉
     
     //if(isDebug)    NSLog(@"allData=%@, epcLen=%d", allData, epclen);
     if (length >= uiiLen + 2 && epclen > 0) {
          Boolean isOnlyEPC = (length < (uiiLen + rssiLen + tidLen) ? YES : NO); //只有epc
          Boolean isEPCAndTid = (length == (uiiLen + rssiLen + tidLen) ||  length ==  (uiiLen + rssiLen + tidLen + antLen) ? YES : NO); //只有epc 和 tid
          Boolean isEPCAndTidUser = (length > (uiiLen + rssiLen + tidLen + antLen) ? YES : NO); // epc + tid + user
          
          // pc    epc                         tid                         user                        rssi
          // 3000  11112222 33334444 56556666  e2003412 0130fc00 0b45db85  00000000 00000000 00000000  fe18
          NSString *epc = [allData substringWithRange:NSMakeRange(4, epclen*2)];
          NSString *tid = @"";
          NSString *user = @"";
          if(isEPCAndTid || isEPCAndTidUser) {
               tid = [allData substringWithRange:NSMakeRange(uiiLen*2, tidLen*2)];
          }
          if(isEPCAndTidUser) {
               NSInteger userLen = allData.length - uiiLen * 2 - tidLen * 2 - rssiLen * 2 - endLen;
               user = [allData substringWithRange:NSMakeRange(uiiLen*2 + tidLen*2, userLen)];
          }
          NSString *rssiHex = [allData substringWithRange:NSMakeRange(allData.length - rssiLen*2 - endLen, rssiLen*2)];
          NSString *rssi = [NSString stringWithFormat:@"%@", [AppHelper getRssiByHexStr: rssiHex]];
          //NSLog(@"rssiHex=%@,  rssi=%@", rssiHex, rssi);
          
          UHFTagInfo *tag = [UHFTagInfo tagWithEpc:epc tid:tid user:user pc:pc rssi:rssi];
          //if(isDebug)    NSLog(@"%@", tag.description);
          [self.managerDelegate rfidTagInfoCallback:tag];
     }
}




#pragma mark 写数据后回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic  error:(NSError *)error {
     if (error) {
          NSLog(@"Error writing characteristic value: %@", [error localizedDescription]);
          return;
     }
     NSLog(@"写入%@成功",characteristic);
}

-(void)notifyCharacteristic:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
     [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
     [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}


- (NSString *)getVisiableIDUUID:(NSString *)peripheralIDUUID {
     if (!peripheralIDUUID.length) {
          return @"";
     }
     peripheralIDUUID = [peripheralIDUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
     peripheralIDUUID = [peripheralIDUUID stringByReplacingOccurrencesOfString:@"<" withString:@""];
     peripheralIDUUID = [peripheralIDUUID stringByReplacingOccurrencesOfString:@">" withString:@""];
     peripheralIDUUID = [peripheralIDUUID stringByReplacingOccurrencesOfString:@" " withString:@""];
     peripheralIDUUID = [peripheralIDUUID substringFromIndex:peripheralIDUUID.length - 12];
     peripheralIDUUID = [peripheralIDUUID uppercaseString];
     NSData *bytes = [peripheralIDUUID dataUsingEncoding:NSUTF8StringEncoding];
     Byte * myByte = (Byte *)[bytes bytes];
     
     
     NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
     for (int i = 5; i >= 0; i--) {
          [result appendString:[NSString stringWithFormat:@"%@",[[NSString alloc] initWithBytes:&myByte[i*2] length:2 encoding:NSUTF8StringEncoding] ]];
     }
     
     for (int i = 1; i < 6; i++) {
          [result insertString:@":" atIndex:3*i-1 ];
     }
     
     return result;
}


#pragma mark - Setter and Getter

- (CBCentralManager *)centralManager {
     if (!_centralManager ) {
          _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
     }
     return _centralManager;
}

- (NSMutableArray *)peripheralArray {
     if (!_peripheralArray) {
          _peripheralArray = [[NSMutableArray alloc] init];
     }
     return _peripheralArray;
}

  

- (NSString *)centralManagerStateDescribe:(CBManagerState)state {
     NSString *descStr = @"";
     switch (state) {
          case CBManagerStateUnauthorized:
               
               break;
          case CBManagerStatePoweredOff:
               descStr = @"请打开蓝牙";
               break;
          default:
               break;
     }
     return descStr;
}

- (void)setGen2WithTarget:(char)Target action:(char)Action t:(char)T qq:(char)Q_Q startQ:(char)StartQ minQ:(char)MinQ maxQ:(char)MaxQ dd:(char)D_D cc:(char)C_C pp:(char)P_P sel:(char)Sel session:(char)Session gg:(char)G_G lf:(char)LF {
     self.isSetGen2Data = YES;
     NSData *byteData = [self setGen2DataWithTarget:Target action:Action t:T qq:Q_Q startQ:StartQ minQ:MinQ maxQ:MaxQ dd:D_D cc:C_C pp:P_P sel:Sel session:Session gg:G_G lf:LF];
     [self sendDataToBle:byteData];
}

- (NSData *)setGen2DataWithTarget:(char)Target action:(char)Action t:(char)T qq:(char)Q_Q startQ:(char)StartQ minQ:(char)MinQ maxQ:(char)MaxQ dd:(char)D_D cc:(char)C_C pp:(char)P_P sel:(char)Sel session:(char)Session gg:(char)G_G lf:(char)LF {
     Byte sbuf[4];
     sbuf[0] = (((Target & 0x07) << 5) | ((Action & 0x07) << 2) | ((T & 0x01) << 1) | ((Q_Q & 0x01) << 0));
     sbuf[1] = (((StartQ & 0x0f) << 4) | ((MinQ & 0x0f) << 0));
     sbuf[2] = (((MaxQ & 0x0f) << 4) | ((D_D & 0x01) << 3) | ((C_C & 0x03) << 1) | ((P_P & 0x01) << 0));
     sbuf[3] = (((Sel & 0x03) << 6) | ((Session & 0x03) << 4) | ((G_G & 0x01) << 3) | ((LF & 0x07) << 0));
     //return sbuf;
     NSData *sbufData = [NSData dataWithBytes:sbuf length:4];
     return [self makeSendDataWithCmd:0x20 dataBuf:sbufData];
}

- (NSData *)makeSendDataWithCmd:(int)cmd dataBuf:(NSData*)databuf {
     Byte outSendbuf[databuf.length + 8];
     int idx = 0;
     int crcValue = 0;
     outSendbuf[idx++] =  0xC8;
     outSendbuf[idx++] =  0x8C;
     outSendbuf[idx++] =  ((8 + databuf.length) / 256);
     outSendbuf[idx++] =  ((8 + databuf.length) % 256);
     outSendbuf[idx++] =  cmd;
     for (int k = 0; k < databuf.length; k++) {
          Byte *dataBufBytes = (Byte *)[databuf bytes];
          outSendbuf[idx++] = dataBufBytes[k];
     }
     for (int i = 2; i < idx; i++) {
          crcValue ^= outSendbuf[i];
     }
     outSendbuf[idx++] = crcValue;
     outSendbuf[idx++] = 0x0D;
     outSendbuf[idx++] = 0x0A;
     return [NSData dataWithBytes:outSendbuf length:databuf.length + 8];
}

- (void)getGen2SendData {
     self.isGetGen2Data = YES;
     Byte sbuf[0];
     NSData *bytesData = [self makeSendDataWithCmd:0x22 dataBuf:[NSData dataWithBytes:sbuf length:0]];
     [self sendDataToBle:bytesData];
}

- (void)parseGetGen2DataWithData:(NSData *)data {
     NSData *parsedData = [BluetoothUtil parseDataWithOriginalStr:data cmd:0x23];
     if (parsedData && parsedData.length >= 4) {
          Byte buff[14];
          Byte *rbuf = (Byte *)[parsedData bytes];
          buff[0] = ((rbuf[0] & 0xe0) >> 5);
          buff[1] = ((rbuf[0] & 0x1c) >> 2);
          buff[2] = ((rbuf[0] & 0x02) >> 1);
          buff[3] = ((rbuf[0] & 0x01) >> 0);
          buff[4] = ((rbuf[1] & 0xf0) >> 4);
          buff[5] = (rbuf[1] & 0x0f);
          buff[6] = ((rbuf[2] & 0xf0) >> 4);
          buff[7] = ((rbuf[2] & 0x08) >> 3);
          buff[8] = ((rbuf[2] & 0x06) >> 1);
          buff[9] = (rbuf[2] & 0x01);
          buff[10] = ((rbuf[3] & 0xc0) >> 6);
          buff[11] = ((rbuf[3] & 0x30) >> 4);
          buff[12] = ((rbuf[3] & 0x08) >> 3);
          buff[13] = (rbuf[3] & 0x07);
          parsedData = [NSData dataWithBytes:buff length:14];
     }
     if (self.managerDelegate && [self.managerDelegate respondsToSelector:@selector(receiveGetGen2WithData:)]) {
          [self.managerDelegate receiveGetGen2WithData:parsedData];
     }
}



- (void)parseSetGen2DataWithData:(NSData *)data {
     BOOL parseResult = NO;
     NSData *parsedData = [BluetoothUtil parseDataWithOriginalStr:data cmd:0x21];
     if (parsedData && parsedData.length > 0) {
          Byte *bytes = (Byte *)parsedData.bytes;
          if (bytes[0] == 0x01) {
               parseResult = YES;
          }
     }
     if (self.managerDelegate && [self.managerDelegate respondsToSelector:@selector(receiveSetGen2WithResult:)]) {
          [self.managerDelegate receiveSetGen2WithResult:parseResult];
     }
}



- (void)parseFilterDataWithData:(NSData *)data {
     BOOL parseResult = NO;
     NSData *parseData = [BluetoothUtil parseDataWithOriginalStr:data cmd:0x6F];
     if (parseData && parseData.length > 0) {
          Byte *bytes = (Byte *)parseData.bytes;
          if (bytes[0] == 0x01) {
               parseResult = YES;
          }
     }
     if (self.managerDelegate && [self.managerDelegate respondsToSelector:@selector(receiveSetFilterWithResult:)]) {
          [self.managerDelegate receiveSetFilterWithResult:parseResult];
     }
}

- (void)setRFLinkWithMode:(int)mode {
     Byte saveFlag = 1;
     Byte sbuf[3] = {0};
     sbuf[0] = 0x00;
     sbuf[1] = saveFlag;
     sbuf[2] = (Byte)mode;
     NSData *rfLinkSetData = [NSData dataWithBytes:sbuf length:3];
     NSData *sendRFLinkData = [self makeSendDataWithCmd:0x52 dataBuf:rfLinkSetData];
     [self sendDataToBle:sendRFLinkData];
}

- (void)parseSetRFLinkWithData:(NSData *)data {
     BOOL parseResult = NO;
     NSData *parseData = [BluetoothUtil parseDataWithOriginalStr:data cmd:0x53];
     if (parseData && parseData.length > 0) {
          Byte *parseBytes = (Byte *)[parseData bytes];
          if (parseBytes[0] == 0x01) {
               parseResult = YES;
          }
     }
     if (self.managerDelegate && [self.managerDelegate respondsToSelector:@selector(receiveSetRFLinkWithResult:)]) {
          [self.managerDelegate receiveSetRFLinkWithResult:parseResult];
     }
}

- (void)getRFLinkSendData {
     Byte sbuf[2] = {0};
     sbuf[0] = 0x00;
     sbuf[1] = 0x00;
     NSData *sendData = [NSData dataWithBytes:sbuf length:2];
     NSData *sendToBleData = [self makeSendDataWithCmd:0x54 dataBuf:sendData];
     [self sendDataToBle:sendToBleData];
}

- (void)parseGetRFLinkWithData:(NSData *)data {
     int resultData = 0;
     NSData *parseData = [BluetoothUtil parseDataWithOriginalStr:data cmd:0x55];
     if (parseData && parseData.length >= 3) {
          Byte *bytes = (Byte *)[parseData bytes];
          if (bytes[0] == 0x01) {
               resultData = bytes[2] & 0xff;
          }
     } else {
          resultData = -1;
     }
     if (self.managerDelegate && [self.managerDelegate respondsToSelector:@selector(receiveGetRFLinkWithData:)]) {
          [self.managerDelegate receiveGetRFLinkWithData:resultData];
     }
}

- (void)dealloc {
     [_connectTime invalidate];
     _connectTime = nil;
}

-(void) getBlutoothList {
     // 2EDCDAAC-26CE-2B9B-4248-F9468812CE4A
     
     NSLog(@"getBluetoothList----");
     
     NSArray<CBUUID *> *serviceUUIDs = @[[CBUUID UUIDWithString:@"2EDCDAAC-26CE-2B9B-4248-F9468812CE4A"]];
     NSArray<CBPeripheral *> *connectedPeripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
     NSLog(@"connectedPeripherals=%@", connectedPeripherals);
     // 遍历已连接的蓝牙设备
     for (CBPeripheral *peripheral in connectedPeripherals) {
          // 处理已连接设备的逻辑
          NSLog(@"已连接设备名称：%@", peripheral.name);
     }
}

- (void)stopBluetoothScan {
    [self.centralManager stopScan];
}

- (NSArray<CBPeripheral *> *)getBluetoothList {
    NSLog(@"getBluetoothList----");
    
    NSArray<CBUUID *> *serviceUUIDs = @[[CBUUID UUIDWithString:@"2EDCDAAC-26CE-2B9B-4248-F9468812CE4A"],[CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"]];
    NSArray<CBPeripheral *> *connectedPeripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
    
    for (CBPeripheral *peripheral in connectedPeripherals) {
        NSLog(@"Connected device name: %@", peripheral.name);
    }
    
    return connectedPeripherals;
}

@end
