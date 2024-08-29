//
//  BluetoothUtil.m
//  RFID_ios
//
//  Created by   on 2018/4/26.
//  Copyright © 2018年  . All rights reserved.
//

#import "BluetoothUtil.h"
#import "AppHelper.h"

@implementation BluetoothUtil

+ (instancetype)shareManager
{
    static BluetoothUtil *shareManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareManager = [[self alloc] init];
    });
    return shareManager;
}

//  二进制转十进制
+ (NSString *)toDecimalWithBinary:(NSString *)binary
{
    int ll = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++) {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    return result;
}
//16进制String和2进制String互转
+ (NSString *)getBinaryByhex:(NSString *)hex binary:(NSString *)binary
{
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
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
    [hexDic setObject:@"1010" forKey:@"a"];
    [hexDic setObject:@"1011" forKey:@"b"];
    [hexDic setObject:@"1100" forKey:@"c"];
    [hexDic setObject:@"1101" forKey:@"d"];
    [hexDic setObject:@"1110" forKey:@"e"];
    [hexDic setObject:@"1111" forKey:@"f"];
    
    NSMutableString *binaryString=[[NSMutableString alloc] init];
    if (hex.length) {
        for (int i=0; i<[hex length]; i++) {
            NSRange rage;
            rage.length = 1;
            rage.location = i;
            NSString *key = [hex substringWithRange:rage];
            [binaryString appendString:hexDic[key]];
        }
        
    }else{
        for (int i=0; i<binary.length; i+=4) {
            NSString *subStr = [binary substringWithRange:NSMakeRange(i, 4)];
            int index = 0;
            for (NSString *str in hexDic.allValues) {
                index ++;
                if ([subStr isEqualToString:str]) {
                    [binaryString appendString:hexDic.allKeys[index-1]];
                    break;
                }
            }
        }
    }
    return binaryString;
}
//普通字符转16进制
+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
// 十六进制转换为普通字符串的
+ (NSString *)stringFromHexString:(NSString *)hexString {
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}
//nsdata转成16进制字符串
+ (NSString*)stringWithHexBytes2:(NSData *)sender {
    static const char hexdigits[] = "0123456789ABCDEF";
    const size_t numBytes = [sender length];
    const unsigned char* bytes = [sender bytes];
    char *strbuf = (char *)malloc(numBytes * 2 + 1);
    char *hex = strbuf;
    NSString *hexBytes = nil;
    
    for (int i = 0; i<numBytes; ++i) {
        const unsigned char c = *bytes++;
        *hex++ = hexdigits[(c >> 4) & 0xF];
        *hex++ = hexdigits[(c ) & 0xF];
    }
    
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strbuf];
    
    free(strbuf);
    return hexBytes;
}
//将16进制数据转化成NSData
+ (NSData*) hexToBytes:(NSString *)string {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= string.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [string substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
//数字转十六进制字符串
+ (NSString *)stringWithHexNumber:(NSUInteger)hexNumber{
    
    char hexChar[6];
    sprintf(hexChar, "%x", (int)hexNumber);
    
    NSString *hexString = [NSString stringWithCString:hexChar encoding:NSUTF8StringEncoding];
    
    return hexString;
}

//十进制转二进制
+ (NSString *)toBinarySystemWithDecimalSystem:(NSInteger)decimal
{
    NSInteger num = decimal;//[decimal intValue];
    NSInteger remainder = 0;      //余数
    NSInteger divisor = 0;        //除数
    NSString * prepare = @"";
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%ld",remainder];
        if (divisor == 0)
        {
            break;
        }
    }
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",
        [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    return result;
}

//  二进制转十进制

+ (NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary

{
    int ll = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    return result;
}

+(NSString *)getTimeStringWithTimeData:(NSInteger)timeData;
{
    NSString *timeStr = @"";
    NSDateFormatter *data = [[NSDateFormatter alloc] init];
    [data setDateFormat:@"HH:mm:ss"];
    timeStr = [data stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeData]];
    return timeStr;
}


+(NSMutableArray *)getSixteenNumberWith:(NSString *)str
{
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    NSMutableArray *brr=[[NSMutableArray alloc]init];
    for (NSInteger i=0; i<str.length/2; i++) {
        NSString *aa=[str substringWithRange:NSMakeRange(2*i, 2)];
        [brr addObject:aa];
    }
    for (NSInteger j=0; j<brr.count; j++) {
        NSString *strr=[self becomeNumberWith:brr[j]];
        [arr addObject:strr];
    }
  
    return arr;
}

+(NSString *)becomeNumberWith:(NSString *)str
{
    NSString *str1=[str substringWithRange:NSMakeRange(0, 1)];
    NSString *str2=[str substringWithRange:NSMakeRange(1, 1)];
    NSInteger a=[self getzhengshuWith:str1];
    NSInteger b=[self getzhengshuWith:str2];
    NSInteger count=a*16+b;
    return [NSString stringWithFormat:@"%ld",count];
}

+(NSString *)getTagCountWith:(NSString *)str
{
    NSString *str1=[str substringWithRange:NSMakeRange(0, 1)];
    NSString *str2=[str substringWithRange:NSMakeRange(1, 1)];
    NSInteger a=[self getzhengshuWith:str1];
    NSInteger b=[self getzhengshuWith:str2];
    NSInteger count=a*16+b;
    NSInteger countt= count>>3;
    NSInteger counttt= countt*2;
    return [NSString stringWithFormat:@"%ld",counttt];
}

+(NSInteger )getzhengshuWith:(NSString *)str
{
    NSInteger aa=0;
    if ([str isEqualToString:@"a"] || [str isEqualToString:@"A"]) {
        aa=10;
    } else if ([str isEqualToString:@"b"] || [str isEqualToString:@"B"]) {
        aa=11;
    } else if ([str isEqualToString:@"c"] || [str isEqualToString:@"C"]) {
        aa=12;
    } else if ([str isEqualToString:@"d"] || [str isEqualToString:@"D"]) {
        aa=13;
    } else if ([str isEqualToString:@"e"] || [str isEqualToString:@"E"]) {
        aa=14;
    } else if ([str isEqualToString:@"f"] || [str isEqualToString:@"F"]) {
        aa=15;
    } else {
        aa=str.integerValue;
    }
    return aa;
}

-(NSMutableArray*) fetchTagEPCStrWithTagCoutStr:(NSString*)tagCountStr epcStr:(NSString *)epcStr dataSource:(NSMutableArray *)dataSource countArr:(NSMutableArray *)countArr{
    NSMutableArray *allArr=[[NSMutableArray alloc]init];
    if ([tagCountStr isEqualToString:@"1"]) {
        //返回1个标签
        NSString *epc=[epcStr substringWithRange:NSMakeRange(2, epcStr.length-2)];
        BOOL isHave=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc]) {
                isHave=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave==NO) {
            NSLog(@"epc=======%@",epc);
            [dataSource addObject:epc];
            [countArr addObject:@"1"];
        }
    }
    else if ([tagCountStr isEqualToString:@"2"]){  //返回2个标签
        NSString *str1=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(0, 2)]];
        NSString *epc1=[epcStr substringWithRange:NSMakeRange(2, str1.integerValue*2)];
        NSString *str2=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+2, 2)]];
        NSString *epc2=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+4, str2.integerValue*2)];
        BOOL isHave=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc1]) {
                isHave=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave==NO) {
            [dataSource addObject:epc1];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave1=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc2]) {
                isHave1=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave1==NO) {
            [dataSource addObject:epc2];
            [countArr addObject:@"1"];
        }
        
    }
    else if ([tagCountStr isEqualToString:@"3"]){  //c88c0032e1 0000 03 0c e20051578818015726600b06 0c e20051578818015727200883 0c 889951578818015725601379 e5 0d0a
        //返回3个标签
        NSString *str1=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(0, 2)]];
        NSString *epc1=[epcStr substringWithRange:NSMakeRange(2, str1.integerValue*2)];
        NSString *str2=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+2, 2)]];
        NSString *epc2=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+4, str2.integerValue*2)];
        NSString *str3=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+4, 2)]];
        NSString *epc3=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+6, str3.integerValue*2)];
        
        BOOL isHave=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc1]) {
                isHave=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave==NO) {
            [dataSource addObject:epc1];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave1=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc2]) {
                isHave1=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave1==NO) {
            [dataSource addObject:epc2];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave2=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc3]) {
                isHave2=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave2==NO) {
            [dataSource addObject:epc3];
            [countArr addObject:@"1"];
        }
    }
    else if ([tagCountStr isEqualToString:@"4"]){  //c88c0032e1 0000 03 0c e20051578818015726600b06 0c e20051578818015727200883 0c 889951578818015725601379 0c 889951578818015725601379 e5 0d0a
        //返回4个标签
        NSString *str1=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(0, 2)]];
        NSString *epc1=[epcStr substringWithRange:NSMakeRange(2, str1.integerValue*2)];
        NSString *str2=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+2, 2)]];
        NSString *epc2=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+4, str2.integerValue*2)];
        NSString *str3=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+4, 2)]];
        NSString *epc3=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+6, str3.integerValue*2)];
        NSString *str4=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+6, 2)]];
        NSString *epc4=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+8, str4.integerValue*2)];
        
        BOOL isHave=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc1]) {
                isHave=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave==NO) {
            [dataSource addObject:epc1];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave1=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc2]) {
                isHave1=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave1==NO) {
            [dataSource addObject:epc2];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave2=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc3]) {
                isHave2=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave2==NO) {
            [dataSource addObject:epc3];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave3=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc4]) {
                isHave3=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave3==NO) {
            [dataSource addObject:epc4];
            [countArr addObject:@"1"];
        }
    }
    else if ([tagCountStr isEqualToString:@"5"]){  //c88c0032e1 0000 03 0c e20051578818015726600b06 0c e20051578818015727200883 0c 889951578818015725601379 0c 889951578818015725601379 e5 0d0a
        //返回5个标签
        NSString *str1=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(0, 2)]];
        NSString *epc1=[epcStr substringWithRange:NSMakeRange(2, str1.integerValue*2)];
        NSString *str2=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+2, 2)]];
        NSString *epc2=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+4, str2.integerValue*2)];
        NSString *str3=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+4, 2)]];
        NSString *epc3=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+6, str3.integerValue*2)];
        NSString *str4=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+6, 2)]];
        NSString *epc4=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+8, str4.integerValue*2)];
        NSString *str5=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+8, 2)]];
        NSString *epc5=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+10, str5.integerValue*2)];
        
        BOOL isHave=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc1]) {
                isHave=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave==NO) {
            [dataSource addObject:epc1];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave1=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc2]) {
                isHave1=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave1==NO) {
            [dataSource addObject:epc2];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave2=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc3]) {
                isHave2=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave2==NO) {
            [dataSource addObject:epc3];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave3=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc4]) {
                isHave3=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave3==NO) {
            [dataSource addObject:epc4];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave4=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc5]) {
                isHave4=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave4==NO) {
            [dataSource addObject:epc5];
            [countArr addObject:@"1"];
        }
    }
    else if ([tagCountStr isEqualToString:@"6"]){  //c88c0032e1 0000 03 0c e20051578818015726600b06 0c e20051578818015727200883 0c 889951578818015725601379 0c 889951578818015725601379 e5 0d0a
        //返回6个标签
        NSString *str1=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(0, 2)]];
        NSString *epc1=[epcStr substringWithRange:NSMakeRange(2, str1.integerValue*2)];
        NSString *str2=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+2, 2)]];
        NSString *epc2=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+4, str2.integerValue*2)];
        NSString *str3=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+4, 2)]];
        NSString *epc3=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+6, str3.integerValue*2)];
        NSString *str4=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+6, 2)]];
        NSString *epc4=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+8, str4.integerValue*2)];
        NSString *str5=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+8, 2)]];
        NSString *epc5=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+10, str5.integerValue*2)];
        NSString *str6=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+10, 2)]];
        NSString *epc6=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+12, str6.integerValue*2)];
        
        BOOL isHave=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc1]) {
                isHave=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave==NO) {
            [dataSource addObject:epc1];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave1=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc2]) {
                isHave1=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave1==NO) {
            [dataSource addObject:epc2];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave2=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc3]) {
                isHave2=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave2==NO) {
            [dataSource addObject:epc3];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave3=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc4]) {
                isHave3=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave3==NO) {
            [dataSource addObject:epc4];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave4=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc5]) {
                isHave4=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave4==NO) {
            [dataSource addObject:epc5];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave5=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc6]) {
                isHave5=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave5==NO) {
            [dataSource addObject:epc6];
            [countArr addObject:@"1"];
        }
    }
    else if ([tagCountStr isEqualToString:@"7"]){  //c88c0032e1 0000 03 0c e20051578818015726600b06 0c e20051578818015727200883 0c 889951578818015725601379 0c 889951578818015725601379 e5 0d0a
        //返回7个标签
        NSString *str1=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(0, 2)]];
        NSString *epc1=[epcStr substringWithRange:NSMakeRange(2, str1.integerValue*2)];
        NSString *str2=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+2, 2)]];
        NSString *epc2=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+4, str2.integerValue*2)];
        NSString *str3=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+4, 2)]];
        NSString *epc3=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+6, str3.integerValue*2)];
        NSString *str4=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+6, 2)]];
        NSString *epc4=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+8, str4.integerValue*2)];
        NSString *str5=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+8, 2)]];
        NSString *epc5=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+10, str5.integerValue*2)];
        NSString *str6=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+10, 2)]];
        NSString *epc6=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+12, str6.integerValue*2)];
        NSString *str7=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+str6.integerValue*2+12, 2)]];
        NSString *epc7=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+str6.integerValue*2+14, str7.integerValue*2)];
        
        BOOL isHave=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc1]) {
                isHave=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave==NO) {
            [dataSource addObject:epc1];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave1=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc2]) {
                isHave1=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave1==NO) {
            [dataSource addObject:epc2];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave2=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc3]) {
                isHave2=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave2==NO) {
            [dataSource addObject:epc3];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave3=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc4]) {
                isHave3=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave3==NO) {
            [dataSource addObject:epc4];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave4=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc5]) {
                isHave4=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave4==NO) {
            [dataSource addObject:epc5];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave5=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc6]) {
                isHave5=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave5==NO) {
            [dataSource addObject:epc6];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave6=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc7]) {
                isHave6=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave6==NO) {
            [dataSource addObject:epc7];
            [countArr addObject:@"1"];
        }
    }
    else if ([tagCountStr isEqualToString:@"8"]){  //c88c0032e1 0000 03 0c e20051578818015726600b06 0c e20051578818015727200883 0c 889951578818015725601379 0c 889951578818015725601379 e5 0d0a
        //返回8个标签
        
        NSString *str1=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(0, 2)]];
        NSString *epc1=[epcStr substringWithRange:NSMakeRange(2, str1.integerValue*2)];
        NSString *str2=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+2, 2)]];
        NSString *epc2=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+4, str2.integerValue*2)];
        NSString *str3=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+4, 2)]];
        NSString *epc3=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+6, str3.integerValue*2)];
        NSString *str4=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+6, 2)]];
        NSString *epc4=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+8, str4.integerValue*2)];
        NSString *str5=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+8, 2)]];
        NSString *epc5=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+10, str5.integerValue*2)];
        NSString *str6=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+10, 2)]];
        NSString *epc6=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+12, str6.integerValue*2)];
        NSString *str7=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+str6.integerValue*2+12, 2)]];
        NSString *epc7=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+str6.integerValue*2+14, str7.integerValue*2)];
        NSString *str8=[BluetoothUtil becomeNumberWith:[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+str6.integerValue*2+str7.integerValue*2+14, 2)]];
        NSString *epc8=[epcStr substringWithRange:NSMakeRange(str1.integerValue*2+str2.integerValue*2+str3.integerValue*2+str4.integerValue*2+str5.integerValue*2+str6.integerValue*2+str7.integerValue*2+16, str8.integerValue*2)];
        
        BOOL isHave=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc1]) {
                isHave=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave==NO) {
            [dataSource addObject:epc1];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave1=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc2]) {
                isHave1=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave1==NO) {
            [dataSource addObject:epc2];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave2=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc3]) {
                isHave2=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave2==NO) {
            [dataSource addObject:epc3];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave3=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc4]) {
                isHave3=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave3==NO) {
            [dataSource addObject:epc4];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave4=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc5]) {
                isHave4=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave4==NO) {
            [dataSource addObject:epc5];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave5=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc6]) {
                isHave5=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave5==NO) {
            [dataSource addObject:epc6];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave6=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc7]) {
                isHave6=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave6==NO) {
            [dataSource addObject:epc7];
            [countArr addObject:@"1"];
        }
        
        BOOL isHave7=NO;
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSString *str=dataSource[i];
            if ([str isEqualToString:epc8]) {
                isHave7=YES;
                NSString *countStr=countArr[i];
                [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
            }
        }
        if (isHave7==NO) {
            [dataSource addObject:epc8];
            [countArr addObject:@"1"];
        }
    }
    
    [allArr addObject:countArr];
    [allArr addObject:dataSource];
    return allArr;
}

