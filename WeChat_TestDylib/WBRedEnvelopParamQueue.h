//
//  WBRedEnvelopParamQueue.h
//  WeChat_TestDylib
//  
//  Created by ash on 2019/6/13.
//  Copyright © 2019 ash. All rights reserved.
//
    

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WeChatRedEnvelopParam;
@interface WBRedEnvelopParamQueue : NSObject

+ (instancetype)sharedQueue;

- (void)enqueue:(WeChatRedEnvelopParam *)param;
- (WeChatRedEnvelopParam *)dequeue;
- (WeChatRedEnvelopParam *)peek;
- (BOOL)isEmpty;

@end


NS_ASSUME_NONNULL_END
