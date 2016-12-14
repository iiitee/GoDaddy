﻿<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Update-GoDaddyAPIKey
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Key,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$Secret
    )

    Begin
    {
        
    }
    Process
    {
        # Get and set module path
        
        $Paths = @()
        
        $Path = Get-Module GoDaddyDNS | Select-Object Path
        $Path = ($Path.Path).TrimEnd('GoDaddyDNS.psd1')
        $Paths += ($Path + "Get-GoDaddyDNS.ps1")
        $Paths += ($Path + "Set-GoDaddyDNS.ps1")

        foreach ($P in $Paths)
        {
            # Get current key
            
            [string]$String = Select-String -Path $P -Pattern "Key="
            $CurrentKey = ($String.Substring($String.IndexOf("'")+1)).TrimEnd(",","'")

            # Replace current key with new key

            $Updated = (Get-Content $P).Replace($CurrentKey,$Key)

            # Update function

            Set-Content -Path $P -Value $Updated
        }
    }
    End
    {
    }
}