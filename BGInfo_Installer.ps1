
# === Remove old scheduled task ===
Unregister-ScheduledTask -TaskName "BGInfo_Overlay" -Confirm:$false -ErrorAction SilentlyContinue

# === Config ===
$extractPath = "C:\BGInfo"
$taskName = "BGInfo_Overlay"
$bginfoExe = "$extractPath\BGInfo64.exe"
$bgiFile = "$extractPath\ITWurks.bgi"

Write-Host "Installing or updating BGInfo..."
Stop-Process -Name BGInfo -Force -ErrorAction SilentlyContinue

$taskName = "BGInfo_Overlay"
$bginfoExe = "$extractPath\\BGInfo64.exe"
$bgiFile = "$extractPath\\ITWurks.bgi"

# === Always install/update on each run ===

    Write-Host "Installing or updating BGInfo...Stop-Process -Name BGInfo -Force -ErrorAction SilentlyContinue
"

    # Remove old files
    if (Test-Path $extractPath) {
    

    New-Item -ItemType Directory -Force -Path $extractPath | Out-Null

# === Always replace existing BGInfo files with latest from GitHub ===
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/main/Bginfo64.exe" -OutFile "$extractPath\BGInfo64.exe" -UseBasicParsing
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/main/ITWurks.bgi" -OutFile "$extractPath\ITWurks.bgi" -UseBasicParsing

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/main/Bginfo64.exe" -OutFile "$extractPath\BGInfo64.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/main/ITWurks.bgi" -OutFile "$extractPath\ITWurks.bgi"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/refs/heads/main/IPv4.vbs" -OutFile "C:\BGInfo\IPv4.vbs"

    # Write version flag
}

# === Step 3: Register Scheduled Task (runs on user login) ===
if ((Test-Path $bginfoExe) -and (Test-Path $bgiFile)) {
    $action = New-ScheduledTaskAction -Execute $bginfoExe -Argument "`"$bgiFile`" /silent /nolicprompt /timer:0"
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Limited
    $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Description "Apply BGInfo overlay on login"

    # Register for all users (will overwrite if exists)
        Write-Host "Scheduled task '$taskName' registered."
} else {
    Write-Host "BGInfo files not found. Cannot register task."
}

# === Step 4: Run BGInfo once immediately ===
if ((Test-Path $bginfoExe) -and (Test-Path $bgiFile)) {
    Start-Process -FilePath $bginfoExe -ArgumentList "`"$bgiFile`" /silent /nolicprompt /timer:0" -WindowStyle Hidden
}

# === Save this script to disk for persistence ===
$scriptPath = "$extractPath\BGInfo_Installer.ps1"
Copy-Item -Path $MyInvocation.MyCommand.Definition -Destination $scriptPath -Force

# === Create trigger to run at logon ===
$trigger = New-ScheduledTaskTrigger -AtLogOn

# === Define action to run the saved script ===
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# === Register scheduled task ===


# === Save this script to disk for persistence ===
$scriptPath = "$extractPath\BGInfo_Installer.ps1"
Copy-Item -Path $MyInvocation.MyCommand.Definition -Destination $scriptPath -Force

# === Create trigger to run at logon ===
$trigger = New-ScheduledTaskTrigger -AtLogOn

# === Define action to run the saved script ===
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# === Register scheduled task ===
Register-ScheduledTask -TaskName "BGInfo_Overlay" -Action $action -Trigger $trigger -RunLevel Highest -Force