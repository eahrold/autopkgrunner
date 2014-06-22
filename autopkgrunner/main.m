//
//  main.m
//  autopkgrunner
//
//  Created by Eldon on 6/17/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <getopt.h>

#import "APRrecipes.h"
#import "APRautopkg.h"

#import "AHLaunchCtl.h"

const char* current_version = "0.1.0";
static NSString* label = @"com.github.autopkgrunner.schedule";

OSStatus run()
{
    if (getuid() == 0) {
        printf("This should not be run as root it will cause permission problems!\nExiting...\n");
        return 127;
    }

    NSError* error;
    BOOL runError = NO;
    NSArray* recipes = [APRrecipes scheduledRecipes];
    for (NSDictionary* recipe in recipes) {
        NSMutableString* cmd = [NSMutableString stringWithFormat:@"autopkg run %@", recipe[kRecipe]];
        for (NSString* key in recipe[kRecipeKeys]) {
            [cmd appendFormat:@" --key=%@", key];
        }
        NSLog(@"%@", cmd);
        NSMutableArray* args = [NSMutableArray new];
        for (NSString* i in recipe[kRecipeKeys]) {
            [args addObject:[NSString stringWithFormat:@"--key=%@", i]];
        }
        if (![APRautopkg runRecipe:recipe[kRecipe] withArgs:args error:&error]) {
            NSLog(@"Error running %@ [code: %ld message: %@]", recipe, (long)error.code, error.localizedDescription);
            runError = YES;
        }
    }
    return runError ? (int)error.code : 0;
}


void schedule(AHLaunchJobSchedule* schedule, NSString* user)
{
    NSLog(@"Adding job");
    NSError* error;
    NSString* launchPath = [[NSProcessInfo processInfo] arguments][0];
    if (!user) {
        user = [[[NSProcessInfo processInfo] environment] objectForKey:@"SUDO_USER"];
    }

    AHLaunchJob* job = [AHLaunchJob new];
    job.Label = label;
    job.ProgramArguments = @[ launchPath, @"-x" ];
    job.StartCalendarInterval = schedule;
    job.StandardOutPath = [NSString stringWithFormat:@"%@/Library/Logs/autopkgrunner.log", NSHomeDirectoryForUser(user)];

    job.StandardErrorPath = job.StandardOutPath;
    job.RunAtLoad = YES;
    job.UserName = user;

    AHLaunchCtl* launchctl = [AHLaunchCtl new];
    if (![launchctl add:job toDomain:kAHGlobalLaunchDaemon error:&error]) {
        NSLog(@"%@", error.localizedDescription);
    }
}


void clear_schedule()
{
    NSError* error;
    if (![[AHLaunchCtl sharedControler] remove:label fromDomain:kAHGlobalLaunchDaemon error:&error]) {
        NSLog(@"%@", error.localizedDescription);
    }
}


