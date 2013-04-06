//
//  KSDefines.h
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#ifndef KSUtilitiesDemo_KSDefines_h
#define KSUtilitiesDemo_KSDefines_h

#define sizeOfArray(_a)                 sizeof((_a))/sizeof((_a[0]))

#define kIsIPad                         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kIsSimulator                    (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

#define kDeviceUUID                     [[UIDevice currentDevice] uniqueIdentifier]
#define kDeviceVersion                  [[[UIDevice currentDevice] systemVersion] floatValue]

#define kScreenBounds                   [UIScreen mainScreen] bounds]
#define kAppWidth                       [[UIScreen mainScreen] bounds].size.width
#define kAppHeight                      [[UIScreen mainScreen] bounds].size.height

#define kTabItemHeight                  44.0
#define kStatusHeight                   20.0

#define kUserNameRegex                  @"^[A-Za-z0-9_]{3,18}(@([a-zA-Z0-9_-])+(\\.[a-zA-Z0-9_-]+)){0,1}$"
#define kPasswordRegex                  @".{6,12}"
#define kPhoneNumberRegex               @"^(0|\\+86|86){0,1}(13[0-9]|15[0-9]|18[6-9])[0-9]{8}$"

#endif
