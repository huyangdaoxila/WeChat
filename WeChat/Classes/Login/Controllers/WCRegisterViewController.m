//
//  WCRegisterViewController.m
//  WeChat
//
//  Created by huyang on 15/7/28.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCRegisterViewController.h"

@interface WCRegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)cancelItemClicked:(id)sender;
- (IBAction)registerButtonClicked:(id)sender;

@end

@implementation WCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelItemClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerButtonClicked:(id)sender
{
    //注册
    // 保存注册的用户名和密码
    [WCAccount shareAccount].registerUser = self.userField.text ;
    [WCAccount shareAccount].registerPassword = self.passwordField.text ;
        
    [WCXMPPTool sharedWCXMPPTool].registerOperation = YES ;
    __weak typeof(self) weakself = self ;
    [[WCXMPPTool sharedWCXMPPTool] xmppRegister:^(XMPPLoginResultType type) {
        
        [weakself handleXMPPRegisterResultWithType:type];
    }];
}
#pragma mark 处理注册的结果
- (void)handleXMPPRegisterResultWithType:(XMPPLoginResultType)type
{
    //回到主线程更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUD];
        if (type == XMPPRegisterResultTypeSuccess) {
            NSLog(@"%s.注册成功",__FUNCTION__);
            
            [MBProgressHUD showSuccess:@"恭喜注册成功"];
            
        }else{
            NSLog(@"%s,登陆失败",__FUNCTION__);
            [MBProgressHUD showError:@"用户名重复"];
        }
    });
}

@end
