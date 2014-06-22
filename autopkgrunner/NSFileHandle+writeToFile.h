//
//  NSFileManager+writeToFile.h
//  OSX Server Backup
//
//  Created by Eldon on 4/23/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileHandle (writeToFile)
- (void)writeFormatString:(NSString*)fmt, ...;
- (void)writeString:(NSString*)fmt;

@end