//解析标签
+(NSMutableArray *)getLabTagWith:(NSString *)tagStr dataSource:(NSMutableArray *)dataSource countArr:(NSMutableArray *)countArr {
    
    NSMutableArray *allArr=[[NSMutableArray alloc]init];
    if (tagStr.length>28) {
        NSString *epcStr=[tagStr substringWithRange:NSMakeRange(16, tagStr.length-16-6)];
        NSString *tagCountStr=[tagStr substringWithRange:NSMakeRange(15, 1)];
        NSInteger tagCountDec = [AppHelper getDecimalByBinary:tagCountStr];
#if 1
        for (NSInteger i = 0; i < tagCountDec; i ++) {
            NSString *epcLength = [epcStr substringToIndex:2];
            NSInteger decimalEPCLong = [AppHelper getDecimalByBinary:[AppHelper getBinaryByHex:epcLength]];
            NSString *epcDataStr = [epcStr substringWithRange:NSMakeRange(2, decimalEPCLong * 2)];
            BOOL isHave=NO;
            for (NSInteger j = 0; j < dataSource.count; j++) {
                NSString *str=dataSource[j];
                if ([str isEqualToString:epcDataStr]) {
                    isHave=YES;
                    NSString *countStr=countArr[j];
                    [countArr replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
                }
            }
            if (isHave==NO) {
                [dataSource addObject:epcDataStr];
                [countArr addObject:@"1"];
            }
            [allArr addObject:countArr];
            [allArr addObject:dataSource];
            tagStr = [tagStr substringFromIndex:2 + decimalEPCLong * 2];
        }
#else
        
        //allArr = [self shareManager];
        allArr = [[self shareManager]fetchTagEPCStrWithTagCoutStr:tagCountStr epcStr:epcStr dataSource:dataSource countArr:countArr];
#endif
    }
    
    
    return allArr;
}

-(NSString *) AnalysisEPCDataWithEPCData:(NSString *)EPCData {
    if (EPCData.length > 2) {
        //NSString *epcDataLong = [EPCData substringToIndex:2];
        //NSInteger decimalEPCLong = [AppHelper getDecimalByBinary:[AppHelper getBinaryByHex:epcDataLong]];
        //NSString *currentEPCData = [EPCData substringToIndex:(decimalEPCLong + 1) * 2];
        NSString *secondStr = [EPCData substringWithRange:NSMakeRange(2, 2)];
        NSString *binarySecondStr = [AppHelper getBinaryByHex:secondStr];
        NSString *headFive = [binarySecondStr substringToIndex:5];
        NSInteger EPCRealDataLong = [AppHelper getDecimalByBinary:headFive];
        if (EPCData.length < (3 *2 + EPCRealDataLong * 2 * 2 + 2 * 2)) {
            for (NSInteger i = EPCData.length; EPCData.length < (3 *2 + EPCRealDataLong * 2 * 2 + 2 * 2); i ++) {
                EPCData = [EPCData stringByAppendingString:@"0"];
            }
        }
        return [EPCData substringWithRange:NSMakeRange(3 * 2, EPCRealDataLong * 2 * 2 + 2 * 2)]; //  此处添加了 RSSI到EPC的后面
    }
    return @"";
}

-(NSString *)analysisEPCAndTIDWithEPCAndTIDData:(NSString *)data {
    if (data.length > 2) {
        NSString *secondStr = [data substringWithRange:NSMakeRange(2, 2)];
        NSString *binarySecondStr = [AppHelper getBinaryByHex:secondStr];
        NSString *headFive = [binarySecondStr substringToIndex:5];
        NSInteger realDataLong = [AppHelper getDecimalByBinary:headFive];
        if (data.length < (3 * 2 + realDataLong * 2 * 2 + 12 * 2 + 2 * 2)) {
            for (NSInteger i = data.length; i < (3 * 2 + realDataLong * 2 * 2 + 12 * 2 + 2 * 2); i ++) {
                data = [data stringByAppendingString:@"0"];
            }
        }
        NSString *tidStr = [data substringWithRange:NSMakeRange(3 * 2 + realDataLong * 2 * 2, 12 * 2 + 2 * 2)]; //  添加了RSSI
        NSString *EPCAndTidStr = [NSString stringWithFormat:@"%@+%@",[data substringWithRange:NSMakeRange(3 * 2, realDataLong * 2 * 2)],tidStr];
        return EPCAndTidStr;
    }
    return @"";
}

-(NSString *)analysisEPCAndTidAndUserDataWithData:(NSString *)data {
    if (data.length > 2) {
        //  先获取EPC数据的长度
        NSString *secondStr = [data substringWithRange:NSMakeRange(2, 2)];
        NSString *binarySecondStr = [AppHelper getBinaryByHex:secondStr];
        NSString *headFive = [binarySecondStr substringToIndex:5];
        NSInteger realEPCDataLong = [AppHelper getDecimalByBinary:headFive];
        //  获取EPC数据
        NSString *EPCRealStr = [data substringWithRange:NSMakeRange(3 * 2, realEPCDataLong * 2 * 2)];
        if (data.length < (3 * 2 + realEPCDataLong * 2 * 2 + 12 * 2 + (data.length - (3 * 2 + realEPCDataLong * 2 * 2 + 12 * 2)))) {
            for (NSInteger i = 0; i < (3 * 2 + realEPCDataLong * 2 * 2 + 12 * 2 + (data.length - (3 * 2 + realEPCDataLong * 2 * 2 + 12 * 2))); i ++) {
                data = [data stringByAppendingString:@"0"];
            }
        }
        //  获取Tid数据 : 长度固定为 12 个字节,紧跟在 EPC  后面
        NSString *tidStr = [data substringWithRange:NSMakeRange(3 * 2 + realEPCDataLong * 2 * 2, 12 * 2)];
        //  获取USER数据
        NSString *userDataStr = [data substringWithRange:NSMakeRange(3 * 2 + realEPCDataLong * 2 * 2 + 12 * 2, data.length - (3 * 2 + realEPCDataLong * 2 * 2 + 12 * 2))]; //  添加了 RSSI
        return [NSString stringWithFormat:@"%@+%@+%@",EPCRealStr,tidStr,userDataStr];
    }
    return @"";
}

//解析标签2
+(NSMutableArray *)getNewLabTagWith:(NSString *)tagStr dataSource:(NSMutableArray *)dataSource countArr:(NSMutableArray *)countArr dataSource1:(NSMutableArray *)dataSource1 countArr1:(NSMutableArray *)countArr1 dataSource2:(NSMutableArray *)dataSource2 countArr2:(NSMutableArray *)countArr2;
{
    NSMutableArray *allArr=[[NSMutableArray alloc]init];
    
    
    //c88c 00 2d e1 00 00
    //02
    //10 3000 e2 00 00 17 01 0b 01 94 17 50 62 90 fd47
    //10 3000 e2 00 00 17 01 0b 02 17 17 50 62 c7 fd59 070d0a
    
    //c88c 00 62 e1 00 00
    //03
    //1c 3000 e2 00 00 17 01 0b 01 93 17 50 62 97    e2 00 34 12 01 2f fc 00 0b 45 e5 7d  fdb9
    //1c 3000 e2 00 00 17 01 0b 01 91 17 50 62 96    e2 00 34 12 01 34 fc 00 0b 45 e5 7c  fdcc
    //1c 3000 e2 00 00 17 01 0b 00 80 17 50 61 af    e2 00 34 12 01 37 fc 00 0b 45 e4 95  fd39 c30d0a
    
   
    //c88c 00 5d e1 00 02
    //02
    //28 3000 e2 00 00 17 01 0b 02 11 17 50 62 b8    e2 00 34 12 01 2c fc 00 0b 45 e5 9e    00 00 00 00 00 00 00 00 00 00 00 00 fd40
    //28 3000 e2 00 00 17 01 0b 01 93 17 50 62 97    e2 00 34 12 01 2f fc 00 0b 45 e5 7d    000000000000000000000000 fdb1 030d0a
    
    //先判断是epc或者是epc+tid或者是epc+tid+User
    NSString *typeStr;
    
    //先判断是epc或者是epc+tid或者是epc+tid+User
    
    //  标签长度 - (EPC长度 + 2) * 2 - 12 * 2 > 2 * 2 个字节 为 EPC + TID + USER
    //  标签长度 - (EPC长度 + 2) * 2 - 12 * 2 = 2 * 2 个字节 为 EPC + TID
    //  标签长度 - (EPC长度 + 2) * 2 - 12 * 2 < 2 * 2 个字节 为 EPC
    NSInteger countStr1 = [AppHelper getDecimalByBinary:[AppHelper getBinaryByHex:[tagStr substringWithRange:NSMakeRange(16, 2)]]];
    NSString *secondStr = [tagStr substringWithRange:NSMakeRange(18, 2)];
    NSString *binarySecondStr = [AppHelper getBinaryByHex:secondStr];
    NSString *headFive = [binarySecondStr substringToIndex:5];
    NSInteger realEPCDataLong = [AppHelper getDecimalByBinary:headFive];
    NSInteger count = countStr1 - (realEPCDataLong * 2 + 2)  - 12;
    if (count > 2) {
        //epc+tid+User
        typeStr = @"2";
    }
    else if (count == 2)
    {
        //epc+tid
        typeStr = @"1";
    }
    else
    {
        //epc
        typeStr = @"0";
    }
    if ([typeStr isEqualToString:@"0"]) {
        //  解析 EPC 标签数据
        NSString *epcStr=[tagStr substringWithRange:NSMakeRange(16, tagStr.length-16-6)];
        NSString *tagCountStr=[tagStr substringWithRange:NSMakeRange(15, 1)];
        if (tagCountStr.integerValue >= 1) {
            for (NSInteger i = 0; i < tagCountStr.integerValue; i ++) {
                NSString *epcDataLong = [epcStr substringToIndex:2];
                NSInteger decimalEPCLong = [AppHelper getDecimalByBinary:[AppHelper getBinaryByHex:epcDataLong]];
                NSString *currentEPCData = [epcStr substringToIndex:(decimalEPCLong + 1) * 2];
                NSString *epcRealStr = [[self shareManager]AnalysisEPCDataWithEPCData:currentEPCData];
                BOOL isHave=NO;
                for (NSInteger j=0; j<dataSource.count; j++) {
                    NSString *str=dataSource[j];
                    if ([str isEqualToString:epcRealStr]) {
                        isHave=YES;
                        NSString *countStr=countArr[j];
                        [countArr replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
                    }
                }
                if (isHave==NO) {
                    [dataSource addObject:epcRealStr];
                    [countArr addObject:@"1"];
                }
                epcStr = [epcStr substringFromIndex:(decimalEPCLong + 1) * 2];
            }
        }
        
        [allArr addObject:countArr];
        [allArr addObject:dataSource];
    } else if ([typeStr isEqualToString:@"1"]) {
        //  解析 EPC + Tid 标签数据
        NSString *epcStr=[tagStr substringWithRange:NSMakeRange(16, tagStr.length-16-6)];
        NSString *tagCountStr=[tagStr substringWithRange:NSMakeRange(15, 1)];
        //c88c 00 62 e1 00 00
        //03
        //1c 30 00 e2 00 00 17 01 0b 01 93 17 50 62 97    e2 00 34 12 01 2f fc 00 0b 45 e5 7d  fdb9
        //1c 3000 e2 00 00 17 01 0b 01 91 17 50 62 96    e2 00 34 12 01 34 fc 00 0b 45 e5 7c  fdcc
        //1c 3000 e2 00 00 17 01 0b 00 80 17 50 61 af    e2 00 34 12 01 37 fc 00 0b 45 e4 95  fd39 c30d0a
        for (NSInteger i = 0; i < tagCountStr.integerValue; i ++) {
            NSString *epcDataLong = [epcStr substringToIndex:2];
            NSInteger decimalEPCLong = [AppHelper getDecimalByBinary:[AppHelper getBinaryByHex:epcDataLong]];
            NSString *currentEPCData = [epcStr substringToIndex:(decimalEPCLong + 1) * 2];
            NSString *EPCAndTidStr = [[self shareManager]analysisEPCAndTIDWithEPCAndTIDData:currentEPCData];
            if (EPCAndTidStr && EPCAndTidStr.length > 12) {
                if ([EPCAndTidStr containsString:@"+"]) {
                    NSArray *epcAndTidStrArr = [EPCAndTidStr componentsSeparatedByString:@"+"];
                    if (epcAndTidStrArr && epcAndTidStrArr.count == 2) {
                        NSString *EPCRealStr = epcAndTidStrArr[0];
                        NSString *tidRealStr = epcAndTidStrArr[1];
                        BOOL isHave=NO;
                        for (NSInteger i=0; i<dataSource.count; i++) {
                            NSString *str=dataSource[i];
                            if ([str isEqualToString:EPCRealStr]) {
                                isHave=YES;
                                if (i < countArr.count) {
                                    NSString *countStr=countArr[i];
                                    [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
                                }
                                if (i < countArr1.count) {
                                    NSString *countStr1=countArr1[i];
                                    [countArr1 replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr1.integerValue+1]];
                                }
                                
                            }
                        }
                        if (isHave==NO) {
                            [dataSource addObject:EPCRealStr];
                            [countArr addObject:@"1"];
                            [dataSource1 addObject:tidRealStr];
                            [countArr1 addObject:@"1"];
                        }
                    }
                }
            }
            epcStr = [epcStr substringFromIndex:(decimalEPCLong + 1) * 2];
        }
        
        [allArr addObject:countArr];
        [allArr addObject:dataSource];
        [allArr addObject:countArr1];
        [allArr addObject:dataSource1];
    } else {
        //  解析 EPC + Tid + USER  标签数据
            NSString *epcStr=[tagStr substringWithRange:NSMakeRange(16, tagStr.length-16-6)];
            NSString *tagCountStr=[tagStr substringWithRange:NSMakeRange(15, 1)];
            for (NSInteger i = 0; i < tagCountStr.integerValue; i++) {
                NSString *epcDataLong = [epcStr substringToIndex:2];
                NSInteger decimalEPCLong = [AppHelper getDecimalByBinary:[AppHelper getBinaryByHex:epcDataLong]];
                NSString *currentEPCData = [epcStr substringToIndex:(decimalEPCLong + 1) * 2];
                NSString *epcAndTidAndUserData = [[self shareManager]analysisEPCAndTidAndUserDataWithData:currentEPCData];
                if (epcAndTidAndUserData && epcAndTidAndUserData.length > 12) {
                    if ([epcAndTidAndUserData containsString:@"+"]) {
                        NSArray *allDataArr = [epcAndTidAndUserData componentsSeparatedByString:@"+"];
                        if (allDataArr && allDataArr.count == 3) {
                            NSString *epcData = allDataArr[0];
                            NSString *tidData = allDataArr[1];
                            NSString *userData = allDataArr[2];
                            BOOL isHave=NO;
                            for (NSInteger i=0; i<dataSource.count; i++) {
                                NSString *str=dataSource[i];
                                if ([str isEqualToString:epcData]) {
                                    isHave=YES;
                                    if (i < countArr.count) {
                                        NSString *countStr=countArr[i];
                                        [countArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr.integerValue+1]];
                                    }
                                    if (i < countArr1.count) {
                                        NSString *countStr1=countArr1[i];
                                        [countArr1 replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr1.integerValue+1]];
                                    }
                                    if (i < countArr2.count) {
                                        NSString *countStr2 = countArr2[i];
                                        [countArr2 replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%ld",countStr2.integerValue + 1]];
                                    }
                                }
                            }
                            if (isHave==NO) {
                                [dataSource addObject:epcData];
                                [countArr addObject:@"1"];
                                [dataSource1 addObject:tidData];
                                [countArr1 addObject:@"1"];
                                [dataSource2 addObject:userData];
                                [countArr2 addObject:@"1"];
                            }
                        }
                    }
                }
                epcStr = [epcStr substringFromIndex:(decimalEPCLong + 1) * 2];
            }
            [allArr addObject:countArr];
            [allArr addObject:dataSource];
            [allArr addObject:countArr1];
            [allArr addObject:dataSource1];
            [allArr addObject:countArr2];
            [allArr addObject:dataSource2];
    }
    
    return allArr;
}

//获取固件版本号
+(NSData *)getFirmwareVersion2 {
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0xC8;
    dateByte[5]=0x00^0x08^0xC8;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//获取电池电量
+(NSData *)getBatteryLevel
{
    Byte dateByte[9];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x09;
    dateByte[4]=0xE4;
    dateByte[5]=0x01;
    dateByte[6]=0x00^0x09^0xE4^0x01;
    dateByte[7]=0x0D;
    dateByte[8]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:9];
    return data;
}
//获取设备当前温度
+(NSData *)getServiceTemperature
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0x34;
    dateByte[5]=0x00^0x08^0x34;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//开启2D扫描
+(NSData *)start2DScan
{
    Byte dateByte[9];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x09;
    dateByte[4]=0xE4;
    dateByte[5]=0x02;
    dateByte[6]=0x00^0x09^0xE4^0x02;
    dateByte[7]=0x0D;
    dateByte[8]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:9];
    return data;
}
//开启连续2D扫描
+(NSData *)startContinuous2DScan
{
    Byte dateByte[10];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0A;
    dateByte[4]=0xE4;
    dateByte[5]=0x02;
    dateByte[6]=0x01;
    dateByte[7]=0x00^0x0A^0xE4^0x02^0x01;
    dateByte[8]=0x0D;
    dateByte[9]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:10];
    return data;
}
//关闭连续2D扫描
+(NSData *)stopContinuous2DScan
{
    Byte dateByte[10];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0A;
    dateByte[4]=0xE4;
    dateByte[5]=0x02;
    dateByte[6]=0x00;
    dateByte[7]=0x00^0x0A^0xE4^0x02^0x00;
    dateByte[8]=0x0D;
    dateByte[9]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:10];
    return data;
}
//获取硬件版本号
+(NSData *)getHardwareVersion
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0x00;
    dateByte[5]=0x00^0x08^0x00;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//获取固件版本号
