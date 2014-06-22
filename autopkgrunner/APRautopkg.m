//
//  APRAutopkg.m
//  autopkgrunner
//
//  Created by Eldon on 6/17/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import "APRautopkg.h"
#import "APRrecipes.h"
#import "APRError.h"
#import "NSFileHandle+writeToFile.h"

NSString* autopkg = @"/usr/local/bin/autopkg";

@implementation APRautopkg
+ (BOOL)runAutoPkgwithArgs:(NSArray*)args output:(NSPipe*)pipe error:(NSError* __autoreleasing*)error
{
    NSString* launchPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:autopkg])
        launchPath = autopkg;
    else {
        launchPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"AUTOPKG_INSTALL_PATH"];
    }

    if (launchPath) {
        NSTask* run = [NSTask new];
        run.launchPath = launchPath;
        run.arguments = args;
        if (pipe) {
            run.standardOutput = pipe;
            run.standardError = pipe;
        }

        [run launch];
        [run waitUntilExit];
        return [APRError errorFromTask:run error:error];
    }
    return NO;
}

+ (BOOL)runRecipe:(NSString*)recipe error:(NSError* __autoreleasing*)error
{
    return [self runRecipe:recipe withArgs:nil error:error];
}

+ (BOOL)runRecipe:(NSString*)recipe withArgs:(NSArray*)args error:(NSError* __autoreleasing*)error
{
    NSMutableArray* arguments = [NSMutableArray arrayWithArray:@[ @"run" ]];
    [arguments addObjectsFromArray:args];
    [arguments addObject:recipe];

    if ([recipe rangeOfString:@".munki"].location != NSNotFound) {
        [arguments addObject:@"MakeCatalogs.munki"];
    }
    return [[self class] runAutoPkgwithArgs:arguments output:nil error:error];
}

+ (NSArray*)avaliableRecipes
{
    NSPipe* results = [NSPipe pipe];
    NSArray* args = @[ @"list-recipes" ];
    if ([[self class] runAutoPkgwithArgs:args output:results error:nil]) {
        NSData* data = [[results fileHandleForReading] readDataToEndOfFile];
        NSString* str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        return [str componentsSeparatedByString:@"\n"];
    }
    return nil;
}

+(BOOL)repoUpdate{
    return [[self class]runAutoPkgwithArgs:@[@"repo-update", @"all"] output:nil error:nil];
}

@end
