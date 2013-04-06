//
//  KSErrorHandler.m
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSErrorHandler.h"
#import "KSLog.h"

@implementation KSErrorHandler

static NSMutableArray * retainedDelegates = nil;

- (id)initWithError:(NSError *)error isFatal:(BOOL)isFatalError
{
    self = [super init];
    if (self) {
        self.error = error;
        self.isFatal = isFatalError;
    }

    return self;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSString * buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        NSInteger recoveryIndex = [[self.error localizedRecoveryOptions] indexOfObject:buttonTitle];
        if (recoveryIndex != NSNotFound)
        {
            if ([[self.error recoveryAttempter] attemptRecoveryFromError:self.error
                                                             optionIndex:recoveryIndex] == NO)
            {
                // Redisplay alert since recovery attempt failed
                [KSErrorHandler handleError:self.error isFatal:self.isFatal];
            }
        }
    }
    else
    {
        // Cancel button clicked
        //
        if (self.isFatal)
        {
            // In case of a fatal error, abort execution
            abort();
            // exit(0);
        }
    }
    
    // Job is finished, release this delegate
    [retainedDelegates removeObject:self];
}

+ (void)handleError:(NSError *)error isFatal:(BOOL)isFatal
{
    NSString *localizedCancelTitle = NSLocalizedString(@"Dismiss", nil);
    if (isFatal)
        localizedCancelTitle = NSLocalizedString(@"Shut Down", nil);
    
    // Notify the user
    KSErrorHandler *delegate = [[KSErrorHandler alloc] initWithError:error isFatal:isFatal];
    if (!retainedDelegates) {
        retainedDelegates = [[NSMutableArray alloc] init];
    }
    [retainedDelegates addObject:delegate];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                     message:[error localizedFailureReason]
                                                    delegate:delegate
                                           cancelButtonTitle:localizedCancelTitle
                                           otherButtonTitles:nil];
    
    if ([error recoveryAttempter])
    {
        // Append the recovery suggestion to the error message
        alert.message = [NSString stringWithFormat:@"%@\n%@", alert.message, error.localizedRecoverySuggestion];
        // Add buttons for the recovery options
        for (NSString * option in error.localizedRecoveryOptions)
        {
            [alert addButtonWithTitle:option];
        }
    }
    
    
    [alert show];

    // Log to standard out
    KSLog(@"Unhandled error:\n%@, %@", error, [error userInfo]);
}


@end