+(NSData *)getFirmwareVersion
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0x02;
    dateByte[5]=0x00^0x08^0x02;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//获取设备ID
+(NSData *)getServiceID
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0x04;
    dateByte[5]=0x00^0x08^0x04;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//软件复位
+(NSData *)softwareReset
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0x68;
    dateByte[5]=0x00^0x08^0x68;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//开启蜂鸣器
+(NSData *)openBuzzer
{
    Byte dateByte[10];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0A;
    dateByte[4]=0xE4;
    dateByte[5]=0x03;
    dateByte[6]=0x01;
    dateByte[7]=0x00^0x0A^0xE4^0x03^0x01;
    dateByte[8]=0x0D;
    dateByte[9]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:10];
    return data;
}
//关闭蜂鸣器
+(NSData *)closeBuzzer
{
    Byte dateByte[10];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0A;
    dateByte[4]=0xE4;
    dateByte[5]=0x03;
    dateByte[6]=0x00;
    dateByte[7]=0x00^0x0A^0xE4^0x03^0x00;
    dateByte[8]=0x0D;
    dateByte[9]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:10];
    return data;
}

//设置标签读取格式
+(NSData *)setEpcTidUserWithAddressStr:(NSString *)addressStr length:(NSString *)lengthStr EPCStr:(NSString *)ePCStr
{
    //NSLog(@"bbbbbb");
    Byte dateByte[12];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0C;
    dateByte[4]=0x70;
    dateByte[5]=0x00;
    dateByte[6]=0x00+ePCStr.integerValue;
    dateByte[7]=0x00+addressStr.integerValue;
    dateByte[8]=0x00+lengthStr.integerValue;
    dateByte[9]=0x00^0x0C^0x70^0x00^dateByte[6]^dateByte[7]^dateByte[8];
    dateByte[10]=0x0D;
    dateByte[11]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:12];
    return data;
}

