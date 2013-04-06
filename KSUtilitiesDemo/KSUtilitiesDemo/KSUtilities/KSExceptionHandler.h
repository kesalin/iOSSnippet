//
//  KSExceptionHandler.h
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface KSExceptionHandler : NSObject<UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) UIViewController * parentViewController;

+ (id)sharedInstance;
- (void)setOrCheckExceptionHandler;

@end
