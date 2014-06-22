##  AutoPKG Run Scheduler

autopkgrunner is intended to be a quick and easy way to schedule [autopkg][autopkgio] recipe runs.  It is not as robust as jenkins and if you have the need for some of the more advanced features of autopkg you should probably use that instead.  But if you simply want to schedule a collection of autopkg recipes on a daily/weekly basis this is for you...  


```
Usage: /usr/local/sbin/autopkgrunner [options]:

Options:
  -i, --install           move autopkgrunner to /usr/local/sbin/

  -x, --run               run all of the scheduled recipes
  -l, --list              list currently scheduled recipes
  
  -a, --add=RECIPE        add a recipe to the run schedule.  This can be
                          specified multiple times, but any --key passed 
                          will apply  to all the added recipes.
                          
  -k, --key=AUTOPKG_KEY   used when adding a recipe.  
                          Same as any override key you would pass to autopkg
                          
  -r, --remove=RECIPE     remove a recipe from the run schedule,
                          can be specified multiple times.
                          
  -u, --user=USERNAME     set the schedule to run as a specific user
  -d, --schedule-daily    schedule autopkgrunner to run daily at 7:00AM
  -w, --schedule-weekly   schedule autopkgrunner to run weekly
                          on Mondays at 7:00AM
                          
  -c, --clear-schedule    stop running scheduled
  -v, --version 
  -h, --usage

```

####Notes:
  AutoPKG must be properly configured in it's own right for autopkgrunner to work.
  If you intend to run as a specific user, such as a "munki" user, you must set both a home directory and a shell .  To configure autopkgrunner for a particular user,  you should probably login to the console as that user and execulte the
  /usr/local/sbin/autopkgrunner --add=/--remove=RECIPE options.

  If the user running autopkg does not have sudo capabilities, you must run the
  /usr/local/sbin/autopkgrunner --schedule-daily/weekly command with a user who does
  and include the --user=USERNAME option

  Schedule is controlled by launchd and a file named com.github.autopkgrunner.schedule.plist
  and is installed into /Library/LaunchDaemons.  You can customize the start times by creating
  the file using autopkgrunner, then manually editing the StartCalendarInterval key


#####Thanks to all of the contributors of [autopkg][autopkgcontrib] for their work on such an excelent project, without wwhich there would be no need for this.

[autopkg]: https://github.com/autopkg/autopkg "Autpkg" 
[autopkgio]: http://autopkg.github.io/autopkg/ "AutoPKG IO"
[autopkgcontrib]:https://github.com/autopkg/autopkg/graphs/contributors