//获取标签读取格式
+(NSData *)getEpcTidUser
{
    Byte dateByte[10];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0A;
    dateByte[4]=0x72;
    dateByte[5]=0x00;
    dateByte[6]=0x00;
    dateByte[7]=0x00^0x0A^0x72^0x00^0x00;
    dateByte[8]=0x0D;
    dateByte[9]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:10];
    return data;
}

//设置发射功率
+(NSData *)setLaunchPowerWithstatus:(NSString *)status antenna:(NSString *)antenna readStr:(NSString *)readStr writeStr:(NSString *)writeStr
{
    Byte dateByte[14];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0E;
    dateByte[4]=0x10;
    dateByte[5]=0x02;
    
    dateByte[6]=0x00+antenna.integerValue;
    
    NSInteger aa=readStr.integerValue*100;
    NSInteger bb=aa/(16*16*16);
    NSInteger cc=aa%(16*16*16)/(16*16);
    NSInteger dd=aa%(16*16*16)%(16*16)/(16);
    NSInteger ee=aa%(16*16*16)%(16*16)%(16);
    dateByte[7]=0x00+bb*16+cc;
    dateByte[8]=0x00+dd*16+ee;
    
    NSInteger aaa=writeStr.integerValue*100;
    NSInteger bbb=aaa/(16*16*16);
    NSInteger ccc=aaa%(16*16*16)/(16*16);
    NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
    NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
    dateByte[9]=0x00+bbb*16+ccc;
    dateByte[10]=0x00+ddd*16+eee;
    
    dateByte[11]=0x00^0x0E^0x10^dateByte[5]^dateByte[6]^dateByte[7]^dateByte[8]^dateByte[9]^dateByte[10];
    dateByte[12]=0x0D;
    dateByte[13]=0x0A;
    
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:14];
    return data;
}
//获取当前发射功率
+(NSData *)getLaunchPower
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0x12;
    dateByte[5]=0x00^0x08^0x12;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//跳频设置
+(NSData *)detailChancelSettingWithstring:(NSString *)str
{
    Byte dateByte[12];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0C;
    dateByte[4]=0x14;
    dateByte[5]=0x01;
    
    NSInteger aa=str.integerValue;
    
    NSInteger bb=aa/(16*16*16*16*16);
    NSInteger cc=aa%(16*16*16*16*16)/(16*16*16*16);
    NSInteger dd=aa%(16*16*16*16*16)%(16*16*16*16)/(16*16*16);
    NSInteger ee=aa%(16*16*16*16*16)%(16*16*16*16)%(16*16*16)/(16*16);
    NSInteger ff=aa%(16*16*16*16*16)%(16*16*16*16)%(16*16*16)%(16*16)/16;
    NSInteger gg=aa%(16*16*16*16*16)%(16*16*16*16)%(16*16*16)%(16*16)%16;
    
    dateByte[6]=0x00+bb*16+cc;
    dateByte[7]=0x00+dd*16+ee;
    dateByte[8]=0x00+ff*16+gg;
    
    dateByte[9]=0x00^0x0C^0x14^dateByte[5]^dateByte[6]^dateByte[7]^dateByte[8];
    dateByte[10]=0x0D;
    dateByte[11]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:12];
    return data;
}
//获取当前跳频设置状态
+(NSData *)getdetailChancelStatus
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0x16;
    dateByte[5]=0x00^0x08^0x16;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//区域设置
+(NSData *)setRegionWithsaveStr:(NSString *)saveStr regionStr:(NSString *)regionStr
{
    Byte dateByte[10];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0A;
    dateByte[4]=0x2C;
    if ([saveStr isEqualToString:@"0"]) {
        dateByte[5]=0x00;
    }
    else
    {
        dateByte[5]=0x01;
    }
    
    if ([regionStr isEqualToString:@"0"]) {
        dateByte[6]=0x01;
    }
    else if ([regionStr isEqualToString:@"1"])
    {
        dateByte[6]=0x02;
    }
    else if ([regionStr isEqualToString:@"2"])
    {
        dateByte[6]=0x04;
    }
    else if ([regionStr isEqualToString:@"3"])
    {
        dateByte[6]=0x08;
    }
    else if ([regionStr isEqualToString:@"4"])
    {
        dateByte[6]=0x16;
    }
    else if ([regionStr isEqualToString:@"5"])
    {
        dateByte[6]=0x32;
    }
    dateByte[7]=0x00^0x0A^0x2C^dateByte[5]^dateByte[6];
    dateByte[8]=0x0D;
    dateByte[9]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:10];
    return data;
}
//获取区域设置
+(NSData *)getRegion
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0x2E;
    dateByte[5]=0x00^0x08^0x2E;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
///设置过滤
+(NSData *)setFilterWithBank:(NSInteger)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data
{
    NSMutableArray *dataArr = [BluetoothUtil getSixteenNumberWith:data];
    int sum = (int)dataArr.count + 15;
    
    Byte dateByte[sum];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=sum;
    dateByte[4]=0x6E;   //cmd
    dateByte[5]=0x00;   //掉电不保存
    dateByte[6]=0x00 + bank;   //bank [(NSNumber *)@(bank) unsignedCharValue]
    
    NSInteger aa=ptr.intValue;
    NSInteger bb=aa/(16*16*16);
    NSInteger cc=aa%(16*16*16)/(16*16);
    NSInteger dd=aa%(16*16*16)%(16*16)/(16);
    NSInteger ee=aa%(16*16*16)%(16*16)%(16);
    dateByte[7]=0x00+bb*16+cc;
    dateByte[8]=0x00+dd*16+ee;
    
    NSInteger aaa=len.integerValue;
    NSInteger bbb=aaa/(16*16*16);
    NSInteger ccc=aaa%(16*16*16)/(16*16);
    NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
    NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
    dateByte[9]=0x00+bbb*16+ccc;
    dateByte[10]=0x00+ddd*16+eee;
    
    for (NSInteger i=0; i<dataArr.count; i++) {
        NSString *dataStr=dataArr[i];
        dateByte[11+i]=0x00+dataStr.integerValue;
    }
    
    // 计算数据校验和
    Byte checksum = 0x00;
    for (int i = 2; i < sum - 3; i++) {
        checksum ^= dateByte[i];
    }
    dateByte[sum-3]=checksum;
    dateByte[sum-2]=0x0D;
    dateByte[sum-1]=0x0A;
    NSData *res = [[NSData alloc] initWithBytes:dateByte length:sum];
    return res;
}
//单次盘存标签  不过滤
+(NSData *)singleInventory
{
    Byte dateByte[10];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0A;
    dateByte[4]=0x80;
    dateByte[5]=0x00;
    dateByte[6]=0x64;
    dateByte[7]=0x00^0x0A^0x80^0x00^0x64;
    dateByte[8]=0x0D;
    dateByte[9]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:10];
    return data;
}

