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

@interface KSViewController ()
{
    sqlite3 * database;
}

- (void)openDatabase;
- (void)closeDatabase;
- (void)createTable;

- (void)insertCustomer:(NSString *)name address:(NSString *)address age:(NSInteger)age;

@end

@implementation KSViewController

@synthesize addButton;

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

- (void)createTable
{
    if (database == NULL) {
        DLOG(@" >> Database does not open yet.");
        return;
    }
    
    char * errorMsg;
    const char * sqlCmd = "create table if not exists customer (id integer primary key autoincrement, name text not null, address text, age integer)";
    int state = sqlite3_exec(database, sqlCmd, NULL, NULL, &errorMsg);
    if (state == SQLITE_OK) {
        DLOG(@" >> Succeed to create table. %@",
             [NSString stringWithCString:sqlCmd encoding:NSUTF8StringEncoding]);
    }
    else {
        DLOG(@" >> Failed to create table. %@. Error: %@",
             [NSString stringWithCString:sqlCmd encoding:NSUTF8StringEncoding],
             [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]);
        
        sqlite3_free(errorMsg);
    }
}

- (void)insertCustomer:(NSString *)name address:(NSString *)address age:(NSInteger)age
{
    if (database == NULL) {
        DLOG(@" >> Database does not open yet.");
        return;
    }
    
    NSString * nsSqlCmd = [NSString stringWithFormat:@"insert into customer (name, address, age) values ('%@', '%@', %d)",
                           name, address, age];
    //    NSString * nsSqlCmd = [NSString stringWithFormat:@"insert into customer values (null, '1', '2', 3)"];
    
    char * errorMsg;
    const char * sqlCmd = [nsSqlCmd cStringUsingEncoding:NSUTF8StringEncoding];
    int state = sqlite3_exec(database, sqlCmd, NULL, NULL, &errorMsg);
    if (state == SQLITE_OK) {
        DLOG(@" >> Succeed to insert record. %@", nsSqlCmd);
    }
    else {
        DLOG(@" >> Failed to insert record. %@. Error: %@",
             nsSqlCmd,
             [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]);
        
        sqlite3_free(errorMsg);
    }
}

- (IBAction)addButtonPressed:(id)sender
{
    NSString * name = @"飘飘白云";
    NSString * address = @"上海张江高科";
    NSInteger age = 28;
    
    [self insertCustomer:name address:address age:age];
}


@end
