//
//  KSViewController.h
//  KSNetworkDemo
//
//  Created by kesalin on 13/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end
