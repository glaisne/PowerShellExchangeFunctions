Function GetPrimarySmtpAddress
{
	<#
		.SYNOPSIS
			Gets the primary SMTP address of an object.

		.DESCRIPTION
			Gets the primary SMTP address of an object.

		.PARAMETER ProxyAddresses
			Specifies the proxyAddresses attribute to parse in order to determine
			the primary SMTP address.

		.EXAMPLE
			PS> GetPrimarySmtpAddress -ProxyAddresses $ProxyAddresses

		.INPUTS
			System.String[]

		.OUTPUTS
			System.String

		.NOTES

	#>

	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $True)]
		$ProxyAddresses
	)

	foreach ($proxyAddress In $ProxyAddresses) {
		If ([string]::Compare([string]$proxyAddress.substring(0,5),"SMTP:",$False) -eq 0)
		{
			$Result = $([string]$proxyAddress.substring(5))
		}
	}
	Return $Result
}
