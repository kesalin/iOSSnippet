//
//  KSNSStreamViewController.h
//  KSNetworkDemo
//
//  Created by kesalin on 15/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSNSStreamViewController : UIViewController <UITextFieldDelegate,NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *serverAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverPortTextField;
@property (weak, nonatomic) IBOutlet UITextView *receiveTextView;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *networkActivityView;

- (IBAction)connectButtonClick:(id)sender;

@end
