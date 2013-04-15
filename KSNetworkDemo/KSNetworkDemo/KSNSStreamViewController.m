//
//  KSNSStreamViewController.m
//  KSNetworkDemo
//
//  Created by kesalin on 15/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "KSNSStreamViewController.h"
#import "NSStream+StreamsToHost.h"

#define kBufferSize 1024

// See http://www.telnet.org/htm/places.htm
//
#define kTestHost @"telnet://towel.blinkenlights.nl"
#define kTestPort 23

@interface KSNSStreamViewController ()
{
    NSMutableData * _receivedData;
}

@end

@implementation KSNSStreamViewController

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
    
    self.title = @"NSStream";
    
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
#pragma mark NSStream

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

- (void)loadDataFromServerWithURL:(NSURL *)url
{
    NSInputStream * readStream;
	[NSStream getStreamsToHostNamed:[url host]
                               port:[[url port] integerValue]
                        inputStream:&readStream
                       outputStream:NULL];
    
	[readStream setDelegate:self];
	[readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[readStream open];
	
	[[NSRunLoop currentRunLoop] run];
}

#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@" >> NSStreamDelegate in Thread %@", [NSThread currentThread]);
    
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable: {
			if (_receivedData == nil) {
                _receivedData = [[NSMutableData alloc] init];
            }
			
            uint8_t buf[kBufferSize];
            int numBytesRead = [(NSInputStream *)stream read:buf maxLength:1024];
			
            if (numBytesRead > 0) {
                [self didReceiveData:[NSData dataWithBytes:buf length:numBytesRead]];
				
            } else if (numBytesRead == 0) {
                NSLog(@" >> End of stream reached");
				
            } else {
				NSLog(@" >> Read error occurred");
			}
			
			break;
		}
			
		case NSStreamEventErrorOccurred: {
			NSError * error = [stream streamError];
			NSString * errorInfo = [NSString stringWithFormat:@"Failed while reading stream; error '%@' (code %d)", error.localizedDescription, error.code];
			
            [self cleanUpStream:stream];
            
            [self networkFailedWithErrorMessage:errorInfo];
		}
			
		case NSStreamEventEndEncountered: {
            
            [self cleanUpStream:stream];
            
            [self didFinishReceivingData];

			break;
		}
			
		default:
			break;
	}
}

- (void)cleanUpStream:(NSStream *)stream
{
	[stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[stream close];
	
	stream = nil;
}

@end
