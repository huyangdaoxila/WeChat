//
//  WCChatViewController.m
//  WeChat
//
//  Created by huyang on 15/7/30.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCChatViewController.h"

@interface WCChatViewController ()<UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate,
                                   NSFetchedResultsControllerDelegate,
                                   UITableViewDataSource,
                                   UITableViewDelegate,
                                   UITextFieldDelegate>

{
    NSFetchedResultsController *_resultController ;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// 输入框容器距离屏幕底部的约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *textFiled;

@end

@implementation WCChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //加载数据库的聊天记录
    
    //1.拿到上下文
    NSManagedObjectContext *msgContext = [WCXMPPTool sharedWCXMPPTool].messageArchivingStorage.mainThreadManagedObjectContext ;
    
    //2.查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    NSString *bareStr = [WCXMPPTool sharedWCXMPPTool].xmppStream.myJID.bare ;
    WCLog(@"bare --- %@",bareStr);
    // 过滤 (条件为收件人 "streamBareJidStr" 是当前用户, 并且发信息的人 "bareJid" 是上个界面选中的好友)
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",bareStr,self.friendJid.bare];
    request.predicate = pre ;
    
    //设置时间排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    //3.执行请求
    _resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _resultController.delegate = self ;
    NSError *error = nil ;
    [_resultController performFetch:&error];
    WCLog(@"error == %@",error);
    WCLog(@"result ----- %@",_resultController.fetchedObjects);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    
    //表格滚动到底部
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_resultController.fetchedObjects.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 发送附件
- (IBAction)addButtonClicked:(id)sender
{
    //初始化图片选择控制器
    UIImagePickerController *imgPC = [[UIImagePickerController alloc] init];
    
    //设置代理
    imgPC.delegate = self ;
    
    //设置资源类型为图片库
    imgPC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary ;
    
    //模态推出图片选择控制器
    [self presentViewController:imgPC animated:YES completion:nil];
}

#pragma mark 用户选择的图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 拿到用户选中的原图
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    
    // 发送附件
    [self sendAttachmentWithData:UIImagePNGRepresentation(img) andBodyType:@"image"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 发送附件
- (void)sendAttachmentWithData:(NSData *)data andBodyType:(NSString *)type
{
    
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    
    // 发送图片
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    // 设置类型
    [msg addAttributeWithName:@"bodyType" stringValue:type];
    
    // body 必须赋值,否则将不能解析这个 "XMPPMessage"
    [msg addBody:type];
    
    // 定义附件
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64Str];
    
    // 添加子节点
    [msg addChild:attachment];
    
    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
}

//- (void)sendAttachmentWithImage:(UIImage *)img
//{
//    //把图片经过 "base64编码" 转成字符串
//    //1.先把图片转成NSData
//    NSData *imgData = UIImagePNGRepresentation(img);
//    //2.再把图片转成字符串
//    NSString *imgBase64Str = [imgData base64EncodedStringWithOptions:0];
//    
//    // 发送图片
//    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
//    
//    // body 必须赋值,否则将不能解析这个 "XMPPMessage"
//    [msg addBody:@"image"];
//    
//    // 定义附件
//    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:imgBase64Str];
//    
//    // 添加子节点
//    [msg addChild:attachment];
//    
//    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
//    
//    WCLog(@"%@",imgBase64Str);
//}

#pragma mark tableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 ;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultController.fetchedObjects.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"tableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    XMPPMessageArchiving_Message_CoreDataObject *messageObj = _resultController.fetchedObjects[indexPath.row];
    
    //判断消息的类型有没有附件
    //1.获取原始的xml数据
    XMPPMessage *message = messageObj.message ;
    
    NSString *bodyType = [message attributeStringValueForName:@"bodyType"];
    
    //2.遍历message的子节点
    if ([bodyType isEqualToString:@"image"]) { //图片
        NSArray *chindren = message.children ;
        for (XMPPElement *note in chindren) {
            //获取节点名称
            if([note.name isEqualToString:@"attachment"]){
                WCLog(@"获取到附件");
                //获取附件字符串,然后转成NSData,再转成图片
                NSString *imgBase64Str = [note stringValue];
                NSData *imgData = [[NSData alloc] initWithBase64EncodedString:imgBase64Str options:0];
                cell.imageView.image = [UIImage imageWithData:imgData];
            }
        }
    }else if ([bodyType isEqualToString:@"sound"]){ // 音频
    
    }else { // 文档
        
    }
    
    cell.textLabel.text = messageObj.body ;
    
    return cell ;
}

#pragma mark 发送聊天数据
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //发送聊天数据
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:textField.text];
    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
    
    //发送完成后情况文本输入框
    textField.text = nil;
    
    return YES ;
}

#pragma mark -键盘的通知
#pragma mark 键盘将显示
-(void)kbWillShow:(NSNotification *)noti
{
    // 显示的时候改变bottomContraint
    // 获取键盘高度
    WCLog(@"%@",noti.userInfo);
    CGFloat kbHeight = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

    self.bottomConstraint.constant = kbHeight;
    
    //表格滚动到底部
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_resultController.fetchedObjects.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark 键盘将隐藏
-(void)kbWillHide:(NSNotification *)noti
{
    self.bottomConstraint.constant = 0;
}

#pragma mark 表格滚动，隐藏键盘
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