/////过滤单次盘存标签
//+(NSData *)singleInventoryWithBank:(NSInteger *)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data
//{
//    Byte dateByte[10];
//    dateByte[0]=0xA5;
//    dateByte[1]=0x5A;
//    dateByte[2]=0x00;
//    dateByte[3]=0x0A;
//    dateByte[4]=0x80;
//    dateByte[5]=0x00;
//    dateByte[6]=0x64;
//    dateByte[7]=0x00^0x0A^0x80^0x00^0x64;
//    dateByte[8]=0x0D;
//    dateByte[9]=0x0A;
//    NSData *res = [[NSData alloc] initWithBytes:dateByte length:10];
//    return res;
//}

//连续盘存标签
+(NSData *)startInventory
{
    Byte dateByte[10];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0A;
    dateByte[4]=0x82;
    
    //NSInteger aa=count.integerValue;
    NSInteger aa=0;
    NSInteger bb=aa/(16*16*16);
    NSInteger cc=aa%(16*16*16)/(16*16);
    NSInteger dd=aa%(16*16*16)%(16*16)/(16);
    NSInteger ee=aa%(16*16*16)%(16*16)%(16);
    dateByte[5]=0x00+bb*16+cc;
    dateByte[6]=0x00+dd*16+ee;
    
    dateByte[7]=0x00^0x0A^0x82^dateByte[5]^dateByte[6];
    dateByte[8]=0x0D;
    dateByte[9]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:10];
    return data;
}

/////过滤连续盘存标签
//+(NSData *)startInventoryWithBank:(NSInteger)bank Ptr:(NSString *)ptr Len:(NSString *)len Data:(NSString *)data
//{
//    NSMutableArray *dataArr = [BluetoothUtil getSixteenNumberWith:data];
//    int sum = (int)dataArr.count + 14;
//    
//    Byte dateByte[sum];
//    dateByte[0]=0xA5;
//    dateByte[1]=0x5A;
//    dateByte[2]=0x00;
//    dateByte[3]=sum;
//    dateByte[4]=0x6E;   //cmd
//    dateByte[5]=0x00;   //掉电不保存
//    dateByte[6]=0x00 + bank;   //bank [(NSNumber *)@(bank) unsignedCharValue]
//    
//    NSInteger aa=ptr.integerValue;
//    NSInteger bb=aa/(16*16*16);
//    NSInteger cc=aa%(16*16*16)/(16*16);
//    NSInteger dd=aa%(16*16*16)%(16*16)/(16);
//    NSInteger ee=aa%(16*16*16)%(16*16)%(16);
//    dateByte[7]=0x00+bb*16+cc;
//    dateByte[8]=0x00+dd*16+ee;
//    
//    NSInteger aaa=len.integerValue;
//    NSInteger bbb=aaa/(16*16*16);
//    NSInteger ccc=aaa%(16*16*16)/(16*16);
//    NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
//    NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
//    dateByte[9]=0x00+bbb*16+ccc;
//    dateByte[10]=0x00+ddd*16+eee;
//    
//    for (NSInteger i=0; i<dataArr.count; i++) {
//        NSString *dataStr=dataArr[i];
//        dateByte[10+i]=0x00+dataStr.integerValue;
//    }
//    
//    // 计算数据校验和
//    Byte checksum = 0x00;
//    for (int i = 2; i < sum - 3; i++) {
//        checksum ^= dateByte[i];
//    }
//    dateByte[sum-3]=checksum;
//    dateByte[sum-2]=0x0D;
//    dateByte[sum-1]=0x0A;
//    NSData *res = [[NSData alloc] initWithBytes:dateByte length:sum];
//    return res;
//}

//停止连续盘存标签
+(NSData *)StopcontinuitySaveLabel
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0x8C;
    dateByte[5]=0x00^0x08^0x8C;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//读标签数据区
+(NSData *)readLabelMessageWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata MBstr:(NSString *)MBstr SAstr:(NSString *)SAstr DLstr:(NSString *)DLstr isfilter:(BOOL)isfilter
{
    NSMutableArray *passwordArr=[[NSMutableArray alloc]init];
    passwordArr=[BluetoothUtil getSixteenNumberWith:password];
    
    NSMutableArray *dataArr=[[NSMutableArray alloc]init];
    dataArr=[BluetoothUtil getSixteenNumberWith:MDdata];
    
    if (passwordArr.count<4) {
        return nil;
    }
    
    
    NSString *passOne=passwordArr[0];
    NSString *passTwo=passwordArr[1];
    NSString *passThree=passwordArr[2];
    NSString *passFour=passwordArr[3];
    
    if (isfilter) {
        
        Byte dateByte[22+dataArr.count];
        dateByte[0]=0xA5;
        dateByte[1]=0x5A;
        dateByte[2]=0x00;
        dateByte[3]=0x16+dataArr.count;
        dateByte[4]=0x84;
        dateByte[5]=0x00+passOne.integerValue;
        dateByte[6]=0x00+passTwo.integerValue;
        dateByte[7]=0x00+passThree.integerValue;
        dateByte[8]=0x00+passFour.integerValue;
        dateByte[9]=0x00+MMBstr.integerValue;
        
        NSInteger aa=MSAstr.integerValue;
        NSInteger bb=aa/(16*16*16);
        NSInteger cc=aa%(16*16*16)/(16*16);
        NSInteger dd=aa%(16*16*16)%(16*16)/(16);
        NSInteger ee=aa%(16*16*16)%(16*16)%(16);
        dateByte[10]=0x00+bb*16+cc;
        dateByte[11]=0x00+dd*16+ee;
        
        NSInteger aaa=MDLstr.integerValue;
        NSInteger bbb=aaa/(16*16*16);
        NSInteger ccc=aaa%(16*16*16)/(16*16);
        NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
        NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
        dateByte[12]=0x00+bbb*16+ccc;
        dateByte[13]=0x00+ddd*16+eee;
        
        
        for (NSInteger i=0; i<dataArr.count; i++) {
            NSString *dataStr=dataArr[i];
            dateByte[i+14]=0x00+dataStr.integerValue;
        }
        dateByte[14+dataArr.count]=0x00+MBstr.integerValue;
        
        NSInteger aa1=SAstr.integerValue;
        NSInteger bb1=aa1/(16*16*16);
        NSInteger cc1=aa1%(16*16*16)/(16*16);
        NSInteger dd1=aa1%(16*16*16)%(16*16)/(16);
        NSInteger ee1=aa1%(16*16*16)%(16*16)%(16);
        dateByte[15+dataArr.count]=0x00+bb1*16+cc1;
        dateByte[16+dataArr.count]=0x00+dd1*16+ee1;
        
        NSInteger aaa1=DLstr.integerValue;
        NSInteger bbb1=aaa1/(16*16*16);
        NSInteger ccc1=aaa1%(16*16*16)/(16*16);
        NSInteger ddd1=aaa1%(16*16*16)%(16*16)/(16);
        NSInteger eee1=aaa1%(16*16*16)%(16*16)%(16);
        dateByte[17+dataArr.count]=0x00+bbb1*16+ccc1;
        dateByte[18+dataArr.count]=0x00+ddd1*16+eee1;
        
         dateByte[19+dataArr.count]=dateByte[2]^dateByte[3]^dateByte[4]^dateByte[5]^dateByte[6]^dateByte[7]^dateByte[8]^dateByte[9]^dateByte[10]^dateByte[11]^dateByte[12]^dateByte[13];
        for (NSInteger i=0; i<dataArr.count+5; i++) {
            dateByte[19+dataArr.count]=dateByte[19+dataArr.count]^dateByte[i+14];
        }
        
        dateByte[20+dataArr.count]=0x0D;
        dateByte[21+dataArr.count]=0x0A;
        NSData *data = [[NSData alloc] initWithBytes:dateByte length:22+dataArr.count];
   
        return data;
    }
    else
    {
        Byte dateByte[22];
        dateByte[0]=0xA5;
        dateByte[1]=0x5A;
        dateByte[2]=0x00;
        dateByte[3]=0x16;
        dateByte[4]=0x84;
        dateByte[5]=0x00+passOne.integerValue;
        dateByte[6]=0x00+passTwo.integerValue;
        dateByte[7]=0x00+passThree.integerValue;
        dateByte[8]=0x00+passFour.integerValue;
        dateByte[9]=0x00;
        dateByte[10]=0x00;
        dateByte[11]=0x00;
        dateByte[12]=0x00;
        dateByte[13]=0x00;
        dateByte[14]=0x00+MBstr.integerValue;
        
        NSInteger aa=SAstr.integerValue;
        NSInteger bb=aa/(16*16*16);
        NSInteger cc=aa%(16*16*16)/(16*16);
        NSInteger dd=aa%(16*16*16)%(16*16)/(16);
        NSInteger ee=aa%(16*16*16)%(16*16)%(16);
        dateByte[15]=0x00+bb*16+cc;
        dateByte[16]=0x00+dd*16+ee;
        
        NSInteger aaa=DLstr.integerValue;
        NSInteger bbb=aaa/(16*16*16);
        NSInteger ccc=aaa%(16*16*16)/(16*16);
        NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
        NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
        dateByte[17]=0x00+bbb*16+ccc;
        dateByte[18]=0x00+ddd*16+eee;
        dateByte[19]=0x00^0x16;
        for (NSInteger i=0; i<15; i++) {
            dateByte[19]=dateByte[19]^dateByte[i+4];
        }
        dateByte[20]=0x0D;
        dateByte[21]=0x0A;
        NSData *data = [[NSData alloc] initWithBytes:dateByte length:22];

        return data;
    }
    
}

