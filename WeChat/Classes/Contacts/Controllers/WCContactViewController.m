//
//  WCContactViewController.m
//  WeChat
//
//  Created by huyang on 15/7/29.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCContactViewController.h"
#import "WCChatViewController.h"

@interface WCContactViewController ()<NSFetchedResultsControllerDelegate>

{
    NSFetchedResultsController *_resultsController ;
}

@property(strong,nonatomic)NSArray *contacts ;

@end

@implementation WCContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadUserContacts2];
}

#pragma mark 加载用户联系人方法2
//方法1配合"NSFetchedResultsController"这个类可以实时刷新好友在线状态
- (void)loadUserContacts2
{
    //显示好友数据 (这个数据保存在XMPPRoster.sqlite文件中)
    
    //1.上下文关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [WCXMPPTool sharedWCXMPPTool].rosterStorage.mainThreadManagedObjectContext ;
    
    //2.request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 过滤不是好友关系的联系人
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@",@"none"];
    request.predicate = pre ;
    
    //3.执行请求
    //3.1创建结果控制器
    // 数据库的查询 , 如果数据比较多的话就会放在子线程查询
    // 移动客户端的数据库数据不会很多,一般放在主线程里进行查询操作
    _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    _resultsController.delegate = self ;
    NSError *error = nil;
    //3.2 执行请求
    [_resultsController performFetch:&error];
}

#pragma mark 结果控制器的代理方法
#pragma mark 结果控制器的内容改变就会调用这个方法(这个方法在主线程里调用)
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    WCLog(@"________");
    [self.tableView reloadData];
}

#pragma mark 加载用户联系人方法1
//方法1配合KVO可以实时刷新好友在线状态
- (void)loadUserContacts1
{
    //显示好友数据 (这个数据保存在XMPPRoster.sqlite文件中)
    
    //1.上下文关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [WCXMPPTool sharedWCXMPPTool].rosterStorage.mainThreadManagedObjectContext ;
    
    //2.request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //执行请求
    NSError *error = nil;
    _contacts = [rosterContext executeFetchRequest:request error:&error];
    
    if (!error) {
        WCLog(@"成功获取好友列表  %@",_contacts);
    }else{
        WCLog(@"获取好友列表失败");
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return _contacts.count;
    return _resultsController.fetchedObjects.count ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
//    XMPPUserCoreDataStorageObject *contact = self.contacts[indexPath.row];
    XMPPUserCoreDataStorageObject *contact = _resultsController.fetchedObjects[indexPath.row];
    
    //sectionNum 这个属性标注用户是否在线
    // 0->在线 , 1->离开 , 2->离线
    
    //通过KVO来监听用户在线状态的改变
//    [contact addObserver:self forKeyPath:@"sectionNum" options:NSKeyValueObservingOptionNew context:nil];
    
    cell.textLabel.text = [contact.displayName stringByAppendingString:[contact.sectionNum stringValue]];
    
    switch ([contact.sectionNum intValue]) {
        case 0: //在线
        {
            cell.detailTextLabel.text = @"在线";
        }
            break;
        case 1: //离开
        {
            cell.detailTextLabel.text = @"离开";
        }
            break;
        case 2: //离线
        {
            cell.detailTextLabel.text = @"离线";
        }
            break;
            
        default:
        {
            cell.detailTextLabel.text = @"未知";
        }
            break;
    }
    
    // 显示好友的头像
    if(contact.photo){ //默认的头像, 不是程序一启动就有的
        cell.imageView.image = contact.photo ;
    }else{             //可以从服务器直接通过头像模块获取头像
        NSData *avatarData = [[WCXMPPTool sharedWCXMPPTool].avatar photoDataForJID:contact.jid];
        cell.imageView.image = [UIImage imageWithData:avatarData];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPJID *frienfJid = [_resultsController.fetchedObjects[indexPath.row] jid];
    [self performSegueWithIdentifier:@"toChatVCSegue" sender:frienfJid];
}

#pragma mark 实现好友删除功能
// 这个方法可以实现对cell的编辑
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取当前cell显示的好友
    XMPPUserCoreDataStorageObject *contact = _resultsController.fetchedObjects[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除好友
        // 这个操作会在coreData数据库中删除当前好友,而我们使用的 "NSFetchedResultsController" 这个类会实时监控数据库中好友状态的变化并实时刷新表格,因此在这里删除后我们不用刷新表格
        [[WCXMPPTool sharedWCXMPPTool].roster removeUser:contact.jid];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //获取目标控制器
    id chatVC = segue.destinationViewController ;
    
    //把cell传过去
    if ([chatVC isKindOfClass:[WCChatViewController class]])
    {
        WCChatViewController *chat = chatVC ;
        chat.friendJid = sender;
    }
}







#pragma mark KVO代理方法
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    WCLog(@"sdferfvfe");
//    [self.tableView reloadData];
//}



@end
