<#
  .SYNOPSIS
  Skrypt monitoruje określony folder i automatycznie przenosi nowo dodane plik do innej lokalizacji

  .DESCRIPTION
  Skrypt będzie monitorował folder i jeśli pojawi się w nim nowy plik z rozszerzeniem txt, 
  przeniesie go do innego folderu

  .PARAMETER folderZrodlowy 
  Parametr określa ścieżkę do folderu monitorowanego przez skrypt

  .PARAMETER folderDocelowy
  Parametr określa ścieżkę do folderu, do którego skrypt przenosi pliki
  
  .EXAMPLE
  PS D:\PythonProjects> . 'D:\PythonProjects\Monitor-Folder.ps1'
  Przeniesiono plik: przykład1.txt do D:\folderDocelowy
  Monitorowanie folderu D:\folderZrodlowy rozpoczete. Nacisnij Ctrl+C, aby zatrzymac.

#>

$folderZrodlowy = "D:\folderZrodlowy"  #Zmienna odpowiadająca ścieżce do folderu monitorowanego przez skrypt
$folderDocelowy = "D:\folderDocelowy"  #Zmienna odpowiadająca ścieżce dp folderu, do którego skrypt przenosi pliki

#Funkcja tworzy folder,do którego skrypt przenosi pliki, jeśli taki folder nie istnieje
if (-not (Test-Path -Path $folderDocelowy)) {
    New-Item -ItemType Directory -Path $folderDocelowy | Out-Null
    Write-Host "Utworzono folder docelowy: $folderDocelowy"
}

#Funkcja przenosi plik z rozszerzeniem .txt do innego folderu
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

#Monitoruje folder do określonego momentu (utworzenie nowego pliku z rozszerzeniem .txt) 
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folderZrodlowy
$watcher.Filter = "*.txt"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

#Przenosi nowo utworzone pliki z rozszetzeniem .txt do innego folderu
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
#Zatrzymuje działanie skryptu
finally {
    Unregister-Event -SourceIdentifier $watcher.Created
    $watcher.Dispose()
    Write-Host "Monitorowanie zatrzymane."
}