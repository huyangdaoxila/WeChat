//
//  AppDelegate.m
//  WeChat
//
//  Created by huyang on 15/7/24.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "AppDelegate.h"
#import "DDTTYLogger.h"
#import "DDLog.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //配置XMPP的日志
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    
//    [self setupStream];
//    [self connectToHost];
    if ([WCAccount shareAccount].isLogin) {
        // 跳转到主界面
        //1.获取Main.storyboard的第一个控制器
        id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        
        //2.切换window的根视图控制器
        self.window.rootViewController = vc ;
        
        //3.自动登录
        [[WCXMPPTool sharedWCXMPPTool] xmppLogin:nil];
    }
    
    // 打印出沙盒的文件夹路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    WCLog(@"%@",paths);
    
    return YES;
}
@end




















