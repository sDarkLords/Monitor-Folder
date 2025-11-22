<#
  .SYNOPSIS
  The script monitors a specified folder and automatically moves newly added files to another location.

  .DESCRIPTION
  The script will monitor the folder and if a new file with the txt extension appears in it, 
  it will move it to another folder.

  .PARAMETER folderZrodlowy 
  This parameter specifies the path to the folder monitored by the script.

  .PARAMETER folderDocelowy
  This parameter specifies the path to the folder where the script moves files.
  
  .EXAMPLE
  PS D:\PythonProjects> . ‘D:\PythonProjects\Monitor-Folder.ps1’
  File example1.txt moved to D:\DestinationFolder
  Monitoring of folder D:\SourceFolder started. Press Ctrl+C to stop.

#>

$folderZrodlowy = "D:\folderZrodlowy"  #Variable corresponding to the path to the folder monitored by the script
$folderDocelowy = "D:\folderDocelowy"  #Variable corresponding to the path to the folder to which the script moves files

#The function creates a folder to which the script moves files if such a folder does not exist.
if (-not (Test-Path -Path $folderDocelowy)) {
    New-Item -ItemType Directory -Path $folderDocelowy | Out-Null
    Write-Host "Utworzono folder docelowy: $folderDocelowy"
}

#This function moves a file with the .txt extension to another folder.
function Move-NewTxtFiles {
    param (
        [string]$source,
        [string]$destination
    )
    
    $files = Get-ChildItem -Path $source -Filter *.txt
    
    foreach ($file in $files) {
        $destinationPath = Join-Path -Path $destination -ChildPath $file.Name
        if (-not (Test-Path -Path $destinationPath)) {
            Move-Item -Path $file.FullName -Destination $destination -Force
            Write-Host "Przeniesiono plik: $($file.Name) do $destination"
        }
    }
}

Move-NewTxtFiles -source $folderZrodlowy -destination $folderDocelowy

#Monitors a folder until a specific moment (creation of a new file with the .txt extension) 
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folderZrodlowy
$watcher.Filter = "*.txt"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

#Moves newly created files with the .txt extension to another folder
$action = {
    $filePath = $Event.SourceEventArgs.FullPath
    $fileName = $Event.SourceEventArgs.Name
    $destinationPath = Join-Path -Path $folderDocelowy -ChildPath $fileName
    
    Start-Sleep -Milliseconds 500
    
    if (Test-Path -Path $filePath) {
        Move-Item -Path $filePath -Destination $destinationPath -Force
        Write-Host "Przeniesiono nowy plik: $fileName do $folderDocelowy"
    }
}

Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action | Out-Null

Write-Host "Monitorowanie folderu $folderZrodlowy rozpoczete. Nacisnij Ctrl+C, aby zatrzymac."

try {
    do {
        Start-Sleep -Seconds 1
    } while ($true)
}
#Stops the script from running
finally {
    Unregister-Event -SourceIdentifier $watcher.Created
    $watcher.Dispose()
    Write-Host "Monitorowanie zatrzymane."

}
