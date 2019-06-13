//
//  WBRedEnvelopTaskManager.h
//  WeChat_TestDylib
//  
//  Created by ash on 2019/6/13.
//  Copyright © 2019 ash. All rights reserved.
//
    

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WBReceiveRedEnvelopOperation;
@interface WBRedEnvelopTaskManager : NSObject

+ (instancetype)sharedManager;

- (void)addNormalTask:(WBReceiveRedEnvelopOperation *)task;
- (void)addSerialTask:(WBReceiveRedEnvelopOperation *)task;

- (BOOL)serialQueueIsEmpty;

@end

NS_ASSUME_NONNULL_END
