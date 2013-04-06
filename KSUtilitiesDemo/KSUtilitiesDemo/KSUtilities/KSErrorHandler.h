//
//  KSErrorHandler.h
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSErrorHandler : NSObject<UIAlertViewDelegate>

@property (nonatomic, strong) NSError * error;
@property (nonatomic, assign) BOOL isFatal;

- (id)initWithError:(NSError *)error isFatal:(BOOL)isFatal;

+ (void)handleError:(NSError *)error isFatal:(BOOL)isFatal;

@end
