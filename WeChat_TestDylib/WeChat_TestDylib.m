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
#if DEBUG
#import "FLEXManager.h"
#endif

#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wunused-function"


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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

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
}

