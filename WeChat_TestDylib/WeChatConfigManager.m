//
//  WeChatConfigManager.m
//  WeChat_TestDylib
//  
//  Created by ash on 2019/6/10.
//  Copyright © 2019 ash. All rights reserved.
//
    
#import <UIKit/UIKit.h>
#import "WeChatConfigManager.h"

NSString *const ConfigAutoRed_Key = @"ConfigAutoRed_Key";
NSString *const WeChatConfigManager_Key = @"WeChatConfigManager_Key";

@interface WeChatConfigManager ()<NSSecureCoding>

@property (nonatomic, assign) BOOL isAutoRed;

@end

@implementation WeChatConfigManager
@dynamic supportsSecureCoding;

+ (instancetype)sharedManager {
    static WeChatConfigManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WeChatConfigManager alloc] init];
    });
    return instance;
}

+ (void)loadInstance:(WeChatConfigManager *)instance {
    WeChatConfigManager *manager = [self sharedManager];
    manager.stepCount = instance.stepCount;
    manager.lastChangeStepCountDate = instance.lastChangeStepCountDate;
}

- (void)handleStepCount:(UITextField *)sender {
    self.stepCount = sender.text.integerValue;
    self.lastChangeStepCountDate = [NSDate date];
}

- (void)handleRedSwitch:(UISwitch *)switchView {
    BOOL isAuto = switchView.isOn;
    self.isAutoRed = isAuto;
}

- (void)setIsAutoRed:(BOOL)isAutoRed {
    [[NSUserDefaults standardUserDefaults] setBool:isAutoRed forKey:ConfigAutoRed_Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isAutoRed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:ConfigAutoRed_Key];
}


+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeInteger:self.stepCount forKey:@"stepCount"];
    [aCoder encodeObject:self.lastChangeStepCountDate forKey:@"lastChangeStepCountDate"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.stepCount = [aDecoder decodeIntegerForKey:@"stepCount"];
        self.lastChangeStepCountDate = [aDecoder decodeObjectForKey:@"lastChangeStepCountDate"];
    }
    return self;
}

@end

