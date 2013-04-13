//
//  KSNetworkDelegate.h
//  KSNetworkDemo
//
//  Created by kesalin on 13/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KSNetworkDelegate <NSObject>

- (void)networkingResultsDidStart;
- (void)networkingResultsDidLoad:(NSData *)results;
- (void)networkingResultsDidFail:(NSString *)errorMessage;

@end
