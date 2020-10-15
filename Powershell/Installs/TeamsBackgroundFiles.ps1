# Installs SIU Backgrounds for Teams Video Chat
# Copies all JPG and PNG files in the current directory to the teams background directory

If(!(Test-Path "C:\ProgramData\SIU\Logs")){
    If(!(Test-Path "C:\ProgramData\SIU")){
        New-Item -Path "C:\ProgramData" -Name "SIU" -ItemType "directory"
    }
    New-Item -Path "C:\ProgramData\SIU" -Name "Logs" -ItemType "directory"
}
$logfile = "C:\Programdata\SIU\logs\TeamsBackgroundFiles.log"
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd_HH.mm.ss"): $_"}

$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

#log add
"Script started for $user." | timestamp | Out-File $logfile -Append

$teamsfolder = "$env:APPDATA\Microsoft\Teams"
if(!(Test-Path "$teamsfolder\Backgrounds\Uploads")){
    if(!(Test-Path "$teamsfolder\Backgrounds")){
        if(!(Test-Path $teamsfolder)){
            if(!(Test-Path "$env:APPDATA\Microsoft")){
                "$env:APPDATA\Microsoft doesn't exist, creating." | timestamp | Out-File $logfile -Append
                New-Item -Path $env:APPDATA -Name "Microsoft" -ItemType "directory"
            }
            "$teamsfolder doesn't exist, creating." | timestamp | Out-File $logfile -Append
            New-Item -Path "$env:APPDATA\Microsoft" -Name "Teams" -ItemType "directory"
        }
        "$teamsfolder\Backgrounds doesn't exist, creating." | timestamp | Out-File $logfile -Append
        New-Item -Path $teamsfolder -Name "Backgrounds" -ItemType "directory"
    }
    "$teamsfolder\Backgrounds\Uploads doesn't exist, creating." | timestamp | Out-File $logfile -Append
    New-Item -Path "$teamsfolder\Backgrounds" -Name "Uploads" -ItemType "directory"    
}
Copy-Item -Path ".\*.jpg" -Destination "$teamsfolder\Backgrounds\Uploads"
Copy-Item -Path ".\*.png" -Destination "$teamsfolder\Backgrounds\Uploads"
Get-Childitem "$teamsfolder\Backgrounds\Uploads" | ForEach-Object {$_.Name + " is in $teamsfolder\Backgrounds\Uploads" | timestamp | Out-File $logfile -Append}
"Script finished for $user" | timestamp | Out-File $logfile -Append
