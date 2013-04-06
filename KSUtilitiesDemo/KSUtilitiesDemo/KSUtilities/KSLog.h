//
//  KSLog.h
//  KSUtilitiesDemo
//
//  Created by kesalin on 6/4/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#ifndef KSUtilitiesDemo_KSLog_h
#define KSUtilitiesDemo_KSLog_h


#ifdef DEBUG
#define KSLog(format, ...)      NSLog(format", file:%s, line:%d, function:%s.", ##__VA_ARGS__, __FILE__, __LINE__, __FUNCTION__)
#define KSTrace(format, ...)    NSLog(@"--- %s "format"---", __FUNCTION__, ##__VA_ARGS__)
#else
#define KSLog(format, ...)
#define KSTrace(format, ...)
#endif

/*
 #ifdef DEBUG_OBJC
 //开启下面的宏就把调试信息输出到文件，注释即输出到终端
 #define DEBUG_TO_FILE
 #define DEBUG_FILE "/tmp/debugmsg"
 #ifdef DEBUG_TO_FILE
 //调试信息的缓冲长度
 #define DEBUG_BUFFER_MAX 4096
 //将调试信息输出到文件中
 #define printDebugMsg(moduleName, format, ...) {\
 char buffer[DEBUG_BUFFER_MAX+1]={0};\
 snprintf( buffer, DEBUG_BUFFER_MAX \
 , "[%s] "format" File:%s, Line:%d\n", moduleName, ##__VA_ARGS__, __FILE__, __LINE__ );\
 FILE* fd = fopen(DEBUG_FILE, "a");\
 if ( fd != NULL ) {\
 fwrite( buffer, strlen(buffer), 1, fd );\
 fflush( fd );\
 fclose( fd );\
 }\
 }
 #else
 //将调试信息输出到终端
 #define printDebugMsg(moduleName, format, ...) \
 printf( "[%s] "format" File:%s, Line:%d\n", moduleName, ##__VA_ARGS__, __FILE__, __LINE__ );
 #endif //end for #ifdef DEBUG_TO_FILE
 #else
 //发行版本，什么也不做
 #define printDebugMsg(moduleName, format, ...)
 #endif
 */

#endif
