//
//  WeChatClassHelp.h
//  WeChat_TestDylib
//  
//  Created by ash on 2019/6/10.
//  Copyright © 2019 ash. All rights reserved.
//
    
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class WCTableViewCellManager;

@interface SKBuiltinBuffer_t : NSObject

@property(retain, nonatomic) NSData *buffer; // @dynamic buffer;

@end

#pragma mark - Message

@interface WCPayInfoItem: NSObject

@property(retain, nonatomic) NSString *m_c2cNativeUrl;

@end

@interface CMessageWrap : NSObject

@property (retain, nonatomic) WCPayInfoItem *m_oWCPayInfoItem;
@property (assign, nonatomic) NSUInteger m_uiMesLocalID;
@property (retain, nonatomic) NSString* m_nsFromUsr;            ///< 发信人，可能是群或个人
@property (retain, nonatomic) NSString* m_nsToUsr;              ///< 收信人
@property (assign, nonatomic) NSUInteger m_uiStatus;
@property (retain, nonatomic) NSString* m_nsContent;            ///< 消息内容
@property (retain, nonatomic) NSString* m_nsRealChatUsr;        ///< 群消息的发信人，具体是群里的哪个人
@property (assign, nonatomic) NSUInteger m_uiMessageType;
@property (assign, nonatomic) long long m_n64MesSvrID;
@property (assign, nonatomic) NSUInteger m_uiCreateTime;
@property (retain, nonatomic) NSString *m_nsDesc;
@property (retain, nonatomic) NSString *m_nsAppExtInfo;
@property (assign, nonatomic) NSUInteger m_uiAppDataSize;
@property (assign, nonatomic) NSUInteger m_uiAppMsgInnerType;
@property (retain, nonatomic) NSString *m_nsShareOpenUrl;
@property (retain, nonatomic) NSString *m_nsShareOriginUrl;
@property (retain, nonatomic) NSString *m_nsJsAppId;
@property (retain, nonatomic) NSString *m_nsPrePublishId;
@property (retain, nonatomic) NSString *m_nsAppID;
@property (retain, nonatomic) NSString *m_nsAppName;
@property (retain, nonatomic) NSString *m_nsThumbUrl;
@property (retain, nonatomic) NSString *m_nsAppMediaUrl;
@property (retain, nonatomic) NSData *m_dtThumbnail;
@property (retain, nonatomic) NSString *m_nsTitle;
@property (retain, nonatomic) NSString *m_nsMsgSource;

- (id)initWithMsgType:(long long)arg1;
+ (_Bool)isSenderFromMsgWrap:(id)arg1;

@end

#pragma mark - RedEnvelop


@interface WCRedEnvelopesControlData : NSObject

@property(retain, nonatomic) CMessageWrap *m_oSelectedMessageWrap;

@end

@interface WCRedEnvelopesLogicMgr: NSObject

- (void)OpenRedEnvelopesRequest:(id)params;
- (void)ReceiverQueryRedEnvelopesRequest:(id)arg1;
- (void)GetHongbaoBusinessRequest:(id)arg1 CMDID:(unsigned int)arg2 OutputType:(unsigned int)arg3;

/** Added Methods */
- (unsigned int)calculateDelaySeconds;

@end

@interface HongBaoRes : NSObject

@property(retain, nonatomic) SKBuiltinBuffer_t *retText; // @dynamic retText;
@property(nonatomic) int cgiCmdid; // @dynamic cgiCmdid;

@end

@interface HongBaoReq : NSObject

@property(retain, nonatomic) SKBuiltinBuffer_t *reqText; // @dynamic reqText;

@end



#pragma mark - TableViewManager
@interface WCTableView : UITableView

@end

@interface WCTableViewManager : NSObject

- (void)insertSection:(id)arg1 At:(unsigned int)arg2;

@end

@interface WCTableViewSectionManager : NSObject

+ (id)defaultSection;

- (void)insertCell:(WCTableViewCellManager *)cell At:(unsigned int)index;

- (void)addCell:(WCTableViewCellManager *)cell;

@end

@interface WCTableViewCellManager : NSObject

+ (id)normalCellForTitle:(id)arg1;

+ (id)switchCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 on:(_Bool)arg4;

+ (id)editorCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 tip:(id)arg4 focus:(_Bool)arg5 autoCorrect:(_Bool)arg6 text:(id)arg7;

@end

@interface WCTableViewNormalCellManager : WCTableViewCellManager

@end

#pragma mark - ViewController

@interface MMUIViewController : UIViewController

- (void)startLoadingBlocked;
- (void)startLoadingNonBlock;
- (void)startLoadingWithText:(NSString *)text;
- (void)stopLoading;
- (void)stopLoadingWithFailText:(NSString *)text;
- (void)stopLoadingWithOKText:(NSString *)text;

@end

@interface NewSettingViewController : MMUIViewController

- (void)reloadTableData;

@end
