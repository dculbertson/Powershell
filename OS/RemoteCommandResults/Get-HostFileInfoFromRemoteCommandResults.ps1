﻿function Get-HostFileInfoFromRemoteCommandResults {
    <#
    .SYNOPSIS
        Converts the contents of a hosts file into powershell friendly objects.
    .DESCRIPTION
        Converts the contents of a hosts file into powershell friendly objects.
    .PARAMETER InputObject
        Object or array of objects returned from Get-RemoteCommandResults
    .EXAMPLE
        PS > $Command = 'cmd.exe /C type %SystemRoot%\system32\drivers\etc\hosts'
        PS > $runcmd = @(New-RemoteCommand -RemoteCMD $command -Verbose)
        PS > $results = Get-RemoteCommandResults -InputObject $runcmd -Verbose
        PS > $HostResults = Get-HostFileInfoFromRemoteCommandResults -InputObject $results
        PS > $HostResults.HostEntries | 
               Select @{n='Computer';e={$HostResults.ComputerName}},IP,HostEntry

        Description
        -----------
        Displays all active hosts entries for the local machine.

    .NOTES
        Author: Zachary Loeber
        Site: http://www.the-little-things.net/
        Requires: Powershell 2.0

        Version History
        1.0.0 - 09/19/2013
        - Initial release
    
        ** This is a supplement function to New-RemoteCommand and Get-RemoteCommandResults **
    #>
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage='Object or array of objects returned from Get-RemoteCommandResults')]
        $InputObject
    )
    begin {
        $HostEntryResults = @()
        $Results = @()
    }
    process {
        $Results += $InputObject
    }
    end {
        Foreach ($result in $Results)
        {
            $HostsEntries = @()
            $output = $result.CommandResults
            for ($i=0; $i -lt $output.Count; $i++)
            {
                
                [regex]$r="\S"
                
                #strip out any lines beginning with # and blank lines
                if  ((($r.Match($output[$i])).value -ne "#") -and 
                      ($output[$i] -notmatch "^\s+$") -and 
                      ($output[$i].Length -gt 0))

                {
                    $output[$i] -match "(?<IP>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(?<HOSTNAME>.+$)" | Out-Null
                    $hostsentryprops = @{
                        'IP' = $matches.ip
                        'HostEntry' = $matches.hostname
                    }
                    $HostsEntries += New-Object PSObject -Property $hostsentryprops
                }
            }
            $HostsProps = @{
                'PSComputerName' = $result.PSComputerName
                'PSDateTime' = $result.PSDateTime
                'ComputerName' = $result.ComputerName
                'HostEntries' = $HostsEntries
            }
            $HostEntryResults += New-Object PSObject -Property $HostsProps
        }
        $HostEntryResults
    }
}
