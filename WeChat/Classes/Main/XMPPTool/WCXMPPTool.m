//
//  WCXMPPTool.m
//  WeChat
//
//  Created by huyang on 15/7/28.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCXMPPTool.h"

/**
 
 用户登陆流程
 
 1. 初始化XMPPStresm
 
 2. 连接服务器(传一个jid)
 
 3. 连接成功后发送密码
 
 4. 发送一个 "在线消息" 请求给服务器(默认登陆成功是不在线的)
 可以通知其他用户你已上线
 */
@interface WCXMPPTool ()<XMPPStreamDelegate>
{
    //由于网络问题与服务器断开连接时,他会过一定的时间间隔自己自动连接服务器
    XMPPReconnect *_reconnect ;//自动连接模块
    
    XMPPLoginResultBlock _resultBlock ;//结果回调block
}
/**
 *  1. 初始化XMPPStresm
 */
- (void)setupStream ;
/**
 *  释放资源
 */
- (void)tearDownStream ;
/**
 *  2. 连接服务器(传一个jid)
 */
- (void)connectToHost ;
/**
 *  3. 连接成功后发送密码
 */
- (void)sendPasswordToHost ;
/**
 *  4. 发送一个 "在线消息"
 */
- (void)sendOnline ;
/**
 *  发送一个 "离线消息"
 */
- (void)sendOffline ;
/**
 *  与主机断开连接
 */
- (void)disConnectFromHost ;

@end

@implementation WCXMPPTool

singleton_implementation(WCXMPPTool)


#pragma mark - 公共方法
- (void)setupStream
{
    // 初始化XMPPStream 对象
    _xmppStream = [[XMPPStream alloc] init];
    
    //添加XMPP模块
    //1.添加 "电子名片" 模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    //激活 "电子名片" 模块功能
    [_vCard activate:_xmppStream];
    
    //电子头像模块一般会配合"头像模块"一起使用
    //2.添加 "电子名片头像" 模块
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    //激活 "电子名片头像" 模块
    [_avatar activate:_xmppStream];
    
#warning 如果切换用户的话那么XMPP框架就会把以前的好友列表清空
    //3.添加 "好友列表" 模块(花名册)
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    //激活花名册模块
    [_roster activate:_xmppStream];
    
    //4.添加 "消息" 模块
    _messageArchivingStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_messageArchivingStorage];
    //激活 "消息" 模块
    [_messageArchiving activate:_xmppStream];
    
    //5.添加 "自动登陆" 模块
    _reconnect = [[XMPPReconnect alloc] init];
    //激活 "自动登陆" 模块
    [_reconnect activate:_xmppStream];
    
    // 设置代理
