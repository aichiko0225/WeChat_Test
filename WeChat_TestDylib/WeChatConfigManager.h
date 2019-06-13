//
//  WeChatConfigManager.h
//  WeChat_TestDylib
//  
//  Created by ash on 2019/6/10.
//  Copyright © 2019 ash. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString* const ConfigAutoRed_Key;
FOUNDATION_EXPORT NSString* const WeChatConfigManager_Key;

@interface WeChatConfigManager : NSObject
/// 是否自动抢红包
@property (nonatomic, assign, readonly) BOOL isAutoRed;
/// 微信步数
@property (nonatomic, assign) NSInteger stepCount;

@property (nonatomic, retain) NSDate *lastChangeStepCountDate;

+ (instancetype)sharedManager;
+ (void)loadInstance:(WeChatConfigManager *)instance;

@end

NS_ASSUME_NONNULL_END
