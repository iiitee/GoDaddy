<#
.Synopsis
   Retrieves DNS records for all domains accessible by API credentials that have dns hosted with Godaddy.
.DESCRIPTION
   Retrieves DNS records for all domains with DNS hosted with GoDaddy.
.EXAMPLE
   Get-GoDaddyAllDNSRecords
   
Retrieves DNS records for all domains accessible by API credentials that have dns hosted with Godaddy
#>
function Get-GoDaddyAllDNSRecords
{
    Param
    (
    )

    Begin {
        $apiKeySecure = Import-Csv "$PSScriptRoot\apiKey.csv"

        # Decrypt API Key
        $apiKey = @(
            [PSCustomObject]@{
                Key = [System.Net.NetworkCredential]::new("", ($apiKeySecure.Key | ConvertTo-SecureString)).Password
                Secret = [System.Net.NetworkCredential]::new("", ($apiKeySecure.Secret | ConvertTo-SecureString)).Password
            }
        )
    }
    Process {
        #---- Build authorization header ----#
        $headers = @{}
        $headers["Authorization"] = 'sso-key ' + $apiKey.key + ':' + $apiKey.secret
        
        #---- Build the request URI ----#
        $Domainuri = "https://api.godaddy.com/v1/domains?includes=nameServers"


        #---- Make the request ----#
        $DomainResult = Invoke-WebRequest -Uri $Domainuri -Method Get -Headers $headers -UseBasicParsing | ConvertFrom-Json
        
        #--- filter results to only those using Godaddy nameservers  and whose status is active---#
        $DNSHosted = $DomainResult | Where-Object { ($_.nameservers -match 'domaincontrol.com') -and ($_.status -eq 'active')}

        ForEach ($Domain in $DNSHosted.domain){
            #---- Build the request URI based on domain ----#
            $DNSuri = "https://api.godaddy.com/v1/domains/$Domain/records"

            Write-Host "Querying domain $domain"
            #---- Make the request ----#
            $DNSresult = Invoke-WebRequest -Uri $DNSuri -Method Get -Headers $headers -UseBasicParsing | ConvertFrom-Json

            #---- Convert the request data into an object ----#
            foreach ($item in $DNSresult) {
                [PSCustomObject]@{
                    domain = $Domain
                    data = $item.data
                    name = $item.name
                    ttl  = $item.ttl
                    type = $item.type
                } 
            }
            #--- wait 2 seconds for next query, godaddy API rate limited to 60 requests per minute ---#
            Start-Sleep -s 2
        }

    }
    End {
    }
}
