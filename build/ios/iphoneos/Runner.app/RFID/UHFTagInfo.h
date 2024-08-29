//
//  TagModel.h
//  RFID_ios
//
//  Created by zsg on 2023/8/28.
//  Copyright © 2023 chainway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface UHFTagInfo : NSObject

@property (nonatomic,copy)NSString *epc;
@property (nonatomic,copy)NSString *tid;
@property (nonatomic,copy)NSString *user;
@property (nonatomic,copy)NSString *pc;
@property (nonatomic,copy)NSString *rssi;
@property (nonatomic,assign)NSInteger count;
@property (nonatomic,copy,readonly)NSString *text;


- (instancetype)initWithEpc:(NSString *)epc;
- (instancetype)initWithEpc:(NSString *)epc pc:(NSString *)pc rssi:(NSString *)rssi;
- (instancetype)initWithEpc:(NSString *)epc tid:(NSString *)tid user:(NSString *)user pc:(NSString *)pc rssi:(NSString *)rssi;
- (NSString *)description;
+ (instancetype)tagWithEpc:(NSString *)epc;
+ (instancetype)tagWithEpc:(NSString *)epc pc:(NSString *)pc rssi:(NSString *)rssi;
+ (instancetype)tagWithEpc:(NSString *)epc tid:(NSString *)tid user:(NSString *)user pc:(NSString *)pc rssi:(NSString *)rssi;


@end

NS_ASSUME_NONNULL_END
