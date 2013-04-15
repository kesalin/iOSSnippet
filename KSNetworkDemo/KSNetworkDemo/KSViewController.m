//
//  KSViewController.m
//  KSNetworkDemo
//
//  Created by kesalin on 13/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSViewController.h"
#import "KSSocketViewController.h"

@interface KSViewController ()
{
    NSDictionary * _items;
}
@end

@implementation KSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _items = @{
               @"BSD Socket Demo": @"KSSocketViewController",
               @"CFNetwork Demo": @"KSCFNetworkViewController",
               @"NSStream Demo" : @"KSNSStreamViewController"
               };
	
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id) keyInDictionary:(NSDictionary *)dict atIndex:(NSInteger)index
{
    NSArray * keys = [dict allKeys];
    if (index >= [keys count]) {
        NSLog(@" >> Error: index out of bounds. %s", __FUNCTION__);
        return nil;
    }
    
    return keys[index];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"NetworkCellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString * key = [self keyInDictionary:_items atIndex:indexPath.row];
    cell.textLabel.text = key;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [self keyInDictionary:_items atIndex:indexPath.row];
    NSString * controllerName = [_items objectForKey:key];
    
    Class controllerClass = NSClassFromString(controllerName);
    if (controllerClass != nil) {
        id controller = [[controllerClass alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
