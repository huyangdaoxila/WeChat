//
//  WCAccount.h
//  WeChat
//
//  Created by huyang on 15/7/27.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCAccount : NSObject
/*
 用户登录账号
 */
@property(nonatomic,copy)NSString *loginUser ;
/*
 用户登录密码
 */
@property(nonatomic,copy)NSString *loginPassword ;
/*
 用户是否登录
 */
@property(nonatomic,assign,getter=isLogin)BOOL login ;
/*
 用户注册账号
 */
@property(nonatomic,copy)NSString *registerUser ;
/*
 用户注册密码
 */
@property(nonatomic,copy)NSString *registerPassword ;
/**
 *  服务器域名
 */
@property(nonatomic,copy,readonly)NSString *domain;
/**
 *  服务器IP
 */
@property(nonatomic,copy,readonly)NSString *host;
/**
 *  端口号
 */
@property(nonatomic,assign,readonly)int port ;
+ (instancetype)shareAccount ;

/**
 *  保存最新的用户信息到沙盒中
 */
- (void)saveToSandBox ;

@end
