//
//  KSViewController.m
//  SQLiteDemo
//
//  Created by kesalin on 3/28/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSViewController.h"
#import "/usr/include/sqlite3.h"
#import "KSDefines.h"
#import "KSCustomer.h"

@interface KSViewController ()
{
    sqlite3 * database;
}

- (void)openDatabase;
- (void)closeDatabase;
- (void)createTable;

- (BOOL)excuteSQL:(NSString *)sqlCmd;
- (BOOL)excuteSQLWithCString:(const char *)sqlCmd;
- (void)insertCustomer:(KSCustomer *)customer;
- (void)deleteCustomer:(KSCustomer *)customer;
- (void)updateCustomer:(KSCustomer *)oldValue newValue:(KSCustomer *)newValue;
- (NSArray *)queryAllCustomers;

@end

@implementation KSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self openDatabase];
    
    [self createTable];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self closeDatabase];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openDatabase
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
	NSString * dbPath = [KSDocumentPath() stringByAppendingPathComponent:@"testSQLite.db"];
    
    // delete db if exists.
    //
	BOOL success	= [fileManager fileExistsAtPath:dbPath];
    if (success) {
        NSError *error;
        [fileManager removeItemAtPath:dbPath error:&error];
    }
    
    // open database
    //
    int state = sqlite3_open([dbPath UTF8String], &database);
    if (state == SQLITE_OK) {
        DLOG(@" >> Succeed to open database. %@", dbPath);
    }
    else {
        DLOG(@" >> Failed to open database. %@", dbPath);
    }
}

- (void)closeDatabase
{
    if (database != NULL) {
        int state = sqlite3_close(database);
        if (state == SQLITE_OK) {
            DLOG(@" >> Succeed to close database.");
        }
        else {
            DLOG(@" >> Failed to open database.");
        }
        
        database = NULL;
    }
}

- (BOOL)excuteSQLWithCString:(const char *)sqlCmd
{
    char * errorMsg;
    int state = sqlite3_exec(database, sqlCmd, NULL, NULL, &errorMsg);
    if (state == SQLITE_OK) {
        DLOG(@" >> Succeed to %@",
             [NSString stringWithCString:sqlCmd encoding:NSUTF8StringEncoding]);
    }
    else {
        DLOG(@" >> Failed to %@. Error: %@",
             [NSString stringWithCString:sqlCmd encoding:NSUTF8StringEncoding],
             [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]);
        
        sqlite3_free(errorMsg);
    }
    
    return (state == SQLITE_OK);
}

- (BOOL)excuteSQL:(NSString *)sqlCmd
{
    char * errorMsg;
    const char * sql = [sqlCmd cStringUsingEncoding:NSUTF8StringEncoding];
    int state = sqlite3_exec(database, sql, NULL, NULL, &errorMsg);
    if (state == SQLITE_OK) {
        DLOG(@" >> Succeed to %@", sqlCmd);
    }
    else {
        DLOG(@" >> Failed to %@. Error: %@",
             sqlCmd,
             [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]);
        
        sqlite3_free(errorMsg);
    }
    
    return (state == SQLITE_OK);
}

- (void)createTable
{
    if (database == NULL) {
        DLOG(@" >> Database does not open yet.");
        return;
    }
    
    const char * sqlCmd = "create table if not exists customer (id integer primary key autoincrement, name text not null, address text, age integer)";
    
    [self excuteSQLWithCString:sqlCmd];
}

- (void)insertCustomer:(KSCustomer *)customer
{
    if (customer == NULL){
        DLOG(@" >> Error: invalid arguments.");
        return;
    }
    
    if (database == NULL) {
        DLOG(@" >> Database does not open yet.");
        return;
    }
    
    NSString * sqlCmd = [NSString stringWithFormat:@"insert into customer (name, address, age) values ('%@', '%@', %d)",
                           customer.name, customer.address, customer.age];
    //    NSString * sqlCmd = [NSString stringWithFormat:@"insert into customer values (null, 'Name', 'Address', 28)"];
    
    [self excuteSQL:sqlCmd];
}

