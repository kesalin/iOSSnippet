//
//  KSCFNetworkViewController.m
//  KSNetworkDemo
//
//  Created by kesalin on 13/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSCFNetworkViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>


#define kBufferSize 1024

// See http://www.telnet.org/htm/places.htm
//
#define kTestHost @"telnet://towel.blinkenlights.nl"
#define kTestPort 23

@interface KSCFNetworkViewController ()
{
    CFSocketRef	_socket;
	NSMutableData * _receivedData;
}

- (void)didReceiveData:(NSData *)data;
- (void)didFinishReceivingData;

@end

@implementation KSCFNetworkViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"CFNetwork";
    
    self.serverAddressTextField.delegate = self;
    self.serverPortTextField.delegate = self;
    
    self.serverAddressTextField.text = kTestHost;
    self.serverPortTextField.text = [[NSNumber numberWithInt:kTestPort] stringValue];
    self.receiveTextView.text = @"";
    self.receiveTextView.editable = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL didResign = [textField resignFirstResponder];
    return didResign;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"Dismiss"
                                           otherButtonTitles:nil];
    [alert show];
}

- (IBAction)connectButtonClick:(id)sender
{
    NSString * serverHost = self.serverAddressTextField.text;
    NSString * serverPort = self.serverPortTextField.text;
    
    if (serverHost == nil || [serverHost isEqualToString:@""]) {
        [self showAlertWithTitle:@"Error" message:@"Server address cann't be empty!"];
        return;
    }
    
    if (serverPort == nil || [serverPort isEqualToString:@""]) {
        [self showAlertWithTitle:@"Error" message:@"Server port cann't be empty!"];
        return;
    }
    
    self.connectButton.enabled = NO;
    self.receiveTextView.text = @"Connecting to server...";
    [self.networkActivityView startAnimating];
    
    NSLog(@" >> main thread %@", [NSThread currentThread]);
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", serverHost, serverPort]];
    NSThread * backgroundThread = [[NSThread alloc] initWithTarget:self
                                                          selector:@selector(loadDataFromServerWithURL:)
                                                            object:url];
	[backgroundThread start];
}

- (void)networkFailedWithErrorMessage:(NSString *)message
{
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@" >> %@", message);
        
        self.receiveTextView.text = message;
        self.connectButton.enabled = YES;
        [self.networkActivityView stopAnimating];
    }];
}

- (void)networkSucceedWithData:(NSData *)data
{
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString * resultsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@" >> Received string: '%@'", resultsString);
        
        self.receiveTextView.text = resultsString;
        self.connectButton.enabled = YES;
        [self.networkActivityView stopAnimating];
    }];
}

#pragma mark -
#pragma mark CFNetwork

- (void)didReceiveData:(NSData *)data {
	if (_receivedData == nil) {
		_receivedData = [[NSMutableData alloc] init];
	}
	
	[_receivedData appendData:data];
    
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString * resultsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.receiveTextView.text = resultsString;
    }];
}

- (void)didFinishReceivingData
{	
    [self networkSucceedWithData:_receivedData];
}

void socketCallback(CFReadStreamRef stream, CFStreamEventType event, void * myPtr)
{
    NSLog(@" >> socketCallback in Thread %@", [NSThread currentThread]);
    
    KSCFNetworkViewController * controller = (__bridge KSCFNetworkViewController *)myPtr;
	
	switch(event) {
        case kCFStreamEventHasBytesAvailable: {
			// Read bytes until there are no more
            //
            while (CFReadStreamHasBytesAvailable(stream)) {
				UInt8 buffer[kBufferSize];
				int numBytesRead = CFReadStreamRead(stream, buffer, kBufferSize);
				
				[controller didReceiveData:[NSData dataWithBytes:buffer length:numBytesRead]];
			}
			
            break;
        }
            
        case kCFStreamEventErrorOccurred: {
			CFErrorRef error = CFReadStreamCopyError(stream);
			if (error != NULL) {
				if (CFErrorGetCode(error) != 0) {
					NSString * errorInfo = [NSString stringWithFormat:@"Failed while reading stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error)];
                    
                    [controller networkFailedWithErrorMessage:errorInfo];
				}
				
				CFRelease(error);
			}
			
			
            break;
		}
			
        case kCFStreamEventEndEncountered:
            // Finnish receiveing data
            //
			[controller didFinishReceivingData];
			
			// Clean up
            //
			CFReadStreamClose(stream);
			CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
			CFRunLoopStop(CFRunLoopGetCurrent());
            
            break;
			
        default:
            break;
    }
}


- (void)loadDataFromServerWithURL:(NSURL *)url
{
    NSString * host = [url host];
    NSInteger port = [[url port] integerValue];
    
	// Keep a reference to self to use for controller callbacks
    //
	CFStreamClientContext ctx = {0, (__bridge void *)(self), NULL, NULL, NULL};
	
	// Get callbacks for stream data, stream end, and any errors
    //
	CFOptionFlags registeredEvents = (kCFStreamEventHasBytesAvailable | kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred);
	
	// Create a read-only socket
    //
	CFReadStreamRef readStream;
	CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)host, port, &readStream, NULL);
	
	// Schedule the stream on the run loop to enable callbacks
    //
	if (CFReadStreamSetClient(readStream, registeredEvents, socketCallback, &ctx)) {
		CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
		
	}
    else {
        [self networkFailedWithErrorMessage:@"Failed to assign callback method"];
		return;
	}
	
	// Open the stream for reading
    //
	if (CFReadStreamOpen(readStream) == NO) {
        [self networkFailedWithErrorMessage:@"Failed to open read stream"];
		
		return;
	}
	
	CFErrorRef error = CFReadStreamCopyError(readStream);
	if (error != NULL) {
		if (CFErrorGetCode(error) != 0) {
			NSString * errorInfo = [NSString stringWithFormat:@"Failed to connect stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error)];
            [self networkFailedWithErrorMessage:errorInfo];
		}
		
		CFRelease(error);
		
		return;
	}
	
	NSLog(@"Successfully connected to %@", url);
	
	// Start processing
    //
	CFRunLoopRun();
}

@end
