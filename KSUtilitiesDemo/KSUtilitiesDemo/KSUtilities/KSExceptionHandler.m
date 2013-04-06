//
//  KSExceptionHandler.m
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSExceptionHandler.h"
#import "KSLog.h"
#import "KSPathUtil.h"

@interface KSExceptionHandler()

@end

@implementation KSExceptionHandler

+ (id)sharedInstance
{
    static KSExceptionHandler * handler = nil;
    
    static dispatch_once_t runOnceToken;
    dispatch_once(&runOnceToken, ^{
        handler = [[self alloc] init];
    });
    
	return handler;
}

+ (void)setExceptionOccurredOnLastRunFlag:(BOOL)value
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:value forKey:@"ExceptionOccurredOnLastRun"];
    [settings synchronize];
}

void exceptionHandler(NSException *exception)
{
    KSLog(@"Uncaught exception: %@\nReason: %@\nUser Info: %@\nCall Stack: %@",
          exception.name, exception.reason, exception.userInfo, exception.callStackSymbols);
    
    //Set flag
    [KSExceptionHandler setExceptionOccurredOnLastRunFlag:YES];
}

- (void)setExceptionHandler
{
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    // Redirect stderr output stream to file
    //
    NSString * stderrPath = [[KSPathUtil documentDirectory] stringByAppendingPathComponent:@"stderr.log"];
    freopen([stderrPath cStringUsingEncoding:NSASCIIStringEncoding], "w", stderr);
}

- (void)setOrCheckExceptionHandler
{
#if TARGET_IPHONE_SIMULATOR
    return;
#endif

    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    if ([settings boolForKey:@"ExceptionOccurredOnLastRun"]) {
        // Reset exception occurred flag
        [KSExceptionHandler setExceptionOccurredOnLastRunFlag:NO];
        
        // Notify the user
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"We're sorry"
                                                         message:@"An error occurred on the previous run."
                                                        delegate:self
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil];
        if (self.parentViewController != nil) {
            [alert addButtonWithTitle:@"Email a Report"];
        }

        [alert show];
    }

    else {
        [self setExceptionHandler];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{   
    if (buttonIndex == 1 && self.parentViewController != nil)
    {
        // Attach log file
        NSString * stderrPath = [[KSPathUtil documentDirectory] stringByAppendingPathComponent:@"stderr.log"];
        NSData * data = [NSData dataWithContentsOfFile:stderrPath];
        
        // Set device information
        UIDevice * device = [UIDevice currentDevice];
        NSString * emailBody = [NSString stringWithFormat:@"My Model: %@\nMy OS: %@\nMy Version: %@",
                                [device model], [device systemName], [device systemVersion]];
        
        // Email a Report
        MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"Error Report"];
        [mailComposer setToRecipients:[NSArray arrayWithObject:@"kesalin@gmail.com"]];
        [mailComposer addAttachmentData:data mimeType:@"Text/XML" fileName:@"stderr.log"];
        [mailComposer setMessageBody:emailBody isHTML:NO];
    
        [self.parentViewController presentViewController:mailComposer animated:YES
                                                   completion:nil];
    }
    
    [self setExceptionHandler];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