#warning 所有的代理方法都将在子线程(global_queue)中执行
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}
-(void)tearDownStream
{
    //移除代理
    [_xmppStream removeDelegate:self];
    
    //取消模块
    [_avatar deactivate];
    [_vCard deactivate];
    [_roster deactivate];
    [_messageArchiving deactivate];
    [_reconnect deactivate];
    
    //断开连接
    [_xmppStream disconnect];
    
    //清空资源
    _reconnect = nil ;
    _messageArchiving = nil;
    _messageArchivingStorage = nil ;
    _roster = nil;
    _rosterStorage = nil;
    _avatar = nil;
    _vCard = nil;
    _vCardStorage = nil ;
    _xmppStream = nil;
}
- (void)connectToHost
{
    if (!_xmppStream) {
        [self setupStream];
    }
    
    // 1. 设置登录用户的jid
    XMPPJID *myJid = nil;
    // resource 用户登录客户端的设备类型
    
    WCAccount *account = [WCAccount shareAccount];
    if (self.isRegisterOperation == YES) { // 注册操作
        NSString *registerUser = account.registerUser;
        myJid = [XMPPJID jidWithUser:registerUser domain:account.domain resource:nil];
    }else{                                 // 登陆操作
        NSString *loginUser = account.loginUser;
        myJid = [XMPPJID jidWithUser:loginUser domain:account.domain resource:nil];
    }
    
    _xmppStream.myJID = myJid ;
    
    // 2. 设置主机地址
    _xmppStream.hostName = account.host;
    
    // 3. 设置主机端口号 (默认就是5222,可以不设置)
    _xmppStream.hostPort = account.port ;
    
    // 4. 发起连接
    
    // 缺少必要的参数时就会发起连接失败(比如缺少jid)
    NSError *error = nil ;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
    if (error) {
        WCLog(@"%@",error);
    }else{
        WCLog(@"发起连接成功");
    }
}
- (void)sendPasswordToHost
{
    WCAccount *account = [WCAccount shareAccount];
    if(self.isRegisterOperation == YES){ // 发送注册的密码
        NSString *registerPwd = account.registerPassword;
        NSError *error = nil;
        [_xmppStream registerWithPassword:registerPwd error:&error];
        
        if (error) {
            WCLog(@"%@",error);
        }
    }else{                               // 发送登陆的密码
        NSString *loginPwd = account.loginPassword;
        NSError *error = nil;
        [_xmppStream authenticateWithPassword:loginPwd error:&error];
        
        if (error) {
            WCLog(@"%@",error);
        }
    }
}
- (void)sendOnline
{
    // XMPP框架已经把所有的指令全部封装为对象
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}
- (void)sendOffline
{
    // 发送离线消息
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
}
-(void)disConnectFromHost
{
    [_xmppStream disconnect];
}


#pragma mark - XMPPStream 代理方法
#pragma mark 建立连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    WCLog(@"%@",@"建立连接成功");
    [self sendPasswordToHost];
}
#pragma mark 登陆成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    WCLog(@"登陆成功");
    
    // 登陆成功以后发送在线请求,告知别人我已上线
    [self sendOnline];
    
    //回调resultBlock
    if(_resultBlock){
        _resultBlock(XMPPLoginResultTypeSuccess);
        //_resultBlock = nil;(调用完毕后置空也可以消除循环引用带来的内存泄露问题)
    }
}
#pragma mark 登陆失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    WCLog(@"%@",error);
    
    //回调resultBlock
    if(_resultBlock){
        _resultBlock(XMPPLoginResultTypeFailure);
        //_resultBlock = nil;(调用完毕后置空也可以消除循环引用带来的内存泄露问题)
    }
}
#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    WCLog(@"注册成功");
    if (_resultBlock) {
        _resultBlock(XMPPRegisterResultTypeSuccess);
    }
}
#pragma mark 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    WCLog(@"注册失败 -- %@",error);
    if (_resultBlock) {
        _resultBlock(XMPPRegisterResultTypeFailure);
    }
    
}

#pragma mark - 公共方法

#pragma mark 用户登录
-(void)xmppLogin:(XMPPLoginResultBlock)resultBlock
{
    // 每次登陆的时候都把以前的连接断开,重新请求
    [_xmppStream disconnect];
    
    // 保存resultBlock
    _resultBlock = resultBlock ;
    
    // 连接服务器开始登陆的操作
    [self connectToHost];
}

#pragma mark 用户注册
-(void)xmppRegister:(XMPPLoginResultBlock)resultBlock
{
    // 每次登陆的时候都把以前的连接断开,重新请求
    [_xmppStream disconnect];
    
    _resultBlock = resultBlock ;
    // 发送"注册的Jid"给服务器,请求一个长连接
    [self connectToHost];
    // 连接成功,发送注册密码
    [self sendPasswordToHost];
}

#pragma mark 用户注销
- (void)xmppLogout
{
    // 注销用户
    //1. 发送离线消息
    [self sendOffline];
    
    //2. 正常断开与服务器连接
    [self disConnectFromHost];
}

-(void)dealloc
{
    [self tearDownStream];
}

@end
