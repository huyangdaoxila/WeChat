//
//  WCEditViewController.h
//  WeChat
//
//  Created by huyang on 15/7/29.
//  Copyright (c) 2015年 huyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WCEditViewController ;

@protocol WCEditViewControllerDelegate <NSObject>

- (void)editViewController:(WCEditViewController *)editVC didFinishedSave:(id)sender ;

@end


@interface WCEditViewController : UITableViewController

/**
 * 上一个控制器(个人信息控制器)传过来的cell
 */
@property(strong,nonatomic)UITableViewCell *cell ;

@property(weak  ,nonatomic)id<WCEditViewControllerDelegate>delegate ;

@end
