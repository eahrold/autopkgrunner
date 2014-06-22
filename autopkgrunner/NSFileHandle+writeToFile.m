//
//  NSFileManager+writeToFile.m
//  OSX Server Backup
//
//  Created by Eldon on 4/23/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import "NSFileHandle+writeToFile.h"

@implementation NSFileHandle (writeToFile)

- (void)writeFormatString:(NSString*)format, ...
{
    if (format) {
        va_list args;
        va_start(args, format);
        NSString* str = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        [self writeString:str];
    }
}

- (void)writeString:(NSString*)string
{
    [self seekToEndOfFile];
    [self writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
