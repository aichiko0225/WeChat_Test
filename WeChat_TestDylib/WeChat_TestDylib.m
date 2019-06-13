//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  WeChat_TestDylib.m
//  WeChat_TestDylib
//
//  Created by 赵光飞 on 2019/6/9.
//  Copyright (c) 2019 ash. All rights reserved.
//

#import "WeChat_TestDylib.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import <MDCycriptManager.h>
#import <CoreMotion/CoreMotion.h>
#import <OCMethodTrace.h>
#import <WeChatClassHelp.h>
#import <objc/objc-runtime.h>
#import <WeChatConfigManager.h>
#import <WeChatRedEnvelopParam.h>
#import <WBRedEnvelopParamQueue.h>
#import <WBReceiveRedEnvelopOperation.h>
#import <WBRedEnvelopTaskManager.h>
#if DEBUG
#import "FLEXManager.h"
#endif

#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wunused-function"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

CHConstructor{
    printf(INSERT_SUCCESS_WELCOME);
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
#ifndef __OPTIMIZE__
        CYListenServer(6666);

        MDCycriptManager* manager = [MDCycriptManager sharedInstance];
        [manager loadCycript:NO];

        NSError* error;
        NSString* result = [manager evaluateCycript:@"UIApp" error:&error];
        NSLog(@"result: %@", result);
        if(error.code != 0){
            NSLog(@"error: %@", error.localizedDescription);
        }
#endif
    }];
}

/*
CHDeclareClass(CustomViewController)

//add new method
CHDeclareMethod1(void, CustomViewController, newMethod, NSString*, output){
    NSLog(@"This is a new method : %@", output);
}

#pragma clang diagnostic pop

CHOptimizedClassMethod0(self, void, CustomViewController, classMethod){
    NSLog(@"hook class method");
    CHSuper0(CustomViewController, classMethod);
}

CHOptimizedMethod0(self, NSString*, CustomViewController, getMyName){
    //get origin value
    NSString* originName = CHSuper(0, CustomViewController, getMyName);
    
    NSLog(@"origin name is:%@",originName);
    
    //get property
    NSString* password = CHIvar(self,_password,__strong NSString*);
    
    NSLog(@"password is %@",password);
    
    [self newMethod:@"output"];
    
    //set new property
    self.newProperty = @"newProperty";
    
    NSLog(@"newProperty : %@", self.newProperty);
    
    //change the value
    return @"赵光飞";
    
}
*/

//add new property
//CHPropertyRetainNonatomic(CustomViewController, NSString*, newProperty, setNewProperty);

CHDeclareClass(MicroMessengerAppDelegate)

