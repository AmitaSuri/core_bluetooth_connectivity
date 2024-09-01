//
//  RFIDBlutoothManager.h
//  RFID_ios
//
//  Created by   on 2018/4/26.
//  Copyright © 2018年  . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEModel.h"
#import "BluetoothUtil.h"
#import "UHFTagInfo.h"
#import <ExternalAccessory/ExternalAccessory.h>



@protocol FatScaleBluetoothManager <NSObject>

@optional

///设置过滤数据回调
- (void)rfidSetFilterCallback:(NSString *)dataStr isSuccess:(BOOL)flag;
///盘点标签返回数据
- (void)rfidTagInfoCallback:(UHFTagInfo *)tag;

- (void)rfidBarcodeLabelCallBack:(NSData *)data;
///读写器参数设置数据回调
- (void)rfidConfigCallback:(NSString *)data  function:(int)function;
///读标签数据回调
- (void)rfidReadLabelCallback:(NSString *)dataStr isSuccess:(BOOL)flag;
///写标签数据回调
- (void)rfidWriteLabelCallback:(NSString *)dataStr isSuccess:(BOOL)flag;
///锁标签数据回调
- (void)rfidLockLabelCallback:(NSString *)dataStr isSuccess:(BOOL)flag;
///销毁标签数据回调
- (void)rfidKillLabelCallback:(NSString *)dataStr isSuccess:(BOOL)flag;


///蓝牙链接失败
- (void)connectBluetoothFailWithMessage:(NSString *)msg;
///蓝牙连接超时
- (void)connectBluetoothTimeout;
///链接到数据
- (void)receiveDataWith:(id)parseModel dataSource:(NSMutableArray *)dataSource;
///列表数据
- (void)receiveDataWithBLEmodel:(BLEModel *)model result:(NSString *)result;
///首页标签数据
//- (void)receiveDataWithBLEDataSource:(NSMutableArray *)dataSource allCount:(NSInteger)allCount countArr:(NSMutableArray *)countArr dataSource1:(NSMutableArray *)dataSource1 countArr1:(NSMutableArray *)countArr1 dataSource2:(NSMutableArray *)dataSource2 countArr2:(NSMutableArray *)countArr2;
//
//- (void)receiveDataWithBLEDataSource:(NSMutableArray *)dataSourceEPC dataSourceTID:(NSMutableArray *)dataSourceTID dataSourceUSER:(NSMutableArray *)dataSourceUSER RSSI:(NSInteger)RSSI ;

///首页标签数据
- (void)receiveRcodeDataWithBLEDataSource:(NSMutableArray *)dataSource;
///
- (void)receiveMessageWithtype:(NSString *)typeStr dataStr:(NSString *)dataStr;
///连接外设成功
- (void)connectPeripheralSuccess:(NSString *)nameStr;
///断开外设
-(void)disConnectPeripheral;
///更改蓝牙设备名称成功
- (void)updateBLENameSuccess;
/// 设置Gen2是否成功
- (void)receiveSetGen2WithResult:(BOOL)result;
/// 获取Gen2
- (void)receiveGetGen2WithData:(NSData *)resultData;
/// 设置Filter是否成功
- (void)receiveSetFilterWithResult:(BOOL)result;
/// 设置RFLink
- (void)receiveSetRFLinkWithResult:(BOOL)result;
/// 获取RFLink
- (void)receiveGetRFLinkWithData:(int)data;

@end



@protocol PeripheralAddDelegate <NSObject>

@optional

- (void)addPeripheralWithPeripheral:(BLEModel *)peripheralModel;

@end

/// 条码解析类型
typedef NS_ENUM(NSInteger,BarcodeParsingType) {
    BarcodeParsingOfASCII = 0,
    BarcodeParsingOfUTF8    = 1,
    BarcodeParsingOfGB2312  = 2
};

