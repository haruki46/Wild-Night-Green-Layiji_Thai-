<#
.SYNOPSIS
    Builds an Aseprite extension (.aseprite-extension) from a target folder.
.DESCRIPTION
    Zips the contents of the specified folder and renames the output file to match the folder name with the .aseprite-extension extension.
.PARAMETER Folder
    The name of the folder containing the extension files (e.g., Oslar-Pallets).
.EXAMPLE
    .\build.ps1 -Folder Oslar-Pallets
#>

param (
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Folder
)

# Get the directory where the script is located
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    $ScriptDir = Get-Location
}

# Check if $Folder is an absolute path or exists directly
if ($Folder -and (Test-Path $Folder -PathType Container)) {
    $folderItem = Get-Item $Folder
    $folderPath = $folderItem.FullName
    $FolderName = $folderItem.Name
    $ScriptDir = $folderItem.Parent.FullName
} else {
    # If no folder is specified, look for folders with package.json
    if (-not $Folder) {
        $subdirs = Get-ChildItem -Path $ScriptDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName "package.json") }
        if ($subdirs.Count -eq 0) {
            Write-Error "No folders containing package.json were found in the current directory."
            exit 1
        } elseif ($subdirs.Count -eq 1) {
            $Folder = $subdirs[0].Name
            Write-Host "Automatically selected folder: $Folder"
        } else {
            Write-Host "Available extension folders:"
            for ($i = 0; $i -lt $subdirs.Count; $i++) {
                Write-Host "[$i] $($subdirs[$i].Name)"
            }
            $choice = Read-Host "Select a folder index to package"
            if ($choice -match '^\d+$' -and [int]$choice -lt $subdirs.Count) {
                $Folder = $subdirs[[int]$choice].Name
            } else {
                Write-Error "Invalid selection."
                exit 1
            }
        }
    }

    $folderPath = Join-Path $ScriptDir $Folder
    if (-not (Test-Path $folderPath -PathType Container)) {
        Write-Error "Folder '$Folder' does not exist."
        exit 1
    }
    $FolderName = (Get-Item $folderPath).Name
}

# Output file path will be in the same parent directory, named <FolderName>.aseprite-extension
$outputFile = Join-Path $ScriptDir "$FolderName.aseprite-extension"
$tempZipFile = Join-Path $ScriptDir "$FolderName.zip"

Write-Host "Packaging files from '$FolderName' into '$FolderName.aseprite-extension'..."

if (Test-Path $outputFile) {
    Write-Host "Removing existing file: $FolderName.aseprite-extension..."
    Remove-Item $outputFile -Force
}
if (Test-Path $tempZipFile) {
    Remove-Item $tempZipFile -Force
}

# Zip the contents of the folder (not the folder itself) to a temp .zip file
Get-ChildItem -Path $folderPath | Compress-Archive -DestinationPath $tempZipFile -Force

# Rename/move the .zip file to .aseprite-extension
Rename-Item -Path $tempZipFile -NewName "$FolderName.aseprite-extension" -Force

Write-Host "Extension successfully created at: $outputFile" -ForegroundColor Green
