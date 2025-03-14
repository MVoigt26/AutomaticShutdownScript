function Invoke-Shutdown {
    param (
        $config
    )

    $timeNow = Get-Date
    $friday = 4
    $saturdayOrSunday = if ($config.schedule_shutdown_on_sundays) { 6 } else { 5 }

    if ($timeNow.DayOfWeek -ge $friday -or $timeNow.DayOfWeek -le $saturdayOrSunday) {
        # return # Skip weekends
    }

    $timeOfShutdown_s = $config.time_of_shutdown
    Write-Output "Read string from file '$timeOfShutdown_s'"

    $timeOfShutdown = [datetime]::ParseExact($config.time_of_shutdown, "HH:mm", $null)
    $deltaHour = $timeOfShutdown.Hour - $timeNow.Hour
    $deltaMinute = $timeOfShutdown.Minute - $timeNow.Minute

    $secondsToShutdown = $deltaHour * 3600 + $deltaMinute * 60

    if ($secondsToShutdown -lt 0) {
        $deltaHour = 24 + $deltaHour
        $deltaMinute = 60 + $deltaMinute
        $secondsToShutdown = $deltaHour * 3600 + $deltaMinute * 60

    }

    Write-Output "Scheduling shutdown in $deltaHour hours and $deltaMinute minutes"
    Read-Host -Prompt "Press Enter to continue"
    # shutdown.exe /s /t $secondsToShutdown
}

function Setup {
    Write-Output "Enter desired time to shutdown (HH:MM)"
    $sTimeOfShutdown = Read-Host -Prompt " "

    if ($sTimeOfShutdown -match "^\d{2}$") {
        $sTimeOfShutdown += ":00"
    }
    if (-not ($sTimeOfShutdown -match "^\d{2}:\d{2}$")) {
        Write-Output "Invalid time format. Please use (HH:MM)"
        return
    }

    Write-Output "Shutdown time set to $sTimeOfShutdown`n"

    Write-Output "Schedule shutdown on Sundays? (y/n)"
    $sScheduleShutdownOnSundays = (Read-Host -Prompt " ").ToLower()

    $config = @{
        "time_of_shutdown" = $sTimeOfShutdown
        "schedule_shutdown_on_sundays" = ($sScheduleShutdownOnSundays -eq "y")
    }

    $config | ConvertTo-Json | Out-File -FilePath "shutdown_config.json"

    $script = "@echo off`npowershell.exe $PWD\main.ps1 $PWD\shutdown_config.json"
    $script | Out-File -FilePath "shutdownScheduler.bat" -NoNewline -Encoding ascii

    Write-Output "Created 'shutdownScheduler.bat and 'shutdown_config.json`n"
    Write-Output "Move this file to your startup folder now? (y/n)"
    if ((Read-Host -Prompt " ").ToLower() -eq "y") {
        Move-Item -Path "shutdownScheduler.bat" -Destination "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    }

    Write-Output "`nEdit anytime by running setup again, or editing shutdown_config.json."
    Read-Host -Prompt "Press Enter to exit"
}

function Main {
    if ($args.Length -lt 1) {
        Write-Output "Usage: powershell.exe -File main.ps1 setup"
        return
    }

    if ($args[0] -eq "setup") {
        if (-not (Test-Path -Path "shutdown_config.json")) {
            Setup
        } else {
            Write-Output "Config already exists. Overwrite? (y/n)"
            if ((Read-Host -Prompt " ").ToLower() -eq "y") {
                Setup
            }
        }
    } elseif (-not (Test-Path -Path $args[0])) {
        Write-Output "Config file does not exist. Run setup first."
        return
    } else {
        $config = Get-Content -Path $args[0] | ConvertFrom-Json
        Invoke-Shutdown -config $config
    }
}

# Write-Output $args
Main $args
