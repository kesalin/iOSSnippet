//
//  KSCustomer.m
//  SQLiteDemo
//
//  Created by kesalin on 3/28/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSCustomer.h"

@implementation KSCustomer

@synthesize name, address, age;

- (id)initWith:(NSString *)aName address:(NSString *)aAddress age:(NSInteger)aAge
{
    self = [super init];
    if (self) {
        name = aName;
        address = aAddress;
        age = aAge;
    }
    
    return self;
}

- (void)dealloc
{
    self.name = nil;
    self.address = nil;
}
    
@end
