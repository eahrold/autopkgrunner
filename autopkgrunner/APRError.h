//
//  APRError.h
//  autopkgrunner
//
//  Created by Eldon on 6/18/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APRError : NSObject
+ (BOOL)errorWithMessage:(NSString*)message code:(NSInteger)code error:(NSError* __autoreleasing*)error;
+ (BOOL)errorFromTask:(NSTask*)task error:(NSError* __autoreleasing*)error;
@end
