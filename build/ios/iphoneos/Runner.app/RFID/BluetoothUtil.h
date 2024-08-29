//
//  BluetoothUtil.h
//  RFID_ios
//
//  Created by   on 2018/4/26.
//  Copyright © 2018年  . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFIDBlutoothManager.h"

@interface BluetoothUtil : NSObject

@property (nonatomic,copy)NSString *typeStr;

+ (instancetype)shareManager;

///  二进制转十进制
+ (NSString *)toDecimalWithBinary:(NSString *)binary;

///16进制String和2进制String互转
+ (NSString *)getBinaryByhex:(NSString *)hex binary:(NSString *)binary;

///普通字符转16进制
+ (NSString *)hexStringFromString:(NSString *)string;

/// 十六进制转换为普通字符串的
+ (NSString *)stringFromHexString:(NSString *)hexString;

///nsdata转成16进制字符串
+ (NSString*)stringWithHexBytes2:(NSData *)sender;

///将16进制数据转化成NSData
+ (NSData*) hexToBytes:(NSString *)string;

///数字转十六进制字符串
- (NSString *)stringWithHexNumber:(NSUInteger)hexNumber;

///十进制转二进制
+ (NSString *)toBinarySystemWithDecimalSystem:(NSInteger)decimal;

///  二进制转十进制
+ (NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary;

+(NSString *)getTimeStringWithTimeData:(NSInteger)timeData;

+(NSMutableArray *)getSixteenNumberWith:(NSString *)str;

+(NSString *)becomeNumberWith:(NSString *)str;

+(NSInteger )getzhengshuWith:(NSString *)str;

+(NSString *)getTagCountWith:(NSString *)str;

///解析标签
+(NSMutableArray *)getLabTagWith:(NSString *)tagStr dataSource:(NSMutableArray *)dataSource countArr:(NSMutableArray *)countArr;

///解析标签2
+(NSMutableArray *)getNewLabTagWith:(NSString *)tagStr dataSource:(NSMutableArray *)dataSource countArr:(NSMutableArray *)countArr dataSource1:(NSMutableArray *)dataSource1 countArr1:(NSMutableArray *)countArr1 dataSource2:(NSMutableArray *)dataSource2 countArr2:(NSMutableArray *)countArr2;

///获取固件版本号
+(NSData *)getFirmwareVersion2;
///获取电池电量
+(NSData *)getBatteryLevel;
///获取设备当前温度
+(NSData *)getServiceTemperature;
///开启2D扫描
+(NSData *)start2DScan;
///开启连续2D扫描
+(NSData *)startContinuous2DScan;
///关闭连续2D扫描
+(NSData *)stopContinuous2DScan;
///获取硬件版本号
+(NSData *)getHardwareVersion;
///获取固件版本号
+(NSData *)getFirmwareVersion;
///获取设备ID
+(NSData *)getServiceID;
///软件复位
+(NSData *)softwareReset;
///开启蜂鸣器
+(NSData *)openBuzzer;
///关闭蜂鸣器
+(NSData *)closeBuzzer;
///设置标签读取格式
+(NSData *)setEpcTidUserWithAddressStr:(NSString *)addressStr length:(NSString *)lengthStr EPCStr:(NSString *)ePCStr;
///获取标签读取格式
+(NSData *)getEpcTidUser;

///设置发射功率
+(NSData *)setLaunchPowerWithstatus:(NSString *)status antenna:(NSString *)antenna readStr:(NSString *)readStr writeStr:(NSString *)writeStr;
///获取当前发射功率
+(NSData *)getLaunchPower;
///跳频设置
+(NSData *)detailChancelSettingWithstring:(NSString *)str;
///获取当前跳频设置状态
+(NSData *)getdetailChancelStatus;
///区域设置
+(NSData *)setRegionWithsaveStr:(NSString *)saveStr regionStr:(NSString *)regionStr;
///获取区域设置
+(NSData *)getRegion;
///设置过滤
+(NSData *)setFilterWithBank:(NSInteger)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data;
///单次盘存标签
+(NSData *)singleInventory;

/////过滤单次盘存标签
//+(NSData *)singleInventoryWithBank:(NSInteger)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data;

///连续盘存标签
+(NSData *)startInventory;

/////过滤连续盘存标签
//+(NSData *)startInventoryWithBank:(NSInteger)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data;

///停止连续盘存标签
+(NSData *)StopcontinuitySaveLabel;
///读标签数据区
+(NSData *)readLabelMessageWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata MBstr:(NSString *)MBstr SAstr:(NSString *)SAstr DLstr:(NSString *)DLstr isfilter:(BOOL)isfilter;

+(NSData *)writeLabelWithPassword:(NSString *)passwordStr MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLStr MDdata:(NSString *)MDdataStr MBstr:(NSString *)MBStr SAstr:(NSString *)SAStr DLstr:(NSString *)DLStr writeData:(NSString *)writeDataStr isfilter:(BOOL)isfilter;
///写标签数据区
+(NSData *)writeLabelMessageWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata MBstr:(NSString *)MBstr SAstr:(NSString *)SAstr DLstr:(NSString *)DLstr writeData:(NSString *)writeData isfilter:(BOOL)isfilter;
///kill标签
+(NSData *)killLabelWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata isfilter:(BOOL)isfilter;
///Lock标签
+(NSData *)lockLabelWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata ldStr:(NSString *)ldStr isfilter:(BOOL)isfilter;
///获取标签数据
+(NSData *)getLabMessage;
///设置密钥
+(NSData *)setSM4PassWordWithmodel:(NSString *)model password:(NSString *)password originPass:(NSString *)originPass;
///获取密钥
+(NSData *)getSM4PassWord;
///SM4数据加密
+(NSData *)encryptionPassWordwithmessage:(NSString *)message;
///SM4数据解密
+(NSData *)decryptPassWordwithmessage:(NSString *)message;
///USER加密
+(NSData *)encryptionUSERWithaddress:(NSString *)address lengthStr:(NSString *)lengthStr dataStr:(NSString *)dataStr;
///USER解密
+(NSData *)decryptUSERWithaddress:(NSString *)address lengthStr:(NSString *)lengthStr;



///进入升级模式
+(NSData *)enterUpgradeMode;
///进入升级接收数据
+(NSData *)enterUpgradeAcceptData;
///进入升级发送数据
+(NSData *)enterUpgradeSendtDataWith:(NSString *)dataStr;
///发送升级数据
+(NSData *)sendtUpgradeDataWith:(NSData *)dataStr;
///退出升级模式
+(NSData *)exitUpgradeMode;

///////////   NLAB------ 2021/3/15

+(NSData *)setGen2;
+(NSData *)getGen2;

///设置透传参数
+(NSData *)setParameter:(NSString *)parameter;
///设置超时时间
+(NSData *)setBarcodeTimeOut:(NSString *)timeout;
///设置CodeID
+(NSData *)setBarcodeCodeId:(BOOL) codeId;

/**
 根据cmd和数据生成发送数据
 */
+ (NSData *)makeSendDataWithCmd:(NSData* __nullable)databuf cmd:(int)cmd;

+ (NSData *)parseDataWithOriginalStr:(NSData *)originalStr cmd:(int)cmd;

@end