/// 标签数据区域
typedef NS_ENUM(NSInteger,BANK) {
    BANK_RESERVE = 0,
    BANK_EPC = 1,
    BANK_TID = 2,
    BANK_USER = 3
};

@interface RFIDBlutoothManager : NSObject

@property (nonatomic, assign) BOOL connectDevice;

+ (instancetype)shareManager;



@property (nonatomic,readonly)BOOL isgetLab;//是否是获取标签

@property (nonatomic,assign)BOOL isSupportRssi;//是否是获取升级后的标签

@property (nonatomic,assign)BOOL isBLE40;//蓝牙4.0

@property (nonatomic,assign)BOOL isGetVerson;//是否是获取版本号

@property (nonatomic,assign)BOOL isGetBattery;//是否是获取电量

@property (nonatomic,assign)BOOL isCodeLab; //扫描二维码

@property (nonatomic,assign)BOOL isTemperature; //获取温度

@property (nonatomic,assign)BOOL isSetEmissionPower; //发射功率

@property (nonatomic,assign)BOOL isGetEmissionPower; //获取发射功率

@property (nonatomic,assign)BOOL isOpenBuzzer; //开启蜂鸣器

@property (nonatomic,assign)BOOL isCloseBuzzer; //关闭蜂鸣器

@property (nonatomic,assign)BOOL isSingleSaveLable; //单次盘点标签

@property (nonatomic,assign)BOOL isSetTag; //设置读取标签格式
@property (nonatomic,assign)BOOL isGetTag; //获取读取标签格式


///////////// NLAB -----   2021/3/15

/** isSetGen2Data */
@property (assign,nonatomic) BOOL isSetGen2Data;
/** isGetGen2Data */
@property (assign,nonatomic) BOOL isGetGen2Data;

/////////////
//@property (nonatomic, strong) NSMutableData *byteData;
/** tagData */
//@property (nonatomic, strong) NSMutableData *tagData;
@property (nonatomic, strong) NSMutableData *uhfData;

@property (nonatomic,copy)NSString *tagTypeStr;//判断连续获取新标签的时候返回的类型是epc还是epc+tid还是epc+tid+user

@property (nonatomic,copy)NSString *typeStr;

@property (nonatomic,strong)NSMutableString *getMiStr;//获取的SM4密码

@property (nonatomic,strong)NSMutableString *encryStr;//SM4加密

@property (nonatomic,strong)NSMutableString *dencryStr;//SM4解密

@property (nonatomic,strong)NSMutableString *USERStr;//USER解密

@property (nonatomic,strong)NSMutableString *readStr;//读数据




- (void)startBleScan;                // 开启蓝牙扫描
- (void)cancelConnectBLE;             //断开连接
- (void)closeBleAndDisconnect;       // 停止蓝牙扫描&断开

///获取固件版本号
//-(void)getFirmwareVersion2;
///获取硬件版本号
-(void)getHardwareVersion;
///获取固件版本号
-(void)getFirmwareVersion;
///获取主板版本号
-(void) getReaderMainboardVersion;
///获取电池电量
-(void)getBatteryLevel;
///获取设备当前温度
-(void)getServiceTemperature;
///开启2D扫描
-(void)start2DScan;
///开启连续2D扫描
-(void)startContinuity2DScan;
///关闭连续2D扫描
-(void)stopContinuity2DScan;
///获取设备ID
-(void)getServiceID;
///软件复位
-(void)softwareReset;
///开启蜂鸣器
-(void)setOpenBuzzer;
///关闭蜂鸣器
-(void)setCloseBuzzer;
/// 设置透传命令
-(BOOL) setBarcodeParmameter:(NSString *) parmameter;
/// 设置超时时间
-(BOOL) setBarcodeTimeout: (NSString *) timeout;
///设置CodeID
-(BOOL) setBarcodeCodeId:(BOOL) codeId;
/** 是否打开isBarcodeCodeID */
@property (assign,nonatomic) BOOL isBarcodeCodeID;


