//
//  KSViewController.m
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSViewController.h"
#import "KSLog.h"

@interface KSViewController ()

@end

@implementation KSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    KSLog(@" >> Root view did load.");
    KSTrace(@" >> Current fuction is ");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
