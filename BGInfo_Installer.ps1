# === Remove old scheduled task ===
Unregister-ScheduledTask -TaskName "BGInfo_Overlay" -Confirm:$false -ErrorAction SilentlyContinue

# === Config ===
$extractPath = "C:\\BGInfo"
$versionFile = "$extractPath\\BGInfo.version"
$currentVersion = "1.0"
$taskName = "BGInfo_Overlay"
$bginfoExe = "$extractPath\\BGInfo64.exe"
$bgiFile = "$extractPath\\ITWurks.bgi"

# === Step 1: Check version ===
$needsInstall = $true
if ((Test-Path $bginfoExe) -and (Test-Path $versionFile)) {
    $installedVersion = Get-Content $versionFile -ErrorAction SilentlyContinue
    if ($installedVersion -eq $currentVersion) {
        $needsInstall = $false
    }
}

# === Step 2: Install/Update if needed ===
if ($needsInstall) {
    Write-Host "Installing or updating BGInfo..."

    # Remove old files
    if (Test-Path $extractPath) {
    }

    New-Item -ItemType Directory -Force -Path $extractPath | Out-Null

# === Always replace existing BGInfo files with latest from GitHub ===
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/main/Bginfo64.exe" -OutFile "$extractPath\BGInfo64.exe" -UseBasicParsing
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/main/ITWurks.bgi" -OutFile "$extractPath\ITWurks.bgi" -UseBasicParsing

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/main/Bginfo64.exe" -OutFile "$extractPath\BGInfo64.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/main/ITWurks.bgi" -OutFile "$extractPath\ITWurks.bgi"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ITWurks/BGInfo/refs/heads/main/IPv4.vbs" -OutFile "C:\BGInfo\IPv4.vbs"

    # Write version flag
    Set-Content -Path $versionFile -Value $currentVersion
}

# === Step 3: Register Scheduled Task (runs on user login) ===
if ((Test-Path $bginfoExe) -and (Test-Path $bgiFile)) {
    $action = New-ScheduledTaskAction -Execute $bginfoExe -Argument "`"$bgiFile`" /silent /nolicprompt /timer:0"
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Limited
    $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Description "Apply BGInfo overlay on login"

    # Register for all users (will overwrite if exists)
    Register-ScheduledTask -TaskName $taskName -InputObject $task -Force
    Write-Host "Scheduled task '$taskName' registered."
} else {
    Write-Host "BGInfo files not found. Cannot register task."
}

# === Step 4: Run BGInfo once immediately ===
if ((Test-Path $bginfoExe) -and (Test-Path $bgiFile)) {
    Start-Process -FilePath $bginfoExe -ArgumentList "`"$bgiFile`" /silent /nolicprompt /timer:0" -WindowStyle Hidden
}