///设置二维码解析方式
-(void) setBarcodeParsingType:(BarcodeParsingType)type;
///获取二维码解析方式
-(BarcodeParsingType) getBarcodeParsingType:(BarcodeParsingType)type;

///设置标签读取格式
-(void)setEpcTidUserWithAddressStr:(NSString *)addressStr length:(NSString *)lengthStr epcStr:(NSString *)epcStr;
///获取标签读取格式
-(void)getEpcTidUser;

///设置发射功率
-(void)setLaunchPowerWithstatus:(NSString *)status antenna:(NSString *)antenna readStr:(NSString *)readStr writeStr:(NSString *)writeStr;
///获取当前发射功率
-(void)getLaunchPower;
///跳频设置
-(void)detailChancelSettingWithstring:(NSString *)str;
///获取当前跳频设置状态
-(void)getdetailChancelStatus;

///区域设置
-(void)setRegionWithsaveStr:(NSString *)saveStr regionStr:(NSString *)regionStr;

///获取区域设置
-(void)getRegion;

/**
 过滤数据
 
 @param bank   过滤区域.
 @param ptr     过滤起始地址(bit).
 @param len     过滤长度(bit)，要求小于等于设置的过滤数据长度(bit).
 @param data   过滤数据，16进制数据.
 */
- (void)setFilterWithBank:(BANK)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data;

///单次盘存标签
-(void)singleInventory;

///过滤单次盘存标签
//-(void)singleInventoryWithBank:(BANK)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data;

///连续盘存标签
-(void)startInventory;

///过滤连续盘存标签
//-(void)startInventoryWithBank:(BANK)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data;

-(void)stopInventory;//停止连续盘存标签

/**
 password:4个字节的访问密码.
 MMBstr:掩码的数据区 (0x00为Reserve 0x01为EPC，0x02表示TID，0x03表示USR).
 MSAstr:为掩码的地址。
 MDLstr:为掩码的长度。
 Mdata:为掩码数据。
 MBstr:为要写的数据区(0x00为Reserve 0x01为EPC，0x02表示TID，0x03表示USR)
 SAstr :为要写数据区的地址。
 DLstr :为要写的数据长度(字为单位)。
 isfilter表示是否过滤
 */
-(void)readLabelMessageWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata MBstr:(NSString *)MBstr SAstr:(NSString *)SAstr DLstr:(NSString *)DLstr isfilter:(BOOL)isfilter;//读标签数据区   成功

/**
 password:4个字节的访问密码.
 MMBstr:掩码的数据区 (0x00为Reserve 0x01为EPC，0x02表示TID，0x03表示USR).
 MSAstr:为掩码的地址。
 MDLstr:为掩码的长度。
 Mdata:为掩码数据。
 MBstr:为要写的数据区(0x00为Reserve 0x01为EPC，0x02表示TID，0x03表示USR)
 SAstr :为要写数据区的地址。
 DLstr :为要写的数据长度(字为单位)。
 writeData :为写入的数据，高位在前。 isfilter表示是否过滤
 */
-(void)writeLabelMessageWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata MBstr:(NSString *)MBstr SAstr:(NSString *)SAstr DLstr:(NSString *)DLstr writeData:(NSString *)writeData isfilter:(BOOL)isfilter;//写标签数据区   成功

/**
 AP 为标签的 AccPwd 值;MMB 为启动过滤操作的 bank 号，
 0x01 表 示 EPC，0x02 表示 TID，0x03 表示 USR，其他值为非法值;
 MSA 为启动过滤 操作的起始地址，单位为 bit;
 MDL为启动过滤操作的过滤数据长度，单位为 bit，0x00 表示无过滤;
 MData 为启动过滤时的数据，单位为字节，若 MDL 不足整数 倍字节，不足位低位补 0;
 LD 共 3 个字节 24bit，其中，高 4bit 无效，第 0~9bit(共10bit)为 Action 位，第 10~19bit(共 10bit)为 mask 位 isfilter表示是否过滤
 */