//写标签数据区
+(NSData *)writeLabelMessageWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata MBstr:(NSString *)MBstr SAstr:(NSString *)SAstr DLstr:(NSString *)DLstr writeData:(NSString *)writeData isfilter:(BOOL)isfilter
{
    if (![AppHelper isHexString:password] || ![AppHelper isHexString:writeData] || (isfilter && ![AppHelper isHexString:MDdata]) ) {
        return nil;
    }
    
    NSMutableArray *passwordArr = [BluetoothUtil getSixteenNumberWith:password];
    NSMutableArray *dataArr = [BluetoothUtil getSixteenNumberWith:MDdata];
    NSMutableArray *writeArr = [BluetoothUtil getSixteenNumberWith:writeData];
    
    NSLog(@"writeArr=%@", writeArr);
    
    if (passwordArr.count<4 || !writeArr.count) {
        return nil;
    }
    
    NSString *passOne=passwordArr[0];
    NSString *passTwo=passwordArr[1];
    NSString *passThree=passwordArr[2];
    NSString *passFour=passwordArr[3];
    
    if (isfilter) {
        Byte dateByte[22+dataArr.count+writeArr.count];
        dateByte[0]=0xA5;
        dateByte[1]=0x5A;
        dateByte[2]=0x00;
        dateByte[3]=0x16+dataArr.count+writeArr.count;
        dateByte[4]=0x86;
        dateByte[5]=0x00+passOne.integerValue;
        dateByte[6]=0x00+passTwo.integerValue;
        dateByte[7]=0x00+passThree.integerValue;
        dateByte[8]=0x00+passFour.integerValue;
        dateByte[9]=0x00+MMBstr.integerValue;
        
        NSInteger aa=MSAstr.integerValue;
        NSInteger bb=aa/(16*16*16);
        NSInteger cc=aa%(16*16*16)/(16*16);
        NSInteger dd=aa%(16*16*16)%(16*16)/(16);
        NSInteger ee=aa%(16*16*16)%(16*16)%(16);
        dateByte[10]=0x00+bb*16+cc;
        dateByte[11]=0x00+dd*16+ee;
        
        NSInteger aaa=MDLstr.integerValue;
        NSInteger bbb=aaa/(16*16*16);
        NSInteger ccc=aaa%(16*16*16)/(16*16);
        NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
        NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
        dateByte[12]=0x00+bbb*16+ccc;
        dateByte[13]=0x00+ddd*16+eee;
        
        for (NSInteger i=0; i<dataArr.count; i++) {
            NSString *dataStr=dataArr[i];
            dateByte[i+14]=0x00+dataStr.integerValue;
        }
        dateByte[14+dataArr.count]=0x00+MBstr.integerValue;
        
        NSInteger aa1=SAstr.integerValue;
        NSInteger bb1=aa1/(16*16*16);
        NSInteger cc1=aa1%(16*16*16)/(16*16);
        NSInteger dd1=aa1%(16*16*16)%(16*16)/(16);
        NSInteger ee1=aa1%(16*16*16)%(16*16)%(16);
        dateByte[15+dataArr.count]=0x00+bb1*16+cc1;
        dateByte[16+dataArr.count]=0x00+dd1*16+ee1;
        
        NSInteger aaa1=DLstr.integerValue;
        NSInteger bbb1=aaa1/(16*16*16);
        NSInteger ccc1=aaa1%(16*16*16)/(16*16);
        NSInteger ddd1=aaa1%(16*16*16)%(16*16)/(16);
        NSInteger eee1=aaa1%(16*16*16)%(16*16)%(16);
        dateByte[17+dataArr.count]=0x00+bbb1*16+ccc1;
        dateByte[18+dataArr.count]=0x00+ddd1*16+eee1;
        
        for (NSInteger i=0; i<writeArr.count; i++) {
            NSString *dataStr=writeArr[i];
            dateByte[i+19+dataArr.count]=0x00+dataStr.integerValue;
        }
        dateByte[19+dataArr.count+writeArr.count]=dateByte[2]^dateByte[3]^dateByte[4]^dateByte[5]^dateByte[6]^dateByte[7]^dateByte[8]^dateByte[9]^dateByte[10]^dateByte[11]^dateByte[12]^dateByte[13];
        for (NSInteger i=0; i<dataArr.count+5+writeArr.count; i++) {
            dateByte[19+dataArr.count+writeArr.count]=dateByte[19+dataArr.count+writeArr.count]^dateByte[i+14];
        }
        
        dateByte[20+dataArr.count+writeArr.count]=0x0D;
        dateByte[21+dataArr.count+writeArr.count]=0x0A;
        NSData *data = [[NSData alloc] initWithBytes:dateByte length:22+dataArr.count+writeArr.count];
        NSLog(@"data===%@",data);
        return data;
        
    } else {
        Byte dateByte[22+writeArr.count];
        dateByte[0]=0xA5;
        dateByte[1]=0x5A;
        dateByte[2]=0x00;
        dateByte[3]=0x16+writeArr.count;
        dateByte[4]=0x86;
        dateByte[5]=0x00+passOne.integerValue;
        dateByte[6]=0x00+passTwo.integerValue;
        dateByte[7]=0x00+passThree.integerValue;
        dateByte[8]=0x00+passFour.integerValue;
        dateByte[9]=0x00;
        dateByte[10]=0x00;
        dateByte[11]=0x00;
        dateByte[12]=0x00;
        dateByte[13]=0x00;
        dateByte[14]=0x00+MBstr.integerValue;
        
        
        NSInteger aa=SAstr.integerValue;
        NSInteger bb=aa/(16*16*16);
        NSInteger cc=aa%(16*16*16)/(16*16);
        NSInteger dd=aa%(16*16*16)%(16*16)/(16);
        NSInteger ee=aa%(16*16*16)%(16*16)%(16);
        dateByte[15]=0x00+bb*16+cc;
        dateByte[16]=0x00+dd*16+ee;
        
        NSInteger aaa=DLstr.integerValue;
        NSInteger bbb=aaa/(16*16*16);
        NSInteger ccc=aaa%(16*16*16)/(16*16);
        NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
        NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
        dateByte[17]=0x00+bbb*16+ccc;
        dateByte[18]=0x00+ddd*16+eee;
        
        for (NSInteger i=0; i<writeArr.count; i++) {
            NSString *writeStr=writeArr[i];
            dateByte[19+i]=0x00+writeStr.integerValue;
        }
        
        dateByte[19+writeArr.count]=0x00^dateByte[3];
        for (NSInteger i=0; i<15+writeArr.count; i++) {
            dateByte[19+writeArr.count]=dateByte[19+writeArr.count]^dateByte[i+4];
        }
        dateByte[20+writeArr.count]=0x0D;
        dateByte[21+writeArr.count]=0x0A;
        NSData *data = [[NSData alloc] initWithBytes:dateByte length:22+writeArr.count];
        NSLog(@"data===%@",data);
        return data;
    }
}

//写标签数据区
+(NSData *)writeLabelWithPassword:(NSString *)passwordStr MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLStr MDdata:(NSString *)MDdataStr MBstr:(NSString *)MBStr SAstr:(NSString *)SAStr DLstr:(NSString *)DLStr writeData:(NSString *)writeDataStr isfilter:(BOOL)isfilter
{
    if ([passwordStr length] == 0 || [MBStr length] == 0 || [SAStr length] == 0 || [DLStr length] == 0 || [writeDataStr length] == 0 || (isfilter && ([MMBstr length] == 0 || [MSAstr length] == 0 || [MDLStr length] == 0 || [MDdataStr length] == 0))
    ){
        NSLog(@"某条写入数据为空");
        return nil;
    }
    if (![AppHelper isHexString:passwordStr] || ![AppHelper isHexString:writeDataStr] || (isfilter && ![AppHelper isHexString:MDdataStr]) ) {
        return nil;
    }
    if (DLStr.intValue * 4 != writeDataStr.length) {
        NSLog(@"数据与长度不匹配 Len=%@ data=%@ data.length %ld", DLStr, writeDataStr, writeDataStr.length);
        return nil;
    }
    NSData *password = [AppHelper hexToNSData:passwordStr];
    NSData *writeData = [AppHelper hexToNSData:writeDataStr];
    if(password == nil || password.length < 4 || writeData == nil)  return nil;
    
    NSMutableData *data = [NSMutableData dataWithData:password];
    NSData *zero = [AppHelper hexToNSData:@"00"];
    
    if (isfilter) {
        if (MDLStr.intValue == 0 || MDLStr.intValue / 4 != MDdataStr.length) {
            NSLog(@"过滤数据与长度不匹配 Len=%@ data=%@ data.length=%ld", MDLStr, MDdataStr, MDdataStr.length);
            return nil;
        }
        NSData *MMB = [AppHelper hexToNSData:MMBstr];   //数据区
        NSData *MSA = [AppHelper dataStrToHexData:MSAstr];   //地址
        NSData *MDL = [AppHelper dataStrToHexData:MDLStr];   //长度
        NSData *MDdata = [AppHelper hexToNSData:MDdataStr]; //数据
        NSLog(@"MSA=%@  MDL=%@",MSA, MDL);
        [data appendData:MMB];
        if(MSA.length == 1) [data appendData:zero];
        [data appendData:MSA];
        if(MDL.length == 1) [data appendData:zero];
        [data appendData:MDL];
        [data appendData:MDdata];
    } else {
        [data appendData:[AppHelper hexToNSData:@"0000000000"]];
    }
    
    NSData *MB = [AppHelper hexToNSData:MBStr];
    NSData *SA = [AppHelper hexToNSData:SAStr];
    NSData *DL = [AppHelper hexToNSData:DLStr];
    [data appendData:MB];
    if(SA.length == 1) [data appendData:zero];
    [data appendData:SA];
    if(DL.length == 1) [data appendData:zero];
    [data appendData:DL];
    [data appendData:writeData];
    
    return [self makeSendDataWithCmd:data cmd:0x86];
}

//kill标签
+(NSData *)killLabelWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata isfilter:(BOOL)isfilter
{
    NSMutableArray *passwordArr=[[NSMutableArray alloc]init];
    passwordArr=[BluetoothUtil getSixteenNumberWith:password];
    
    NSMutableArray *dataArr=[[NSMutableArray alloc]init];
    dataArr=[BluetoothUtil getSixteenNumberWith:MDdata];
    
    NSString *passOne=passwordArr[0];
    NSString *passTwo=passwordArr[1];
    NSString *passThree=passwordArr[2];
    NSString *passFour=passwordArr[3];
    
    if (isfilter) {
        Byte dateByte[17+dataArr.count];
        dateByte[0]=0xA5;
        dateByte[1]=0x5A;
        dateByte[2]=0x00;
        dateByte[3]=0x11+dataArr.count;
        dateByte[4]=0x8A;
        dateByte[5]=0x00+passOne.integerValue;
        dateByte[6]=0x00+passTwo.integerValue;
        dateByte[7]=0x00+passThree.integerValue;
        dateByte[8]=0x00+passFour.integerValue;
        dateByte[9]=0x00+MMBstr.integerValue;
        
        NSInteger aa=MSAstr.integerValue;
        NSInteger bb=aa/(16*16*16);
        NSInteger cc=aa%(16*16*16)/(16*16);
        NSInteger dd=aa%(16*16*16)%(16*16)/(16);
        NSInteger ee=aa%(16*16*16)%(16*16)%(16);
        dateByte[10]=0x00+bb*16+cc;
        dateByte[11]=0x00+dd*16+ee;
        
        NSInteger aaa=MDLstr.integerValue;
        NSInteger bbb=aaa/(16*16*16);
        NSInteger ccc=aaa%(16*16*16)/(16*16);
        NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
        NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
        dateByte[12]=0x00+bbb*16+ccc;
        dateByte[13]=0x00+ddd*16+eee;
        
        for (NSInteger i=0; i<dataArr.count; i++) {
            NSString *dataStr=dataArr[i];
            dateByte[i+14]=0x00+dataStr.integerValue;
        }
        dateByte[14+dataArr.count]=0x00^dateByte[3];
        for (NSInteger i=0; i<10+dataArr.count; i++) {
            dateByte[14+dataArr.count]=dateByte[14+dataArr.count]^dateByte[i+4];
        }
        
        
        dateByte[15+dataArr.count]=0x0D;
        dateByte[16+dataArr.count]=0x0A;
        NSData *data = [[NSData alloc] initWithBytes:dateByte length:17+dataArr.count];
        return data;
    } else {
        Byte dateByte[17];
        dateByte[0]=0xA5;
        dateByte[1]=0x5A;
        dateByte[2]=0x00;
        dateByte[3]=0x11;
        dateByte[4]=0x8A;
        dateByte[5]=0x00+passOne.integerValue;
        dateByte[6]=0x00+passTwo.integerValue;
        dateByte[7]=0x00+passThree.integerValue;
        dateByte[8]=0x00+passFour.integerValue;
        
        dateByte[9]=0x00;
        dateByte[10]=0x00;
        dateByte[11]=0x00;
        dateByte[12]=0x00;
        dateByte[13]=0x00;
        
//        for (NSInteger i=0; i<dataArr.count; i++) {
//            NSString *dataStr=dataArr[i];
//            dateByte[i+14]=0x00+dataStr.integerValue;
//        }
        dateByte[14]=0x00^dateByte[3];
        for (NSInteger i=0; i<10; i++) {
            dateByte[14]=dateByte[14]^dateByte[i+4];
        }

        dateByte[15]=0x0D;
        dateByte[16]=0x0A;
        NSData *data = [[NSData alloc] initWithBytes:dateByte length:17];
        return data;
    }
    
    
}

