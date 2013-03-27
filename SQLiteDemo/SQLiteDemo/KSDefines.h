//
//  KSDefines.h
//  SQLiteDemo
//
//  Created by kesalin on 3/27/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#ifndef SQLiteDemo_KSDefines_h
#define SQLiteDemo_KSDefines_h

#ifdef DEBUG
#define DLOG(format, ...)   NSLog(format", file:%s, line:%d, function:%s.", ##__VA_ARGS__, __FILE__, __LINE__, __FUNCTION__)
#define TRACE(format, ...)  NSLog(@"--- %s "format"---", __FUNCTION__, ##__VA_ARGS__)
#else
#define DLOG(format, ...)
#define TRACE(format, ...)
#endif

#define KSDocumentPath()                [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#endif
