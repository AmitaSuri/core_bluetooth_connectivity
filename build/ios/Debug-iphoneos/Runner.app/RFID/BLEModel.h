//
//  BLEModel.h
//  RFID_ios
//
//  Created by   on 2018/4/26.
//  Copyright © 2018年  . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BLEModel : NSObject

@property (nonatomic,copy)NSString *nameStr;
@property (nonatomic,copy)NSString *addressStr;
@property (nonatomic,copy)NSString *rssStr;
@property (nonatomic,strong)CBPeripheral *peripheral;


@end
