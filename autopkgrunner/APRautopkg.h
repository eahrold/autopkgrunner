//
//  APRAutopkg.h
//  autopkgrunner
//
//  Created by Eldon on 6/17/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface APRautopkg : NSObject
+ (BOOL)runRecipe:(NSString*)recipe error:(NSError**)error;
+ (BOOL)runRecipe:(NSString*)recipe withArgs:(NSArray*)args error:(NSError**)error;
+ (NSArray*)avaliableRecipes;
+ (BOOL)repoUpdate;
@end