//Lock标签
+(NSData *)lockLabelWithPassword:(NSString *)password MMBstr:(NSString *)MMBstr MSAstr:(NSString *)MSAstr MDLstr:(NSString *)MDLstr MDdata:(NSString *)MDdata ldStr:(NSString *)ldStr isfilter:(BOOL)isfilter
{
    
    NSMutableArray *passwordArr=[[NSMutableArray alloc]init];
    passwordArr=[BluetoothUtil getSixteenNumberWith:password];
    
    NSMutableArray *dataArr=[[NSMutableArray alloc]init];
    dataArr=[BluetoothUtil getSixteenNumberWith:MDdata];
    
    NSMutableArray *ldArr=[[NSMutableArray alloc]init];
    ldArr=[BluetoothUtil getSixteenNumberWith:ldStr];
    
    if (passwordArr.count<3) {
        
    }
    
    NSString *passOne=passwordArr[0];
    NSString *passTwo=passwordArr[1];
    NSString *passThree=passwordArr[2];
    NSString *passFour=passwordArr[3];
    
    if (isfilter) {
        
        Byte dateByte[20+dataArr.count];
        dateByte[0]=0xA5;
        dateByte[1]=0x5A;
        dateByte[2]=0x00;
        dateByte[3]=0x14+dataArr.count;
        dateByte[4]=0x88;
        dateByte[5]=0x00+passOne.integerValue;
        dateByte[6]=0x00+passTwo.integerValue;
        dateByte[7]=0x00+passThree.integerValue;
        dateByte[8]=0x00+passFour.integerValue;
        dateByte[9]=0x00+MMBstr.integerValue;
        
        NSInteger aa=MSAstr.integerValue;
        NSInteger bb=aa/(16*16*16);
        NSInteger cc=aa%(16*16*16)/(16*16);
        NSInteger dd=aa%(16*16*16)%(16*16)/(16);
        NSInteger ee=aa%(16*16*16)%(16*16)%(16);
        dateByte[10]=0x00+bb*16+cc;
        dateByte[11]=0x00+dd*16+ee;
        
        NSInteger aaa=MDLstr.integerValue;
        NSInteger bbb=aaa/(16*16*16);
        NSInteger ccc=aaa%(16*16*16)/(16*16);
        NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
        NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
        dateByte[12]=0x00+bbb*16+ccc;
        dateByte[13]=0x00+ddd*16+eee;
        
        
        for (NSInteger i=0; i<dataArr.count; i++) {
            NSString *dataStr=dataArr[i];
            dateByte[i+14]=0x00+dataStr.integerValue;
        }
        NSString *ldStr1=ldArr[0];
        NSString *ldStr2=ldArr[1];
        NSString *ldStr3=ldArr[2];
        dateByte[14+dataArr.count]=0x00+ldStr1.integerValue;//ld
        dateByte[15+dataArr.count]=0x00+ldStr2.integerValue;//ld
        dateByte[16+dataArr.count]=0x00+ldStr3.integerValue;//ld
        
        dateByte[17+dataArr.count]=dateByte[2]^dateByte[3];
        for (NSInteger i=0; i<13+dataArr.count; i++) {
            dateByte[17+dataArr.count]=dateByte[17+dataArr.count]^dateByte[i+4];
        }
        
        dateByte[18+dataArr.count]=0x0D;
        dateByte[19+dataArr.count]=0x0A;
        NSData *data = [[NSData alloc] initWithBytes:dateByte length:20+dataArr.count];
        
        return data;
    }
    else
    {
        Byte dateByte[20];
        dateByte[0]=0xA5;
        dateByte[1]=0x5A;
        dateByte[2]=0x00;
        dateByte[3]=0x14;
        dateByte[4]=0x88;
        dateByte[5]=0x00+passOne.integerValue;
        dateByte[6]=0x00+passTwo.integerValue;
        dateByte[7]=0x00+passThree.integerValue;
        dateByte[8]=0x00+passFour.integerValue;
        dateByte[9]=0x00;
        dateByte[10]=0x00;
        dateByte[11]=0x00;
        dateByte[12]=0x00;
        dateByte[13]=0x00;
        
        NSString *ldStr1=ldArr[0];
        NSString *ldStr2=ldArr[1];
        NSString *ldStr3=ldArr[2];
        dateByte[14]=0x00+ldStr1.integerValue;//ld
        dateByte[15]=0x00+ldStr2.integerValue;//ld
        dateByte[16]=0x00+ldStr3.integerValue;//ld
        
        dateByte[17]=0x00^0x14;
        for (NSInteger i=0; i<13; i++) {
            dateByte[17]=dateByte[17]^dateByte[i+4];
        }
        dateByte[18]=0x0D;
        dateByte[19]=0x0A;
        NSData *data = [[NSData alloc] initWithBytes:dateByte length:20];
        return data;
    }
}

//获取标签数据
+(NSData *)getLabMessage
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0xE0;
    dateByte[5]=0x00^0x08^0xE0;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//设置密钥
+(NSData *)setSM4PassWordWithmodel:(NSString *)model password:(NSString *)password originPass:(NSString *)originPass
{
    Byte dateByte[42];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x2A;
    dateByte[4]=0xE2;
    dateByte[5]=0x01;
    if ([model isEqualToString:@"0"]) {
        dateByte[6]=0x00;
    }
    else if ([model isEqualToString:@"1"])
    {
        dateByte[6]=0x01;
    }
    else if ([model isEqualToString:@"2"])
    {
        dateByte[6]=0x02;
    }
    else if ([model isEqualToString:@"3"])
    {
        dateByte[6]=0x03;
    }
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    arr=[BluetoothUtil getSixteenNumberWith:password];
    NSMutableArray *brr=[[NSMutableArray alloc]init];
    brr=[BluetoothUtil getSixteenNumberWith:originPass];
    for (NSInteger i=0; i<arr.count; i++) {
        NSString *strrr=arr[i];
        dateByte[i+7]=0x00+strrr.integerValue;
    }
    for (NSInteger j=0; j<brr.count; j++) {
        NSString *strrr=brr[j];
        dateByte[j+23]=0x00+strrr.integerValue;
    }

    
    dateByte[39]=0x00^dateByte[3];
    for (NSInteger i=0; i<35; i++) {
        dateByte[39]=dateByte[39]^dateByte[i+4];
    }
    
    dateByte[40]=0x0D;
    dateByte[41]=0x0A;
    
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:42];
    
    return data;
}
//获取密钥
+(NSData *)getSM4PassWord
{
    Byte dateByte[9];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x09;
    dateByte[4]=0xE2;
    dateByte[5]=0x02;
    dateByte[6]=0x00^0x09^0xE2^0x02;
    dateByte[7]=0x0D;
    dateByte[8]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:9];
    return data;
}
//SM4数据加密
+(NSData *)encryptionPassWordwithmessage:(NSString *)message
{
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    arr=[BluetoothUtil getSixteenNumberWith:message];
    
    Byte dateByte[9+arr.count];//14  5
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x09+arr.count;
    dateByte[4]=0xE2;
    dateByte[5]=0x03;
    
    for (NSInteger i=0; i<arr.count; i++) {
        NSString *str=arr[i];
        dateByte[i+6]=0x00+str.integerValue;
    }
    
    dateByte[6+arr.count]=0x00^dateByte[3]^0xE2^0x03;
    for (NSInteger i=0; i<arr.count; i++) {
        dateByte[6+arr.count]=dateByte[6+arr.count]^dateByte[i+6];
    }
    dateByte[7+arr.count]=0x0D;
    dateByte[8+arr.count]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:9+arr.count];
    NSLog(@"data===%@",data);
    return data;
}
//SM4数据解密
+(NSData *)decryptPassWordwithmessage:(NSString *)message
{
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    arr=[BluetoothUtil getSixteenNumberWith:message];
    
    Byte dateByte[9+arr.count];//14  5
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x09+arr.count;
    dateByte[4]=0xE2;
    dateByte[5]=0x04;
    
    for (NSInteger i=0; i<arr.count; i++) {
        NSString *str=arr[i];
        dateByte[i+6]=0x00+str.integerValue;
    }
    
    dateByte[6+arr.count]=0x00^dateByte[3]^0xE2^0x04;
    for (NSInteger i=0; i<arr.count; i++) {
        dateByte[6+arr.count]=dateByte[6+arr.count]^dateByte[i+6];
    }
    dateByte[7+arr.count]=0x0D;
    dateByte[8+arr.count]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:9+arr.count];
    NSLog(@"data===%@",data);
    return data;
}
//USER加密
+(NSData *)encryptionUSERWithaddress:(NSString *)address lengthStr:(NSString *)lengthStr dataStr:(NSString *)dataStr
{
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    arr=[BluetoothUtil getSixteenNumberWith:dataStr];
    
    Byte dateByte[13+arr.count];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0D+arr.count;
    dateByte[4]=0xE2;
    dateByte[5]=0x05;
    
    NSInteger aa=address.integerValue;
    NSInteger bb=aa/(16*16*16);
    NSInteger cc=aa%(16*16*16)/(16*16);
    NSInteger dd=aa%(16*16*16)%(16*16)/(16);
    NSInteger ee=aa%(16*16*16)%(16*16)%(16);
    dateByte[6]=0x00+bb*16+cc;
    dateByte[7]=0x00+dd*16+ee;
    
    NSInteger aaa=lengthStr.integerValue;
    NSInteger bbb=aaa/(16*16*16);
    NSInteger ccc=aaa%(16*16*16)/(16*16);
    NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
    NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
    dateByte[8]=0x00+bbb*16+ccc;
    dateByte[9]=0x00+ddd*16+eee;
    
    for (NSInteger i=0; i<arr.count; i++) {
        NSString *str=arr[i];
        dateByte[i+10]=0x00+str.integerValue;
    }
    dateByte[10+arr.count]=0x00^dateByte[3]^0xE2^0x05;
    for (NSInteger i=0; i<4+arr.count; i++) {
        dateByte[10+arr.count]=dateByte[10+arr.count]^dateByte[i+6];
    }
    
    dateByte[11+arr.count]=0x0D;
    dateByte[12+arr.count]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:13+arr.count];
    NSLog(@"data===%@",data);
    return data;
}
//USER解密
+(NSData *)decryptUSERWithaddress:(NSString *)address lengthStr:(NSString *)lengthStr
{
    Byte dateByte[13];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0D;
    dateByte[4]=0xE2;
    dateByte[5]=0x06;
    
    NSInteger aa=address.integerValue;
    NSInteger bb=aa/(16*16*16);
    NSInteger cc=aa%(16*16*16)/(16*16);
    NSInteger dd=aa%(16*16*16)%(16*16)/(16);
    NSInteger ee=aa%(16*16*16)%(16*16)%(16);
    dateByte[6]=0x00+bb*16+cc;
    dateByte[7]=0x00+dd*16+ee;
    
    NSInteger aaa=lengthStr.integerValue;
    NSInteger bbb=aaa/(16*16*16);
    NSInteger ccc=aaa%(16*16*16)/(16*16);
    NSInteger ddd=aaa%(16*16*16)%(16*16)/(16);
    NSInteger eee=aaa%(16*16*16)%(16*16)%(16);
    dateByte[8]=0x00+bbb*16+ccc;
    dateByte[9]=0x00+ddd*16+eee;
    
    dateByte[10]=0x00^0x0D^dateByte[4]^dateByte[5]^dateByte[6]^dateByte[7]^dateByte[8]^dateByte[9];
    
    dateByte[11]=0x0D;
    dateByte[12]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:13];
    NSLog(@"data===%@",data);
    return data;
}

