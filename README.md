##  AutoPKG Run Scheduler

autopkgrunner is intended to be a quick and easy way to schedule [autopkg][autopkgio] recipe runs.  It is not as robust as [jenkins] and if you have the need for some of the more advanced features of autopkg you should probably use that instead.  But if you simply want to schedule a collection of autopkg recipes on a daily/weekly basis this is for you...  

To install download the [latest release file from here...](https://github.com/eahrold/autopkgrunner/releases),  
Unzip it, and, in terminal, cd to the downloaded directory and run

	sudo ./autopkgrunner --install
	
which will move the executable to the /usr/local/sbin/ folder.
Now you can start adding recipes to the run schedule

	/usr/local/sbin/autopkgrunner --add=FireFox.munki	
	/usr/local/sbin/autopkgrunner --add=GoogleChrome.munki --key=MUNKI_REPO_SUBDIR=apps/Google/

once you have your recipes list added, check it like this

	/usr/local/sbin/autopkgrunner --list
	
and then do a test run 

	/usr/local/sbin/autopkgrunner --run

if everything looks good, then set the schedule to run every day at 7:00AM

	sudo /usr/local/sbin/autopkgrunner --schedule-daily 

Notice you need to run the schedule option with sudo.  If you plan on running
autopkgrunner as a user that is not an admin user, you will need to append the user flag
to the command.

	sudo /usr/local/sbin/autopkgrunner --schedule-daily --user=munki
	
If doing this make sure the "munki" user has both home directory set and shell. 
You should actually login to the terminal as the "munki" user and perform all of
the --add commands and do a --run to make sure things are working as expected.
then log in to your admin and do the --schedule... command.

Schedule is controlled by launchd and a file named com.github.autopkgrunner.schedule.plist and is installed into /Library/LaunchDaemons.  You can customize the start times by creating the file using autopkgrunner, then manually editing the StartCalendarInterval key

By default autopkgrunner updates all recipe repos, you can toggle this feature by running

	sudo /usr/local/sbin/autopkgrunner --update-repo
    

###Full Usage:
```
Usage: /usr/local/sbin/autopkgrunner [options]

Options:
  -i, --install           install autopkgrunner to /usr/local/sbin/
  -x, --run               run all of the scheduled recipes
  -l, --list              list currently scheduled recipes
  -a, --add=RECIPE        add a recipe to the run schedule, 
                          can be specified more than once
                          
  -k, --key=AUTOPKG_KEY   used when adding a recipe. Same as any 
                          override key you would pass to autopkg
                          
  -r, --remove=RECIPE     remove a recipe from the run schedule,
                          can be specified more than once
                          
  -u, --user=USERNAME     set the schedule to run as a specific user
  
  -g, --update-repo       toggle on/off automatically updating 
                          autopkg recipe repos
                          
  -c, --clear-schedule    stop running at scheduled intervals

  -d, --schedule-daily    schedule autopkgrunner to run daily at 7:00AM
  -w, --schedule-weekly   schedule autopkgrunner to run weekly on
                          Mondays at 7:00AM
                          
  -v, --version 
  -h, --usage

```


  

#####Thanks to all of the contributors of [autopkg][autopkgcontrib] for their work on such an excelent project, without which there would be no need for this.

[autopkg]: https://github.com/autopkg/autopkg "Autpkg" 
[autopkgio]: http://autopkg.github.io/autopkg/ "AutoPKG IO"
[autopkgcontrib]:https://github.com/autopkg/autopkg/graphs/contributors
[jenkins]:http://jenkins-ci.org "Jenkins CI"