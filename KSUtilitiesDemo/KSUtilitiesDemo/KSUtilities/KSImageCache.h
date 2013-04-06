//
//  KSImageCache.h
//  AmericanEnglish
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSImageCache : NSObject

+ (id)imageNamed:(NSString *)name;
+ (BOOL)setImage:(UIImage *)image forName:(NSString *)name;
+ (BOOL)setImagePath:(NSString *)filepath forName:(NSString *)name;
+ (void)removeImage:(NSString *)name;
+ (void)removeImages:(NSArray *)names;
+ (void)clear;

@end