//进入升级模式
+(NSData *)enterUpgradeMode
{
    Byte dateByte[9];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x09;
    dateByte[4]=0xC0;
    dateByte[5]=0xCC;
    dateByte[6]=0x00^0x09^0xC0^0xCC;
    dateByte[7]=0x0D;
    dateByte[8]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:9];
    return data;
}
//进入升级接收数据
+(NSData *)enterUpgradeAcceptData
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0xC2;
    dateByte[5]=0x00^0x08^0xC2;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}
//进入升级发送数据
+(NSData *)enterUpgradeSendtDataWith:(NSString *)dataStr
{
    NSMutableArray *dataArr=[[NSMutableArray alloc]init];
    dataArr=[BluetoothUtil getSixteenNumberWith:dataStr];
    
    Byte dateByte[72];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x48;
    dateByte[4]=0xC4;
    
    for (NSInteger i=0; i<dataArr.count; i++) {
        NSString *str=dataArr[i];
        dateByte[i+5]=0x00+str.integerValue;
    }
    
    dateByte[69]=0x00^0x48^0xC4;
    for (NSInteger i=0; i<64; i++) {
        dateByte[69]=dateByte[69]^dateByte[i+5];
    }
    dateByte[70]=0x0D;
    dateByte[71]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:72];
    return data;
}
//发送升级数据
+(NSData *)sendtUpgradeDataWith:(NSData *)dataStr
{
    return dataStr;
}

//退出升级模式
+(NSData *)exitUpgradeMode
{
    Byte dateByte[8];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x08;
    dateByte[4]=0xC6;
    dateByte[5]=0x00^0x08^0xC6;
    dateByte[6]=0x0D;
    dateByte[7]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:8];
    return data;
}

/*+(NSData *)setGen2WithCmd:(int)cmd dataBuf:(NSData*)databuf {
    Byte outSendbuf[databuf.length + 8];
    int idx = 0;
    int crcValue = 0;
    outSendbuf[idx++] =  0xA5;
    outSendbuf[idx++] =  0x5A;
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

+(NSData *)getGen2 {
    
}*/

//设置透传参数
+(NSData *)setParameter:(NSString *)parameter {
    NSData *parameterData = [AppHelper hexToNSData:parameter];
    int sum = 12 + (int)parameterData.length;
    Byte dateByte[sum];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=sum;
    dateByte[4]=0xF0;
    dateByte[5]=0x04;
    dateByte[6]=0x77;
    dateByte[7]=parameterData.length + 1;
    dateByte[8]=0x00;
    
    for (int i = 0; i < parameterData.length; i++) {
        Byte byte;
        [parameterData getBytes:&byte range:NSMakeRange(i, 1)];
        dateByte[9 + i] = byte;
    }
    
    // 计算数据校验和
    Byte checksum = 0x00;
    for (int i = 2; i < sum - 3; i++) {
        checksum ^= dateByte[i];
    }
    
    dateByte[sum-3] = checksum;
    dateByte[sum-2]=0x0D;
    dateByte[sum-1]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:sum];
    return data;
}

//设置超时时间
+(NSData *)setBarcodeTimeOut:(NSString *)timeout {
    Byte dateByte[14];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0E;
    dateByte[4]=0xF0;
    dateByte[5]=0x04;
    dateByte[6]=0x77;
    dateByte[7]=0x03;
    dateByte[8]=0x00;
    dateByte[9]=0x88;
    dateByte[10]=[timeout intValue];
    dateByte[11]=dateByte[2]^dateByte[3]^dateByte[4]^dateByte[5]^dateByte[6]^dateByte[7]^dateByte[8]^dateByte[9]^dateByte[10];
    dateByte[12]=0x0D;
    dateByte[13]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:14];
    return data;
}

//设置CodeID
+(NSData *)setBarcodeCodeId:(BOOL) codeId {
    Byte dateByte[14];
    dateByte[0]=0xA5;
    dateByte[1]=0x5A;
    dateByte[2]=0x00;
    dateByte[3]=0x0E;
    dateByte[4]=0xF0;
    dateByte[5]=0x04;
    dateByte[6]=0x77;
    dateByte[7]=0x03;
    dateByte[8]=0x00;
    dateByte[9]=0x2d;
    if(codeId)  dateByte[10]=0x02;
    else        dateByte[10]=0x00;
    dateByte[11]=dateByte[2]^dateByte[3]^dateByte[4]^dateByte[5]^dateByte[6]^dateByte[7]^dateByte[8]^dateByte[9]^dateByte[10];
    dateByte[12]=0x0D;
    dateByte[13]=0x0A;
    NSData *data = [[NSData alloc] initWithBytes:dateByte length:14];
    return data;
}






+ (NSData *)makeSendDataWithCmd:(NSData * __nullable) databuf cmd:(int)cmd {
    NSInteger len = 0;
    if(databuf != nil){
        len = databuf.length;
    }
    Byte outSendbuf[len + 8];
    int idx = 0;
    int crcValue = 0;
    outSendbuf[idx++] =  0xA5;
    outSendbuf[idx++] =  0x5A;
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
    return [NSData dataWithBytes:outSendbuf length:len + 8];
}
   
+ (NSData *)parseDataWithOriginalStr:(NSData *)originalStr cmd:(int)cmd {
     const int R_START = 0;//开始
     const int R_5A = 1;
     const int R_LEN_H = 2;//数据长度高位
     const int R_LEN_L = 3;//数据长度低位
     const int R_CMD = 4;//命令字节
     const int R_DATA = 5;//数据
     const int R_XOR = 6;//校验位
     const int R_END_0D = 7;//结束贞
     const int R_END_0A = 8;//结束贞
     int Head1 = 0xA5;//C8;
     int Head2 = 0x5A;//@"8C";
     int Tail1 = 0x0D;//@"0D";
     //NSString *Tail2 = @"0A";//0x0A;
     int Tail2 = 0x0A;
     
     int rxsta = R_START;
     int rlen = 0;//数据长度
     int ridx = 0; //数据
     int rxor = 0; //校验字节
     int rcmd = 0; //命令字节
     int rflag = 0;//是否正确的完成了数据解析
     //NSString *dataStr = [NSString string];
     Byte rbuf[2048];
     Byte *originalByte = (Byte *)originalStr.bytes;
     for (int i = 0; i < originalStr.length; i ++) {
          
          int tmpdata = originalByte[i] & 0xff;
          switch (rxsta) {
               case R_START:
                    //从头开始解析C8， 下一步开始解析5
                    if (tmpdata == Head1) {
                         rxsta = R_5A;
                    } else {
                         rxsta = R_START;
                    }
                    rxor = 0;
                    ridx = 0;
                    rlen = 0;
                    rflag = 0;
                    break;
               case R_5A:
                    //解析5A，下一步解析数据长度
                    if (tmpdata == Head2) {
                         rxsta = R_LEN_H;
                    } else {
                         rxsta = R_START;
                    }
                    break;
               case R_LEN_H:
                    //解析数据长度高字节，下一步解析数据长度低字节
                    rxor = rxor ^ tmpdata;
                    rlen = tmpdata * 256;
                    rxsta = R_LEN_L;
                    break;
               case R_LEN_L:
                    //解析数据长度低字节，下一步解析命令
                    rxor = rxor ^ tmpdata;
                    rlen = rlen + tmpdata;
                    if ((rlen < 8) || (rlen > 2048)) {
                         rxsta = R_START;
                    } else {
                         rlen = rlen - 8;
                         rxsta = R_CMD;
                    }
                    break;
               case R_CMD:
                    //解析数据长度低字节，下一步解析标签数据
                    rxor = rxor ^ tmpdata;
                    rcmd = tmpdata;
                    if (rlen > 0) {
                         rxsta = R_DATA;
                    } else {
                         rxsta = R_XOR;
                    }
                    break;
               case R_DATA:
                    //解析标签数据，下一步解析校验码
                    if (rlen == 0) {
                         rxsta = R_START;
                         break;
                    }
                    if (ridx < rlen) {
                         rxor = rxor ^ tmpdata;
                         //开始存标签数据
                         rbuf[ridx++] = (Byte)tmpdata;
                         if (ridx >= rlen) {
                              rxsta = R_XOR;
                         }
                    }
                    break;
               case R_XOR: {
                    //解析校验码，下一步解析尾部0
                    if (rxor == tmpdata) {
                         rxsta = R_END_0D;
                    } else {
                         rxsta = R_START;
                    }
               }
                    break;
               case R_END_0D:
                    //解析尾部0D，下一步解析尾部0A
                    if (tmpdata == Tail1) {
                         rxsta = R_END_0A;
                    } else {
                         rxsta = R_START;
                    }
                    break;
               case R_END_0A:
                    //解析尾部0A， ,解析成功则解析完成
                    rxsta = R_START;
                    if (tmpdata == Tail2) {
                         rflag = 1;
                    }
                    break;
               default:
                    rxor = 0;
                    ridx = 0;
                    rlen = 0;
                    rflag = 0;
                    break;
          }
          if (rflag == 1) {
               break;
          }
     }
     
     if (rflag == 1) {
          if (rcmd != cmd) {
               //命令不对
               return [NSData data];
          }
          //解析成功，只返回标签数据（去掉头尾）
          return [NSData dataWithBytes:rbuf length:ridx];
     } else {
          //解析失败
          return [NSData data];
     }
}



@end
