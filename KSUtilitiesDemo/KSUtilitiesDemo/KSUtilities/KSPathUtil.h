//
//  KSPathUtil.h
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSPathUtil : NSObject

+ (NSString *)homeDirectory;
+ (NSString *)temporaryDirectory;
+ (NSString *)documentDirectory;
+ (NSString *)cacheDirectory;

+ (NSString *)resourcePath;
+ (NSString *)resourcePathForResource:(NSString *)name ofType:(NSString *)type;
+ (NSString *)resourcePathForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)dir;

@end
