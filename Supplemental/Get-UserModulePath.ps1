﻿function Get-UserModulePath { 
    $Path = $env:PSModulePath -split ";" -match $env:USERNAME | Select -First 1
 
    if (-not (Test-Path -Path $Path))     {
        New-Item -Path $Path -ItemType Container | Out-Null
    }
    
    Write-Output $Path
}
 
Invoke-Item (Get-UserModulePath)