CHOptimizedMethod2(self, void, MicroMessengerAppDelegate, application, UIApplication *, application, didFinishLaunchingWithOptions, NSDictionary *, options) {
    CHSuper2(MicroMessengerAppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    // 监听 Cycript 8888 端口
    NSLog(@"## Start Cycript ##");
    CYListenServer(6666);
    
    NSLog(@"## Load WeChatConfigManager ##");
    NSData *managerData = [[NSUserDefaults standardUserDefaults] objectForKey:WeChatConfigManager_Key];
    if (managerData) {
        WeChatConfigManager *manager = [NSKeyedUnarchiver unarchiveObjectWithData:managerData];
        if (manager) { [WeChatConfigManager loadInstance:manager]; }
    }
#if DEBUG
    [[FLEXManager sharedManager] showExplorer];
#endif
}

CHOptimizedMethod1(self, void, MicroMessengerAppDelegate, applicationWillResignActive, UIApplication *, application) {
    CHSuper1(MicroMessengerAppDelegate, applicationWillResignActive, application);
    if (@available(iOS 11.0, *)) {
        NSData *centerData = [NSKeyedArchiver archivedDataWithRootObject:[WeChatConfigManager sharedManager] requiringSecureCoding:NO error:NULL];
        [[NSUserDefaults standardUserDefaults] setObject:centerData forKey:WeChatConfigManager_Key];
    } else {
        // Fallback on earlier versions
        NSData *centerData =  [NSKeyedArchiver archivedDataWithRootObject:[WeChatConfigManager sharedManager]];
        [[NSUserDefaults standardUserDefaults] setObject:centerData forKey:WeChatConfigManager_Key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

CHDeclareClass(NewSettingViewController)
CHDeclareClass(WCTableViewManager)
CHDeclareClass(WCTableViewSectionManager)
CHDeclareClass(WCTableViewNormalCellManager)
CHDeclareClass(WCTableViewCellManager)
CHDeclareClass(WCDeviceStepObject)

CHOptimizedMethod0(self, void, NewSettingViewController, reloadTableData) {
    NSLog(@"hook reloadTableData method !!!");
    CHSuper0(NewSettingViewController, reloadTableData);
    
    CHLoadLateClass(WCTableViewManager);
    CHLoadLateClass(WCTableViewSectionManager);
    CHLoadLateClass(WCTableViewNormalCellManager);
    CHLoadLateClass(WCTableViewCellManager);
    [self startLoadingBlocked];
    //get property
    WCTableViewManager *tableViewMgr = CHIvar(self,m_tableViewMgr,__strong WCTableViewManager*);
    
//    WCTableViewManager *tableViewMgr = [self valueForKeyPath:@"m_tableViewMgr"];
//    WCTableViewSectionManager *sectionMgr = ((WCTableViewSectionManager* (*) (Class, SEL))objc_msgSend)(NSClassFromString(@"WCTableViewSectionManager"), @selector(defaultSection));
    
    WCTableViewSectionManager *sectionMgr = [objc_getClass("WCTableViewSectionManager") defaultSection];
    
    WCTableViewNormalCellManager *cellMgr = [objc_getClass("WCTableViewNormalCellManager") switchCellForSel:@selector(handleRedSwitch:) target:[WeChatConfigManager sharedManager] title:@"自动抢红包" on:[WeChatConfigManager sharedManager].isAutoRed];
    // objc_msgSend 的写法太麻烦了
//    WCTableViewNormalCellManager *cellMgr = ((WCTableViewNormalCellManager* (*) (Class, SEL, SEL, id, id, _Bool))objc_msgSend)(NSClassFromString(@"WCTableViewNormalCellManager"), @selector(switchCellForSel:target:title:on:), @selector(handleRedSwitch:), [WeChatConfigManager sharedManager], @"自动抢红包", [WeChatConfigManager sharedManager].isAutoRed);
    
//    WCTableViewNormalCellManager *cellMgr_step = ((WCTableViewNormalCellManager* (*) (Class, SEL, SEL, id, NSString *, NSString *, _Bool, _Bool, NSString *))objc_msgSend)(NSClassFromString(@"WCTableViewNormalCellManager"), @selector(editorCellForSel:target:title:tip:focus:autoCorrect:text:), @selector(handleStepCount:), [WeChatConfigManager sharedManager], @"微信运动步数", @"请输入步数", false, true, [NSString stringWithFormat:@"%ld", (long)[WeChatConfigManager sharedManager].stepCount]);
    
    WCTableViewNormalCellManager *cellMgr_step = [objc_getClass("WCTableViewNormalCellManager") editorCellForSel:@selector(handleStepCount:) target:[WeChatConfigManager sharedManager] title:@"微信运动步数" tip:@"请输入步数" focus:NO autoCorrect:YES text:[NSString stringWithFormat:@"%ld", (long)[WeChatConfigManager sharedManager].stepCount]];
    
    [sectionMgr insertCell:cellMgr At:0];
    [sectionMgr addCell:cellMgr_step];
    [tableViewMgr insertSection:sectionMgr At:0];
    
    WCTableView *tableView = (WCTableView *)[tableViewMgr valueForKeyPath:@"_tableView"];
    [tableView reloadData];
    [self stopLoading];
}

// 微信运动步数

CHOptimizedMethod0(self, unsigned int, WCDeviceStepObject, m7StepCount)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[WeChatConfigManager sharedManager].lastChangeStepCountDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    BOOL modifyToday = NO;
    if([today isEqualToDate:otherDate]) {
        modifyToday = YES;
    }
    unsigned int count = CHSuper0(WCDeviceStepObject, m7StepCount);
    if ([WeChatConfigManager sharedManager].stepCount == 0 || !modifyToday) {
        [WeChatConfigManager sharedManager].stepCount = count;
    }
    
    if (count >= [WeChatConfigManager sharedManager].stepCount) {
        return count;
    }
    return (int)[WeChatConfigManager sharedManager].stepCount;
}

CHDeclareClass(WCRedEnvelopesLogicMgr)
CHDeclareClass(CMessageMgr)

CHOptimizedMethod2(self, void, WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, HongBaoRes *, arg1, Request, HongBaoReq *, arg2) {
    CHSuper2(WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, arg1, Request, arg2);
    
    // 非参数查询请求
    if (arg1.cgiCmdid != 3) { return; }
    
    NSString *(^parseRequestSign)(void) = ^NSString *() {
        NSString *requestString = [[NSString alloc] initWithData:arg2.reqText.buffer encoding:NSUTF8StringEncoding];
        NSDictionary *requestDictionary = [objc_getClass("WCBizUtil") dictionaryWithDecodedComponets:requestString separator:@"&"];
        NSString *nativeUrl = [[requestDictionary stringForKey:@"nativeUrl"] stringByRemovingPercentEncoding];
        NSDictionary *nativeUrlDict = [objc_getClass("WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
        
        return [nativeUrlDict stringForKey:@"sign"];
    };
    
    NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];
    
    WeChatRedEnvelopParam *mgrParams = [[WBRedEnvelopParamQueue sharedQueue] dequeue];
    
    BOOL (^shouldReceiveRedEnvelop)(void) = ^BOOL() {
        
        // 手动抢红包
        if (!mgrParams) { return NO; }
        
        // 自己已经抢过
        if ([responseDict[@"receiveStatus"] integerValue] == 2) { return NO; }
        
        // 红包被抢完
        if ([responseDict[@"hbStatus"] integerValue] == 4) { return NO; }
        
        // 没有这个字段会被判定为使用外挂
        if (!responseDict[@"timingIdentifier"]) { return NO; }
        
        if (mgrParams.isGroupSender) { // 自己发红包的时候没有 sign 字段
            return [WeChatConfigManager sharedManager].isAutoRed;
        } else {
            return [parseRequestSign() isEqualToString:mgrParams.sign] && [WeChatConfigManager sharedManager].isAutoRed;
        }
    };
    
    if (shouldReceiveRedEnvelop()) {
        mgrParams.timingIdentifier = responseDict[@"timingIdentifier"];
        
        unsigned int delaySeconds = [self calculateDelaySeconds];
        WBReceiveRedEnvelopOperation *operation = [[WBReceiveRedEnvelopOperation alloc] initWithRedEnvelopParam:mgrParams delay:delaySeconds];
        
        [[WBRedEnvelopTaskManager sharedManager] addNormalTask:operation];
    }
    
}

CHDeclareMethod0(unsigned int, WCRedEnvelopesLogicMgr, calculateDelaySeconds) {
    return 1;
}

CHOptimizedMethod2(self, void, CMessageMgr, AsyncOnAddMsg, NSString *, msg, MsgWrap, CMessageWrap *, wrap) {
    CHSuper2(CMessageMgr, AsyncOnAddMsg, msg, MsgWrap, wrap);
    
    switch (wrap.m_uiMessageType) {
        case 49: {
            /** 是否为红包消息 */
            BOOL (^isRedEnvelopMessage)(void) = ^BOOL() {
                return [wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound;
            };
            
            if (isRedEnvelopMessage()) {
                // 红包
                CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
                CContact *selfContact = [contactManager getSelfContact];
                
                BOOL (^isSender)(void) = ^BOOL() {
                    return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
                };
                
                /** 是否别人在群聊中发消息 */
                BOOL (^isGroupReceiver)(void) = ^BOOL() {
                    return [wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound;
                };
                
                /** 是否自己在群聊中发消息 */
                BOOL (^isGroupSender)(void) = ^BOOL() {
                    return isSender() && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
                };
                
                /** 是否自动抢红包 */
                BOOL (^shouldReceiveRedEnvelop)(void) = ^BOOL() {
                    if (![WeChatConfigManager sharedManager].isAutoRed) { return NO; }
                    return isGroupReceiver() || isGroupSender();
                };
                
                NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
                    nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
                    return [objc_getClass("WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
                };
                
                /** 获取服务端验证参数 */
                void (^queryRedEnvelopesReqeust)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                    NSMutableDictionary *params = [@{} mutableCopy];
                    params[@"agreeDuty"] = @"0";
                    params[@"channelId"] = [nativeUrlDict stringForKey:@"channelid"];
                    params[@"inWay"] = @"0";
                    params[@"msgType"] = [nativeUrlDict stringForKey:@"msgtype"];
                    params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    params[@"sendId"] = [nativeUrlDict stringForKey:@"sendid"];
                    
                    WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
                    [logicMgr ReceiverQueryRedEnvelopesRequest:params];
                };
                
                /** 储存参数 */
                void (^enqueueParam)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                    WeChatRedEnvelopParam *mgrParams = [[WeChatRedEnvelopParam alloc] init];
                    mgrParams.msgType = [nativeUrlDict stringForKey:@"msgtype"];
                    mgrParams.sendId = [nativeUrlDict stringForKey:@"sendid"];
                    mgrParams.channelId = [nativeUrlDict stringForKey:@"channelid"];
                    mgrParams.nickName = [selfContact getContactDisplayName];
                    mgrParams.headImg = [selfContact m_nsHeadImgUrl];
                    mgrParams.nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    mgrParams.sessionUserName = isGroupSender() ? wrap.m_nsToUsr : wrap.m_nsFromUsr;
                    mgrParams.sign = [nativeUrlDict stringForKey:@"sign"];
                    
                    mgrParams.isGroupSender = isGroupSender();
                    
                    [[WBRedEnvelopParamQueue sharedQueue] enqueue:mgrParams];
                };
                
                if (shouldReceiveRedEnvelop()) {
                    NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    NSDictionary *nativeUrlDict = parseNativeUrl(nativeUrl);
                    
                    queryRedEnvelopesReqeust(nativeUrlDict);
                    enqueueParam(nativeUrlDict);
                }
            }
        }// AppNode
            break;
            
        default:
            break;
    }
}


CHConstructor{
//    CHLoadLateClass(CustomViewController);
//    CHClassHook0(CustomViewController, getMyName);
//    CHClassHook0(CustomViewController, classMethod);
//
//    CHHook0(CustomViewController, newProperty);
//    CHHook1(CustomViewController, setNewProperty);

    
    CHLoadLateClass(WCDeviceStepObject);
    CHHook0(WCDeviceStepObject, m7StepCount);
    
    CHLoadLateClass(NewSettingViewController);
    CHHook0(NewSettingViewController, reloadTableData);
    
    CHLoadLateClass(MicroMessengerAppDelegate);  // load class (that will be "available later")
    CHHook2(MicroMessengerAppDelegate, application, didFinishLaunchingWithOptions); // register hook
    CHHook1(MicroMessengerAppDelegate, applicationWillResignActive);
    
    CHLoadLateClass(WCRedEnvelopesLogicMgr);
    CHLoadLateClass(CMessageMgr);
    
    
    CHHook2(WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, Request);
    CHHook2(CMessageMgr, AsyncOnAddMsg, MsgWrap);
    
}

