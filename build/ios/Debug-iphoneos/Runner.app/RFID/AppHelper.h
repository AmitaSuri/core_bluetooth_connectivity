//
//  AppHelper.h
//  RFID_ios
//
//  Created by 张磊 on 2019/9/29.
//  Copyright © 2019  . All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppHelper : NSObject

/**
 二进制转换为十进制
 
 @param binary 二进制数
 @return 十进制数
 */
+ (NSInteger)getDecimalByBinary:(NSString *)binary;

/**
 十进制转化为二进制
 
 @param decimal 十进制的数据
 @return 二进制的结果
 */
+ (NSString *)getBinaryByDecimal:(NSInteger)decimal;


/**
 十进制转换十六进制
 
 @param decimal 十进制数
 @return 十六进制数
 */
+ (NSString *)getHexByDecimal:(NSInteger)decimal;

/**
 十六进制转换为二进制
 
 @param hex 十六进制数
 @return 二进制数
 */
+ (NSString *)getBinaryByHex:(NSString *)hex;

/**
 二进制转换成十六进制
 
 @param binary 二进制数
 @return 十六进制数
 */
+ (NSString *)getHexByBinary:(NSString *)binary;

/**
 十六进制转十进制
 
 @param hex 十六进制数
 @return 十进制数
 */
+ (UInt64)getHexToDecimal:(NSString *)hex;

/**
 十六进制转NSData
 
 @param hex 十六进制数
 @return 十进制数
 */
+ (NSData *)hexToNSData:(NSString *)hex;


/**
 NSData转十六进制数
 
 @param data 十进制数
 @return 十六进制数
 */
+(NSString *)dataToHex:(NSData *)data ;

/**
 十进制字符串转十六进制Data
 */
+(NSData *)dataStrToHexData:(NSString *)dataStr;


/** 根据返回的16进制数据生成十进制RSSI数据 */
+ (NSString*) getRssiByHexStr:(NSString *) rssiStr;

/** 判断字符串是否为十六进制数字 */
+ (BOOL) isHexString:(NSString *)str;

/**
    根据CodeID获取条码类型
 */
+(NSString *)getBarcodeTypeByCodeID:(NSString *) codeID;

@end
NS_ASSUME_NONNULL_END
