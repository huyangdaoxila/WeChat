//
//  WCAddFriendViewController.m
//  WeChat
//
//  Created by huyang on 15/7/30.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCAddFriendViewController.h"

@interface WCAddFriendViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation WCAddFriendViewController

- (IBAction)addItemClicked:(id)sender
{
    // 添加好友
    NSString *user = self.textField.text ;
    
    //1.不能添加自己为好友
    if([user isEqualToString:[WCAccount shareAccount].loginUser])
    {
        [self showAlertMessageWithString:@"不能添加自己为好友"];
        return ;
    }
    
    //2.已经是好友的不能添加
    XMPPJID *userJid = [XMPPJID jidWithUser:user domain:[WCAccount shareAccount].domain resource:nil];
    BOOL isContact = [[WCXMPPTool sharedWCXMPPTool].rosterStorage userExistsWithJID:userJid xmppStream:[WCXMPPTool sharedWCXMPPTool].xmppStream] ;
    if (isContact == YES) {
        [self showAlertMessageWithString:@"已经是好友了!"];
        return ;
    }
    
    //3.正常添加好友(订阅)
    
    /* 解决添加好友在现有的openfire服务器存在的问题
    问题1.添加不存在的好友,通讯录里面也显示了好友
    解决方法1. 用服务器拦截好友添加请求,如果数据库中没有该好友就不要返回信息给客户端(建议使用这种)
    解决办法2. 客户端过滤本地数据库的Subscription字段查询请求(不建议这样做,因为如果服务器不拦截的话,那么我们客户端本地的数据库中会因为这种失误操作存取太多的无效联系人,浪费资源)
        none 对方没有同意添加好友
        to   发给对方添加好友
        from 别人发来的添加好友
        both 双方互为好友
     */
    
    if(user.length > 0)
    {
        [[WCXMPPTool sharedWCXMPPTool].roster subscribePresenceToUser:userJid];
    }
    
}
- (void)showAlertMessageWithString:(NSString *)str
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;
}



@end
