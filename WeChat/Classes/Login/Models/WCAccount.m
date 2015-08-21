//
//  WCAccount.m
//  WeChat
//
//  Created by huyang on 15/7/27.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCAccount.h"
#define kUserKey     @"user"
#define kPasswordKey @"password"
#define kLoginKey    @"isLogin"

static NSString *domain = @"young4ever.local";
static NSString *host = @"127.0.0.1";
static int port = 5222 ;

@implementation WCAccount

-(NSString*)host{
    return host ;
}
-(NSString*)domain{
    return domain;
}
-(int)port{
    return port;
}
+ (instancetype)shareAccount
{
    return [[self alloc] init];
}

#pragma mark  分配内存创建对象
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static WCAccount *account ;
    static dispatch_once_t onceToken ;
    // 这样写的目的线程安全
    dispatch_once(&onceToken, ^{
        if (account == nil) { // 因只会调用一次所以不用判断是否为空
            account = [super allocWithZone:zone];
            
            // 从沙盒获取用户的上次登录信息
            account.loginUser = [[NSUserDefaults standardUserDefaults] objectForKey:kUserKey];
            account.loginPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kPasswordKey];
            account.login = [[NSUserDefaults standardUserDefaults] boolForKey:kLoginKey];
        }
        
    });
    return account;
}

- (void)saveToSandBox
{
    // 保存user, password , login
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:self.loginUser forKey:kUserKey];
    [ud setObject:self.loginPassword forKey:kPasswordKey];
    [ud setBool:self.isLogin forKey:kLoginKey];
    [ud synchronize];
}

@end
