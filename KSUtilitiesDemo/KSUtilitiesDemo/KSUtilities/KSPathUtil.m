//
//  KSPath.m
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSPathUtil.h"

@implementation KSPathUtil


+ (NSString *)homeDirectory
{
    return NSHomeDirectory();
}

+ (NSString *)temporaryDirectory
{
    return NSTemporaryDirectory();
}

+ (NSString *)documentDirectory
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * dir = [paths objectAtIndex:0];
    return dir;
}

+ (NSString *)cacheDirectory
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * dir = [paths objectAtIndex:0];
    return dir;
}

+ (NSString *)resourcePath
{
    return [[NSBundle mainBundle] resourcePath];
}

+ (NSString *)resourcePathForResource:(NSString *)name ofType:(NSString *)type
{
    return [[NSBundle mainBundle] pathForResource:name ofType:type];
}

+ (NSString *)resourcePathForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)dir
{
    return [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:dir];
}


@end
