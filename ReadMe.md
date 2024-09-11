# Automatic Shutdown Timer

## Contents

This repo contains 4 files
- ReadMe.md
- shutdownAbort.bat
- shutdownGetter.bat
- shutdownTimerStart.ps1

## Setup
	
1. Edit **shutdownTimerStart.ps1**
1. Change the time for variable **$end** in line 2 to the time you want your computer to turn off.
1. Save changes.
1. Edit **shutdownGetter.bat** to refrence the folder you cloned these files to.
1. Go to *%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup*
1. Make a shortcut refrencing **shutdownGetter.bat**

### Abort setup

1. Right click on **shutdownAbort.bat** 
1. Expand *Send to* and click *Desktop (create shortcut)*
1. Go to desktop.
1. Right click on the shortcut.
1. Click *Properties*
1. Add *Shortcut key* (I chose **CTRL + SHIFT + ALT + NUM -**, far from eachother and hard to do by accident)
1. Click *Apply* and *OK* 
