if (-not(Test-Path -Path "$PSScriptRoot\port-forward.tar.gz" -PathType Leaf)) {
    "port-forward.tar.gz is not found. Make sure you run this in the same directory as your tarball."
    exit
}

Write-Host "Checking if $HOME\.ssh\ exists."
if (Test-Path $HOME\.ssh\) {
    Write-Host "$HOME\.ssh\ exists."
} else {
    Write-Host "$HOME\.ssh\ does not exist. Creating a new folder..."
    New-Item -ItemType Directory -Path $HOME\.ssh\
}

Write-Host "Extracting the tarball."
tar -xvzf $PSScriptRoot\port-forward.tar.gz

Set-Location port-forwarding-data

if (Test-Path config) {
    # Continue.
} else {
    Write-Host "config was not found in the tarball. Please re-run the setup from your XDC and try again."
    exit
}

if (Test-Path merge_key) {
    # Continue.
} else {
    Write-Host "merge_key was not found in the tarball. Please re-run the setup from your XDC and try again."
    exit
}

Write-Host "Checking for config file..."

if (-not(Test-Path $HOME\.ssh\config)) {
    Write-Host "$HOME\.ssh\config does not exist. Creating the config file..."
    Copy-Item config -Destination "$HOME\.ssh\"
} else {
    Write-Host "$HOME\.ssh\config exists."

    if (Select-String -Path $HOME\.ssh\config -Pattern "Host mergejump") {
        Write-Host "Merge data already exists in the config file. Ignoring."
    }

    else {
        Write-Host "Merge data does not already exist in the config file. Appending..."
        # Adding a new line before appending the content from config into the config in \.ssh.
        Add-Content -Path $HOME\.ssh\config -Value "`n"
        Get-Content -Path config | Add-Content -Path $HOME\.ssh\config
    }
}

Write-Host "Checking if known_hosts exists..."
if (-not(Test-Path $HOME\.ssh\known_hosts)) {
    Write-Host "$HOME\.ssh\known_hosts does not exist. Creating the known_hosts file..."
    New-Item $HOME\.ssh\known_hosts -type file
} else {
    Write-Host "known_hosts exists. Ignoring..."
}

Write-Host "Moving merge_key into $HOME\.ssh..."
if ((Test-Path $HOME\.ssh\merge_key)) {
    Write-Host "merge_key already exists. Ignoring."
    Write-Host "If you want to update it, please delete it from $HOME\.ssh and re-run this script."
} else {
    Move-Item -Path merge_key -Destination $HOME\.ssh
}

Set-Location ..
Remove-Item port-forwarding-data -Recurse

Write-Host "`n"
Write-Host "Task completed. You may now delete this tarball."
Write-Host "HINT: Before deleting the tarball, view the README.md file for instructions with how to access your XDC from terminal."
Read-Host -Prompt "Press Enter to exit"