void install_cli()
{
    NSError* error;
    NSString* installDir = @"/usr/local/sbin/";
    NSString* launchPath = [[NSProcessInfo processInfo] arguments][0];
    NSString* installPath = [installDir stringByAppendingPathComponent:[launchPath lastPathComponent]];

    if ([installPath isEqualToString:launchPath]) {
        printf("There is no need to install file over itself\n");
        exit(0);
    }
    NSFileManager* fm = [NSFileManager new];
    if (![fm fileExistsAtPath:installDir]) {
        [fm createDirectoryAtPath:installDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (!error) {
        if ([fm fileExistsAtPath:installPath]) {
            [fm removeItemAtPath:installPath error:&error];
        }
        if (!error) {
            [fm moveItemAtPath:launchPath toPath:installPath error:&error];
        }
    }
    if (error) {
        printf("%s\n", error.localizedDescription.UTF8String);
        exit((int)error.code);
    } else {
        printf("Successfully installed autopkgrunner version %s\n", current_version);
    }
    exit(0);
}


void version()
{
    printf("%s\n", current_version);
    exit(0);
}


int usage(int rc)
{
    system("clear");
    NSString* execPath = [[NSProcessInfo processInfo] arguments][0];
    printf("##############################################\n");
    printf("##  AutoPKG Run Scheduler version %s     ##\n", current_version);
    printf("##############################################\n");
    printf("Usage: %s [options]\n\n", execPath.UTF8String);
    printf("Options:\n");
    printf("  -i, --install           install autopkgrunner to /usr/local/sbin/\n");
    printf("  -x, --run               run all of the scheduled recipes\n");
    printf("  -l, --list              list currently scheduled recipes\n");
    printf("  -a, --add=RECIPE        add a recipe to the run schedule, can be specified more than once\n");
    printf("  -k, --key=AUTOPKG_KEY   used when adding a recipe.  Same as any override key you would pass to autopkg\n");

    printf("  -r, --remove=RECIPE     remove a recipe from the run schedule,can be specified more than once\n");
    printf("  -u, --user=USERNAME     set the schedule to run as a specific user\n");
    printf("  -d, --schedule-daily    schedule autopkgrunner to run daily at 7:00AM\n");
    printf("  -w, --schedule-weekly   schedule autopkgrunner to run weekly on Mondays at 7:00AM\n");
    printf("  -c, --clear-schedule    stop running at scheduled intervals\n");
    printf("  -v, --version \n");
    printf("  -h, --usage\n");
    printf("\n");
    printf("Notes:\n");
    printf("  AutoPKG must be properly configured in it's own right for autopkgrunner to work.\n");
    printf("  If you intend to run as a specific user, such as a \"munki\" user, that user must \n");
    printf("  have a home directory and a shell.  To configure autopkgrunner for a particular user,\n");
    printf("  you must login to the console as that user and execulte the\n");
    printf("  %s --add=/--remove=RECIPE options.\n\n", execPath.UTF8String);
    printf("  If the user running autopkg does not have sudo capabilities, you must run the\n");
    printf("  %s --schedule-daily/weekly command with a user who does\n", execPath.UTF8String);
    printf("  and include the --user=USERNAME option\n");
    printf("\n");
    printf("  Schedule is controlled by launchd and a file named com.github.autopkgrunner.schedule.plist\n");
    printf("  and is installed into /Library/LaunchDaemons.  You can customize the start times by creating\n");
    printf("  the file using autopkgrunner, then manually editing the StartCalendarInterval key\n");

    return rc;
}

int main(int argc, char* argv[])
{

    @autoreleasepool
    {
        int c;
        
        BOOL
        run_daily = NO,
        run_weekly = NO,
        remove_schedule = NO,
        list_recipes = NO,
        add_recipe = NO,
        remove_recipe = NO,
        install = NO;

        NSError* error = nil;
        NSString* user = nil;

        NSMutableArray* addRecipes,
            *recipeKeys,
            *removeRecipes;

        struct option longopts[] = {
            { "run", no_argument, NULL, 'x' },
            { "list", no_argument, NULL, 'l' },
            { "add", required_argument, NULL, 'a' },
            { "key", required_argument, NULL, 'k' },
            { "remove", required_argument, NULL, 'r' },
            { "schedule-daily", no_argument, NULL, 'd' },
            { "schedule-weekly", no_argument, NULL, 'w' },
            { "clear-schedule", no_argument, NULL, 'c' },
            { "user", required_argument, NULL, 'u' },
            { "version", no_argument, NULL, 'v' },
            { "install", no_argument, NULL, 'i' },
            { "usage", no_argument, NULL, 'h' },
            { "help", no_argument, NULL, 'h' },
            { NULL, 0, 0, 0 } // NULL row to catch anything unknown.
        };

        while ((c = getopt_long(argc, argv, "?hvxliu:a:r:", longopts, NULL)) != -1) {
            switch (c) {
            case 'x':
                return run();
            case 'u':
                user = [NSString stringWithUTF8String:optarg];
                break;
            case 'a':
                if (!addRecipes) {
                    addRecipes = [NSMutableArray new];
                }
                [addRecipes addObject:[NSString stringWithUTF8String:optarg]];
                add_recipe = YES;
                break;
            case 'k':
                if (!recipeKeys) {
                    recipeKeys = [NSMutableArray new];
                }
                [recipeKeys addObject:[NSString stringWithUTF8String:optarg]];
                break;
            case 'r':
                if (!removeRecipes) {
                    removeRecipes = [NSMutableArray new];
                }
                [removeRecipes addObject:[NSString stringWithUTF8String:optarg]];
                remove_recipe = YES;
                break;
            case 'l':
                list_recipes = YES;
                break;
            case 'd':
                run_daily = YES;
                break;
            case 'w':
                run_weekly = YES;
                break;
            case 'c':
                remove_schedule = YES;
                break;
            case 'i':
                install = YES;
                break;
            case '?':
            case 'h':
                return usage(1);
            case 'v':
                version();
                return 0;
            }
        }

        if (list_recipes) {
            for (NSDictionary* recipe in [APRrecipes scheduledRecipes]) {
                printf("  * %s\n", [[NSString stringWithFormat:@"%@", recipe[kRecipe]] UTF8String]);
                for (NSString* key in recipe[kRecipeKeys]) {
                    printf("      %s\n", [[NSString stringWithFormat:@"%@", key] UTF8String]);
                }
            }
            return 0;
        }

        if (add_recipe) {
            for (NSString* recipe in addRecipes) {
                if (![APRrecipes addRecipeToSchedule:recipe keys:recipeKeys error:&error]) {
                    printf("Recipe Add Error: %s\n", error.localizedDescription.UTF8String);
                }
            }
            return 0;
        }

        if (remove_recipe) {
            for (NSString* recipe in removeRecipes) {
                if (![APRrecipes removeRecipeFromSchedule:recipe error:&error])
                    printf("Recipe Removal Error: %s\n", error.localizedDescription.UTF8String);
            }
            return 0;
        }

        // Anything past this must run as root...
        if (getuid() != 0) {
            printf("that command must be run by root user\n");
            return 1;
        }

        if (install) {
            install_cli();
            return 0;
        }

        if (remove_schedule) {
            clear_schedule();
        } else if (run_daily) {
            schedule([AHLaunchJobSchedule dailyRunAtHour:7 minute:00], user);
        } else if (run_weekly) {
            schedule([AHLaunchJobSchedule weeklyRunOnWeekday:1 hour:7], user);
        }

        return error ? (int)error.code : 0;
    }
    return 0;
}
