//
//  KSViewController.m
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSViewController.h"
#import "KSLog.h"
#import "KSErrorHandler.h"

@interface KSViewController ()
{
    NSDictionary * _testItems;
}

- (id)testKeyAtIndex:(NSInteger) index;

- (void)testError;
- (void)testFatalError;
@end

@implementation KSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    KSLog(@" >> Root view did load.");
    KSTrace(@" >> Root view did load.");
    
    _testItems = @{
                   @"Common error":@"testError",
                   @"Fatal error":@"testFatalError",
                   @"Exception":@"testException"
                   };
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)testKeyAtIndex:(NSInteger) index
{
    NSEnumerator * enumerator = [_testItems keyEnumerator];
    id key = nil;
    NSInteger i = 0;
    while (i <= index) {
        key = [enumerator nextObject];
        i++;
        
        if (key == nil)
            break;
    }
    return key;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_testItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"KSUtilitiesDemoCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    cell.textLabel.text = [self testKeyAtIndex:row];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString * key = [self testKeyAtIndex:row];
    
    NSString * selectorName = [_testItems valueForKey:key];
    SEL sel = NSSelectorFromString(selectorName);
    if (sel != nil) {
        [self performSelector:sel];
    }
}

- (void)testError
{
    NSString * description = @"Common Error";
    NSString * failureReason = @"Can't seem to connect to network.";
    NSArray * recoveryOptions = @[@"Retry"];
    NSString * recoverySuggestion = @"Check your wifi or 3G settings and retry.";
    
    NSDictionary * userInfo =
    [NSDictionary dictionaryWithObjects:@[description, failureReason, recoveryOptions, recoverySuggestion, self]
                                forKeys: @[NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey, NSLocalizedRecoveryOptionsErrorKey, NSLocalizedRecoverySuggestionErrorKey, NSRecoveryAttempterErrorKey]];
    
    NSError *error = [[NSError alloc] initWithDomain:@"com.kesalin.KSUtilitiesDemo"
                                                code:10 userInfo:userInfo];
    
    [KSErrorHandler handleError:error isFatal:NO];
}

- (void)testFatalError
{
    NSString *description = @"Fatal Error";
    NSString *failureReason = @"Data is corrupt. The app must shut down.";
    NSString *recoverySuggestion = @"Contact support!";
    
    NSDictionary *userInfo = @{
                               description: NSLocalizedDescriptionKey,
                               failureReason: NSLocalizedFailureReasonErrorKey,
                               recoverySuggestion: NSLocalizedRecoverySuggestionErrorKey
                               };
    
    NSError *error = [[NSError alloc] initWithDomain:@"com.kesalin.KSUtilitiesDemo"
                                                code:11 userInfo:userInfo];
    
    [KSErrorHandler handleError:error isFatal:YES];
}

- (void)testException
{
    NSException * e = [[NSException alloc] initWithName:@"FakeException"
                                                 reason:@"The developer sucks!"
                                               userInfo:[NSDictionary dictionaryWithObject:@"Extra info" forKey:@"Key"]];
    [e raise];
}

@end
