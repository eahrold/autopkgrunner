//
//  APRrecipes.m
//  autopkgrunner
//
//  Created by Eldon on 6/17/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import "APRrecipes.h"
#import "APRautopkg.h"
#import "APRError.h"
static NSString* AppPreferenceDomain = @"com.github.autopkgrunner";

@implementation APRrecipes

+ (NSArray*)scheduledRecipes
{
    return [[self class] recipes];
}

+ (BOOL)addRecipeToSchedule:(NSString*)recipe keys:(NSArray*)keys error:(NSError**)error
{
    if (![[APRautopkg avaliableRecipes] containsObject:recipe]) {
        return [APRError errorWithMessage:@"No matching recipe in the current autopkg repos" code:1 error:error];
    }
    [self removeRecipeFromSchedule:recipe error:nil];

    NSMutableArray* recipes = [[self class] recipes];
    NSMutableDictionary* recipeDict = [[NSMutableDictionary alloc] init];
    [recipeDict setObject:recipe forKey:kRecipe];
    if (keys) {
        [recipeDict setObject:keys forKey:kRecipeKeys];
    }

    [recipes addObject:recipeDict];
    return [[self class] setRecipes:recipes];
}

+ (BOOL)removeRecipeFromSchedule:(NSString*)recipe error:(NSError* __autoreleasing*)error
{
    NSMutableArray* recipes = [NSMutableArray arrayWithArray:[self recipes]];
    NSMutableArray* recipesToRemove = [NSMutableArray new];

    for (NSDictionary* dict in recipes) {
        if ([dict[kRecipe] isEqualToString:recipe]) {
            [recipesToRemove addObject:dict];
        }
    }
    if (recipes.count) {
        [recipes removeObjectsInArray:recipesToRemove];
        return [[self class] setRecipes:recipes];
    } else {
        return [APRError errorWithMessage:@"No matching recipe" code:1 error:error];
    }
}

+ (NSMutableArray*)recipes
{
    NSMutableArray* recipes;    
    NSString* preferencesPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/"];

    NSString* plist = [[preferencesPath stringByAppendingPathComponent:AppPreferenceDomain]
        stringByAppendingPathExtension:@"plist"];

    recipes = [NSMutableArray arrayWithArray:[NSDictionary dictionaryWithContentsOfFile:plist][kRunRecipes]];
    return recipes;
}

#pragma mark - Set Recipes...
+ (BOOL)setRecipes:(NSArray*)recipes
{
    return [self setUsingFileWrite:recipes];
}

+ (BOOL)setUsingDefaults:(NSArray*)recipes
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:recipes forKey:kRunRecipes];
    return [defaults synchronize];
}

+ (BOOL)setUsingFileWrite:(NSArray*)recipes
{
    NSMutableDictionary* dict = [NSMutableDictionary new];
    NSString* preferencesPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/"];
    NSFileManager* dm = [NSFileManager defaultManager];
    if (![dm fileExistsAtPath:preferencesPath]) {
        if (![dm createDirectoryAtPath:preferencesPath withIntermediateDirectories:YES attributes:nil error:nil])
            return NO;
    }

    NSString* plist = [[preferencesPath stringByAppendingPathComponent:AppPreferenceDomain]
        stringByAppendingPathExtension:@"plist"];

    [dict setObject:recipes forKey:kRunRecipes];
    return [dict writeToFile:plist atomically:YES];
}

@end