-(void)lockLabelWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata ldStr:(NSString *)ldStr isfilter:(BOOL)isfilter;//Lock标签

/**
 KP 为标签的 KillPwd 值;
 MMB 为启动过滤操作的 bank 号，0x01 表 示 EPC，0x02 表示 TID，0x03 表示 USR，其他值为非法值;
 MSA 为启动过滤 操作的起始地址，单位为 bit;
 MDL为启动过滤操作的过滤数据长度，单位为 bit， 0x00 表示无过滤;
 MData 为启动过滤时的数据，单位为字节，若 MDL 不足整数 倍字节，不足位低位补 0;
 当标签的 KillPwd 区的值为 0x00000000 时，标签会忽 略 kill 命令，kill 命令不会成功 isfilter表示是否过滤
 */
-(void)killLabelWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata isfilter:(BOOL)isfilter;//kill标签

///获取标签数据 可以
-(void)getLabMessage;
-(void)setSM4PassWordWithmodel:(NSString *)model password:(NSString *)password originPass:(NSString *)originPass;//设置密钥   可以
-(void)getSM4PassWord;//获取密钥 可以

-(void)encryptionPassWordwithmessage:(NSString *)message;//SM4数据加密  可以
-(void)decryptPassWordwithmessage:(NSString *)message;//SM4数据解密  可以

-(void)encryptionUSERWithaddress:(NSString *)address lengthStr:(NSString *)lengthStr dataStr:(NSString *)dataStr;//USER加密  可以
-(void)decryptUSERWithaddress:(NSString *)address lengthStr:(NSString *)lengthStr;//USER解密 可以


-(void)enterUpgradeMode;//进入升级模式
-(void)enterUpgradeAcceptData;//进入升级接收数据
-(void)enterUpgradeSendtDataWith:(NSString *)dataStr;//进入升级发送数据
-(void)sendtUpgradeDataWith:(NSData *)dataStr;//发送升级数据

-(void)exitUpgradeMode;//退出升级模式


- (void)setFatScaleBluetoothDelegate:(id<FatScaleBluetoothManager>)delegate;
- (void)setPeripheralAddDelegate:(id<PeripheralAddDelegate>)delegate;
- (void)bleDoScan;
- (void)connectPeripheral:(CBPeripheral *)peripheral macAddress:(NSString *)macAddress;


- (Byte )getBye8:(Byte[])data;
- (void)sendDataToBle:(NSData *)data;

- (void)setGen2WithTarget:(char)Target action:(char)Action t:(char)T qq:(char)Q_Q startQ:(char)StartQ minQ:(char)MinQ maxQ:(char)MaxQ dd:(char)D_D cc:(char)C_C pp:(char)P_P sel:(char)Sel session:(char)Session gg:(char)G_G lf:(char)LF;
- (void)getGen2SendData;


- (void)setRFLinkWithMode:(int)mode;
- (void)getRFLinkSendData;
//- (void)clearCacheTag;
- (void)parseKeyDown:(NSData *) data;
//- (NSData *)setFilterSendDataWithUfBank:(char)ufBank ufPtr:(int)ufPtr dataLen:(int)datalen hexDataBuf:(NSString *)hexDatabuf;





///连续盘存标签
//-(void)startInventory;
////停止连续盘存标签
//-(void)stopInventory;
///升级第一步：进入升级模式 1:表示rfid固件， 2:表示主板固件
- (void)enterUpgradeMode:(int) firmwareType;
///升级第二步：开始升级
- (void)startUpgrade;
///升级第三步：发送升级数据，hexdata为64个字节的十六进制数据(也就是128个字符)。
- (void)sendUpgradeData:(NSString *)hexdata;
///升级第四步：结束升级
- (void)stopUpgrade;

- (void)stopBluetoothScan;

-(void) getBlutoothList;

- (NSArray<CBPeripheral *> *)getBluetoothList;

@end
