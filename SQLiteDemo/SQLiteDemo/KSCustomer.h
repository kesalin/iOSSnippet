//
//  KSCustomer.h
//  SQLiteDemo
//
//  Created by kesalin on 3/28/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSCustomer : NSObject
{
    NSString * name;
    NSString * address;
    NSInteger age;
}

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, assign) NSInteger age;

- (id)initWith:(NSString *)aName address:(NSString *)aAddress age:(NSInteger)aAge;

@end
