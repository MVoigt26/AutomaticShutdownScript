@echo off
@REM This file written by copilot and verified by skovborg
@REM Cancel the shutdown
shutdown -a
@REM Ask for the time to snooze
set /p snoozeTime="How long do you want to snooze for? (in minutes): "
@REM Calculate the time to wake up
set /a snoozeTime=snoozeTime*60
@REM Snooze the shutdown
shutdown -s -t %snoozeTime%
