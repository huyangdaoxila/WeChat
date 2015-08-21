//
//  WCLoginViewController.m
//  WeChat
//
//  Created by huyang on 15/7/27.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCLoginViewController.h"
#import "MBProgressHUD+HM.h"

@interface WCLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation WCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)loginButtonClicked:(id)sender
{
    // 1. 判断是否输入用户名及密码
    if (self.userField.text.length == 0 || self.passwordField.text.length == 0) {
        NSLog(@"请输入用户名及密码");
        return ;
    }
    
    [MBProgressHUD showMessage:@"正在登陆..." toView:self.view];
    
    // 2. 登录服务器
//    // 2.1 把用户名集密码保存到沙盒
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    [ud setObject:self.userField.text forKey:@"user"];
//    [ud setObject:self.passwordField.text forKey:@"password"];
//    [ud synchronize];
    // 2.1 把用户名集密码保存到WCAccount单例中
    [WCAccount shareAccount].loginUser = self.userField.text;
    [WCAccount shareAccount].loginPassword = self.passwordField.text ;
    
    // 2.2 调用AppDelegate的xmppLogin方法
    // block会对self进行强引用,导致循环引用无法释放内存泄露
    /*
     自己写的block,有强引用的时候我们要使用弱引用,对于系统的block我们可以不用弱引用处理
     (除了弱引用以外我们还可以block调用完毕后将block置空,)
     */
    [WCXMPPTool sharedWCXMPPTool].registerOperation = NO ;
    __weak typeof(self) weakself = self ;
    [[WCXMPPTool sharedWCXMPPTool] xmppLogin:^(XMPPLoginResultType resultType) {
        
        [weakself handleXMPPLoginResultWithType:resultType];
    }];
}

- (void)handleXMPPLoginResultWithType:(XMPPLoginResultType)type
{
    //回到主线程更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUD];
        if (type == XMPPLoginResultTypeSuccess) {
            NSLog(@"%s.登陆成功",__FUNCTION__);
            
            // 3. 登陆成功切换到主界面
            [UIStoryboard showInitialVCWithName:@"Main"];
            
            // 设置登录状态
            [WCAccount shareAccount].login = YES ;
            // 保存账户登录信息
            [[WCAccount shareAccount] saveToSandBox];
            
        }else{
            NSLog(@"%s,登陆失败",__FUNCTION__);
            [MBProgressHUD showError:@"用户名或密码不正确"];
        }
    });
}

//#pragma mark  切换到主界面
//- (void)changeToMainController
//{
//    //1.获取Main.storyboard的第一个控制器
//    id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
//    
//    //2.切换window的根视图控制器
//    [UIApplication sharedApplication].keyWindow.rootViewController = vc ;
//}

@end
