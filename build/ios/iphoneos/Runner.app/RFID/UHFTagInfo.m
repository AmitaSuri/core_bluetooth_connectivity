//
//  TagModel.m
//  RFID_ios
//
//  Created by zsg on 2023/8/28.
//  Copyright © 2023 chainway. All rights reserved.
//

#import "UHFTagInfo.h"

@implementation UHFTagInfo


+ (instancetype)tagWithEpc:(NSString *)epc {
    return [[self alloc] initWithEpc:epc pc:@"" rssi:@""];
}

- (instancetype)initWithEpc:(NSString *)epc {
    return [self initWithEpc:epc pc:@"" rssi:@""];
}

+ (instancetype)tagWithEpc:(NSString *)epc pc:(NSString *)pc rssi:(NSString *)rssi {
    return [[self alloc] initWithEpc:epc pc:pc rssi:rssi];
}

- (instancetype)initWithEpc:(NSString *)epc pc:(NSString *)pc rssi:(NSString *)rssi {
    return [self initWithEpc:epc tid:@"" user:@"" pc:pc rssi:rssi];
}

+ (instancetype)tagWithEpc:(NSString *)epc tid:(NSString *)tid user:(NSString *)user pc:(NSString *)pc rssi:(NSString *)rssi {
    return [[self alloc] initWithEpc:epc tid:tid user:user pc:pc rssi:rssi];
}

- (instancetype)initWithEpc:(NSString *)epc tid:(NSString *)tid user:(NSString *)user pc:(NSString *)pc rssi:(NSString *)rssi {
    if (self = [super init]) {
        _epc = [epc copy];
        _tid = [tid copy];
        _user = [user copy];
        _pc = [pc copy];
        self.rssi = [rssi copy];
        self.count = 1;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"UHFTagInfo: epc=%@, tid=%@, user=%@, pc=%@, rssi=%@, count=%ld", self.epc, self.tid, self.user, self.pc, self.rssi, self.count];
}


@synthesize text = _text;

- (NSString *)text {
    if (_text == nil || _text.length == 0) {
        [self updateText];
    }
    return _text;
}

- (void)updateText {
    NSString *epc = (self.tid == nil || [self.tid isEqualToString:@""]) ? self.epc : [NSString stringWithFormat:@"EPC:%@", self.epc];
    NSString *tid = (self.tid.length > 0) ? [NSString stringWithFormat:@"\nTID:%@", self.tid] : @"";
    NSString *user = (self.user.length > 0) ? [NSString stringWithFormat:@"\nUSER:%@", self.user] : @"";
    _text = [NSString stringWithFormat:@"%@%@%@", epc, tid, user];
}

- (void)setTid:(NSString *)tid{
    if(![_tid isEqualToString:tid]) {
        _tid = [tid copy];
    }
    [self updateText]; //更新text
}

-(void)setUser:(NSString *)user{
    if(![_user isEqualToString:user]) {
        _user = [user copy];
    }
    [self updateText]; //更新text
}

@end