- (void)deleteCustomer:(KSCustomer *)customer
{
    if (customer == NULL || customer.name == NULL){
        DLOG(@" >> Error: invalid arguments.");
        return;
    }
    
    if (database == NULL) {
        DLOG(@" >> Database does not open yet.");
        return;
    }
    
    NSString * sqlCmd = [NSString stringWithFormat:@"delete from customer where name='%@'",
                           customer.name];

    [self excuteSQL:sqlCmd];
}

- (void)updateCustomer:(KSCustomer *)oldValue newValue:(KSCustomer *)newValue
{
    if (oldValue == NULL || oldValue.name == NULL || newValue == NULL) {
        DLOG(@" >> Error: invalid arguments.");
        return;
    }
    
    if (database == NULL) {
        DLOG(@" >> Database does not open yet.");
        return;
    }
    
    NSString * sqlCmd = [NSString stringWithFormat:@"update customer set address='%@',age=%d where name='%@'",
                         newValue.address, newValue.age, oldValue.name];
    
    [self excuteSQL:sqlCmd];
}

- (NSArray *)queryAllCustomers
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    const char * sqlCmd = "select name, address, age from customer";
    sqlite3_stmt * statement;
    int state = sqlite3_prepare_v2(database, sqlCmd, -1, &statement, nil);
    if (state == SQLITE_OK) {
        DLOG(@" >> Succeed to prepare statement. %@",
             [NSString stringWithCString:sqlCmd encoding:NSUTF8StringEncoding]);
    }
    
    NSInteger index = 0;
    while (sqlite3_step(statement) == SQLITE_ROW) {
        // get raw data from statement
        //
        char * cstrName = (char *)sqlite3_column_text(statement, 0);
        char * cstrAddress = (char *)sqlite3_column_text(statement, 1);
        int age = sqlite3_column_int(statement, 2);
        
        NSString * name = [NSString stringWithCString:cstrName encoding:NSUTF8StringEncoding];
        NSString * address = [NSString stringWithCString:cstrAddress encoding:NSUTF8StringEncoding];
        KSCustomer * customer = [[KSCustomer alloc]
                                 initWith:name
                                 address:address
                                 age:age];
        [array addObject:customer];
        
        DLOG(@"   >> Record %d : %@ %@ %d", index++, name, address, age);
    }
    
    sqlite3_finalize(statement);
    
    DLOG(@" >> Query %d records.", [array count]);
    return array;
}

- (BOOL)beginTransaction
{
    return [self excuteSQLWithCString:"BEGIN EXCLUSIVE TRANSACTION;"];
}

- (BOOL)commit
{
    return [self excuteSQLWithCString:"COMMIT TRANSACTION;"];	
}

- (BOOL)rollback
{
    return [self excuteSQLWithCString:"ROLLBACK TRANSACTION;"];
}

- (IBAction)addButtonPressed:(id)sender
{
    NSString * name = @"飘飘白云";
    NSString * address = @"上海张江高科";
    NSInteger age = 28;
    
    KSCustomer * customer = [[KSCustomer alloc] initWith:name address:address age:age];
    
    [self insertCustomer:customer];
    
    [self queryAllCustomers];
}

- (IBAction)deleteButtonPressed:(id)sender
{
    NSString * name = @"飘飘白云";
    NSString * address = @"上海张江高科";
    NSInteger age = 28;
    
    KSCustomer * customer = [[KSCustomer alloc] initWith:name address:address age:age];
    
    [self deleteCustomer:customer];
    
    [self queryAllCustomers];
}

- (IBAction)updateButtonPressed:(id)sender
{
    NSString * name = @"飘飘白云";
    NSString * address = @"上海张江高科";
    NSString * newAddress = @"浦东新区张江高科";
    NSInteger age = 28;
    
    KSCustomer * customer = [[KSCustomer alloc] initWith:name address:address age:age];
    KSCustomer * newCustomer = [[KSCustomer alloc] initWith:name address:newAddress age:age];

    [self updateCustomer:customer newValue:newCustomer];
    
    [self queryAllCustomers];
}

@end
