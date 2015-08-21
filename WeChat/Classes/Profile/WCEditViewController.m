//
//  WCEditViewController.m
//  WeChat
//
//  Created by huyang on 15/7/29.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import "WCEditViewController.h"

@interface WCEditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *editField;

@end

@implementation WCEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置标题
    self.title = self.cell.textLabel.text ;
    
    //设置输入框默认文本
    self.editField.text = self.cell.detailTextLabel.text ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 取消和保存

- (IBAction)saveItemClicked:(id)sender
{
    // 1.修改cell的detailTextLabel的值
    self.cell.detailTextLabel.text = self.editField.text ;
    
    // 解决第一次返回cell修改的值不显示问题
    [self.cell layoutSubviews];
    
    // 2.销毁当前控制器
    [self.navigationController popViewControllerAnimated:YES];
    
    // 3.通过代理保存修改的数据
    if(self.delegate && [self.delegate respondsToSelector:@selector(editViewController:didFinishedSave:)])
    {
        [self.delegate editViewController:self didFinishedSave:sender];
    }    
}

- (IBAction)cancelItemClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
