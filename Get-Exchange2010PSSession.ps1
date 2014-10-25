function Get-Exchange2010PSSession
{

<#
.SYNOPSIS
	Synopsis
.DESCRIPTION
	description
.EXAMPLE
	example
.PARAMETER username
	the username to modify
#>
	[CmdletBinding(SupportsShouldProcess=$true)]
	param(
		[Parameter(Mandatory=$true)]
		# ServerList is an array of FQDN server names
		[string[]]	$ServerList,
		[boolean]   $prompt = $false
	)

	begin{
		$Session = $null
	}

	Process{

		$ConnectionAttpemts = 0

		do
		{
			$ConnectionAttpemts++

			$server = get-random -inputObject $serverList

			try
			{

				if ($prompt)
				{
					$Session = New-PSSession -ConfigurationName "Microsoft.Exchange" -ConnectionUri "http://$server/PowerShell?serializationLevel=Full;ExchClientVer=14.2.247.5/" -Credential $(get-credential) #-SessionOption $psSessionOption -verbose
				}
				else
				{
					#$Session = New-PSSession -ConfigurationName "Microsoft.Exchange" -ConnectionUri "http://$server/PowerShell?serializationLevel=None/" -Authentication kerberos -SessionOption $sessionOptions
					$Session = New-PSSession -ConfigurationName "Microsoft.Exchange" -ConnectionUri "http://$server/PowerShell?serializationLevel=Full;ExchClientVer=14.2.247.5/" -Authentication kerberos #-SessionOption $psSessionOption -verbose
				}
			}
			catch
			{
				Write-host -fore red $error[0]

			}

		} until ($session -ne $null -OR $ConnectionAttpemts -gt $($serverList.Count))

		Write-Output $session

    }

    end {

    }

}

