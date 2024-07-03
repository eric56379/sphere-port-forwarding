# Set the working directory to the script's directory.
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location -Path $scriptDir

Write-Host "Checking if $HOME\.ssh\ exists."
if (Test-Path "$HOME\.ssh\") {
    Write-Host "$HOME\.ssh\ exists."
} else {
    Write-Host "$HOME\.ssh\ does not exist. Creating a new folder..."
    New-Item -ItemType Directory -Path "$HOME\.ssh\"
}

$currentDir = Get-Location
$parentDir = Split-Path -Path $currentDir -Parent

Write-Host "Current directory: $currentDir"
Write-Host "Parent directory: $parentDir"

if (Test-Path -Path "$parentDir\config") {
    Write-Host "config found in the parent directory."
    # Continue.
} else {
    Write-Host "config was not found in the parent directory. Please re-run the setup from your XDC and try again."
    exit
}

if (Test-Path -Path "$parentDir\merge_key") {
    Write-Host "merge_key found in the parent directory."
    # Continue.
} else {
    Write-Host "merge_key was not found in the parent directory. Please re-run the setup from your XDC and try again."
    exit
}

Write-Host "Checking for config file..."

if (-not(Test-Path "$HOME\.ssh\config")) {
    Write-Host "$HOME\.ssh\config does not exist. Creating the config file..."
    Copy-Item "$parentDir\config" -Destination "$HOME\.ssh\"
} else {
    Write-Host "$HOME\.ssh\config exists."

    if (Select-String -Path "$HOME\.ssh\config" -Pattern "Host mergejump") {
        Write-Host "Merge data already exists in the config file. Ignoring."
    } else {
        Write-Host "Merge data does not already exist in the config file. Appending..."
        # Adding a new line before appending the content from config into the config in \.ssh.
        Add-Content -Path "$HOME\.ssh\config" -Value "`n"
        Get-Content -Path "$parentDir\config" | Add-Content -Path "$HOME\.ssh\config"
    }
}

Write-Host "Checking if known_hosts exists..."
if (-not(Test-Path "$HOME\.ssh\known_hosts")) {
    Write-Host "$HOME\.ssh\known_hosts does not exist. Creating the known_hosts file..."
    New-Item "$HOME\.ssh\known_hosts" -type file
} else {
    Write-Host "known_hosts exists. Ignoring..."
}

Write-Host "Moving merge_key into $HOME\.ssh..."
if (Test-Path "$HOME\.ssh\merge_key") {
    Write-Host "merge_key already exists. Ignoring."
    Write-Host "If you want to update it, please delete it from $HOME\.ssh and re-run this script."
} else {
    Move-Item -Path "$parentDir\merge_key" -Destination "$HOME\.ssh\"
}

Write-Host "`n"
Write-Host "Task completed. You may now delete this zip file."
Write-Host "HINT: Before deleting the zip file, view the README.md file for instructions with how to access your XDC from terminal."
Read-Host -Prompt "Press Enter to exit"
