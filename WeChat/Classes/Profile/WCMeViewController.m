//
//  WCMeViewController.m
//  WeChat
//
//  Created by huyang on 15/7/27.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCMeViewController.h"
#import "XMPPvCardTemp.h"

@interface WCMeViewController ()

//头像图片
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
//登陆用户的微信账号
@property (weak, nonatomic) IBOutlet UILabel *weChatNumLabel;

@end

@implementation WCMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //显示微信头像和微信号
    //使用电子名片获取用户的个人信息
    //登录用户的电子名片信息
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp ;
    
    //获取头像
    if(myvCard.photo){
        self.avatarImgView.image = [UIImage imageWithData:myvCard.photo];
    }
    //微信号(显示用户名)
    //为什么jid是空,原因是服务器返回的XML数据中没有JABBERID这个节点
    //self.weChatNumLabel.text = myvCard.jid.user ;
    self.weChatNumLabel.text = [@"微信号:" stringByAppendingString:[WCAccount shareAccount].loginUser] ;
}

- (IBAction)logoutButtonClicked:(id)sender
{
    // 注销
    [[WCXMPPTool sharedWCXMPPTool] xmppLogout];
    NSLog(@"注销成功");
    
    //注销后把沙盒的登录状态设置为NO
    [WCAccount shareAccount].login = NO ;
    [[WCAccount shareAccount] saveToSandBox];
    
    // 切换到登陆界面
    [UIStoryboard showInitialVCWithName:@"login"];
}

@end
