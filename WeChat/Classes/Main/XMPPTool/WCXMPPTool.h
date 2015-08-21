//
//  WCXMPPTool.h
//  WeChat
//
//  Created by huyang on 15/7/28.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "Singleton.h"

typedef NS_ENUM(NSInteger, XMPPLoginResultType) {
    
    XMPPLoginResultTypeSuccess,    //登陆成功
    XMPPLoginResultTypeFailure,    //登录失败
    XMPPRegisterResultTypeSuccess, //注册成功
    XMPPRegisterResultTypeFailure  //注册失败
};
/*
 *  与服务器交互的结果
 */
typedef void (^XMPPLoginResultBlock)(XMPPLoginResultType);

@interface WCXMPPTool : NSObject

singleton_interface(WCXMPPTool)

@property(strong,nonatomic,readonly)XMPPStream *xmppStream ;//与服务器交互的核心类

@property(strong,nonatomic,readonly)XMPPvCardTempModule *vCard ;//电子名片
@property(strong,nonatomic,readonly)XMPPvCardCoreDataStorage *vCardStorage ;//电子名片数据存储
@property(strong,nonatomic,readonly)XMPPvCardAvatarModule *avatar ;//头像模块

@property(strong,nonatomic,readonly)XMPPRoster *roster;//好友列表
@property(strong,nonatomic,readonly)XMPPRosterCoreDataStorage *rosterStorage;//好友列表数据存储

@property(strong,nonatomic,readonly)XMPPMessageArchiving *messageArchiving ; //消息
@property(strong,nonatomic,readonly)XMPPMessageArchivingCoreDataStorage *messageArchivingStorage;//消息数据存储

/**
 *  标识连接服务器是登陆操作还是注册操作
 *   NO-> 代表登陆操作
 *  YES-> 代表注册操作
 */
@property(nonatomic,assign,getter=isRegisterOperation)BOOL registerOperation;

/**
 *  XMPP 用户登录
 */
- (void)xmppLogin:(XMPPLoginResultBlock)resultBlock ;

/**
 *  XMPP 用户注册
 */
- (void)xmppRegister:(XMPPLoginResultBlock)resultBlock ;

/**
 *  XMPP 用户注销
 */
- (void)xmppLogout ;

@end
