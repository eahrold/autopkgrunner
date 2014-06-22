//
//  APRError.m
//  autopkgrunner
//
//  Created by Eldon on 6/18/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import "APRError.h"
static NSString* const domain = @"com.github.autopkgrunner";
@implementation APRError
+ (BOOL)errorWithMessage:(NSString*)message code:(NSInteger)code error:(NSError* __autoreleasing*)error
{
    if (error && code != 0) {
        *error = [NSError errorWithDomain:domain code:code userInfo:@{ NSLocalizedDescriptionKey : message }];
    }
    return (code == 0);
}

+ (BOOL)errorFromTask:(NSTask*)task error:(NSError* __autoreleasing*)error
{
    if (error && task.terminationStatus != 0) {
        NSString* errorMsg = [NSString stringWithFormat:@"There was a problem executing %@", task.launchPath];
        *error = [NSError errorWithDomain:domain code:task.terminationStatus userInfo:@{ NSLocalizedDescriptionKey : errorMsg }];
    }
    return (task.terminationStatus == 0);
}
@end
