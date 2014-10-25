function Get-ExchangeServersInSite($siteDN="*", $Forest=$null)
{
	$configNC=([ADSI]"LDAP:/$Forest/RootDse").configurationNamingContext
	$search = new-object DirectoryServices.DirectorySearcher([ADSI]"LDAP:/$Forest/$configNC")
	$search.Filter = "(&(objectClass=msExchExchangeServer)(versionNumber>=1937801568)(msExchServerSite=$siteDN))"
	$search.PageSize=1000
	$search.PropertiesToLoad.Clear()
	[void] $search.PropertiesToLoad.Add("msexchcurrentserverroles")
	[void] $search.PropertiesToLoad.Add("networkaddress")
	[void] $search.PropertiesToLoad.Add("serialnumber")
	$servers = $search.FindAll()

	$arrServers = @()

	foreach ($server in $servers)
	{
		$serverName = $server.properties["networkaddress"] | where {$_.ToString().StartsWith("ncacn_ip_tcp")} | %{$_.ToString().SubString(13)}
		$arrServers += $serverName
	}

	return $arrServers
}