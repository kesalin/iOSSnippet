//
//  KSImageCache.m
//  AmericanEnglish
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSImageCache.h"
#import "KSLog.h"

@interface KSImageCache()
{
    NSMutableDictionary	* _imageDict;
    NSObject * _lockObject;
}

- (id)imageForKey:(NSString *)name;
- (BOOL)setImage:(UIImage *)image forKey:(NSString *)name;
- (BOOL)setImagePath:(NSString *)filepath forKey:(NSString *)name;
- (void)removeImageForKey:(NSString *)name;
- (void)removeImageForKeys:(NSArray *)names;
- (void)removeAll;

@end

@implementation KSImageCache

+ (id)sharedInstance
{
    static KSImageCache * imageCache = nil;
    
    static dispatch_once_t runOnceToken;
    dispatch_once(&runOnceToken, ^{
            imageCache = [[self alloc] init];
    });

	return imageCache;
}

- (id)copyWithZone:(NSZone *)paramZone{
    return self;
}

#pragma mark -
#pragma mark Static methods wrapper

+ (id)imageNamed:(NSString *)name
{
    return [[KSImageCache sharedInstance] imageForKey:name];
}

+ (BOOL)setImage:(UIImage *)image forName:(NSString *)name
{
    return [[KSImageCache sharedInstance] setImage:image forKey:name];
}

+ (BOOL)setImagePath:(NSString *)filepath forName:(NSString *)name
{
    return [[KSImageCache sharedInstance] setImagePath:filepath forKey:name];
}

+ (void)removeImage:(NSString *)name
{
    return [[KSImageCache sharedInstance] removeImageForKey:name];
}

+ (void)removeImages:(NSArray *)names
{
    return [[KSImageCache sharedInstance] removeImageForKeys:names];
}

+ (void)clear
{
    return [[KSImageCache sharedInstance] removeAll];
}

#pragma mark -
#pragma mark Image cache methods

- (id)init
{
    self = [super init];
	if (self) {
		_imageDict = [[NSMutableDictionary alloc] init];
        _lockObject = [[NSObject alloc] init];
	}

	return self;
}

- (id)imageForKey:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        KSLog(@" >> Error: Name is nil or empty.");
        return nil;
    }
    
    return [_imageDict objectForKey:name];
}

- (BOOL)setImage:(UIImage *)image forKey:(NSString *)name
{
    if (image == nil) {
        KSLog(@" >> Error: Image is nil");
        return NO;
    }
    
    if (name == nil || [name isEqualToString:@""]) {
        KSLog(@" >> Error: Name is nil or empty.");
        return NO;
    }
    
    @synchronized(_lockObject){
        [_imageDict setObject:image forKey:name];
    }
    
    return YES;
}

- (BOOL)setImagePath:(NSString *)filepath forKey:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        KSLog(@" >> Error: Name is nil or empty.");
        return NO;
    }
    
    if (filepath == nil || [filepath isEqualToString:@""]) {
        KSLog(@" >> Error: Filepath is nil or empty.");
        return NO;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        KSLog(@" >> Error: File does not exist at %@", filepath);
    }
    
    UIImage * image = [UIImage imageWithContentsOfFile:filepath];
    @synchronized(_lockObject){
        [_imageDict setObject:image forKey:name];
    }
    
    return YES;
}

- (void)removeImageForKey:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""]) {
        KSLog(@" >> Error: Name is nil or empty.");
        return;
    }
    
    @synchronized(_lockObject){
        [_imageDict removeObjectForKey:name];
    }
}

- (void)removeImageForKeys:(NSArray *)names
{
    if (names == nil) {
        KSLog(@" >> Error: Names is nil.");
        return;
    }
    
    @synchronized(_lockObject){
        [_imageDict removeObjectsForKeys:names];
    }
}

- (void)removeAll
{
    @synchronized(_lockObject){
        [_imageDict removeAllObjects];
    }
}

@end
