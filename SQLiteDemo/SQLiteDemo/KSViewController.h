//
//  KSViewController.h
//  SQLiteDemo
//
//  Created by kesalin on 3/28/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSViewController : UIViewController
{
    UIButton * addButton;
}

@property (nonatomic, retain) IBOutlet UIButton * addButton;

- (IBAction)addButtonPressed:(id)sender;

@end
