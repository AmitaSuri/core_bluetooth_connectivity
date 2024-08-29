//
//  AppHelper.m
//  RFID_ios
//
//  Created by   on 2019/9/29.
//  Copyright © 2019  . All rights reserved.
//

#import "AppHelper.h"

@implementation AppHelper

/**
 二进制转换为十进制
 
 @param binary 二进制数
 @return 十进制数
 */
+ (NSInteger)getDecimalByBinary:(NSString *)binary {
    
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

+ (NSString *)getBinaryByDecimal:(NSInteger)decimal {
    NSString *binary = @"";
    while (decimal) {
        
        binary = [[NSString stringWithFormat:@"%d", decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            
            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
}

+ (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", (long)number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}

/**
 十六进制转换为二进制
 
 @param hex 十六进制数
 @return 二进制数
 */
+ (NSString *)getBinaryByHex:(NSString *)hex {
    
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}

/**
 二进制转换成十六进制
 
 @param binary 二进制数
 @return 十六进制数
 */
+ (NSString *)getHexByBinary:(NSString *)binary {
    
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    NSString *hex = @"";
    for (int i=0; i<binary.length; i+=4) {
        
        NSString *key = [binary substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            
            hex = [hex stringByAppendingString:value];
        }
    }
    return hex;
}

/**
 十六进制转十进制
 
 @param hex 十六进制数
 @return 十进制数
 */
+ (UInt64)getHexToDecimal:(NSString *)hex{
    UInt64 data= strtoul([hex UTF8String],0,16);
    return data;
}


+ (NSData *)hexToNSData:(NSString *)str
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


+(NSString *)dataToHex:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

+(NSData *)dataStrToHexData:(NSString *)dataStr{
    if(dataStr == nil)  return nil;
    // 将输入的十进制字符串转为整数
    NSUInteger value = [dataStr integerValue];
    // 将整数转为16进制字符串
    NSString *hexString = [NSString stringWithFormat:@"%02lx", (unsigned long)value];
    // 将16进制字符串转为NSData
    NSMutableData *data = [[NSMutableData alloc] init];
    for (NSUInteger i = 0; i < hexString.length; i += 2) {
        NSString *subString = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner *scanner = [NSScanner scannerWithString:subString];
        unsigned int value;
        [scanner scanHexInt:&value];
        unsigned char byte = (unsigned char)value;
        [data appendBytes:&byte length:1];
    }
    return data;
}


+ (NSString*) getRssiByHexStr:(NSString *) rssiStr {
    NSInteger numOfRssiStr = [AppHelper getDecimalByBinary:[AppHelper getBinaryByHex:rssiStr]];
    CGFloat rssi = (65535 - numOfRssiStr) / 10.0;
    if (numOfRssiStr > 0) {
        return [NSString stringWithFormat:@"-%.2f",rssi];
    }
    return @"";
}

/**
 判断字符串是否为十六进制数字
 */
+ (BOOL) isHexString:(NSString *)str {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9a-fA-F]+$" options:0 error:&error];
    NSRange range = [regex rangeOfFirstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
    return range.location != NSNotFound;
}


/**
    根据CodeID获取条码类型
 */
+(NSString *)getBarcodeTypeByCodeID:(NSString *) codeID {
    NSString *res = @"";
    if ([codeID isEqual:@"A"]) {
        res = @"<UPC-A>";
    } else if ([codeID isEqual:@"B"]) {
        res = @"<Code 39>";
    } else if ([codeID isEqual:@"C"]) {
        res = @"<Codabar>";
    } else if ([codeID isEqual:@"D"]) {
        res = @"<Code 128>";
    } else if ([codeID isEqual:@"E"]) {
        res = @"<Code 93>";
    } else if ([codeID isEqual:@"F"]) {
        res = @"<Interleaved 2 of 5>";
    } else if ([codeID isEqual:@"G"]) {
        res = @"<Discrete 2 of 5>";
    } else if ([codeID isEqual:@"H"]) {
        res = @"<Code 11>";
    } else if ([codeID isEqual:@"J"]) {
        res = @"<MSI>";
    } else if ([codeID isEqual:@"K"]) {
        res = @"<GS1-128>";
    } else if ([codeID isEqual:@"L"]) {
        res = @"<Bookland EAN>";
    } else if ([codeID isEqual:@"M"]) {
        res = @"<Trioptic Code 39>";
    } else if ([codeID isEqual:@"N"]) {
        res = @"<Coupon Code>";
    } else if ([codeID isEqual:@"R"]) {
        res = @"<GS1 DataBar Family>";
    } else if ([codeID isEqual:@"S"]) {
        res = @"<Matrix 2 of 5>";
    } else if ([codeID isEqual:@"T"]) {
        res = @"<UCC Composite>";
    } else if ([codeID isEqual:@"U"]) {
        res = @"<Chinese 2 of 5>";
    } else if ([codeID isEqual:@"V"]) {
        res = @"<Korean 3 of 5>";
    } else if ([codeID isEqual:@"X"]) {
        res = @"<ISSN EAN>";
    } else if ([codeID isEqual:@"z"]) {
        res = @"<Aztec>";
    } else if ([codeID isEqual:@"P00"]) {
        res = @"<Data Matrix>";
    } else if ([codeID isEqual:@"P01"]) {
        res = @"<QR Code>";
    } else if ([codeID isEqual:@"P02"]) {
        res = @"<Maxicode>";
    } else if ([codeID isEqual:@"P03"]) {
        res = @"<US Postnet>";
    } else if ([codeID isEqual:@"P04"]) {
        res = @"<US Planet>";
    } else if ([codeID isEqual:@"P05"]) {
        res = @"<Japan Postal>";
    } else if ([codeID isEqual:@"P06"]) {
        res = @"<UK Postal>";
    } else if ([codeID isEqual:@"P08"]) {
        res = @"<Netherlands KIX Code>";
    } else if ([codeID isEqual:@"P09"]) {
        res = @"<Australia Post>";
    } else if ([codeID isEqual:@"P0A"]) {
        res = @"<USPS 4CB>";
    } else if ([codeID isEqual:@"P0B"]) {
        res = @"<UPU FICS Postal>";
    } else if ([codeID isEqual:@"P0H"]) {
        res = @"<Han Xin>";
    } else if ([codeID isEqual:@"P0X"]) {
        res = @"<Signature Capture>";
    } else {
        res = codeID;
    }
    return res;
}

@end
