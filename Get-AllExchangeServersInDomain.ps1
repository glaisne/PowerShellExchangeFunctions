function Get-AllExchangeServersInDomain($Domain=$null)
{
	$configNC=([ADSI]"LDAP:/$Forest/RootDse").configurationNamingContext
	$search = new-object DirectoryServices.DirectorySearcher([ADSI]"LDAP:/$Domain/$configNC")
	$search.Filter = "(&(objectClass=msExchExchangeServer)(msExchServerSite=*))"
	$search.PageSize=1000
	$search.PropertiesToLoad.Clear()
	[void] $search.PropertiesToLoad.Add("msexchcurrentserverroles")
	[void] $search.PropertiesToLoad.Add("networkaddress")
	[void] $search.PropertiesToLoad.Add("serialnumber")
	[void] $search.PropertiesToLoad.Add("versionNumber")
	[void] $search.PropertiesToLoad.Add("msExchServerSite")
	$servers = $search.FindAll()

	foreach ($server in $servers)
	{
		#$serverName = $server.properties["networkaddress"] | where {$_.ToString().StartsWith("ncacn_ip_tcp")} | %{$_.ToString().SubString(13)}

        if ($server.properties["networkaddress"] -contains "netbios:")
        {
            $NetBiosName = $($server.properties["networkaddress"] | where {$_.ToString().StartsWith("netbios")}).replace("netbios:","")
        }
        
        $Object = New-Object PSObject -Property @{
            Name                     = $($server.properties["networkaddress"] | where {$_.ToString().StartsWith("netbios")}).replace("netbios:","")
            FQDN                     = $($server.properties["networkaddress"] | where {$_.ToString().StartsWith("ncacn_ip_tcp:")}).replace("ncacn_ip_tcp:","")
            msExchCurrentServerRoles = $server.properties["msexchcurrentserverroles"]
            serialnumber             = $server.properties["serialnumber"][0]
            versionNumber            = $server.properties["versionNumber"]
            msExchServerSite         = $server.properties["msExchServerSite"]
        }
		Write-Output $Object
	}
}