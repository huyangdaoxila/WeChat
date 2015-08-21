//
//  WCProfileViewController.m
//  WeChat
//
//  Created by huyang on 15/7/29.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "WCEditViewController.h"

@interface WCProfileViewController ()<WCEditViewControllerDelegate,
                                      UIActionSheetDelegate,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView; //头像图片
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;     //昵称
@property (weak, nonatomic) IBOutlet UILabel *weChatNumLabel;    //微信号


@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;      //公司名
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;   //部门名称
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;        //职位名称
@property (weak, nonatomic) IBOutlet UILabel *telLabel;          //联系电话
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;        //邮箱

@end

@implementation WCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp ;
    
    //获取头像
    if(myvCard.photo){
        self.avatarImgView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    //昵称
    self.nicknameLabel.text = myvCard.nickname ;
    
    //微信号
    self.weChatNumLabel.text = [WCAccount shareAccount].loginUser ;
    
    //公司名
    self.orgNameLabel.text = myvCard.orgName ;
    
    //部门名称
    if (myvCard.orgUnits.count > 0) {
        self.departmentLabel.text = myvCard.orgUnits[0];
    }
    
    //职位名称
    self.titleLabel.text = myvCard.title ;
    
    //联系电话
    //self.telLabel.text = myvCard.telecomsAddresses[0];
    //因为telecomsAddresses没有解析,临时使用note
    self.telLabel.text = myvCard.note;
    
    //邮箱
    if (myvCard.emailAddresses.count > 0) {
        self.emailLabel.text = myvCard.emailAddresses[0];
    }else{
        self.emailLabel.text = @"暂无";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 选中表格

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //根据cell不同的tag进行相对应的操作
    /*
      tag = 0 换头像
      tag = 1 推出下一个控制器
      tag = 2 不做任何操作
     */
    
    //获取cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (cell.tag) {
        case 0:
        {
            WCLog(@"换头像");
            [self changeAvatarImage];
        }
            break;
        case 1:
        {
            WCLog(@"推出下一个控制器");
            [self performSegueWithIdentifier:@"toEditVcSegue" sender:cell];
        }
            break;
        case 2:{
            WCLog(@"不做任何操作");
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 更换头像
- (void)changeAvatarImage
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"图片库", nil];
    sheet.actionSheetStyle = UIActionSheetStyleDefault;
    [sheet showInView:self.view];
}
#pragma mark actionSheet 代理函数
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    WCLog(@"%ld",buttonIndex);
    
    //创建图片选择器
    UIImagePickerController *imgPC = [[UIImagePickerController alloc] init];
    
    //设置代理
    imgPC.delegate = self ;
    //允许编辑图片
    imgPC.allowsEditing = YES ;
    
    switch (buttonIndex) {
        case 0: // 拍照
        {
            imgPC.sourceType = UIImagePickerControllerSourceTypeCamera ;
        }
            break;
        case 1: // 图片库
        {
            imgPC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary ;
        }
            break;
        case 2: // 取消
        {}
            break;
            
        default:
            break;
    }
    
    //显示图片选择器
    [self presentViewController:imgPC animated:YES completion:nil];
}
#pragma mark 图片选择器代理函数
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    WCLog(@"%@",info);
    
    //获取编辑后的图片
    UIImage *editedImg = info[UIImagePickerControllerEditedImage];
    
    //更换头像
    self.avatarImgView.image = editedImg ;
    
    //推出图片编辑器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //保存修改后的头像数据
    [self editViewController:nil didFinishedSave:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //获取目标控制器
    id descVC = segue.destinationViewController ;
    
    //把cell传过去
    if ([descVC isKindOfClass:[WCEditViewController class]])
    {
        WCEditViewController *edit = descVC ;
        edit.cell = sender ;
        //设置代理
        edit.delegate = self;
    }
}
#pragma mark WCEditViewController 代理事件函数 保存修改的电子名片数据
- (void)editViewController:(WCEditViewController *)editVC didFinishedSave:(id)sender
{
    WCLog(@"delegate");
    
    // 获取当前电子名片
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp ;
    
    //重新设置myvCard的头像属性
    myvCard.photo = UIImageJPEGRepresentation(self.avatarImgView.image, 0.5) ;
    
    //重新设置myvCard的属性
    myvCard.nickname = self.nicknameLabel.text ;
    myvCard.orgName = self.orgNameLabel.text ;
    
    if (self.departmentLabel.text != nil) {
        myvCard.orgUnits = @[self.departmentLabel.text];
    }
    
    myvCard.title = self.titleLabel.text ;
    myvCard.note = self.telLabel.text ;
    
//    if (self.telLabel.text != nil) {
//        myvCard.telecomsAddresses = @[self.telLabel.text];
//    }
    
    if (self.emailLabel.text.length > 0) {
        myvCard.emailAddresses = @[self.emailLabel.text];
    }
    
    //把数据保存到服务器
    [[WCXMPPTool sharedWCXMPPTool].vCard updateMyvCardTemp:myvCard];
}

@end
