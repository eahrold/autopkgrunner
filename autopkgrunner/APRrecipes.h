//
//  APRrecipes.h
//  autopkgrunner
//
//  Created by Eldon on 6/17/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* kRunRecipes = @"RUN_RECIPES";
static NSString* kRecipe = @"RECIPE";
static NSString* kRecipeKeys = @"RECIPE_KEYS";
static NSString* kRepoUpdate = @"REPO_UPDATE";

static NSString* AppPreferenceDomain = @"com.github.autopkgrunner";

@interface APRrecipes : NSObject
+ (BOOL)addRecipeToSchedule:(NSString*)recipe keys:(NSArray*)keys error:(NSError**)error;
+ (BOOL)removeRecipeFromSchedule:(NSString*)recipe error:(NSError**)error;
+ (NSArray*)scheduledRecipes;
@end
